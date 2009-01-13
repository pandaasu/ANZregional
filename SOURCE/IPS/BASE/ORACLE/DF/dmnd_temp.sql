/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dmnd_temp
 Owner   : df
 Author  : Steve Gregan

 Description
 -----------
 Demand Financials - Forecast temporary data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table df.dmnd_temp
   (fcst_id                     number(20)                 not null,
    dmnd_grp_org_id             number(20)                 not null,
    gsv                         number(30,10)              null,
    qty_in_base_uom             number(30,10)              null,
    zrep                        varchar2(20)               null,
    tdu                         varchar2(20)               null,
    price                       number(30,10)              null,
    mars_week                   varchar2(20)               not null,
    price_condition             varchar2(200)              null,
    type                        varchar2(1)                null,
    tdu_ovrd_flag               varchar2(1)                null)
on commit preserve rows;

/**/
/* Authority
/**/
grant select, insert, update, delete on df.dmnd_temp to df_app;

/**/
/* Synonym
/**/
create or replace public synonym dmnd_temp for df.dmnd_temp;