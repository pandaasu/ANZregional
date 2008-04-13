/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_material_bom_loader 
  Owner   : bds_app  
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound material BOM loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  08-Apr-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.plant_material_bom_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_material_bom_loader ; 
/

create or replace package body bds_app.plant_material_bom_loader as

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
    
  rcd_hdr bds_material_bom_hdr%rowtype;
  rcd_det bds_material_bom_det%rowtype;

  var_sap_bom rcd_hdr.sap_bom%type;
  var_sap_alt_bom rcd_hdr.sap_bom_alternative%type;

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
    lics_inbound_utility.set_definition('CTL','SAP_BOM', 8);
    lics_inbound_utility.set_definition('CTL','SAP_BOM_ALTERNATIVE', 2);
    lics_inbound_utility.set_definition('CTL','MSG_TIMESTAMP', 14);
    
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','BOM_PLANT',5);
    lics_inbound_utility.set_definition('HDR','BOM_USAGE',1);
    lics_inbound_utility.set_definition('HDR','BOM_EFF_DATE',14);
    lics_inbound_utility.set_definition('HDR','BOM_STATUS',1);
    lics_inbound_utility.set_definition('HDR','PARENT_MATERIAL_CODE',18);
    lics_inbound_utility.set_definition('HDR','PARENT_BASE_QTY',38);
    lics_inbound_utility.set_definition('HDR','PARENT_BASE_UOM',3);
    
    /*-*/
    lics_inbound_utility.set_definition('DET','ID',3);
    lics_inbound_utility.set_definition('DET','CHILD_ITEM_CATEGORY',1);
    lics_inbound_utility.set_definition('DET','CHILD_BASE_QTY',38);
    lics_inbound_utility.set_definition('DET','CHILD_BASE_UOM',3);
    
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
    cursor csr_bds_material_bom_hdr is
      select t01.sap_bom as sap_bom,
        t01.sap_bom_alternative as sap_bom_alternative,
        min(t01.msg_timestamp) as msg_timestamp
      from bds_material_bom_hdr t01
      where t01.sap_bom = rcd_hdr.sap_bom
        and t01.sap_bom_alternative = rcd_hdr.sap_bom_alternative 
      group by t01.sap_bom,t01.sap_bom_alternative;
      
    rcd_bds_material_bom_hdr csr_bds_material_bom_hdr%rowtype;
    
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
    rcd_hdr.sap_bom := lics_inbound_utility.get_variable('SAP_BOM');
    rcd_hdr.sap_bom_alternative := lics_inbound_utility.get_variable('SAP_BOM_ALTERNATIVE');
    rcd_hdr.msg_timestamp := lics_inbound_utility.get_date('MSG_TIMESTAMP','yyyymmddhh24miss');
    
    /*-*/
    /* Validate message sequence  
    /*-*/
    open csr_bds_material_bom_hdr;
    fetch csr_bds_material_bom_hdr into rcd_bds_material_bom_hdr;
    
    if ( csr_bds_material_bom_hdr%notfound ) then
      var_exists := false;
    end if;
    
    close csr_bds_material_bom_hdr;
    
    if ( var_exists = true ) then
      if ( rcd_hdr.msg_timestamp > rcd_bds_material_bom_hdr.msg_timestamp ) then
        delete from bds_material_bom_hdr where sap_bom = rcd_hdr.sap_bom and sap_bom_alternative = rcd_hdr.sap_bom_alternative;
        delete from bds_material_bom_det where sap_bom = rcd_hdr.sap_bom and sap_bom_alternative = rcd_hdr.sap_bom_alternative;
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
    rcd_hdr.bom_plant := lics_inbound_utility.get_variable('BOM_PLANT');
    rcd_hdr.bom_usage := lics_inbound_utility.get_variable('BOM_USAGE');
    rcd_hdr.bom_eff_date := lics_inbound_utility.get_variable('BOM_EFF_DATE');
    rcd_hdr.bom_status := lics_inbound_utility.get_number('BOM_STATUS', null);
    rcd_hdr.parent_material_code := lics_inbound_utility.get_variable('PARENT_MATERIAL_CODE');
    rcd_hdr.parent_base_qty := lics_inbound_utility.get_number('PARENT_BASE_QTY', null);
    rcd_hdr.parent_base_uom := lics_inbound_utility.get_variable('PARENT_BASE_UOM');

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
    if ( rcd_hdr.sap_bom is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_BOM');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.sap_bom_alternative is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_BOM_ALTERNATIVE');
      var_trn_error := true;
    end if;
             
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into bds_material_bom_hdr
    (
      sap_bom,
      sap_bom_alternative,
      bom_plant,
      bom_usage,
      bom_eff_date,
      bom_status,
      parent_material_code,
      parent_base_qty,
      parent_base_uom,
      msg_timestamp
    )
    values 
    (
      rcd_hdr.sap_bom,
      rcd_hdr.sap_bom_alternative,
      rcd_hdr.bom_plant,
      rcd_hdr.bom_usage,
      rcd_hdr.bom_eff_date,
      rcd_hdr.bom_status,
      rcd_hdr.parent_material_code,
      rcd_hdr.parent_base_qty,
      rcd_hdr.parent_base_uom,
      rcd_hdr.msg_timestamp
    );    

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
   
  /**************************************************/
  /* This procedure performs the record UOM routine */
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
    rcd_det.child_material_code := lics_inbound_utility.get_variable('CHILD_MATERIAL_CODE');
    rcd_det.child_item_category := lics_inbound_utility.get_variable('CHILD_ITEM_CATEGORY');
    rcd_det.child_base_qty := lics_inbound_utility.get_number('CHILD_BASE_QTY',null);
    rcd_det.child_base_uom := lics_inbound_utility.get_variable('CHILD_BASE_UOM');
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
    if ( rcd_det.child_material_code is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - DET.CHILD_MATERIAL_CODE');
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
    insert into bds_material_bom_det
    (
      sap_bom,
      sap_bom_alternative,
      child_material_code,
      child_item_category,
      child_base_qty,
      child_base_uom
    )
    values 
    (
      rcd_hdr.sap_bom,
      rcd_hdr.sap_bom_alternative,
      rcd_det.child_material_code,
      rcd_det.child_item_category,
      rcd_det.child_base_qty,
      rcd_det.child_base_uom
    );

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;
  
end plant_material_bom_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_material_bom_loader to appsupport;
grant execute on bds_app.plant_material_bom_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_material_bom_loader for bds_app.plant_material_bom_loader;