/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_comp_whtax
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Company Withholding Tax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_comp_whtax
   (vendor_code                        varchar2(10 char)        not null,
    company_code                       varchar2(6 char)         not null,
    withhold_tax_type                  varchar2(5 char)         not null,
    withhold_tax_code                  varchar2(5 char)         not null,
    withhold_tax_from_date             date                     not null,
    withhold_tax_to_date               date                     not null,
    withhold_tax_flag                  varchar2(1 char)         null,
    withhold_tax_recipient_type        varchar2(2 char)         null,
    withhold_tax_identification        varchar2(16 char)        null,
    withhold_tax_exemption             varchar2(15 char)        null,
    withhold_tax_rate                  varchar2(7 char)         null,
    withhold_tax_exemption_reason      varchar2(2 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_comp_whtax is 'Business Data Store - Vendor Company Withholding Tax';
comment on column bds_vend_comp_whtax.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_wtx.lifnr';
comment on column bds_vend_comp_whtax.company_code is 'Company Code - lads_ven_ccd.bukrs';
comment on column bds_vend_comp_whtax.withhold_tax_type is 'Indicator for withholding tax type - lads_ven_wtx.witht';
comment on column bds_vend_comp_whtax.withhold_tax_code is 'Withholding tax code - lads_ven_wtx.wt_withcd';
comment on column bds_vend_comp_whtax.withhold_tax_from_date is 'IDOC: Date - lads_ven_wtx.wt_exdf';
comment on column bds_vend_comp_whtax.withhold_tax_to_date is 'IDOC: Date - lads_ven_wtx.wt_exdt';
comment on column bds_vend_comp_whtax.withhold_tax_flag is 'Indicator: Subject to withholding tax? - lads_ven_wtx.wt_subjct';
comment on column bds_vend_comp_whtax.withhold_tax_recipient_type is 'Type of recipient - lads_ven_wtx.qsrec';
comment on column bds_vend_comp_whtax.withhold_tax_identification is 'Withholding tax identification number - lads_ven_wtx.wt_wtstcd';
comment on column bds_vend_comp_whtax.withhold_tax_exemption is 'Exemption certificate number - lads_ven_wtx.wt_exnr';
comment on column bds_vend_comp_whtax.withhold_tax_rate is 'Percentage NNN.NN field for IDoc - lads_ven_wtx.wt_exrt';
comment on column bds_vend_comp_whtax.withhold_tax_exemption_reason is 'Reason for exemption - lads_ven_wtx.wt_wtexrs';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_comp_whtax
   add constraint bds_vend_comp_whtax_pk primary key (vendor_code, company_code, withhold_tax_type, withhold_tax_code, withhold_tax_from_date, withhold_tax_to_date);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_comp_whtax to lics_app;
grant select, insert, update, delete on bds_vend_comp_whtax to lads_app;
grant select, insert, update, delete on bds_vend_comp_whtax to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_comp_whtax for bds.bds_vend_comp_whtax;