set serveroutput on size 100000
set linesize 512
set echo on
spool ods_all.log

--------------------------------------------------------------------------------
@D:/DATA/Project/q4/loader_app/sql/ods/auto/ALL.sql;
--------------------------------------------------------------------------------

@D:/DATA/Project/q4/loader_app/sql/ods/quo_interface_hdr.sql
@D:/DATA/Project/q4/loader_app/sql/ods/quo_interface_list.sql
@D:/DATA/Project/q4/loader_app/sql/ods/quo_load_seq.sql

@D:/DATA/Project/q4/loader_app/sql/ods/quo_digest_load.sql
@D:/DATA/Project/q4/loader_app/sql/ods/quo_digest.sql
@D:/DATA/Project/q4/loader_app/sql/ods/quo_digest_hist.sql

spool off

