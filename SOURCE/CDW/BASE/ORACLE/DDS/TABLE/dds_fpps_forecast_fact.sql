/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : dds_fpps_fcst_fact
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - FPPS Forecast Fact

 yyyy/mm   author         description
 -------   ------         -----------
 2008/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table dds_fpps_fcst_fact;


/**/
/* table creation
/**/
create table dds_fpps_fcst_fact
   (company_code                varchar2(6 char)    not null,
    fcst_type                   varchar2(4 char)    not null,
    fcst_yyyypp                 varchar2(6 char)    not null,    
    fcst_matl_code              varchar2(18 char)   not null,
    fcst_currency               varchar2(4 char)    not null,
    fcst_aag_code               varchar2(6 char)    not null,
    fcst_gsv                    number              null,
    fcst_gsv_usd                number              null);

/**/
/* constraints
/**/
alter table dds_fpps_fcst_fact
  add constraint dds_fpps_fcst_fact_pk primary key (company_code, 
                                                    fcst_type, 
                                                    fcst_yyyypp,
                                                    fcst_matl_code,  
                                                    fcst_aag_code);

/**/
/* comments
/**/
comment on table dds_fpps_fcst_fact is 'Ap Regional DBP - FPPS Forecast Fact';


/**/
/* authority
/**/
grant select, insert, update, delete on dds_fpps_fcst_fact to ods_app;
grant select, insert, update, delete on dds_fpps_fcst_fact to lics_app;

/**/
/* synonym
/**/
create or replace public synonym dds_fpps_fcst_fact for dds.dds_fpps_fcst_fact;