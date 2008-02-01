 /******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 View    : BDS_PRODCTN_RESRC_EN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference - Production Resource English Descriptions

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/


/**/
/* View creation
/**/
create or replace view bds_prodctn_resrc_en as
   select a.resrc_id as resrc_id,
          a.resrc_code as resrc_code,
          a.resrc_plant_code as resrc_plant_code,
          b.resrc_text as resrc_text,
          a.resrc_ctgry as resrc_ctgry,
          a.resrc_deletion_flag as resrc_deletion_flag,
          a.sap_idoc_number as hdr_idoc_number,
          a.sap_idoc_timestamp as hdr_idoc_timestamp
   from bds_refrnc_prodctn_resrc_hdr a,
        bds_refrnc_prodctn_resrc_text b
   where a.client_id = b.client_id
     and a.resrc_type = b.resrc_type
     and a.resrc_id = b.resrc_id
     and a.client_id = '002'
     and a.resrc_type = 'A'
     and b.resrc_lang = 'E';
/


/**/
/* Synonym
/**/
create or replace public synonym bds_prodctn_resrc_en for bds.bds_prodctn_resrc_en;


/**/
/* Authority
/**/