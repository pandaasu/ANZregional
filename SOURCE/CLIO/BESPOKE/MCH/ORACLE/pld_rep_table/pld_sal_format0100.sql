/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Object  : pld_sal_format0100                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format0100
   (sap_company_code varchar2(6 char) not null,
    extract_date date not null,
    logical_date date not null,
    current_YYYYPP number(6,0) not null,
    current_YYYYMM number(6,0) not null,
    extract_status varchar2(256 char) not null,
    sales_date date not null,
    sales_status varchar2(256 char) not null,
    prd_asofdays varchar2(128 char) not null,
    prd_percent number(5,2) not null,
    mth_asofdays varchar2(128 char) not null,
    mth_percent number(5,2) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format0100 is 'Planning Sales Format 01 Control Table';
comment on column pld_sal_format0100.sap_company_code is 'SAP Company code';
comment on column pld_sal_format0100.extract_date is 'Extract date - execution date';
comment on column pld_sal_format0100.logical_date is 'Logical date - as of date';
comment on column pld_sal_format0100.current_YYYYPP is 'Current period - logical date';
comment on column pld_sal_format0100.current_YYYYMM is 'current month - logical date';
comment on column pld_sal_format0100.extract_status is 'Extract status';
comment on column pld_sal_format0100.sales_date is 'Sales date - sales creation date';
comment on column pld_sal_format0100.sales_status is 'Sales status';
comment on column pld_sal_format0100.prd_asofdays is 'Period as of days literal';
comment on column pld_sal_format0100.prd_percent is 'Period progress percentage';
comment on column pld_sal_format0100.mth_asofdays is 'Month as of days literal';
comment on column pld_sal_format0100.mth_percent is 'Month progress percentage';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format0100
   add constraint pld_sal_format0100_pk primary key (sap_company_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format0100 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format0100 for pld_rep.pld_sal_format0100;
