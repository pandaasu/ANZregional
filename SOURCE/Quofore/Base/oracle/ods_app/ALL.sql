set serveroutput on size 100000
set linesize 512
set echo on
spool ods_app.log

--------------------------------------------------------------------------------
@D:/DATA/Project/q4/loader_app/sql/ods_app/auto/ALL.sql;
--------------------------------------------------------------------------------

@D:/DATA/Project/q4/loader_app/sql/ods_app/quo_constants.sql;
@D:/DATA/Project/q4/loader_app/sql/ods_app/quo_util.sql;
@D:/DATA/Project/q4/loader_app/sql/ods_app/quo_interface.sql;
@D:/DATA/Project/q4/loader_app/sql/ods_app/quo_batch.sql;

@D:/DATA/Project/q4/loader_app/sql/ods_app/quo_quocdw00.sql;
@D:/DATA/Project/q4/loader_app/sql/ods_app/quo_quocdw99.sql;

spool off

