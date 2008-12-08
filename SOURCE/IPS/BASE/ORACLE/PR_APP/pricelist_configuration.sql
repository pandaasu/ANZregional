/******************/
/* Package Header */
/******************/
create or replace package pricelist_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pricelist_configuration
    Owner   : pr_app

    Description
    -----------
    Price List Generator - Configuration

    This package contain the procedures for the price list generator configuration.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/12   Steve Gregan   Created

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function define_report(par_report_name in varchar2,
                          par_report_grp_id in varchar2,
                          par_price_mdl_id in varchar2,
                          par_matl_alrtng in varchar2,
                          par_auto_matl_update in varchar2) return varchar2;
   function define_data_item
   function define_break_item
   function define_order_item
   function define_commit
   function format_report
   function format_data_item
   function format_break_item
   function format_term
   function format_commit
   function delete_report
   function copy_report


 --  function update_report(par_report_id in varchar2,
 --                         par_report_name in varchar2) return varchar2;
 --  function format_report(par_report_id in varchar2) return varchar2;
 --  function delete_group(par_report_id in varchar2) return varchar2;
 --  function copy(par_report_id in varchar2) return varchar2;

end pricelist_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body pricelist_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_report report%rowtype;

   /****************************************************/
   /* This function performs the create report routine */
   /****************************************************/
   function create_report(par_report_name in varchar2,
                          par_report_grp_id in varchar2,
                          par_price_mdl_id in varchar2,
                          par_matl_alrtng in varchar2,
                          par_auto_matl_update in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_return common.st_result;
      var_return_msg common.st_message_string;
      var_id common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report_01 is 
         select *
           from report t01
          where t01.report_name = rcd_lics_group.gro_group;
      rcd_report_01 csr_report_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Create Report';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_report.report_id := null;
      rcd_report.report_name := par_report_name;
      rcd_report.price_sales_org_id := to_number(substr(par_price_mdl_id,instr(par_price_mdl_id,':',1,1)+1,instr(par_price_mdl_id,':',1,2)-1-instr(par_price_mdl_id,':',1,1)));
      rcd_report.price_distbn_chnl_id := to_number(substr(par_price_mdl_id,instr(par_price_mdl_id,':',1,2)+1));
      rcd_report.price_mdl_id := to_number(substr(par_price_mdl_id,1,instr(par_price_mdl_id,':',1,1)-1));
      rcd_report.status := 'I';
      rcd_report.report_grp_id := to_number(par_report_grd_id);
      rcd_report.owner_id := null;
      rcd_report.matl_alrtng := par_matl_alrtng;
      rcd_report.auto_matl_update := par_matl_alrtng;
      rcd_report.report_name_frmt := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_report.report_name is null then
         var_message := var_message || chr(13) || 'Report name be specified';
      end if;

      /*-*/
      /* Report must not already exist
      /*-*/
      open csr_report_01;
      fetch csr_report_01 into rcd_report_01;
      if csr_report_01%found then
         var_message := var_message || chr(13) || 'Report (' || rcd_report.report_name || ') already exists';
      end if;
      close csr_report_01;

      /*-*/
      /* Retrieve the report identifier
      /*-*/
      var_return := pricelist_object_tracking.get_new_id ('REPORT', 'REPORT_ID', var_id, var_return_msg);
      if var_return != common.gc_success then
         var_message := var_message || chr(13) || 'Unable to request new id for a report - ' || var_return_msg;
      end if;
      rcd_report.report_id := var_id;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the report
      /*-*/
      insert into report values rcd_report;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_report;

end pricelist_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_configuration for pr_app.pricelist_configuration;
grant execute on pricelist_configuration to public;