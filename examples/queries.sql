cl: call strustest;
Create table QTEMP/NETSTAT As (SELECT * FROM QSYS2.netstat_info) With Data;

SELECT * FROM QTEMP/NETSTAT Limit 10;
SELECT * FROM QTEMP/NETSTAT;

-- Processors
json: SELECT CONNECTION_TYPE, REMOTE_ADDRESS, REMOTE_PORT, REMOTE_PORT_NAME, LOCAL_ADDRESS, LOCAL_PORT, LOCAL_PORT_NAME, PROTOCOL FROM QTEMP/NETSTAT;
csv: SELECT CONNECTION_TYPE, REMOTE_ADDRESS, REMOTE_PORT, REMOTE_PORT_NAME, LOCAL_ADDRESS, LOCAL_PORT, LOCAL_PORT_NAME, PROTOCOL FROM QTEMP/NETSTAT;
rpg: SELECT CONNECTION_TYPE, REMOTE_ADDRESS, REMOTE_PORT, REMOTE_PORT_NAME, LOCAL_ADDRESS, LOCAL_PORT, LOCAL_PORT_NAME, PROTOCOL FROM QTEMP/NETSTAT;
update: SELECT CONNECTION_TYPE, REMOTE_ADDRESS, REMOTE_PORT, REMOTE_PORT_NAME, LOCAL_ADDRESS, LOCAL_PORT, LOCAL_PORT_NAME, PROTOCOL FROM QTEMP/NETSTAT;
sql: SELECT CONNECTION_TYPE, REMOTE_ADDRESS, REMOTE_PORT, REMOTE_PORT_NAME, LOCAL_ADDRESS, LOCAL_PORT, LOCAL_PORT_NAME, PROTOCOL FROM QTEMP/NETSTAT;

cl: DSPFFD FILE(QTEMP/NETSTAT) OUTPUT(*OUTFILE) OUTFILE(QTEMP/FIELDS);
select * from QTEMP/FIELDS;

udtf: With Objects As (
    select objname, objlongname, objattribute, objtype, objtext, 0 SQL_OBJECT
    from table (qsys2.object_statistics(
        object_schema => 'QSYS2',
        objtypelist => 'ALL')
    )
    where sql_object_type is null And not exists (
        select 1 FROM QSYS2.SYSTABLES where table_schema = objlib and table_name = objname and file_type = 'S'
    )
),
SQLObjects As (
    select objname, objlongname, sql_object_type, objtype, objtext, 1 SQL_OBJECT
    from table(qsys2.object_statistics(
        object_schema => 'QSYS2',
        objtypelist => 'ALL'
    ))
    where sql_object_type is not null
)
Select * From Objects
Union All
Select * From SQLObjects;

md: With Objects As (select objname, objlongname, objattribute, objtype, objtext, 0 SQL_OBJECT from table (qsys2.
        object_statistics(object_schema => 'QSYS2',
        objtypelist => 'ALL')) where sql_object_type is null And not exists (select 1 FROM QSYS2.SYSTABLES where
        table_schema = objlib and table_name = objname and file_type = 'S')),
        SQLObjects As (
    select objname, objlongname, sql_object_type, objtype, objtext, 1 SQL_OBJECT from table(qsys2.object_statistics(
        object_schema => 'QSYS2',
        objtypelist => 'ALL'
    )) where sql_object_type is not null
)
Select * From Objects
Union All
Select * From SQLObjects;

-- Bindings
SELECT * FR   dsOM QTEMP/NETSTAT whre remote_address = :w_remoteAddress and local_port = ?;
bind: '0.0.0.0' 21; -- run to select FTP server job
bind: '0.0.0.0' 23; -- run to select Telnet server job
bind: '0.0.0.0' 22; -- run to select SSH server job