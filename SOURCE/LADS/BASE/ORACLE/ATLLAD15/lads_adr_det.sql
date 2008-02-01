/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_det
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    context                                      number                              not null,
    detseq                                       number                              not null,
    addr_vers                                    varchar2(1 char)                    null,
    from_date                                    varchar2(8 char)                    null,
    to_date                                      varchar2(8 char)                    null,
    title                                        varchar2(4 char)                    null,
    name                                         varchar2(40 char)                   null,
    name_2                                       varchar2(40 char)                   null,
    name_3                                       varchar2(40 char)                   null,
    name_4                                       varchar2(40 char)                   null,
    conv_name                                    varchar2(50 char)                   null,
    c_o_name                                     varchar2(40 char)                   null,
    city                                         varchar2(40 char)                   null,
    district                                     varchar2(40 char)                   null,
    city_no                                      varchar2(12 char)                   null,
    distrct_no                                   varchar2(8 char)                    null,
    chckstatus                                   varchar2(1 char)                    null,
    regiogroup                                   varchar2(8 char)                    null,
    postl_cod1                                   varchar2(10 char)                   null,
    postl_cod2                                   varchar2(10 char)                   null,
    postl_cod3                                   varchar2(10 char)                   null,
    pcode1_ext                                   varchar2(10 char)                   null,
    pcode2_ext                                   varchar2(10 char)                   null,
    pcode3_ext                                   varchar2(10 char)                   null,
    po_box                                       varchar2(10 char)                   null,
    po_w_o_no                                    varchar2(1 char)                    null,
    po_box_cit                                   varchar2(40 char)                   null,
    pboxcit_no                                   varchar2(12 char)                   null,
    po_box_reg                                   varchar2(3 char)                    null,
    pobox_ctry                                   varchar2(3 char)                    null,
    po_ctryiso                                   varchar2(2 char)                    null,
    deliv_dis                                    varchar2(15 char)                   null,
    transpzone                                   varchar2(10 char)                   null,
    street                                       varchar2(60 char)                   null,
    street_no                                    varchar2(12 char)                   null,
    str_abbr                                     varchar2(2 char)                    null,
    house_no                                     varchar2(10 char)                   null,
    house_no2                                    varchar2(10 char)                   null,
    house_no3                                    varchar2(10 char)                   null,
    str_suppl1                                   varchar2(40 char)                   null,
    str_suppl2                                   varchar2(40 char)                   null,
    str_suppl3                                   varchar2(40 char)                   null,
    location                                     varchar2(40 char)                   null,
    building                                     varchar2(20 char)                   null,
    floor                                        varchar2(10 char)                   null,
    room_no                                      varchar2(10 char)                   null,
    country                                      varchar2(3 char)                    null,
    countryiso                                   varchar2(2 char)                    null,
    langu                                        varchar2(1 char)                    null,
    langu_iso                                    varchar2(2 char)                    null,
    region                                       varchar2(3 char)                    null,
    sort1                                        varchar2(20 char)                   null,
    sort2                                        varchar2(20 char)                   null,
    extens_1                                     varchar2(40 char)                   null,
    extens_2                                     varchar2(40 char)                   null,
    time_zone                                    varchar2(6 char)                    null,
    taxjurcode                                   varchar2(15 char)                   null,
    address_id                                   varchar2(10 char)                   null,
    langu_cr                                     varchar2(1 char)                    null,
    langucriso                                   varchar2(2 char)                    null,
    comm_type                                    varchar2(3 char)                    null,
    addr_group                                   varchar2(4 char)                    null,
    home_city                                    varchar2(40 char)                   null,
    homecityno                                   varchar2(12 char)                   null,
    dont_use_s                                   varchar2(4 char)                    null,
    dont_use_p                                   varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_adr_det is 'LADS Address Detail';
comment on column lads_adr_det.obj_type is 'Address owner object type';
comment on column lads_adr_det.obj_id is 'Address owner object ID';
comment on column lads_adr_det.context is 'Semantic description of an object address';
comment on column lads_adr_det.detseq is 'DET - generated sequence number';
comment on column lads_adr_det.addr_vers is 'International address version ID';
comment on column lads_adr_det.from_date is 'Date valid from';
comment on column lads_adr_det.to_date is 'Valid-to date';
comment on column lads_adr_det.title is 'Form-of-Address Key';
comment on column lads_adr_det.name is 'Name 1';
comment on column lads_adr_det.name_2 is 'Name 2';
comment on column lads_adr_det.name_3 is 'Name 3';
comment on column lads_adr_det.name_4 is 'Name 4';
comment on column lads_adr_det.conv_name is 'Converted name field (with form of address)';
comment on column lads_adr_det.c_o_name is 'c/o name';
comment on column lads_adr_det.city is 'City';
comment on column lads_adr_det.district is 'District';
comment on column lads_adr_det.city_no is 'City code for city/street file';
comment on column lads_adr_det.distrct_no is 'District code for City and Street file';
comment on column lads_adr_det.chckstatus is 'City file test status';
comment on column lads_adr_det.regiogroup is 'Regional structure grouping';
comment on column lads_adr_det.postl_cod1 is 'City postal code';
comment on column lads_adr_det.postl_cod2 is 'PO Box postal code';
comment on column lads_adr_det.postl_cod3 is 'Company postal code (for large customers)';
comment on column lads_adr_det.pcode1_ext is '"City postal code extension, e.g. ZIP+4+2 code"';
comment on column lads_adr_det.pcode2_ext is '"PO Box postal code extension, e.g. ZIP+4+2 code"';
comment on column lads_adr_det.pcode3_ext is '"Major customer postal code extension, e.g. ZIP+4+2 code"';
comment on column lads_adr_det.po_box is 'PO Box';
comment on column lads_adr_det.po_w_o_no is 'Flag: PO Box without number';
comment on column lads_adr_det.po_box_cit is 'PO Box city';
comment on column lads_adr_det.pboxcit_no is 'City PO box code (City file)';
comment on column lads_adr_det.po_box_reg is '"Region for PO Box (Country, State, Province, ...)"';
comment on column lads_adr_det.pobox_ctry is 'PO box country';
comment on column lads_adr_det.po_ctryiso is 'Country ISO code';
comment on column lads_adr_det.deliv_dis is 'Post delivery district';
comment on column lads_adr_det.transpzone is 'Transportation zone to or from which the goods are delivered';
comment on column lads_adr_det.street is 'Street';
comment on column lads_adr_det.street_no is 'Street code for city/street file';
comment on column lads_adr_det.str_abbr is 'Abbreviation of street name (e.g in Spain)';
comment on column lads_adr_det.house_no is 'House Number';
comment on column lads_adr_det.house_no2 is 'House number supplement';
comment on column lads_adr_det.house_no3 is 'House number range';
comment on column lads_adr_det.str_suppl1 is 'Street 2';
comment on column lads_adr_det.str_suppl2 is 'Street 3';
comment on column lads_adr_det.str_suppl3 is 'Street 4';
comment on column lads_adr_det.location is 'Street 5';
comment on column lads_adr_det.building is 'Building (Number or Code)';
comment on column lads_adr_det.floor is 'Floor in building';
comment on column lads_adr_det.room_no is 'Room or Appartment Number';
comment on column lads_adr_det.country is 'Country Key';
comment on column lads_adr_det.countryiso is 'Country ISO code';
comment on column lads_adr_det.langu is 'Language Key';
comment on column lads_adr_det.langu_iso is 'Language according to ISO 639';
comment on column lads_adr_det.region is '"Region (State, Province, County)"';
comment on column lads_adr_det.sort1 is 'Search term 1';
comment on column lads_adr_det.sort2 is 'Search term 2';
comment on column lads_adr_det.extens_1 is 'Extension (only for data conversion) (e.g. data line)';
comment on column lads_adr_det.extens_2 is 'Extension (only for data conversion) (e.g. telebox)';
comment on column lads_adr_det.time_zone is 'Address time zone';
comment on column lads_adr_det.taxjurcode is 'Tax jurisdiction code';
comment on column lads_adr_det.address_id is 'Physical address ID';
comment on column lads_adr_det.langu_cr is 'Address record creation original language';
comment on column lads_adr_det.langucriso is 'Language according to ISO 639';
comment on column lads_adr_det.comm_type is 'Communication Method (Key) (Business Address Services)';
comment on column lads_adr_det.addr_group is 'Address Group (Key) (Business Address Services)';
comment on column lads_adr_det.home_city is 'City (different from postal city)';
comment on column lads_adr_det.homecityno is 'Different city for city/street file';
comment on column lads_adr_det.dont_use_s is 'Street Address Undeliverable Flag';
comment on column lads_adr_det.dont_use_p is 'PO Box Address Undeliverable Flag';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_det
   add constraint lads_adr_det_pk primary key (obj_type, obj_id, context, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_det to lads_app;
grant select, insert, update, delete on lads_adr_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_det for lads.lads_adr_det;
