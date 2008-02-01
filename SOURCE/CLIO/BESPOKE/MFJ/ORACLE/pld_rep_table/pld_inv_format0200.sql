/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_inv_format0200                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0200
   (extract_date date not null,
    current_YYYYPP number(6,0) not null,
    current_YYYYMM number(6,0) not null,
    extract_status varchar2(256 char) not null,
    inventory_date date not null,
    inventory_status varchar2(256 char) not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0200 is 'Planning Inventory Format 02 Control Table';
comment on column pld_inv_format0200.extract_date is 'Extract date - execution date';
comment on column pld_inv_format0200.current_YYYYPP is 'Current period - logical date';
comment on column pld_inv_format0200.current_YYYYMM is 'current month - logical date';
comment on column pld_inv_format0200.extract_status is 'Extract status';
comment on column pld_inv_format0200.inventory_date is 'Inventory date - inventory balance date';
comment on column pld_inv_format0200.inventory_status is 'Inventory status';

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0200 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0200 for pld_rep.pld_inv_format0200;
