import duckdb
import pandas as pd

def query_duckdb():
    # Connect to DuckDB (this will create an in-memory database unless you specify a file)
    connection = duckdb.connect(database=':memory:', read_only=False)

    # Query to select all rows from the provider_address_agg table
    query = "SELECT * FROM provider_address_agg;"

    # Execute the query and store the results in a pandas DataFrame
    df = connection.execute(query).fetchdf()

    # Close the connection
    connection.close()

    # Return the DataFrame (which contains the result of the query)
    return df

if __name__ == "__main__":
    # Call the query_duckdb function and print the results
    result = query_duckdb()
    print(result)