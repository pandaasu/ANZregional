
/**/
/* Set the define character
/**/
set define ^;

/**/
/* Define the work variables
/**/
define database = db1296t.ap.mars
define datauser = lics_app
define data_password = kwi9s92a

/**/
/* Create the configuration data
/**/
prompt CONNECTING ...

connect ^datauser/^data_password@^database

prompt CREATING JOB CONFIGURATION ...

insert into lics_job values('ICS_FILE_POLLER','ICS File Poller',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*POLLER','ICSFILE','lics_file_poller.execute','sysdate',10,'1');
insert into lics_job values('ICS_STREAM_POLLER','ICS Stream Poller',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*POLLER','ICSSTREAM','lics_stream_poller.execute','sysdate',30,'1');
insert into lics_job values('FILE_REF01','File Reference Loader (Loader 01)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*FILE','FP_REF#01',null,'sysdate',null,'1');
insert into lics_job values('FILE_REF02','File Reference Loader (Loader 02)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*FILE','FP_REF#02',null,'sysdate',null,'1');
insert into lics_job values('FILE_FAC01','File Factory Loader (Loader 01)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*FILE','FP_FAC#01',null,'sysdate',null,'1');
insert into lics_job values('FILE_FAC02','File Factory Loader (Loader 02)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*FILE','FP_FAC#02',null,'sysdate',null,'1');
insert into lics_job values('INBOUND_REF01','Inbound Reference Interfaces (Processor 01)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*INBOUND','IB_REF#01',null,'sysdate',null,'1');
insert into lics_job values('INBOUND_REF02','Inbound Reference Interfaces (Processor 02)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*INBOUND','IB_REF#02',null,'sysdate',null,'1');
insert into lics_job values('INBOUND_REF03','Inbound Reference Interfaces (Processor 03)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*INBOUND','IB_REF#03',null,'sysdate',null,'1');
insert into lics_job values('INBOUND_REF04','Inbound Reference Interfaces (Processor 04)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*INBOUND','IB_REF#04',null,'sysdate',null,'1');
insert into lics_job values('INBOUND_FAC01','Inbound Factory Interfaces (Processor 01)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*INBOUND','IB_FAC#01',null,'sysdate',null,'1');
insert into lics_job values('INBOUND_FAC02','Inbound Factory Interfaces (Processor 02)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*INBOUND','IB_FAC#02',null,'sysdate',null,'1');
insert into lics_job values('OUTBOUND_NORM01','Inbound Interfaces (Normal Priority Processor 01)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*OUTBOUND','OB_NORM#01',null,'sysdate',null,'1');
insert into lics_job values('OUTBOUND_NORM02','Inbound Interfaces (Normal Priority Processor 02)',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*OUTBOUND','OB_NORM#02',null,'sysdate',null,'1');
insert into lics_job values('LICS_PURGING','LICS Purging - DAILY 7:00',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*PROCEDURE',null,'lics_purging.execute','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');
insert into lics_job values('BDS_PURGING','BDS Purging - DAILY 2:30',null,20,null,'"ISI ICS Test Group"@smtp.ap.mars','*PROCEDURE',null,'bds_purging.execute','lics_time.schedule_next(''*ALL'',2.5)','lics_time.schedule_next(''*ALL'',2.5)','1');
commit;

prompt CREATING INBOUND INTERFACE CONFIGURATION ...

insert into lics_interface values('LADPDB01.8','LADS to MCH Plant Database - Process Orders','*INBOUND','IB_FAC',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb01_loader','1');
insert into lics_interface values('LADPDB02.8','LADS to MCH Plant Database - Material Data','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb02_loader','1');
insert into lics_interface values('LADPDB03.8','LADS to MCH Plant Database - Customer Address','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb03_loader','1');
insert into lics_interface values('LADPDB04.8','LADS to MCH Plant Database - BOM Detail','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb04_loader','1');
insert into lics_interface values('LADPDB05.8','LADS to MCH Plant Database - BOM Alternative','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb05_loader','1');
insert into lics_interface values('LADPDB06.8','LADS to MCH Plant Database - Production Resources','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb06_loader','1');
insert into lics_interface values('LADPDB07.8','LADS to MCH Plant Database - Reference Characteristics','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb07_loader','1');
insert into lics_interface values('LADPDB08.8','LADS to MCH Plant Database - Reference Data','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb08_loader','1');
insert into lics_interface values('LADPDB09.8','LADS to MCH Plant Database - Reference Purchasing Source','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb09_loader','1');
insert into lics_interface values('LADPDB10.8','LADS to MCH Plant Database - Customer Sales Area','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb10_loader','1');
insert into lics_interface values('LADPDB11.8','LADS to MCH Plant Database - Material Classifications','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb11_loader','1');
insert into lics_interface values('LADPDB12.8','LADS to MCH Plant Database - Vendor Company','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb12_loader','1');
insert into lics_interface values('LADPDB13.8','LADS to MCH Plant Database - Material BOM','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb13_loader','1');
insert into lics_interface values('LADPDB14.8','LADS to MCH Plant Database - Stock Balance','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb14_loader','1');
insert into lics_interface values('LADPDB15.8','LADS to MCH Plant Database - In Transit','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb15_loader','1');
insert into lics_interface values('LADPDB16.8','LADS to MCH Plant Database - Characteristic Values','*INBOUND','IB_REF',1,5,5,'ICS_INBOUND',null,0,null,null,'"ISI ICS Test Group"@smtp.ap.mars',null,'bds_app.ladpdb16_loader','1');
commit;

prompt CREATING SECURITY CONFIGURATION ...

insert into lics_sec_user values('*GUEST','Guest','GUEST','1');
insert into lics_sec_user values('GREGASTE','Steve Gregan','ICS_ADMIN','1');
insert into lics_sec_user values('HALICBEN','Ben Halicki','ICS_ADMIN','1');
insert into lics_sec_user values('HUANGVIV','Vivian Huang','ICS_ADMIN','1');

insert into lics_sec_menu values('*SECURITY','Security');
insert into lics_sec_link values('*SECURITY',1,'*OPT','ICS_USR_CONFIG');
insert into lics_sec_link values('*SECURITY',2,'*OPT','ICS_MNU_CONFIG');
insert into lics_sec_link values('*SECURITY',3,'*OPT','ICS_OPT_CONFIG');
insert into lics_sec_link values('*SECURITY',4,'*OPT','ICS_INS_CONFIG');

insert into lics_sec_menu values('ICS_MONITOR','Monitoring');
insert into lics_sec_link values('ICS_MONITOR',1,'*OPT','ICS_JOB_MONITOR');
insert into lics_sec_link values('ICS_MONITOR',2,'*OPT','ICS_INT_MONITOR');
insert into lics_sec_link values('ICS_MONITOR',3,'*OPT','ICS_FIL_MONITOR');
insert into lics_sec_link values('ICS_MONITOR',4,'*OPT','ICS_EVE_MONITOR');
insert into lics_sec_link values('ICS_MONITOR',5,'*OPT','ICS_LOG_MONITOR');
insert into lics_sec_link values('ICS_MONITOR',6,'*OPT','ICS_FIL_SEARCH');

insert into lics_sec_menu values('ICS_CONFIG','Configuration');
insert into lics_sec_link values('ICS_CONFIG',1,'*OPT','ICS_JOB_CONTROL');
insert into lics_sec_link values('ICS_CONFIG',2,'*OPT','ICS_JOB_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',3,'*OPT','ICS_INT_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',7,'*OPT','ICS_STR_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',4,'*OPT','ICS_GRP_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',5,'*OPT','ICS_ROU_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',6,'*OPT','ICS_SET_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',8,'*OPT','ICS_DAS_CONFIG');
insert into lics_sec_link values('ICS_CONFIG',9,'*OPT','ICS_INT_PROCESS')
insert into lics_sec_link values('ICS_CONFIG',10,'*OPT','ICS_INT_LOADER');
insert into lics_sec_link values('ICS_CONFIG',11,'*OPT','ICS_LCK_MONITOR');

insert into lics_sec_menu values('GUEST','Guest');
insert into lics_sec_link values('GUEST',1,'*MNU','ICS_MONITOR');

insert into lics_sec_menu values('ICS_ADMIN','ICS Administrator');
insert into lics_sec_link values('ICS_ADMIN',1,'*MNU','*SECURITY');
insert into lics_sec_link values('ICS_ADMIN',2,'*MNU','ICS_MONITOR');
insert into lics_sec_link values('ICS_ADMIN',3,'*MNU','ICS_CONFIG');

insert into lics_sec_option values('ICS_USR_CONFIG','Security User Configuration','ics_sec_usr_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_MNU_CONFIG','Security Menu Configuration','ics_sec_mnu_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_OPT_CONFIG','Security Option Configuration','ics_sec_opt_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_INS_CONFIG','Security Interface Configuration','ics_sec_int_configuration.asp?Mode=SELECT','1');

insert into lics_sec_option values('ICS_JOB_MONITOR','Job Monitoring','ics_job_monitor.asp?Mode=SEARCH','1');
insert into lics_sec_option values('ICS_INT_MONITOR','Interface Monitoring','ics_int_monitor.asp?Mode=SEARCH','1');
insert into lics_sec_option values('ICS_FIL_MONITOR','File Monitoring','ics_fil_monitor.asp?Mode=SEARCH','1');
insert into lics_sec_option values('ICS_EVE_MONITOR','Event Monitoring','ics_eve_monitor.asp?Mode=SEARCH','1');
insert into lics_sec_option values('ICS_LOG_MONITOR','Log Monitoring','ics_log_monitor.asp?Mode=SEARCH','1');
insert into lics_sec_option values('ICS_FIL_SEARCH','File Search','ics_fil_search.asp?Mode=SEARCH','1');

insert into lics_sec_option values('ICS_JOB_CONTROL','Job Control','ics_job_control.asp','1');
insert into lics_sec_option values('ICS_JOB_CONFIG','Job Configuration','ics_job_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_INT_CONFIG','Interface Configuration','ics_int_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_GRP_CONFIG','Group Configuration','ics_grp_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_ROU_CONFIG','Routing Configuration','ics_rou_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_SET_CONFIG','Setting Configuration','ics_set_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_STR_CONFIG','Stream Configuration','ics_stream_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_DAS_CONFIG','Data Store Configuration','ics_das_configuration.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_INT_LOADER','Interface Loader','ics_int_loader.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_INT_PROCESS','Interface Processing','ics_int_process.asp?Mode=SELECT','1');
insert into lics_sec_option values('ICS_LCK_MONITOR','Lock Monitoring','ics_loc_monitor.asp?Mode=SELECT','1');

commit;

/**/
/* Undefine the work variables
/**/
undefine database
undefine datauser
undefine data_password

/**/
/* Set the define character
/**/
set define &;