/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_stock_detail
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Stock Balance Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_stock_detail
   (company_code                       varchar2(3 char)         not null,
    plant_code                         varchar2(4 char)         not null,
    storage_location_code              varchar2(4 char)         not null,
    stock_balance_date                 varchar2(8 char)         not null,
    stock_balance_time                 varchar2(8 char)         not null,
    material_code                      varchar2(18 char)        not null,
    material_batch_number              varchar2(10 char)        null,
    inspection_stock_flag              varchar2(1 char)         null,
    stock_quantity                     number                   null,
    stock_uom_code                     varchar2(3 char)         null,
    stock_best_before_date             varchar2(8 char)         null,
    consignment_cust_vend              varchar2(10 char)        null,
    rcv_isu_storage_location_code      varchar2(4 char)         null,
    stock_type_code                    varchar2(2 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_stock_detail is 'Business Data Store - Stock Balance Detail';
comment on column bds_stock_detail.company_code is 'Company Code - lads_stk_bal_det.bukrs';
comment on column bds_stock_detail.plant_code is 'Plant - lads_stk_bal_det.werks';
comment on column bds_stock_detail.storage_location_code is 'Storage Location. Intransit and Consignment does not have a storage location. - lads_stk_bal_det.lgort';
comment on column bds_stock_detail.stock_balance_date is 'Date of stock balance - lads_stk_bal_det.budat';
comment on column bds_stock_detail.stock_balance_time is 'Stock balance Time - lads_stk_bal_det.timlo';
comment on column bds_stock_detail.material_code is 'Material Code - lads_stk_bal_det.matnr';
comment on column bds_stock_detail.material_batch_number is 'Batch Number of the material in stock - lads_stk_bal_det.charg';
comment on column bds_stock_detail.inspection_stock_flag is 'Inspection stock indicator - lads_stk_bal_det.sobkz';
comment on column bds_stock_detail.stock_quantity is 'Quantity in stock - lads_stk_bal_det.menga';
comment on column bds_stock_detail.stock_uom_code is 'Stock-keeping unit of measure - lads_stk_bal_det.altme';
comment on column bds_stock_detail.stock_best_before_date is 'Best Before Date - lads_stk_bal_det.vfdat';
comment on column bds_stock_detail.consignment_cust_vend is 'Indicates consignment customer or vendor - lads_stk_bal_det.kunnr';
comment on column bds_stock_detail.rcv_isu_storage_location_code is 'Receiving/Issuing Storage Location - lads_stk_bal_det.umlgo';
comment on column bds_stock_detail.stock_type_code is 'Stock Type for ESIS - lads_stk_bal_det.insmk';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_stock_detail
   add constraint bds_stock_detail_pk primary key (company_code, plant_code, storage_location_code, stock_balance_date, stock_balance_time, material_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_stock_detail to lics_app;
grant select, insert, update, delete on bds_stock_detail to lads_app;
grant select, insert, update, delete on bds_stock_detail to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_stock_detail for bds.bds_stock_detail;