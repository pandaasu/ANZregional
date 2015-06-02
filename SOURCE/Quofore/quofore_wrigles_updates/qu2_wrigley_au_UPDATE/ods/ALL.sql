set serveroutput on size 100000
set linesize 512
set echo on
spool ods.log

-- Update Interface List
@qu2_interface_list_UPDATE.sql

-- Add Columns to Tables
@qu2_act_dtl_a_loc_UPDATE.sql
@qu2_act_dtl_off_loc_UPDATE.sql
@qu2_act_hdr_UPDATE.sql

-- New Tables
@qu2_act_dtl_comp_act_tables.sql;
@qu2_act_dtl_comp_face_tables.sql;
@qu2_act_dtl_exec_compl_tables.sql;

spool off
