/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_rpt_sal_mat_tyr_04                              */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : April 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_rpt_sal_mat_tyr_04 as

/**DESCRIPTION**
 Material Operating Plan Report.

 **PARAMETERS**
 par_company_code = SAP company code (mandatory)
 par_bus_sgmnt_code = SAP business segment code (mandatory)
 par_for_type = Forecast type (mandatory)
                  PRD = Period
                  MTH = Month
 par_val_type = Value type (mandatory)
                  QTY = quantity
                  TON = tonnes
                  GSV = gross sale value
                  NIV = net invoice value

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_company_code in varchar2, par_bus_sgmnt_code in varchar2, par_for_type in varchar2, par_val_type in varchar2) return varchar2;

end hk_rpt_sal_mat_tyr_04;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_rpt_sal_mat_tyr_04 as

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_prd(par_company_code in varchar2, par_bus_sgmnt_code in varchar2, par_val_type in varchar2);
   procedure do_mth(par_company_code in varchar2, par_bus_sgmnt_code in varchar2, par_val_type in varchar2);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_company_code in varchar2, par_bus_sgmnt_code in varchar2, par_for_type in varchar2, par_val_type in varchar2) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the requested report method
      /*-*/
      if par_for_type = 'PRD' then
         do_prd(par_company_code, par_bus_sgmnt_code, par_val_type);
      elsif par_for_type = 'MTH' then
         do_mth(par_company_code, par_bus_sgmnt_code, par_val_type);
      end if;

      /*-*/
      /* Must return *OK when successful
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /*****************************************************/
   /* This procedure performs the period report routine */
   /*****************************************************/
   procedure do_prd(par_company_code in varchar2, par_bus_sgmnt_code in varchar2, par_val_type in varchar2) is

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
      var_string := 'Material Operating Plan - Period';
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
      hk_sal_mat_prd_12_excel.define_sheet('Report',8);

      /*-*/
      /* Add the columns based on parameters
      /*-*/
      if par_val_type = 'QTY' then
         hk_sal_mat_prd_12_excel.add_group('Operating Plan');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_TOP_QTY',null,3,3,1);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_QTY','Value',3,3,1);
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_LY_QTY','% Growth',null,null,null);
      elsif par_val_type = 'TON' then
         hk_sal_mat_prd_12_excel.add_group('Operating Plan');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_TOP_TON',null,null,null,null);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_TON','Value',null,null,null);
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_LY_TON','% Growth',null,null,null);
      elsif par_val_type = 'GSV' then
         hk_sal_mat_prd_12_excel.add_group('Operating Plan');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_TOP_GSV',null,3,5,1000);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_GSV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_LY_GSV','% Growth',null,null,null);
      elsif par_val_type = 'NIV' then
         hk_sal_mat_prd_12_excel.add_group('Operating Plan');
         hk_sal_mat_prd_12_excel.add_column('PRD0113_TOP_NIV',null,3,5,1000);
         hk_sal_mat_prd_12_excel.add_group('YEE');
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_NIV','Value',3,5,1000);
         hk_sal_mat_prd_12_excel.add_column('YEE_OP_LY_NIV','% Growth',null,null,null);
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_prd_12_excel.start_sheet(var_string);

      /*-*/
      /* Business segment
      /*-*/
      if par_bus_sgmnt_code = '01' then
         hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
         hk_sal_mat_prd_12_excel.set_hierarchy(1,'BUS_SGMNT',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(2,'BDT',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(3,'BRAND',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(4,'INGRED_VRTY',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(6,'PACK_SIZE',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(7,'REP_ITEM',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(8,'MATERIAL',false);
      elsif par_bus_sgmnt_code = '02' then
         hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
         hk_sal_mat_prd_12_excel.set_hierarchy(1,'BUS_SGMNT',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(2,'BDT',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(3,'BRAND',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(6,'PACK_SIZE',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(7,'REP_ITEM',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(8,'MATERIAL',false);
      elsif par_bus_sgmnt_code = '05' then
         hk_sal_mat_prd_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
         hk_sal_mat_prd_12_excel.set_hierarchy(1,'BUS_SGMNT',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(2,'BRAND',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(3,'PRDCT_CTGRY',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(4,'SUB_BRAND',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(6,'PACK_SIZE',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(7,'REP_ITEM',false);
         hk_sal_mat_prd_12_excel.set_hierarchy(8,'MATERIAL',false);
      end if;

      /*-*/
      /* Retrieve data
      /*-*/
      hk_sal_mat_prd_12_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_prd_12_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_prd;

   /****************************************************/
   /* This procedure performs the month report routine */
   /****************************************************/
   procedure do_mth(par_company_code in varchar2, par_bus_sgmnt_code in varchar2, par_val_type in varchar2) is

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
      var_string := 'Material Operating Plan - Month';
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
      hk_sal_mat_mth_12_excel.define_sheet('Report',8);

      /*-*/
      /* Add the columns based on parameters
      /*-*/
      if par_val_type = 'QTY' then
         hk_sal_mat_mth_12_excel.add_group('Operating Plan');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_TOP_QTY',null,3,3,1);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_QTY','Value',3,3,1);
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_LY_QTY','% Growth',null,null,null);
      elsif par_val_type = 'TON' then
         hk_sal_mat_mth_12_excel.add_group('Operating Plan');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_TOP_TON',null,null,null,null);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_TON','Value',null,null,null);
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_LY_TON','% Growth',null,null,null);
      elsif par_val_type = 'GSV' then
         hk_sal_mat_mth_12_excel.add_group('Operating Plan');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_TOP_GSV',null,3,5,1000);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_GSV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_LY_GSV','% Growth',null,null,null);
      elsif par_val_type = 'NIV' then
         hk_sal_mat_mth_12_excel.add_group('Operating Plan');
         hk_sal_mat_mth_12_excel.add_column('MTH0112_TOP_NIV',null,3,5,1000);
         hk_sal_mat_mth_12_excel.add_group('YEE');
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_NIV','Value',3,5,1000);
         hk_sal_mat_mth_12_excel.add_column('YEE_OP_LY_NIV','% Growth',null,null,null);
      end if;

      /*-*/
      /* Start the sheet
      /*-*/
      hk_sal_mat_mth_12_excel.start_sheet(var_string);

      /*-*/
      /* Business segment
      /*-*/
      if par_bus_sgmnt_code = '01' then
         hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','01');
         hk_sal_mat_mth_12_excel.set_hierarchy(1,'BUS_SGMNT',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(2,'BDT',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(3,'BRAND',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(4,'INGRED_VRTY',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(6,'PACK_SIZE',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(7,'REP_ITEM',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(8,'MATERIAL',false);
      elsif par_bus_sgmnt_code = '02' then
         hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','02');
         hk_sal_mat_mth_12_excel.set_hierarchy(1,'BUS_SGMNT',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(2,'BDT',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(3,'BRAND',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(4,'PRDCT_CTGRY',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(6,'PACK_SIZE',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(7,'REP_ITEM',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(8,'MATERIAL',false);
      elsif par_bus_sgmnt_code = '05' then
         hk_sal_mat_mth_12_excel.set_parameter_string('BUS_SGMNT_CODE','05');
         hk_sal_mat_mth_12_excel.set_hierarchy(1,'BUS_SGMNT',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(2,'BRAND',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(3,'PRDCT_CTGRY',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(4,'SUB_BRAND',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(5,'CNSMR_PACK',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(6,'PACK_SIZE',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(7,'REP_ITEM',false);
         hk_sal_mat_mth_12_excel.set_hierarchy(8,'MATERIAL',false);
      end if;

      /*-*/
      /* Retrieve data
      /*-*/
      hk_sal_mat_mth_12_excel.retrieve_data;

      /*-*/
      /* End the sheet
      /*-*/
      hk_sal_mat_mth_12_excel.end_sheet;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_mth;

end hk_rpt_sal_mat_tyr_04;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_rpt_sal_mat_tyr_04 for pld_rep_app.hk_rpt_sal_mat_tyr_04;
grant execute on hk_rpt_sal_mat_tyr_04 to public;