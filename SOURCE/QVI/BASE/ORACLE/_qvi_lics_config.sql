/******************************************************************/
/* System  : QVI                                                  */
/* Object  : _qvi_lics_app_config                                 */
/* Author  : Mal Chambeyron                                       */
/* Date    : May 2012                                             */
/******************************************************************/

/*--------------------------------*/
/* MUST BE CONNECTED AS USER LICS */
/*--------------------------------*/

/*
** Add QVI Specific Maintenance Menus
*/.

insert into lics_sec_option (seo_option,seo_description,seo_script,seo_status) values ('QVI_DAS_CONFIG','Dashboard Maintenance','qvi_das_config.asp','1');
insert into lics_sec_option (seo_option,seo_description,seo_script,seo_status) values ('QVI_DAS_ENQUIRY','Dashboard Enquiry','qvi_das_enquiry.asp','1');
insert into lics_sec_option (seo_option,seo_description,seo_script,seo_status) values ('QVI_DIM_CONFIG','Dimension Maintenance','qvi_dim_config.asp','1');

insert into lics_sec_menu (sem_menu,sem_description) values ('QVI_ADMIN','QlikView Interfacing Administration');

insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',1,'*MNU','ICS_ADMIN');
insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',2,'*OPT','QVI_DIM_CONFIG');
insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',3,'*OPT','QVI_DAS_CONFIG');
insert into lics_sec_link (sel_menu,sel_sequence,sel_type,sel_link) values ('QVI_ADMIN',4,'*OPT','QVI_DAS_ENQUIRY');

/*
** Configure QVI Specific Jobs
*/.

insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('FILE_REF01','File Reference Loader (Loader #01)',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*FILE','FP_REF#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('FILE_REF02','File Reference Loader (Loader #02)',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*FILE','FP_REF#02',null,'sysdate',null,'0');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('ICS_FILE_POLLER','ICS File Poller',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*POLLER','ICSFILE','lics_file_poller.execute','sysdate','10','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('ICS_STREAM_POLLER','ICS Stream Poller',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*POLLER','ICSSTREAM','lics_stream_poller.execute','sysdate','30','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('INBOUND_REF01','Inbound Reference Interfaces (Processor #01)',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*INBOUND','IB_REF#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('INBOUND_REF02','Inbound Reference Interfaces (Processor #02)',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*INBOUND','IB_REF#02',null,'sysdate',null,'0');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('LICS_ALERTING','LICS Alerting',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*PROCEDURE',null,'lics_alerting.execute','sysdate','sysdate+1/96','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('LICS_PURGING','LICS Purging - DAILY 7:00',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*PROCEDURE',null,'lics_purging.execute','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('OUTBOUND_NORM01','Outbound Interfaces (Normal Priority Processor #01)',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*OUTBOUND','OB_NORM#01',null,'sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('OUTBOUND_NORM02','Outbound Interfaces (Normal Priority Processor #02)',null,20,null,'group_anz_bi_deplyment_team_-_test@effem.com','*OUTBOUND','OB_NORM#02',null,'sysdate',null,'0');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QVI_POLLER','QlikView Dashboard Poller',null,10,null,'group_anz_bi_deplyment_team_-_test@effem.com','*POLLER','QVIPOLLER','qv_app.qvi_das_poller.execute','sysdate','10','1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QVI_PROCESS01','QlikView Dashboard (Processor #01)',null,10,null,'group_anz_bi_deplyment_team_-_test@effem.com','*DAEMON','QVI#01','lics_trigger_processor.execute_from_daemon','sysdate',null,'1');
insert into lics_job (job_job,job_description,job_res_group,job_exe_history,job_opr_alert,job_ema_group,job_type,job_int_group,job_procedure,job_next,job_interval,job_status) values ('QVI_PROCESS02','QlikView Dashboard (Processor #02)',null,10,null,'group_anz_bi_deplyment_team_-_test@effem.com','*DAEMON','QVI#02','lics_trigger_processor.execute_from_daemon','sysdate',null,'0');




