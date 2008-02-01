CREATE OR REPLACE package body ics_ladchn01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);


   /*-*/
   /* Constants
   /*-*/
   var_interface constant varchar2(8) := 'LADCHN01';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local Variables
      /*-*/
      var_instance number(15,0);
      var_count number;


      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_matl_master is
      select rpad(nvl(a.sap_material_code,' '),18,' ') ||
                rpad(nvl(a.material_desc_en,' '),40,' ') ||
                rpad(nvl(a.material_sts_code,' '),8,' ') ||
                rpad(nvl(a.material_sts_abbrd_desc,' '),20,' ') ||
                rpad(nvl(a.material_sts_desc,' '),60,' ') ||
                rpad(nvl(to_char(a.gross_wgt),' '),17,' ') ||
                rpad(nvl(to_char(a.net_wgt),' '),17,' ') ||
                rpad(nvl(a.sap_wgt_unit_code,' '),3,' ') ||
                rpad(nvl(a.wgt_unit_abbrd_desc,' '),15,' ') ||
                rpad(nvl(a.wgt_unit_desc,' '),40,' ') ||
                rpad(nvl(to_char(a.vol),' '),17,' ') ||
                rpad(nvl(a.sap_vol_unit_code,' '),3,' ') ||
                rpad(nvl(a.vol_unit_abbrd_desc,' '),15,' ') ||
                rpad(nvl(a.vol_unit_desc,' '),40,' ') ||
                rpad(nvl(a.sap_base_uom_code,' '),3,' ') ||
                rpad(nvl(a.base_uom_abbrd_desc,' '),15,' ') ||
                rpad(nvl(a.base_uom_desc,' '),40,' ') ||
                rpad(nvl(a.material_owner,' '),12,' ') ||
                rpad(nvl(a.sap_rep_item_code,' '),18,' ') ||
                rpad(nvl(a.rep_item_desc_en,' '),40,' ') ||
                rpad(nvl(a.sap_rpt_item_code,' '),18,' ') ||
                rpad(nvl(a.rpt_item_desc_en,' '),40,' ') ||
                rpad(nvl(to_char(a.mat_lead_time_days),' '),3,' ') ||
                rpad(nvl(a.old_material_code,' '),18,' ') ||
                rpad(nvl(a.material_type_flag_int,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_rsu,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_tdu,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_mcu,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_pro,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_sfp,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_sc,' '),1,' ') ||
                rpad(nvl(a.material_type_flag_rep,' '),1,' ') ||
                rpad(nvl(a.ean_upc,' '),18,' ') ||
                rpad(nvl(a.sap_ean_upc_ctgry_code,' '),2,' ') ||
                rpad(nvl(a.ean_upc_ctgry_desc,' '),40,' ') ||
                rpad(nvl(a.sap_material_division_code,' '),2,' ') ||
                rpad(nvl(a.material_division_desc,' '),40,' ') ||
                rpad(nvl(a.sap_material_type_code,' '),4,' ') ||
                rpad(nvl(a.material_type_desc,' '),40,' ') ||
                rpad(nvl(a.sap_bus_sgmnt_code,' '),4,' ') ||
                rpad(nvl(a.bus_sgmnt_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.bus_sgmnt_desc,' '),30,' ') ||
                rpad(nvl(a.sap_mkt_sgmnt_code,' '),4,' ') ||
                rpad(nvl(a.mkt_sgmnt_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.mkt_sgmnt_desc,' '),30,' ') ||
                rpad(nvl(a.sap_brand_essnc_code,' '),4,' ') ||
                rpad(nvl(a.brand_essnc_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.brand_essnc_desc,' '),30,' ') ||
                rpad(nvl(a.sap_brand_flag_code,' '),4,' ') ||
                rpad(nvl(a.brand_flag_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.brand_flag_desc,' '),30,' ') ||
                rpad(nvl(a.sap_brand_sub_flag_code,' '),4,' ') ||
                rpad(nvl(a.brand_sub_flag_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.brand_sub_flag_desc,' '),30,' ') ||
                rpad(nvl(a.sap_supply_sgmnt_code,' '),4,' ') ||
                rpad(nvl(a.supply_sgmnt_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.supply_sgmnt_desc,' '),30,' ') ||
                rpad(nvl(a.sap_ingred_vrty_code,' '),4,' ') ||
                rpad(nvl(a.ingred_vrty_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.ingred_vrty_desc,' '),30,' ') ||
                rpad(nvl(a.sap_funcl_vrty_code,' '),4,' ') ||
                rpad(nvl(a.funcl_vrty_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.funcl_vrty_desc,' '),30,' ') ||
                rpad(nvl(a.sap_occsn_code,' '),4,' ') ||
                rpad(nvl(a.occsn_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.occsn_desc,' '),30,' ') ||
                rpad(nvl(a.sap_prdct_ctgry_code,' '),4,' ') ||
                rpad(nvl(a.prdct_ctgry_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.prdct_ctgry_desc,' '),30,' ') ||
                rpad(nvl(a.sap_prdct_type_code,' '),4,' ') ||
                rpad(nvl(a.prdct_type_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.prdct_type_desc,' '),30,' ') ||
                rpad(nvl(a.sap_prdct_pack_size_code,' '),4,' ') ||
                rpad(nvl(a.prdct_pack_size_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.prdct_pack_size_desc,' '),30,' ') ||
                rpad(nvl(a.sap_cnsmr_pack_frmt_code,' '),4,' ') ||
                rpad(nvl(a.cnsmr_pack_frmt_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.cnsmr_pack_frmt_desc,' '),30,' ') ||
                rpad(nvl(a.sap_bdt_code,' '),2,' ') ||
                rpad(nvl(a.bdt_abbrd_desc,' '),12,' ') ||
                rpad(nvl(a.bdt_desc,' '),30,' ') ||
                rpad(nvl(b.fppsmoe,' '),30,' ') ||
                rpad(nvl(c.cs_each,' '),11,' ') ||
                rpad(nvl(d.sb_each,' '),11,' ') ||
                rpad(nvl(e.pc_each,' '),11,' ') as matl_master
         from material_dim a,
              (select ltrim(t01.matnr,'0') as matnr,
                      max(t02.zzfppsmoe) as fppsmoe
                 from lads_mat_mrc t01,
                      lads_mat_zmc t02
                where t01.matnr = t02.matnr
                  and t02.mrcseq = t02.mrcseq
                  and t01.werks = 'HK01'
                group by t01.matnr) b,
              (select ltrim(t21.matnr,'0') as matnr,
                      to_char(round((1/ t21.umrez) * t21.umren,5),'fm00000.00000') as cs_each
                 from lads_mat_uom t21
                where t21.meinh = 'CS') c,
              (select ltrim(t31.matnr,'0') as matnr,
                      to_char(round((1/ t31.umrez) * t31.umren,5),'fm00000.00000') as sb_each
                 from lads_mat_uom t31
                where t31.meinh = 'SB') d,
              (select ltrim(t41.matnr,'0') as matnr,
                      to_char(round((1/ t41.umrez) * t41.umren,5),'fm00000.00000') as pc_each
                 from lads_mat_uom t41
                where t41.meinh = 'PCE') e
         where a.sap_material_code = b.matnr(+)
           and a.sap_material_code = c.matnr(+)
           and a.sap_material_code = d.matnr(+)
           and a.sap_material_code = e.matnr(+)
         order by a.sap_material_code;
      rec_matl_master csr_matl_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin


      /*-*/
      /* Initialise Variables
      /*-*/
      var_count := 0;

      /*-*/
      /* Create Outbound Interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface(var_interface);

      /*-*/
      /* Write Header
      /*-*/
      lics_outbound_loader.append_data('HDRMAT01A');

      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_matl_master;
      loop
         fetch csr_matl_master into rec_matl_master;
         if (csr_matl_master%notfound) then
            exit;
         end if;

         lics_outbound_loader.append_data(rec_matl_master.matl_master);

         var_count := var_count+1;

      end loop;
      close csr_matl_master;

      /*-*/
      /* Write Trailer
      /*-*/
      lics_outbound_loader.append_data('TRA' || to_char(var_count,'FM0000000000'));

      /*-*/
      /* Finalise Interface
      /*-*/
      lics_outbound_loader.finalise_interface;


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
         /* Close Interface
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ics_ladchn01;
/

