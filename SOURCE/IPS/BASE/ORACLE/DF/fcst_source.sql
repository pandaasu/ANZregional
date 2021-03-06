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
    source_date                 date                       not null);

/**/
/* Primary Key Constraint
/**/
alter table df.fcst_source
   add constraint fcst_source_pk primary key (fcst_id, source_type);

/**/
/* Foreign Key Constraints
/**/
alter table df.fcst_source
   add constraint fcst_source_fk01 foreign key (fcst_id)
      references fcst (fcst_id);

/**/
/* Authority
/**/
grant select, insert, update, delete on df.fcst_source to df_app;

/**/
/* Synonym
/**/
create or replace public synonym fcst_source for df.fcst_source;

