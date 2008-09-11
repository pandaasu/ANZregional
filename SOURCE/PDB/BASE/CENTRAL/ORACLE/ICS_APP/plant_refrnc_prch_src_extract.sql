create or replace package ics_app.plant_refrnc_prch_src_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_refrnc_prch_src_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Purchasing Source Reference Data for Plant databases 
      
  EXECUTE - 
    Send purchasing source reference data.  

  1. PAR_SITE (OPTIONAL) 
  
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
  2008/07   Trevor Keon    Changed package to do full refreshes only

*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end plant_refrnc_prch_src_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_refrnc_prch_src_extract as

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
  var_material_code bds_refrnc_purchasing_src.sap_material_code%type;
  
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
    
    /*-*/
    /* validate parameters 
    /*-*/   
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *BTH, *WGI or NULL');
    end if;

    var_start := execute_extract;
        
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB09.1');
      end if;    
      if (par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB09.2'); 
      end if;    
      if (par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB09.3');
      end if;    
      if (par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB09.4');
      end if;    
      if (par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB09.5');   
      end if;
      if (par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB09.6');   
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
    raise_application_error(-20000, 'plant_refrnc_prch_src_extract - material_code: ' || var_material_code || ' - ' || var_exception);

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
    cursor csr_refrnc_purchasing_src is
      select t01.sap_material_code as sap_material_code, 
        t01.plant_code as plant_code, 
        t01.record_no as record_no, 
        to_char(t01.creatn_date, 'yyyymmddhh24miss') as creatn_date, 
        t01.creatn_user as creatn_user,
        to_char(t01.src_list_valid_from, 'yyyymmddhh24miss') as src_list_valid_from, 
        to_char(t01.src_list_valid_to, 'yyyymmddhh24miss') as src_list_valid_to, 
        t01.vendor_code as vendor_code,
        t01.fixed_vendor_indctr as fixed_vendor_indctr, 
        t01.agreement_no as agreement_no, 
        t01.agreement_item as agreement_item,
        t01.fixed_purchase_agreement_item as fixed_purchase_agreement_item, 
        t01.plant_procured_from as plant_procured_from,
        t01.sto_fixed_issuing_plant as sto_fixed_issuing_plant, 
        t01.manufctr_part_refrnc_material as manufctr_part_refrnc_material,
        t01.blocked_supply_src_flag as blocked_supply_src_flag, 
        t01.purchasing_organisation as purchasing_organisation,
        t01.purchasing_document_ctgry as purchasing_document_ctgry,
        t01.src_list_ctgry as src_list_ctgry, 
        t01.src_list_planning_usage as src_list_planning_usage,
        t01.order_unit as order_unit, 
        t01.logical_system as logical_system, 
        t01.special_stock_indctr as special_stock_indctr
      from bds_refrnc_purchasing_src t01
      order by t01.sap_material_code;
        
    rcd_refrnc_purchasing_src csr_refrnc_purchasing_src%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := false;
    var_material_code := null;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_refrnc_purchasing_src;
    loop
        
      fetch csr_refrnc_purchasing_src into rcd_refrnc_purchasing_src;
      exit when csr_refrnc_purchasing_src%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      var_material_code := rcd_refrnc_purchasing_src.sap_material_code;   
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.sap_material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.record_no),' '),5,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.creatn_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.creatn_user),' '),12,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_valid_from),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_valid_to),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.vendor_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.fixed_vendor_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.agreement_no),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.agreement_item),' '),5,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.fixed_purchase_agreement_item),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.plant_procured_from),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.sto_fixed_issuing_plant),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.manufctr_part_refrnc_material),' '),18,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.blocked_supply_src_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.purchasing_organisation),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.purchasing_document_ctgry),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_ctgry),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_planning_usage),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.order_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.logical_system),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.special_stock_indctr),' '),1,' ');

    end loop;
    close csr_refrnc_purchasing_src;

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

end plant_refrnc_prch_src_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_refrnc_prch_src_extract to appsupport;
grant execute on ics_app.plant_refrnc_prch_src_extract to lads_app;
grant execute on ics_app.plant_refrnc_prch_src_extract to lics_app;
grant execute on ics_app.plant_refrnc_prch_src_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_refrnc_prch_src_extract for ics_app.plant_refrnc_prch_src_extract;
