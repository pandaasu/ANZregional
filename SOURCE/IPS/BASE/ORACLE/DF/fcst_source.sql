/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : fcst_source
 Owner   : df
 Author  : Steve Gregan

 Description
 -----------
 Demand Financials - Forecast Source

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table df.fcst_source
   (fcst_id                     number(20)                 not null,
    source_type                 varchar2(10)               not null,
    value                        varchar2(1000)             null,
    data_frmt                    varchar2(4000)             null);

/**/
/* Primary Key Constraint
/**/
alter table df.fcst_source
   add constraint fcst_source_pk primary key (fcst_id, source_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on df.fcst_source to df_app;

/**/
/* Synonym
/**/
create or replace public synonym fcst_source for df.fcst_source;

