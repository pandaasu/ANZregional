/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_iss
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_iss

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_iss
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    sgtyp                                        varchar2(3 char)                    null,
    zltyp                                        varchar2(3 char)                    null,
    lvalt                                        varchar2(3 char)                    null,
    altno                                        varchar2(2 char)                    null,
    alref                                        varchar2(5 char)                    null,
    zlart                                        varchar2(3 char)                    null,
    linno                                        number                              null,
    rang                                         varchar2(2 char)                    null,
    exgrp                                        varchar2(8 char)                    null,
    uepos                                        varchar2(6 char)                    null,
    matkl                                        varchar2(9 char)                    null,
    menge                                        varchar2(15 char)                   null,
    menee                                        varchar2(3 char)                    null,
    bmng2                                        varchar2(15 char)                   null,
    pmene                                        varchar2(3 char)                    null,
    bpumn                                        number                              null,
    bpumz                                        number                              null,
    vprei                                        varchar2(15 char)                   null,
    peinh                                        varchar2(9 char)                    null,
    netwr                                        varchar2(18 char)                   null,
    anetw                                        varchar2(18 char)                   null,
    skfbp                                        varchar2(18 char)                   null,
    curcy                                        varchar2(3 char)                    null,
    preis                                        varchar2(18 char)                   null,
    action                                       varchar2(3 char)                    null,
    kzabs                                        varchar2(1 char)                    null,
    uebto                                        varchar2(4 char)                    null,
    uebtk                                        varchar2(1 char)                    null,
    lbnum                                        varchar2(3 char)                    null,
    ausgb                                        number                              null,
    frpos                                        varchar2(6 char)                    null,
    topos                                        varchar2(6 char)                    null,
    ktxt1                                        varchar2(40 char)                   null,
    ktxt2                                        varchar2(40 char)                   null,
    pernr                                        number                              null,
    lgart                                        varchar2(4 char)                    null,
    stell                                        number                              null,
    zwert                                        varchar2(18 char)                   null,
    formelnr                                     varchar2(10 char)                   null,
    frmval1                                      number                              null,
    frmval2                                      number                              null,
    frmval3                                      number                              null,
    frmval4                                      number                              null,
    frmval5                                      number                              null,
    userf1_num                                   number                              null,
    userf2_num                                   number                              null,
    userf1_txt                                   varchar2(40 char)                   null,
    userf2_txt                                   varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_iss is 'LADS Sales Order Item Service Specification';
comment on column lads_sal_ord_iss.belnr is 'Document number';
comment on column lads_sal_ord_iss.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_iss.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_iss.sgtyp is 'IDoc service specifications segment type';
comment on column lads_sal_ord_iss.zltyp is 'IDoc service specifications line category';
comment on column lads_sal_ord_iss.lvalt is 'IDoc service specifications alternatives';
comment on column lads_sal_ord_iss.altno is 'IDoc alternative number for service specifications';
comment on column lads_sal_ord_iss.alref is 'IDoc Allocation Number for Service Specifications';
comment on column lads_sal_ord_iss.zlart is 'IDoc service specifications line type';
comment on column lads_sal_ord_iss.linno is 'Line number';
comment on column lads_sal_ord_iss.rang is 'Hierarchy level of group';
comment on column lads_sal_ord_iss.exgrp is 'Outline Level';
comment on column lads_sal_ord_iss.uepos is 'Higher-Level Item in BOM Structures';
comment on column lads_sal_ord_iss.matkl is 'IDOC material class';
comment on column lads_sal_ord_iss.menge is 'Quantity';
comment on column lads_sal_ord_iss.menee is 'Unit of measure';
comment on column lads_sal_ord_iss.bmng2 is 'Quantity in price unit';
comment on column lads_sal_ord_iss.pmene is 'Price unit of measure';
comment on column lads_sal_ord_iss.bpumn is 'Denominator for conv. of order price unit into order unit';
comment on column lads_sal_ord_iss.bpumz is 'Numerator for conversion of order price unit into order unit';
comment on column lads_sal_ord_iss.vprei is 'Price (net)';
comment on column lads_sal_ord_iss.peinh is 'Price unit';
comment on column lads_sal_ord_iss.netwr is 'Item value (net)';
comment on column lads_sal_ord_iss.anetw is 'Absolute net value of item';
comment on column lads_sal_ord_iss.skfbp is 'Amount qualifying for cash discount';
comment on column lads_sal_ord_iss.curcy is 'Currency';
comment on column lads_sal_ord_iss.preis is 'Gross price';
comment on column lads_sal_ord_iss.action is 'Action code for the item';
comment on column lads_sal_ord_iss.kzabs is 'Flag: order acknowledgment required';
comment on column lads_sal_ord_iss.uebto is 'overfulfillment tolerance';
comment on column lads_sal_ord_iss.uebtk is 'Unlimited overfulfillment';
comment on column lads_sal_ord_iss.lbnum is 'Short description of service type';
comment on column lads_sal_ord_iss.ausgb is 'Edition of service type';
comment on column lads_sal_ord_iss.frpos is 'Lower limit';
comment on column lads_sal_ord_iss.topos is 'Upper limit';
comment on column lads_sal_ord_iss.ktxt1 is 'Short text';
comment on column lads_sal_ord_iss.ktxt2 is 'Short text';
comment on column lads_sal_ord_iss.pernr is 'Personnel Number';
comment on column lads_sal_ord_iss.lgart is 'Wage type';
comment on column lads_sal_ord_iss.stell is 'Job';
comment on column lads_sal_ord_iss.zwert is 'Total value of sum segment';
comment on column lads_sal_ord_iss.formelnr is 'Formula number';
comment on column lads_sal_ord_iss.frmval1 is 'Formula value';
comment on column lads_sal_ord_iss.frmval2 is 'Formula value';
comment on column lads_sal_ord_iss.frmval3 is 'Formula value';
comment on column lads_sal_ord_iss.frmval4 is 'Formula value';
comment on column lads_sal_ord_iss.frmval5 is 'Formula value';
comment on column lads_sal_ord_iss.userf1_num is 'User-defined field';
comment on column lads_sal_ord_iss.userf2_num is 'User-defined field';
comment on column lads_sal_ord_iss.userf1_txt is 'User-defined field';
comment on column lads_sal_ord_iss.userf2_txt is 'User-defined field';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_iss
   add constraint lads_sal_ord_iss_pk primary key (belnr, genseq, issseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_iss to lads_app;
grant select, insert, update, delete on lads_sal_ord_iss to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_iss for lads.lads_sal_ord_iss;
