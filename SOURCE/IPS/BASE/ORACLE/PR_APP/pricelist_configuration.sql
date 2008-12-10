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
   procedure define_group(par_report_grp_id in number,
                          par_report_grp_name in varchar2,
                          par_status in varchar2);
   procedure delete_group(par_report_grp_id in number);
   procedure define_report(par_report_id in number,
                           par_report_name in varchar2,
                           par_report_grp_id in varchar2,
                           par_price_mdl_id in number,
                           par_price_sales_org_id in number,
                           par_price_distbn_id in number,
                           par_status in varchar2,
                           par_matl_alrtng in varchar2,
                           par_auto_matl_update in varchar2);
   procedure define_data(par_report_item_id in number,
                         par_price_item_id in number);
   procedure define_break(par_report_item_id in number,
                          par_price_item_id in number);
   procedure define_order(par_report_item_id in number,
                          par_price_item_id in number);
   procedure define_term(par_value in varchar2);
   procedure define_material(par_matl_code in varchar2);
   procedure define_commit;
   procedure format_report(par_report_id in number,
                           par_report_name_frmt in varchar2);
   procedure format_data(par_report_item_id in number,
                         par_name_ovrd in varchar2,
                         par_name_frmt in varchar2,
                         par_data_frmt in varchar2);
   procedure format_break(par_report_item_id in number,
                          par_data_frmt in varchar2);
   procedure format_term(par_data_frmt in varchar2);
   procedure format_commit;
   procedure delete_report(par_report_id in number);
   procedure copy_report(par_report_id in number,
                         par_report_grp_id in number);

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
   rcd_report_grp report_grp%rowtype;
   type typ_report_grp is table of report_grp%rowtype index by binary_integer;
   tbl_report_grp typ_report_grp;
   rcd_report report%rowtype;
   rcd_report_item report_item%rowtype;
   rcd_report_term report_term%rowtype;
   rcd_report_matl report_matl%rowtype;
   type typ_report is table of report%rowtype index by binary_integer;
   type typ_report_item is table of report_item%rowtype index by binary_integer;
   type typ_report_term is table of report_term%rowtype index by binary_integer;
   type typ_report_matl is table of report_matl%rowtype index by binary_integer;
   tbl_report typ_report;
   tbl_report_data typ_report_item;
   tbl_report_break typ_report_item;
   tbl_report_order typ_report_item;
   tbl_report_term typ_report_term;
   tbl_report_matl typ_report_matl;

   /***********************************************************/
   /* This procedure performs the define report group routine */
   /***********************************************************/
   procedure define_group(par_report_grp_id in number,
                          par_report_grp_name in varchar2,
                          par_status in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_return common.st_result;
      var_return_msg common.st_message_string;
      var_id common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_report_grp is 
         select t01.*
           from report_grp t01
          where t01.report_grp_id = tbl_report_grp(1).report_grp_id;
      rcd_check_report_grp csr_check_report_grp%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report group
      /*-*/
      tbl_report_grp.delete;

      /*-*/
      /* Set the report group variables
      /*-*/
      tbl_report_grp(1).report_grp_id := par_report_grp_id;
      tbl_report_grp(1).report_grp_name := par_report_grp_name;
      tbl_report_grp(1).status := par_status;

      /*-*/
      /* Update/insert the report group
      /*-*/
      open csr_check_report_grp;
      fetch csr_check_report_grp into rcd_check_report_grp;
      if csr_check_report_grp%found then
         update report_grp
            set report_grp_name = tbl_report_grp(1).report_grp_name,
                status = tbl_report_grp(1).status
          where report_grp_id = tbl_report_grp(1).report_grp_id;
      else
         var_return := pricelist_object_tracking.get_new_id('REPORT_GRP', 'REPORT_GRP_ID', var_id, var_return_msg);
         if var_return != common.gc_success then
            raise_application_error(-20000, 'Unable to request new id for a report group - ' || var_return_msg);
         end if;
         rcd_report_grp.report_grp_id := var_id;
         rcd_report_grp.report_grp_name := tbl_report_grp(1).report_grp_name;
         rcd_report_grp.status := tbl_report_grp(1).status;
         insert into report_grp values rcd_report_grp;
      end if;
      close csr_check_report_grp;

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
   end define_group;

   /***********************************************************/
   /* This procedure performs the delete report group routine */
   /***********************************************************/
   procedure delete_group(par_report_grp_id in number) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_report is 
         select t01.*
           from report t01
          where t01.report_grp_id = par_report_grp_id;
      rcd_check_report csr_check_report%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Check for related reports
      /*-*/
      open csr_check_report;
      fetch csr_check_report into rcd_check_report;
      if csr_check_report%found then
         raise_application_error(-20000, 'Unable to delete the report group - reports attached');
      end if;
      close csr_check_report;

      /*-*/
      /* Delete the report group
      /*-*/
      delete from report_grp
       where report_grp_id = par_report_grp_id;

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
   end delete_group;

   /*****************************************************/
   /* This procedure performs the define report routine */
   /*****************************************************/
   procedure define_report(par_report_id in number,
                           par_report_name in varchar2,
                           par_report_grp_id in varchar2,
                           par_price_mdl_id in number,
                           par_price_sales_org_id in number,
                           par_price_distbn_id in number,
                           par_status in varchar2,
                           par_matl_alrtng in varchar2,
                           par_auto_matl_update in varchar2) is

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
      tbl_report_matl.delete;

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
      tbl_report(1).auto_matl_update := par_auto_matl_update;
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
   procedure define_term(par_value in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_term(tbl_report_term.count+1).value := par_value;

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

   /*******************************************************/
   /* This procedure performs the define material routine */
   /*******************************************************/
   procedure define_material(par_matl_code in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_matl(tbl_report_matl.count+1).matl_code := par_matl_code;

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
   end define_material;

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
      /* Update/insert the report
      /*-*/
      open csr_check_report;
      fetch csr_check_report into rcd_check_report;
      if csr_check_report%found then
         update report
            set report_name = tbl_report(1).report_name,
                price_sales_org_id = tbl_report(1).price_sales_org_id,
                price_distbn_chnl_id = tbl_report(1).price_distbn_chnl_id,
                price_mdl_id = tbl_report(1).price_mdl_id,
                status = tbl_report(1).status,
                report_grp_id = tbl_report(1).report_grp_id,
                owner_id = tbl_report(1).owner_id,
                matl_alrtng = tbl_report(1).matl_alrtng,
                auto_matl_update = tbl_report(1).auto_matl_update,
                report_name_frmt = rcd_check_report.report_name_frmt
          where report_id = tbl_report(1).report_id;
         delete from report_term where report_id = tbl_report(1).report_id;
       ----  delete from report_matl where report_id = tbl_report(1).report_id;
         delete from report_item where report_id = tbl_report(1).report_id;
      else
         var_return := pricelist_object_tracking.get_new_id('REPORT', 'REPORT_ID', var_id, var_return_msg);
         if var_return != common.gc_success then
            raise_application_error(-20000, 'Unable to request new id for a report - ' || var_return_msg);
         end if;
         rcd_report.report_id := var_id;
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
         insert into report values rcd_report;
      end if;
      close csr_check_report;

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
            var_return := pricelist_object_tracking.get_new_id('REPORT_ITEM', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
            rcd_report_item.report_item_id := var_id;
         end if;
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
            var_return := pricelist_object_tracking.get_new_id('REPORT_ITEM', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
            rcd_report_item.report_item_id := var_id;
         end if;
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
            var_return := pricelist_object_tracking.get_new_id('REPORT_ITEM', 'REPORT_ITEM_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
            end if;
            rcd_report_item.report_item_id := var_id;
         end if;
         insert into report_item values rcd_report_item;
      end loop;

      /*-*/
      /* Insert the new report materials
      /*-*/
      for idx in 1..tbl_report_matl.count loop
         rcd_report_matl.report_id := rcd_report.report_id;
         rcd_report_matl.matl_code := tbl_report_matl(idx).matl_code;
  ----     insert into report_matl values rcd_report_matl;
      end loop;

      /*-*/
      /* Insert the new report terms
      /*-*/
      for idx in 1..tbl_report_term.count loop
         rcd_report_term.report_id := rcd_report.report_id;
         rcd_report_term.sort_order := idx;
         rcd_report_term.value := tbl_report_term(idx).value;
         rcd_report_term.data_frmt := null;
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
   procedure format_term(par_data_frmt in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_term(tbl_report_term.count+1).data_frmt := par_data_frmt;

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
            and sort_order = idx;
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

   /*****************************************************/
   /* This procedure performs the delete report routine */
   /*****************************************************/
   procedure delete_report(par_report_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the report information
      /*-*/
      delete from report_term where report_id = par_report_id;
      delete from report_matl where report_id = par_report_id;
      delete from report_item where report_id = par_report_id;
      delete from report where report_id = par_report_id;

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
   end delete_report;

   /*****************************************************/
   /* This procedure performs the delete report routine */
   /*****************************************************/
   procedure copy_report(par_report_id in number,
                         par_report_grp_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the report information
      /*-*/
      delete from report_term where report_id = par_report_id;
      delete from report_matl where report_id = par_report_id;
      delete from report_item where report_id = par_report_id;
      delete from report where report_id = par_report_id;

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
   end copy_report;

end pricelist_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_configuration for pr_app.pricelist_configuration;
grant execute on pricelist_configuration to public;