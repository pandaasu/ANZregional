/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_prc_lst_val
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_prc_lst_val

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Replaced DATSEQ with KNUMH
                          as a result of LADS_PRC_LST_HDR 
                          and LADS_PRC_LST_DAT flattening
 2005/05   Linden Glen    Primary key now includes DATAB

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_prc_lst_val
   (vakey                                        varchar2(50 char)                   not null,
    kschl                                        varchar2(4 char)                    not null,
    knumh                                        varchar2(10 char)                   not null,
    datab                                        varchar2(8 char)                    not null,
    detseq                                       number                              not null,
    valseq                                       number                              not null,
    kstbw                                        number                              null,
    kbetr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_prc_lst_val is 'LADS Price List Value';
comment on column lads_prc_lst_val.vakey is 'Variable key 50 bytes';
comment on column lads_prc_lst_val.kschl is 'Condition type';
comment on column lads_prc_lst_val.knumh is 'Condition record number';
comment on column lads_prc_lst_val.datab is 'Valid-From Date';
comment on column lads_prc_lst_val.detseq is 'DET - generated sequence number';
comment on column lads_prc_lst_val.valseq is 'VAL - generated sequence number';
comment on column lads_prc_lst_val.kstbw is 'Condition scale quantity';
comment on column lads_prc_lst_val.kbetr is 'Rate (condition amount or percentage)';

/**/
/* Primary Key Constraint
/**/
alter table lads_prc_lst_val
   add constraint lads_prc_lst_val_pk primary key (vakey, kschl, knumh, datab, detseq, valseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_prc_lst_val to lads_app;
grant select, insert, update, delete on lads_prc_lst_val to ics_app;
grant select on lads_prc_lst_val to site_app;
grant select on lads_prc_lst_val to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym lads_prc_lst_val for lads.lads_prc_lst_val;
