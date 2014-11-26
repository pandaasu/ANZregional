/******************/
/* Package Header */
/******************/
create or replace
PACKAGE         STEPTS03_LOADER as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : STEPTS03_LOADER
    Owner   : PTS_APP
    Author  : Peter Tylee
    
    Description
    -----------
    STEPTS01 interface loader - uploads OCR data to PTS (Product Testing)
                                for household survey data.

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

end STEPTS03_LOADER;
/

/****************/
/* Package Body */
/****************/
create or replace
PACKAGE BODY         STEPTS03_LOADER as

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
      
      lics_inbound_utility.set_csv_definition('HOU_CODE',1);
      lics_inbound_utility.set_csv_definition('TITLE',2);
      lics_inbound_utility.set_csv_definition('FIRST_NAME',3);
      lics_inbound_utility.set_csv_definition('LAST_NAME',4);
      lics_inbound_utility.set_csv_definition('STREET_NUMBER',5);
      lics_inbound_utility.set_csv_definition('STREET',6);
      lics_inbound_utility.set_csv_definition('CITY',7);
      lics_inbound_utility.set_csv_definition('POSTCODE',8);
      lics_inbound_utility.set_csv_definition('TEL_NUMBER',9);
      lics_inbound_utility.set_csv_definition('GEO_ZONE',10);
      
      for rcd_column in (
        select    tab_code,
                  fld_code,
                  column_index
        from      pts.pts_inbound_config
        where     config_type = '*HOU'
        order by  column_index asc
      ) loop
        lics_inbound_utility.set_csv_definition(rcd_column.tab_code||'_'||to_char(rcd_column.fld_code)||'_'||to_char(rcd_column.column_index),rcd_column.column_index);
      end loop;
      
      /*-*/
      /* Remove any previous records from the household inbound table
      /*-*/
      delete from pts.pts_inbound_hou;
      delete from pts.pts_inbound_hou_cla;
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
      if upper(substr(par_record,1,4)) <> 'HHNO' then      
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
         pts_ocr.data_import_hou;
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
    var_tel_areacode  varchar2(32 char);
    var_tel_number    varchar2(32 char);

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

      var_hou_code := lics_inbound_utility.get_number('HOU_CODE',null);
      
      -- If there is no household code provided, it is a new household
      if var_hou_code is null then
        select  pts_hou_sequence.nextval
        into    var_hou_code
        from    dual;
      end if;
      
      -- Telephone rules:
      -- 1) If it is 9 characters, all numeric, and doesn't start with a 0, prepend a 0 to it
      -- 2) If it starts with an areacode (02, 03, 07, 08), move that to the area-code variable
      -- 3) If the remainder is 8 characters, split with a space as 4, 4 (landline format)
      -- 4) If the remainder is 10 characters, split with a space as 4, 3, 3 (mobile format)
      var_tel_number := lics_inbound_utility.get_variable('TEL_NUMBER');

      if length(var_tel_number) = 9 and trim(translate(var_tel_number, '0123456789', ' ')) is null then
        var_tel_number := '0' || var_tel_number;
      end if;

      if substr(var_tel_number, 1, 2) in ('02', '03', '07', '08') then
        var_tel_areacode := substr(var_tel_number, 1, 2);
        var_tel_number := substr(var_tel_number, 3);
      end if;
      
      if length(var_tel_number) = 8 then
        -- Land line: format 4, 4
        var_tel_number := substr(var_tel_number, 1, 4) ||' '|| substr(var_tel_number, 5);
      elsif length(var_tel_number) = 10 then
        -- Mobile: format: 4, 3, 3
        var_tel_number := substr(var_tel_number, 1, 4) ||' '|| substr(var_tel_number, 5, 3) ||' '|| substr(var_tel_number, 8);
      end if;
      
      
      -- Merge into the pts_inbound_hou table (for later import into the household definition records)
      merge into pts.pts_inbound_hou a
      using (
        select  var_hou_code as hou_code,
                lics_inbound_utility.get_variable('TITLE') as title,
                lics_inbound_utility.get_variable('FIRST_NAME') as first_name,
                lics_inbound_utility.get_variable('LAST_NAME') as last_name,
                lics_inbound_utility.get_variable('STREET_NUMBER') as street_number,
                lics_inbound_utility.get_variable('STREET') as street,
                lics_inbound_utility.get_variable('CITY') as city,
                lics_inbound_utility.get_variable('POSTCODE') as postcode,
                lics_inbound_utility.get_number('GEO_ZONE',null) as geo_zone
        from    dual
      ) b on (
        a.hou_code = b.hou_code
      )
      when matched then
        update
        set     a.title = b.title,
                a.first_name = b.first_name,
                a.last_name = b.last_name,
                a.street_number = b.street_number,
                a.street = b.street,
                a.city = b.city,
                a.postcode = b.postcode,
                a.tel_areacode = var_tel_areacode,
                a.tel_number = var_tel_number,
                a.geo_zone = b.geo_zone
      when not matched then
        insert
        (
          hou_code,
          title,
          first_name,
          last_name,
          street_number,
          street,
          city,
          postcode,
          tel_areacode,
          tel_number,
          geo_zone
        )
        values
        (
          b.hou_code,
          b.title,
          b.first_name,
          b.last_name,
          b.street_number,
          b.street,
          b.city,
          b.postcode,
          var_tel_areacode,
          var_tel_number,
          b.geo_zone
        );
        
      -- For every classification column, merge into the pts_inbound_hou_cla table
      -- for later import into the pts_hou_classification table
      for rcd_column in (
        select    tab_code,
                  fld_code,
                  column_index
        from      pts.pts_inbound_config
        where     config_type = '*HOU'
        order by  column_index asc
      ) loop
      
        merge into pts.pts_inbound_hou_cla a
        using (
          select  var_hou_code as hou_code,
                  lics_inbound_utility.get_number(rcd_column.tab_code||'_'||to_char(rcd_column.fld_code)||'_'||to_char(rcd_column.column_index),null) as val_code
          from    dual
        ) b on (
          a.hou_code = b.hou_code
          and a.tab_code = rcd_column.tab_code
          and a.fld_code = rcd_column.fld_code
          and a.val_code = b.val_code
        )
        when not matched then
          insert
          (
            hou_code,
            tab_code,
            fld_code,
            val_code
          )
          values
          (
            b.hou_code,
            rcd_column.tab_code,
            rcd_column.fld_code,
            b.val_code
          )
          where b.val_code is not null
                and b.val_code <> -1;
        
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

end STEPTS03_LOADER;

/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on pts_app.stepts03_loader to public;
