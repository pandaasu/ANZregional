SET DEFINE OFF;

--------------------------------------------------------------------------------
-- Setup LICS Settings
insert into LICS_SETTING (SET_GROUP,SET_CODE,SET_VALUE) values ('QUOFORE','EMAIL:DEFAULT','Group_ANZ_Venus_Production_Notification@smtp.ap.mars');
insert into LICS_SETTING (SET_GROUP,SET_CODE,SET_VALUE) values ('QUOFORE','SOURCE:1','Petcare Australia');
commit;

--------------------------------------------------------------------------------
-- Setup LICS Jobs
insert into LICS_JOB (JOB_JOB,JOB_DESCRIPTION,JOB_RES_GROUP,JOB_EXE_HISTORY,JOB_OPR_ALERT,JOB_EMA_GROUP,JOB_TYPE,JOB_INT_GROUP,JOB_PROCEDURE,JOB_NEXT,JOB_INTERVAL,JOB_STATUS) values ('IB_QUO_01','Inbound Quofore - 01',null,20,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars','*INBOUND','IB_QUO#01',null,'sysdate',null,'1');
insert into LICS_JOB (JOB_JOB,JOB_DESCRIPTION,JOB_RES_GROUP,JOB_EXE_HISTORY,JOB_OPR_ALERT,JOB_EMA_GROUP,JOB_TYPE,JOB_INT_GROUP,JOB_PROCEDURE,JOB_NEXT,JOB_INTERVAL,JOB_STATUS) values ('FILE_QUO_01','Quofore File Processor - 01',null,20,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars','*FILE','FP_QUO#01',null,'sysdate',null,'1');
insert into LICS_JOB (JOB_JOB,JOB_DESCRIPTION,JOB_RES_GROUP,JOB_EXE_HISTORY,JOB_OPR_ALERT,JOB_EMA_GROUP,JOB_TYPE,JOB_INT_GROUP,JOB_PROCEDURE,JOB_NEXT,JOB_INTERVAL,JOB_STATUS) values ('QUO_PROCESS_BATCH','Quofore Process Batch - Every 15 Minutes',null,20,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars','*PROCEDURE',null,'ods_app.quo_batch.process_batches','sysdate','sysdate+1/96','1');
insert into LICS_JOB (JOB_JOB,JOB_DESCRIPTION,JOB_RES_GROUP,JOB_EXE_HISTORY,JOB_OPR_ALERT,JOB_EMA_GROUP,JOB_TYPE,JOB_INT_GROUP,JOB_PROCEDURE,JOB_NEXT,JOB_INTERVAL,JOB_STATUS) values ('QUO_CHECK_BATCH','Quofore Check Batches - Daily 07:00',null,20,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars','*PROCEDURE',null,'ods_app.quo_batch.check_batches','lics_time.schedule_next(''*ALL'',7)','lics_time.schedule_next(''*ALL'',7)','1');
commit;

--------------------------------------------------------------------------------
-- Setup LICS Interace Entries
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW00.1','Quofore : Petcare Australia - Digest','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW00#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw00','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW01.1','Quofore : Petcare Australia - Hierarchy','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW01#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw01','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW02.1','Quofore : Petcare Australia - GeneralList','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW02#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw02','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW03.1','Quofore : Petcare Australia - Position','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW03#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw03','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW04.1','Quofore : Petcare Australia - Rep','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW04#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw04','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW05.1','Quofore : Petcare Australia - RepAddress','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW05#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw05','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW06.1','Quofore : Petcare Australia - Product','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW06#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw06','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW07.1','Quofore : Petcare Australia - ProductBarcode','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW07#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw07','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW08.1','Quofore : Petcare Australia - Customer','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW08#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw08','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW09.1','Quofore : Petcare Australia - CustomerAddress','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW09#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw09','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW10.1','Quofore : Petcare Australia - CustomerNote','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW10#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw10','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW11.1','Quofore : Petcare Australia - CustomerContact','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW11#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw11','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW12.1','Quofore : Petcare Australia - CustomerVisitorDay','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW12#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw12','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW13.1','Quofore : Petcare Australia - AssortmentDetail','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW13#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw13','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW14.1','Quofore : Petcare Australia - CustomerAssortmentDetail','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW14#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw14','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW15.1','Quofore : Petcare Australia - ProductAssortmentDetail','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW15#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw15','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW16.1','Quofore : Petcare Australia - AuthorisedListProduct','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW16#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw16','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW17.1','Quofore : Petcare Australia - Appointment','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW17#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw17','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW18.1','Quofore : Petcare Australia - CallCard','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW18#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw18','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW19.1','Quofore : Petcare Australia - CallcardNote','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW19#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw19','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW20.1','Quofore : Petcare Australia - OrderHeader','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW20#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw20','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW21.1','Quofore : Petcare Australia - OrderDetail','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW21#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw21','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW22.1','Quofore : Petcare Australia - Territory','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW22#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw22','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW23.1','Quofore : Petcare Australia - CustomerTerritory','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW23#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw23','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW24.1','Quofore : Petcare Australia - PositionTerritory','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW24#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw24','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW25.1','Quofore : Petcare Australia - Survey','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW25#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw25','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW26.1','Quofore : Petcare Australia - SurveyQuestion','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW26#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw26','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW27.1','Quofore : Petcare Australia - ResponseOption','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW27#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw27','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW28.1','Quofore : Petcare Australia - Task','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW28#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw28','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW29.1','Quofore : Petcare Australia - TaskAssignment','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW29#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw29','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW30.1','Quofore : Petcare Australia - TaskCustomer','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW30#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw30','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW31.1','Quofore : Petcare Australia - TaskProduct','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW31#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw31','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW32.1','Quofore : Petcare Australia - TaskSurvey','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW32#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw32','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW33.1','Quofore : Petcare Australia - ActivityHeader','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW33#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw33','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW34.1','Quofore : Petcare Australia - ActivityDetailDistCheck','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW34#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw34','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW35.1','Quofore : Petcare Australia - ActivityDetailOOS','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW35#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw35','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW36.1','Quofore : Petcare Australia - ActivityDetailSoSPSD','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW36#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw36','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW37.1','Quofore : Petcare Australia - ActivityDetailSoSSPC','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW37#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw37','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW38.1','Quofore : Petcare Australia - ActivityDetailSoCPSD','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW38#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw38','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW39.1','Quofore : Petcare Australia - ActivityDetailSoCSPC','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW39#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw39','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW40.1','Quofore : Petcare Australia - ActivityDetailTraining','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW40#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw40','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW41.1','Quofore : Petcare Australia - SurveyAnswer','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW41#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw41','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW42.1','Quofore : Petcare Australia - Graveyard','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW42#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw42','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW43.1','Quofore : Petcare Australia - ActivityDetailOFF','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW43#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw43','1','0',null,null,'*POLL','FP_QUO');
insert into LICS_INTERFACE (INT_INTERFACE,INT_DESCRIPTION,INT_TYPE,INT_GROUP,INT_PRIORITY,INT_HDR_HISTORY,INT_DTA_HISTORY,INT_FIL_PATH,INT_FIL_PREFIX,INT_FIL_SEQUENCE,INT_FIL_EXTENSION,INT_OPR_ALERT,INT_EMA_GROUP,INT_SEARCH,INT_PROCEDURE,INT_STATUS,INT_USR_INVOCATION,INT_USR_VALIDATION,INT_USR_MESSAGE,INT_LOD_TYPE,INT_LOD_GROUP) values ('QUOCDW99.1','Quofore : Petcare Australia - * ROUTER','*INBOUND','IB_QUO',1,7,7,'ICS_QUOCDW99#1',null,null,null,null,'Group_ANZ_Venus_Production_Notification@smtp.ap.mars',null,'ods_app.quo_quocdw99','1','0',null,null,'*POLL','FP_QUO');
commit;

--------------------------------------------------------------------------------
-- Setup LICS Interface Groups
insert into LICS_GROUP (GRO_GROUP,GRO_DESCRIPTION) values ('QUOCDW_1_INBOUND','Quofore : Petcare Australia - Inbound');
commit;

insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW00.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW01.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW02.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW03.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW04.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW05.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW06.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW07.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW08.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW09.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW10.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW11.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW12.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW13.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW14.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW15.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW16.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW17.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW18.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW19.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW20.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW21.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW22.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW23.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW24.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW25.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW26.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW27.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW28.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW29.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW30.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW31.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW32.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW33.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW34.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW35.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW36.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW37.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW38.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW39.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW40.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW41.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW42.1');
insert into LICS_GRP_INTERFACE (GRI_GROUP,GRI_INTERFACE) values ('QUOCDW_1_INBOUND','QUOCDW99.1');
commit;

--------------------------------------------------------------------------------
-- Set Directory Permissions
begin
  lics_directory.create_directory('ICS_QUOCDW00#1', '/ics/cdw/prod/inbound/quocdw00.1');
  lics_directory.create_directory('ICS_QUOCDW01#1', '/ics/cdw/prod/inbound/quocdw01.1');
  lics_directory.create_directory('ICS_QUOCDW02#1', '/ics/cdw/prod/inbound/quocdw02.1');
  lics_directory.create_directory('ICS_QUOCDW03#1', '/ics/cdw/prod/inbound/quocdw03.1');
  lics_directory.create_directory('ICS_QUOCDW04#1', '/ics/cdw/prod/inbound/quocdw04.1');
  lics_directory.create_directory('ICS_QUOCDW05#1', '/ics/cdw/prod/inbound/quocdw05.1');
  lics_directory.create_directory('ICS_QUOCDW06#1', '/ics/cdw/prod/inbound/quocdw06.1');
  lics_directory.create_directory('ICS_QUOCDW07#1', '/ics/cdw/prod/inbound/quocdw07.1');
  lics_directory.create_directory('ICS_QUOCDW08#1', '/ics/cdw/prod/inbound/quocdw08.1');
  lics_directory.create_directory('ICS_QUOCDW09#1', '/ics/cdw/prod/inbound/quocdw09.1');
  lics_directory.create_directory('ICS_QUOCDW10#1', '/ics/cdw/prod/inbound/quocdw10.1');
  lics_directory.create_directory('ICS_QUOCDW11#1', '/ics/cdw/prod/inbound/quocdw11.1');
  lics_directory.create_directory('ICS_QUOCDW12#1', '/ics/cdw/prod/inbound/quocdw12.1');
  lics_directory.create_directory('ICS_QUOCDW13#1', '/ics/cdw/prod/inbound/quocdw13.1');
  lics_directory.create_directory('ICS_QUOCDW14#1', '/ics/cdw/prod/inbound/quocdw14.1');
  lics_directory.create_directory('ICS_QUOCDW15#1', '/ics/cdw/prod/inbound/quocdw15.1');
  lics_directory.create_directory('ICS_QUOCDW16#1', '/ics/cdw/prod/inbound/quocdw16.1');
  lics_directory.create_directory('ICS_QUOCDW17#1', '/ics/cdw/prod/inbound/quocdw17.1');
  lics_directory.create_directory('ICS_QUOCDW18#1', '/ics/cdw/prod/inbound/quocdw18.1');
  lics_directory.create_directory('ICS_QUOCDW19#1', '/ics/cdw/prod/inbound/quocdw19.1');
  lics_directory.create_directory('ICS_QUOCDW20#1', '/ics/cdw/prod/inbound/quocdw20.1');
  lics_directory.create_directory('ICS_QUOCDW21#1', '/ics/cdw/prod/inbound/quocdw21.1');
  lics_directory.create_directory('ICS_QUOCDW22#1', '/ics/cdw/prod/inbound/quocdw22.1');
  lics_directory.create_directory('ICS_QUOCDW23#1', '/ics/cdw/prod/inbound/quocdw23.1');
  lics_directory.create_directory('ICS_QUOCDW24#1', '/ics/cdw/prod/inbound/quocdw24.1');
  lics_directory.create_directory('ICS_QUOCDW25#1', '/ics/cdw/prod/inbound/quocdw25.1');
  lics_directory.create_directory('ICS_QUOCDW26#1', '/ics/cdw/prod/inbound/quocdw26.1');
  lics_directory.create_directory('ICS_QUOCDW27#1', '/ics/cdw/prod/inbound/quocdw27.1');
  lics_directory.create_directory('ICS_QUOCDW28#1', '/ics/cdw/prod/inbound/quocdw28.1');
  lics_directory.create_directory('ICS_QUOCDW29#1', '/ics/cdw/prod/inbound/quocdw29.1');
  lics_directory.create_directory('ICS_QUOCDW30#1', '/ics/cdw/prod/inbound/quocdw30.1');
  lics_directory.create_directory('ICS_QUOCDW31#1', '/ics/cdw/prod/inbound/quocdw31.1');
  lics_directory.create_directory('ICS_QUOCDW32#1', '/ics/cdw/prod/inbound/quocdw32.1');
  lics_directory.create_directory('ICS_QUOCDW33#1', '/ics/cdw/prod/inbound/quocdw33.1');
  lics_directory.create_directory('ICS_QUOCDW34#1', '/ics/cdw/prod/inbound/quocdw34.1');
  lics_directory.create_directory('ICS_QUOCDW35#1', '/ics/cdw/prod/inbound/quocdw35.1');
  lics_directory.create_directory('ICS_QUOCDW36#1', '/ics/cdw/prod/inbound/quocdw36.1');
  lics_directory.create_directory('ICS_QUOCDW37#1', '/ics/cdw/prod/inbound/quocdw37.1');
  lics_directory.create_directory('ICS_QUOCDW38#1', '/ics/cdw/prod/inbound/quocdw38.1');
  lics_directory.create_directory('ICS_QUOCDW39#1', '/ics/cdw/prod/inbound/quocdw39.1');
  lics_directory.create_directory('ICS_QUOCDW40#1', '/ics/cdw/prod/inbound/quocdw40.1');
  lics_directory.create_directory('ICS_QUOCDW41#1', '/ics/cdw/prod/inbound/quocdw41.1');
  lics_directory.create_directory('ICS_QUOCDW42#1', '/ics/cdw/prod/inbound/quocdw42.1');
  lics_directory.create_directory('ICS_QUOCDW43#1', '/ics/cdw/prod/inbound/quocdw43.1');
  lics_directory.create_directory('ICS_QUOCDW99#1', '/ics/cdw/prod/inbound/quocdw99.1');
end;
/

--------------------------------------------------------------------------------
-- Set Interface Directory Permissions
begin
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw00.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw01.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw02.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw03.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw04.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw05.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw06.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw07.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw08.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw09.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw10.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw11.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw12.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw13.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw14.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw15.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw16.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw17.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw18.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw19.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw20.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw21.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw22.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw23.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw24.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw25.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw26.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw27.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw28.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw29.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw30.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw31.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw32.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw33.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw34.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw35.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw36.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw37.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw38.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw39.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw40.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw41.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw42.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw43.1');
  lics_filesystem.execute_external_procedure('/bin/chmod 777 /ics/cdw/prod/inbound/quocdw99.1');
end;
/

--------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------

