--
-- ICS_LADPDB18_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP."ICS_LADPDB18_EXTRACT" as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB18_EXTRACT 
  Owner   : ics_app 

  Description 
  ----------- 
  Plant Maintenance Equipment Master Extract for Plant databases 

  EXECUTE - 
    Send Equipment Master data since last successful send 
    
  EXECUTE - 
    Send Equipment Master data based on the specified action.     

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all equipment master data 
    *EQUIPMENT - send equipment master data matching a given equipment code 
    *HISTORY - all modified since specified date
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
    
    *ALL = null 
    *EQUIPMENT = equipment code 
    *HISTORY = number of days

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to 
        (configured using VALID_PLANTS directive in ICS Data Store Configuration)
        
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand

  YYYY/MM    Author       Version    Description 
  -------    ------       -------    ----------- 
  2011/04   Ben Halicki   1.0        Created 
  2012/08   Ben Halicki   1.1        Updated to include logic for End Point Architecture
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ICS_LADPDB18_EXTRACT;
/


--
-- ICS_LADPDB18_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP."ICS_LADPDB18_EXTRACT" as

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
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
  
  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB18';
      
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
    
  end execute; 

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
    var_intfc_trg varchar2(1);
     
    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_intfc is
      select t01.dsv_system,
             t01.dsv_group as site,
             max(case when t01.dsv_code='INTFC_EXTN' then DSV_VALUE end) as intfc_extn,
             nvl(max(case when t01.dsv_code='INTFC_TRG' then DSV_VALUE end),'Y') as intfc_trg 
        from table (lics_datastore.retrieve_group('PDB',null,null)) t01
      having (var_site = '*ALL' or '*' || t01.dsv_group = var_site)
      group by t01.dsv_system, 
               t01.dsv_group;  
    rcd_intfc csr_intfc%rowtype;
         
  begin  
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    /*-*/
    /* validate parameters 
   /*-*/
    if ( var_action != '*ALL'
        and var_action != '*EQUIPMENT'
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *EQUIPMENT or *HISTORY');
    end if;
    
    if ( var_action = '*EQUIPMENT' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *EQUIPMENT actions.');
    elsif ( var_action = '*HISTORY' and (var_data is null or to_number(var_data) <= 0) ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null and must be greater than 1 for *HISTORY actions.');
    end if;
    
    open csr_intfc;
    loop
        fetch csr_intfc into rcd_intfc;
        exit when csr_intfc%notfound;
       
        tbl_definition.delete;
        
        var_intfc := con_intfc || rcd_intfc.intfc_extn; 
        var_intfc_trg := rcd_intfc.intfc_trg;
        
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
            execute_send(var_intfc, var_intfc_trg);
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
    raise_application_error(-20000, 'ics_ladpdb18_extract - ' || ' - ' || var_exception);

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
    cursor csr_equipment_plant_hdr is
      select 
        t01.sap_equipment_code,
        t01.plant_code,
        t01.equipment_desc,
        t01.functnl_locn_code,
        t01.sort_field,
        t01.sap_idoc_name,
        t01.sap_idoc_number,
        t01.sap_idoc_timestamp,
        t01.bds_lads_date,
        t01.bds_lads_status
      from bds_equipment_plant_hdr t01
      where
        t01.plant_code in 
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS'))
        )
        and
        (
            (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
            or (par_action = '*EQUIPMENT' and trim(t01.sap_equipment_code) = trim(par_data))
            or (par_action = '*HISTORY' and trunc(t01.bds_lads_date) >= trunc(sysdate-to_number(par_data)))          
        );

    rcd_equipment_plant_hdr csr_equipment_plant_hdr%rowtype;

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
    open csr_equipment_plant_hdr;
    loop
    
      fetch csr_equipment_plant_hdr into rcd_equipment_plant_hdr;
      exit when csr_equipment_plant_hdr%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.sap_equipment_code),' '),18,' ')      
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.equipment_desc),' '),40,' ')
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.functnl_locn_code),' '),40,' ')
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.sort_field),' '),30,' ')                    
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.sap_idoc_name),' '),20,' ')
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.sap_idoc_number),' '),16,' ')               
        || rpad(nvl(to_char(rcd_equipment_plant_hdr.sap_idoc_timestamp),' '),14,' ');       

    end loop;
    close csr_equipment_plant_hdr;

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
          if (upper(par_trigger) = 'Y') then
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

end ICS_LADPDB18_EXTRACT;
/


--
-- ICS_LADPDB18_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB18_EXTRACT FOR ICS_APP.ICS_LADPDB18_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB18_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB18_EXTRACT TO LICS_APP;

