CREATE OR REPLACE PACKAGE ICS_APP.plant_refrnc_charistic_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_refrnc_charistic_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Reference Characteristic Data for Plant databases 

  1. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 
  2008/07   Trevor Keon    Changed package to do full refreshes only
  2011/12   B. Halicki    Added trigger option for sending to systems without V2
  2012/11   B. Halicki     Removed Scoresby (SCO)
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end plant_refrnc_charistic_extract;
/

CREATE OR REPLACE PUBLIC SYNONYM PLANT_REFRNC_CHARISTIC_EXTRACT FOR ICS_APP.PLANT_REFRNC_CHARISTIC_EXTRACT;
CREATE OR REPLACE PACKAGE BODY ICS_APP.plant_refrnc_charistic_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_charistic_code bds_refrnc_charistic.sap_charistic_code%type;
  var_charistic_value_code bds_refrnc_charistic.sap_charistic_value_code%type;
  
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
    
    tbl_definition.delete;
       
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *WOD, *MFA, *BTH, *WGI or NULL');
    end if;
    
    var_start := execute_extract;
        
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB07.1','Y'); 
      end if;    
      if (par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB07.2','Y');
      end if;    
      if (par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB07.3','N');
      end if;    
      if (par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB07.4','Y');  
      end if;    
      if (par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB07.5','Y');   
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
    raise_application_error(-20000, 'plant_refrnc_charistic_extract - charistic_code: ' || var_charistic_code || ' - charistic_value_code: ' || var_charistic_value_code || ' - ' || var_exception);

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

end plant_refrnc_charistic_extract;
/

CREATE OR REPLACE PUBLIC SYNONYM PLANT_REFRNC_CHARISTIC_EXTRACT FOR ICS_APP.PLANT_REFRNC_CHARISTIC_EXTRACT;
