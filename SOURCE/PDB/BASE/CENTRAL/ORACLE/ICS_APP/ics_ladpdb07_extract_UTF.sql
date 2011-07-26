--
-- ICS_LADPDB07_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ICS_LADPDB07_EXTRACT as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB07_EXTRACT 
  Owner   : ics_app 

  Description 
  ----------- 
  Reference Characteristic Data for Plant databases 

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
  2010/10   Ben Halicki    Moved interface configuration to be configured via 
                             Data Store Configuration
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end ICS_LADPDB07_EXTRACT;
/


--
-- ICS_LADPDB07_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ICS_LADPDB07_EXTRACT as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_charistic_code bds_refrnc_charistic.sap_charistic_code%type;
  var_charistic_value_code bds_refrnc_charistic.sap_charistic_value_code%type;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB07';
  
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
  
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
       
    var_start := execute_extract;    

    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/     
    if (var_start = true) then
        open csr_intfc;
        loop
            fetch csr_intfc into rcd_intfc;
            exit when csr_intfc%notfound;
    
            var_intfc := con_intfc || rcd_intfc.intfc_extn;         
            execute_send(var_intfc);
        end loop;    
    end if;
    
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
    raise_application_error(-20000, 'ICS_LADPDB07_EXTRACT - charistic_code: ' || var_charistic_code || ' - charistic_value_code: ' || var_charistic_value_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  function execute_extract return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
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
      from bds_refrnc_charistic t01; 
        
    rcd_refrnc_charistic csr_refrnc_charistic%rowtype;

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
    open csr_refrnc_charistic;
    loop
    
      fetch csr_refrnc_charistic into rcd_refrnc_charistic;
      exit when csr_refrnc_charistic%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true; 
      
      var_charistic_code := rcd_refrnc_charistic.sap_charistic_code;
      var_charistic_value_code := rcd_refrnc_charistic.sap_charistic_value_code;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_refrnc_charistic.sap_charistic_code),' '),30,' ')
        || rpad(nvl(to_char(rcd_refrnc_charistic.sap_charistic_value_code),' '),30,' ')
        || rpad(nvl(to_char(rcd_refrnc_charistic.sap_charistic_value_shrt_desc),' '),256,' ')
        || rpad(nvl(to_char(rcd_refrnc_charistic.sap_charistic_value_long_desc),' '),256,' ')
        || rpad(nvl(to_char(rcd_refrnc_charistic.sap_idoc_number),'0'),38,' ')
        || rpad(nvl(to_char(rcd_refrnc_charistic.sap_idoc_timestamp),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_charistic.change_flag),' '),1,' ');

    end loop;
    close csr_refrnc_charistic;

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

end ICS_LADPDB07_EXTRACT;
/


--
-- ICS_LADPDB07_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB07_EXTRACT FOR ICS_APP.ICS_LADPDB07_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB07_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB07_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB07_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB07_EXTRACT TO LICS_APP;

