/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mbe
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mbe

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mbe
   (matnr                                        varchar2(18 char)                   not null,
    mbeseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    bwkey                                        varchar2(4 char)                    null,
    bwtar                                        varchar2(10 char)                   null,
    lvorm                                        varchar2(1 char)                    null,
    vprsv                                        varchar2(1 char)                    null,
    verpr                                        number                              null,
    stprs                                        number                              null,
    peinh                                        number                              null,
    bklas                                        varchar2(4 char)                    null,
    vmvpr                                        varchar2(1 char)                    null,
    vmver                                        number                              null,
    vmstp                                        number                              null,
    vmpei                                        number                              null,
    vmbkl                                        varchar2(4 char)                    null,
    vjvpr                                        varchar2(1 char)                    null,
    vjver                                        number                              null,
    vjstp                                        number                              null,
    lfgja                                        number                              null,
    lfmon                                        number                              null,
    bwtty                                        varchar2(1 char)                    null,
    zkprs                                        number                              null,
    zkdat                                        varchar2(8 char)                    null,
    bwprs                                        number                              null,
    bwprh                                        number                              null,
    vjbws                                        number                              null,
    vjbwh                                        number                              null,
    vvjlb                                        number                              null,
    vvmlb                                        number                              null,
    vvsal                                        number                              null,
    zplpr                                        number                              null,
    zplp1                                        number                              null,
    zplp2                                        number                              null,
    zplp3                                        number                              null,
    zpld1                                        varchar2(8 char)                    null,
    zpld2                                        varchar2(8 char)                    null,
    zpld3                                        varchar2(8 char)                    null,
    kalkz                                        varchar2(1 char)                    null,
    kalkl                                        varchar2(1 char)                    null,
    xlifo                                        varchar2(1 char)                    null,
    mypol                                        varchar2(4 char)                    null,
    bwph1                                        number                              null,
    bwps1                                        number                              null,
    abwkz                                        number                              null,
    pstat                                        varchar2(15 char)                   null,
    kaln1                                        number                              null,
    kalnr                                        number                              null,
    bwva1                                        varchar2(3 char)                    null,
    bwva2                                        varchar2(3 char)                    null,
    bwva3                                        varchar2(3 char)                    null,
    vers1                                        number                              null,
    vers2                                        number                              null,
    vers3                                        number                              null,
    hrkft                                        varchar2(4 char)                    null,
    kosgr                                        varchar2(10 char)                   null,
    pprdz                                        number                              null,
    pprdl                                        number                              null,
    pprdv                                        number                              null,
    pdatz                                        number                              null,
    pdatl                                        number                              null,
    pdatv                                        number                              null,
    ekalr                                        varchar2(1 char)                    null,
    vplpr                                        number                              null,
    mlmaa                                        varchar2(1 char)                    null,
    mlast                                        varchar2(1 char)                    null,
    vjbkl                                        varchar2(4 char)                    null,
    vjpei                                        number                              null,
    hkmat                                        varchar2(1 char)                    null,
    eklas                                        varchar2(4 char)                    null,
    qklas                                        varchar2(4 char)                    null,
    mtuse                                        varchar2(1 char)                    null,
    mtorg                                        varchar2(1 char)                    null,
    ownpr                                        varchar2(1 char)                    null,
    bwpei                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_mat_mbe is 'LADS Material Valuation';
comment on column lads_mat_mbe.matnr is 'Material Number';
comment on column lads_mat_mbe.mbeseq is 'MBE - generated sequence number';
comment on column lads_mat_mbe.msgfn is 'Function';
comment on column lads_mat_mbe.bwkey is 'Valuation area';
comment on column lads_mat_mbe.bwtar is 'Valuation Type';
comment on column lads_mat_mbe.lvorm is 'Deletion Indicator';
comment on column lads_mat_mbe.vprsv is 'Price Control Indicator';
comment on column lads_mat_mbe.verpr is 'Moving Average Price/Periodic Unit Price';
comment on column lads_mat_mbe.stprs is 'Standard Price';
comment on column lads_mat_mbe.peinh is 'Price Unit';
comment on column lads_mat_mbe.bklas is 'Valuation Class';
comment on column lads_mat_mbe.vmvpr is 'Price Control Indicator in Previous Period';
comment on column lads_mat_mbe.vmver is 'Moving Average Price/Periodic Unit Price in Previous Period';
comment on column lads_mat_mbe.vmstp is 'Standard price in the previous period';
comment on column lads_mat_mbe.vmpei is 'Price unit of previous period';
comment on column lads_mat_mbe.vmbkl is 'Valuation Class in Previous Period';
comment on column lads_mat_mbe.vjvpr is 'Price Control Indicator in Previous Year';
comment on column lads_mat_mbe.vjver is 'Moving Average Price/Periodic Unit Price in Previous Year';
comment on column lads_mat_mbe.vjstp is 'Standard price in previous year';
comment on column lads_mat_mbe.lfgja is 'Fiscal Year of Current Period';
comment on column lads_mat_mbe.lfmon is 'Current period (posting period)';
comment on column lads_mat_mbe.bwtty is 'Valuation Category';
comment on column lads_mat_mbe.zkprs is 'Future price';
comment on column lads_mat_mbe.zkdat is 'Date as of which the price is valid';
comment on column lads_mat_mbe.bwprs is 'Valuation price based on tax law: level 1';
comment on column lads_mat_mbe.bwprh is 'Valuation price based on commercial law: level 1';
comment on column lads_mat_mbe.vjbws is 'Valuation price based on tax law: level 3';
comment on column lads_mat_mbe.vjbwh is 'Valuation price based on commercial law: level 3';
comment on column lads_mat_mbe.vvjlb is 'Total valuated stock in year before last';
comment on column lads_mat_mbe.vvmlb is 'Total valuated stock in period before last';
comment on column lads_mat_mbe.vvsal is 'Value of total valuated stock in period before last';
comment on column lads_mat_mbe.zplpr is 'Future planned price';
comment on column lads_mat_mbe.zplp1 is 'Future Planned Price 1';
comment on column lads_mat_mbe.zplp2 is 'Future Planned Price 2';
comment on column lads_mat_mbe.zplp3 is 'Future Planned Price 3';
comment on column lads_mat_mbe.zpld1 is 'Date from Which Future Planned Price 1 Is Valid';
comment on column lads_mat_mbe.zpld2 is 'Date from Which Future Planned Price 2 Is Valid';
comment on column lads_mat_mbe.zpld3 is 'Date from Which Future Planned Price 3 Is Valid';
comment on column lads_mat_mbe.kalkz is 'Indicator: Standard cost estimate for the period';
comment on column lads_mat_mbe.kalkl is 'Standard Cost Estimate for Current Period';
comment on column lads_mat_mbe.xlifo is 'LIFO/FIFO-relevant';
comment on column lads_mat_mbe.mypol is 'Pool number for LIFO valuation';
comment on column lads_mat_mbe.bwph1 is 'Valuation price based on commercial law: level 2';
comment on column lads_mat_mbe.bwps1 is 'Valuation price based on tax law: level 2';
comment on column lads_mat_mbe.abwkz is 'Lowest value: devaluation indicator';
comment on column lads_mat_mbe.pstat is 'Maintenance status';
comment on column lads_mat_mbe.kaln1 is 'Cost Estimate Number - Product Costing';
comment on column lads_mat_mbe.kalnr is 'Cost Estimate Number for Cost Est. w/o Qty Structure';
comment on column lads_mat_mbe.bwva1 is 'Valuation Variant for Future Standard Cost Estimate';
comment on column lads_mat_mbe.bwva2 is 'Valuation Variant for Current Standard Cost Estimate';
comment on column lads_mat_mbe.bwva3 is 'Valuation Variant for Previous Standard Cost Estimate';
comment on column lads_mat_mbe.vers1 is 'Costing Version of Future Standard Cost Estimate';
comment on column lads_mat_mbe.vers2 is 'Costing Version of Current Standard Cost Estimate';
comment on column lads_mat_mbe.vers3 is 'Costing Version of Previous Standard Cost Estimate';
comment on column lads_mat_mbe.hrkft is 'Origin Group as Subdivision of Cost Element';
comment on column lads_mat_mbe.kosgr is 'Costing Overhead Group';
comment on column lads_mat_mbe.pprdz is 'Period of Future Standard Cost Estimate';
comment on column lads_mat_mbe.pprdl is 'Period of Current Standard Cost Estimate';
comment on column lads_mat_mbe.pprdv is 'Period of Previous Standard Cost Estimate';
comment on column lads_mat_mbe.pdatz is 'Fiscal Year of Future Standard Cost Estimate';
comment on column lads_mat_mbe.pdatl is 'Fiscal Year of Current Standard Cost Estimate';
comment on column lads_mat_mbe.pdatv is 'Fiscal Year of Previous Standard Cost Estimate';
comment on column lads_mat_mbe.ekalr is 'Material Is Costed with Quantity Structure';
comment on column lads_mat_mbe.vplpr is 'Previous planned price';
comment on column lads_mat_mbe.mlmaa is 'Material ledger activated at material level';
comment on column lads_mat_mbe.mlast is 'Material Price Determination: Control';
comment on column lads_mat_mbe.vjbkl is 'Valuation Class in Previous Year';
comment on column lads_mat_mbe.vjpei is 'Price unit of previous year';
comment on column lads_mat_mbe.hkmat is 'Material Origin';
comment on column lads_mat_mbe.eklas is 'Valuation Class for Sales Order Stock';
comment on column lads_mat_mbe.qklas is 'Valuation Class for Project Stock';
comment on column lads_mat_mbe.mtuse is 'Usage of the material';
comment on column lads_mat_mbe.mtorg is 'Origin of the material';
comment on column lads_mat_mbe.ownpr is 'Produced in-house';
comment on column lads_mat_mbe.bwpei is 'Price unit for valuation prices based on tax/commercial law';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mbe
   add constraint lads_mat_mbe_pk primary key (matnr, mbeseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mbe to lads_app;
grant select, insert, update, delete on lads_mat_mbe to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mbe for lads.lads_mat_mbe;
