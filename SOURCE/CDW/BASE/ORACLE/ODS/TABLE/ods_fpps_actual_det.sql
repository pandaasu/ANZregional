a/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : ods_fpps_actual_det
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - FPPS Actual Detail ODS table

 yyyy/mm   author         description
 -------   ------         -----------
 2008/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table ods_fpps_actual_det;


/**/
/* table creation
/**/
create table ods_fpps_actual_det
   (company_code                  varchar2(6 char)    not null,
    actual_yyyy                   varchar2(6 char)    not null,
    actual_matl_code              varchar2(18 char)   not null,
    actual_period                 varchar2(2 char)    not null,
    actual_destination            varchar2(256 char)  not null,
    actual_mrkt_gsv               number              null,
    actual_mrkt_ton               number              null,
    actual_mrkt_qty               number              null,
    actual_fctry_gsv              number              null,
    actual_fctry_ton              number              null,
    actual_fctry_qty              number              null);

/**/
/* constraints
/**/

/**/
/* indexes
/**/
create index ods_fpps_actual_det_idx01 on ods_fpps_actual_det (company_code, actual_yyyy);


/**/
/* comments
/**/
comment on table ods_fpps_actual_det is 'Ap Regional DBP - FPPS Actual Detail ODS table';


/**/
/* authority
/**/
grant select, insert, update, delete on ods_fpps_actual_det to ods_app;
grant select, insert, update, delete on ods_fpps_actual_det to lics_app;

/**/
/* synonym
/**/
create or replace public synonym ods_fpps_actual_det for ods.ods_fpps_actual_det;