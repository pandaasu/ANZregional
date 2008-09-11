create or replace package ods_app.ladods01_loader as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : cdw
  Package : ladods01_loader 
  Owner   : ods_app 
  Author  : Trevor Keon
  
  Description 
  ----------- 
  Venus - Inbound sap_bom_hdr interface 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  12-Aug-2008  Trevor Keon      Created
   
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladods01_loader; 
/

create or replace package body ods_app.ladods01_loader as

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
    
  rcd_hdr sap_bom_hdr%rowtype;
  rcd_det sap_bom_det%rowtype;

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
    /* Delete reference data entries
    /*-*/     
    delete sap_bom_det;
    delete sap_bom_hdr;    
    
    /*-*/
    /* Initialise the inbound definitions 
    /*-*/ 
    lics_inbound_utility.clear_definition;
    
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','BOM_MATERIAL_CODE',18);
    lics_inbound_utility.set_definition('HDR','BOM_ALTERNATIVE',2);
    lics_inbound_utility.set_definition('HDR','BOM_PLANT',4);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NAME',30);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NUMBER',38);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_TIMESTAMP',14);
    lics_inbound_utility.set_definition('HDR','BOM_NUMBER',8);
    lics_inbound_utility.set_definition('HDR','BOM_MSG_FUNCTION',3);
    lics_inbound_utility.set_definition('HDR','BOM_USAGE',1);
    lics_inbound_utility.set_definition('HDR','BOM_EFF_FROM_DATE',14);
    lics_inbound_utility.set_definition('HDR','BOM_EFF_TO_DATE',14);
    lics_inbound_utility.set_definition('HDR','BOM_BASE_QTY',38);
    lics_inbound_utility.set_definition('HDR','BOM_BASE_UOM',3);
    lics_inbound_utility.set_definition('HDR','BOM_STATUS',2);
    
    /*-*/
    lics_inbound_utility.set_definition('DET','ID',3);
    lics_inbound_utility.set_definition('DET','ITEM_SEQUENCE',38);
    lics_inbound_utility.set_definition('DET','ITEM_NUMBER',4);
    lics_inbound_utility.set_definition('DET','ITEM_MSG_FUNCTION',3);
    lics_inbound_utility.set_definition('DET','ITEM_MATERIAL_CODE',18);
    lics_inbound_utility.set_definition('DET','ITEM_CATEGORY',1);
    lics_inbound_utility.set_definition('DET','ITEM_BASE_QTY',38);
    lics_inbound_utility.set_definition('DET','ITEM_BASE_UOM',3);
    lics_inbound_utility.set_definition('DET','ITEM_EFF_FROM_DATE',14);
    lics_inbound_utility.set_definition('DET','ITEM_EFF_TO_DATE',14);
    lics_inbound_utility.set_definition('DET','BOM_NUMBER',8);
    lics_inbound_utility.set_definition('DET','BOM_MSG_FUNCTION',3);
    lics_inbound_utility.set_definition('DET','BOM_USAGE',1);
    lics_inbound_utility.set_definition('DET','BOM_EFF_FROM_DATE',14);
    lics_inbound_utility.set_definition('DET','BOM_EFF_TO_DATE',14);
    lics_inbound_utility.set_definition('DET','BOM_BASE_QTY',38);
    lics_inbound_utility.set_definition('DET','BOM_BASE_UOM',3);
    lics_inbound_utility.set_definition('DET','BOM_STATUS',2);  
    
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
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/
    rcd_hdr.bom_material_code := lics_inbound_utility.get_variable('BOM_MATERIAL_CODE');
    rcd_hdr.bom_alternative := lics_inbound_utility.get_variable('BOM_ALTERNATIVE');
    rcd_hdr.bom_plant := lics_inbound_utility.get_variable('BOM_PLANT');
    rcd_hdr.sap_idoc_name := lics_inbound_utility.get_variable('SAP_IDOC_NAME');
    rcd_hdr.sap_idoc_number := lics_inbound_utility.get_number('SAP_IDOC_NUMBER',null);
    rcd_hdr.sap_idoc_timestamp := lics_inbound_utility.get_date('SAP_IDOC_TIMESTAMP','yyyymmddhh24miss');
    rcd_hdr.bom_number := lics_inbound_utility.get_variable('BOM_NUMBER');
    rcd_hdr.bom_msg_function := lics_inbound_utility.get_variable('BOM_MSG_FUNCTION');
    rcd_hdr.bom_usage := lics_inbound_utility.get_variable('BOM_USAGE');
    rcd_hdr.bom_eff_from_date := lics_inbound_utility.get_date('BOM_EFF_FROM_DATE','yyyymmddhh24miss');
    rcd_hdr.bom_eff_to_date := lics_inbound_utility.get_date('BOM_EFF_TO_DATE','yyyymmddhh24miss');
    rcd_hdr.bom_base_qty := lics_inbound_utility.get_number('BOM_BASE_QTY',null);
    rcd_hdr.bom_base_uom := lics_inbound_utility.get_variable('BOM_BASE_UOM');
    rcd_hdr.bom_status := lics_inbound_utility.get_variable('BOM_STATUS');
    rcd_hdr.load_date := sysdate;

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
    if ( rcd_hdr.bom_material_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.BOM_MATERIAL_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.bom_alternative is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.BOM_ALTERNATIVE');
      var_trn_error := true;
    end if;

    if ( rcd_hdr.bom_plant is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.BOM_PLANT');
      var_trn_error := true;
    end if;
             
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into sap_bom_hdr
    (
      bom_material_code,
      bom_alternative,
      bom_plant,
      sap_idoc_name,
      sap_idoc_number,
      sap_idoc_timestamp,
      bom_number,
      bom_msg_function,
      bom_usage,
      bom_eff_from_date,
      bom_eff_to_date,
      bom_base_qty,
      bom_base_uom,
      bom_status,
      load_date
    )
    values 
    (
      rcd_hdr.bom_material_code,
      rcd_hdr.bom_alternative,
      rcd_hdr.bom_plant,
      rcd_hdr.sap_idoc_name,
      rcd_hdr.sap_idoc_number,
      rcd_hdr.sap_idoc_timestamp,
      rcd_hdr.bom_number,
      rcd_hdr.bom_msg_function,
      rcd_hdr.bom_usage,
      rcd_hdr.bom_eff_from_date,
      rcd_hdr.bom_eff_to_date,
      rcd_hdr.bom_base_qty,
      rcd_hdr.bom_base_uom,
      rcd_hdr.bom_status,
      rcd_hdr.load_date
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

    if var_trn_ignore = true then
       return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('DET', par_record);    
      
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_det.bom_material_code := lics_inbound_utility.get_variable('BOM_MATERIAL_CODE');
    rcd_det.bom_alternative := lics_inbound_utility.get_variable('BOM_ALTERNATIVE');
    rcd_det.bom_plant := lics_inbound_utility.get_variable('BOM_PLANT');
    rcd_det.item_sequence := lics_inbound_utility.get_number('ITEM_SEQUENCE',null);
    rcd_det.item_number := lics_inbound_utility.get_variable('ITEM_NUMBER');
    rcd_det.item_msg_function := lics_inbound_utility.get_variable('ITEM_MSG_FUNCTION');
    rcd_det.item_material_code := lics_inbound_utility.get_variable('ITEM_MATERIAL_CODE');
    rcd_det.item_category := lics_inbound_utility.get_variable('ITEM_CATEGORY');
    rcd_det.item_base_qty := lics_inbound_utility.get_number('ITEM_BASE_QTY',null);
    rcd_det.item_base_uom := lics_inbound_utility.get_variable('ITEM_BASE_UOM');
    rcd_det.item_eff_from_date := lics_inbound_utility.get_date('ITEM_EFF_FROM_DATE','yyyymmddhh24miss');
    rcd_det.item_eff_to_date := lics_inbound_utility.get_date('ITEM_EFF_TO_DATE','yyyymmddhh24miss');
    rcd_det.bom_number := lics_inbound_utility.get_variable('BOM_NUMBER');
    rcd_det.bom_msg_function := lics_inbound_utility.get_variable('BOM_MSG_FUNCTION');
    rcd_det.bom_usage := lics_inbound_utility.get_variable('BOM_USAGE');
    rcd_det.bom_eff_from_date := lics_inbound_utility.get_date('BOM_EFF_FROM_DATE','yyyymmddhh24miss');
    rcd_det.bom_eff_to_date := lics_inbound_utility.get_date('BOM_EFF_TO_DATE','yyyymmddhh24miss');
    rcd_det.bom_base_qty := lics_inbound_utility.get_number('BOM_BASE_QTY',null);
    rcd_det.bom_base_uom := lics_inbound_utility.get_variable('BOM_BASE_UOM');
    rcd_det.bom_status := lics_inbound_utility.get_variable('BOM_STATUS');

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
    if ( rcd_det.item_sequence is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - DET.ITEM_SEQUENCE');
       var_trn_error := true;
    end if;
            
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
       return;
    end if;

    insert into sap_bom_det
    (
      bom_material_code,
      bom_alternative,
      bom_plant,
      item_sequence,
      item_number,
      item_msg_function,
      item_material_code,
      item_category,
      item_base_qty,
      item_base_uom,
      item_eff_from_date,
      item_eff_to_date,
      bom_number,
      bom_msg_function,
      bom_usage,
      bom_eff_from_date,
      bom_eff_to_date,
      bom_base_qty,
      bom_base_uom,
      bom_status
    )
    values 
    (
      rcd_hdr.bom_material_code,
      rcd_hdr.bom_alternative,
      rcd_hdr.bom_plant,
      rcd_det.item_sequence,
      rcd_det.item_number,
      rcd_det.item_msg_function,
      rcd_det.item_material_code,
      rcd_det.item_category,
      rcd_det.item_base_qty,
      rcd_det.item_base_uom,
      rcd_det.item_eff_from_date,
      rcd_det.item_eff_to_date,
      rcd_det.bom_number,
      rcd_det.bom_msg_function,
      rcd_det.bom_usage,
      rcd_det.bom_eff_from_date,
      rcd_det.bom_eff_to_date,
      rcd_det.bom_base_qty,
      rcd_det.bom_base_uom,
      rcd_det.bom_status
    );

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;  
  
end ladods01_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on ods_app.ladods01_loader to appsupport;
grant execute on ods_app.ladods01_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladods01_loader for ods_app.ladods01_loader;