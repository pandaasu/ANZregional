/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : sap_cdhdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - SAP Change Data Audit Trail Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_cdhdr
   (sap_environment                              varchar2(10 char)                   not null,
    sap_object                                   varchar2(15 char)                   not null,
    sap_date                                     varchar2(8 char)                    not null,
    mandant                                      varchar2(3 char)                    null,
    objectclas                                   varchar2(15 char)                   null,
    objectid                                     varchar2(90 char)                   null,
    changenr                                     varchar2(10 char)                   null,
    username                                     varchar2(12 char)                   null,
    udate                                        varchar2(8 char)                    null,
    utime                                        varchar2(8 char)                    null,
    tcode                                        varchar2(20 char)                   null,
    planchngnr                                   varchar2(12 char)                   null,
    act_chngno                                   varchar2(10 char)                   null,
    was_plannd                                   varchar2(1 char)                    null,
    change_ind                                   varchar2(1 char)                    null,
    langu                                        varchar2(2 char)                    null,
    version                                      varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table sap_cdhdr is 'SAP Change Data Audit Trail Header';
comment on column sap_cdhdr.sap_environment is 'SAP environment';
comment on column sap_cdhdr.sap_object is 'SAP object';
comment on column sap_cdhdr.sap_date is 'SAP date';
comment on column sap_cdhdr.mandant is 'Client';
comment on column sap_cdhdr.objectclas is 'Object classification';
comment on column sap_cdhdr.objectid is 'Object identifier';
comment on column sap_cdhdr.changenr is 'Change number';
comment on column sap_cdhdr.username is 'Change user name';
comment on column sap_cdhdr.udate is 'Change date';
comment on column sap_cdhdr.utime is 'Change time';
comment on column sap_cdhdr.tcode is 'Transaction code';
comment on column sap_cdhdr.planchngnr is 'Planned change number';
comment on column sap_cdhdr.act_chngno is 'Actual change number';
comment on column sap_cdhdr.was_plannd is 'Was planned';
comment on column sap_cdhdr.change_ind is 'Change identifier';
comment on column sap_cdhdr.langu is 'Language';
comment on column sap_cdhdr.version is 'Version';

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_cdhdr to lads_app;
grant select, insert, update, delete on sap_cdhdr to ics_app;
grant select on sap_cdhdr to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym sap_cdhdr for lads.sap_cdhdr;
