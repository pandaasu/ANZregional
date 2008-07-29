/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_stx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_stx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_stx
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    stxseq                                       number                              not null,
    aland                                        varchar2(3 char)                    null,
    tatyp                                        varchar2(4 char)                    null,
    taxkd                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_stx is 'LADS Customer Tax Indicator';
comment on column lads_cus_stx.kunnr is 'Customer Number';
comment on column lads_cus_stx.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_stx.stxseq is 'STX - generated sequence number';
comment on column lads_cus_stx.aland is 'Departure country (country from which the goods are sent)';
comment on column lads_cus_stx.tatyp is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_cus_stx.taxkd is 'Tax classification for customer';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_stx
   add constraint lads_cus_stx_pk primary key (kunnr, sadseq, stxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_stx to lads_app;
grant select, insert, update, delete on lads_cus_stx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_stx for lads.lads_cus_stx;
