/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_plant
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Plant View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_plant
   (sap_plant_code,
    plant_desc) as
   select trim(substr(t01.z_data,4,4)),
          trim(substr(t01.z_data,8,30))
     from lads_ref_dat t01
    where t01.z_tabname = 'T001W';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_plant to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_plant for lads.ods_plant;

