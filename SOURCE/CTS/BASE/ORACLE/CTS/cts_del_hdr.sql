/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cts
 Table   : cts_del_hdr
 Owner   : cts
 Author  : Steve Gregan

 Description
 -----------
 Cost To Serve - cts_del_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created
 2006/08   Steve Gregan   Added Tolas shipment load number

*******************************************************************************/

/**/
/* Table creation
/**/
create table cts_del_hdr
   (cdh_delv_nbr varchar2(12 char) not null,
    cdh_ship_nbr varchar2(18 char) null,
    cdh_ship_dte varchar2(10 char) null,
    cdh_delv_rte varchar2(30 char) null,
    cdh_ship_lod varchar2(15 char) null,
    cdh_ship_car varchar2(30 char) null,
    cdh_ship_veh varchar2(30 char) null,
    cdh_ship_fup number null,
    cdh_ship_pal number null,
    cdh_ship_cas number null,
    cdh_delv_pal number null,
    cdh_delv_fup number null,
    cdh_delv_eps number null,
    cdh_delv_cas number null,
    cdh_delv_vol number null,
    cdh_delv_wgt number null);


/**/
/* Comments
/**/
comment on table cts_del_hdr is 'CTS Delivery Header Table';
comment on column cts_del_hdr.cdh_delv_nbr is 'Delivery number';
comment on column cts_del_hdr.cdh_ship_nbr is 'Shipment number';
comment on column cts_del_hdr.cdh_ship_dte is 'Shipment date';
comment on column cts_del_hdr.cdh_delv_rte is 'Delivery route';
comment on column cts_del_hdr.cdh_ship_lod is 'Shipment load';
comment on column cts_del_hdr.cdh_ship_car is 'Shipment carrier';
comment on column cts_del_hdr.cdh_ship_veh is 'Shipment vehicle';
comment on column cts_del_hdr.cdh_ship_fup is 'Shipment full pallets';
comment on column cts_del_hdr.cdh_ship_pal is 'Shipment pallets';
comment on column cts_del_hdr.cdh_ship_cas is 'Shipment cases';
comment on column cts_del_hdr.cdh_delv_pal is 'Delivery pallets';
comment on column cts_del_hdr.cdh_delv_fup is 'Delivery full pallets';
comment on column cts_del_hdr.cdh_delv_eps is 'Delivery equivalent pallet spaces';
comment on column cts_del_hdr.cdh_delv_cas is 'Delivery cases';
comment on column cts_del_hdr.cdh_delv_vol is 'Delivery volume';
comment on column cts_del_hdr.cdh_delv_wgt is 'Delivery weight';

/**/
/* Primary Key Constraint
/**/
alter table cts_del_hdr
   add constraint cts_del_hdr_pk primary key (cdh_delv_nbr);

/**/
/* Authority
/**/
grant select, insert, update, delete on cts_del_hdr to ics_app;
grant select on cts_del_hdr to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym cts_del_hdr for cts.cts_del_hdr;
