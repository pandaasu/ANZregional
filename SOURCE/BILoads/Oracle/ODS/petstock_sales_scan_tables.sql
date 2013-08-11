drop table petstock_sales_scan;

create table petstock_sales_scan (
  branch varchar2(100),
  department varchar2(100),
  grp_code varchar2(100),
  sub_grp_code varchar2(100),
  sales_value number(30,10),
  qty_sold number(8,0),
  month date,
  ean varchar2(100),
  product varchar2(100),
  account_no varchar2(100),
  reference_no varchar2(100)
);

select * from petstock_sales_scan;

create index petstock_sales_scan_nu01 on petstock_sales_scan (month);

create or replace public synonym petstock_sales_scan for ods.petstock_sales_scan;

grant select, insert, update, delete on petstock_sales_scan to ods_app;