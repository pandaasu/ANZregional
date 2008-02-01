/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_rpt_sal_mat_day_01                              */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : April 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_rpt_sal_mat_day_01 as

/**DESCRIPTION**
 Material Combined DBP Report.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_RB = Period ROB forecast
                  MTH_BR = Month BR forecast
                  MTH_RB = Month ROB forecast

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2, par_for_type in varchar2) return varchar2;

end hk_rpt_sal_mat_day_01;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_rpt_sal_mat_day_01 as

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_prd_br(par_company_code in varchar2);
   procedure do_prd_rb(par_company_code in varchar2);
   procedure do_mth_br(par_company_code in varchar2);
   procedure do_mth_rb(par_company_code in varchar2);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2, par_for_type in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the requested report method
      /*-*/
      if par_for_type = 'PRD_BR' then
         do_prd_br(par_company_code);
      elsif par_for_type = 'PRD_RB' then
         do_prd_rb(par_company_code);
      elsif par_for_type = 'MTH_BR' then
         do_mth_br(par_company_code);
      elsif par_for_type = 'MTH_RB' then
         do_mth_rb(par_company_code);
      end if;

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /********************************************************/
   /* This procedure performs the period BR report routine */
   /********************************************************/
   procedure do_prd_br(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'Material Combined DBP Report - Period - BR Forecast (HK$ Thousands) - Billing Date';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_prd_11_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_prd_11_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns
      /*-*/
      hk_sal_mat_prd_11_excel.add_group('Daily');
      hk_sal_mat_prd_11_excel.add_column('CUR_DY_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('CUR_DY_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_group('PTD');
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_group('Plan');
      hk_sal_mat_prd_11_excel.add_column('PTD_OP_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_OP_QTY','QTY % Plan',null,null,null);
      hk_sal_mat_prd_11_excel.add_column('PTD_OP_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_OP_GSV','GSV % Plan',null,null,null);
      hk_sal_mat_prd_11_excel.add_group('BR');
      hk_sal_mat_prd_11_excel.add_column('PTD_BR_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_BR_QTY','QTY % BR',null,null,null);
      hk_sal_mat_prd_11_excel.add_column('PTD_BR_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_BR_GSV','GSV % BR',null,null,null);
      hk_sal_mat_prd_11_excel.add_group('SPLY');
      hk_sal_mat_prd_11_excel.add_column('PTD_LY_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_LY_QTY','QTY % SPLY',null,null,null);
      hk_sal_mat_prd_11_excel.add_column('PTD_LY_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_LY_GSV','GSV % SPLY',null,null,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_prd_11_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_prd_11_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_11_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_prd_11_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_11_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_prd_11_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_prd_11_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_prd_br;

   /*********************************************************/
   /* This procedure performs the period ROB report routine */
   /*********************************************************/
   procedure do_prd_rb(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'Material Combined DBP Report - Period - ROB Forecast (HK$ Thousands) - Billing Date';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_prd_11_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_prd_11_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns
      /*-*/
      hk_sal_mat_prd_11_excel.add_group('Daily');
      hk_sal_mat_prd_11_excel.add_column('CUR_DY_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('CUR_DY_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_group('PTD');
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_group('Plan');
      hk_sal_mat_prd_11_excel.add_column('PTD_OP_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_OP_QTY','QTY % Plan',null,null,null);
      hk_sal_mat_prd_11_excel.add_column('PTD_OP_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_OP_GSV','GSV % Plan',null,null,null);
      hk_sal_mat_prd_11_excel.add_group('ROB');
      hk_sal_mat_prd_11_excel.add_column('PTD_RB_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_RB_QTY','QTY % ROB',null,null,null);
      hk_sal_mat_prd_11_excel.add_column('PTD_RB_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_RB_GSV','GSV % ROB',null,null,null);
      hk_sal_mat_prd_11_excel.add_group('SPLY');
      hk_sal_mat_prd_11_excel.add_column('PTD_LY_QTY','QTY',3,3,1);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_LY_QTY','QTY % SPLY',null,null,null);
      hk_sal_mat_prd_11_excel.add_column('PTD_LY_GSV','GSV',3,5,1000);
      hk_sal_mat_prd_11_excel.add_column('PTD_TY_LY_GSV','GSV % SPLY',null,null,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_prd_11_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_prd_11_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_11_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_prd_11_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_11_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_prd_11_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_prd_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_prd_11_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_prd_rb;

   /*******************************************************/
   /* This procedure performs the month BR report routine */
   /*******************************************************/
   procedure do_mth_br(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'Material Combined DBP Report - Month - BR Forecast (HK$ Thousands) - Billing Date';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_mth_11_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_mth_11_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns
      /*-*/
      hk_sal_mat_mth_11_excel.add_group('Daily');
      hk_sal_mat_mth_11_excel.add_column('CUR_DY_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('CUR_DY_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_group('MTD');
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_group('Plan');
      hk_sal_mat_mth_11_excel.add_column('MTD_OP_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_OP_QTY','QTY % Plan',null,null,null);
      hk_sal_mat_mth_11_excel.add_column('MTD_OP_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_OP_GSV','GSV % Plan',null,null,null);
      hk_sal_mat_mth_11_excel.add_group('BR');
      hk_sal_mat_mth_11_excel.add_column('MTD_BR_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_BR_QTY','QTY % BR',null,null,null);
      hk_sal_mat_mth_11_excel.add_column('MTD_BR_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_BR_GSV','GSV % BR',null,null,null);
      hk_sal_mat_mth_11_excel.add_group('SMLY');
      hk_sal_mat_mth_11_excel.add_column('MTD_LY_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_LY_QTY','QTY % SMLY',null,null,null);
      hk_sal_mat_mth_11_excel.add_column('MTD_LY_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_LY_GSV','GSV % SMLY',null,null,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_mth_11_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_mth_11_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_mth_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_11_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_mth_11_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_mth_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_11_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_mth_11_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_mth_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_mth_11_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_mth_br;

   /********************************************************/
   /* This procedure performs the month ROB report routine */
   /********************************************************/
   procedure do_mth_rb(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_string varchar2(2048 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the report heading
      /*-*/
      var_string := 'Material Combined DBP Report - Month - ROB Forecast (HK$ Thousands) - Billing Date';

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_mth_11_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_mth_11_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns
      /*-*/
      hk_sal_mat_mth_11_excel.add_group('Daily');
      hk_sal_mat_mth_11_excel.add_column('CUR_DY_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('CUR_DY_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_group('MTD');
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_group('Plan');
      hk_sal_mat_mth_11_excel.add_column('MTD_OP_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_OP_QTY','QTY % Plan',null,null,null);
      hk_sal_mat_mth_11_excel.add_column('MTD_OP_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_OP_GSV','GSV % Plan',null,null,null);
      hk_sal_mat_mth_11_excel.add_group('ROB');
      hk_sal_mat_mth_11_excel.add_column('MTD_RB_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_RB_QTY','QTY % ROB',null,null,null);
      hk_sal_mat_mth_11_excel.add_column('MTD_RB_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_RB_GSV','GSV % ROB',null,null,null);
      hk_sal_mat_mth_11_excel.add_group('SMLY');
      hk_sal_mat_mth_11_excel.add_column('MTD_LY_QTY','QTY',3,3,1);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_LY_QTY','QTY % SMLY',null,null,null);
      hk_sal_mat_mth_11_excel.add_column('MTD_LY_GSV','GSV',3,5,1000);
      hk_sal_mat_mth_11_excel.add_column('MTD_TY_LY_GSV','GSV % SMLY',null,null,null);

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_mth_11_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_mth_11_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_mth_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_11_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_mth_11_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_mth_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_11_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_mth_11_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_mth_11_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_11_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_11_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_mth_11_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_mth_rb;

end hk_rpt_sal_mat_day_01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_rpt_sal_mat_day_01 for pld_rep_app.hk_rpt_sal_mat_day_01;
grant execute on hk_rpt_sal_mat_day_01 to public;