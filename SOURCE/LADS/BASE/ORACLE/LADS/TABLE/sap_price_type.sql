/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sap_price_type
 Owner  : lads

 Description
 -----------
 Local Atlas Data Store  - Price Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads.sap_price_type
   (sap_price_type_code  varchar2(128 char)       not null,
    price_type_desc      varchar2(80 char)        not null,
    price_type_bps       varchar2(1 char)         not null,
    price_type_gsv       varchar2(1 char)         not null,
    price_type_niv       varchar2(1 char)         not null);

/**/
/* Comments
/**/
comment on table lads.sap_price_type is 'Price Type Table';
comment on column lads.sap_price_type.sap_price_type_code is 'SAP Price Type Code / Description';
comment on column lads.sap_price_type.price_type_desc is 'Price Type Description';
comment on column lads.sap_price_type.price_type_bps is 'Price type used for BPS (0=no, 1=yes)';
comment on column lads.sap_price_type.price_type_gsv is 'Price type used for GSV (0=no, 1=yes)';
comment on column lads.sap_price_type.price_type_niv is 'Price type used for NIV (0=no, 1=yes)';

/**/
/* Primary Key Constraint
/**/
alter table lads.sap_price_type
   add constraint sap_price_type_pk primary key (sap_price_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads.sap_price_type to lads_app;
grant select on lads.sap_price_type to ics_app;

/**/
/* Synonym
/**/
create public synonym sap_price_type for lads.sap_price_type;
