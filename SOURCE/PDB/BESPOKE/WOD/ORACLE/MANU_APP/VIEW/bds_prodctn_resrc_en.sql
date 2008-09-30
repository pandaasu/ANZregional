DROP VIEW MANU_APP.BDS_PRODCTN_RESRC_EN;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.bds_prodctn_resrc_en (resrc_id,
                                                            resrc_code,
                                                            resrc_text,
                                                            resrc_plant_code
                                                           )
AS
  SELECT
         /* NOTE this will break when the new table is redifiend in BDS  */
         /* it can be deleted WHEN BDS_PRODCTN_RESRC_EN is running  */
         "RESRC_ID", "RESRC_CODE", "RESRC_TEXT", "RESRC_PLANT_CODE"
    FROM bds_prodctn_resrc_en_ics;


