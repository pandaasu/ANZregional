/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_drs
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_drs

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_drs
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    drsseq                                       number                              not null,
    abnum                                        number                              null,
    anfrf                                        number                              null,
    vsart                                        varchar2(2 char)                    null,
    distz                                        number                              null,
    medst                                        varchar2(3 char)                    null,
    tstyp                                        varchar2(1 char)                    null,
    vsart_bez                                    varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_drs is 'LADS Shipment Route Stage';
comment on column lads_shp_drs.tknum is 'Shipment Number';
comment on column lads_shp_drs.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_drs.drsseq is 'DRS - generated sequence number';
comment on column lads_shp_drs.abnum is 'Stage Number';
comment on column lads_shp_drs.anfrf is 'Itinerary for regular route';
comment on column lads_shp_drs.vsart is 'Shipping type';
comment on column lads_shp_drs.distz is 'Distance';
comment on column lads_shp_drs.medst is 'Unit of measure for distance';
comment on column lads_shp_drs.tstyp is 'Stage category';
comment on column lads_shp_drs.vsart_bez is 'Description of the Shipping Type';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_drs
   add constraint lads_shp_drs_pk primary key (tknum, dlvseq, drsseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_drs to lads_app;
grant select, insert, update, delete on lads_shp_drs to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_drs for lads.lads_shp_drs;
