/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : ean_upc_ctgry
 Owner  : od

 Description
 -----------
 Operational Data Store - EAN UPC Category Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.ean_upc_ctgry
   (sap_ean_upc_ctgry_code  varchar2(2 char)           not null,
    ean_upc_ctgry_desc      varchar2(40 char)          not null,
    ean_upc_ctgry_lupdp     varchar2(8 char)           not null,
    ean_upc_ctgry_lupdt     date                       not null);

/**/
/* Comments
/**/
comment on table od.ean_upc_ctgry is 'EAN UPC Category Table';
comment on column od.ean_upc_ctgry.sap_ean_upc_ctgry_code is 'SAP EAN-UPC Category Code';
comment on column od.ean_upc_ctgry.ean_upc_ctgry_desc is 'EAN-UPC Category Description';
comment on column od.ean_upc_ctgry.ean_upc_ctgry_lupdp is 'Last Updated Person';
comment on column od.ean_upc_ctgry.ean_upc_ctgry_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.ean_upc_ctgry
   add constraint ean_upc_ctgry_pk primary key (sap_ean_upc_ctgry_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.ean_upc_ctgry to dw_app;
grant select on od.ean_upc_ctgry to od_app with grant option;
grant select on od.ean_upc_ctgry to od_user;
grant select on od.ean_upc_ctgry to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym ean_upc_ctgry for od.ean_upc_ctgry;