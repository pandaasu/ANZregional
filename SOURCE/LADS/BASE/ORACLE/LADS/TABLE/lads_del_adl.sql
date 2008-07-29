/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_adl
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_adl

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_adl
   (vbeln                                        varchar2(10 char)                   not null,
    addseq                                       number                              not null,
    adlseq                                       number                              not null,
    nation                                       varchar2(1 char)                    null,
    name1                                        varchar2(40 char)                   null,
    name2                                        varchar2(40 char)                   null,
    name3                                        varchar2(40 char)                   null,
    name4                                        varchar2(40 char)                   null,
    name_txt                                     varchar2(50 char)                   null,
    name_co                                      varchar2(40 char)                   null,
    city1                                        varchar2(40 char)                   null,
    city2                                        varchar2(40 char)                   null,
    city_code                                    varchar2(12 char)                   null,
    cityp_code                                   varchar2(8 char)                    null,
    home_city                                    varchar2(40 char)                   null,
    cityh_code                                   varchar2(12 char)                   null,
    chckstatus                                   varchar2(1 char)                    null,
    regiogroup                                   varchar2(8 char)                    null,
    post_code1                                   varchar2(10 char)                   null,
    post_code2                                   varchar2(10 char)                   null,
    post_code3                                   varchar2(10 char)                   null,
    pcode1_ext                                   varchar2(10 char)                   null,
    pcode2_ext                                   varchar2(10 char)                   null,
    pcode3_ext                                   varchar2(10 char)                   null,
    po_box                                       varchar2(10 char)                   null,
    po_box_num                                   varchar2(1 char)                    null,
    po_box_loc                                   varchar2(40 char)                   null,
    city_code2                                   varchar2(12 char)                   null,
    po_box_reg                                   varchar2(3 char)                    null,
    po_box_cty                                   varchar2(3 char)                    null,
    postalarea                                   varchar2(15 char)                   null,
    street                                       varchar2(60 char)                   null,
    streetcode                                   varchar2(12 char)                   null,
    streetabbr                                   varchar2(2 char)                    null,
    house_num1                                   varchar2(10 char)                   null,
    house_num2                                   varchar2(10 char)                   null,
    house_num3                                   varchar2(10 char)                   null,
    str_suppl1                                   varchar2(40 char)                   null,
    str_suppl2                                   varchar2(40 char)                   null,
    str_suppl3                                   varchar2(40 char)                   null,
    location                                     varchar2(40 char)                   null,
    building                                     varchar2(20 char)                   null,
    floor                                        varchar2(10 char)                   null,
    country                                      varchar2(3 char)                    null,
    region                                       varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_del_adl is 'LADS Delivery Address Additional';
comment on column lads_del_adl.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_adl.addseq is 'ADD - generated sequence number';
comment on column lads_del_adl.adlseq is 'ADL - generated sequence number';
comment on column lads_del_adl.nation is 'International address version ID';
comment on column lads_del_adl.name1 is 'Name 1';
comment on column lads_del_adl.name2 is 'Name 2';
comment on column lads_del_adl.name3 is 'Name 3';
comment on column lads_del_adl.name4 is 'Name 4';
comment on column lads_del_adl.name_txt is 'Converted name field (with form of address)';
comment on column lads_del_adl.name_co is 'c/o name';
comment on column lads_del_adl.city1 is 'City';
comment on column lads_del_adl.city2 is 'District';
comment on column lads_del_adl.city_code is 'City code for city/street file';
comment on column lads_del_adl.cityp_code is 'District code for City and Street file';
comment on column lads_del_adl.home_city is 'City (different from postal city)';
comment on column lads_del_adl.cityh_code is 'Different city for city/street file';
comment on column lads_del_adl.chckstatus is 'City file test status';
comment on column lads_del_adl.regiogroup is 'Regional structure grouping';
comment on column lads_del_adl.post_code1 is 'City postal code';
comment on column lads_del_adl.post_code2 is 'PO Box postal code';
comment on column lads_del_adl.post_code3 is 'Company postal code (for large customers)';
comment on column lads_del_adl.pcode1_ext is '"City postal code extension, e.g. ZIP+4+2 code"';
comment on column lads_del_adl.pcode2_ext is '"PO Box postal code extension, e.g. ZIP+4+2 code"';
comment on column lads_del_adl.pcode3_ext is '"Major customer postal code extension, e.g. ZIP+4+2 code"';
comment on column lads_del_adl.po_box is 'PO Box';
comment on column lads_del_adl.po_box_num is 'Flag: PO Box without number';
comment on column lads_del_adl.po_box_loc is 'PO Box city';
comment on column lads_del_adl.city_code2 is 'City PO box code (City file)';
comment on column lads_del_adl.po_box_reg is '"Region for PO Box (Country, State, Province, ...)"';
comment on column lads_del_adl.po_box_cty is 'PO box country';
comment on column lads_del_adl.postalarea is 'Post delivery district';
comment on column lads_del_adl.street is 'Street';
comment on column lads_del_adl.streetcode is 'Street code for city/street file';
comment on column lads_del_adl.streetabbr is 'Abbreviation of street name (e.g in Spain)';
comment on column lads_del_adl.house_num1 is 'House Number';
comment on column lads_del_adl.house_num2 is 'House number supplement';
comment on column lads_del_adl.house_num3 is 'House number range';
comment on column lads_del_adl.str_suppl1 is 'Street 2';
comment on column lads_del_adl.str_suppl2 is 'Street 3';
comment on column lads_del_adl.str_suppl3 is 'Street 4';
comment on column lads_del_adl.location is 'Street 5';
comment on column lads_del_adl.building is 'Building (Number or Code)';
comment on column lads_del_adl.floor is 'Floor in building';
comment on column lads_del_adl.country is 'Country Key';
comment on column lads_del_adl.region is '"Region (State, Province, County)"';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_adl
   add constraint lads_del_adl_pk primary key (vbeln, addseq, adlseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_adl to lads_app;
grant select, insert, update, delete on lads_del_adl to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_adl for lads.lads_del_adl;
