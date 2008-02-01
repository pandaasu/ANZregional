/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_prc_lst_qua
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operational Data Store - sap_prc_lst_qua

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_prc_lst_qua
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
comment on table sap_prc_lst_qua is 'ODS Price List Quantity';
comment on column sap_prc_lst_qua.vakey is 'Variable key 50 bytes';
comment on column sap_prc_lst_qua.kschl is 'Condition type';
comment on column sap_prc_lst_qua.knumh is 'Condition record number';
comment on column sap_prc_lst_qua.datab is 'Valid-From Date';
comment on column sap_prc_lst_qua.detseq is 'DET - generated sequence number';
comment on column sap_prc_lst_qua.quaseq is 'QUA - generated sequence number';
comment on column sap_prc_lst_qua.kstbm is 'Condition scale quantity';
comment on column sap_prc_lst_qua.kbetr is 'Rate (condition amount or percentage)';

/**/
/* Primary Key Constraint
/**/
alter table sap_prc_lst_qua
   add constraint sap_prc_lst_qua_pk primary key (vakey, kschl, knumh, datab, detseq, quaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_prc_lst_qua to ods_app;
grant select on sap_prc_lst_qua to lics_app;
grant select on sap_prc_lst_qua to appsupport;
grant select on sap_prc_lst_qua to ods_select;

/**/
/* Synonym
/**/
create or replace public synonym sap_prc_lst_qua for ods.sap_prc_lst_qua;
