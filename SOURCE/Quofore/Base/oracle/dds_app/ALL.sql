set serveroutput on size 100000
set linesize 512
set echo on
spool dds_app_all.log

--------------------------------------------------------------------------------
@D:/DATA/Project/q4/loader_app/sql/dds_app/auto/ALL.sql;
--------------------------------------------------------------------------------

@D:/DATA/Project/q4/loader_app/sql/dds_app/quo_assort_pkg.sql
-- @D:/DATA/Project/q4/loader_app/sql/dds_app/quo_dist_check_pkg.sql .. replaced by [quo_act_dtl_pkg.sql]
@D:/DATA/Project/q4/loader_app/sql/dds_app/quo_act_dtl_pkg.sql

spool off

