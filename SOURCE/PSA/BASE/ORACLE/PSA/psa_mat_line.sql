/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_mat_line
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Material line Configuration Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_mat_line
   (mli_mat_code                    varchar2(32)                  not null,
    mli_prd_type                    varchar2(32)                  not null,
    mli_lin_code                    varchar2(32)                  not null,
    mli_con_code                    varchar2(32)                  not null,
    mli_rra_code                    varchar2(32)                  not null,
    mli_rra_efficiency              number                        not null,
    mli_rra_wastage                 number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_mat_line is 'Material line Configuration Table';
comment on column psa.psa_mat_line.mli_mat_code is 'Material code';
comment on column psa.psa_mat_line.mli_prd_type is 'Production type code';
comment on column psa.psa_mat_line.mli_lin_code is 'Line code';
comment on column psa.psa_mat_line.mli_con_code is 'Line configuration code';
comment on column psa.psa_mat_line.mli_rra_code is 'Run rate code';
comment on column psa.psa_mat_line.mli_rra_efficiency is 'Run rate efficiency percentage';
comment on column psa.psa_mat_line.mli_rra_wastage is 'Run rate wastage percentage';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_mat_line
   add constraint psa_mat_line_pk primary key (mli_mat_code, mli_prd_type, mli_lin_code, mli_con_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_mat_line to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_mat_line for psa.psa_mat_line;