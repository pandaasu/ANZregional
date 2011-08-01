/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb14_loader 
  Owner   : bds_app  
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound stock loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  08-Apr-2008  Trevor Keon      Created 
  22-Oct-2008  Trevor Keon      Updated to handle full refreshes of data
*******************************************************************************/

create or replace package bds_app.ladpdb14_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb14_loader ; 
/

create or replace package body bds_app.ladpdb14_loader as

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


  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
    
  rcd_hdr bds_stock_balance%rowtype;

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
    var_trn_start := true;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-*/
    /* Delete Stock Balance data entries
    /*-*/     
    delete bds_stock_balance;

    /*-*/
    /* Initialise the inbound definitions 
    /*-*/ 
    lics_inbound_utility.clear_definition;
    
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','COMPANY_CODE', 4);
    lics_inbound_utility.set_definition('HDR','PLANT_CODE', 4);
    lics_inbound_utility.set_definition('HDR','STORAGE_LOCATION_CODE', 12);
    lics_inbound_utility.set_definition('HDR','STOCK_BALANCE_DATE', 8);
    lics_inbound_utility.set_definition('HDR','STOCK_BALANCE_TIME', 8);
    lics_inbound_utility.set_definition('HDR','MATERIAL_CODE',18);
    lics_inbound_utility.set_definition('HDR','MATERIAL_BATCH_NUMBER',10);
    lics_inbound_utility.set_definition('HDR','INSPECTION_STOCK_FLAG',1);
    lics_inbound_utility.set_definition('HDR','STOCK_QUANTITY',38);
    lics_inbound_utility.set_definition('HDR','STOCK_UOM_CODE',3);
    lics_inbound_utility.set_definition('HDR','STOCK_BEST_BEFORE_DATE',8);
    lics_inbound_utility.set_definition('HDR','CONSIGNMENT_CUST_VEND',10);
    lics_inbound_utility.set_definition('HDR','RCV_ISU_STORAGE_LOCATION_CODE',4);
    lics_inbound_utility.set_definition('HDR','STOCK_TYPE_CODE',6);
    
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
                          
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/       
    rcd_hdr.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
    rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_hdr.storage_location_code := lics_inbound_utility.get_variable('STORAGE_LOCATION_CODE');
    rcd_hdr.stock_balance_date := lics_inbound_utility.get_variable('STOCK_BALANCE_DATE');
    rcd_hdr.stock_balance_time := lics_inbound_utility.get_variable('STOCK_BALANCE_TIME');    
    rcd_hdr.material_code := lics_inbound_utility.get_variable('MATERIAL_CODE');
    rcd_hdr.material_batch_number := lics_inbound_utility.get_variable('MATERIAL_BATCH_NUMBER');
    rcd_hdr.inspection_stock_flag := lics_inbound_utility.get_variable('INSPECTION_STOCK_FLAG');
    rcd_hdr.stock_quantity := lics_inbound_utility.get_variable('STOCK_QUANTITY');
    rcd_hdr.stock_uom_code := lics_inbound_utility.get_variable('STOCK_UOM_CODE');
    rcd_hdr.stock_best_before_date := lics_inbound_utility.get_variable('STOCK_BEST_BEFORE_DATE');
    rcd_hdr.consignment_cust_vend := lics_inbound_utility.get_variable('CONSIGNMENT_CUST_VEND');
    rcd_hdr.rcv_isu_storage_location_code := lics_inbound_utility.get_variable('RCV_ISU_STORAGE_LOCATION_CODE');
    rcd_hdr.stock_type_code := lics_inbound_utility.get_variable('STOCK_TYPE_CODE');    

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
             
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;
    
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into bds_stock_balance 
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
      rcd_hdr.material_code,
      rcd_hdr.material_batch_number,
      rcd_hdr.inspection_stock_flag,
      rcd_hdr.stock_quantity,
      rcd_hdr.stock_uom_code,
      rcd_hdr.stock_best_before_date,
      rcd_hdr.consignment_cust_vend,
      rcd_hdr.rcv_isu_storage_location_code,
      rcd_hdr.stock_type_code
    );    

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
  
end ladpdb14_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb14_loader to appsupport;
grant execute on bds_app.ladpdb14_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb14_loader for bds_app.ladpdb14_loader;