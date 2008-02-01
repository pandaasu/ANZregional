/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_work0203                                   */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : January 2006                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create global temporary table pld_for_work0203
   (summary varchar2(255 char) not null,
    fcst_yyyynn number(6,0) not null,
    fcst_accuracy number(9,2) not null,
    fcst_count01 number(15,0) not null,
    fcst_count02 number(15,0) not null,
    fcst_count03 number(15,0) not null)
on commit preserve rows;

/**/
/* Comment */
/**/
comment on table pld_for_work0203 is 'Forecast Summary Work Table';
comment on column pld_for_work0203.summary is 'Summary';
comment on column pld_for_work0203.fcst_yyyynn is 'Forecast number';
comment on column pld_for_work0203.fcst_accuracy is 'Forecast accuracy';
comment on column pld_for_work0203.fcst_count01 is 'Forecast count 01';
comment on column pld_for_work0203.fcst_count02 is 'Forecast count 02';
comment on column pld_for_work0203.fcst_count03 is 'Forecast count 03';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_work0203
   add constraint pld_for_work0203_pk primary key (summary, fcst_yyyynn);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_work0203 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_work0203 for pld_rep.pld_for_work0203;
