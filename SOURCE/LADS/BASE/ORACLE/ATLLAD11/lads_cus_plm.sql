/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_plm
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_plm

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_plm
   (kunnr                                        varchar2(10 char)                   not null,
    plmseq                                       number                              not null,
    locnr                                        varchar2(10 char)                   null,
    eroed                                        varchar2(8 char)                    null,
    schld                                        varchar2(8 char)                    null,
    spdab                                        varchar2(8 char)                    null,
    spdbi                                        varchar2(8 char)                    null,
    autob                                        varchar2(1 char)                    null,
    kopro                                        varchar2(4 char)                    null,
    layvr                                        varchar2(10 char)                   null,
    flvar                                        varchar2(4 char)                    null,
    stfak                                        varchar2(2 char)                    null,
    wanid                                        varchar2(3 char)                    null,
    verfl                                        number                              null,
    verfe                                        varchar2(3 char)                    null,
    spgr1                                        varchar2(2 char)                    null,
    inpro                                        varchar2(4 char)                    null,
    ekoar                                        varchar2(4 char)                    null,
    kzlik                                        varchar2(1 char)                    null,
    betrp                                        varchar2(4 char)                    null,
    erdat                                        varchar2(8 char)                    null,
    ernam                                        varchar2(12 char)                   null,
    nlmatfb                                      varchar2(1 char)                    null,
    bwwrk                                        varchar2(4 char)                    null,
    bwvko                                        varchar2(4 char)                    null,
    bwvtw                                        varchar2(2 char)                    null,
    bbpro                                        varchar2(4 char)                    null,
    vkbur_wrk                                    varchar2(4 char)                    null,
    vlfkz                                        varchar2(1 char)                    null,
    lstfl                                        varchar2(2 char)                    null,
    ligrd                                        varchar2(1 char)                    null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    desroi                                       varchar2(7 char)                    null,
    timinc                                       varchar2(6 char)                    null,
    posws                                        varchar2(5 char)                    null,
    ssopt_pro                                    varchar2(4 char)                    null,
    wbpro                                        varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_plm is 'LADS Customer Plant';
comment on column lads_cus_plm.kunnr is 'Customer Number';
comment on column lads_cus_plm.plmseq is 'PLM - generated sequence number';
comment on column lads_cus_plm.locnr is 'Customer number for plant';
comment on column lads_cus_plm.eroed is 'Opening date';
comment on column lads_cus_plm.schld is 'Closing date';
comment on column lads_cus_plm.spdab is 'Block from';
comment on column lads_cus_plm.spdbi is 'Block to';
comment on column lads_cus_plm.autob is 'Automatic purchase order';
comment on column lads_cus_plm.kopro is 'POS outbound profile';
comment on column lads_cus_plm.layvr is 'Layout';
comment on column lads_cus_plm.flvar is 'Area schema';
comment on column lads_cus_plm.stfak is 'Calendar';
comment on column lads_cus_plm.wanid is 'Goods receiving hours ID (default value)';
comment on column lads_cus_plm.verfl is 'Sales area (floor space)';
comment on column lads_cus_plm.verfe is 'Sales area (floor space) unit';
comment on column lads_cus_plm.spgr1 is 'Blocking reason';
comment on column lads_cus_plm.inpro is 'POS inbound profile';
comment on column lads_cus_plm.ekoar is 'POS outbound: condition type group';
comment on column lads_cus_plm.kzlik is 'Listing conditions should be created per assortment';
comment on column lads_cus_plm.betrp is 'Plant profile';
comment on column lads_cus_plm.erdat is 'Date on which the record was created';
comment on column lads_cus_plm.ernam is 'Name of Person who Created the Object';
comment on column lads_cus_plm.nlmatfb is 'ID: Carry out subsequent listing';
comment on column lads_cus_plm.bwwrk is 'Plant for retail price determination';
comment on column lads_cus_plm.bwvko is 'Sales organization for retail price determination';
comment on column lads_cus_plm.bwvtw is 'Distribution channel for retail price determination';
comment on column lads_cus_plm.bbpro is 'Assortment list profile';
comment on column lads_cus_plm.vkbur_wrk is 'Sales office';
comment on column lads_cus_plm.vlfkz is 'Plant category';
comment on column lads_cus_plm.lstfl is 'Listing procedure for store or other assortment categories';
comment on column lads_cus_plm.ligrd is 'Basic listing rule for assortments';
comment on column lads_cus_plm.vkorg is 'Sales organization for intercompany billing';
comment on column lads_cus_plm.vtweg is 'Distribution channel for intercompany billing';
comment on column lads_cus_plm.desroi is 'Required ROI (for ALE)';
comment on column lads_cus_plm.timinc is 'Time Increment for Investment Buying Algorithms (for ALE)';
comment on column lads_cus_plm.posws is 'Currency of POS systems';
comment on column lads_cus_plm.ssopt_pro is 'Space management profile';
comment on column lads_cus_plm.wbpro is 'Profile for value-based inventory management';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_plm
   add constraint lads_cus_plm_pk primary key (kunnr, plmseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_plm to lads_app;
grant select, insert, update, delete on lads_cus_plm to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_plm for lads.lads_cus_plm;
