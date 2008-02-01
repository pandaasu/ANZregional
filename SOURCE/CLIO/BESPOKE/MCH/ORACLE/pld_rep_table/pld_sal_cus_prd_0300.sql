/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_sal_cus_prd_0300                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_cus_prd_0300
   (sap_company_code varchar2(6 char) not null,
    extract_date date not null,
    logical_date date not null,
    current_yyyypp number(6,0) not null,
    extract_status varchar2(256 char) not null,
    sales_date date not null,
    sales_status varchar2(256 char) not null,
    prd_asofdays varchar2(128 char) not null,
    prd_percent number(5,2) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_cus_prd_0300 is 'Planning Sales Customer 03 Period Control Table - Invoice Date';
comment on column pld_sal_cus_prd_0300.sap_company_code is 'SAP Company code';
comment on column pld_sal_cus_prd_0300.extract_date is 'Extract date - execution date';
comment on column pld_sal_cus_prd_0300.logical_date is 'Logical date - as of date';
comment on column pld_sal_cus_prd_0300.current_yyyypp is 'Current period - logical date';
comment on column pld_sal_cus_prd_0300.extract_status is 'Extract status';
comment on column pld_sal_cus_prd_0300.sales_date is 'Sales date - sales creation date';
comment on column pld_sal_cus_prd_0300.sales_status is 'Sales status';
comment on column pld_sal_cus_prd_0300.prd_asofdays is 'Period as of days literal';
comment on column pld_sal_cus_prd_0300.prd_percent is 'Period progress percentage';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_cus_prd_0300
   add constraint pld_sal_cus_prd_0300_pk primary key (sap_company_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_cus_prd_0300 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_cus_prd_0300 for pld_rep.pld_sal_cus_prd_0300;
