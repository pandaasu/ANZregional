/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_sty_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Schedule Type Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_sty_defn
   (std_sty_code                    varchar2(32)                  not null,
    std_sty_name                    varchar2(120 char)            not null,
    std_sty_event                   vachar2(10)                   not null,
    std_sty_status                  varchar2(1)                   not null,
    std_upd_user                    varchar2(30)                  not null,
    std_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_sty_defn is 'Schedule Type Definition Table';
comment on column psa.psa_sty_defn.std_sty_code is 'Schedule type code';
comment on column psa.psa_sty_defn.std_sty_name is 'Schedule type name';
comment on column psa.psa_sty_defn.std_sty_event is 'Schedule type event *PROD(production) or *TIME(time)';
comment on column psa.psa_sty_defn.std_sty_status is 'Schedule type status (0=inactive or 1=active)';
comment on column psa.psa_sty_defn.std_upd_user is 'Last updated user';
comment on column psa.psa_sty_defn.std_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_sty_defn
   add constraint psa_sty_defn_pk primary key (std_sty_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_sty_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_sty_defn for psa.psa_sty_defn;