/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_cdpos
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Change Data Audit Trail Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_cdpos
   (sap_environment                              varchar2(10 char)                   not null,
    sap_object                                   varchar2(15 char)                   not null,
    sap_date                                     varchar2(8 char)                    not null,
    mandant                                      varchar2(3 char)                    null,
    objectclas                                   varchar2(15 char)                   null,
    objectid                                     varchar2(90 char)                   null,
    changenr                                     varchar2(10 char)                   null,
    tabname                                      varchar2(30 char)                   null,
    tabkey                                       varchar2(70 char)                   null,
    fname                                        varchar2(30 char)                   null,
    chngind                                      varchar2(1 char)                    null,
    text_case                                    varchar2(1 char)                    null,
    unit_old                                     varchar2(3 char)                    null,
    unit_new                                     varchar2(3 char)                    null,
    cuky_old                                     varchar2(5 char)                    null,
    cuky_new                                     varchar2(5 char)                    null,
    value_new                                    varchar2(254 char)                  null,
    value_old                                    varchar2(254 char)                  null);

/**/
/* Comments
/**/
comment on table sap_cdpos is 'SAP Change Data Audit Trail Detail';
comment on column sap_cdpos.sap_environment is 'SAP environment';
comment on column sap_cdpos.sap_object is 'SAP object';
comment on column sap_cdpos.sap_date is 'SAP date';
comment on column sap_cdpos.mandant is 'Client';
comment on column sap_cdpos.objectclas is 'Object classification';
comment on column sap_cdpos.objectid is 'Object identifier';
comment on column sap_cdpos.changenr is 'Change number';
comment on column sap_cdpos.tabname is 'Table name';
comment on column sap_cdpos.tabkey is 'Table key';
comment on column sap_cdpos.fname is 'Field name';
comment on column sap_cdpos.chngind is 'Change indicator';
comment on column sap_cdpos.text_case is 'Text case';
comment on column sap_cdpos.unit_old is 'Old unit';
comment on column sap_cdpos.unit_new is 'New unit';
comment on column sap_cdpos.cuky_old is 'Old CUKY';
comment on column sap_cdpos.cuky_new is 'New CUKY';
comment on column sap_cdpos.value_new is 'New value';
comment on column sap_cdpos.value_old is 'Old value';

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_cdpos to lads_app;
grant select, insert, update, delete on sap_cdpos to ics_app;
grant select on sap_cdpos to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym sap_cdpos for lads.sap_cdpos;