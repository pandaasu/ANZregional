/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_top
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_top

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_top
   (belnr                                        varchar2(35 char)                   not null,
    topseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    tage                                         varchar2(8 char)                    null,
    prznt                                        varchar2(8 char)                    null,
    zterm_txt                                    varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_top is 'LADS Invoice Terms Of Payment';
comment on column lads_inv_top.belnr is 'IDOC document number';
comment on column lads_inv_top.topseq is 'TOP - generated sequence number';
comment on column lads_inv_top.qualf is 'IDOC qualifier: Terms of payment';
comment on column lads_inv_top.tage is 'IDOC Number of days';
comment on column lads_inv_top.prznt is 'IDOC percentage for terms of payment';
comment on column lads_inv_top.zterm_txt is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_top
   add constraint lads_inv_top_pk primary key (belnr, topseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_top to lads_app;
grant select, insert, update, delete on lads_inv_top to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_top for lads.lads_inv_top;
