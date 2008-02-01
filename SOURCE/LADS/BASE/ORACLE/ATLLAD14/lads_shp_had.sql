/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_had
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_had

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_had
   (tknum                                        varchar2(10 char)                   not null,
    harseq                                       number                              not null,
    hadseq                                       number                              not null,
    extend_q                                     varchar2(3 char)                    null,
    extend_d                                     varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_had is 'LADS Shipment Address Additional';
comment on column lads_shp_had.tknum is 'Shipment Number';
comment on column lads_shp_had.harseq is 'HAR - generated sequence number';
comment on column lads_shp_had.hadseq is 'HAD - generated sequence number';
comment on column lads_shp_had.extend_q is '"Qualifier for additional data, e.g. ILN or D and B number"';
comment on column lads_shp_had.extend_d is '"Additional data, e.g. ILN or D and B no."';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_had
   add constraint lads_shp_had_pk primary key (tknum, harseq, hadseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_had to lads_app;
grant select, insert, update, delete on lads_shp_had to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_had for lads.lads_shp_had;
