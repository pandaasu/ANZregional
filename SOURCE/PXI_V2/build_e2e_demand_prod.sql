---------------------------------------------------------------------------------
-- REPLACE <password> WITH APPROPERIATE PRODUCTION SCHEMA PASSWORD BEFORE RUNNING
---------------------------------------------------------------------------------

set arraysize 5000
set define '^'
set echo off
set linesize 512
set pagesize 0
set serveroutput on size 100000

-- whenever sqlerror exit;

-- Log Build
spool build_e2e_demand_prod.log

-- Parameters
define BASE_PATH = .

----------------------------------------------------------------------------------------
-- Begin
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: BEGIN
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: BASE_PATH : [[ ^BASE_PATH ]]
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt

----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: LADS > connect pxi/{password}@ap0064p.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect pxi/<password>@ap0064p.ap.mars
prompt

@^BASE_PATH\oracle\lads\pxi\pxi_moe_attributes.sql; 
@^BASE_PATH\oracle\lads\pxi\pxi_moe_attributes.data.sql; 
@^BASE_PATH\oracle\lads\pxi\pxi_demand_group_to_account.sql;
@^BASE_PATH\oracle\lads\pxi\pxi_demand_group_to_account.data.sql;
@^BASE_PATH\oracle\lads\pxi\jdbc_connect_config.sql;
@^BASE_PATH\oracle\lads\pxi\jdbc_connect_config.data.sql;
@^BASE_PATH\oracle\lads\pxi\pxi_demand.sql;
@^BASE_PATH\oracle\lads\pxi\pxi_baseline.sql;
@^BASE_PATH\oracle\lads\pxi\pxi_estimate.sql;
@^BASE_PATH\oracle\lads\pxi\pxi_uplift.sql;

----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: LADS > connect pxi_app/{password}@ap0064p.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect pxi_app/<password>@ap0064p.ap.mars
prompt

@^BASE_PATH\oracle\lads\pxi_app\pxi.synonyms.sql
@^BASE_PATH\oracle\lads\pxi_app\pxi_e2e_demand.sql
@^BASE_PATH\oracle\lads\pxi_app\pxi_e2e_demand.body.sql
@^BASE_PATH\oracle\lads\pxi_app\pxi_e2e_demand.grants.sql
@^BASE_PATH\oracle\lads\pxi_app\flupxi01_loader.sql
@^BASE_PATH\oracle\lads\pxi_app\flupxi01_loader.body.sql
@^BASE_PATH\oracle\lads\pxi_app\flupxi01_loader.grants.sql
@^BASE_PATH\oracle\lads\pxi_app\jdbc_connect.type.sql
@^BASE_PATH\oracle\lads\pxi_app\jdbc_connect.sql
@^BASE_PATH\oracle\lads\pxi_app\jdbc_connect.java.sql
@^BASE_PATH\oracle\lads\pxi_app\jdbc_connect.body.sql
@^BASE_PATH\oracle\lads\pxi_app\pxi_promax_connect.sql
@^BASE_PATH\oracle\lads\pxi_app\pxi_promax_connect.body.sql
@^BASE_PATH\oracle\lads\pxi_app\apopxi01_loader.sql
@^BASE_PATH\oracle\lads\pxi_app\apopxi01_loader.body.sql
@^BASE_PATH\oracle\lads\pxi_app\apopxi01_loader.grants.sql
@^BASE_PATH\oracle\lads\pxi_app\pmxpxi04_loader.sql
@^BASE_PATH\oracle\lads\pxi_app\pmxpxi04_loader.body.sql
@^BASE_PATH\oracle\lads\pxi_app\pmxpxi04_loader.grants.sql
@^BASE_PATH\oracle\lads\pxi_app\pxiapo01_extract.sql
@^BASE_PATH\oracle\lads\pxi_app\pxiapo01_extract.body.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx14_extract.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx14_extract.body.sql


----------------------------------------------------------------------------------------
prompt
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: END
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
spool off
exit
----------------------------------------------------------------------------------------

