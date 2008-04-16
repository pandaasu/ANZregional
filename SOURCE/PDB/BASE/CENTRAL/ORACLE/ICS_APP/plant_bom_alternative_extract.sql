/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_bom_alternative_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  BOM Alternative Data for Plant databases 

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

*******************************************************************************/

create or replace package ics_app.plant_bom_alternative_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');
  procedure execute(par_material_code in varchar2, par_alternative in varchar2, par_plant in varchar2, par_site in varchar2 default '*ALL');

end plant_bom_alternative_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_bom_alternative_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_material_code in varchar2, par_alternative in varchar2, par_plant in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_material_code bds_refrnc_bom_altrnt_t415a.sap_material_code%type; 
  var_alternative bds_refrnc_bom_altrnt_t415a.altrntv_bom%type;
  var_plant bds_refrnc_bom_altrnt_t415a.plant_code%type;
  
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
    execute(null, null, null, par_site);
  end;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_material_code in varchar2, par_alternative in varchar2, par_plant in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_site      varchar2(10);
    var_start     boolean := false;
         
  begin
    var_material_code := trim(par_material_code);
    var_alternative := trim(par_alternative);
    var_plant := trim(par_plant);    
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
       
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI or NULL');
    end if;
        
    var_start := execute_extract(var_material_code, var_alternative, var_plant);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB05.1');   
      end if;    
      if (par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB05.2');   
      end if;    
      if (par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB05.3');   
      end if;    
      if (par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB05.4');   
      end if;    
      if (par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB05.5');   
      end if;
      if (par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB05.6');   
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
    raise_application_error(-20000, 'plant_bom_alternative_extract - material_code: ' || var_material_code || ' - alternative_bom: ' || var_alternative || ' - plant_code: ' || var_plant || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_material_code in varchar2, par_alternative in varchar2, par_plant in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_refrnc_bom_altrnt is
      select ltrim(t01.sap_material_code,'0') as bom_material_code,
        ltrim(t01.altrntv_bom,'0') as bom_alternative,
        t01.plant_code as bom_plant,
        t01.bom_usage as bom_usage,
        to_char(t01.valid_from_date, 'yyyymmddhh24miss') as bom_eff_from_date
      from bds_refrnc_bom_altrnt_t415a t01
      where (par_material_code is null or ltrim(t01.sap_material_code,'0') = ltrim(par_material_code,'0'))
        and (par_alternative is null or ltrim(t01.altrntv_bom,'0') = ltrim(par_alternative,'0'))
        and (par_plant is null or t01.plant_code = par_plant);
        
    rcd_bds_refrnc_bom_altrnt csr_bds_refrnc_bom_altrnt%rowtype;

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
    open csr_bds_refrnc_bom_altrnt;
    loop
    
      fetch csr_bds_refrnc_bom_altrnt into rcd_bds_refrnc_bom_altrnt;
      exit when csr_bds_refrnc_bom_altrnt%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_alternative,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_plant,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_usage,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_refrnc_bom_altrnt.bom_eff_from_date,' ')),14,' ');

    end loop;
    close csr_bds_refrnc_bom_altrnt;

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

end plant_bom_alternative_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_bom_alternative_extract to appsupport;
grant execute on ics_app.plant_bom_alternative_extract to lads_app;
grant execute on ics_app.plant_bom_alternative_extract to lics_app;
grant execute on ics_app.plant_bom_alternative_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_bom_alternative_extract for ics_app.plant_bom_alternative_extract;
