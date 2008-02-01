/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_rpt_002                                     */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2007                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_rpt_002 as

/**DESCRIPTION**
 GRD Material Hierarchy Report - TDU.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2) return varchar2;

end hk_sal_rpt_002;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_rpt_002 as

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the GRD material report
      /*-*/
      hk_sal_rpt_002_excel.start_report(par_company_code);

      /*-*/
      /* Snackfood sheet
      /*-*/
      hk_sal_rpt_002_excel.define_sheet('Snackfood',8);
      hk_sal_rpt_002_excel.start_sheet('Material Hierarchy Report');
      hk_sal_rpt_002_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_rpt_002_excel.set_hierarchy(1,'BUS_SGMNT',false);
      hk_sal_rpt_002_excel.set_hierarchy(2,'BDT',false);
      hk_sal_rpt_002_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_rpt_002_excel.set_hierarchy(4,'PACK_SIZE',false);
      hk_sal_rpt_002_excel.set_hierarchy(5,'PACK_SIZE',false);
      hk_sal_rpt_002_excel.set_hierarchy(6,'PACK_SIZE',false);
      hk_sal_rpt_002_excel.set_hierarchy(7,'REP_ITEM',false);
      hk_sal_rpt_002_excel.set_hierarchy(8,'MATERIAL',false);
      hk_sal_rpt_002_excel.retrieve_data;
      hk_sal_rpt_002_excel.end_sheet;

      /*-*/
      /* Food sheet
      /*-*/
      hk_sal_rpt_002_excel.define_sheet('Food',8);
      hk_sal_rpt_002_excel.start_sheet('Material Hierarchy Report');
      hk_sal_rpt_002_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_rpt_002_excel.set_hierarchy(1,'BUS_SGMNT',false);
      hk_sal_rpt_002_excel.set_hierarchy(2,'BDT',false);
      hk_sal_rpt_002_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_rpt_002_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_rpt_002_excel.set_hierarchy(5,'CNSMR_PACK',false);
      hk_sal_rpt_002_excel.set_hierarchy(6,'PACK_SIZE',false);
      hk_sal_rpt_002_excel.set_hierarchy(7,'REP_ITEM',false);
      hk_sal_rpt_002_excel.set_hierarchy(8,'MATERIAL',false);
      hk_sal_rpt_002_excel.retrieve_data;
      hk_sal_rpt_002_excel.end_sheet;

      /*-*/
      /* Petcare sheet
      /*-*/
      hk_sal_rpt_002_excel.define_sheet('Petcare',8);
      hk_sal_rpt_002_excel.start_sheet('Material Hierarchy Report');
      hk_sal_rpt_002_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_rpt_002_excel.set_hierarchy(1,'BUS_SGMNT',false);
      hk_sal_rpt_002_excel.set_hierarchy(2,'BRAND',false);
      hk_sal_rpt_002_excel.set_hierarchy(3,'PRDCT_CTGRY',false);
      hk_sal_rpt_002_excel.set_hierarchy(4,'CNSMR_PACK',false);
      hk_sal_rpt_002_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_rpt_002_excel.set_hierarchy(6,'PACK_SIZE',false);
      hk_sal_rpt_002_excel.set_hierarchy(7,'REP_ITEM',false);
      hk_sal_rpt_002_excel.set_hierarchy(8,'MATERIAL',false);
      hk_sal_rpt_002_excel.retrieve_data;
      hk_sal_rpt_002_excel.end_sheet;

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

end hk_sal_rpt_002;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_rpt_002 for pld_rep_app.hk_sal_rpt_002;
grant execute on hk_sal_rpt_002 to public;
