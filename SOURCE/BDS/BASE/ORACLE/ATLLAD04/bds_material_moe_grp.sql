/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_MOE_GRP
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Mars Organisational Entity Group (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_moe_grp
   (sap_material_code             varchar2(18 char)     not null, 
    grp_type_code                 varchar2(2 char)      not null, 
    grp_moe_code                  varchar2(4 char)      not null, 
    usage_code                    varchar2(3 char)      not null, 
    start_date                    date                  not null, 
    end_date                      date                  not null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_moe_grp
   add constraint bds_material_moe_grp_pk primary key (sap_material_code, grp_type_code, grp_moe_code, usage_code, start_date, end_date);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_moe_grp is 'Business Data Store - Material Mars Organisational Entity Grouping (MATMAS)';
comment on column bds_material_moe_grp.sap_material_code is 'Material Number - lads_mat_gme.matnr';
comment on column bds_material_moe_grp.grp_type_code is 'Mars Organizational Entity Type - lads_mat_gme.grouptype';
comment on column bds_material_moe_grp.grp_moe_code is 'MOE code - lads_mat_gme.groupmoe';
comment on column bds_material_moe_grp.usage_code is 'Item Usage Code - lads_mat_gme.usagecode';
comment on column bds_material_moe_grp.start_date is 'MOE  Start date - lads_mat_gme.datab';
comment on column bds_material_moe_grp.end_date is 'MOE End Date - lads_mat_gme.dated';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_moe_grp for bds.bds_material_moe_grp;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_moe_grp to lics_app;
grant select,update,delete,insert on bds_material_moe_grp to bds_app;
grant select,update,delete,insert on bds_material_moe_grp to lads_app;
