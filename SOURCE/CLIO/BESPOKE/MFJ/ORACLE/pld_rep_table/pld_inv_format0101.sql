/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_inv_format0101                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0101
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    prd_billed_qty number(22,0) not null,
    prd_br_qty number(22,0) not null,
    prd_le_qty number(22,0) not null,
    prd_fut_br_qty number(22,0) not null,
    prd_fut_le_qty number(22,0) not null,
    mth_billed_qty number(22,0) not null,
    mth_br_qty number(22,0) not null,
    mth_le_qty number(22,0) not null,
    mth_fut_br_qty number(22,0) not null,
    mth_fut_le_qty number(22,0) not null,
    inv_tot_value number(22,0) not null,
    inv_tot_qty number(22,3) not null,
    inv_int_qty number(22,3) not null,
    inv_war_value number(22,0) not null,
    inv_war_qty number(22,3) not null,
    inv_hld_qty number(22,3) not null,
    inv_unk_qty number(22,3) not null,
    inv_age_qty number(22,3) not null,
    inv_sal_qty number(22,3) not null,
    inv_prd_br_ons_cover number(9,2) not null,
    inv_prd_le_ons_cover number(9,2) not null,
    inv_mth_br_ons_cover number(9,2) not null,
    inv_mth_le_ons_cover number(9,2) not null,
    inv_prd_br_sal_cover number(9,2) not null,
    inv_prd_le_sal_cover number(9,2) not null,
    inv_mth_br_sal_cover number(9,2) not null,
    inv_mth_le_sal_cover number(9,2) not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0101 is 'Planning Inventory Format 01 Material Table';
comment on column pld_inv_format0101.sap_company_code is 'SAP Company code';
comment on column pld_inv_format0101.sap_material_code is 'SAP Material code';
comment on column pld_inv_format0101.prd_billed_qty is 'Current period quantity billed';
comment on column pld_inv_format0101.prd_br_qty is 'Current period br quantity';
comment on column pld_inv_format0101.prd_le_qty is 'Current period le quantity';
comment on column pld_inv_format0101.prd_fut_br_qty is 'Future periods br quantity';
comment on column pld_inv_format0101.prd_fut_le_qty is 'Future periods le quantity';
comment on column pld_inv_format0101.mth_billed_qty is 'Current period quantity billed';
comment on column pld_inv_format0101.mth_br_qty is 'Current month br quantity';
comment on column pld_inv_format0101.mth_le_qty is 'Current month le quantity';
comment on column pld_inv_format0101.mth_fut_br_qty is 'Future months br quantity';
comment on column pld_inv_format0101.mth_fut_le_qty is 'Future months le quantity';
comment on column pld_inv_format0101.inv_tot_value is 'Total inventory value';
comment on column pld_inv_format0101.inv_tot_qty is 'Total inventory quantity';
comment on column pld_inv_format0101.inv_int_qty is 'Intransit inventory quantity (JP01)';
comment on column pld_inv_format0101.inv_war_value is 'Warehoused inventory value';
comment on column pld_inv_format0101.inv_war_qty is 'Warehoused inventory quantity';
comment on column pld_inv_format0101.inv_hld_qty is 'Held inventory quantity';
comment on column pld_inv_format0101.inv_unk_qty is 'Unknown inventory quantity';
comment on column pld_inv_format0101.inv_age_qty is 'Ageing inventory quantity';
comment on column pld_inv_format0101.inv_sal_qty is 'Saleable inventory quantity';
comment on column pld_inv_format0101.inv_prd_br_ons_cover is 'Period br onshore weeks cover';
comment on column pld_inv_format0101.inv_prd_le_ons_cover is 'Period le onshore weeks cover';
comment on column pld_inv_format0101.inv_mth_br_ons_cover is 'Month br onshore weeks cover';
comment on column pld_inv_format0101.inv_mth_le_ons_cover is 'Month le onshore weeks cover';
comment on column pld_inv_format0101.inv_prd_br_sal_cover is 'Period br saleable weeks cover';
comment on column pld_inv_format0101.inv_prd_le_sal_cover is 'Period le saleable weeks cover';
comment on column pld_inv_format0101.inv_mth_br_sal_cover is 'Month br saleable weeks cover';
comment on column pld_inv_format0101.inv_mth_le_sal_cover is 'Month le saleable weeks cover';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_format0101
   add constraint pld_inv_format0101_pk primary key (sap_company_code, sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0101 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0101 for pld_rep.pld_inv_format0101;
