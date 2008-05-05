/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : dds_dbp_week_mart
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - Regional DBP Weekly Fact Table

 yyyy/mm   author         description
 -------   ------         -----------
 2008/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table dds_dbp_week_mart;


/**/
/* table creation
/**/
create table dds_dbp_week_mart
   (dbp_company_code                  varchar2(6 char)    not null,
    dbp_yyyyppw                       varchar2(7 char)    not null,    
    dbp_matl_code                     varchar2(18 char)   not null,
    dbp_aag_code                      varchar2(6 char)    not null,
    dbp_currency                      varchar2(4 char)    not null,
    dbp_ptd_tp_inv_gsv                number              null,
    dbp_ptd_tp_ord_gsv                number              null,
    dbp_prd_tp_op_gsv                 number              null,
    dbp_prd_ly_inv_gsv                number              null);

/**/
/* constraints
/**/
alter table dds_dbp_week_mart
  add constraint dds_dbp_week_mart_pk primary key (dbp_company_code, 
                                                   dbp_yyyyppw,
                                                   dbp_matl_code,  
                                                   dbp_aag_code);
/**/
/* indexes
/**/
create index dds_dbp_week_mart_idx01 on dds_dbp_week_mart (dbp_company_code, dbp_yyyyppw);


/**/
/* comments
/**/
comment on table dds_dbp_week_mart is 'Ap Regional DBP - Regional DBP Reporting Fact';


/**/
/* authority
/**/
grant select, insert, update, delete on dds_dbp_week_mart to ods_app;
grant select, insert, update, delete on dds_dbp_week_mart to lics_app;

/**/
/* synonym
/**/
create or replace public synonym dds_dbp_week_mart for dds.dds_dbp_week_mart;