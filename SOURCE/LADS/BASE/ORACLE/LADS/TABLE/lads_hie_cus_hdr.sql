/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_hie_cus_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_hie_cus_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_hie_cus_hdr
   (hdrdat                                       varchar2(8 char)                    not null,
    hdrseq                                       number                              not null,
    hityp                                        varchar2(1 char)                    null,
    datab                                        varchar2(8 char)                    null,
    datbi                                        varchar2(8 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_hie_cus_hdr is 'LADS Hierarchy Customer Header';
comment on column lads_hie_cus_hdr.hdrdat is 'HDR - Date';
comment on column lads_hie_cus_hdr.hdrseq is 'HDR - generated sequence number';
comment on column lads_hie_cus_hdr.hityp is 'Customer Hierarchy Type';
comment on column lads_hie_cus_hdr.datab is 'Start of Validity Period for Assignment';
comment on column lads_hie_cus_hdr.datbi is 'End of Validity Period for Assignment';
comment on column lads_hie_cus_hdr.idoc_name is 'IDOC name';
comment on column lads_hie_cus_hdr.idoc_number is 'IDOC number';
comment on column lads_hie_cus_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_hie_cus_hdr.lads_date is 'LADS date loaded';
comment on column lads_hie_cus_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_hie_cus_hdr
   add constraint lads_hie_cus_hdr_pk primary key (hdrdat, hdrseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_hie_cus_hdr to lads_app;
grant select, insert, update, delete on lads_hie_cus_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_hie_cus_hdr for lads.lads_hie_cus_hdr;
