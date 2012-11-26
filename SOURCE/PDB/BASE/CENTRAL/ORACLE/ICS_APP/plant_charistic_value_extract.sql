CREATE OR REPLACE PACKAGE ICS_APP.plant_charistic_value_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_charistic_value_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Characteristic Value Extract for Plant databases 

  EXECUTE - 
    Send Characteristic Value data since last successful send 
    
  EXECUTE - 
    Send Characteristic Value data based on the specified action.     

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all address data  
    *CHARISTIC - send charateristic value data matching a given charateristic code 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *CHARISTIC = charateristic code 

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/05   Trevor Keon    Created 
  2011/12   B. Halicki     Added trigger option for sending to systems without V2
  2012/11   B. Halicki     Removed Scoresby (SCO)
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_charistic_value_extract;
/

CREATE OR REPLACE PUBLIC SYNONYM PLANT_CHARISTIC_VALUE_EXTRACT FOR ICS_APP.PLANT_CHARISTIC_VALUE_EXTRACT;
CREATE OR REPLACE PACKAGE BODY ICS_APP.plant_charistic_value_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
    
  var_charistic_code bds_charistic_value_en.sap_charistic_code%type;
  
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
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB16');
  
    execute('*ALL',null,'*ALL');
  end; 

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
    var_start     boolean := false;
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*CHARISTIC' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *CHARISTIC');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *WOD, *MFA, *BTH, *WGI or NULL');
    end if;
    
    if ( var_action = '*CHARISTIC' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *CHARISTIC actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then  
    
      if ( par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB16.1','Y');
      end if;    
      if ( par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB16.2','Y');
      end if;    
      if ( par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB16.3','N');
      end if;    
      if ( par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB16.4','Y');
      end if;    
      if ( par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB16.5','Y');   
      end if;
    end if; 
    
    if ( var_update_lastrun = true ) then
      lics_last_run_control.set_last_run('LADPDB16',var_start_date);
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
    raise_application_error(-20000, 'plant_charistic_value_extract - ' || 'charistic_code: ' || var_charistic_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_charistic_value is
      select t01.sap_charistic_code as sap_charistic_code, 
        t02.sap_charistic_value_code as sap_charistic_value_code, 
        t02.sap_charistic_value_desc as sap_charistic_value_desc
      from bds_charistic_hdr t01,
        bds_charistic_value_en t02        
      where t01.sap_charistic_code = t02.sap_charistic_code
        and 
        (
          (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
          or (par_action = '*CHARISTIC' and t01.sap_charistic_code = par_data)
        );
    rcd_bds_charistic_value csr_bds_charistic_value%rowtype;

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
    open csr_bds_charistic_value;
    loop
    
      fetch csr_bds_charistic_value into rcd_bds_charistic_value;
      exit when csr_bds_charistic_value%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current charistic code for error message purposes 
      /*-*/
      var_charistic_code := rcd_bds_charistic_value.sap_charistic_code;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_charistic_value.sap_charistic_code),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_charistic_value.sap_charistic_value_code),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_charistic_value.sap_charistic_value_desc),' '),30,' ');

    end loop;
    close csr_bds_charistic_value;

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

end plant_charistic_value_extract;
/

CREATE OR REPLACE PUBLIC SYNONYM PLANT_CHARISTIC_VALUE_EXTRACT FOR ICS_APP.PLANT_CHARISTIC_VALUE_EXTRACT;
