CREATE OR REPLACE package DF_APP.PPLAN_INV_PROCESS as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : DF_APP.PPLAN_INV_PROCESS
    Owner   : df_app
    Author  : David Zhang

    Description
    -----------
    Integrated Planning Demand Financials - PPLAN Projected Finished Goods Onhand inventory load and process

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/1    David Zhang        Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end pplan_inv_process;
/

CREATE OR REPLACE package body DF_APP.PPLAN_INV_PROCESS as

   /*-*/
   /* Private exceptions 
   /*-*/application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/

   con_delimiter constant varchar2(32)  := ',';

   /*-*/
   /* Private definitions 
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
 
   FUNCTION lookupFcstID(p_moe_code IN VARCHAR2) RETURN NUMBER;
   
   /* Variables  */
   var_fcst_id  NUMBER(20);
   var_moe_code VARCHAR2(20);
   
   var_result_msg varchar2(3900);
   
   var_line_no  NUMBER;
   rec_inv_fcst_data  inv_fcst_data%ROWTYPE;
  
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
      lics_inbound_utility.set_csv_definition('MOE_CODE',1);
      lics_inbound_utility.set_csv_definition('MARS_WEEK',2);
      lics_inbound_utility.set_csv_definition('PLANT_CODE',3);
      lics_inbound_utility.set_csv_definition('TDU',4);
      lics_inbound_utility.set_csv_definition('QTY_IN_BASE_UOM',5);
      
      var_line_no := 0;
     
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
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
       var_strlen NUMBER;   
       var_len   NUMBER;
     
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

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);
      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
     
      /*-*/
      /* Retrieve field values
      /*-*/
      var_moe_code                          := lics_inbound_utility.get_variable('MOE_CODE');
      rec_inv_fcst_data.mars_week           := lics_inbound_utility.get_variable('MARS_WEEK');
      rec_inv_fcst_data.plant_code          := lics_inbound_utility.get_variable('PLANT_CODE');
      rec_inv_fcst_data.tdu                 := lics_inbound_utility.get_variable('TDU');
      rec_inv_fcst_data.tdu                 := LTRIM(rec_inv_fcst_data.tdu, '0'); /* Remove leading 0s */
      rec_inv_fcst_data.qty_in_base_uom     := lics_inbound_utility.get_variable('QTY_IN_BASE_UOM');
      
      /* Lookup most recent Forecast ID */  
      var_fcst_id := lookupFcstID (var_moe_code) ;
      IF var_fcst_id = -1 THEN
         raise_application_error(-20000, 'Error in getting Forecast ID. for MOE ('||var_moe_code||').');
      END IF;
      
      IF var_line_no = 0 THEN
        DELETE FROM inv_fcst_data
         WHERE fcst_id = var_fcst_id;
      END IF;
                 
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      var_line_no := var_line_no + 1;
      
      /* Record projeced finished goods onhand inventory */
      INSERT INTO inv_fcst_data  
            (FCST_ID,       MARS_WEEK, 
             PLANT_CODE,    TDU, 
             QTY_IN_BASE_UOM)
      VALUES 
            (var_fcst_id,                       rec_inv_fcst_data.mars_week,
             rec_inv_fcst_data.plant_code,      rec_inv_fcst_data.tdu,
             rec_inv_fcst_data.qty_in_base_uom);
      
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
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when commited
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
      COMMIT;      
      
      /* Now that data finished loading, execute trigger */
      eventit.trigger_event('DEMAND_FINANCIALS','IF_FCST_COMPLETE', var_fcst_id, 'MOE:'||var_moe_code);
      
    end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

    /* Look up the most current Fcst ID for given MOE within last 2 weeks (Fail if not found) */
    FUNCTION lookupFcstID(p_moe_code in varchar2)
    RETURN number
    IS
    v_number number;
    BEGIN
       SELECT NVL(MAX(fcst_id), -1)
         INTO v_number
         FROM fcst
        WHERE last_updated in 
              (SELECT MAX (last_updated) FROM fcst
                WHERE last_updated >=  TRUNC (SYSDATE, 'DAY') - 14
                  AND forecast_type = 'FCST'
                  AND moe_code = p_moe_code)
          AND moe_code = p_moe_code
          AND forecast_type = 'FCST';
   
       RETURN v_number; 
 
    EXCEPTION
    WHEN OTHERS THEN
      RETURN -1; 
    END;
    
   
END pplan_inv_process;


-- rights access
/

CREATE PUBLIC SYNONYM pplan_inv_process FOR DF_APP.PPLAN_INV_PROCESS;

GRANT EXECUTE ON pplan_inv_process TO appsupport;
GRANT EXECUTE ON pplan_inv_process TO lics_app;

