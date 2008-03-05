create or replace package plant_material_extract 
as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_material_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Material Data for Plant databases 

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all material data  
    *MATERIAL - send material data matching a given material code 
    *HISTORY - send material data updated since a specific point in the past 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *MATERIAL = material code 
      - *HISTORY = number of days 

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
  
  YYYY/MM    Author       Description 
  -------    ------       ----------- 
  2007/11   J. Phillipson Created 
  2007/11   J. Phillipson Added ability to send 1 matl code 
  2007/12   J. Phillipson Changed criteria to accept numerical value in minutes 
  2008/02   J. Phillipson Changed criteria to just material so it can be 
                            trigged by changes only to LADS table 
  2008/03   J. Phillipson Added sending of Packaging instruction data 
  2008/03   T. Keon       Changed structure to match new standards    

*******************************************************************************/ 


  /*-*/
  /* Public declarations 
  /* par_material either null or a material code 
  /*-*/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default null);

end plant_material_extract;
/

create or replace package body plant_material_extract
as
/******************************************************************************
   NAME: plant_material_extract
*****************************************************************************/

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
      
  /*-*/
  /* Private declarations
  /*-*/
  procedure execute_extract(par_action in varchar2, par_option in varchar2);
  procedure execute_send(par_interface in varchar2);
  
  var_interface varchar2(32 char);    
      
  /*-*/
  /* Private declarations
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;
  tbl_interface typ_definition;

  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default null) is
    
    /*-*/
    /* Local definitions
    /*-*/
    var_exception varchar2(4000);
    var_instance  number(15,0);
    var_output    varchar2(4000);
    var_index     number(5,0);
    var_index_01  number(5,0);
    var_material_code bds_material_hdr.sap_material_code%type;
    
    var_action    varchar2(10);
    var_data      varchar2(100);
    var_site      varchar2(10);
         
  BEGIN
  
    var_action := upper(nvl(trim(par_action), 'x'));
    var_data := nvl(trim(par_data), 'x');
    var_site := upper(nvl(trim(par_site), 'x'));
    
    /*-*/
    /* validate parameters 
    /*-*/
    if var_action != '*ALL'
        and var_action != '*MATERIAL'
        and var_action != '*HISTORY' then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *MATERIAL or *HISTORY');
    end if;
    
    if var_action = '*MATERIAL'
        and var_data = 'x' then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *MATERIAL actions.');
    elsif var_action = '*HISTORY'
        and ( var_data = 'x' or to_number(var_data) <= 0 ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null and must be greater than 1 for *HISTORY actions.');
    end if;
     
     
     --IF NOT (par_material = '*ALL' OR length(par_material) > 0) THEN
     IF NVL(TRIM(par_material), 'x') != '*ALL') THEN
         raise_application_error(-20000,'Package: plant_material_extract parameter:' || par_material || ' is only *ALL or a material code.');
     END IF;
     IF NOT(par_plant_code IS NULL OR (length(par_plant_code) = 4 AND substr(par_plant_code,0,2) IN ('AU','NZ'))) THEN
         raise_application_error(-20000,'Package: plant_material_extract parameter:' || par_plant_code || ' is not valid.');
     END IF;
     
     /*-*/
     /* set defaults
     /*-*/
     var_material_code := '';
     var_index := 0;
     var_index_01 := 0;
     /*-*/
     /* clear table records
     /*-*/
     tbl_definition.DELETE;
     tbl_interface.DELETE;

          execute_retrieve(par_action, par_option);
          validate par_action
          validate par_option
          execute retrieve
          
     
     if (par_site = '*ALL' or '*SCO') then
          execute_extract('LADPDB02.6');
     if (.....)
     
     end if
     -- validate par_site earlier 
        raise exception, must be *SCO,.....
     end if;
     
     
     /*-*/
     /* Create an array of interfaces 
     /*-*/
     var_index_01 := tbl_interface.count + 1;
     tbl_interface(var_index_01).value := 'LADPDB02.5';  -- Ballarat plant
     var_index_01 := tbl_interface.count + 1;
     tbl_interface(var_index_01).value := 'LADPDB02.6';  -- Scoresby plant
     /*var_index_01 := tbl_interface.count + 1;
     tbl_interface(var_index_01).value := 'LADPDB02.1';  -- Wyong plant
     var_index_01 := tbl_interface.count + 1;
     tbl_interface(var_index_01).value := 'LADPDB02.2';  -- Wanganui plant
     var_index_01 := tbl_interface.count + 1;
     tbl_interface(var_index_01).value := 'LADPDB02.3'; -- Wodonga plant
     var_index_01 := tbl_interface.count + 1;
     tbl_interface(var_index_01).value := 'LADPDB02.4'; -- Bathurst plant
     */
      
     OPEN csr_bds_material_plant_mfanz;
     LOOP
         FETCH csr_bds_material_plant_mfanz INTO rcd_bds_material_plant_mfanz;
         EXIT WHEN csr_bds_material_plant_mfanz%NOTFOUND;
         
         var_index := tbl_definition.count + 1;
            
         var_output := 'HDR';
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.sap_material_code,' '),18,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.plant_code,' '),4,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.bds_material_desc_en,' '),40,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.material_type,' '),4,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.material_grp,' '),9,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.base_uom,' '),3,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.order_unit,' '),3,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.gross_weight),'0'),38,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.net_weight),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.gross_weight_unit,' '),3,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.LENGTH),'0'),38,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.width),'0'),38,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.height),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.dimension_uom,' '),3,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.interntl_article_no,' '),18,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.total_shelf_life),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_intrmdt_prdct_compnt_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_merchandising_unit_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_prmotional_material_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_retail_sales_unit_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_semi_finished_prdct_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_rprsnttv_item_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_traded_unit_flag,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.xplant_status,' '),2,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.xplant_status_valid,'yyyymmddhh24miss'),' '),14,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.batch_mngmnt_reqrmnt_indctr,' '),2,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.mars_plant_material_type),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.procurement_type,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.special_procurement_type,' '),2,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.issue_storage_location,' '),4,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mrp_controller,' '),3,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.plant_specific_status_valid,'yyyymmddhh24miss'),' '),14,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.deletion_indctr,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.plant_specific_status,' '),2,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.assembly_scrap_percntg),'0'),38,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.component_scrap_percntg),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.backflush_indctr,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_rprsnttv_item_code,' '),18,' ');
         var_output := var_output || RPAD(NVL(SUBSTR(rcd_bds_material_plant_mfanz.sales_text_147,1,1000),' '),1000,' ');
         var_output := var_output || RPAD(NVL(SUBSTR(rcd_bds_material_plant_mfanz.sales_text_149,1,1000),' '),1000,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.regional_code_10,' '),18,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.regional_code_17,' '),18,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.regional_code_18,' '),18,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.regional_code_19,' '),18,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.price_unit),'0'),38,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.future_planned_price_1),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.vltn_class,' '),4,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.bds_pce_factor_from_base_uom),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_pce_item_code,' '),18,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_pce_interntl_article_no,' '),18,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.bds_sb_factor_from_base_uom),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mars_sb_item_code,' '),18,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.effective_out_date,'yyyymmddhh24miss'),' '),14,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.discontinuation_indctr,' '),1,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.followup_material,' '),18,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.material_division,' '),2,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.mrp_type,' '),2,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.max_storage_prd),'0'),38,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.max_storage_prd_unit,' '),3,' ');
         var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.issue_unit,' '),3,' ');
         var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_plant_mfanz.planned_delivery_days),'0'),38,' ');
         tbl_definition(var_index).value := var_output; 
          
         IF LENGTH(rcd_bds_material_plant_mfanz.sales_text_147) > 1000 THEN
             /*-*/
             /* send second part of text block if exists
             /* this has to be split since the standard var_output variable above is limited to 4000 chars 
             /*-*/
             var_index := tbl_definition.count + 1;
             
             var_output := 'STX147';
             var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.sap_material_code,' '),18,' ');
             var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.plant_code,' '),4,' ');
             var_output := var_output || RPAD(NVL(SUBSTR(rcd_bds_material_plant_mfanz.sales_text_147,1001,1000),' '),1000,' ');
             tbl_definition(var_index).value := var_output; 
         END IF;
          
         IF LENGTH(rcd_bds_material_plant_mfanz.sales_text_149) > 1000 THEN
             
             var_index := tbl_definition.count + 1;
             
             var_output := 'ST9';
             var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.sap_material_code,' '),18,' ');
             var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.plant_code,' '),4,' ');
             var_output := var_output || RPAD(NVL(SUBSTR(rcd_bds_material_plant_mfanz.sales_text_149,1001,1000),' '),1000,' ');
             tbl_definition(var_index).value := var_output; 
         END IF;
         
         /*-*/
         /* add entries for the associated packaging instructions
         /* these are not plant code spoecific
         /*-*/
         IF var_material_code <> rcd_bds_material_plant_mfanz.sap_material_code OR var_material_code IS NULL THEN
         
             OPEN csr_bds_material_pkg_instr_det;
             LOOP
                 FETCH csr_bds_material_pkg_instr_det INTO rcd_bds_material_pkg_instr_det;
                 EXIT WHEN csr_bds_material_pkg_instr_det%NOTFOUND;
                 
                 var_index := tbl_definition.count + 1;
                 
                 var_output := 'PKG';
                 var_output := var_output || RPAD(NVL(rcd_bds_material_plant_mfanz.sap_material_code,' '),18,' ');
                 var_output := var_output || nvl(rcd_bds_material_pkg_instr_det.pkg_instr_table_usage,' ');
                 var_output := var_output || rpad(NVL(rcd_bds_material_pkg_instr_det.pkg_instr_table,' '),64,' ');
                 var_output := var_output || rpad(NVL(rcd_bds_material_pkg_instr_det.pkg_instr_type,' '),4,' ');
                 var_output := var_output || rpad(NVL(rcd_bds_material_pkg_instr_det.pkg_instr_application,' '),2,' ');
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.item_ctgry,' '),2,' ');
                 var_output := var_output || rpad(NVL(rcd_bds_material_pkg_instr_det.sales_organisation,' '),4,' ');
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.component,' '), 20,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.pkg_instr_start_date,'yyyymmddhh24miss'),' '),14,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.pkg_instr_end_date,'yyyymmddhh24miss'),' '),14,' ');
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.variable_key,' '),100,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.height),'0'),38,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.width),'0'),38,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.length),'0'),38,' ');                 
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.hu_total_weight),'0'),38,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.hu_total_volume),'0'),38,' ');
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.dimension_uom,' '),3,' ');
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.weight_unit,' '),3,' ');
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.volume_unit,' '),3,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.target_qty),'0'),38,' ');
                 var_output := var_output || RPAD(NVL(TO_CHAR(rcd_bds_material_pkg_instr_det.rounding_qty),'0'),38,' '); 
                 var_output := var_output || RPAD(NVL(rcd_bds_material_pkg_instr_det.uom,' '),3,' ');
                 tbl_definition(var_index).value := var_output; 
             END LOOP;
             CLOSE csr_bds_material_pkg_instr_det;
             
             
         END IF;
         
         /*-*/
         /* save code so that only one packaging record is assembled against the material code
         /*-*/
         var_material_code := rcd_bds_material_plant_mfanz.sap_material_code;
         
     END LOOP;
     CLOSE csr_bds_material_plant_mfanz;
      
     /*-*/
     FOR idx01 IN 1..tbl_interface.count LOOP
         FOR idx IN 1..tbl_definition.count LOOP
             IF NOT lics_outbound_loader.is_created THEN
                 var_instance := lics_outbound_loader.create_interface(tbl_interface(idx01).value, NULL, tbl_interface(idx01).value);
             END IF;
             lics_outbound_loader.append_data(tbl_definition(idx).value);
         END LOOP;
         /*-*/
         IF lics_outbound_loader.is_created THEN
             lics_outbound_loader.finalise_interface;
         END IF;
     END LOOP;
     COMMIT;
      
  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  EXCEPTION

      /**/
      /* Exception trap
     /**/
      WHEN OTHERS THEN

         /*-*/
         /* Rollback the database
                       /*-*/
         ROLLBACK;

         /*-*/
         /* Save the exception
                       /*-*/
         var_exception := SUBSTR(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
                       /*-*/
         IF lics_outbound_loader.is_created = TRUE THEN
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         END IF;

         /*-*/
         /* Raise an exception to the calling application
                        /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'plant_material_extract - ' || 'sap_material_code: ' || TO_CHAR(rcd_bds_material_plant_mfanz.sap_material_code) || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
   
  procedure execute_extract(par_action in varchar2, par_option in varchar2) is
  
        /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_bds_material_plant_mfanz 
      IS
      SELECT t01.sap_material_code as sap_material_code,
             t02.plant_code as plant_code,
             t01.bds_material_desc_en as bds_material_desc_en,
             t01.material_type as material_type,
             t01.material_grp as material_grp,
             t01.base_uom as base_uom,
             t01.order_unit as order_unit,
             t01.gross_weight as gross_weight,
             t01.net_weight as net_weight,
             t01.gross_weight_unit as gross_weight_unit,
             t01.LENGTH as LENGTH,
             t01.width as width,
             t01.height as height,
             t01.dimension_uom as dimension_uom,
             t01.interntl_article_no as interntl_article_no,
             t01.total_shelf_life as total_shelf_life,
             t01.mars_intrmdt_prdct_compnt_flag as mars_intrmdt_prdct_compnt_flag,
             t01.mars_merchandising_unit_flag as mars_merchandising_unit_flag,
             t01.mars_prmotional_material_flag as mars_prmotional_material_flag,
             t01.mars_retail_sales_unit_flag as mars_retail_sales_unit_flag,
             t01.mars_semi_finished_prdct_flag as mars_semi_finished_prdct_flag,
             t01.mars_rprsnttv_item_flag as mars_rprsnttv_item_flag,
             t01.mars_traded_unit_flag as mars_traded_unit_flag,
             t01.xplant_status as xplant_status,
             to_char(t01.xplant_status_valid, 'yyyymmddhh24miss') as xplant_status_valid,
             t01.batch_mngmnt_reqrmnt_indctr as batch_mngmnt_reqrmnt_indctr,
             t02.mars_plant_material_type as mars_plant_material_type,
             t02.procurement_type as procurement_type,
             t02.special_procurement_type as special_procurement_type,
             t02.issue_storage_location as issue_storage_location,
             t02.mrp_controller as mrp_controller,
             to_char(t02.plant_specific_status_valid, 'yyyymmddhh24miss') as plant_specific_status_valid,
             t02.deletion_indctr as deletion_indctr,
             t02.plant_specific_status as plant_specific_status,
             t02.assembly_scrap_percntg as assembly_scrap_percntg,
             t02.component_scrap_percntg as component_scrap_percntg,
             t02.backflush_indctr as backflush_indctr,
             t01.mars_rprsnttv_item_code as mars_rprsnttv_item_code,
             t03.sales_text_147 as sales_text_147,
             t03.sales_text_149 as sales_text_149,
             t04.regional_code_10 as regional_code_10,
             t04.regional_code_17 as regional_code_17,
             t04.regional_code_18 as regional_code_18,
             t04.regional_code_19 as regional_code_19,
             t05.stndrd_price / t05.price_unit as price_unit,
             t05.future_planned_price_1 as future_planned_price_1,
             t05.vltn_class as vltn_class,
             DECODE(t06.bds_pce_factor_from_base_uom,NULL,1,t06.bds_pce_factor_from_base_uom) as bds_pce_factor_from_base_uom,
             t06.mars_pce_item_code as mars_pce_item_code,
             t06.mars_pce_interntl_article_no as mars_pce_interntl_article_no,
             t06.bds_sb_factor_from_base_uom as bds_sb_factor_from_base_uom,
             t06.mars_sb_item_code as mars_sb_item_code,
             to_char(t02.effective_out_date, 'yyyymmddhh24miss') as effective_out_date,
             t02.discontinuation_indctr as discontinuation_indctr,
             t02.followup_material as followup_material,
             t01.material_division as material_division,
             t02.mrp_type as mrp_type,
             t02.max_storage_prd as max_storage_prd,
             t02.max_storage_prd_unit as max_storage_prd_unit,
             t02.issue_unit as issue_unit,
             t02.planned_delivery_days as planned_delivery_days
        FROM bds_material_hdr t01,
             bds_material_plant_hdr t02,
             (SELECT sap_material_code,
                     MAX(CASE WHEN sales_organisation = '147' THEN text END) as sales_text_147,
                     MAX(CASE WHEN sales_organisation = '149' THEN text END) as sales_text_149
             FROM bds_material_text_en
               WHERE sales_organisation IN ('147','149')
                 AND dstrbtn_channel = '99'
               GROUP BY sap_material_code) t03,
             (SELECT sap_material_code,
                     MAX(CASE WHEN regional_code_id = '10' THEN regional_code END) as regional_code_10,
                     MAX(CASE WHEN regional_code_id = '18' THEN regional_code END) as regional_code_18,
                     MAX(CASE WHEN regional_code_id = '17' THEN regional_code END) as regional_code_17,
                     MAX(CASE WHEN regional_code_id = '19' THEN regional_code END) as regional_code_19
                FROM bds_material_regional
               WHERE regional_code_id IN ('10', '18', '17', '19')
               GROUP BY sap_material_code) t04,
             bds_material_vltn t05,
             (SELECT sap_material_code,
                     MAX(CASE WHEN uom_code = 'PCE' THEN bds_factor_from_base_uom END) as bds_pce_factor_from_base_uom,
                     MAX(CASE WHEN uom_code = 'PCE' THEN mars_pc_item_code END) as mars_pce_item_code,
                     MAX(CASE WHEN uom_code = 'PCE' THEN interntl_article_no END) as mars_pce_interntl_article_no,
                     MAX(CASE WHEN uom_code = 'SB' THEN bds_factor_from_base_uom END) as bds_sb_factor_from_base_uom,
                     MAX(CASE WHEN uom_code = 'SB' THEN mars_pc_item_code END) as mars_sb_item_code
                FROM bds_material_uom
               WHERE uom_code IN ('PCE','SB')
               GROUP BY sap_material_code) t06
       WHERE t01.sap_material_code = t02.sap_material_code
         AND t01.mars_rprsnttv_item_code = t03.sap_material_code(+)
         AND t01.sap_material_code = t04.sap_material_code(+)
         AND t02.sap_material_code = t05.sap_material_code(+)
         AND t02.plant_code = t05.vltn_area(+)
         AND t01.sap_material_code = t06.sap_material_code(+)
         AND t01.material_type IN ('ROH', 'VERP', 'NLAG', 'PIPE', 'FERT') -- all interested materials
         AND t01.deletion_flag IS NULL
         AND (t02.plant_code LIKE 'AU%' OR t02.plant_code LIKE 'NZ%')
         AND t02.deletion_indctr IS NULL
         AND t05.vltn_type(+) = '*NONE'
         AND t05.deletion_indctr(+) IS NULL 
         AND (LTRIM(t01.sap_material_code,'0') = ltrim(par_material,'0') OR par_material = '*ALL')
         AND (t01.bds_lads_date >= par_history OR par_history IS NULL)
         AND (t02.plant_code = par_plant_code OR par_plant_code IS NULL); 
         
      rcd_bds_material_plant_mfanz csr_bds_material_plant_mfanz%ROWTYPE; 
      
      
      CURSOR csr_bds_material_pkg_instr_det
      IS
      SELECT t01.sap_material_code as sap_material_code,
             t01.pkg_instr_table_usage as pkg_instr_table_usage,
             t01.pkg_instr_table as pkg_instr_table,
             t01.pkg_instr_type as pkg_instr_type,
             t01.pkg_instr_application as pkg_instr_application,
             to_char(t01.pkg_instr_start_date, 'yyyymmddhh24miss') as pkg_instr_start_date,
             to_char(t01.pkg_instr_end_date, 'yyyymmddhh24miss') as pkg_instr_end_date,
             t01.sales_organisation as sales_organisation,
             t01.item_ctgry as item_ctgry,
             t01.component as component,
             t01.target_qty as target_qty,
             t01.min_qty as min_qty,
             t01.rounding_qty as rounding_qty,
             t01.uom as uom,
             t01.load_carrier_indctr as load_carrier_indctr,
             t01.pkg_instr_no as pkg_instr_no,
             t01.variable_key as variable_key,
             t01.alternative_pkg_instr_1 as alternative_pkg_instr_1,
             t01.alternative_pkg_instr_2 as alternative_pkg_instr_2,
             t01.alternative_pkg_instr_3 as alternative_pkg_instr_3,
             t01.alternative_pkg_instr_4 as alternative_pkg_instr_4,
             t01.height as height,
             t01.width as width,
             t01.length as length,
             t01.pkg_material_tare_weight as pkg_material_tare_weight,
             t01.goods_load_weight as goods_load_weight,
             t01.hu_total_weight as hu_total_weight,
             t01.pkg_material_tare_volume as pkg_material_tare_volume,
             t01.goods_load_volume as goods_load_volume,
             t01.hu_total_volume as hu_total_volume,
             t01.pkg_instr_id_no as pkg_instr_id_no,
             t01.stack_factor as stack_factor,
             t01.change_date as change_date,
             t01.dimension_uom as dimension_uom,
             t01.weight_unit as weight_unit,
             t01.max_weight_unit as max_weight_unit,
             t01.volume_unit as volume_unit,
             t01.max_volume_unit as max_volume_unit
        FROM bds_material_pkg_instr_det t01
       WHERE t01.pkg_instr_table_usage = 'P'
         AND t01.pkg_instr_application = 'PO'
         AND t01.pkg_instr_type = 'Z001'
         AND t01.pkg_instr_table = '505'
         AND t01.sales_organisation IN ('147', '149')
         AND t01.item_ctgry IN ('I')
         /* only take instructions that are still valid */
         AND t01.pkg_instr_end_date >= sysdate
         AND ltrim(t01.sap_material_code,'0') = ltrim(rcd_bds_material_plant_mfanz.sap_material_code,'0');
      
      rcd_bds_material_pkg_instr_det csr_bds_material_pkg_instr_det%ROWTYPE;
  
  begin
  
  
  
  end execute_extract;
  
  procedure execute_send(par_interface in varchar2) is
  begin
  
  end execute_send;

END plant_material_extract;
/


