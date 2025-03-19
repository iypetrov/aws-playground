# To connec to the Oracle database

```bash
sqlplus test1234/test1234@//foo.cfs62smkw60n.eu-west-2.rds.amazonaws.com:1521/ORCL
```

# To check the database name

```sql
SELECT name FROM v$database;
```

# Create a table 

```sql
CREATE TABLE TEST1234.users (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100)
);
```

# Check the table

```sql
SELECT table_name FROM all_tables WHERE owner = 'TEST1234';
```

# Insert a record

```sql
INSERT INTO TEST1234.users (id, name) VALUES (1, 'John');
INSERT INTO TEST1234.users (id, name) VALUES (2, 'Mike');
INSERT INTO TEST1234.users (id, name) VALUES (3, 'Michelle');
```
