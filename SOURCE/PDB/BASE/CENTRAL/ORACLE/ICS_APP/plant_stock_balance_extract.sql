/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_stock_balance_extract 
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
      - *REL = Relevant - will only send the data to the site which matches 
        the plant code parameter.  If plant code is null, will act like *ALL 

  For extended execute procedure: 
  
  1. PAR_COMPANY_CODE (MANDATORY) 
    
    Specify the company code to send to the plant.
    Refers to lads_stk_bal_hdr.burks 
    
  2. PAR_PLANT_CODE (MANDATORY) 
    
    Specify the plant code to send to the plant.
    Refers to lads_stk_bal_hdr.werks 
    
  3. PAR_STORAGE_LOCATION_CODE (MANDATORY) 
    
    Specify the storage location code to send to the plant.
    Refers to lads_stk_bal_hdr.lgort 
    
  4. PAR_STOCK_BALANCE_DATE (MANDATORY) 
    
    Specify the stock balance date to send to the plant.
    Refers to lads_stk_bal_hdr.budat 
    
  5. PAR_STOCK_BALANCE_TIME (MANDATORY) 
    
    Specify the stock balance time to send to the plant.
    Refers to lads_stk_bal_hdr.timlo 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 

*******************************************************************************/

create or replace package ics_app.plant_stock_balance_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');
  procedure execute(par_company_code in varchar2, par_plant_code in varchar2, par_storage_location_code in varchar2, par_stock_balance_date in varchar2, par_stock_balance_time in varchar2, par_site in varchar2 default '*ALL');

end plant_stock_balance_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_stock_balance_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_company_code in varchar2, par_plant_code in varchar2, par_storage_location_code in varchar2, par_stock_balance_date in varchar2, par_stock_balance_time in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  procedure execute_send_relative;
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_company_code bds_stock_balance.company_code%type;
  var_plant_code bds_stock_balance.plant_code%type;
  var_storage_location_code bds_stock_balance.storage_location_code%type;
  var_stock_balance_date bds_stock_balance.stock_balance_date%type;
  var_stock_balance_time bds_stock_balance.stock_balance_time%type;
  
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
  begin
    execute(null,null,null,null,null,par_site);
  end;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_company_code in varchar2, par_plant_code in varchar2, par_storage_location_code in varchar2, par_stock_balance_date in varchar2, par_stock_balance_time in varchar2, par_site in varchar2 default '*ALL') is 
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_site      varchar2(10);
    var_start     boolean;
         
  begin
  
    var_site := upper(nvl(trim(par_site), '*ALL'));  
    var_company_code := trim(par_company_code);
    var_plant_code := trim(par_plant_code);
    var_storage_location_code := trim(par_storage_location_code);
    var_stock_balance_date := trim(par_stock_balance_date);
    var_stock_balance_time := trim(par_stock_balance_time);
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/   
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI'
        and var_site != '*REL' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI, *REL or NULL');
    end if;
       
    var_start := execute_extract(var_company_code,var_plant_code,var_storage_location_code,var_stock_balance_date,var_stock_balance_time);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then
      if (par_site = '*REL' and var_plant_code is not null) then
        /*-*/
        /* send to relevant plant 
        /*-*/ 
        execute_send_relative;
      else    
        if ( par_site in ('*ALL','*MFA') ) then
          execute_send('LADPDB02.1');   
        end if;    
        if ( par_site in ('*ALL','*WGI') ) then
          execute_send('LADPDB02.2');   
        end if;    
        if ( par_site in ('*ALL','*WOD') ) then
          execute_send('LADPDB02.3');   
        end if;    
        if ( par_site in ('*ALL','*BTH') ) then
          execute_send('LADPDB02.4');   
        end if;    
        if ( par_site in ('*ALL','*MCA') ) then
          execute_send('LADPDB02.5');   
        end if;
        if ( par_site in ('*ALL','*SCO') ) then
          execute_send('LADPDB02.6');   
        end if;
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
    raise_application_error(-20000, 'plant_stock_balance_extract - company_code: ' || var_company_code || ' - plant_code: ' || var_plant_code || ' - storage_location_code: ' || var_storage_location_code || ' - stock_balance_date: ' || var_stock_balance_date || ' - stock_balance_time: ' || var_stock_balance_time || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_company_code in varchar2, par_plant_code in varchar2, par_storage_location_code in varchar2, par_stock_balance_date in varchar2, par_stock_balance_time in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
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
        t01.inspection_stock_flag as inspection_stock_flag,
        t01.stock_quantity as stock_quantity, 
        t01.stock_uom_code as stock_uom_code, 
        t01.stock_best_before_date as stock_best_before_date,
        t01.consignment_cust_vend as consignment_cust_vend, 
        t01.rcv_isu_storage_location_code as rcv_isu_storage_location_code, 
        t01.stock_type_code as stock_type_code,        
      from bds_stock_balance t01
      where (par_company_code is null or par_company_code = t01.company_code)
        and (par_plant_code is null or par_plant_code = t01.plant_code)
        and (par_storage_location_code is null or par_storage_location_code = t01.storage_location_code)
        and (par_stock_balance_date is null or par_stock_balance_date = t01.stock_balance_date)
        and (par_stock_balance_time is null or par_stock_balance_time = t01.stock_balance_time);
        
    rcd_bds_stock_balance csr_bds_stock_balance%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := true;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_stock_balance;
    loop
    
      fetch csr_bds_stock_balance into rcd_bds_stock_balance;
      exit when csr_bds_stock_balance%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
      
      /*-*/
      /* Store current customer code for error message purposes 
      /*-*/
      var_material_code := rcd_bds_stock_balance.bom_material_code;
      
      var_company_code := rcd_bds_stock_balance.company_code;
      var_plant_code := trim(par_plant_code);
      var_storage_location_code := trim(par_storage_location_code);
      var_stock_balance_date := trim(par_stock_balance_date);
      var_stock_balance_time := trim(par_stock_balance_time);
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(to_char(nvl(rcd_bds_stock_balance.company_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.plant_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.storage_location_code,' ')),12,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.stock_balance_date,' ')),8,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.stock_balance_time,' ')),8,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.inspection_stock_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.stock_quantity,' ')),38,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.stock_uom_code,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.stock_best_before_date,' ')),8,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.consignment_cust_vend,' ')),10,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.rcv_isu_storage_location_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_stock_balance.stock_type_code,' ')),6,' ');

    end loop;
    close csr_bds_stock_balance;

    return var_result;
    
  end execute_extract;

  procedure execute_send_relative is
    /*-*/
    /* Local variables 
    /*-*/
    var_plant_city bds_refrnc_plant.plant_city%type;
    
  begin
    select max(plant_city) as plant_city
    into var_plant_city
    from bds_refrnc_plant
    where plant_code = var_plant_code;
    
    if ( var_plant_city is null ) then
      /*-*/
      /* Raise an exception to the calling application 
      /*-*/
      raise_application_error(-20000, 'Plant code (' || var_plant_code || ') is not known');
    else
      if ( var_plant_city = 'Wyong' ) then
        execute_send('LADPDB02.1');      
      elsif ( var_plant_city = 'Wanganui' ) then
        execute_send('LADPDB02.2');   
      elsif ( var_plant_city = 'Wodonga' ) then
        execute_send('LADPDB02.3');   
      elsif ( var_plant_city = 'Bathurst' ) then
        execute_send('LADPDB02.4');   
      elsif ( var_plant_city in ('Wendouree','Ballarat') ) then
        execute_send('LADPDB02.5');   
      elsif ( var_plant_city = 'Scoresby' ) then
        execute_send('LADPDB02.6');  
      else         
        raise_application_error(-20000, 'Plant city (' || var_plant_city || ') is not known');
      end if;
      
    end if;
  end;
  
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

end plant_stock_balance_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_stock_balance_extract to appsupport;
grant execute on ics_app.plant_stock_balance_extract to lads_app;
grant execute on ics_app.plant_stock_balance_extract to lics_app;
grant execute on ics_app.plant_stock_balance_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_stock_balance_extract for ics_app.plant_stock_balance_extract;
