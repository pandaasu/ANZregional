
set serveroutput on size 100000
set linesize 512
set define off
set echo on

  /*****************************************************************************
  ** Setup Scrips
  ******************************************************************************

    System  : qu3
    Owner   : lics_app
    Script  : qu3_setup_lics_app
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    Setup LICS .. Settings / Jobs / Interfaces / Groups

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2014-05-16  Mal Chambeyron        Created
    2015-03-18  Mal Chambeyron        Add - UPDATE (where already CREATED)
                                      Can now run this to both create,
                                      and update / refresh [qu3] install
    2015-03-23  Mal Chambeyron        Update to ONLY Add Back Entities with Attributes
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

--------------------------------------------------------------------------------
-- Log
spool setup_lics_app.log

--------------------------------------------------------------------------------
-- Connect
-- connect lics_app/password@db1270p

--------------------------------------------------------------------------------
-- Setup LICS Settings

-- CREATE
insert into lics_setting (set_group,set_code,set_value) values ('QU3_WRIGLEY_NZ','EMAIL:DEFAULT','group_anz_venus_production_notification@effem.com');
commit;

-- UPDATE (where already CREATED)
update lics_setting
set set_value ='group_anz_venus_production_notification@effem.com'
where set_group = 'QU3_WRIGLEY_NZ'
and set_code ='EMAIL:DEFAULT';

commit;

--------------------------------------------------------------------------------
-- Setup LICS Jobs

-- CREATE
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('IB_QU3_01','Quofore - Wrigley New Zealand - Inbound - 01',null,20,null,'group_anz_venus_production_notification@effem.com','*INBOUND','IB_QU3#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('FILE_QU3_01','Quofore - Wrigley New Zealand - File Processor - 01',null,20,null,'group_anz_venus_production_notification@effem.com','*FILE','FP_QU3#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU3_PROCESS_BATCH','Quofore - Wrigley New Zealand - Process Batch - Every 15 Minutes',null,20,null,'group_anz_venus_production_notification@effem.com','*PROCEDURE',null,'ods_app.qu3_batch.process_batches','sysdate','sysdate+1/96','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU3_CHECK_BATCH','Quofore - Wrigley New Zealand - Check Batches - Daily 07:00',null,20,null,'group_anz_venus_production_notification@effem.com','*PROCEDURE',null,'ods_app.qu3_batch.check_batches','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');

commit;

-- UPDATE (where already CREATED)

-- deactivate existing
update lics_job
set job_status = '0'
where job_job like 'QU3%'
or job_job like '%QU3_01';

-- updates
update lics_job
set
  job_description = 'Quofore - Wrigley New Zealand - Inbound - 01',
  job_res_group = null, job_exe_history = 20, job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*INBOUND',
  job_int_group = 'IB_QU3#01',
  job_procedure = null,
  job_next = 'sysdate', job_interval = null,
  job_status = '1'
where job_job = 'IB_QU3_01';

update lics_job
set
  job_description = 'Quofore - Wrigley New Zealand - File Processor - 01',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*FILE',
  job_int_group = 'FP_QU3#01',
  job_procedure = null,
  job_next = 'sysdate',
  job_interval = null,
  job_status = '1'
where job_job = 'FILE_QU3_01';

update lics_job
set
  job_description = 'Quofore - Wrigley New Zealand - Process Batch - Every 15 Minutes',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*PROCEDURE',
  job_int_group = null,
  job_procedure = 'ods_app.qu3_batch.process_batches',
  job_next = 'sysdate',
  job_interval = 'sysdate+1/96',
  job_status = '1'
where job_job = 'QU3_PROCESS_BATCH';

update lics_job
set
  job_description = 'Quofore - Wrigley New Zealand - Check Batches - Daily 07:00',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*PROCEDURE',
  job_int_group = null,
  job_procedure = 'ods_app.qu3_batch.check_batches',
  job_next = 'lics_time.schedule_next(''*ALL'',7)',
  job_interval = 'lics_time.schedule_next(''*ALL'',7)',
  job_status = '1'
where job_job = 'QU3_CHECK_BATCH';

commit;

--------------------------------------------------------------------------------
-- Setup LICS Interace Entries

-- CREATE

-- interfaces
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW00','Quofore - Wrigley New Zealand - Digest','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW00',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw00','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW01','Quofore - Wrigley New Zealand - Hierarchy','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW01',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw01','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW02','Quofore - Wrigley New Zealand - GeneralList','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW02',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw02','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW03','Quofore - Wrigley New Zealand - Role','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW03',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw03','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW04','Quofore - Wrigley New Zealand - Position','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW04',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw04','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW05','Quofore - Wrigley New Zealand - Rep','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW05',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw05','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW06','Quofore - Wrigley New Zealand - RepAddress','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW06',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw06','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW07','Quofore - Wrigley New Zealand - Product','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW07',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw07','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW08','Quofore - Wrigley New Zealand - ProductBarcode','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW08',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw08','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW09','Quofore - Wrigley New Zealand - Customer','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW09',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw09','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW10','Quofore - Wrigley New Zealand - CustomerAddress','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW10',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw10','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW11','Quofore - Wrigley New Zealand - CustomerNote','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW11',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw11','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW12','Quofore - Wrigley New Zealand - CustomerContact','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW12',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw12','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW13','Quofore - Wrigley New Zealand - CustomerVisitorDay','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW13',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw13','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW14','Quofore - Wrigley New Zealand - AssortmentDetail','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW14',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw14','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW15','Quofore - Wrigley New Zealand - CustomerAssortmentDetail','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW15',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw15','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW16','Quofore - Wrigley New Zealand - ProductAssortmentDetail','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW16',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw16','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW17','Quofore - Wrigley New Zealand - AuthorisedListProduct','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW17',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw17','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW18','Quofore - Wrigley New Zealand - Appointment','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW18',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw18','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW19','Quofore - Wrigley New Zealand - CallCard','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW19',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw19','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW20','Quofore - Wrigley New Zealand - CallcardNote','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW20',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw20','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW21','Quofore - Wrigley New Zealand - OrderHeader','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW21',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw21','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW22','Quofore - Wrigley New Zealand - OrderDetail','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW22',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw22','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW23','Quofore - Wrigley New Zealand - Territory','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW23',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw23','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW24','Quofore - Wrigley New Zealand - CustomerTerritory','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW24',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw24','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW25','Quofore - Wrigley New Zealand - PositionTerritory','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW25',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw25','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW26','Quofore - Wrigley New Zealand - Survey','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW26',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw26','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW27','Quofore - Wrigley New Zealand - SurveyQuestion','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW27',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw27','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW28','Quofore - Wrigley New Zealand - ResponseOption','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW28',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw28','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW29','Quofore - Wrigley New Zealand - Task','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW29',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw29','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW30','Quofore - Wrigley New Zealand - TaskAssignment','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW30',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw30','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW31','Quofore - Wrigley New Zealand - TaskCustomer','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW31',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw31','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW32','Quofore - Wrigley New Zealand - TaskProduct','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW32',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw32','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW33','Quofore - Wrigley New Zealand - TaskSurvey','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW33',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw33','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW34','Quofore - Wrigley New Zealand - ActivityHeader','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW34',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw34','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW35','Quofore - Wrigley New Zealand - ActivityDetail_HotSpot','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW35',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw35','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW36','Quofore - Wrigley New Zealand - ActivityDetail_GPA','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW36',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw36','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW37','Quofore - Wrigley New Zealand - ActivityDetail_Ranging','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW37',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw37','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW38','Quofore - Wrigley New Zealand - ActivityDetail_POS','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW38',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw38','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW39','Quofore - Wrigley New Zealand - ActivityDetail_OffLocation','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW39',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw39','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW40','Quofore - Wrigley New Zealand - SurveyAnswer','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW40',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw40','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW41','Quofore - Wrigley New Zealand - Graveyard','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW41',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw41','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW42','Quofore - Wrigley New Zealand - ActivityDetail_HWAuditGroc','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW42',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw42','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW43','Quofore - Wrigley New Zealand - ActivityDetail_HardwareAuditRoute','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW43',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw43','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW44','Quofore - Wrigley New Zealand - ActivityDetail_StoreOppGrocery','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW44',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw44','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW45','Quofore - Wrigley New Zealand - ActivityDetail_StoreOppRoute','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW45',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw45','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW46','Quofore - Wrigley New Zealand - ActivityDetail_TopSkuAudit','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW46',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw46','1','0',null,null,'*POLL','FP_QU3');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW47','Quofore - Wrigley New Zealand - ActivityDetail_PackagingChgAudit','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW47',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw47','1','0',null,null,'*POLL','FP_QU3');
-- router
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU3CDW99','Quofore - Wrigley New Zealand - Interface *ROUTER','*INBOUND','IB_QU3',1,7,7,'ICS_QU3CDW99',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu3_qu3cdw99','1','0',null,null,'*POLL','FP_QU3');
commit;

-- UPDATE (where already CREATED)

-- deactivate existing
update lics_interface
set int_status = '0'
where int_interface like 'QU3CDW%';

-- updates interfaces
update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Digest',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW00',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw00',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW00';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Hierarchy',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW01',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw01',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW01';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - GeneralList',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW02',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw02',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW02';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Role',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW03',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw03',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW03';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Position',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW04',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw04',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW04';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Rep',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW05',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw05',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW05';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - RepAddress',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW06',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw06',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW06';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Product',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW07',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw07',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW07';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ProductBarcode',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW08',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw08',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW08';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Customer',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW09',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw09',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW09';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CustomerAddress',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW10',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw10',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW10';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CustomerNote',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW11',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw11',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW11';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CustomerContact',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW12',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw12',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW12';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CustomerVisitorDay',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW13',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw13',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW13';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - AssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW14',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw14',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW14';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CustomerAssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW15',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw15',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW15';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ProductAssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW16',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw16',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW16';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - AuthorisedListProduct',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW17',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw17',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW17';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Appointment',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW18',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw18',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW18';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CallCard',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW19',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw19',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW19';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CallcardNote',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW20',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw20',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW20';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - OrderHeader',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW21',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw21',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW21';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - OrderDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW22',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw22',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW22';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Territory',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW23',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw23',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW23';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - CustomerTerritory',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW24',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw24',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW24';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - PositionTerritory',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW25',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw25',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW25';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Survey',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW26',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw26',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW26';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - SurveyQuestion',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW27',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw27',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW27';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ResponseOption',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW28',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw28',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW28';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Task',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW29',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw29',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW29';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - TaskAssignment',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW30',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw30',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW30';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - TaskCustomer',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW31',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw31',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW31';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - TaskProduct',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW32',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw32',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW32';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - TaskSurvey',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW33',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw33',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW33';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityHeader',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW34',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw34',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW34';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_HotSpot',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW35',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw35',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW35';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_GPA',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW36',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw36',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW36';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_Ranging',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW37',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw37',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW37';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_POS',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW38',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw38',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW38';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_OffLocation',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW39',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw39',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW39';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - SurveyAnswer',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW40',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw40',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW40';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Graveyard',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW41',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw41',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW41';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_HWAuditGroc',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW42',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw42',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW42';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_HardwareAuditRoute',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW43',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw43',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW43';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_StoreOppGrocery',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW44',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw44',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW44';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_StoreOppRoute',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW45',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw45',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW45';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_TopSkuAudit',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW46',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw46',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW46';

update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - ActivityDetail_PackagingChgAudit',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW47',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw47',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW47';

-- updates router
update lics_interface
set
  int_description = 'Quofore - Wrigley New Zealand - Interface *ROUTER',
  int_type = '*INBOUND',
  int_group = 'IB_QU3',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU3CDW99',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu3_qu3cdw99',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU3'
where int_interface = 'QU3CDW99';

commit;


--------------------------------------------------------------------------------
-- Setup LICS Interface Groups

-- CREATE
insert into lics_group (gro_group,gro_description) values ('QU3CDW_INBOUND','Quofore - Wrigley New Zealand - Inbound');

commit;

-- UPDATE (where already CREATED)
update lics_group
set gro_description = ,'Quofore - Wrigley New Zealand - Inbound'
where gro_group = 'QU3CDW_INBOUND';

commit;

-- CREATE / UPDATE

-- cleanup
delete from lics_grp_interface
where gri_group = 'QU3CDW_INBOUND';

-- create entry for interfaces
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW00');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW01');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW02');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW03');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW04');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW05');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW06');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW07');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW08');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW09');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW10');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW11');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW12');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW13');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW14');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW15');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW16');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW17');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW18');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW19');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW20');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW21');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW22');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW23');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW24');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW25');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW26');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW27');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW28');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW29');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW30');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW31');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW32');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW33');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW34');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW35');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW36');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW37');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW38');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW39');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW40');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW41');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW42');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW43');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW44');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW45');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW46');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW47');

-- create entry for router
insert into lics_grp_interface (gri_group,gri_interface) values ('QU3CDW_INBOUND','QU3CDW99');

commit;

--------------------------------------------------------------------------------
-- Create Directories
begin
  lics_directory.create_directory('ICS_QU3CDW00', '/ics/cdw/prod/inbound/qu3cdw00');
  lics_directory.create_directory('ICS_QU3CDW01', '/ics/cdw/prod/inbound/qu3cdw01');
  lics_directory.create_directory('ICS_QU3CDW02', '/ics/cdw/prod/inbound/qu3cdw02');
  lics_directory.create_directory('ICS_QU3CDW03', '/ics/cdw/prod/inbound/qu3cdw03');
  lics_directory.create_directory('ICS_QU3CDW04', '/ics/cdw/prod/inbound/qu3cdw04');
  lics_directory.create_directory('ICS_QU3CDW05', '/ics/cdw/prod/inbound/qu3cdw05');
  lics_directory.create_directory('ICS_QU3CDW06', '/ics/cdw/prod/inbound/qu3cdw06');
  lics_directory.create_directory('ICS_QU3CDW07', '/ics/cdw/prod/inbound/qu3cdw07');
  lics_directory.create_directory('ICS_QU3CDW08', '/ics/cdw/prod/inbound/qu3cdw08');
  lics_directory.create_directory('ICS_QU3CDW09', '/ics/cdw/prod/inbound/qu3cdw09');
  lics_directory.create_directory('ICS_QU3CDW10', '/ics/cdw/prod/inbound/qu3cdw10');
  lics_directory.create_directory('ICS_QU3CDW11', '/ics/cdw/prod/inbound/qu3cdw11');
  lics_directory.create_directory('ICS_QU3CDW12', '/ics/cdw/prod/inbound/qu3cdw12');
  lics_directory.create_directory('ICS_QU3CDW13', '/ics/cdw/prod/inbound/qu3cdw13');
  lics_directory.create_directory('ICS_QU3CDW14', '/ics/cdw/prod/inbound/qu3cdw14');
  lics_directory.create_directory('ICS_QU3CDW15', '/ics/cdw/prod/inbound/qu3cdw15');
  lics_directory.create_directory('ICS_QU3CDW16', '/ics/cdw/prod/inbound/qu3cdw16');
  lics_directory.create_directory('ICS_QU3CDW17', '/ics/cdw/prod/inbound/qu3cdw17');
  lics_directory.create_directory('ICS_QU3CDW18', '/ics/cdw/prod/inbound/qu3cdw18');
  lics_directory.create_directory('ICS_QU3CDW19', '/ics/cdw/prod/inbound/qu3cdw19');
  lics_directory.create_directory('ICS_QU3CDW20', '/ics/cdw/prod/inbound/qu3cdw20');
  lics_directory.create_directory('ICS_QU3CDW21', '/ics/cdw/prod/inbound/qu3cdw21');
  lics_directory.create_directory('ICS_QU3CDW22', '/ics/cdw/prod/inbound/qu3cdw22');
  lics_directory.create_directory('ICS_QU3CDW23', '/ics/cdw/prod/inbound/qu3cdw23');
  lics_directory.create_directory('ICS_QU3CDW24', '/ics/cdw/prod/inbound/qu3cdw24');
  lics_directory.create_directory('ICS_QU3CDW25', '/ics/cdw/prod/inbound/qu3cdw25');
  lics_directory.create_directory('ICS_QU3CDW26', '/ics/cdw/prod/inbound/qu3cdw26');
  lics_directory.create_directory('ICS_QU3CDW27', '/ics/cdw/prod/inbound/qu3cdw27');
  lics_directory.create_directory('ICS_QU3CDW28', '/ics/cdw/prod/inbound/qu3cdw28');
  lics_directory.create_directory('ICS_QU3CDW29', '/ics/cdw/prod/inbound/qu3cdw29');
  lics_directory.create_directory('ICS_QU3CDW30', '/ics/cdw/prod/inbound/qu3cdw30');
  lics_directory.create_directory('ICS_QU3CDW31', '/ics/cdw/prod/inbound/qu3cdw31');
  lics_directory.create_directory('ICS_QU3CDW32', '/ics/cdw/prod/inbound/qu3cdw32');
  lics_directory.create_directory('ICS_QU3CDW33', '/ics/cdw/prod/inbound/qu3cdw33');
  lics_directory.create_directory('ICS_QU3CDW34', '/ics/cdw/prod/inbound/qu3cdw34');
  lics_directory.create_directory('ICS_QU3CDW35', '/ics/cdw/prod/inbound/qu3cdw35');
  lics_directory.create_directory('ICS_QU3CDW36', '/ics/cdw/prod/inbound/qu3cdw36');
  lics_directory.create_directory('ICS_QU3CDW37', '/ics/cdw/prod/inbound/qu3cdw37');
  lics_directory.create_directory('ICS_QU3CDW38', '/ics/cdw/prod/inbound/qu3cdw38');
  lics_directory.create_directory('ICS_QU3CDW39', '/ics/cdw/prod/inbound/qu3cdw39');
  lics_directory.create_directory('ICS_QU3CDW40', '/ics/cdw/prod/inbound/qu3cdw40');
  lics_directory.create_directory('ICS_QU3CDW41', '/ics/cdw/prod/inbound/qu3cdw41');
  lics_directory.create_directory('ICS_QU3CDW42', '/ics/cdw/prod/inbound/qu3cdw42');
  lics_directory.create_directory('ICS_QU3CDW43', '/ics/cdw/prod/inbound/qu3cdw43');
  lics_directory.create_directory('ICS_QU3CDW44', '/ics/cdw/prod/inbound/qu3cdw44');
  lics_directory.create_directory('ICS_QU3CDW45', '/ics/cdw/prod/inbound/qu3cdw45');
  lics_directory.create_directory('ICS_QU3CDW46', '/ics/cdw/prod/inbound/qu3cdw46');
  lics_directory.create_directory('ICS_QU3CDW47', '/ics/cdw/prod/inbound/qu3cdw47');
  lics_directory.create_directory('ICS_QU3CDW99', '/ics/cdw/prod/inbound/qu3cdw99');
end;
/

--------------------------------------------------------------------------------
-- Set Directory Permissions
begin
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw00');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw01');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw02');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw03');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw04');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw05');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw06');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw07');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw08');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw09');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw10');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw11');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw12');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw13');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw14');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw15');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw16');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw17');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw18');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw19');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw20');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw21');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw22');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw23');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw24');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw25');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw26');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw27');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw28');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw29');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw30');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw31');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw32');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw33');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw34');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw35');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw36');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw37');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw38');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw39');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw40');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw41');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw42');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw43');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw44');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw45');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw46');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw47');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu3cdw99');
end;
/

--------------------------------------------------------------------------------
-- Log Off
spool off

--------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------
