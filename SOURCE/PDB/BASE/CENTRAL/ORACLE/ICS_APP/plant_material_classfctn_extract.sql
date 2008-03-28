/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_material_classfctn_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Material Classification Data for Plant databases 

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all material classification data  
    *MATERIAL - send material classification data matching a given material code 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *MATERIAL = material code 

  3. PAR_SITE (OPTIONAL) 
  
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

create or replace package ics_app.plant_material_classfctn_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_material_classfctn_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_material_classfctn_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_material_code bds_bom_all.bom_material_code%type;
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_action    varchar2(10);
    var_data      varchar2(100);
    var_site      varchar2(10);
    var_start     boolean;
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*MATERIAL' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *MATERIAL');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI or NULL');
    end if;
    
    if ( var_action = '*MATERIAL' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *MATERIAL actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site = '*ALL' or '*MFA') then
        execute_send('LADPDB11.1');   
      end if;    
      if (par_site = '*ALL' or '*WGI') then
        execute_send('LADPDB11.2');   
      end if;    
      if (par_site = '*ALL' or '*WOD') then
        execute_send('LADPDB11.3');   
      end if;    
      if (par_site = '*ALL' or '*BTH') then
        execute_send('LADPDB11.4');   
      end if;    
      if (par_site = '*ALL' or '*MCA') then
        execute_send('LADPDB11.5');   
      end if;
      if (par_site = '*ALL' or '*SCO') then
        execute_send('LADPDB11.6');   
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
    raise_application_error(-20000, 'plant_material_classfctn_extract - ' || 'material_code: ' || var_material_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_material_classfctn is
      SELECT t01.sap_material_code as sap_material_code, 
        to_char(t01.bds_lads_date, 'yyyymmddhh24miss') as bds_lads_date, 
        t01.bds_lads_status as bds_lads_status, 
        t01.sap_idoc_name as sap_idoc_name,
        t01.sap_idoc_number as sap_idoc_number, 
        t01.sap_idoc_timestamp as sap_idoc_timestamp, 
        t01.sap_bus_sgmnt_code as sap_bus_sgmnt_code,
        t01.sap_mrkt_sgmnt_code as sap_mrkt_sgmnt_code, 
        t01.sap_brand_flag_code as sap_brand_flag_code, 
        t01.sap_funcl_vrty_code as sap_funcl_vrty_code,
        t01.sap_ingrdnt_vrty_code as sap_ingrdnt_vrty_code, 
        t01.sap_brand_sub_flag_code as sap_brand_sub_flag_code, 
        t01.sap_supply_sgmnt_code as sap_supply_sgmnt_code,
        t01.sap_trade_sector_code as sap_trade_sector_code, 
        t01.sap_occsn_code as sap_occsn_code, 
        t01.sap_mrkting_concpt_code as sap_mrkting_concpt_code,
        t01.sap_multi_pack_qty_code as sap_multi_pack_qty_code, 
        t01.sap_prdct_ctgry_code as sap_prdct_ctgry_code, 
        t01.sap_pack_type_code as sap_pack_type_code,
        t01.sap_size_code as sap_size_code, 
        t01.sap_size_grp_code as sap_size_grp_code, 
        t01.sap_prdct_type_code as sap_prdct_type_code,
        t01.sap_trad_unit_config_code as sap_trad_unit_config_code, 
        t01.sap_trad_unit_frmt_code as sap_trad_unit_frmt_code,
        t01.sap_dsply_storg_condtn_code as sap_dsply_storg_condtn_code, 
        t01.sap_onpack_cnsmr_value_code as sap_onpack_cnsmr_value_code,
        t01.sap_onpack_cnsmr_offer_code as sap_onpack_cnsmr_offer_code, 
        t01.sap_onpack_trade_offer_code as sap_onpack_trade_offer_code,
        t01.sap_brand_essnc_code as sap_brand_essnc_code, 
        t01.sap_cnsmr_pack_frmt_code as sap_cnsmr_pack_frmt_code, 
        t01.sap_cuisine_code as sap_cuisine_code,
        t01.sap_fpps_minor_pack_code as sap_fpps_minor_pack_code, 
        t01.sap_fighting_unit_code as sap_fighting_unit_code, 
        t01.sap_china_bdt_code as sap_china_bdt_code,
        t01.sap_mrkt_ctgry_code as sap_mrkt_ctgry_code, 
        t01.sap_mrkt_sub_ctgry_code as sap_mrkt_sub_ctgry_code,
        t01.sap_mrkt_sub_ctgry_grp_code as sap_mrkt_sub_ctgry_grp_code, 
        t01.sap_sop_bus_code as sap_sop_bus_code, 
        t01.sap_prodctn_line_code as sap_prodctn_line_code,
        t01.sap_planning_src_code as sap_planning_src_code, 
        t01.sap_sub_fighting_unit_code as sap_sub_fighting_unit_code, 
        t01.sap_raw_family_code as sap_raw_family_code,
        t01.sap_raw_sub_family_code as sap_raw_sub_family_code, 
        t01.sap_raw_group_code as sap_raw_group_code, 
        t01.sap_animal_parts_code as sap_animal_parts_code,
        t01.sap_physical_condtn_code as sap_physical_condtn_code, 
        t01.sap_pack_family_code as sap_pack_family_code,
        t01.sap_pack_sub_family_code as sap_pack_sub_family_code
      from bds.bds_material_classfctn t01
      where 
        (
          par_action = '*ALL'
          or (par_action = '*MATERIAL' and ltrim(t01.sap_material_code,'0') = ltrim(par_data,'0'))
        );
    rcd_bds_material_classfctn csr_bds_material_classfctn%rowtype;

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
    open csr_bds_material_classfctn;
    loop
    
      fetch csr_bds_material_classfctn into rcd_bds_material_classfctn;
      exit when csr_bds_material_classfctn%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
      
      /*-*/
      /* Store current customer code for error message purposes 
      /*-*/
      var_material_code := rcd_bds_material_classfctn.bom_material_code;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.bds_lads_date,' ')),14,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.bds_lads_status,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_idoc_name,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_idoc_number,' ')),38,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_idoc_timestamp,' ')),14,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_bus_sgmnt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_mrkt_sgmnt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_brand_flag_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_funcl_vrty_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_ingrdnt_vrty_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_brand_sub_flag_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_supply_sgmnt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_trade_sector_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_occsn_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_mrkting_concpt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_multi_pack_qty_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_prdct_ctgry_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_pack_type_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_size_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_size_grp_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_prdct_type_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_trad_unit_config_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_trad_unit_frmt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_dsply_storg_condtn_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_onpack_cnsmr_value_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_onpack_cnsmr_offer_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_onpack_trade_offer_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_brand_essnc_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_cnsmr_pack_frmt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_cuisine_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_fpps_minor_pack_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_fighting_unit_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_china_bdt_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_mrkt_ctgry_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_mrkt_sub_ctgry_grp_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_sop_bus_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_prodctn_line_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_planning_src_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_sub_fighting_unit_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_raw_family_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_raw_sub_family_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_raw_group_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_animal_parts_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_physical_condtn_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_pack_family_code,' ')),30,' ')
        || rpad(to_char(nvl(rcd_bds_material_classfctn.sap_pack_sub_family_code,' ')),30,' ');

    end loop;
    close csr_bds_material_classfctn;

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
        var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end plant_material_classfctn_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_material_classfctn_extract to appsupport;
grant execute on ics_app.plant_material_classfctn_extract to lads_app;
grant execute on ics_app.plant_material_classfctn_extract to lics_app;
grant execute on ics_app.plant_material_classfctn_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_material_classfctn_extract for ics_app.plant_material_classfctn_extract;
