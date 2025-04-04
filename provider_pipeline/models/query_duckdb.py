import duckdb
import pandas as pd

def query_duckdb():
    # Connect to the DuckDB database
    connection = duckdb.connect(database='dev.duckdb', read_only=True)
    
    # Query the provider_address_agg table
    query = "SELECT * FROM provider_address_agg"
    df = connection.execute(query).fetchdf()

    # Print the result
    print(df)

if __name__ == "__main__":
    query_duckdb()