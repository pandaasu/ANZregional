/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_dtp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_dtp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_dtp
   (vbeln                                        varchar2(10 char)                   not null,
    detseq                                       number                              not null,
    dtxseq                                       number                              not null,
    dtpseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_del_dtp is 'LADS Delivery Detail Text Detail';
comment on column lads_del_dtp.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_dtp.detseq is 'DET - generated sequence number';
comment on column lads_del_dtp.dtxseq is 'DTX - generated sequence number';
comment on column lads_del_dtp.dtpseq is 'DTP - generated sequence number';
comment on column lads_del_dtp.tdformat is 'Tag column';
comment on column lads_del_dtp.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_dtp
   add constraint lads_del_dtp_pk primary key (vbeln, detseq, dtxseq, dtpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_dtp to lads_app;
grant select, insert, update, delete on lads_del_dtp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_dtp for lads.lads_del_dtp;
