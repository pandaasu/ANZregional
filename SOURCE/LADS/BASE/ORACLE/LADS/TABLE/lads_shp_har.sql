/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_har
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_har

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_har
   (tknum                                        varchar2(10 char)                   not null,
    harseq                                       number                              not null,
    partner_q                                    varchar2(3 char)                    null,
    address_t                                    varchar2(1 char)                    null,
    partner_id                                   varchar2(17 char)                   null,
    jurisdic                                     varchar2(17 char)                   null,
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
comment on table lads_shp_har is 'LADS Shipment Address';
comment on column lads_shp_har.tknum is 'Shipment Number';
comment on column lads_shp_har.harseq is 'HAR - generated sequence number';
comment on column lads_shp_har.partner_q is 'Qualifier for partner function';
comment on column lads_shp_har.address_t is 'Addr. type';
comment on column lads_shp_har.partner_id is 'Partner no. (SAP)';
comment on column lads_shp_har.jurisdic is 'Location for tax calculation - Tax Jurisdiction Code';
comment on column lads_shp_har.language is 'Language key';
comment on column lads_shp_har.formofaddr is 'Form of address';
comment on column lads_shp_har.name1 is 'Name or address line';
comment on column lads_shp_har.name2 is 'Name or address line';
comment on column lads_shp_har.name3 is 'Name or address line';
comment on column lads_shp_har.name4 is 'Name or address line';
comment on column lads_shp_har.name_text is 'Name or address line (formatted)';
comment on column lads_shp_har.name_co is 'Subsequent line for name or address (c/o)';
comment on column lads_shp_har.location is 'Location description of location';
comment on column lads_shp_har.building is 'Location description: Building';
comment on column lads_shp_har.floor is 'Location description: Floor';
comment on column lads_shp_har.room is 'Location description: Room';
comment on column lads_shp_har.street1 is 'House number and street';
comment on column lads_shp_har.street2 is 'House number and street';
comment on column lads_shp_har.street3 is 'House number and street';
comment on column lads_shp_har.house_supl is 'House number';
comment on column lads_shp_har.house_rang is 'House no. (interval)';
comment on column lads_shp_har.postl_cod1 is 'Postal code';
comment on column lads_shp_har.postl_cod3 is 'Postal code';
comment on column lads_shp_har.postl_area is 'Post delivery district';
comment on column lads_shp_har.city1 is 'Town or city';
comment on column lads_shp_har.city2 is 'Town or city';
comment on column lads_shp_har.postl_pbox is 'PO Box';
comment on column lads_shp_har.postl_cod2 is 'Postal code';
comment on column lads_shp_har.postl_city is 'Town or city';
comment on column lads_shp_har.telephone1 is 'Telephone number';
comment on column lads_shp_har.telephone2 is 'Telephone number';
comment on column lads_shp_har.telefax is 'Fax number';
comment on column lads_shp_har.telex is 'Telex number';
comment on column lads_shp_har.e_mail is 'E-Mail Address';
comment on column lads_shp_har.country1 is 'Country indicator (ISO alphanumeric)';
comment on column lads_shp_har.country2 is 'Country indicator (ISO numeric)';
comment on column lads_shp_har.region is '"Region, state"';
comment on column lads_shp_har.county_cod is 'County Code (e.g. in USA)';
comment on column lads_shp_har.county_txt is '"County name (for example, in USA)"';
comment on column lads_shp_har.tzcode is 'Location for time zone (SAP code)';
comment on column lads_shp_har.tzdesc is 'Location for time zone (external code)';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_har
   add constraint lads_shp_har_pk primary key (tknum, harseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_har to lads_app;
grant select, insert, update, delete on lads_shp_har to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_har for lads.lads_shp_har;
