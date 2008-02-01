/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_hdr
   (matnr                                        varchar2(18 char)                   not null,
    ersda                                        varchar2(8 char)                    null,
    ernam                                        varchar2(12 char)                   null,
    laeda                                        varchar2(8 char)                    null,
    aenam                                        varchar2(12 char)                   null,
    pstat                                        varchar2(15 char)                   null,
    lvorm                                        varchar2(1 char)                    null,
    mtart                                        varchar2(4 char)                    null,
    mbrsh                                        varchar2(1 char)                    null,
    matkl                                        varchar2(9 char)                    null,
    bismt                                        varchar2(18 char)                   null,
    meins                                        varchar2(3 char)                    null,
    bstme                                        varchar2(3 char)                    null,
    zeinr                                        varchar2(22 char)                   null,
    zeiar                                        varchar2(3 char)                    null,
    zeivr                                        varchar2(2 char)                    null,
    zeifo                                        varchar2(4 char)                    null,
    aeszn                                        varchar2(6 char)                    null,
    blatt                                        varchar2(3 char)                    null,
    blanz                                        number                              null,
    ferth                                        varchar2(18 char)                   null,
    formt                                        varchar2(4 char)                    null,
    groes                                        varchar2(32 char)                   null,
    wrkst                                        varchar2(14 char)                   null,
    normt                                        varchar2(18 char)                   null,
    labor                                        varchar2(3 char)                    null,
    ekwsl                                        varchar2(4 char)                    null,
    brgew                                        number                              null,
    ntgew                                        number                              null,
    gewei                                        varchar2(3 char)                    null,
    volum                                        number                              null,
    voleh                                        varchar2(3 char)                    null,
    behvo                                        varchar2(2 char)                    null,
    raube                                        varchar2(2 char)                    null,
    tempb                                        varchar2(2 char)                    null,
    tragr                                        varchar2(4 char)                    null,
    stoff                                        varchar2(18 char)                   null,
    spart                                        varchar2(2 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    wesch                                        number                              null,
    bwvor                                        varchar2(1 char)                    null,
    bwscl                                        varchar2(1 char)                    null,
    saiso                                        varchar2(4 char)                    null,
    etiar                                        varchar2(2 char)                    null,
    etifo                                        varchar2(2 char)                    null,
    ean11                                        varchar2(18 char)                   null,
    numtp                                        varchar2(2 char)                    null,
    laeng                                        number                              null,
    breit                                        number                              null,
    hoehe                                        number                              null,
    meabm                                        varchar2(3 char)                    null,
    prdha                                        varchar2(18 char)                   null,
    cadkz                                        varchar2(1 char)                    null,
    ergew                                        number                              null,
    ergei                                        varchar2(3 char)                    null,
    ervol                                        number                              null,
    ervoe                                        varchar2(3 char)                    null,
    gewto                                        number                              null,
    volto                                        number                              null,
    vabme                                        varchar2(1 char)                    null,
    kzkfg                                        varchar2(1 char)                    null,
    xchpf                                        varchar2(1 char)                    null,
    vhart                                        varchar2(4 char)                    null,
    fuelg                                        number                              null,
    stfak                                        number                              null,
    magrv                                        varchar2(4 char)                    null,
    begru                                        varchar2(4 char)                    null,
    qmpur                                        varchar2(1 char)                    null,
    rbnrm                                        varchar2(9 char)                    null,
    mhdrz                                        number                              null,
    mhdhb                                        number                              null,
    mhdlp                                        number                              null,
    vpsta                                        varchar2(15 char)                   null,
    extwg                                        varchar2(18 char)                   null,
    mstae                                        varchar2(2 char)                    null,
    mstav                                        varchar2(2 char)                    null,
    mstde                                        varchar2(8 char)                    null,
    mstdv                                        varchar2(8 char)                    null,
    kzumw                                        varchar2(1 char)                    null,
    kosch                                        varchar2(18 char)                   null,
    nrfhg                                        varchar2(1 char)                    null,
    mfrpn                                        varchar2(40 char)                   null,
    mfrnr                                        varchar2(10 char)                   null,
    bmatn                                        varchar2(18 char)                   null,
    mprof                                        varchar2(4 char)                    null,
    profl                                        varchar2(3 char)                    null,
    ihivi                                        varchar2(1 char)                    null,
    iloos                                        varchar2(1 char)                    null,
    kzgvh                                        varchar2(1 char)                    null,
    xgchp                                        varchar2(1 char)                    null,
    compl                                        number                              null,
    kzeff                                        varchar2(1 char)                    null,
    rdmhd                                        varchar2(1 char)                    null,
    iprkz                                        varchar2(1 char)                    null,
    przus                                        varchar2(1 char)                    null,
    mtpos_mara                                   varchar2(4 char)                    null,
    gewto_new                                    number                              null,
    volto_new                                    number                              null,
    wrkst_new                                    varchar2(48 char)                   null,
    aennr                                        varchar2(12 char)                   null,
    matfi                                        varchar2(1 char)                    null,
    cmrel                                        varchar2(1 char)                    null,
    satnr                                        varchar2(18 char)                   null,
    sled_bbd                                     varchar2(1 char)                    null,
    gtin_variant                                 varchar2(2 char)                    null,
    gennr                                        varchar2(18 char)                   null,
    serlv                                        varchar2(1 char)                    null,
    rmatp                                        varchar2(18 char)                   null,
    zzdecvolum                                   number                              null,
    zzdecvoleh                                   varchar2(3 char)                    null,
    zzdeccount                                   number                              null,
    zzdeccounit                                  varchar2(3 char)                    null,
    zzpproweight                                 number                              null,
    zzpprowunit                                  varchar2(3 char)                    null,
    zzpprovolum                                  number                              null,
    zzpprovunit                                  varchar2(3 char)                    null,
    zzpprocount                                  number                              null,
    zzpprocunit                                  varchar2(3 char)                    null,
    zzalpha01                                    varchar2(8 char)                    null,
    zzalpha02                                    varchar2(8 char)                    null,
    zzalpha03                                    varchar2(8 char)                    null,
    zzalpha04                                    varchar2(8 char)                    null,
    zzalpha05                                    varchar2(8 char)                    null,
    zzalpha06                                    varchar2(8 char)                    null,
    zzalpha07                                    varchar2(8 char)                    null,
    zzalpha08                                    varchar2(8 char)                    null,
    zzalpha09                                    varchar2(8 char)                    null,
    zzalpha10                                    varchar2(8 char)                    null,
    zznum01                                      number                              null,
    zznum02                                      number                              null,
    zznum03                                      number                              null,
    zznum04                                      number                              null,
    zznum05                                      number                              null,
    zznum06                                      number                              null,
    zznum07                                      number                              null,
    zznum08                                      number                              null,
    zznum09                                      number                              null,
    zznum10                                      number                              null,
    zzcheck01                                    varchar2(1 char)                    null,
    zzcheck02                                    varchar2(1 char)                    null,
    zzcheck03                                    varchar2(1 char)                    null,
    zzcheck04                                    varchar2(1 char)                    null,
    zzcheck05                                    varchar2(1 char)                    null,
    zzcheck06                                    varchar2(1 char)                    null,
    zzcheck07                                    varchar2(1 char)                    null,
    zzcheck08                                    varchar2(1 char)                    null,
    zzcheck09                                    varchar2(1 char)                    null,
    zzcheck10                                    varchar2(1 char)                    null,
    zzplan_item                                  varchar2(6 char)                    null,
    zzisint                                      varchar2(1 char)                    null,
    zzismcu                                      varchar2(1 char)                    null,
    zzispro                                      varchar2(1 char)                    null,
    zzisrsu                                      varchar2(1 char)                    null,
    zzissc                                       varchar2(1 char)                    null,
    zzissfp                                      varchar2(1 char)                    null,
    zzistdu                                      varchar2(1 char)                    null,
    zzistra                                      varchar2(1 char)                    null,
    zzstatuscode                                 varchar2(3 char)                    null,
    zzitemowner                                  varchar2(12 char)                   null,
    zzchangedby                                  varchar2(12 char)                   null,
    zzmattim                                     number                              null,
    zzrepmatnr                                   varchar2(18 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_mat_hdr is 'LADS Material Header';
comment on column lads_mat_hdr.matnr is 'Material Number';
comment on column lads_mat_hdr.ersda is 'Creation date';
comment on column lads_mat_hdr.ernam is 'Name of Person who Created the Object';
comment on column lads_mat_hdr.laeda is 'Date of Last Change';
comment on column lads_mat_hdr.aenam is 'Name of person who changed object';
comment on column lads_mat_hdr.pstat is 'Maintenance status';
comment on column lads_mat_hdr.lvorm is 'Flag Material for Deletion at Client Level';
comment on column lads_mat_hdr.mtart is 'Material Type';
comment on column lads_mat_hdr.mbrsh is 'Industry Sector';
comment on column lads_mat_hdr.matkl is 'Material Group';
comment on column lads_mat_hdr.bismt is 'Old material number';
comment on column lads_mat_hdr.meins is 'Base Unit of Measure';
comment on column lads_mat_hdr.bstme is 'Order unit';
comment on column lads_mat_hdr.zeinr is 'Document number (without document management system)';
comment on column lads_mat_hdr.zeiar is 'Document type (without Document Management system)';
comment on column lads_mat_hdr.zeivr is 'Document version (without Document Management system)';
comment on column lads_mat_hdr.zeifo is 'Page format of document (without Document Management system)';
comment on column lads_mat_hdr.aeszn is 'Document change number (without document management system)';
comment on column lads_mat_hdr.blatt is 'Page number of document (without Document Management system)';
comment on column lads_mat_hdr.blanz is 'Number of sheets (without Document Management system)';
comment on column lads_mat_hdr.ferth is 'Production/Inspection Memo';
comment on column lads_mat_hdr.formt is 'Page Format of Production Memo';
comment on column lads_mat_hdr.groes is 'Size/dimensions';
comment on column lads_mat_hdr.wrkst is 'Basic material (basic constituent of a material) - obsolete';
comment on column lads_mat_hdr.normt is 'Industry Standard Description (such as ANSI or ISO)';
comment on column lads_mat_hdr.labor is 'Laboratory/design office';
comment on column lads_mat_hdr.ekwsl is 'Purchasing Value Key';
comment on column lads_mat_hdr.brgew is 'Gross weight';
comment on column lads_mat_hdr.ntgew is 'Net weight';
comment on column lads_mat_hdr.gewei is 'Weight Unit';
comment on column lads_mat_hdr.volum is 'Volume';
comment on column lads_mat_hdr.voleh is 'Volume unit';
comment on column lads_mat_hdr.behvo is 'Container requirements';
comment on column lads_mat_hdr.raube is 'Storage conditions';
comment on column lads_mat_hdr.tempb is 'Temperature conditions indicator';
comment on column lads_mat_hdr.tragr is 'Transportation group';
comment on column lads_mat_hdr.stoff is 'Hazardous material number';
comment on column lads_mat_hdr.spart is 'Division';
comment on column lads_mat_hdr.kunnr is 'Competitor';
comment on column lads_mat_hdr.wesch is 'Quantity: Number of GR/GI slips to be printed';
comment on column lads_mat_hdr.bwvor is 'Procurement rule';
comment on column lads_mat_hdr.bwscl is 'Source of Supply';
comment on column lads_mat_hdr.saiso is 'Season category';
comment on column lads_mat_hdr.etiar is 'Label type';
comment on column lads_mat_hdr.etifo is 'Label form';
comment on column lads_mat_hdr.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_mat_hdr.numtp is 'Category of International Article Number (EAN)';
comment on column lads_mat_hdr.laeng is 'Length';
comment on column lads_mat_hdr.breit is 'Width';
comment on column lads_mat_hdr.hoehe is 'Height';
comment on column lads_mat_hdr.meabm is 'Unit of dimension for length/width/height';
comment on column lads_mat_hdr.prdha is 'Product hierarchy';
comment on column lads_mat_hdr.cadkz is 'CAD indicator';
comment on column lads_mat_hdr.ergew is 'Allowed packaging weight';
comment on column lads_mat_hdr.ergei is 'Weight Unit';
comment on column lads_mat_hdr.ervol is 'Allowed packaging volume';
comment on column lads_mat_hdr.ervoe is 'Volume unit';
comment on column lads_mat_hdr.gewto is 'Excess Weight Tolerance for Handling unit';
comment on column lads_mat_hdr.volto is 'Excess Volume Tolerance of the Handling Unit';
comment on column lads_mat_hdr.vabme is 'Variable order unit active';
comment on column lads_mat_hdr.kzkfg is 'Configurable Material';
comment on column lads_mat_hdr.xchpf is 'Batch management requirement indicator';
comment on column lads_mat_hdr.vhart is 'Packaging Material Type';
comment on column lads_mat_hdr.fuelg is 'Maximum level (by volume)';
comment on column lads_mat_hdr.stfak is 'Stacking factor';
comment on column lads_mat_hdr.magrv is 'Material Group: Packaging Materials';
comment on column lads_mat_hdr.begru is 'Authorization Group';
comment on column lads_mat_hdr.qmpur is 'QM in Procurement is Active';
comment on column lads_mat_hdr.rbnrm is 'Catalog Profile';
comment on column lads_mat_hdr.mhdrz is 'Minimum remaining shelf life';
comment on column lads_mat_hdr.mhdhb is 'Total shelf life';
comment on column lads_mat_hdr.mhdlp is 'Storage percentage';
comment on column lads_mat_hdr.vpsta is 'Maintenance status of complete material';
comment on column lads_mat_hdr.extwg is 'External material group';
comment on column lads_mat_hdr.mstae is 'Cross-Plant Material Status';
comment on column lads_mat_hdr.mstav is 'Cross-distribution-chain material status';
comment on column lads_mat_hdr.mstde is 'Date from which the cross-plant material status is valid';
comment on column lads_mat_hdr.mstdv is 'Date from which the X-distr.-chain material status is valid';
comment on column lads_mat_hdr.kzumw is 'Indicator: Environmentally Relevant';
comment on column lads_mat_hdr.kosch is 'Product allocation determination procedure';
comment on column lads_mat_hdr.nrfhg is 'Material qualifies for discount in kind';
comment on column lads_mat_hdr.mfrpn is 'Manufacturer part number';
comment on column lads_mat_hdr.mfrnr is 'Manufacturer number';
comment on column lads_mat_hdr.bmatn is 'To material number';
comment on column lads_mat_hdr.mprof is 'Mfr part profile';
comment on column lads_mat_hdr.profl is 'Dangerous Goods Indicator Profile';
comment on column lads_mat_hdr.ihivi is 'Indicator: Highly Viscous';
comment on column lads_mat_hdr.iloos is 'Indicator: In Bulk/Liquid';
comment on column lads_mat_hdr.kzgvh is 'Packaging Material is Closed Packaging';
comment on column lads_mat_hdr.xgchp is 'Indicator: Approved batch record required';
comment on column lads_mat_hdr.compl is 'Material completion level';
comment on column lads_mat_hdr.kzeff is 'Assign effectivity parameter values/ override change numbers';
comment on column lads_mat_hdr.rdmhd is 'Rounding rule for calculation of SLED';
comment on column lads_mat_hdr.iprkz is 'Period indicator for shelf life expiration date';
comment on column lads_mat_hdr.przus is 'Indicator: Product composition printed on packaging';
comment on column lads_mat_hdr.mtpos_mara is 'General item category group';
comment on column lads_mat_hdr.gewto_new is 'Excess Weight Tolerance for Handling unit';
comment on column lads_mat_hdr.volto_new is 'Excess Volume Tolerance of the Handling Unit';
comment on column lads_mat_hdr.wrkst_new is 'Basic Material';
comment on column lads_mat_hdr.aennr is 'Change Number';
comment on column lads_mat_hdr.matfi is 'Material Is Locked';
comment on column lads_mat_hdr.cmrel is 'Relevant for Configuration Management';
comment on column lads_mat_hdr.satnr is 'Cross-Plant Configurable Material';
comment on column lads_mat_hdr.sled_bbd is 'sled_bbd';
comment on column lads_mat_hdr.gtin_variant is 'Global Trade Item Number Variant';
comment on column lads_mat_hdr.gennr is 'Material Number of the Generic Material in Prepack Materials';
comment on column lads_mat_hdr.serlv is 'Level of Explicitness for Serial Number';
comment on column lads_mat_hdr.rmatp is 'Reference material for materials packed in same way';
comment on column lads_mat_hdr.zzdecvolum is 'Declared Volume';
comment on column lads_mat_hdr.zzdecvoleh is 'Declared Volume Unit';
comment on column lads_mat_hdr.zzdeccount is 'Declared Count';
comment on column lads_mat_hdr.zzdeccounit is 'Declared Count Unit';
comment on column lads_mat_hdr.zzpproweight is 'Pre-Promoted weight';
comment on column lads_mat_hdr.zzpprowunit is 'Pre Promoted weight Unit';
comment on column lads_mat_hdr.zzpprovolum is 'Pre-Promoted Volume';
comment on column lads_mat_hdr.zzpprovunit is 'Pre promoted volume unit';
comment on column lads_mat_hdr.zzpprocount is 'Pre-Promoted Count';
comment on column lads_mat_hdr.zzpprocunit is 'Pre Promoted count unit';
comment on column lads_mat_hdr.zzalpha01 is 'unused';
comment on column lads_mat_hdr.zzalpha02 is 'unused';
comment on column lads_mat_hdr.zzalpha03 is 'Unused';
comment on column lads_mat_hdr.zzalpha04 is 'Unused';
comment on column lads_mat_hdr.zzalpha05 is 'Unused';
comment on column lads_mat_hdr.zzalpha06 is 'Unused';
comment on column lads_mat_hdr.zzalpha07 is 'Unused';
comment on column lads_mat_hdr.zzalpha08 is 'Unused';
comment on column lads_mat_hdr.zzalpha09 is 'Unused';
comment on column lads_mat_hdr.zzalpha10 is 'Unused';
comment on column lads_mat_hdr.zznum01 is 'Unused';
comment on column lads_mat_hdr.zznum02 is 'Unused';
comment on column lads_mat_hdr.zznum03 is 'Unused';
comment on column lads_mat_hdr.zznum04 is 'Unused';
comment on column lads_mat_hdr.zznum05 is 'Unused';
comment on column lads_mat_hdr.zznum06 is 'Unused';
comment on column lads_mat_hdr.zznum07 is 'Unused';
comment on column lads_mat_hdr.zznum08 is 'Unused';
comment on column lads_mat_hdr.zznum09 is 'Unused';
comment on column lads_mat_hdr.zznum10 is 'Unused';
comment on column lads_mat_hdr.zzcheck01 is 'Unused';
comment on column lads_mat_hdr.zzcheck02 is 'Unused';
comment on column lads_mat_hdr.zzcheck03 is 'Unused';
comment on column lads_mat_hdr.zzcheck04 is 'Unused';
comment on column lads_mat_hdr.zzcheck05 is 'Unused';
comment on column lads_mat_hdr.zzcheck06 is 'Unused';
comment on column lads_mat_hdr.zzcheck07 is 'Unused';
comment on column lads_mat_hdr.zzcheck08 is 'Unused';
comment on column lads_mat_hdr.zzcheck09 is 'Unused';
comment on column lads_mat_hdr.zzcheck10 is 'Unused';
comment on column lads_mat_hdr.zzplan_item is 'ATLAS MD plan item';
comment on column lads_mat_hdr.zzisint is 'INT (Intermediate Product Component)';
comment on column lads_mat_hdr.zzismcu is 'MCU (Merchandising Unit)';
comment on column lads_mat_hdr.zzispro is 'PRO (Promotional Material)';
comment on column lads_mat_hdr.zzisrsu is 'RSU (Retail Sales Unit)';
comment on column lads_mat_hdr.zzissc is 'SC  (Shipping Container)';
comment on column lads_mat_hdr.zzissfp is 'SFP (Semi-Finished Product)';
comment on column lads_mat_hdr.zzistdu is 'TDU (Traded Unit)';
comment on column lads_mat_hdr.zzistra is 'REP (Representative Item)';
comment on column lads_mat_hdr.zzstatuscode is 'ATLAS MD mars Item Status Code';
comment on column lads_mat_hdr.zzitemowner is 'ATLAS MD mars Item Owner';
comment on column lads_mat_hdr.zzchangedby is 'ATLAS MD mars Last changed by';
comment on column lads_mat_hdr.zzmattim is 'Maturation lead time in days';
comment on column lads_mat_hdr.zzrepmatnr is 'Representative item code';
comment on column lads_mat_hdr.idoc_name is 'IDOC name';
comment on column lads_mat_hdr.idoc_number is 'IDOC number';
comment on column lads_mat_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_mat_hdr.lads_date is 'LADS date loaded';
comment on column lads_mat_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_hdr
   add constraint lads_mat_hdr_pk primary key (matnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_hdr to lads_app;
grant select, insert, update, delete on lads_mat_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_hdr for lads.lads_mat_hdr;
