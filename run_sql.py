import duckdb

# Connect to DuckDB
con = duckdb.connect()

# Read SQL file
with open("sql/telecom_churn_analysis.sql", "r") as file:
    sql = file.read()

# Execute SQL
result = con.execute(sql)

# Display result
print(result.fetchall())

# Close connection
con.close()