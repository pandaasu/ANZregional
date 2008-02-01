/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_mrc
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_mrc

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_mrc
   (matnr                                        varchar2(18 char)                   not null,
    mrcseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    werks                                        varchar2(4 char)                    null,
    pstat                                        varchar2(15 char)                   null,
    lvorm                                        varchar2(1 char)                    null,
    bwtty                                        varchar2(1 char)                    null,
    maabc                                        varchar2(1 char)                    null,
    kzkri                                        varchar2(1 char)                    null,
    ekgrp                                        varchar2(3 char)                    null,
    ausme                                        varchar2(3 char)                    null,
    dispr                                        varchar2(4 char)                    null,
    dismm                                        varchar2(2 char)                    null,
    dispo                                        varchar2(3 char)                    null,
    plifz                                        number                              null,
    webaz                                        number                              null,
    perkz                                        varchar2(1 char)                    null,
    ausss                                        number                              null,
    disls                                        varchar2(2 char)                    null,
    beskz                                        varchar2(1 char)                    null,
    sobsl                                        varchar2(2 char)                    null,
    minbe                                        number                              null,
    eisbe                                        number                              null,
    bstmi                                        number                              null,
    bstma                                        number                              null,
    bstfe                                        number                              null,
    bstrf                                        number                              null,
    mabst                                        number                              null,
    losfx                                        number                              null,
    sbdkz                                        varchar2(1 char)                    null,
    lagpr                                        varchar2(1 char)                    null,
    altsl                                        varchar2(1 char)                    null,
    kzaus                                        varchar2(1 char)                    null,
    ausdt                                        varchar2(8 char)                    null,
    nfmat                                        varchar2(18 char)                   null,
    kzbed                                        varchar2(1 char)                    null,
    miskz                                        varchar2(1 char)                    null,
    fhori                                        varchar2(3 char)                    null,
    pfrei                                        varchar2(1 char)                    null,
    ffrei                                        varchar2(1 char)                    null,
    rgekz                                        varchar2(1 char)                    null,
    fevor                                        varchar2(3 char)                    null,
    bearz                                        number                              null,
    ruezt                                        number                              null,
    tranz                                        number                              null,
    basmg                                        number                              null,
    dzeit                                        number                              null,
    maxlz                                        number                              null,
    lzeih                                        varchar2(3 char)                    null,
    kzpro                                        varchar2(1 char)                    null,
    gpmkz                                        varchar2(1 char)                    null,
    ueeto                                        number                              null,
    ueetk                                        varchar2(1 char)                    null,
    uneto                                        number                              null,
    wzeit                                        number                              null,
    atpkz                                        varchar2(1 char)                    null,
    vzusl                                        number                              null,
    herbl                                        varchar2(2 char)                    null,
    insmk                                        varchar2(1 char)                    null,
    ssqss                                        varchar2(8 char)                    null,
    kzdkz                                        varchar2(1 char)                    null,
    umlmc                                        number                              null,
    ladgr                                        varchar2(4 char)                    null,
    xchpf                                        varchar2(1 char)                    null,
    usequ                                        varchar2(1 char)                    null,
    lgrad                                        number                              null,
    auftl                                        varchar2(1 char)                    null,
    plvar                                        varchar2(2 char)                    null,
    otype                                        varchar2(2 char)                    null,
    objid                                        number                              null,
    mtvfp                                        varchar2(2 char)                    null,
    periv                                        varchar2(2 char)                    null,
    kzkfk                                        varchar2(1 char)                    null,
    vrvez                                        number                              null,
    vbamg                                        number                              null,
    vbeaz                                        number                              null,
    lizyk                                        varchar2(4 char)                    null,
    bwscl                                        varchar2(1 char)                    null,
    kautb                                        varchar2(1 char)                    null,
    kordb                                        varchar2(1 char)                    null,
    stawn                                        varchar2(17 char)                   null,
    herkl                                        varchar2(3 char)                    null,
    herkr                                        varchar2(3 char)                    null,
    expme                                        varchar2(3 char)                    null,
    mtver                                        varchar2(4 char)                    null,
    prctr                                        varchar2(10 char)                   null,
    trame                                        number                              null,
    mrppp                                        varchar2(3 char)                    null,
    sauft                                        varchar2(1 char)                    null,
    fxhor                                        number                              null,
    vrmod                                        varchar2(1 char)                    null,
    vint1                                        number                              null,
    vint2                                        number                              null,
    stlal                                        varchar2(2 char)                    null,
    stlan                                        varchar2(1 char)                    null,
    plnnr                                        varchar2(8 char)                    null,
    aplal                                        varchar2(2 char)                    null,
    losgr                                        number                              null,
    sobsk                                        varchar2(2 char)                    null,
    frtme                                        varchar2(3 char)                    null,
    lgpro                                        varchar2(4 char)                    null,
    disgr                                        varchar2(4 char)                    null,
    kausf                                        number                              null,
    qzgtp                                        varchar2(4 char)                    null,
    takzt                                        number                              null,
    rwpro                                        varchar2(3 char)                    null,
    copam                                        varchar2(10 char)                   null,
    abcin                                        varchar2(1 char)                    null,
    awsls                                        varchar2(6 char)                    null,
    sernp                                        varchar2(4 char)                    null,
    stdpd                                        varchar2(18 char)                   null,
    sfepr                                        varchar2(4 char)                    null,
    xmcng                                        varchar2(1 char)                    null,
    qssys                                        varchar2(4 char)                    null,
    lfrhy                                        varchar2(3 char)                    null,
    rdprf                                        varchar2(4 char)                    null,
    vrbmt                                        varchar2(18 char)                   null,
    vrbwk                                        varchar2(4 char)                    null,
    vrbdt                                        varchar2(8 char)                    null,
    vrbfk                                        number                              null,
    autru                                        varchar2(1 char)                    null,
    prefe                                        varchar2(1 char)                    null,
    prenc                                        varchar2(1 char)                    null,
    preno                                        number                              null,
    prend                                        varchar2(8 char)                    null,
    prene                                        varchar2(1 char)                    null,
    preng                                        varchar2(8 char)                    null,
    itark                                        varchar2(1 char)                    null,
    prfrq                                        varchar2(7 char)                    null,
    kzkup                                        varchar2(1 char)                    null,
    strgr                                        varchar2(2 char)                    null,
    lgfsb                                        varchar2(4 char)                    null,
    schgt                                        varchar2(1 char)                    null,
    ccfix                                        varchar2(1 char)                    null,
    eprio                                        varchar2(4 char)                    null,
    qmata                                        varchar2(6 char)                    null,
    plnty                                        varchar2(1 char)                    null,
    mmsta                                        varchar2(2 char)                    null,
    sfcpf                                        varchar2(6 char)                    null,
    shflg                                        varchar2(1 char)                    null,
    shzet                                        number                              null,
    mdach                                        varchar2(2 char)                    null,
    kzech                                        varchar2(1 char)                    null,
    mmstd                                        varchar2(8 char)                    null,
    mfrgr                                        varchar2(8 char)                    null,
    fvidk                                        varchar2(4 char)                    null,
    indus                                        varchar2(2 char)                    null,
    mownr                                        varchar2(12 char)                   null,
    mogru                                        varchar2(6 char)                    null,
    casnr                                        varchar2(15 char)                   null,
    gpnum                                        varchar2(9 char)                    null,
    steuc                                        varchar2(16 char)                   null,
    fabkz                                        varchar2(1 char)                    null,
    matgr                                        varchar2(20 char)                   null,
    loggr                                        varchar2(4 char)                    null,
    vspvb                                        varchar2(10 char)                   null,
    dplfs                                        varchar2(2 char)                    null,
    dplpu                                        varchar2(1 char)                    null,
    dplho                                        number                              null,
    minls                                        number                              null,
    maxls                                        number                              null,
    fixls                                        number                              null,
    ltinc                                        number                              null,
    compl                                        number                              null,
    convt                                        varchar2(2 char)                    null,
    fprfm                                        varchar2(3 char)                    null,
    shpro                                        varchar2(3 char)                    null,
    fxpru                                        varchar2(1 char)                    null,
    kzpsp                                        varchar2(1 char)                    null,
    ocmpf                                        varchar2(6 char)                    null,
    apokz                                        varchar2(1 char)                    null,
    ahdis                                        varchar2(1 char)                    null,
    eislo                                        number                              null,
    ncost                                        varchar2(1 char)                    null,
    megru                                        varchar2(4 char)                    null,
    rotation_date                                varchar2(1 char)                    null,
    uchkz                                        varchar2(1 char)                    null,
    ucmat                                        varchar2(18 char)                   null,
    msgfn1                                       varchar2(3 char)                    null,
    objty                                        varchar2(2 char)                    null,
    objid1                                       number                              null,
    zaehl                                        number                              null,
    objty_v                                      varchar2(2 char)                    null,
    objid_v                                      number                              null,
    kzkbl                                        varchar2(1 char)                    null,
    steuf                                        varchar2(4 char)                    null,
    steuf_ref                                    varchar2(1 char)                    null,
    fgru1                                        varchar2(4 char)                    null,
    fgru2                                        varchar2(4 char)                    null,
    planv                                        varchar2(3 char)                    null,
    ktsch                                        varchar2(7 char)                    null,
    ktsch_ref                                    varchar2(1 char)                    null,
    bzoffb                                       varchar2(2 char)                    null,
    bzoffb_ref                                   varchar2(1 char)                    null,
    offstb                                       number                              null,
    ehoffb                                       varchar2(3 char)                    null,
    offstb_ref                                   varchar2(1 char)                    null,
    bzoffe                                       varchar2(2 char)                    null,
    bzoffe_ref                                   varchar2(1 char)                    null,
    offste                                       number                              null,
    ehoffe                                       varchar2(3 char)                    null,
    offste_ref                                   varchar2(1 char)                    null,
    mgform                                       varchar2(6 char)                    null,
    mgform_ref                                   varchar2(1 char)                    null,
    ewform                                       varchar2(6 char)                    null,
    ewform_ref                                   varchar2(1 char)                    null,
    par01                                        varchar2(6 char)                    null,
    par02                                        varchar2(6 char)                    null,
    par03                                        varchar2(6 char)                    null,
    par04                                        varchar2(6 char)                    null,
    par05                                        varchar2(6 char)                    null,
    par06                                        varchar2(6 char)                    null,
    paru1                                        varchar2(3 char)                    null,
    paru2                                        varchar2(3 char)                    null,
    paru3                                        varchar2(3 char)                    null,
    paru4                                        varchar2(3 char)                    null,
    paru5                                        varchar2(3 char)                    null,
    paru6                                        varchar2(3 char)                    null,
    parv1                                        number                              null,
    parv2                                        number                              null,
    parv3                                        number                              null,
    parv4                                        number                              null,
    parv5                                        number                              null,
    parv6                                        number                              null,
    msgfn2                                       varchar2(3 char)                    null,
    prgrp                                        varchar2(18 char)                   null,
    prwrk                                        varchar2(4 char)                    null,
    umref                                        varchar2(10 char)                   null,
    prgrp_external                               varchar2(40 char)                   null,
    prgrp_version                                varchar2(10 char)                   null,
    prgrp_guid                                   varchar2(32 char)                   null,
    msgfn3                                       varchar2(3 char)                    null,
    versp                                        varchar2(2 char)                    null,
    propr                                        varchar2(4 char)                    null,
    modaw                                        varchar2(1 char)                    null,
    modav                                        varchar2(1 char)                    null,
    kzpar                                        varchar2(1 char)                    null,
    opgra                                        varchar2(1 char)                    null,
    kzini                                        varchar2(1 char)                    null,
    prmod                                        varchar2(1 char)                    null,
    alpha                                        number                              null,
    beta1                                        number                              null,
    gamma                                        number                              null,
    delta                                        number                              null,
    epsil                                        number                              null,
    siggr                                        number                              null,
    perkz1                                       varchar2(1 char)                    null,
    prdat                                        varchar2(8 char)                    null,
    peran                                        number                              null,
    perin                                        number                              null,
    perio                                        number                              null,
    perex                                        number                              null,
    anzpr                                        number                              null,
    fimon                                        number                              null,
    gwert                                        number                              null,
    gwer1                                        number                              null,
    gwer2                                        number                              null,
    vmgwe                                        number                              null,
    vmgw1                                        number                              null,
    vmgw2                                        number                              null,
    twert                                        number                              null,
    vmtwe                                        number                              null,
    prmad                                        number                              null,
    vmmad                                        number                              null,
    fsumm                                        number                              null,
    vmfsu                                        number                              null,
    gewgr                                        varchar2(2 char)                    null,
    thkof                                        number                              null,
    ausna                                        varchar2(30 char)                   null,
    proab                                        varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_mrc is 'LADS Material Plant Data';
comment on column lads_mat_mrc.matnr is 'Material Number';
comment on column lads_mat_mrc.mrcseq is 'MRC - generated sequence number';
comment on column lads_mat_mrc.msgfn is 'Function';
comment on column lads_mat_mrc.werks is 'Plant';
comment on column lads_mat_mrc.pstat is 'Maintenance status';
comment on column lads_mat_mrc.lvorm is 'Deletion Indicator';
comment on column lads_mat_mrc.bwtty is 'Valuation Category';
comment on column lads_mat_mrc.maabc is 'ABC indicator';
comment on column lads_mat_mrc.kzkri is 'Indicator: Critical part';
comment on column lads_mat_mrc.ekgrp is 'Purchasing Group';
comment on column lads_mat_mrc.ausme is 'Unit of issue';
comment on column lads_mat_mrc.dispr is 'Material: MRP profile';
comment on column lads_mat_mrc.dismm is 'MRP Type';
comment on column lads_mat_mrc.dispo is 'MRP Controller';
comment on column lads_mat_mrc.plifz is 'Planned delivery time in days';
comment on column lads_mat_mrc.webaz is 'Goods receipt processing time in days';
comment on column lads_mat_mrc.perkz is 'Period indicator';
comment on column lads_mat_mrc.ausss is 'Assembly scrap in percent';
comment on column lads_mat_mrc.disls is 'Lot size (materials planning)';
comment on column lads_mat_mrc.beskz is 'Procurement Type';
comment on column lads_mat_mrc.sobsl is 'Special procurement type';
comment on column lads_mat_mrc.minbe is 'Reorder point';
comment on column lads_mat_mrc.eisbe is 'Safety stock';
comment on column lads_mat_mrc.bstmi is 'Minimum lot size';
comment on column lads_mat_mrc.bstma is 'Maximum lot size';
comment on column lads_mat_mrc.bstfe is 'Fixed lot size';
comment on column lads_mat_mrc.bstrf is 'Rounding value for purchase order quantity';
comment on column lads_mat_mrc.mabst is 'Maximum stock level';
comment on column lads_mat_mrc.losfx is 'Ordering costs';
comment on column lads_mat_mrc.sbdkz is 'Dependent requirements ind. for individual and coll. reqmts';
comment on column lads_mat_mrc.lagpr is 'Storage costs indicator';
comment on column lads_mat_mrc.altsl is 'Method for Selecting Alternative Bills of Material';
comment on column lads_mat_mrc.kzaus is 'Discontinuation indicator';
comment on column lads_mat_mrc.ausdt is 'Effective-Out Date';
comment on column lads_mat_mrc.nfmat is 'Follow-up material';
comment on column lads_mat_mrc.kzbed is 'Indicator for Requirements Grouping';
comment on column lads_mat_mrc.miskz is 'Mixed MRP indicator';
comment on column lads_mat_mrc.fhori is 'Scheduling Margin Key for Floats';
comment on column lads_mat_mrc.pfrei is 'Indicator: automatic fixing of planned orders';
comment on column lads_mat_mrc.ffrei is 'Release indicator for production orders';
comment on column lads_mat_mrc.rgekz is 'Indicator: Backflush';
comment on column lads_mat_mrc.fevor is 'Production scheduler';
comment on column lads_mat_mrc.bearz is 'Processing time';
comment on column lads_mat_mrc.ruezt is 'Setup and teardown time';
comment on column lads_mat_mrc.tranz is 'Interoperation time';
comment on column lads_mat_mrc.basmg is 'Base quantity';
comment on column lads_mat_mrc.dzeit is 'In-house production time';
comment on column lads_mat_mrc.maxlz is 'Maximum storage period';
comment on column lads_mat_mrc.lzeih is 'Unit for maximum storage period';
comment on column lads_mat_mrc.kzpro is 'Indicator: withdrawal of stock from production bin';
comment on column lads_mat_mrc.gpmkz is 'Indicator: material included in rough-cut planning';
comment on column lads_mat_mrc.ueeto is 'Overdelivery tolerance limit';
comment on column lads_mat_mrc.ueetk is 'Indicator: Unlimited overdelivery allowed';
comment on column lads_mat_mrc.uneto is 'Underdelivery tolerance limit';
comment on column lads_mat_mrc.wzeit is 'Total replenishment lead time (in workdays)';
comment on column lads_mat_mrc.atpkz is 'Replacement part';
comment on column lads_mat_mrc.vzusl is 'Surcharge factor for cost in percent';
comment on column lads_mat_mrc.herbl is 'State of manufacture';
comment on column lads_mat_mrc.insmk is 'Post to Inspection Stock';
comment on column lads_mat_mrc.ssqss is 'QA control key';
comment on column lads_mat_mrc.kzdkz is 'Documentation required indicator';
comment on column lads_mat_mrc.umlmc is 'Stock in transfer (plant to plant)';
comment on column lads_mat_mrc.ladgr is 'Loading group';
comment on column lads_mat_mrc.xchpf is 'Batch management requirement indicator';
comment on column lads_mat_mrc.usequ is 'Quota arrangement usage';
comment on column lads_mat_mrc.lgrad is 'Service level';
comment on column lads_mat_mrc.auftl is 'Splitting Indicator';
comment on column lads_mat_mrc.plvar is 'Plan Version';
comment on column lads_mat_mrc.otype is 'Object Type';
comment on column lads_mat_mrc.objid is 'Object ID';
comment on column lads_mat_mrc.mtvfp is 'Checking Group for Availability Check';
comment on column lads_mat_mrc.periv is 'Fiscal Year Variant';
comment on column lads_mat_mrc.kzkfk is 'Indicator: take correction factors into account';
comment on column lads_mat_mrc.vrvez is 'Shipping setup time';
comment on column lads_mat_mrc.vbamg is 'Base quantity for capacity planning in shipping';
comment on column lads_mat_mrc.vbeaz is 'Shipping processing time';
comment on column lads_mat_mrc.lizyk is 'Delivery cycle';
comment on column lads_mat_mrc.bwscl is 'Source of Supply';
comment on column lads_mat_mrc.kautb is '"Indicator: ""automatic purchase order allowed"""';
comment on column lads_mat_mrc.kordb is 'Indicator: Source list requirement';
comment on column lads_mat_mrc.stawn is 'Commodity code / Import code number for foreign trade';
comment on column lads_mat_mrc.herkl is 'Country of origin of the material';
comment on column lads_mat_mrc.herkr is 'Region of origin of material (non-preferential origin)';
comment on column lads_mat_mrc.expme is 'Unit of measure for commodity code (foreign trade)';
comment on column lads_mat_mrc.mtver is 'Export/import material group';
comment on column lads_mat_mrc.prctr is 'Profit Center';
comment on column lads_mat_mrc.trame is 'Stock in transit';
comment on column lads_mat_mrc.mrppp is 'PPC planning calendar';
comment on column lads_mat_mrc.sauft is 'Ind.: Repetitive mfg allowed';
comment on column lads_mat_mrc.fxhor is 'Planning time fence';
comment on column lads_mat_mrc.vrmod is 'Consumption mode';
comment on column lads_mat_mrc.vint1 is 'Consumption period: backward';
comment on column lads_mat_mrc.vint2 is 'Consumption period: forward';
comment on column lads_mat_mrc.stlal is 'Alternative BOM';
comment on column lads_mat_mrc.stlan is 'BOM Usage';
comment on column lads_mat_mrc.plnnr is 'Key for Task List Group';
comment on column lads_mat_mrc.aplal is 'Group Counter';
comment on column lads_mat_mrc.losgr is 'Lot Size for Product Costing';
comment on column lads_mat_mrc.sobsk is 'Special Procurement Type for Costing';
comment on column lads_mat_mrc.frtme is 'Production unit';
comment on column lads_mat_mrc.lgpro is 'Issue Storage Location';
comment on column lads_mat_mrc.disgr is 'MRP Group';
comment on column lads_mat_mrc.kausf is 'Component scrap in percent';
comment on column lads_mat_mrc.qzgtp is 'Certificate Type';
comment on column lads_mat_mrc.takzt is 'Takt time';
comment on column lads_mat_mrc.rwpro is 'Range of coverage profile';
comment on column lads_mat_mrc.copam is 'Local field name for CO/PA link to SOP';
comment on column lads_mat_mrc.abcin is 'Physical inventory indicator for cycle counting';
comment on column lads_mat_mrc.awsls is 'Variance Key';
comment on column lads_mat_mrc.sernp is 'Serial Number Profile';
comment on column lads_mat_mrc.stdpd is 'Configurable material';
comment on column lads_mat_mrc.sfepr is 'Repetitive manufacturing profile';
comment on column lads_mat_mrc.xmcng is 'Negative stocks allowed in plant';
comment on column lads_mat_mrc.qssys is 'Required QM System for Vendor';
comment on column lads_mat_mrc.lfrhy is 'Planning cycle';
comment on column lads_mat_mrc.rdprf is 'Rounding profile';
comment on column lads_mat_mrc.vrbmt is 'Reference material for consumption';
comment on column lads_mat_mrc.vrbwk is 'Reference plant for consumption';
comment on column lads_mat_mrc.vrbdt is 'To date of the material to be copied for consumption';
comment on column lads_mat_mrc.vrbfk is 'Multiplier for reference material for consumption';
comment on column lads_mat_mrc.autru is 'Reset Forecast Model Automatically';
comment on column lads_mat_mrc.prefe is 'Preference indicator in export/import';
comment on column lads_mat_mrc.prenc is 'Exemption certificate: Indicator for legal control';
comment on column lads_mat_mrc.preno is 'Number of exemption certificate in export/import';
comment on column lads_mat_mrc.prend is 'Exemption certificate: Issue date of exemption certificate';
comment on column lads_mat_mrc.prene is 'Indicator: Vendor declaration exists';
comment on column lads_mat_mrc.preng is 'Validity date of vendor declaration';
comment on column lads_mat_mrc.itark is 'Indicator: Military goods';
comment on column lads_mat_mrc.prfrq is 'Character Field With Field Length 7';
comment on column lads_mat_mrc.kzkup is 'Indicator: Material can be co-product';
comment on column lads_mat_mrc.strgr is 'Planning strategy group';
comment on column lads_mat_mrc.lgfsb is 'Default storage location for external procurement';
comment on column lads_mat_mrc.schgt is 'Indicator: bulk material';
comment on column lads_mat_mrc.ccfix is 'CC indicator is fixed';
comment on column lads_mat_mrc.eprio is 'Withdrawal sequence group for stocks';
comment on column lads_mat_mrc.qmata is 'Material Authorization Group for Activities in QM';
comment on column lads_mat_mrc.plnty is 'Task List Type';
comment on column lads_mat_mrc.mmsta is 'Plant-Specific Material Status';
comment on column lads_mat_mrc.sfcpf is 'Production Scheduling Profile';
comment on column lads_mat_mrc.shflg is 'Safety time indicator (with or without safety time)';
comment on column lads_mat_mrc.shzet is 'Safety time (in workdays)';
comment on column lads_mat_mrc.mdach is 'Action control: planned order processing';
comment on column lads_mat_mrc.kzech is 'Determination of batch entry in the production/process order';
comment on column lads_mat_mrc.mmstd is 'Date from which the plant-specific material status is valid';
comment on column lads_mat_mrc.mfrgr is 'Material freight group';
comment on column lads_mat_mrc.fvidk is 'Production Version To Be Costed';
comment on column lads_mat_mrc.indus is 'Material CFOP category';
comment on column lads_mat_mrc.mownr is 'CAP: Number of CAP products list';
comment on column lads_mat_mrc.mogru is 'Common Agricultural Policy: CAP products group-Foreign Trade';
comment on column lads_mat_mrc.casnr is 'CAS number for pharmaceutical products in foreign trade';
comment on column lads_mat_mrc.gpnum is 'Production statistics: PRODCOM number for foreign trade';
comment on column lads_mat_mrc.steuc is 'Control code for consumption taxes in foreign trade';
comment on column lads_mat_mrc.fabkz is 'Indicator: Item relevant to JIT delivery schedules';
comment on column lads_mat_mrc.matgr is 'Group of materials for transition matrix';
comment on column lads_mat_mrc.loggr is 'Logistics handling group for workload calculation';
comment on column lads_mat_mrc.vspvb is 'Proposed Supply Area in Material Master Record';
comment on column lads_mat_mrc.dplfs is 'Fair share rule';
comment on column lads_mat_mrc.dplpu is 'Indicator: push distribution';
comment on column lads_mat_mrc.dplho is 'Deployment horizon in days';
comment on column lads_mat_mrc.minls is 'Minimum lot size for Supply Demand Match';
comment on column lads_mat_mrc.maxls is 'Maximum lot size for Supply Demand Match';
comment on column lads_mat_mrc.fixls is 'Fixed lot size for Supply Demand Match';
comment on column lads_mat_mrc.ltinc is 'Lot size increment for  Supply Demand Match';
comment on column lads_mat_mrc.compl is 'Material completion level';
comment on column lads_mat_mrc.convt is 'Conversion types for production figures';
comment on column lads_mat_mrc.fprfm is 'Distribution profile of material in plant';
comment on column lads_mat_mrc.shpro is 'Period profile for safety time';
comment on column lads_mat_mrc.fxpru is 'Fixed-Price Co-Product';
comment on column lads_mat_mrc.kzpsp is 'Indicator for cross-project material';
comment on column lads_mat_mrc.ocmpf is 'Profile for OCM PP / PS';
comment on column lads_mat_mrc.apokz is 'Indicator: Is material relevant for APO';
comment on column lads_mat_mrc.ahdis is 'MRP relevancy for dependent requirements';
comment on column lads_mat_mrc.eislo is 'Minimum Safety Stock';
comment on column lads_mat_mrc.ncost is 'Do Not Cost';
comment on column lads_mat_mrc.megru is 'Unit of measure group';
comment on column lads_mat_mrc.rotation_date is 'Rotation date';
comment on column lads_mat_mrc.uchkz is 'Indicator for Original Batch Management';
comment on column lads_mat_mrc.ucmat is 'Reference Material for Original Batches';
comment on column lads_mat_mrc.msgfn1 is 'Function';
comment on column lads_mat_mrc.objty is 'Object types of the CIM resource';
comment on column lads_mat_mrc.objid1 is 'Object ID of the resource';
comment on column lads_mat_mrc.zaehl is 'Internal counter';
comment on column lads_mat_mrc.objty_v is 'Object types of the CIM resource';
comment on column lads_mat_mrc.objid_v is 'Object ID of the resource';
comment on column lads_mat_mrc.kzkbl is 'Indicator: Create load records for prod. resources/tools';
comment on column lads_mat_mrc.steuf is 'Control key for management of production resources/tools';
comment on column lads_mat_mrc.steuf_ref is 'Control key cannot be changed';
comment on column lads_mat_mrc.fgru1 is 'Grouping key 1 for production resources/tools';
comment on column lads_mat_mrc.fgru2 is 'Grouping key 2 for production resources/tools';
comment on column lads_mat_mrc.planv is 'Production resource/tool usage';
comment on column lads_mat_mrc.ktsch is 'Standard text key for production resources/tools';
comment on column lads_mat_mrc.ktsch_ref is 'Reference key cannot be changed.';
comment on column lads_mat_mrc.bzoffb is 'Reference date to start of production resource/tool usage';
comment on column lads_mat_mrc.bzoffb_ref is 'Offset to start cannot be changed';
comment on column lads_mat_mrc.offstb is 'Offset to start of production resource/tool usage';
comment on column lads_mat_mrc.ehoffb is 'Offset unit for start of prod. resource/tool usage';
comment on column lads_mat_mrc.offstb_ref is 'Offset to start cannot be changed';
comment on column lads_mat_mrc.bzoffe is 'Reference date for end of production resource/tool usage';
comment on column lads_mat_mrc.bzoffe_ref is 'End reference date cannot be changed';
comment on column lads_mat_mrc.offste is 'Offset to finish of production resource/tool usage';
comment on column lads_mat_mrc.ehoffe is 'Offset unit for end of production resource/tool usage';
comment on column lads_mat_mrc.offste_ref is 'Offset to end cannot be changed';
comment on column lads_mat_mrc.mgform is 'Formula for calculating the total quantity of PRT';
comment on column lads_mat_mrc.mgform_ref is 'Formula for calculating the total quantity cannot be changed';
comment on column lads_mat_mrc.ewform is 'Formula for calculating the total usage value of PRT';
comment on column lads_mat_mrc.ewform_ref is 'Formula to calculate entire usage value cannot be changed';
comment on column lads_mat_mrc.par01 is 'First parameter (for formulas)';
comment on column lads_mat_mrc.par02 is 'Second parameter (for formulas)';
comment on column lads_mat_mrc.par03 is 'Third parameter (for formulas)';
comment on column lads_mat_mrc.par04 is 'Fourth parameter (for formulas)';
comment on column lads_mat_mrc.par05 is 'Fifth parameter (for formulas)';
comment on column lads_mat_mrc.par06 is 'Sixth parameter (for formulas)';
comment on column lads_mat_mrc.paru1 is 'Parameter unit';
comment on column lads_mat_mrc.paru2 is 'Parameter unit';
comment on column lads_mat_mrc.paru3 is 'Parameter unit';
comment on column lads_mat_mrc.paru4 is 'Parameter unit';
comment on column lads_mat_mrc.paru5 is 'Parameter unit';
comment on column lads_mat_mrc.paru6 is 'Parameter unit';
comment on column lads_mat_mrc.parv1 is 'Parameter value';
comment on column lads_mat_mrc.parv2 is 'Parameter value';
comment on column lads_mat_mrc.parv3 is 'Parameter value';
comment on column lads_mat_mrc.parv4 is 'Parameter value';
comment on column lads_mat_mrc.parv5 is 'Parameter value';
comment on column lads_mat_mrc.parv6 is 'Parameter value';
comment on column lads_mat_mrc.msgfn2 is 'Function';
comment on column lads_mat_mrc.prgrp is 'Planning material';
comment on column lads_mat_mrc.prwrk is 'Planning plant';
comment on column lads_mat_mrc.umref is 'Conv. factor f. plng material';
comment on column lads_mat_mrc.prgrp_external is 'Long material number (future development) for field PRGRP';
comment on column lads_mat_mrc.prgrp_version is 'Version number (future development) for field PRGRP';
comment on column lads_mat_mrc.prgrp_guid is 'External GUID (future development) for field PRGRP';
comment on column lads_mat_mrc.msgfn3 is 'Function';
comment on column lads_mat_mrc.versp is 'Version number of forecast parameters';
comment on column lads_mat_mrc.propr is 'Forecast profile';
comment on column lads_mat_mrc.modaw is 'Model selection indicator';
comment on column lads_mat_mrc.modav is 'Model selection procedure';
comment on column lads_mat_mrc.kzpar is 'Indicator for parameter optimization';
comment on column lads_mat_mrc.opgra is 'Optimization level';
comment on column lads_mat_mrc.kzini is 'Initialization indicator';
comment on column lads_mat_mrc.prmod is 'Forecast model';
comment on column lads_mat_mrc.alpha is 'Basic value smoothing using alpha factor';
comment on column lads_mat_mrc.beta1 is 'Trend value smoothing using the beta factor';
comment on column lads_mat_mrc.gamma is 'Seasonal index smoothing using gamma factor';
comment on column lads_mat_mrc.delta is 'MAD (mean absolute deviation) smoothing using delta factor';
comment on column lads_mat_mrc.epsil is 'Epsilon factor';
comment on column lads_mat_mrc.siggr is 'Tracking limit';
comment on column lads_mat_mrc.perkz1 is 'Period indicator';
comment on column lads_mat_mrc.prdat is 'Date of last forecast';
comment on column lads_mat_mrc.peran is 'Number of historical periods';
comment on column lads_mat_mrc.perin is 'Number of periods for initialization';
comment on column lads_mat_mrc.perio is 'Number of periods per seasonal cycle';
comment on column lads_mat_mrc.perex is 'Number of periods for ex-post forecasting';
comment on column lads_mat_mrc.anzpr is 'Number of forecast periods';
comment on column lads_mat_mrc.fimon is 'Fixed periods';
comment on column lads_mat_mrc.gwert is 'Basic value';
comment on column lads_mat_mrc.gwer1 is 'Basic value of the 2nd order';
comment on column lads_mat_mrc.gwer2 is 'Basic value of the 2nd order';
comment on column lads_mat_mrc.vmgwe is 'Basic value of previous period';
comment on column lads_mat_mrc.vmgw1 is 'Base value of the second order in previous period';
comment on column lads_mat_mrc.vmgw2 is 'Base value of the second order in previous period';
comment on column lads_mat_mrc.twert is 'Trend value';
comment on column lads_mat_mrc.vmtwe is 'Trend value of previous period';
comment on column lads_mat_mrc.prmad is 'Mean absolute deviation (MAD)';
comment on column lads_mat_mrc.vmmad is 'Mean absolute devaition of previous period';
comment on column lads_mat_mrc.fsumm is 'Error total';
comment on column lads_mat_mrc.vmfsu is 'Error total for the previous period';
comment on column lads_mat_mrc.gewgr is 'Weighting group';
comment on column lads_mat_mrc.thkof is 'Theil coefficient';
comment on column lads_mat_mrc.ausna is 'Exception message bar';
comment on column lads_mat_mrc.proab is 'Forecast flow control';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_mrc
   add constraint lads_mat_mrc_pk primary key (matnr, mrcseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_mrc to lads_app;
grant select, insert, update, delete on lads_mat_mrc to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_mrc for lads.lads_mat_mrc;
