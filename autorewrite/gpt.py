import os
from openai import OpenAI

client = OpenAI()
from typing import Annotated, Any, Literal, cast
from dataclasses import dataclass
from retry import retry
import pyglove as pg
from openai import APIConnectionError, APITimeoutError, AuthenticationError, BadRequestError, InternalServerError, RateLimitError

import concurrent.futures


@dataclass
class LMOptions:
    temperature: Annotated[
      float,
      (
          'Model temperature, which is usually between 0 and 1.0. '
          'OpenAI models have temperature range from 0.0 to 2.0.'
      )
    ] = 0.3

    # TODO: max_completion_tokens should be adjusted based on the length of the prompt.
    max_completion_tokens: int = 5000
    top_p: float = 1.0
    frequency_penalty: float = 0.0
    presence_penalty: float = 0.0

# create a class for gpt response
# including content, prompt_tokens, completion_tokens, and the cost computed using these tokens
class GptResponse:
    def __init__(self, response):
        self.content = response.choices[0].message.content
        self.prompt_tokens = response.usage.prompt_tokens
        self.reasoning_tokens = 0
        self.completion_tokens = response.usage.completion_tokens
        self.model = response.model
        self.cost = self.calculate_cost()
        
        if hasattr(response.usage.completion_tokens_details, 'reasoning_tokens'):
            self.reasoning_tokens = response.usage.completion_tokens_details.reasoning_tokens

    def calculate_cost(self):
        if self.model.startswith('gpt-4o-mini'):
            return self.prompt_tokens * 0.15 / 1000000 + self.completion_tokens * 0.6 / 1000000
        elif self.model.startswith('gpt-4o'):
            return self.prompt_tokens * 2.5 / 1000000 + self.completion_tokens * 10 / 1000000
        elif self.model.startswith('gpt-4'):
            return self.prompt_tokens * 30 / 1000000 + self.completion_tokens * 60 / 1000000
        elif self.model.startswith('o3-mini'):
            return self.prompt_tokens * 1.1 / 1000000 + (self.reasoning_tokens + self.completion_tokens) * 4.4 / 1000000
        elif self.model.startswith('o1'):
            return self.prompt_tokens * 15 / 1000000 + (self.reasoning_tokens + self.completion_tokens) * 60 / 1000000
        else:
            return 0


@pg.use_init_args(['model'])
class OpenAI(pg.Object):
    model: Annotated[
        Literal[
            'o1',
            'o3-mini',
            'gpt-4o-mini',
            'gpt-4o',
            'gpt-4',
            'gpt-4-32k',
            'gpt-3.5-turbo-0125',
        ],
        'The name of the model to use.',
    ] = 'gpt-4o'

    api_key = None

    def _on_bound(self):
        super()._on_bound()
        self.api_key = os.getenv('OPENAI_API_KEY')
        if self.api_key is None:
            raise ValueError('OPENAI_API_KEY is not set.')


    @property
    def model_id(self) -> str:
        """Returns a string to identify the model."""
        return f'OpenAI({self.model})'

    @property
    def is_reasoning_model(self):
        """Returns True if the model is a reasoning model."""
        return self.model in ['o3-mini', 'o1']

    def _get_request_args(
      self, options: LMOptions) -> dict[str, Any]:
        args = dict(
            max_completion_tokens=options.max_completion_tokens,
            top_p=options.top_p,
            frequency_penalty=options.frequency_penalty,
            presence_penalty=options.presence_penalty
        )
        args['model'] = self.model
        
        # if the model is a reasoning model, set reasoning_effort to 'medium'
        if self.is_reasoning_model:
            args['reasoning_effort'] = 'medium'
        else:
            args['temperature'] = options.temperature
        return args


    @retry((APIConnectionError, APITimeoutError, AuthenticationError, BadRequestError, InternalServerError, RateLimitError), delay=1, backoff=2, max_delay=4)
    def _open_ai_chat_completion(self, prompt: str):
        default_options = LMOptions()
        response = client.chat.completions.create(messages=[{'role': 'user', 'content': prompt}],
        **self._get_request_args(default_options))
        return GptResponse(response)



    def _chat_complete_batch(self, prompts: list[str]):
      max_workers = 6
      with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(self._open_ai_chat_completion, prompts))
      return results


    # an example of msg: [{"role": "user", "content": full_q1}]
    @retry((APIConnectionError, APITimeoutError, AuthenticationError, BadRequestError, InternalServerError, RateLimitError), delay=1, backoff=2, max_delay=4)
    def _open_ai_chat_completion_msg(self, msg: list[dict[str, str]]):
        default_options = LMOptions()
        response = client.chat.completions.create(messages=msg,
        **self._get_request_args(default_options))
        return GptResponse(response)

    def _chat_complete_batch_msg(self, msgs: list[list[dict[str, str]]]):
      max_workers = 6
      with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(self._open_ai_chat_completion_msg, msgs))
      return results

class O1(OpenAI):
    """O1 OpenAI model."""
    model = 'o1'

class O3Mini(OpenAI):
    """O3-mini OpenAI model."""
    model = 'o3-mini'

class Gpt4oMini(OpenAI):
    """GPT-4o-mini OpenAI model."""
    model = 'gpt-4o-mini'

class Gpt4o(OpenAI):
    """GPT-4o model."""
    model = 'gpt-4o'

class Gpt4(OpenAI):
    """GPT-4."""
    model = 'gpt-4'

class Gpt4_32K(Gpt4):       # pylint:disable=invalid-name
  """GPT-4 with 32K context window size."""
  model = 'gpt-4-32k'

class Gpt35Turbo_0125(OpenAI):   # pylint:disable=invalid-name
  """Gtp 3.5 Turbo 0125."""
  model = 'gpt-3.5-turbo-0125'

