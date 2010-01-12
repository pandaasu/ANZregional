/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_sac_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Schedule Activity Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_sac_defn
   (sad_sac_code                    varchar2(32)                  not null,
    sad_sac_name                    varchar2(120 char)            not null,
    sad_sac_event                   varchar2(10)                  not null,
    sad_sac_status                  varchar2(1)                   not null,
    sad_upd_user                    varchar2(30)                  not null,
    sad_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_sac_defn is 'Schedule Activity Definition Table';
comment on column psa.psa_sac_defn.sad_sac_code is 'Schedule activity code';
comment on column psa.psa_sac_defn.sad_sac_name is 'Schedule activity name';
comment on column psa.psa_sac_defn.sad_sac_event is 'Schedule activity event *PROD(production) or *TIME(time)';
comment on column psa.psa_sac_defn.sad_sac_status is 'Schedule activity status (0=inactive or 1=active)';
comment on column psa.psa_sac_defn.sad_upd_user is 'Last updated user';
comment on column psa.psa_sac_defn.sad_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_sac_defn
   add constraint psa_sac_defn_pk primary key (sad_sac_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_sac_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_sac_defn for psa.psa_sac_defn;