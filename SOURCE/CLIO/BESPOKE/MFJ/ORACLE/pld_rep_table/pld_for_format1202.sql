/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reporting                             */
/* Object  : pld_for_format1202                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format1202
   (sap_material_code varchar2(18 char) not null,
    channel_id varchar2(20 char) not null,
    ld_time number(3,0) not null);

/**/
/* Comment */
/**/
comment on table pld_for_format1202 is 'Planning Forecast Format 12 Channel Table';
comment on column pld_for_format1202.sap_material_code is 'SAP Material code';
comment on column pld_for_format1202.channel_id is 'Channel identifier';
comment on column pld_for_format1202.ld_time is 'Lead time (days)';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_format1202
   add constraint pld_for_format1202_pk primary key (sap_material_code, channel_id);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format1202 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format1202 for pld_rep.pld_for_format1202;
