/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS04_LOADER as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS04_LOADER
    Owner   : PTS_APP
    Author  : Peter Tylee
    
    Description
    -----------
    STEPTS01 interface loader - uploads OCR data to PTS (Product Testing)
                                for pet survey data.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2014/11   Peter Tylee    Created.

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end STEPTS04_LOADER;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS04_LOADER as

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
      
      lics_inbound_utility.set_csv_definition('LAST_NAME',1);
      lics_inbound_utility.set_csv_definition('HOU_CODE',2);
      lics_inbound_utility.set_csv_definition('PET_CODE',3);
      lics_inbound_utility.set_csv_definition('PET_TYPE',4);
      lics_inbound_utility.set_csv_definition('PET_NAME',5);
      lics_inbound_utility.set_csv_definition('BIRTH_YEAR',6);
      
      for rcd_column in (
        select    tab_code,
                  fld_code,
                  column_index
        from      pts.pts_inbound_config
        where     config_type = '*PET'
        order by  column_index asc
      ) loop
        lics_inbound_utility.set_csv_definition(rcd_column.tab_code||'_'||to_char(rcd_column.fld_code)||'_'||to_char(rcd_column.column_index),rcd_column.column_index);
      end loop;
      
      /*-*/
      /* Remove any previous records from the pet inbound table
      /*-*/
      delete from pts.pts_inbound_pet;
      delete from pts.pts_inbound_pet_cla;
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
      if upper(substr(par_record,1,7)) <> 'HH_NAME' then      
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
         pts_ocr.data_import_pet;
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

    var_hou_code      integer;
    var_pet_code      integer;
    var_pet_type      integer;
    var_last_name     varchar2(120 char);
    var_is_new        integer := 0;

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

      var_last_name := lics_inbound_utility.get_variable('LAST_NAME');
      var_hou_code := lics_inbound_utility.get_number('HOU_CODE',null);
      var_pet_code := lics_inbound_utility.get_number('PET_CODE',null);
      
      -- If there was no household code provided, it needs to be retrieved
      -- from a recently created household via the last name
      if var_hou_code is null then
        select  hde_hou_code
        into    var_hou_code
        from    pts_hou_definition
        where   upper(hde_con_surname) = upper(var_last_name)
                  and hde_crt_date > sysdate - 1;
      end if;
      
      -- If there is no pet code provided, it is a new pet
      if var_pet_code is null then
        select  pts_pet_sequence.nextval
        into    var_pet_code
        from    dual;
        
        select  1
        into    var_is_new
        from    dual;
      end if;
      
      -- Retreive the pet type code
      select  pty_pet_type
      into    var_pet_type
      from    pts_pet_type
      where   upper(pty_typ_text) = upper(lics_inbound_utility.get_variable('PET_TYPE'));

      -- Merge into the pts_inbound_pet table (for later import into the pet definition records)
      merge into pts.pts_inbound_pet a
      using (
        select  var_hou_code as hou_code,
                var_pet_code as pet_code,
                lics_inbound_utility.get_variable('PET_NAME') as pet_name,
                lics_inbound_utility.get_number('BIRTH_YEAR',null) as birth_year,
                var_pet_type as pet_type
        from    dual
      ) b on (
        a.pet_code = b.pet_code
      )
      when matched then
        update
        set     a.pet_name = b.pet_name,
                a.pet_type = b.pet_type,
                a.birth_year = b.birth_year
      when not matched then
        insert
        (
          hou_code,
          pet_code,
          pet_name,
          pet_type,
          birth_year
        )
        values
        (
          b.hou_code,
          b.pet_code,
          b.pet_name,
          b.pet_type,
          b.birth_year
        );
        
      -- For every classification column, merge into the pts_inbound_pet_cla table
      -- for later import into the pts_pet_classification table
      for rcd_column in (
        select    tab_code,
                  fld_code,
                  column_index
        from      pts.pts_inbound_config
        where     config_type = '*PET'
        order by  column_index asc
      ) loop
      
        merge into pts.pts_inbound_pet_cla a
        using (
          select  var_pet_code as pet_code,
                  lics_inbound_utility.get_number(rcd_column.tab_code||'_'||to_char(rcd_column.fld_code)||'_'||to_char(rcd_column.column_index),null) as val_code
          from    dual
        ) b on (
          a.pet_code = b.pet_code
          and a.tab_code = rcd_column.tab_code
          and a.fld_code = rcd_column.fld_code
          and a.val_code = b.val_code
        )
        when not matched then
          insert
          (
            pet_code,
            tab_code,
            fld_code,
            val_code
          )
          values
          (
            b.pet_code,
            rcd_column.tab_code,
            rcd_column.fld_code,
            b.val_code
          )
          where b.val_code is not null
                and b.val_code <> -1;
        
      end loop;
      
      -- And a default classification for new households
      if var_is_new = 1 then
        insert into pts.pts_inbound_pet_cla (
          pet_code,
          tab_code,
          fld_code,
          val_code
        )
        values
        (
          var_pet_code,
          '*PET_CLA',
          26, --Pet environment
          1 --Household
        );
      end if;
        
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

end STEPTS04_LOADER;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on pts_app.stepts04_loader to public;
