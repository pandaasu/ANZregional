/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_nod
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_nod

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_nod
   (vbeln                                        varchar2(10 char)                   not null,
    rteseq                                       number                              not null,
    stgseq                                       number                              not null,
    nodseq                                       number                              not null,
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
    knote_bez                                    varchar2(30 char)                   null,
    vstel_bez                                    varchar2(30 char)                   null,
    lstel_bez                                    varchar2(20 char)                   null,
    werks_bez                                    varchar2(30 char)                   null,
    lgort_bez                                    varchar2(16 char)                   null,
    lgnum_bez                                    varchar2(25 char)                   null,
    lgtor_bez                                    varchar2(25 char)                   null,
    partner_q                                    varchar2(3 char)                    null,
    addres_t                                     varchar2(1 char)                    null,
    partner_id                                   varchar2(17 char)                   null,
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
    city1                                        varchar2(40 char)                   null,
    city2                                        varchar2(40 char)                   null,
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
comment on table lads_del_nod is 'LADS Delivery Route Stage Point';
comment on column lads_del_nod.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_nod.rteseq is 'RTE - generated sequence number';
comment on column lads_del_nod.stgseq is 'STG - generated sequence number';
comment on column lads_del_nod.nodseq is 'NOD - generated sequence number';
comment on column lads_del_nod.quali is 'Qualifier for stage point';
comment on column lads_del_nod.knote is 'Transportation Connection Points';
comment on column lads_del_nod.adrnr is 'Address';
comment on column lads_del_nod.vstel is 'Shipping Point/Receiving Point';
comment on column lads_del_nod.lstel is 'Loading Point';
comment on column lads_del_nod.werks is 'EDI plant number for shipping unit';
comment on column lads_del_nod.lgort is 'Storage Location';
comment on column lads_del_nod.kunnr is 'Customer Number 1';
comment on column lads_del_nod.lifnr is 'Vendor number of destination point';
comment on column lads_del_nod.ablad is 'Unloading Point';
comment on column lads_del_nod.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_del_nod.lgtor is 'Door For Warehouse Number';
comment on column lads_del_nod.knote_bez is 'Node name';
comment on column lads_del_nod.vstel_bez is 'Description of shipping point';
comment on column lads_del_nod.lstel_bez is 'Loading point description';
comment on column lads_del_nod.werks_bez is 'Plant Descript.';
comment on column lads_del_nod.lgort_bez is 'Description of storage location';
comment on column lads_del_nod.lgnum_bez is 'Warehouse number description';
comment on column lads_del_nod.lgtor_bez is 'Door description';
comment on column lads_del_nod.partner_q is 'Qualifier for partner function';
comment on column lads_del_nod.addres_t is 'Addr. type';
comment on column lads_del_nod.partner_id is 'Partner no. (SAP)';
comment on column lads_del_nod.language is 'Language key';
comment on column lads_del_nod.formofaddr is 'Form of address';
comment on column lads_del_nod.name1 is 'Name or address line';
comment on column lads_del_nod.name2 is 'Name or address line';
comment on column lads_del_nod.name3 is 'Name or address line';
comment on column lads_del_nod.name4 is 'Name or address line';
comment on column lads_del_nod.name_text is 'Name or address line (formatted)';
comment on column lads_del_nod.name_co is 'Subsequent line for name or address (c/o)';
comment on column lads_del_nod.location is 'Location description of location';
comment on column lads_del_nod.building is 'Location description: Building';
comment on column lads_del_nod.floor is 'Location description: Floor';
comment on column lads_del_nod.room is 'Location description: Room';
comment on column lads_del_nod.street1 is 'House number and street';
comment on column lads_del_nod.street2 is 'House number and street';
comment on column lads_del_nod.street3 is 'House number and street';
comment on column lads_del_nod.house_supl is 'House number';
comment on column lads_del_nod.house_rang is 'House no. (interval)';
comment on column lads_del_nod.postl_cod1 is 'Postal code';
comment on column lads_del_nod.postl_cod3 is 'Postal code';
comment on column lads_del_nod.city1 is 'Town or city';
comment on column lads_del_nod.city2 is 'Town or city';
comment on column lads_del_nod.country1 is 'Country indicator (ISO alphanumeric)';
comment on column lads_del_nod.country2 is 'Country indicator (ISO numeric)';
comment on column lads_del_nod.region is '"Region, state"';
comment on column lads_del_nod.county_cod is 'County Code (e.g. in USA)';
comment on column lads_del_nod.county_txt is '"County name (for example, in USA)"';
comment on column lads_del_nod.tzcode is 'Location for time zone (SAP code)';
comment on column lads_del_nod.tzdesc is 'Location for time zone (external code)';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_nod
   add constraint lads_del_nod_pk primary key (vbeln, rteseq, stgseq, nodseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_nod to lads_app;
grant select, insert, update, delete on lads_del_nod to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_nod for lads.lads_del_nod;
