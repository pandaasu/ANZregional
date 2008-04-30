/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb09_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound reference data loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  19-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.ladpdb09_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb09_loader; 
/

create or replace package body bds_app.ladpdb09_loader as

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
  
  rcd_hdr bds_refrnc_prchsing_src_ics%rowtype;

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
    lics_inbound_utility.set_definition('HDR','SAP_MATERIAL_CODE', 18);
    lics_inbound_utility.set_definition('HDR','PLANT_CODE', 4);
    lics_inbound_utility.set_definition('HDR','RECORD_NO', 5);
    lics_inbound_utility.set_definition('HDR','CREATN_DATE', 14);
    lics_inbound_utility.set_definition('HDR','CREATN_USER', 12);
    lics_inbound_utility.set_definition('HDR','SRC_LIST_VALID_FROM', 14);
    lics_inbound_utility.set_definition('HDR','SRC_LIST_VALID_TO', 14);
    lics_inbound_utility.set_definition('HDR','VENDOR_CODE', 10);
    lics_inbound_utility.set_definition('HDR','FIXED_VENDOR_INDCTR', 1);
    lics_inbound_utility.set_definition('HDR','AGREEMENT_NO', 10);
    lics_inbound_utility.set_definition('HDR','AGREEMENT_ITEM', 5);
    lics_inbound_utility.set_definition('HDR','FIXED_PURCHASE_AGREEMENT_ITEM', 1);
    lics_inbound_utility.set_definition('HDR','PLANT_PROCURED_FROM', 4);
    lics_inbound_utility.set_definition('HDR','STO_FIXED_ISSUING_PLANT', 1);
    lics_inbound_utility.set_definition('HDR','MANUFCTR_PART_REFRNC_MATERIAL', 18);
    lics_inbound_utility.set_definition('HDR','BLOCKED_SUPPLY_SRC_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','PURCHASING_ORGANISATION', 4);
    lics_inbound_utility.set_definition('HDR','PURCHASING_DOCUMENT_CTGRY', 1);
    lics_inbound_utility.set_definition('HDR','SRC_LIST_CTGRY', 1);
    lics_inbound_utility.set_definition('HDR','SRC_LIST_PLANNING_USAGE', 1);
    lics_inbound_utility.set_definition('HDR','ORDER_UNIT', 3);
    lics_inbound_utility.set_definition('HDR','LOGICAL_SYSTEM', 10);
    lics_inbound_utility.set_definition('HDR','SPECIAL_STOCK_INDCTR', 1);
      
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
      lics_inbound_utility.add_exception(substr(sqlerrm, 1, 512));
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

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/        
    rcd_hdr.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
    rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_hdr.record_no := lics_inbound_utility.get_variable('RECORD_NO');
    rcd_hdr.creatn_date := lics_inbound_utility.get_date('CREATN_DATE','yyyymmddhh24miss');
    rcd_hdr.creatn_user := lics_inbound_utility.get_variable('CREATN_USER');
    rcd_hdr.src_list_valid_from := lics_inbound_utility.get_date('SRC_LIST_VALID_FROM','yyyymmddhh24miss');
    rcd_hdr.src_list_valid_to := lics_inbound_utility.get_date('SRC_LIST_VALID_TO','yyyymmddhh24miss');
    rcd_hdr.vendor_code := lics_inbound_utility.get_variable('VENDOR_CODE');
    rcd_hdr.fixed_vendor_indctr := lics_inbound_utility.get_variable('FIXED_VENDOR_INDCTR');
    rcd_hdr.agreement_no := lics_inbound_utility.get_variable('AGREEMENT_NO');
    rcd_hdr.agreement_item := lics_inbound_utility.get_variable('AGREEMENT_ITEM');
    rcd_hdr.fixed_purchase_agreement_item := lics_inbound_utility.get_variable('FIXED_PURCHASE_AGREEMENT_ITEM');
    rcd_hdr.plant_procured_from := lics_inbound_utility.get_variable('PLANT_PROCURED_FROM');
    rcd_hdr.sto_fixed_issuing_plant := lics_inbound_utility.get_variable('STO_FIXED_ISSUING_PLANT');
    rcd_hdr.manufctr_part_refrnc_material := lics_inbound_utility.get_variable('MANUFCTR_PART_REFRNC_MATERIAL');
    rcd_hdr.blocked_supply_src_flag := lics_inbound_utility.get_variable('BLOCKED_SUPPLY_SRC_FLAG');
    rcd_hdr.purchasing_organisation := lics_inbound_utility.get_variable('PURCHASING_ORGANISATION');
    rcd_hdr.purchasing_document_ctgry := lics_inbound_utility.get_variable('PURCHASING_DOCUMENT_CTGRY');
    rcd_hdr.src_list_ctgry := lics_inbound_utility.get_variable('SRC_LIST_CTGRY');
    rcd_hdr.src_list_planning_usage := lics_inbound_utility.get_variable('SRC_LIST_PLANNING_USAGE');
    rcd_hdr.order_unit := lics_inbound_utility.get_variable('ORDER_UNIT');
    rcd_hdr.logical_system := lics_inbound_utility.get_variable('LOGICAL_SYSTEM');
    rcd_hdr.special_stock_indctr := lics_inbound_utility.get_variable('SPECIAL_STOCK_INDCTR');

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
    if ( rcd_hdr.sap_material_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_MATERIAL_CODE');
      var_trn_error := true;
    end if;
          
    if ( rcd_hdr.plant_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PLANT_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.record_no is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.RECORD_NO');
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
    
    /*------------------------------*/
    /* UPDATE - Update the database */
    /*------------------------------*/        
    update bds_refrnc_prchsing_src_ics
    set sap_material_code = rcd_hdr.sap_material_code, 
      plant_code = rcd_hdr.plant_code, 
      record_no = rcd_hdr.record_no, 
      creatn_date = rcd_hdr.creatn_date, 
      creatn_user = rcd_hdr.creatn_user,
      src_list_valid_from = rcd_hdr.src_list_valid_from, 
      src_list_valid_to = rcd_hdr.src_list_valid_to, 
      vendor_code = rcd_hdr.vendor_code,
      fixed_vendor_indctr = rcd_hdr.fixed_vendor_indctr, 
      agreement_no = rcd_hdr.agreement_no, 
      agreement_item = rcd_hdr.agreement_item,
      fixed_purchase_agreement_item = rcd_hdr.fixed_purchase_agreement_item, 
      plant_procured_from = rcd_hdr.plant_procured_from,
      sto_fixed_issuing_plant = rcd_hdr.sto_fixed_issuing_plant, 
      manufctr_part_refrnc_material = rcd_hdr.manufctr_part_refrnc_material,
      blocked_supply_src_flag = rcd_hdr.blocked_supply_src_flag, 
      purchasing_organisation = rcd_hdr.purchasing_organisation,
      purchasing_document_ctgry = rcd_hdr.purchasing_document_ctgry, 
      src_list_ctgry = rcd_hdr.src_list_ctgry, 
      src_list_planning_usage = rcd_hdr.src_list_planning_usage,
      order_unit = rcd_hdr.order_unit, 
      logical_system = rcd_hdr.logical_system, 
      special_stock_indctr = rcd_hdr.special_stock_indctr
    where sap_material_code = rcd_hdr.sap_material_code 
      and plant_code = rcd_hdr.plant_code 
      and record_no = rcd_hdr.record_no; 
    
    if ( sql%notfound ) then    
      insert into bds_refrnc_prchsing_src_ics
      (
        sap_material_code, 
        plant_code, 
        record_no, 
        creatn_date, 
        creatn_user,
        src_list_valid_from, 
        src_list_valid_to, 
        vendor_code,
        fixed_vendor_indctr, 
        agreement_no, 
        agreement_item,
        fixed_purchase_agreement_item, 
        plant_procured_from,
        sto_fixed_issuing_plant, 
        manufctr_part_refrnc_material,
        blocked_supply_src_flag, 
        purchasing_organisation,
        purchasing_document_ctgry, 
        src_list_ctgry, 
        src_list_planning_usage,
        order_unit, 
        logical_system, 
        special_stock_indctr
      )
      values 
      (
        rcd_hdr.sap_material_code, 
        rcd_hdr.plant_code, 
        rcd_hdr.record_no, 
        rcd_hdr.creatn_date, 
        rcd_hdr.creatn_user,
        rcd_hdr.src_list_valid_from, 
        rcd_hdr.src_list_valid_to, 
        rcd_hdr.vendor_code,
        rcd_hdr.fixed_vendor_indctr, 
        rcd_hdr.agreement_no, 
        rcd_hdr.agreement_item,
        rcd_hdr.fixed_purchase_agreement_item, 
        rcd_hdr.plant_procured_from,
        rcd_hdr.sto_fixed_issuing_plant, 
        rcd_hdr.manufctr_part_refrnc_material,
        rcd_hdr.blocked_supply_src_flag, 
        rcd_hdr.purchasing_organisation,
        rcd_hdr.purchasing_document_ctgry, 
        rcd_hdr.src_list_ctgry, 
        rcd_hdr.src_list_planning_usage,
        rcd_hdr.order_unit, 
        rcd_hdr.logical_system, 
        rcd_hdr.special_stock_indctr
      );
    end if;
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
    
end ladpdb09_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb09_loader to appsupport;
grant execute on bds_app.ladpdb09_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb09_loader for bds_app.ladpdb09_loader;