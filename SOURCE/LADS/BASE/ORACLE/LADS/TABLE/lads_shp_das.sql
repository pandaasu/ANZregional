/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_das
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_das

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_das
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    dadseq                                       number                              not null,
    dasseq                                       number                              not null,
    extend_q                                     varchar2(3 char)                    null,
    extend_d                                     varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_das is 'LADS Shipment Delivery Address Additional';
comment on column lads_shp_das.tknum is 'Shipment Number';
comment on column lads_shp_das.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_das.dadseq is 'DAD - generated sequence number';
comment on column lads_shp_das.dasseq is 'DAS - generated sequence number';
comment on column lads_shp_das.extend_q is '"Qualifier for additional data, e.g. ILN or D and B number"';
comment on column lads_shp_das.extend_d is '"Additional data, e.g. ILN or D and B no."';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_das
   add constraint lads_shp_das_pk primary key (tknum, dlvseq, dadseq, dasseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_das to lads_app;
grant select, insert, update, delete on lads_shp_das to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_das for lads.lads_shp_das;
