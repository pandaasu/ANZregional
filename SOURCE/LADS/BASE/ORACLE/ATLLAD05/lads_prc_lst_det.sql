/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_prc_lst_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_prc_lst_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Replaced DATSEQ with KNUMH
                          as a result of LADS_PRC_LST_HDR 
                          and LADS_PRC_LST_DAT flattening
 2005/05   Linden Glen    Primary key now includes DATAB
                          

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_prc_lst_det
   (vakey                                        varchar2(50 char)                   not null,
    kschl                                        varchar2(4 char)                    not null,
    knumh                                        varchar2(10 char)                   not null,
    datab                                        varchar2(8 char)                    not null,
    detseq                                       number                              not null,
    anzauf                                       number                              null,
    gkwrt                                        number                              null,
    kbrue                                        number                              null,
    klf_kal                                      number                              null,
    klf_stg                                      number                              null,
    kmein                                        varchar2(3 char)                    null,
    komxwrt                                      number                              null,
    konwa                                        varchar2(5 char)                    null,
    krech                                        varchar2(1 char)                    null,
    kschl1                                       varchar2(4 char)                    null,
    kstbm                                        number                              null,
    kstbw                                        number                              null,
    kumne                                        number                              null,
    meins                                        varchar2(3 char)                    null,
    kbetr                                        number                              null,
    kpein                                        number                              null,
    mikbas                                       number                              null,
    mxkbas                                       number                              null,
    mxwrt                                        number                              null,
    stfkz                                        varchar2(1 char)                    null,
    valdt                                        varchar2(8 char)                    null,
    valtg                                        number                              null,
    zaehk_ind                                    number                              null,
    kwaeh                                        varchar2(5 char)                    null,
    knumt                                        varchar2(10 char)                   null,
    kzbzg                                        varchar2(1 char)                    null,
    konms                                        varchar2(3 char)                    null,
    konws                                        varchar2(5 char)                    null,
    prsch                                        varchar2(4 char)                    null,
    kumza                                        number                              null,
    pkwrt                                        number                              null,
    ukbas                                        number                              null,
    kznep                                        varchar2(1 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    lifnr                                        varchar2(10 char)                   null,
    mwsk1                                        varchar2(2 char)                    null,
    loevm_ko                                     varchar2(1 char)                    null,
    bomat                                        varchar2(18 char)                   null,
    kspae                                        varchar2(1 char)                    null,
    bosta                                        varchar2(1 char)                    null,
    knuma_pi                                     varchar2(10 char)                   null,
    knuma_ag                                     varchar2(10 char)                   null,
    knuma_sq                                     varchar2(10 char)                   null,
    vkkal                                        varchar2(1 char)                    null,
    aktnr                                        varchar2(10 char)                   null,
    knuma_bo                                     varchar2(10 char)                   null,
    mdflg                                        varchar2(1 char)                    null,
    zterm                                        varchar2(4 char)                    null,
    bomat_external                               varchar2(40 char)                   null,
    bomat_version                                varchar2(10 char)                   null,
    bomat_guid                                   varchar2(32 char)                   null);

/**/
/* Comments
/**/
comment on table lads_prc_lst_det is 'LADS Price List Detail';
comment on column lads_prc_lst_det.vakey is 'Variable key 50 bytes';
comment on column lads_prc_lst_det.kschl is 'Condition type';
comment on column lads_prc_lst_det.knumh is 'Condition record number';
comment on column lads_prc_lst_det.datab is 'Valid-From Date';
comment on column lads_prc_lst_det.detseq is 'DET - generated sequence number';
comment on column lads_prc_lst_det.anzauf is 'Maximum number of sales orders per condition record';
comment on column lads_prc_lst_det.gkwrt is 'Upper limit for the condition rate';
comment on column lads_prc_lst_det.kbrue is 'Accrual Amount';
comment on column lads_prc_lst_det.klf_kal is 'Scale number for pricing';
comment on column lads_prc_lst_det.klf_stg is 'Number of incremental scale';
comment on column lads_prc_lst_det.kmein is 'Condition unit';
comment on column lads_prc_lst_det.komxwrt is 'Maximum condition value';
comment on column lads_prc_lst_det.konwa is 'Rate unit (currency or percentage)';
comment on column lads_prc_lst_det.krech is 'Calculation type for condition';
comment on column lads_prc_lst_det.kschl1 is 'Condition type';
comment on column lads_prc_lst_det.kstbm is 'Condition scale quantity';
comment on column lads_prc_lst_det.kstbw is 'Scale value';
comment on column lads_prc_lst_det.kumne is 'Denominator for converting condition units to base units';
comment on column lads_prc_lst_det.meins is 'Base Unit of Measure';
comment on column lads_prc_lst_det.kbetr is 'Rate (condition amount or percentage)';
comment on column lads_prc_lst_det.kpein is 'Condition pricing unit';
comment on column lads_prc_lst_det.mikbas is 'Minimum condition base value';
comment on column lads_prc_lst_det.mxkbas is 'Maximum condition base value';
comment on column lads_prc_lst_det.mxwrt is 'Lower limit of the condition rate/amount';
comment on column lads_prc_lst_det.stfkz is 'Scale Type';
comment on column lads_prc_lst_det.valdt is 'Fixed value date';
comment on column lads_prc_lst_det.valtg is 'Additional value days';
comment on column lads_prc_lst_det.zaehk_ind is 'Condition item index';
comment on column lads_prc_lst_det.kwaeh is 'Condition currency (for cumulation fields)';
comment on column lads_prc_lst_det.knumt is 'Number of texts';
comment on column lads_prc_lst_det.kzbzg is 'Scale basis indicator';
comment on column lads_prc_lst_det.konms is 'Condition scale unit of measure';
comment on column lads_prc_lst_det.konws is 'Scale currency';
comment on column lads_prc_lst_det.prsch is 'Price levels';
comment on column lads_prc_lst_det.kumza is 'Numerator for converting condition units to base units';
comment on column lads_prc_lst_det.pkwrt is 'Planned condition value';
comment on column lads_prc_lst_det.ukbas is 'Planned condition basis';
comment on column lads_prc_lst_det.kznep is 'Condition exclusion indicator';
comment on column lads_prc_lst_det.kunnr is 'Customer Number 1';
comment on column lads_prc_lst_det.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_prc_lst_det.mwsk1 is 'Tax on sales/purchases code';
comment on column lads_prc_lst_det.loevm_ko is 'Deletion Indicator for Condition Item';
comment on column lads_prc_lst_det.bomat is 'Material for rebate settlement';
comment on column lads_prc_lst_det.kspae is 'Rebate was set up retroactively';
comment on column lads_prc_lst_det.bosta is 'Status of the agreement';
comment on column lads_prc_lst_det.knuma_pi is 'Promotion';
comment on column lads_prc_lst_det.knuma_ag is 'Sales deal';
comment on column lads_prc_lst_det.knuma_sq is 'Sales quote';
comment on column lads_prc_lst_det.vkkal is 'Sales Price Calculation: Relevant to pricing';
comment on column lads_prc_lst_det.aktnr is 'Promotion';
comment on column lads_prc_lst_det.knuma_bo is 'Agreement (subsequent settlement)';
comment on column lads_prc_lst_det.mdflg is 'Indicator: Matrix maintenance';
comment on column lads_prc_lst_det.zterm is 'Terms of payment key';
comment on column lads_prc_lst_det.bomat_external is 'Long material number (future development) for field BOMAT';
comment on column lads_prc_lst_det.bomat_version is 'Version number (future development) for field BOMAT';
comment on column lads_prc_lst_det.bomat_guid is 'External GUID (future development) for field BOMAT';

/**/
/* Primary Key Constraint
/**/
alter table lads_prc_lst_det
   add constraint lads_prc_lst_det_pk primary key (vakey, kschl, knumh, datab, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_prc_lst_det to lads_app;
grant select, insert, update, delete on lads_prc_lst_det to ics_app;
grant select on lads_prc_lst_det to site_app;
grant select on lads_prc_lst_det to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym lads_prc_lst_det for lads.lads_prc_lst_det;
