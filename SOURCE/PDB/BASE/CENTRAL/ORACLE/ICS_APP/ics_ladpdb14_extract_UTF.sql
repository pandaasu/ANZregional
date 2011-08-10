--
-- ICS_LADPDB14_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP."ICS_LADPDB14_EXTRACT" as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 

  Package : ics_ladpdb14_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Stock Balance Data for Plant databases 
  
  For both execute procedures: 
  
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
  2008/10   Trevor Keon    Changed to use lads stock balance view and be a 
                            full refresh of the data
  2010/09   Ben Halicki    Moved site specific settings to configuration via 
                            Data Store Configuration
  2011/08   Ben Halicki    Added MQFT trigger logic

*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end ics_ladpdb14_extract;
/


--
-- ICS_LADPDB14_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP."ICS_LADPDB14_EXTRACT" as

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
  var_company_code bds_stock_header.company_code%type;
  var_plant_code bds_stock_header.plant_code%type;
  var_storage_location_code bds_stock_header.storage_location_code%type;
  var_stock_balance_date bds_stock_header.stock_balance_date%type;
  var_stock_balance_time bds_stock_header.stock_balance_time%type;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB14';
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_site in varchar2) is 
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

    end loop;
    
    /*-*/
    /* if no valid sites were found, raise exception
    /*-*/
    if (csr_intfc%rowcount=0 and var_site='ALL') then
        raise_application_error(-20000, 'No valid plant databases have been configured via Data Store Configuration.');
    end if;
    
    if (csr_intfc%rowcount=0 and var_site!='ALL') then
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
    raise_application_error(-20000, 'ics_ladpdb14_extract - company_code: ' || var_company_code || ' - plant_code: ' || var_plant_code || ' - storage_location_code: ' || var_storage_location_code || ' - stock_balance_date: ' || var_stock_balance_date || ' - stock_balance_time: ' || var_stock_balance_time || ' - ' || var_exception);

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
    cursor csr_bds_stock_balance is
      select t01.company_code as company_code,
        t01.plant_code as plant_code,
        t01.storage_location_code as storage_location_code,
        t01.stock_balance_date as stock_balance_date,
        t01.stock_balance_time as stock_balance_time,
        t01.material_code as material_code,
        t01.material_batch_number as material_batch_number,
        t01.inspection_stock_flag as inspection_stock_flag,
        t01.stock_quantity as stock_quantity,
        t01.stock_uom_code as stock_uom_code,
        t01.stock_best_before_date as stock_best_before_date,
        t01.consignment_cust_vend as consignment_cust_vend,
        t01.rcv_isu_storage_location_code as rcv_isu_storage_location_code,
        t01.stock_type_code as stock_type_code
      from bds_stock_balance t01
      where t01.plant_code in (select dsv_value from table(lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS')));
        
    rcd_bds_stock_balance csr_bds_stock_balance%rowtype;  

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
    open csr_bds_stock_balance;
    loop
    
      fetch csr_bds_stock_balance into rcd_bds_stock_balance;
      exit when csr_bds_stock_balance%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current codes for error message purposes 
      /*-*/      
      var_company_code := rcd_bds_stock_balance.company_code;
      var_plant_code := rcd_bds_stock_balance.plant_code;
      var_storage_location_code := rcd_bds_stock_balance.storage_location_code;
      var_stock_balance_date := rcd_bds_stock_balance.stock_balance_date;
      var_stock_balance_time := rcd_bds_stock_balance.stock_balance_time;
      
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_stock_balance.company_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.storage_location_code),' '),12,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.stock_balance_date),' '),8,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.stock_balance_time),' '),8,' ')      
        || rpad(nvl(to_char(rcd_bds_stock_balance.material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.material_batch_number),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.inspection_stock_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.stock_quantity),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.stock_uom_code),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.stock_best_before_date),' '),8,' ')   
        || rpad(nvl(to_char(rcd_bds_stock_balance.consignment_cust_vend),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.rcv_isu_storage_location_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_stock_balance.stock_type_code),' '),6,' ');

    end loop;
    close csr_bds_stock_balance;

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

end ics_ladpdb14_extract;
/


--
-- ICS_LADPDB14_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB14_EXTRACT FOR ICS_APP.ICS_LADPDB14_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB14_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB14_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB14_EXTRACT TO LICS_APP;

