--
-- ICS_LADPDB02_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ICS_LADPDB02_EXTRACT as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB02_EXTRACT 
  Owner   : ics_app 

  Description 
  ----------- 
  Material Data for Plant databases 

  EXECUTE - 
    Send Material data since last successful send 
    
  EXECUTE - 
    Send Material data based on the specified action.     

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
      - *PCH = Pak Chong Thailand
      - *MCH = China
      
  YYYY/MM    Author       Description 
  -------    ------       ----------- 
  2007/11   J. Phillipson Created 
  2007/11   J. Phillipson Added ability to send 1 matl code 
  2007/12   J. Phillipson Changed criteria to accept numerical value in minutes 
  2008/02   J. Phillipson Changed criteria to just material so it can be 
                            trigged by changes only to LADS table 
  2008/03   J. Phillipson Added sending of Packaging instruction data 
  2008/03   T. Keon       Changed structure to match new standards   
  2008/04   T. Keon       Added option to extract data since last run only 
  2008/09   T. Keon       Changed criteria to broadcast deletes
  2010/06   B. Halicki    Modified for Pak Chong Thailand Implementation
  2010/10   B. Halicki    Removed hard-coded plant codes, moved to configuration via
                            Data Store Configuration
  2011/01   B. Halicki    Added order by to material extract query to resolve issue
                            whereby separate control record would be generated for 
                            each material/plant, resulting in plant db inbound loader
                            to remove all material/plants and only add latest entry.
  2011/06   B. Halicki    Added regional code, sales text and language descriptions for China Plant DB
  2011/07   B. Halicki    Modified interface to append sequences to outbound filename
  
*******************************************************************************/ 

  /*-*/
  /* Public declarations 
  /* par_material either null or a material code 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ICS_LADPDB02_EXTRACT;
/


--
-- ICS_LADPDB02_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ICS_LADPDB02_EXTRACT
as
/******************************************************************************
   NAME: ICS_LADPDB02_EXTRACT 
*****************************************************************************/

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
      
  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
  var_material_code bds_material_hdr.sap_material_code%type := NULL;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB02';
      
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute is
  begin
    /*-*/
    /* Set global variables  
    /*-*/    
    var_start_date := sysdate;
    var_update_lastrun := true;
    
    /*-*/
    /* Get last run date  
    /*-*/    
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB02');
  
    execute('*ALL',null,'*ALL');
  end; 

  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL') is

    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_action    varchar2(10);
    var_data      varchar2(100);
    var_site      varchar2(10);
    var_start     boolean := false;
    var_intfc     varchar2(20);

    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_intfc is
        select 
            dsv_group as site, 
            dsv_value as intfc_extn 
        from 
            table (lics_datastore.retrieve_group('PDB','INTFC_EXTN',NULL)) t01
        where 
            (var_site = '*ALL' or '*' || t01.dsv_group = var_site);
    
    rcd_intfc csr_intfc%rowtype;        
             
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*MATERIAL'
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *MATERIAL or *HISTORY');
    end if;
    
    if ( var_action = '*MATERIAL' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *MATERIAL actions.');
    elsif ( var_action = '*HISTORY' and (var_data is null or to_number(var_data) <= 0) ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null and must be greater than 1 for *HISTORY actions.');
    end if;

    open csr_intfc;
    loop
        fetch csr_intfc into rcd_intfc;
        exit when csr_intfc%notfound;
       
        tbl_definition.delete;
        
        var_intfc := con_intfc || rcd_intfc.intfc_extn; 
        
        /*-*/
        /* Get last run date  
        /*-*/    
        if ( var_update_lastrun = true ) then
            var_lastrun_date := lics_last_run_control.get_last_run(var_intfc);
        end if;
        
        var_start_date := sysdate;
        var_start := execute_extract(var_action, var_data, rcd_intfc.site);      

        /*-*/
        /* ensure data was returned in the cursor before creating interfaces 
        /* to send to the specified site(s) 
        /*-*/           
        if ( var_start = true ) then
            execute_send(var_intfc);
        end if;
        
        if ( var_update_lastrun = true ) then
            lics_last_run_control.set_last_run(var_intfc,var_start_date);
        end if;  
        
    end loop;

    /*-*/
    /* if no valid sites were found, raise exception
    /*-*/
    if (csr_intfc%rowcount=0 and var_site='*ALL') then
        raise_application_error(-20000, 'No valid plant databases have been configured via Data Store Configuration.');
    end if;
    
    if (csr_intfc%rowcount=0 and var_site!='*ALL') then
        raise_application_error(-20000, 'Site parameter (' || par_site || ') has not been configured via Data Store Configuration.');
    end if;

    close csr_intfc;

    commit;

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
    var_exception := substr(sqlerrm, 1, 1024);

    /*-*/
    /* Finalise the outbound loader when required 
    /*-*/
    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.add_exception(var_exception);
      lics_outbound_loader.finalise_interface;
    end if;

    /*-*/
    /* Raise an exception to the calling application 
    /*-*/
    raise_application_error(-20000, 'ics_ladpdb02_extract - ' || 'sap_material_code: ' || var_material_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
   
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index     number(8,0);        
    var_result    boolean;
    var_skip_pkg  boolean; 
  
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_material_plant_local is
      select t01.sap_material_code as sap_material_code,
        t02.plant_code as plant_code,
        t01.bds_material_desc_en as bds_material_desc_en,
        t01.bds_material_desc_th as bds_material_desc_th,
        t01.bds_material_desc_zh as bds_material_desc_zh,
        t01.material_type as material_type,
        t01.material_grp as material_grp,
        t01.base_uom as base_uom,
        t01.order_unit as order_unit,
        t01.gross_weight as gross_weight,
        t01.net_weight as net_weight,
        t01.gross_weight_unit as gross_weight_unit,
        t01.length as length,
        t01.width as width,
        t01.height as height,
        t01.deletion_flag as deletion_flag,
        t01.dimension_uom as dimension_uom,
        t01.interntl_article_no as interntl_article_no,
        t01.total_shelf_life as total_shelf_life,
        t01.prd_shelf_life_indctr as prd_shelf_life_indctr,
        t01.mars_plan_item_flag as mars_plan_item_flag,
        t01.mars_intrmdt_prdct_compnt_flag as mars_intrmdt_prdct_compnt_flag,
        t01.mars_merchandising_unit_flag as mars_merchandising_unit_flag,
        t01.mars_prmotional_material_flag as mars_prmotional_material_flag,
        t01.mars_retail_sales_unit_flag as mars_retail_sales_unit_flag,
        t01.mars_shpping_contnr_flag as mars_shpping_contnr_flag,
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
        t03.sales_text_135 as sales_text_135,
        t03.sales_text_147 as sales_text_147,
        t03.sales_text_149 as sales_text_149,
        t03.sales_text_163 as sales_text_163,
        t03.sales_text_164 as sales_text_164,
        t03.sales_text_234 as sales_text_234,
        t04.regional_code_8 as regional_code_8,
        t04.regional_code_10 as regional_code_10,
        t04.regional_code_14 as regional_code_14,
        t04.regional_code_17 as regional_code_17,
        t04.regional_code_18 as regional_code_18,
        t04.regional_code_19 as regional_code_19,
        t04.regional_code_20 as regional_code_20,
        t05.stndrd_price / t05.price_unit as price_unit,
        t05.future_planned_price_1 as future_planned_price_1,
        t05.vltn_class as vltn_class,
        t05.deletion_indctr as vltn_deletion_indctr,
        decode(t06.bds_pce_factor_from_base_uom,null,1,t06.bds_pce_factor_from_base_uom) as bds_pce_factor_from_base_uom,
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
        t02.planned_delivery_days as planned_delivery_days,
        t02.deletion_indctr as plant_deletion_indctr
      from bds_material_hdr t01,
        bds_material_plant_hdr t02,
        (
          select t01.sap_material_code,
            max(case when t01.sales_organisation = '135' then text end) as sales_text_135,
            max(case when t01.sales_organisation = '147' then text end) as sales_text_147,
            max(case when t01.sales_organisation = '149' then text end) as sales_text_149,
            max(case when t01.sales_organisation = '163' then text end) as sales_text_163,
            max(case when t01.sales_organisation = '164' then text end) as sales_text_164,
            max(case when t01.sales_organisation = '234' then text end) as sales_text_234
          from bds_material_text_en t01
          where t01.sales_organisation in ('135','147','149','163','164','234')
            and t01.dstrbtn_channel = '99'
          group by t01.sap_material_code
        ) t03,
        (
          select sap_material_code,
            max(case when regional_code_id = '8' then regional_code end) as regional_code_8,
            max(case when regional_code_id = '10' then regional_code end) as regional_code_10,
            max(case when regional_code_id = '14' then regional_code end) as regional_code_14,
            max(case when regional_code_id = '17' then regional_code end) as regional_code_17,
            max(case when regional_code_id = '18' then regional_code end) as regional_code_18,
            max(case when regional_code_id = '19' then regional_code end) as regional_code_19,
            max(case when regional_code_id = '20' then regional_code end) as regional_code_20
          from bds_material_regional
          where regional_code_id in ('10', '14', '17', '18', '19', '20')
          group by sap_material_code
        ) t04,
        bds_material_vltn t05,
        (
          select sap_material_code,
            max(case when uom_code = 'PCE' then bds_factor_from_base_uom end) as bds_pce_factor_from_base_uom,
            max(case when uom_code = 'PCE' then mars_pc_item_code end) as mars_pce_item_code,
            max(case when uom_code = 'PCE' then interntl_article_no end) as mars_pce_interntl_article_no,
            max(case when uom_code = 'SB' then bds_factor_from_base_uom end) as bds_sb_factor_from_base_uom,
            max(case when uom_code = 'SB' then mars_pc_item_code end) as mars_sb_item_code
          from bds_material_uom
          where uom_code in ('PCE','SB')
          group by sap_material_code
        ) t06
      where t01.sap_material_code = t02.sap_material_code
        and t01.mars_rprsnttv_item_code = t03.sap_material_code(+)
        and t01.sap_material_code = t04.sap_material_code(+)
        and t02.sap_material_code = t05.sap_material_code(+)
        and t02.plant_code = t05.vltn_area(+)
        and t01.sap_material_code = t06.sap_material_code(+)
        and t01.material_type in ('ROH', 'VERP', 'NLAG', 'PIPE', 'FERT') -- all interested materials 
        and t02.plant_code in 
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS'))
        )
        and t05.vltn_type(+) = '*NONE'
        and 
        (
          (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
          or (par_action = '*MATERIAL' and ltrim(t01.sap_material_code,'0') = ltrim(par_data,'0'))
          or (par_action = '*HISTORY' and t01.bds_lads_date >= trunc(sysdate - to_number(par_data)))
        )
        order by t01.sap_material_code;  
                  
    rcd_bds_material_plant_local csr_bds_material_plant_local%rowtype;       
          
    cursor csr_bds_material_pkg_instr_det is
      select t01.sap_material_code as sap_material_code,
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
      from bds_material_pkg_instr_det t01
      where t01.pkg_instr_table_usage = 'P'
        and t01.pkg_instr_application = 'PO'
        and t01.pkg_instr_type = 'Z001'
        and t01.pkg_instr_table = '505'
        and t01.sales_organisation in
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_SALES_ORGS'))
        )        
        and t01.item_ctgry IN ('I')
        /* only take instructions that are still valid */
        and t01.pkg_instr_end_date >= sysdate
        and t01.sap_material_code = rcd_bds_material_plant_local.sap_material_code;       
         
    rcd_bds_material_pkg_instr_det csr_bds_material_pkg_instr_det%rowtype;   
    
    cursor csr_bds_material_uom is
      select t01.sap_material_code as sap_material_code,
        t01.uom_code as uom_code,
        t01.sap_function as sap_function,
        t01.base_uom_numerator as base_uom_numerator,
        t01.base_uom_denominator as base_uom_denominator,
        t01.bds_factor_to_base_uom as bds_factor_to_base_uom,
        t01.bds_factor_from_base_uom as bds_factor_from_base_uom,
        t01.interntl_article_no as interntl_article_no,
        t01.interntl_article_no_ctgry as interntl_article_no_ctgry,
        t01.length as length,
        t01.width as width,
        t01.height as height,
        t01.dimension_uom as dimension_uom,
        t01.volume as volume,
        t01.volume_unit as volume_unit,
        t01.gross_weight as gross_weight,
        t01.gross_weight_unit as gross_weight_unit,
        t01.lower_level_hierachy_uom as lower_level_hierachy_uom,
        t01.global_trade_item_variant as global_trade_item_variant,
        t01.mars_mutli_convrsn_uom_indctr as mars_mutli_convrsn_uom_indctr,
        t01.mars_pc_item_code as mars_pc_item_code,
        t01.mars_pc_level as mars_pc_level,
        t01.mars_order_uom_prfrnc_indctr as mars_order_uom_prfrnc_indctr,
        t01.mars_sales_uom_prfrnc_indctr as mars_sales_uom_prfrnc_indctr,
        t01.mars_issue_uom_prfrnc_indctr as mars_issue_uom_prfrnc_indctr,
        t01.mars_wm_uom_prfrnc_indctr as mars_wm_uom_prfrnc_indctr,
        t01.mars_rprsnttv_material_code as mars_rprsnttv_material_code
      from bds_material_uom t01
      where t01.sap_material_code = rcd_bds_material_plant_local.sap_material_code;
    
    rcd_bds_material_uom csr_bds_material_uom%rowtype;
  
  begin
  
    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := false;
    var_skip_pkg := false;
    var_material_code := null;
   
    open csr_bds_material_plant_local;
    loop
    
      fetch csr_bds_material_plant_local into rcd_bds_material_plant_local;
      exit when csr_bds_material_plant_local%notfound;
           
      var_index := tbl_definition.count + 1;
      var_result := true;
 
      if ( var_material_code is null or var_material_code <> rcd_bds_material_plant_local.sap_material_code) then
              
        var_material_code := rcd_bds_material_plant_local.sap_material_code;
        
        tbl_definition(var_index).value := 'CTL'
          || rpad(nvl(to_char(rcd_bds_material_plant_local.sap_material_code),' '),18,' ')
          || rpad(to_char(sysdate, 'yyyymmddhh24miss'),14,' ');
        
        var_index := tbl_definition.count + 1;
        var_skip_pkg := false;
      else
        /*-*/
        /* Skip the package load as it was done in the previous loop 
        /*-*/
        var_skip_pkg := true;
      end if;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_material_plant_local.plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.bds_material_desc_en),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.bds_material_desc_th),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.bds_material_desc_zh),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.material_type),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.material_grp),' '),9,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.base_uom),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.order_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.gross_weight),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.net_weight),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.gross_weight_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.length),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.width),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.height),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.deletion_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.dimension_uom),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.interntl_article_no),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.total_shelf_life),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.prd_shelf_life_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_plan_item_flag),' '),6,' ')        
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_intrmdt_prdct_compnt_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_merchandising_unit_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_prmotional_material_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_retail_sales_unit_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_shpping_contnr_flag),' '),1,' ')        
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_semi_finished_prdct_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_rprsnttv_item_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_traded_unit_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.xplant_status),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.xplant_status_valid),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.batch_mngmnt_reqrmnt_indctr),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_plant_material_type),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.procurement_type),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.special_procurement_type),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.issue_storage_location),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mrp_controller),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.plant_specific_status_valid),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.deletion_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.plant_specific_status),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.assembly_scrap_percntg),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.component_scrap_percntg),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.backflush_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_rprsnttv_item_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_8),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_10),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_14),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_17),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_18),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_19),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.regional_code_20),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.price_unit),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.future_planned_price_1),' '),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.vltn_class),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.vltn_deletion_indctr),' '),1,' ')        
        || rpad(nvl(to_char(rcd_bds_material_plant_local.bds_pce_factor_from_base_uom),'0'),42,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_pce_item_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_pce_interntl_article_no),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.bds_sb_factor_from_base_uom),' '),42,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mars_sb_item_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.effective_out_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.discontinuation_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.followup_material),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.material_division),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.mrp_type),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.max_storage_prd),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.max_storage_prd_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.issue_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.planned_delivery_days),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_plant_local.plant_deletion_indctr),' '),1,' ');         
      
      -- include the sales text in a seperate child record if it contains data 
      if ( rcd_bds_material_plant_local.sales_text_135 is not null
          and length(trim(rcd_bds_material_plant_local.sales_text_135)) > 0 ) then        
        var_index := tbl_definition.count + 1;
        tbl_definition(var_index).value := 'STX135' || rpad(to_char(rcd_bds_material_plant_local.sales_text_135), 2000, ' ');      
      end if;

      if ( rcd_bds_material_plant_local.sales_text_147 is not null
          and length(trim(rcd_bds_material_plant_local.sales_text_147)) > 0 ) then        
        var_index := tbl_definition.count + 1;
        tbl_definition(var_index).value := 'STX147' || rpad(to_char(rcd_bds_material_plant_local.sales_text_147), 2000, ' ');      
      end if;
      
      if ( rcd_bds_material_plant_local.sales_text_149 is not null
          and length(trim(rcd_bds_material_plant_local.sales_text_149)) > 0 ) then        
        var_index := tbl_definition.count + 1;
        tbl_definition(var_index).value := 'STX149' || rpad(to_char(rcd_bds_material_plant_local.sales_text_149), 2000, ' ');      
      end if;          
      
      if ( rcd_bds_material_plant_local.sales_text_163 is not null
          and length(trim(rcd_bds_material_plant_local.sales_text_163)) > 0 ) then        
        var_index := tbl_definition.count + 1;
        tbl_definition(var_index).value := 'STX163' || rpad(to_char(rcd_bds_material_plant_local.sales_text_163), 2000, ' ');      
      end if;          
      
      if ( rcd_bds_material_plant_local.sales_text_164 is not null
          and length(trim(rcd_bds_material_plant_local.sales_text_164)) > 0 ) then        
        var_index := tbl_definition.count + 1;
        tbl_definition(var_index).value := 'STX164' || rpad(to_char(rcd_bds_material_plant_local.sales_text_164), 2000, ' ');      
      end if;          

      if ( rcd_bds_material_plant_local.sales_text_234 is not null
          and length(trim(rcd_bds_material_plant_local.sales_text_234)) > 0 ) then        
        var_index := tbl_definition.count + 1;
        tbl_definition(var_index).value := 'STX234' || rpad(to_char(rcd_bds_material_plant_local.sales_text_234), 2000, ' ');      
      end if;
            
      if ( var_skip_pkg = false ) then                         
        open csr_bds_material_pkg_instr_det;
        loop
          fetch csr_bds_material_pkg_instr_det into rcd_bds_material_pkg_instr_det;
          exit when csr_bds_material_pkg_instr_det%notfound;
                               
          var_index := tbl_definition.count + 1;
                                 
          tbl_definition(var_index).value := 'PKG'
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.pkg_instr_table_usage),' '),1,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.pkg_instr_table),' '),64,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.pkg_instr_type),' '),4,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.pkg_instr_application),' '),2,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.item_ctgry),' '),2,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.sales_organisation),' '),4,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.component),' '), 20,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.pkg_instr_start_date),' '),14,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.pkg_instr_end_date),' '),14,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.variable_key),' '),100,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.height),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.width),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.length),'0'),38,' ')                 
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.hu_total_weight),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.hu_total_volume),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.dimension_uom),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.weight_unit),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.volume_unit),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.target_qty),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.rounding_qty),'0'),38,' ') 
            || rpad(nvl(to_char(rcd_bds_material_pkg_instr_det.uom),' '),3,' ');
            
        end loop;
        close csr_bds_material_pkg_instr_det;
        
        open csr_bds_material_uom;
        loop
          fetch csr_bds_material_uom into rcd_bds_material_uom;
          exit when csr_bds_material_uom%notfound;
                               
          var_index := tbl_definition.count + 1;
                                 
          tbl_definition(var_index).value := 'UOM'
            || rpad(nvl(to_char(rcd_bds_material_uom.uom_code),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.sap_function),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.base_uom_numerator),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.base_uom_denominator),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.bds_factor_to_base_uom),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.bds_factor_from_base_uom),'0'),42,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.interntl_article_no),' '),18,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.interntl_article_no_ctgry),' '),2,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.length),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.width),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.height),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.dimension_uom),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.volume),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.volume_unit),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.gross_weight),'0'),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.gross_weight_unit),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.lower_level_hierachy_uom),' '),3,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.global_trade_item_variant),' '),2,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_mutli_convrsn_uom_indctr),' '),1,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_pc_item_code),' '),18,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_pc_level),' '),38,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_order_uom_prfrnc_indctr),' '),1,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_sales_uom_prfrnc_indctr),' '),1,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_issue_uom_prfrnc_indctr),' '),1,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_wm_uom_prfrnc_indctr),' '),1,' ')
            || rpad(nvl(to_char(rcd_bds_material_uom.mars_rprsnttv_material_code),' '),18,' ');
            
        end loop;
        close csr_bds_material_uom;
                          
      end if;
           
    end loop;
    close csr_bds_material_plant_local;
    
    commit;
    
    return var_result;
    
  end execute_extract;
  
  procedure execute_send(par_interface in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
          var_instance := lics_outbound_loader.create_interface(par_interface);
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end ICS_LADPDB02_EXTRACT;
/


--
-- ICS_LADPDB02_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB02_EXTRACT FOR ICS_APP.ICS_LADPDB02_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB02_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB02_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB02_EXTRACT TO LICS_APP;

