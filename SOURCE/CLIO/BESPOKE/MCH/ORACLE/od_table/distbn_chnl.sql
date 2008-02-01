/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : distbn_chnl
 Owner  : od

 Description
 -----------
 Operational Data Store - Distribution Channel Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.distbn_chnl
   (sap_distbn_chnl_code  varchar2(2 char)             not null,
    distbn_chnl_desc      varchar2(60 char)            not null,
    distbn_chnl_lupdp     varchar2(8 char)             not null,
    distbn_chnl_lupdt     date                         not null);

/**/
/* Comments
/**/
comment on table od.distbn_chnl is 'Distribution Channel Table';
comment on column od.distbn_chnl.sap_distbn_chnl_code is 'SAP Distribution Channel Code';
comment on column od.distbn_chnl.distbn_chnl_desc is 'Distribution Channel Description';
comment on column od.distbn_chnl.distbn_chnl_lupdp is 'last updated person';
comment on column od.distbn_chnl.distbn_chnl_lupdt is 'last updated time';

/**/
/* Primary Key Constraint
/**/
alter table od.distbn_chnl
   add constraint distbn_chnl_pk primary key (sap_distbn_chnl_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.distbn_chnl to dw_app;
grant select on od.distbn_chnl to od_app with grant option;
grant select on od.distbn_chnl to od_user;
grant select on od.distbn_chnl to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym distbn_chnl for od.distbn_chnl;