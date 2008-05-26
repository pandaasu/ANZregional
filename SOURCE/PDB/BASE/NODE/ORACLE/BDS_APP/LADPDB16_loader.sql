/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb16_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound charistic value data loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  22-May-2008  Trevor Keon      Created 
*******************************************************************************/

/* Using bds_charistic_value_en_ics table for testing only.  Replace for other sites */ 

create or replace package bds_app.ladpdb16_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb16_loader; 
/

create or replace package body bds_app.ladpdb16_loader as

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
  
  rcd_hdr bds_charistic_value_en_ics%rowtype;

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
    lics_inbound_utility.set_definition('HDR','SAP_CHARISTIC_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_CHARISTIC_VALUE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_CHARISTIC_VALUE_DESC', 30);
      
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

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/
    
    rcd_hdr.sap_charistic_code := lics_inbound_utility.get_variable('SAP_CHARISTIC_CODE');
    rcd_hdr.sap_charistic_value_code := lics_inbound_utility.get_variable('SAP_CHARISTIC_VALUE_CODE');
    rcd_hdr.sap_charistic_value_desc := lics_inbound_utility.get_variable('SAP_CHARISTIC_VALUE_DESC');
    
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
    if ( rcd_hdr.sap_charistic_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_CHARISTIC_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.sap_charistic_value_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_CHARISTIC_VALUE_CODE');
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
    update bds_charistic_value_en_ics
    set sap_charistic_code = rcd_hdr.sap_charistic_code, 
      sap_charistic_value_code = rcd_hdr.sap_charistic_value_code, 
      sap_charistic_value_desc = rcd_hdr.sap_charistic_value_desc
    where sap_charistic_code = rcd_hdr.sap_charistic_code 
      and sap_charistic_value_code = rcd_hdr.sap_charistic_value_code;
    
    if ( sql%notfound ) then    
      insert into bds_charistic_value_en_ics
      (
        sap_charistic_code, 
        sap_charistic_value_code, 
        sap_charistic_value_desc
      )
      values 
      (
        rcd_hdr.sap_charistic_code, 
        rcd_hdr.sap_charistic_value_code, 
        rcd_hdr.sap_charistic_value_desc
      );
    end if;
    
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
  
end ladpdb16_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb16_loader to appsupport;
grant execute on bds_app.ladpdb16_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb16_loader for bds_app.ladpdb16_loader;