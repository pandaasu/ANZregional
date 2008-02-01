/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_detail
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_detail
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    address_version                    varchar2(5 char)         not null,
    valid_from_date                    date                     not null,
    valid_to_date                      date                     not null,
    title                              varchar2(4 char)         null,
    name                               varchar2(40 char)        null,
    name_02                            varchar2(40 char)        null,
    name_03                            varchar2(40 char)        null,
    name_04                            varchar2(40 char)        null,
    converted_name                     varchar2(50 char)        null,
    c_o_name                           varchar2(40 char)        null,
    city                               varchar2(40 char)        null,
    district                           varchar2(40 char)        null,
    city_code                          varchar2(12 char)        null,
    district_code                      varchar2(8 char)         null,
    city_status                        varchar2(1 char)         null,
    regional_structure_grouping        varchar2(8 char)         null,
    city_post_code                     varchar2(10 char)        null,
    po_box_post_code                   varchar2(10 char)        null,
    company_post_code                  varchar2(10 char)        null,
    city_post_code_extension           varchar2(10 char)        null,
    po_box_post_code_extension         varchar2(10 char)        null,
    company_post_code_extension        varchar2(10 char)        null,
    po_box                             varchar2(10 char)        null,
    po_box_minus_number                varchar2(1 char)         null,
    po_box_city                        varchar2(40 char)        null,
    po_box_city_code                   varchar2(12 char)        null,
    po_box_region                      varchar2(3 char)         null,
    po_box_country                     varchar2(3 char)         null,
    po_box_country_iso                 varchar2(2 char)         null,
    delivery_district                  varchar2(15 char)        null,
    transportation_zone                varchar2(10 char)        null,
    street                             varchar2(60 char)        null,
    street_code                        varchar2(12 char)        null,
    street_abbreviated                 varchar2(2 char)         null,
    house_number                       varchar2(10 char)        null,
    house_number_supplement            varchar2(10 char)        null,
    house_number_range                 varchar2(10 char)        null,
    street_supplement_01               varchar2(40 char)        null,
    street_supplement_02               varchar2(40 char)        null,
    street_supplement_03               varchar2(40 char)        null,
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
    data_extension_01                  varchar2(40 char)        null,
    data_extension_02                  varchar2(40 char)        null,
    time_zone                          varchar2(6 char)         null,
    tax_jurisdiction_code              varchar2(15 char)        null,
    address_identifier                 varchar2(10 char)        null,
    creation_language                  varchar2(1 char)         null,
    language_iso639                    varchar2(2 char)         null,
    communication_type                 varchar2(3 char)         null,
    address_group                      varchar2(4 char)         null,
    home_city                          varchar2(40 char)        null,
    home_city_code                     varchar2(12 char)        null,
    street_undeliverable_flag          varchar2(4 char)         null,
    po_box_undeliverable_flag          varchar2(4 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_detail is 'Business Data Store - Address Detail';
comment on column bds_addr_detail.address_type is 'Address owner object type - lads_adr_det.obj_type';
comment on column bds_addr_detail.address_code is 'Address owner object ID - lads_adr_det.obj_id';
comment on column bds_addr_detail.address_context is 'Semantic description of an object address - lads_adr_det.context';
comment on column bds_addr_detail.address_version is 'International address version ID - lads_adr_det.addr_vers';
comment on column bds_addr_detail.valid_from_date is 'Date valid from - lads_adr_det.from_date';
comment on column bds_addr_detail.valid_to_date is 'Valid-to date - lads_adr_det.to_date';
comment on column bds_addr_detail.title is 'Form-of-Address Key - lads_adr_det.title';
comment on column bds_addr_detail.name is 'Name 1 - lads_adr_det.name';
comment on column bds_addr_detail.name_02 is 'Name 2 - lads_adr_det.name_2';
comment on column bds_addr_detail.name_03 is 'Name 3 - lads_adr_det.name_3';
comment on column bds_addr_detail.name_04 is 'Name 4 - lads_adr_det.name_4';
comment on column bds_addr_detail.converted_name is 'Converted name field (with form of address) - lads_adr_det.conv_name';
comment on column bds_addr_detail.c_o_name is 'c/o name - lads_adr_det.c_o_name';
comment on column bds_addr_detail.city is 'City - lads_adr_det.city';
comment on column bds_addr_detail.district is 'District - lads_adr_det.district';
comment on column bds_addr_detail.city_code is 'City code for city/street file - lads_adr_det.city_no';
comment on column bds_addr_detail.district_code is 'District code for City and Street file - lads_adr_det.distrct_no';
comment on column bds_addr_detail.city_status is 'City file test status - lads_adr_det.chckstatus';
comment on column bds_addr_detail.regional_structure_grouping is 'Regional structure grouping - lads_adr_det.regiogroup';
comment on column bds_addr_detail.city_post_code is 'City postal code - lads_adr_det.postl_cod1';
comment on column bds_addr_detail.po_box_post_code is 'PO Box postal code - lads_adr_det.postl_cod2';
comment on column bds_addr_detail.company_post_code is 'Company postal code (for large customers) - lads_adr_det.postl_cod3';
comment on column bds_addr_detail.city_post_code_extension is '''City postal code extension, e.g. ZIP+4+2 code'' - lads_adr_det.pcode1_ext';
comment on column bds_addr_detail.po_box_post_code_extension is '''PO Box postal code extension, e.g. ZIP+4+2 code'' - lads_adr_det.pcode2_ext';
comment on column bds_addr_detail.company_post_code_extension is '''Major customer postal code extension, e.g. ZIP+4+2 code'' - lads_adr_det.pcode3_ext';
comment on column bds_addr_detail.po_box is 'PO Box - lads_adr_det.po_box';
comment on column bds_addr_detail.po_box_minus_number is 'Flag: PO Box without number - lads_adr_det.po_w_o_no';
comment on column bds_addr_detail.po_box_city is 'PO Box city - lads_adr_det.po_box_cit';
comment on column bds_addr_detail.po_box_city_code is 'City PO box code (City file) - lads_adr_det.pboxcit_no';
comment on column bds_addr_detail.po_box_region is '''Region for PO Box (Country, State, Province, ...)'' - lads_adr_det.po_box_reg';
comment on column bds_addr_detail.po_box_country is 'PO box country - lads_adr_det.pobox_ctry';
comment on column bds_addr_detail.po_box_country_iso is 'Country ISO code - lads_adr_det.po_ctryiso';
comment on column bds_addr_detail.delivery_district is 'Post delivery district - lads_adr_det.deliv_dis';
comment on column bds_addr_detail.transportation_zone is 'Transportation zone to or from which the goods are delivered - lads_adr_det.transpzone';
comment on column bds_addr_detail.street is 'Street - lads_adr_det.street';
comment on column bds_addr_detail.street_code is 'Street code for city/street file - lads_adr_det.street_no';
comment on column bds_addr_detail.street_abbreviated is 'Abbreviation of street name (e.g in Spain) - lads_adr_det.str_abbr';
comment on column bds_addr_detail.house_number is 'House Number - lads_adr_det.house_no';
comment on column bds_addr_detail.house_number_supplement is 'House number supplement - lads_adr_det.house_no2';
comment on column bds_addr_detail.house_number_range is 'House number range - lads_adr_det.house_no3';
comment on column bds_addr_detail.street_supplement_01 is 'Street 2 - lads_adr_det.str_suppl1';
comment on column bds_addr_detail.street_supplement_02 is 'Street 3 - lads_adr_det.str_suppl2';
comment on column bds_addr_detail.street_supplement_03 is 'Street 4 - lads_adr_det.str_suppl3';
comment on column bds_addr_detail.location is 'Street 5 - lads_adr_det.location';
comment on column bds_addr_detail.building is 'Building (Number or Code) - lads_adr_det.building';
comment on column bds_addr_detail.floor is 'Floor in building - lads_adr_det.floor';
comment on column bds_addr_detail.room_number is 'Room or Appartment Number - lads_adr_det.room_no';
comment on column bds_addr_detail.country is 'Country Key - lads_adr_det.country';
comment on column bds_addr_detail.country_iso is 'Country ISO code - lads_adr_det.countryiso';
comment on column bds_addr_detail.language is 'Language Key - lads_adr_det.langu';
comment on column bds_addr_detail.language_iso is 'Language according to ISO 639 - lads_adr_det.langu_iso';
comment on column bds_addr_detail.region_code is '''Region (State, Province, County)'' - lads_adr_det.region';
comment on column bds_addr_detail.search_term_01 is 'Search term 1 - lads_adr_det.sort1';
comment on column bds_addr_detail.search_term_02 is 'Search term 2 - lads_adr_det.sort2';
comment on column bds_addr_detail.data_extension_01 is 'Extension (only for data conversion) (e.g. data line) - lads_adr_det.extens_1';
comment on column bds_addr_detail.data_extension_02 is 'Extension (only for data conversion) (e.g. telebox) - lads_adr_det.extens_2';
comment on column bds_addr_detail.time_zone is 'Address time zone - lads_adr_det.time_zone';
comment on column bds_addr_detail.tax_jurisdiction_code is 'Tax jurisdiction code - lads_adr_det.taxjurcode';
comment on column bds_addr_detail.address_identifier is 'Physical address ID - lads_adr_det.address_id';
comment on column bds_addr_detail.creation_language is 'Address record creation original language - lads_adr_det.langu_cr';
comment on column bds_addr_detail.language_iso639 is 'Language according to ISO 639 - lads_adr_det.langucriso';
comment on column bds_addr_detail.communication_type is 'Communication Method (Key) (Business Address Services) - lads_adr_det.comm_type';
comment on column bds_addr_detail.address_group is 'Address Group (Key) (Business Address Services) - lads_adr_det.addr_group';
comment on column bds_addr_detail.home_city is 'City (different from postal city) - lads_adr_det.home_city';
comment on column bds_addr_detail.home_city_code is 'Different city for city/street file - lads_adr_det.homecityno';
comment on column bds_addr_detail.street_undeliverable_flag is 'Street Address Undeliverable Flag - lads_adr_det.dont_use_s';
comment on column bds_addr_detail.po_box_undeliverable_flag is 'PO Box Address Undeliverable Flag - lads_adr_det.dont_use_p';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_detail
   add constraint bds_addr_detail_pk primary key (address_type, address_code, address_context, address_version, valid_from_date, valid_to_date);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_detail to lics_app;
grant select, insert, update, delete on bds_addr_detail to lads_app;
grant select, insert, update, delete on bds_addr_detail to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_detail for bds.bds_addr_detail;