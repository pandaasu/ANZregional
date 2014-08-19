
set serveroutput on size 100000
set linesize 512
set define off
set echo on

  /*****************************************************************************
  ** Setup Scrips
  ******************************************************************************

    System  : qu4
    Owner   : lics_app
    Script  : qu4_setup_lics_app
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Setup LICS .. Settings / Jobs / Interfaces / Groups

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2014-05-16  Mal Chambeyron        Created
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

--------------------------------------------------------------------------------
-- Log
spool setup_lics_app.log

--------------------------------------------------------------------------------
-- Connect
connect lics_app/password@db1293t

--------------------------------------------------------------------------------
-- Setup LICS Settings
insert into lics_setting (set_group,set_code,set_value) values ('QUOFORE_QU4','EMAIL:DEFAULT','group_anz_bi_deployment_team_-_test@effem.com');
insert into lics_setting (set_group,set_code,set_value) values ('QUOFORE_QU4','SOURCE:4','Quofore - Australia Chocolate');
commit;

--------------------------------------------------------------------------------
-- Setup LICS Jobs
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('IB_QU4_01','Quofore - Australia Chocolate - Inbound - 01',null,20,null,'group_anz_bi_deployment_team_-_test@effem.com','*INBOUND','IB_QU4#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('FILE_QU4_01','Quofore - Australia Chocolate - File Processor - 01',null,20,null,'group_anz_bi_deployment_team_-_test@effem.com','*FILE','FP_QU4#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU4_PROCESS_BATCH','Quofore - Australia Chocolate - Process Batch - Every 15 Minutes',null,20,null,'group_anz_bi_deployment_team_-_test@effem.com','*PROCEDURE',null,'ods_app.QU4_batch.process_batches','sysdate','sysdate+1/96','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU4_CHECK_BATCH','Quofore - Australia Chocolate - Check Batches - Daily 07:00',null,20,null,'group_anz_bi_deployment_team_-_test@effem.com','*PROCEDURE',null,'ods_app.QU4_batch.check_batches','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');
commit;

--------------------------------------------------------------------------------
-- Setup LICS Interace Entries

insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW00','Quofore - Australia Chocolate - Digest','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW00',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw00','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW01','Quofore - Australia Chocolate - Hierarchy','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW01',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw01','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW02','Quofore - Australia Chocolate - GeneralList','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW02',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw02','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW03','Quofore - Australia Chocolate - Role','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW03',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw03','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW04','Quofore - Australia Chocolate - Position','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW04',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw04','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW05','Quofore - Australia Chocolate - Rep','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW05',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw05','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW06','Quofore - Australia Chocolate - RepAddress','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW06',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw06','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW07','Quofore - Australia Chocolate - Product','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW07',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw07','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW08','Quofore - Australia Chocolate - ProductBarcode','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW08',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw08','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW09','Quofore - Australia Chocolate - Customer','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW09',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw09','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW10','Quofore - Australia Chocolate - CustomerAddress','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW10',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw10','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW11','Quofore - Australia Chocolate - CustomerNote','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW11',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw11','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW12','Quofore - Australia Chocolate - CustomerContact','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW12',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw12','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW13','Quofore - Australia Chocolate - CustomerVisitorDay','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW13',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw13','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW14','Quofore - Australia Chocolate - AssortmentDetail','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW14',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw14','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW15','Quofore - Australia Chocolate - CustomerAssortmentDetail','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW15',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw15','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW16','Quofore - Australia Chocolate - ProductAssortmentDetail','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW16',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw16','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW17','Quofore - Australia Chocolate - AuthorisedListProduct','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW17',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw17','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW18','Quofore - Australia Chocolate - Appointment','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW18',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw18','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW19','Quofore - Australia Chocolate - CallCard','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW19',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw19','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW20','Quofore - Australia Chocolate - CallcardNote','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW20',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw20','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW21','Quofore - Australia Chocolate - OrderHeader','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW21',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw21','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW22','Quofore - Australia Chocolate - OrderDetail','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW22',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw22','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW23','Quofore - Australia Chocolate - Territory','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW23',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw23','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW24','Quofore - Australia Chocolate - CustomerTerritory','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW24',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw24','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW25','Quofore - Australia Chocolate - PositionTerritory','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW25',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw25','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW26','Quofore - Australia Chocolate - Survey','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW26',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw26','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW27','Quofore - Australia Chocolate - SurveyQuestion','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW27',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw27','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW28','Quofore - Australia Chocolate - ResponseOption','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW28',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw28','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW29','Quofore - Australia Chocolate - Task','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW29',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw29','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW30','Quofore - Australia Chocolate - TaskAssignment','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW30',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw30','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW31','Quofore - Australia Chocolate - TaskCustomer','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW31',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw31','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW32','Quofore - Australia Chocolate - TaskProduct','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW32',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw32','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW33','Quofore - Australia Chocolate - TaskSurvey','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW33',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw33','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW34','Quofore - Australia Chocolate - ActivityHeader','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW34',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw34','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW35','Quofore - Australia Chocolate - ActivityDetail_Distribution','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW35',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw35','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW36','Quofore - Australia Chocolate - ActivityDetail_Permanency','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW36',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw36','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW37','Quofore - Australia Chocolate - ActivityDetail_DisplayTradeStd','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW37',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw37','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW38','Quofore - Australia Chocolate - SurveyAnswer','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW38',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw38','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW39','Quofore - Australia Chocolate - Graveyard','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW39',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw39','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW40','Quofore - Australia Chocolate - ActivityDetail_Planogram','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW40',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw40','1','0',null,null,'*POLL','FP_QU4');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU4CDW99','Quofore - Australia Chocolate - Interface *ROUTER','*INBOUND','IB_QU4',1,7,7,'ICS_QU4CDW99',null,null,null,null,'group_anz_bi_deployment_team_-_test@effem.com',null,'ods_app.qu4_qu4cdw99','1','0',null,null,'*POLL','FP_QU4');
commit;

--------------------------------------------------------------------------------
-- Setup LICS Interface Groups
insert into lics_group (gro_group,gro_description) values ('QU4CDW_INBOUND','Quofore - Australia Chocolate - Inbound');
commit;

insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW00');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW01');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW02');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW03');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW04');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW05');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW06');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW07');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW08');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW09');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW10');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW11');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW12');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW13');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW14');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW15');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW16');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW17');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW18');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW19');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW20');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW21');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW22');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW23');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW24');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW25');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW26');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW27');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW28');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW29');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW30');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW31');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW32');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW33');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW34');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW35');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW36');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW37');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW38');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW39');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW40');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU4CDW_INBOUND','QU4CDW99');
commit;

--------------------------------------------------------------------------------
-- Create Directories
begin
  lics_directory.create_directory('ICS_QU4CDW00', '/ics/cdw/prod/inbound/qu4cdw00');
  lics_directory.create_directory('ICS_QU4CDW01', '/ics/cdw/prod/inbound/qu4cdw01');
  lics_directory.create_directory('ICS_QU4CDW02', '/ics/cdw/prod/inbound/qu4cdw02');
  lics_directory.create_directory('ICS_QU4CDW03', '/ics/cdw/prod/inbound/qu4cdw03');
  lics_directory.create_directory('ICS_QU4CDW04', '/ics/cdw/prod/inbound/qu4cdw04');
  lics_directory.create_directory('ICS_QU4CDW05', '/ics/cdw/prod/inbound/qu4cdw05');
  lics_directory.create_directory('ICS_QU4CDW06', '/ics/cdw/prod/inbound/qu4cdw06');
  lics_directory.create_directory('ICS_QU4CDW07', '/ics/cdw/prod/inbound/qu4cdw07');
  lics_directory.create_directory('ICS_QU4CDW08', '/ics/cdw/prod/inbound/qu4cdw08');
  lics_directory.create_directory('ICS_QU4CDW09', '/ics/cdw/prod/inbound/qu4cdw09');
  lics_directory.create_directory('ICS_QU4CDW10', '/ics/cdw/prod/inbound/qu4cdw10');
  lics_directory.create_directory('ICS_QU4CDW11', '/ics/cdw/prod/inbound/qu4cdw11');
  lics_directory.create_directory('ICS_QU4CDW12', '/ics/cdw/prod/inbound/qu4cdw12');
  lics_directory.create_directory('ICS_QU4CDW13', '/ics/cdw/prod/inbound/qu4cdw13');
  lics_directory.create_directory('ICS_QU4CDW14', '/ics/cdw/prod/inbound/qu4cdw14');
  lics_directory.create_directory('ICS_QU4CDW15', '/ics/cdw/prod/inbound/qu4cdw15');
  lics_directory.create_directory('ICS_QU4CDW16', '/ics/cdw/prod/inbound/qu4cdw16');
  lics_directory.create_directory('ICS_QU4CDW17', '/ics/cdw/prod/inbound/qu4cdw17');
  lics_directory.create_directory('ICS_QU4CDW18', '/ics/cdw/prod/inbound/qu4cdw18');
  lics_directory.create_directory('ICS_QU4CDW19', '/ics/cdw/prod/inbound/qu4cdw19');
  lics_directory.create_directory('ICS_QU4CDW20', '/ics/cdw/prod/inbound/qu4cdw20');
  lics_directory.create_directory('ICS_QU4CDW21', '/ics/cdw/prod/inbound/qu4cdw21');
  lics_directory.create_directory('ICS_QU4CDW22', '/ics/cdw/prod/inbound/qu4cdw22');
  lics_directory.create_directory('ICS_QU4CDW23', '/ics/cdw/prod/inbound/qu4cdw23');
  lics_directory.create_directory('ICS_QU4CDW24', '/ics/cdw/prod/inbound/qu4cdw24');
  lics_directory.create_directory('ICS_QU4CDW25', '/ics/cdw/prod/inbound/qu4cdw25');
  lics_directory.create_directory('ICS_QU4CDW26', '/ics/cdw/prod/inbound/qu4cdw26');
  lics_directory.create_directory('ICS_QU4CDW27', '/ics/cdw/prod/inbound/qu4cdw27');
  lics_directory.create_directory('ICS_QU4CDW28', '/ics/cdw/prod/inbound/qu4cdw28');
  lics_directory.create_directory('ICS_QU4CDW29', '/ics/cdw/prod/inbound/qu4cdw29');
  lics_directory.create_directory('ICS_QU4CDW30', '/ics/cdw/prod/inbound/qu4cdw30');
  lics_directory.create_directory('ICS_QU4CDW31', '/ics/cdw/prod/inbound/qu4cdw31');
  lics_directory.create_directory('ICS_QU4CDW32', '/ics/cdw/prod/inbound/qu4cdw32');
  lics_directory.create_directory('ICS_QU4CDW33', '/ics/cdw/prod/inbound/qu4cdw33');
  lics_directory.create_directory('ICS_QU4CDW34', '/ics/cdw/prod/inbound/qu4cdw34');
  lics_directory.create_directory('ICS_QU4CDW35', '/ics/cdw/prod/inbound/qu4cdw35');
  lics_directory.create_directory('ICS_QU4CDW36', '/ics/cdw/prod/inbound/qu4cdw36');
  lics_directory.create_directory('ICS_QU4CDW37', '/ics/cdw/prod/inbound/qu4cdw37');
  lics_directory.create_directory('ICS_QU4CDW38', '/ics/cdw/prod/inbound/qu4cdw38');
  lics_directory.create_directory('ICS_QU4CDW39', '/ics/cdw/prod/inbound/qu4cdw39');
  lics_directory.create_directory('ICS_QU4CDW40', '/ics/cdw/prod/inbound/qu4cdw40');
  lics_directory.create_directory('ICS_QU4CDW99', '/ics/cdw/prod/inbound/qu4cdw99');
end;
/

--------------------------------------------------------------------------------
-- Set Directory Permissions
begin
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw00');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw01');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw02');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw03');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw04');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw05');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw06');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw07');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw08');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw09');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw10');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw11');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw12');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw13');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw14');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw15');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw16');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw17');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw18');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw19');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw20');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw21');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw22');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw23');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw24');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw25');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw26');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw27');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw28');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw29');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw30');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw31');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw32');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw33');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw34');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw35');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw36');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw37');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw38');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw39');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw40');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu4cdw99');
end;
/

--------------------------------------------------------------------------------
-- Log Off
spool off

--------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------
