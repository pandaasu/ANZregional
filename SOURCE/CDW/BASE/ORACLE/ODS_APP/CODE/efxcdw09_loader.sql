/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw09_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw09_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Item Sub Group Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw09_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw09_loader as

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
   rcd_efex_matl_subgrp efex_matl_subgrp%rowtype;

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
      lics_inbound_utility.set_definition('HDR','ISG_ID',10);
      lics_inbound_utility.set_definition('HDR','ISG_NAME',50);
      lics_inbound_utility.set_definition('HDR','ITG_ID',10);
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

      rcd_efex_matl_subgrp.matl_subgrp_id := lics_inbound_utility.get_number('ISG_ID');
      rcd_efex_matl_subgrp.matl_subgrp_name := lics_inbound_utility.get_variable('ISG_NAME');
      rcd_efex_matl_subgrp.matl_grp_id := lics_inbound_utility.get_number('ITG_ID');
      rcd_efex_matl_subgrp.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_matl_subgrp.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_matl_subgrp values rcd_efex_matl_subgrp;
      exception
         when dup_val_on_index then
            update efex_matl_subgrp
               set matl_subgrp_name = rcd_efex_matl_subgrp.matl_subgrp_name,
                   matl_grp_id = rcd_efex_matl_subgrp.matl_grp_id,
                   status = rcd_efex_matl_subgrp.status,
                   valdtn_status = rcd_efex_matl_subgrp.valdtn_status
             where matl_subgrp_id = rcd_efex_matl_subgrp.matl_subgrp_id;
      end;

--doesn't make sense - how can lupdt be greater than sysdate
--  UPDATE efex_matl_subgrp t1
--  SET status = 'X'
--  WHERE EXISTS (SELECT *
--                FROM efex_matl_grp t2
--                WHERE t1.matl_grp_id = t2.matl_grp_id
--                  AND t2.status = 'X'
--                  AND t2.matl_grp_lupdt    > trunc(sysdate))
--    AND status = 'A';

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

end efxcdw09_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw09_loader for ods_app.efxcdw09_loader;
grant execute on ods_app.efxcdw09_loader to lics_app;
