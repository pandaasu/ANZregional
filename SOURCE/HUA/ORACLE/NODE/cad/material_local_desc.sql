/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CAD
 Table   : MATERIAL_LOCAL_DESC
 Owner   : CAD
 Author  : Linden Glen

 Description
 -----------
 China Application Data - Material Local Description

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Linden Glen    Created

*******************************************************************************/

drop table material_local_desc;


/**/
/* Table creation
/**/
create table material_local_desc
   (sap_material_code                varchar2(18 char)     not null,
    lcl_material_desc                varchar2(40 char)     not null);


/**/
/* Primary Key Constraint
/**/
alter table material_local_desc
   add constraint material_local_desc_pk primary key (sap_material_code);

/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table material_local_desc is 'China Application Data - Material Local Description';

/**/
/* Synonym
/**/
create or replace public synonym material_local_desc for cad.material_local_desc;

/**/
/* Authority
/**/
grant select,update,delete,insert on material_local_desc to lics_app;
grant select,update,delete,insert on material_local_desc to cad_app;
grant select on material_local_desc to public;
