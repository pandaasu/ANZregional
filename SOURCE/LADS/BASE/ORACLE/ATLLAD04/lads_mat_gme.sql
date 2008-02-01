/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_gme
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_gme

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_gme
   (matnr                                        varchar2(18 char)                   not null,
    gmeseq                                       number                              not null,
    grouptype                                    varchar2(2 char)                    null,
    groupmoe                                     varchar2(4 char)                    null,
    usagecode                                    varchar2(3 char)                    null,
    datab                                        varchar2(8 char)                    null,
    dated                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_gme is 'LADS Material Group MOE';
comment on column lads_mat_gme.matnr is 'Material Number';
comment on column lads_mat_gme.gmeseq is 'GME - generated sequence number';
comment on column lads_mat_gme.grouptype is 'Mars Organizational Entity Type';
comment on column lads_mat_gme.groupmoe is 'MOE code';
comment on column lads_mat_gme.usagecode is 'Item Usage Code';
comment on column lads_mat_gme.datab is 'MOE  Start date';
comment on column lads_mat_gme.dated is 'MOE End Date';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_gme
   add constraint lads_mat_gme_pk primary key (matnr, gmeseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_gme to lads_app;
grant select, insert, update, delete on lads_mat_gme to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_gme for lads.lads_mat_gme;
