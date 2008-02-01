/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_for_format0204                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : September 2003                                     */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_for_format0204
   (sap_material_code varchar2(18 char) not null,
    casting_yyyymm number(6,0) not null,
    fcst_yyyymm number(6,0) not null,
    case_qty number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_for_format0204 is 'Planning Forecast Format 02 Month Table';
comment on column pld_for_format0204.sap_material_code is 'SAP Material code';
comment on column pld_for_format0204.casting_yyyymm is 'Casting month';
comment on column pld_for_format0204.fcst_yyyymm is 'Forecast month';
comment on column pld_for_format0204.case_qty is 'Case quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_for_format0204
   add constraint pld_for_format0204_pk primary key (sap_material_code, casting_yyyymm, fcst_yyyymm);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_for_format0204 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_for_format0204 for pld_rep.pld_for_format0204;
