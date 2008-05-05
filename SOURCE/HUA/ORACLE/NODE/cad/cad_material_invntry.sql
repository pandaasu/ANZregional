/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CAD
 Table   : CAD_MATERIAL_INVNTRY
 Owner   : CAD
 Author  : Linden Glen

 Description
 -----------
 China Application Data - Material Master Inventory

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/

drop table cad_material_invntry;


/**/
/* Table creation
/**/
create table cad_material_invntry
   (sap_material_code                varchar2(18 char)    not null,
    sap_company_code                 varchar2(6 char)     null,
    sap_plant_code                   varchar2(4 char)     null,
    inv_exp_date                     varchar2(8 char)     null,
    inv_unreleased_qty               number               null,
    inv_reserved_qty                 number               null,
    inv_class01                      varchar2(3 char)     null,
    inv_class02                      varchar2(3 char)     null);


/**/
/* Primary Key Constraint
/**/
alter table cad_material_invntry
   add constraint cad_material_invntry_pk primary key (sap_material_code, 
                                                       sap_company_code, 
                                                       sap_plant_code, 
                                                       inv_exp_date);

/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table cad_material_invntry is 'China Application Data - Material Master Inventory';

/**/
/* Synonym
/**/
create or replace public synonym cad_material_invntry for cad.cad_material_invntry;

/**/
/* Authority
/**/
grant select,update,delete,insert on cad_material_invntry to lics_app;
grant select,update,delete,insert on cad_material_invntry to cad_app;
grant select on cad_material_invntry to public;
