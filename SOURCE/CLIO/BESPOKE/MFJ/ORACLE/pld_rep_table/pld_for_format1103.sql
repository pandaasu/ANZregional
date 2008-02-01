/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_format1103                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format1103
   (sap_material_code varchar2(18 char) not null,
    asof_yyyypp number(6,0) not null,
    fcst_yyyypp number(6,0) not null,
    case_qty number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_for_format1103 is 'Planning Forecast Format 11 Period Table';
comment on column pld_for_format1103.sap_material_code is 'SAP Material code';
comment on column pld_for_format1103.asof_yyyypp is 'As of period';
comment on column pld_for_format1103.fcst_yyyypp is 'Forecast period';
comment on column pld_for_format1103.case_qty is 'Case quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_format1103
   add constraint pld_for_format1103_pk primary key (sap_material_code, asof_yyyypp, fcst_yyyypp);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format1103 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format1103 for pld_rep.pld_for_format1103;
