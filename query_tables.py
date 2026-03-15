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
cs.execute('SHOW TABLES')
tables = cs.fetchall()

print('Tables in SNOWFLAKE_LEARNING_DB.PUBLIC:')
for table in tables:
    print('-', table[1])

conn.close()