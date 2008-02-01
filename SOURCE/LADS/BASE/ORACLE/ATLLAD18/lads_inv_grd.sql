/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_grd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_grd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_grd
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    grdseq                                       number                              not null,
    z_lcdid                                      varchar2(5 char)                    null,
    z_lcdnr                                      varchar2(18 char)                   null,
    z_lcddsc                                     varchar2(16 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_grd is 'LADS Invoice Item Regional';
comment on column lads_inv_grd.belnr is 'IDOC document number';
comment on column lads_inv_grd.genseq is 'GEN - generated sequence number';
comment on column lads_inv_grd.grdseq is 'GRD - generated sequence number';
comment on column lads_inv_grd.z_lcdid is 'Regional code Id';
comment on column lads_inv_grd.z_lcdnr is 'Regional code number';
comment on column lads_inv_grd.z_lcddsc is 'Regional code description';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_grd
   add constraint lads_inv_grd_pk primary key (belnr, genseq, grdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_grd to lads_app;
grant select, insert, update, delete on lads_inv_grd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_grd for lads.lads_inv_grd;
