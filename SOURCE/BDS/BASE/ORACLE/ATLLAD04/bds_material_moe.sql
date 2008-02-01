/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_MOE
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Mars Organisational Entity (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_moe
   (sap_material_code         varchar2(18 char)    not null, 
    usage_code                varchar2(3 char)     not null, 
    moe_code                  varchar2(4 char)     not null, 
    start_date                date                 not null, 
    end_date                  date                 not null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_moe
   add constraint bds_material_moe_pk primary key (sap_material_code, usage_code, moe_code, start_date, end_date);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_moe is 'Business Data Store - Material Mars Organisational Entity (MATMAS)';
comment on column bds_material_moe.sap_material_code is 'SAP Material Number - lads_mat_moe.matnr';
comment on column bds_material_moe.usage_code is 'Item Usage Code - lads_mat_moe.usagecode';
comment on column bds_material_moe.moe_code is 'MOE code - lads_mat_moe.moe';
comment on column bds_material_moe.start_date is 'MOE  Start date - lads_mat_moe.datab';
comment on column bds_material_moe.end_date is 'MOE End Date - lads_mat_moe.dated';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_moe for bds.bds_material_moe;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_moe to lics_app;
grant select,update,delete,insert on bds_material_moe to bds_app;
grant select,update,delete,insert on bds_material_moe to lads_app;
