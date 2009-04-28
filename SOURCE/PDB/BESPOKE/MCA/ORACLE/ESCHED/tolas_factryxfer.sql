/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : esched 
 Table   : tolas_factryxfer
 Owner   : esched 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Electronic Schedule - tolas_factryxfer 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/11   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table esched.tolas_factryxfer
(
  transmit_date         varchar2(8 char)        not null,
  transmit_time         varchar2(6 char)        not null,
  warehouse_ref         varchar2(16 char)       not null,
  cnn_no                varchar2(16 char),
  doc_text              varchar2(25 char),
  external_id           varchar2(16 char),
  plant_1               varchar2(4 char)        not null,
  sloc_1                varchar2(4 char)        not null,
  plant_2               varchar2(4 char)        not null,
  sloc_2                varchar2(4 char)        not null,
  material              varchar2(8 char)        not null,
  mvmt_code             varchar2(4 char)        not null,
  neg_sign              varchar2(1 char),
  quantity              number                  not null,
  uom                   varchar2(3 char)        not null,
  iss_stk_status        varchar2(1 char),
  rec_stk_status        varchar2(1 char),
  batch_code            varchar2(10 char),
  mvmt_reason           varchar2(8 char),
  stock_ind             varchar2(1 char),
  vendor                varchar2(8 char),
  cost_centre           varchar2(8 char),  
  best_before_date      varchar2(8 char),
  iss_disposition       varchar2(4 char)        not null,
  rec_disposition       varchar2(4 char)        not null,
  cost_centre_determ    varchar2(8 char),
  purch_ord_num         varchar2(10 char),
  purch_ord_line        varchar2(5 char),
  gl_account            varchar2(6 char)
);

/**/
/* Comments
/**/
comment on table tolas_factryxfer is 'DCO Factory Transfers';
comment on column tolas_factryxfer.transmit_date is 'Transmit date';
comment on column tolas_factryxfer.transmit_time is 'Transmit time';
comment on column tolas_factryxfer.warehouse_ref is 'Unique warehouse reference';
comment on column tolas_factryxfer.cnn_no is 'CNN Number';
comment on column tolas_factryxfer.doc_text is 'Header text on material document';
comment on column tolas_factryxfer.external_id is 'External identification';
comment on column tolas_factryxfer.plant_1 is 'Issuing plant';
comment on column tolas_factryxfer.sloc_1 is 'Issuing storage location';
comment on column tolas_factryxfer.plant_2 is 'Receiving plant';
comment on column tolas_factryxfer.sloc_2 is 'Receiving storage location';
comment on column tolas_factryxfer.material is 'Material code';
comment on column tolas_factryxfer.mvmt_code is 'Inventory movement type';
comment on column tolas_factryxfer.neg_sign is 'Negative sign';
comment on column tolas_factryxfer.quantity is 'Quantity of stock moved';
comment on column tolas_factryxfer.uom is 'Unit of measure';
comment on column tolas_factryxfer.iss_stk_status is 'Atlas issuing stock type';
comment on column tolas_factryxfer.rec_stk_status is 'Atlas receiving stock type';
comment on column tolas_factryxfer.batch_code is 'Batch code of material';
comment on column tolas_factryxfer.mvmt_reason is 'Reason for movement';
comment on column tolas_factryxfer.stock_ind is 'Stock indicator';
comment on column tolas_factryxfer.vendor is 'Vendor code for consignment stock';
comment on column tolas_factryxfer.cost_centre is 'Cost centre for scrapping adjustments';
comment on column tolas_factryxfer.best_before_date is 'Best before date of batch';
comment on column tolas_factryxfer.iss_disposition is 'Issued warehouse disposition';
comment on column tolas_factryxfer.rec_disposition is 'Received warehouse disposition';
comment on column tolas_factryxfer.cost_centre_determ is 'Cost centre determination for scrapping adjustments';
comment on column tolas_factryxfer.purch_ord_num is 'Document number of the purchase order';
comment on column tolas_factryxfer.purch_ord_line is 'Line item number in the purchase order';
comment on column tolas_factryxfer.gl_account is 'General ledger account code';

/**/
/* Authority 
/**/
grant select, update, delete, insert on esched.tolas_factryxfer to esched_app with grant option;
grant select on esched.tolas_factryxfer to appsupport with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym tolas_factryxfer for esched.tolas_factryxfer;