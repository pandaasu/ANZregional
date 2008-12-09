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
   procedure define_report(par_report_id in number,
                           par_report_name in varchar2,
                           par_report_grp_id in varchar2,
                           par_price_mdl_id in number,
                           par_price_sales_org_id in number,
                           par_price_distbn_id in number,
                           par_matl_alrtng in varchar2,
                           par_auto_matl_update in varchar2,
                           par_status in varchar2);
   procedure define_data(par_report_item_id in number,
                         par_price_item_id in number);
   procedure define_break(par_report_item_id in number,
                          par_price_item_id in number);
   procedure define_order(par_report_item_id in number,
                          par_price_item_id in number);
   procedure define_term(par_report_item_id in number,
                         par_value in varchar2);
   procedure define_commit;
   procedure format_report(par_report_id in number,
                           par_report_name_frmt in varchar2);
   procedure format_data(par_report_item_id in number,
                         par_name_ovrd in varchar2,
                         par_name_frmt in varchar2,
                         par_data_frmt in varchar2);
   procedure format_break(par_report_item_id in number,
                          par_data_frmt in varchar2);
   procedure format_term(par_report_item_id in number,
                         par_data_frmt in varchar2);
   procedure format_commit;

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
   rcd_report_item report_item%rowtype;
   rcd_report_term report_term%rowtype;
   type typ_report is table of report%rowtype index by binary_integer;
   type typ_report_item is table of report_item%rowtype index by binary_integer;
   type typ_report_term is table of report_term%rowtype index by binary_integer;
   tbl_report typ_report;
   tbl_report_data typ_report_item;
   tbl_report_break typ_report_item;
   tbl_report_order typ_report_item;
   tbl_report_term typ_report_term;

   /*****************************************************/
   /* This procedure performs the define report routine */
   /*****************************************************/
   procedure define_report(par_report_id in number,
                           par_report_name in varchar2,
                           par_report_grp_id in varchar2,
                           par_price_mdl_id in number,
                           par_price_sales_org_id in number,
                           par_price_distbn_id in number,
                           par_matl_alrtng in varchar2,
                           par_auto_matl_update in varchar2,
                           par_status in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report
      /*-*/
      tbl_report.delete;
      tbl_report_data.delete;
      tbl_report_break.delete;
      tbl_report_order.delete;
      tbl_report_term.delete;

      /*-*/
      /* Set the report variables
      /**/
      tbl_report(1).report_id := par_report_id;
      tbl_report(1).report_name := par_report_name;
      tbl_report(1).price_sales_org_id := par_price_sales_org_id;
      tbl_report(1).price_distbn_chnl_id := par_price_distbn_id;
      tbl_report(1).price_mdl_id := par_price_mdl_id;
      tbl_report(1).status := par_status;
      tbl_report(1).report_grp_id := par_report_grp_id;
      tbl_report(1).owner_id := 0;
      tbl_report(1).matl_alrtng := par_matl_alrtng;
      tbl_report(1).auto_matl_update := par_matl_alrtng;
      tbl_report(1).report_name_frmt := null;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_report;

   /********************************************************/
   /* This procedure performs the define data item routine */
   /********************************************************/
   procedure define_data(par_report_item_id in number,
                         par_price_item_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_data(tbl_report_data.count+1).report_item_id := par_report_item_id;
      tbl_report_data(tbl_report_data.count).price_item_id := par_price_item_id;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_data;

   /*********************************************************/
   /* This procedure performs the define break item routine */
   /*********************************************************/
   procedure define_break(par_report_item_id in number,
                          par_price_item_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_break(tbl_report_break.count+1).report_item_id := par_report_item_id;
      tbl_report_break(tbl_report_break.count).price_item_id := par_price_item_id;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_break;

   /*********************************************************/
   /* This procedure performs the define order item routine */
   /*********************************************************/
   procedure define_order(par_report_item_id in number,
                          par_price_item_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_order(tbl_report_order.count+1).report_item_id := par_report_item_id;
      tbl_report_order(tbl_report_order.count).price_item_id := par_price_item_id;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_order;

   /********************************************************/
   /* This procedure performs the define term item routine */
   /********************************************************/
   procedure define_term(par_report_item_id in number,
                         par_value in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_term(tbl_report_term.count+1).report_item_id := par_report_item_id;
      tbl_report_term(tbl_report_term.count).value := par_value;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_term;

   /*****************************************************/
   /* This procedure performs the define commit routine */
   /*****************************************************/
   procedure define_commit is

      /*-*/
      /* Local definitions
      /*-*/
      var_return common.st_result;
      var_return_msg common.st_message_string;
      var_id common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_report is 
         select t01.*
           from report t01
          where t01.report_id = tbl_report(1).report_id;
      rcd_check_report csr_check_report%rowtype;

      cursor csr_check_item is 
         select t01.*
           from report_item t01
          where t01.report_id = tbl_report(1).report_id
          order by t01.report_item_id asc;
      rcd_check_item csr_check_item%rowtype;

      cursor csr_check_term is 
         select t01.*
           from report_item t01
          where t01.report_id = tbl_report(1).report_id
          order by t01.report_item_id asc;
      rcd_check_term csr_check_term%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the existing report
      /*-*/
      open csr_check_report;
      fetch csr_check_report into rcd_check_report;
      if csr_check_report%found then
         tbl_report(1).report_name_frmt := rcd_check_report.report_name_frmt;
      end if;
      close csr_check_report;

      /*-*/
      /* Retrieve the existing report data items
      /*-*/
      open csr_check_item;
      loop
         fetch csr_check_item into rcd_check_item;
         if csr_check_item%notfound then
            exit;
         end if;
         for idx in 1..tbl_report_data.count loop
            if tbl_report_data(idx).report_item_id = rcd_check_item.report_item_id then
               tbl_report_data(idx).name_ovrd := rcd_check_item.name_ovrd;
               tbl_report_data(idx).name_frmt := rcd_check_item.name_frmt;
               tbl_report_data(idx).data_frmt := rcd_check_item.data_frmt;
            end if;
         end loop;
      end loop;
      close csr_check_item;

      /*-*/
      /* Retrieve the existing report break items
      /*-*/
      open csr_check_item;
      loop
         fetch csr_check_item into rcd_check_item;
         if csr_check_item%notfound then
            exit;
         end if;
         for idx in 1..tbl_report_break.count loop
            if tbl_report_break(idx).report_item_id = rcd_check_item.report_item_id then
               tbl_report_break(idx).name_ovrd := rcd_check_item.name_ovrd;
               tbl_report_break(idx).name_frmt := rcd_check_item.name_frmt;
               tbl_report_break(idx).data_frmt := rcd_check_item.data_frmt;
            end if;
         end loop;
      end loop;
      close csr_check_item;

      /*-*/
      /* Retrieve the existing report terms
      /*-*/
      open csr_check_term;
      loop
         fetch csr_check_term into rcd_check_term;
         if csr_check_term%notfound then
            exit;
         end if;
         for idx in 1..tbl_report_term.count loop
            if tbl_report_term(idx).report_item_id = rcd_check_term.report_item_id then
               tbl_report_term(idx).data_frmt := rcd_check_term.data_frmt;
            end if;
         end loop;
      end loop;
      close csr_check_term;

      /*-*/
      /* Delete the existing report information
      /*-*/
      delete from report_term where report_id = tbl_report(1).report_id;
      delete from report_item where report_id = tbl_report(1).report_id;
      delete from report where report_id = tbl_report(1).report_id;

      /*-*/
      /* Insert the report
      /**/
      rcd_report.report_id := tbl_report(1).report_id;
      rcd_report.report_name := tbl_report(1).report_name;
      rcd_report.price_sales_org_id := tbl_report(1).price_sales_org_id;
      rcd_report.price_distbn_chnl_id := tbl_report(1).price_distbn_chnl_id;
      rcd_report.price_mdl_id := tbl_report(1).price_mdl_id;
      rcd_report.status := tbl_report(1).status;
      rcd_report.report_grp_id := tbl_report(1).report_grp_id;
      rcd_report.owner_id := tbl_report(1).owner_id;
      rcd_report.matl_alrtng := tbl_report(1).matl_alrtng;
      rcd_report.auto_matl_update := tbl_report(1).auto_matl_update;
      rcd_report.report_name_frmt := tbl_report(1).report_name_frmt;
      if rcd_report.report_id = 0 then
         var_return := pricelist_object_tracking.get_new_id ('REPORT', 'REPORT_ID', var_id, var_return_msg);
         if var_return != common.gc_success then
            raise_application_error(-20000, 'Unable to request new id for a report - ' || var_return_msg);
         end if;
      end if;
      rcd_report.report_id := var_id;
      insert into report values rcd_report;

      /*-*/
      /* Insert the new report data items
      /*-*/
      for idx in 1..tbl_report_data.count loop
         rcd_report_item.report_id := rcd_report.report_id;
         rcd_report_item.report_item_id := tbl_report_data(idx).report_item_id;
         rcd_report_item.price_item_id := tbl_report_data(idx).price_item_id;
         rcd_report_item.report_item_type := 'D';
         rcd_report_item.name_ovrd := tbl_report_data(idx).name_ovrd;
         rcd_report_item.sort_order := idx;
         rcd_report_item.name_frmt := tbl_report_data(idx).name_frmt;
         rcd_report_item.data_frmt := tbl_report_data(idx).data_frmt;
         if rcd_report_item.report_item_id = 0 then
            var_return := pricelist_object_tracking.get_new_id ('REPORT', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
         end if;
         rcd_report_item.report_item_id := var_id;
         insert into report_item values rcd_report_item;
      end loop;

      /*-*/
      /* Insert the new report break items
      /*-*/
      for idx in 1..tbl_report_break.count loop
         rcd_report_item.report_id := rcd_report.report_id;
         rcd_report_item.report_item_id := tbl_report_break(idx).report_item_id;
         rcd_report_item.price_item_id := tbl_report_break(idx).price_item_id;
         rcd_report_item.report_item_type := 'B';
         rcd_report_item.name_ovrd := null;
         rcd_report_item.sort_order := idx;
         rcd_report_item.name_frmt := null;
         rcd_report_item.data_frmt := tbl_report_break(idx).data_frmt;
         if rcd_report_item.report_item_id = 0 then
            var_return := pricelist_object_tracking.get_new_id ('REPORT', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
         end if;
         rcd_report_item.report_item_id := var_id;
         insert into report_item values rcd_report_item;
      end loop;

      /*-*/
      /* Insert the new report order items
      /*-*/
      for idx in 1..tbl_report_order.count loop
         rcd_report_item.report_id := rcd_report.report_id;
         rcd_report_item.report_item_id := tbl_report_order(idx).report_item_id;
         rcd_report_item.price_item_id := tbl_report_order(idx).price_item_id;
         rcd_report_item.report_item_type := 'O';
         rcd_report_item.name_ovrd := null;
         rcd_report_item.sort_order := idx;
         rcd_report_item.name_frmt := null;
         rcd_report_item.data_frmt := null;
         if rcd_report_item.report_item_id = 0 then
            var_return := pricelist_object_tracking.get_new_id ('REPORT', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
         end if;
         rcd_report_item.report_item_id := var_id;
         insert into report_item values rcd_report_item;
      end loop;

      /*-*/
      /* Insert the new report order terms
      /*-*/
      for idx in 1..tbl_report_term.count loop
         rcd_report_term.report_id := rcd_report.report_id;
         rcd_report_term.report_item_id := tbl_report_term(idx).report_item_id;
         rcd_report_term.sort_order := idx;
         rcd_report_term.value := tbl_report_term(idx).value;
         rcd_report_term.data_frmt := tbl_report_term(idx).data_frmt;
         if rcd_report_term.report_item_id = 0 then
            var_return := pricelist_object_tracking.get_new_id ('REPORT', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
         end if;
         rcd_report_term.report_item_id := var_id;
         insert into report_term values rcd_report_term;
      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_commit;

   /*****************************************************/
   /* This procedure performs the format report routine */
   /*****************************************************/
   procedure format_report(par_report_id in number,
                           par_report_name_frmt in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report
      /*-*/
      tbl_report.delete;
      tbl_report_data.delete;
      tbl_report_break.delete;
      tbl_report_order.delete;
      tbl_report_term.delete;

      /*-*/
      /* Set the report variables
      /**/
      tbl_report(1).report_id := par_report_id;
      tbl_report(1).report_name_frmt := par_report_name_frmt;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_report;

   /********************************************************/
   /* This procedure performs the format data item routine */
   /********************************************************/
   procedure format_data(par_report_item_id in number,
                         par_name_ovrd in varchar2,
                         par_name_frmt in varchar2,
                         par_data_frmt in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_data(tbl_report_data.count+1).report_item_id := par_report_item_id;
      tbl_report_data(tbl_report_data.count).name_ovrd := par_name_ovrd;
      tbl_report_data(tbl_report_data.count).name_frmt := par_name_frmt;
      tbl_report_data(tbl_report_data.count).data_frmt := par_data_frmt;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_data;

   /*********************************************************/
   /* This procedure performs the format break item routine */
   /*********************************************************/
   procedure format_break(par_report_item_id in number,
                          par_data_frmt in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_break(tbl_report_break.count+1).report_item_id := par_report_item_id;
      tbl_report_break(tbl_report_break.count).data_frmt := par_data_frmt;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_break;

   /********************************************************/
   /* This procedure performs the format term item routine */
   /********************************************************/
   procedure format_term(par_report_item_id in number,
                         par_data_frmt in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_term(tbl_report_term.count+1).report_item_id := par_report_item_id;
      tbl_report_term(tbl_report_term.count).data_frmt := par_data_frmt;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_term;

   /*****************************************************/
   /* This procedure performs the format commit routine */
   /*****************************************************/
   procedure format_commit is

      /*-*/
      /* Local definitions
      /*-*/
      var_return common.st_result;
      var_return_msg common.st_message_string;
      var_id common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_report is 
         select t01.*
           from report t01
          where t01.report_id = tbl_report(1).report_id;
      rcd_check_report csr_check_report%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the existing report
      /*-*/
      open csr_check_report;
      fetch csr_check_report into rcd_check_report;
      if csr_check_report%notfound then
         raise_application_error(-20000, 'Report (' || tbl_report(1).report_id || ') does not exist');
      end if;
      close csr_check_report;

      /*-*/
      /* Update the report
      /*-*/
      update report
         set report_name_frmt = tbl_report(1).report_name_frmt
       where report_id = tbl_report(1).report_id;

      /*-*/
      /* Update the report data items
      /*-*/
      for idx in 1..tbl_report_data.count loop
         update report_item
            set name_ovrd = tbl_report_data(idx).name_ovrd,
                name_frmt = tbl_report_data(idx).name_frmt,
                data_frmt = tbl_report_data(idx).data_frmt
          where report_id = tbl_report(1).report_id
            and report_item_id = tbl_report_data(idx).report_item_id;
      end loop;

      /*-*/
      /* Update the report break items
      /*-*/
      for idx in 1..tbl_report_break.count loop
         update report_item
            set data_frmt = tbl_report_break(idx).data_frmt
          where report_id = tbl_report(1).report_id
            and report_item_id = tbl_report_break(idx).report_item_id;
      end loop;

      /*-*/
      /* Update the report terms
      /*-*/
      for idx in 1..tbl_report_term.count loop
         update report_term
            set data_frmt = tbl_report_term(idx).data_frmt
          where report_id = tbl_report(1).report_id
            and report_item_id = tbl_report_term(idx).report_item_id;
      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_commit;

end pricelist_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_configuration for pr_app.pricelist_configuration;
grant execute on pricelist_configuration to public;