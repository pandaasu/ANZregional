/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_erf
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_erf

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_erf
   (vbeln                                        varchar2(10 char)                   not null,
    detseq                                       number                              not null,
    erfseq                                       number                              not null,
    quali                                        varchar2(3 char)                    null,
    bstnr                                        varchar2(35 char)                   null,
    bstdt                                        varchar2(8 char)                    null,
    bsark                                        varchar2(4 char)                    null,
    ihrez                                        varchar2(12 char)                   null,
    posex                                        varchar2(6 char)                    null,
    bsark_bez                                    varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_del_erf is 'LADS Delivery Detail External Reference';
comment on column lads_del_erf.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_erf.detseq is 'DET - generated sequence number';
comment on column lads_del_erf.erfseq is 'ERF - generated sequence number';
comment on column lads_del_erf.quali is 'Qualifier for Reference Data of Ordering Party';
comment on column lads_del_erf.bstnr is 'Customer purchase order number';
comment on column lads_del_erf.bstdt is 'Customer purchase order date';
comment on column lads_del_erf.bsark is 'Customer purchase order type';
comment on column lads_del_erf.ihrez is 'Customers or vendors internal reference';
comment on column lads_del_erf.posex is 'Item Number of the Underlying Purchase Order';
comment on column lads_del_erf.bsark_bez is 'Description of purchase order type';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_erf
   add constraint lads_del_erf_pk primary key (vbeln, detseq, erfseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_erf to lads_app;
grant select, insert, update, delete on lads_del_erf to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_erf for lads.lads_del_erf;
