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

# Check the records

```sql
SELECT * FROM TEST1234.users;
```


don't work
```yaml
- expdp ${DB_USERNAME}/${DB_PASSWORD}@qato01.ck7fba7fypan.eu-central-1.rds.amazonaws.com:1521/QATO01 \
  DIRECTORY=DATA_PUMP_DIR \
  DUMPFILE=coremaster_sys_sandbox_backup_${rand}.dmp \
  LOGFILE=coremaster_sys_sandbox_backup_${rand}.log \
  SCHEMAS=COREMASTER_SYS;
- impdp ${DB_USERNAME}/${DB_PASSWORD}@qato01.ck7fba7fypan.eu-central-1.rds.amazonaws.com:1521/QATO01 \
  DIRECTORY=DATA_PUMP_DIR \
  DUMPFILE=coremaster_sys_sandbox_backup_${rand}.dmp \
  LOGFILE=coremaster_sandbox_sys_import_${rand}.log \
  REMAP_SCHEMA=COREMASTER_SYS:COREMASTER_SANDBOX_SYS \
  TABLE_EXISTS_ACTION=REPLACE || true```
```
