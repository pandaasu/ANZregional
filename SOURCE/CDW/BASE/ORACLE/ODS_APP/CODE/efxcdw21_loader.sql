/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw21_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw21_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Range Item Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw21_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw21_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   rcd_efex_range_matl efex_range_matl%rowtype;

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

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','RAN_ID',10);
      lics_inbound_utility.set_definition('HDR','ITM_ID',10);
      lics_inbound_utility.set_definition('HDR','REF_CODE',50);
      lics_inbound_utility.set_definition('HDR','GRADE',50);
      lics_inbound_utility.set_definition('HDR','REQ_FLAG',1);
      lics_inbound_utility.set_definition('HDR','STR_DATE',14);
      lics_inbound_utility.set_definition('HDR','TAR_DATE',14);
      lics_inbound_utility.set_definition('HDR','STATUS',1);

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
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));

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
      /* Commit/rollback as required
      /*-*/
      if var_trn_error = true then
         rollback;
      else
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
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

      rcd_efex_range_matl.range_id := lics_inbound_utility.get_number('RAN_ID');
      rcd_efex_range_matl.efex_matl_id := lics_inbound_utility.get_number('ITM_ID');
      rcd_efex_range_matl.ref_code := lics_inbound_utility.get_variable('REF_CODE');
      rcd_efex_range_matl.grade := lics_inbound_utility.get_variable('GRADE');
      rcd_efex_range_matl.rqd_flg := lics_inbound_utility.get_variable('REQ_FLAG');
      rcd_efex_range_matl.start_date := lics_inbound_utility.get_date('STR_DATE','yyyymmddhh24miss');
      rcd_efex_range_matl.target_date := lics_inbound_utility.get_date('TAR_DATE','yyyymmddhh24miss');
      rcd_efex_range_matl.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_range_matl.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_range_matl values rcd_efex_range_matl;
      exception
         when dup_val_on_index then
            update efex_range_matl
               set ref_code = rcd_efex_range_matl.ref_code,
                   grade = rcd_efex_range_matl.grade,
                   rqd_flg = rcd_efex_range_matl.rqd_flg,
                   start_date = rcd_efex_range_matl.start_date,
                   target_date = rcd_efex_range_matl.target_date,
                   status = rcd_efex_range_matl.status,
                   valdtn_status = rcd_efex_range_matl.valdtn_status
             where range_id = rcd_efex_range_matl.range_id
               and efex_matl_id = rcd_efex_range_matl.efex_matl_id;
      end;

--???????  surely done in efex ???????
 -- UPDATE efex_range_matl t1
 -- SET status = 'X'
 -- WHERE exists (SELECT *
 --               FROM efex_matl t2
 --               WHERE t1.efex_matl_id = t2.efex_matl_id
 --               AND t2.status = 'X'
 --               AND TRUNC(t2.matl_lupdt) = TRUNC(SYSDATE));

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end efxcdw21_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw21_loader for ods_app.efxcdw21_loader;
grant execute on ods_app.efxcdw21_loader to lics_app;
