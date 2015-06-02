
set serveroutput on size 100000
set linesize 512
set define off
set echo on

  /*****************************************************************************
  ** Setup Scrips
  ******************************************************************************

    System  : qu2
    Owner   : lics_app
    Script  : qu2_setup_lics_app
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    Setup LICS .. Settings / Jobs / Interfaces / Groups

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2014-05-16  Mal Chambeyron        Created
    2015-03-18  Mal Chambeyron        Add - UPDATE (where already CREATED)
                                      Can now run this to both create,
                                      and update / refresh [qu2] install
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
insert into lics_setting (set_group,set_code,set_value) values ('QU2_WRIGLEY_AU','EMAIL:DEFAULT','group_anz_venus_production_notification@effem.com');
commit;

-- UPDATE (where already CREATED)
update lics_setting
set set_value ='group_anz_venus_production_notification@effem.com'
where set_group = 'QU2_WRIGLEY_AU'
and set_code ='EMAIL:DEFAULT';

commit;

--------------------------------------------------------------------------------
-- Setup LICS Jobs

-- CREATE
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('IB_QU2_01','Quofore - Wrigley Australia - Inbound - 01',null,20,null,'group_anz_venus_production_notification@effem.com','*INBOUND','IB_QU2#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('FILE_QU2_01','Quofore - Wrigley Australia - File Processor - 01',null,20,null,'group_anz_venus_production_notification@effem.com','*FILE','FP_QU2#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU2_PROCESS_BATCH','Quofore - Wrigley Australia - Process Batch - Every 15 Minutes',null,20,null,'group_anz_venus_production_notification@effem.com','*PROCEDURE',null,'ods_app.qu2_batch.process_batches','sysdate','sysdate+1/96','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU2_CHECK_BATCH','Quofore - Wrigley Australia - Check Batches - Daily 07:00',null,20,null,'group_anz_venus_production_notification@effem.com','*PROCEDURE',null,'ods_app.qu2_batch.check_batches','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');

commit;

-- UPDATE (where already CREATED)

-- deactivate existing
update lics_job
set job_status = '0'
where job_job like 'QU2%'
or job_job like '%QU2_01';

-- updates
update lics_job
set
  job_description = 'Quofore - Wrigley Australia - Inbound - 01',
  job_res_group = null, job_exe_history = 20, job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*INBOUND',
  job_int_group = 'IB_QU2#01',
  job_procedure = null,
  job_next = 'sysdate', job_interval = null,
  job_status = '1'
where job_job = 'IB_QU2_01';

update lics_job
set
  job_description = 'Quofore - Wrigley Australia - File Processor - 01',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*FILE',
  job_int_group = 'FP_QU2#01',
  job_procedure = null,
  job_next = 'sysdate',
  job_interval = null,
  job_status = '1'
where job_job = 'FILE_QU2_01';

update lics_job
set
  job_description = 'Quofore - Wrigley Australia - Process Batch - Every 15 Minutes',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*PROCEDURE',
  job_int_group = null,
  job_procedure = 'ods_app.qu2_batch.process_batches',
  job_next = 'sysdate',
  job_interval = 'sysdate+1/96',
  job_status = '1'
where job_job = 'QU2_PROCESS_BATCH';

update lics_job
set
  job_description = 'Quofore - Wrigley Australia - Check Batches - Daily 07:00',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*PROCEDURE',
  job_int_group = null,
  job_procedure = 'ods_app.qu2_batch.check_batches',
  job_next = 'lics_time.schedule_next(''*ALL'',7)',
  job_interval = 'lics_time.schedule_next(''*ALL'',7)',
  job_status = '1'
where job_job = 'QU2_CHECK_BATCH';

commit;

--------------------------------------------------------------------------------
-- Setup LICS Interace Entries

-- CREATE

-- interfaces
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW00','Quofore - Wrigley Australia - Digest','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW00',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw00','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW01','Quofore - Wrigley Australia - Hierarchy','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW01',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw01','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW02','Quofore - Wrigley Australia - GeneralList','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW02',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw02','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW03','Quofore - Wrigley Australia - Role','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW03',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw03','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW04','Quofore - Wrigley Australia - Position','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW04',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw04','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW05','Quofore - Wrigley Australia - Rep','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW05',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw05','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW06','Quofore - Wrigley Australia - RepAddress','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW06',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw06','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW07','Quofore - Wrigley Australia - Product','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW07',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw07','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW08','Quofore - Wrigley Australia - ProductBarcode','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW08',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw08','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW09','Quofore - Wrigley Australia - Customer','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW09',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw09','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW10','Quofore - Wrigley Australia - CustomerAddress','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW10',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw10','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW11','Quofore - Wrigley Australia - CustomerNote','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW11',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw11','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW12','Quofore - Wrigley Australia - CustomerContact','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW12',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw12','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW13','Quofore - Wrigley Australia - CustomerVisitorDay','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW13',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw13','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW14','Quofore - Wrigley Australia - AssortmentDetail','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW14',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw14','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW15','Quofore - Wrigley Australia - CustomerAssortmentDetail','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW15',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw15','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW16','Quofore - Wrigley Australia - ProductAssortmentDetail','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW16',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw16','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW17','Quofore - Wrigley Australia - AuthorisedListProduct','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW17',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw17','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW18','Quofore - Wrigley Australia - Appointment','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW18',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw18','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW19','Quofore - Wrigley Australia - CallCard','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW19',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw19','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW20','Quofore - Wrigley Australia - CallcardNote','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW20',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw20','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW21','Quofore - Wrigley Australia - OrderHeader','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW21',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw21','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW22','Quofore - Wrigley Australia - OrderDetail','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW22',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw22','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW23','Quofore - Wrigley Australia - Territory','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW23',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw23','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW24','Quofore - Wrigley Australia - CustomerTerritory','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW24',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw24','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW25','Quofore - Wrigley Australia - PositionTerritory','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW25',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw25','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW26','Quofore - Wrigley Australia - Survey','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW26',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw26','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW27','Quofore - Wrigley Australia - SurveyQuestion','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW27',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw27','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW28','Quofore - Wrigley Australia - ResponseOption','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW28',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw28','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW29','Quofore - Wrigley Australia - Task','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW29',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw29','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW30','Quofore - Wrigley Australia - TaskAssignment','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW30',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw30','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW31','Quofore - Wrigley Australia - TaskCustomer','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW31',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw31','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW32','Quofore - Wrigley Australia - TaskProduct','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW32',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw32','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW33','Quofore - Wrigley Australia - TaskSurvey','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW33',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw33','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW34','Quofore - Wrigley Australia - ActivityHeader','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW34',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw34','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW35','Quofore - Wrigley Australia - ActivityDetail_ALoc','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW35',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw35','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW38','Quofore - Wrigley Australia - ActivityDetail_Sell_In','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW38',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw38','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW39','Quofore - Wrigley Australia - ActivityDetail_OffLocation','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW39',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw39','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW40','Quofore - Wrigley Australia - ActivityDetail_Facing','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW40',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw40','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW41','Quofore - Wrigley Australia - ActivityDetail_Checkout_Std','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW41',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw41','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW42','Quofore - Wrigley Australia - ActivityDetail_Checkout_ExpressQZ','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW42',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw42','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW43','Quofore - Wrigley Australia - ActivityDetail_Checkout_Express','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW43',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw43','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW44','Quofore - Wrigley Australia - ActivityDetail_Checkout_SelfscanQZ','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW44',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw44','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW45','Quofore - Wrigley Australia - ActivityDetail_Checkout_Selfscan','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW45',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw45','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW46','Quofore - Wrigley Australia - ActivityDetail_LocOOS','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW46',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw46','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW47','Quofore - Wrigley Australia - ActivityDetail_PermDisplay','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW47',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw47','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW48','Quofore - Wrigley Australia - SurveyAnswer','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW48',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw48','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW49','Quofore - Wrigley Australia - Graveyard','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW49',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw49','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW50','Quofore - Wrigley Australia - ActivityDetail_FacingAisle','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW50',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw50','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW51','Quofore - Wrigley Australia - ActivityDetail_FacingExpress','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW51',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw51','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW52','Quofore - Wrigley Australia - ActivityDetail_FacingSelfScan','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW52',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw52','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW53','Quofore - Wrigley Australia - ActivityDetail_FacingStandard','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW53',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw53','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW54','Quofore - Wrigley Australia - ActivityDetail_CompetitionAct','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW54',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw54','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW55','Quofore - Wrigley Australia - ActivityDetail_CompetitionFacings','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW55',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw55','1','0',null,null,'*POLL','FP_QU2');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW56','Quofore - Wrigley Australia - ActivityDetail_ExecCompliance','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW56',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw56','1','0',null,null,'*POLL','FP_QU2');
-- router
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU2CDW99','Quofore - Wrigley Australia - Interface *ROUTER','*INBOUND','IB_QU2',1,7,7,'ICS_QU2CDW99',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu2_qu2cdw99','1','0',null,null,'*POLL','FP_QU2');
commit;

-- UPDATE (where already CREATED)

-- deactivate existing
update lics_interface
set int_status = '0'
where int_interface like 'QU2CDW%';

-- updates interfaces
update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Digest',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW00',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw00',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW00';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Hierarchy',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW01',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw01',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW01';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - GeneralList',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW02',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw02',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW02';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Role',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW03',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw03',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW03';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Position',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW04',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw04',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW04';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Rep',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW05',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw05',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW05';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - RepAddress',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW06',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw06',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW06';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Product',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW07',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw07',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW07';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ProductBarcode',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW08',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw08',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW08';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Customer',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW09',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw09',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW09';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CustomerAddress',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW10',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw10',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW10';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CustomerNote',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW11',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw11',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW11';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CustomerContact',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW12',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw12',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW12';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CustomerVisitorDay',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW13',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw13',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW13';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - AssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW14',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw14',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW14';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CustomerAssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW15',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw15',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW15';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ProductAssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW16',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw16',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW16';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - AuthorisedListProduct',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW17',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw17',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW17';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Appointment',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW18',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw18',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW18';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CallCard',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW19',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw19',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW19';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CallcardNote',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW20',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw20',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW20';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - OrderHeader',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW21',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw21',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW21';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - OrderDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW22',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw22',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW22';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Territory',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW23',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw23',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW23';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - CustomerTerritory',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW24',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw24',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW24';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - PositionTerritory',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW25',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw25',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW25';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Survey',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW26',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw26',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW26';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - SurveyQuestion',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW27',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw27',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW27';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ResponseOption',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW28',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw28',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW28';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Task',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW29',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw29',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW29';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - TaskAssignment',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW30',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw30',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW30';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - TaskCustomer',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW31',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw31',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW31';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - TaskProduct',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW32',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw32',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW32';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - TaskSurvey',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW33',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw33',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW33';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityHeader',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW34',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw34',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW34';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_ALoc',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW35',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw35',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW35';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Sell_In',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW38',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw38',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW38';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_OffLocation',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW39',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw39',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW39';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Facing',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW40',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw40',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW40';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Checkout_Std',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW41',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw41',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW41';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Checkout_ExpressQZ',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW42',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw42',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW42';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Checkout_Express',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW43',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw43',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW43';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Checkout_SelfscanQZ',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW44',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw44',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW44';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_Checkout_Selfscan',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW45',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw45',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW45';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_LocOOS',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW46',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw46',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW46';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_PermDisplay',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW47',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw47',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW47';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - SurveyAnswer',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW48',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw48',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW48';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Graveyard',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW49',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw49',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW49';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_FacingAisle',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW50',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw50',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW50';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_FacingExpress',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW51',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw51',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW51';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_FacingSelfScan',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW52',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw52',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW52';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_FacingStandard',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW53',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw53',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW53';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_CompetitionAct',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW54',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw54',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW54';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_CompetitionFacings',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW55',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw55',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW55';

update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - ActivityDetail_ExecCompliance',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW56',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw56',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW56';

-- updates router
update lics_interface
set
  int_description = 'Quofore - Wrigley Australia - Interface *ROUTER',
  int_type = '*INBOUND',
  int_group = 'IB_QU2',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU2CDW99',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu2_qu2cdw99',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU2'
where int_interface = 'QU2CDW99';

commit;


--------------------------------------------------------------------------------
-- Setup LICS Interface Groups

-- CREATE
insert into lics_group (gro_group,gro_description) values ('QU2CDW_INBOUND','Quofore - Wrigley Australia - Inbound');

commit;

-- UPDATE (where already CREATED)
update lics_group
set gro_description = ,'Quofore - Wrigley Australia - Inbound'
where gro_group = 'QU2CDW_INBOUND';

commit;

-- CREATE / UPDATE

-- cleanup
delete from lics_grp_interface
where gri_group = 'QU2CDW_INBOUND';

-- create entry for interfaces
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW00');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW01');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW02');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW03');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW04');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW05');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW06');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW07');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW08');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW09');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW10');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW11');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW12');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW13');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW14');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW15');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW16');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW17');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW18');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW19');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW20');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW21');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW22');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW23');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW24');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW25');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW26');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW27');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW28');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW29');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW30');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW31');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW32');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW33');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW34');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW35');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW38');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW39');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW40');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW41');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW42');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW43');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW44');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW45');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW46');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW47');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW48');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW49');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW50');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW51');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW52');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW53');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW54');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW55');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW56');

-- create entry for router
insert into lics_grp_interface (gri_group,gri_interface) values ('QU2CDW_INBOUND','QU2CDW99');

commit;

--------------------------------------------------------------------------------
-- Create Directories
begin
  lics_directory.create_directory('ICS_QU2CDW00', '/ics/cdw/prod/inbound/qu2cdw00');
  lics_directory.create_directory('ICS_QU2CDW01', '/ics/cdw/prod/inbound/qu2cdw01');
  lics_directory.create_directory('ICS_QU2CDW02', '/ics/cdw/prod/inbound/qu2cdw02');
  lics_directory.create_directory('ICS_QU2CDW03', '/ics/cdw/prod/inbound/qu2cdw03');
  lics_directory.create_directory('ICS_QU2CDW04', '/ics/cdw/prod/inbound/qu2cdw04');
  lics_directory.create_directory('ICS_QU2CDW05', '/ics/cdw/prod/inbound/qu2cdw05');
  lics_directory.create_directory('ICS_QU2CDW06', '/ics/cdw/prod/inbound/qu2cdw06');
  lics_directory.create_directory('ICS_QU2CDW07', '/ics/cdw/prod/inbound/qu2cdw07');
  lics_directory.create_directory('ICS_QU2CDW08', '/ics/cdw/prod/inbound/qu2cdw08');
  lics_directory.create_directory('ICS_QU2CDW09', '/ics/cdw/prod/inbound/qu2cdw09');
  lics_directory.create_directory('ICS_QU2CDW10', '/ics/cdw/prod/inbound/qu2cdw10');
  lics_directory.create_directory('ICS_QU2CDW11', '/ics/cdw/prod/inbound/qu2cdw11');
  lics_directory.create_directory('ICS_QU2CDW12', '/ics/cdw/prod/inbound/qu2cdw12');
  lics_directory.create_directory('ICS_QU2CDW13', '/ics/cdw/prod/inbound/qu2cdw13');
  lics_directory.create_directory('ICS_QU2CDW14', '/ics/cdw/prod/inbound/qu2cdw14');
  lics_directory.create_directory('ICS_QU2CDW15', '/ics/cdw/prod/inbound/qu2cdw15');
  lics_directory.create_directory('ICS_QU2CDW16', '/ics/cdw/prod/inbound/qu2cdw16');
  lics_directory.create_directory('ICS_QU2CDW17', '/ics/cdw/prod/inbound/qu2cdw17');
  lics_directory.create_directory('ICS_QU2CDW18', '/ics/cdw/prod/inbound/qu2cdw18');
  lics_directory.create_directory('ICS_QU2CDW19', '/ics/cdw/prod/inbound/qu2cdw19');
  lics_directory.create_directory('ICS_QU2CDW20', '/ics/cdw/prod/inbound/qu2cdw20');
  lics_directory.create_directory('ICS_QU2CDW21', '/ics/cdw/prod/inbound/qu2cdw21');
  lics_directory.create_directory('ICS_QU2CDW22', '/ics/cdw/prod/inbound/qu2cdw22');
  lics_directory.create_directory('ICS_QU2CDW23', '/ics/cdw/prod/inbound/qu2cdw23');
  lics_directory.create_directory('ICS_QU2CDW24', '/ics/cdw/prod/inbound/qu2cdw24');
  lics_directory.create_directory('ICS_QU2CDW25', '/ics/cdw/prod/inbound/qu2cdw25');
  lics_directory.create_directory('ICS_QU2CDW26', '/ics/cdw/prod/inbound/qu2cdw26');
  lics_directory.create_directory('ICS_QU2CDW27', '/ics/cdw/prod/inbound/qu2cdw27');
  lics_directory.create_directory('ICS_QU2CDW28', '/ics/cdw/prod/inbound/qu2cdw28');
  lics_directory.create_directory('ICS_QU2CDW29', '/ics/cdw/prod/inbound/qu2cdw29');
  lics_directory.create_directory('ICS_QU2CDW30', '/ics/cdw/prod/inbound/qu2cdw30');
  lics_directory.create_directory('ICS_QU2CDW31', '/ics/cdw/prod/inbound/qu2cdw31');
  lics_directory.create_directory('ICS_QU2CDW32', '/ics/cdw/prod/inbound/qu2cdw32');
  lics_directory.create_directory('ICS_QU2CDW33', '/ics/cdw/prod/inbound/qu2cdw33');
  lics_directory.create_directory('ICS_QU2CDW34', '/ics/cdw/prod/inbound/qu2cdw34');
  lics_directory.create_directory('ICS_QU2CDW35', '/ics/cdw/prod/inbound/qu2cdw35');
  lics_directory.create_directory('ICS_QU2CDW38', '/ics/cdw/prod/inbound/qu2cdw38');
  lics_directory.create_directory('ICS_QU2CDW39', '/ics/cdw/prod/inbound/qu2cdw39');
  lics_directory.create_directory('ICS_QU2CDW40', '/ics/cdw/prod/inbound/qu2cdw40');
  lics_directory.create_directory('ICS_QU2CDW41', '/ics/cdw/prod/inbound/qu2cdw41');
  lics_directory.create_directory('ICS_QU2CDW42', '/ics/cdw/prod/inbound/qu2cdw42');
  lics_directory.create_directory('ICS_QU2CDW43', '/ics/cdw/prod/inbound/qu2cdw43');
  lics_directory.create_directory('ICS_QU2CDW44', '/ics/cdw/prod/inbound/qu2cdw44');
  lics_directory.create_directory('ICS_QU2CDW45', '/ics/cdw/prod/inbound/qu2cdw45');
  lics_directory.create_directory('ICS_QU2CDW46', '/ics/cdw/prod/inbound/qu2cdw46');
  lics_directory.create_directory('ICS_QU2CDW47', '/ics/cdw/prod/inbound/qu2cdw47');
  lics_directory.create_directory('ICS_QU2CDW48', '/ics/cdw/prod/inbound/qu2cdw48');
  lics_directory.create_directory('ICS_QU2CDW49', '/ics/cdw/prod/inbound/qu2cdw49');
  lics_directory.create_directory('ICS_QU2CDW50', '/ics/cdw/prod/inbound/qu2cdw50');
  lics_directory.create_directory('ICS_QU2CDW51', '/ics/cdw/prod/inbound/qu2cdw51');
  lics_directory.create_directory('ICS_QU2CDW52', '/ics/cdw/prod/inbound/qu2cdw52');
  lics_directory.create_directory('ICS_QU2CDW53', '/ics/cdw/prod/inbound/qu2cdw53');
  lics_directory.create_directory('ICS_QU2CDW54', '/ics/cdw/prod/inbound/qu2cdw54');
  lics_directory.create_directory('ICS_QU2CDW55', '/ics/cdw/prod/inbound/qu2cdw55');
  lics_directory.create_directory('ICS_QU2CDW56', '/ics/cdw/prod/inbound/qu2cdw56');
  lics_directory.create_directory('ICS_QU2CDW99', '/ics/cdw/prod/inbound/qu2cdw99');
end;
/

--------------------------------------------------------------------------------
-- Set Directory Permissions
begin
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw00');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw01');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw02');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw03');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw04');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw05');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw06');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw07');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw08');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw09');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw10');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw11');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw12');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw13');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw14');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw15');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw16');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw17');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw18');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw19');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw20');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw21');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw22');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw23');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw24');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw25');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw26');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw27');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw28');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw29');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw30');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw31');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw32');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw33');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw34');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw35');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw38');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw39');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw40');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw41');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw42');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw43');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw44');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw45');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw46');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw47');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw48');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw49');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw50');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw51');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw52');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw53');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw54');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw55');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw56');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu2cdw99');
end;
/

--------------------------------------------------------------------------------
-- Log Off
spool off

--------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------
