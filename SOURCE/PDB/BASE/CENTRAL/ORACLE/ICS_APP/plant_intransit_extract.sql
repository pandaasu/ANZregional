/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_intransit_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  In Transit Data for Plant databases 
  
  1. PAR_ACTION (MANDATORY) 

    *ALL - send all in transit data  
    *PLANT - send in transit data matching a given plant code 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *PLANT = plant code 
        
  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *REL = Relevant - will only send the data to the site which matches 
        the plant code parameter.  If plant code is null, will act like *ALL 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 

*******************************************************************************/

create or replace package ics_app.plant_intransit_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_intransit_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_intransit_extract as

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
  function get_send_relative return varchar2;
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_plant_code bds_intransit_header.plant_code%type;
  
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
        and var_action != '*PLANT' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *PLANT');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*WGI' 
        and var_site != '*REL' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI, *REL or NULL');
    end if;
    
    if ( var_action = '*PLANT' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *PLANT actions.');
    end if;
       
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then
      if (var_site = '*REL' ) then
        if ( var_plant_code is null or var_action = '*ALL' ) then
          var_site := '*ALL';
        else  
          var_site := get_send_relative;
        end if;
      end if;
                
      if ( par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB15.1');   
      end if;    
      if ( par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB15.2');   
      end if;    
      if ( par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB15.3');   
      end if;    
      if ( par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB15.4');   
      end if;    
      if ( par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB15.5');   
      end if;
      if ( par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB15.6');   
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
    raise_application_error(-20000, 'plant_intransit_extract - plant_code: ' || var_plant_code || ' - ' || var_exception);

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
    cursor csr_bds_intransit_header is
      select t01.plant_code as plant_code,
        t01.target_planning_area as target_planning_area
      from bds_intransit_header t01
      where         
        (
          par_action = '*ALL'
          or (par_action = '*PLANT' and t01.plant_code = par_data)
        );
        
    rcd_bds_intransit_header csr_bds_intransit_header%rowtype;    
    
    cursor csr_bds_intransit_detail is
      select t01.plant_code as plant_code,
        t01.detseq as detseq,
        t01.company_code as company_code,
        t01.business_segment_code as business_segment_code,
        t01.cnn_number as cnn_number,
        t01.purch_order_number as purch_order_number,
        t01.vendor_code as vendor_code,
        t01.shipment_number as shipment_number,
        t01.inbound_delivery_number as inbound_delivery_number,
        t01.source_plant_code as source_plant_code,
        t01.source_storage_location_code as source_storage_location_code,
        t01.shipping_plant_code as shipping_plant_code,
        t01.target_storage_location_code as target_storage_location_code,
        t01.target_mrp_plant_code as target_mrp_plant_code,
        t01.shipping_date as shipping_date,
        t01.arrival_date as arrival_date,
        t01.maturation_date as maturation_date,
        t01.batch_number as batch_number,
        t01.best_before_date as best_before_date,
        t01.transportation_model_code as transportation_model_code,
        t01.forward_agent_code as forward_agent_code,
        t01.forward_agent_trailer_number as forward_agent_trailer_number,
        t01.material_code as material_code,
        t01.quantity as quantity,
        t01.uom_code as uom_code,
        t01.stock_type_code as stock_type_code,
        t01.order_type_code as order_type_code,
        t01.container_number as container_number,
        t01.seal_number as seal_number,
        t01.vessel_name as vessel_name,
        t01.voyage as voyage,
        t01.record_sequence as record_sequence, 
        t01.record_count as record_count,
        t01.record_timestamp as record_timestamp
      from bds_intransit_detail t01
      where t01.plant_code = rcd_bds_intransit_header.plant_code;
        
    rcd_bds_intransit_detail csr_bds_intransit_detail%rowtype;  

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
    open csr_bds_intransit_header;
    loop
    
      fetch csr_bds_intransit_header into rcd_bds_intransit_header;
      exit when csr_bds_intransit_header%notfound;

      var_index := tbl_definition.count + 1;
      var_result := false;
      
      /*-*/
      /* Store current codes for error message purposes 
      /*-*/      
      var_plant_code := rcd_bds_intransit_header.plant_code;
      
      tbl_definition(var_index).value := 'HDR'
        || rpad(to_char(nvl(rcd_bds_intransit_header.plant_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_intransit_header.target_planning_area,' ')),10,' ')
        || rpad(to_char(sysdate, 'yyyymmddhh24miss'),14,' ');
          
      open csr_bds_intransit_detail;
      loop      
      
        var_index := tbl_definition.count + 1;
        
        fetch csr_bds_intransit_detail into rcd_bds_intransit_detail;
        exit when csr_bds_intransit_detail%notfound;
        
        tbl_definition(var_index).value := 'DET'
          || rpad(to_char(nvl(rcd_bds_intransit_detail.detseq,'0')),10,' ')
          || rpad(to_char(nvl(rcd_bds_intransit_detail.company_code,' ')),4,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.business_segment_code,'0')),4,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.cnn_number,' ')),35,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.purch_order_number,' ')),10,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.vendor_code,' ')),10,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.shipment_number,' ')),10,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.inbound_delivery_number,' ')),10,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.source_plant_code,' ')),4,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.source_storage_location_code,' ')),4,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.shipping_plant_code,' ')),4,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.target_storage_location_code,' ')),4,' ')  
          || rpad(to_char(nvl(rcd_bds_intransit_detail.target_mrp_plant_code,' ')),4,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.shipping_date,' ')),8,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.arrival_date,' ')),8,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.maturation_date,' ')),8,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.batch_number,' ')),10,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.best_before_date,' ')),8,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.transportation_model_code,' ')),2,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.forward_agent_code,' ')),10,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.forward_agent_trailer_number,' ')),10,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.material_code,' ')),18,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.quantity,'0')),38,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.uom_code,' ')),3,' ')   
          || rpad(to_char(nvl(rcd_bds_intransit_detail.stock_type_code,' ')),1,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.order_type_code,' ')),4,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.container_number,' ')),20,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.seal_number,' ')),40,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.vessel_name,' ')),20,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.voyage,' ')),20,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.record_sequence,' ')),15,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.record_count,' ')),15,' ')    
          || rpad(to_char(nvl(rcd_bds_intransit_detail.record_timestamp,' ')),18,' ');         
      
      end loop;
      close csr_bds_intransit_detail;  

    end loop;
    close csr_bds_intransit_header;

    return var_result;
    
  end execute_extract;

  function get_send_relative return varchar2 is
    /*-*/
    /* Local variables 
    /*-*/
    var_result varchar2(10);    
    var_vir_table lics_datastore_table := lics_datastore_table();
    
  begin
    var_vir_table := lics_datastore.retrieve_group('PDB','PLC',var_plant_code);
    
    if ( var_vir_table.count = 0 ) then      
      raise_application_error(-20000, 'Plant code (' || var_plant_code || ') is not known');
    elsif ( var_vir_table.count > 1 ) then
      raise_application_error(-20000, 'Plant code (' || var_plant_code || ') has multiple entries in the lics datastore');    
    else
      var_result := '*' || var_vir_table(1).dsv_group;
    end if;
    
    return var_result;
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

end plant_intransit_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_intransit_extract to appsupport;
grant execute on ics_app.plant_intransit_extract to lads_app;
grant execute on ics_app.plant_intransit_extract to lics_app;
grant execute on ics_app.plant_intransit_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_intransit_extract for ics_app.plant_intransit_extract;
