/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_wtx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_wtx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_wtx
   (lifnr                                        varchar2(10 char)                   not null,
    ccdseq                                       number                              not null,
    wtxseq                                       number                              not null,
    witht                                        varchar2(2 char)                    null,
    wt_subjct                                    varchar2(1 char)                    null,
    qsrec                                        varchar2(2 char)                    null,
    wt_wtstcd                                    varchar2(16 char)                   null,
    wt_withcd                                    varchar2(2 char)                    null,
    wt_exnr                                      varchar2(15 char)                   null,
    wt_exrt                                      varchar2(7 char)                    null,
    wt_exdf                                      varchar2(8 char)                    null,
    wt_exdt                                      varchar2(8 char)                    null,
    wt_wtexrs                                    varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_wtx is 'LADS Vendor Company Withholding Tax';
comment on column lads_ven_wtx.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_wtx.ccdseq is 'CCD - generated sequence number';
comment on column lads_ven_wtx.wtxseq is 'WTX - generated sequence number';
comment on column lads_ven_wtx.witht is 'Indicator for withholding tax type';
comment on column lads_ven_wtx.wt_subjct is 'Indicator: Subject to withholding tax?';
comment on column lads_ven_wtx.qsrec is 'Type of recipient';
comment on column lads_ven_wtx.wt_wtstcd is 'Withholding tax identification number';
comment on column lads_ven_wtx.wt_withcd is 'Withholding tax code';
comment on column lads_ven_wtx.wt_exnr is 'Exemption certificate number';
comment on column lads_ven_wtx.wt_exrt is 'Percentage NNN.NN field for IDoc';
comment on column lads_ven_wtx.wt_exdf is 'IDOC: Date';
comment on column lads_ven_wtx.wt_exdt is 'IDOC: Date';
comment on column lads_ven_wtx.wt_wtexrs is 'Reason for exemption';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_wtx
   add constraint lads_ven_wtx_pk primary key (lifnr, ccdseq, wtxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_wtx to lads_app;
grant select, insert, update, delete on lads_ven_wtx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_wtx for lads.lads_ven_wtx;
