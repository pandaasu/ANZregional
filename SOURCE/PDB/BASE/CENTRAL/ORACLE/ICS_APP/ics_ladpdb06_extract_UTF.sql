--
-- ICS_LADPDB06_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ICS_LADPDB06_EXTRACT as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB06_EXTRACT 
  Owner   : ics_app 

  Description 
  ----------- 
  Production Resource Data for Plant databases 

  1. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 
  2008/07   Trevor Keon    Changed package to do full refreshes only
  2010/06   Ben Halicki    Modified for Atlas Thailand implementation
  2010/10   Ben Halicki    Updated to remove hard coded plants, moved to 
                            configuration via Data Store Configuration
                            
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end ICS_LADPDB06_EXTRACT;
/


--
-- ICS_LADPDB06_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ICS_LADPDB06_EXTRACT as

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
  var_update_lastrun boolean := false;
  var_resrc_id bds_prodctn_resrc_en.resrc_id%type;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB06';
  
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
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB06');
  
    execute('*ALL');
  end; 


  procedure execute(par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
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
  
    var_site := upper(nvl(trim(par_site), '*ALL'));
      
    open csr_intfc;
    loop
        fetch csr_intfc into rcd_intfc;
        exit when csr_intfc%notfound;
       
        tbl_definition.delete;
        
        var_intfc := con_intfc || rcd_intfc.intfc_extn; 
  
        var_start := execute_extract(rcd_intfc.site);      

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
    raise_application_error(-20000, 'ICS_LADPDB06_EXTRACT - ' || 'resrc_id: ' || var_resrc_id || ' - ' || var_exception);

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
    cursor csr_prodctn_resrc_en is
      select t01.resrc_id as resrc_id, 
        t01.resrc_code as resrc_code, 
        t01.resrc_text as resrc_text, 
        t01.resrc_plant_code as resrc_plant_code
      from bds_prodctn_resrc_en t01
      where t01.resrc_deletion_flag is null
        and t01.resrc_plant_code in
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS'))
        )       
        and substr(upper(resrc_text), 0, 6) <> 'DO NOT';
        
    rcd_prodctn_resrc_en csr_prodctn_resrc_en%rowtype;

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
    open csr_prodctn_resrc_en;
    loop
    
      fetch csr_prodctn_resrc_en into rcd_prodctn_resrc_en;
      exit when csr_prodctn_resrc_en%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      var_resrc_id := rcd_prodctn_resrc_en.resrc_id;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_id),' '),8,' ')
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_code),' '),8,' ')
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_text),' '),40,' ')
        || rpad(nvl(to_char(rcd_prodctn_resrc_en.resrc_plant_code),' '),4,' ');

    end loop;
    close csr_prodctn_resrc_en;

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

end ICS_LADPDB06_EXTRACT;
/


--
-- ICS_LADPDB06_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB06_EXTRACT FOR ICS_APP.ICS_LADPDB06_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB06_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB06_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB06_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB06_EXTRACT TO LICS_APP;

