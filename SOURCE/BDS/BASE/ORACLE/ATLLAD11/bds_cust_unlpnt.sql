/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_unlpnt
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Unloading Point

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_unlpnt
   (customer_code                      varchar2(10 char)        not null,
    unloading_point                    varchar2(25 char)        not null,
    factory_calendar                   varchar2(2 char)         null,
    goods_receiving_code               varchar2(3 char)         null,
    default_unloading_point_flag       varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_unlpnt is 'Business Data Store - Customer Unloading Point';
comment on column bds_cust_unlpnt.customer_code is 'Customer Number - lads_cus_unl.kunnr';
comment on column bds_cust_unlpnt.unloading_point is 'Unloading Point - lads_cus_unl.ablad';
comment on column bds_cust_unlpnt.factory_calendar is 'Customers factory calendar - lads_cus_unl.knfak';
comment on column bds_cust_unlpnt.goods_receiving_code is 'Goods receiving hours ID (default value) - lads_cus_unl.wanid';
comment on column bds_cust_unlpnt.default_unloading_point_flag is 'Default unloading point - lads_cus_unl.defab';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_unlpnt
   add constraint bds_cust_unlpnt_pk primary key (customer_code, unloading_point);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_unlpnt to lics_app;
grant select, insert, update, delete on bds_cust_unlpnt to lads_app;
grant select, insert, update, delete on bds_cust_unlpnt to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_unlpnt for bds.bds_cust_unlpnt;