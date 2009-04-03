/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : kor_inb_summary
 Owner  : od

 Description
 -----------
 Operational Data Store - Korea Inbound Summary Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.kor_inb_summary
   (plant                             varchar2(128 char)         null,
    delivery                          varchar2(128 char)         null,
    source_plant                      varchar2(128 char)         null,
    ship_date                         varchar2(128 char)         null,
    delivery_date                     varchar2(128 char)         null,
    expiry_date                       varchar2(128 char)         null,
    material                          varchar2(128 char)         null,
    qty                               varchar2(128 char)         null,
    ordertype                         varchar2(128 char)         null,
    ship_period                       varchar2(128 char)         null,
    rsmn_date                         varchar2(128 char)         null);

/**/
/* Comments
/**/
comment on table od.kor_inb_summary is 'Korea Inbound Summary Table';

/**/
/* Authority
/**/
grant select, insert, update, delete on od.kor_inb_summary to ics_app;
grant select on od.kor_inb_summary to public;

/**/
/* Synonym
/**/
create or replace public synonym kor_inb_summary for od.kor_inb_summary;