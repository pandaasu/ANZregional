/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_iti
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_iti

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_iti
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itxseq                                       number                              not null,
    itiseq                                       number                              not null,
    tdline                                       varchar2(70 char)                   null,
    tdformat                                     varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_iti is 'LADS Invoice Item Text Detail';
comment on column lads_inv_iti.belnr is 'IDOC document number';
comment on column lads_inv_iti.genseq is 'GEN - generated sequence number';
comment on column lads_inv_iti.itxseq is 'ITX - generated sequence number';
comment on column lads_inv_iti.itiseq is 'ITI - generated sequence number';
comment on column lads_inv_iti.tdline is 'Text line';
comment on column lads_inv_iti.tdformat is 'Tag column';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_iti
   add constraint lads_inv_iti_pk primary key (belnr, genseq, itxseq, itiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_iti to lads_app;
grant select, insert, update, delete on lads_inv_iti to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_iti for lads.lads_inv_iti;
