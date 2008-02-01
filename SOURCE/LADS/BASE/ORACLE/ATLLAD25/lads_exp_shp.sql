/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_shp
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_shp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_shp
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    znbshpmnt                                    varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_shp is 'Generic ICB Document - Shipment data';
comment on column lads_exp_shp.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_shp.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_shp.znbshpmnt is 'Total number of Shipment';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_shp
   add constraint lads_exp_shp_pk primary key (zzgrpnr, shpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_shp to lads_app;
grant select, insert, update, delete on lads_exp_shp to ics_app;
grant select on lads_exp_shp to ics_reader with grant option;
grant select on lads_exp_shp to ics_executor;
grant select on lads_exp_shp to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_shp for lads.lads_exp_shp;
