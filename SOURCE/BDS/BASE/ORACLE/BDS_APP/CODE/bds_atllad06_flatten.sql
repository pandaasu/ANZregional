--
-- BDS_ATLLAD06_FLATTEN  (Package) 
--
CREATE OR REPLACE PACKAGE BDS_APP.bds_atllad06_flatten as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_atllad06_flatten
 Owner   : BDS_APP
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - ATLLAD06 - Classification Data (CLFMAS01)


 PARAMETERS
   1. PAR_ACTION [MANDATORY]
      *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
      *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
      *REFRESH             - process all unflattened LADS records
      *REBUILD             - process all LADS records - truncates BDS table(s) first
                           - RECOMMEND stopping ICS jobs prior to execution

   2. PAR_OBTAB [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
      Field from LADS document in LADS_CLA_HDR.OBTAB

   3. PAR_OBJEK [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
      Field from LADS document in LADS_CLA_HDR.OBJEK

   4. PAR_KLART [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
      Field from LADS document in LADS_CLA_HDR.KLART


 NOTES 
   1. This package must raise an exception on failure to exclude database activity from parent commit


 YYYY/MM   Author           Description
 -------   ------           -----------
 2006/11   Linden Glen      Created
 2006/11   Linden Glen      Added Raws and Packs classification columns
 2006/12   Linden Glen      Removed ltrim of '0' from material code
 2007/04   Steve Gregan     Removed ltrim of '0' from customer code
 2007/09   Linden Glen      Added ZZAUCUST01 to process_customer
 2008/01   Linden Glen      Added Z_APCHAR10 to 13 to process_material
                            Added CLFFERT109, ZZCNCUST01, ZZCNCUST02, ZZCNCUST03, ZZCNCUST04,
                                ZZCNCUST05, ZZAUCUST01, ZZAUCUST02 to process_customer
 2009/04   Trevor Keon      Added Z_APCHAR14 and 15 to process_material   
 2011/01   Ben Halicki      Added ZZTHCUST01, ZZTHCUST02, ZZTHCUST03, ZZTHCUST04 for Atlas Thailand 
 2011/03   Ben Halicki      Added Z_APCHAR16, Z_APCHAR17, Z_APCHAR18, Z_APCHAR19, Z_APCHAR20, Z_APCHAR21, 
                                Z_APVERP01, Z_APVERP02, Z_APCHAR22, Z_APCHAR23
 2011/07   Edward Rousseau  Bugfix for ZZTHCUST01 (was picking up data for ZZTHCUST02) ref CR 73958

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_obtab in varchar2, par_objek in varchar2, par_klart in varchar2);

end bds_atllad06_flatten;
/

--
-- BDS_ATLLAD06_FLATTEN  (Synonym) 
--
CREATE PUBLIC SYNONYM BDS_ATLLAD06_FLATTEN FOR BDS_APP.BDS_ATLLAD06_FLATTEN;


GRANT EXECUTE ON BDS_APP.BDS_ATLLAD06_FLATTEN TO LADS_APP;

GRANT EXECUTE ON BDS_APP.BDS_ATLLAD06_FLATTEN TO LICS_APP;


--
-- BDS_ATLLAD06_FLATTEN  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY BDS_APP.bds_atllad06_flatten as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   snapshot_exception exception;
   pragma exception_init(application_exception, -20000);
   pragma exception_init(snapshot_exception, -1555);

   /*-*/
   /* Private declarations
   /*-*/
   procedure lads_lock(par_obtab in varchar2, par_objek in varchar2, par_klart in varchar2);
   procedure bds_flatten(par_obtab in varchar2, par_objek in varchar2, par_klart in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;
   /*-*/
   procedure process_material(par_objek in varchar2);
   procedure process_customer(par_objek in varchar2);


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_obtab in varchar2, par_objek in varchar2, par_klart in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/   
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_obtab, par_objek, par_klart);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_obtab, par_objek, par_klart);
        when '*REFRESH' then bds_refresh;
        when '*REBUILD' then bds_rebuild;
        else raise_application_error(-20000, 'Action parameter must be *DOCUMENT, *DOCUMENT_OVERRIDE, *REFRESH or *REBUILD');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_ATLLAD06_FLATTEN - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_obtab in varchar2, par_objek in varchar2, par_klart in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_excluded := false;
      var_flattened := '1';

      /*-*/
      /* Process data based on classification type
      /*  notes : data not conforming to filters below will not be processed to BDS
      /*          skipped records will have a LADS_FLATTENED status of 2 (skipped/excluded)
      /*-*/   
      case 
         when par_obtab = 'MARA' and par_klart = '001' then process_material(par_objek);
         when par_obtab = 'KNA1' and par_klart = '011' then process_customer(par_objek);
         else var_excluded := true;
      end case;


      /*-*/
      /* Perform exclusion processing
      /*-*/   
      if (var_excluded) then
         var_flattened := '2';
      end if;


      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/   
      update lads_cla_hdr
         set lads_flattened = var_flattened
       where obtab = par_obtab
         and objek = par_objek
         and klart = par_klart;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_FLATTEN -  ' 
                                         || 'OBTAB/OBJEK/KLART: ' 
                                         || nvl(par_obtab,'null') || '/' || nvl(par_objek,'null') || '/' || nvl(par_klart,'null') || ' - '
                                         || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_flatten;


   /***********************************************************************/
   /* This procedure performs the flatten material classification routine */
   /***********************************************************************/
   procedure process_material(par_objek in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_material_classfctn bds_material_classfctn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_classfctn is
         select t01.objek as sap_material_code,
                max(case when t02.atnam = 'CLFFERT01' then t02.atwrt end) as sap_bus_sgmnt_code,
                max(case when t02.atnam = 'CLFFERT02' then t02.atwrt end) as sap_mrkt_sgmnt_code,
                max(case when t02.atnam = 'CLFFERT03' then t02.atwrt end) as sap_brand_flag_code,
                max(case when t02.atnam = 'CLFFERT07' then t02.atwrt end) as sap_funcl_vrty_code,
                max(case when t02.atnam = 'CLFFERT06' then t02.atwrt end) as sap_ingrdnt_vrty_code,
                max(case when t02.atnam = 'CLFFERT04' then t02.atwrt end) as sap_brand_sub_flag_code,
                max(case when t02.atnam = 'CLFFERT05' then t02.atwrt end) as sap_supply_sgmnt_code,
                max(case when t02.atnam = 'CLFFERT08' then t02.atwrt end) as sap_trade_sector_code,
                max(case when t02.atnam = 'CLFFERT11' then t02.atwrt end) as sap_occsn_code,
                max(case when t02.atnam = 'CLFFERT09' then t02.atwrt end) as sap_mrkting_concpt_code,
                max(case when t02.atnam = 'CLFFERT10' then t02.atwrt end) as sap_multi_pack_qty_code,
                max(case when t02.atnam = 'CLFFERT12' then t02.atwrt end) as sap_prdct_ctgry_code,
                max(case when t02.atnam = 'CLFFERT17' then t02.atwrt end) as sap_pack_type_code,
                max(case when t02.atnam = 'CLFFERT14' then t02.atwrt end) as sap_size_code,
                max(case when t02.atnam = 'CLFFERT18' then t02.atwrt end) as sap_size_grp_code,
                max(case when t02.atnam = 'CLFFERT13' then t02.atwrt end) as sap_prdct_type_code,
                max(case when t02.atnam = 'CLFFERT21' then t02.atwrt end) as sap_trad_unit_config_code,
                max(case when t02.atnam = 'CLFFERT20' then t02.atwrt end) as sap_trad_unit_frmt_code,
                max(case when t02.atnam = 'CLFFERT19' then t02.atwrt end) as sap_dsply_storg_condtn_code,
                max(case when t02.atnam = 'CLFFERT22' then t02.atwrt end) as sap_onpack_cnsmr_value_code,
                max(case when t02.atnam = 'CLFFERT23' then t02.atwrt end) as sap_onpack_cnsmr_offer_code,
                max(case when t02.atnam = 'CLFFERT24' then t02.atwrt end) as sap_onpack_trade_offer_code,
                max(case when t02.atnam = 'CLFFERT16' then t02.atwrt end) as sap_brand_essnc_code,
                max(case when t02.atnam = 'CLFFERT25' then t02.atwrt end) as sap_cnsmr_pack_frmt_code,
                max(case when t02.atnam = 'CLFFERT40' then t02.atwrt end) as sap_cuisine_code,
                max(case when t02.atnam = 'CLFFERT38' then t02.atwrt end) as sap_fpps_minor_pack_code,
                max(case when t02.atnam = 'Z_APCHAR1' then t02.atwrt end) as sap_mrkt_ctgry_code,
                max(case when t02.atnam = 'Z_APCHAR2' then t02.atwrt end) as sap_mrkt_sub_ctgry_code,
                max(case when t02.atnam = 'Z_APCHAR3' then t02.atwrt end) as sap_mrkt_sub_ctgry_grp_code,
                max(case when t02.atnam = 'Z_APCHAR4' then t02.atwrt end) as sap_sop_bus_code,
                max(case when t02.atnam = 'Z_APCHAR5' then t02.atwrt end) as sap_prodctn_line_code,
                max(case when t02.atnam = 'Z_APCHAR6' then t02.atwrt end) as sap_fighting_unit_code,
                max(case when t02.atnam = 'Z_APCHAR7' then t02.atwrt end) as sap_china_bdt_code,
                max(case when t02.atnam = 'Z_APCHAR8' then t02.atwrt end) as sap_planning_src_code,
                max(case when t02.atnam = 'Z_APCHAR9' then t02.atwrt end) as sap_sub_fighting_unit_code,
                max(case when t02.atnam = 'Z_APCHAR10' then t02.atwrt end) as sap_china_abc_indctr_code,
                max(case when t02.atnam = 'Z_APCHAR11' then t02.atwrt end) as sap_nz_promotional_grp_code,
                max(case when t02.atnam = 'Z_APCHAR12' then t02.atwrt end) as sap_nz_sop_business_code,
                max(case when t02.atnam = 'Z_APCHAR13' then t02.atwrt end) as sap_nz_must_win_ctgry_code,
                max(case when t02.atnam = 'Z_APCHAR14' then t02.atwrt end) as sap_au_snk_activity_name,
                max(case when t02.atnam = 'Z_APCHAR15' then t02.atwrt end) as sap_china_forecast_group,
                max(case when t02.atnam = 'Z_APCHAR16' then t02.atwrt end) as sap_hk_sub_ctgry_code,
                max(case when t02.atnam = 'Z_APCHAR17' then t02.atwrt end) as sap_hk_line_code,
                max(case when t02.atnam = 'Z_APCHAR18' then t02.atwrt end) as sap_hk_product_sgmnt_code,
                max(case when t02.atnam = 'Z_APCHAR19' then t02.atwrt end) as sap_hk_type_code,
                max(case when t02.atnam = 'Z_APCHAR20' then t02.atwrt end) as sap_strgy_grp_code,
                max(case when t02.atnam = 'Z_APCHAR21' then t02.atwrt end) as sap_th_boi_code,
                max(case when t02.atnam = 'Z_APCHAR22' then t02.atwrt end) as sap_nz_launch_ranking_code,
                max(case when t02.atnam = 'Z_APCHAR23' then t02.atwrt end) as sap_nz_selectively_grow_code,
                max(case when t02.atnam = 'Z_APVERP01' then t02.atwrt end) as sap_pack_dspsal_class,
                max(case when t02.atnam = 'Z_APVERP02' then t02.atwrt end) as sap_th_boi_grp_code,
                max(case when t02.atnam = 'CLFROH01' then t02.atwrt end) as sap_raw_family_code,
                max(case when t02.atnam = 'CLFROH02' then t02.atwrt end) as sap_raw_sub_family_code,
                max(case when t02.atnam = 'CLFROH03' then t02.atwrt end) as sap_raw_group_code,
                max(case when t02.atnam = 'CLFROH04' then t02.atwrt end) as sap_animal_parts_code,
                max(case when t02.atnam = 'CLFROH05' then t02.atwrt end) as sap_physical_condtn_code,
                max(case when t02.atnam = 'CLFVERP01' then t02.atwrt end) as sap_pack_family_code,
                max(case when t02.atnam = 'CLFVERP02' then t02.atwrt end) as sap_pack_sub_family_code,
                max(t01.idoc_name) as sap_idoc_name,
                max(t01.idoc_number) as sap_idoc_number,
                max(t01.idoc_timestamp) as sap_idoc_timestamp,
                max(t01.lads_date) as bds_lads_date,
                max(t01.lads_status) as bds_lads_status
         from lads_cla_hdr t01,
              lads_cla_chr t02
         where t01.obtab = t02.obtab(+)
           and t01.objek = t02.objek(+)
           and t01.klart = t02.klart(+)
           and t01.obtab = 'MARA'
           and t01.klart = '001'
           and t01.objek = par_objek
         group by t01.objek;
      rcd_lads_mat_classfctn csr_lads_mat_classfctn%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform BDS Flattening Logic
      /* **note** - process only material classification data
      /*          - assumes that a lock is held in a parent procedure
      /*          - assumes commit/rollback will be issued in a parent procedure
      /*-*/
      open csr_lads_mat_classfctn;
      fetch csr_lads_mat_classfctn into rcd_lads_mat_classfctn;
      if (csr_lads_mat_classfctn%notfound) then
         raise_application_error(-20000, 'Material Classification cursor not found');
      end if;
      close csr_lads_mat_classfctn;

      rcd_bds_material_classfctn.sap_material_code := rcd_lads_mat_classfctn.sap_material_code;
      rcd_bds_material_classfctn.bds_lads_date := rcd_lads_mat_classfctn.bds_lads_date;
      rcd_bds_material_classfctn.bds_lads_status := rcd_lads_mat_classfctn.bds_lads_status;
      rcd_bds_material_classfctn.sap_idoc_name := rcd_lads_mat_classfctn.sap_idoc_name;
      rcd_bds_material_classfctn.sap_idoc_number := rcd_lads_mat_classfctn.sap_idoc_number;
      rcd_bds_material_classfctn.sap_idoc_timestamp := rcd_lads_mat_classfctn.sap_idoc_timestamp;
      rcd_bds_material_classfctn.sap_bus_sgmnt_code := rcd_lads_mat_classfctn.sap_bus_sgmnt_code;
      rcd_bds_material_classfctn.sap_mrkt_sgmnt_code := rcd_lads_mat_classfctn.sap_mrkt_sgmnt_code;
      rcd_bds_material_classfctn.sap_brand_flag_code := rcd_lads_mat_classfctn.sap_brand_flag_code;
      rcd_bds_material_classfctn.sap_funcl_vrty_code := rcd_lads_mat_classfctn.sap_funcl_vrty_code;
      rcd_bds_material_classfctn.sap_ingrdnt_vrty_code := rcd_lads_mat_classfctn.sap_ingrdnt_vrty_code;
      rcd_bds_material_classfctn.sap_brand_sub_flag_code := rcd_lads_mat_classfctn.sap_brand_sub_flag_code;
      rcd_bds_material_classfctn.sap_supply_sgmnt_code := rcd_lads_mat_classfctn.sap_supply_sgmnt_code;
      rcd_bds_material_classfctn.sap_trade_sector_code := rcd_lads_mat_classfctn.sap_trade_sector_code;
      rcd_bds_material_classfctn.sap_occsn_code := rcd_lads_mat_classfctn.sap_occsn_code;
      rcd_bds_material_classfctn.sap_mrkting_concpt_code := rcd_lads_mat_classfctn.sap_mrkting_concpt_code;
      rcd_bds_material_classfctn.sap_multi_pack_qty_code := rcd_lads_mat_classfctn.sap_multi_pack_qty_code;
      rcd_bds_material_classfctn.sap_prdct_ctgry_code := rcd_lads_mat_classfctn.sap_prdct_ctgry_code;
      rcd_bds_material_classfctn.sap_pack_type_code := rcd_lads_mat_classfctn.sap_pack_type_code;
      rcd_bds_material_classfctn.sap_size_code := rcd_lads_mat_classfctn.sap_size_code;
      rcd_bds_material_classfctn.sap_size_grp_code := rcd_lads_mat_classfctn.sap_size_grp_code;
      rcd_bds_material_classfctn.sap_prdct_type_code := rcd_lads_mat_classfctn.sap_prdct_type_code;
      rcd_bds_material_classfctn.sap_trad_unit_config_code := rcd_lads_mat_classfctn.sap_trad_unit_config_code;
      rcd_bds_material_classfctn.sap_trad_unit_frmt_code := rcd_lads_mat_classfctn.sap_trad_unit_frmt_code;
      rcd_bds_material_classfctn.sap_dsply_storg_condtn_code := rcd_lads_mat_classfctn.sap_dsply_storg_condtn_code;
      rcd_bds_material_classfctn.sap_onpack_cnsmr_value_code := rcd_lads_mat_classfctn.sap_onpack_cnsmr_value_code;
      rcd_bds_material_classfctn.sap_onpack_cnsmr_offer_code := rcd_lads_mat_classfctn.sap_onpack_cnsmr_offer_code;
      rcd_bds_material_classfctn.sap_onpack_trade_offer_code := rcd_lads_mat_classfctn.sap_onpack_trade_offer_code;
      rcd_bds_material_classfctn.sap_brand_essnc_code := rcd_lads_mat_classfctn.sap_brand_essnc_code;
      rcd_bds_material_classfctn.sap_cnsmr_pack_frmt_code := rcd_lads_mat_classfctn.sap_cnsmr_pack_frmt_code;
      rcd_bds_material_classfctn.sap_cuisine_code := rcd_lads_mat_classfctn.sap_cuisine_code;
      rcd_bds_material_classfctn.sap_fpps_minor_pack_code := rcd_lads_mat_classfctn.sap_fpps_minor_pack_code;
      rcd_bds_material_classfctn.sap_fighting_unit_code := rcd_lads_mat_classfctn.sap_fighting_unit_code;
      rcd_bds_material_classfctn.sap_china_bdt_code := rcd_lads_mat_classfctn.sap_china_bdt_code;
      rcd_bds_material_classfctn.sap_mrkt_ctgry_code := rcd_lads_mat_classfctn.sap_mrkt_ctgry_code;
      rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_code := rcd_lads_mat_classfctn.sap_mrkt_sub_ctgry_code;
      rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_grp_code := rcd_lads_mat_classfctn.sap_mrkt_sub_ctgry_grp_code;
      rcd_bds_material_classfctn.sap_sop_bus_code := rcd_lads_mat_classfctn.sap_sop_bus_code;
      rcd_bds_material_classfctn.sap_prodctn_line_code := rcd_lads_mat_classfctn.sap_prodctn_line_code;
      rcd_bds_material_classfctn.sap_planning_src_code := rcd_lads_mat_classfctn.sap_planning_src_code;
      rcd_bds_material_classfctn.sap_sub_fighting_unit_code := rcd_lads_mat_classfctn.sap_sub_fighting_unit_code;
      rcd_bds_material_classfctn.sap_raw_family_code := rcd_lads_mat_classfctn.sap_raw_family_code;
      rcd_bds_material_classfctn.sap_raw_sub_family_code := rcd_lads_mat_classfctn.sap_raw_sub_family_code;
      rcd_bds_material_classfctn.sap_raw_group_code := rcd_lads_mat_classfctn.sap_raw_group_code;
      rcd_bds_material_classfctn.sap_animal_parts_code := rcd_lads_mat_classfctn.sap_animal_parts_code;
      rcd_bds_material_classfctn.sap_physical_condtn_code := rcd_lads_mat_classfctn.sap_physical_condtn_code;
      rcd_bds_material_classfctn.sap_pack_family_code := rcd_lads_mat_classfctn.sap_pack_family_code;
      rcd_bds_material_classfctn.sap_pack_sub_family_code := rcd_lads_mat_classfctn.sap_pack_sub_family_code;
      rcd_bds_material_classfctn.sap_china_abc_indctr_code := rcd_lads_mat_classfctn.sap_china_abc_indctr_code;
      rcd_bds_material_classfctn.sap_nz_promotional_grp_code := rcd_lads_mat_classfctn.sap_nz_promotional_grp_code;
      rcd_bds_material_classfctn.sap_nz_sop_business_code := rcd_lads_mat_classfctn.sap_nz_sop_business_code;
      rcd_bds_material_classfctn.sap_nz_must_win_ctgry_code := rcd_lads_mat_classfctn.sap_nz_must_win_ctgry_code;
      rcd_bds_material_classfctn.sap_au_snk_activity_name := rcd_lads_mat_classfctn.sap_au_snk_activity_name;
      rcd_bds_material_classfctn.sap_china_forecast_group := rcd_lads_mat_classfctn.sap_china_forecast_group;      
      rcd_bds_material_classfctn.sap_hk_sub_ctgry_code := rcd_lads_mat_classfctn.sap_hk_sub_ctgry_code;  
      rcd_bds_material_classfctn.sap_hk_line_code := rcd_lads_mat_classfctn.sap_hk_sub_ctgry_code;        
      rcd_bds_material_classfctn.sap_hk_product_sgmnt_code := rcd_lads_mat_classfctn.sap_hk_product_sgmnt_code;    
      rcd_bds_material_classfctn.sap_hk_type_code := rcd_lads_mat_classfctn.sap_hk_type_code;            
      rcd_bds_material_classfctn.sap_strgy_grp_code := rcd_lads_mat_classfctn.sap_strgy_grp_code;          
      rcd_bds_material_classfctn.sap_th_boi_code := rcd_lads_mat_classfctn.sap_th_boi_code;            
      rcd_bds_material_classfctn.sap_pack_dspsal_class := rcd_lads_mat_classfctn.sap_pack_dspsal_class;     
      rcd_bds_material_classfctn.sap_th_boi_grp_code := rcd_lads_mat_classfctn.sap_th_boi_grp_code;      
      rcd_bds_material_classfctn.sap_nz_launch_ranking_code := rcd_lads_mat_classfctn.sap_nz_launch_ranking_code;
      rcd_bds_material_classfctn.sap_nz_selectively_grow_code := rcd_lads_mat_classfctn.sap_nz_selectively_grow_code;   

      /*-*/
      /* UPDATE BDS, INSERT when new record
      /*-*/
      update bds_material_classfctn
         set bds_lads_date = rcd_bds_material_classfctn.bds_lads_date,
             bds_lads_status = rcd_bds_material_classfctn.bds_lads_status,
             sap_idoc_name = rcd_bds_material_classfctn.sap_idoc_name,
             sap_idoc_number = rcd_bds_material_classfctn.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_material_classfctn.sap_idoc_timestamp,
             sap_bus_sgmnt_code = rcd_bds_material_classfctn.sap_bus_sgmnt_code,
             sap_mrkt_sgmnt_code = rcd_bds_material_classfctn.sap_mrkt_sgmnt_code,
             sap_brand_flag_code = rcd_bds_material_classfctn.sap_brand_flag_code,
             sap_funcl_vrty_code = rcd_bds_material_classfctn.sap_funcl_vrty_code,
             sap_ingrdnt_vrty_code = rcd_bds_material_classfctn.sap_ingrdnt_vrty_code,
             sap_brand_sub_flag_code = rcd_bds_material_classfctn.sap_brand_sub_flag_code,
             sap_supply_sgmnt_code = rcd_bds_material_classfctn.sap_supply_sgmnt_code,
             sap_trade_sector_code = rcd_bds_material_classfctn.sap_trade_sector_code,
             sap_occsn_code = rcd_bds_material_classfctn.sap_occsn_code,
             sap_mrkting_concpt_code = rcd_bds_material_classfctn.sap_mrkting_concpt_code,
             sap_multi_pack_qty_code = rcd_bds_material_classfctn.sap_multi_pack_qty_code,
             sap_prdct_ctgry_code = rcd_bds_material_classfctn.sap_prdct_ctgry_code,
             sap_pack_type_code = rcd_bds_material_classfctn.sap_pack_type_code,
             sap_size_code = rcd_bds_material_classfctn.sap_size_code,
             sap_size_grp_code = rcd_bds_material_classfctn.sap_size_grp_code,
             sap_prdct_type_code = rcd_bds_material_classfctn.sap_prdct_type_code,
             sap_trad_unit_config_code = rcd_bds_material_classfctn.sap_trad_unit_config_code,
             sap_trad_unit_frmt_code = rcd_bds_material_classfctn.sap_trad_unit_frmt_code,
             sap_dsply_storg_condtn_code = rcd_bds_material_classfctn.sap_dsply_storg_condtn_code,
             sap_onpack_cnsmr_value_code = rcd_bds_material_classfctn.sap_onpack_cnsmr_value_code,
             sap_onpack_cnsmr_offer_code = rcd_bds_material_classfctn.sap_onpack_cnsmr_offer_code,
             sap_onpack_trade_offer_code = rcd_bds_material_classfctn.sap_onpack_trade_offer_code,
             sap_brand_essnc_code = rcd_bds_material_classfctn.sap_brand_essnc_code,
             sap_cnsmr_pack_frmt_code = rcd_bds_material_classfctn.sap_cnsmr_pack_frmt_code,
             sap_cuisine_code = rcd_bds_material_classfctn.sap_cuisine_code,
             sap_fpps_minor_pack_code = rcd_bds_material_classfctn.sap_fpps_minor_pack_code,
             sap_fighting_unit_code = rcd_bds_material_classfctn.sap_fighting_unit_code,
             sap_china_bdt_code = rcd_bds_material_classfctn.sap_china_bdt_code,
             sap_mrkt_ctgry_code = rcd_bds_material_classfctn.sap_mrkt_ctgry_code,
             sap_mrkt_sub_ctgry_code = rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_code,
             sap_mrkt_sub_ctgry_grp_code = rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_grp_code,
             sap_sop_bus_code = rcd_bds_material_classfctn.sap_sop_bus_code,
             sap_prodctn_line_code = rcd_bds_material_classfctn.sap_prodctn_line_code,
             sap_planning_src_code = rcd_bds_material_classfctn.sap_planning_src_code,
             sap_sub_fighting_unit_code = rcd_bds_material_classfctn.sap_sub_fighting_unit_code,
             sap_raw_family_code = rcd_bds_material_classfctn.sap_raw_family_code,
             sap_raw_sub_family_code = rcd_bds_material_classfctn.sap_raw_sub_family_code,
             sap_raw_group_code = rcd_bds_material_classfctn.sap_raw_group_code,
             sap_animal_parts_code = rcd_bds_material_classfctn.sap_animal_parts_code,
             sap_physical_condtn_code = rcd_bds_material_classfctn.sap_physical_condtn_code,
             sap_pack_family_code = rcd_bds_material_classfctn.sap_pack_family_code,
             sap_pack_sub_family_code = rcd_bds_material_classfctn.sap_pack_sub_family_code,
             sap_china_abc_indctr_code = rcd_bds_material_classfctn.sap_china_abc_indctr_code,
             sap_nz_promotional_grp_code = rcd_bds_material_classfctn.sap_nz_promotional_grp_code,
             sap_nz_sop_business_code = rcd_bds_material_classfctn.sap_nz_sop_business_code,
             sap_nz_must_win_ctgry_code = rcd_bds_material_classfctn.sap_nz_must_win_ctgry_code,
             sap_au_snk_activity_name = rcd_bds_material_classfctn.sap_au_snk_activity_name,
             sap_china_forecast_group = rcd_bds_material_classfctn.sap_china_forecast_group,
             sap_hk_sub_ctgry_code = rcd_bds_material_classfctn.sap_hk_sub_ctgry_code,       
             sap_hk_line_code = rcd_bds_material_classfctn.sap_hk_line_code,            
             sap_hk_product_sgmnt_code = rcd_bds_material_classfctn.sap_hk_product_sgmnt_code,   
             sap_hk_type_code = rcd_bds_material_classfctn.sap_hk_type_code,            
             sap_strgy_grp_code = rcd_bds_material_classfctn.sap_strgy_grp_code,          
             sap_th_boi_code = rcd_bds_material_classfctn.sap_th_boi_code,             
             sap_pack_dspsal_class = rcd_bds_material_classfctn.sap_pack_dspsal_class,     
             sap_th_boi_grp_code = rcd_bds_material_classfctn.sap_th_boi_grp_code,
             sap_nz_launch_ranking_code = rcd_bds_material_classfctn.sap_nz_launch_ranking_code,
             sap_nz_selectively_grow_code = rcd_bds_material_classfctn.sap_nz_selectively_grow_code         
         where sap_material_code = rcd_bds_material_classfctn.sap_material_code;
      if (sql%notfound) then
         insert into bds_material_classfctn
            (sap_material_code,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             sap_bus_sgmnt_code,
             sap_mrkt_sgmnt_code,
             sap_brand_flag_code,
             sap_funcl_vrty_code,
             sap_ingrdnt_vrty_code,
             sap_brand_sub_flag_code,
             sap_supply_sgmnt_code,
             sap_trade_sector_code,
             sap_occsn_code,
             sap_mrkting_concpt_code,
             sap_multi_pack_qty_code,
             sap_prdct_ctgry_code,
             sap_pack_type_code,
             sap_size_code,
             sap_size_grp_code,
             sap_prdct_type_code,
             sap_trad_unit_config_code,
             sap_trad_unit_frmt_code,
             sap_dsply_storg_condtn_code,
             sap_onpack_cnsmr_value_code,
             sap_onpack_cnsmr_offer_code,
             sap_onpack_trade_offer_code,
             sap_brand_essnc_code,
             sap_cnsmr_pack_frmt_code,
             sap_cuisine_code,
             sap_fpps_minor_pack_code,
             sap_fighting_unit_code,
             sap_china_bdt_code,
             sap_mrkt_ctgry_code,
             sap_mrkt_sub_ctgry_code,
             sap_mrkt_sub_ctgry_grp_code,
             sap_sop_bus_code,
             sap_prodctn_line_code,
             sap_planning_src_code,
             sap_sub_fighting_unit_code,
             sap_raw_family_code,
             sap_raw_sub_family_code,
             sap_raw_group_code,
             sap_animal_parts_code,
             sap_physical_condtn_code,
             sap_pack_family_code,
             sap_pack_sub_family_code,
             sap_china_abc_indctr_code,
             sap_nz_promotional_grp_code,
             sap_nz_sop_business_code,
             sap_nz_must_win_ctgry_code,
             sap_au_snk_activity_name,
             sap_china_forecast_group,
             sap_hk_sub_ctgry_code,        
             sap_hk_line_code,             
             sap_hk_product_sgmnt_code,    
             sap_hk_type_code,             
             sap_strgy_grp_code,           
             sap_th_boi_code,
             sap_pack_dspsal_class,      
             sap_th_boi_grp_code,
             sap_nz_launch_ranking_code,
             sap_nz_selectively_grow_code          
            )
           values
            (rcd_bds_material_classfctn.sap_material_code,
             rcd_bds_material_classfctn.sap_idoc_name,
             rcd_bds_material_classfctn.sap_idoc_number,
             rcd_bds_material_classfctn.sap_idoc_timestamp,
             rcd_bds_material_classfctn.bds_lads_date,
             rcd_bds_material_classfctn.bds_lads_status,
             rcd_bds_material_classfctn.sap_bus_sgmnt_code,
             rcd_bds_material_classfctn.sap_mrkt_sgmnt_code,
             rcd_bds_material_classfctn.sap_brand_flag_code,
             rcd_bds_material_classfctn.sap_funcl_vrty_code,
             rcd_bds_material_classfctn.sap_ingrdnt_vrty_code,
             rcd_bds_material_classfctn.sap_brand_sub_flag_code,
             rcd_bds_material_classfctn.sap_supply_sgmnt_code,
             rcd_bds_material_classfctn.sap_trade_sector_code,
             rcd_bds_material_classfctn.sap_occsn_code,
             rcd_bds_material_classfctn.sap_mrkting_concpt_code,
             rcd_bds_material_classfctn.sap_multi_pack_qty_code,
             rcd_bds_material_classfctn.sap_prdct_ctgry_code,
             rcd_bds_material_classfctn.sap_pack_type_code,
             rcd_bds_material_classfctn.sap_size_code,
             rcd_bds_material_classfctn.sap_size_grp_code,
             rcd_bds_material_classfctn.sap_prdct_type_code,
             rcd_bds_material_classfctn.sap_trad_unit_config_code,
             rcd_bds_material_classfctn.sap_trad_unit_frmt_code,
             rcd_bds_material_classfctn.sap_dsply_storg_condtn_code,
             rcd_bds_material_classfctn.sap_onpack_cnsmr_value_code,
             rcd_bds_material_classfctn.sap_onpack_cnsmr_offer_code,
             rcd_bds_material_classfctn.sap_onpack_trade_offer_code,
             rcd_bds_material_classfctn.sap_brand_essnc_code,
             rcd_bds_material_classfctn.sap_cnsmr_pack_frmt_code,
             rcd_bds_material_classfctn.sap_cuisine_code,
             rcd_bds_material_classfctn.sap_fpps_minor_pack_code,
             rcd_bds_material_classfctn.sap_fighting_unit_code,
             rcd_bds_material_classfctn.sap_china_bdt_code,
             rcd_bds_material_classfctn.sap_mrkt_ctgry_code,
             rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_code,
             rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_grp_code,
             rcd_bds_material_classfctn.sap_sop_bus_code,
             rcd_bds_material_classfctn.sap_prodctn_line_code,
             rcd_bds_material_classfctn.sap_planning_src_code,
             rcd_bds_material_classfctn.sap_sub_fighting_unit_code,
             rcd_bds_material_classfctn.sap_raw_family_code,
             rcd_bds_material_classfctn.sap_raw_sub_family_code,
             rcd_bds_material_classfctn.sap_raw_group_code,
             rcd_bds_material_classfctn.sap_animal_parts_code,
             rcd_bds_material_classfctn.sap_physical_condtn_code,
             rcd_bds_material_classfctn.sap_pack_family_code,
             rcd_bds_material_classfctn.sap_pack_sub_family_code,
             rcd_bds_material_classfctn.sap_china_abc_indctr_code,
             rcd_bds_material_classfctn.sap_nz_promotional_grp_code,
             rcd_bds_material_classfctn.sap_nz_sop_business_code,
             rcd_bds_material_classfctn.sap_nz_must_win_ctgry_code,
             rcd_bds_material_classfctn.sap_au_snk_activity_name,
             rcd_bds_material_classfctn.sap_china_forecast_group,
             rcd_bds_material_classfctn.sap_hk_sub_ctgry_code,        
             rcd_bds_material_classfctn.sap_hk_line_code,             
             rcd_bds_material_classfctn.sap_hk_product_sgmnt_code,    
             rcd_bds_material_classfctn.sap_hk_type_code,             
             rcd_bds_material_classfctn.sap_strgy_grp_code,           
             rcd_bds_material_classfctn.sap_th_boi_code,              
             rcd_bds_material_classfctn.sap_pack_dspsal_class,      
             rcd_bds_material_classfctn.sap_th_boi_grp_code,
             rcd_bds_material_classfctn.sap_nz_launch_ranking_code,
             rcd_bds_material_classfctn.sap_nz_selectively_grow_code                            
             );
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
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_material;


   /***********************************************************************/
   /* This procedure performs the flatten customer classification routine */
   /***********************************************************************/
   procedure process_customer(par_objek in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_customer_classfctn bds_customer_classfctn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_cus_classfctn is
         select t01.objek as sap_customer_code,
                max(case when t02.atnam = 'CLFFERT36' then t02.atwrt end) as sap_cust_buying_grp_code,
                max(case when t02.atnam = 'CLFFERT37' then t02.atwrt end) as sap_multi_mrkt_acct_code,
                max(case when t02.atnam = 'CLFFERT41' then t02.atwrt end) as sap_pos_frmt_grp_code,
                max(case when t02.atnam = 'CLFFERT101' then t02.atwrt end) as sap_pos_frmt_code,
                max(case when t02.atnam = 'CLFFERT102' then t02.atwrt end) as sap_pos_frmt_size_code,
                max(case when t02.atnam = 'CLFFERT103' then t02.atwrt end) as sap_pos_place_code,
                max(case when t02.atnam = 'CLFFERT104' then t02.atwrt end) as sap_banner_code,
                max(case when t02.atnam = 'CLFFERT105' then t02.atwrt end) as sap_ultmt_prnt_acct_code,
                max(case when t02.atnam = 'CLFFERT106' then t02.atwrt end) as sap_dstrbtn_route_code,
                max(case when t02.atnam = 'CLFFERT107' then t02.atwrt end) as sap_prim_route_to_cnsmr_code,
                max(case when t02.atnam = 'CLFFERT108' then t02.atwrt end) as sap_operation_bus_model_code,
                max(case when t02.atnam = 'CLFFERT109' then t02.atwrt end) as sap_ap_cust_grp_food_code,
                max(case when t02.atnam = 'ZZAUCUST01' then t02.atwrt end) as sap_fundrsng_sales_trrtry_code,
                max(case when t02.atnam = 'ZZAUCUST02' then t02.atwrt end) as sap_fundrsng_grp_type_code,
                max(case when t02.atnam = 'ZZCNCUST01' then t02.atwrt end) as sap_cn_sales_team_code,
                max(case when t02.atnam = 'ZZCNCUST02' then t02.atwrt end) as sap_petcare_city_tier_code,
                max(case when t02.atnam = 'ZZCNCUST03' then t02.atwrt end) as sap_snackfood_city_tier_code,
                max(case when t02.atnam = 'ZZCNCUST04' then t02.atwrt end) as sap_channel_code,
                max(case when t02.atnam = 'ZZCNCUST05' then t02.atwrt end) as sap_sub_channel_code,
                max(case when t02.atnam = 'ZZTHCUST01' then t02.atwrt end) as sap_th_channel_code,
                max(case when t02.atnam = 'ZZTHCUST02' then t02.atwrt end) as sap_th_sub_channel_code,
                max(case when t02.atnam = 'ZZTHCUST03' then t02.atwrt end) as sap_th_sales_area_neg_code,
                max(case when t02.atnam = 'ZZTHCUST04' then t02.atwrt end) as sap_th_sales_area_geo_code,                   
                max(t01.idoc_name) as sap_idoc_name,
                max(t01.idoc_number) as sap_idoc_number,
                max(t01.idoc_timestamp) as sap_idoc_timestamp,
                max(t01.lads_date) as bds_lads_date,
                max(t01.lads_status) as bds_lads_status
         from lads_cla_hdr t01,
              lads_cla_chr t02
         where t01.obtab = t02.obtab(+)
           and t01.objek = t02.objek(+)
           and t01.klart = t02.klart(+)
           and t01.obtab = 'KNA1'
           and t01.klart = '011'
           and t01.objek = par_objek
         group by t01.objek;
      rcd_lads_cus_classfctn csr_lads_cus_classfctn%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform BDS Flattening Logic
      /* **note** - process only material classification data
      /*          - assumes that a lock is held in a parent procedure
      /*          - assumes commit/rollback will be issued in a parent procedure
      /*-*/
      open csr_lads_cus_classfctn;
      fetch csr_lads_cus_classfctn into rcd_lads_cus_classfctn;
      if (csr_lads_cus_classfctn%notfound) then
         raise_application_error(-20000, 'Customer Classification cursor not found');
      end if;
      close csr_lads_cus_classfctn;

      rcd_bds_customer_classfctn.sap_customer_code := rcd_lads_cus_classfctn.sap_customer_code;
      rcd_bds_customer_classfctn.bds_lads_date := rcd_lads_cus_classfctn.bds_lads_date;
      rcd_bds_customer_classfctn.bds_lads_status := rcd_lads_cus_classfctn.bds_lads_status;
      rcd_bds_customer_classfctn.sap_idoc_name := rcd_lads_cus_classfctn.sap_idoc_name;
      rcd_bds_customer_classfctn.sap_idoc_number := rcd_lads_cus_classfctn.sap_idoc_number;
      rcd_bds_customer_classfctn.sap_idoc_timestamp := rcd_lads_cus_classfctn.sap_idoc_timestamp;
      rcd_bds_customer_classfctn.sap_pos_frmt_code := rcd_lads_cus_classfctn.sap_pos_frmt_code;
      rcd_bds_customer_classfctn.sap_pos_frmt_grp_code := rcd_lads_cus_classfctn.sap_pos_frmt_grp_code;
      rcd_bds_customer_classfctn.sap_pos_frmt_size_code := rcd_lads_cus_classfctn.sap_pos_frmt_size_code;
      rcd_bds_customer_classfctn.sap_pos_place_code := rcd_lads_cus_classfctn.sap_pos_place_code;
      rcd_bds_customer_classfctn.sap_banner_code := rcd_lads_cus_classfctn.sap_banner_code;
      rcd_bds_customer_classfctn.sap_ultmt_prnt_acct_code := rcd_lads_cus_classfctn.sap_ultmt_prnt_acct_code;
      rcd_bds_customer_classfctn.sap_multi_mrkt_acct_code := rcd_lads_cus_classfctn.sap_multi_mrkt_acct_code;
      rcd_bds_customer_classfctn.sap_cust_buying_grp_code := rcd_lads_cus_classfctn.sap_cust_buying_grp_code;
      rcd_bds_customer_classfctn.sap_dstrbtn_route_code := rcd_lads_cus_classfctn.sap_dstrbtn_route_code;
      rcd_bds_customer_classfctn.sap_prim_route_to_cnsmr_code := rcd_lads_cus_classfctn.sap_prim_route_to_cnsmr_code;
      rcd_bds_customer_classfctn.sap_operation_bus_model_code := rcd_lads_cus_classfctn.sap_operation_bus_model_code;
      rcd_bds_customer_classfctn.sap_fundrsng_sales_trrtry_code := rcd_lads_cus_classfctn.sap_fundrsng_sales_trrtry_code;
      rcd_bds_customer_classfctn.sap_fundrsng_grp_type_code := rcd_lads_cus_classfctn.sap_fundrsng_grp_type_code;
      rcd_bds_customer_classfctn.sap_ap_cust_grp_food_code := rcd_lads_cus_classfctn.sap_ap_cust_grp_food_code;
      rcd_bds_customer_classfctn.sap_cn_sales_team_code := rcd_lads_cus_classfctn.sap_cn_sales_team_code;
      rcd_bds_customer_classfctn.sap_petcare_city_tier_code := rcd_lads_cus_classfctn.sap_petcare_city_tier_code;
      rcd_bds_customer_classfctn.sap_snackfood_city_tier_code := rcd_lads_cus_classfctn.sap_snackfood_city_tier_code;
      rcd_bds_customer_classfctn.sap_channel_code := rcd_lads_cus_classfctn.sap_channel_code;
      rcd_bds_customer_classfctn.sap_sub_channel_code := rcd_lads_cus_classfctn.sap_sub_channel_code;
      rcd_bds_customer_classfctn.sap_th_channel_code := rcd_lads_cus_classfctn.sap_th_channel_code;
      rcd_bds_customer_classfctn.sap_th_sub_channel_code := rcd_lads_cus_classfctn.sap_th_sub_channel_code;
      rcd_bds_customer_classfctn.sap_th_sales_area_neg_code := rcd_lads_cus_classfctn.sap_th_sales_area_neg_code;
      rcd_bds_customer_classfctn.sap_th_sales_area_geo_code := rcd_lads_cus_classfctn.sap_th_sales_area_geo_code;

      /*-*/
      /* UPDATE BDS, INSERT when new record
      /*-*/
      update bds_customer_classfctn
         set bds_lads_date = rcd_bds_customer_classfctn.bds_lads_date,
             bds_lads_status = rcd_bds_customer_classfctn.bds_lads_status,
             sap_idoc_name = rcd_bds_customer_classfctn.sap_idoc_name,
             sap_idoc_number = rcd_bds_customer_classfctn.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_customer_classfctn.sap_idoc_timestamp,
             sap_pos_frmt_code = rcd_bds_customer_classfctn.sap_pos_frmt_code,
             sap_pos_frmt_grp_code = rcd_bds_customer_classfctn.sap_pos_frmt_grp_code,
             sap_pos_frmt_size_code = rcd_bds_customer_classfctn.sap_pos_frmt_size_code,
             sap_pos_place_code = rcd_bds_customer_classfctn.sap_pos_place_code,
             sap_banner_code = rcd_bds_customer_classfctn.sap_banner_code,
             sap_ultmt_prnt_acct_code = rcd_bds_customer_classfctn.sap_ultmt_prnt_acct_code,
             sap_multi_mrkt_acct_code = rcd_bds_customer_classfctn.sap_multi_mrkt_acct_code,
             sap_cust_buying_grp_code = rcd_bds_customer_classfctn.sap_cust_buying_grp_code,
             sap_dstrbtn_route_code = rcd_bds_customer_classfctn.sap_dstrbtn_route_code,
             sap_prim_route_to_cnsmr_code = rcd_bds_customer_classfctn.sap_prim_route_to_cnsmr_code,
             sap_operation_bus_model_code = rcd_bds_customer_classfctn.sap_operation_bus_model_code,
             sap_fundrsng_sales_trrtry_code = rcd_bds_customer_classfctn.sap_fundrsng_sales_trrtry_code,
             sap_fundrsng_grp_type_code = rcd_bds_customer_classfctn.sap_fundrsng_grp_type_code,
             sap_ap_cust_grp_food_code = rcd_bds_customer_classfctn.sap_ap_cust_grp_food_code,
             sap_cn_sales_team_code = rcd_bds_customer_classfctn.sap_cn_sales_team_code,
             sap_petcare_city_tier_code = rcd_bds_customer_classfctn.sap_petcare_city_tier_code,
             sap_snackfood_city_tier_code = rcd_bds_customer_classfctn.sap_snackfood_city_tier_code,
             sap_channel_code = rcd_bds_customer_classfctn.sap_channel_code,
             sap_sub_channel_code = rcd_bds_customer_classfctn.sap_sub_channel_code,
             sap_th_channel_code = rcd_bds_customer_classfctn.sap_th_channel_code,
             sap_th_sub_channel_code = rcd_bds_customer_classfctn.sap_th_sub_channel_code,
             sap_th_sales_area_neg_code = rcd_bds_customer_classfctn.sap_th_sales_area_neg_code,
             sap_th_sales_area_geo_code = rcd_bds_customer_classfctn.sap_th_sales_area_geo_code
         where sap_customer_code = rcd_bds_customer_classfctn.sap_customer_code;
      if (sql%notfound) then
         insert into bds_customer_classfctn
            (sap_customer_code,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             sap_pos_frmt_code,
             sap_pos_frmt_grp_code,
             sap_pos_frmt_size_code,
             sap_pos_place_code,
             sap_banner_code,
             sap_ultmt_prnt_acct_code,
             sap_multi_mrkt_acct_code,
             sap_cust_buying_grp_code,
             sap_dstrbtn_route_code,
             sap_prim_route_to_cnsmr_code,
             sap_operation_bus_model_code,
             sap_fundrsng_sales_trrtry_code,
             sap_fundrsng_grp_type_code,
             sap_ap_cust_grp_food_code,
             sap_cn_sales_team_code,
             sap_petcare_city_tier_code,
             sap_snackfood_city_tier_code,
             sap_channel_code,
             sap_sub_channel_code,
             sap_th_channel_code,
             sap_th_sub_channel_code,
             sap_th_sales_area_neg_code,
             sap_th_sales_area_geo_code
             )
          values
            (rcd_bds_customer_classfctn.sap_customer_code,
             rcd_bds_customer_classfctn.sap_idoc_name,
             rcd_bds_customer_classfctn.sap_idoc_number,
             rcd_bds_customer_classfctn.sap_idoc_timestamp,
             rcd_bds_customer_classfctn.bds_lads_date,
             rcd_bds_customer_classfctn.bds_lads_status,
             rcd_bds_customer_classfctn.sap_pos_frmt_code,
             rcd_bds_customer_classfctn.sap_pos_frmt_grp_code,
             rcd_bds_customer_classfctn.sap_pos_frmt_size_code,
             rcd_bds_customer_classfctn.sap_pos_place_code,
             rcd_bds_customer_classfctn.sap_banner_code,
             rcd_bds_customer_classfctn.sap_ultmt_prnt_acct_code,
             rcd_bds_customer_classfctn.sap_multi_mrkt_acct_code,
             rcd_bds_customer_classfctn.sap_cust_buying_grp_code,
             rcd_bds_customer_classfctn.sap_dstrbtn_route_code,
             rcd_bds_customer_classfctn.sap_prim_route_to_cnsmr_code,
             rcd_bds_customer_classfctn.sap_operation_bus_model_code,
             rcd_bds_customer_classfctn.sap_fundrsng_sales_trrtry_code,
             rcd_bds_customer_classfctn.sap_fundrsng_grp_type_code,
             rcd_bds_customer_classfctn.sap_ap_cust_grp_food_code,
             rcd_bds_customer_classfctn.sap_cn_sales_team_code,
             rcd_bds_customer_classfctn.sap_petcare_city_tier_code,
             rcd_bds_customer_classfctn.sap_snackfood_city_tier_code,
             rcd_bds_customer_classfctn.sap_channel_code,
             rcd_bds_customer_classfctn.sap_sub_channel_code,
             rcd_bds_customer_classfctn.sap_th_channel_code,
             rcd_bds_customer_classfctn.sap_th_sub_channel_code,
             rcd_bds_customer_classfctn.sap_th_sales_area_neg_code,
             rcd_bds_customer_classfctn.sap_th_sales_area_geo_code
             );
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
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_customer;


   /*******************************************************************************/
   /* This procedure performs the lock routine                                    */
   /*   notes - acquires a lock on the LADS header record                         */
   /*         - uses NOWAIT, assumes if locked, LADS load will re-call flattening */
   /*         - issues commit to release lock                                     */
   /*         - used when manually executing flattening                           */
   /*******************************************************************************/
   procedure lads_lock(par_obtab in varchar2, par_objek in varchar2, par_klart in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select *
         from lads_cla_hdr t01
         where t01.obtab = par_obtab
           and t01.objek = par_objek
           and t01.klart = par_klart
         for update nowait;
      rcd_lock csr_lock%rowtype;
    
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the header row
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_lock;
         fetch csr_lock into rcd_lock;
         if csr_lock%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      /*-*/
      if csr_lock%isopen then
         close csr_lock;
      end if;
      /*-*/
      if (var_available) then

         /*-*/
         /* Flatten
         /*-*/
         bds_flatten(par_obtab, par_objek, par_klart);

         /*-*/
         /* Commit
         /*-*/
         commit;

      else
         rollback;
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
         /* Rollback database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lads_lock;


   /******************************************************************************************/
   /* This procedure performs the refresh routine                                            */
   /*   notes - processes all LADS records with unflattened status                           */
   /******************************************************************************************/
   procedure bds_refresh is

      /*-*/
      /* Local definitions
      /*-*/
      var_open boolean;
      var_exit boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_flatten is
         select t01.obtab,
                t01.objek,
                t01.klart
         from lads_cla_hdr t01
         where nvl(t01.lads_flattened,'0') = '0';
      rcd_flatten csr_flatten%rowtype;
    
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve document header with lads_flattened status = 0
      /* notes - cursor is reopened when snapshot to old
      /*-*/
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next document to process
         /*-*/
         loop
            if var_open = true then
               if csr_flatten%isopen then
                  close csr_flatten;
               end if;
               open csr_flatten;
               var_open := false;
            end if;
            begin
               fetch csr_flatten into rcd_flatten;
               if csr_flatten%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         /*-*/
         if var_exit = true then
            exit;
         end if;

         lads_lock(rcd_flatten.obtab, rcd_flatten.objek, rcd_flatten.klart);

      end loop;
      close csr_flatten;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_refresh;


   /******************************************************************************************/
   /* This procedure performs the rebuild routine                                            */
   /*   notes - RECOMMEND stopping ICS jobs prior to execution                               */
   /*         - performs a truncate on the target BDS table                                  */
   /*         - updates all LADS records to unflattened status                               */
   /*         - calls bds_refresh procedure to drive processing                              */
   /******************************************************************************************/
   procedure bds_rebuild is
    
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin


      /*-*/
      /* Truncate target BDS table(s)
      /*-*/
      bds_table.truncate('bds_material_classfctn');
      bds_table.truncate('bds_customer_classfctn');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_cla_hdr
         set lads_flattened = '0';

      /*-*/
      /* Commit
      /*-*/
      commit;

      /*-*/
      /* Execute BDS_REFRESH to repopulate BDS target tables
      /*-*/
      bds_refresh;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad06_flatten;
/


--
-- BDS_ATLLAD06_FLATTEN  (Synonym) 
--
CREATE PUBLIC SYNONYM BDS_ATLLAD06_FLATTEN FOR BDS_APP.BDS_ATLLAD06_FLATTEN;


GRANT EXECUTE ON BDS_APP.BDS_ATLLAD06_FLATTEN TO LADS_APP;

GRANT EXECUTE ON BDS_APP.BDS_ATLLAD06_FLATTEN TO LICS_APP;
