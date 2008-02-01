/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_zcc
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_zcc

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_zcc
   (lifnr                                        varchar2(10 char)                   not null,
    ccdseq                                       number                              not null,
    zccseq                                       number                              not null,
    zpytadv                                      varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_zcc is 'LADS Vendor Company MARS Data';
comment on column lads_ven_zcc.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_zcc.ccdseq is 'CCD - generated sequence number';
comment on column lads_ven_zcc.zccseq is 'ZCC - generated sequence number';
comment on column lads_ven_zcc.zpytadv is 'Transmission medium';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_zcc
   add constraint lads_ven_zcc_pk primary key (lifnr, ccdseq, zccseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_zcc to lads_app;
grant select, insert, update, delete on lads_ven_zcc to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_zcc for lads.lads_ven_zcc;
