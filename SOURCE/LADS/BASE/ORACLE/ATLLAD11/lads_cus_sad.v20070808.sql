/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_sad
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_sad

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/11   Steve Gregan   Added columns: ZZCURRENTFLAG
                                         ZZFUTUREFLAG
                                         ZZMARKETACCTFLAG

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_sad
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    begru                                        varchar2(4 char)                    null,
    loevm                                        varchar2(1 char)                    null,
    versg                                        varchar2(1 char)                    null,
    aufsd                                        varchar2(2 char)                    null,
    kalks                                        varchar2(1 char)                    null,
    kdgrp                                        varchar2(2 char)                    null,
    bzirk                                        varchar2(6 char)                    null,
    konda                                        varchar2(2 char)                    null,
    pltyp                                        varchar2(2 char)                    null,
    awahr                                        number                              null,
    inco1                                        varchar2(3 char)                    null,
    inco2                                        varchar2(28 char)                   null,
    lifsd                                        varchar2(2 char)                    null,
    autlf                                        varchar2(1 char)                    null,
    antlf                                        number                              null,
    kztlf                                        varchar2(1 char)                    null,
    kzazu                                        varchar2(1 char)                    null,
    chspl                                        varchar2(1 char)                    null,
    lprio                                        number                              null,
    eikto                                        varchar2(12 char)                   null,
    vsbed                                        varchar2(2 char)                    null,
    faksd                                        varchar2(2 char)                    null,
    mrnkz                                        varchar2(1 char)                    null,
    perfk                                        varchar2(2 char)                    null,
    perrl                                        varchar2(2 char)                    null,
    waers                                        varchar2(5 char)                    null,
    ktgrd                                        varchar2(2 char)                    null,
    zterm                                        varchar2(4 char)                    null,
    vwerk                                        varchar2(4 char)                    null,
    vkgrp                                        varchar2(3 char)                    null,
    vkbur                                        varchar2(4 char)                    null,
    vsort                                        varchar2(10 char)                   null,
    kvgr1                                        varchar2(3 char)                    null,
    kvgr2                                        varchar2(3 char)                    null,
    kvgr3                                        varchar2(3 char)                    null,
    kvgr4                                        varchar2(3 char)                    null,
    kvgr5                                        varchar2(3 char)                    null,
    bokre                                        varchar2(1 char)                    null,
    kurst                                        varchar2(4 char)                    null,
    prfre                                        varchar2(1 char)                    null,
    klabc                                        varchar2(2 char)                    null,
    kabss                                        varchar2(4 char)                    null,
    kkber                                        varchar2(4 char)                    null,
    cassd                                        varchar2(2 char)                    null,
    rdoff                                        varchar2(1 char)                    null,
    agrel                                        varchar2(1 char)                    null,
    megru                                        varchar2(4 char)                    null,
    uebto                                        varchar2(4 char)                    null,
    untto                                        varchar2(4 char)                    null,
    uebtk                                        varchar2(1 char)                    null,
    pvksm                                        varchar2(2 char)                    null,
    podkz                                        varchar2(1 char)                    null,
    podtg                                        varchar2(11 char)                   null,
    blind                                        varchar2(1 char)                    null,
    zzshelfgrp                                   number                              null,
    zzvmicdim                                    number                              null,
    zzcurrentflag                                varchar2(1 char)                    null,
    zzfutureflag                                 varchar2(1 char)                    null,
    zzmarketacctflag                             varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_sad is 'LADS Customer Sales Area';
comment on column lads_cus_sad.kunnr is 'Customer Number';
comment on column lads_cus_sad.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_sad.vkorg is 'Sales Organization';
comment on column lads_cus_sad.vtweg is 'Distribution Channel';
comment on column lads_cus_sad.spart is 'Division';
comment on column lads_cus_sad.begru is 'Authorization Group';
comment on column lads_cus_sad.loevm is 'Deletion flag for customer (sales level)';
comment on column lads_cus_sad.versg is 'Customer statistics group';
comment on column lads_cus_sad.aufsd is 'Customer order block (sales area)';
comment on column lads_cus_sad.kalks is 'Pricing procedure assigned to this customer';
comment on column lads_cus_sad.kdgrp is 'Customer group';
comment on column lads_cus_sad.bzirk is 'Sales district';
comment on column lads_cus_sad.konda is 'Price group (customer)';
comment on column lads_cus_sad.pltyp is 'Price list type';
comment on column lads_cus_sad.awahr is 'Order probability of the item';
comment on column lads_cus_sad.inco1 is 'Incoterms (part 1)';
comment on column lads_cus_sad.inco2 is 'Incoterms (part 2)';
comment on column lads_cus_sad.lifsd is 'Customer delivery block (sales area)';
comment on column lads_cus_sad.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_cus_sad.antlf is 'Maximum Number of Partial Deliveries Allowed Per Item';
comment on column lads_cus_sad.kztlf is 'Partial delivery at item level';
comment on column lads_cus_sad.kzazu is 'Order combination indicator';
comment on column lads_cus_sad.chspl is 'Batch split allowed';
comment on column lads_cus_sad.lprio is 'Delivery Priority';
comment on column lads_cus_sad.eikto is 'Shippers (Our) Account Number at the Customer or Vendor';
comment on column lads_cus_sad.vsbed is 'Shipping conditions';
comment on column lads_cus_sad.faksd is 'Billing block for customer (sales and distribution)';
comment on column lads_cus_sad.mrnkz is 'Manual invoice maintenance';
comment on column lads_cus_sad.perfk is 'Invoice dates (calendar identification)';
comment on column lads_cus_sad.perrl is 'Invoice list schedule (calendar identification)';
comment on column lads_cus_sad.waers is 'Currency';
comment on column lads_cus_sad.ktgrd is 'Account assignment group for this customer';
comment on column lads_cus_sad.zterm is 'Terms of payment key';
comment on column lads_cus_sad.vwerk is 'Delivering Plant';
comment on column lads_cus_sad.vkgrp is 'Sales group';
comment on column lads_cus_sad.vkbur is 'Sales office';
comment on column lads_cus_sad.vsort is 'Item proposal';
comment on column lads_cus_sad.kvgr1 is 'Invoice Combina';
comment on column lads_cus_sad.kvgr2 is 'Expected Band Price';
comment on column lads_cus_sad.kvgr3 is 'Cust. Accept Int. Pallet';
comment on column lads_cus_sad.kvgr4 is 'Guaranteed Band Price';
comment on column lads_cus_sad.kvgr5 is 'Back Order Accepted';
comment on column lads_cus_sad.bokre is 'ID: Customer is to receive rebates';
comment on column lads_cus_sad.kurst is 'Exchange Rate Type';
comment on column lads_cus_sad.prfre is 'Relevant for price determination ID';
comment on column lads_cus_sad.klabc is 'Customer classification (ABC analysis)';
comment on column lads_cus_sad.kabss is 'Customer payment guarantee procedure';
comment on column lads_cus_sad.kkber is 'Credit control area';
comment on column lads_cus_sad.cassd is 'Sales block for customer (sales area)';
comment on column lads_cus_sad.rdoff is 'Switch off rounding?';
comment on column lads_cus_sad.agrel is 'Indicator: Relevant for agency business';
comment on column lads_cus_sad.megru is 'Unit of measure group';
comment on column lads_cus_sad.uebto is 'Overdelivery tolerance limit (BTCI)';
comment on column lads_cus_sad.untto is 'Underdelivery tolerance (BTCI)';
comment on column lads_cus_sad.uebtk is 'Unlimited overdelivery allowed';
comment on column lads_cus_sad.pvksm is 'Customer procedure for product proposal';
comment on column lads_cus_sad.podkz is 'Relevant for POD processing';
comment on column lads_cus_sad.podtg is 'Timeframe for Confirmation of POD (BI)';
comment on column lads_cus_sad.blind is 'Indicator: Doc. index compilation active for purchase orders';
comment on column lads_cus_sad.zzshelfgrp is 'Customer Group for Batch Search Strategy';
comment on column lads_cus_sad.zzvmicdim is 'VMI Customer Data Input Method'; 
comment on column lads_cus_sad.zzcurrentflag is 'Current Planning Flag';
comment on column lads_cus_sad.zzfutureflag is 'Future Planning Flag';
comment on column lads_cus_sad.zzmarketacctflag is 'Market Headquarter Account Flag';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_sad
   add constraint lads_cus_sad_pk primary key (kunnr, sadseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_sad to lads_app;
grant select, insert, update, delete on lads_cus_sad to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_sad for lads.lads_cus_sad;
