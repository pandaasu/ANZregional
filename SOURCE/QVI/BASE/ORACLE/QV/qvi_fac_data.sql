/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_fac_data
 Owner  : qv

 Description
 -----------
 QlikView - Fact Data Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_fac_data
   (qfd_das_code                    varchar2(32)                  not null,
    qfd_fac_code                    varchar2(32)                  not null,
    qfd_tim_code                    varchar2(32)                  not null,
    qfd_dat_seqn                    number                        not null,
    qfd_dat_data                    sys.anydata                   not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_fac_data is 'Fact Data Table';
comment on column qv.qvi_fac_data.qfd_das_code is 'Dashboard code';
comment on column qv.qvi_fac_data.qfd_fac_code is 'Fact code';
comment on column qv.qvi_fac_data.qfd_tim_code is 'Time code';
comment on column qv.qvi_fac_data.qfd_dat_seqn is 'Data sequence';
comment on column qv.qvi_fac_data.qfd_dat_data is 'Data object';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_fac_data
   add constraint qvi_fac_data_pk primary key (qfd_das_code, qfd_fac_code, qfd_tim_code, qfd_dat_seqn);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_fac_data to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_fac_data for qv.qvi_fac_data;