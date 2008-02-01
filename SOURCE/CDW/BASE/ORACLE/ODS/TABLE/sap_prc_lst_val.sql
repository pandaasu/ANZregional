/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_prc_lst_val
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operational Data Store - sap_prc_lst_val

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_prc_lst_val
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
comment on table sap_prc_lst_val is 'ODS Price List Value';
comment on column sap_prc_lst_val.vakey is 'Variable key 50 bytes';
comment on column sap_prc_lst_val.kschl is 'Condition type';
comment on column sap_prc_lst_val.knumh is 'Condition record number';
comment on column sap_prc_lst_val.datab is 'Valid-From Date';
comment on column sap_prc_lst_val.detseq is 'DET - generated sequence number';
comment on column sap_prc_lst_val.valseq is 'VAL - generated sequence number';
comment on column sap_prc_lst_val.kstbw is 'Condition scale quantity';
comment on column sap_prc_lst_val.kbetr is 'Rate (condition amount or percentage)';

/**/
/* Primary Key Constraint
/**/
alter table sap_prc_lst_val
   add constraint sap_prc_lst_val_pk primary key (vakey, kschl, knumh, datab, detseq, valseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_prc_lst_val to ods_app;
grant select on sap_prc_lst_val to lics_app;
grant select on sap_prc_lst_val to appsupport;
grant select on sap_prc_lst_val to ods_select;

/**/
/* Synonym
/**/
create or replace public synonym sap_prc_lst_val for ods.sap_prc_lst_val;
