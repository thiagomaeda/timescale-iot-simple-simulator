import psycopg2
from pgcopy import CopyManager



CONNECTION = "<SUA_CONNECTION_STRING_AQUI>"

# insert using pgcopy
def fast_insert(conn):
    cursor = conn.cursor()
    tag = 'random_tag'
    # for sensors with ids 1-4
    for sensor_id in range(1, 4, 1):
        data = (sensor_id,tag,)
        # create random data
        simulate_query = """SELECT generate_series(now() - interval '24 hour', now(), interval '6 seconds') AS time,
                           %s as sensor_id,
                           %s as tag_name,
                           random()::text AS tag_value
                        """
        cursor.execute(simulate_query, data)
        values = cursor.fetchall()

        # column names of the table you're inserting into
        cols = ['time', 'sensor_id', 'tag_name', 'tag_value']

        # create copy manager with the target table and insert
        mgr = CopyManager(conn, 'dados_sensores', cols)
        mgr.copy(values)

    # commit after all sensor data is inserted
    # could also commit after each sensor insert is done
    conn.commit()



def main():
    with psycopg2.connect(CONNECTION) as conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM sensores")
            fast_insert(conn)
        except Exception as e:
            print(e)

main()