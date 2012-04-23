/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_dim_data
 Owner  : qv

 Description
 -----------
 QlikView - Dimension Data Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_dim_data
   (qdd_dim_code                    varchar2(32)                  not null,
    qdd_dat_seqn                    number                        not null,
    qdd_dat_data                    sys.anydata                   not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_dim_data is 'Dimension Data Table';
comment on column qv.qvi_dim_data.qdd_dim_code is 'Dimension code';
comment on column qv.qvi_dim_data.qdd_dat_seqn is 'Data sequence';
comment on column qv.qvi_dim_data.qdd_dat_data is 'Data object';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_dim_data
   add constraint qvi_dim_data_pk primary key (qdd_dim_code, qdd_dat_seqn);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_dim_data to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_dim_data for qv.qvi_dim_data;