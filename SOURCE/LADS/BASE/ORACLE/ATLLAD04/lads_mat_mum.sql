/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mum
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mum

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mum
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    mumseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    ertag                                        varchar2(8 char)                    null,
    vbwrt                                        number                              null,
    kovbw                                        number                              null,
    kzexi                                        varchar2(1 char)                    null,
    antei                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_mum is 'LADS Material Unplanned Consumption';
comment on column lads_mat_mum.matnr is 'Material Number';
comment on column lads_mat_mum.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_mum.mumseq is 'MUM - generated sequence number';
comment on column lads_mat_mum.msgfn is 'Function';
comment on column lads_mat_mum.ertag is 'First day of the period to which the values refer';
comment on column lads_mat_mum.vbwrt is 'Consumption value';
comment on column lads_mat_mum.kovbw is 'Corrected consumption value';
comment on column lads_mat_mum.kzexi is 'Checkbox';
comment on column lads_mat_mum.antei is 'Ratio of the corrected value to the original value (CV:OV)';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mum
   add constraint lads_mat_mum_pk primary key (matnr, mrcseq, mumseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mum to lads_app;
grant select, insert, update, delete on lads_mat_mum to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mum for lads.lads_mat_mum;
