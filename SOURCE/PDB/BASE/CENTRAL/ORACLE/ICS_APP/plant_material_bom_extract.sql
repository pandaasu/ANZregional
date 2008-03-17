/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_material_bom_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Material Bill of Material Data for Plant databases 

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all address data  
    *BOM - send material BOM data matching a given SAP BOM code 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *BOM = SAP BOM code 

  3. PAR_SITE (OPTIONAL) 
  
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

create or replace package ics_app.plant_material_bom_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2, par_cust_code in varchar2);

end plant_material_bom_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_material_bom_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_bom_code bds_material_bom_all.sap_bom%type;
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;

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
    var_start     boolean;
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*BOM' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *BOM');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI or NULL');
    end if;
    
    if ( var_action = '*BOM' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *BOM actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site = '*ALL' or '*MFA') then
        execute_send('LADPDB02.1');   
      end if;    
      if (par_site = '*ALL' or '*WGI') then
        execute_send('LADPDB02.2');   
      end if;    
      if (par_site = '*ALL' or '*WOD') then
        execute_send('LADPDB02.3');   
      end if;    
      if (par_site = '*ALL' or '*BTH') then
        execute_send('LADPDB02.4');   
      end if;    
      if (par_site = '*ALL' or '*MCA') then
        execute_send('LADPDB02.5');   
      end if;
      if (par_site = '*ALL' or '*SCO') then
        execute_send('LADPDB02.6');   
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
    raise_application_error(-20000, 'plant_material_bom_extract - ' || 'sap_bom_code: ' || var_bom_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(5,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_material_bom_all is
      select t01.sap_bom as sap_bom, 
        t01.bom_alternative as bom_alternative, 
        t01.bom_plant as bom_plant, 
        t01.bom_usage as bom_usage, 
        t01.bom_status as bom_status,
        to_char(t01.bom_eff_date,'yyyymmddhh24miss') as bom_eff_date, 
        t01.parent_material_code as parent_material_code, 
        t01.parent_base_qty as parent_base_qty, 
        t01.parent_base_uom as parent_base_uom,
        t01.parent_material_type as parent_material_type, 
        t01.parent_ian as parent_ian, 
        t01.parent_plan_flag as parent_plan_flag, 
        t01.parent_intr_flag as parent_intr_flag,
        t01.parent_mcu_flag as parent_mcu_flag, 
        t01.parent_prom_flag as parent_prom_flag, 
        t01.parent_rsu_flag as parent_rsu_flag, 
        t01.parent_ship_cont as parent_ship_cont,
        t01.parent_semi_finished as parent_semi_finished, 
        t01.parent_tdu_flag as parent_tdu_flag, 
        t01.parent_rep_flag as parent_rep_flag,
        t01.child_material_code as child_material_code, 
        t01.child_base_qty as child_base_qty, 
        t01.child_base_uom as child_base_uom, 
        t01.child_per_parent as child_per_parent,
        t01.child_material_type as child_material_type, 
        t01.child_ian as child_ian, 
        t01.child_plan_flag as child_plan_flag, 
        t01.child_intr_flag as child_intr_flag,
        t01.child_mcu_flag as child_mcu_flag, 
        t01.child_prom_flag as child_prom_flag, 
        t01.child_rsu_flag as child_rsu_flag, 
        t01.child_ship_cont as child_ship_cont,
        t01.child_semi_finished as child_semi_finished, 
        t01.child_tdu_flag as child_tdu_flag, 
        t01.child_rep_flag as child_rep_flag
      from bds_material_bom_all t01
      where t01.bom_plant = '*NONE'                                                   --
        and t01.bom_status in (1, 7) -- 1 is active 7 inactive
        and exists
        (
          select 1
          from bds_material_plant_hdr t02
          where t01.parent_material_code = t02.sap_material_code
            and 
            (
              t02.plant_code like 'AU%'
              or t02.plant_code like 'NZ%'
            )
        )
        and 
        (
          par_action = '*ALL'
          or (par_action = '*BOM' and ltrim(t01.sap_bom,'0') = ltrim(par_data,'0'))
        );
    rcd_bds_material_bom_all csr_bds_material_bom_all%rowtype;

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
    open csr_bds_material_bom_all;
    loop
    
      fetch csr_bds_material_bom_all into rcd_bds_material_bom_all;
      exit when csr_bds_material_bom_all%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
      
      /*-*/
      /* Store current sap bom code for error message purposes 
      /*-*/
      var_bom_code := rcd_bds_material_bom_all.sap_bom;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(to_char(nvl(rcd_bds_material_bom_all.sap_bom,' ')),24,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.bom_alternative,' ')),6,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.bom_plant,' ')),15,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.bom_usage,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.bom_status,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.bom_eff_date,' ')),14,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_base_qty,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_base_uom,' ')),9,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_material_type,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_ian,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_plan_flag,' ')),6,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_intr_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_mcu_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_prom_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_rsu_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_ship_cont,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_semi_finished,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_tdu_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.parent_rep_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_material_code,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_base_qty,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_base_uom,' ')),9,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_per_parent,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_material_type,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_ian,' ')),18,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_plan_flag,' ')),6,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_intr_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_mcu_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_prom_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_rsu_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_ship_cont,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_semi_finished,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_tdu_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_material_bom_all.child_rep_flag,' ')),1,' ');

    end loop;
    close csr_bds_material_bom_all;

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

end plant_material_bom_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_material_bom_extract to appsupport;
grant execute on ics_app.plant_material_bom_extract to lads_app;
grant execute on ics_app.plant_material_bom_extract to lics_app;
grant execute on ics_app.plant_material_bom_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_material_bom_extract for ics_app.plant_material_bom_extract;
