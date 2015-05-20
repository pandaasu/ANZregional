
set serveroutput on size 100000
set linesize 512
set define off
set echo on

  /*****************************************************************************
  ** Setup Scrips
  ******************************************************************************

    System  : qu5
    Owner   : lics_app
    Script  : qu5_setup_lics_app
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    Setup LICS .. Settings / Jobs / Interfaces / Groups

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2014-05-16  Mal Chambeyron        Created
    2015-03-18  Mal Chambeyron        Add - UPDATE (where already CREATED)
                                      Can now run this to both create,
                                      and update / refresh [qu5] install
    2015-03-23  Mal Chambeyron        Update to ONLY Add Back Entities with Attributes
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

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
insert into lics_setting (set_group,set_code,set_value) values ('QU5_MARS_NZ','EMAIL:DEFAULT','group_anz_venus_production_notification@effem.com');
commit;

-- UPDATE (where already CREATED)
update lics_setting
set set_value ='group_anz_venus_production_notification@effem.com'
where set_group = 'QU5_MARS_NZ'
and set_code ='EMAIL:DEFAULT';

commit;

--------------------------------------------------------------------------------
-- Setup LICS Jobs

-- CREATE
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('IB_QU5_01','Quofore - Mars New Zealand - Inbound - 01',null,20,null,'group_anz_venus_production_notification@effem.com','*INBOUND','IB_QU5#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('FILE_QU5_01','Quofore - Mars New Zealand - File Processor - 01',null,20,null,'group_anz_venus_production_notification@effem.com','*FILE','FP_QU5#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU5_PROCESS_BATCH','Quofore - Mars New Zealand - Process Batch - Every 15 Minutes',null,20,null,'group_anz_venus_production_notification@effem.com','*PROCEDURE',null,'ods_app.qu5_batch.process_batches','sysdate','sysdate+1/96','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QU5_CHECK_BATCH','Quofore - Mars New Zealand - Check Batches - Daily 07:00',null,20,null,'group_anz_venus_production_notification@effem.com','*PROCEDURE',null,'ods_app.qu5_batch.check_batches','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');

commit;

-- UPDATE (where already CREATED)

-- deactivate existing
update lics_job
set job_status = '0'
where job_job like 'QU5%'
or job_job like '%QU5_01';

-- updates
update lics_job
set
  job_description = 'Quofore - Mars New Zealand - Inbound - 01',
  job_res_group = null, job_exe_history = 20, job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*INBOUND',
  job_int_group = 'IB_QU5#01',
  job_procedure = null,
  job_next = 'sysdate', job_interval = null,
  job_status = '1'
where job_job = 'IB_QU5_01';

update lics_job
set
  job_description = 'Quofore - Mars New Zealand - File Processor - 01',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*FILE',
  job_int_group = 'FP_QU5#01',
  job_procedure = null,
  job_next = 'sysdate',
  job_interval = null,
  job_status = '1'
where job_job = 'FILE_QU5_01';

update lics_job
set
  job_description = 'Quofore - Mars New Zealand - Process Batch - Every 15 Minutes',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*PROCEDURE',
  job_int_group = null,
  job_procedure = 'ods_app.qu5_batch.process_batches',
  job_next = 'sysdate',
  job_interval = 'sysdate+1/96',
  job_status = '1'
where job_job = 'QU5_PROCESS_BATCH';

update lics_job
set
  job_description = 'Quofore - Mars New Zealand - Check Batches - Daily 07:00',
  job_res_group = null,
  job_exe_history = 20,
  job_opr_alert = null,
  job_ema_group = 'group_anz_venus_production_notification@effem.com',
  job_type = '*PROCEDURE',
  job_int_group = null,
  job_procedure = 'ods_app.qu5_batch.check_batches',
  job_next = 'lics_time.schedule_next(''*ALL'',7)',
  job_interval = 'lics_time.schedule_next(''*ALL'',7)',
  job_status = '1'
where job_job = 'QU5_CHECK_BATCH';

commit;

--------------------------------------------------------------------------------
-- Setup LICS Interace Entries

-- CREATE

-- interfaces
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW00','Quofore - Mars New Zealand - Digest','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW00',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw00','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW01','Quofore - Mars New Zealand - Hierarchy','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW01',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw01','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW02','Quofore - Mars New Zealand - GeneralList','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW02',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw02','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW03','Quofore - Mars New Zealand - Role','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW03',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw03','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW04','Quofore - Mars New Zealand - Position','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW04',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw04','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW05','Quofore - Mars New Zealand - Rep','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW05',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw05','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW06','Quofore - Mars New Zealand - RepAddress','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW06',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw06','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW07','Quofore - Mars New Zealand - Product','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW07',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw07','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW08','Quofore - Mars New Zealand - ProductBarcode','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW08',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw08','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW09','Quofore - Mars New Zealand - Customer','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW09',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw09','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW10','Quofore - Mars New Zealand - CustomerAddress','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW10',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw10','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW11','Quofore - Mars New Zealand - CustomerNote','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW11',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw11','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW12','Quofore - Mars New Zealand - CustomerContact','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW12',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw12','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW13','Quofore - Mars New Zealand - CustomerVisitorDay','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW13',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw13','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW14','Quofore - Mars New Zealand - CustomerContactTraining','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW14',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw14','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW15','Quofore - Mars New Zealand - AssortmentDetail','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW15',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw15','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW16','Quofore - Mars New Zealand - CustomerAssortmentDetail','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW16',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw16','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW17','Quofore - Mars New Zealand - ProductAssortmentDetail','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW17',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw17','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW18','Quofore - Mars New Zealand - AuthorisedListProduct','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW18',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw18','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW19','Quofore - Mars New Zealand - Appointment','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW19',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw19','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW20','Quofore - Mars New Zealand - CallCard','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW20',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw20','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW21','Quofore - Mars New Zealand - CallCardNote','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW21',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw21','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW22','Quofore - Mars New Zealand - OrderHeader','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW22',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw22','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW23','Quofore - Mars New Zealand - OrderDetail','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW23',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw23','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW24','Quofore - Mars New Zealand - Territory','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW24',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw24','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW25','Quofore - Mars New Zealand - CustomerTerritory','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW25',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw25','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW26','Quofore - Mars New Zealand - PositionTerritory','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW26',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw26','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW27','Quofore - Mars New Zealand - Survey','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW27',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw27','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW28','Quofore - Mars New Zealand - SurveyQuestion','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW28',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw28','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW29','Quofore - Mars New Zealand - ResponseOption','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW29',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw29','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW30','Quofore - Mars New Zealand - Task','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW30',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw30','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW31','Quofore - Mars New Zealand - TaskAssignment','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW31',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw31','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW32','Quofore - Mars New Zealand - TaskCustomer','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW32',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw32','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW33','Quofore - Mars New Zealand - TaskProduct','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW33',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw33','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW34','Quofore - Mars New Zealand - TaskSurvey','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW34',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw34','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW35','Quofore - Mars New Zealand - ActivityHeader','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW35',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw35','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW36','Quofore - Mars New Zealand - SurveyAnswer','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW36',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw36','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW37','Quofore - Mars New Zealand - Graveyard','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW37',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw37','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW38','Quofore - Mars New Zealand - CustomerWholesaler','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW38',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw38','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW39','Quofore - Mars New Zealand - ActivityDetail_DistCheck1','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW39',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw39','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW40','Quofore - Mars New Zealand - ActivityDetail_DistCheck2','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW40',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw40','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW41','Quofore - Mars New Zealand - ActivityDetail_RelayHours','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW41',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw41','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW42','Quofore - Mars New Zealand - ActivityDetail_SecondSite','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW42',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw42','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW43','Quofore - Mars New Zealand - ActivityDetail_PtOfInterupt','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW43',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw43','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW44','Quofore - Mars New Zealand - ActivityDetail_Hardware','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW44',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw44','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW45','Quofore - Mars New Zealand - ActivityDetail_Upgrades','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW45',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw45','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW46','Quofore - Mars New Zealand - ActivityDetail_Training','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW46',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw46','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW47','Quofore - Mars New Zealand - ActivityDetail_ShareOfShelf','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW47',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw47','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW48','Quofore - Mars New Zealand - ActivityDetail_PromoCompliance','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW48',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw48','1','0',null,null,'*POLL','FP_QU5');
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW49','Quofore - Mars New Zealand - ActivityDetail_NewProdDev','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW49',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw49','1','0',null,null,'*POLL','FP_QU5');
-- router
insert into lics_interface (int_interface,int_description,int_type,int_group,int_priority,int_hdr_history,int_dta_history,int_fil_path,int_fil_prefix,int_fil_sequence,int_fil_extension,int_opr_alert,int_ema_group,int_search,int_procedure,int_status,int_usr_invocation,int_usr_validation,int_usr_message,int_lod_type,int_lod_group) values ('QU5CDW99','Quofore - Mars New Zealand - Interface *ROUTER','*INBOUND','IB_QU5',1,7,7,'ICS_QU5CDW99',null,null,null,null,'group_anz_venus_production_notification@effem.com',null,'ods_app.qu5_qu5cdw99','1','0',null,null,'*POLL','FP_QU5');
commit;

-- UPDATE (where already CREATED)

-- deactivate existing
update lics_interface
set int_status = '0'
where int_interface like 'QU5CDW%';

-- updates interfaces
update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Digest',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW00',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw00',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW00';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Hierarchy',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW01',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw01',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW01';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - GeneralList',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW02',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw02',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW02';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Role',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW03',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw03',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW03';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Position',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW04',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw04',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW04';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Rep',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW05',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw05',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW05';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - RepAddress',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW06',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw06',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW06';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Product',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW07',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw07',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW07';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ProductBarcode',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW08',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw08',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW08';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Customer',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW09',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw09',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW09';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerAddress',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW10',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw10',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW10';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerNote',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW11',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw11',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW11';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerContact',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW12',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw12',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW12';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerVisitorDay',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW13',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw13',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW13';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerContactTraining',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW14',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw14',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW14';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - AssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW15',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw15',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW15';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerAssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW16',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw16',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW16';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ProductAssortmentDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW17',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw17',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW17';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - AuthorisedListProduct',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW18',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw18',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW18';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Appointment',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW19',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw19',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW19';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CallCard',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW20',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw20',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW20';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CallCardNote',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW21',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw21',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW21';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - OrderHeader',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW22',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw22',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW22';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - OrderDetail',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW23',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw23',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW23';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Territory',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW24',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw24',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW24';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerTerritory',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW25',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw25',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW25';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - PositionTerritory',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW26',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw26',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW26';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Survey',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW27',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw27',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW27';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - SurveyQuestion',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW28',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw28',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW28';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ResponseOption',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW29',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw29',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW29';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Task',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW30',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw30',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW30';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - TaskAssignment',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW31',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw31',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW31';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - TaskCustomer',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW32',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw32',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW32';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - TaskProduct',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW33',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw33',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW33';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - TaskSurvey',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW34',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw34',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW34';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityHeader',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW35',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw35',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW35';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - SurveyAnswer',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW36',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw36',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW36';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Graveyard',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW37',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw37',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW37';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - CustomerWholesaler',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW38',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw38',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW38';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_DistCheck1',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW39',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw39',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW39';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_DistCheck2',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW40',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw40',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW40';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_RelayHours',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW41',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw41',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW41';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_SecondSite',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW42',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw42',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW42';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_PtOfInterupt',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW43',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw43',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW43';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_Hardware',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW44',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw44',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW44';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_Upgrades',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW45',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw45',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW45';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_Training',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW46',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw46',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW46';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_ShareOfShelf',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW47',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw47',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW47';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_PromoCompliance',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW48',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw48',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW48';

update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - ActivityDetail_NewProdDev',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW49',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw49',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW49';

-- updates router
update lics_interface
set
  int_description = 'Quofore - Mars New Zealand - Interface *ROUTER',
  int_type = '*INBOUND',
  int_group = 'IB_QU5',
  int_priority = 1,
  int_hdr_history = 7,
  int_dta_history = 7,
  int_fil_path = 'ICS_QU5CDW99',
  int_fil_prefix = null,
  int_fil_sequence = null,
  int_fil_extension = null,
  int_opr_alert = null,
  int_ema_group = 'group_anz_venus_production_notification@effem.com',
  int_search = null,
  int_procedure = 'ods_app.qu5_qu5cdw99',
  int_status = '1',
  int_usr_invocation = '0',
  int_usr_validation = null,
  int_usr_message = null,
  int_lod_type = '*POLL',
  int_lod_group = 'FP_QU5'
where int_interface = 'QU5CDW99';

commit;


--------------------------------------------------------------------------------
-- Setup LICS Interface Groups

-- CREATE
insert into lics_group (gro_group,gro_description) values ('QU5CDW_INBOUND','Quofore - Mars New Zealand - Inbound');

commit;

-- UPDATE (where already CREATED)
update lics_group
set gro_description = ,'Quofore - Mars New Zealand - Inbound'
where gro_group = 'QU5CDW_INBOUND';

commit;

-- CREATE / UPDATE

-- cleanup
delete from lics_grp_interface
where gri_group = 'QU5CDW_INBOUND';

-- create entry for interfaces
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW00');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW01');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW02');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW03');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW04');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW05');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW06');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW07');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW08');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW09');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW10');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW11');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW12');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW13');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW14');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW15');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW16');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW17');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW18');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW19');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW20');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW21');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW22');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW23');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW24');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW25');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW26');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW27');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW28');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW29');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW30');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW31');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW32');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW33');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW34');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW35');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW36');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW37');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW38');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW39');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW40');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW41');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW42');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW43');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW44');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW45');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW46');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW47');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW48');
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW49');

-- create entry for router
insert into lics_grp_interface (gri_group,gri_interface) values ('QU5CDW_INBOUND','QU5CDW99');

commit;

--------------------------------------------------------------------------------
-- Create Directories
begin
  lics_directory.create_directory('ICS_QU5CDW00', '/ics/cdw/prod/inbound/qu5cdw00');
  lics_directory.create_directory('ICS_QU5CDW01', '/ics/cdw/prod/inbound/qu5cdw01');
  lics_directory.create_directory('ICS_QU5CDW02', '/ics/cdw/prod/inbound/qu5cdw02');
  lics_directory.create_directory('ICS_QU5CDW03', '/ics/cdw/prod/inbound/qu5cdw03');
  lics_directory.create_directory('ICS_QU5CDW04', '/ics/cdw/prod/inbound/qu5cdw04');
  lics_directory.create_directory('ICS_QU5CDW05', '/ics/cdw/prod/inbound/qu5cdw05');
  lics_directory.create_directory('ICS_QU5CDW06', '/ics/cdw/prod/inbound/qu5cdw06');
  lics_directory.create_directory('ICS_QU5CDW07', '/ics/cdw/prod/inbound/qu5cdw07');
  lics_directory.create_directory('ICS_QU5CDW08', '/ics/cdw/prod/inbound/qu5cdw08');
  lics_directory.create_directory('ICS_QU5CDW09', '/ics/cdw/prod/inbound/qu5cdw09');
  lics_directory.create_directory('ICS_QU5CDW10', '/ics/cdw/prod/inbound/qu5cdw10');
  lics_directory.create_directory('ICS_QU5CDW11', '/ics/cdw/prod/inbound/qu5cdw11');
  lics_directory.create_directory('ICS_QU5CDW12', '/ics/cdw/prod/inbound/qu5cdw12');
  lics_directory.create_directory('ICS_QU5CDW13', '/ics/cdw/prod/inbound/qu5cdw13');
  lics_directory.create_directory('ICS_QU5CDW14', '/ics/cdw/prod/inbound/qu5cdw14');
  lics_directory.create_directory('ICS_QU5CDW15', '/ics/cdw/prod/inbound/qu5cdw15');
  lics_directory.create_directory('ICS_QU5CDW16', '/ics/cdw/prod/inbound/qu5cdw16');
  lics_directory.create_directory('ICS_QU5CDW17', '/ics/cdw/prod/inbound/qu5cdw17');
  lics_directory.create_directory('ICS_QU5CDW18', '/ics/cdw/prod/inbound/qu5cdw18');
  lics_directory.create_directory('ICS_QU5CDW19', '/ics/cdw/prod/inbound/qu5cdw19');
  lics_directory.create_directory('ICS_QU5CDW20', '/ics/cdw/prod/inbound/qu5cdw20');
  lics_directory.create_directory('ICS_QU5CDW21', '/ics/cdw/prod/inbound/qu5cdw21');
  lics_directory.create_directory('ICS_QU5CDW22', '/ics/cdw/prod/inbound/qu5cdw22');
  lics_directory.create_directory('ICS_QU5CDW23', '/ics/cdw/prod/inbound/qu5cdw23');
  lics_directory.create_directory('ICS_QU5CDW24', '/ics/cdw/prod/inbound/qu5cdw24');
  lics_directory.create_directory('ICS_QU5CDW25', '/ics/cdw/prod/inbound/qu5cdw25');
  lics_directory.create_directory('ICS_QU5CDW26', '/ics/cdw/prod/inbound/qu5cdw26');
  lics_directory.create_directory('ICS_QU5CDW27', '/ics/cdw/prod/inbound/qu5cdw27');
  lics_directory.create_directory('ICS_QU5CDW28', '/ics/cdw/prod/inbound/qu5cdw28');
  lics_directory.create_directory('ICS_QU5CDW29', '/ics/cdw/prod/inbound/qu5cdw29');
  lics_directory.create_directory('ICS_QU5CDW30', '/ics/cdw/prod/inbound/qu5cdw30');
  lics_directory.create_directory('ICS_QU5CDW31', '/ics/cdw/prod/inbound/qu5cdw31');
  lics_directory.create_directory('ICS_QU5CDW32', '/ics/cdw/prod/inbound/qu5cdw32');
  lics_directory.create_directory('ICS_QU5CDW33', '/ics/cdw/prod/inbound/qu5cdw33');
  lics_directory.create_directory('ICS_QU5CDW34', '/ics/cdw/prod/inbound/qu5cdw34');
  lics_directory.create_directory('ICS_QU5CDW35', '/ics/cdw/prod/inbound/qu5cdw35');
  lics_directory.create_directory('ICS_QU5CDW36', '/ics/cdw/prod/inbound/qu5cdw36');
  lics_directory.create_directory('ICS_QU5CDW37', '/ics/cdw/prod/inbound/qu5cdw37');
  lics_directory.create_directory('ICS_QU5CDW38', '/ics/cdw/prod/inbound/qu5cdw38');
  lics_directory.create_directory('ICS_QU5CDW39', '/ics/cdw/prod/inbound/qu5cdw39');
  lics_directory.create_directory('ICS_QU5CDW40', '/ics/cdw/prod/inbound/qu5cdw40');
  lics_directory.create_directory('ICS_QU5CDW41', '/ics/cdw/prod/inbound/qu5cdw41');
  lics_directory.create_directory('ICS_QU5CDW42', '/ics/cdw/prod/inbound/qu5cdw42');
  lics_directory.create_directory('ICS_QU5CDW43', '/ics/cdw/prod/inbound/qu5cdw43');
  lics_directory.create_directory('ICS_QU5CDW44', '/ics/cdw/prod/inbound/qu5cdw44');
  lics_directory.create_directory('ICS_QU5CDW45', '/ics/cdw/prod/inbound/qu5cdw45');
  lics_directory.create_directory('ICS_QU5CDW46', '/ics/cdw/prod/inbound/qu5cdw46');
  lics_directory.create_directory('ICS_QU5CDW47', '/ics/cdw/prod/inbound/qu5cdw47');
  lics_directory.create_directory('ICS_QU5CDW48', '/ics/cdw/prod/inbound/qu5cdw48');
  lics_directory.create_directory('ICS_QU5CDW49', '/ics/cdw/prod/inbound/qu5cdw49');
  lics_directory.create_directory('ICS_QU5CDW99', '/ics/cdw/prod/inbound/qu5cdw99');
end;
/

--------------------------------------------------------------------------------
-- Set Directory Permissions
begin
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw00');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw01');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw02');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw03');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw04');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw05');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw06');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw07');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw08');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw09');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw10');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw11');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw12');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw13');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw14');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw15');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw16');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw17');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw18');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw19');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw20');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw21');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw22');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw23');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw24');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw25');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw26');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw27');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw28');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw29');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw30');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw31');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw32');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw33');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw34');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw35');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw36');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw37');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw38');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw39');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw40');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw41');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw42');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw43');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw44');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw45');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw46');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw47');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw48');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw49');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/qu5cdw99');
end;
/

--------------------------------------------------------------------------------
-- Log Off
spool off

--------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------
