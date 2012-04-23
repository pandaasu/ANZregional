/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_src_data
 Owner  : qv

 Description
 -----------
 QlikView - Source Data Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_src_data
   (qsd_das_code                    varchar2(32)                  not null,
    qsd_fac_code                    varchar2(32)                  not null,
    qsd_tim_code                    varchar2(32)                  not null,
    qsd_par_code                    varchar2(32)                  not null,
    qsd_dat_seqn                    number                        not null,
    qsd_dat_data                    sys.anydata                   not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_src_data is 'Source Data Table';
comment on column qv.qvi_src_data.qsd_das_code is 'Dashboard code';
comment on column qv.qvi_src_data.qsd_fac_code is 'Fact code';
comment on column qv.qvi_src_data.qsd_tim_code is 'Time code';
comment on column qv.qvi_src_data.qsd_par_code is 'Part code';
comment on column qv.qvi_src_data.qsd_dat_seqn is 'Data sequence';
comment on column qv.qvi_src_data.qsd_dat_data is 'Data object';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_src_data
   add constraint qvi_src_data_pk primary key (qsd_das_code, qsd_fac_code, qsd_tim_code, qsd_par_code, qsd_dat_seqn);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_src_data to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_src_data for qv.qvi_src_data;