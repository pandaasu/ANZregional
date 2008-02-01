/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : partner_funcn
 Owner  : od

 Description
 -----------
 Operational Data Store - Partner Function Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.partner_funcn
   (sap_partner_funcn_code  varchar2(2 char)           not null,
    partner_funcn_desc      varchar2(40 char)          not null,
    partner_funcn_lupdp     varchar2(8 char)           not null,
    partner_funcn_lupdt     date                       not null);

/**/
/* Comments
/**/
comment on table od.partner_funcn is 'Partner Function Table';
comment on column od.partner_funcn.sap_partner_funcn_code is 'SAP Partner Function Code';
comment on column od.partner_funcn.partner_funcn_desc is 'Partner Function Description';
comment on column od.partner_funcn.partner_funcn_lupdp is 'Last Updated Person';
comment on column od.partner_funcn.partner_funcn_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.partner_funcn
   add constraint partner_funcn_pk primary key (sap_partner_funcn_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.partner_funcn to dw_app;
grant select on od.partner_funcn to od_app with grant option;
grant select on od.partner_funcn to od_user;
grant select on od.partner_funcn to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym partner_funcn for od.partner_funcn;