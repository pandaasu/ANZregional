/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_val_fil_det
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Validation Filter Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_val_fil_det
   (vfd_filter                                   varchar2(30 char)                   not null,
    vfd_code                                     varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table vds_val_fil_det is 'VDS Validation Filter Detail';
comment on column vds_val_fil_det.vfd_filter is 'Validation filter identifier';
comment on column vds_val_fil_det.vfd_code is 'Validation filter code (eg. material code, customer code, etc.)';

/**/
/* Primary Key Constraint
/**/
alter table vds_val_fil_det
   add constraint vds_val_fil_det_pk primary key (vfd_filter, vfd_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_val_fil_det to vds_app;
grant select on vds_val_fil_det to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym vds_val_fil_det for vds.vds_val_fil_det;
