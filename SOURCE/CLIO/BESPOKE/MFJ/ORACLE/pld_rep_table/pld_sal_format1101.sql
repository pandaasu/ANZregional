/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format1101                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format1101
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    day_billed_qty number(22,0) not null,
    day_billed_gsv number(22,0) not null,
    prd_billed_qty number(22,0) not null,
    prd_billed_gsv number(22,0) not null,
    prd_sply_qty number(22,0) not null,
    prd_sply_gsv number(22,0) not null,
    prd_op_qty number(22,0) not null,
    prd_op_gsv number(22,0) not null,
    prd_br_qty number(22,0) not null,
    prd_br_gsv number(22,0) not null,
    prd_le_qty number(22,0) not null,
    prd_le_gsv number(22,0) not null,
    mth_billed_qty number(22,0) not null,
    mth_billed_gsv number(22,0) not null,
    mth_smly_qty number(22,0) not null,
    mth_smly_gsv number(22,0) not null,
    mth_op_qty number(22,0) not null,
    mth_op_gsv number(22,0) not null,
    mth_br_qty number(22,0) not null,
    mth_br_gsv number(22,0) not null,
    mth_le_qty number(22,0) not null,
    mth_le_gsv number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format1101 is 'Planning Sales Format 11 Material Table';
comment on column pld_sal_format1101.sap_company_code is 'SAP Company code';
comment on column pld_sal_format1101.sap_material_code is 'SAP Material code';
comment on column pld_sal_format1101.day_billed_qty is 'Daily billed quantity';
comment on column pld_sal_format1101.day_billed_gsv is 'Daily billed gross sales value';
comment on column pld_sal_format1101.prd_billed_qty is 'Period billed quantity';
comment on column pld_sal_format1101.prd_billed_gsv is 'Period billed gross sales value';
comment on column pld_sal_format1101.prd_sply_qty is 'Same period last year quantity';
comment on column pld_sal_format1101.prd_sply_gsv is 'Same period last year gross sales value';
comment on column pld_sal_format1101.prd_op_qty is 'Period plan quantity';
comment on column pld_sal_format1101.prd_op_gsv is 'Period plan gross sales value';
comment on column pld_sal_format1101.prd_br_qty is 'Period business review quantity';
comment on column pld_sal_format1101.prd_br_gsv is 'Period business review gross sales value';
comment on column pld_sal_format1101.prd_le_qty is 'Period latest estimate quantity';
comment on column pld_sal_format1101.prd_le_gsv is 'Period latest extimate gross sales value';
comment on column pld_sal_format1101.mth_billed_qty is 'Month billed quantity';
comment on column pld_sal_format1101.mth_billed_gsv is 'Month billed gross sales value';
comment on column pld_sal_format1101.mth_smly_qty is 'Same month last year quantity';
comment on column pld_sal_format1101.mth_smly_gsv is 'Same month last year gross sales value';
comment on column pld_sal_format1101.mth_op_qty is 'Month plan quantity';
comment on column pld_sal_format1101.mth_op_gsv is 'Month plan gross sales value';
comment on column pld_sal_format1101.mth_br_qty is 'Month business review quantity';
comment on column pld_sal_format1101.mth_br_gsv is 'Month business review gross sales value';
comment on column pld_sal_format1101.mth_le_qty is 'Month latest estimate quantity';
comment on column pld_sal_format1101.mth_le_gsv is 'Month latest extimate gross sales value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format1101
   add constraint pld_sal_format1101_pk primary key (sap_company_code, sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format1101 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format1101 for pld_rep.pld_sal_format1101;
