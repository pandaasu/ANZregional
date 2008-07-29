/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_moe
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_moe

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_moe
   (matnr                                        varchar2(18 char)                   not null,
    moeseq                                       number                              not null,
    usagecode                                    varchar2(3 char)                    null,
    moe                                          varchar2(4 char)                    null,
    datab                                        varchar2(8 char)                    null,
    dated                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_moe is 'LADS Material MOE';
comment on column lads_mat_moe.matnr is 'Material Number';
comment on column lads_mat_moe.moeseq is 'MOE - generated sequence number';
comment on column lads_mat_moe.usagecode is 'Item Usage Code';
comment on column lads_mat_moe.moe is 'MOE code';
comment on column lads_mat_moe.datab is 'MOE  Start date';
comment on column lads_mat_moe.dated is 'MOE End Date';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_moe
   add constraint lads_mat_moe_pk primary key (matnr, moeseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_moe to lads_app;
grant select, insert, update, delete on lads_mat_moe to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_moe for lads.lads_mat_moe;
