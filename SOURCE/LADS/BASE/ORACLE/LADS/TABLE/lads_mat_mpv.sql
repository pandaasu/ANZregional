/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mpv
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mpv

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mpv
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    mpvseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    verid                                        varchar2(4 char)                    null,
    bdatu                                        varchar2(8 char)                    null,
    adatu                                        varchar2(8 char)                    null,
    stlal                                        varchar2(2 char)                    null,
    stlan                                        varchar2(1 char)                    null,
    plnty                                        varchar2(1 char)                    null,
    plnnr                                        varchar2(8 char)                    null,
    alnal                                        varchar2(2 char)                    null,
    beskz                                        varchar2(1 char)                    null,
    sobsl                                        varchar2(2 char)                    null,
    losgr                                        number                              null,
    mdv01                                        varchar2(8 char)                    null,
    mdv02                                        varchar2(8 char)                    null,
    text1                                        varchar2(40 char)                   null,
    ewahr                                        number                              null,
    verto                                        varchar2(4 char)                    null,
    serkz                                        varchar2(1 char)                    null,
    bstmi                                        number                              null,
    bstma                                        number                              null,
    rgekz                                        varchar2(1 char)                    null,
    alort                                        varchar2(4 char)                    null,
    pltyg                                        varchar2(1 char)                    null,
    plnng                                        varchar2(8 char)                    null,
    alnag                                        varchar2(2 char)                    null,
    pltym                                        varchar2(1 char)                    null,
    plnnm                                        varchar2(8 char)                    null,
    alnam                                        varchar2(2 char)                    null,
    csplt                                        varchar2(4 char)                    null,
    matko                                        varchar2(18 char)                   null,
    elpro                                        varchar2(4 char)                    null,
    prvbe                                        varchar2(10 char)                   null,
    matko_external                               varchar2(40 char)                   null,
    matko_version                                varchar2(10 char)                   null,
    matko_guid                                   varchar2(32 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_mpv is 'LADS Material Production Version';
comment on column lads_mat_mpv.matnr is 'Material Number';
comment on column lads_mat_mpv.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_mpv.mpvseq is 'MPV - generated sequence number';
comment on column lads_mat_mpv.msgfn is 'Function';
comment on column lads_mat_mpv.verid is 'Production Version';
comment on column lads_mat_mpv.bdatu is 'Run-time end: production version';
comment on column lads_mat_mpv.adatu is 'Valid-from date of production version';
comment on column lads_mat_mpv.stlal is 'Alternative BOM';
comment on column lads_mat_mpv.stlan is 'BOM Usage';
comment on column lads_mat_mpv.plnty is 'Task List Type';
comment on column lads_mat_mpv.plnnr is 'Key for Task List Group';
comment on column lads_mat_mpv.alnal is 'Group Counter';
comment on column lads_mat_mpv.beskz is 'Procurement Type';
comment on column lads_mat_mpv.sobsl is 'Special procurement type';
comment on column lads_mat_mpv.losgr is 'Lot Size for Product Costing';
comment on column lads_mat_mpv.mdv01 is 'Aggregation field for production versions';
comment on column lads_mat_mpv.mdv02 is 'Aggregation field for production versions';
comment on column lads_mat_mpv.text1 is 'Short text on the production version';
comment on column lads_mat_mpv.ewahr is 'Usage Probability with Version Control';
comment on column lads_mat_mpv.verto is 'Distribution key for quantity produced';
comment on column lads_mat_mpv.serkz is 'Repetitive manufacturing allowed for version';
comment on column lads_mat_mpv.bstmi is 'Lower value of the lot-size interval';
comment on column lads_mat_mpv.bstma is 'Upper value of the lot-size interval';
comment on column lads_mat_mpv.rgekz is 'Indicator: backflush for RS header';
comment on column lads_mat_mpv.alort is 'Receiving storage location for repetitive manufacturing';
comment on column lads_mat_mpv.pltyg is 'Task List Type';
comment on column lads_mat_mpv.plnng is 'Key for Task List Group';
comment on column lads_mat_mpv.alnag is 'Group Counter';
comment on column lads_mat_mpv.pltym is 'Task List Type';
comment on column lads_mat_mpv.plnnm is 'Key for Task List Group';
comment on column lads_mat_mpv.alnam is 'Group Counter';
comment on column lads_mat_mpv.csplt is 'Apportionment Structure';
comment on column lads_mat_mpv.matko is 'Other material for which BOM and task list are maintained';
comment on column lads_mat_mpv.elpro is 'Proposed issue storage location for components';
comment on column lads_mat_mpv.prvbe is 'Default supply area for components';
comment on column lads_mat_mpv.matko_external is 'Long material number (future development) for field MATKO';
comment on column lads_mat_mpv.matko_version is 'Version number (future development) for field MATKO';
comment on column lads_mat_mpv.matko_guid is 'External GUID (future development) for field MATKO';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mpv
   add constraint lads_mat_mpv_pk primary key (matnr, mrcseq, mpvseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mpv to lads_app;
grant select, insert, update, delete on lads_mat_mpv to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mpv for lads.lads_mat_mpv;
