/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : kor_shp_summary
 Owner  : od

 Description
 -----------
 Operational Data Store - Korea Shipment Summary Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.kor_shp_summary
   (segment                           varchar2(128 char)         null,
    warehouse                         varchar2(128 char)         null,
    supplier                          varchar2(128 char)         null,
    ship_period                       varchar2(128 char)         null,
    material                          varchar2(128 char)         null,
    forecast_qty                      varchar2(128 char)         null,
    outstand_qty                      varchar2(128 char)         null,
    expt_avail_date                   varchar2(128 char)         null);

/**/
/* Comments
/**/
comment on table od.kor_shp_summary is 'Korea Shipment Summary Table';

/**/
/* Authority
/**/
grant select, insert, update, delete on od.kor_shp_summary to ics_app;
grant select on od.kor_shp_summary to public;

/**/
/* Synonym
/**/
create or replace public synonym kor_shp_summary for od.kor_shp_summary;