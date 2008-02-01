/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_prc_lst_qua
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_prc_lst_qua

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
create table lads_prc_lst_qua
   (vakey                                        varchar2(50 char)                   not null,
    kschl                                        varchar2(4 char)                    not null,
    knumh                                        varchar2(10 char)                   not null,
    datab                                        varchar2(8 char)                    not null,
    detseq                                       number                              not null,
    quaseq                                       number                              not null,
    kstbm                                        number                              null,
    kbetr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_prc_lst_qua is 'LADS Price List Quantity';
comment on column lads_prc_lst_qua.vakey is 'Variable key 50 bytes';
comment on column lads_prc_lst_qua.kschl is 'Condition type';
comment on column lads_prc_lst_qua.knumh is 'Condition record number';
comment on column lads_prc_lst_qua.datab is 'Valid-From Date';
comment on column lads_prc_lst_qua.detseq is 'DET - generated sequence number';
comment on column lads_prc_lst_qua.quaseq is 'QUA - generated sequence number';
comment on column lads_prc_lst_qua.kstbm is 'Condition scale quantity';
comment on column lads_prc_lst_qua.kbetr is 'Rate (condition amount or percentage)';

/**/
/* Primary Key Constraint
/**/
alter table lads_prc_lst_qua
   add constraint lads_prc_lst_qua_pk primary key (vakey, kschl, knumh, datab, detseq, quaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_prc_lst_qua to lads_app;
grant select, insert, update, delete on lads_prc_lst_qua to ics_app;
grant select on lads_prc_lst_qua to site_app;
grant select on lads_prc_lst_qua to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym lads_prc_lst_qua for lads.lads_prc_lst_qua;
