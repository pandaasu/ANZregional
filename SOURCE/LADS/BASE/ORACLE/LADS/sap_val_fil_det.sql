/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_fil_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Filter Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_fil_det
   (vfd_filter                                   varchar2(30 char)                   not null,
    vfd_code                                     varchar2(30 char)                   not null);

/**/
/* Comments
/**/
comment on table sap_val_fil_det is 'SAP Validation Filter Detail';
comment on column sap_val_fil_det.vfd_filter is 'Validation filter identifier';
comment on column sap_val_fil_det.vfd_code is 'Validation filter code (eg. material code, customer code, etc.)';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_fil_det
   add constraint sap_val_fil_det_pk primary key (vfd_filter, vfd_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_fil_det to lads_app;
grant select on sap_val_fil_det to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_fil_det for lads.sap_val_fil_det;
