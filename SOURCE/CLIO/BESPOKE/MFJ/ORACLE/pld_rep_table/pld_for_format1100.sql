/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_format1100                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format1100
   (extract_date date not null);

/**/
/* Comment */
/**/
comment on table pld_for_format1100 is 'Planning Forecast Format 11 Control Table';
comment on column pld_for_format1100.extract_date is 'Extract date - execution date';

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format1100 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format1100 for pld_rep.pld_for_format1100;