/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_enty
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Entry Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_enty
   (pse_act_code                    number                        not null,
    pse_ent_time                    date                          not null,
    pse_ent_text                    varchar2(128 char)            not null,
    pse_ent_qnty                    number                        not null,
    pse_ent_wast                    number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_enty is 'Production Schedule Entry Table';
comment on column psa.psa_psc_enty.pse_act_code is 'Activity code';
comment on column psa.psa_psc_enty.pse_ent_time is 'Entry time';
comment on column psa.psa_psc_enty.pse_ent_text is 'Entry text';
comment on column psa.psa_psc_enty.pse_ent_qnty is 'Entry quantity';
comment on column psa.psa_psc_enty.pse_ent_wast is 'Entry wastage';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_enty
   add constraint psa_psc_enty_pk primary key (pse_act_code, pse_ent_time);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_enty to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_enty for psa.psa_psc_enty;