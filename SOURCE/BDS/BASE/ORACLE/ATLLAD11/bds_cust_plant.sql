/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_plant
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Plant

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_plant
   (customer_code                      varchar2(10 char)        not null,
    cust_plant                         varchar2(10 char)        not null,
    open_date                          date                     null,
    close_date                         date                     null,
    block_from_date                    date                     null,
    block_to_date                      date                     null,
    auto_purchase_order                varchar2(1 char)         null,
    pos_outbound_profile               varchar2(4 char)         null,
    layout                             varchar2(10 char)        null,
    area                               varchar2(4 char)         null,
    calendar                           varchar2(2 char)         null,
    goods_receive_code                 varchar2(3 char)         null,
    sales_area_space                   number                   null,
    sales_area_space_unit              varchar2(3 char)         null,
    block_reason                       varchar2(2 char)         null,
    pos_inbound_profile                varchar2(4 char)         null,
    pos_outbound_cndtn_type            varchar2(4 char)         null,
    assortment_list_conditions         varchar2(1 char)         null,
    plant_profile                      varchar2(4 char)         null,
    create_date                        date                     null,
    create_user                        varchar2(12 char)        null,
    carry_out                          varchar2(1 char)         null,
    retail_price_plant                 varchar2(4 char)         null,
    retail_price_sal_org               varchar2(4 char)         null,
    retail_price_distbn_chnl           varchar2(2 char)         null,
    assortment_list_profile            varchar2(4 char)         null,
    sales_office                       varchar2(4 char)         null,
    plant_category                     varchar2(1 char)         null,
    list_procedure                     varchar2(2 char)         null,
    list_rule                          varchar2(1 char)         null,
    intercompany_sales_org             varchar2(4 char)         null,
    intercompany_distbn_chnl           varchar2(2 char)         null,
    roi_required                       varchar2(7 char)         null,
    ale_time_increment                 varchar2(6 char)         null,
    pos_currency                       varchar2(5 char)         null,
    space_manage_profile               varchar2(4 char)         null,
    vbim_profile                       varchar2(4 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_plant is 'Business Data Store - Customer Plant';
comment on column bds_cust_plant.customer_code is 'Customer Number - lads_cus_plm.kunnr';
comment on column bds_cust_plant.cust_plant is 'Customer number for plant - lads_cus_plm.locnr';
comment on column bds_cust_plant.open_date is 'Opening date - lads_cus_plm.eroed';
comment on column bds_cust_plant.close_date is 'Closing date - lads_cus_plm.schld';
comment on column bds_cust_plant.block_from_date is 'Block from - lads_cus_plm.spdab';
comment on column bds_cust_plant.block_to_date is 'Block to - lads_cus_plm.spdbi';
comment on column bds_cust_plant.auto_purchase_order is 'Automatic purchase order - lads_cus_plm.autob';
comment on column bds_cust_plant.pos_outbound_profile is 'POS outbound profile - lads_cus_plm.kopro';
comment on column bds_cust_plant.layout is 'Layout - lads_cus_plm.layvr';
comment on column bds_cust_plant.area is 'Area schema - lads_cus_plm.flvar';
comment on column bds_cust_plant.calendar is 'Calendar - lads_cus_plm.stfak';
comment on column bds_cust_plant.goods_receive_code is 'Goods receiving hours ID (default value) - lads_cus_plm.wanid';
comment on column bds_cust_plant.sales_area_space is 'Sales area (floor space) - lads_cus_plm.verfl';
comment on column bds_cust_plant.sales_area_space_unit is 'Sales area (floor space) unit - lads_cus_plm.verfe';
comment on column bds_cust_plant.block_reason is 'Blocking reason - lads_cus_plm.spgr1';
comment on column bds_cust_plant.pos_inbound_profile is 'POS inbound profile - lads_cus_plm.inpro';
comment on column bds_cust_plant.pos_outbound_cndtn_type is 'POS outbound: condition type group - lads_cus_plm.ekoar';
comment on column bds_cust_plant.assortment_list_conditions is 'Listing conditions should be created per assortment - lads_cus_plm.kzlik';
comment on column bds_cust_plant.plant_profile is 'Plant profile - lads_cus_plm.betrp';
comment on column bds_cust_plant.create_date is 'Date on which the record was created - lads_cus_plm.erdat';
comment on column bds_cust_plant.create_user is 'Name of Person who Created the Object - lads_cus_plm.ernam';
comment on column bds_cust_plant.carry_out is 'ID: Carry out subsequent listing - lads_cus_plm.nlmatfb';
comment on column bds_cust_plant.retail_price_plant is 'Plant for retail price determination - lads_cus_plm.bwwrk';
comment on column bds_cust_plant.retail_price_sal_org is 'Sales organization for retail price determination - lads_cus_plm.bwvko';
comment on column bds_cust_plant.retail_price_distbn_chnl is 'Distribution channel for retail price determination - lads_cus_plm.bwvtw';
comment on column bds_cust_plant.assortment_list_profile is 'Assortment list profile - lads_cus_plm.bbpro';
comment on column bds_cust_plant.sales_office is 'Sales office - lads_cus_plm.vkbur_wrk';
comment on column bds_cust_plant.plant_category is 'Plant category - lads_cus_plm.vlfkz';
comment on column bds_cust_plant.list_procedure is 'Listing procedure for store or other assortment categories - lads_cus_plm.lstfl';
comment on column bds_cust_plant.list_rule is 'Basic listing rule for assortments - lads_cus_plm.ligrd';
comment on column bds_cust_plant.intercompany_sales_org is 'Sales organization for intercompany billing - lads_cus_plm.vkorg';
comment on column bds_cust_plant.intercompany_distbn_chnl is 'Distribution channel for intercompany billing - lads_cus_plm.vtweg';
comment on column bds_cust_plant.roi_required is 'Required ROI (for ALE) - lads_cus_plm.desroi';
comment on column bds_cust_plant.ale_time_increment is 'Time Increment for Investment Buying Algorithms (for ALE) - lads_cus_plm.timinc';
comment on column bds_cust_plant.pos_currency is 'Currency of POS systems - lads_cus_plm.posws';
comment on column bds_cust_plant.space_manage_profile is 'Space management profile - lads_cus_plm.ssopt_pro';
comment on column bds_cust_plant.vbim_profile is 'Profile for value-based inventory management - lads_cus_plm.wbpro';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_plant
   add constraint bds_cust_plant_pk primary key (customer_code, cust_plant);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_plant to lics_app;
grant select, insert, update, delete on bds_cust_plant to lads_app;
grant select, insert, update, delete on bds_cust_plant to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_plant for bds.bds_cust_plant;