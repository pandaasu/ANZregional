/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_mat_component
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Material Component Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_mat_component
   (mco_mat_code                    varchar2(32)                  not null,
    mco_com_code                    varchar2(32)                  not null,
    mco_com_quantity                number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_mat_component is 'Material Component Table';
comment on column psa.psa_mat_component.mco_mat_code is 'Material code';
comment on column psa.psa_mat_component.mco_com_code is 'Component code';
comment on column psa.psa_mat_component.mco_com_quantity is 'Component quantity';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_mat_component
   add constraint psa_mat_component_pk primary key (mco_mat_code, mco_com_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_mat_component to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_mat_component for psa.psa_mat_component;