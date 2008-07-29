/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_cdwics02
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Interface Control System - cdwics01 - Inbound Local Classification Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_cdwics02 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_cdwics02;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_cdwics02 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_typ(par_record in varchar2);
   procedure process_record_cla(par_record in varchar2);
   procedure process_record_mat(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_local_classn_type_load local_classn_type_load%rowtype;
   rcd_local_classn_load local_classn_load%rowtype;
   rcd_local_matl_classn_load local_matl_classn_load%rowtype;

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
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Attempt to lock the local classification type load table in exclusive mode
      /*-*/
      begin
         lock table local_classn_type_load in exclusive mode nowait;
      exception
         when others then
            lics_inbound_utility.add_exception('Unable to lock the local classification type load table (local_classn_type_load) interface rejected');
            var_trn_ignore := true;
      end;
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('TYP','INT_CODE',3);
      lics_inbound_utility.set_definition('TYP','TYPE_CODE',3);
      lics_inbound_utility.set_definition('TYP','TYPE_DESC',40);
      /*-*/
      lics_inbound_utility.set_definition('CLA','INT_CODE',3);
      lics_inbound_utility.set_definition('CLA','CLASSN_CODE',4);
      lics_inbound_utility.set_definition('CLA','CLASSN_DESC',40);
      lics_inbound_utility.set_definition('CLA','CLASSN_STATUS',8);
      /*-*/
      lics_inbound_utility.set_definition('MAT','INT_CODE',3);
      lics_inbound_utility.set_definition('MAT','MATL_CODE',18);
      lics_inbound_utility.set_definition('MAT','MATL_STATUS',8);

      /*-*/
      /* Truncate the load tables (reverse order)
      /*-*/
      matl_truncate_table.trunc_local_matl_classn_load;
      matl_truncate_table.trunc_local_classn_load;
      matl_truncate_table.trunc_local_classn_type_load;

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
         when 'TYP' then process_record_typ(par_record);
         when 'CLA' then process_record_cla(par_record);
         when 'MAT' then process_record_mat(par_record);
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
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**************************************************/
   /* This procedure performs the record TYP routine */
   /**************************************************/
   procedure process_record_typ(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore the data row when required
      /*-*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('TYP', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_local_classn_type_load.local_classn_type_code := lics_inbound_utility.get_number('TYPE_CODE',null);
      rcd_local_classn_type_load.local_classn_type_desc := lics_inbound_utility.get_variable('TYPE_DESC');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Insert the table row
      /*-*/
      insert into local_classn_type_load
         (local_classn_type_code,
          local_classn_type_desc)
      values
         (rcd_local_classn_type_load.local_classn_type_code,
          rcd_local_classn_type_load.local_classn_type_desc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_typ;

   /**************************************************/
   /* This procedure performs the record CLA routine */
   /**************************************************/
   procedure process_record_cla(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore the data row when required
      /*-*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CLA', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_local_classn_load.local_classn_type_code := rcd_local_classn_type_load.local_classn_type_code;
      rcd_local_classn_load.local_classn_code := lics_inbound_utility.get_number('CLASSN_CODE',null);
      rcd_local_classn_load.local_classn_desc := lics_inbound_utility.get_variable('CLASSN_DESC');
      rcd_local_classn_load.local_classn_status := lics_inbound_utility.get_variable('CLASSN_STATUS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Insert the table row
      /*-*/
      insert into local_classn_load
         (local_classn_type_code,
          local_classn_code,
          local_classn_desc,
          local_classn_status)
      values
         (rcd_local_classn_load.local_classn_type_code,
          rcd_local_classn_load.local_classn_code,
          rcd_local_classn_load.local_classn_desc,
          rcd_local_classn_load.local_classn_status);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cla;

   /**************************************************/
   /* This procedure performs the record MAT routine */
   /**************************************************/
   procedure process_record_mat(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore the data row when required
      /*-*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('MAT', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_local_matl_classn_load.local_classn_type_code := rcd_local_classn_load.local_classn_type_code;
      rcd_local_matl_classn_load.local_classn_code := rcd_local_classn_load.local_classn_code;
      rcd_local_matl_classn_load.matl_code := lics_inbound_utility.get_variable('MATL_CODE');
      rcd_local_matl_classn_load.local_matl_classn_status := lics_inbound_utility.get_variable('MATL_STATUS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Insert the table row
      /*-*/
      insert into local_matl_classn_load
         (matl_code,
          local_classn_type_code,
          local_classn_code,
          local_matl_classn_status)
      values
         (rcd_local_matl_classn_load.matl_code,
          rcd_local_matl_classn_load.local_classn_type_code,
          rcd_local_matl_classn_load.local_classn_code,
          rcd_local_matl_classn_load.local_matl_classn_status);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mat;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback the data as required
      /*
      /* **notes**
      /* 1. Truncate the data tables
      /* 2. Copy the load tables to the data tables
      /* 3. Truncate the load tables 
      /*-*/
      if var_trn_ignore = true or
         var_trn_error = true then
         rollback;
      else
         matl_truncate_table.trunc_local_matl_classn;
         matl_truncate_table.trunc_local_classn;
         matl_truncate_table.trunc_local_classn_type;
         insert into local_classn_type (select * from local_classn_type_load);
         insert into local_classn (select * from local_classn_load);
         insert into local_matl_classn (select * from local_matl_classn_load);
         matl_truncate_table.trunc_local_matl_classn_load;
         matl_truncate_table.trunc_local_classn_load;
         matl_truncate_table.trunc_local_classn_type_load;
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end ics_cdwics02;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
drop public synonym ics_cdwics02;
create public synonym ics_cdwics02 for ics_app.ics_cdwics02;
grant execute on ics_cdwics02 to lics_app;
