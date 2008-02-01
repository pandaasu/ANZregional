/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_stg
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_stg

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_stg
   (vbeln                                        varchar2(10 char)                   not null,
    rteseq                                       number                              not null,
    stgseq                                       number                              not null,
    abnum                                        varchar2(4 char)                    null,
    anfrf                                        varchar2(3 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    distz                                        number                              null,
    medst                                        varchar2(3 char)                    null,
    tstyp                                        varchar2(1 char)                    null,
    vsart_bez                                    varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_del_stg is 'LADS Delivery Route Stage';
comment on column lads_del_stg.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_stg.rteseq is 'RTE - generated sequence number';
comment on column lads_del_stg.stgseq is 'STG - generated sequence number';
comment on column lads_del_stg.abnum is 'Stage Number';
comment on column lads_del_stg.anfrf is 'Itinerary for regular route';
comment on column lads_del_stg.vsart is 'Shipping type';
comment on column lads_del_stg.distz is 'Distance';
comment on column lads_del_stg.medst is 'Unit of measure for distance';
comment on column lads_del_stg.tstyp is 'Stage category';
comment on column lads_del_stg.vsart_bez is 'Description of the Shipping Type';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_stg
   add constraint lads_del_stg_pk primary key (vbeln, rteseq, stgseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_stg to lads_app;
grant select, insert, update, delete on lads_del_stg to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_stg for lads.lads_del_stg;
