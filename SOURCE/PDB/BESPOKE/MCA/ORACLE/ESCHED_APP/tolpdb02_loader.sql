create or replace package esched_app.tolpdb02_loader as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Electronic Schedule
  Package : tolpdb02_loader
  Owner   : esched_app
  Author  : Trevor Keon

  Description 
  ----------- 
  Electronic Schedule - Inbound DCO Factory Transfers Interface

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  20-Nov-2008  Trevor Keon      Created 
  21-Apr-2009  Trevor Keon      Removed primary key validation
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end tolpdb02_loader; 
/

create or replace package body esched_app.tolpdb02_loader as

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
    
  rcd_hdr tolas_factryxfer%rowtype;

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
    lics_inbound_utility.set_definition('HDR','TRANSMIT_DATE',8);
    lics_inbound_utility.set_definition('HDR','TRANSMIT_TIME',6);
    lics_inbound_utility.set_definition('HDR','CNN_NO',16);
    lics_inbound_utility.set_definition('HDR','DOC_TEXT',25);
    lics_inbound_utility.set_definition('HDR','WAREHOUSE_REF',16);
    lics_inbound_utility.set_definition('HDR','EXTERNAL_ID',16);
    
    /*-*/
    lics_inbound_utility.set_definition('DET','ID',3);
    lics_inbound_utility.set_definition('DET','PLANT_1',4);
    lics_inbound_utility.set_definition('DET','SLOC_1',4);
    lics_inbound_utility.set_definition('DET','PLANT_2',4);
    lics_inbound_utility.set_definition('DET','SLOC_2',4);
    lics_inbound_utility.set_definition('DET','MATERIAL',8);
    lics_inbound_utility.set_definition('DET','MVMT_CODE',4);
    lics_inbound_utility.set_definition('DET','NEG_SIGN',1);
    lics_inbound_utility.set_definition('DET','QUANTITY',13);
    lics_inbound_utility.set_definition('DET','UOM',3);
    lics_inbound_utility.set_definition('DET','ISS_STK_STATUS',1);
    lics_inbound_utility.set_definition('DET','REC_STK_STATUS',1);
    lics_inbound_utility.set_definition('DET','BATCH_CODE',10);
    lics_inbound_utility.set_definition('DET','MVMT_REASON',8);
    lics_inbound_utility.set_definition('DET','STOCK_IND',1);
    lics_inbound_utility.set_definition('DET','VENDOR',8);
    lics_inbound_utility.set_definition('DET','COST_CENTRE',8);
    lics_inbound_utility.set_definition('DET','BEST_BEFORE_DATE',8);
    lics_inbound_utility.set_definition('DET','ISS_DISPOSITION',4);
    lics_inbound_utility.set_definition('DET','REC_DISPOSITION',4);
    lics_inbound_utility.set_definition('DET','COST_CENTRE_DETERM',8);
    lics_inbound_utility.set_definition('DET','PURCH_ORD_NUM',10);
    lics_inbound_utility.set_definition('DET','PURCH_ORD_LINE',5);
    lics_inbound_utility.set_definition('DET','GL_ACCOUNT',6);
    
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
    /* Local cursors 
    /*-*/
    cursor csr_tolas_factryxfer is
    select t01.transmit_date as transmit_date,
      t01.transmit_time as transmit_time
    from tolas_factryxfer t01
    where t01.warehouse_ref = rcd_hdr.warehouse_ref
    group by t01.transmit_date,
      t01.transmit_time;
      
    rcd_tolas_factryxfer csr_tolas_factryxfer%rowtype;
    
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
    rcd_hdr.transmit_date := lics_inbound_utility.get_variable('TRANSMIT_DATE');
    rcd_hdr.transmit_time := lics_inbound_utility.get_variable('TRANSMIT_TIME');
    rcd_hdr.cnn_no := lics_inbound_utility.get_variable('CNN_NO');
    rcd_hdr.doc_text := lics_inbound_utility.get_variable('DOC_TEXT');
    rcd_hdr.warehouse_ref := lics_inbound_utility.get_variable('WAREHOUSE_REF');
    rcd_hdr.external_id := lics_inbound_utility.get_variable('EXTERNAL_ID');
        
    /*-*/
    /* Validate message sequence  
    /*-*/
    open csr_tolas_factryxfer;
    fetch csr_tolas_factryxfer into rcd_tolas_factryxfer;
    
    if ( csr_tolas_factryxfer%found ) then      
      if ( (rcd_hdr.transmit_date > rcd_tolas_factryxfer.transmit_date) 
          or (rcd_hdr.transmit_date = rcd_tolas_factryxfer.transmit_date and rcd_hdr.transmit_time > rcd_tolas_factryxfer.transmit_time) ) then
        delete from tolas_factryxfer where warehouse_ref = rcd_hdr.warehouse_ref;
      else
        var_trn_ignore := true;
      end if;
    end if;   
     
    close csr_tolas_factryxfer;
    
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
    rcd_hdr.plant_1 := lics_inbound_utility.get_variable('PLANT_1');
    rcd_hdr.sloc_1 := lics_inbound_utility.get_variable('SLOC_1');
    rcd_hdr.plant_2 := lics_inbound_utility.get_variable('PLANT_2');
    rcd_hdr.sloc_2 := lics_inbound_utility.get_variable('SLOC_2');
    rcd_hdr.material := lics_inbound_utility.get_variable('MATERIAL');
    rcd_hdr.mvmt_code := lics_inbound_utility.get_variable('MVMT_CODE');
    rcd_hdr.neg_sign := lics_inbound_utility.get_variable('NEG_SIGN');
    rcd_hdr.quantity := lics_inbound_utility.get_variable('QUANTITY');
    rcd_hdr.uom := lics_inbound_utility.get_variable('UOM');
    rcd_hdr.iss_stk_status := lics_inbound_utility.get_variable('ISS_STK_STATUS');
    rcd_hdr.rec_stk_status := lics_inbound_utility.get_variable('REC_STK_STATUS');
    rcd_hdr.batch_code := lics_inbound_utility.get_variable('BATCH_CODE');
    rcd_hdr.mvmt_reason := lics_inbound_utility.get_variable('MVMT_REASON');
    rcd_hdr.stock_ind := lics_inbound_utility.get_variable('STOCK_IND');
    rcd_hdr.vendor := lics_inbound_utility.get_variable('VENDOR');
    rcd_hdr.cost_centre := lics_inbound_utility.get_variable('COST_CENTRE');
    rcd_hdr.best_before_date := lics_inbound_utility.get_variable('BEST_BEFORE_DATE');
    rcd_hdr.iss_disposition := lics_inbound_utility.get_variable('ISS_DISPOSITION');
    rcd_hdr.rec_disposition := lics_inbound_utility.get_variable('REC_DISPOSITION');
    rcd_hdr.cost_centre_determ := lics_inbound_utility.get_variable('COST_CENTRE_DETERM');
    rcd_hdr.purch_ord_num := lics_inbound_utility.get_variable('PURCH_ORD_NUM');
    rcd_hdr.purch_ord_line := lics_inbound_utility.get_variable('PURCH_ORD_LINE');
    rcd_hdr.gl_account := lics_inbound_utility.get_variable('GL_ACCOUNT');

    /*-*/
    /* Retrieve exceptions raised 
    /*-*/
    if ( lics_inbound_utility.has_errors = true ) then
      var_trn_error := true;
    end if;
             
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into tolas_factryxfer
    (
      transmit_date,
      transmit_time,
      cnn_no,
      doc_text,
      warehouse_ref,
      external_id,
      plant_1,
      sloc_1,
      plant_2,
      sloc_2,
      material,
      mvmt_code,
      neg_sign,
      quantity,
      uom,
      iss_stk_status,
      rec_stk_status,
      batch_code,
      mvmt_reason,
      stock_ind,
      vendor,
      cost_centre,
      best_before_date,
      iss_disposition,
      rec_disposition,
      cost_centre_determ,
      purch_ord_num,
      purch_ord_line,
      gl_account
    )
    values 
    (
      rcd_hdr.transmit_date,
      rcd_hdr.transmit_time,
      rcd_hdr.cnn_no,
      rcd_hdr.doc_text,
      rcd_hdr.warehouse_ref,
      rcd_hdr.external_id,
      rcd_hdr.plant_1,
      rcd_hdr.sloc_1,
      rcd_hdr.plant_2,
      rcd_hdr.sloc_2,
      rcd_hdr.material,
      rcd_hdr.mvmt_code,
      rcd_hdr.neg_sign,
      rcd_hdr.quantity,
      rcd_hdr.uom,
      rcd_hdr.iss_stk_status,
      rcd_hdr.rec_stk_status,
      rcd_hdr.batch_code,
      rcd_hdr.mvmt_reason,
      rcd_hdr.stock_ind,
      rcd_hdr.vendor,
      rcd_hdr.cost_centre,
      rcd_hdr.best_before_date,
      rcd_hdr.iss_disposition,
      rcd_hdr.rec_disposition,
      rcd_hdr.cost_centre_determ,
      rcd_hdr.purch_ord_num,
      rcd_hdr.purch_ord_line,
      rcd_hdr.gl_account
    );

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_det;
  
end tolpdb02_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on esched_app.tolpdb02_loader to appsupport;
grant execute on esched_app.tolpdb02_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym tolpdb02_loader for esched_app.tolpdb02_loader;