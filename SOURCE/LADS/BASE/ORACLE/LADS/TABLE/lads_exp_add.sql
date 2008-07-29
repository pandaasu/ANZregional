/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_add
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_add

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_add
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    addseq                                       number                              not null,
    partner_q                                    varchar2(3 char)                    null,
    address_t                                    varchar2(1 char)                    null,
    partner_id                                   varchar2(17 char)                   null,
    jurisdic                                     varchar2(15 char)                   null,
    language                                     varchar2(2 char)                    null,
    formofaddr                                   varchar2(15 char)                   null,
    name1                                        varchar2(40 char)                   null,
    name2                                        varchar2(40 char)                   null,
    name3                                        varchar2(40 char)                   null,
    name4                                        varchar2(40 char)                   null,
    name_text                                    varchar2(50 char)                   null,
    name_co                                      varchar2(40 char)                   null,
    location                                     varchar2(40 char)                   null,
    building                                     varchar2(10 char)                   null,
    floor                                        varchar2(10 char)                   null,
    room                                         varchar2(10 char)                   null,
    street1                                      varchar2(40 char)                   null,
    street2                                      varchar2(40 char)                   null,
    street3                                      varchar2(40 char)                   null,
    house_supl                                   varchar2(4 char)                    null,
    house_rang                                   varchar2(10 char)                   null,
    postl_cod1                                   varchar2(10 char)                   null,
    postl_cod3                                   varchar2(10 char)                   null,
    postl_area                                   varchar2(15 char)                   null,
    city1                                        varchar2(40 char)                   null,
    city2                                        varchar2(40 char)                   null,
    postl_pbox                                   varchar2(10 char)                   null,
    postl_cod2                                   varchar2(10 char)                   null,
    postl_city                                   varchar2(40 char)                   null,
    telephone1                                   varchar2(30 char)                   null,
    telephone2                                   varchar2(30 char)                   null,
    telefax                                      varchar2(30 char)                   null,
    telex                                        varchar2(30 char)                   null,
    e_mail                                       varchar2(70 char)                   null,
    country1                                     varchar2(3 char)                    null,
    country2                                     varchar2(3 char)                    null,
    region                                       varchar2(3 char)                    null,
    county_cod                                   varchar2(3 char)                    null,
    county_txt                                   varchar2(25 char)                   null,
    tzcode                                       varchar2(6 char)                    null,
    tzdesc                                       varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_add is 'Generic ICB Document - Delivery data';
comment on column lads_exp_add.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_add.delseq is 'DEL - generated sequence number';
comment on column lads_exp_add.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_add.addseq is 'ADD - generated sequence number';
comment on column lads_exp_add.partner_q is 'Qualifier for partner function';
comment on column lads_exp_add.address_t is 'Addr. type';
comment on column lads_exp_add.partner_id is 'Partner no. (SAP)';
comment on column lads_exp_add.jurisdic is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_exp_add.language is 'Language key';
comment on column lads_exp_add.formofaddr is 'Form of address';
comment on column lads_exp_add.name1 is 'Name or address line';
comment on column lads_exp_add.name2 is 'Name or address line';
comment on column lads_exp_add.name3 is 'Name or address line';
comment on column lads_exp_add.name4 is 'Name or address line';
comment on column lads_exp_add.name_text is 'Name or address line (formatted)';
comment on column lads_exp_add.name_co is 'Subsequent line for name or address (c/o)';
comment on column lads_exp_add.location is 'Location description of location';
comment on column lads_exp_add.building is 'Location description: Building';
comment on column lads_exp_add.floor is 'Location description: Floor';
comment on column lads_exp_add.room is 'Location description: Room';
comment on column lads_exp_add.street1 is 'House number and street';
comment on column lads_exp_add.street2 is 'House number and street';
comment on column lads_exp_add.street3 is 'House number and street';
comment on column lads_exp_add.house_supl is 'House number';
comment on column lads_exp_add.house_rang is 'House no. (interval)';
comment on column lads_exp_add.postl_cod1 is 'Postal code';
comment on column lads_exp_add.postl_cod3 is 'Postal code';
comment on column lads_exp_add.postl_area is 'Post delivery district';
comment on column lads_exp_add.city1 is 'Town or city';
comment on column lads_exp_add.city2 is 'Town or city';
comment on column lads_exp_add.postl_pbox is 'PO Box';
comment on column lads_exp_add.postl_cod2 is 'Postal code';
comment on column lads_exp_add.postl_city is 'Town or city';
comment on column lads_exp_add.telephone1 is 'Telephone number';
comment on column lads_exp_add.telephone2 is 'Telephone number';
comment on column lads_exp_add.telefax is 'Fax number';
comment on column lads_exp_add.telex is 'Telex number';
comment on column lads_exp_add.e_mail is 'E-Mail Address';
comment on column lads_exp_add.country1 is 'Country indicator (ISO alphanumeric)';
comment on column lads_exp_add.country2 is 'Country indicator (ISO numeric)';
comment on column lads_exp_add.region is '"Region, state"';
comment on column lads_exp_add.county_cod is 'County Code (e.g. in USA)';
comment on column lads_exp_add.county_txt is '"County name (for example, in USA)"';
comment on column lads_exp_add.tzcode is 'Location for time zone (SAP code)';
comment on column lads_exp_add.tzdesc is 'Location for time zone (external code)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_add
   add constraint lads_exp_add_pk primary key (zzgrpnr, delseq, hdeseq, addseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_add to lads_app;
grant select, insert, update, delete on lads_exp_add to ics_app;
grant select on lads_exp_add to ics_reader with grant option;
grant select on lads_exp_add to ics_executor;
grant select on lads_exp_add to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_add for lads.lads_exp_add;
