/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_cmo_resource
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Crew Model Resource Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_cmo_resource
   (cmr_cmo_code                    varchar2(32)                  not null,
    cmr_res_code                    varchar2(32)                  not null,
    cmr_res_qnty                    number                        not null);  

/**/
/* Comments
/**/
comment on table psa.psa_cmo_resource is 'Crew Model Resource Table';
comment on column psa.psa_cmo_resource.cmr_cmo_code is 'Crew Model code';
comment on column psa.psa_cmo_resource.cmr_res_code is 'Resource code';
comment on column psa.psa_cmo_resource.cmr_res_qnty is 'Resource quantity';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_cmo_resource
   add constraint psa_cmo_resource_pk primary key (cmr_cmo_code, cmr_res_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_cmo_resource to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_cmo_resource for psa.psa_cmo_resource;