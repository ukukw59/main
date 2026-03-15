import snowflake.connector

conn = snowflake.connector.connect(
    user='UMAN',
    password='Ashvath08$GGeethA86$',
    account='VHCWREG-YM73012',
    warehouse='COMPUTE_WH',
    database='SNOWFLAKE_LEARNING_DB',
    schema='PUBLIC'
)

cs = conn.cursor()
cs.execute('SELECT COUNT(*) FROM CANDIDATE')
result = cs.fetchone()

print(f'Row count in CANDIDATE table: {result[0]}')

conn.close()
