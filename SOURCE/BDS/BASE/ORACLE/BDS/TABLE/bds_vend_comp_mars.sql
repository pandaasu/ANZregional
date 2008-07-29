/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_comp_mars
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Company MARS Data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_comp_mars
   (vendor_code                        varchar2(10 char)        not null,
    company_code                       varchar2(6 char)         not null,
    transmission_medium                varchar2(2 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_comp_mars is 'Business Data Store - Vendor Company MARS Data';
comment on column bds_vend_comp_mars.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_zcc.lifnr';
comment on column bds_vend_comp_mars.company_code is 'Company Code - lads_ven_ccd.bukrs';
comment on column bds_vend_comp_mars.transmission_medium is 'Transmission medium - lads_ven_zcc.zpytadv';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_comp_mars
   add constraint bds_vend_comp_mars_pk primary key (vendor_code, company_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_comp_mars to lics_app;
grant select, insert, update, delete on bds_vend_comp_mars to lads_app;
grant select, insert, update, delete on bds_vend_comp_mars to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_comp_mars for bds.bds_vend_comp_mars;