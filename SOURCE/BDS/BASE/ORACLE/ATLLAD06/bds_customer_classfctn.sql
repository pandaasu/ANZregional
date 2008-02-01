/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CUSTOMER_CLASSFCTN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Customer Classification - ATLLAD06 (CLFMAS01)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2007/04   Steve Gregan   Changed sap_pos_frmt_code definition
 2007/09   Linden Glen    Added ZZAUCUST01 to process_customer

*******************************************************************************/



/**/
/* Table creation
/**/
create table bds_customer_classfctn
   (sap_customer_code                     varchar2(10 char)     not null,
    bds_lads_date                         date                  null,
    bds_lads_status                       varchar2(2 char)      null,
    sap_idoc_name                         varchar2(30 char)     null,
    sap_idoc_number                       number                null,
    sap_idoc_timestamp                    varchar2(14 char)     null,
    sap_pos_frmt_code                     varchar2(30 char)     null,
    sap_pos_frmt_grp_code                 varchar2(30 char)     null,
    sap_pos_frmt_size_code                varchar2(30 char)     null,
    sap_pos_place_code                    varchar2(30 char)     null,
    sap_banner_code                       varchar2(30 char)     null,
    sap_ultmt_prnt_acct_code              varchar2(30 char)     null,
    sap_multi_mrkt_acct_code              varchar2(30 char)     null,
    sap_cust_buying_grp_code              varchar2(30 char)     null,
    sap_dstrbtn_route_code                varchar2(30 char)     null,
    sap_prim_route_to_cnsmr_code          varchar2(30 char)     null,
    sap_operation_bus_model_code          varchar2(30 char)     null,
    sap_fundrsng_sales_trrtry_code        varchar2(30 char)     null);
    
/**/
/* Primary Key Constraint
/**/
alter table bds_customer_classfctn
   add constraint bds_customer_classfctn_pk primary key (sap_customer_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_customer_classfctn is 'Business Data Store - customer Classification (CLFMAS01)';
comment on column bds_customer_classfctn.sap_customer_code is 'SAP customer Code - LADS_CLA_HDR.OBJEK';
comment on column bds_customer_classfctn.bds_lads_date is 'LADS Date - LADS_CLA_HDR.LADS_DATE';
comment on column bds_customer_classfctn.bds_lads_status is 'LADS Status - LADS_CLA_HDR.LADS_STATUS';
comment on column bds_customer_classfctn.sap_idoc_name is 'IDOC Name - LADS_CLA_HDR.IDOC_NAME';
comment on column bds_customer_classfctn.sap_idoc_number is 'IDOC Number - LADS_CLA_HDR.IDOC_NUMBER';
comment on column bds_customer_classfctn.sap_idoc_timestamp is 'IDOC Timestamp - LADS_CLA_HDR.IDOC_TIMESTAMP';
comment on column bds_customer_classfctn.sap_pos_frmt_code is 'SAP POS Format  - LADS_CLA_CHR.ATWRT - CLFFERT101';
comment on column bds_customer_classfctn.sap_pos_frmt_grp_code is 'SAP POS Format Grouping  - LADS_CLA_CHR.ATWRT - CLFFERT41';
comment on column bds_customer_classfctn.sap_pos_frmt_size_code is 'SAP POS Format Size  - LADS_CLA_CHR.ATWRT - CLFFERT102';
comment on column bds_customer_classfctn.sap_pos_place_code is 'SAP POS Place  - LADS_CLA_CHR.ATWRT - CLFFERT103';
comment on column bds_customer_classfctn.sap_banner_code is 'SAP Banner  - LADS_CLA_CHR.ATWRT - CLFFERT104';
comment on column bds_customer_classfctn.sap_ultmt_prnt_acct_code is 'SAP Ultimate Parent Account  - LADS_CLA_CHR.ATWRT - CLFFERT105';
comment on column bds_customer_classfctn.sap_multi_mrkt_acct_code is 'SAP Multi Market Account  - LADS_CLA_CHR.ATWRT - CLFFERT37';
comment on column bds_customer_classfctn.sap_cust_buying_grp_code is 'SAP Customer Buying Group  - LADS_CLA_CHR.ATWRT - CLFFERT36';
comment on column bds_customer_classfctn.sap_dstrbtn_route_code is 'SAP Distribution Route  - LADS_CLA_CHR.ATWRT - CLFFERT106';
comment on column bds_customer_classfctn.sap_prim_route_to_cnsmr_code is 'SAP Primary Route to Consumer  - LADS_CLA_CHR.ATWRT - CLFFERT107';
comment on column bds_customer_classfctn.sap_operation_bus_model_code is 'SAP Operational Business Model  - LADS_CLA_CHR.ATWRT - CLFFERT108';
comment on column bds_customer_classfctn.sap_fundrsng_sales_trrtry_code is 'SAP Fundraising Sales Territory  - LADS_CLA_CHR.ATWRT - ZZAUCUST01';



/**/
/* Synonym
/**/
create or replace public synonym bds_customer_classfctn for bds.bds_customer_classfctn;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_customer_classfctn to lics_app;
grant select,update,delete,insert on bds_customer_classfctn to bds_app;
grant select,update,delete,insert on bds_customer_classfctn to lads_app;
grant select on bds_customer_classfctn to public;