/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hct
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hct

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hct
   (tknum                                        varchar2(10 char)                   not null,
    hctseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    param                                        varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_hct is 'LADS Shipment Control';
comment on column lads_shp_hct.tknum is 'Shipment Number';
comment on column lads_shp_hct.hctseq is 'HCT - generated sequence number';
comment on column lads_shp_hct.qualf is 'IDOC Qualifier: Control (Shipment)';
comment on column lads_shp_hct.param is 'IDOC: Control Parameters';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hct
   add constraint lads_shp_hct_pk primary key (tknum, hctseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hct to lads_app;
grant select, insert, update, delete on lads_shp_hct to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hct for lads.lads_shp_hct;
