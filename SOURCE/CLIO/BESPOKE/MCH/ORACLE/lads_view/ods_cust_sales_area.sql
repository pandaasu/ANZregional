/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_cust_sales_area
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Customer Sales Area View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_cust_sales_area
   (sap_cust_code,
    sap_sales_org_code,
    sap_distbn_chnl_code,
    sap_division_code,
    sap_cust_sales_office_code,
    sap_cust_sales_grp_code,
    sap_cust_grp_code,
    sap_cust_currcy_code,
    sap_cust_dlvry_plant_code) as 
   select lads_trim_code(t01.kunnr),
          t01.vkorg,
          t01.vtweg,
          t01.spart,
          t01.vkbur,
          t01.vkgrp,
          t01.kdgrp,
          t01.waers,
          t01.vwerk
     from lads_cus_sad t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_cust_sales_area to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_cust_sales_area for lads.ods_cust_sales_area;

