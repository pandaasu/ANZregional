/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_vat
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_vat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_vat
   (kunnr                                        varchar2(10 char)                   not null,
    vatseq                                       number                              not null,
    land1                                        varchar2(3 char)                    null,
    stceg                                        varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_cus_vat is 'LADS Customer Additional Tax Number';
comment on column lads_cus_vat.kunnr is 'Customer Number';
comment on column lads_cus_vat.vatseq is 'VAT - generated sequence number';
comment on column lads_cus_vat.land1 is 'Country Key';
comment on column lads_cus_vat.stceg is 'VAT registration number';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_vat
   add constraint lads_cus_vat_pk primary key (kunnr, vatseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_vat to lads_app;
grant select, insert, update, delete on lads_cus_vat to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_vat for lads.lads_cus_vat;
