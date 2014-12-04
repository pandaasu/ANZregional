/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi 
  Package   : obsolete_stock_dtl 
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  Inventory - Obsolete Stock Detail  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-11-11  Trevor Keon           [Auto Generated] 

*******************************************************************************/

  -- Drop Table
  drop table ods.obsolete_stock_dtl cascade constraints;
  
  -- Create Table
  create table bi.obsolete_stock_dtl (
    matl_code varchar2(32 char) not null,
    batch varchar2(16 char) not null,
    status varchar2(100 char) not null,
    original_rrp number(8,2) not null,
    max_clear_rrp number(8,2) not null,
    max_clear_rrp_ex_gst number(8,2) not null,
    cust_saving number(8,2) not null,
    orig_list_price number(8,2) not null,
    curr_list_price number(8,2) not null,
    on_inv_case_deal number(8,2) not null,
    case_deal number(8,2) not null,
    price_case number(8,2) not null,
    price_unit number(8,2) not null,
    discount number(8,2) not null,
    margin number(8,2) not null,
    account varchar2(100 char) not null,
    deal_qty number(8,2) not null,
    inv_date date not null,
    comment_1 varchar2(1000 char),
    comment_2 varchar2(1000 char),
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table bi.obsolete_stock_dtl add constraint obsolete_stock_dtl_pk primary key (matl_code,batch)
    using index (create unique index bi.obsolete_stock_dtl_pk on bi.obsolete_stock_dtl (matl_code,batch));


  -- Comments
  comment on table obsolete_stock_dtl is 'Inventory - Obsolete Stock Detail';
  comment on column obsolete_stock_dtl.matl_code is 'Material';
  comment on column obsolete_stock_dtl.batch is 'Batch';
  comment on column obsolete_stock_dtl.status is 'Status';
  comment on column obsolete_stock_dtl.original_rrp is 'Original RRP';
  comment on column obsolete_stock_dtl.max_clear_rrp is 'Maximum Clearance RRP';
  comment on column obsolete_stock_dtl.max_clear_rrp_ex_gst is 'Maximum Clearance RRP (exc GST)';
  comment on column obsolete_stock_dtl.cust_saving is 'Customer Saving';
  comment on column obsolete_stock_dtl.orig_list_price is 'Original List Price';
  comment on column obsolete_stock_dtl.curr_list_price is 'Current List Price';
  comment on column obsolete_stock_dtl.on_inv_case_deal is 'On Invoice Document or Case Deal to be Claimed';
  comment on column obsolete_stock_dtl.case_deal is 'Case Deal';
  comment on column obsolete_stock_dtl.price_case is 'Price/Case';
  comment on column obsolete_stock_dtl.price_unit is 'Price/Unit';
  comment on column obsolete_stock_dtl.discount is 'Discount';
  comment on column obsolete_stock_dtl.margin is 'Margin';
  comment on column obsolete_stock_dtl.account is 'Account';
  comment on column obsolete_stock_dtl.deal_qty is 'Deal QTY';
  comment on column obsolete_stock_dtl.inv_date is 'Invoice Date';
  comment on column obsolete_stock_dtl.comment_1 is 'Comment Field #1';
  comment on column obsolete_stock_dtl.comment_2 is 'Comment Field #2';
  comment on column obsolete_stock_dtl.last_update_date is 'Last Update Date/Time';
  comment on column obsolete_stock_dtl.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.obsolete_stock_dtl to bi_app, lics_app with grant option;
  grant select on bi.obsolete_stock_dtl to qv_user, lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
