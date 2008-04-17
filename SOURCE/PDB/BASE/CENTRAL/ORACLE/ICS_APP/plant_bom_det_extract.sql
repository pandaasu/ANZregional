/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_bom_det_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Bill of Material Detail Data for Plant databases 
  
  EXECUTE - 
    Send all BOM material data since last successful send 
    
  EXECUTE - 
    Send all BOM material data to the specified site(s)   
  
  1. PAR_SITE 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      
  EXECUTE - 
    Send the specified BOM material data to the specified site(s)
    
  1. PAR_ALTERNATIVE (MANDATORY) 
   
    Alternative BOM 
    
  2. PAR_MATERIAL_CODE (MANDATORY) 
  
    Material Code 
    
  3. PAR_PLANT (MANDATORY) 
  
    Plant Code 
    
  4. PAR_SITE 
  
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

create or replace package ics_app.plant_bom_det_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_site in varchar2);
  procedure execute(par_alternative in varchar2, par_material_code in varchar2, par_plant in varchar2, par_site in varchar2 default '*ALL');

end plant_bom_det_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_bom_det_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_alternative in varchar2, par_material_code in varchar2, par_plant in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
  
  var_material_code bds_bom_det.bom_material_code%type;
  var_alternative bds_bom_det.bom_alternative%type;
  var_plant bds_bom_det.bom_plant%type;
  
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
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB04');
  
    execute(null, null, null, '*MCA');
  end;  
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_site in varchar2) is
  begin
    execute(null, null, null, par_site);
  end;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_alternative in varchar2, par_material_code in varchar2, par_plant in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_site      varchar2(10);
    var_start     boolean := false;
         
  begin
  
    var_material_code := trim(par_material_code);
    var_alternative := trim(par_alternative);
    var_plant := trim(par_plant);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
       
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI or NULL');
    end if;
        
    var_start := execute_extract(var_alternative, var_material_code, var_plant);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB04.1');   
      end if;    
      if (par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB04.2');   
      end if;    
      if (par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB04.3');   
      end if;    
      if (par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB04.4');   
      end if;    
      if (par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB04.5');   
      end if;
      if (par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB04.6');   
      end if;
    end if; 
    
    if ( var_update_lastrun = true ) then
      lics_last_run_control.set_last_run('LADPDB04',var_start_date);
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
    raise_application_error(-20000, 'plant_bom_det_extract - material_code: ' || var_material_code || ' - alternative_bom: ' || var_alternative || ' - plant_code: ' || var_plant || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_alternative in varchar2, par_material_code in varchar2, par_plant in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_bom_det is
      select t01.bom_material_code as bom_material_code, 
        t01.bom_alternative as bom_alternative, 
        t01.bom_plant as bom_plant,
        t01.bom_number as bom_number, 
        t01.bom_msg_function as bom_msg_function, 
        t01.bom_usage as bom_usage,
        to_char(t01.bom_eff_from_date, 'yyyymmddhh24miss') as bom_eff_from_date,
        to_char(t01.bom_eff_to_date, 'yyyymmddhh24miss') as bom_eff_to_date,
        t01.bom_base_qty as bom_base_qty, 
        t01.bom_base_uom as bom_base_uom,
        t01.bom_status as bom_status, 
        t01.item_sequence as item_sequence, 
        t01.item_number as item_number,
        t01.item_msg_function as item_msg_function, 
        t01.item_material_code as item_material_code, 
        t01.item_category as item_category,
        t01.item_base_qty as item_base_qty, 
        t01.item_base_uom as item_base_uom, 
        to_char(t01.item_eff_from_date, 'yyyymmddhh24miss') as item_eff_from_date, 
        to_char(t01.item_eff_to_date, 'yyyymmddhh24miss') as item_eff_to_date
      from bds_bom_det t01,
        bds_bom_hdr t02
      where t01.bom_material_code = t02.bom_material_code
        and t01.bom_alternative = t02.bom_alternative
        and t01.bom_plant = t02.bom_plant
        and t01.bds_lads_status = '1'
        and (var_alternative is null or t01.bom_alternative = var_alternative)
        and (var_material_code is null or t01.bom_material_code = var_material_code)
        and (var_plant is null or t01.bom_plant = var_plant)
        and (var_lastrun_date is null or t02.bds_lads_date >= var_lastrun_date);
        
    rcd_bds_bom_det csr_bds_bom_det%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := false;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_bom_det;
    loop
    
      fetch csr_bds_bom_det into rcd_bds_bom_det;
      exit when csr_bds_bom_det%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current record details for error message purposes 
      /*-*/
      var_material_code := rcd_bds_bom_det.bom_material_code;
      var_alternative := rcd_bds_bom_det.bom_alternative;
      var_plant := rcd_bds_bom_det.bom_plant;
                    
      tbl_definition(var_index).value := 'HDR'
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_alternative,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_plant,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_number,' ')),8,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_msg_function,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_usage,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_eff_from_date,' ')),14,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_eff_to_date,' ')),14,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_base_qty,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_base_uom,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.bom_status,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_sequence,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_number,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_msg_function,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_category,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_base_qty,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_base_uom,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_eff_from_date,' ')),14,' ')
        || rpad(to_char(nvl(rcd_bds_bom_det.item_eff_to_date,' ')),14,' ');

    end loop;
    close csr_bds_bom_det;

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

end plant_bom_det_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_bom_det_extract to appsupport;
grant execute on ics_app.plant_bom_det_extract to lads_app;
grant execute on ics_app.plant_bom_det_extract to lics_app;
grant execute on ics_app.plant_bom_det_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_bom_det_extract for ics_app.plant_bom_det_extract;
