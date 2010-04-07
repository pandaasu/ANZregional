/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_date
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Date Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_date
   (psd_psc_code                    varchar2(32)                  not null,
    psd_psc_week                    varchar2(7)                   not null,
    psd_day_date                    date                          not null,
    psd_day_name                    varchar2(30)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_date is 'Production Schedule Date Table';
comment on column psa.psa_psc_date.psd_psc_code is 'Schedule code';
comment on column psa.psa_psc_date.psd_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_date.psd_day_date is 'Day date YYYY/MM/DD';
comment on column psa.psa_psc_date.psd_day_name is 'Day name';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_date
   add constraint psa_psc_date_pk primary key (psd_psc_code, psd_psc_week, psd_day_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_date to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_date for psa.psa_psc_date;