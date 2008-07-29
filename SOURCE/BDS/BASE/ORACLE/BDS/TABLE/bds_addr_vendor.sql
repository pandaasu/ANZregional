/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_vendor
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Vendor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_vendor
   (vendor_code                        varchar2(10 char)        not null,
    address_version                    varchar2(5 char)         not null,
    valid_from_date                    date                     not null,
    valid_to_date                      date                     not null,
    title                              varchar2(4 char)         null,
    name                               varchar2(40 char)        null,
    name_02                            varchar2(40 char)        null,
    name_03                            varchar2(40 char)        null,
    name_04                            varchar2(40 char)        null,
    city                               varchar2(40 char)        null,
    district                           varchar2(40 char)        null,
    city_post_code                     varchar2(10 char)        null,
    po_box_post_code                   varchar2(10 char)        null,
    company_post_code                  varchar2(10 char)        null,
    po_box                             varchar2(10 char)        null,
    po_box_minus_number                varchar2(1 char)         null,
    po_box_city                        varchar2(40 char)        null,
    po_box_region                      varchar2(3 char)         null,
    po_box_country                     varchar2(3 char)         null,
    po_box_country_iso                 varchar2(2 char)         null,
    transportation_zone                varchar2(10 char)        null,
    street                             varchar2(60 char)        null,
    house_number                       varchar2(10 char)        null,
    location                           varchar2(40 char)        null,
    building                           varchar2(20 char)        null,
    floor                              varchar2(10 char)        null,
    room_number                        varchar2(10 char)        null,
    country                            varchar2(3 char)         null,
    country_iso                        varchar2(2 char)         null,
    language                           varchar2(1 char)         null,
    language_iso                       varchar2(2 char)         null,
    region_code                        varchar2(3 char)         null,
    search_term_01                     varchar2(20 char)        null,
    search_term_02                     varchar2(20 char)        null,
    phone_number                       varchar2(30 char)        null,
    phone_extension                    varchar2(10 char)        null,
    phone_full_number                  varchar2(30 char)        null,
    fax_number                         varchar2(30 char)        null,
    fax_extension                      varchar2(10 char)        null,
    fax_full_number                    varchar2(30 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_vendor is 'Business Data Store - Address Vendor';
comment on column bds_addr_vendor.vendor_code is 'Vendor code - lads_adr_det.obj_id';
comment on column bds_addr_vendor.address_version is 'International address version ID - lads_adr_det.addr_vers';
comment on column bds_addr_vendor.valid_from_date is 'Date valid from - lads_adr_det.from_date';
comment on column bds_addr_vendor.valid_to_date is 'Valid-to date - lads_adr_det.to_date';
comment on column bds_addr_vendor.title is 'Form-of-Address Key - lads_adr_det.title';
comment on column bds_addr_vendor.name is 'Name 1 - lads_adr_det.name';
comment on column bds_addr_vendor.name_02 is 'Name 2 - lads_adr_det.name_2';
comment on column bds_addr_vendor.name_03 is 'Name 3 - lads_adr_det.name_3';
comment on column bds_addr_vendor.name_04 is 'Name 4 - lads_adr_det.name_4';
comment on column bds_addr_vendor.city is 'City - lads_adr_det.city';
comment on column bds_addr_vendor.district is 'District - lads_adr_det.district';
comment on column bds_addr_vendor.city_post_code is 'City postal code - lads_adr_det.postl_cod1';
comment on column bds_addr_vendor.po_box_post_code is 'PO Box postal code - lads_adr_det.postl_cod2';
comment on column bds_addr_vendor.company_post_code is 'Company postal code (for large customers) - lads_adr_det.postl_cod3';
comment on column bds_addr_vendor.po_box is 'PO Box - lads_adr_det.po_box';
comment on column bds_addr_vendor.po_box_minus_number is 'Flag: PO Box without number - lads_adr_det.po_w_o_no';
comment on column bds_addr_vendor.po_box_city is 'PO Box city - lads_adr_det.po_box_cit';
comment on column bds_addr_vendor.po_box_region is '''Region for PO Box (Country, State, Province, ...)'' - lads_adr_det.po_box_reg';
comment on column bds_addr_vendor.po_box_country is 'PO box country - lads_adr_det.pobox_ctry';
comment on column bds_addr_vendor.po_box_country_iso is 'Country ISO code - lads_adr_det.po_ctryiso';
comment on column bds_addr_vendor.transportation_zone is 'Transportation zone to or from which the goods are delivered - lads_adr_det.transpzone';
comment on column bds_addr_vendor.street is 'Street - lads_adr_det.street';
comment on column bds_addr_vendor.house_number is 'House Number - lads_adr_det.house_no';
comment on column bds_addr_vendor.location is 'Street 5 - lads_adr_det.location';
comment on column bds_addr_vendor.building is 'Building (Number or Code) - lads_adr_det.building';
comment on column bds_addr_vendor.floor is 'Floor in building - lads_adr_det.floor';
comment on column bds_addr_vendor.room_number is 'Room or Appartment Number - lads_adr_det.room_no';
comment on column bds_addr_vendor.country is 'Country Key - lads_adr_det.country';
comment on column bds_addr_vendor.country_iso is 'Country ISO code - lads_adr_det.countryiso';
comment on column bds_addr_vendor.language is 'Language Key - lads_adr_det.langu';
comment on column bds_addr_vendor.language_iso is 'Language according to ISO 639 - lads_adr_det.langu_iso';
comment on column bds_addr_vendor.region_code is '''Region (State, Province, County)'' - lads_adr_det.region';
comment on column bds_addr_vendor.search_term_01 is 'Search term 1 - lads_adr_det.sort1';
comment on column bds_addr_vendor.search_term_02 is 'Search term 2 - lads_adr_det.sort2';
comment on column bds_addr_vendor.phone_number is 'Telephone no.: dialling code+number - lads_adr_tel.telephone';
comment on column bds_addr_vendor.phone_extension is 'Telephone no.: Extension - lads_adr_tel.extension';
comment on column bds_addr_vendor.phone_full_number is 'Complete number: dialling code+number+extension - lads_adr_tel.tel_no';
comment on column bds_addr_vendor.fax_number is 'Fax number: dialling code+number - lads_adr_fax.fax';
comment on column bds_addr_vendor.fax_extension is 'Fax no.: Extension - lads_adr_fax.extension';
comment on column bds_addr_vendor.fax_full_number is 'Complete number: dialling code+number+extension - lads_adr_fax.fax_no';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_vendor
   add constraint bds_addr_vendor_pk primary key (vendor_code, address_version, valid_from_date, valid_to_date);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_vendor to lics_app;
grant select, insert, update, delete on bds_addr_vendor to lads_app;
grant select, insert, update, delete on bds_addr_vendor to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_vendor for bds.bds_addr_vendor;