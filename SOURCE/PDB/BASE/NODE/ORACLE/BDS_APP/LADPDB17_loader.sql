CREATE OR REPLACE PACKAGE BDS_APP.ladpdb17_loader as

  /******************************************************************************/
  /* Package Definition                                                         */
  /******************************************************************************/
  /** 
    System  : Plant Database 
    Package : ladpdb17_loader 
    Owner   : bds_app 
    Author  : Ben Halicki

    Description 
    ----------- 
    Plant Database - Stock Transfer Order / Purchase Order interface loader 

    dd-mmm-yyyy  Author           Version   Description 
    -----------  ------           -------   ----------- 
    18-Jun-2010  Ben Halicki      1.0       Created
    
  *******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;

end ladpdb17_loader;
/

GRANT EXECUTE ON BDS_APP.LADPDB17_LOADER TO LICS_APP
/
CREATE OR REPLACE PACKAGE BODY BDS_APP.ladpdb17_loader as

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
  
  rcd_bds_sto_po_header bds_sto_po_header%rowtype;
  rcd_bds_sto_po_detail bds_sto_po_detail%rowtype;
  
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
    /* Initialise the inbound definitions 
    /*-*/ 
    lics_inbound_utility.clear_definition;
    
    /*-*/  
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','PURCH_ORDER_DOC_NUM',35);
    lics_inbound_utility.set_definition('HDR','DOCUMENT_TYPE',4);
    lics_inbound_utility.set_definition('HDR','CURRENCY_CODE',3);
    lics_inbound_utility.set_definition('HDR','PURCH_ORDER_TYPE',35);
    lics_inbound_utility.set_definition('HDR','VENDOR_CODE',17);
    lics_inbound_utility.set_definition('HDR','DOCUMENT_DATE',8);
    lics_inbound_utility.set_definition('HDR','COMPANY_CODE',35);
    lics_inbound_utility.set_definition('HDR','PURCH_ORDER_ORG_CODE',35);
    lics_inbound_utility.set_definition('HDR','PURCH_ORDER_GRP_CODE',35);
    lics_inbound_utility.set_definition('HDR','CUSTOMER_CODE',10);  

    lics_inbound_utility.set_definition('DET','ID',3); 
    lics_inbound_utility.set_definition('DET','PURCH_ORDER_DOC_NUM',35);    
    lics_inbound_utility.set_definition('DET','PURCH_ORDER_DOC_LINE_NUM',6); 
    lics_inbound_utility.set_definition('DET','SAP_MATERIAL_CODE',35); 
    lics_inbound_utility.set_definition('DET','DELIVERY_DATE',8); 
    lics_inbound_utility.set_definition('DET','QTY',15); 
    lics_inbound_utility.set_definition('DET','UOM_CODE',3); 
    lics_inbound_utility.set_definition('DET','ITEM_VALUE_NET',18); 
    lics_inbound_utility.set_definition('DET','PLANT_CODE',4); 
    lics_inbound_utility.set_definition('DET','STORAGE_LOCN_CODE',4); 
    lics_inbound_utility.set_definition('DET','ACTION_CODE',3);
    lics_inbound_utility.set_definition('DET','DLVRY_COMP',1);
    lics_inbound_utility.set_definition('DET','OVER_DEL_TOLRNCE',5);
    lics_inbound_utility.set_definition('DET','STOCK_TYPE',1);
       
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

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/       
    rcd_bds_sto_po_header.purch_order_doc_num := lics_inbound_utility.get_variable('PURCH_ORDER_DOC_NUM');
    rcd_bds_sto_po_header.document_type := lics_inbound_utility.get_variable('DOCUMENT_TYPE');
    rcd_bds_sto_po_header.currency_code := lics_inbound_utility.get_variable('CURRENCY_CODE');
    rcd_bds_sto_po_header.purch_order_type := lics_inbound_utility.get_variable('PURCH_ORDER_TYPE');
    rcd_bds_sto_po_header.vendor_code := lics_inbound_utility.get_variable('VENDOR_CODE');
    rcd_bds_sto_po_header.document_date := lics_inbound_utility.get_date('DOCUMENT_DATE','yyyymmdd');
    rcd_bds_sto_po_header.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
    rcd_bds_sto_po_header.purch_order_org_code := lics_inbound_utility.get_variable('PURCH_ORDER_ORG_CODE');
    rcd_bds_sto_po_header.purch_order_grp_code := lics_inbound_utility.get_variable('PURCH_ORDER_GRP_CODE');
    rcd_bds_sto_po_header.customer_code := lics_inbound_utility.get_variable('CUSTOMER_CODE');
    rcd_bds_sto_po_header.upd_datime := sysdate;
        
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
    if ( rcd_bds_sto_po_header.purch_order_doc_num is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PURCH_ORDER_DOC_NUM');
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

    begin
        insert into bds_sto_po_header
        (
            purch_order_doc_num,
            document_type,
            currency_code,
            purch_order_type,
            vendor_code,
            document_date,
            company_code,
            purch_order_org_code,
            purch_order_grp_code,
            customer_code,
            upd_datime     
        )
        values
        (
            rcd_bds_sto_po_header.purch_order_doc_num,
            rcd_bds_sto_po_header.document_type,
            rcd_bds_sto_po_header.currency_code,
            rcd_bds_sto_po_header.purch_order_type,
            rcd_bds_sto_po_header.vendor_code,
            rcd_bds_sto_po_header.document_date,
            rcd_bds_sto_po_header.company_code,
            rcd_bds_sto_po_header.purch_order_org_code,
            rcd_bds_sto_po_header.purch_order_grp_code,
            rcd_bds_sto_po_header.customer_code,
            rcd_bds_sto_po_header.upd_datime
        );  
    exception
    when dup_val_on_index then
         
        update bds_sto_po_header set
            document_type = rcd_bds_sto_po_header.document_type,
            currency_code = rcd_bds_sto_po_header.currency_code,
            purch_order_type = rcd_bds_sto_po_header.purch_order_type,
            vendor_code = rcd_bds_sto_po_header.vendor_code,
            document_date = rcd_bds_sto_po_header.document_date,
            company_code = rcd_bds_sto_po_header.company_code,
            purch_order_org_code = rcd_bds_sto_po_header.purch_order_org_code,
            purch_order_grp_code = rcd_bds_sto_po_header.purch_order_grp_code,
            customer_code = rcd_bds_sto_po_header.customer_code,
            upd_datime = rcd_bds_sto_po_header.upd_datime
        where
            purch_order_doc_num=rcd_bds_sto_po_header.purch_order_doc_num;   

        delete from bds_sto_po_detail where purch_order_doc_num=rcd_bds_sto_po_header.purch_order_doc_num;
         
    end;  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;

  procedure process_record_det(par_record in varchar2) is
    
  /*-------------*/
  /* Begin block */
  /*-------------*/    
  begin

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('DET', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/       
    rcd_bds_sto_po_detail.purch_order_doc_num := lics_inbound_utility.get_variable('PURCH_ORDER_DOC_NUM');
    rcd_bds_sto_po_detail.purch_order_doc_line_num := lics_inbound_utility.get_variable('PURCH_ORDER_DOC_LINE_NUM');
    rcd_bds_sto_po_detail.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
    rcd_bds_sto_po_detail.delivery_date := lics_inbound_utility.get_date('DELIVERY_DATE','yyyymmdd');
    rcd_bds_sto_po_detail.qty := lics_inbound_utility.get_number('QTY',null);
    rcd_bds_sto_po_detail.uom_code := lics_inbound_utility.get_variable('UOM_CODE');
    rcd_bds_sto_po_detail.item_value_net := lics_inbound_utility.get_number('ITEM_VALUE_NET',null);
    rcd_bds_sto_po_detail.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_bds_sto_po_detail.storage_locn_code := lics_inbound_utility.get_variable('STORAGE_LOCN_CODE');
    rcd_bds_sto_po_detail.action_code := lics_inbound_utility.get_variable('ACTION_CODE');
    rcd_bds_sto_po_detail.dlvry_comp := lics_inbound_utility.get_variable('DLVRY_COMP');
    rcd_bds_sto_po_detail.over_del_tolrnce := lics_inbound_utility.get_variable('OVER_DEL_TOLRNCE');
    rcd_bds_sto_po_detail.stock_type := lics_inbound_utility.get_variable('STOCK_TYPE');
    
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
    if ( rcd_bds_sto_po_header.purch_order_doc_num is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PURCH_ORDER_DOC_NUM');
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

    insert into bds_sto_po_detail
    (
        purch_order_doc_num,
        purch_order_doc_line_num,
        sap_material_code,
        delivery_date,
        qty,
        uom_code,
        item_value_net,
        plant_code,
        storage_locn_code,
        action_code,
        dlvry_comp,
        over_del_tolrnce,
        stock_type     
    )
    values
    (
        rcd_bds_sto_po_detail.purch_order_doc_num,
        rcd_bds_sto_po_detail.purch_order_doc_line_num,
        rcd_bds_sto_po_detail.sap_material_code,
        rcd_bds_sto_po_detail.delivery_date,
        rcd_bds_sto_po_detail.qty,
        rcd_bds_sto_po_detail.uom_code,
        rcd_bds_sto_po_detail.item_value_net,
        rcd_bds_sto_po_detail.plant_code,
        rcd_bds_sto_po_detail.storage_locn_code,
        rcd_bds_sto_po_detail.action_code,
        rcd_bds_sto_po_detail.dlvry_comp,
        rcd_bds_sto_po_detail.over_del_tolrnce,
        rcd_bds_sto_po_detail.stock_type      
    );  
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;
        
end ladpdb17_loader;
/

GRANT EXECUTE ON BDS_APP.LADPDB17_LOADER TO LICS_APP
/
