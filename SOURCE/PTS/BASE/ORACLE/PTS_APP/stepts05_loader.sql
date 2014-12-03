/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS05_LOADER as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS05_LOADER
    Owner   : PTS_APP
    Author  : Peter Tylee
    
    Description
    -----------
    STEPTS01 interface loader - uploads OCR data to PTS (Product Testing)
                                for owner survey tests

    YYYY/MM   Author         Description
    -------   ------         -----------
    2014/12   Peter Tylee    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end STEPTS05_LOADER;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS05_LOADER as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_up_error boolean;

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
      var_trn_error := false;
      var_up_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      
      lics_inbound_utility.set_csv_definition('TES_CODE',1);
      lics_inbound_utility.set_csv_definition('DAY_CODE',2);
      lics_inbound_utility.set_csv_definition('PAN_CODE',3);
      lics_inbound_utility.set_csv_definition('MKT_CODE',4);
      
      for que_sequence in 1 .. 100
      loop
        lics_inbound_utility.set_csv_definition('Q_'||to_char(que_sequence),que_sequence + 4);
      end loop;

      /*-*/
      /* Remove any previous records from the temp table
      /*-*/
      delete from pts.pts_inbound_test;
      commit;
      
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
         var_up_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      if upper(substr(par_record,1,4)) <> 'TEST' then      
        process_record(par_record);
      end if;

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
         var_up_error := true;

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
      /* Complete the transaction
      /*-*/
      complete_transaction;
      
      /*-*/
      /* Import the data from temp table to response table
      /*-*/
      if var_up_error = false then
         pts_ocr.data_import_owner;
         commit;
      end if;
      
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore when required
      /*-*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Commit/rollback the transaction as required 
      /*-*/
      if ( var_trn_error = true ) then
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

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Add the exception to the interface
         /*-*/
         lics_inbound_utility.add_exception(var_exception);
         
         var_up_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record(par_record in varchar2) is

    var_tes_code integer;
    var_pan_code integer;
    var_day_code integer;
    var_mkt_code varchar2(3 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------------------------------*/
      /* COMPLETE - Complete the previous transaction */
      /*----------------------------------------------*/

      /*-*/
      /* Complete the previous transaction and reset
      /*-*/
      complete_transaction;
      var_trn_error := false;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_csv_record(par_record, ',');

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      var_tes_code := lics_inbound_utility.get_number('TES_CODE',null);
      var_day_code := lics_inbound_utility.get_number('DAY_CODE',null);
      var_pan_code := lics_inbound_utility.get_number('PAN_CODE',null);
      var_mkt_code := lics_inbound_utility.get_variable('MKT_CODE');

      for rcd_column in (
        select    tqu_dsp_seqn,
                  tqu_que_code as que_code
        from      pts.pts_tes_question
        where     tqu_tes_code = var_tes_code
                  and tqu_day_code = var_day_code
        order by  tqu_dsp_seqn asc
      ) loop
      
        merge into pts.pts_inbound_test a
        using (
          select  var_tes_code as tes_code,
                  var_pan_code as pan_code,
                  var_day_code as day_code,
                  var_mkt_code as mkt_code,
                  lics_inbound_utility.get_number('Q_'||to_char(rcd_column.tqu_dsp_seqn),null) as res_code
          from    dual
        ) b on (
          a.tes_code = b.tes_code
          and a.pan_code = b.pan_code
          and a.day_code = b.day_code
          and a.mkt_code = b.mkt_code
          and a.que_code = rcd_column.que_code
        )
        when not matched then
          insert
          (
            tes_code,
            pan_code,
            day_code,
            mkt_code,
            que_code,
            res_code
          )
          values
          (
            b.tes_code,
            b.pan_code,
            b.day_code,
            b.mkt_code,
            rcd_column.que_code,
            b.res_code
          )
          where b.res_code is not null
                and b.res_code <> -1;
        
      end loop;
      
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record;

end STEPTS05_LOADER;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on pts_app.stepts05_loader to public;
