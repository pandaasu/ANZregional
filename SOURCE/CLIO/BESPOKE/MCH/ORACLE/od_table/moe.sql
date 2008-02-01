/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : moe
 Owner  : od

 Description
 -----------
 Operational Data Store - Mars Organisational Entity Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.moe
   (sap_moe_code  varchar2(4 char)                     not null,
    moe_desc      varchar2(40 char)                    not null,
    moe_lupdp     varchar2(8 char)                     not null,
    moe_lupdt     date                                 not null);

/**/
/* Comments
/**/
comment on table od.moe is 'Mars Organisational Entity Table';
comment on column od.moe.sap_moe_code is 'SAP Mars Organisation Entity Code';
comment on column od.moe.moe_desc is 'Mars Organisation Entity Description';
comment on column od.moe.moe_lupdp is 'Last Updated Person';
comment on column od.moe.moe_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.moe
   add constraint moe_pk primary key (sap_moe_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.moe to dw_app;
grant select on od.moe to od_app with grant option;
grant select on od.moe to od_user;
grant select on od.moe to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym moe for od.moe;