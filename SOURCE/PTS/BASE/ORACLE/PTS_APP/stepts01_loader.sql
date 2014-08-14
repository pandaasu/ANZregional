/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS01_LOADER as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS01_LOADER
    Owner   : PTS_APP
    Author  : Peter Tylee
    
    Description
    -----------
    STEPTS01 interface loader - uploads OCR data to PTS (Product Testing)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/11   Peter Tylee    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end STEPTS01_LOADER;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS01_LOADER as

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
      
      lics_inbound_utility.set_csv_definition('TRA_TES_CODE',1);
      lics_inbound_utility.set_csv_definition('TRA_PET_CODE',2);
      lics_inbound_utility.set_csv_definition('TRA_DAY_CODE',3);
      lics_inbound_utility.set_csv_definition('TRA_MKT_CODE',4);
      lics_inbound_utility.set_csv_definition('TRA_Q1',5);
      lics_inbound_utility.set_csv_definition('TRA_Q2',6);
      lics_inbound_utility.set_csv_definition('TRA_Q3',7);
      lics_inbound_utility.set_csv_definition('TRA_Q4',8);
      lics_inbound_utility.set_csv_definition('TRA_Q5',9);
      lics_inbound_utility.set_csv_definition('TRA_Q6',10);
      lics_inbound_utility.set_csv_definition('TRA_Q7',11);
      lics_inbound_utility.set_csv_definition('TRA_Q8',12);
      lics_inbound_utility.set_csv_definition('TRA_Q9',13);
      lics_inbound_utility.set_csv_definition('TRA_Q10',14);
      lics_inbound_utility.set_csv_definition('TRA_Q11',15);
      lics_inbound_utility.set_csv_definition('TRA_Q12',16);
      lics_inbound_utility.set_csv_definition('TRA_Q13',17);
      lics_inbound_utility.set_csv_definition('TRA_Q14',18);
      lics_inbound_utility.set_csv_definition('TRA_Q15',19);
      
      /*-*/
      /* Remove any previous records from the temp table
      /*-*/
      delete from pts_tes_temp;
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
         pts_ocr.data_import;
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

      merge into pts_tes_temp t
      using (
        select  lics_inbound_utility.get_number('TRA_TES_CODE',null) as tra_tes_code,
                lics_inbound_utility.get_number('TRA_PET_CODE',null) as tra_pet_code,
                lics_inbound_utility.get_number('TRA_DAY_CODE',null) as tra_day_code,
                lics_inbound_utility.get_variable('TRA_MKT_CODE') as tra_mkt_code,
                lics_inbound_utility.get_number('TRA_Q1',null) as tra_q1,
                lics_inbound_utility.get_number('TRA_Q2',null) as tra_q2,
                lics_inbound_utility.get_number('TRA_Q3',null) as tra_q3,
                lics_inbound_utility.get_number('TRA_Q4',null) as tra_q4,
                lics_inbound_utility.get_number('TRA_Q5',null) as tra_q5,
                lics_inbound_utility.get_number('TRA_Q6',null) as tra_q6,
                lics_inbound_utility.get_number('TRA_Q7',null) as tra_q7,
                lics_inbound_utility.get_number('TRA_Q8',null) as tra_q8,
                lics_inbound_utility.get_number('TRA_Q9',null) as tra_q9,
                lics_inbound_utility.get_number('TRA_Q10',null) as tra_q10,
                lics_inbound_utility.get_number('TRA_Q11',null) as tra_q11,
                lics_inbound_utility.get_number('TRA_Q12',null) as tra_q12,
                lics_inbound_utility.get_number('TRA_Q13',null) as tra_q13,
                lics_inbound_utility.get_number('TRA_Q14',null) as tra_q14,
                lics_inbound_utility.get_number('TRA_Q15',null) as tra_q15
                
        from    dual
      ) x on (
        t.tra_tes_code = x.tra_tes_code
        and t.tra_pet_code = x.tra_pet_code
        and t.tra_day_code = x.tra_day_code
        and t.tra_mkt_code = x.tra_mkt_code
      )
      when matched then
        update
        set     t.tra_q1 = x.tra_q1,
                t.tra_q2 = x.tra_q2,
                t.tra_q3 = x.tra_q3,
                t.tra_q4 = x.tra_q4,
                t.tra_q5 = x.tra_q5,
                t.tra_q6 = x.tra_q6,
                t.tra_q7 = x.tra_q7,
                t.tra_q8 = x.tra_q8,
                t.tra_q9 = x.tra_q9,
                t.tra_q10 = x.tra_q10,
                t.tra_q11 = x.tra_q11,
                t.tra_q12 = x.tra_q12,
                t.tra_q13 = x.tra_q13,
                t.tra_q14 = x.tra_q14,
                t.tra_q15 = x.tra_q15,
                t.tra_valid = 1
        where   nvl(x.tra_q1,0) <> nvl(t.tra_q1,0)
                or nvl(x.tra_q2,0) <> nvl(t.tra_q2,0)
                or nvl(x.tra_q3,0) <> nvl(t.tra_q3,0)
                or nvl(x.tra_q4,0) <> nvl(t.tra_q4,0)
                or nvl(x.tra_q5,0) <> nvl(t.tra_q5,0)
                or nvl(x.tra_q6,0) <> nvl(t.tra_q6,0)
                or nvl(x.tra_q7,0) <> nvl(t.tra_q7,0)
                or nvl(x.tra_q8,0) <> nvl(t.tra_q8,0)
                or nvl(x.tra_q9,0) <> nvl(t.tra_q9,0)
                or nvl(x.tra_q10,0) <> nvl(t.tra_q10,0)
                or nvl(x.tra_q11,0) <> nvl(t.tra_q11,0)
                or nvl(x.tra_q12,0) <> nvl(t.tra_q12,0)
                or nvl(x.tra_q13,0) <> nvl(t.tra_q13,0)
                or nvl(x.tra_q14,0) <> nvl(t.tra_q14,0)
                or nvl(x.tra_q15,0) <> nvl(t.tra_q15,0)
                or t.tra_valid <> 1
      when not matched then
        insert
        (
          tra_tes_code, 
          tra_pet_code,
          tra_day_code,
          tra_mkt_code,
          tra_q1,
          tra_q2,
          tra_q3,
          tra_q4,
          tra_q5,
          tra_q6,
          tra_q7,
          tra_q8,
          tra_q9,
          tra_q10,
          tra_q11,
          tra_q12,
          tra_q13,
          tra_q14,
          tra_q15
        )
        values
        (
          x.tra_tes_code, 
          x.tra_pet_code,
          x.tra_day_code,
          x.tra_mkt_code,
          x.tra_q1,
          x.tra_q2,
          x.tra_q3,
          x.tra_q4,
          x.tra_q5,
          x.tra_q6,
          x.tra_q7,
          x.tra_q8,
          x.tra_q9,
          x.tra_q10,
          x.tra_q11,
          x.tra_q12,
          x.tra_q13,
          x.tra_q14,
          x.tra_q15
        );
      
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

end STEPTS01_LOADER;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym stepts01_loader for pts_app.stepts01_loader;
grant execute on pts_app.stepts01_loader to public;
