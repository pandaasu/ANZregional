--
-- PLANT_BOM_ALL_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.plant_bom_all_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_bom_all_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Bill of Material Data for Plant databases 
      
  EXECUTE - 
    Send all site relevant BOM data to the specified site
  
  1. PAR_SITE (OPTIONAL)
  
    Specify the site for the data to be sent to.
      - *ALL (DEFAULT)
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui
      - *BTH = Bathurst
    

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/10   Trevor Keon    Created 
  2011/12   B. Halicki    Added trigger option for sending to systems without V2
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end plant_bom_all_extract;
/


--
-- PLANT_BOM_ALL_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM PLANT_BOM_ALL_EXTRACT FOR ICS_APP.PLANT_BOM_ALL_EXTRACT;


GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO LICS_APP;


--
-- PLANT_BOM_ALL_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.plant_bom_all_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_site in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  
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
  procedure execute(par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_site      varchar2(10);
    var_start     boolean := false;
         
  begin
  
    var_site := upper(nvl(trim(par_site), '*ALL'));
       
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *BTH or *WGI');
    end if;
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/  
    if ( par_site in ('*ALL','*MFA') and execute_extract('MFA') = true ) then   
        execute_send('LADPDB04.1','Y'); 
    end if;    
    if ( par_site in ('*ALL','*WGI') and execute_extract('WGI') = true ) then   
        execute_send('LADPDB04.2','Y'); 
    end if;    
    if ( par_site in ('*ALL','*WOD') and execute_extract('WOD') = true ) then   
        execute_send('LADPDB04.3','N'); 
    end if;    
    if ( par_site in ('*ALL','*BTH') and execute_extract('BTH') = true ) then 
        execute_send('LADPDB04.4','Y'); 
    end if;    
    if ( par_site in ('*ALL','*MCA') and execute_extract('MCA') = true ) then   
        execute_send('LADPDB04.5','N'); 
    end if;
    if ( par_site in ('*ALL','*SCO') and execute_extract('SCO') = true ) then  
        execute_send('LADPDB04.6','N');
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
    raise_application_error(-20000, 'plant_bom_all_extract - material_code: ' || var_material_code || ' - alternative_bom: ' || var_alternative || ' - plant_code: ' || var_plant || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_site in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_bom_all is
      select t01.bom_material_code, 
        t01.bom_alternative, 
        t01.bom_plant,
        t01.bom_number, 
        t01.bom_msg_function, 
        t01.bom_usage,
        to_char(t01.bom_eff_from_date, 'yyyymmddhh24miss') as bom_eff_from_date,
        to_char(t01.bom_eff_to_date, 'yyyymmddhh24miss') as bom_eff_to_date,        
        t01.bom_base_qty, 
        t01.bom_base_uom,
        t01.bom_status, 
        t01.item_sequence, 
        t01.item_number,
        t01.item_msg_function, 
        t01.item_material_code, 
        t01.item_category,
        t01.item_base_qty, 
        t01.item_base_uom, 
        to_char(t01.item_eff_from_date, 'yyyymmddhh24miss') as item_eff_from_date, 
        to_char(t01.item_eff_to_date, 'yyyymmddhh24miss') as item_eff_to_date
      from bds_bom_all t01
      where t01.bom_plant in (select dsv_value from table(lics_datastore.retrieve_value('PDB',par_site,'BOM')));
        
    rcd_bds_bom_all csr_bds_bom_all%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := false;    
    tbl_definition.delete;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_bom_all;
    loop
    
      fetch csr_bds_bom_all into rcd_bds_bom_all;
      exit when csr_bds_bom_all%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store variables for error reporting 
      /*-*/      
      var_material_code := rcd_bds_bom_all.bom_material_code;
      var_alternative := rcd_bds_bom_all.bom_alternative;
      var_plant := rcd_bds_bom_all.bom_plant;       
                               
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_alternative),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_plant),' '),4,' ')      
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_number),' '),8,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_msg_function),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_usage),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_eff_from_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_eff_to_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_base_qty),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_base_uom),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.bom_status),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_sequence),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_number),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_msg_function),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_category),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_base_qty),' '),38,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_base_uom),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_eff_from_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_bom_all.item_eff_to_date),' '),14,' ');

    end loop;
    close csr_bds_bom_all;

    return var_result;
    
  end execute_extract;
  
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
          if upper(par_trigger) = 'Y' then
             var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
          else
             var_instance := lics_outbound_loader.create_interface(par_interface);
          end if;
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end plant_bom_all_extract;
/


--
-- PLANT_BOM_ALL_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM PLANT_BOM_ALL_EXTRACT FOR ICS_APP.PLANT_BOM_ALL_EXTRACT;


GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.PLANT_BOM_ALL_EXTRACT TO LICS_APP;
