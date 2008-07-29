/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_htx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_htx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_htx
   (tknum                                        varchar2(10 char)                   not null,
    htxseq                                       number                              not null,
    function                                     varchar2(3 char)                    null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    langua_iso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_shp_htx is 'LADS Shipment Text Header';
comment on column lads_shp_htx.tknum is 'Shipment Number';
comment on column lads_shp_htx.htxseq is 'HTX - generated sequence number';
comment on column lads_shp_htx.function is 'Function (for transferred text)';
comment on column lads_shp_htx.tdobject is 'Texts: application object';
comment on column lads_shp_htx.tdobname is 'Name';
comment on column lads_shp_htx.tdid is 'Text ID';
comment on column lads_shp_htx.tdspras is 'Language';
comment on column lads_shp_htx.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_shp_htx.langua_iso is 'Language key';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_htx
   add constraint lads_shp_htx_pk primary key (tknum, htxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_htx to lads_app;
grant select, insert, update, delete on lads_shp_htx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_htx for lads.lads_shp_htx;
