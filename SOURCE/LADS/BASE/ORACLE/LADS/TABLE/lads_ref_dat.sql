/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ref_dat
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ref_dat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ref_dat
   (z_tabname                                    varchar2(30 char)                   not null,
    datseq                                       number                              not null,
    z_recnr                                      number                              null,
    z_chgtyp                                     varchar2(1 char)                    null,
    z_data                                       varchar2(451 char)                  null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null);

/**/
/* Comments
/**/
comment on table lads_ref_dat is 'LADS Reference Data';
comment on column lads_ref_dat.z_tabname is 'Name of table for inclusion in distribution group';
comment on column lads_ref_dat.datseq is 'DAT - generated sequence number';
comment on column lads_ref_dat.z_recnr is 'Record number for table data in IDOC distribution';
comment on column lads_ref_dat.z_chgtyp is 'Type of change for distribution of change records';
comment on column lads_ref_dat.z_data is 'Data field for distribution of table records';
comment on column lads_ref_dat.idoc_number is 'IDOC number';
comment on column lads_ref_dat.idoc_timestamp is 'IDOC timestamp';

/**/
/* Primary Key Constraint
/**/
alter table lads_ref_dat
   add constraint lads_ref_dat_pk primary key (z_tabname, datseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ref_dat to lads_app;
grant select, insert, update, delete on lads_ref_dat to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ref_dat for lads.lads_ref_dat;
