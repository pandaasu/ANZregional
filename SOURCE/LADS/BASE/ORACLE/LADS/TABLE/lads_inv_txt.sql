/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_txt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_txt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_txt
   (belnr                                        varchar2(35 char)                   not null,
    txtseq                                       number                              not null,
    tdid                                         varchar2(4 char)                    null,
    tsspras                                      varchar2(3 char)                    null,
    tsspras_iso                                  varchar2(2 char)                    null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_txt is 'LADS Invoice Text Header';
comment on column lads_inv_txt.belnr is 'IDOC document number';
comment on column lads_inv_txt.txtseq is 'TXT - generated sequence number';
comment on column lads_inv_txt.tdid is 'Text ID';
comment on column lads_inv_txt.tsspras is 'Language Key';
comment on column lads_inv_txt.tsspras_iso is 'Language according to ISO 639';
comment on column lads_inv_txt.tdobject is 'Texts: application object';
comment on column lads_inv_txt.tdobname is 'Name';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_txt
   add constraint lads_inv_txt_pk primary key (belnr, txtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_txt to lads_app;
grant select, insert, update, delete on lads_inv_txt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_txt for lads.lads_inv_txt;
