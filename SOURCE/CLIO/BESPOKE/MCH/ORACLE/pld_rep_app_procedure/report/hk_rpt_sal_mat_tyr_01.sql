/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_rpt_sal_mat_tyr_01                              */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : April 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_rpt_sal_mat_tyr_01 as

/**DESCRIPTION**
 Material Combined Business YEE Report.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD_BR = Period BR forecast
                  PRD_RB = Period ROB forecast
                  MTH_BR = Month BR forecast
                  MTH_RB = Month ROB forecast
 par_val_type = Value type (mandatory)
                  QTY = quantity
                  TON = tonnes
                  GSV = gross sale value
                  NIV = net invoice value

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2, par_for_type in varchar2, par_val_type in varchar2) return varchar2;

end hk_rpt_sal_mat_tyr_01;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_rpt_sal_mat_tyr_01 as

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_prd_br(par_company_code in varchar2, par_val_type in varchar2);
   procedure do_prd_rb(par_company_code in varchar2, par_val_type in varchar2);
   procedure do_mth_br(par_company_code in varchar2, par_val_type in varchar2);
   procedure do_mth_rb(par_company_code in varchar2, par_val_type in varchar2);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2, par_for_type in varchar2, par_val_type in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the requested report method
      /*-*/
      if par_for_type = 'PRD_BR' then
         do_prd_br(par_company_code, par_val_type);
      elsif par_for_type = 'PRD_RB' then
         do_prd_rb(par_company_code, par_val_type);
      elsif par_for_type = 'MTH_BR' then
         do_mth_br(par_company_code, par_val_type);
      elsif par_for_type = 'MTH_RB' then
         do_mth_rb(par_company_code, par_val_type);
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
   procedure do_prd_br(par_company_code in varchar2, par_val_type in varchar2) is

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
      var_string := 'Material Combined Business YEE - Period - BR Forecast';
      if par_val_type = 'QTY' then
         var_string := var_string || ' - Quantity - Billing Date';
      elsif par_val_type = 'TON' then
         var_string := var_string || ' - Tonnes - Billing Date';
      elsif par_val_type = 'GSV' then
         var_string := var_string || ' - Gross Sales Value (HK$ Thousands) - Billing Date';
      elsif par_val_type = 'NIV' then
         var_string := var_string || ' - Net Invoice Value (HK$ Thousands) - Billing Date';
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_prd_12_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_prd_12_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns based on parameters
      /*-*/
      if par_val_type = 'QTY' then
         hk_sal_mat_prd_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ABR_QTY',null,3,3,1);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_LY_QTY','% Growth',null,null,null);
      elsif par_val_type = 'TON' then
         hk_sal_mat_prd_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ABR_TON',null,null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_TON','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_TON','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_OP_TON','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_LY_TON','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_OP_TON','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_LY_TON','% Growth',null,null,null);
      elsif par_val_type = 'GSV' then
         hk_sal_mat_prd_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ABR_GSV',null,3,5,1000);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_LY_GSV','% Growth',null,null,null);
      elsif par_val_type = 'NIV' then
         hk_sal_mat_prd_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ABR_NIV',null,3,5,1000);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_BR_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TB_LY_NIV','% Growth',null,null,null);
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_prd_12_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_prd_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_prd_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_prd_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_prd_12_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_prd_br;

   /*********************************************************/
   /* This procedure performs the period ROB report routine */
   /*********************************************************/
   procedure do_prd_rb(par_company_code in varchar2, par_val_type in varchar2) is

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
      var_string := 'Material Combined Business YEE - Period - ROB Forecast';
      if par_val_type = 'QTY' then
         var_string := var_string || ' - Quantity - Billing Date';
      elsif par_val_type = 'TON' then
         var_string := var_string || ' - Tonnes - Billing Date';
      elsif par_val_type = 'GSV' then
         var_string := var_string || ' - Gross Sales Value (HK$ Thousands) - Billing Date';
      elsif par_val_type = 'NIV' then
         var_string := var_string || ' - Net Invoice Value (HK$ Thousands) - Billing Date';
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_prd_12_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_prd_12_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns based on parameters
      /*-*/
      if par_val_type = 'QTY' then
         hk_sal_mat_prd_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ARB_QTY',null,3,3,1);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_LY_QTY','% Growth',null,null,null);
      elsif par_val_type = 'TON' then
         hk_sal_mat_prd_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ARB_TON',null,null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_TON','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_TON','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_OP_TON','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_LY_TON','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_OP_TON','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_LY_TON','% Growth',null,null,null);
      elsif par_val_type = 'GSV' then
         hk_sal_mat_prd_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ARB_GSV',null,3,5,1000);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_LY_GSV','% Growth',null,null,null);
      elsif par_val_type = 'NIV' then
         hk_sal_mat_prd_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_ARB_NIV',null,3,5,1000);
         hk_sal_mat_prd_12_excel.add_group('YTD');
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTD_TY_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YTG');
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YTG_RB_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_TR_LY_NIV','% Growth',null,null,null);
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_prd_12_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_prd_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_prd_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_prd_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_prd_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_prd_12_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_prd_rb;

   /*******************************************************/
   /* This procedure performs the month BR report routine */
   /*******************************************************/
   procedure do_mth_br(par_company_code in varchar2, par_val_type in varchar2) is

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
      var_string := 'Material Combined Business YEE - Month - BR Forecast';
      if par_val_type = 'QTY' then
         var_string := var_string || ' - Quantity - Billing Date';
      elsif par_val_type = 'TON' then
         var_string := var_string || ' - Tonnes - Billing Date';
      elsif par_val_type = 'GSV' then
         var_string := var_string || ' - Gross Sales Value (HK$ Thousands) - Billing Date';
      elsif par_val_type = 'NIV' then
         var_string := var_string || ' - Net Invoice Value (HK$ Thousands) - Billing Date';
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_mth_12_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_mth_12_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns based on parameters
      /*-*/
      if par_val_type = 'QTY' then
         hk_sal_mat_mth_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ABR_QTY',null,3,3,1);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_LY_QTY','% Growth',null,null,null);
      elsif par_val_type = 'TON' then
         hk_sal_mat_mth_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ABR_TON',null,null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_TON','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_TON','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_OP_TON','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_LY_TON','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_OP_TON','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_LY_TON','% Growth',null,null,null);
      elsif par_val_type = 'GSV' then
         hk_sal_mat_mth_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ABR_GSV',null,3,5,1000);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_LY_GSV','% Growth',null,null,null);
      elsif par_val_type = 'NIV' then
         hk_sal_mat_mth_12_excel.add_group('Actual + BR Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ABR_NIV',null,3,5,1000);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_BR_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TB_LY_NIV','% Growth',null,null,null);
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_mth_12_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_mth_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_mth_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_mth_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_mth_12_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_mth_br;

   /********************************************************/
   /* This procedure performs the month ROB report routine */
   /********************************************************/
   procedure do_mth_rb(par_company_code in varchar2, par_val_type in varchar2) is

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
      var_string := 'Material Combined Business YEE - Month - ROB Forecast';
      if par_val_type = 'QTY' then
         var_string := var_string || ' - Quantity - Billing Date';
      elsif par_val_type = 'TON' then
         var_string := var_string || ' - Tonnes - Billing Date';
      elsif par_val_type = 'GSV' then
         var_string := var_string || ' - Gross Sales Value (HK$ Thousands) - Billing Date';
      elsif par_val_type = 'NIV' then
         var_string := var_string || ' - Net Invoice Value (HK$ Thousands) - Billing Date';
      end if;

      /*-*/
      /* Start the report
      /*-*/
      hk_sal_mat_mth_12_excel.start_report(par_company_code);

      /*-*/
      /* Define sheet
      /*-*/
      hk_sal_mat_mth_12_excel.define_sheet('Report',9);

      /*-*/
      /* Add the columns based on parameters
      /*-*/
      if par_val_type = 'QTY' then
         hk_sal_mat_mth_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ARB_QTY',null,3,3,1);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_LY_QTY','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_OP_QTY','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_LY_QTY','% Growth',null,null,null);
      elsif par_val_type = 'TON' then
         hk_sal_mat_mth_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ARB_TON',null,null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_TON','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_TON','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_OP_TON','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_LY_TON','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_OP_TON','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_LY_TON','% Growth',null,null,null);
      elsif par_val_type = 'GSV' then
         hk_sal_mat_mth_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ARB_GSV',null,3,5,1000);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_LY_GSV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_OP_GSV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_LY_GSV','% Growth',null,null,null);
      elsif par_val_type = 'NIV' then
         hk_sal_mat_mth_12_excel.add_group('Actual + ROB Forecast');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_ARB_NIV',null,3,5,1000);
         hk_sal_mat_mth_12_excel.add_group('YTD');
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTD_TY_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YTG');
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YTG_RB_LY_NIV','% Growth',null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_OP_NIV','% Plan',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_TR_LY_NIV','% Growth',null,null,null);
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_mth_12_excel.start_sheet(var_string);

      /*-*/
      /* Snackfood data
      /*-*/
      hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
      hk_sal_mat_mth_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(5,'INGRED_VRTY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* Food data
      /*-*/
      hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
      hk_sal_mat_mth_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(3,'BDT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(4,'BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(5,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* Petcare data
      /*-*/
      hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
      hk_sal_mat_mth_12_excel.set_hierarchy(1,'COMPANY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(2,'BUS_SGMNT',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(3,'BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(5,'SUB_BRAND',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(6,'CNSMR_PACK',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(7,'PACK_SIZE',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(8,'REP_ITEM',false);
      hk_sal_mat_mth_12_excel.set_hierarchy(9,'MATERIAL',false);
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_mth_12_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_mth_rb;

end hk_rpt_sal_mat_tyr_01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_rpt_sal_mat_tyr_01 for pld_rep_app.hk_rpt_sal_mat_tyr_01;
grant execute on hk_rpt_sal_mat_tyr_01 to public;