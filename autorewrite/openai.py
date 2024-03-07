import os
import openai
from typing import Annotated, Any, Literal, cast
from dataclasses import dataclass
from retry import retry
import pyglove as pg
from openai.error import ServiceUnavailableError, Timeout, APIError, APIConnectionError, RateLimitError, InvalidRequestError

# import multiprocessing as mp
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

    # TODO: max_tokens should be adjusted based on the length of the prompt.
    max_tokens: int = 3000
    top_p: float = 1.0
    frequency_penalty: float = 0.0
    presence_penalty: float = 0.0
    
@pg.use_init_args(['model'])
class OpenAI(pg.Object):
    model: Annotated[
        Literal[
            'gpt-4-0125-preview',
            'gpt-4-1106-preview',
            'gpt-4',
            'gpt-4-0613',
            'gpt-4-0314',
            'gpt-4-32k',
            'gpt-4-32k-0613',
            'gpt-4-32k-0314',
            'gpt-3.5-turbo-0125',
            'gpt-3.5-turbo',
            'gpt-3.5-turbo-0613',
            'gpt-3.5-turbo-0301',
            'gpt-3.5-turbo-16k',
            'gpt-3.5-turbo-16k-0613',
            'gpt-3.5-turbo-16k-0301',
            'text-davinci-003',
            'davinci',
            'curie',
            'babbage',
            'ada',
        ],
        'The name of the model to use.',
    ] = 'gpt-3.5-turbo'
    
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
    def is_chat_model(self):
        """Returns True if the model is a chat model."""
        return self.model.startswith(('gpt-4', 'gpt-3.5-turbo'))
    
    def _get_request_args(
      self, options: LMOptions) -> dict[str, Any]:
        args = dict(
            temperature=options.temperature,
            max_tokens=options.max_tokens,
            top_p=options.top_p,
            frequency_penalty=options.frequency_penalty,
            presence_penalty=options.presence_penalty
        )

        # Completion and ChatCompletion uses different parameter name for model.
        args['model' if self.is_chat_model else 'engine'] = self.model
        return args
    

    @retry((ServiceUnavailableError, Timeout, APIError, APIConnectionError, RateLimitError, InvalidRequestError), delay=1, backoff=2, max_delay=4)
    def _open_ai_chat_completion(self, prompt: str):
        default_options = LMOptions()
        response = openai.ChatCompletion.create(
            messages=[{'role': 'user', 'content': prompt}],
            **self._get_request_args(default_options)
        )
      #   response = cast(openai_object.OpenAIObject, response)
        return response.choices[0].message.content
    
    

    def _chat_complete_batch(self, prompts: list[str]):
      max_workers = 6
      with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(self._open_ai_chat_completion, prompts))
      return results
    

    # an example of msg: [{"role": "user", "content": full_q1}]
    @retry((ServiceUnavailableError, Timeout, APIError, APIConnectionError, RateLimitError), delay=1, backoff=2, max_delay=4)
    def _open_ai_chat_completion_msg(self, msg: list[dict[str, str]]):
        default_options = LMOptions()
        response = openai.ChatCompletion.create(
            messages=msg,
            **self._get_request_args(default_options)
        )
        return response.choices[0].message.content
    
    def _chat_complete_batch_msg(self, msgs: list[list[dict[str, str]]]):
      max_workers = 6
      with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(self._open_ai_chat_completion_msg, msgs))
      return results


class Gpt_4_0125_Preview(OpenAI):
    """GPT-4 0125 Preview."""
    model = 'gpt-4-0125-preview'

class Gpt_4_1106_Preview(OpenAI):
    """GPT-4 1106 Preview."""
    model = 'gpt-4-1106-preview'


class Gpt4(OpenAI):
    """GPT-4."""
    model = 'gpt-4'


class Gpt4_0613(Gpt4):    # pylint:disable=invalid-name
    """GPT-4 0613."""
    model = 'gpt-4-0613'


class Gpt4_0314(Gpt4):   # pylint:disable=invalid-name
  """GPT-4 0314."""
  model = 'gpt-4-0314'


class Gpt4_32K(Gpt4):       # pylint:disable=invalid-name
  """GPT-4 with 32K context window size."""
  model = 'gpt-4-32k'


class Gpt4_32K_0613(Gpt4_32K):    # pylint:disable=invalid-name
  """GPT-4 32K 0613."""
  model = 'gpt-4-32k-0613'


class Gpt4_32K_0314(Gpt4_32K):   # pylint:disable=invalid-name
  """GPT-4 32K 0314."""
  model = 'gpt-4-32k-0314'


class Gpt35(OpenAI):
  """GPT-3.5. 4K max tokens, trained up on data up to Sep, 2021."""
  model = 'text-davinci-003'


class Gpt35Turbo(Gpt35):
  """Most capable GPT-3.5 model, 10x cheaper than GPT35 (text-davinci-003)."""
  model = 'gpt-3.5-turbo'

class Gpt35Turbo_0125(Gpt35Turbo):   # pylint:disable=invalid-name
  """Gtp 3.5 Turbo 0125."""
  model = 'gpt-3.5-turbo-0125'


class Gpt35Turbo_0613(Gpt35Turbo):   # pylint:disable=invalid-name
  """Gtp 3.5 Turbo 0613."""
  model = 'gpt-3.5-turbo-0613'


class Gpt35Turbo_0301(Gpt35Turbo):   # pylint:disable=invalid-name
  """Gtp 3.5 Turbo 0301."""
  model = 'gpt-3.5-turbo-0301'


class Gpt35Turbo16K(Gpt35Turbo):
  """Latest GPT-3.5 model with 16K context window size."""
  model = 'gpt-3.5-turbo-16k'


class Gpt35Turbo16K_0613(Gpt35Turbo):   # pylint:disable=invalid-name
  """Gtp 3.5 Turbo 16K 0613."""
  model = 'gpt-3.5-turbo-16k-0613'


class Gpt35Turbo16K_0301(Gpt35Turbo):   # pylint:disable=invalid-name
  """Gtp 3.5 Turbo 16K 0301."""
  model = 'gpt-3.5-turbo-16k-0301'


class Gpt3(OpenAI):
  """Most capable GPT-3 model (Davinci) 2K context window size.

  All GPT3 models have 2K max tokens and trained on data up to Oct 2019.
  """
  model = 'davinci'


class Gpt3Curie(Gpt3):
  """Very capable, but faster and lower cost than Davici."""
  model = 'curie'


class Gpt3Babbage(Gpt3):
  """Capable of straightforward tasks, very fast and low cost."""
  model = 'babbage'


class Gpt3Ada(Gpt3):
  """Capable of very simple tasks, the fastest/lowest cost among GPT3 models."""
  model = 'ada'