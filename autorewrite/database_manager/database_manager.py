# this class is used to manage the database and execute queries to collect stats
from .enums import DBEquivalenceTestResult, DBEquivalenceTestStatus, DBPerfTestResult

class DatabaseManager:

    def __init__(self):
        pass

    """
    This function is used to test if two queries are equivalent
    The return value can be 
    """

    def test_equiv(self, query1: str, query2: str)->DBEquivalenceTestResult:
        pass
    
    """
    This function is used to collect the performance stats of a query
    """
    
    def test_perf(self, query, timeout, warmup, repeat, clear_cache=True) -> DBPerfTestResult:
        pass

    """
    This function is used to load a database from csv files and schema file
    It will return the database name and the schema name
    """

    def load_db_from_csv(self, folder_that_contains_csv, schema_file) -> (str, str):
        pass

    def _create_tables(self, schema_file):
        pass

    def _import_tables(self, folder_that_contains_csv):
        pass
