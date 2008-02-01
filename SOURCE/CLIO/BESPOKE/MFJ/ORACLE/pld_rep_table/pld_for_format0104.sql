/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_format0104                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : September 2003                                     */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format0104
   (sap_material_code varchar2(18 char) not null,
    asof_yyyymm number(6,0) not null,
    fcst_yyyymm number(6,0) not null,
    case_qty number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_for_format0104 is 'Planning Forecast Format 01 Month Table';
comment on column pld_for_format0104.sap_material_code is 'SAP Material code';
comment on column pld_for_format0104.asof_yyyymm is 'As of month';
comment on column pld_for_format0104.fcst_yyyymm is 'Forecast month';
comment on column pld_for_format0104.case_qty is 'Case quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_format0104
   add constraint pld_for_format0104_pk primary key (sap_material_code, asof_yyyymm, fcst_yyyymm);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format0104 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format0104 for pld_rep.pld_for_format0104;
