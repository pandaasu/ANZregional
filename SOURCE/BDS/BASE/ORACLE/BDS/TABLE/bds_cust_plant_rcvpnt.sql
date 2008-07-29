/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_plant_rcvpnt
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Plant Receiving Point

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_plant_rcvpnt
   (customer_code                      varchar2(10 char)        not null,
    cust_plant                         varchar2(10 char)        not null,
    receiving_point                    varchar2(25 char)        not null,
    partner_cust_code                  varchar2(10 char)        null,
    unloading_point                    varchar2(25 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_plant_rcvpnt is 'Business Data Store - Customer Plant Receiving Point';
comment on column bds_cust_plant_rcvpnt.customer_code is 'Customer Number - lads_cus_prp.kunnr';
comment on column bds_cust_plant_rcvpnt.cust_plant is 'Customer number for plant - lads_cus_plm.locnr';
comment on column bds_cust_plant_rcvpnt.receiving_point is 'Receiving point - lads_cus_prp.empst';
comment on column bds_cust_plant_rcvpnt.partner_cust_code is 'Customer number of business partner - lads_cus_prp.kunn2';
comment on column bds_cust_plant_rcvpnt.unloading_point is 'Unloading Point - lads_cus_prp.ablad';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_plant_rcvpnt
   add constraint bds_cust_plant_rcvpnt_pk primary key (customer_code, cust_plant, receiving_point);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_plant_rcvpnt to lics_app;
grant select, insert, update, delete on bds_cust_plant_rcvpnt to lads_app;
grant select, insert, update, delete on bds_cust_plant_rcvpnt to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_plant_rcvpnt for bds.bds_cust_plant_rcvpnt;