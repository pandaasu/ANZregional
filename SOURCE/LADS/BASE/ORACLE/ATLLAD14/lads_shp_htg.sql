/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_htg
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_htg

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_htg
   (tknum                                        varchar2(10 char)                   not null,
    htxseq                                       number                              not null,
    htgseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_shp_htg is 'LADS Shipment Text Detail';
comment on column lads_shp_htg.tknum is 'Shipment Number';
comment on column lads_shp_htg.htxseq is 'HTX - generated sequence number';
comment on column lads_shp_htg.htgseq is 'HTG - generated sequence number';
comment on column lads_shp_htg.tdformat is 'Tag column';
comment on column lads_shp_htg.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_htg
   add constraint lads_shp_htg_pk primary key (tknum, htxseq, htgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_htg to lads_app;
grant select, insert, update, delete on lads_shp_htg to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_htg for lads.lads_shp_htg;
