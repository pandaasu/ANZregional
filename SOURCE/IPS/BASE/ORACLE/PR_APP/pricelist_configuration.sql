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
                           par_auto_matl_update in varchar2,
                           par_email_address in varchar2,
                           par_user in varchar2);
   procedure define_data(par_report_item_id in number,
                         par_price_item_id in number);
   procedure define_break(par_report_item_id in number,
                          par_price_item_id in number);
   procedure define_order(par_report_item_id in number,
                          par_price_item_id in number);
   procedure define_term(par_value in varchar2);
   procedure define_commit;
   procedure rule_begin(par_report_id in number);
   procedure rule_header(par_report_rule_name in varchar2);
   procedure rule_detail(par_price_rule_type_id in number,
                         par_rule_vlu in varchar2,
                         par_rule_not in varchar2);
   procedure rule_commit;
   procedure material_begin(par_report_id in number);
   procedure material_detail(par_matl_code in varchar2);
   procedure material_commit;
   procedure format_report(par_report_id in number,
                           par_report_name_frmt in varchar2,
                           par_user in varchar2);
   procedure format_data(par_report_item_id in number,
                         par_name_ovrd in varchar2,
                         par_name_frmt in varchar2,
                         par_data_frmt in varchar2);
   procedure format_break(par_report_item_id in number,
                          par_data_frmt in varchar2);
   procedure format_term(par_data_frmt in varchar2);
   procedure format_commit;
   procedure delete_report(par_report_id in number);
   procedure copy_report(par_copy_id in number,
                         par_report_grp_id in number,
                         par_report_name in varchar2);
   procedure review_reports;

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
   /* Private declarations
   /*-*/
   procedure load_materials(par_report_id in number);
   procedure check_materials(par_report_id in number, par_update in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   type rcd_rule is record(rule_type varchar2(2),
                           report_rule_name varchar2(200),
                           price_rule_type_id number,
                           rule_vlu varchar2(200),
                           rule_not varchar2(1));
   rcd_report_grp report_grp%rowtype;
   type typ_report_grp is table of report_grp%rowtype index by binary_integer;
   tbl_report_grp typ_report_grp;
   rcd_report report%rowtype;
   rcd_report_item report_item%rowtype;
   rcd_report_term report_term%rowtype;
   rcd_report_rule report_rule%rowtype;
   rcd_report_rule_detl report_rule_detl%rowtype;
   rcd_report_matl report_matl%rowtype;
   type typ_report is table of report%rowtype index by binary_integer;
   type typ_report_item is table of report_item%rowtype index by binary_integer;
   type typ_report_term is table of report_term%rowtype index by binary_integer;
   type typ_report_rule is table of rcd_rule index by binary_integer;
   type typ_report_matl is table of report_matl%rowtype index by binary_integer;
   tbl_report typ_report;
   tbl_report_data typ_report_item;
   tbl_report_break typ_report_item;
   tbl_report_order typ_report_item;
   tbl_report_term typ_report_term;
   tbl_report_rule typ_report_rule;
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
          where t01.report_grp_id = rcd_report_grp.report_grp_id;
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
      /* Initialise the report group identifier
      /*-*/
      rcd_report_grp.report_grp_id := tbl_report_grp(1).report_grp_id;

      /*-*/
      /* Update/insert the report group
      /*-*/
      open csr_check_report_grp;
      fetch csr_check_report_grp into rcd_check_report_grp;
      if csr_check_report_grp%found then
         update report_grp
            set report_grp_name = tbl_report_grp(1).report_grp_name,
                status = tbl_report_grp(1).status
          where report_grp_id = rcd_report_grp.report_grp_id;
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
                           par_auto_matl_update in varchar2,
                           par_email_address in varchar2,
                           par_user in varchar2) is

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
      tbl_report(1).matl_alrtng := par_matl_alrtng;
      tbl_report(1).auto_matl_update := par_auto_matl_update;
      tbl_report(1).report_name_frmt := null;
      tbl_report(1).create_user := par_user;
      tbl_report(1).update_user := par_user;
      tbl_report(1).email_address := par_email_address;

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
      tbl_report_term(tbl_report_term.count+1).value := substr(rtrim(rtrim(ltrim(ltrim(par_value,chr(10)),chr(13)),chr(10)),chr(13)),1,1000);

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
      var_materials boolean;
      var_price_rule_type_column price_rule_type.price_rule_type_column%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_report is 
         select t01.*
           from report t01
          where t01.report_id = rcd_report.report_id;
      rcd_check_report csr_check_report%rowtype;

      cursor csr_check_item is 
         select t01.*
           from report_item t01
          where t01.report_id = rcd_report.report_id
          order by t01.report_item_id asc;
      rcd_check_item csr_check_item%rowtype;

      cursor csr_price_rule_type is 
         select t01.price_rule_type_id
           from price_rule_type t01
          where t01.price_rule_type_column = var_price_rule_type_column;
      rcd_price_rule_type csr_price_rule_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report identifier
      /*-*/
      rcd_report.report_id := tbl_report(1).report_id;

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
      /* **notes**
      /* 1. New reports have the following default rules created
      /*    1.1 x_plant_matl_sts = 10 (price_rule_type_id = 100)
      /*    1.2 dstrbtn_chain_sts = 20 (price_rule_type_id = 101)
      /*    1.3 matl_type = ZREP (price_rule_type_id = 102)
      /*-*/
      var_materials := false;
      open csr_check_report;
      fetch csr_check_report into rcd_check_report;
      if csr_check_report%found then
         if rcd_check_report.price_sales_org_id != tbl_report(1).price_sales_org_id or
            rcd_check_report.price_distbn_chnl_id != tbl_report(1).price_distbn_chnl_id then
            var_materials := true;
         end if;
         update report
            set report_name = tbl_report(1).report_name,
                price_sales_org_id = tbl_report(1).price_sales_org_id,
                price_distbn_chnl_id = tbl_report(1).price_distbn_chnl_id,
                price_mdl_id = tbl_report(1).price_mdl_id,
                status = tbl_report(1).status,
                report_grp_id = tbl_report(1).report_grp_id,
                matl_alrtng = tbl_report(1).matl_alrtng,
                auto_matl_update = tbl_report(1).auto_matl_update,
                report_name_frmt = rcd_check_report.report_name_frmt,
                create_user = nvl(rcd_check_report.create_user,tbl_report(1).update_user),
                update_user = tbl_report(1).update_user,
                email_address = tbl_report(1).email_address
          where report_id = rcd_report.report_id;
         delete from report_term where report_id = tbl_report(1).report_id;
         delete from report_item where report_id = tbl_report(1).report_id;
      else
         var_materials := true;
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
         rcd_report.matl_alrtng := tbl_report(1).matl_alrtng;
         rcd_report.auto_matl_update := tbl_report(1).auto_matl_update;
         rcd_report.report_name_frmt := tbl_report(1).report_name_frmt;
         rcd_report.create_user := tbl_report(1).create_user;
         rcd_report.update_user := tbl_report(1).update_user;
         rcd_report.email_address := tbl_report(1).email_address;
         insert into report values rcd_report;
         var_return := pricelist_object_tracking.get_new_id('REPORT_RULE', 'REPORT_RULE_ID', var_id, var_return_msg);
         if var_return != common.gc_success then
            raise_application_error(-20000, 'Unable to request new id for a report rule - ' || var_return_msg);
         end if;
         rcd_report_rule.report_id := rcd_report.report_id;
         rcd_report_rule.report_rule_id := var_id;
         rcd_report_rule.report_rule_name := 'Default material selection rule';
         insert into report_rule values rcd_report_rule;
         var_price_rule_type_column := 'DISBTN_CHNNL';
         open csr_price_rule_type;
         fetch csr_price_rule_type into rcd_price_rule_type;
         if csr_price_rule_type%found then
            rcd_report_rule_detl.report_rule_id := rcd_report_rule.report_rule_id;
            rcd_report_rule_detl.price_rule_type_id := rcd_price_rule_type.price_rule_type_id;
            rcd_report_rule_detl.rule_vlu := '20';
            rcd_report_rule_detl.rule_not := 'F';
            insert into report_rule_detl values rcd_report_rule_detl;
         end if;
         close csr_price_rule_type;
         var_price_rule_type_column := 'X_PLANT_MATL_STS';
         open csr_price_rule_type;
         fetch csr_price_rule_type into rcd_price_rule_type;
         if csr_price_rule_type%found then
            rcd_report_rule_detl.report_rule_id := rcd_report_rule.report_rule_id;
            rcd_report_rule_detl.price_rule_type_id := rcd_price_rule_type.price_rule_type_id;
            rcd_report_rule_detl.rule_vlu := '10';
            rcd_report_rule_detl.rule_not := 'F';
            insert into report_rule_detl values rcd_report_rule_detl;
         end if;
         close csr_price_rule_type;
         var_price_rule_type_column := 'MATL_TYPE';
         open csr_price_rule_type;
         fetch csr_price_rule_type into rcd_price_rule_type;
         if csr_price_rule_type%found then
            rcd_report_rule_detl.report_rule_id := rcd_report_rule.report_rule_id;
            rcd_report_rule_detl.price_rule_type_id := rcd_price_rule_type.price_rule_type_id;
            rcd_report_rule_detl.rule_vlu := 'ZREP';
            rcd_report_rule_detl.rule_not := 'F';
            insert into report_rule_detl values rcd_report_rule_detl;
         end if;
         close csr_price_rule_type;
         var_price_rule_type_column := 'TRDD_UNIT';
         open csr_price_rule_type;
         fetch csr_price_rule_type into rcd_price_rule_type;
         if csr_price_rule_type%found then
            rcd_report_rule_detl.report_rule_id := rcd_report_rule.report_rule_id;
            rcd_report_rule_detl.price_rule_type_id := rcd_price_rule_type.price_rule_type_id;
            rcd_report_rule_detl.rule_vlu := 'X';
            rcd_report_rule_detl.rule_not := 'F';
            insert into report_rule_detl values rcd_report_rule_detl;
         end if;
         close csr_price_rule_type;
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
      /* Reload the report materials when required
      /*-*/
      if var_materials = true then
         load_materials(rcd_report.report_id);
      end if;

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

   /**************************************************/
   /* This procedure performs the rule begin routine */
   /**************************************************/
   procedure rule_begin(par_report_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the rules
      /*-*/
      tbl_report_rule.delete;

      /*-*/
      /* Initialise the report identifier
      /*-*/
      rcd_report_rule.report_id := par_report_id;

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
   end rule_begin;

   /***************************************************/
   /* This procedure performs the rule header routine */
   /***************************************************/
   procedure rule_header(par_report_rule_name in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the rule
      /*-*/
      rcd_report_rule.report_rule_name := par_report_rule_name;

      /*-*/
      /* Set the report variables
      /**/
      tbl_report_rule(tbl_report_rule.count+1).rule_type := 'RH';
      tbl_report_rule(tbl_report_rule.count).report_rule_name := par_report_rule_name;

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
   end rule_header;

   /***************************************************/
   /* This procedure performs the rule detail routine */
   /***************************************************/
   procedure rule_detail(par_price_rule_type_id in number,
                         par_rule_vlu in varchar2,
                         par_rule_not in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the rule detail
      /*-*/
      tbl_report_rule(tbl_report_rule.count+1).rule_type := 'RD';
      tbl_report_rule(tbl_report_rule.count).price_rule_type_id := par_price_rule_type_id;
      tbl_report_rule(tbl_report_rule.count).rule_vlu := par_rule_vlu;
      tbl_report_rule(tbl_report_rule.count).rule_not := par_rule_not;

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
   end rule_detail;

   /***************************************************/
   /* This procedure performs the rule commit routine */
   /***************************************************/
   procedure rule_commit is

      /*-*/
      /* Local definitions
      /*-*/
      var_return common.st_result;
      var_return_msg common.st_message_string;
      var_id common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_rule is 
         select t01.*
           from report_rule t01
          where t01.report_id = rcd_report_rule.report_id
          order by t01.report_rule_id asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_rule_detl is 
         select t01.rule_vlu,
                t01.rule_not,
                t02.sql_where
           from report_rule_detl t01,
                price_rule_type t02
          where t01.price_rule_type_id = t02.price_rule_type_id
            and t01.report_rule_id = rcd_rule.report_rule_id
          order by t01.price_rule_type_id asc;
      rcd_rule_detl csr_rule_detl%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the existing report rule data
      /*-*/
      delete from report_rule_detl where report_rule_id in (select report_rule_id from report_rule where report_id = rcd_report_rule.report_id);
      delete from report_rule where report_id = rcd_report_rule.report_id;

      /*-*/
      /* Insert the new report rule data
      /*-*/
      for idx in 1..tbl_report_rule.count loop
         if tbl_report_rule(idx).rule_type = 'RH' then
            var_return := pricelist_object_tracking.get_new_id('REPORT_RULE', 'REPORT_RULE_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report rule - ' || var_return_msg);
            end if;
            rcd_report_rule.report_rule_id := var_id;
            rcd_report_rule.report_rule_name := tbl_report_rule(idx).report_rule_name;
            insert into report_rule values rcd_report_rule;
         end if;
         if tbl_report_rule(idx).rule_type = 'RD' then
            rcd_report_rule_detl.report_rule_id := rcd_report_rule.report_rule_id;
            rcd_report_rule_detl.price_rule_type_id := tbl_report_rule(idx).price_rule_type_id;
            rcd_report_rule_detl.rule_vlu := tbl_report_rule(idx).rule_vlu;
            rcd_report_rule_detl.rule_not := tbl_report_rule(idx).rule_not;
            insert into report_rule_detl values rcd_report_rule_detl;
         end if;
      end loop;

      /*-*/
      /* Reload the report materials
      /*-*/
      load_materials(rcd_report_rule.report_id);

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
   end rule_commit;

   /******************************************************/
   /* This procedure performs the material begin routine */
   /******************************************************/
   procedure material_begin(par_report_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the materials
      /*-*/
      tbl_report_matl.delete;

      /*-*/
      /* Initialise the report identifier
      /*-*/
      rcd_report_matl.report_id := par_report_id;

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
   end material_begin;

   /*******************************************************/
   /* This procedure performs the material detail routine */
   /*******************************************************/
   procedure material_detail(par_matl_code in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the rule detail
      /*-*/
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
   end material_detail;

   /*******************************************************/
   /* This procedure performs the material commit routine */
   /*******************************************************/
   procedure material_commit is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the existing report material data
      /*-*/
      delete from report_matl where report_id = rcd_report_matl.report_id;

      /*-*/
      /* Insert the new report material data
      /*-*/
      for idx in 1..tbl_report_matl.count loop
         rcd_report_matl.matl_code := tbl_report_matl(idx).matl_code;
         insert into report_matl values rcd_report_matl;
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
   end material_commit;

   /*****************************************************/
   /* This procedure performs the format report routine */
   /*****************************************************/
   procedure format_report(par_report_id in number,
                           par_report_name_frmt in varchar2,
                           par_user in varchar2) is

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
      tbl_report(1).update_user := par_user;

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
         set report_name_frmt = tbl_report(1).report_name_frmt,
             update_user = tbl_report(1).update_user
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
      delete from report_matl where report_id = par_report_id;
      delete from report_rule_detl where report_rule_id in (select report_rule_id from report_rule where report_id = par_report_id);
      delete from report_rule where report_id = par_report_id;
      delete from report_term where report_id = par_report_id;
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
   procedure copy_report(par_copy_id in number,
                         par_report_grp_id in number,
                         par_report_name in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_return common.st_result;
      var_return_msg common.st_message_string;
      var_id common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_copy_report is 
         select t01.*
           from report t01
          where t01.report_id = par_copy_id;
      rcd_copy_report csr_copy_report%rowtype;

      cursor csr_copy_item is 
         select t01.*
           from report_item t01
          where t01.report_id = par_copy_id
          order by t01.report_item_id asc;
      rcd_copy_item csr_copy_item%rowtype;

      cursor csr_copy_term is 
         select t01.*
           from report_term t01
          where t01.report_id = par_copy_id
          order by t01.sort_order asc;
      rcd_copy_term csr_copy_term%rowtype;

      cursor csr_copy_rule is 
         select t01.*
           from report_rule t01
          where t01.report_id = par_copy_id
          order by t01.report_rule_id asc;
      rcd_copy_rule csr_copy_rule%rowtype;

      cursor csr_copy_rule_detl is 
         select t01.*
           from report_rule_detl t01
          where t01.report_rule_id = rcd_copy_rule.report_rule_id
          order by t01.price_rule_type_id asc;
      rcd_copy_rule_detl csr_copy_rule_detl%rowtype;

      cursor csr_copy_matl is 
         select t01.*
           from report_matl t01
          where t01.report_id = par_copy_id
          order by t01.matl_code asc;
      rcd_copy_matl csr_copy_matl%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Copy the report
      /*-*/
      open csr_copy_report;
      fetch csr_copy_report into rcd_copy_report;
      if csr_copy_report%notfound then
         raise_application_error(-20000, 'Report (' || par_copy_id || ') does not exist');
      end if;
      close csr_copy_report;
      var_return := pricelist_object_tracking.get_new_id('REPORT', 'REPORT_ID', var_id, var_return_msg);
      if var_return != common.gc_success then
         raise_application_error(-20000, 'Unable to request new id for a report - ' || var_return_msg);
      end if;
      rcd_report.report_id := var_id;
      rcd_report.report_name := par_report_name;
      rcd_report.price_sales_org_id := rcd_copy_report.price_sales_org_id;
      rcd_report.price_distbn_chnl_id := rcd_copy_report.price_distbn_chnl_id;
      rcd_report.price_mdl_id := rcd_copy_report.price_mdl_id;
      rcd_report.status := rcd_copy_report.status;
      rcd_report.report_grp_id := par_report_grp_id;
      rcd_report.matl_alrtng := rcd_copy_report.matl_alrtng;
      rcd_report.auto_matl_update := rcd_copy_report.auto_matl_update;
      rcd_report.report_name_frmt := rcd_copy_report.report_name_frmt;
      rcd_report.create_user := rcd_copy_report.create_user;
      rcd_report.update_user := rcd_copy_report.update_user;
      rcd_report.email_address := rcd_copy_report.email_address;
      insert into report values rcd_report;

      /*-*/
      /* Copy the report items
      /*-*/
      open csr_copy_item;
      loop
         fetch csr_copy_item into rcd_copy_item;
         if csr_copy_item%notfound then
            exit;
         end if;
         var_return := pricelist_object_tracking.get_new_id('REPORT_ITEM', 'REPORT_ITEM_ID', var_id, var_return_msg);
         if var_return != common.gc_success then
            raise_application_error(-20000, 'Unable to request new id for a report item - ' || var_return_msg);
         end if;
         rcd_report_item.report_item_id := var_id;
         rcd_report_item.report_id := rcd_report.report_id;
         rcd_report_item.price_item_id := rcd_copy_item.price_item_id;
         rcd_report_item.report_item_type := rcd_copy_item.report_item_type;
         rcd_report_item.name_ovrd := rcd_copy_item.name_ovrd;
         rcd_report_item.sort_order := rcd_copy_item.sort_order;
         rcd_report_item.name_frmt := rcd_copy_item.name_frmt;
         rcd_report_item.data_frmt := rcd_copy_item.data_frmt;
         insert into report_item values rcd_report_item;
      end loop;
      close csr_copy_item;

      /*-*/
      /* Copy the report terms
      /*-*/
      open csr_copy_term;
      loop
         fetch csr_copy_term into rcd_copy_term;
         if csr_copy_term%notfound then
            exit;
         end if;
         rcd_report_term.report_id := rcd_report.report_id;
         rcd_report_term.sort_order := rcd_copy_term.sort_order;
         rcd_report_term.value := rcd_copy_term.value;
         rcd_report_term.data_frmt := rcd_copy_term.data_frmt;
         insert into report_term values rcd_report_term;
      end loop;
      close csr_copy_term;

      /*-*/
      /* Copy the report rules
      /*-*/
      open csr_copy_rule;
      loop
         fetch csr_copy_rule into rcd_copy_rule;
         if csr_copy_rule%notfound then
            exit;
         end if;
            var_return := pricelist_object_tracking.get_new_id('REPORT_RULE', 'REPORT_RULE_ID', var_id, var_return_msg);
            if var_return != common.gc_success then
               raise_application_error(-20000, 'Unable to request new id for a report rule - ' || var_return_msg);
            end if;
            rcd_report_rule.report_rule_id := var_id;
            rcd_report_rule.report_id := rcd_report.report_id;
            rcd_report_rule.report_rule_name := rcd_copy_rule.report_rule_name;
            insert into report_rule values rcd_report_rule;
            open csr_copy_rule_detl;
            loop
               fetch csr_copy_rule_detl into rcd_copy_rule_detl;
               if csr_copy_rule_detl%notfound then
                  exit;
               end if;
               rcd_report_rule_detl.report_rule_id := rcd_report_rule.report_rule_id;
               rcd_report_rule_detl.price_rule_type_id := rcd_copy_rule_detl.price_rule_type_id;
               rcd_report_rule_detl.rule_vlu := rcd_copy_rule_detl.rule_vlu;
               rcd_report_rule_detl.rule_not := rcd_copy_rule_detl.rule_not;
               insert into report_rule_detl values rcd_report_rule_detl;
            end loop;
            close csr_copy_rule_detl;
      end loop;
      close csr_copy_rule;

      /*-*/
      /* Copy the report materials
      /*-*/
      open csr_copy_matl;
      loop
         fetch csr_copy_matl into rcd_copy_matl;
         if csr_copy_matl%notfound then
            exit;
         end if;
         rcd_report_matl.report_id := rcd_report.report_id;
         rcd_report_matl.matl_code := rcd_copy_matl.matl_code;
         insert into report_matl values rcd_report_matl;
      end loop;
      close csr_copy_matl;

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

   /******************************************************/
   /* This procedure performs the review reports routine */
   /******************************************************/
   procedure review_reports is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_review_report is 
         select t01.*
           from report t01
          order by t01.report_name;
      rcd_review_report csr_review_report%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'PRICE_LIST_REVIEW';
      var_log_search := 'PRICE_LIST_REVIEW';

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Price List Report Review');

      /*-*/
      /* Retrieve all activated reports
      /*-*/
      open csr_review_report;
      loop
         fetch csr_review_report into rcd_review_report;
         if csr_review_report%notfound then
            exit;
         end if;

         /*-*/
         /* Log the report event
         /*-*/
         lics_logging.write_log('Reviewing report (' || rcd_review_report.report_name || ') status (' || rcd_review_report.status || ') automatic material update (' || rcd_review_report.auto_matl_update || ') material alerting (' || rcd_review_report.matl_alrtng || ') email address (' || rcd_review_report.email_address || ')');

         /*-*/
         /* Process activated reports
         /*-*/
         if rcd_review_report.status = 'V' then

            /*-*/
            /* Automatic material update requested
            /*-*/
            if rcd_review_report.auto_matl_update = 'Y' then

               /*-*/
               /* Check the report materials based on the report rules
               /*-*/
               if rcd_review_report.matl_alrtng = 'Y' and not(rcd_review_report.email_address is null) then
                  lics_logging.write_log('Generating automatic material update notification for report (' || rcd_review_report.report_name || ')');
                  check_materials(rcd_review_report.report_id,'Y');
               end if;

               /*-*/
               /* Update the report materials based on the report rules
               /*-*/
               lics_logging.write_log('Performing automatic material update for report (' || rcd_review_report.report_name || ')');
               load_materials(rcd_review_report.report_id);

               /*-*/
               /* Commit the database
               /*-*/
               commit;

            /*-*/
            /* Automatic material update NOT requested
            /*-*/
            else

               /*-*/
               /* Material alerting requested and notification email address specified
               /*-*/
               if rcd_review_report.matl_alrtng = 'Y' and not(rcd_review_report.email_address is null) then

                  /*-*/
                  /* Check the report materials based on the report rules and email recommendations
                  /*-*/
                  lics_logging.write_log('Generating material recommendation notification for report (' || rcd_review_report.report_name || ')');
                  check_materials(rcd_review_report.report_id,'N');

                  /*-*/
                  /* Commit the database
                  /*-*/
                  commit;

               end if;

            end if;

         end if;

      end loop;
      close csr_review_report;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Price List Report Review');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         begin
            if lics_logging.is_created = true then
               lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
               lics_logging.end_log;
            end if;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end review_reports;

   /******************************************************/
   /* This procedure performs the load materials routine */
   /******************************************************/
   procedure load_materials(par_report_id in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(32767 char);
      type typ_cursor is ref cursor;
      csr_material typ_cursor;
      var_matl_code report_matl.matl_code%type;
      var_rule boolean;
      var_detail boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report is 
         select t01.report_id,
                t02.price_sales_org_code,
                t03.price_distbn_chnl_code
           from report t01,
                price_sales_org t02,
                price_distbn_chnl t03
          where t01.price_sales_org_id = t02.price_sales_org_id
            and t01.price_distbn_chnl_id = t03.price_distbn_chnl_id
            and t01.report_id = par_report_id;
      rcd_report csr_report%rowtype;

      cursor csr_rule is 
         select t01.*
           from report_rule t01
          where t01.report_id = par_report_id
          order by t01.report_rule_id asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_rule_detl is 
         select t01.rule_vlu,
                t01.rule_not,
                t02.sql_where
           from report_rule_detl t01,
                price_rule_type t02
          where t01.price_rule_type_id = t02.price_rule_type_id
            and t01.report_rule_id = rcd_rule.report_rule_id
          order by t01.price_rule_type_id asc;
      rcd_rule_detl csr_rule_detl%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the report data
      /*-*/
      open csr_report;
      fetch csr_report into rcd_report;
      if csr_report%notfound then
         raise_application_error(-20000, 'Report (' || to_char(par_report_id) || ') not found');
      end if;
      close csr_report;

      /*-*/
      /* Delete the existing report materials
      /*-*/
      delete from report_matl where report_id = par_report_id;

      /*-*/
      /* Build the query statement
      /*-*/
      var_query := 'select t1.matl_code
                      from matl t1, matl_by_sales_area t2
                     where t1.matl_code = t2.matl_code
                       and t2.sales_org = '''||rcd_report.price_sales_org_code||'''
                       and t2.dstrbtn_chnl = '''||rcd_report.price_distbn_chnl_code||'''';

      /*-*/
      /* Add the report rules
      /*-*/
      var_rule := false;
      open csr_rule;
      loop
         fetch csr_rule into rcd_rule;
         if csr_rule%notfound then
            exit;
         end if;
         if var_rule = false then
            var_query :=  var_query || ' and ((';
         else
            var_query :=  var_query || ' or (';
         end if;
         var_rule := true;
         var_detail := false;
         open csr_rule_detl;
         loop
            fetch csr_rule_detl into rcd_rule_detl;
            if csr_rule_detl%notfound then
               exit;
            end if;
            if var_detail = false then
               if rcd_rule_detl.rule_not = 'T' then
                  var_query := var_query || 'not(' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu) || ')';
               else
                  var_query := var_query || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu);
               end if;
            else
               if rcd_rule_detl.rule_not = 'T' then
                  var_query := var_query || ' and not(' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu) || ')';
               else
                  var_query := var_query || ' and ' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu);
               end if;
            end if;
            var_detail := true;
         end loop;
         close csr_rule_detl;
         var_query :=  var_query || ')';
      end loop;
      close csr_rule;
      if var_rule = true then
         var_query :=  var_query || ')';
      end if;

      /*-*/
      /* Insert the order by
      /*-*/
      var_query :=  var_query || ' order by t1.matl_code asc';

      /*-*/
      /* Load the report materials
      /*-*/
      open csr_material for var_query;
      loop
         fetch csr_material into var_matl_code;
         if csr_material%notfound then
            exit;
         end if;
         insert into report_matl values(rcd_report.report_id, var_matl_code);
      end loop;
      close csr_material;

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
   end load_materials;

   /*******************************************************/
   /* This procedure performs the check materials routine */
   /*******************************************************/
   procedure check_materials(par_report_id in number, par_update in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(32767 char);
      type typ_cursor is ref cursor;
      csr_material typ_cursor;
      var_matl_code report_matl.matl_code%type;
      var_matl_desc matl.matl_desc%type;
      var_rule boolean;
      var_detail boolean;
      type rcd_matl is record(matl_code varchar2(20),
                              matl_desc varchar2(200));
      type typ_matl is table of rcd_matl index by binary_integer;
      tbl_matl01 typ_matl;
      tbl_matl02 typ_matl;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report is 
         select t01.report_id,
                t01.report_name,
                t01.email_address,
                t02.price_sales_org_code,
                t03.price_distbn_chnl_code
           from report t01,
                price_sales_org t02,
                price_distbn_chnl t03
          where t01.price_sales_org_id = t02.price_sales_org_id
            and t01.price_distbn_chnl_id = t03.price_distbn_chnl_id
            and t01.report_id = par_report_id;
      rcd_report csr_report%rowtype;

      cursor csr_rule is 
         select t01.*
           from report_rule t01
          where t01.report_id = par_report_id
          order by t01.report_rule_id asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_rule_detl is 
         select t01.rule_vlu,
                t01.rule_not,
                t02.sql_where
           from report_rule_detl t01,
                price_rule_type t02
          where t01.price_rule_type_id = t02.price_rule_type_id
            and t01.report_rule_id = rcd_rule.report_rule_id
          order by t01.price_rule_type_id asc;
      rcd_rule_detl csr_rule_detl%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the report data
      /*-*/
      open csr_report;
      fetch csr_report into rcd_report;
      if csr_report%notfound then
         raise_application_error(-20000, 'Report (' || to_char(par_report_id) || ') not found');
      end if;
      close csr_report;

      /*-*/
      /* Build the add query statement (ie. report rule materials not in the rule materials)
      /*-*/
      var_query := 'select t1.matl_code, t1.matl_desc
                      from matl t1, matl_by_sales_area t2
                     where t1.matl_code = t2.matl_code
                       and t2.sales_org = '''||rcd_report.price_sales_org_code||'''
                       and t2.dstrbtn_chnl = '''||rcd_report.price_distbn_chnl_code||'''';

      /*-*/
      /* Add the report rules
      /*-*/
      var_rule := false;
      open csr_rule;
      loop
         fetch csr_rule into rcd_rule;
         if csr_rule%notfound then
            exit;
         end if;
         if var_rule = false then
            var_query :=  var_query || ' and ((';
         else
            var_query :=  var_query || ' or (';
         end if;
         var_rule := true;
         var_detail := false;
         open csr_rule_detl;
         loop
            fetch csr_rule_detl into rcd_rule_detl;
            if csr_rule_detl%notfound then
               exit;
            end if;
            if var_detail = false then
               if rcd_rule_detl.rule_not = 'T' then
                  var_query := var_query || 'not(' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu) || ')';
               else
                  var_query := var_query || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu);
               end if;
            else
               if rcd_rule_detl.rule_not = 'T' then
                  var_query := var_query || ' and not(' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu) || ')';
               else
                  var_query := var_query || ' and ' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu);
               end if;
            end if;
            var_detail := true;
         end loop;
         close csr_rule_detl;
         var_query :=  var_query || ')';
      end loop;
      close csr_rule;
      if var_rule = true then
         var_query :=  var_query || ')';
      end if;

      /*-*/
      /* Close the query
      /*-*/
      var_query :=  var_query || ' and t1.matl_code not in (select t1.matl_code from report_matl t1 where t1.report_id = ' || rcd_report.report_id || ') order by t1.matl_code asc';

      /*-*/
      /* Load the report add materials
      /*-*/
      tbl_matl01.delete;
      open csr_material for var_query;
      loop
         fetch csr_material into var_matl_code, var_matl_desc;
         if csr_material%notfound then
            exit;
         end if;
         tbl_matl01(tbl_matl01.count+1).matl_code := var_matl_code;
         tbl_matl01(tbl_matl01.count).matl_desc := var_matl_desc;
      end loop;
      close csr_material;


      /*-*/
      /* Build the delete query statement (ie. report materials not in the report rule materials)
      /*-*/
      var_query := 'select t1.matl_code, nvl(t2.matl_desc,''*UNKNOWN'') as matl_desc
                      from report_matl t1, matl t2
                     where t1.matl_code = t2.matl_code(+)
                       and t1.report_id = ' || rcd_report.report_id || '
                       and t1.matl_code not in (select t1.matl_code
                                                  from matl t1, matl_by_sales_area t2
                                                 where t1.matl_code = t2.matl_code
                                                   and t2.sales_org = '''||rcd_report.price_sales_org_code||'''
                                                   and t2.dstrbtn_chnl = '''||rcd_report.price_distbn_chnl_code||'''';

      /*-*/
      /* Add the report rules
      /*-*/
      var_rule := false;
      open csr_rule;
      loop
         fetch csr_rule into rcd_rule;
         if csr_rule%notfound then
            exit;
         end if;
         if var_rule = false then
            var_query :=  var_query || ' and ((';
         else
            var_query :=  var_query || ' or (';
         end if;
         var_rule := true;
         var_detail := false;
         open csr_rule_detl;
         loop
            fetch csr_rule_detl into rcd_rule_detl;
            if csr_rule_detl%notfound then
               exit;
            end if;
            if var_detail = false then
               if rcd_rule_detl.rule_not = 'T' then
                  var_query := var_query || 'not(' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu) || ')';
               else
                  var_query := var_query || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu);
               end if;
            else
               if rcd_rule_detl.rule_not = 'T' then
                  var_query := var_query || ' and not(' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu) || ')';
               else
                  var_query := var_query || ' and ' || replace(rcd_rule_detl.sql_where,'<SQLVALUE>',rcd_rule_detl.rule_vlu);
               end if;
            end if;
            var_detail := true;
         end loop;
         close csr_rule_detl;
         var_query :=  var_query || ')';
      end loop;
      close csr_rule;
      if var_rule = true then
         var_query :=  var_query || ')';
      end if;

      /*-*/
      /* Close the query
      /*-*/
      var_query :=  var_query || ') order by t1.matl_code asc';

      /*-*/
      /* Load the report delete materials
      /*-*/
      tbl_matl02.delete;
      open csr_material for var_query;
      loop
         fetch csr_material into var_matl_code, var_matl_desc;
         if csr_material%notfound then
            exit;
         end if;
         tbl_matl02(tbl_matl02.count+1).matl_code := var_matl_code;
         tbl_matl02(tbl_matl02.count).matl_desc := var_matl_desc;
      end loop;
      close csr_material;

      /*-*/
      /* Log the event when no email generated
      /*-*/
      if tbl_matl01.count = 0 and tbl_matl02.count = 0 then
         if par_Update = 'N' then
            lics_logging.write_log('No price list material recommendations for report (' || rcd_report.report_name || ')');
         else
            lics_logging.write_log('No price list automatic material updates for report (' || rcd_report.report_name || ')');
         end if;
      end if;

      /*-*/
      /* Create the notification email when recommendations exist
      /*-*/
      if tbl_matl01.count != 0 or tbl_matl02.count != 0 then

         /*-*/
         /* Log event
         /*-*/
         if par_Update = 'N' then
            lics_logging.write_log('Sending price list material recommendation notification email for report (' || rcd_report.report_name || ') to ' || rcd_report.email_address);
         else
            lics_logging.write_log('Sending price list automatic material update notification email for report (' || rcd_report.report_name || ') to ' || rcd_report.email_address);
         end if;

         /*-*/
         /* Create the new email and create the email text header part
         /*-*/
         if par_Update = 'N' then
            lics_mailer.create_email(lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment,
                                     rcd_report.email_address,
                                     'Price List Report - ' || rcd_report.report_name || ' - Material Recommendations',
                                     null,
                                     null);
            lics_mailer.create_part(null);
            lics_mailer.append_data('Price List Report - ' || rcd_report.report_name || ' - Material Recommendations');
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
         else
            lics_mailer.create_email(lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment,
                                     rcd_report.email_address,
                                     'Price List Report - ' || rcd_report.report_name || ' - Automatic Material Updates',
                                     null,
                                     null);
            lics_mailer.create_part(null);
            lics_mailer.append_data('Price List Report - ' || rcd_report.report_name || ' - Automatic Material Updates');
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
         end if;

         /*-*/
         /* Create the email file and output the header data
         /*-*/
         if par_Update = 'N' then
            lics_mailer.create_part('Price_List_Material_Recommendations.xls');
            lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
            lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
            lics_mailer.append_data('<tr>');
            lics_mailer.append_data('<td align=center colspan=3 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Price List Report - ' || rcd_report.report_name || ' - Material Recommendations</td>');
            lics_mailer.append_data('</tr>');
         else
            lics_mailer.create_part('Price_List_Automatic_Material_Updates.xls');
            lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
            lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
            lics_mailer.append_data('<tr>');
            lics_mailer.append_data('<td align=center colspan=3 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Price List Report - ' || rcd_report.report_name || ' - Automatic Material Updates</td>');
            lics_mailer.append_data('</tr>');
         end if;

         /*-*/
         /* Output the header
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('</tr>');
         lics_mailer.append_data('<tr>');
         if par_Update = 'N' then
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Recommendation</td>');
         else
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Action</td>');
         end if;
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Material Code</td>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Material Name</td>');
         lics_mailer.append_data('</tr>');

         /*-*/
         /* Append the additions
         /*-*/
         for idx in 1..tbl_matl01.count loop
            lics_mailer.append_data('<tr>');
            if par_Update = 'N' then
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;">ADD</td>');
            else
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;">ADDED</td>');
            end if;
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||tbl_matl01(idx).matl_code||'</td>');
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||tbl_matl01(idx).matl_desc||'</td>');
            lics_mailer.append_data('</tr>');
         end loop;

         /*-*/
         /* Append the deletions
         /*-*/
         for idx in 1..tbl_matl02.count loop
            lics_mailer.append_data('<tr>');
            if par_Update = 'N' then
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;">DELETE</td>');
            else
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;">DELETED</td>');
            end if;
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||tbl_matl02(idx).matl_code||'</td>');
            lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||tbl_matl02(idx).matl_desc||'</td>');
            lics_mailer.append_data('</tr>');
         end loop;

         /*-*/
         /* Output the email file part trailer data
         /*-*/
         lics_mailer.append_data('</table>');
         lics_mailer.create_part(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data('** Email End **');
         lics_mailer.finalise_email('utf-8');

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_materials;

end pricelist_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_configuration for pr_app.pricelist_configuration;
grant execute on pricelist_configuration to public;