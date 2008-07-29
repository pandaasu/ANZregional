/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_con
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_con

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_con
   (belnr                                        varchar2(35 char)                   not null,
    conseq                                       number                              not null,
    kschl                                        varchar2(4 char)                    null,
    krech                                        varchar2(1 char)                    null,
    kawrt                                        number                              null,
    awein                                        varchar2(5 char)                    null,
    awei1                                        varchar2(5 char)                    null,
    kbetr                                        number                              null,
    koein                                        varchar2(5 char)                    null,
    koei1                                        varchar2(5 char)                    null,
    kkurs                                        number                              null,
    kpein                                        number                              null,
    kmein                                        varchar2(3 char)                    null,
    kumza                                        number                              null,
    kumne                                        number                              null,
    kntyp                                        varchar2(1 char)                    null,
    kstat                                        varchar2(1 char)                    null,
    kherk                                        varchar2(1 char)                    null,
    kwert                                        number                              null,
    ksteu                                        varchar2(1 char)                    null,
    kinak                                        varchar2(1 char)                    null,
    koaid                                        varchar2(1 char)                    null,
    knumt                                        varchar2(10 char)                   null,
    drukz                                        varchar2(1 char)                    null,
    vtext                                        varchar2(40 char)                   null,
    mwskz                                        varchar2(2 char)                    null,
    stufe                                        number                              null,
    wegxx                                        number                              null,
    kfaktor                                      number                              null,
    nrmng                                        number                              null,
    mdflg                                        varchar2(1 char)                    null,
    kwert_euro                                   number                              null);

/**/
/* Comments
/**/
comment on table lads_inv_con is 'LADS Invoice Condition';
comment on column lads_inv_con.belnr is 'IDOC document number';
comment on column lads_inv_con.conseq is 'CON - generated sequence number';
comment on column lads_inv_con.kschl is 'Condition type';
comment on column lads_inv_con.krech is 'Calculation type for condition';
comment on column lads_inv_con.kawrt is 'Condition base value';
comment on column lads_inv_con.awein is '"Rate unit (currency, sales unit, or %)"';
comment on column lads_inv_con.awei1 is '"Rate unit (currency, sales unit, or %)"';
comment on column lads_inv_con.kbetr is 'Rate (condition amount or percentage)';
comment on column lads_inv_con.koein is '"Rate unit (currency, sales unit, or %)"';
comment on column lads_inv_con.koei1 is '"Rate unit (currency, sales unit, or %)"';
comment on column lads_inv_con.kkurs is 'Condition exchange rate for conversion to local currency';
comment on column lads_inv_con.kpein is 'Condition pricing unit';
comment on column lads_inv_con.kmein is 'Condition unit in the document';
comment on column lads_inv_con.kumza is 'Numerator for converting condition units to base units';
comment on column lads_inv_con.kumne is 'Denominator for converting condition units to base units';
comment on column lads_inv_con.kntyp is '"Condition category (examples: tax, freight, price, cost)"';
comment on column lads_inv_con.kstat is 'Condition is used for statistics';
comment on column lads_inv_con.kherk is 'Origin of the condition';
comment on column lads_inv_con.kwert is 'Condition value';
comment on column lads_inv_con.ksteu is 'Condition control';
comment on column lads_inv_con.kinak is 'Condition is inactive';
comment on column lads_inv_con.koaid is 'Condition class';
comment on column lads_inv_con.knumt is 'Number of texts';
comment on column lads_inv_con.drukz is 'Print ID for condition lines';
comment on column lads_inv_con.vtext is 'Description';
comment on column lads_inv_con.mwskz is 'Tax on sales/purchases code';
comment on column lads_inv_con.stufe is 'Level (in multi-level BOM explosions)';
comment on column lads_inv_con.wegxx is 'Path (for multi-level BOM explosions)';
comment on column lads_inv_con.kfaktor is 'Factor for condition base value';
comment on column lads_inv_con.nrmng is 'Discount in kind: Inclusive bonus quantity of item';
comment on column lads_inv_con.mdflg is 'Indicator: Matrix maintenance';
comment on column lads_inv_con.kwert_euro is 'Condition value';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_con
   add constraint lads_inv_con_pk primary key (belnr, conseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_con to lads_app;
grant select, insert, update, delete on lads_inv_con to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_con for lads.lads_inv_con;
