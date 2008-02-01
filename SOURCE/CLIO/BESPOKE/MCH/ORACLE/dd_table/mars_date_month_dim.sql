/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : mars_date_month_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Mars Date Month Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.mars_date_month_dim
   (yyyymm_date              number(6,0)                 not null,
    yyyyqq_date              number(6,0)                 not null,
    month_num                number(2,0)                 not null,
    year_num                 number(4,0)                 not null);

/**/
/* Comments
/**/
comment on table dd.mars_date_month_dim is 'Mars Date Month Dimension Table';
comment on column dd.mars_date_month_dim.yyyymm_date is 'Calendar Date in YYYYMM format';
comment on column dd.mars_date_month_dim.yyyyqq_date is 'Calendar Date in YYYYQQ format';
comment on column dd.mars_date_month_dim.month_num is 'Calendar Date in MM format';
comment on column dd.mars_date_month_dim.year_num is 'Calendar Date in YYYY format';

/**/
/* Primary Key Constraint
/**/
alter table dd.mars_date_month_dim
   add constraint mars_date_month_dim_pk primary key (yyyymm_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.mars_date_month_dim to dw_app;
grant select on dd.mars_date_month_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym mars_date_month_dim for dd.mars_date_month_dim;
