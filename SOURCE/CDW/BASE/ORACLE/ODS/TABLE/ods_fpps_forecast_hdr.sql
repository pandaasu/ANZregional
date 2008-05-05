/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : ods_fpps_fcst_hdr
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - FPPS Forecast Header ODS table

 yyyy/mm   author         description
 -------   ------         -----------
 20058/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table ods_fpps_fcst_hdr;


/**/
/* table creation
/**/
create table ods_fpps_fcst_hdr
   (company_code                varchar2(6 char)  not null,
    fcst_type                   varchar2(4 char)  not null,
    fcst_yyyy                   varchar2(6 char)  not null,
    fcst_currency               varchar2(4 char)  not null,
    fcst_load_date              date              not null);


/**/
/* constraints
/**/
alter table ods_fpps_fcst_hdr
  add constraint ods_fpps_fcst_hdr_pk primary key (company_code, fcst_type, fcst_yyyy);

/**/
/* comments
/**/
comment on table ods_fpps_fcst_hdr is 'Ap Regional DBP - FPPS Forecast ODS table';


/**/
/* authority
/**/
grant select, insert, update, delete on ods_fpps_fcst_hdr to ods_app;
grant select, insert, update, delete on ods_fpps_fcst_hdr to lics_app;

/**/
/* synonym
/**/
create or replace public synonym ods_fpps_fcst_hdr for ods.ods_fpps_fcst_hdr;