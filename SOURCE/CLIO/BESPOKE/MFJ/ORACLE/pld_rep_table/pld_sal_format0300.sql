/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format0300                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format0300
   (extract_date date not null,
    logical_date date not null,
    current_YYYYPP number(6,0) not null,
    current_YYYYMM number(6,0) not null,
    extract_status varchar2(256 char) not null,
    sales_date date not null,
    sales_status varchar2(256 char) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format0300 is 'Planning Sales Format 03 Control Table';
comment on column pld_sal_format0300.extract_date is 'Extract date - execution date';
comment on column pld_sal_format0300.logical_date is 'Logical date - as of date';
comment on column pld_sal_format0300.current_YYYYPP is 'Current period - logical date';
comment on column pld_sal_format0300.current_YYYYMM is 'current month - logical date';
comment on column pld_sal_format0300.extract_status is 'Extract status';
comment on column pld_sal_format0300.sales_date is 'Sales date - sales creation date';
comment on column pld_sal_format0300.sales_status is 'Sales status';

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format0300 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format0300 for pld_rep.pld_sal_format0300;
