/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_reference_data_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Reference Data for Plant databases 

  1. PAR_Z_TABNAME (MANDATORY) 

    The table name updated. Determines which 

  2. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 

*******************************************************************************/

create or replace package ics_app.plant_reference_data_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_z_tabname in varchar2, par_site in varchar2 default '*ALL');

end plant_reference_data_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_reference_data_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_bom_extract() return boolean;
  function execute_prodctn_resrc_extract() return boolean;
  function execute_refrnc_charistic_extract() return boolean;
  function execute_refrnc_plant_extract() return boolean;
  function execute_refrnc_purchasing_src_extract() return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_z_tabname lads_ref_hdr.z_tabname%type;
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_z_tabname in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_site      varchar2(10);
    var_start     boolean;
         
  begin
  
    var_z_tabname := upper(nvl(trim(par_z_tabname). '*NULL'));
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    if ( var_z_tabname = '*NULL' ) then
      raise_application_error(-20000, 'Z_TABNAME parameter (' || par_z_tabname || ') must not be null.');
    end if;
       
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI or NULL');
    end if;

    case
      /*----------------------------------------------------*/
      /* Characteristic Reference Tables                    */
      /*----------------------------------------------------*/
      when (var_z_tabname = '/MARS/MD_CHC001' or
        var_z_tabname = '/MARS/MD_CHC002' or
        var_z_tabname = '/MARS/MD_CHC008' or
        var_z_tabname = '/MARS/MD_CHC010' or
        var_z_tabname = '/MARS/MD_CHC011' or
        var_z_tabname = '/MARS/MD_CHC012' or
        var_z_tabname = '/MARS/MD_CHC015' or
        var_z_tabname = '/MARS/MD_CHC017' or
        var_z_tabname = '/MARS/MD_CHC018' or
        var_z_tabname = '/MARS/MD_CHC019' or
        var_z_tabname = '/MARS/MD_CHC020' or
        var_z_tabname = '/MARS/MD_CHC022' or
        var_z_tabname = '/MARS/MD_CHC023' or
        var_z_tabname = '/MARS/MD_CHC024' or
        var_z_tabname = '/MARS/MD_CHC025' or
        var_z_tabname = '/MARS/MD_CHC026' or
        var_z_tabname = '/MARS/MD_CHC027' or
        var_z_tabname = '/MARS/MD_CHC028' or
        var_z_tabname = '/MARS/MD_CHC029' or
        var_z_tabname = '/MARS/MD_CHC030' or
        var_z_tabname = '/MARS/MD_CHC031' or
        var_z_tabname = '/MARS/MD_CHC032' or
        var_z_tabname = '/MARS/MD_CHC040' or
        var_z_tabname = '/MARS/MD_CHC042' or
        var_z_tabname = '/MARS/MD_CHC046' or
        var_z_tabname = '/MARS/MD_CHC047' or
        var_z_tabname = '/MARS/MD_CHC003' or
        var_z_tabname = '/MARS/MD_CHC004' or
        var_z_tabname = '/MARS/MD_CHC005' or
        var_z_tabname = '/MARS/MD_CHC007' or
        var_z_tabname = '/MARS/MD_CHC009' or
        var_z_tabname = '/MARS/MD_CHC013' or
        var_z_tabname = '/MARS/MD_CHC014' or
        var_z_tabname = '/MARS/MD_CHC016' or
        var_z_tabname = '/MARS/MD_CHC021' or
        var_z_tabname = '/MARS/MD_CHC038' or
        var_z_tabname = '/MARS/MD_CHC006' or
        var_z_tabname = '/MARS/MD_VERP01' or
        var_z_tabname = '/MARS/MD_VERP02' or
        var_z_tabname = '/MARS/MD_ROH01' or
        var_z_tabname = '/MARS/MD_ROH02' or
        var_z_tabname = '/MARS/MD_ROH03' or
        var_z_tabname = '/MARS/MD_ROH04' or
        var_z_tabname = '/MARS/MD_ROH05') then var_start := execute_refrnc_charistic_extract;
      /*----------------------------------------------------*/
      /* Plant Reference Tables                             */
      /*----------------------------------------------------*/
      when (var_z_tabname = 'T001W') then var_start := execute_refrnc_plant_extract;
      /*----------------------------------------------------*/
      /* BOM Alternate Versions Reference Tables            */
      /*----------------------------------------------------*/
      when (var_z_tabname = 'T415A') then var_start := execute_bom_extract;
      /*----------------------------------------------------*/
      /* Purchasing Source (Vendor/Material) Reference Table*/
      /*----------------------------------------------------*/
      when (var_z_tabname = 'EORD') then var_start := execute_refrnc_purchasing_src_extract;
      /*----------------------------------------------------*/
      /* Production Resources (Details/Descriptions)        */
      /*----------------------------------------------------*/
      when (var_z_tabname = 'CRTX' or var_z_tabname = 'CRHD') then var_start := execute_prodctn_resrc_extract;
      /*-*/
      else raise_application_error(-20000, 'Z_TABNAME parameter (' || var_z_tabname || ') is not known.');
    end case;
        
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site = '*ALL' or '*MFA') then
        execute_send('LADPDB04.1');   
      end if;    
      if (par_site = '*ALL' or '*WGI') then
        execute_send('LADPDB04.2');   
      end if;    
      if (par_site = '*ALL' or '*WOD') then
        execute_send('LADPDB04.3');   
      end if;    
      if (par_site = '*ALL' or '*BTH') then
        execute_send('LADPDB04.4');   
      end if;    
      if (par_site = '*ALL' or '*MCA') then
        execute_send('LADPDB04.5');   
      end if;
      if (par_site = '*ALL' or '*SCO') then
        execute_send('LADPDB04.6');   
      end if;
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
    raise_application_error(-20000, 'plant_reference_data_extract - material_code: ' || var_material_code || ' - alternative_bom: ' || var_alternative || ' - plant_code: ' || var_plant || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_bom_extract() return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_refrnc_bom_altrnt is
      select ltrim(t01.sap_material_code,'0') as bom_material_code,
        ltrim(t01.altrntv_bom,'0') as bom_alternative,
        t01.plant_code as bom_plant,
        to_char(t01.valid_from_date, 'yyyymmddhh24miss') as bom_eff_from_date
      from bds_refrnc_bom_altrnt_t415a t01;
        
    rcd_bds_refrnc_bom_altrnt csr_bds_refrnc_bom_altrnt%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := true;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_refrnc_bom_altrnt;
    loop
    
      fetch csr_bds_refrnc_bom_altrnt into rcd_bds_refrnc_bom_altrnt;
      exit when csr_bds_refrnc_bom_altrnt%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
              
      tbl_definition(var_index).value := 'BOM'
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_alternative,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_plant,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_eff_from_date,' ')),14,' ');

    end loop;
    close csr_bds_refrnc_bom_altrnt;

    return var_result;
    
  end execute_extract;

  function execute_prodctn_resrc_extract() return boolean is

    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_prodctn_resrc_en is
      select t01.resrc_id as resrc_id, 
        t01.resrc_code as resrc_code, 
        t01.resrc_text as resrc_text, 
        t01.resrc_plant_code as resrc_plant_code
      from bds_prodctn_resrc_en t01
      where t01.resrc_deletion_flag is null
        and substr(upper(resrc_text), 0, 6) <> 'DO NOT';
        
    rcd_prodctn_resrc_en csr_prodctn_resrc_en%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := true;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_prodctn_resrc_en;
    loop
    
      fetch csr_prodctn_resrc_en into rcd_prodctn_resrc_en;
      exit when csr_prodctn_resrc_en%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
              
      tbl_definition(var_index).value := 'PDR'
        || rpad(to_char(nvl(rcd_prodctn_resrc_en.resrc_id,' ')),8,' ')
        || rpad(to_char(nvl(rcd_prodctn_resrc_en.resrc_code,' ')),8,' ')
        || rpad(to_char(nvl(rcd_prodctn_resrc_en.resrc_text,' ')),40,' ')
        || rpad(to_char(nvl(rcd_prodctn_resrc_en.resrc_plant_code,' ')),4,' ');

    end loop;
    close csr_prodctn_resrc_en;

    return var_result;
  
  end execute_prodctn_resrc_extract;
  function execute_refrnc_charistic_extract() return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_refrnc_charistic is
      select t01.sap_charistic_code as sap_charistic_code, 
        t01.sap_charistic_value_code as sap_charistic_value_code,
        t01.sap_charistic_value_shrt_desc as sap_charistic_value_shrt_desc, 
        t01.sap_charistic_value_long_desc as sap_charistic_value_long_desc,
        t01.sap_idoc_number as sap_idoc_number, 
        t01.sap_idoc_timestamp as sap_idoc_timestamp, 
        t01.change_flag as change_flag
      from bds_refrnc_charistic t01
        
    rcd_refrnc_charistic csr_refrnc_charistic%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := true;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_refrnc_charistic;
    loop
    
      fetch csr_refrnc_charistic into rcd_refrnc_charistic;
      exit when csr_refrnc_charistic%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false; 
              
      tbl_definition(var_index).value := 'RCH'
        || rpad(to_char(nvl(rcd_refrnc_charistic.sap_charistic_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_refrnc_charistic.sap_charistic_value_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_refrnc_charistic.sap_charistic_value_shrt_desc,' ')),256,' ')
        || rpad(to_char(nvl(rcd_refrnc_charistic.sap_charistic_value_long_desc,' ')),256,' ')
        || rpad(to_char(nvl(rcd_refrnc_charistic.sap_idoc_number,' ')),38,' ')
        || rpad(to_char(nvl(rcd_refrnc_charistic.sap_idoc_timestamp,' ')),14,' ')
        || rpad(to_char(nvl(rcd_refrnc_charistic.change_flag,' ')),1,' ');

    end loop;
    close csr_refrnc_charistic;

    return var_result;
  
  end execute_refrnc_charistic_extract;
  function execute_refrnc_plant_extract() return boolean is

    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_refrnc_plant is
      select t01.plant_code as plant_code, 
        t01.sap_idoc_number as sap_idoc_number, 
        t01.sap_idoc_timestamp as sap_idoc_timestamp, 
        t01.change_flag as change_flag,
        t01.plant_name as plant_name, 
        t01.vltn_area as vltn_area, 
        t01.plant_customer_no as plant_customer_no, 
        t01.plant_vendor_no as plant_vendor_no,
        t01.factory_calendar_key as factory_calendar_key, 
        t01.plant_name_2 as plant_name_2, 
        t01.plant_street as plant_street, 
        t01.plant_po_box as plant_po_box,
        t01.plant_post_code as plant_post_code, 
        t01.plant_city as plant_city, 
        t01.plant_purchasing_organisation as plant_purchasing_organisation,
        t01.plant_sales_organisation as plant_sales_organisation, 
        t01.batch_manage_indctr as batch_manage_indctr, 
        t01.plant_condition_indctr as plant_condition_indctr,
        t01.source_list_indctr as source_list_indctr, 
        t01.activate_reqrmnt_indctr as activate_reqrmnt_indctr, 
        t01.plant_country_key as plant_country_key,
        t01.plant_region as plant_region, 
        t01.plant_country_code as plant_country_code, 
        t01.plant_city_code as plant_city_code, 
        t01.plant_address as plant_address,
        t01.maint_planning_plant as maint_planning_plant, 
        t01.tax_jurisdiction_code as tax_jurisdiction_code,
        t01.dstrbtn_channel as dstrbtn_channel, 
        t01.division as division,
        t01.language_key as language_key, 
        t01.sop_plant as sop_plant, 
        t01.variance_key as variance_key, 
        t01.batch_manage_old_indctr as batch_manage_old_indctr,
        t01.plant_ctgry as plant_ctgry, 
        t01.plant_sales_district as plant_sales_district, 
        t01.plant_supply_region as plant_supply_region,
        t01.plant_tax_indctr as plant_tax_indctr, 
        t01.regular_vendor_indctr as regular_vendor_indctr, 
        t01.first_reminder_days as first_reminder_days,
        t01.second_reminder_days as second_reminder_days,  
        t01.third_reminder_days as third_reminder_days, 
        t01.vendor_declaration_text_1 as vendor_declaration_text_1,
        t01.vendor_declaration_text_2 as vendor_declaration_text_2, 
        t01.vendor_declaration_text_3 as vendor_declaration_text_3,
        t01.po_tolerance_days as po_tolerance_days, 
        t01.plant_business_place as plant_business_place, 
        t01.stock_xfer_rule as stock_xfer_rule,
        t01.plant_dstrbtn_profile as plant_dstrbtn_profile, 
        t01.central_archive_marker as central_archive_marker, 
        t01.dms_type_indctr as dms_type_indctr,
        t01.node_type as node_type, 
        t01.name_formation_structure as name_formation_structure, 
        t01.cost_control_active_indctr as cost_control_active_indctr,
        t01.mixed_costing_active_indctr as mixed_costing_active_indctr, 
        t01.actual_costing_active_indctr as actual_costing_active_indctr,
        t01.transport_point as transport_point
      from bds_refrnc_plant t01
      where t01.plant_code like 'AU%' 
        or t01.plant_code like 'NZ%';
        
    rcd_refrnc_plant csr_refrnc_plant%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := true;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_refrnc_plant;
    loop
    
      fetch csr_refrnc_plant into rcd_refrnc_plant;
      exit when csr_refrnc_plant%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;    
              
      tbl_definition(var_index).value := 'RPL'
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.sap_idoc_number,' ')),38,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.sap_idoc_timestamp,' ')),14,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.change_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_name,' ')),30,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.vltn_area,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_customer_no,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_vendor_no,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.factory_calendar_key,' ')),2,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_name_2,' ')),30,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_street,' ')),30,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_po_box,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_post_code,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_city,' ')),25,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_purchasing_organisation,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_sales_organisation,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.batch_manage_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_condition_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.source_list_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.activate_reqrmnt_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_country_key,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_region,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_country_code,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_city_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_address,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.maint_planning_plant,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.tax_jurisdiction_code,' ')),15,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.dstrbtn_channel,' ')),2,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.division,' ')),2,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.language_key,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.sop_plant,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.variance_key,' ')),6,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.batch_manage_old_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_ctgry,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_sales_district,' ')),6,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_supply_region,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_tax_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.regular_vendor_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.first_reminder_days,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.second_reminder_days,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.third_reminder_days,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.vendor_declaration_text_1,' ')),16,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.vendor_declaration_text_2,' ')),16,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.vendor_declaration_text_3,' ')),16,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.po_tolerance_days,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_business_place,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.stock_xfer_rule,' ')),2,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.plant_dstrbtn_profile,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.central_archive_marker,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.dms_type_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.node_type,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.name_formation_structure,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.cost_control_active_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.mixed_costing_active_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.actual_costing_active_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_plant.transport_point,' ')),4,' ');

    end loop;
    close csr_refrnc_plant;

    return var_result;
  
  end execute_refrnc_plant_extract;
  function execute_refrnc_purchasing_src_extract() return boolean is

    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_refrnc_purchasing_src is
      select t01.sap_material_code as sap_material_code, 
        t01.plant_code as plant_code, 
        t01.record_no as record_no, 
        to_char(t01.creatn_date, 'yyyymmddhh24miss') as creatn_date, 
        t01.creatn_user as creatn_user,
        to_char(t01.src_list_valid_from, 'yyyymmddhh24miss') as src_list_valid_from, 
        to_char(t01.src_list_valid_to, 'yyyymmddhh24miss') as src_list_valid_to, 
        t01.vendor_code as vendor_code,
        t01.fixed_vendor_indctr as fixed_vendor_indctr, 
        t01.agreement_no as agreement_no, 
        t01.agreement_item as agreement_item,
        t01.fixed_purchase_agreement_item as fixed_purchase_agreement_item, 
        t01.plant_procured_from as plant_procured_from,
        t01.sto_fixed_issuing_plant as sto_fixed_issuing_plant, 
        t01.manufctr_part_refrnc_material as manufctr_part_refrnc_material,
        t01.blocked_supply_src_flag as blocked_supply_src_flag, 
        t01.purchasing_organisation as purchasing_organisation,
        t01.purchasing_document_ctgry as purchasing_document_ctgry,
        t01.src_list_ctgry as src_list_ctgry, 
        t01.src_list_planning_usage as src_list_planning_usage,
        t01.order_unit as order_unit, 
        t01.logical_system as logical_system, 
        t01.special_stock_indctr as special_stock_indctr
      from bds_refrnc_purchasing_src t01
        
    rcd_refrnc_purchasing_src csr_refrnc_plant%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := true;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_refrnc_purchasing_src;
    loop
    
      fetch csr_refrnc_purchasing_src into rcd_refrnc_purchasing_src;
      exit when csr_refrnc_purchasing_src%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
              
      tbl_definition(var_index).value := 'RPR'
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.sap_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.plant_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.record_no,' ')),5,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.creatn_date,' ')),14,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.creatn_user,' ')),12,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.src_list_valid_from,' ')),14,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.src_list_valid_to,' ')),14,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.vendor_code,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.fixed_vendor_indctr,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.agreement_no,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.agreement_item,' ')),5,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.fixed_purchase_agreement_item,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.plant_procured_from,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.sto_fixed_issuing_plant,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.manufctr_part_refrnc_material,' ')),18,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.blocked_supply_src_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.purchasing_organisation,' ')),4,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.purchasing_document_ctgry,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.src_list_ctgry,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.src_list_planning_usage,' ')),1,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.order_unit,' ')),3,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.logical_system,' ')),10,' ')
        || rpad(to_char(nvl(rcd_refrnc_purchasing_src.special_stock_indctr,' ')),1,' ');

    end loop;
    close csr_refrnc_purchasing_src;

    return var_result;
  
  end execute_refrnc_purchasing_src_extract;
  
  procedure execute_send(par_interface in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
        var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end plant_reference_data_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_reference_data_extract to appsupport;
grant execute on ics_app.plant_reference_data_extract to lads_app;
grant execute on ics_app.plant_reference_data_extract to lics_app;
grant execute on ics_app.plant_reference_data_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_reference_data_extract for ics_app.plant_reference_data_extract;
