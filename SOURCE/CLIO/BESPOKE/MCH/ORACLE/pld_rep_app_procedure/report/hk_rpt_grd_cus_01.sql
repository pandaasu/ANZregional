/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_rpt_grd_cus_01                                  */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : April 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_rpt_grd_cus_01 as

/**DESCRIPTION**
 GRD Customer Hierarchy Report.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2) return varchar2;

end hk_rpt_grd_cus_01;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_rpt_grd_cus_01 as

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the GRD customer report
      /*-*/
      hk_grd_cus_excel.start_report(par_company_code);

      /*-*/
      /* Customer sheet
      /*-*/
      hk_grd_cus_excel.define_sheet('Customer',4);
      hk_grd_cus_excel.start_sheet('Customer Hierarchy Report');
      hk_grd_cus_excel.set_hierarchy(1,'STD_HIER01',false);
      hk_grd_cus_excel.set_hierarchy(2,'STD_HIER02',false);
      hk_grd_cus_excel.set_hierarchy(3,'STD_HIER03',false);
      hk_grd_cus_excel.set_hierarchy(4,'STD_HIER04',false);
      hk_grd_cus_excel.retrieve_data;
      hk_grd_cus_excel.end_sheet;

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

end hk_rpt_grd_cus_01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_rpt_grd_cus_01 for pld_rep_app.hk_rpt_grd_cus_01;
grant execute on hk_rpt_grd_cus_01 to public;