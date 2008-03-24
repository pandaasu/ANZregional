/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_prodctn_resrc_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound reference data loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  19-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.plant_prodctn_resrc_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_prodctn_resrc_loader; 
/

create or replace package body bds_app.plant_prodctn_resrc_loader as

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
  
  rcd_hdr bds_prodctn_resrc_en%rowtype;
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
    lics_inbound_utility.set_definition('HDR','ID', 3);  
    lics_inbound_utility.set_definition('HDR','RESRC_ID', 8);  
    lics_inbound_utility.set_definition('HDR','RESRC_CODE', 8);  
    lics_inbound_utility.set_definition('HDR','RESRC_TEXT', 40);  
    lics_inbound_utility.set_definition('HDR','RESRC_PLANT_CODE', 4); 
    
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
    rcd_hdr.resrc_id := lics_inbound_utility.get_variable('RESRC_ID');
    rcd_hdr.resrc_code := lics_inbound_utility.get_variable('RESRC_CODE');
    rcd_hdr.resrc_text := lics_inbound_utility.get_variable('RESRC_TEXT');
    rcd_hdr.resrc_plant_code := lics_inbound_utility.get_variable('RESRC_PLANT_CODE');
    
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
    if ( rcd_hdr.resrc_id is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - PDR.RESRC_ID');
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
    update bds_prodctn_resrc_en
    set resrc_id = rcd_hdr.resrc_id,
      resrc_code = rcd_hdr.resrc_code,
      resrc_text = rcd_hdr.resrc_text,
      resrc_plant_code = rcd_hdr.resrc_plant_code
    where resrc_id = rcd_hdr.resrc_id;
    
    if ( sql%notfound ) then    
      insert into bds_prodctn_resrc_en
      (
        resrc_id, 
        resrc_code,
        resrc_text,        
        resrc_plant_code
      )
      values 
      (
        rcd_hdr.resrc_id, 
        rcd_hdr.resrc_code,
        rcd_hdr.resrc_text,        
        rcd_hdr.resrc_plant_code
      );
    end if;  
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
    
end plant_prodctn_resrc_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_prodctn_resrc_loader to appsupport;
grant execute on bds_app.plant_prodctn_resrc_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_prodctn_resrc_loader for bds_app.plant_prodctn_resrc_loader;