/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dad
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dad

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dad
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    dadseq                                       number                              not null,
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
comment on table lads_shp_dad is 'LADS Shipment Delivery Address';
comment on column lads_shp_dad.tknum is 'Shipment Number';
comment on column lads_shp_dad.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dad.dadseq is 'DAD - generated sequence number';
comment on column lads_shp_dad.partner_q is 'Qualifier for partner function';
comment on column lads_shp_dad.address_t is 'Addr. type';
comment on column lads_shp_dad.partner_id is 'Partner no. (SAP)';
comment on column lads_shp_dad.jurisdic is 'Location for tax calculation - Tax Jurisdiction Code';
comment on column lads_shp_dad.language is 'Language key';
comment on column lads_shp_dad.formofaddr is 'Form of address';
comment on column lads_shp_dad.name1 is 'Name or address line';
comment on column lads_shp_dad.name2 is 'Name or address line';
comment on column lads_shp_dad.name3 is 'Name or address line';
comment on column lads_shp_dad.name4 is 'Name or address line';
comment on column lads_shp_dad.name_text is 'Name or address line (formatted)';
comment on column lads_shp_dad.name_co is 'Subsequent line for name or address (c/o)';
comment on column lads_shp_dad.location is 'Location description of location';
comment on column lads_shp_dad.building is 'Location description: Building';
comment on column lads_shp_dad.floor is 'Location description: Floor';
comment on column lads_shp_dad.room is 'Location description: Room';
comment on column lads_shp_dad.street1 is 'House number and street';
comment on column lads_shp_dad.street2 is 'House number and street';
comment on column lads_shp_dad.street3 is 'House number and street';
comment on column lads_shp_dad.house_supl is 'House number';
comment on column lads_shp_dad.house_rang is 'House no. (interval)';
comment on column lads_shp_dad.postl_cod1 is 'Postal code';
comment on column lads_shp_dad.postl_cod3 is 'Postal code';
comment on column lads_shp_dad.postl_area is 'Post delivery district';
comment on column lads_shp_dad.city1 is 'Town or city';
comment on column lads_shp_dad.city2 is 'Town or city';
comment on column lads_shp_dad.postl_pbox is 'PO Box';
comment on column lads_shp_dad.postl_cod2 is 'Postal code';
comment on column lads_shp_dad.postl_city is 'Town or city';
comment on column lads_shp_dad.telephone1 is 'Telephone number';
comment on column lads_shp_dad.telephone2 is 'Telephone number';
comment on column lads_shp_dad.telefax is 'Fax number';
comment on column lads_shp_dad.telex is 'Telex number';
comment on column lads_shp_dad.e_mail is 'E-Mail Address';
comment on column lads_shp_dad.country1 is 'Country indicator (ISO alphanumeric)';
comment on column lads_shp_dad.country2 is 'Country indicator (ISO numeric)';
comment on column lads_shp_dad.region is '"Region, state"';
comment on column lads_shp_dad.county_cod is 'County Code (e.g. in USA)';
comment on column lads_shp_dad.county_txt is '"County name (for example, in USA)"';
comment on column lads_shp_dad.tzcode is 'Location for time zone (SAP code)';
comment on column lads_shp_dad.tzdesc is 'Location for time zone (external code)';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dad
   add constraint lads_shp_dad_pk primary key (tknum, dlvseq, dadseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dad to lads_app;
grant select, insert, update, delete on lads_shp_dad to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dad for lads.lads_shp_dad;
