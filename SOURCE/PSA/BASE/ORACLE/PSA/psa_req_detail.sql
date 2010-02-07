/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_req_detail
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Requirement Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_req_detail
   (rde_req_code                    varchar2(32)                  not null,
    rde_mat_code                    varchar2(32)                  not null,
    rde_mat_qnty                    number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_req_detail is 'Production Requirement Detail Table';
comment on column psa.psa_req_detail.rde_req_code is 'Requirement code - YYYYPPW_YYYYMMDDHHMISS';
comment on column psa.psa_req_detail.rde_mat_code is 'Material code';
comment on column psa.psa_req_detail.rde_mat_qnty is 'Material quantity';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_req_detail
   add constraint psa_req_detail_pk primary key (rde_req_code, rde_mat_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_req_detail to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_req_detail for psa.psa_req_detail;