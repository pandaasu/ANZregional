/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_format1200                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format1200
   (extract_date date not null);

/**/
/* Comment */
/**/
comment on table pld_for_format1200 is 'Planning Forecast Format 12 Control Table';
comment on column pld_for_format1200.extract_date is 'Extract date - execution date';

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format1200 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format1200 for pld_rep.pld_for_format1200;