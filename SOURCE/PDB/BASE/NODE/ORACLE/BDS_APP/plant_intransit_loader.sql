/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_intransit_loader 
  Owner   : bds_app  
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound stock loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  09-Apr-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.plant_intransit_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_intransit_loader ; 
/

create or replace package body bds_app.plant_intransit_loader as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  procedure complete_transaction;
  procedure process_record_hdr(par_record in varchar2);
  procedure process_record_det(par_record in varchar2);


  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
    
  rcd_hdr bds_intransit_header%rowtype;
  rcd_det bds_intransit_detail%rowtype;

  var_plant_code rcd_hdr.plant_code%type;

  /************************************************/
  /* This procedure performs the on start routine */
  /************************************************/
  procedure on_start is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Initialise the transaction variables 
    /*-*/
    var_trn_start := false;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-*/
    /* Initialise the inbound definitions 
    /*-*/ 
    lics_inbound_utility.clear_definition;
        
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','PLANT_CODE',4);
    lics_inbound_utility.set_definition('HDR','TARGET_PLANNING_AREA',10);
    lics_inbound_utility.set_definition('HDR','MSG_TIMESTAMP', 14);
    
    /*-*/
    lics_inbound_utility.set_definition('DET','ID',3);
    lics_inbound_utility.set_definition('DET','DETSEQ',10);
    lics_inbound_utility.set_definition('DET','COMPANY_CODE',4);
    lics_inbound_utility.set_definition('DET','BUSINESS_SEGMENT_CODE',4);
    lics_inbound_utility.set_definition('DET','CNN_NUMBER',35);
    lics_inbound_utility.set_definition('DET','PURCH_ORDER_NUMBER',10);
    lics_inbound_utility.set_definition('DET','VENDOR_CODE',10);
    lics_inbound_utility.set_definition('DET','SHIPMENT_NUMBER',10);
    lics_inbound_utility.set_definition('DET','INBOUND_DELIVERY_NUMBER',10);
    lics_inbound_utility.set_definition('DET','SOURCE_PLANT_CODE',4);
    lics_inbound_utility.set_definition('DET','SOURCE_STORAGE_LOCATION_CODE',4);
    lics_inbound_utility.set_definition('DET','SHIPPING_PLANT_CODE',4);
    lics_inbound_utility.set_definition('DET','TARGET_STORAGE_LOCATION_CODE',4);
    lics_inbound_utility.set_definition('DET','TARGET_MRP_PLANT_CODE',4);
    lics_inbound_utility.set_definition('DET','SHIPPING_DATE',8);
    lics_inbound_utility.set_definition('DET','ARRIVAL_DATE',8);
    lics_inbound_utility.set_definition('DET','MATURATION_DATE',8);
    lics_inbound_utility.set_definition('DET','BATCH_NUMBER',10);
    lics_inbound_utility.set_definition('DET','BEST_BEFORE_DATE',8);
    lics_inbound_utility.set_definition('DET','TRANSPORTATION_MODEL_CODE',2);
    lics_inbound_utility.set_definition('DET','FORWARD_AGENT_CODE',10);
    lics_inbound_utility.set_definition('DET','FORWARD_AGENT_TRAILER_NUMBER',10);
    lics_inbound_utility.set_definition('DET','MATERIAL_CODE',18);
    lics_inbound_utility.set_definition('DET','QUANTITY',38);
    lics_inbound_utility.set_definition('DET','UOM_CODE',3);
    lics_inbound_utility.set_definition('DET','STOCK_TYPE_CODE',1);
    lics_inbound_utility.set_definition('DET','ORDER_TYPE_CODE',4);
    lics_inbound_utility.set_definition('DET','CONTAINER_NUMBER',20);
    lics_inbound_utility.set_definition('DET','SEAL_NUMBER',40);
    lics_inbound_utility.set_definition('DET','VESSEL_NAME',20);
    lics_inbound_utility.set_definition('DET','VOYAGE',20);
    lics_inbound_utility.set_definition('DET','RECORD_SEQUENCE',15);
    lics_inbound_utility.set_definition('DET','RECORD_COUNT',15);
    lics_inbound_utility.set_definition('DET','RECORD_TIMESTAMP',18);
    
   /*-------------*/
   /* End routine */
   /*-------------*/
  end on_start;

  /***********************************************/
  /* This procedure performs the on data routine */
  /***********************************************/
  procedure on_data(par_record in varchar2) is

    /*-*/
    /* Local definitions 
    /*-*/
    var_record_identifier varchar2(3);

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin
    /*-*/
    /* Process the data based on record identifier  
    /*-*/
    var_record_identifier := substr(par_record,1,3);
    
    case var_record_identifier
      when 'HDR' then process_record_hdr(par_record);
      when 'DET' then process_record_det(par_record);
      else lics_inbound_utility.add_exception('Record identifier (' || var_record_identifier || ') not recognised');
    end case;

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

  /*-*/
  /* Exception trap 
  /*-*/
    when others then
      lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
      var_trn_error := true;
      
  /*-------------*/
  /* End routine */
  /*-------------*/
  end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
  procedure on_end is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Complete the Transaction 
    /*-*/
    complete_transaction;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end on_end;


   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
  procedure complete_transaction is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* No data processed 
    /*-*/
    if ( var_trn_start = false ) then
      rollback;
      return;
    end if;

    /*-*/
    /* Commit/rollback the transaction as required 
    /*-*/
    if ( var_trn_ignore = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    elsif ( var_trn_error = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    else
      /*-*/
      /* Commit the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      commit;
    end if;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end complete_transaction;

  /**************************************************/
  /* This procedure performs the record HDR routine */
  /**************************************************/
  procedure process_record_hdr(par_record in varchar2) is              
  
    /*-*/
    /* Local definitions
    /*-*/
    var_exists boolean;
                     
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_intransit_header is
      select t01.plant_code as plant_code,
        min(t01.msg_timestamp) as msg_timestamp
      from bds_intransit_header t01
      where t01.plant_code = rcd_hdr.plant_code
      group by t01.plant_code;
      
    rcd_bds_intransit_header csr_bds_intransit_header%rowtype;
    
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Complete the previous transactions 
    /*-*/
    complete_transaction;

    /*-*/
    /* Reset transaction variables 
    /*-*/
    var_trn_start := true;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-*/
    /* PARSE - Parse the data record 
    /*-*/    
    lics_inbound_utility.parse_record('HDR', par_record);

    /*-*/
    /* RETRIEVE - Retrieve the field values 
    /*-*/
    rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_hdr.target_planning_area := lics_inbound_utility.get_variable('TARGET_PLANNING_AREA');
    rcd_hdr.msg_timestamp := lics_inbound_utility.get_date('MSG_TIMESTAMP','yyyymmddhh24miss');
    
    /*-*/
    /* Validate message sequence  
    /*-*/
    open csr_bds_intransit_header;
    fetch csr_bds_intransit_header into rcd_bds_intransit_header;
    
    if ( csr_bds_intransit_header%notfound ) then
      var_exists := false;
    end if;
    
    close csr_bds_intransit_header;
    
    if ( var_exists = true ) then
      if ( rcd_hdr.msg_timestamp > rcd_bds_intransit_header.msg_timestamp ) then
        delete from bds_intransit_detail where plant_code = rcd_hdr.plant_code;
        delete from bds_intransit_header where plant_code = rcd_hdr.plant_code;
      else
        var_trn_ignore := true;
      end if;
    end if;
    
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

    /*-*/
    /* Retrieve exceptions raised 
    /*-*/
    if ( lics_inbound_utility.has_errors = true ) then
      var_trn_error := true;
    end if;

    /*----------------------------------------*/
    /* VALIDATION - Validate the field values */
    /*----------------------------------------*/

    /*-*/
    /* Validate the primary keys 
    /*-*/   
    if ( rcd_hdr.plant_code is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PLANT_CODE');
      var_trn_error := true;
    end if;
             
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into bds_intransit_header 
    (
      plant_code,
      target_planning_area,
      msg_timestamp
    )
    values 
    (
      rcd_hdr.plant_code,
      rcd_hdr.target_planning_area,
      rcd_hdr.msg_timestamp
    );     
    
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
   
  /**************************************************/
  /* This procedure performs the record DET routine */
  /**************************************************/
  procedure process_record_det(par_record in varchar2) is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('DET', par_record);

    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */
    /*--------------------------------------*/
    rcd_det.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_det.detseq := lics_inbound_utility.get_variable('DETSEQ');
    rcd_det.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
    rcd_det.business_segment_code := lics_inbound_utility.get_variable('BUSINESS_SEGMENT_CODE');
    rcd_det.cnn_number := lics_inbound_utility.get_variable('CNN_NUMBER');
    rcd_det.purch_order_number := lics_inbound_utility.get_variable('PURCH_ORDER_NUMBER');
    rcd_det.vendor_code := lics_inbound_utility.get_variable('VENDOR_CODE');
    rcd_det.shipment_number := lics_inbound_utility.get_variable('SHIPMENT_NUMBER');
    rcd_det.inbound_delivery_number := lics_inbound_utility.get_variable('INBOUND_DELIVERY_NUMBER');
    rcd_det.source_plant_code := lics_inbound_utility.get_variable('SOURCE_PLANT_CODE');
    rcd_det.source_storage_location_code := lics_inbound_utility.get_variable('SOURCE_STORAGE_LOCATION_CODE');
    rcd_det.shipping_plant_code := lics_inbound_utility.get_variable('SHIPPING_PLANT_CODE');
    rcd_det.target_storage_location_code := lics_inbound_utility.get_variable('TARGET_STORAGE_LOCATION_CODE');
    rcd_det.target_mrp_plant_code := lics_inbound_utility.get_variable('TARGET_MRP_PLANT_CODE');
    rcd_det.shipping_date := lics_inbound_utility.get_variable('SHIPPING_DATE');
    rcd_det.arrival_date := lics_inbound_utility.get_variable('ARRIVAL_DATE');
    rcd_det.maturation_date := lics_inbound_utility.get_variable('MATURATION_DATE');
    rcd_det.batch_number := lics_inbound_utility.get_variable('BATCH_NUMBER');
    rcd_det.best_before_date := lics_inbound_utility.get_variable('BEST_BEFORE_DATE');
    rcd_det.transportation_model_code := lics_inbound_utility.get_variable('TRANSPORTATION_MODEL_CODE');
    rcd_det.forward_agent_code := lics_inbound_utility.get_variable('FORWARD_AGENT_CODE');
    rcd_det.forward_agent_trailer_number := lics_inbound_utility.get_variable('FORWARD_AGENT_TRAILER_NUMBER');
    rcd_det.material_code := lics_inbound_utility.get_variable('MATERIAL_CODE');
    rcd_det.quantitys := lics_inbound_utility.get_variable('QUANTITY');
    rcd_det.uom_code := lics_inbound_utility.get_variable('UOM_CODE');
    rcd_det.stock_type_code := lics_inbound_utility.get_variable('STOCK_TYPE_CODE');
    rcd_det.order_type_code := lics_inbound_utility.get_variable('ORDER_TYPE_CODE');
    rcd_det.container_number := lics_inbound_utility.get_variable('CONTAINER_NUMBER');
    rcd_det.seal_number := lics_inbound_utility.get_variable('SEAL_NUMBER');
    rcd_det.vessel_name := lics_inbound_utility.get_variable('VESSEL_NAME');
    rcd_det.voyage := lics_inbound_utility.get_variable('VOYAGE');
    rcd_det.record_sequence := lics_inbound_utility.get_variable('RECORD_SEQUENCE');
    rcd_det.record_count := lics_inbound_utility.get_variable('RECORD_COUNT');
    rcd_det.record_timestamp := lics_inbound_utility.get_variable('RECORD_TIMESTAMP');
    
    /*-*/
    /* Retrieve exceptions raised 
    /*-*/
    if ( lics_inbound_utility.has_errors = true ) then
      var_trn_error := true;
    end if;

    /*----------------------------------------*/
    /* VALIDATION - Validate the field values */
    /*----------------------------------------*/

    /*-*/
    /* Validate the primary keys 
    /*-*/
    if ( rcd_det.plant_code is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - DET.PLANT_CODE');
       var_trn_error := true;
    end if;

    if ( rcd_det.detseq is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - DET.DETSEQ');
       var_trn_error := true;
    end if;
            
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
       return;
    end if;

    /*----------------------------------------*/
    /* LOCK- Lock the interface transaction   */
    /*----------------------------------------*/

    /*-*/
    /* Lock the transaction 
    /* NOTE - attempt to lock the transaction header row (oracle default wait behaviour) 
    /*          - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index 
    /*          - update/update (exists) - logic goes to update and default wait behaviour 
    /*      - validate the IDOC sequence when locking row exists 
    /*      - lock and commit cycle encompasses transaction child procedure execution 
    /*-*/
    insert into bds_intransit_detail
    (
      plant_code,
      detseq,
      company_code,
      business_segment_code,
      cnn_number,
      purch_order_number,
      vendor_code,
      shipment_number,
      inbound_delivery_number,
      source_plant_code,
      source_storage_location_code,
      shipping_plant_code,
      target_storage_location_code,
      target_mrp_plant_code,
      shipping_date,
      arrival_date,
      maturation_date,
      batch_number,
      best_before_date,
      transportation_model_code,
      forward_agent_code,
      forward_agent_trailer_number,
      material_code,
      quantitys,
      uom_code,
      stock_type_code,
      order_type_code,
      container_number,
      seal_number,
      vessel_name,
      voyage,
      record_sequence,
      record_count,
      record_timestamp
    )
    values 
    (
      rcd_hdr.plant_code,
      rcd_det.detseq,
      rcd_det.company_code,
      rcd_det.business_segment_code,
      rcd_det.cnn_number,
      rcd_det.purch_order_number,
      rcd_det.vendor_code,
      rcd_det.shipment_number,
      rcd_det.inbound_delivery_number,
      rcd_det.source_plant_code,
      rcd_det.source_storage_location_code,
      rcd_det.shipping_plant_code,
      rcd_det.target_storage_location_code,
      rcd_det.target_mrp_plant_code,
      rcd_det.shipping_date,
      rcd_det.arrival_date,
      rcd_det.maturation_date,
      rcd_det.batch_number,
      rcd_det.best_before_date,
      rcd_det.transportation_model_code,
      rcd_det.forward_agent_code,
      rcd_det.forward_agent_trailer_number,
      rcd_det.material_code,
      rcd_det.quantitys,
      rcd_det.uom_code,
      rcd_det.stock_type_code,
      rcd_det.order_type_code,
      rcd_det.container_number,
      rcd_det.seal_number,
      rcd_det.vessel_name,
      rcd_det.voyage,
      rcd_det.record_sequence,
      rcd_det.record_count,
      rcd_det.record_timestamp
    );

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;
  
end plant_intransit_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_intransit_loader to appsupport;
grant execute on bds_app.plant_intransit_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_intransit_loader for bds_app.plant_intransit_loader;