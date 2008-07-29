/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mvm
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mvm

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mvm
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    mvmseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    ertag                                        varchar2(8 char)                    null,
    vbwrt                                        number                              null,
    kovbw                                        number                              null,
    kzexi                                        varchar2(1 char)                    null,
    antei                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_mvm is 'LADS Material Total Consumption';
comment on column lads_mat_mvm.matnr is 'Material Number';
comment on column lads_mat_mvm.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_mvm.mvmseq is 'MVM - generated sequence number';
comment on column lads_mat_mvm.msgfn is 'Function';
comment on column lads_mat_mvm.ertag is 'First day of the period to which the values refer';
comment on column lads_mat_mvm.vbwrt is 'Consumption value';
comment on column lads_mat_mvm.kovbw is 'Corrected consumption value';
comment on column lads_mat_mvm.kzexi is 'Checkbox';
comment on column lads_mat_mvm.antei is 'Ratio of the corrected value to the original value (CV:OV)';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mvm
   add constraint lads_mat_mvm_pk primary key (matnr, mrcseq, mvmseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mvm to lads_app;
grant select, insert, update, delete on lads_mat_mvm to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mvm for lads.lads_mat_mvm;
