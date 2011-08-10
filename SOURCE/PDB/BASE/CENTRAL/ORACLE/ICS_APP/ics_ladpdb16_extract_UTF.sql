--
-- ICS_LADPDB16_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP."ICS_LADPDB16_EXTRACT" as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ics_ladpdb16_extract 
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
  
    Specify the site for the data to be sent to. (configured via Data Store Configuration)
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand
      - *MCH = HUA Plant DB (China)
      
  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/05   Trevor Keon    Created 
  2010/09   Ben Halicki    Moved hard coded settings to Data Store Configuration
  2011/08   Ben Halicki    Added MQFT trigger logic
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ics_ladpdb16_extract;
/


--
-- ICS_LADPDB16_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP."ICS_LADPDB16_EXTRACT" as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean;
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
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB16';
  
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
    var_update_lastrun := true;
          
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

    cursor csr_trigger is
        select dsv_value as intfc_trigger 
          from table (lics_datastore.retrieve_value('PDB',rcd_intfc.site,'INTFC_TRIGGER')) t01;
    rcd_trigger csr_trigger%rowtype; 
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*CHARISTIC'
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *CHARISTIC or *HISTORY');
    end if;
    
    if ( var_action = '*CHARISTIC' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *CHARISTIC actions.');
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
           open csr_trigger;
           fetch csr_trigger into rcd_trigger;
           if csr_trigger%notfound then
              rcd_trigger.intfc_trigger := 'Y';
           end if;
           close csr_trigger;
           execute_send(var_intfc, rcd_trigger.intfc_trigger);
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
    raise_application_error(-20000, 'ics_ladpdb16_extract - ' || 'charistic_code: ' || var_charistic_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean is  
  
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
          or (par_action = '*HISTORY' and trunc(t01.bds_lads_date) >= trunc(sysdate-to_number(par_data)))             
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

end ics_ladpdb16_extract;
/


--
-- ICS_LADPDB16_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB16_EXTRACT FOR ICS_APP.ICS_LADPDB16_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB16_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB16_EXTRACT TO LICS_APP;

