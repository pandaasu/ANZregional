/******************************************************************************/
/* table definition                                                           */
/******************************************************************************/
/**
 system  : AP Regional DBP
 table   : ods_fpps_fcst_det
 owner   : regl
 author  : linden glen

 description
 -----------
 AP Regional DBP - FPPS Forecast Detail ODS table

 yyyy/mm   author         description
 -------   ------         -----------
 20058/01   linden glen    created

*******************************************************************************/

/**/
/* drop existing table
/**/
drop table ods_fpps_fcst_det;


/**/
/* table creation
/**/
create table ods_fpps_fcst_det
   (company_code                varchar2(6 char)    not null,
    fcst_type                   varchar2(4 char)    not null,
    fcst_yyyy                   varchar2(6 char)    not null,
    fcst_matl_code              varchar2(18 char)   not null,
    fcst_period                 varchar2(2 char)    not null,
    fcst_destination            varchar2(256 char)  not null,
    fcst_mrkt_gsv               number              null,
    fcst_mrkt_ton               number              null,
    fcst_mrkt_qty               number              null,
    fcst_fctry_gsv              number              null,
    fcst_fctry_ton              number              null,
    fcst_fctry_qty              number              null);

/**/
/* constraints
/**/

/**/
/* indexes
/**/
create index ods_fpps_fcst_det_idx01 on ods_fpps_fcst_det (company_code, fcst_type, fcst_yyyy);

/**/
/* comments
/**/
comment on table ods_fpps_fcst_det is 'Ap Regional DBP - FPPS Forecast Detail ODS table';


/**/
/* authority
/**/
grant select, insert, update, delete on ods_fpps_fcst_det to ods_app;
grant select, insert, update, delete on ods_fpps_fcst_det to lics_app;

/**/
/* synonym
/**/
create or replace public synonym ods_fpps_fcst_det for ods.ods_fpps_fcst_det;