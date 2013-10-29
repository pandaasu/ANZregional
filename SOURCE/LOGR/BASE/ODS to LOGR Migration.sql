-- Part 1.
-- Run the create table scripts on LOGR and change scripts.

-- Part 2 Script to grant select access on the tables to Logr schema.
-- Run as ODS
grant select on LOGR_WOD_ADVERT_EFFCTVNSS to logr;
grant select on LOGR_WOD_DSTNCTV_ASSET to logr;
grant select on LOGR_WOD_PRDCT_PRFRMNC to logr;
grant select on LOGR_WOD_PACK_EFFCTVNSS to logr;
grant select on LOGR_WOD_HOUSE_PNTRTN to logr;
grant select on LOGR_WOD_SALES_SCAN to logr;
grant select on LOGR_WOD_TV_ACTIVITY to logr;
grant select on LOGR_WOD_SHARE_OF_SHELF to logr;

-- Part 3. Transfer and commit the data to LOGR schema.
-- Run the following in LOGR.
insert into LOGR_WOD_ADVERT_EFFCTVNSS select * from ODS.LOGR_WOD_ADVERT_EFFCTVNSS; 
commit;
insert into LOGR_WOD_DSTNCTV_ASSET select * from ODS.LOGR_WOD_DSTNCTV_ASSET; 
commit;
insert into LOGR_WOD_PRDCT_PRFRMNC select * from ODS.LOGR_WOD_PRDCT_PRFRMNC; 
commit;
insert into LOGR_WOD_PACK_EFFCTVNSS select * from ODS.LOGR_WOD_PACK_EFFCTVNSS; 
commit;
insert into LOGR_WOD_HOUSE_PNTRTN select * from ODS.LOGR_WOD_HOUSE_PNTRTN; 
commit;
insert into LOGR_WOD_SALES_SCAN select * from ODS.LOGR_WOD_SALES_SCAN; 
commit;
insert into LOGR_WOD_TV_ACTIVITY select * from ODS.LOGR_WOD_TV_ACTIVITY; 
commit;
insert into LOGR_WOD_SHARE_OF_SHELF select * from ODS.LOGR_WOD_SHARE_OF_SHELF; 
commit;

-- Part 5
-- This script should be run within FFLU_APP to grant execute access to the 
-- approperiate packages for other app schemas to create interfaces.

grant execute on fflu_common to LOGR_app;
grant execute on fflu_data to LOGR_app;
grant execute on fflu_utils to LOGR_app;  

-- Part 6 
-- These can be run in the LOGR_APP schema in production.
create or replace synonym fflu_common for fflu_app.fflu_common;
create or replace synonym fflu_data for fflu_app.fflu_data;
create or replace synonym fflu_utils for fflu_app.fflu_utils;

-- Part 7 
-- Install each of the packages in LOGR_APP and run the grant script.

-- Part 8 - DONE
-- Reconfigure the pointers in ICS Interface Configration Screens from ODS_APP to LOGR_APP.

-- Part 9 - DONE
-- Drop the packages from test ODS_APP;
drop package LOGRWOD01_LOADER;
drop package LOGRWOD02_LOADER;
drop package LOGRWOD03_LOADER;
drop package LOGRWOD04_LOADER;
drop package LOGRWOD05_LOADER;
drop package LOGRWOD06_LOADER;
drop package LOGRWOD07_LOADER;
drop package LOGRWOD08_LOADER;

-- Part 10 Drop the tables in ODS.
drop table LOGR_WOD_ADVERT_EFFCTVNSS;
drop table LOGR_WOD_DSTNCTV_ASSET;
drop table LOGR_WOD_PRDCT_PRFRMNC;
drop table LOGR_WOD_PACK_EFFCTVNSS;
drop table LOGR_WOD_HOUSE_PNTRTN;
drop table LOGR_WOD_SALES_SCAN;
drop table LOGR_WOD_TV_ACTIVITY;
drop table LOGR_WOD_SHARE_OF_SHELF;


select * from LOGR.LOGR_WOD_SALES_SCAN