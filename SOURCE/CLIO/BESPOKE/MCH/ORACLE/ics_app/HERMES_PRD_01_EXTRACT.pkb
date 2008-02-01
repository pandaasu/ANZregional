CREATE OR REPLACE package body hermes_prd_01_extract as

   /*-*/
   /* Private global declarations
   /*-*/
   procedure exe_control_data;
   procedure exe_tp_data;
   procedure exe_tp_fcst_data;
   procedure createPeriodHeader(par_sap_company_code in varchar2,
                                par_sap_sold_to_cust_code in varchar2,
                                par_sap_material_code in varchar2,
                                par_hp0101_tp_type in varchar2);
   procedure createPeriodDetail(par_sap_company_code in varchar2,
                                par_sap_sold_to_cust_code in varchar2,
                                par_sap_material_code in varchar2,
                                par_hp0102_tp_type in varchar2,
                                par_dta_type in varchar2);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main return varchar2 is

      /*-*/
      /* Exception definitions
      /*-*/
      ApplicationError exception;
      pragma exception_init(ApplicationError, -20000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Truncate the data mart tables
      /**/
      hermes_truncate.truncate_table('hermes_prd_0100');
      hermes_truncate.truncate_table('hermes_prd_0101');
      hermes_truncate.truncate_table('hermes_prd_0102');
      commit;

      /**/
      /* Extract the control data
      /**/
      exe_control_data;
      commit;

		--Extract TP Actuals data
		exe_tp_data;
		commit;

		--Extract TP Forecast data
		exe_tp_fcst_data;
		commit;

      /*-*/
      /*- Return the status
      /**/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application error
      /*-*/
      when ApplicationError then
         return substr(SQLERRM, 1, 512);

      /*-*/
      /* Error trap
      /*-*/
      when others then
         return substr(SQLERRM, 1, 512);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /****************************************************/
   /* This procedure performs the control data routine */
   /****************************************************/
   procedure exe_control_data is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work_date date;
      var_current_yyyypp number(6,0);
      var_prd_asofdays varchar2(128 char);
      var_prd_percent number(5,2);
      var_current_yyyymm number(6,0);
      var_mth_asofdays varchar2(128 char);
      var_mth_percent number(5,2);
      var_extract_status varchar2(256 char);
      var_inventory_date date;
      var_inventory_status varchar2(256 char);
      var_sales_date date;
      var_sales_status varchar2(256 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the control information
      /* **NOTE** based on current day
      /*-*/
      mfjpln_control.main('*INV',
                          sysdate,
                          false,
                          var_work_date,
                          var_current_yyyypp,
                          var_prd_asofdays,
                          var_prd_percent,
                          var_current_yyyymm,
                          var_mth_asofdays,
                          var_mth_percent,
                          var_extract_status,
                          var_inventory_date,
                          var_inventory_status,
                          var_sales_date,
                          var_sales_status);

      /*-*/
      /* Insert the control extract data
      /*-*/
      insert into hermes_prd_0100
         (extract_date,
          logical_date,
          current_yyyypp,
          extract_status,
          sales_date,
          sales_status,
          prd_asofdays,
          prd_percent)
         values(sysdate,
                var_work_date,
                var_current_yyyypp,
                var_extract_status,
                var_sales_date,
                var_sales_status,
                var_prd_asofdays,
                var_prd_percent);
     /*insert into hermes_prd_0100
         (extract_date,
          logical_date,
          current_yyyypp,
          extract_status,
          sales_date,
          sales_status,
          prd_asofdays,
          prd_percent)
         values(sysdate - 10,
                sysdate - 10,
                200613,
                'Creation Date: 2007/01/02 As Of Date: 2007/01/02',
                '2006-12-25',
                'Sales Date: 2006/12/25 Status: OK',
                'Current Period: 2007/01 Current Date: 02/01/2007 Working Day: 2 of 20 (10.00%)',
                10.00);*/

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_control_data;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure exe_tp_data is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);
      var_start_yyyypp number(6,0);
      var_end_yyyypp number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      -- this is the tp actual costs
      cursor tp_actuals_on_c01 is
      	SELECT sap_company_code,
      				sap_sold_to_cust_code,
      				sap_material_code,
      				billing_yyyypp,
      				tp_type,
      				sum(tp_value) as tp_value
      	FROM (
	         SELECT t02.tph_com_code as sap_company_code,
	         		t02.tph_cust_level as sap_sold_to_cust_code,
	         		t02.tph_matl_level as sap_material_code,
	         		t02.tph_period as billing_yyyypp,
	         		t03.TPT_RPT_TYPE as tp_type,
				   	sum(nvl(t02.tph_act, 0) + nvl(t02.tph_curr_accr, 0) - nvl(t02.tph_new_accr, 0)) as tp_value
				FROM tp_header t02, tp_types t03
				WHERE t02.tph_tp_type = t03.TPT_TP_TYPE
					  and t02.tph_period >= var_start_yyyypp
					  and t02.tph_period <= var_end_yyyypp
				GROUP BY t02.tph_com_code,
							t02.tph_cust_level,
							t02.tph_matl_level,
							t02.tph_period,
							t03.TPT_RPT_TYPE
				union	all -- currently the below script is for cash discount only
				SELECT t01.tpca_com_code as sap_company_code,
					   t01.tpca_cust_code as sap_sold_to_cust_code,
					   t01.tpca_matl_code as sap_material_code,
					   t01.tpca_period as billing_yyyypp,
					   t03.tpt_rpt_type as tp_type,
					   sum(nvl(t01.tpca_act, 0)) as tp_value
				FROM tp_cash t01, tp_types t03
				WHERE t01.tpca_tp_type = t03.TPT_TP_TYPE
					  and t01.tpca_period >= var_start_yyyypp
					  and t01.tpca_period <= var_end_yyyypp
				GROUP BY t01.tpca_com_code,
					  	 t01.tpca_cust_code,
						 t01.tpca_matl_code,
						 t01.tpca_period,
						 t03.tpt_rpt_type
				union all
				SELECT t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp as billing_yyyypp,
				       'TD' as tp_type,
					   sum(- nvl(sales_dtl_price_value_3, 0)) as tp_value
				FROM sales_period_03_fact t01
				WHERE  t01.sap_billing_yyyypp >= var_start_yyyypp
				       and t01.sap_billing_yyyypp <= var_end_yyyypp
				       and nvl(t01.sales_dtl_price_value_3, 0) <> 0
				       and nvl(t01.SAP_ORDER_USAGE_CODE, 'UNKNOWN') not in ('085', '086', '087', '088', '003', '008', '045', '051', '052')
				GROUP BY t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp
				union all
				SELECT t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp billing_yyyypp,
				       'PD' as tp_type,
					   sum(- nvl(sales_dtl_price_value_4, 0)) as tp_value
				FROM sales_period_03_fact t01
				WHERE  t01.sap_billing_yyyypp >= var_start_yyyypp
				       and t01.sap_billing_yyyypp <= var_end_yyyypp
				       and nvl(t01.sales_dtl_price_value_4, 0) <> 0
				       and nvl(t01.SAP_ORDER_USAGE_CODE, 'UNKNOWN') not in ('085', '086', '087', '088', '003', '008', '045', '051', '052')
				GROUP BY t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp
				union all
				SELECT t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp billing_yyyypp,
				       'DA' as tp_type,
					   sum(- nvl(sales_dtl_price_value_5, 0)) as tp_value
				FROM sales_period_03_fact t01
				WHERE  t01.sap_billing_yyyypp >= var_start_yyyypp
				       and t01.sap_billing_yyyypp <= var_end_yyyypp
				       and nvl(t01.sales_dtl_price_value_5, 0) <> 0
				       and nvl(t01.SAP_ORDER_USAGE_CODE, 'UNKNOWN') not in ('085', '086', '087', '088', '003', '008', '045', '051', '052')
				GROUP BY t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp
				union all
				SELECT t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					    t01.sap_billing_yyyypp as billing_yyyypp,
				       'FG' as tp_type,
					   sum(- nvl(sales_dtl_price_value_7, 0)) as tp_value
				FROM sales_fact t01
				WHERE  t01.sap_billing_yyyypp >= var_start_yyyypp
				       and t01.sap_billing_yyyypp <= var_end_yyyypp
				       and nvl(t01.sales_dtl_price_value_7, 0) <> 0
				       and nvl(substr(nvl(t01.purch_order_num, ' '), -2, 2), '  ') <> '-S'
				       and nvl(substr(nvl(t01.purch_order_num, ' '), -2, 2), '  ') <> '-s'
				       and nvl(t01.SAP_ORDER_USAGE_CODE, 'UNKNOWN') not in ('085', '086', '087', '088', '003', '008', '045', '051', '052')
				GROUP BY t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp
				union all
				SELECT t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					    t01.sap_billing_yyyypp as billing_yyyypp,
				       'SS' as tp_type,
					   sum(- nvl(sales_dtl_price_value_7, 0)) as tp_value
				FROM sales_fact t01
				WHERE  t01.sap_billing_yyyypp >= var_start_yyyypp
				       and t01.sap_billing_yyyypp <= var_end_yyyypp
				       and nvl(t01.sales_dtl_price_value_7, 0) <> 0
						 and (nvl(substr(nvl(t01.purch_order_num, ' '), -2, 2), '  ') = '-S'
						 		or nvl(substr(nvl(t01.purch_order_num, ' '), -2, 2), '  ') = '-s')
						 and nvl(t01.SAP_ORDER_USAGE_CODE, 'UNKNOWN') not in ('085', '086', '087', '088', '003', '008', '045', '051', '052')
				GROUP BY t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp
				union all
				SELECT t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					    t01.sap_billing_yyyypp as billing_yyyypp,
				       'NSR' as tp_type,
					   sum(- nvl(sales_dtl_price_value_17, 0)) as tp_value
				FROM sales_fact t01
				WHERE  t01.sap_billing_yyyypp >= var_start_yyyypp
				       and t01.sap_billing_yyyypp <= var_end_yyyypp
				       and nvl(t01.sales_dtl_price_value_17, 0) <> 0
						 and t01.SAP_ORDER_USAGE_CODE in ('085', '086', '087', '088', '003', '008', '045', '051', '052')
				GROUP BY t01.sap_company_code,
				       t01.sap_sold_to_cust_code,
				       t01.sap_material_code,
					   t01.sap_billing_yyyypp
				)
			GROUP BY sap_company_code,
						sap_sold_to_cust_code,
						sap_material_code,
						billing_yyyypp,
						tp_type
			;
      tp_actuals_on_r01 tp_actuals_on_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date and period variables
      /*-*/
      select current_yyyypp into var_current_yyyypp from hermes_prd_0100;

      /*-*/
      /* Extract the period sales values - this year
      /*-*/
      -- previousPeriodStart(200605, false): 200601
      -- perviousPeriod(200605, false): 200604
      -- previousPeriodStart(200601, false): 200601
      -- perviousPeriod(200601, false): 200600
      -- previousPeriodStart(200601, true): 200501
      -- previousPeriodStart(200608, true): 200601
      -- perviousPeriod(200601, true): 200513
      -- perviousPeriod(200608, true): 200607
      -- previousPeriodEnd(200601, false):200613
      -- previousPeriodEnd(200601, true): 200513
      -- PreviousPeriodEnd(200608, false):200613
      -- PreviousPeriodEnd(200608, true): 200613
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
      --var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp, false);
      --var_end_yyyypp := mfjpln_control.previousPeriod(var_current_yyyypp, false);
      var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp, true);
      var_end_yyyypp := mfjpln_control.previousPeriod(var_current_yyyypp, true);
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
      open tp_actuals_on_c01;
      loop
         fetch tp_actuals_on_c01 into tp_actuals_on_r01;
         if tp_actuals_on_c01%notfound then
            exit;
         end if;

         createPeriodHeader(tp_actuals_on_r01.sap_company_code,
                            tp_actuals_on_r01.sap_sold_to_cust_code,
                            tp_actuals_on_r01.sap_material_code,
                            tp_actuals_on_r01.tp_type);

			-- this part is for the values in the current period
			-- you know, the var_current_yyyypp is the currrent working period
			-- but the current report period is (var_current_yyyypp - 1)
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
         --if tp_actuals_on_r01.billing_yyyypp = var_current_yyyypp - 1  then
         if tp_actuals_on_r01.billing_yyyypp = mfjpln_control.previousPeriod(var_current_yyyypp, true) then
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
            update hermes_prd_0101
               set cur_ty_tpv = tp_actuals_on_r01.tp_value,
                   ytd_ty_tpv = ytd_ty_tpv + tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0101_tp_type = tp_actuals_on_r01.tp_type;
         else	--if tp_actuals_on_r01.billing_yyyypp = var_current_yyyypp - 1,
         	-- the rest belongs to YTD actual, can you figure it out?
            update hermes_prd_0101
               set ytd_ty_tpv = ytd_ty_tpv + tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0101_tp_type = tp_actuals_on_r01.tp_type;
         end if;	--if tp_actuals_on_r01.billing_yyyypp = var_current_yyyypp - 1,

         if substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '01' then
            update hermes_prd_0102
               set p01_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p01_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '02' then
            update hermes_prd_0102
               set p02_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p02_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '03' then
            update hermes_prd_0102
               set p03_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p03_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '04' then
            update hermes_prd_0102
               set p04_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p04_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '05' then
            update hermes_prd_0102
               set p05_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p05_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '06' then
            update hermes_prd_0102
               set p06_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p06_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '07' then
            update hermes_prd_0102
               set p07_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p07_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '08' then
            update hermes_prd_0102
               set p08_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p08_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '09' then
            update hermes_prd_0102
               set p09_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p09_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '10' then
            update hermes_prd_0102
               set p10_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p10_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '11' then
            update hermes_prd_0102
               set p11_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p11_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '12' then
            update hermes_prd_0102
               set p12_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p12_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '13' then
            update hermes_prd_0102
               set p13_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'AOP';
            update hermes_prd_0102
               set p13_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
                 and dta_type = 'ABR';
         end if;

      end loop;
      close tp_actuals_on_c01;

      /*-*/
      /* Extract the period sales values - last year
      /*-*/
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
      --var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp-100, false);
      --var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp-100, false);
      var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp-100, true);
      var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp-100, true);
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
      open tp_actuals_on_c01;
      loop
         fetch tp_actuals_on_c01 into tp_actuals_on_r01;
         if tp_actuals_on_c01%notfound then
            exit;
         end if;

			-- in about lines, the var_current_yyyypp is used with (-100), so, here, we need to (+100) to get the right period
         tp_actuals_on_r01.billing_yyyypp := tp_actuals_on_r01.billing_yyyypp + 100;
         createPeriodHeader(tp_actuals_on_r01.sap_company_code,
                            tp_actuals_on_r01.sap_sold_to_cust_code,
                            tp_actuals_on_r01.sap_material_code,
                            tp_actuals_on_r01.tp_type);
         -- the actuals for last year is divided into YTD and YTG
         if tp_actuals_on_r01.billing_yyyypp < var_current_yyyypp then
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
            --if tp_actuals_on_r01.billing_yyyypp = var_current_yyyypp - 1 then
            if tp_actuals_on_r01.billing_yyyypp = mfjpln_control.previousPeriod(var_current_yyyypp, true) then
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
               update hermes_prd_0101
                  set cur_ly_tpv = tp_actuals_on_r01.tp_value,
                      ytd_ly_tpv = ytd_ly_tpv + tp_actuals_on_r01.tp_value
                  where sap_company_code = tp_actuals_on_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_actuals_on_r01.sap_material_code
                    and hp0101_tp_type = tp_actuals_on_r01.tp_type;
            else	--if tp_actuals_on_r01.billing_yyyypp = var_current_yyyypp - 1
               update hermes_prd_0101
                  set ytd_ly_tpv = ytd_ly_tpv + tp_actuals_on_r01.tp_value
                  where sap_company_code = tp_actuals_on_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_actuals_on_r01.sap_material_code
                    and hp0101_tp_type = tp_actuals_on_r01.tp_type;
            end if;	--if tp_actuals_on_r01.billing_yyyypp = var_current_yyyypp - 1

         else	--if tp_actuals_on_r01.billing_yyyypp < var_current_yyyypp

            update hermes_prd_0101
               set ytg_ly_tpv = ytg_ly_tpv + tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_actuals_on_r01.sap_material_code
                    and hp0101_tp_type = tp_actuals_on_r01.tp_type;

         end if;	--if tp_actuals_on_r01.billing_yyyypp < var_current_yyyypp

         if substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '01' then
            update hermes_prd_0102
               set p01_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '02' then
            update hermes_prd_0102
               set p02_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '03' then
            update hermes_prd_0102
               set p03_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '04' then
            update hermes_prd_0102
               set p04_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '05' then
            update hermes_prd_0102
               set p05_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '06' then
            update hermes_prd_0102
               set p06_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '07' then
            update hermes_prd_0102
               set p07_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '08' then
            update hermes_prd_0102
               set p08_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '09' then
            update hermes_prd_0102
               set p09_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '10' then
            update hermes_prd_0102
               set p10_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '11' then
            update hermes_prd_0102
               set p11_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '12' then
            update hermes_prd_0102
               set p12_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         elsif substr(to_char(tp_actuals_on_r01.billing_yyyypp,'fm000000'),5,2) = '13' then
            update hermes_prd_0102
               set p13_tpv = tp_actuals_on_r01.tp_value
               where sap_company_code = tp_actuals_on_r01.sap_company_code
                 and sap_sold_to_cust_code = tp_actuals_on_r01.sap_sold_to_cust_code
                 and sap_material_code = tp_actuals_on_r01.sap_material_code
                 and hp0102_tp_type = tp_actuals_on_r01.tp_type
              	  and dta_type = 'LYR';
         end if;

      end loop;
      close tp_actuals_on_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_tp_data;

   /*****************************************************/
   /* This procedure performs the forecast data routine */
   /*****************************************************/
   procedure exe_tp_fcst_data is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);
      var_start_yyyypp number(6,0);
      var_end_yyyypp number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor tp_fcst_op_c01 is
         SELECT t01.TPO_COM_CODE as sap_company_code,
				   t01.tpo_cust_level as sap_sold_to_cust_code,
				   t01.tpo_matl_level as sap_material_code,
				   t01.tpo_period as billing_yyyypp,
				   t01.tpo_tp_type as tp_type,
				   t01.tpo_op_value as op_value
			FROM tp_op t01
			WHERE t01.tpo_op_vrsn = '99'
				  and t01.tpo_period >= var_start_yyyypp
				  and t01.tpo_period <= var_end_yyyypp;
      tp_fcst_op_r01 tp_fcst_op_c01%rowtype;

		cursor tp_fcst_br_c01 is
			SELECT t01.TPb_COM_CODE as sap_company_code,
				   t01.tpb_cust_level as sap_sold_to_cust_code,
				   t01.tpb_matl_level as sap_material_code,
				   t01.tpb_period as billing_yyyypp,
				   t01.tpb_tp_type as tp_type,
				   t01.tpb_br_value as br_value
			FROM tp_br t01
			WHERE t01.tpb_br_vrsn = t01.tpb_period
				  and t01.tpb_period >= var_start_yyyypp
				  and t01.tpb_period <= var_end_yyyypp;
		tp_fcst_br_r01 tp_fcst_br_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period variable
      /*-*/
      select current_yyyypp into var_current_yyyypp from hermes_prd_0100;

      /*-*/
      /* Extract the period forecast values - this year
      /*-*/
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
     -- var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp, false);
     -- var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp, false);
     var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp, true);
     var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp, true);
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
      --================================================
      -- First, loop the OP cursor
      --================================================

      open tp_fcst_op_c01;
      loop
         fetch tp_fcst_op_c01 into tp_fcst_op_r01;
         if tp_fcst_op_c01%notfound then
            exit;
         end if;

         createPeriodHeader(tp_fcst_op_r01.sap_company_code,
                            tp_fcst_op_r01.sap_sold_to_cust_code,
                            tp_fcst_op_r01.sap_material_code,
                            tp_fcst_op_r01.tp_type);

         if tp_fcst_op_r01.billing_yyyypp < var_current_yyyypp then
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
            --if tp_fcst_op_r01.billing_yyyypp = var_current_yyyypp - 1 then
            if tp_fcst_op_r01.billing_yyyypp = mfjpln_control.previousPeriod(var_current_yyyypp, true) then
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
               update hermes_prd_0101
                  set cur_op_tpv = tp_fcst_op_r01.op_value,
                      ytd_op_tpv = ytd_op_tpv + tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0101_tp_type = tp_fcst_op_r01.tp_type;
            else	--if tp_fcst_op_r01.billing_yyyypp = var_current_yyyypp - 1
               update hermes_prd_0101
                  set ytd_op_tpv = ytd_op_tpv + tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0101_tp_type = tp_fcst_op_r01.tp_type;
            end if;	--if tp_fcst_op_r01.billing_yyyypp = var_current_yyyypp - 1

         else	--if tp_fcst_op_r01.billing_yyyypp < var_current_yyyypp

            update hermes_prd_0101
               set ytg_op_tpv = ytg_op_tpv + tp_fcst_op_r01.op_value
               where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0101_tp_type = tp_fcst_op_r01.tp_type;

            if substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '01' then
               update hermes_prd_0102
                  set p01_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';
            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '02' then
               update hermes_prd_0102
                  set p02_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '03' then
               update hermes_prd_0102
                  set p03_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '04' then
               update hermes_prd_0102
                  set p04_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '05' then
               update hermes_prd_0102
                  set p05_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '06' then
               update hermes_prd_0102
                  set p06_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '07' then
               update hermes_prd_0102
                  set p07_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '08' then
               update hermes_prd_0102
                  set p08_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '09' then
               update hermes_prd_0102
                  set p09_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '10' then
               update hermes_prd_0102
                  set p10_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '11' then
               update hermes_prd_0102
                  set p11_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '12' then
               update hermes_prd_0102
                  set p12_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '13' then
               update hermes_prd_0102
                  set p13_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'AOP';

            end if;	--if substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '01', '02', '03'...

         end if;	----if tp_fcst_op_r01.billing_yyyypp < var_current_yyyypp

         if substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '01' then
            update hermes_prd_0102
                  set p01_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '02' then
            update hermes_prd_0102
                  set p02_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '03' then
            update hermes_prd_0102
                  set p03_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '04' then
            update hermes_prd_0102
                  set p04_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '05' then
            update hermes_prd_0102
                  set p05_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '06' then
            update hermes_prd_0102
                  set p06_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '07' then
            update hermes_prd_0102
                  set p07_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '08' then
            update hermes_prd_0102
                  set p08_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '09' then
            update hermes_prd_0102
                  set p09_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '10' then
            update hermes_prd_0102
                  set p10_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '11' then
            update hermes_prd_0102
                  set p11_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '12' then
            update hermes_prd_0102
                  set p12_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         elsif substr(to_char(tp_fcst_op_r01.billing_yyyypp,'fm000000'),5,2) = '13' then
            update hermes_prd_0102
                  set p13_tpv = tp_fcst_op_r01.op_value
                  where sap_company_code = tp_fcst_op_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_op_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_op_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_op_r01.tp_type
                    and dta_type = 'TOP';
         end if;

      end loop;
      close tp_fcst_op_c01;

		--======================================================
		-- Now let us loop the BR cursor
		--======================================================

		open tp_fcst_br_c01;
      loop
         fetch tp_fcst_br_c01 into tp_fcst_br_r01;
         if tp_fcst_br_c01%notfound then
            exit;
         end if;

         createPeriodHeader(tp_fcst_br_r01.sap_company_code,
                            tp_fcst_br_r01.sap_sold_to_cust_code,
                            tp_fcst_br_r01.sap_material_code,
                            tp_fcst_br_r01.tp_type);

         if tp_fcst_br_r01.billing_yyyypp < var_current_yyyypp then
------------------------------------------------------------------------------------------
--========changed by Danny, begin========--
            --if tp_fcst_br_r01.billing_yyyypp = var_current_yyyypp - 1 then
            if tp_fcst_br_r01.billing_yyyypp = mfjpln_control.previousPeriod(var_current_yyyypp, true) then
--========changed by Danny, end========--
-------------------------------------------------------------------------------------------
               update hermes_prd_0101
                  set cur_br_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0101_tp_type = tp_fcst_br_r01.tp_type;
            end if;	--if tp_fcst_br_r01.billing_yyyypp = var_current_yyyypp - 1

         else	--if tp_fcst_br_r01.billing_yyyypp < var_current_yyyypp

            update hermes_prd_0101
               set ytg_br_tpv = ytg_br_tpv + tp_fcst_br_r01.br_value
               where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0101_tp_type = tp_fcst_br_r01.tp_type;

            if substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '01' then

               update hermes_prd_0102
                  set p01_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '02' then

               update hermes_prd_0102
                  set p02_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '03' then

               update hermes_prd_0102
                  set p03_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '04' then

               update hermes_prd_0102
                  set p04_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '05' then

               update hermes_prd_0102
                  set p05_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '06' then

               update hermes_prd_0102
                  set p06_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '07' then

               update hermes_prd_0102
                  set p07_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '08' then

               update hermes_prd_0102
                  set p08_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '09' then

               update hermes_prd_0102
                  set p09_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '10' then

               update hermes_prd_0102
                  set p10_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '11' then

               update hermes_prd_0102
                  set p11_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '12' then

               update hermes_prd_0102
                  set p12_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            elsif substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '13' then

               update hermes_prd_0102
                  set p13_tpv = tp_fcst_br_r01.br_value
                  where sap_company_code = tp_fcst_br_r01.sap_company_code
                    and sap_sold_to_cust_code = tp_fcst_br_r01.sap_sold_to_cust_code
                    and sap_material_code = tp_fcst_br_r01.sap_material_code
                    and hp0102_tp_type = tp_fcst_br_r01.tp_type
                    and dta_type = 'ABR';
            end if;	--if substr(to_char(tp_fcst_br_r01.billing_yyyypp,'fm000000'),5,2) = '01', '02', '03'...

         end if;	----if tp_fcst_br_r01.billing_yyyypp < var_current_yyyypp

      end loop;
      close tp_fcst_br_c01;


   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_tp_fcst_data;

   /************************************************************/
   /* This procedure performs the create period header routine */
   /************************************************************/
   procedure createPeriodHeader(par_sap_company_code in varchar2,
                                par_sap_sold_to_cust_code in varchar2,
                                par_sap_material_code in varchar2,
                                par_hp0101_tp_type in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor hermes_prd_0101_c01 is
         select 'x'
         from hermes_prd_0101
         where hermes_prd_0101.sap_company_code = par_sap_company_code
           and hermes_prd_0101.sap_sold_to_cust_code = par_sap_sold_to_cust_code
           and hermes_prd_0101.sap_material_code = par_sap_material_code
           and hermes_prd_0101.hp0101_tp_type = par_hp0101_tp_type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period data row when required
      /*-*/
      open hermes_prd_0101_c01;
      fetch hermes_prd_0101_c01 into var_work;
      if hermes_prd_0101_c01%notfound then
         insert into hermes_prd_0101
            (sap_company_code,
             sap_sold_to_cust_code,
             sap_material_code,
             hp0101_tp_type,
             cur_ty_tpv,
				 cur_ly_tpv,
				 cur_op_tpv,
				 cur_br_tpv,
				 ytd_ty_tpv,
				 ytd_ly_tpv,
				 ytd_op_tpv,
				 ytg_ly_tpv,
				 ytg_op_tpv,
				 ytg_br_tpv)
         values
            (par_sap_company_code,
             par_sap_sold_to_cust_code,
             par_sap_material_code,
             par_hp0101_tp_type,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0);
         createPeriodDetail(par_sap_company_code,
                            par_sap_sold_to_cust_code,
                            par_sap_material_code,
                            par_hp0101_tp_type,
                            'AOP');
         createPeriodDetail(par_sap_company_code,
                            par_sap_sold_to_cust_code,
                            par_sap_material_code,
                            par_hp0101_tp_type,
                            'ABR');
         createPeriodDetail(par_sap_company_code,
                            par_sap_sold_to_cust_code,
                            par_sap_material_code,
                            par_hp0101_tp_type,
                            'LYR');
         createPeriodDetail(par_sap_company_code,
                            par_sap_sold_to_cust_code,
                            par_sap_material_code,
                            par_hp0101_tp_type,
                            'TOP');
      end if;
      close hermes_prd_0101_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createPeriodHeader;

   /************************************************************/
   /* This procedure performs the create period detail routine */
   /************************************************************/
   procedure createPeriodDetail(par_sap_company_code in varchar2,
                                par_sap_sold_to_cust_code in varchar2,
                                par_sap_material_code in varchar2,
                                par_hp0102_tp_type in varchar2,
                                par_dta_type in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period detail row
      /*-*/
      insert into hermes_prd_0102
         (sap_company_code,
          sap_sold_to_cust_code,
          sap_material_code,
          hp0102_tp_type,
          dta_type,
			 p01_tpv,
		    p02_tpv,
		    p03_tpv,
		    p04_tpv,
		    p05_tpv,
		    p06_tpv,
		    p07_tpv,
		    p08_tpv,
		    p09_tpv,
		    p10_tpv,
		    p11_tpv,
		    p12_tpv,
		    p13_tpv)
         values(
            par_sap_company_code,
            par_sap_sold_to_cust_code,
            par_sap_material_code,
            par_hp0102_tp_type,
            par_dta_type,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createPeriodDetail;

end hermes_prd_01_extract;
/

