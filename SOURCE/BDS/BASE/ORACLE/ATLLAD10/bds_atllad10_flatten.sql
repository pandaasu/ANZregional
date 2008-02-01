create or replace package bds_atllad10_flatten as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_atllad21_flatten
 Owner   : BDS_APP
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - ATLLAD10 - Reference Data (ZDISTR)


 PARAMETERS
   1. PAR_ACTION [MANDATORY]
      *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
      *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
      *REFRESH             - process all unflattened LADS records
      *REBUILD             - process all LADS records - truncates BDS table(s) first
                           - RECOMMEND stopping ICS jobs prior to execution

   2. PAR_Z_TABNAME [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
      Field from LADS document in LADS_REF_HDR.Z_TABNAME


 NOTES 
   1. This package must raise an exception on failure to exclude database activity from parent commit


 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created
 2007/01   Linden Glen    Added ROH01,02,03,04,05 and VERP01,02 Characteristics
                          Added Short Description length parameter to process_charistic
                          Added process_purchasing_src
                                process_prodctn_resrc_text
                                process_prodctn_resrc_hdr
 2007/05   Steve Gregan   Fixed process_prodctn_resrc_text field mapping
 2007/07   Steve Gregan   Added null primary key filters

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_z_tabname in varchar2);

end bds_atllad10_flatten;
/


/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad10_flatten as

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
   procedure lads_lock(par_z_tabname in varchar2);
   procedure bds_flatten(par_z_tabname in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;
   /*-*/
   procedure process_material_tdu(par_z_tabname in varchar2);
   procedure process_material_zrep(par_z_tabname in varchar2);
   procedure process_moe(par_z_tabname in varchar2);
   procedure process_plant(par_z_tabname in varchar2);
   procedure process_bom_altrnt(par_z_tabname in varchar2);
   procedure process_purchasing_src(par_z_tabname in varchar2);
   procedure process_acct_assgnmnt_grp(par_z_tabname in varchar2);
   procedure process_prodctn_resrc_text(par_z_tabname in varchar2);
   procedure process_prodctn_resrc_hdr(par_z_tabname in varchar2);
   procedure process_charistic(par_z_tabname in varchar2, par_code_length in number, par_shrt_desc_length in number default 12);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_z_tabname in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/   
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_z_tabname);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_z_tabname);
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
         raise_application_error(-20000, 'BDS_ATLLAD10_FLATTEN - EXECUTE ' || par_action || ', ' || par_z_tabname || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_z_tabname in varchar2) is

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
      /* Process data based on Z_TABNAME
      /*  notes : data not conforming to filters below will not be processed to BDS
      /*          skipped records will have a LADS_FLATTENED status of 2 (skipped/excluded)
      /*-*/   
      case  
         /*----------------------------------------------------*/
         /* Characteristic Reference Tables                    */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = '/MARS/MD_CHC001' or 
               upper(par_z_tabname) = '/MARS/MD_CHC002' or 
               upper(par_z_tabname) = '/MARS/MD_CHC008' or 
               upper(par_z_tabname) = '/MARS/MD_CHC010' or 
               upper(par_z_tabname) = '/MARS/MD_CHC011' or 
               upper(par_z_tabname) = '/MARS/MD_CHC012' or 
               upper(par_z_tabname) = '/MARS/MD_CHC015' or 
               upper(par_z_tabname) = '/MARS/MD_CHC017' or 
               upper(par_z_tabname) = '/MARS/MD_CHC018' or 
               upper(par_z_tabname) = '/MARS/MD_CHC019' or 
               upper(par_z_tabname) = '/MARS/MD_CHC020' or 
               upper(par_z_tabname) = '/MARS/MD_CHC022' or 
               upper(par_z_tabname) = '/MARS/MD_CHC023' or 
               upper(par_z_tabname) = '/MARS/MD_CHC024' or 
               upper(par_z_tabname) = '/MARS/MD_CHC025' or 
               upper(par_z_tabname) = '/MARS/MD_CHC026' or 
               upper(par_z_tabname) = '/MARS/MD_CHC027' or 
               upper(par_z_tabname) = '/MARS/MD_CHC028' or 
               upper(par_z_tabname) = '/MARS/MD_CHC029' or 
               upper(par_z_tabname) = '/MARS/MD_CHC030' or 
               upper(par_z_tabname) = '/MARS/MD_CHC031' or 
               upper(par_z_tabname) = '/MARS/MD_CHC032' or 
               upper(par_z_tabname) = '/MARS/MD_CHC040' or 
               upper(par_z_tabname) = '/MARS/MD_CHC042' or 
               upper(par_z_tabname) = '/MARS/MD_CHC046' or 
               upper(par_z_tabname) = '/MARS/MD_CHC047') then process_charistic(par_z_tabname, 2);
         when (upper(par_z_tabname) = '/MARS/MD_CHC003' or 
               upper(par_z_tabname) = '/MARS/MD_CHC004' or 
               upper(par_z_tabname) = '/MARS/MD_CHC005' or 
               upper(par_z_tabname) = '/MARS/MD_CHC007' or 
               upper(par_z_tabname) = '/MARS/MD_CHC009' or 
               upper(par_z_tabname) = '/MARS/MD_CHC013' or 
               upper(par_z_tabname) = '/MARS/MD_CHC014' or 
               upper(par_z_tabname) = '/MARS/MD_CHC016' or 
               upper(par_z_tabname) = '/MARS/MD_CHC021' or 
               upper(par_z_tabname) = '/MARS/MD_CHC038') then process_charistic(par_z_tabname, 3);
         when (upper(par_z_tabname) = '/MARS/MD_CHC006') then process_charistic(par_z_tabname, 4);
         when (upper(par_z_tabname) = '/MARS/MD_VERP01' or 
               upper(par_z_tabname) = '/MARS/MD_VERP02' or 
               upper(par_z_tabname) = '/MARS/MD_ROH01' or 
               upper(par_z_tabname) = '/MARS/MD_ROH02' or 
               upper(par_z_tabname) = '/MARS/MD_ROH03' or 
               upper(par_z_tabname) = '/MARS/MD_ROH04' or 
               upper(par_z_tabname) = '/MARS/MD_ROH05') then process_charistic(par_z_tabname, 30, 0);
         /*----------------------------------------------------*/
         /* Plant Reference Tables                             */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'T001W') then process_plant(par_z_tabname);
         /*----------------------------------------------------*/
         /* Account Assignment Group Reference Tables          */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'TVKTT') then process_acct_assgnmnt_grp(par_z_tabname);
         /*----------------------------------------------------*/
         /* Company Reference Tables                           */
         /*   note : not currently required                    */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'T001') then null; 
         /*----------------------------------------------------*/
         /* Mars Organisational Entity (MOE) Reference Tables  */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = '/MARS/MDMOE') then process_moe(par_z_tabname);
         /*----------------------------------------------------*/
         /* BOM Alternate Versions Reference Tables            */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'T415A') then process_bom_altrnt(par_z_tabname);
         /*----------------------------------------------------*/
         /* Purchasing Source (Vendor/Material) Reference Table*/
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'EORD') then process_purchasing_src(par_z_tabname);
         /*----------------------------------------------------*/
         /* Material Determination Reference Tables            */
         /*      KONDD - TDU                                   */
         /*      KOTD501, KOTD907, KOTD880, KOTD002 - ZREP     */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'KONDD') then process_material_tdu(par_z_tabname);
         when (upper(par_z_tabname) = 'KOTD501' or 
               upper(par_z_tabname) = 'KOTD907' or
               upper(par_z_tabname) = 'KOTD880' or
               upper(par_z_tabname) = 'KOTD002') then process_material_zrep(par_z_tabname);
         /*----------------------------------------------------*/
         /* Production Resources (Details/Descriptions)        */
         /*      CRTX - Production Resource Text               */
         /*      CRHD - Production Resource Header             */
         /*----------------------------------------------------*/
         when (upper(par_z_tabname) = 'CRTX') then process_prodctn_resrc_text(par_z_tabname);
         when (upper(par_z_tabname) = 'CRHD') then process_prodctn_resrc_hdr(par_z_tabname);
         /*-*/ 
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
      update lads_ref_hdr
         set lads_flattened = var_flattened
       where z_tabname = par_z_tabname;


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
         raise_application_error(-20000, 'BDS_FLATTEN :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_flatten;


   /***********************************************************************/
   /* This procedure performs the flatten plant routine                   */
   /***********************************************************************/
   procedure process_plant(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_plant bds_refrnc_plant%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_plant is
         select * from (
            select nvl(trim(substr(t01.z_data, 4, 4)),'*NONE') as plant_code,
                   t01.idoc_number as idoc_number,
                   t01.idoc_timestamp as idoc_timestamp,
                   t01.z_chgtyp as z_chgtyp,
                   trim(substr(t01.z_data, 8, 30)) as plant_name,
                   trim(substr(t01.z_data, 38, 4)) as vltn_area,
                   trim(substr(t01.z_data, 42, 10)) as plant_customer_no,
                   trim(substr(t01.z_data, 52, 10)) as plant_vendor_no,
                   trim(substr(t01.z_data, 62, 2)) as factory_calendar_key,
                   trim(substr(t01.z_data, 64, 30)) as plant_name_2,
                   trim(substr(t01.z_data, 94, 30)) as plant_street,
                   trim(substr(t01.z_data, 124, 10)) as plant_po_box,
                   trim(substr(t01.z_data, 134, 10)) as plant_post_code,
                   trim(substr(t01.z_data, 144, 25)) as plant_city,
                   trim(substr(t01.z_data, 169, 4)) as plant_purchasing_organisation,
                   trim(substr(t01.z_data, 173, 4)) as plant_sales_organisation,
                   trim(substr(t01.z_data, 177, 1)) as batch_manage_indctr,
                   trim(substr(t01.z_data, 178, 1)) as plant_condition_indctr,
                   trim(substr(t01.z_data, 179, 1)) as source_list_indctr,
                   trim(substr(t01.z_data, 180, 1)) as activate_reqrmnt_indctr,
                   trim(substr(t01.z_data, 181, 3)) as plant_country_key,
                   trim(substr(t01.z_data, 184, 3)) as plant_region,
                   trim(substr(t01.z_data, 187, 3)) as plant_country_code,
                   trim(substr(t01.z_data, 190, 4)) as plant_city_code,
                   trim(substr(t01.z_data, 194, 10)) as plant_address,
                   trim(substr(t01.z_data, 204, 4)) as maint_planning_plant,
                   trim(substr(t01.z_data, 208, 15)) as tax_jurisdiction_code,
                   trim(substr(t01.z_data, 223, 2)) as dstrbtn_channel,
                   trim(substr(t01.z_data, 225, 2)) as division,
                   trim(substr(t01.z_data, 227, 1)) as language_key,
                   trim(substr(t01.z_data, 228, 1)) as sop_plant,
                   trim(substr(t01.z_data, 229, 6)) as variance_key,
                   trim(substr(t01.z_data, 235, 1)) as batch_manage_old_indctr,
                   trim(substr(t01.z_data, 236, 1)) as plant_ctgry,
                   trim(substr(t01.z_data, 237, 6)) as plant_sales_district,
                   trim(substr(t01.z_data, 243, 10)) as plant_supply_region,
                   trim(substr(t01.z_data, 253, 1)) as plant_tax_indctr,
                   trim(substr(t01.z_data, 254, 1)) as regular_vendor_indctr,
                   trim(substr(t01.z_data, 255, 3)) as first_reminder_days,
                   trim(substr(t01.z_data, 258, 3)) as second_reminder_days,
                   trim(substr(t01.z_data, 261, 3)) as third_reminder_days,
                   trim(substr(t01.z_data, 264, 16)) as vendor_declaration_text_1,
                   trim(substr(t01.z_data, 280, 16)) as vendor_declaration_text_2,
                   trim(substr(t01.z_data, 296, 16)) as vendor_declaration_text_3,
                   trim(substr(t01.z_data, 312, 3)) as po_tolerance_days,
                   trim(substr(t01.z_data, 315, 4)) as plant_business_place,
                   trim(substr(t01.z_data, 319, 2)) as stock_xfer_rule,
                   trim(substr(t01.z_data, 321, 3)) as plant_dstrbtn_profile,
                   trim(substr(t01.z_data, 324, 1)) as central_archive_marker,
                   trim(substr(t01.z_data, 325, 1)) as dms_type_indctr,
                   trim(substr(t01.z_data, 326, 3)) as node_type,
                   trim(substr(t01.z_data, 329, 4)) as name_formation_structure,
                   trim(substr(t01.z_data, 333, 1)) as cost_control_active_indctr,
                   trim(substr(t01.z_data, 334, 1)) as mixed_costing_active_indctr,
                   trim(substr(t01.z_data, 335, 1)) as actual_costing_active_indctr,
                   trim(substr(t01.z_data, 336, 4)) as transport_point,
                   rank() over (partition by nvl(trim(substr(t01.z_data, 4, 4)),'*NONE') order by rownum) as rnkseq
            from lads_ref_dat t01
            where t01.z_tabname = par_z_tabname)
         where rnkseq = 1;
      rcd_lads_ref_plant csr_lads_ref_plant%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin


      /*------------------------------*/
      /* DELETE BDS_REFRNC_PLANT      */
      /*------------------------------*/
      delete bds_refrnc_plant;

      open csr_lads_ref_plant;
      loop
         fetch csr_lads_ref_plant into rcd_lads_ref_plant;
          if (csr_lads_ref_plant%notfound) then
             exit;
          end if;

          rcd_bds_refrnc_plant.plant_code := rcd_lads_ref_plant.plant_code;
          rcd_bds_refrnc_plant.plant_name := rcd_lads_ref_plant.plant_name;
          rcd_bds_refrnc_plant.sap_idoc_number := rcd_lads_ref_plant.idoc_number;
          rcd_bds_refrnc_plant.sap_idoc_timestamp := rcd_lads_ref_plant.idoc_timestamp;
          rcd_bds_refrnc_plant.change_flag := rcd_lads_ref_plant.z_chgtyp;
          rcd_bds_refrnc_plant.vltn_area := rcd_lads_ref_plant.vltn_area;
          rcd_bds_refrnc_plant.plant_customer_no := rcd_lads_ref_plant.plant_customer_no;
          rcd_bds_refrnc_plant.plant_vendor_no := rcd_lads_ref_plant.plant_vendor_no;
          rcd_bds_refrnc_plant.factory_calendar_key := rcd_lads_ref_plant.factory_calendar_key;
          rcd_bds_refrnc_plant.plant_name_2 := rcd_lads_ref_plant.plant_name_2;
          rcd_bds_refrnc_plant.plant_street := rcd_lads_ref_plant.plant_street;
          rcd_bds_refrnc_plant.plant_po_box := rcd_lads_ref_plant.plant_po_box;
          rcd_bds_refrnc_plant.plant_post_code := rcd_lads_ref_plant.plant_post_code;
          rcd_bds_refrnc_plant.plant_city := rcd_lads_ref_plant.plant_city;
          rcd_bds_refrnc_plant.plant_purchasing_organisation := rcd_lads_ref_plant.plant_purchasing_organisation;
          rcd_bds_refrnc_plant.plant_sales_organisation := rcd_lads_ref_plant.plant_sales_organisation;
          rcd_bds_refrnc_plant.batch_manage_indctr := rcd_lads_ref_plant.batch_manage_indctr;
          rcd_bds_refrnc_plant.plant_condition_indctr := rcd_lads_ref_plant.plant_condition_indctr;
          rcd_bds_refrnc_plant.source_list_indctr := rcd_lads_ref_plant.source_list_indctr;
          rcd_bds_refrnc_plant.activate_reqrmnt_indctr := rcd_lads_ref_plant.activate_reqrmnt_indctr;
          rcd_bds_refrnc_plant.plant_country_key := rcd_lads_ref_plant.plant_country_key;
          rcd_bds_refrnc_plant.plant_region := rcd_lads_ref_plant.plant_region;
          rcd_bds_refrnc_plant.plant_country_code := rcd_lads_ref_plant.plant_country_code;
          rcd_bds_refrnc_plant.plant_city_code := rcd_lads_ref_plant.plant_city_code;
          rcd_bds_refrnc_plant.plant_address := rcd_lads_ref_plant.plant_address;
          rcd_bds_refrnc_plant.maint_planning_plant := rcd_lads_ref_plant.maint_planning_plant;
          rcd_bds_refrnc_plant.tax_jurisdiction_code := rcd_lads_ref_plant.tax_jurisdiction_code;
          rcd_bds_refrnc_plant.dstrbtn_channel := rcd_lads_ref_plant.dstrbtn_channel;
          rcd_bds_refrnc_plant.division := rcd_lads_ref_plant.division;
          rcd_bds_refrnc_plant.language_key := rcd_lads_ref_plant.language_key;
          rcd_bds_refrnc_plant.sop_plant := rcd_lads_ref_plant.sop_plant;
          rcd_bds_refrnc_plant.variance_key := rcd_lads_ref_plant.variance_key;
          rcd_bds_refrnc_plant.batch_manage_old_indctr := rcd_lads_ref_plant.batch_manage_old_indctr;
          rcd_bds_refrnc_plant.plant_ctgry := rcd_lads_ref_plant.plant_ctgry;
          rcd_bds_refrnc_plant.plant_sales_district := rcd_lads_ref_plant.plant_sales_district;
          rcd_bds_refrnc_plant.plant_supply_region := rcd_lads_ref_plant.plant_supply_region;
          rcd_bds_refrnc_plant.plant_tax_indctr := rcd_lads_ref_plant.plant_tax_indctr;
          rcd_bds_refrnc_plant.regular_vendor_indctr := rcd_lads_ref_plant.regular_vendor_indctr;
          rcd_bds_refrnc_plant.first_reminder_days := rcd_lads_ref_plant.first_reminder_days;
          rcd_bds_refrnc_plant.second_reminder_days := rcd_lads_ref_plant.second_reminder_days;
          rcd_bds_refrnc_plant.third_reminder_days := rcd_lads_ref_plant.third_reminder_days;
          rcd_bds_refrnc_plant.vendor_declaration_text_1 := rcd_lads_ref_plant.vendor_declaration_text_1;
          rcd_bds_refrnc_plant.vendor_declaration_text_2 := rcd_lads_ref_plant.vendor_declaration_text_2;
          rcd_bds_refrnc_plant.vendor_declaration_text_3 := rcd_lads_ref_plant.vendor_declaration_text_3;
          rcd_bds_refrnc_plant.po_tolerance_days := rcd_lads_ref_plant.po_tolerance_days;
          rcd_bds_refrnc_plant.plant_business_place := rcd_lads_ref_plant.plant_business_place;
          rcd_bds_refrnc_plant.stock_xfer_rule := rcd_lads_ref_plant.stock_xfer_rule;
          rcd_bds_refrnc_plant.plant_dstrbtn_profile := rcd_lads_ref_plant.plant_dstrbtn_profile;
          rcd_bds_refrnc_plant.central_archive_marker := rcd_lads_ref_plant.central_archive_marker;
          rcd_bds_refrnc_plant.dms_type_indctr := rcd_lads_ref_plant.dms_type_indctr;
          rcd_bds_refrnc_plant.node_type := rcd_lads_ref_plant.node_type;
          rcd_bds_refrnc_plant.name_formation_structure := rcd_lads_ref_plant.name_formation_structure;
          rcd_bds_refrnc_plant.cost_control_active_indctr := rcd_lads_ref_plant.cost_control_active_indctr;
          rcd_bds_refrnc_plant.mixed_costing_active_indctr := rcd_lads_ref_plant.mixed_costing_active_indctr;
          rcd_bds_refrnc_plant.actual_costing_active_indctr := rcd_lads_ref_plant.actual_costing_active_indctr;
          rcd_bds_refrnc_plant.transport_point := rcd_lads_ref_plant.transport_point;


          /*------------------------------*/
          /* INSERT BDS_REFRNC_PLANT      */
          /*------------------------------*/
          insert into bds_refrnc_plant
                (plant_code,
                 sap_idoc_number,
                 sap_idoc_timestamp,
                 change_flag,
                 plant_name,
                 vltn_area,
                 plant_customer_no,
                 plant_vendor_no,
                 factory_calendar_key,
                 plant_name_2,
                 plant_street,
                 plant_po_box,
                 plant_post_code,
                 plant_city,
                 plant_purchasing_organisation,
                 plant_sales_organisation,
                 batch_manage_indctr,
                 plant_condition_indctr,
                 source_list_indctr,
                 activate_reqrmnt_indctr,
                 plant_country_key,
                 plant_region,
                 plant_country_code,
                 plant_city_code,
                 plant_address,
                 maint_planning_plant,
                 tax_jurisdiction_code,
                 dstrbtn_channel,
                 division,
                 language_key,
                 sop_plant,
                 variance_key,
                 batch_manage_old_indctr,
                 plant_ctgry,
                 plant_sales_district,
                 plant_supply_region,
                 plant_tax_indctr,
                 regular_vendor_indctr,
                 first_reminder_days,
                 second_reminder_days,
                 third_reminder_days,
                 vendor_declaration_text_1,
                 vendor_declaration_text_2,
                 vendor_declaration_text_3,
                 po_tolerance_days,
                 plant_business_place,
                 stock_xfer_rule,
                 plant_dstrbtn_profile,
                 central_archive_marker,
                 dms_type_indctr,
                 node_type,
                 name_formation_structure,
                 cost_control_active_indctr,
                 mixed_costing_active_indctr,
                 actual_costing_active_indctr,
                 transport_point)
           values
                (rcd_bds_refrnc_plant.plant_code,
                 rcd_bds_refrnc_plant.sap_idoc_number,
                 rcd_bds_refrnc_plant.sap_idoc_timestamp,
                 rcd_bds_refrnc_plant.change_flag,
                 rcd_bds_refrnc_plant.plant_name,
                 rcd_bds_refrnc_plant.vltn_area,
                 rcd_bds_refrnc_plant.plant_customer_no,
                 rcd_bds_refrnc_plant.plant_vendor_no,
                 rcd_bds_refrnc_plant.factory_calendar_key,
                 rcd_bds_refrnc_plant.plant_name_2,
                 rcd_bds_refrnc_plant.plant_street,
                 rcd_bds_refrnc_plant.plant_po_box,
                 rcd_bds_refrnc_plant.plant_post_code,
                 rcd_bds_refrnc_plant.plant_city,
                 rcd_bds_refrnc_plant.plant_purchasing_organisation,
                 rcd_bds_refrnc_plant.plant_sales_organisation,
                 rcd_bds_refrnc_plant.batch_manage_indctr,
                 rcd_bds_refrnc_plant.plant_condition_indctr,
                 rcd_bds_refrnc_plant.source_list_indctr,
                 rcd_bds_refrnc_plant.activate_reqrmnt_indctr,
                 rcd_bds_refrnc_plant.plant_country_key,
                 rcd_bds_refrnc_plant.plant_region,
                 rcd_bds_refrnc_plant.plant_country_code,
                 rcd_bds_refrnc_plant.plant_city_code,
                 rcd_bds_refrnc_plant.plant_address,
                 rcd_bds_refrnc_plant.maint_planning_plant,
                 rcd_bds_refrnc_plant.tax_jurisdiction_code,
                 rcd_bds_refrnc_plant.dstrbtn_channel,
                 rcd_bds_refrnc_plant.division,
                 rcd_bds_refrnc_plant.language_key,
                 rcd_bds_refrnc_plant.sop_plant,
                 rcd_bds_refrnc_plant.variance_key,
                 rcd_bds_refrnc_plant.batch_manage_old_indctr,
                 rcd_bds_refrnc_plant.plant_ctgry,
                 rcd_bds_refrnc_plant.plant_sales_district,
                 rcd_bds_refrnc_plant.plant_supply_region,
                 rcd_bds_refrnc_plant.plant_tax_indctr,
                 rcd_bds_refrnc_plant.regular_vendor_indctr,
                 rcd_bds_refrnc_plant.first_reminder_days,
                 rcd_bds_refrnc_plant.second_reminder_days,
                 rcd_bds_refrnc_plant.third_reminder_days,
                 rcd_bds_refrnc_plant.vendor_declaration_text_1,
                 rcd_bds_refrnc_plant.vendor_declaration_text_2,
                 rcd_bds_refrnc_plant.vendor_declaration_text_3,
                 rcd_bds_refrnc_plant.po_tolerance_days,
                 rcd_bds_refrnc_plant.plant_business_place,
                 rcd_bds_refrnc_plant.stock_xfer_rule,
                 rcd_bds_refrnc_plant.plant_dstrbtn_profile,
                 rcd_bds_refrnc_plant.central_archive_marker,
                 rcd_bds_refrnc_plant.dms_type_indctr,
                 rcd_bds_refrnc_plant.node_type,
                 rcd_bds_refrnc_plant.name_formation_structure,
                 rcd_bds_refrnc_plant.cost_control_active_indctr,
                 rcd_bds_refrnc_plant.mixed_costing_active_indctr,
                 rcd_bds_refrnc_plant.actual_costing_active_indctr,
                 rcd_bds_refrnc_plant.transport_point);

      end loop;
      close csr_lads_ref_plant;


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
         raise_application_error(-20000, 'PROCESS_PLANT :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_plant;


   /***********************************************************************/
   /* This procedure performs the flatten Account Assignment Group routine*/
   /***********************************************************************/
   procedure process_acct_assgnmnt_grp(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_aag bds_refrnc_acct_assgnmnt_grp%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_aag is
         select trim(substr(t01.z_data, 6, 2)) as acct_assgnmnt_grp_code,
                trim(substr(t01.z_data, 4, 2)) as desc_language,
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp,
                trim(substr(max(t01.z_data), 8, 20)) as acct_assgnmnt_grp_desc
         from lads_ref_dat t01
         where t01.z_tabname = par_z_tabname
         group by trim(substr(t01.z_data, 6, 2)), trim(substr(t01.z_data, 4, 2));
      rcd_lads_ref_aag csr_lads_ref_aag%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin


      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_ACCT_ASSGNMNT_GRP      */
      /*------------------------------------------*/
      delete bds_refrnc_acct_assgnmnt_grp;

      open csr_lads_ref_aag;
      loop
         fetch csr_lads_ref_aag into rcd_lads_ref_aag;
          if (csr_lads_ref_aag%notfound) then
             exit;
          end if;

          rcd_bds_refrnc_aag.acct_assgnmnt_grp_code := rcd_lads_ref_aag.acct_assgnmnt_grp_code;
          rcd_bds_refrnc_aag.desc_language := rcd_lads_ref_aag.desc_language;
          rcd_bds_refrnc_aag.sap_idoc_number := rcd_lads_ref_aag.idoc_number;
          rcd_bds_refrnc_aag.sap_idoc_timestamp := rcd_lads_ref_aag.idoc_timestamp;
          rcd_bds_refrnc_aag.change_flag := rcd_lads_ref_aag.z_chgtyp;
          rcd_bds_refrnc_aag.acct_assgnmnt_grp_desc := rcd_lads_ref_aag.acct_assgnmnt_grp_desc;
 
          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_ACCT_ASSGNMNT_GRP      */
          /*------------------------------------------*/
          if not(rcd_bds_refrnc_aag.acct_assgnmnt_grp_code is null) and
             not(rcd_bds_refrnc_aag.desc_language is null) then
             insert into bds_refrnc_acct_assgnmnt_grp
                   (acct_assgnmnt_grp_code,
                    desc_language,
                    sap_idoc_number,
                    sap_idoc_timestamp,
                    change_flag,
                    acct_assgnmnt_grp_desc)
              values
                   (rcd_bds_refrnc_aag.acct_assgnmnt_grp_code,
                    rcd_bds_refrnc_aag.desc_language,
                    rcd_bds_refrnc_aag.sap_idoc_number,
                    rcd_bds_refrnc_aag.sap_idoc_timestamp,
                    rcd_bds_refrnc_aag.change_flag,
                    rcd_bds_refrnc_aag.acct_assgnmnt_grp_desc);
          end if;

      end loop;
      close csr_lads_ref_aag;


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
         raise_application_error(-20000, 'PROCESS_ACCT_ASSGNMNT_GRP :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_acct_assgnmnt_grp;


   /***********************************************************************/
   /* This procedure performs the flatten Characteristic routine          */
   /***********************************************************************/
   procedure process_charistic(par_z_tabname in varchar2, par_code_length in number, par_shrt_desc_length in number default 12) is

      /*-*/
      /* Private definitions
      /*-*/
      var_start_pos number;
      rcd_bds_refrnc_charistic bds_refrnc_charistic%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_charistic is
         select nvl(trim(substr(t01.z_data,var_start_pos, par_code_length)),'*NONE') as sap_charistic_value_code,
                trim(substr(max(t01.z_data),var_start_pos+par_code_length,par_shrt_desc_length)) as sap_charistic_value_shrt_desc,
                trim(substr(max(t01.z_data),var_start_pos+par_code_length+par_shrt_desc_length,30)) as sap_charistic_value_long_desc,
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp,
                trim(substr(max(t01.z_data), 8, 20)) as acct_assgnmnt_grp_desc
         from lads_ref_dat t01
         where t01.z_tabname = par_z_tabname
         group by nvl(trim(substr(t01.z_data,var_start_pos, par_code_length)),'*NONE');
      rcd_lads_ref_charistic csr_lads_ref_charistic%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise Variables
      /*-*/
      var_start_pos := 4;

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_CHARISTIC              */
      /*------------------------------------------*/
      delete bds_refrnc_charistic
         where sap_charistic_code = par_z_tabname;

      open csr_lads_ref_charistic;
      loop
         fetch csr_lads_ref_charistic into rcd_lads_ref_charistic;
          if (csr_lads_ref_charistic%notfound) then
             exit;
          end if;

          rcd_bds_refrnc_charistic.sap_charistic_code := par_z_tabname;
          rcd_bds_refrnc_charistic.sap_charistic_value_code := rcd_lads_ref_charistic.sap_charistic_value_code;
          rcd_bds_refrnc_charistic.sap_charistic_value_shrt_desc := rcd_lads_ref_charistic.sap_charistic_value_shrt_desc;
          rcd_bds_refrnc_charistic.sap_charistic_value_long_desc := rcd_lads_ref_charistic.sap_charistic_value_long_desc;
          rcd_bds_refrnc_charistic.sap_idoc_number := rcd_lads_ref_charistic.idoc_number;
          rcd_bds_refrnc_charistic.sap_idoc_timestamp := rcd_lads_ref_charistic.idoc_timestamp;
          rcd_bds_refrnc_charistic.change_flag := rcd_lads_ref_charistic.z_chgtyp;
 
          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_CHARISTIC              */
          /*------------------------------------------*/
          insert into bds_refrnc_charistic
                (sap_charistic_code,
                 sap_charistic_value_code,
                 sap_charistic_value_shrt_desc,
                 sap_charistic_value_long_desc,
                 sap_idoc_number,
                 sap_idoc_timestamp,
                 change_flag)
           values
                (rcd_bds_refrnc_charistic.sap_charistic_code,
                 rcd_bds_refrnc_charistic.sap_charistic_value_code,
                 rcd_bds_refrnc_charistic.sap_charistic_value_shrt_desc,
                 rcd_bds_refrnc_charistic.sap_charistic_value_long_desc,
                 rcd_bds_refrnc_charistic.sap_idoc_number,
                 rcd_bds_refrnc_charistic.sap_idoc_timestamp,
                 rcd_bds_refrnc_charistic.change_flag);

      end loop;
      close csr_lads_ref_charistic;

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
         raise_application_error(-20000, 'PROCESS_CHARISTIC :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_charistic;


   /***********************************************************************/
   /* This procedure performs the flatten MOE routine                     */
   /***********************************************************************/
   procedure process_moe(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_moe bds_refrnc_moe%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_moe is
         select trim(substr(t01.z_data, 4, 4)) as moe_code,
                trim(substr(max(t01.z_data), 8, 12)) as moe_shrt_desc,
                trim(substr(max(t01.z_data), 20, 40)) as moe_long_desc,
                trim(substr(max(t01.z_data), 60, 2)) as moe_type,
                trim(substr(max(t01.z_data), 62, 4)) as moe_reporting_grp,
                trim(substr(max(t01.z_data), 66, 4)) as moe_dp_grp,
                trim(substr(max(t01.z_data), 70, 4)) as moe_grp_3,
                trim(substr(max(t01.z_data), 74, 4)) as moe_grp_4,
                trim(substr(max(t01.z_data), 78, 4)) as moe_grp_5,
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp
         from lads_ref_dat t01
         where t01.z_tabname = par_z_tabname
         group by trim(substr(t01.z_data, 4, 4));
      rcd_lads_ref_moe csr_lads_ref_moe%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_MOE                    */
      /*------------------------------------------*/
      delete bds_refrnc_moe;

      open csr_lads_ref_moe;
      loop
         fetch csr_lads_ref_moe into rcd_lads_ref_moe;
          if (csr_lads_ref_moe%notfound) then
             exit;
          end if;

          rcd_bds_refrnc_moe.moe_code := rcd_lads_ref_moe.moe_code;
          rcd_bds_refrnc_moe.moe_shrt_desc := rcd_lads_ref_moe.moe_shrt_desc;
          rcd_bds_refrnc_moe.moe_long_desc := rcd_lads_ref_moe.moe_long_desc;
          rcd_bds_refrnc_moe.moe_type := rcd_lads_ref_moe.moe_type;
          rcd_bds_refrnc_moe.moe_reporting_grp := rcd_lads_ref_moe.moe_reporting_grp;
          rcd_bds_refrnc_moe.moe_dp_grp := rcd_lads_ref_moe.moe_dp_grp;
          rcd_bds_refrnc_moe.moe_grp_3 := rcd_lads_ref_moe.moe_grp_3;
          rcd_bds_refrnc_moe.moe_grp_4 := rcd_lads_ref_moe.moe_grp_4;
          rcd_bds_refrnc_moe.moe_grp_5 := rcd_lads_ref_moe.moe_grp_5;
          rcd_bds_refrnc_moe.sap_idoc_number := rcd_lads_ref_moe.idoc_number;
          rcd_bds_refrnc_moe.sap_idoc_timestamp := rcd_lads_ref_moe.idoc_timestamp;
          rcd_bds_refrnc_moe.change_flag := rcd_lads_ref_moe.z_chgtyp;
 
          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_MOE                    */
          /*------------------------------------------*/
          if not(rcd_bds_refrnc_moe.moe_code is null) then
             insert into bds_refrnc_moe
                   (moe_code, 
                    moe_shrt_desc, 
                    moe_long_desc, 
                    moe_type, 
                    moe_reporting_grp, 
                    moe_dp_grp, 
                    moe_grp_3, 
                    moe_grp_4, 
                    moe_grp_5, 
                    sap_idoc_number, 
                    sap_idoc_timestamp, 
                    change_flag)
              values
                   (rcd_bds_refrnc_moe.moe_code,
                    rcd_bds_refrnc_moe.moe_shrt_desc,
                    rcd_bds_refrnc_moe.moe_long_desc,
                    rcd_bds_refrnc_moe.moe_type,
                    rcd_bds_refrnc_moe.moe_reporting_grp,
                    rcd_bds_refrnc_moe.moe_dp_grp,
                    rcd_bds_refrnc_moe.moe_grp_3,
                    rcd_bds_refrnc_moe.moe_grp_4,
                    rcd_bds_refrnc_moe.moe_grp_5,
                    rcd_bds_refrnc_moe.sap_idoc_number,
                    rcd_bds_refrnc_moe.sap_idoc_timestamp,
                    rcd_bds_refrnc_moe.change_flag);
          end if;

      end loop;
      close csr_lads_ref_moe;

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
         raise_application_error(-20000, 'PROCESS_MOE :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_moe;


   /***********************************************************************/
   /* This procedure performs the flatten BOM Alternate routine           */
   /***********************************************************************/
   procedure process_bom_altrnt(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_bom_altrnt bds_refrnc_bom_altrnt_t415a%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_bom_altrnt is
         select trim(substr(t01.z_data, 4, 18)) as sap_material_code,
                trim(substr(t01.z_data, 22, 4)) as plant_code,
                trim(substr(t01.z_data, 26, 1)) as bom_usage,
                trim(substr(t01.z_data, 27, 8)) as valid_from_date,
                trim(substr(max(t01.z_data), 35, 12)) as technical_status_from_date,
                trim(substr(max(t01.z_data), 47, 2)) as altrntv_bom,
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp
         from lads_ref_dat t01
         where z_tabname = par_z_tabname
          and trim(substr(z_data,1,34)) not in (select trim(substr(z_data,1,34)) 
                                           from lads_ref_dat 
                                          where z_tabname = t01.z_tabname
                                           and z_chgtyp = 'D')  
         group by trim(substr(t01.z_data, 4, 18)), 
                  trim(substr(t01.z_data, 22, 4)),
                  trim(substr(t01.z_data, 26, 1)),
                  trim(substr(t01.z_data, 27, 8));
      rcd_lads_ref_bom_altrnt csr_lads_ref_bom_altrnt%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_BOM_ALTRNTV_T415A      */
      /*------------------------------------------*/
      delete bds_refrnc_bom_altrnt_t415a;

      open csr_lads_ref_bom_altrnt;
      loop
         fetch csr_lads_ref_bom_altrnt into rcd_lads_ref_bom_altrnt;
          if (csr_lads_ref_bom_altrnt%notfound) then
             exit;
          end if;

          rcd_bds_refrnc_bom_altrnt.sap_material_code := rcd_lads_ref_bom_altrnt.sap_material_code;
          rcd_bds_refrnc_bom_altrnt.plant_code := rcd_lads_ref_bom_altrnt.plant_code;
          rcd_bds_refrnc_bom_altrnt.bom_usage := rcd_lads_ref_bom_altrnt.bom_usage;
          rcd_bds_refrnc_bom_altrnt.valid_from_date := bds_date.bds_to_date('*DATE',rcd_lads_ref_bom_altrnt.valid_from_date,'yyyymmdd');
          rcd_bds_refrnc_bom_altrnt.technical_status_from_date := bds_date.bds_to_date('*DATE',rcd_lads_ref_bom_altrnt.technical_status_from_date,'yyyymmdd');
          rcd_bds_refrnc_bom_altrnt.altrntv_bom := rcd_lads_ref_bom_altrnt.altrntv_bom;
          rcd_bds_refrnc_bom_altrnt.sap_idoc_number := rcd_lads_ref_bom_altrnt.idoc_number;
          rcd_bds_refrnc_bom_altrnt.sap_idoc_timestamp := rcd_lads_ref_bom_altrnt.idoc_timestamp;
          rcd_bds_refrnc_bom_altrnt.change_flag := rcd_lads_ref_bom_altrnt.z_chgtyp;
 

          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_BOM_ALTRNTV_T415A      */
          /*------------------------------------------*/
          if not(rcd_bds_refrnc_bom_altrnt.sap_material_code is null) and
             not(rcd_bds_refrnc_bom_altrnt.plant_code is null) and
             not(rcd_bds_refrnc_bom_altrnt.bom_usage is null) and
             not(rcd_bds_refrnc_bom_altrnt.valid_from_date is null) then
             insert into bds_refrnc_bom_altrnt_t415a
                   (sap_material_code, 
                    plant_code, 
                    bom_usage, 
                    valid_from_date, 
                    technical_status_from_date, 
                    altrntv_bom, 
                    change_flag, 
                    sap_idoc_number, 
                    sap_idoc_timestamp)
              values
                   (rcd_bds_refrnc_bom_altrnt.sap_material_code,
                    rcd_bds_refrnc_bom_altrnt.plant_code,
                    rcd_bds_refrnc_bom_altrnt.bom_usage,
                    rcd_bds_refrnc_bom_altrnt.valid_from_date,
                    rcd_bds_refrnc_bom_altrnt.technical_status_from_date,
                    rcd_bds_refrnc_bom_altrnt.altrntv_bom,
                    rcd_bds_refrnc_bom_altrnt.change_flag,
                    rcd_bds_refrnc_bom_altrnt.sap_idoc_number,
                    rcd_bds_refrnc_bom_altrnt.sap_idoc_timestamp);
          end if;

      end loop;
      close csr_lads_ref_bom_altrnt;

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
         raise_application_error(-20000, 'PROCESS_BOM_ALTRNT :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_bom_altrnt;

   /***********************************************************************/
   /* This procedure performs the flatten Material TDU routine            */
   /***********************************************************************/
   procedure process_material_tdu(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_material_tdu bds_refrnc_material_tdu%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_material_tdu is
         select trim(substr(t01.z_data, 1, 3)) as mandt,
                nvl(trim(substr(t01.z_data, 4, 10)),'*NONE') as knumh,
                trim(substr(max(t01.z_data), 14, 18)) as smatn,
                trim(substr(max(t01.z_data), 32, 3)) as subme,
                trim(substr(max(t01.z_data), 35, 4)) as sugrd,
                trim(substr(max(t01.z_data), 39, 1)) as psdsp,
                trim(substr(max(t01.z_data), 40, 1)) as lstacs,
                trim(substr(max(t01.z_data), 47, 2)) as altrntv_bom,
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp
         from lads_ref_dat t01
         where z_tabname = par_z_tabname
         group by trim(substr(t01.z_data, 1, 3)),
                  nvl(trim(substr(t01.z_data, 4, 10)),'*NONE');
      rcd_lads_ref_material_tdu csr_lads_ref_material_tdu%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_MATERIAL_TDU           */
      /*------------------------------------------*/
      delete bds_refrnc_material_tdu;

      open csr_lads_ref_material_tdu;
      loop
         fetch csr_lads_ref_material_tdu into rcd_lads_ref_material_tdu;
          if (csr_lads_ref_material_tdu%notfound) then
             exit;
          end if;

          rcd_bds_refrnc_material_tdu.client_id := rcd_lads_ref_material_tdu.mandt;
          rcd_bds_refrnc_material_tdu.condition_record_no := rcd_lads_ref_material_tdu.knumh;
          rcd_bds_refrnc_material_tdu.tdu_material_code := rcd_lads_ref_material_tdu.smatn;
          rcd_bds_refrnc_material_tdu.tdu_uom := rcd_lads_ref_material_tdu.subme;
          rcd_bds_refrnc_material_tdu.substitution_reason := rcd_lads_ref_material_tdu.sugrd;
          rcd_bds_refrnc_material_tdu.mrp_indctr := rcd_lads_ref_material_tdu.psdsp;
          rcd_bds_refrnc_material_tdu.cross_sell_dlvry_cntrl := rcd_lads_ref_material_tdu.lstacs;
          rcd_bds_refrnc_material_tdu.sap_idoc_number := rcd_lads_ref_material_tdu.idoc_number;
          rcd_bds_refrnc_material_tdu.sap_idoc_timestamp := rcd_lads_ref_material_tdu.idoc_timestamp;
          rcd_bds_refrnc_material_tdu.change_flag := rcd_lads_ref_material_tdu.z_chgtyp;
 

          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_MATERIAL_TDU           */
          /*------------------------------------------*/
          insert into bds_refrnc_material_tdu
                (client_id,
                 condition_record_no,
                 tdu_material_code,
                 tdu_uom,
                 substitution_reason,
                 mrp_indctr,
                 cross_sell_dlvry_cntrl, 
                 change_flag, 
                 sap_idoc_number, 
                 sap_idoc_timestamp)
           values
                (rcd_bds_refrnc_material_tdu.client_id,
                 rcd_bds_refrnc_material_tdu.condition_record_no,
                 rcd_bds_refrnc_material_tdu.tdu_material_code,
                 rcd_bds_refrnc_material_tdu.tdu_uom,
                 rcd_bds_refrnc_material_tdu.substitution_reason,
                 rcd_bds_refrnc_material_tdu.mrp_indctr,
                 rcd_bds_refrnc_material_tdu.cross_sell_dlvry_cntrl,
                 rcd_bds_refrnc_material_tdu.change_flag,
                 rcd_bds_refrnc_material_tdu.sap_idoc_number,
                 rcd_bds_refrnc_material_tdu.sap_idoc_timestamp);

      end loop;
      close csr_lads_ref_material_tdu;

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
         raise_application_error(-20000, 'PROCESS_MATERIAL_TDU :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_material_tdu;


   /***********************************************************************/
   /* This procedure performs the flatten Material ZREP routine           */
   /***********************************************************************/
   procedure process_material_zrep(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_material_zrep bds_refrnc_material_zrep%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ref_material_zrep is
         select nvl(a.mandt,'*NONE') as mandt,
                nvl(a.kappl,'*NONE') as kappl,
                nvl(a.kschd,'*NONE') as kschd,
                nvl(a.vkorg,'*NONE') as vkorg,
                nvl(a.vtweg,'*NONE') as vtweg,
                nvl(a.kunag,'*NONE') as kunag,
                nvl(a.matwa,'*NONE') as matwa,
                a.datbi as datbi,
                a.datab as datab,
                max(a.knumh) as knumh,
                max(a.idoc_number) as idoc_number,
                max(a.idoc_timestamp) as idoc_timestamp,
                max(a.z_chgtyp) as z_chgtyp
         from (select trim(substr(z_data,1,3)) as mandt,
                      trim(substr(z_data,4,2)) as kappl,
                      trim(substr(z_data,6,4)) as kschd,
                      trim(substr(z_data,10,4)) as vkorg,
                      trim(substr(z_data,14,2)) as vtweg,
                      trim(substr(z_data,16,10)) as kunag,
                      trim(substr(z_data,26,18)) as matwa,
                      trim(substr(z_data,44,8)) as datbi,
                      trim(substr(z_data,52,8)) as datab,
                      trim(substr(z_data,60,10)) as knumh,
                      t01.idoc_number as idoc_number,
                      t01.idoc_timestamp as idoc_timestamp,
                      t01.z_chgtyp as z_chgtyp
               from lads_ref_dat t01
               where z_tabname = par_z_tabname
                 and par_z_tabname in ('KOTD501','KOTD907')
               union all
               select trim(substr(z_data,1,3)) as mandt,
                      trim(substr(z_data,4,2)) as kappl,
                      trim(substr(z_data,6,4)) as kschd,
                      trim(substr(z_data,10,4)) as vkorg,
                      null as vtweg,
                      null as kunag,
                      trim(substr(z_data,14,18)) as matwa,
                      trim(substr(z_data,32,8)) as datbi,
                      trim(substr(z_data,40,8)) as datab,
                      trim(substr(z_data,48,10)) as knumh,
                      t01.idoc_number as idoc_number,
                      t01.idoc_timestamp as idoc_timestamp,
                      t01.z_chgtyp as z_chgtyp
               from lads_ref_dat t01
               where z_tabname = par_z_tabname
                 and par_z_tabname in ('KOTD880')
               union all
               select trim(substr(z_data,1,3)) as mandt,
                      trim(substr(z_data,4,2)) as kappl,
                      trim(substr(z_data,6,4)) as kschd,
                      trim(substr(z_data,10,4)) as vkorg,
                      trim(substr(z_data,14,2)) as vtweg,
                      null as kunag,
                      trim(substr(z_data,16,18)) as matwa,
                      trim(substr(z_data,34,8)) as datbi,
                      trim(substr(z_data,42,8)) as datab,
                      trim(substr(z_data,50,10)) as knumh,
                      t01.idoc_number as idoc_number,
                      t01.idoc_timestamp as idoc_timestamp,
                      t01.z_chgtyp as z_chgtyp
               from lads_ref_dat t01
               where z_tabname = par_z_tabname
                 and par_z_tabname in ('KOTD002')) a
         group by nvl(a.mandt,'*NONE'), 
                  nvl(a.kappl,'*NONE'),  
                  nvl(a.kschd,'*NONE'),  
                  nvl(a.vkorg,'*NONE'),  
                  nvl(a.vtweg,'*NONE'),  
                  nvl(a.kunag,'*NONE'),  
                  nvl(a.matwa,'*NONE'),  
                  a.datbi,  
                  a.datab;
      rcd_ref_material_zrep csr_ref_material_zrep%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_MATERIAL_ZREP          */
      /*------------------------------------------*/
      delete bds_refrnc_material_zrep
        where refrnc_code = par_z_tabname;


      open csr_ref_material_zrep;
      loop
         fetch csr_ref_material_zrep into rcd_ref_material_zrep;
         if (csr_ref_material_zrep%notfound) then
            exit;
         end if;

         rcd_bds_refrnc_material_zrep.refrnc_code := par_z_tabname;
         rcd_bds_refrnc_material_zrep.client_id := rcd_ref_material_zrep.mandt;
         rcd_bds_refrnc_material_zrep.application_id := rcd_ref_material_zrep.kappl;
         rcd_bds_refrnc_material_zrep.material_dtrmntn_type := rcd_ref_material_zrep.kschd;
         rcd_bds_refrnc_material_zrep.sales_organisation := rcd_ref_material_zrep.vkorg;
         rcd_bds_refrnc_material_zrep.dstrbtn_channel := rcd_ref_material_zrep.vtweg;
         rcd_bds_refrnc_material_zrep.sold_to_code := rcd_ref_material_zrep.kunag;
         rcd_bds_refrnc_material_zrep.zrep_material_code := rcd_ref_material_zrep.matwa;
         rcd_bds_refrnc_material_zrep.end_date := bds_date.bds_to_date('*END_DATE',rcd_ref_material_zrep.datbi,'yyyymmdd');
         rcd_bds_refrnc_material_zrep.start_date := bds_date.bds_to_date('*START_DATE',rcd_ref_material_zrep.datab,'yyyymmdd');
         rcd_bds_refrnc_material_zrep.condition_record_no := rcd_ref_material_zrep.knumh;
         rcd_bds_refrnc_material_zrep.sap_idoc_number := rcd_ref_material_zrep.idoc_number;
         rcd_bds_refrnc_material_zrep.sap_idoc_timestamp := rcd_ref_material_zrep.idoc_timestamp;
         rcd_bds_refrnc_material_zrep.change_flag := rcd_ref_material_zrep.z_chgtyp;
  
         /*------------------------------------------*/
         /* INSERT BDS_REFRNC_MATERIAL_ZREP          */
         /*------------------------------------------*/
         insert into bds_refrnc_material_zrep
               (refrnc_code,
                client_id, 
                application_id,  
                material_dtrmntn_type, 
                sales_organisation, 
                dstrbtn_channel, 
                sold_to_code, 
                zrep_material_code,  
                start_date,  
                end_date, 
                condition_record_no,  
                change_flag,  
                sap_idoc_number, 
                sap_idoc_timestamp)
          values
               (rcd_bds_refrnc_material_zrep.refrnc_code,
                rcd_bds_refrnc_material_zrep.client_id,
                rcd_bds_refrnc_material_zrep.application_id,
                rcd_bds_refrnc_material_zrep.material_dtrmntn_type,
                rcd_bds_refrnc_material_zrep.sales_organisation,
                rcd_bds_refrnc_material_zrep.dstrbtn_channel,
                rcd_bds_refrnc_material_zrep.sold_to_code,
                rcd_bds_refrnc_material_zrep.zrep_material_code,
                rcd_bds_refrnc_material_zrep.start_date,
                rcd_bds_refrnc_material_zrep.end_date,
                rcd_bds_refrnc_material_zrep.condition_record_no,
                rcd_bds_refrnc_material_zrep.change_flag,
                rcd_bds_refrnc_material_zrep.sap_idoc_number,
                rcd_bds_refrnc_material_zrep.sap_idoc_timestamp);

      end loop;
      close csr_ref_material_zrep;

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
         raise_application_error(-20000, 'PROCESS_MATERIAL_ZREP :  ' || substr(SQLERRM, 1, 1024));


   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_material_zrep;


   /***********************************************************************/
   /* This procedure performs the flatten Purchasing Source routine       */
   /***********************************************************************/
   procedure process_purchasing_src(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_refrnc_purchasing_src bds_refrnc_purchasing_src%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ref_purchasing_src is
         select trim(substr(t01.z_data,4,18)) as sap_material_code,
                trim(substr(t01.z_data,22,4)) as plant_code,
                trim(substr(t01.z_data,26,5)) as record_no,
                trim(substr(max(t01.z_data),31,8)) as creatn_date,
                trim(substr(max(t01.z_data),39,12)) as creatn_user,
                trim(substr(max(t01.z_data),51,8)) as src_list_valid_from,
                trim(substr(max(t01.z_data),59,8)) as src_list_valid_to,
                trim(substr(max(t01.z_data),67,10)) as vendor_code,
                trim(substr(max(t01.z_data),77,1)) as fixed_vendor_indctr,
                trim(substr(max(t01.z_data),78,10)) as agreement_no,
                trim(substr(max(t01.z_data),88,5)) as agreement_item,
                trim(substr(max(t01.z_data),93,1)) as fixed_purchase_agreement_item,
                trim(substr(max(t01.z_data),94,4)) as plant_procured_from,
                trim(substr(max(t01.z_data),98,1)) as sto_fixed_issuing_plant,
                trim(substr(max(t01.z_data),99,18)) as manufctr_part_refrnc_material,
                trim(substr(max(t01.z_data),117,1)) as blocked_supply_src_flag,
                trim(substr(max(t01.z_data),118,4)) as purchasing_organisation,
                trim(substr(max(t01.z_data),122,1)) as purchasing_document_ctgry,
                trim(substr(max(t01.z_data),123,1)) as src_list_ctgry,
                trim(substr(max(t01.z_data),124,1)) as src_list_planning_usage,
                trim(substr(max(t01.z_data),125,3)) as order_unit,
                trim(substr(max(t01.z_data),128,10)) as logical_system,
                trim(substr(max(t01.z_data),138,1)) as special_stock_indctr
         from lads_ref_dat t01
         where t01.z_tabname = par_z_tabname
           and nvl(t01.z_chgtyp,'x') != 'D'
         group by trim(substr(t01.z_data,4,18)),
                  trim(substr(t01.z_data,22,4)),
                  trim(substr(t01.z_data,26,5));
      rcd_ref_purchasing_src csr_ref_purchasing_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_MATERIAL_ZREP          */
      /*------------------------------------------*/
      delete bds_refrnc_purchasing_src;

      open csr_ref_purchasing_src;
      loop
         fetch csr_ref_purchasing_src into rcd_ref_purchasing_src;
         if (csr_ref_purchasing_src%notfound) then
            exit;
         end if;

         rcd_bds_refrnc_purchasing_src.sap_material_code := rcd_ref_purchasing_src.sap_material_code;
         rcd_bds_refrnc_purchasing_src.plant_code := rcd_ref_purchasing_src.plant_code;
         rcd_bds_refrnc_purchasing_src.record_no := rcd_ref_purchasing_src.record_no;
         rcd_bds_refrnc_purchasing_src.creatn_date := bds_date.bds_to_date('*DATE',rcd_ref_purchasing_src.creatn_date,'yyyymmdd');
         rcd_bds_refrnc_purchasing_src.creatn_user := rcd_ref_purchasing_src.creatn_user;
         rcd_bds_refrnc_purchasing_src.src_list_valid_from := bds_date.bds_to_date('*START_DATE',rcd_ref_purchasing_src.src_list_valid_from,'yyyymmdd');
         rcd_bds_refrnc_purchasing_src.src_list_valid_to := bds_date.bds_to_date('*END_DATE',rcd_ref_purchasing_src.src_list_valid_to,'yyyymmdd');
         rcd_bds_refrnc_purchasing_src.vendor_code := rcd_ref_purchasing_src.vendor_code;
         rcd_bds_refrnc_purchasing_src.fixed_vendor_indctr := rcd_ref_purchasing_src.fixed_vendor_indctr;
         rcd_bds_refrnc_purchasing_src.agreement_no := rcd_ref_purchasing_src.agreement_no;
         rcd_bds_refrnc_purchasing_src.agreement_item := rcd_ref_purchasing_src.agreement_item;
         rcd_bds_refrnc_purchasing_src.fixed_purchase_agreement_item := rcd_ref_purchasing_src.fixed_purchase_agreement_item;
         rcd_bds_refrnc_purchasing_src.plant_procured_from := rcd_ref_purchasing_src.plant_procured_from;
         rcd_bds_refrnc_purchasing_src.sto_fixed_issuing_plant := rcd_ref_purchasing_src.sto_fixed_issuing_plant;
         rcd_bds_refrnc_purchasing_src.manufctr_part_refrnc_material := rcd_ref_purchasing_src.manufctr_part_refrnc_material;
         rcd_bds_refrnc_purchasing_src.blocked_supply_src_flag := rcd_ref_purchasing_src.blocked_supply_src_flag;
         rcd_bds_refrnc_purchasing_src.purchasing_organisation := rcd_ref_purchasing_src.purchasing_organisation;
         rcd_bds_refrnc_purchasing_src.purchasing_document_ctgry := rcd_ref_purchasing_src.purchasing_document_ctgry;
         rcd_bds_refrnc_purchasing_src.src_list_ctgry := rcd_ref_purchasing_src.src_list_ctgry;
         rcd_bds_refrnc_purchasing_src.src_list_planning_usage := rcd_ref_purchasing_src.src_list_planning_usage;
         rcd_bds_refrnc_purchasing_src.order_unit := rcd_ref_purchasing_src.order_unit;
         rcd_bds_refrnc_purchasing_src.logical_system := rcd_ref_purchasing_src.logical_system;
         rcd_bds_refrnc_purchasing_src.special_stock_indctr := rcd_ref_purchasing_src.special_stock_indctr;

  
         /*------------------------------------------*/
         /* INSERT BDS_REFRNC_MATERIAL_ZREP          */
         /*------------------------------------------*/
         insert into bds_refrnc_purchasing_src
               (sap_material_code,
                plant_code,
                record_no,
                creatn_date,
                creatn_user,
                src_list_valid_from,
                src_list_valid_to,
                vendor_code,
                fixed_vendor_indctr,
                agreement_no,
                agreement_item,
                fixed_purchase_agreement_item,
                plant_procured_from,
                sto_fixed_issuing_plant,
                manufctr_part_refrnc_material,
                blocked_supply_src_flag,
                purchasing_organisation,
                purchasing_document_ctgry,
                src_list_ctgry,
                src_list_planning_usage,
                order_unit,
                logical_system,
                special_stock_indctr)
          values
               (rcd_bds_refrnc_purchasing_src.sap_material_code,
                rcd_bds_refrnc_purchasing_src.plant_code,
                rcd_bds_refrnc_purchasing_src.record_no,
                rcd_bds_refrnc_purchasing_src.creatn_date,
                rcd_bds_refrnc_purchasing_src.creatn_user,
                rcd_bds_refrnc_purchasing_src.src_list_valid_from,
                rcd_bds_refrnc_purchasing_src.src_list_valid_to,
                rcd_bds_refrnc_purchasing_src.vendor_code,
                rcd_bds_refrnc_purchasing_src.fixed_vendor_indctr,
                rcd_bds_refrnc_purchasing_src.agreement_no,
                rcd_bds_refrnc_purchasing_src.agreement_item,
                rcd_bds_refrnc_purchasing_src.fixed_purchase_agreement_item,
                rcd_bds_refrnc_purchasing_src.plant_procured_from,
                rcd_bds_refrnc_purchasing_src.sto_fixed_issuing_plant,
                rcd_bds_refrnc_purchasing_src.manufctr_part_refrnc_material,
                rcd_bds_refrnc_purchasing_src.blocked_supply_src_flag,
                rcd_bds_refrnc_purchasing_src.purchasing_organisation,
                rcd_bds_refrnc_purchasing_src.purchasing_document_ctgry,
                rcd_bds_refrnc_purchasing_src.src_list_ctgry,
                rcd_bds_refrnc_purchasing_src.src_list_planning_usage,
                rcd_bds_refrnc_purchasing_src.order_unit,
                rcd_bds_refrnc_purchasing_src.logical_system,
                rcd_bds_refrnc_purchasing_src.special_stock_indctr);

      end loop;
      close csr_ref_purchasing_src;

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
         raise_application_error(-20000, 'PROCESS_PURCHASING_SRC :  ' || substr(SQLERRM, 1, 1024));


   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_purchasing_src;


   /***********************************************************************/
   /* This procedure performs the flatten Production Resource Text routine*/
   /***********************************************************************/
   procedure process_prodctn_resrc_text(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_prodctn_resrc_text bds_refrnc_prodctn_resrc_text%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_prodctn_resrc is
         select nvl(trim(substr(t01.z_data, 1, 3)),'*NONE') as client_id,
                nvl(trim(substr(t01.z_data, 4, 2)),'*NONE') as resrc_type,
                nvl(trim(substr(t01.z_data, 6, 8)),'*NONE') as resrc_id,
                nvl(trim(substr(t01.z_data, 14, 1)),'*NONE') as resrc_lang,
                trim(substr(max(t01.z_data), 35, 40)) as resrc_text,
                trim(substr(max(t01.z_data), 75, 40)) as resrc_text_upper,
                trim(substr(max(t01.z_data), 15, 8)) as change_date,
                trim(substr(max(t01.z_data), 23, 12)) as change_user,					
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp
         from lads_ref_dat t01
         where t01.z_tabname = par_z_tabname
         group by nvl(trim(substr(t01.z_data, 1, 3)),'*NONE'), 
                  nvl(trim(substr(t01.z_data, 4, 2)),'*NONE'), 
                  nvl(trim(substr(t01.z_data, 6, 8)),'*NONE'),
                  nvl(trim(substr(t01.z_data, 14, 1)),'*NONE');
      rcd_lads_ref_prodctn_resrc csr_lads_ref_prodctn_resrc%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_PRODCTN_RESRC_TEXT     */
      /*------------------------------------------*/
      delete bds_refrnc_prodctn_resrc_text;

      open csr_lads_ref_prodctn_resrc;
      loop
         fetch csr_lads_ref_prodctn_resrc into rcd_lads_ref_prodctn_resrc;
          if (csr_lads_ref_prodctn_resrc%notfound) then
             exit;
          end if;

          rcd_bds_prodctn_resrc_text.client_id := rcd_lads_ref_prodctn_resrc.client_id;
          rcd_bds_prodctn_resrc_text.resrc_type := rcd_lads_ref_prodctn_resrc.resrc_type;
          rcd_bds_prodctn_resrc_text.resrc_id := rcd_lads_ref_prodctn_resrc.resrc_id;
          rcd_bds_prodctn_resrc_text.resrc_lang := rcd_lads_ref_prodctn_resrc.resrc_lang;
          rcd_bds_prodctn_resrc_text.resrc_text := rcd_lads_ref_prodctn_resrc.resrc_text;
          rcd_bds_prodctn_resrc_text.resrc_text_upper := rcd_lads_ref_prodctn_resrc.resrc_text_upper;
          rcd_bds_prodctn_resrc_text.change_date := bds_date.bds_to_date('*DATE',rcd_lads_ref_prodctn_resrc.change_date,'yyyymmdd');
          rcd_bds_prodctn_resrc_text.change_user := rcd_lads_ref_prodctn_resrc.change_user;
          rcd_bds_prodctn_resrc_text.sap_idoc_number := rcd_lads_ref_prodctn_resrc.idoc_number;
          rcd_bds_prodctn_resrc_text.sap_idoc_timestamp := rcd_lads_ref_prodctn_resrc.idoc_timestamp;
          rcd_bds_prodctn_resrc_text.change_flag := rcd_lads_ref_prodctn_resrc.z_chgtyp;
 
          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_PRODCTN_RESRC_TEXT     */
          /*------------------------------------------*/
          insert into bds_refrnc_prodctn_resrc_text
                (client_id,
                 resrc_type,
                 resrc_id,
                 resrc_lang,
                 resrc_text,
                 resrc_text_upper,
                 change_date,
                 change_user, 
                 sap_idoc_number, 
                 sap_idoc_timestamp,
                 change_flag)
           values
                (rcd_bds_prodctn_resrc_text.client_id,
                 rcd_bds_prodctn_resrc_text.resrc_type,
                 rcd_bds_prodctn_resrc_text.resrc_id,
                 rcd_bds_prodctn_resrc_text.resrc_lang,
                 rcd_bds_prodctn_resrc_text.resrc_text,
                 rcd_bds_prodctn_resrc_text.resrc_text_upper,
                 rcd_bds_prodctn_resrc_text.change_date,
                 rcd_bds_prodctn_resrc_text.change_user,
                 rcd_bds_prodctn_resrc_text.sap_idoc_number,
                 rcd_bds_prodctn_resrc_text.sap_idoc_timestamp,
                 rcd_bds_prodctn_resrc_text.change_flag);

      end loop;
      close csr_lads_ref_prodctn_resrc;

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
         raise_application_error(-20000, 'PROCESS_PRODCTN_RESRC_TEXT :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_prodctn_resrc_text;



   /***********************************************************************/
   /* This procedure performs the flatten Production Resource HDR routine */
   /***********************************************************************/
   procedure process_prodctn_resrc_hdr(par_z_tabname in varchar2) is

      /*-*/
      /* Private definitions
      /*-*/
      rcd_bds_prodctn_resrc_hdr bds_refrnc_prodctn_resrc_hdr%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_prodctn_resrc is
         select nvl(trim(substr(t01.z_data, 1, 3)),'*NONE') as client_id,
                nvl(trim(substr(t01.z_data, 4, 2)),'*NONE') as resrc_type,
                nvl(trim(substr(t01.z_data, 6, 8)),'*NONE') as resrc_id,
                trim(substr(max(t01.z_data), 110, 8)) as resrc_code,
                trim(substr(max(t01.z_data), 118, 4)) as resrc_plant_code,		
                trim(substr(max(t01.z_data), 122, 4)) as resrc_ctgry,		
                trim(substr(max(t01.z_data), 126, 1)) as resrc_deletion_flag,		
                max(t01.idoc_number) as idoc_number,
                max(t01.idoc_timestamp) as idoc_timestamp,
                max(t01.z_chgtyp) as z_chgtyp
         from lads_ref_dat t01
         where t01.z_tabname = par_z_tabname
           and trim(substr(t01.z_data, 1, 3)) = '002'
         group by nvl(trim(substr(t01.z_data, 1, 3)),'*NONE'), 
                  nvl(trim(substr(t01.z_data, 4, 2)),'*NONE'), 
                  nvl(trim(substr(t01.z_data, 6, 8)),'*NONE');
      rcd_lads_ref_prodctn_resrc csr_lads_ref_prodctn_resrc%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* DELETE BDS_REFRNC_PRODCTN_RESRC_HDR      */
      /*------------------------------------------*/
      delete bds_refrnc_prodctn_resrc_hdr;

      open csr_lads_ref_prodctn_resrc;
      loop
         fetch csr_lads_ref_prodctn_resrc into rcd_lads_ref_prodctn_resrc;
          if (csr_lads_ref_prodctn_resrc%notfound) then
             exit;
          end if;

          rcd_bds_prodctn_resrc_hdr.client_id := rcd_lads_ref_prodctn_resrc.client_id;
          rcd_bds_prodctn_resrc_hdr.resrc_type := rcd_lads_ref_prodctn_resrc.resrc_type;
          rcd_bds_prodctn_resrc_hdr.resrc_id := rcd_lads_ref_prodctn_resrc.resrc_id;
          rcd_bds_prodctn_resrc_hdr.resrc_code := rcd_lads_ref_prodctn_resrc.resrc_code;
          rcd_bds_prodctn_resrc_hdr.resrc_plant_code := rcd_lads_ref_prodctn_resrc.resrc_plant_code;
          rcd_bds_prodctn_resrc_hdr.resrc_ctgry := rcd_lads_ref_prodctn_resrc.resrc_ctgry;
          rcd_bds_prodctn_resrc_hdr.resrc_deletion_flag := rcd_lads_ref_prodctn_resrc.resrc_deletion_flag;
          rcd_bds_prodctn_resrc_hdr.sap_idoc_number := rcd_lads_ref_prodctn_resrc.idoc_number;
          rcd_bds_prodctn_resrc_hdr.sap_idoc_timestamp := rcd_lads_ref_prodctn_resrc.idoc_timestamp;
          rcd_bds_prodctn_resrc_hdr.change_flag := rcd_lads_ref_prodctn_resrc.z_chgtyp;
 
          /*------------------------------------------*/
          /* INSERT BDS_REFRNC_PRODCTN_RESRC_HDR      */
          /*------------------------------------------*/
          insert into bds_refrnc_prodctn_resrc_hdr
                (client_id,
                 resrc_type,
                 resrc_id,
                 resrc_code,
                 resrc_plant_code,
                 resrc_ctgry,
                 resrc_deletion_flag,
                 sap_idoc_number, 
                 sap_idoc_timestamp,
                 change_flag)
           values
                (rcd_bds_prodctn_resrc_hdr.client_id,
                 rcd_bds_prodctn_resrc_hdr.resrc_type,
                 rcd_bds_prodctn_resrc_hdr.resrc_id,
                 rcd_bds_prodctn_resrc_hdr.resrc_code,
                 rcd_bds_prodctn_resrc_hdr.resrc_plant_code,
                 rcd_bds_prodctn_resrc_hdr.resrc_ctgry,
                 rcd_bds_prodctn_resrc_hdr.resrc_deletion_flag,
                 rcd_bds_prodctn_resrc_hdr.sap_idoc_number,
                 rcd_bds_prodctn_resrc_hdr.sap_idoc_timestamp,
                 rcd_bds_prodctn_resrc_hdr.change_flag);

      end loop;
      close csr_lads_ref_prodctn_resrc;

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
         raise_application_error(-20000, 'PROCESS_PRODCTN_RESRC_HDR :  ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_prodctn_resrc_hdr;




   /*******************************************************************************/
   /* This procedure performs the lock routine                                    */
   /*   notes - acquires a lock on the LADS header record                         */
   /*         - uses NOWAIT, assumes if locked, LADS load will re-call flattening */
   /*         - issues commit to release lock                                     */
   /*         - used when manually executing flattening                           */
   /*******************************************************************************/
   procedure lads_lock(par_z_tabname in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select *
         from lads_ref_hdr t01
         where t01.z_tabname = par_z_tabname
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
         bds_flatten(par_z_tabname);

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
         select t01.z_tabname
         from lads_ref_hdr t01
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

         lads_lock(rcd_flatten.z_tabname);

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
      bds_table.truncate('bds_refrnc_prodctn_resrc_hdr');
      bds_table.truncate('bds_refrnc_prodctn_resrc_text');
      bds_table.truncate('bds_refrnc_purchasing_src');
      bds_table.truncate('bds_refrnc_material_zrep');
      bds_table.truncate('bds_refrnc_material_tdu');
      bds_table.truncate('bds_refrnc_bom_altrnt_t415a');
      bds_table.truncate('bds_refrnc_plant');
      bds_table.truncate('bds_refrnc_acct_assgnmnt_grp');
      bds_table.truncate('bds_refrnc_charistic');
      bds_table.truncate('bds_refrnc_moe');


      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_ref_hdr
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

end bds_atllad10_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad10_flatten for bds_app.bds_atllad10_flatten;
grant execute on bds_atllad10_flatten to lics_app;
grant execute on bds_atllad10_flatten to lads_app;
