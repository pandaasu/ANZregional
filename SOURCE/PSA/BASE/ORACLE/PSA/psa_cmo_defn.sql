/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_cmo_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Crew Model Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_cmo_defn
   (cmd_cmo_code                    varchar2(32)                  not null,
    cmd_cmo_name                    varchar2(120 char)            not null,
    cmd_cmo_status                  varchar2(1)                   not null,
    cmd_prd_type                    varchar2(32)                  not null,
    cmd_upd_user                    varchar2(30)                  not null,
    cmd_upd_date                    date                          not null);  

/**/
/* Comments
/**/
comment on table psa.psa_cmo_defn is 'Crew Model Definition Table';
comment on column psa.psa_cmo_defn.cmd_cmo_code is 'Crew model code';
comment on column psa.psa_cmo_defn.cmd_cmo_name is 'Crew model name';
comment on column psa.psa_cmo_defn.cmd_cmo_status is 'Crew model status (0=inactive or 1=active)';
comment on column psa.psa_cmo_defn.cmd_prd_type is 'Production type code';
comment on column psa.psa_cmo_defn.cmd_upd_user is 'Last updated user';
comment on column psa.psa_cmo_defn.cmd_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_cmo_defn
   add constraint psa_cmo_defn_pk primary key (cmd_cmo_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_cmo_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_cmo_defn for psa.psa_cmo_defn;