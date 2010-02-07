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
   (rde_mat_code                    varchar2(32)                  not null,
    rde_lin_code                    varchar2(32)                  not null,
    rde_con_code                    varchar2(32)                  not null,
    rde_rra_code                    varchar2(32)                  not null,
    rde_rra_efficiency              number                        not null,
    rde_rra_wastage                 number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_req_detail is 'Production Requirement Detail Table';
comment on column psa.psa_req_detail.rde_mat_code is 'Material code';
comment on column psa.psa_req_detail.rde_lin_code is 'Line code';
comment on column psa.psa_req_detail.rde_con_code is 'Line configuration code';
comment on column psa.psa_req_detail.rde_rra_code is 'Run rate code';
comment on column psa.psa_req_detail.rde_rra_efficiency is 'Run rate efficiency percentage';
comment on column psa.psa_req_detail.rde_rra_wastage is 'Run rate wastage percentage';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_req_detail
   add constraint psa_req_detail_pk primary key (rde_mat_code, rde_lin_code, rde_con_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_req_detail to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_req_detail for psa.psa_req_detail;