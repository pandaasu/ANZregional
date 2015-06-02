set serveroutput on size 100000
set linesize 512
set echo on
spool ods.log

-- Update Interface List
@qu3_interface_list_UPDATE.sql

-- Add Columns to Tables
@qu3_act_dtl_gpa_tables_UPDATE.sql
@qu3_act_dtl_off_loc_tables_UPDATE.sql
@qu3_act_dtl_storeop_ro_tables_UPDATE.sql
@qu3_act_dtl_top_sku_tables_UPDATE.sql

-- New Tables
@qu3_act_dtl_pcking_chg_tables.sql

spool off
