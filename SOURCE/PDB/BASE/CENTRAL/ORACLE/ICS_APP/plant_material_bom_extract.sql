create or replace package ics_app.plant_material_bom_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_material_bom_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Material BOM Data for Plant databases 
  
  EXECUTE - 
    Send Material BOM data since last successful send 
    
  EXECUTE - 
    Send Material BOM data based on the specified action.   

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all material BOM data  
    *BOM - send material BOM data matching a given BOM and alternate BOM  
    *HISTORY - send material BOM data updated since a specific point in the past 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *BOM = bom code 
      - *HISTORY = number of days 
      
  3. PAR_ALT_DATA (ACTION DEPENDANT) 
  
    Data related to the action specified.
      - *ALL = null 
      - *BOM = bom alternate code (REQUIRED) 
      - *HISTORY = null 

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
  2008/04   Trevor Keon    Created 

*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_alt_data in varchar2, par_site in varchar2);

end plant_material_bom_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_material_bom_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2, par_alt_data in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
    
  var_bom bds_material_bom_hdr.sap_bom%type;
  var_alt_bom bds_material_bom_hdr.sap_bom_alternative%type;
  
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
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB13');
  
    execute('*ALL',null,null,'*ALL');
  end; 

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_action in varchar2, par_data in varchar2, par_alt_data in varchar2, par_site in varchar2) is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_action    varchar2(10);
    var_data      varchar2(100);
    var_alt_data      varchar2(100);
    var_site      varchar2(10);
    var_start     boolean := false;
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_alt_data := trim(par_alt_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*BOM' 
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *CUSTOMER or *HISTORY');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *BTH, *WGI or NULL');
    end if;
    
    if ( var_action = '*BOM' and (var_data is null or var_alt_data is null) ) then
      raise_application_error(-20000, 'Data parameters (' || par_data || ',' || par_alt_data || ') must not be null for *BOM actions.');
    elsif ( var_action = '*HISTORY' and (var_data is null or to_number(var_data) <= 0) ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null and must be greater than 1 for *HISTORY actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data, var_alt_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if ( par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB13.1'); 
      end if;    
      if ( par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB13.2');
      end if;    
      if ( par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB13.3');
      end if;    
      if ( par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB13.4');
      end if;    
      if ( par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB13.5');   
      end if;
      if ( par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB13.6');   
      end if;
    end if; 

    if ( var_update_lastrun = true ) then
      lics_last_run_control.set_last_run('LADPDB13',var_start_date);
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
    raise_application_error(-20000, 'plant_material_bom_extract - ' || 'bom: ' || var_bom || ' - ' || 'alt bom: ' || var_alt_bom || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_action in varchar2, par_data in varchar2, par_alt_data in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_material_bom_hdr is
      select t01.sap_bom as sap_bom,
        t01.sap_bom_alternative as sap_bom_alternative,
        t01.bom_plant as bom_plant,
        t01.bom_usage as bom_usage,
        to_char(t01.bom_eff_date,'yyyymmdd') as bom_eff_date,
        t01.bom_status as bom_status,
        t01.parent_material_code as parent_material_code,
        t01.parent_base_qty as parent_base_qty,
        t01.parent_base_uom as parent_base_uom
      from bds_material_bom_hdr t01
      where t01.bds_lads_status = '1'
        and  
        (
          (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
          or (par_action = '*BOM' and t01.sap_bom = par_data and t01.sap_bom_alternative = par_alt_data)          
          or (par_action = '*HISTORY' and t01.bds_lads_date >= trunc(sysdate - to_number(par_data)))
        );
    rcd_bds_material_bom_hdr csr_bds_material_bom_hdr%rowtype;
    
    cursor csr_bds_material_bom_det is
      select t01.sap_bom as sap_bom,
        t01.sap_bom_alternative as sap_bom_alternative,
        t01.child_material_code as child_material_code,
        t01.child_item_category as child_item_category,
        t01.child_base_qty as child_base_qty,
        t01.child_base_uom as child_base_uom
      from bds_material_bom_det t01
      where t01.sap_bom = rcd_bds_material_bom_hdr.sap_bom
        and t01.sap_bom_alternative = rcd_bds_material_bom_hdr.sap_bom_alternative;
    rcd_bds_material_bom_det csr_bds_material_bom_det%rowtype;    

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
    open csr_bds_material_bom_hdr;
    loop
    
      fetch csr_bds_material_bom_hdr into rcd_bds_material_bom_hdr;
      exit when csr_bds_material_bom_hdr%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current codes for error message purposes 
      /*-*/
      var_bom := rcd_bds_material_bom_hdr.sap_bom;
      var_alt_bom := rcd_bds_material_bom_hdr.sap_bom_alternative;
      
      tbl_definition(var_index).value := 'CTL'
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.sap_bom),' '),8,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.sap_bom_alternative),' '),2,' ')
        || rpad(to_char(sysdate, 'yyyymmddhh24miss'),14,' ');
        
      var_index := tbl_definition.count + 1;
              
      tbl_definition(var_index).value := 'HDR' 
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.bom_plant),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.bom_usage),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.bom_eff_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.bom_status),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.parent_material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.parent_base_qty),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_material_bom_hdr.parent_base_uom),' '),3,' ');
        
      open csr_bds_material_bom_det;
      loop
        fetch csr_bds_material_bom_det into rcd_bds_material_bom_det;
        exit when csr_bds_material_bom_det%notfound;
                               
        var_index := tbl_definition.count + 1;
                                 
        tbl_definition(var_index).value := 'DET'
          || rpad(nvl(to_char(rcd_bds_material_bom_det.child_material_code),' '),18,' ')
          || rpad(nvl(to_char(rcd_bds_material_bom_det.child_item_category),' '),1,' ')
          || rpad(nvl(to_char(rcd_bds_material_bom_det.child_base_qty),'0'),38,' ')
          || rpad(nvl(to_char(rcd_bds_material_bom_det.child_base_uom),' '),3,' ');
            
      end loop;
      close csr_bds_material_bom_det;         

    end loop;
    close csr_bds_material_bom_hdr;

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

end plant_material_bom_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_material_bom_extract to appsupport;
grant execute on ics_app.plant_material_bom_extract to lads_app;
grant execute on ics_app.plant_material_bom_extract to lics_app;
grant execute on ics_app.plant_material_bom_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_material_bom_extract for ics_app.plant_material_bom_extract;
