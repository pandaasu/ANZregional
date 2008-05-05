/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : ods_fpps_actual_hdr
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - FPPS Actual Header ODS table

 yyyy/mm   author         description
 -------   ------         -----------
 2008/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table ods_fpps_actual_hdr;


/**/
/* table creation
/**/
create table ods_fpps_actual_hdr
   (company_code                  varchar2(6 char)  not null,
    actual_yyyy                   varchar2(6 char)  not null,
    actual_currency               varchar2(4 char)  not null,
    actual_load_date              date              not null);


/**/
/* constraints
/**/
alter table ods_fpps_actual_hdr
  add constraint ods_fpps_actual_hdr_pk primary key (company_code, actual_yyyy);

/**/
/* comments
/**/
comment on table ods_fpps_actual_hdr is 'Ap Regional DBP - FPPS Actual ODS table';


/**/
/* authority
/**/
grant select, insert, update, delete on ods_fpps_actual_hdr to ods_app;
grant select, insert, update, delete on ods_fpps_actual_hdr to lics_app;

/**/
/* synonym
/**/
create or replace public synonym ods_fpps_actual_hdr for ods.ods_fpps_actual_hdr;