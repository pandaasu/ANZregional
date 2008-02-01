/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_inv_work0101                                   */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create global temporary table pld_inv_work0101
   (summary number(2,0) not null,
    billing_YYYYNN number(6,0) not null,
    fc_qty number not null)
on commit preserve rows;

/**/
/* Comment */
/**/
comment on table pld_inv_work0101 is 'Standard Inventory Work Table';
comment on column pld_inv_work0101.summary is 'Summary level';
comment on column pld_inv_work0101.billing_YYYYNN is 'Billing number';
comment on column pld_inv_work0101.fc_qty is 'Forecast quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_work0101
   add constraint pld_inv_work0101_pk primary key (summary, billing_YYYYNN);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_work0101 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_work0101 for pld_rep.pld_inv_work0101;
