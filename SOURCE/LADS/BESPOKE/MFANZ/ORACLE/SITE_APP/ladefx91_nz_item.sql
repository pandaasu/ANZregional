/******************/
/* Package Header */
/******************/
create or replace package site_app.ladefx91_nz_item as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx91_nz_item
    Owner   : site_app

    Description
    -----------
    New Zealand Item Master Data - LADS to EFEX

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladefx91_nz_item;
/

/****************/
/* Package Body */
/****************/
create or replace package body site_app.ladefx91_nz_item as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 5;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_item_master is
         select ltrim(bmh.sap_material_code, '0') as item_code,
                bmh.bds_material_desc_en as item_name,
                rpt.rsu_ean as rsu_ean_code,
                rpt.mcu_ean as mcu_ean_code,
                rpt.tdu_ean as tdu_ean_code,
                pi.cases_layer,
                pi.layers_pallet,
                rpt.units_case as units_case,
                DECODE (rpt.mcu_per_tdu, NULL, 1, rpt.mcu_per_tdu) as mcu_per_tdu,
                rpt.tdu_uom as unit_measure,
                pr.zrep_list_price as tdu_price,
                pr.zrep_rrp as rrp_price,
                0 as mcu_price,
                0 as rsu_price,
                ' ' order_by,
                1 min_order_qty,
                1 order_multiples,
                c.brand,
                c.sub_brand,
                c.product_category,
                c.market_category,
                c.market_subcategory,
                c.market_subcategory_group,
                mbsa.item_status,
                rpt.tdu_name,
                rpt.mcu_name,
                rpt.rsu_name
           from
------------------------rpt: RSU EAN Code---------------------------------------------------------------
          (SELECT zrep.zrep_material_code,            --for EFEX_ITEM view where clause
                  zrep.tdu_material_code,
                  rt.tdu_uom,                         --for EFEX_ITEM view column
                  rt.rsu_ean,                         --for EFEX_ITEM view column
                  rt.tdu_ean,                         --for EFEX_ITEM view column
                  rt.units_case,                      --for EFEX_ITEM view column
                  mt.mcu_ean,                         --for EFEX_ITEM view column
                  mt.mcu_per_tdu,                     --for EFEX_ITEM view column
                  zrep.tdu_name,                      --for EFEX_ITEM view column
                  mcu.mcu_name,                       --for EFEX_ITEM view column
                  rsu.rsu_name                        --for EFEX_ITEM view column
             FROM
                  ----------------------zrep over BDS--------------------------------
                  (SELECT bmds.sales_organisation AS sales_org,
                          DECODE (bmds.sold_to_code,'*NONE', NULL,bmds.sold_to_code ) AS cust_code,
                          bmds.zrep_material_code,
                          bmds.tdu_material_code,
                          bmt.text AS tdu_name
                     FROM bds_material_dtrmntn_sysdate bmds,
                          bds_material_text_en bmt
                    WHERE bmds.zrep_material_code = bmt.sap_material_code
                      AND bmds.sales_organisation = '149'
                      AND bmds.sold_to_code = '*NONE'
                      AND bmds.dstrbtn_channel = '*NONE'
                      AND bmt.sales_organisation = 149
                      AND bmt.dstrbtn_channel = 99) zrep,
                  ----------------------END zrep over BDS----------------------------
                  ----------------------mt: mcu per tdu over BDS---------------------
                  (SELECT parent_material_code AS tdu_matl_code,
                          child_material_code AS mcu_matl_code,
                          child_ian AS mcu_ean,
                          child_per_parent AS mcu_per_tdu
                     FROM bds_material_bom_sysdate
                    WHERE parent_tdu_flag = 'X'
                      AND parent_material_type = 'FERT'
                      AND bom_plant = '*NONE'
                      AND bom_alternative = 1
                      AND bom_status IN (1, 7)
                      AND bom_usage = 1
                      AND child_material_type = 'FERT'
                      AND child_mcu_flag = 'X') mt,
                  ---------------------mt: end mcu per tdu over BDS-----------------
                  ----------------------mtz: mcu per tdu over BDS zrep--------------
                  (SELECT parent_material_code AS tdu_matl_code,
                          child_material_code AS mcu_matl_code
                     FROM bds_material_bom_sysdate
                    WHERE parent_tdu_flag = 'X'
                      AND parent_material_type = 'ZREP'
                      AND bom_plant = '*NONE'
                      AND bom_alternative = 1
                      AND bom_status IN (1, 7)
                      AND bom_usage = 1
                      AND child_material_type = 'ZREP'
                      AND child_mcu_flag = 'X') mtz,
                  ---------------------mtz: end mcu per tdu over BDS zrep-------------
                  ---------------------mcu: material view over BDS------------------
                  (SELECT mcubmh.sap_material_code AS matl_code,
                          bmt.text AS mcu_name
                     FROM bds_material_hdr mcubmh,
                          bds_material_text_en bmt
                    WHERE mcubmh.sap_material_code = bmt.sap_material_code
                      AND mcubmh.bds_lads_status = '1'
                      AND mcubmh.material_type = 'ZREP'
                      AND mcubmh.mars_merchandising_unit_flag = 'X'--is an MCU
                      AND mcubmh.deletion_flag IS NULL
                      AND bmt.sales_organisation = 149
                      AND bmt.dstrbtn_channel = 99) mcu,
                  ---------------------mcu: END material view over BDS--------------
                  ----------------------rt: rsu per tdu over BDS---------------------
                  (SELECT parent_material_code AS tdu_matl_code,
                          parent_base_uom AS tdu_uom,
                          child_material_code AS rsu_matl_code,
                          child_ian AS rsu_ean,
                          parent_ian AS tdu_ean,
                          child_per_parent AS units_case
                     FROM bds_material_bom_sysdate
                    WHERE parent_tdu_flag = 'X'
                      AND parent_material_type = 'FERT'
                      AND bom_plant = '*NONE'
                      AND bom_alternative = 1
                      AND bom_status IN (1, 7)
                      AND bom_usage = 5
                      AND child_material_type = 'FERT'
                      AND child_rsu_flag = 'X') rt,
                  ---------------------rt: end rsu per tdu over BDS-----------------
                  ----------------------rtz: rsu per tdu over BDS---------------------
                  (SELECT parent_material_code AS tdu_matl_code,
                          parent_base_uom AS tdu_uom,
                          child_material_code AS rsu_matl_code
                     FROM bds_material_bom_sysdate
                    WHERE parent_tdu_flag = 'X'
                      AND parent_material_type = 'ZREP'
                      AND bom_plant = '*NONE'
                      AND bom_alternative = 1
                      AND bom_status IN (1, 7)
                      AND bom_usage = 5
                      AND child_material_type = 'ZREP'
                      AND child_rsu_flag = 'X') rtz,
                  ---------------------rtz: end rsu per tdu over BDS-----------------
                  ---------------------rsu: material view over BDS------------------
                  (SELECT rsubmh.sap_material_code AS matl_code,
                          bmt.text AS rsu_name
                     FROM bds_material_hdr rsubmh,
                          bds_material_text_en bmt
                    WHERE rsubmh.sap_material_code = bmt.sap_material_code
                      AND rsubmh.bds_lads_status = '1'
                      AND rsubmh.material_type = 'ZREP'
                      AND rsubmh.mars_retail_sales_unit_flag = 'X' --is an RSU
                      AND rsubmh.deletion_flag IS NULL
                      AND bmt.sales_organisation = 149
                      AND bmt.dstrbtn_channel = 99) rsu
            ---------------------rsu: END material view over BDS--------------
           WHERE  zrep.tdu_material_code = mt.tdu_matl_code(+)
              AND zrep.tdu_material_code = rt.tdu_matl_code
              AND zrep.zrep_material_code = mtz.tdu_matl_code(+)
              AND zrep.zrep_material_code = rtz.tdu_matl_code(+)
              AND mtz.mcu_matl_code = mcu.matl_code(+)
              AND rtz.rsu_matl_code = rsu.matl_code(+)) rpt,
------------------------rpt: End RSU EAN Code---------------------------------------------------------*/
          bds_material_hdr bmh,
------------------------c: MFANZ FG Material Classification---------------------------------------------
          (SELECT sap_material_code, sap_brand_flag_lng_dsc AS brand,
                  sap_brand_sub_flag_lng_dsc AS sub_brand,
                  sap_prdct_ctgry_lng_dsc AS product_category,
                  sap_size_lng_dsc AS pack_size,
                  sap_cnsmr_pack_frmt_lng_dsc AS pack_type,
                  sap_trad_unit_config_sht_dsc AS pack_format,
                  sap_bus_sgmnt_lng_dsc AS bus_segment,
                  sap_mrkt_ctgry_desc AS market_category,
                  sap_mrkt_sub_ctgry_desc AS market_subcategory,
                  sap_mrkt_sub_ctgry_grp_desc AS market_subcategory_group
             FROM bds_material_classfctn_en
            WHERE material_type IN ('ZREP')) c,
 -----------------------c: END MFANZ FG Material Classification-----------------------------------------
------------------------pi: Packaging Instructions------------------------------------------------------
          (SELECT sap_material_code AS matl_code, --for EFEX_ITEM View WHERE clause
                  rounding_qty AS cases_layer, --for EFEX_ITEM View column
                  target_qty / (DECODE (rounding_qty, 0, 1, rounding_qty)) AS layers_pallet --for EFEX_ITEM View column
           FROM   bds_material_pkg_instr_sysdate
            WHERE sales_organisation IN ('149') -- 149 - NZ
          ) pi,
------------------------pi: End Packaging Instructions------------------------------------------------*/
------------------------mbsa: MFANZ Material By Sales Area----------------------------------------------
          (SELECT DISTINCT sap_material_code AS matl_code, --for EFEX ITEM View WHERE clause
                           MIN (delivering_plant) AS delivering_plant,--Get the first delivering plant record
                           DECODE (MIN (dstrbtn_chain_status), '20', 'A', 'X' ) AS item_status --get the first record
                      FROM bds_material_dstrbtn_chain
                     WHERE sales_organisation IN ('149') --NZ
                       AND dstrbtn_channel <> '99' --Exclude 99 Exports
                       AND dstrbtn_chain_delete_indctr IS NULL
                  GROUP BY sap_material_code) mbsa,
------------------------pr: Material Pricing Information------------------------------------------------
          (SELECT m.sap_material_code,
                  ROUND (lp.zrep_list_price, 4) AS zrep_list_price, --List Price
                  ROUND (rrp.zrep_rrp, 4) AS zrep_rrp --Recommended Retail Price
             FROM bds_material_hdr m,
                  -----------------lp: ZREP List Price----------------------------
                  (SELECT SUBSTR (vrbl_key, 5, 18) AS matl_code,
                          rate_qty_or_pcntg AS zrep_list_price
                     FROM (SELECT t1.vakey AS vrbl_key,
                                  t1.datab AS valid_from_date,
                                  t1.datbi AS valid_to_date,
                                  t1.kotabnr AS cndtn_table,
                                  t2.kschl AS cndtn_type,
                                  t2.kbetr AS rate_qty_or_pcntg
                             FROM lads_prc_lst_hdr t1, lads_prc_lst_det t2
                            WHERE t1.vakey = t2.vakey
                              AND t1.kschl = t2.kschl
                              AND t1.datab = t2.datab
                              AND t1.knumh = t2.knumh
                              AND t2.loevm_ko IS NULL)
                    WHERE cndtn_table = '812'       --Sales_Org/Material level
                      AND cndtn_type = 'ZN00'                     --List Price
                      AND SUBSTR (vrbl_key, 1, 3) = '149'          --NZ
                      AND valid_from_date <= TO_CHAR (SYSDATE, 'yyyymmdd')
                      AND valid_to_date >= TO_CHAR (SYSDATE, 'yyyymmdd')) lp,
                  -----------------lp: END ZREP List Price------------------------
                  -----------------rrp: ZREP Recommended Retail Price-----------
                  (SELECT SUBSTR (vrbl_key, 5, 18) AS matl_code,
                          rate_qty_or_pcntg AS zrep_rrp
                     FROM (SELECT t1.vakey AS vrbl_key,
                                  t1.datab AS valid_from_date,
                                  t1.datbi AS valid_to_date,
                                  t1.kotabnr AS cndtn_table,
                                  t2.kschl AS cndtn_type,
                                  t2.kbetr AS rate_qty_or_pcntg
                             FROM lads_prc_lst_hdr t1, lads_prc_lst_det t2
                            WHERE t1.vakey = t2.vakey
                              AND t1.kschl = t2.kschl
                              AND t1.datab = t2.datab
                              AND t1.knumh = t2.knumh
                              AND t2.loevm_ko IS NULL)
                    WHERE cndtn_table = '599'       --Sales_Org/Material level
                      AND cndtn_type = 'ZRSP'       --Recommended Retail Price
                      AND SUBSTR (vrbl_key, 1, 3) = '149'          --NZ
                      AND valid_from_date <= TO_CHAR (SYSDATE, 'yyyymmdd')
                      AND valid_to_date >= TO_CHAR (SYSDATE, 'yyyymmdd')) rrp
            -----------------rrp: END ZREP Recommended Retail Price---------
           WHERE  m.sap_material_code = lp.matl_code
              AND m.sap_material_code = rrp.matl_code(+)
              AND m.material_type = 'ZREP'
              AND m.mars_traded_unit_flag = 'X') pr
------------------------pr: END Material Pricing Information------------------------------------------------
    WHERE bmh.material_type = 'ZREP'
      AND bmh.mars_traded_unit_flag = 'X'
      AND bmh.sap_material_code = c.sap_material_code
      AND rpt.tdu_material_code = mbsa.matl_code
      AND bmh.sap_material_code = rpt.zrep_material_code
      AND bmh.sap_material_code = pr.sap_material_code
      AND rpt.tdu_material_code = pi.matl_code(+);
      rcd_item_master csr_item_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_item_master;
      loop
         fetch csr_item_master into rcd_item_master;
         if csr_item_master%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADEFX91',null,'LADEFX91.dat');
            lics_outbound_loader.append_data('CTL');
            var_start := false;
         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          to_char(nvl(con_market_id,0))||rpad(' ',10-length(to_char(nvl(con_market_id,0))),' ') ||
                                          nvl(rcd_item_master.item_code,' ')||rpad(' ',50-length(nvl(rcd_item_master.item_code,' ')),' ') ||
                                          nvl(rcd_item_master.item_name,' ')||rpad(' ',50-length(nvl(rcd_item_master.item_name,' ')),' ') ||
                                          nvl(rcd_item_master.rsu_ean_code,' ')||rpad(' ',50-length(nvl(rcd_item_master.rsu_ean_code,' ')),' ') ||
                                          nvl(rcd_item_master.mcu_ean_code,' ')||rpad(' ',50-length(nvl(rcd_item_master.mcu_ean_code,' ')),' ') ||
                                          nvl(rcd_item_master.tdu_ean_code,' ')||rpad(' ',50-length(nvl(rcd_item_master.tdu_ean_code,' ')),' ') ||
                                          to_char(nvl(rcd_item_master.cases_layer,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.cases_layer,0))),' ') ||
                                          to_char(nvl(rcd_item_master.layers_pallet,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.layers_pallet,0))),' ') ||
                                          to_char(nvl(rcd_item_master.units_case,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.units_case,0))),' ') ||
                                          to_char(nvl(rcd_item_master.mcu_per_tdu,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.mcu_per_tdu,0))),' ') ||
                                          nvl(rcd_item_master.unit_measure,' ')||rpad(' ',3-length(nvl(rcd_item_master.unit_measure,' ')),' ') ||
                                          to_char(nvl(rcd_item_master.tdu_price,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.tdu_price,0))),' ') ||
                                          to_char(nvl(rcd_item_master.rrp_price,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.rrp_price,0))),' ') ||
                                          to_char(nvl(rcd_item_master.mcu_price,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.mcu_price,0))),' ') ||
                                          to_char(nvl(rcd_item_master.rsu_price,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.rsu_price,0))),' ') ||
                                          nvl(rcd_item_master.order_by,' ')||rpad(' ',1-length(nvl(rcd_item_master.order_by,' ')),' ') ||
                                          to_char(nvl(rcd_item_master.min_order_qty,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.min_order_qty,0))),' ') ||
                                          to_char(nvl(rcd_item_master.order_multiples,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.order_multiples,0))),' ') ||
                                          nvl(rcd_item_master.brand,' ')||rpad(' ',50-length(nvl(rcd_item_master.brand,' ')),' ') ||
                                          nvl(rcd_item_master.sub_brand,' ')||rpad(' ',50-length(nvl(rcd_item_master.sub_brand,' ')),' ') ||
                                          nvl(rcd_item_master.product_category,' ')||rpad(' ',50-length(nvl(rcd_item_master.product_category,' ')),' ') ||
                                          nvl(rcd_item_master.market_category,' ')||rpad(' ',30-length(nvl(rcd_item_master.market_category,' ')),' ') ||
                                          nvl(rcd_item_master.market_subcategory,' ')||rpad(' ',30-length(nvl(rcd_item_master.market_subcategory,' ')),' ') ||
                                          nvl(rcd_item_master.market_subcategory_group,' ')||rpad(' ',30-length(nvl(rcd_item_master.market_subcategory_group,' ')),' ') ||
                                          nvl(rcd_item_master.item_status,' ')||rpad(' ',1-length(nvl(rcd_item_master.item_status,' ')),' ') ||
                                          nvl(rcd_item_master.tdu_name,' ')||rpad(' ',200-length(nvl(rcd_item_master.tdu_name,' ')),' ') ||
                                          nvl(rcd_item_master.mcu_name,' ')||rpad(' ',200-length(nvl(rcd_item_master.mcu_name,' ')),' ') ||
                                          nvl(rcd_item_master.rsu_name,' ')||rpad(' ',200-length(nvl(rcd_item_master.rsu_name,' ')),' '));

      end loop;
      close csr_item_master;

      /*-*/
      /* Finalise Interface
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADEFX91 NEW ZEALAND ITEM - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladefx91_nz_item;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx91_nz_item for site_app.ladefx91_nz_item;
grant execute on ladefx91_nz_item to public;
