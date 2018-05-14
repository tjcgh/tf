import pg8000

def handler(event, context):
    print('starting here')
    connection = pg8000.connect(user='admin_user', password='!Race2Win!', host='dev001.cqgqlfkgvtei.us-west-1.rds.amazonaws.com', database='dev001')
    print('connected')
    item_count = 0
    with connection.cursor() as cur:
        cur.execute("create table Employee1 ( EmpID  int NOT NULL, Name varchar(255) NOT NULL, PRIMARY KEY (EmpID))")
        print('creating db')
        cur.execute("insert into Employee1 (EmpID, Name) values(1, 'Joe')")
        print('inderting record 1')
        cur.execute("insert into Employee1 (EmpID, Name) values(2, 'Bob')")
        print('inderting record 2')
        cur.execute("insert into Employee1 (EmpID, Name) values(3, 'Mary')")
        print('inderting record 3')
        connection.commit()
        print('commiting changes')
        cur.execute("select * from Employee1")
        for row in cur:
            item_count += 1
    print('Added %d items from RDS Postgres table' %(item_count))    
    return "Added %d items from RDS Postgres table" %(item_count)