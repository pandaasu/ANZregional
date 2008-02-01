/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : mars_date_period_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Mars Date Period Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.mars_date_period_dim
   (mars_period              number(6,0)                 not null,
    mars_yyyyqq_date         number(6,0)                 not null,
    period_num               number(2,0)                 not null,
    mars_year                number(4,0)                 not null);

/**/
/* Comments
/**/
comment on table dd.mars_date_period_dim is 'Mars Date Period Dimension Table';
comment on column dd.mars_date_period_dim.mars_period is 'Mars Date in YYYYPP format';
comment on column dd.mars_date_period_dim.mars_yyyyqq_date is 'Mars Date in YYYYQQ format';
comment on column dd.mars_date_period_dim.period_num is 'Mars Date in PP format';
comment on column dd.mars_date_period_dim.mars_year is 'Mars Date in YYYY format';

/**/
/* Primary Key Constraint
/**/
alter table dd.mars_date_period_dim
   add constraint mars_date_period_dim_pk primary key (mars_period);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.mars_date_period_dim to dw_app;
grant select on dd.mars_date_period_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym mars_date_period_dim for dd.mars_date_period_dim;

