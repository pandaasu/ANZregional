set arraysize 5000
set define '^'
set echo off
set linesize 512
set pagesize 0
set serveroutput on size 100000

-- whenever sqlerror exit;

-- Log Build
spool build_promax_px.log

-- Parameters
define BASE_PATH = ^1

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
prompt :: CDW > connect pxi/{password}@db1293t.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect pxi/Pxi1293@db1293t.ap.mars
prompt

@^BASE_PATH\oracle\common\pxi\pmx_extract_criteria.sql
create or replace public synonym pmx_extract_criteria for pxi.pmx_extract_criteria;

----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: CDW > connect pxi_app/{password}@db1293t.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect pxi_app/pxiapp1293@db1293t.ap.mars
prompt

@^BASE_PATH\oracle\common\pxi_app\pxi_common.sql
@^BASE_PATH\oracle\cdw\pxi_app\pxipmx07_extract_v2.sql
@^BASE_PATH\oracle\cdw\pxi_app\pxipmx10_extract_v2.sql
@^BASE_PATH\oracle\cdw\pxi_app\pxipmx11_loader_v2.sql


----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: IPS > connect df/{password}@ap0074t.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect df/financials@ap0074t.ap.mars
prompt

@^BASE_PATH\oracle\ips\df\jdbc_connect_config.sql
@^BASE_PATH\oracle\ips\df\px_355dmnd_history.sql
@^BASE_PATH\oracle\ips\df\px_dmnd_lookup.sql

-- Insert Config Entries into JDBC Connect Config Table

/*
-- Production
insert into df.jdbc_connect_config (connection_name, driver_class, connection_string, username, password) values (
  'PX_AU_PETCARE',
  'com.microsoft.sqlserver.jdbc.SQLServerDriver',
  'jdbc:sqlserver://wodnts5.mars-ad.net:1433;instanceName=MI0998P;databaseName=Petcare_PromaxPX_Prod',
  'PromaxPX_Reader',
  'readonly'
);
*/

-- Test
insert into df.jdbc_connect_config (connection_name, driver_class, connection_string, username, password) values (
  'PX_AU_PETCARE',
  'com.microsoft.sqlserver.jdbc.SQLServerDriver',
  'jdbc:sqlserver://mfants5.mars-ad.net:1433;instanceName=MI9997T;databaseName=PETCARE_TEST',
  'PromaxPX_Reader',
  'readonly'
);

commit;

----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: IPS > connect df_app/{password}@ap0074t.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect df_app/dftestpw@ap0074t.ap.mars
prompt

@^BASE_PATH\oracle\common\pxi_app\pxi_common.sql
@^BASE_PATH\oracle\ips\df_app\jdbc_connect.sql
@^BASE_PATH\oracle\ips\df_app\pxi_common_df.sql
@^BASE_PATH\oracle\ips\df_app\pxi_promax_connect.sql
@^BASE_PATH\oracle\ips\df_app\dfnpxi01_extract_v2.sql
@^BASE_PATH\oracle\ips\df_app\pxidfn01_loader_v2.sql


----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: LADS > connect pxi/{password}@ap0052t.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect pxi/xipch521@ap0052t.ap.mars
prompt

@^BASE_PATH\oracle\common\pxi\pmx_extract_criteria.sql
@^BASE_PATH\oracle\lads\pxi\pmx_prom_config_REFRESH_DATA.sql;


----------------------------------------------------------------------------------------
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: LADS > connect pxi_app/{password}@ap0052t.ap.mars
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
connect pxi_app/xipap395@ap0052t.ap.mars
prompt

create or replace synonym pmx_extract_criteria for pxi.pmx_extract_criteria;

@^BASE_PATH\oracle\common\pxi_app\pxi_common.sql
@^BASE_PATH\oracle\lads\pxi_app\pmxpxi01_loader_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pmxpxi02_loader_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pmxpxi03_loader_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxiatl01_extract_v2.sql -- doesn't make sense to have interface suffix ?
@^BASE_PATH\oracle\lads\pxi_app\pxipmx01_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx02_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx04_extract_v2.sql -- out of sequence as pxipmx03_extract_v2.sql is dependant on pxipmx04_extract_v2.sql 
@^BASE_PATH\oracle\lads\pxi_app\pxipmx03_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx05_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx06_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx08_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx09_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx12_extract_v2.sql
@^BASE_PATH\oracle\lads\pxi_app\pxipmx13_loader_v2.sql

----------------------------------------------------------------------------------------
prompt
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
prompt :: END
prompt :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
spool off
exit
----------------------------------------------------------------------------------------

