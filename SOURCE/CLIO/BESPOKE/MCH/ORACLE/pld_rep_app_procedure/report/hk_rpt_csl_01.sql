/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_rpt_csl_01                                      */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : May 2006                                           */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_rpt_csl_01 as

/**DESCRIPTION**
 Customer Service Level Report - Finished Goods - Previous Period.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2) return varchar2;

end hk_rpt_csl_01;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_rpt_csl_01 as

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Start the report
      /*-*/
      hk_csl_prd_11_excel.start_report(par_company_code,'FERT');

      /*-*/
      /* Define sheet - Case Fill
      /*-*/
      hk_csl_prd_11_excel.define_sheet('Case Fill',5,'01');

      /*-*/
      /* Add the columns
      /*-*/
      hk_csl_prd_11_excel.add_group(null);
      hk_csl_prd_11_excel.add_column('PRD_CF_PCT','Case Fill %',null,null,null);
      hk_csl_prd_11_excel.add_column('PRD_ORD_QTY','Order Qty',2,2,null);
      hk_csl_prd_11_excel.add_column('PRD_DEL_QTY','Delivered Qty',2,2,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_csl_prd_11_excel.start_sheet('Customer Service Level - Finished Goods - Previous Period Case Fill', 'CASE');

      /*-*/
      /* Retrieve data
      /*-*/
      hk_csl_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_csl_prd_11_excel.set_hierarchy(2,'STD_HIER01',false);
      hk_csl_prd_11_excel.set_hierarchy(3,'STD_HIER02',false);
      hk_csl_prd_11_excel.set_hierarchy(4,'STD_HIER03',false);
      hk_csl_prd_11_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
      hk_csl_prd_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_csl_prd_11_excel.end_sheet;

      /*-*/
      /* Define sheet - Order Fill
      /*-*/
      hk_csl_prd_11_excel.define_sheet('Order Fill',5,'02');

      /*-*/
      /* Add the columns
      /*-*/
      hk_csl_prd_11_excel.add_group(null);
      hk_csl_prd_11_excel.add_column('PRD_OF_PCT','Order Fill %',null,null,null);
      hk_csl_prd_11_excel.add_column('TOT_ORD_CNT','Total Orders',2,2,null);
      hk_csl_prd_11_excel.add_column('FIL_ORD_CNT','Filled Orders',2,2,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_csl_prd_11_excel.start_sheet('Customer Service Level - Finished Goods - Previous Period Order Fill', 'ORDER');

      /*-*/
      /* Retrieve data
      /*-*/
      hk_csl_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_csl_prd_11_excel.set_hierarchy(2,'STD_HIER01',false);
      hk_csl_prd_11_excel.set_hierarchy(3,'STD_HIER02',false);
      hk_csl_prd_11_excel.set_hierarchy(4,'STD_HIER03',false);
      hk_csl_prd_11_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
      hk_csl_prd_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_csl_prd_11_excel.end_sheet;

      /*-*/
      /* Define sheet - Delivery Rate
      /*-*/
      hk_csl_prd_11_excel.define_sheet('Delivery Completion Rate',5,'01');

      /*-*/
      /* Add the columns
      /*-*/
      hk_csl_prd_11_excel.add_group(null);
      hk_csl_prd_11_excel.add_column('PRD_DR_PCT','Delivery Completion %',null,null,null);
      hk_csl_prd_11_excel.add_column('PRD_DEL_QTY','Delivery Qty',2,2,null);
      hk_csl_prd_11_excel.add_column('PRD_POD_QTY','POD Qty',2,2,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_csl_prd_11_excel.start_sheet('Customer Service Level - Finished Goods - Previous Period Delivery Completion Rate', 'DELIVERY');

      /*-*/
      /* Retrieve data
      /*-*/
      hk_csl_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_csl_prd_11_excel.set_hierarchy(2,'STD_HIER01',false);
      hk_csl_prd_11_excel.set_hierarchy(3,'STD_HIER02',false);
      hk_csl_prd_11_excel.set_hierarchy(4,'STD_HIER03',false);
      hk_csl_prd_11_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
      hk_csl_prd_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_csl_prd_11_excel.end_sheet;

      /*-*/
      /* Define sheet - On-Time Rate
      /*-*/
      hk_csl_prd_11_excel.define_sheet('On-Time Rate',5,'02');

      /*-*/
      /* Add the columns
      /*-*/
      hk_csl_prd_11_excel.add_group(null);
      hk_csl_prd_11_excel.add_column('PRD_OT_PCT','On-Time %',null,null,null);
      hk_csl_prd_11_excel.add_column('TOT_ORD_CNT','Total Orders',2,2,null);
      hk_csl_prd_11_excel.add_column('ONT_ORD_CNT','On-Time Orders',2,2,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_csl_prd_11_excel.start_sheet('Customer Service Level - Finished Goods - Previous Period On-Time Rate', 'ONTIME');

      /*-*/
      /* Retrieve data
      /*-*/
      hk_csl_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_csl_prd_11_excel.set_hierarchy(2,'STD_HIER01',false);
      hk_csl_prd_11_excel.set_hierarchy(3,'STD_HIER02',false);
      hk_csl_prd_11_excel.set_hierarchy(4,'STD_HIER03',false);
      hk_csl_prd_11_excel.set_hierarchy(5,'SHIP_TO_CUSTOMER',false);
      hk_csl_prd_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_csl_prd_11_excel.end_sheet;

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

end hk_rpt_csl_01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_rpt_csl_01 for pld_rep_app.hk_rpt_csl_01;
grant execute on hk_rpt_csl_01 to public;