/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_sog
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_sog

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_sog
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    sogseq                                       number                              not null,
    z_lcdid                                      varchar2(5 char)                    null,
    z_lcdnr                                      varchar2(18 char)                   null,
    z_lcddsc                                     varchar2(16 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_sog is 'LADS Sales Order Item Regional';
comment on column lads_sal_ord_sog.belnr is 'Document number';
comment on column lads_sal_ord_sog.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_sog.sogseq is 'SOG - generated sequence number';
comment on column lads_sal_ord_sog.z_lcdid is 'Regional code Id';
comment on column lads_sal_ord_sog.z_lcdnr is 'Regional code number';
comment on column lads_sal_ord_sog.z_lcddsc is 'Regional code description';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_sog
   add constraint lads_sal_ord_sog_pk primary key (belnr, genseq, sogseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_sog to lads_app;
grant select, insert, update, delete on lads_sal_ord_sog to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_sog for lads.lads_sal_ord_sog;
