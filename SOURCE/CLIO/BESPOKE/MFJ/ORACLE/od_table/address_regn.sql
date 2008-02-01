/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : address_regn
 Owner  : od

 Description
 -----------
 Operational Data Store - Address Region Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.address_regn
   (sap_addr_regn_code  varchar2(3 char)          not null,
    addr_regn_desc      varchar2(40 char)         not null,
    addr_regn_lupdp     varchar2(8 char)          not null,
    addr_regn_lupdt     date                      not null);

/**/
/* Comments
/**/
comment on table od.address_regn is 'Address Region Table';
comment on column od.address_regn.sap_addr_regn_code is 'SAP Address Region Code';
comment on column od.address_regn.addr_regn_desc is 'Address Region Description';
comment on column od.address_regn.addr_regn_lupdp is 'Last Updated Person';
comment on column od.address_regn.addr_regn_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.address_regn
   add constraint address_regn_pk primary key (sap_addr_regn_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.address_regn to dw_app;
grant select on od.address_regn to od_app with grant option;
grant select on od.address_regn to od_user;
grant select on od.address_regn to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym address_regn for od.address_regn;
