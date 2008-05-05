/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : dds_fpps_actual_fact
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - FPPS Actual Fact

 yyyy/mm   author         description
 -------   ------         -----------
 2008/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table dds_fpps_actual_fact;


/**/
/* table creation
/**/
create table dds_fpps_actual_fact
   (company_code                  varchar2(6 char)    not null,
    actual_yyyypp                 varchar2(6 char)    not null,    
    actual_matl_code              varchar2(18 char)   not null,
    actual_currency               varchar2(4 char)    not null,
    actual_aag_code               varchar2(6 char)    not null,
    actual_gsv                    number              null,
    actual_gsv_usd                number              null);

/**/
/* constraints
/**/
alter table dds_fpps_actual_fact
  add constraint dds_fpps_actual_fact_pk primary key (company_code, 
                                                      actual_yyyypp,
                                                      actual_matl_code,  
                                                      actual_aag_code);

/**/
/* comments
/**/
comment on table dds_fpps_actual_fact is 'Ap Regional DBP - FPPS Forecast Fact';


/**/
/* authority
/**/
grant select, insert, update, delete on dds_fpps_actual_fact to ods_app;
grant select, insert, update, delete on dds_fpps_actual_fact to lics_app;

/**/
/* synonym
/**/
create or replace public synonym dds_fpps_actual_fact for dds.dds_fpps_actual_fact;