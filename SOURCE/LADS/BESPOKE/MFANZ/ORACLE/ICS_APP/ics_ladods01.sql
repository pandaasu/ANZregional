create or replace package ics_app.ics_ladods01 as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ics_ladods01 
  Owner   : ics_app 

  Description 
  ----------- 
  Bill of material data for Venus

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/08   Trevor Keon    Created 

*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;

end ics_ladods01;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.ics_ladods01 as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_material_code bds_bom_hdr.bom_material_code%type; 
  var_alternative bds_bom_hdr.bom_alternative%type;
  var_plant bds_bom_hdr.bom_plant%type;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_instance  number(15,0);
    var_start     boolean := false;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_bom_hdr is
      select t01.bom_material_code as bom_material_code,
        t01.bom_alternative as bom_alternative,
        t01.bom_plant as bom_plant,
        t01.sap_idoc_name as sap_idoc_name,
        t01.sap_idoc_number as sap_idoc_number,
        t01.sap_idoc_timestamp as sap_idoc_timestamp,
        t01.bom_number as bom_number,
        t01.bom_msg_function as bom_msg_function,
        t01.bom_usage as bom_usage,
        to_char(t01.bom_eff_from_date, 'yyyymmddhh24miss') as bom_eff_from_date,
        to_char(t01.bom_eff_to_date, 'yyyymmddhh24miss') as bom_eff_to_date,
        t01.bom_base_qty as bom_base_qty,
        t01.bom_base_uom as bom_base_uom,
        t01.bom_status as bom_status
      from bds_bom_hdr t01; 
      
    rcd_bds_bom_hdr csr_bds_bom_hdr%rowtype;
    
    cursor csr_bds_bom_det is
      select t01.bom_material_code as bom_material_code,
        t01.bom_alternative as bom_alternative,
        t01.bom_plant as bom_plant,
        t01.item_sequence as item_sequence,
        t01.item_number as item_number,
        t01.item_msg_function as item_msg_function,
        t01.item_material_code as item_material_code,
        t01.item_category as item_category,
        t01.item_base_qty as item_base_qty,
        t01.item_base_uom as item_base_uom,
        to_char(t01.item_eff_from_date, 'yyyymmddhh24miss') as item_eff_from_date,
        to_char(t01.item_eff_to_date, 'yyyymmddhh24miss') as item_eff_to_date,
        t01.bom_number as bom_number,
        t01.bom_msg_function as bom_msg_function,
        t01.bom_usage as bom_usage,
        to_char(t01.bom_eff_from_date, 'yyyymmddhh24miss') as bom_eff_from_date,
        to_char(t01.bom_eff_to_date, 'yyyymmddhh24miss') as bom_eff_to_date,
        t01.bom_base_qty as bom_base_qty,
        t01.bom_base_uom as bom_base_uom,
        t01.bom_status as bom_status
      from bds_bom_det t01
      where t01.bom_material_code = rcd_bds_bom_hdr.bom_material_code
        and t01.bom_alternative = rcd_bds_bom_hdr.bom_alternative
        and t01.bom_plant = rcd_bds_bom_hdr.bom_plant;
      
    rcd_bds_bom_det csr_bds_bom_det%rowtype;        
         
  begin
    /*-*/
    /* Initialise variables
    /*-*/        
    var_start := true;
    
    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_bom_hdr;
    loop
    
      fetch csr_bds_bom_hdr into rcd_bds_bom_hdr;
      exit when csr_bds_bom_hdr%notfound;
      
      /*-*/
      /* Create Outbound Interface if record(s) exist
      /*-*/
      if (var_start) then
        var_instance := lics_outbound_loader.create_interface('LADODS01',null,'LADODS01');
        var_start := false;
      end if;      
      
      var_material_code := rcd_bds_bom_hdr.bom_material_code;
      var_alternative := rcd_bds_bom_hdr.bom_alternative;
      var_plant := rcd_bds_bom_hdr.bom_plant;
              
      lics_outbound_loader.append_data('HDR'
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_alternative),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_plant),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.sap_idoc_name),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.sap_idoc_number),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.sap_idoc_timestamp),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_number),' '),8,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_msg_function),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_usage),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_eff_from_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_eff_to_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_base_qty),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_base_uom),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_bom_hdr.bom_status),' '),2,' '));
        
      open csr_bds_bom_det;
      loop
            
        fetch csr_bds_bom_det into rcd_bds_bom_det;
        exit when csr_bds_bom_det%notfound;
        
        lics_outbound_loader.append_data('DET'
          || rpad(nvl(to_char(rcd_bds_bom_det.item_sequence),'0'),38,' ')   
          || rpad(nvl(to_char(rcd_bds_bom_det.item_number),' '),4,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_msg_function),' '),3,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_material_code),' '),18,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_category),' '),1,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_base_qty),'0'),38,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_base_uom),' '),3,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_eff_from_date),' '),14,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.item_eff_to_date),' '),14,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_number),' '),8,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_msg_function),' '),3,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_usage),' '),1,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_eff_from_date),' '),14,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_eff_to_date),' '),14,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_base_qty),'0'),38,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_base_uom),' '),3,' ') 
          || rpad(nvl(to_char(rcd_bds_bom_det.bom_status),' '),2,' '));
      
      end loop;
      close csr_bds_bom_det;

    end loop;
    close csr_bds_bom_hdr; 
    
    /*-*/
    /* Finalise Interface
    /*-*/
    if lics_outbound_loader.is_created = true then
       lics_outbound_loader.finalise_interface;
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
      raise_application_error(-20000, 'ics_ladods01 - material_code: ' || var_material_code || ' - alternative_bom: ' || var_alternative || ' - plant_code: ' || var_plant || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
end ics_ladods01;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.ics_ladods01 to appsupport;
grant execute on ics_app.ics_ladods01 to lads_app;
grant execute on ics_app.ics_ladods01 to lics_app;
grant execute on ics_app.ics_ladods01 to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ics_ladods01 for ics_app.ics_ladods01;
