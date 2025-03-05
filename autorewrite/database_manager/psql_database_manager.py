# this class is an implementation of the DatabaseManager interface
# for PostgreSQL databases
# import sys
import os
# sys.path.append(os.path.abspath(os.path.dirname(__file__)))
import uuid
import glob
import csv
from .database_manager import DatabaseManager
from .enums import DBEquivalenceTestResult, DBEquivalenceTestStatus, DBPerfTestResult, DBPerfTestStatus
from typing import List
import json
import psycopg
import logging
from enum import IntEnum
from itertools import permutations
from collections import Counter
import re
from contextlib import contextmanager

class EnumEnv:
    def __init__(self, enums):
        self.enums = enums
        self.last_idx = -1
    def newly_added(self):
        if self.last_idx != -1:
            tmp = self.last_idx
            self.last_idx = len(self.enums)
            return [(i,self.enums[i]) for i in range(tmp,len(self.enums))]
        else:
            self.last_idx = len(self.enums)
            return [(i,self.enums[i]) for i in range(0,len(self.enums))]
        
def diff_table(data1, data2, consider_order=False):
    if len(data1) != len(data2):
        return True

    if consider_order:
        if data1 == data2:
            return False
    else:
        bag_semantic_data1 = dict(Counter(data1))
        bag_semantic_data2 = dict(Counter(data2))
        if bag_semantic_data1 == bag_semantic_data2:
            return False
    return True
        
def type_string(column, enums: EnumEnv):
    """
    check size of varchar and add enum type
    """
    types = column["Type"].split(",")
    data_type = types[0]
    extra_info = ""
    if data_type == "varchar" and len(types) > 1 and types[1] == "size":
        assert(column["Size"])
        extra_info = f'({column["Size"]})'
    elif data_type == "enum":
        this_enum = set(types[1:])
        try:
            index = enums.enums.index(this_enum)
        except:
            index = len(enums.enums)
            enums.enums.append(this_enum)
        data_type = f'enum{index}'
    return data_type + extra_info

def gen_create_drop_statement(schema, schema_name:str, enums:EnumEnv=EnumEnv(enums=[])):
    """
    generate CREATE/DROP TABLE statements
    """
    table_schemas = schema["Tables"]
    problem_number = schema["Problem Number"]
    create_tables = []
    drop_tables = []
    for table_schema in table_schemas:
        create_table = ["CREATE TABLE IF NOT EXISTS ",schema_name,".", table_schema["TableName"].lower(), " ("]
        fields = []
        primary_key_names = set()
        for pkey in table_schema["PKeys"]:
            fields.append(f'{pkey["Name"]} {type_string(pkey, enums)}')
            primary_key_names.add(pkey["Name"])
        for fkey in table_schema["FKeys"]:
            if fkey["FName"] in primary_key_names:
                # foreign key is also a primary key
                continue
            ptable_keys = table_schemas[int(fkey["PTable"])]["PKeys"]
            pkey = next(key for key in ptable_keys if key["Name"] == fkey["PName"])
            fields.append(f'{fkey["FName"]} {type_string(pkey, enums)}')
        for col in table_schema["Others"]:
            fields.append(f'{col["Name"]} {type_string(col, enums)}')
        if len(primary_key_names) > 0:
            pkey_list = ",".join(list(primary_key_names))
            fields.append(f"PRIMARY KEY ({pkey_list})")
        create_table.extend([", ".join(fields), ");"])
        create_tables.append("".join(create_table))
        drop_tables.append(f'DROP TABLE IF EXISTS {table_schema["TableName"]};')
    create_types = []
    drop_types = []
    for i, enum in enums.newly_added():
        enum_string = ", ".join([f"'{item}'" for item in enum])
        create_types.append(f'CREATE TYPE enum{i} AS ENUM ({enum_string});')
        drop_types.append(f'DROP TYPE IF EXISTS enum{i} CASCADE;')
    create_statement = "\n".join(create_types + create_tables)
    drop_statement = "\n".join(drop_tables + drop_types)
    return create_statement, drop_statement




class PSQLDatabaseManager(DatabaseManager):
    def __init__(self, host, user, password):
        self.host:str = host
        self.user:str = user
        self.password:str = password
        self.conn = None
        self.db_name = None
        self.schema_name = None
    
    def run_query(self, queries: List[str]):
        result = []
        with self.conn.cursor() as cur:
            for q in queries:
                try:
                    cur.execute(q)
                    result.append(cur.fetchall())
                except Exception as e:
                    cur.execute("ROLLBACK")
                    raise e
                    
        return result
    
    def _clear_cache(self):
        os.system("echo 1003 | sudo -S service postgresql stop")
        os.system('echo 1003 | sudo -S sh -c "echo 3 > /proc/sys/vm/drop_caches"')
        os.system('echo 1003 | sudo -S service postgresql start')
    
    def explain_query(self, queries: List[str]):
        result = []
        with self.conn.cursor() as cur:
            for q in queries:
                try:
                    cur.execute("EXPLAIN " + q)
                    result.append(cur.fetchall())
                except Exception as e:
                    cur.execute("ROLLBACK")
                    # raise e
                    result.append([str(e)])
                    print(e)
                    
        return result
    
    def explain_analyze_query(self, queries: List[str], timeout:float):
        result = []
        with self.conn.cursor() as cur:
            # set timeout
            cur.execute(f"SET statement_timeout = {timeout};")
            for q in queries:
                try:
                    cur.execute("EXPLAIN ANALYZE " + q)
                    result.append(cur.fetchall())
                except Exception as e:
                    cur.execute("ROLLBACK")
                    raise e
                    
        return result
          

    def test_equiv(self, query1: str, query2: str)->DBEquivalenceTestResult:
        """
        This function is used to test if two queries are equivalent
        """
        try:
            outputs = self.run_query([query1, query2])
            if len(outputs[0]) == 0 and len(outputs[1]) == 0:
                return DBEquivalenceTestResult(DBEquivalenceTestStatus.UnDetermined)
            if diff_table(outputs[0], outputs[1]):
                return DBEquivalenceTestResult(DBEquivalenceTestStatus.InEquiv)
            return DBEquivalenceTestResult(DBEquivalenceTestStatus.Equiv)
        except Exception as e:
            return DBEquivalenceTestResult(DBEquivalenceTestStatus.Error, str(e))
        
    def test_perf(self, query:str, timeout_ms:float, warmup:int, repeat:int, clear_cache:bool =True) -> DBPerfTestResult:
        result = DBPerfTestResult()
        result.runtime = timeout_ms
        # first run explain to get cost
        try:
            analyze_result = self._parse_explain_analyze(self.explain_query([query])[0])
            result.cost = analyze_result["cost"]
            result.plan = analyze_result["plan"]
            logging.info(msg=f"Finished getting cost for query {query}. The cost is {result.cost}")
        except Exception as e:
            logging.warning(msg=f"Failed to get cost using EXPLAIN for query {query}, error: {str(e)}")
            if "timeout" in str(e):
                result.runtime = -1
                result.status = DBPerfTestStatus.Timeout
                result.extra_info = str(e) + "(explain)"
                return result
            else:
                result.runtime = -1
                result.status = DBPerfTestStatus.Error
                result.extra_info = str(e) + "(explain)"
                return result
        
        # first run the query to warm up
        try:
            for i in range(warmup):
                if clear_cache:
                    self._clear_cache()
                    self.__connect_to_db_from_cache()
                self.explain_analyze_query([query], timeout_ms)
                logging.info(f"warm up for query {query} for {i} times")
        except Exception as e:
            logging.warning(msg=f"Failed to warm up for query {query} with timeout {timeout_ms} ms, error: {str(e)}")
            if "timeout" in str(e):
                result.status = DBPerfTestStatus.Timeout
                result.extra_info = str(e)
                return result
            else:
                result.status = DBPerfTestStatus.Error
                result.extra_info = str(e)
                result.runtime = -1
                return result
        
        times = []
        # then run the query to get the result
        try:
            for i in range(repeat):
                if clear_cache:
                    self._clear_cache()
                    self.__connect_to_db_from_cache()
                    
                explain_analyze_result = self._parse_explain_analyze(self.explain_analyze_query([query], timeout_ms)[0])
                result.plan = explain_analyze_result["plan"]
                times.append(explain_analyze_result["runtime"])
                logging.info(f"executed query {query} for {i} times, time: {explain_analyze_result['runtime']}")
        except Exception as e:
            logging.warning(msg=f"Failed to execute for query {query} with timeout {timeout_ms} ms, error: {str(e)}")
            if "timeout" in str(e):
                result.status = DBPerfTestStatus.Timeout
                result.extra_info = str(e)
                return result
            else:
                result.status = DBPerfTestStatus.Error
                result.extra_info = str(e)
                result.runtime = -1
                return result
        
        # then calculate the average time
        result.status = DBPerfTestStatus.Success
        result.runtime = sum(times) / len(times)
        return result
        

    
    def connect_to_db(self, database, schema):
        self.conn = psycopg.connect(f"dbname={database} host={self.host} user={self.user} password={self.password} options='-c search_path={schema}'")
        self.db_name = database
        self.schema_name = schema
    
    def __connect_to_db_from_cache(self):
        self.conn = psycopg.connect(f"dbname={self.db_name} host={self.host} user={self.user} password={self.password} options='-c search_path={self.schema_name}'")
    
    def drop_tmp_db(self):
        if self.tmp_db_name:
            tmp_conn = psycopg.connect(f"dbname=postgres host={self.host} user={self.user} password={self.password}", autocommit=True)
            with tmp_conn.cursor() as cursor:
                cursor.execute(f"DROP DATABASE IF EXISTS {self.tmp_db_name} WITH (FORCE)")
                tmp_conn.close()
  
            
    def load_db_from_csv(self, folder_that_contains_csv, schema_file) -> (str, str):
        """
        This function is used to load a database from csv files and schema file
        It will return the database name and the schema name
        """
        database = f"tmp_{uuid.uuid4().hex}"
        schema = "problem"+folder_that_contains_csv.split("/")[-1]
        
        # connect to the database to create the database
        tmp_conn = psycopg.connect(f"dbname=postgres host={self.host} user={self.user} password={self.password}", autocommit=True)
        with tmp_conn.cursor() as cursor:
            cursor.execute(f"CREATE DATABASE {database}")
        tmp_conn.close()
        tmp_conn = psycopg.connect(f"dbname={database} host={self.host} user={self.user} password={self.password} options='-c search_path={schema}'")
        
        # create the schema
        with psycopg.connect(f"dbname={database} host={self.host} user={self.user} password={self.password}", autocommit=True) as conn:
            with conn.cursor() as cursor:
                cursor.execute(f"CREATE SCHEMA {schema}")
        
        tmp_conn = psycopg.connect(f"dbname={database} host={self.host} user={self.user} password={self.password} options='-c search_path={schema}'")
        self._create_tables(schema_file, tmp_conn, schema)
        self._import_tables(folder_that_contains_csv, tmp_conn, schema, database)
        self.tmp_db_name = database
        self.tmp_schema_name = schema
        return database, schema
        
    def _parse_explain_analyze(self, explain_analyze_result):
        # this function get the explain analyze result and parse it into a dictionary {"runtime":..., "cost":..., "plan":...}
        try:
            runtime = float(re.search("Time: (\d+\.\d+) ms", explain_analyze_result[-1][0]).group(1))
        except:
            runtime = -1
        cost = float(re.search("cost=\d+\.\d+\.\.(\d+\.\d+)", explain_analyze_result[0][0]).group(1))
        plan = "\n".join([t[0] for t in explain_analyze_result[:-2]])
        return {"runtime":runtime, "cost":cost, "plan":plan}
        
    
    def _create_tables(self, schema_file, tmp_conn, schema_name):
        with open(schema_file) as f:
            schema = json.load(f)
        create_statement, drop_statement = gen_create_drop_statement(schema, schema_name)
        with tmp_conn.cursor() as cursor:
            cursor.execute(create_statement)
        tmp_conn.commit()

    def _import_tables(self, folder_that_contains_csv, tmp_conn, schema_name, database_name):
        for table in glob.glob(folder_that_contains_csv+"/*.csv"):
            table_name = table.split("/")[-1].split(".")[0].lower()
            # import the table
            with open(table) as f:
                # skip the first two lines
                f.readline()
                f.readline()
                with tmp_conn.cursor() as cur:
                    with cur.copy(f"COPY {schema_name}.{table_name} FROM STDIN WITH (FORMAT CSV)") as cp:
                        cp.write(f.read())
            tmp_conn.commit()
            # vacuum analyze the table
            with psycopg.connect(f"dbname={database_name} host={self.host} user={self.user} password={self.password}", autocommit=True) as conn:
                with conn.cursor() as cursor:
                    cursor.execute(f"VACUUM ANALYZE {schema_name}.{table_name};")
    
    def close_connection(self):
        if self.conn:
            self.conn.close()
            self.conn = None
    
        
@contextmanager
def database_connection(manager, database, schema):
    try:
        manager.connect_to_db(database, schema)
        yield
    finally:
        manager.close_connection()