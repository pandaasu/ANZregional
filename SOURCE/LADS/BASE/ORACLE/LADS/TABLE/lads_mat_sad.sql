/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_sad
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_sad

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_sad
   (matnr                                        varchar2(18 char)                   not null,
    sadseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    lvorm                                        varchar2(1 char)                    null,
    versg                                        varchar2(1 char)                    null,
    bonus                                        varchar2(2 char)                    null,
    provg                                        varchar2(2 char)                    null,
    sktof                                        varchar2(1 char)                    null,
    vmsta                                        varchar2(2 char)                    null,
    vmstd                                        varchar2(8 char)                    null,
    aumng                                        number                              null,
    lfmng                                        number                              null,
    efmng                                        number                              null,
    scmng                                        number                              null,
    schme                                        varchar2(3 char)                    null,
    vrkme                                        varchar2(3 char)                    null,
    mtpos                                        varchar2(4 char)                    null,
    dwerk                                        varchar2(4 char)                    null,
    prodh                                        varchar2(18 char)                   null,
    pmatn                                        varchar2(18 char)                   null,
    kondm                                        varchar2(2 char)                    null,
    ktgrm                                        varchar2(2 char)                    null,
    mvgr1                                        varchar2(3 char)                    null,
    mvgr2                                        varchar2(3 char)                    null,
    mvgr3                                        varchar2(3 char)                    null,
    mvgr4                                        varchar2(3 char)                    null,
    mvgr5                                        varchar2(3 char)                    null,
    sstuf                                        varchar2(2 char)                    null,
    pflks                                        varchar2(1 char)                    null,
    lstfl                                        varchar2(2 char)                    null,
    lstvz                                        varchar2(2 char)                    null,
    lstak                                        varchar2(1 char)                    null,
    prat1                                        varchar2(1 char)                    null,
    prat2                                        varchar2(1 char)                    null,
    prat3                                        varchar2(1 char)                    null,
    prat4                                        varchar2(1 char)                    null,
    prat5                                        varchar2(1 char)                    null,
    prat6                                        varchar2(1 char)                    null,
    prat7                                        varchar2(1 char)                    null,
    prat8                                        varchar2(1 char)                    null,
    prat9                                        varchar2(1 char)                    null,
    prata                                        varchar2(1 char)                    null,
    vavme                                        varchar2(1 char)                    null,
    rdprf                                        varchar2(4 char)                    null,
    megru                                        varchar2(4 char)                    null,
    pmatn_external                               varchar2(40 char)                   null,
    pmatn_version                                varchar2(10 char)                   null,
    pmatn_guid                                   varchar2(32 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_sad is 'LADS Material Sales Area Data';
comment on column lads_mat_sad.matnr is 'Material Number';
comment on column lads_mat_sad.sadseq is 'SAD - generated sequence number';
comment on column lads_mat_sad.msgfn is 'Function';
comment on column lads_mat_sad.vkorg is 'Sales Organization';
comment on column lads_mat_sad.vtweg is 'Distribution Channel';
comment on column lads_mat_sad.lvorm is 'Ind.: Flag material for deletion at distribution chain level';
comment on column lads_mat_sad.versg is 'Material statistics group';
comment on column lads_mat_sad.bonus is 'Volume rebate group';
comment on column lads_mat_sad.provg is 'Commission group';
comment on column lads_mat_sad.sktof is 'Cash discount indicator';
comment on column lads_mat_sad.vmsta is 'Distribution-chain-specific material status';
comment on column lads_mat_sad.vmstd is 'Date from which distr.-chain-spec. material status is valid';
comment on column lads_mat_sad.aumng is 'Minimum order quantity in base unit of measure';
comment on column lads_mat_sad.lfmng is 'Minimum delivery quantity in delivery note processing';
comment on column lads_mat_sad.efmng is 'Minimum make-to-order quantity';
comment on column lads_mat_sad.scmng is 'Delivery unit';
comment on column lads_mat_sad.schme is 'Unit of measure of delivery unit';
comment on column lads_mat_sad.vrkme is 'Sales unit';
comment on column lads_mat_sad.mtpos is 'Item category group from material master';
comment on column lads_mat_sad.dwerk is 'Delivering Plant';
comment on column lads_mat_sad.prodh is 'Product hierarchy';
comment on column lads_mat_sad.pmatn is 'Pricing reference material';
comment on column lads_mat_sad.kondm is 'Material Pricing Group';
comment on column lads_mat_sad.ktgrm is 'Account assignment group for this material';
comment on column lads_mat_sad.mvgr1 is 'CRPC Material Category';
comment on column lads_mat_sad.mvgr2 is 'Material group 2';
comment on column lads_mat_sad.mvgr3 is 'Material group 3';
comment on column lads_mat_sad.mvgr4 is 'Material Group 4';
comment on column lads_mat_sad.mvgr5 is 'Material group 5';
comment on column lads_mat_sad.sstuf is 'Assortment grade';
comment on column lads_mat_sad.pflks is 'External assortment priority';
comment on column lads_mat_sad.lstfl is 'Listing procedure for store or other assortment categories';
comment on column lads_mat_sad.lstvz is 'Listing procedure for distr. center assortment categories';
comment on column lads_mat_sad.lstak is 'Listing functions (assortments) are active';
comment on column lads_mat_sad.prat1 is 'ID for product attribute 1';
comment on column lads_mat_sad.prat2 is 'ID for product attribute 2';
comment on column lads_mat_sad.prat3 is 'ID for product attribute 3';
comment on column lads_mat_sad.prat4 is 'ID for product attribute 4';
comment on column lads_mat_sad.prat5 is 'ID for product attribute 5';
comment on column lads_mat_sad.prat6 is 'ID for product attribute 6';
comment on column lads_mat_sad.prat7 is 'ID for product attribute 7';
comment on column lads_mat_sad.prat8 is 'ID for product attribute 8';
comment on column lads_mat_sad.prat9 is 'ID for product attribute 9';
comment on column lads_mat_sad.prata is 'ID for product attribute 10';
comment on column lads_mat_sad.vavme is 'Variable Sales Unit Not Allowed';
comment on column lads_mat_sad.rdprf is 'Rounding profile';
comment on column lads_mat_sad.megru is 'Unit of measure group';
comment on column lads_mat_sad.pmatn_external is 'Long material number (future development) for field PMATN';
comment on column lads_mat_sad.pmatn_version is 'Version number (future development) for field PMATN';
comment on column lads_mat_sad.pmatn_guid is 'External GUID (future development) for field PMATN';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_sad
   add constraint lads_mat_sad_pk primary key (matnr, sadseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_sad to lads_app;
grant select, insert, update, delete on lads_mat_sad to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_sad for lads.lads_mat_sad;
