/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : uom_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Unit Of Measure Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.uom_dim
   (pev_code                 varchar2(32 char)                not null,
    pev_desc                 varchar2(128 char)               not null);

/**/
/* Comments
/**/
comment on table dd.uom_dim is 'Unit Of Measure Dimension Table';
comment on column dd.uom_dim.sap_uom_code is 'SAP Unit Of Measure Code';
comment on column dd.uom_dim.uom_abbrd_desc is 'Unit Of Measure Abbreviated Description';
comment on column dd.uom_dim.uom_desc is 'Unit Of Measure Description';
comment on column dd.uom_dim.uom_dim is 'Unit Of Measure Dimension';

/**/
/* Primary Key Constraint
/**/
alter table dd.uom_dim
   add constraint uom_dim_pk primary key (sap_uom_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.uom_dim to dw_app;
grant select on dd.uom_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym uom_dim for dd.uom_dim;

