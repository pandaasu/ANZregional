/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2007/03   Steve Gregan   Added LADS_FLATTENED

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_hdr
   (lifnr                                        varchar2(10 char)                   not null,
    begru                                        varchar2(4 char)                    null,
    brsch                                        varchar2(4 char)                    null,
    erdat                                        varchar2(8 char)                    null,
    ernam                                        varchar2(12 char)                   null,
    konzs                                        varchar2(10 char)                   null,
    ktokk                                        varchar2(4 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    lnrza                                        varchar2(10 char)                   null,
    loevm                                        varchar2(1 char)                    null,
    name1                                        varchar2(35 char)                   null,
    name2                                        varchar2(35 char)                   null,
    name3                                        varchar2(35 char)                   null,
    name4                                        varchar2(35 char)                   null,
    sortl                                        varchar2(10 char)                   null,
    sperr                                        varchar2(1 char)                    null,
    sperm                                        varchar2(1 char)                    null,
    spras                                        varchar2(1 char)                    null,
    stcd1                                        varchar2(16 char)                   null,
    stcd2                                        varchar2(11 char)                   null,
    stkza                                        varchar2(1 char)                    null,
    stkzu                                        varchar2(1 char)                    null,
    xcpdk                                        varchar2(1 char)                    null,
    xzemp                                        varchar2(1 char)                    null,
    vbund                                        varchar2(6 char)                    null,
    fiskn                                        varchar2(10 char)                   null,
    stceg                                        varchar2(20 char)                   null,
    stkzn                                        varchar2(1 char)                    null,
    sperq                                        varchar2(2 char)                    null,
    adrnr                                        varchar2(10 char)                   null,
    gbort                                        varchar2(25 char)                   null,
    gbdat                                        varchar2(8 char)                    null,
    sexkz                                        varchar2(1 char)                    null,
    kraus                                        varchar2(11 char)                   null,
    revdb                                        varchar2(8 char)                    null,
    qssys                                        varchar2(4 char)                    null,
    ktock                                        varchar2(4 char)                    null,
    werks                                        varchar2(4 char)                    null,
    ltsna                                        varchar2(1 char)                    null,
    werkr                                        varchar2(1 char)                    null,
    plkal                                        varchar2(2 char)                    null,
    duefl                                        varchar2(1 char)                    null,
    txjcd                                        varchar2(15 char)                   null,
    scacd                                        varchar2(4 char)                    null,
    sfrgr                                        varchar2(4 char)                    null,
    lzone                                        varchar2(10 char)                   null,
    dlgrp                                        varchar2(4 char)                    null,
    fityp                                        varchar2(2 char)                    null,
    stcdt                                        varchar2(2 char)                    null,
    regss                                        varchar2(1 char)                    null,
    actss                                        varchar2(3 char)                    null,
    stcd3                                        varchar2(18 char)                   null,
    stcd4                                        varchar2(18 char)                   null,
    ipisp                                        varchar2(1 char)                    null,
    profs                                        varchar2(30 char)                   null,
    stgdl                                        varchar2(2 char)                    null,
    emnfr                                        varchar2(10 char)                   null,
    nodel                                        varchar2(1 char)                    null,
    lfurl                                        varchar2(132 char)                  null,
    j_1kfrepre                                   varchar2(10 char)                   null,
    j_1kftbus                                    varchar2(30 char)                   null,
    j_1kftind                                    varchar2(30 char)                   null,
    qssysdat                                     varchar2(8 char)                    null,
    podkzb                                       varchar2(1 char)                    null,
    fisku                                        varchar2(10 char)                   null,
    stenr                                        varchar2(18 char)                   null,
    psois                                        varchar2(20 char)                   null,
    pson1                                        varchar2(35 char)                   null,
    pson2                                        varchar2(35 char)                   null,
    pson3                                        varchar2(35 char)                   null,
    psovn                                        varchar2(35 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null,
    lads_flattened                               varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_ven_hdr is 'LADS Vendor Header';
comment on column lads_ven_hdr.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_hdr.begru is 'Authorization Group';
comment on column lads_ven_hdr.brsch is 'Industry key';
comment on column lads_ven_hdr.erdat is 'Date on which the Record Was Created';
comment on column lads_ven_hdr.ernam is 'Name of Person who Created the Object';
comment on column lads_ven_hdr.konzs is 'Group key';
comment on column lads_ven_hdr.ktokk is 'Vendor account group';
comment on column lads_ven_hdr.kunnr is 'Customer Number 1';
comment on column lads_ven_hdr.lnrza is 'Account Number of Vendor or Creditor';
comment on column lads_ven_hdr.loevm is 'Central Deletion Flag for Master Record';
comment on column lads_ven_hdr.name1 is 'Employees last name';
comment on column lads_ven_hdr.name2 is 'Employees last name';
comment on column lads_ven_hdr.name3 is 'Employees last name';
comment on column lads_ven_hdr.name4 is 'Employees last name';
comment on column lads_ven_hdr.sortl is 'Character Field Length = 10';
comment on column lads_ven_hdr.sperr is 'Central posting block';
comment on column lads_ven_hdr.sperm is 'Centrally imposed purchasing block';
comment on column lads_ven_hdr.spras is 'Language Key';
comment on column lads_ven_hdr.stcd1 is 'Tax Number 1';
comment on column lads_ven_hdr.stcd2 is 'Tax Number 2';
comment on column lads_ven_hdr.stkza is 'Indicator: Business Partner Subject to Equalization Tax?';
comment on column lads_ven_hdr.stkzu is 'Liable for VAT';
comment on column lads_ven_hdr.xcpdk is 'Indicator: Is the account a one-time account?';
comment on column lads_ven_hdr.xzemp is 'Indicator: Alternative payee in document allowed ?';
comment on column lads_ven_hdr.vbund is 'Company ID of Trading Partner';
comment on column lads_ven_hdr.fiskn is 'Account number of the master record with fiscal address';
comment on column lads_ven_hdr.stceg is 'VAT registration number';
comment on column lads_ven_hdr.stkzn is 'Natural Person';
comment on column lads_ven_hdr.sperq is 'Function That Will Be Blocked';
comment on column lads_ven_hdr.adrnr is 'Address';
comment on column lads_ven_hdr.gbort is 'Place of birth of the person subject to withholding tax';
comment on column lads_ven_hdr.gbdat is 'Date of Birth';
comment on column lads_ven_hdr.sexkz is 'Key for the Sex of the Person Subject to Withholding Tax';
comment on column lads_ven_hdr.kraus is 'Credit information number';
comment on column lads_ven_hdr.revdb is 'Last review (external)';
comment on column lads_ven_hdr.qssys is 'Vendors QM system';
comment on column lads_ven_hdr.ktock is 'Reference Account Group for One-Time Account (Vendor)';
comment on column lads_ven_hdr.werks is 'Plant';
comment on column lads_ven_hdr.ltsna is 'Indicator: vendor sub-range relevant';
comment on column lads_ven_hdr.werkr is 'Indicator: plant level relevant';
comment on column lads_ven_hdr.plkal is 'Factory calendar key';
comment on column lads_ven_hdr.duefl is 'Status of Data Transfer into Subsequent Release';
comment on column lads_ven_hdr.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_ven_hdr.scacd is 'Standard carrier access code';
comment on column lads_ven_hdr.sfrgr is 'Forwarding agent freight group';
comment on column lads_ven_hdr.lzone is 'Transportation zone to or from which the goods are delivered';
comment on column lads_ven_hdr.dlgrp is 'Service agent procedure group';
comment on column lads_ven_hdr.fityp is 'Tax type';
comment on column lads_ven_hdr.stcdt is 'Tax Number Type';
comment on column lads_ven_hdr.regss is 'Registered for Social Insurance';
comment on column lads_ven_hdr.actss is 'Activity Code for Social Insurance';
comment on column lads_ven_hdr.stcd3 is 'Tax Number 3';
comment on column lads_ven_hdr.stcd4 is 'Tax Number 4';
comment on column lads_ven_hdr.ipisp is 'Tax Split';
comment on column lads_ven_hdr.profs is 'Profession';
comment on column lads_ven_hdr.stgdl is '"Shipment: statistics group, transportation service agent"';
comment on column lads_ven_hdr.emnfr is 'External manufacturer code name or number';
comment on column lads_ven_hdr.nodel is 'Central deletion block for master record';
comment on column lads_ven_hdr.lfurl is 'Uniform resource locator';
comment on column lads_ven_hdr.j_1kfrepre is 'Name of Representative';
comment on column lads_ven_hdr.j_1kftbus is 'Type of Business';
comment on column lads_ven_hdr.j_1kftind is 'Type of Industry';
comment on column lads_ven_hdr.qssysdat is 'Validity date of certification';
comment on column lads_ven_hdr.podkzb is 'Vendor indicator relevant for proof of delivery';
comment on column lads_ven_hdr.fisku is 'Account Number of Master Record of Tax Office Responsible';
comment on column lads_ven_hdr.stenr is 'Tax Number at Responsible Tax Authority';
comment on column lads_ven_hdr.psois is 'Subledger acct preprocessing procedure';
comment on column lads_ven_hdr.pson1 is 'Name 1';
comment on column lads_ven_hdr.pson2 is 'Name 1';
comment on column lads_ven_hdr.pson3 is 'Name 1';
comment on column lads_ven_hdr.psovn is 'First name';
comment on column lads_ven_hdr.idoc_name is 'IDOC name';
comment on column lads_ven_hdr.idoc_number is 'IDOC number';
comment on column lads_ven_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_ven_hdr.lads_date is 'LADS date loaded';
comment on column lads_ven_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';
comment on column lads_ven_hdr.lads_flattened is 'LADS Flattened Status - 0 Unflattened, 1 Flattened to BDS, 2 Excluded/Skipped';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_hdr
   add constraint lads_ven_hdr_pk primary key (lifnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_hdr to lads_app;
grant select, insert, update, delete on lads_ven_hdr to ics_app;
grant select, update on lads_ven_hdr to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_hdr for lads.lads_ven_hdr;
