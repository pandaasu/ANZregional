/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_das_defn
 Owner  : qv

 Description
 -----------
 QlikView - Dashboard Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_das_defn
   (qdd_das_code                    varchar2(32)                  not null,
    qdd_das_name                    varchar2(120 char)            not null,
    qdd_das_status                  varchar2(1)                   not null,
    qdd_upd_user                    varchar2(30)                  not null,
    qdd_upd_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_das_defn is 'Dashboard Definition Table';
comment on column qv.qvi_das_defn.qdd_das_code is 'Dashboard code';
comment on column qv.qvi_das_defn.qdd_das_name is 'Dashboard name';
comment on column qv.qvi_das_defn.qdd_das_status is 'Dashboard status (0=inactive or 1=active)';
comment on column qv.qvi_das_defn.qdd_upd_user is 'Last updated user';
comment on column qv.qvi_das_defn.qdd_upd_date is 'Last updated date';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_das_defn
   add constraint qvi_das_defn_pk primary key (qdd_das_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_das_defn to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_das_defn for qv.qvi_das_defn;