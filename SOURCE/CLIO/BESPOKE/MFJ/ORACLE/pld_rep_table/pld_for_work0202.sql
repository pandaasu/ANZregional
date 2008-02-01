/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_work0202                                   */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : September 2003                                     */
/****************************************************************/

/**/
/* Table creation */
/**/
create global temporary table pld_for_work0202
   (sequence number(15,0) not null,
    asof_yyyynn number(6,0) not null,
    sum_level number(2,0) not null,
    description varchar2(255 char) not null,
    fcst_qty01 number(22,0) not null,
    fcst_qty02 number(22,0) not null,
    fcst_qty03 number(22,0) not null,
    fcst_qty04 number(22,0) not null,
    fcst_qty05 number(22,0) not null,
    fcst_qty06 number(22,0) not null,
    fcst_qty07 number(22,0) not null,
    fcst_qty08 number(22,0) not null,
    fcst_qty09 number(22,0) not null,
    fcst_qty10 number(22,0) not null,
    fcst_qty11 number(22,0) not null,
    fcst_qty12 number(22,0) not null,
    fcst_qty13 number(22,0) not null)
on commit preserve rows;

/**/
/* Comment */
/**/
comment on table pld_for_work0202 is 'Forecast Summary Work Table';
comment on column pld_for_work0202.sequence is 'Sequence';
comment on column pld_for_work0202.asof_yyyynn is 'Asof number';
comment on column pld_for_work0202.sum_level is 'Summary level';
comment on column pld_for_work0202.description is 'Description';
comment on column pld_for_work0202.fcst_qty01 is 'Forecast quantity 01';
comment on column pld_for_work0202.fcst_qty02 is 'Forecast quantity 02';
comment on column pld_for_work0202.fcst_qty03 is 'Forecast quantity 03';
comment on column pld_for_work0202.fcst_qty04 is 'Forecast quantity 04';
comment on column pld_for_work0202.fcst_qty05 is 'Forecast quantity 05';
comment on column pld_for_work0202.fcst_qty06 is 'Forecast quantity 06';
comment on column pld_for_work0202.fcst_qty07 is 'Forecast quantity 07';
comment on column pld_for_work0202.fcst_qty08 is 'Forecast quantity 08';
comment on column pld_for_work0202.fcst_qty09 is 'Forecast quantity 09';
comment on column pld_for_work0202.fcst_qty10 is 'Forecast quantity 10';
comment on column pld_for_work0202.fcst_qty11 is 'Forecast quantity 11';
comment on column pld_for_work0202.fcst_qty12 is 'Forecast quantity 12';
comment on column pld_for_work0202.fcst_qty13 is 'Forecast quantity 13';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_work0202
   add constraint pld_for_work0202_pk primary key (sequence, asof_yyyynn);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_work0202 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_work0202 for pld_rep.pld_for_work0202;
