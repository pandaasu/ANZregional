/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_val_sta
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Validation Statistic

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_val_sta
   (vas_group                                    varchar2(30 char)                   not null,
    vas_statistic                                varchar2(30 char)                   not null,
    vas_identifier                               varchar2(30 char)                   not null,
    vas_description                              varchar2(128 char)                  not null,
    vas_missing                                  number                              not null,
    vas_error                                    number                              not null,
    vas_valid                                    number                              not null,
    vas_message                                  number                              not null);

/**/
/* Comments
/**/
comment on table sap_val_sta is 'SAP Validation Statistic';
comment on column sap_val_sta.vas_group is 'Validation statistic group';
comment on column sap_val_sta.vas_statistic is 'Validation statistic code';
comment on column sap_val_sta.vas_identifier is 'Validation statistic identifier';
comment on column sap_val_sta.vas_description is 'Validation statistic description';
comment on column sap_val_sta.vas_missing is 'Validation statistic missing count';
comment on column sap_val_sta.vas_error is 'Validation statistic error count';
comment on column sap_val_sta.vas_valid is 'Validation statistic valid count';
comment on column sap_val_sta.vas_message is 'Validation statistic message count';

/**/
/* Primary Key Constraint
/**/
alter table sap_val_sta
   add constraint sap_val_sta_pk primary key (vas_group, vas_statistic, vas_identifier);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_val_sta to lads_app;
grant select on sap_val_sta to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_val_sta for lads.sap_val_sta;
