CREATE OR REPLACE PACKAGE        pricelist_initial AS
  /*************************************************************************
    NAME:      PRICELIST_INITIAL
    PURPOSE:   This package is responsible for initalise any new components
               that are to be available to users of the price list generator.
               Such as Priceing Models. Items etc.
  *************************************************************************/


  /*******************************************************************************
    NAME:      INITIALISE
    PURPOSE:   This procedure initalises the pricing model with the latest
               pricing item information.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   17/07/2006 Chris Horn           Created this procedure.
    NOTES:
  ********************************************************************************/
  PROCEDURE initialise;

END pricelist_initial; 
/


CREATE OR REPLACE PACKAGE BODY        pricelist_initial AS
  ------------------------ PACKAGE DECLARATIONS ---------------------------------
  -- Package Constants
  pc_package_name  CONSTANT common.st_package_name := 'PRICELIST_INITIAL';

  ---------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------
  --  PUBLIC FUNCTIONS/PROCEDURES.
  ---------------------------------------------------------------------------------
  PROCEDURE initialise IS
    PROCEDURE add_sales_orgs IS
    BEGIN
      pricelist_common.add_sales_org ('147', '147 - Australia');
      pricelist_common.add_sales_org ('149', '149 - New Zealand');
    END;

    PROCEDURE add_distbn_chnls IS
    BEGIN
      pricelist_common.add_distbn_chnl ('10', '10 - Non Specific');
      pricelist_common.add_distbn_chnl ('11', '11 - Grocery');
      pricelist_common.add_distbn_chnl ('12', '12 - Food Service');
      pricelist_common.add_distbn_chnl ('18', '18 - Hard Discount');
      pricelist_common.add_distbn_chnl ('20', '20 - Pet Speciality');
    END;

    PROCEDURE add_generic_price_items IS
    BEGIN
      pricelist_common.add_item('BRAND_ESSNC',null,'Brand Essence Code','(SELECT T0.BRAND_ESSNC_LONG_DESC FROM BRAND_ESSNC T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.BRAND_ESSNC_CODE = T0.BRAND_ESSNC_CODE)','Finished Good Classification - Brand Essence.');
      pricelist_common.add_item('BRAND_FLAG',null,'Brand Flag','(SELECT T0.BRAND_FLAG_LONG_DESC FROM BRAND_FLAG T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.BRAND_FLAG_CODE = T0.BRAND_FLAG_CODE)','Finished Good Classification - Brand Flag.');
      pricelist_common.add_item('BRAND_SUB_FLAG',null,'Brand Sub Flag','(SELECT T0.BRAND_SUB_FLAG_LONG_DESC FROM BRAND_SUB_FLAG T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.BRAND_SUB_FLAG_CODE = T0.BRAND_SUB_FLAG_CODE)','Finished Good Classification - Brand Sub Flag.');
      pricelist_common.add_item('BUS_SGMNT',null,'Business Segment','(SELECT T0.BUS_SGMNT_LONG_DESC FROM BUS_SGMNT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.BUS_SGMNT_CODE = T0.BUS_SGMNT_CODE)','Finished Good Classification - Business Segment. Typically represents Petcare, Food, Snackfood product groupings.');
      pricelist_common.add_item('CNSMR_PACK_FRMT',null,'Consumer Pack Format','(SELECT T0.CNSMR_PACK_FRMT_LONG_DESC FROM CNSMR_PACK_FRMT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.CNSMR_PACK_FRMT_CODE = T0.CNSMR_PACK_FRMT_CODE)','Finished Good Classification - Consumer Pack Format.');
      pricelist_common.add_item('CSUS_PER_TDU',null,'CSUS per TDU','( select pricelist_functions.no_consumer_units ( T0.MLTPCK_QTY_CODE)  FROM  MATL_FG_CLSSFCTN T0 WHERE T0.MATL_CODE = T1.MATL_CODE)','CSUS per Trading Unit.');
      pricelist_common.add_item('DIST_CHNL_STATUS',null,'Distribution Channel Status','t2.DSTRBTN_CHAIN_STS','Distribution Channel Status.');
      pricelist_common.add_item('DSPLY_STRG_CNDTN',null,'Display Storage Condition','(SELECT T0.DSPLY_STRG_CNDTN_LONG_DESC FROM DSPLY_STRG_CNDTN T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.DSPLY_STRG_CNDTN_CODE = T0.DSPLY_STRG_CNDTN_CODE)','Finished Good Classification - Display Storage Condition.');
      pricelist_common.add_item('FIGHTING_UNIT',null,'Fighting Unit','(SELECT T0.FIGHTING_UNIT_DESC FROM FIGHTING_UNIT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.FIGHTING_UNIT_CODE = T0.FIGHTING_UNIT_CODE)','Finished Good Classification - Fighting Unit.');
      pricelist_common.add_item('FNCTNL_VRTY',null,'Functional Variety','(SELECT T0.FNCTNL_VRTY_LONG_DESC FROM FNCTNL_VRTY T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.FNCTNL_VRTY_CODE = T0.FNCTNL_VRTY_CODE)','Finished Good Classification - Functional Variety.');
      pricelist_common.add_item('INGRDNT_VRTY',null,'Ingredient Variety','(SELECT T0.INGRDNT_VRTY_LONG_DESC FROM INGRDNT_VRTY T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.INGRDNT_VRTY_CODE = T0.INGRDNT_VRTY_CODE)','Finished Good Classification - Ingredient Variety.');
      pricelist_common.add_item('MCUS_PER_TDU',null,'MCUS per TDU','(pricelist_functions.lookup_mcus_per_tdu(t1.matl_code))','MCUS Per Traded Unit.');
      pricelist_common.add_item('MCU_BASE_UOM',null,'MCU Base UOM','(select t0.BASE_UOM from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Base Unit of Measure.');
      pricelist_common.add_item('MCU_CTGRY_OF_EAN',null,'MCU Cat of EAN','(select t0.CTGRY_OF_EAN from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Category of EAN.');
      pricelist_common.add_item('MCU_DCLRD_UOM',null,'MCU Declared UOM','(select t0.DCLRD_UOM from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Declared Unit of Measure.');
      pricelist_common.add_item('MCU_EAN_CODE',null,'MCU EAN Code','(select t0.EAN_CODE from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit EAN Code.');
      pricelist_common.add_item('MCU_GROSS_WGHT',null,'MCU Gross Wt','(select t0.GROSS_WGHT from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Gross Weight.');
      pricelist_common.add_item('MCU_HGHT',null,'MCU Height','(select t0.HGHT from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Height.');
      pricelist_common.add_item('MCU_LNGTH',null,'MCU Length','(select t0.LNGTH from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Length.');
      pricelist_common.add_item('MCU_MATL_CODE',null,'MCU Material Code','(select t0.matl_code from matl t0 where t0.matl_code = reference_functions.SHORT_MATL_CODE(pricelist_functions.lookup_mcu_matl_code(t1.matl_code)))','MCU Material Code.');
      pricelist_common.add_item('MCU_MATL_DESC',null,'MCU Matl Desc','(select t0.MATL_DESC from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Material Description.');
      pricelist_common.add_item('MCU_MATL_SALES_TEXT',null,'MCU Matl Sales Text','(pricelist_functions.GET_MATL_SALES_TEXT (pricelist_functions.lookup_mcu_matl_code(t1.matl_code)),t2.sales_org,t2.DSTRBTN_CHNL)','Merchandising Unit Material Sales Text');
      pricelist_common.add_item('MCU_NET_WGHT',null,'MCU Net Wt','(select t0.NET_WGHT from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Net Weight.');
      pricelist_common.add_item('MCU_VOL',null,'MCU volume','(select t0.vol from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Volume.');
      pricelist_common.add_item('MCU_VOL_UNIT',null,'MCU Volume Unit','(select t0.VOL_UNIT from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Volume Unit.');
      pricelist_common.add_item('MCU_WIDTH',null,'MCU Width','(select t0.WIDTH from matl t0 where t0.matl_code = pricelist_functions.lookup_mcu_matl_code(t1.matl_code))','Merchandising Unit Width.');
      pricelist_common.add_item('MKT_CAT',null,'Market Category','(SELECT T0.MKT_CAT_DESC FROM MKT_CAT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.MKT_CAT_CODE = T0.MKT_CAT_CODE)','Finished Good Classification - Market Category.');
      pricelist_common.add_item('MKT_SGMNT',null,'Market Segment','(SELECT T0.MKT_SGMNT_LONG_DESC FROM MKT_SGMNT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.MKT_SGMNT_CODE = T0.MKT_SGMNT_CODE)','Finished Good Classification - Market Segment.');
      pricelist_common.add_item('MKT_SUB_CAT',null,'Market Sub Category','(SELECT T0.MKT_SUB_CAT_DESC FROM MKT_SUB_CAT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.MKT_SUB_CAT_CODE = T0.MKT_SUB_CAT_CODE)','Finished Good Classification - Market Sub Category.');
      pricelist_common.add_item('MKT_SUB_CAT_GRP',null,'Market Sub Category Group','(SELECT T0.MKT_SUB_CAT_GRP_DESC FROM MKT_SUB_CAT_GRP T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.MKT_SUB_CAT_GRP_CODE = T0.MKT_SUB_CAT_GRP_CODE)','Finished Good Classification - Market Sub Category Group.');
      pricelist_common.add_item('MLTPCK_QTY',null,'Multi Pack Quantity','(SELECT T0.MLTPCK_QTY_LONG_DESC FROM MLTPCK_QTY T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.MLTPCK_QTY_CODE = T0.MLTPCK_QTY_CODE)','Finished Good Classification - Multi Pack Quantity.');
      pricelist_common.add_item('MRKTNG_CNCPT',null,'Marketing Concept','(SELECT T0.MRKTNG_CNCPT_LONG_DESC FROM MRKTNG_CNCPT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.MRKTNG_CNCPT_CODE = T0.MRKTNG_CNCPT_CODE)','Finished Good Classification - Marketing Concept.');
      pricelist_common.add_item('OCCSN',null,'Occasion','(SELECT T0.MLTPCK_QTY_LONG_DESC FROM OCCSN T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.OCCSN_CODE = T0.OCCSN_CODE)','Finished Good Classification - Occasion.');
      pricelist_common.add_item('ON_PACK_CNSMR_OFFER',null,'On Pack Consumer Offer','(SELECT T0.ON_PACK_CNSMR_OFFER_LONG_DESC FROM ON_PACK_CNSMR_OFFER T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.ON_PACK_CNSMR_OFFER_CODE = T0.ON_PACK_CNSMR_OFFER_CODE)','Finished Good Classification - On Pack Consumer Offer.');
      pricelist_common.add_item('ON_PACK_CNSMR_VALUE',null,'On Pack Consumer Value','(SELECT T0.ON_PACK_CNSMR_VALUE_LONG_DESC FROM ON_PACK_CNSMR_VALUE T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.ON_PACK_CNSMR_VALUE_CODE = T0.ON_PACK_CNSMR_VALUE_CODE)','Finished Good Classification - On Pack Consumer Value.');
      pricelist_common.add_item('ON_PACK_TRADE_OFFER',null,'On Pack Trade Offer','(SELECT T0.ON_PACK_TRADE_OFFER_LONG_DESC FROM ON_PACK_TRADE_OFFER T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.ON_PACK_TRADE_OFFER_CODE = T0.ON_PACK_TRADE_OFFER_CODE)','Finished Good Classification - On Pack Trade Offer.');
      pricelist_common.add_item('PACK_TYPE',null,'Pack Type','(SELECT T0.PACK_TYPE_LONG_DESC FROM PACK_TYPE T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.PACK_TYPE_CODE = T0.PACK_TYPE_CODE)','Finished Good Classification - Pack Type.');
      pricelist_common.add_item('PLNG_SRCE',null,'Planning Source','(SELECT T0.PLNG_SRCE_DESC FROM PLNG_SRCE T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.PLNG_SRCE_CODE = T0.PLNG_SRCE_CODE)','Finished Good Classification - Planning Source.');
      pricelist_common.add_item('PRDCT_CTGRY',null,'Product Category','(SELECT T0.PRDCT_CTGRY_LONG_DESC FROM PRDCT_CTGRY T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.PRDCT_CTGRY_CODE = T0.PRDCT_CTGRY_CODE)','Finished Good Classification - Product Category.');
      pricelist_common.add_item('PRDCT_TYPE',null,'Product Type','(SELECT T0.PRDCT_TYPE_LONG_DESC FROM PRDCT_TYPE T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.PRDCT_TYPE_CODE = T0.PRDCT_TYPE_CODE)','Finished Good Classification - Product Type.');
      pricelist_common.add_item('PRICE_ZPL0',null,'Planned Price','pricelist_functions.apply_zpl0(0,t2.sales_org,t2.DSTRBTN_CHNL,t1.RPRSNTTV_ITEM_CODE)','Planned Price');
      pricelist_common.add_item('PRICE_ZRSP',null,'RRP','pricelist_functions.apply_zrsp(0,t2.sales_org,t1.RPRSNTTV_ITEM_CODE)','Recommended Retail Price');
      pricelist_common.add_item('PRODN_LINE',null,'Production Line','(SELECT T0.PRODN_LINE_DESC FROM PRODN_LINE T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.PRODN_LINE_CODE = T0.PRODN_LINE_CODE)','Finished Good Classification - Production Line.');
      pricelist_common.add_item('RSUS_PER_TDU',null,'RSUS per TDU','(pricelist_functions.lookup_rsus_per_tdu (t1.matl_code))','RSUS Per Traded Unit.');
      pricelist_common.add_item('RSU_BASE_UOM',null,'RSU Base UOM','(select t0.BASE_UOM from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Base Unit of Measure.');
      pricelist_common.add_item('RSU_CTGRY_OF_EAN',null,'RSU Cat of EAN','(select t0.CTGRY_OF_EAN from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Category of EAN.');
      pricelist_common.add_item('RSU_DCLRD_UOM',null,'RSU Declared UOM','(select t0.DCLRD_UOM from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Declared Unit of Measure.');
      pricelist_common.add_item('RSU_EAN_CODE',null,'RSU EAN Code','(select t0.EAN_CODE from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit EAN Code.');
      pricelist_common.add_item('RSU_GROSS_WGHT',null,'RSU Gross Wt','(select t0.GROSS_WGHT from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Gross Weight.');
      pricelist_common.add_item('RSU_HGHT',null,'RSU Height','(select t0.HGHT from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Height.');
      pricelist_common.add_item('RSU_LNGTH',null,'RSU Length','(select t0.LNGTH from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Length.');
      pricelist_common.add_item('RSU_MATL_CODE',null,'RSU Material Code','(select t0.matl_code from matl t0 where t0.matl_code = reference_functions.SHORT_MATL_CODE(pricelist_functions.lookup_rsu_matl_code(t1.matl_code)))','RSU Material Code.');
      pricelist_common.add_item('RSU_MATL_DESC',null,'RSU Material Description','(select t0.MATL_DESC from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Material Description.');
      pricelist_common.add_item('RSU_MATL_SALES_TEXT',null,'RSU Matl Sales Text','(pricelist_functions.GET_MATL_SALES_TEXT (pricelist_functions.lookup_rsu_matl_code(t1.matl_code)),t2.sales_org,t2.DSTRBTN_CHNL)','Retail Sales Unit Material Sales Text');
      pricelist_common.add_item('RSU_NET_WGHT',null,'RSU Net Wt','(select t0.NET_WGHT from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Net Weight.');
      pricelist_common.add_item('RSU_VOL',null,'RSU volume','(select t0.vol from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Volume.');
      pricelist_common.add_item('RSU_VOL_UNIT',null,'RSU Volume Unit','(select t0.VOL_UNIT from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Volume Unit.');
      pricelist_common.add_item('RSU_WIDTH',null,'RSU Width','(select t0.WIDTH from matl t0 where t0.matl_code = pricelist_functions.lookup_rsu_matl_code(t1.matl_code))','Retail Sales Unit Width.');
      pricelist_common.add_item('SHELF_LIFE',null,'Shelf Life','t1.shelf_life','Shelf Life');
      pricelist_common.add_item('SIZE_DSCRPTV',null,'Size Code','(SELECT T0.SIZE_LONG_DESC FROM SIZE_DSCRPTV T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.SIZE_CODE = T0.SIZE_CODE)','Finished Good Classification - Size Code.');
      pricelist_common.add_item('SIZE_GROUP',null,'Size Group','(SELECT T0.SIZE_GROUP_LONG_DESC FROM SIZE_GROUP T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.SIZE_GROUP_CODE = T0.SIZE_GROUP_CODE)','Finished Good Classification - Size Code.');
      pricelist_common.add_item('SOP_BUS',null,'Sop Business','(SELECT T0.SOP_BUS_DESC FROM SOP_BUS T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.SOP_BUS_CODE = T0.SOP_BUS_CODE)','Finished Good Classification - Sop Business.');
      pricelist_common.add_item('SPPLY_SGMNT',null,'Supply Segment','(SELECT T0.SPPLY_SGMNT_LONG_DESC FROM SPPLY_SGMNT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.SPPLY_SGMNT_CODE = T0.SPPLY_SGMNT_CODE)','Finished Good Classification - Supply Segment.');
      pricelist_common.add_item('TDU_BASE_UOM',null,'TDU Base UOM','t1.base_uom','Traded Unit base Unit of Measure Code');
      pricelist_common.add_item('TDU_CNFGRTN',null,'TDU Configuration','(SELECT T0.TDU_CNFGRTN_LONG_DESC FROM TDU_CNFGRTN T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.TDU_CNFGRTN_CODE = T0.TDU_CNFGRTN_CODE)','Finished Good Classification - TDU Configuration.');
      pricelist_common.add_item('TDU_CTGRY_OF_EAN',null,'TDU Cat EAN ','t1.CTGRY_OF_EAN','Traded Unit Category of EAN');
      pricelist_common.add_item('TDU_DCLRD_UOM',null,'TDU Declared UOM','t1.DCLRD_UOM','Traded Unit UOM');
      pricelist_common.add_item('TDU_EAN_CODE',null,'TDU EAN Code',''''''''' ||t1.EAN_CODE','Traded Unit EAN Code');
      pricelist_common.add_item('TDU_FRMT',null,'TDU Format','(SELECT T0.TDU_FRMT_LONG_DESC FROM TDU_FRMT T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.TDU_FRMT_CODE = T0.TDU_FRMT_CODE)','Finished Good Classification - TDU Format.');
      pricelist_common.add_item('TDU_GROSS_WGHT',null,'TDU Gross Wt','t1.GROSS_WGHT','Traded Unit Gross Weight');
      pricelist_common.add_item('TDU_HGHT',null,'TDU Height','t1.HGHT','Traded Unit Height');
      pricelist_common.add_item('TDU_LNGTH',null,'TDU Length','t1.LNGTH','Traded Unit Length');
      pricelist_common.add_item('TDU_MATL_CODE',null,'Traded Unit Code','reference_functions.short_matl_code(t1.matl_code)','Traded Unit Material Code.');
      pricelist_common.add_item('TDU_MATL_DESC',null,'TDU Matl Descritpion','t1.matl_desc','Traded Unit Description');
      pricelist_common.add_item('TDU_MATL_SALES_TEXT',null,'TDU Matl Sales Text','(pricelist_functions.get_matl_sales_text(reference_functions.short_matl_code(t1.matl_code)), t2.sales_org,t2.DSTRBTN_CHNL) ','Traded Unit Material Sales Text.');
      pricelist_common.add_item('TDU_NET_WGHT',null,'TDU Net Wt','t1.NET_WGHT','Traded Unit Net Weight');
      pricelist_common.add_item('TDU_SALES_UOM',null,'TDU Sales UOM','t2.SALES_UNIT','Traded Unit Sales Unit of Measure .');
      pricelist_common.add_item('TDU_VOL',null,'TDU Volume','t1.vol','Traded Unit Volume');
      pricelist_common.add_item('TDU_VOL_UNIT',null,'TDU Volume Unit','t1.vol_unit','Traded Unit Volume Unit');
      pricelist_common.add_item('TDU_WIDTH',null,'TDU Width','t1.WIDTH','Traded Unit Width');
      pricelist_common.add_item('TRADE_SCTR',null,'Trade Sector','(SELECT T0.TRADE_SCTR_LONG_DESC FROM TRADE_SCTR T0, MATL_FG_CLSSFCTN T00 WHERE T00.MATL_CODE = T1.MATL_CODE AND T00.TRADE_SCTR_CODE = T0.TRADE_SCTR_CODE)','Finished Good Classification - Trade Sector.');
      pricelist_common.add_item('ZREP_MATL_CODE',null,'Rep Item Code','reference_functions.short_matl_code(t1.RPRSNTTV_ITEM_CODE)','Representative Item Code.');                              
    END add_generic_price_items;	

    PROCEDURE add_icb_atlas_atlas_model IS
    BEGIN
      pricelist_common.add_price_mdl ('ICB_ATLAS_ATLAS', 'ICB Atlas to Atlas', '', '');
   --   pricelist_common.add_price_mdl_by_sales_area ('ICB_ATLAS_ATLAS', '147', '99');
   --   pricelist_common.add_price_mdl_by_sales_area ('ICB_ATLAS_ATLAS', '149', '99');
    END add_icb_atlas_atlas_model;

    PROCEDURE add_icb_atlas_non_atlas_model IS
    BEGIN
      pricelist_common.add_price_mdl ('ICB_ATLAS_NON_ATLAS', 'ICB Atlas to Non Atlas', '', '');
    --  pricelist_common.add_price_mdl_by_sales_area ('ICB_ATLAS_NON_ATLAS', '147', '99');
    --  pricelist_common.add_price_mdl_by_sales_area ('ICB_ATLAS_NON_ATLAS', '149', '99');
      pricelist_common.add_item('PRICE_ZV01','ICB_ATLAS_NON_ATLAS','Affiliate Price A to NA','pricelist_functions.apply_zv01(0,t2.sales_org,t2.DSTRBTN_CHNL,''''0'''',t1.RPRSNTTV_ITEM_CODE)','Affiliate Price Atlas to Non Atlas');
      pricelist_common.add_item('PRICE_UNIT_ZV01','ICB_ATLAS_NON_ATLAS','Affiliate Price Unit A to NA','pricelist_functions.get_pricing_unit_zv01(t2.sales_org,t2.DSTRBTN_CHNL,''''0'''',t1.RPRSNTTV_ITEM_CODE)','Affiliate Price Unit Atlas to Non Atlas');
    END add_icb_atlas_non_atlas_model;

    PROCEDURE add_australian_domestic_model IS
    BEGIN
      pricelist_common.add_price_mdl ('AU_DOMESTIC', 'Australian Domestic', '', '');
      pricelist_common.add_price_mdl_by_sales_area ('AU_DOMESTIC', '147', '10');
      pricelist_common.add_price_mdl_by_sales_area ('AU_DOMESTIC', '147', '11');
      pricelist_common.add_price_mdl_by_sales_area ('AU_DOMESTIC', '147', '12');
      pricelist_common.add_price_mdl_by_sales_area ('AU_DOMESTIC', '147', '18');
      pricelist_common.add_price_mdl_by_sales_area ('AU_DOMESTIC', '147', '20');
      pricelist_common.add_item('PRICE_ZR05','AU_DOMESTIC','Domestic Price','pricelist_functions.apply_zr05(0,t2.sales_org,t2.DSTRBTN_CHNL,''  '',''   '',t1.RPRSNTTV_ITEM_CODE)','Australian Domestic Price');
      pricelist_common.add_item('PRICE_STATUS_ZR05','AU_DOMESTIC','Domestic Price Status','pricelist_functions.get_zr05_status(t2.sales_org,t1.matl_code)','Domestic Price Status');
      pricelist_common.add_item('PRICE_UNIT_ZR05','AU_DOMESTIC','Domestic Price Unit','pricelist_functions.get_pricing_unit_zv05(t2.sales_org,t2.DSTRBTN_CHNL,''  '',''   '',t1.RPRSNTTV_ITEM_CODE)','Domestic Price Unit');
    END add_australian_domestic_model;

    PROCEDURE add_new_zealand_domestic_model IS
    BEGIN
      pricelist_common.add_price_mdl ('NZ_DOMESTIC', 'New Zealand Domestic', '', '');
      pricelist_common.add_price_mdl_by_sales_area ('NZ_DOMESTIC', '149', '10');
      pricelist_common.add_price_mdl_by_sales_area ('NZ_DOMESTIC', '149', '11');
    END add_new_zealand_domestic_model;

    PROCEDURE add_rule_types IS
    BEGIN
      pricelist_common.add_rule_type('BRAND_ESSNC','Brand Essence Code','select BRAND_ESSNC_code as sqlvalue, BRAND_ESSNC_long_desc as value_name from  BRAND_ESSNC order by BRAND_ESSNC_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.BRAND_ESSNC_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('BRAND_FLAG','Brand Flag','select BRAND_FLAG_code  as sqlvalue, BRAND_FLAG_long_desc as value_name from  BRAND_FLAG order by BRAND_FLAG_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.BRAND_FLAG_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('BRAND_SUB_FLAG','Brand Sub Flag','select BRAND_SUB_FLAG_code  as sqlvalue, BRAND_SUB_FLAG_long_desc as value_name from  BRAND_SUB_FLAG order by BRAND_SUB_FLAG_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.BRAND_SUB_FLAG_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('BUS_SGMNT','Business Segment','select bus_sgmnt_code as sqlvalue , bus_sgmnt_long_desc as value_name from bus_sgmnt where bus_sgmnt_code <> ''98'' order by BUS_SGMNT_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.bus_sgmnt_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('CNSMR_PACK_FRMT','Consumer Pack Format','select CNSMR_PACK_FRMT_code  as sqlvalue, CNSMR_PACK_FRMT_long_desc as value_name from  CNSMR_PACK_FRMT order by CNSMR_PACK_FRMT_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.CNSMR_PACK_FRMT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('DSPLY_STRG_CNDTN','Display Storage Condition','select DSPLY_STRG_CNDTN_code as sqlvalue, DSPLY_STRG_CNDTN_long_desc as value_name from  DSPLY_STRG_CNDTN order by DSPLY_STRG_CNDTN_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.DSPLY_STRG_CNDTN_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('DSTRBTN_CHNNL','Distribution Channel','select DSTRBTN_CHNNL_code as sqlvalue, DSTRBTN_CHNNL_desc as value_name from DSTRBTN_CHNNL order by DSTRBTN_CHNNL_desc','t2.DSTRBTN_CHNL = ''<SQLVALUE>''');
      pricelist_common.add_rule_type('DSTRBTN_CHNNL_STS','Distribution Channel Status','select DSTRBTN_CHAIN_STS, ''Distribution status - '' || DSTRBTN_CHAIN_STS from matl_by_sales_area where not(dstrbtn_chain_sts is null) group by DSTRBTN_CHAIN_STS','t2.DSTRBTN_CHAIN_STS = ''<SQLVALUE>''');
      pricelist_common.add_rule_type('FIGHTING_UNIT','Fighting Unit','select FIGHTING_UNIT_code as sqlvalue, FIGHTING_UNIT_desc as value_name from  FIGHTING_UNIT order by FIGHTING_UNIT_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.FIGHTING_UNIT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('FNCTNL_VRTY','Functional Variety','select FNCTNL_VRTY_code as sqlvalue,  FNCTNL_VRTY_long_desc as value_name from  FNCTNL_VRTY order by FNCTNL_VRTY_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.FNCTNL_VRTY_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('INGRDNT_VRTY','Ingredient Variety','select INGRDNT_VRTY_code as sqlvalue, INGRDNT_VRTY_long_desc as value_name from  INGRDNT_VRTY order by INGRDNT_VRTY_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.INGRDNT_VRTY_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('MATL_TYPE','Material Type','select matl_type, ''Material type - '' || matl_type from matl where not(matl_type is null) group by matl_type','t1.matl_type = ''<SQLVALUE>''');
      pricelist_common.add_rule_type('MKT_CAT','Market Category','select MKT_CAT_code  as sqlvalue, MKT_CAT_desc as value_name from  MKT_CAT order by MKT_CAT_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.MKT_CAT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('MKT_SGMNT','Market Segment','select MKT_SGMNT_code  as sqlvalue, MKT_SGMNT_long_desc as value_name from  MKT_SGMNT order by MKT_SGMNT_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.MKT_SGMNT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('MKT_SUB_CAT','Market Sub Category','select MKT_SUB_CAT_code as sqlvalue, MKT_SUB_CAT_desc as value_name from  MKT_SUB_CAT order by MKT_SUB_CAT_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.MKT_SUB_CAT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('MKT_SUB_CAT_GRP','Market Sub Category Group','select MKT_SUB_CAT_GRP_code as sqlvalue, MKT_SUB_CAT_GRP_desc as value_name from   MKT_SUB_CAT_GRP order by MKT_SUB_CAT_GRP_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.MKT_SUB_CAT_GRP_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('MLTPCK_QTY','Multi Pack Quantity','select MLTPCK_QTY_code  as sqlvalue, MLTPCK_QTY_long_desc as value_name from  MLTPCK_QTY order by MLTPCK_QTY_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.MLTPCK_QTY_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('MRKTNG_CNCPT','Marketing Concept','select MRKTNG_CNCPT_code as sqlvalue, MRKTNG_CNCPT_long_desc as value_name from  MRKTNG_CNCPT order by MRKTNG_CNCPT_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.MRKTNG_CNCPT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('OCCSN','Occasion','select OCCSN_code as sqlvalue, OCCSN_long_desc as value_name from  OCCSN order by OCCSN_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.OCCSN_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('ON_PACK_CNSMR_OFFER','On Pack Consumer Offer','select ON_PACK_CNSMR_OFFER_code as sqlvalue, ON_PACK_CNSMR_OFFER_long_desc as value_name from  ON_PACK_CNSMR_OFFER order by ON_PACK_CNSMR_OFFER_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.ON_PACK_CNSMR_OFFER_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('ON_PACK_CNSMR_VALUE','On Pack Consumer Value','select ON_PACK_CNSMR_VALUE_code as sqlvalue, ON_PACK_CNSMR_VALUE_long_desc as value_name from  ON_PACK_CNSMR_VALUE order by ON_PACK_CNSMR_VALUE_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.ON_PACK_CNSMR_VALUE_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('ON_PACK_TRADE_OFFER','On Pack Trade Offer','select ON_PACK_TRADE_OFFER_code as sqlvalue, ON_PACK_TRADE_OFFER_long_desc as value_name from  ON_PACK_TRADE_OFFER order by ON_PACK_TRADE_OFFER_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.ON_PACK_TRADE_OFFER_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('PACK_TYPE','Pack Type','select PACK_TYPE_code as sqlvalue, PACK_TYPE_long_desc as value_name from  PACK_TYPE order by PACK_TYPE_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.PACK_TYPE_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('PLNG_SRCE','Planning Source','select PLNG_SRCE_code as sqlvalue, PLNG_SRCE_desc as value_name from  PLNG_SRCE order by PLNG_SRCE_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.PLNG_SRCE_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('PRDCT_CTGRY','Product Category','select PRDCT_CTGRY_code  as sqlvalue, PRDCT_CTGRY_long_desc as value_name from  PRDCT_CTGRY order by PRDCT_CTGRY_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.PRDCT_CTGRY_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('PRODN_LINE','Production Line','select PRODN_LINE_code as sqlvalue, PRODN_LINE_desc as value_name from PRODN_LINE order by PRODN_LINE_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.PRODN_LINE_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('SIZE_DSCRPTV','Size Code','select SIZE_code as sqlvalue, SIZE_long_desc as value_name from  SIZE_DSCRPTV order by SIZE_DSCRPTV_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.SIZE_DSCRPTV_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('SIZE_GROUP','Size Group','select SIZE_GROUP_code as sqlvalue, SIZE_GROUP_long_desc as value_name from  SIZE_GROUP order by SIZE_GROUP_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.SIZE_GROUP_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('SOP_BUS','Sop Business','select SOP_BUS_code as sqlvalue, SOP_BUS_desc as value_name from  SOP_BUS order by SOP_BUS_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.SOP_BUS_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('SPPLY_SGMNT','Supply Segment','select SPPLY_SGMNT_code  as sqlvalue, SPPLY_SGMNT_long_desc as value_name from  SPPLY_SGMNT order by SPPLY_SGMNT_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.SPPLY_SGMNT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('TDU_CNFGRTN','TDU Configuration','select TDU_CNFGRTN_code as sqlvalue, TDU_CNFGRTN_long_desc as value_name from  TDU_CNFGRTN order by TDU_CNFGRTN_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.TDU_CNFGRTN_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('TDU_FRMT','TDU Format','select TDU_FRMT_code as sqlvalue, TDU_FRMT_long_desc as value_name from  TDU_FRMT order by TDU_FRMT_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.TDU_FRMT_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('TRADE_SCTR','Trade Sector','select TRADE_SCTR_code as sqlvalue, TRADE_SCTR_long_desc as value_name from  TRADE_SCTR order by TRADE_SCTR_long_desc','exists (select * from matl_fg_clssfctn t0 where t0.matl_code = t1.matl_code and t0.TRADE_SCTR_code = ''<SQLVALUE>'')');
      pricelist_common.add_rule_type('TRDD_UNIT','Traded Unit','select TRDD_UNIT, ''Traded Unit - ''  || TRDD_UNIT from matl where not(TRDD_UNIT is null) group by TRDD_UNIT','t1.TRDD_UNIT = ''<SQLVALUE>''');
      pricelist_common.add_rule_type('X_PLANT_MATL_STS','X Plant Material Status','select X_PLANT_MATL_STS, ''Plant status - '' || X_PLANT_MATL_STS from matl where not(x_plant_matl_sts is null) group by X_PLANT_MATL_STS','t1.X_PLANT_MATL_STS = ''<SQLVALUE>''');
    END add_rule_types;
  BEGIN
    logit.enter_method;
    add_sales_orgs;
    add_distbn_chnls;
    add_generic_price_items;
    add_icb_atlas_atlas_model;
    add_icb_atlas_non_atlas_model;
    add_australian_domestic_model;
    add_new_zealand_domestic_model;
    add_rule_types;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to initialise Price List Generator. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END;
END pricelist_initial; 
/
