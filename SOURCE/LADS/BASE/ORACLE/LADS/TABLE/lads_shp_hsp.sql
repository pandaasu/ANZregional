/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hsp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hsp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hsp
   (tknum                                        varchar2(10 char)                   not null,
    hstseq                                       number                              not null,
    hspseq                                       number                              not null,
    quali                                        varchar2(3 char)                    null,
    knote                                        varchar2(10 char)                   null,
    adrnr                                        varchar2(10 char)                   null,
    vstel                                        varchar2(4 char)                    null,
    lstel                                        varchar2(2 char)                    null,
    werks                                        varchar2(4 char)                    null,
    lgort                                        varchar2(4 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    lifnr                                        varchar2(10 char)                   null,
    ablad                                        varchar2(25 char)                   null,
    lgnum                                        varchar2(3 char)                    null,
    lgtor                                        varchar2(3 char)                    null,
    bahnra                                       varchar2(10 char)                   null,
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
    tzdesc                                       varchar2(35 char)                   null,
    knote_bez                                    varchar2(30 char)                   null,
    vstel_bez                                    varchar2(30 char)                   null,
    lstel_bez                                    varchar2(20 char)                   null,
    werks_bez                                    varchar2(30 char)                   null,
    lgort_bez                                    varchar2(16 char)                   null,
    lgnum_bez                                    varchar2(25 char)                   null,
    lgtor_bez                                    varchar2(25 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_hsp is 'LADS Shipment Stage Point';
comment on column lads_shp_hsp.tknum is 'Shipment Number';
comment on column lads_shp_hsp.hstseq is 'HST - generated sequence number';
comment on column lads_shp_hsp.hspseq is 'HSP - generated sequence number';
comment on column lads_shp_hsp.quali is 'Qualifier for stage point';
comment on column lads_shp_hsp.knote is 'Transportation Connection Points';
comment on column lads_shp_hsp.adrnr is 'Address';
comment on column lads_shp_hsp.vstel is 'Shipping Point/Receiving Point';
comment on column lads_shp_hsp.lstel is 'Loading Point';
comment on column lads_shp_hsp.werks is 'EDI plant number for shipping unit';
comment on column lads_shp_hsp.lgort is 'Storage Location';
comment on column lads_shp_hsp.kunnr is 'Customer Number 1';
comment on column lads_shp_hsp.lifnr is 'Vendor number of destination point';
comment on column lads_shp_hsp.ablad is 'Unloading Point';
comment on column lads_shp_hsp.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_shp_hsp.lgtor is 'Door For Warehouse Number';
comment on column lads_shp_hsp.bahnra is 'TrainStnNumber';
comment on column lads_shp_hsp.partner_q is 'Qualifier for partner function';
comment on column lads_shp_hsp.address_t is 'Addr. type';
comment on column lads_shp_hsp.partner_id is 'Partner no. (SAP)';
comment on column lads_shp_hsp.jurisdic is 'Location for tax calculation - Tax Jurisdiction Code';
comment on column lads_shp_hsp.language is 'Language key';
comment on column lads_shp_hsp.formofaddr is 'Form of address';
comment on column lads_shp_hsp.name1 is 'Name or address line';
comment on column lads_shp_hsp.name2 is 'Name or address line';
comment on column lads_shp_hsp.name3 is 'Name or address line';
comment on column lads_shp_hsp.name4 is 'Name or address line';
comment on column lads_shp_hsp.name_text is 'Name or address line (formatted)';
comment on column lads_shp_hsp.name_co is 'Subsequent line for name or address (c/o)';
comment on column lads_shp_hsp.location is 'Location description of location';
comment on column lads_shp_hsp.building is 'Location description: Building';
comment on column lads_shp_hsp.floor is 'Location description: Floor';
comment on column lads_shp_hsp.room is 'Location description: Room';
comment on column lads_shp_hsp.street1 is 'House number and street';
comment on column lads_shp_hsp.street2 is 'House number and street';
comment on column lads_shp_hsp.street3 is 'House number and street';
comment on column lads_shp_hsp.house_supl is 'House number';
comment on column lads_shp_hsp.house_rang is 'House no. (interval)';
comment on column lads_shp_hsp.postl_cod1 is 'Postal code';
comment on column lads_shp_hsp.postl_cod3 is 'Postal code';
comment on column lads_shp_hsp.postl_area is 'Post delivery district';
comment on column lads_shp_hsp.city1 is 'Town or city';
comment on column lads_shp_hsp.city2 is 'Town or city';
comment on column lads_shp_hsp.postl_pbox is 'PO Box';
comment on column lads_shp_hsp.postl_cod2 is 'Postal code';
comment on column lads_shp_hsp.postl_city is 'Town or city';
comment on column lads_shp_hsp.telephone1 is 'Telephone number';
comment on column lads_shp_hsp.telephone2 is 'Telephone number';
comment on column lads_shp_hsp.telefax is 'Fax number';
comment on column lads_shp_hsp.telex is 'Telex number';
comment on column lads_shp_hsp.e_mail is 'E-Mail Address';
comment on column lads_shp_hsp.country1 is 'Country indicator (ISO alphanumeric)';
comment on column lads_shp_hsp.country2 is 'Country indicator (ISO numeric)';
comment on column lads_shp_hsp.region is '"Region, state"';
comment on column lads_shp_hsp.county_cod is 'County Code (e.g. in USA)';
comment on column lads_shp_hsp.county_txt is '"County name (for example, in USA)"';
comment on column lads_shp_hsp.tzcode is 'Location for time zone (SAP code)';
comment on column lads_shp_hsp.tzdesc is 'Location for time zone (external code)';
comment on column lads_shp_hsp.knote_bez is 'Node name';
comment on column lads_shp_hsp.vstel_bez is 'Description of shipping point';
comment on column lads_shp_hsp.lstel_bez is 'Loading point description';
comment on column lads_shp_hsp.werks_bez is 'Plant Descript.';
comment on column lads_shp_hsp.lgort_bez is 'Description of storage location';
comment on column lads_shp_hsp.lgnum_bez is 'Warehouse number description';
comment on column lads_shp_hsp.lgtor_bez is 'Door description';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hsp
   add constraint lads_shp_hsp_pk primary key (tknum, hstseq, hspseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hsp to lads_app;
grant select, insert, update, delete on lads_shp_hsp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hsp for lads.lads_shp_hsp;
