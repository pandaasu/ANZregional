/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_tax
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_tax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_tax
   (matnr                                        varchar2(18 char)                   not null,
    taxseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    aland                                        varchar2(3 char)                    null,
    taty1                                        varchar2(4 char)                    null,
    taxm1                                        varchar2(1 char)                    null,
    taty2                                        varchar2(4 char)                    null,
    taxm2                                        varchar2(1 char)                    null,
    taty3                                        varchar2(4 char)                    null,
    taxm3                                        varchar2(1 char)                    null,
    taty4                                        varchar2(4 char)                    null,
    taxm4                                        varchar2(1 char)                    null,
    taty5                                        varchar2(4 char)                    null,
    taxm5                                        varchar2(1 char)                    null,
    taty6                                        varchar2(4 char)                    null,
    taxm6                                        varchar2(1 char)                    null,
    taty7                                        varchar2(4 char)                    null,
    taxm7                                        varchar2(1 char)                    null,
    taty8                                        varchar2(4 char)                    null,
    taxm8                                        varchar2(1 char)                    null,
    taty9                                        varchar2(4 char)                    null,
    taxm9                                        varchar2(1 char)                    null,
    taxim                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_tax is 'LADS Material Tax Classification';
comment on column lads_mat_tax.matnr is 'Material Number';
comment on column lads_mat_tax.taxseq is 'TAX - generated sequence number';
comment on column lads_mat_tax.msgfn is 'Function';
comment on column lads_mat_tax.aland is 'Departure country (country from which the goods are sent)';
comment on column lads_mat_tax.taty1 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm1 is 'Tax classification material';
comment on column lads_mat_tax.taty2 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm2 is 'Tax classification material';
comment on column lads_mat_tax.taty3 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm3 is 'Tax classification material';
comment on column lads_mat_tax.taty4 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm4 is 'Tax classification material';
comment on column lads_mat_tax.taty5 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm5 is 'Tax classification material';
comment on column lads_mat_tax.taty6 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm6 is 'Tax classification material';
comment on column lads_mat_tax.taty7 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm7 is 'Tax classification material';
comment on column lads_mat_tax.taty8 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm8 is 'Tax classification material';
comment on column lads_mat_tax.taty9 is '"Tax category (sales tax, federal sales tax,...)"';
comment on column lads_mat_tax.taxm9 is 'Tax classification material';
comment on column lads_mat_tax.taxim is 'Tax indicator for material (Purchasing)';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_tax
   add constraint lads_mat_tax_pk primary key (matnr, taxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_tax to lads_app;
grant select, insert, update, delete on lads_mat_tax to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_tax for lads.lads_mat_tax;
