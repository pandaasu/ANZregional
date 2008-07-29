/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mpm
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mpm

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mpm
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    mpmseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    ertag                                        varchar2(8 char)                    null,
    prwrt                                        number                              null,
    koprw                                        number                              null,
    saiin                                        number                              null,
    fixkz                                        varchar2(1 char)                    null,
    exprw                                        number                              null,
    antei                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_mpm is 'LADS Material Forecast Value';
comment on column lads_mat_mpm.matnr is 'Material Number';
comment on column lads_mat_mpm.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_mpm.mpmseq is 'MPM - generated sequence number';
comment on column lads_mat_mpm.msgfn is 'Function';
comment on column lads_mat_mpm.ertag is 'First day of the period to which the values refer';
comment on column lads_mat_mpm.prwrt is 'Forecast value';
comment on column lads_mat_mpm.koprw is 'Corrected value for forecast';
comment on column lads_mat_mpm.saiin is 'Seasonal index';
comment on column lads_mat_mpm.fixkz is 'Indicator: consumption value is fixed';
comment on column lads_mat_mpm.exprw is 'Ex-post forecast value';
comment on column lads_mat_mpm.antei is 'Ratio of the corrected value to the original value (CV:OV)';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mpm
   add constraint lads_mat_mpm_pk primary key (matnr, mrcseq, mpmseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mpm to lads_app;
grant select, insert, update, delete on lads_mat_mpm to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mpm for lads.lads_mat_mpm;
