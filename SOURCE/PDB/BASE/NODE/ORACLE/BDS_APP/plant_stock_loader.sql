/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_stock_loader 
  Owner   : bds_app  
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound stock loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  08-Apr-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.plant_stock_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_stock_loader ; 
/

create or replace package body bds_app.plant_stock_loader as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  procedure complete_transaction;
  procedure process_record_ctl(par_record in varchar2);
  procedure process_record_hdr(par_record in varchar2);
  procedure process_record_det(par_record in varchar2);


  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
    
  rcd_hdr bds_stock_header%rowtype;
  rcd_det bds_stock_detail%rowtype;

  var_company_code rcd_hdr.company_code%type;
  var_plant_code rcd_hdr.plant_code%type;
  var_storage_location_code rcd_hdr.storage_location_code%type;
  var_stock_balance_date rcd_hdr.stock_balance_date%type;
  var_stock_balance_time rcd_hdr.stock_balance_time%type;

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
    lics_inbound_utility.set_definition('CTL','ID',3);
    lics_inbound_utility.set_definition('CTL','COMPANY_CODE', 4);
    lics_inbound_utility.set_definition('CTL','PLANT_CODE', 4);
    lics_inbound_utility.set_definition('CTL','STORAGE_LOCATION_CODE', 12);
    lics_inbound_utility.set_definition('CTL','STOCK_BALANCE_DATE', 8);
    lics_inbound_utility.set_definition('CTL','STOCK_BALANCE_TIME', 8);
    lics_inbound_utility.set_definition('CTL','MSG_TIMESTAMP', 14);
    
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','COMPANY_IDENTIFIER',6);
    lics_inbound_utility.set_definition('HDR','INVENTORY_DOCUMENT',10);
    
    /*-*/
    lics_inbound_utility.set_definition('DET','ID',3);
    lics_inbound_utility.set_definition('DET','MATERIAL_CODE',10);
    lics_inbound_utility.set_definition('DET','MATERIAL_BATCH_NUMBER',1);
    lics_inbound_utility.set_definition('DET','INSPECTION_STOCK_FLAG',1);
    lics_inbound_utility.set_definition('DET','STOCK_QUANTITY',38);
    lics_inbound_utility.set_definition('DET','STOCK_UOM_CODE',3);
    lics_inbound_utility.set_definition('DET','STOCK_BEST_BEFORE_DATE',8);
    lics_inbound_utility.set_definition('DET','CONSIGNMENT_CUST_VEND',10);
    lics_inbound_utility.set_definition('DET','RCV_ISU_STORAGE_LOCATION_CODE',4);
    lics_inbound_utility.set_definition('DET','STOCK_TYPE_CODE',2);
    
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
      when 'CTL' then process_record_ctl(par_record);
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
  /* This procedure performs the record CTL routine */
  /**************************************************/
  procedure process_record_ctl(par_record in varchar2) is              
  
    /*-*/
    /* Local definitions
    /*-*/
    var_exists boolean;
                     
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_stock_header is
      select t01.company_code as company_code,
        t01.plant_code as plant_code,
        t01.storage_location_code as storage_location_code,
        t01.stock_balance_date as stock_balance_date,
        t01.stock_balance_time as stock_balance_time,
        min(t01.msg_timestamp) as msg_timestamp
      from bds_stock_header t01
      where t01.company_code = rcd_hdr.company_code
        and t01.plant_code = rcd_hdr.plant_code
        and t01.storage_location_code = rcd_hdr.storage_location_code
        and t01.stock_balance_date = rcd_hdr.stock_balance_date
        and t01.stock_balance_time = rcd_hdr.stock_balance_time
      group by t01.company_code,
        t01.plant_code,
        t01.storage_location_code,
        t01.stock_balance_date,
        t01.stock_balance_time;
      
    rcd_bds_stock_header csr_bds_stock_header%rowtype;
    
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
    lics_inbound_utility.parse_record('CTL', par_record);

    /*-*/
    /* RETRIEVE - Retrieve the field values 
    /*-*/
    rcd_hdr.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
    rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_hdr.storage_location_code := lics_inbound_utility.get_variable('STORAGE_LOCATION_CODE');
    rcd_hdr.stock_balance_date := lics_inbound_utility.get_variable('STOCK_BALANCE_DATE');
    rcd_hdr.stock_balance_time := lics_inbound_utility.get_variable('STOCK_BALANCE_TIME');
    rcd_hdr.msg_timestamp := lics_inbound_utility.get_date('MSG_TIMESTAMP','yyyymmddhh24miss');
    
    /*-*/
    /* Validate message sequence  
    /*-*/
    open csr_bds_stock_header;
    fetch csr_bds_stock_header into rcd_bds_stock_header;
    
    if ( csr_bds_stock_header%notfound ) then
      var_exists := false;
    end if;
    
    close csr_bds_stock_header;
    
    if ( var_exists = true ) then
      if ( rcd_hdr.msg_timestamp > rcd_bds_stock_header.msg_timestamp ) then
        delete 
        from bds_stock_detail 
        where company_code = rcd_hdr.company_code
          and plant_code = rcd_hdr.plant_code
          and storage_location_code = rcd_hdr.storage_location_code
          and stock_balance_date = rcd_hdr.stock_balance_date
          and stock_balance_time = rcd_hdr.stock_balance_time;        
        
        delete 
        from bds_stock_header 
        where company_code = rcd_hdr.company_code
          and plant_code = rcd_hdr.plant_code
          and storage_location_code = rcd_hdr.storage_location_code
          and stock_balance_date = rcd_hdr.stock_balance_date
          and stock_balance_time = rcd_hdr.stock_balance_time;
      else
        var_trn_ignore := true;
      end if;
    end if;    
    
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_ctl;

  /**************************************************/
  /* This procedure performs the record HDR routine */
  /**************************************************/
  procedure process_record_hdr(par_record in varchar2) is
                          
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
    
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_hdr.company_identifier := lics_inbound_utility.get_variable('COMPANY_IDENTIFIER');
    rcd_hdr.inventory_document := lics_inbound_utility.get_variable('INVENTORY_DOCUMENT');

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
    if ( rcd_hdr.company_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.COMPANY_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.plant_code is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PLANT_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.storage_location_code is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.STORAGE_LOCATION_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.stock_balance_date is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.STOCK_BALANCE_DATE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.stock_balance_time is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.STOCK_BALANCE_TIME');
      var_trn_error := true;
    end if;
             
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into bds_stock_header 
    (
      company_code,
      plant_code,
      storage_location_code,
      stock_balance_date,
      stock_balance_time,
      company_identifier,
      inventory_document,
      msg_timestamp
    )
    values 
    (
      rcd_hdr.company_code,
      rcd_hdr.plant_code,
      rcd_hdr.storage_location_code,
      rcd_hdr.stock_balance_date,
      rcd_hdr.stock_balance_time,
      rcd_hdr.company_identifier,
      rcd_hdr.inventory_document,
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
    rcd_det.material_code := lics_inbound_utility.get_variable('MATERIAL_CODE');
    rcd_det.material_batch_number := lics_inbound_utility.get_variable('MATERIAL_BATCH_NUMBER');
    rcd_det.inspection_stock_flag := lics_inbound_utility.get_variable('INSPECTION_STOCK_FLAG');
    rcd_det.stock_quantity := lics_inbound_utility.get_variable('STOCK_QUANTITY');
    rcd_det.stock_uom_code := lics_inbound_utility.get_variable('STOCK_UOM_CODE');
    rcd_det.stock_best_before_date := lics_inbound_utility.get_variable('STOCK_BEST_BEFORE_DATE');
    rcd_det.consignment_cust_vend := lics_inbound_utility.get_variable('CONSIGNMENT_CUST_VEND');
    rcd_det.rcv_isu_storage_location_code := lics_inbound_utility.get_variable('RCV_ISU_STORAGE_LOCATION_CODE');
    rcd_det.stock_type_code := lics_inbound_utility.get_variable('STOCK_TYPE_CODE');
    
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
    if ( rcd_det.material_code is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - DET.MATERIAL_CODE');
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
    insert into bds_stock_detail
    (
      company_code,
      plant_code,
      storage_location_code,
      stock_balance_date,
      stock_balance_time,
      material_code,
      material_batch_number,
      inspection_stock_flag,
      stock_quantity,
      stock_uom_code,
      stock_best_before_date,
      consignment_cust_vend,
      rcv_isu_storage_location_code,
      stock_type_code
    )
    values 
    (
      rcd_hdr.company_code,
      rcd_hdr.plant_code,
      rcd_hdr.storage_location_code,
      rcd_hdr.stock_balance_date,
      rcd_hdr.stock_balance_time,
      rcd_det.material_code,
      rcd_det.material_batch_number,
      rcd_det.inspection_stock_flag,
      rcd_det.stock_quantity,
      rcd_det.stock_uom_code,
      rcd_det.stock_best_before_date,
      rcd_det.consignment_cust_vend,
      rcd_det.rcv_isu_storage_location_code,
      rcd_det.stock_type_code
    );

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;
  
end plant_stock_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_stock_loader to appsupport;
grant execute on bds_app.plant_stock_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_stock_loader for bds_app.plant_stock_loader;