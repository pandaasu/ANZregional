create or replace package ladcad01_material as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladcad01_material
 Owner   : site_app

 Description
 -----------
 Material Master Data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/01   Linden Glen    Added data check to stop empty interfaces
                          Removed delta send option - inclusion of inventory
                          position in interface requires full send
 2008/03   Linden Glen    Added zrep English and Chinese descriptions
                          Added SELL and MAKE MOE identifier for 0168
                          Added Intermediate Component identifier
                           
*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladcad01_material;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad01_material as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_matl_master is
          select a.sap_material_code as sap_material_code,
                a.bds_material_desc_zh as material_desc_ch, 
                a.bds_material_desc_en as material_desc_en,
                a.mars_rprsnttv_item_code as mars_rprsnttv_item_code,
                i.zrep_material_desc_ch as zrep_material_desc_ch, 
                i.zrep_material_desc_en as zrep_material_desc_en,
                to_char(a.net_weight,'fm0000000000.00000') as net_weight,
                to_char(a.gross_weight,'fm0000000000.00000') as gross_weight,
                to_char(a.length,'fm0000000000.00000') as matl_length,
                to_char(a.width,'fm0000000000.00000') as width,
                to_char(a.height,'fm0000000000.00000') as height,
                h.pcs_per_case as pcs_per_case,
                h.outters_per_case as outers_per_case,
                h.cases_per_pallet as cases_per_pallet,
                c.sap_brand_essnc_code as brand_essnc_code,
                c.sap_brand_essnc_lng_dsc as brand_essnc_desc,
                c.sap_brand_essnc_sht_dsc as brand_essnc_abbrd_desc,
                c.sap_brand_flag_code as brand_flag_code,
                c.sap_brand_flag_lng_dsc as brand_flag_desc,
                c.sap_brand_flag_sht_dsc as brand_flag_abbrd_desc,
                c.sap_brand_sub_flag_code as brand_sub_flag_code,
                c.sap_brand_sub_flag_lng_dsc as brand_sub_flag_desc,
                c.sap_brand_sub_flag_sht_dsc as brand_sub_flag_abbrd_desc,
                c.sap_bus_sgmnt_code as bus_sgmnt_code,
                c.sap_bus_sgmnt_lng_dsc as bus_sgmnt_desc,
                c.sap_bus_sgmnt_sht_dsc as bus_sgmnt_abbrd_desc,
                c.sap_mrkt_sgmnt_code as mkt_sgmnt_code,
                c.sap_mrkt_sgmnt_lng_dsc as mkt_sgmnt_desc,
                c.sap_mrkt_sgmnt_sht_dsc as mkt_sgmnt_abbrd_desc,
                c.sap_prdct_ctgry_code as prdct_ctgry_code,
                c.sap_prdct_ctgry_lng_dsc as prdct_ctgry_desc,
                c.sap_prdct_ctgry_sht_dsc as prdct_ctgry_abbrd_desc,
                c.sap_prdct_type_code as prdct_type_code,
                c.sap_prdct_type_lng_dsc as prdct_type_desc,
                c.sap_prdct_type_sht_dsc as prdct_type_abbrd_desc,
                c.sap_cnsmr_pack_frmt_code as cnsmr_pack_frmt_code,
                c.sap_cnsmr_pack_frmt_lng_dsc as cnsmr_pack_frmt_desc,
                c.sap_cnsmr_pack_frmt_sht_dsc as cnsmr_pack_frmt_abbrd_desc,
                c.sap_ingrdnt_vrty_code as ingred_vrty_code,
                c.sap_ingrdnt_vrty_lng_dsc as ingred_vrty_desc,
                c.sap_ingrdnt_vrty_sht_dsc as ingred_vrty_abbrd_desc,
                c.sap_size_grp_code as prdct_size_grp_code,
                c.sap_size_grp_lng_dsc as prdct_size_grp_desc,
                c.sap_size_grp_sht_dsc as prdct_size_grp_abbrd_desc,
                c.sap_size_code as prdct_pack_size_code,
                c.sap_size_lng_dsc as prdct_pack_size_desc,
                c.sap_size_sht_dsc as prdct_pack_size_abbrd_desc,
                d.sales_organisation_135 as sales_organisation_135,
                d.sales_organisation_234 as sales_organisation_234,
                a.base_uom as base_uom_code,
                a.material_type as material_type_code,
                e.material_type_desc as material_type_desc,
                decode(a.deletion_flag,'X','INACTIVE','ACTIVE') as material_sts_code,
                c.sap_china_bdt_code as bdt_code,
                c.sap_china_bdt_desc as bdt_desc,
                null as bdt_abbrd_desc,
                f.tax_classfctn_01 as tax_classification,
                j.sell_moe_0168 as sell_moe_0168,
                j.make_moe_0168 as make_moe_0168,
                a.mars_intrmdt_prdct_compnt_flag as intrmdt_prdct_compnt
         from bds_material_hdr a,
              bds_material_classfctn_en c,
              (select sap_material_code,
                      max(case when sales_organisation = '135' then 'X' end) as sales_organisation_135,
                      max(case when sales_organisation = '234' then 'X' end) as sales_organisation_234
               from bds_material_dstrbtn_chain
               where sales_organisation in ('135','234')
               group by sap_material_code) d,
              material_type e,
              (select sap_material_code,
                      max(tax_classfctn_01) as tax_classfctn_01
               from bds_material_tax
               where departure_cntry = 'CN'
               group by sap_material_code) f,
              (select sap_material_code,
                      max(case when uom_code = 'PCE' then to_char(round((1/ base_uom_numerator) * base_uom_denominator,5),'fm0000000000.00000') end) as pcs_per_case,
                      max(case when uom_code = 'SB' then to_char(round((1/ base_uom_numerator) * base_uom_denominator,5),'fm0000000000.00000') end) as outters_per_case,
                      max(case when uom_code = 'CS' then to_char(round((1/ base_uom_numerator) * base_uom_denominator,5),'fm0000000000.00000') end) as cases_per_pallet
               from bds_material_uom
               where uom_code in ('PCE','SB','CS')
               group by sap_material_code) h,
               (select sap_material_code as sap_material_code,
                       bds_material_desc_zh as zrep_material_desc_ch, 
                       bds_material_desc_en as zrep_material_desc_en
                from bds_material_hdr
                where bds_lads_status = '1') i,
              (select sap_material_code,
                      max(case when usage_code = 'SEL' then 'X' end) as sell_moe_0168,
                      max(case when usage_code = 'MKE' then 'X' end) as make_moe_0168
               from bds_material_moe
               where usage_code in ('SEL','MKE')
                 and moe_code = '0168'
               group by sap_material_code) j
         where a.sap_material_code = c.sap_material_code(+)
           and a.sap_material_code = d.sap_material_code(+)
           and a.material_type = e.sap_material_type_code(+)
           and a.sap_material_code = f.sap_material_code(+)
           and a.sap_material_code = h.sap_material_code(+)
           and a.mars_rprsnttv_item_code = i.sap_material_code(+)
           and a.sap_material_code = j.sap_material_code(+)
           and a.bds_lads_status = '1';
      rec_matl_master  csr_matl_master%rowtype;

      cursor csr_matl_invntry is
         select a.sap_company_code as sap_company_code,
                a.sap_plant_code as sap_plant_code,
                to_char(a.inv_exp_date,'yyyymmdd') as inv_exp_date,
                to_char(a.inv_unr_qty,'fm0000000000.00000') as inv_unreleased_qty,
                to_char(a.inv_res_qty,'fm0000000000.00000') as inv_reserved_qty,
                a.inv_class01 as inv_class01,
                a.inv_class02 as inv_class02
         from pld_inv_format0202 a
         where a.sap_company_code = '135'
           and a.sap_material_code = rec_matl_master.sap_material_code;
      rec_matl_invntry  csr_matl_invntry%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_matl_master;
      loop
         fetch csr_matl_master into rec_matl_master;
         if (csr_matl_master%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface('LADCAD01',null,'LADCAD01.dat');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(to_char(nvl(rec_matl_master.sap_material_code,' ')),18, ' ') ||
                                          nvl(rec_matl_master.material_desc_ch,' ')||rpad(' ',40-length(nvl(rec_matl_master.material_desc_ch,' ')),' ') ||
                                          rpad(to_char(nvl(rec_matl_master.material_desc_en,' ')),40, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.mars_rprsnttv_item_code,' ')),18, ' ') ||
                                          nvl(rec_matl_master.zrep_material_desc_ch,' ')||rpad(' ',40-length(nvl(rec_matl_master.zrep_material_desc_ch,' ')),' ') ||
                                          rpad(to_char(nvl(rec_matl_master.zrep_material_desc_en,' ')),40, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.net_weight,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.gross_weight,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.matl_length,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.width,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.height,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.pcs_per_case,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.outers_per_case,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.cases_per_pallet,' ')),16, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_essnc_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_essnc_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_essnc_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_flag_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_flag_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_flag_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_sub_flag_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_sub_flag_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.brand_sub_flag_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.bus_sgmnt_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.bus_sgmnt_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.bus_sgmnt_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.mkt_sgmnt_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.mkt_sgmnt_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.mkt_sgmnt_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_ctgry_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_ctgry_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_ctgry_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_type_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_type_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_type_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.cnsmr_pack_frmt_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.cnsmr_pack_frmt_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.cnsmr_pack_frmt_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.ingred_vrty_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.ingred_vrty_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.ingred_vrty_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_size_grp_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_size_grp_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_size_grp_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_pack_size_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_pack_size_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.prdct_pack_size_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.sales_organisation_135,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.sales_organisation_234,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.base_uom_code,' ')),3, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.material_type_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.material_type_desc,' ')),40, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.material_sts_code,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.bdt_code,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.bdt_desc,' ')),30, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.bdt_abbrd_desc,' ')),12, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.tax_classification,' ')),1, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.sell_moe_0168,' ')),1, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.make_moe_0168,' ')),1, ' ') ||
                                          rpad(to_char(nvl(rec_matl_master.intrmdt_prdct_compnt,' ')),1, ' '));


         /*-*/
         /* Open Cursor for Inventory Line Output
         /*-*/
         open csr_matl_invntry;
         loop
            fetch csr_matl_invntry into rec_matl_invntry;
            if (csr_matl_invntry%notfound) then
               exit;
            end if;

            /*-*/
            /* Append Data Lines
            /*-*/
            lics_outbound_loader.append_data('INV' ||
                                             rpad(to_char(nvl(rec_matl_invntry.sap_company_code,' ')),6, ' ') ||
                                             rpad(to_char(nvl(rec_matl_invntry.sap_plant_code,' ')),4, ' ') ||
                                             rpad(to_char(nvl(rec_matl_invntry.inv_exp_date,' ')),8, ' ') ||
                                             rpad(to_char(nvl(rec_matl_invntry.inv_unreleased_qty,' ')),16, ' ') ||
                                             rpad(to_char(nvl(rec_matl_invntry.inv_reserved_qty,' ')),16, ' ') ||
                                             rpad(to_char(nvl(rec_matl_invntry.inv_class01,' ')),3, ' ') ||
                                             rpad(to_char(nvl(rec_matl_invntry.inv_class02,' ')),3, ' '));

         end loop;
         close csr_matl_invntry;

      end loop;
      close csr_matl_master;

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
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADCAD01 MATERIAL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladcad01_material;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad01_material for site_app.ladcad01_material;
grant execute on ladcad01_material to public;
