/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dbt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dbt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dbt
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    ditseq                                       number                              not null,
    dngseq                                       number                              not null,
    dbtseq                                       number                              not null,
    atinn                                        number                              null,
    atnam                                        varchar2(30 char)                   null,
    atbez                                        varchar2(30 char)                   null,
    atwrt                                        varchar2(30 char)                   null,
    atwtb                                        varchar2(30 char)                   null,
    ewahr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_shp_dbt is 'LADS Shipment Batch Characteristic';
comment on column lads_shp_dbt.tknum is 'Shipment Number';
comment on column lads_shp_dbt.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dbt.ditseq is 'DIT - generated sequence number';
comment on column lads_shp_dbt.dngseq is 'DNG - generated sequence number';
comment on column lads_shp_dbt.dbtseq is 'DBT - generated sequence number';
comment on column lads_shp_dbt.atinn is 'Internal characteristic';
comment on column lads_shp_dbt.atnam is 'Characteristic Name';
comment on column lads_shp_dbt.atbez is 'Characteristic description';
comment on column lads_shp_dbt.atwrt is 'Characteristic Value';
comment on column lads_shp_dbt.atwtb is 'Characteristic value description';
comment on column lads_shp_dbt.ewahr is 'Tolerance from';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dbt
   add constraint lads_shp_dbt_pk primary key (tknum, dlvseq, ditseq, dngseq, dbtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dbt to lads_app;
grant select, insert, update, delete on lads_shp_dbt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dbt for lads.lads_shp_dbt;
