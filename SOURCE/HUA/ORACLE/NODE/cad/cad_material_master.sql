/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CAD
 Table   : CAD_MATERIAL_MASTER
 Owner   : CAD
 Author  : Linden Glen

 Description
 -----------
 China Application Data - Material master

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created
 2008/03   Linden Glen    Added zrep English and Chinese descriptions
                          Added SELL and MAKE MOE identifier for 0168
                          Added Intermediate Component identifier
 2008/05   Linden Glen    Added dstrbtn_chain_status
                          Added lads_change_date (LADS Last Updated timestamp)
                          Added sap_change_date (SAP Last Updated timestamp)

*******************************************************************************/

drop table cad_material_master;


/**/
/* Table creation
/**/
create table cad_material_master
   (sap_material_code                varchar2(18 char)     not null,
    material_desc_ch                 varchar2(40 char)     null,
    material_desc_en                 varchar2(40 char)     null,
    material_zrep_code               varchar2(18 char)     null,
    material_zrep_desc_ch            varchar2(40 char)     null,
    material_zrep_desc_en            varchar2(40 char)     null,
    net_weight                       number                null,
    gross_weight                     number                null,
    matl_length                      number                null,
    width                            number                null,
    height                           number                null,
    pcs_per_case                     number                null,
    outers_per_case                  number                null,
    cases_per_pallet                 number                null,
    brand_essnc_code	             varchar2(4 char)	   null,
    brand_essnc_desc	             varchar2(30 char)	   null,
    brand_essnc_abbrd_desc	     varchar2(12 char)	   null,
    brand_flag_code                  varchar2(4 char)	   null,
    brand_flag_desc	             varchar2(30 char)	   null,
    brand_flag_abbrd_desc	     varchar2(12 char)	   null,
    brand_sub_flag_code	             varchar2(4 char)	   null,
    brand_sub_flag_desc	             varchar2(30 char)	   null,
    brand_sub_flag_abbrd_desc	     varchar2(12 char)	   null,
    bus_sgmnt_code	             varchar2(4 char)	   null,
    bus_sgmnt_desc	             varchar2(30 char)	   null,
    bus_sgmnt_abbrd_desc	     varchar2(12 char)	   null,
    mkt_sgmnt_code	             varchar2(4 char)	   null,
    mkt_sgmnt_desc	             varchar2(30 char)	   null,
    mkt_sgmnt_abbrd_desc	     varchar2(12 char)	   null,
    prdct_ctgry_code	             varchar2(4 char)      null,
    prdct_ctgry_desc	             varchar2(30 char)	   null,
    prdct_ctgry_abbrd_desc	     varchar2(12 char)	   null,
    prdct_type_code	             varchar2(4 char)      null,
    prdct_type_desc	             varchar2(30 char)	   null,
    prdct_type_abbrd_desc	     varchar2(12 char)	   null,
    cnsmr_pack_frmt_code	     varchar2(4 char)	   null,
    cnsmr_pack_frmt_desc	     varchar2(30 char)	   null,
    cnsmr_pack_frmt_abbrd_desc	     varchar2(12 char)	   null,
    ingred_vrty_code	             varchar2(4 char)	   null,
    ingred_vrty_desc                 varchar2(30 char)	   null,
    ingred_vrty_abbrd_desc           varchar2(12 char)	   null,
    prdct_size_grp_code              varchar2(4 char)	   null,
    prdct_size_grp_desc	             varchar2(30 char)	   null,
    prdct_size_grp_abbrd_desc        varchar2(12 char)	   null,
    prdct_pack_size_code             varchar2(4 char)	   null,
    prdct_pack_size_desc             varchar2(30 char)	   null,
    prdct_pack_size_abbrd_desc       varchar2(12 char)	   null,
    sales_organisation_135           varchar2(4 char)      null,
    sales_organisation_234           varchar2(4 char)      null,
    base_uom_code                    varchar2(3 char)      null,
    material_type_code               varchar2(4 char)      null,
    material_type_desc               varchar2(40 char)     null,
    material_sts_code                varchar2(8 char)      null,
    bdt_code                         varchar2(2 char)      null,
    bdt_desc                         varchar2(30 char)     null,
    bdt_abbrd_desc                   varchar2(12 char)     null,
    tax_classification               varchar2(1 char)      null,
    sell_moe_0168                    varchar2(1 char)      null,
    make_moe_0168                    varchar2(1 char)      null,
    intrmdt_prdct_compnt             varchar2(1 char)      null,
    dstrbtn_chain_status             varchar2(2 char)      null,
    lads_change_date                 varchar2(14 char)     null,
    sap_change_date                  varchar2(14 char)     null,
    cad_load_date                    date                  not null);


/**/
/* Primary Key Constraint
/**/
alter table cad_material_master
   add constraint cad_material_master_pk primary key (sap_material_code);

/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table cad_material_master is 'China Application Data - Material Master';

/**/
/* Synonym
/**/
create or replace public synonym cad_material_master for cad.cad_material_master;

/**/
/* Authority
/**/
grant select,update,delete,insert on cad_material_master to lics_app;
grant select,update,delete,insert on cad_material_master to cad_app;
grant select on cad_material_master to public;
