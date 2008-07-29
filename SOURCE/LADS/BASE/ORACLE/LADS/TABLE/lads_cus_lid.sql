/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_lid
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_lid

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_lid
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    lidseq                                       number                              not null,
    aland                                        varchar2(3 char)                    null,
    tatyp                                        varchar2(4 char)                    null,
    licnr                                        varchar2(15 char)                   null,
    datab                                        varchar2(8 char)                    null,
    datbi                                        varchar2(8 char)                    null,
    belic                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_lid is 'LADS Customer License';
comment on column lads_cus_lid.kunnr is 'Customer Number';
comment on column lads_cus_lid.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_lid.lidseq is 'LID - generated sequence number';
comment on column lads_cus_lid.aland is 'Departure country (country from which the goods are sent)';
comment on column lads_cus_lid.tatyp is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_cus_lid.licnr is 'License number';
comment on column lads_cus_lid.datab is 'Valid-From Date';
comment on column lads_cus_lid.datbi is 'Valid To Date';
comment on column lads_cus_lid.belic is 'Confirmation for licenses';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_lid
   add constraint lads_cus_lid_pk primary key (kunnr, sadseq, lidseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_lid to lads_app;
grant select, insert, update, delete on lads_cus_lid to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_lid for lads.lads_cus_lid;
