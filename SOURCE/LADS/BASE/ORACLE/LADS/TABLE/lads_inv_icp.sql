/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_icp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_icp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_icp
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    icnseq                                       number                              not null,
    icpseq                                       number                              not null,
    kosrt                                        varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_icp is 'LADS Invoice Item Promotion';
comment on column lads_inv_icp.belnr is 'IDOC document number';
comment on column lads_inv_icp.genseq is 'GEN - generated sequence number';
comment on column lads_inv_icp.icnseq is 'ICN - generated sequence number';
comment on column lads_inv_icp.icpseq is 'ICP - generated sequence number';
comment on column lads_inv_icp.kosrt is 'Promotion Number';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_icp
   add constraint lads_inv_icp_pk primary key (belnr, genseq, icnseq, icpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_icp to lads_app;
grant select, insert, update, delete on lads_inv_icp to ics_app;
grant select on lads_inv_icp to ics_reader with grant option;
grant select on lads_inv_icp to ics_executor;
grant select on lads_inv_icp to site_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_icp for lads.lads_inv_icp;
