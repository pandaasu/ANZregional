/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_fac_part
 Owner  : qv

 Description
 -----------
 QlikView - Fact Part Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_fac_part
   (qfp_das_code                    varchar2(32)                  not null,
    qfp_fac_code                    varchar2(32)                  not null,
    qfp_par_code                    varchar2(32)                  not null,
    qfp_par_name                    varchar2(120 char)            not null,
    qfp_par_status                  varchar2(1)                   not null,
    qfp_src_table                   varchar2(120)                 not null,
    qfp_src_type                    varchar2(120)                 not null,
    qfp_upd_user                    varchar2(30)                  not null,
    qfp_upd_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_fac_part is 'Fact Part Table';
comment on column qv.qvi_fac_part.qfp_das_code is 'Dashboard code';
comment on column qv.qvi_fac_part.qfp_fac_code is 'Fact code';
comment on column qv.qvi_fac_part.qfp_par_code is 'Part code';
comment on column qv.qvi_fac_part.qfp_par_name is 'Part name';
comment on column qv.qvi_fac_part.qfp_par_status is 'Part status (0=inactive or 1=active)';
comment on column qv.qvi_fac_part.qfp_src_table is Source pipelined table function';
comment on column qv.qvi_fac_part.qfp_src_type is 'Source data type';
comment on column qv.qvi_fac_part.qfp_upd_user is 'Last updated user';
comment on column qv.qvi_fac_part.qfp_upd_date is 'Last updated date';


-- can be unit / p&l or unit / balance sheet which can simply tie to an interface

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_fac_part
   add constraint qvi_fac_part_pk primary key (qfp_das_code, qfp_fac_code, qfp_par_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_fac_part to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_fac_part for qv.qvi_fac_part;