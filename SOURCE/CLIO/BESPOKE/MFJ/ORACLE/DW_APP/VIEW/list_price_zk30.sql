/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : list_price_zk30
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - List Price ZK30

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.list_price_zk30
   (sap_material_code,
    sap_sales_org_code,
    sap_distbn_chnl_code,
    str_yyyymmdd,
    end_yyyymmdd, 
    zk30,
    sap_currcy_code,
    material_list_price_per_units,
    sap_uom_code,
    pieces_per_base_uom) as
   select sap_material_code,
          sap_sales_org_code,
          sap_distbn_chnl_code,
          to_number(year_from || month_from || day_from) as str_yyyymmdd,
          to_number(year_to || month_to || day_to) as end_yyyymmdd,
          case when sap_cndtn_type_code = 'ZK30' then material_list_price else null end "ZK30",
          sap_currcy_code,
          material_list_price_per_units,
          sap_uom_code,
          pieces_per_base_uom
     from material_list_price_view;

/*-*/
/* Authority
/*-*/
grant select on dw_app.list_price_zk30 to bo_user;

/*-*/
/* Synonym
/*-*/
create public synonym list_price_zk30 for dw_app.list_price_zk30;