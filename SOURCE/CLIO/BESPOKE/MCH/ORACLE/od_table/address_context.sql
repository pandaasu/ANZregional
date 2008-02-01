/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : address_context
 Owner  : od

 Description
 -----------
 Operational Data Store - Address Context Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.address_context
   (sap_addr_context_code  number                 not null,
    addr_context_desc      varchar2(40 char)      not null,
    addr_context_lupdp     varchar2(8 char)       not null,
    addr_context_lupdt     date                   not null);

/**/
/* Comments
/**/
comment on table od.address_context is 'Address Context Table';
comment on column od.address_context.sap_addr_context_code is 'SAP Address Context Code';
comment on column od.address_context.addr_context_desc is 'Address Context Description';
comment on column od.address_context.addr_context_lupdp is 'Last Updated Person';
comment on column od.address_context.addr_context_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.address_context
   add constraint address_context_pk primary key (sap_addr_context_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.address_context to dw_app;
grant select on od.address_context to od_app with grant option;
grant select on od.address_context to od_user;
grant select on od.address_context to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym address_context for od.address_context;
