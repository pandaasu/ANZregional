/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_rte
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_rte

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_rte
   (vbeln                                        varchar2(10 char)                   not null,
    rteseq                                       number                              not null,
    route                                        varchar2(6 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    vsavl                                        varchar2(2 char)                    null,
    vsanl                                        varchar2(2 char)                    null,
    rouid                                        varchar2(100 char)                  null,
    distz                                        number                              null,
    medst                                        varchar2(3 char)                    null,
    route_bez                                    varchar2(40 char)                   null,
    vsart_bez                                    varchar2(20 char)                   null,
    vsavl_bez                                    varchar2(20 char)                   null,
    vsanl_bez                                    varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_del_rte is 'LADS Delivery Route';
comment on column lads_del_rte.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_rte.rteseq is 'RTE - generated sequence number';
comment on column lads_del_rte.route is 'Route';
comment on column lads_del_rte.vsart is 'Shipping type';
comment on column lads_del_rte.vsavl is 'Shipping type of preliminary leg';
comment on column lads_del_rte.vsanl is 'Shipping type of subsequent leg';
comment on column lads_del_rte.rouid is 'Route identification';
comment on column lads_del_rte.distz is 'Distance';
comment on column lads_del_rte.medst is 'Unit of measure for distance';
comment on column lads_del_rte.route_bez is 'Route description';
comment on column lads_del_rte.vsart_bez is 'Description of the Shipping Type';
comment on column lads_del_rte.vsavl_bez is 'Description of shipping type of preliminary leg';
comment on column lads_del_rte.vsanl_bez is 'Description of shipping type of subsequent leg';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_rte
   add constraint lads_del_rte_pk primary key (vbeln, rteseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_rte to lads_app;
grant select, insert, update, delete on lads_del_rte to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_rte for lads.lads_del_rte;
