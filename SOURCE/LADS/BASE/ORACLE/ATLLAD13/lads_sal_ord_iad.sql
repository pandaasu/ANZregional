/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_iad
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_iad

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_iad
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iadseq                                       number                              not null,
    addimatnr                                    varchar2(18 char)                   null,
    addinumber                                   number                              null,
    addivkme                                     number                              null,
    addifm                                       varchar2(4 char)                    null,
    addifm_txt                                   varchar2(40 char)                   null,
    addiklart                                    varchar2(3 char)                    null,
    addiklart_txt                                varchar2(40 char)                   null,
    addiclass                                    varchar2(18 char)                   null,
    addiclass_txt                                varchar2(40 char)                   null,
    addiidoc                                     varchar2(1 char)                    null,
    addimatnr_external                           varchar2(40 char)                   null,
    addimatnr_version                            varchar2(10 char)                   null,
    addimatnr_guid                               varchar2(32 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_iad is 'LADS Sales Order Item Material';
comment on column lads_sal_ord_iad.belnr is 'Document number';
comment on column lads_sal_ord_iad.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_iad.iadseq is 'IAD - generated sequence number';
comment on column lads_sal_ord_iad.addimatnr is 'Material number for additional';
comment on column lads_sal_ord_iad.addinumber is 'Number of additionals';
comment on column lads_sal_ord_iad.addivkme is 'Sales unit of the material';
comment on column lads_sal_ord_iad.addifm is 'Procedure for additionals';
comment on column lads_sal_ord_iad.addifm_txt is 'Additionals: Description for the procedure for additionals';
comment on column lads_sal_ord_iad.addiklart is 'Class type displayed when editing additionals';
comment on column lads_sal_ord_iad.addiklart_txt is 'Text describing class type';
comment on column lads_sal_ord_iad.addiclass is 'Class with additionals assigned to its elements';
comment on column lads_sal_ord_iad.addiclass_txt is 'Keywords';
comment on column lads_sal_ord_iad.addiidoc is 'Indicator which refers to separate additionals IDoc';
comment on column lads_sal_ord_iad.addimatnr_external is 'Long material number (future development) for ADDIM field';
comment on column lads_sal_ord_iad.addimatnr_version is 'Version number (future development) for ADDIMATNR field';
comment on column lads_sal_ord_iad.addimatnr_guid is 'External GUID (future development) for ADDIMATNR field';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_iad
   add constraint lads_sal_ord_iad_pk primary key (belnr, genseq, iadseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_iad to lads_app;
grant select, insert, update, delete on lads_sal_ord_iad to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_iad for lads.lads_sal_ord_iad;
