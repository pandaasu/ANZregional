/******************/
/* Package Header */
/******************/
create or replace package dw_sales_01_mart as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_sales_01_mart
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Dimensional Data Store - Sales Mart 01 Extract

    The package extracts the data mart for the sales 01 data mart.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure refresh(par_company_code in varchar2);

end dw_sales_01_mart;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_sales_01_mart as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract_header(par_company_code in varchar2);
   procedure extract_sale(par_company_code in varchar2);
   procedure extract_forecast(par_company_code in varchar2);
   procedure create_detail(par_company_code in varchar2,
                           par_matl_code in varchar2,
                           par_acct_assgnmnt_grp_code in varchar2,
                           par_demand_plng_grp_code in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_current_yyyypp number(6,0);
   var_current_yyyyppw number(7,0);

   /***********************************************/
   /* This procedure performs the refresh routine */
   /***********************************************/
   procedure refresh(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Extract the header data
      /*-*/
      extract_header(par_company_code);

      /*-*/
      /* Remove the data rows
      /*-*/
      delete from sales_01_mart_t02
       where company_code = par_company_code;

      /*-*/
      /* Extract the sales data
      /*-*/
      extract_sale(par_company_code);

      /*-*/
      /* Extract the forecast data
      /*-*/
      extract_forecast(par_company_code);

      /*-*/
      /* Update the header extract end time
      /*-*/
      update sales_01_mart_t01
         set extract_end_time = sysdate
       where company_code = par_company_code;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_SALES_01_MART - EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract;

   /***************************************************/
   /* This procedure performs the header data routine */
   /***************************************************/
   procedure extract_header(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_hed_p01 varchar2(50 char);
      var_hed_p02 varchar2(50 char);
      var_hed_p03 varchar2(50 char);
      var_hed_p04 varchar2(50 char);
      var_hed_p05 varchar2(50 char);
      var_hed_p06 varchar2(50 char);
      var_hed_p07 varchar2(50 char);
      var_hed_p08 varchar2(50 char);
      var_hed_p09 varchar2(50 char);
      var_hed_p10 varchar2(50 char);
      var_hed_p11 varchar2(50 char);
      var_hed_p12 varchar2(50 char);
      var_hed_p13 varchar2(50 char);
      var_hed_p14 varchar2(50 char);
      var_hed_p15 varchar2(50 char);
      var_hed_p16 varchar2(50 char);
      var_hed_p17 varchar2(50 char);
      var_hed_p18 varchar2(50 char);
      var_hed_p19 varchar2(50 char);
      var_hed_p20 varchar2(50 char);
      var_hed_p21 varchar2(50 char);
      var_hed_p22 varchar2(50 char);
      var_hed_p23 varchar2(50 char);
      var_hed_p24 varchar2(50 char);
      var_hed_p25 varchar2(50 char);
      var_hed_p26 varchar2(50 char);
      var_hed_p27 varchar2(50 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_period is
         select t01.mars_year,
                t01.mars_period,
                t01.mars_week,
                t01.period_num,
                t01.mars_week_of_year,
                t01.mars_week_of_period
           from mars_date_dim t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_period csr_period%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period information
      /*-*/
      open csr_period;
      fetch csr_period into rcd_period;
      if csr_period%notfound then
         raise_application_error(-20000, 'No mars date found for ' || to_char(trunc(sysdate),'yyyy/mm/dd'));
      end if;
      close csr_period;

      /*-*/
      /* Set the period headings
      /*-*/
      var_hed_p01 := 'Actual';
      var_hed_p02 := 'Fcst P1';
      var_hed_p03 := 'Fcst P2';
      var_hed_p04 := 'Fcst P3';
      var_hed_p05 := 'Fcst P4';
      var_hed_p06 := 'Fcst P5';
      var_hed_p07 := 'Fcst P6';
      var_hed_p08 := 'Fcst P7';
      var_hed_p09 := 'Fcst P8';
      var_hed_p10 := 'Fcst P9';
      var_hed_p11 := 'Fcst P10';
      var_hed_p12 := 'Fcst P11';
      var_hed_p13 := 'Fcst P12';
      var_hed_p14 := 'Fcst P13';
      if substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '01' then
         var_hed_p01 := 'Actual P1';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '02' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '03' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '04' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '05' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '06' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '07' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '08' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
         var_hed_p08 := 'Actual P8';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '09' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
         var_hed_p08 := 'Actual P8';
         var_hed_p09 := 'Actual P9';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '10' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
         var_hed_p08 := 'Actual P8';
         var_hed_p09 := 'Actual P9';
         var_hed_p10 := 'Actual P10';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '11' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
         var_hed_p08 := 'Actual P8';
         var_hed_p09 := 'Actual P9';
         var_hed_p10 := 'Actual P10';
         var_hed_p11 := 'Actual P11';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '12' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
         var_hed_p08 := 'Actual P8';
         var_hed_p09 := 'Actual P9';
         var_hed_p10 := 'Actual P10';
         var_hed_p11 := 'Actual P11';
         var_hed_p12 := 'Actual P12';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '13' then
         var_hed_p01 := 'Actual P1';
         var_hed_p02 := 'Actual P2';
         var_hed_p03 := 'Actual P3';
         var_hed_p04 := 'Actual P4';
         var_hed_p05 := 'Actual P5';
         var_hed_p06 := 'Actual P6';
         var_hed_p07 := 'Actual P7';
         var_hed_p08 := 'Actual P8';
         var_hed_p09 := 'Actual P9';
         var_hed_p10 := 'Actual P10';
         var_hed_p11 := 'Actual P11';
         var_hed_p12 := 'Actual P12';
         var_hed_p13 := 'Actual P13';
      end if;
      var_hed_p15 := 'Fcst P1';
      var_hed_p16 := 'Fcst P2';
      var_hed_p17 := 'Fcst P3';
      var_hed_p18 := 'Fcst P4';
      var_hed_p19 := 'Fcst P5';
      var_hed_p20 := 'Fcst P6';
      var_hed_p21 := 'Fcst P7';
      var_hed_p22 := 'Fcst P8';
      var_hed_p23 := 'Fcst P9';
      var_hed_p24 := 'Fcst P10';
      var_hed_p25 := 'Fcst P11';
      var_hed_p26 := 'Fcst P12';
      var_hed_p27 := 'Fcst P13';

      /*-*/
      /* Remove the data mart header
      /*-*/
      delete from sales_01_mart_t01
       where company_code = par_company_code;

      /*-*/
      /* Create the data mart header
      /*-*/
      insert into sales_01_mart_t01
         (company_code,
          extract_date,
          extract_str_time,
          extract_end_time,
          sale_extract_date,
          fcst_extract_date,
          current_yyyy,
          current_yyyypp,
          current_yyyyppw,
          current_pp,
          current_yw,
          current_pw,
          p01_heading,
          p02_heading,
          p03_heading,
          p04_heading,
          p05_heading,
          p06_heading,
          p07_heading,
          p08_heading,
          p09_heading,
          p10_heading,
          p11_heading,
          p12_heading,
          p13_heading,
          p14_heading,
          p15_heading,
          p16_heading,
          p17_heading,
          p18_heading,
          p19_heading,
          p20_heading,
          p21_heading,
          p22_heading,
          p23_heading,
          p24_heading,
          p25_heading,
          p26_heading,
          p27_heading)
         values(par_company_code,
                sysdate,
                sysdate,
                sysdate,
                sysdate,
                sysdate,
                rcd_period.mars_year,
                rcd_period.mars_period,
                rcd_period.mars_week,
                rcd_period.period_num,
                rcd_period.mars_week_of_year,
                rcd_period.mars_week_of_period,
                var_hed_p01,
                var_hed_p02,
                var_hed_p03,
                var_hed_p04,
                var_hed_p05,
                var_hed_p06,
                var_hed_p07,
                var_hed_p08,
                var_hed_p09,
                var_hed_p10,
                var_hed_p11,
                var_hed_p12,
                var_hed_p13,
                var_hed_p14,
                var_hed_p15,
                var_hed_p16,
                var_hed_p17,
                var_hed_p18,
                var_hed_p19,
                var_hed_p20,
                var_hed_p21,
                var_hed_p22,
                var_hed_p23,
                var_hed_p24,
                var_hed_p25,
                var_hed_p26,
                var_hed_p27);

      /*-*/
      /* Set the private variables
      /*-*/
      var_current_yyyypp := rcd_period.mars_period;
      var_current_yyyyppw := rcd_period.mars_week;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_header;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure extract_sale(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_lyr_str_yyyypp number(6,0);
      var_lyr_end_yyyypp number(6,0);
      var_ytd_str_yyyypp number(6,0);
      var_ytd_end_yyyypp number(6,0);
      var_mat_str_yyyypp number(6,0);
      var_mat_end_yyyypp number(6,0);
      var_cyr_str_yyyypp number(6,0);
      var_cyr_p01 number(6,0);
      var_cyr_p02 number(6,0);
      var_cyr_p03 number(6,0);
      var_cyr_p04 number(6,0);
      var_cyr_p05 number(6,0);
      var_cyr_p06 number(6,0);
      var_cyr_p07 number(6,0);
      var_cyr_p08 number(6,0);
      var_cyr_p09 number(6,0);
      var_cyr_p10 number(6,0);
      var_cyr_p11 number(6,0);
      var_cyr_p12 number(6,0);
      var_cyr_p13 number(6,0);
      var_str_yyyypp number(6,0);
      var_end_yyyypp number(6,0);
      var_cpd_yyyypp number(6,0);
      var_cpd_str_yyyyppw number(7,0);
      var_cpd_end_yyyyppw number(7,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales_extract_01 is 
         select t01.company_code,
                t01.matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyr_str_yyyypp and t01.billing_eff_yyyypp <= var_lyr_end_yyyypp then t01.billed_qty_base_uom end),0) as lyr_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyr_str_yyyypp and t01.billing_eff_yyyypp <= var_lyr_end_yyyypp then t01.billed_gsv end),0) as lyr_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyr_str_yyyypp and t01.billing_eff_yyyypp <= var_lyr_end_yyyypp then t01.billed_qty_net_tonnes end),0) as lyr_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ytd_str_yyyypp and t01.billing_eff_yyyypp <= var_ytd_end_yyyypp then t01.billed_qty_base_uom end),0) as ytd_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ytd_str_yyyypp and t01.billing_eff_yyyypp <= var_ytd_end_yyyypp then t01.billed_gsv end),0) as ytd_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ytd_str_yyyypp and t01.billing_eff_yyyypp <= var_ytd_end_yyyypp then t01.billed_qty_net_tonnes end),0) as ytd_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_mat_str_yyyypp and t01.billing_eff_yyyypp <= var_mat_end_yyyypp then t01.billed_qty_base_uom end),0) as mat_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_mat_str_yyyypp and t01.billing_eff_yyyypp <= var_mat_end_yyyypp then t01.billed_gsv end),0) as mat_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_mat_str_yyyypp and t01.billing_eff_yyyypp <= var_mat_end_yyyypp then t01.billed_qty_net_tonnes end),0) as mat_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_base_uom end),0) as p01_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_base_uom end),0) as p02_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_base_uom end),0) as p03_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_base_uom end),0) as p04_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_base_uom end),0) as p05_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_base_uom end),0) as p06_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_base_uom end),0) as p07_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_base_uom end),0) as p08_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_base_uom end),0) as p09_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_base_uom end),0) as p10_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_base_uom end),0) as p11_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_base_uom end),0) as p12_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_base_uom end),0) as p13_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_gsv end),0) as p01_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_gsv end),0) as p02_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_gsv end),0) as p03_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_gsv end),0) as p04_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_gsv end),0) as p05_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_gsv end),0) as p06_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_gsv end),0) as p07_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_gsv end),0) as p08_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_gsv end),0) as p09_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_gsv end),0) as p10_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_gsv end),0) as p11_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_gsv end),0) as p12_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_gsv end),0) as p13_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_net_tonnes end),0) as p13_ton
           from dw_sales_period_01_fact t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.hdr_distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.hdr_sales_org_code = t02.sales_org_code(+)
            and t01.sold_to_cust_code = t03.cust_code(+)
            and t01.hdr_distbn_chnl_code = t03.distbn_chnl_code(+) 
            and t01.hdr_division_code = t03.division_code(+) 
            and t01.hdr_sales_org_code = t03.sales_org_code(+)
            and t01.company_code = par_company_code
            and t01.billing_eff_yyyypp >= var_str_yyyypp
            and t01.billing_eff_yyyypp <= var_end_yyyypp
          group by t01.company_code,
                   t01.matl_code,
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code;
      rcd_sales_extract_01 csr_sales_extract_01%rowtype;

      cursor csr_sales_extract_02 is 
         select t01.company_code,
                t01.matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(t01.billed_qty_base_uom),0) as ytw_qty,
                nvl(sum(t01.billed_gsv),0) as ytw_gsv,
                nvl(sum(t01.billed_qty_net_tonnes),0) as ytw_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_base_uom end),0) as p01_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_base_uom end),0) as p02_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_base_uom end),0) as p03_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_base_uom end),0) as p04_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_base_uom end),0) as p05_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_base_uom end),0) as p06_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_base_uom end),0) as p07_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_base_uom end),0) as p08_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_base_uom end),0) as p09_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_base_uom end),0) as p10_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_base_uom end),0) as p11_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_base_uom end),0) as p12_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_base_uom end),0) as p13_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_gsv end),0) as p01_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_gsv end),0) as p02_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_gsv end),0) as p03_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_gsv end),0) as p04_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_gsv end),0) as p05_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_gsv end),0) as p06_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_gsv end),0) as p07_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_gsv end),0) as p08_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_gsv end),0) as p09_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_gsv end),0) as p10_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_gsv end),0) as p11_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_gsv end),0) as p12_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_gsv end),0) as p13_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_net_tonnes end),0) as p13_ton
           from dw_sales_fact t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.hdr_distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.hdr_sales_org_code = t02.sales_org_code(+)
            and t01.sold_to_cust_code = t03.cust_code(+)
            and t01.hdr_distbn_chnl_code = t03.distbn_chnl_code(+) 
            and t01.hdr_division_code = t03.division_code(+) 
            and t01.hdr_sales_org_code = t03.sales_org_code(+)
            and t01.company_code = par_company_code
            and t01.billing_eff_yyyypp = var_cpd_yyyypp
            and t01.billing_eff_yyyyppw >= var_cpd_str_yyyyppw
            and t01.billing_eff_yyyyppw <= var_cpd_end_yyyyppw
          group by t01.company_code,
                   t01.matl_code,
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code;
      rcd_sales_extract_02 csr_sales_extract_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate the period and week filters
      /*-*/
      var_lyr_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 1) * 100) + 1;
      var_lyr_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 1) * 100) + 13;
      var_ytd_str_yyyypp := (to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100) + 1;
      var_ytd_end_yyyypp := var_current_yyyypp - 1;
      var_mat_str_yyyypp := var_current_yyyypp - 100;
      var_mat_end_yyyypp := var_current_yyyypp - 1;
      var_cyr_str_yyyypp := to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100;
      var_cyr_p01 := var_cyr_str_yyyypp + 1;
      var_cyr_p02 := var_cyr_str_yyyypp + 2;
      var_cyr_p03 := var_cyr_str_yyyypp + 3;
      var_cyr_p04 := var_cyr_str_yyyypp + 4;
      var_cyr_p05 := var_cyr_str_yyyypp + 5;
      var_cyr_p06 := var_cyr_str_yyyypp + 6;
      var_cyr_p07 := var_cyr_str_yyyypp + 7;
      var_cyr_p08 := var_cyr_str_yyyypp + 8;
      var_cyr_p09 := var_cyr_str_yyyypp + 9;
      var_cyr_p10 := var_cyr_str_yyyypp + 10;
      var_cyr_p11 := var_cyr_str_yyyypp + 11;
      var_cyr_p12 := var_cyr_str_yyyypp + 12;
      var_cyr_p13 := var_cyr_str_yyyypp + 13;
      var_str_yyyypp := var_lyr_str_yyyypp;
      var_end_yyyypp := var_ytd_end_yyyypp;
      var_cpd_yyyypp := var_current_yyyypp;
      var_cpd_str_yyyyppw := (var_current_yyyypp * 10) + 1;
      var_cpd_end_yyyyppw := var_current_yyyyppw - 1;

      /*-*/
      /* Extract the period sales values
      /*-*/
      open csr_sales_extract_01;
      loop
         fetch csr_sales_extract_01 into rcd_sales_extract_01;
         if csr_sales_extract_01%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(par_company_code,
                       rcd_sales_extract_01.matl_code,
                       rcd_sales_extract_01.acct_assgnmnt_grp_code,
                       rcd_sales_extract_01.demand_plng_grp_code);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update sales_01_mart_t02
            set lyr_yte_inv_value = lyr_yte_inv_value + rcd_sales_extract_01.lyr_qty,
                cyr_ytd_inv_value = cyr_ytd_inv_value + rcd_sales_extract_01.ytd_qty,
                cyr_ytw_inv_value = cyr_ytw_inv_value + rcd_sales_extract_01.ytd_qty,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_qty,
                cyr_yee_inv_br_value = cyr_yee_inv_br_value + rcd_sales_extract_01.ytd_qty,
                cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_sales_extract_01.ytd_qty,
                p01_value = p01_value + rcd_sales_extract_01.p01_qty,
                p02_value = p02_value + rcd_sales_extract_01.p02_qty,
                p03_value = p03_value + rcd_sales_extract_01.p03_qty,
                p04_value = p04_value + rcd_sales_extract_01.p04_qty,
                p05_value = p05_value + rcd_sales_extract_01.p05_qty,
                p06_value = p06_value + rcd_sales_extract_01.p06_qty,
                p07_value = p07_value + rcd_sales_extract_01.p07_qty,
                p08_value = p08_value + rcd_sales_extract_01.p08_qty,
                p09_value = p09_value + rcd_sales_extract_01.p09_qty,
                p10_value = p10_value + rcd_sales_extract_01.p10_qty,
                p11_value = p11_value + rcd_sales_extract_01.p11_qty,
                p12_value = p12_value + rcd_sales_extract_01.p12_qty,
                p13_value = p13_value + rcd_sales_extract_01.p13_qty
          where company_code = rcd_sales_extract_01.company_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update sales_01_mart_t02
            set lyr_yte_inv_value = lyr_yte_inv_value + rcd_sales_extract_01.lyr_gsv,
                cyr_ytd_inv_value = cyr_ytd_inv_value + rcd_sales_extract_01.ytd_gsv,
                cyr_ytw_inv_value = cyr_ytw_inv_value + rcd_sales_extract_01.ytd_gsv,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_gsv,
                cyr_yee_inv_br_value = cyr_yee_inv_br_value + rcd_sales_extract_01.ytd_gsv,
                cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_sales_extract_01.ytd_gsv,
                p01_value = p01_value + rcd_sales_extract_01.p01_gsv,
                p02_value = p02_value + rcd_sales_extract_01.p02_gsv,
                p03_value = p03_value + rcd_sales_extract_01.p03_gsv,
                p04_value = p04_value + rcd_sales_extract_01.p04_gsv,
                p05_value = p05_value + rcd_sales_extract_01.p05_gsv,
                p06_value = p06_value + rcd_sales_extract_01.p06_gsv,
                p07_value = p07_value + rcd_sales_extract_01.p07_gsv,
                p08_value = p08_value + rcd_sales_extract_01.p08_gsv,
                p09_value = p09_value + rcd_sales_extract_01.p09_gsv,
                p10_value = p10_value + rcd_sales_extract_01.p10_gsv,
                p11_value = p11_value + rcd_sales_extract_01.p11_gsv,
                p12_value = p12_value + rcd_sales_extract_01.p12_gsv,
                p13_value = p13_value + rcd_sales_extract_01.p13_gsv
          where company_code = rcd_sales_extract_01.company_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update sales_01_mart_t02
            set lyr_yte_inv_value = lyr_yte_inv_value + rcd_sales_extract_01.lyr_ton,
                cyr_ytd_inv_value = cyr_ytd_inv_value + rcd_sales_extract_01.ytd_ton,
                cyr_ytw_inv_value = cyr_ytw_inv_value + rcd_sales_extract_01.ytd_ton,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_ton,
                cyr_yee_inv_br_value = cyr_yee_inv_br_value + rcd_sales_extract_01.ytd_ton,
                cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_sales_extract_01.ytd_ton,
                p01_value = p01_value + rcd_sales_extract_01.p01_ton,
                p02_value = p02_value + rcd_sales_extract_01.p02_ton,
                p03_value = p03_value + rcd_sales_extract_01.p03_ton,
                p04_value = p04_value + rcd_sales_extract_01.p04_ton,
                p05_value = p05_value + rcd_sales_extract_01.p05_ton,
                p06_value = p06_value + rcd_sales_extract_01.p06_ton,
                p07_value = p07_value + rcd_sales_extract_01.p07_ton,
                p08_value = p08_value + rcd_sales_extract_01.p08_ton,
                p09_value = p09_value + rcd_sales_extract_01.p09_ton,
                p10_value = p10_value + rcd_sales_extract_01.p10_ton,
                p11_value = p11_value + rcd_sales_extract_01.p11_ton,
                p12_value = p12_value + rcd_sales_extract_01.p12_ton,
                p13_value = p13_value + rcd_sales_extract_01.p13_ton
          where company_code = rcd_sales_extract_01.company_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and data_type = '*TON';

      end loop;
      close csr_sales_extract_01;

      /*-*/
      /* Extract the weekly sales values when required
      /*-*/
      if var_cpd_str_yyyyppw <= var_cpd_end_yyyyppw then

         open csr_sales_extract_02;
         loop
            fetch csr_sales_extract_02 into rcd_sales_extract_02;
            if csr_sales_extract_02%notfound then
               exit;
            end if;

            /*-*/
            /* Create the data mart detail
            /*-*/
            create_detail(rcd_sales_extract_02.company_code,
                          rcd_sales_extract_02.matl_code,
                          rcd_sales_extract_02.acct_assgnmnt_grp_code,
                          rcd_sales_extract_02.demand_plng_grp_code);

            /*-*/
            /* Update the data mart detail - QTY
            /*-*/
            update sales_01_mart_t02
               set cyr_ytw_inv_value = cyr_ytw_inv_value + rcd_sales_extract_02.ytw_qty,
                   cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_sales_extract_02.ytw_qty,
                   p01_value = p01_value + rcd_sales_extract_02.p01_qty,
                   p02_value = p02_value + rcd_sales_extract_02.p02_qty,
                   p03_value = p03_value + rcd_sales_extract_02.p03_qty,
                   p04_value = p04_value + rcd_sales_extract_02.p04_qty,
                   p05_value = p05_value + rcd_sales_extract_02.p05_qty,
                   p06_value = p06_value + rcd_sales_extract_02.p06_qty,
                   p07_value = p07_value + rcd_sales_extract_02.p07_qty,
                   p08_value = p08_value + rcd_sales_extract_02.p08_qty,
                   p09_value = p09_value + rcd_sales_extract_02.p09_qty,
                   p10_value = p10_value + rcd_sales_extract_02.p10_qty,
                   p11_value = p11_value + rcd_sales_extract_02.p11_qty,
                   p12_value = p12_value + rcd_sales_extract_02.p12_qty,
                   p13_value = p13_value + rcd_sales_extract_02.p13_qty
             where company_code = rcd_sales_extract_02.company_code
               and matl_code = rcd_sales_extract_02.matl_code
               and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
               and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
               and data_type = '*QTY';

            /*-*/
            /* Update the data mart detail - GSV
            /*-*/
            update sales_01_mart_t02
               set cyr_ytw_inv_value = cyr_ytw_inv_value + rcd_sales_extract_02.ytw_gsv,
                   cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_sales_extract_02.ytw_gsv,
                   p01_value = p01_value + rcd_sales_extract_02.p01_gsv,
                   p02_value = p02_value + rcd_sales_extract_02.p02_gsv,
                   p03_value = p03_value + rcd_sales_extract_02.p03_gsv,
                   p04_value = p04_value + rcd_sales_extract_02.p04_gsv,
                   p05_value = p05_value + rcd_sales_extract_02.p05_gsv,
                   p06_value = p06_value + rcd_sales_extract_02.p06_gsv,
                   p07_value = p07_value + rcd_sales_extract_02.p07_gsv,
                   p08_value = p08_value + rcd_sales_extract_02.p08_gsv,
                   p09_value = p09_value + rcd_sales_extract_02.p09_gsv,
                   p10_value = p10_value + rcd_sales_extract_02.p10_gsv,
                   p11_value = p11_value + rcd_sales_extract_02.p11_gsv,
                   p12_value = p12_value + rcd_sales_extract_02.p12_gsv,
                   p13_value = p13_value + rcd_sales_extract_02.p13_gsv
             where company_code = rcd_sales_extract_02.company_code
               and matl_code = rcd_sales_extract_02.matl_code
               and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
               and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
               and data_type = '*GSV';

            /*-*/
            /* Update the data mart detail - TON
            /*-*/
            update sales_01_mart_t02
               set cyr_ytw_inv_value = cyr_ytw_inv_value + rcd_sales_extract_02.ytw_ton,
                   cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_sales_extract_02.ytw_ton,
                   p01_value = p01_value + rcd_sales_extract_02.p01_ton,
                   p02_value = p02_value + rcd_sales_extract_02.p02_ton,
                   p03_value = p03_value + rcd_sales_extract_02.p03_ton,
                   p04_value = p04_value + rcd_sales_extract_02.p04_ton,
                   p05_value = p05_value + rcd_sales_extract_02.p05_ton,
                   p06_value = p06_value + rcd_sales_extract_02.p06_ton,
                   p07_value = p07_value + rcd_sales_extract_02.p07_ton,
                   p08_value = p08_value + rcd_sales_extract_02.p08_ton,
                   p09_value = p09_value + rcd_sales_extract_02.p09_ton,
                   p10_value = p10_value + rcd_sales_extract_02.p10_ton,
                   p11_value = p11_value + rcd_sales_extract_02.p11_ton,
                   p12_value = p12_value + rcd_sales_extract_02.p12_ton,
                   p13_value = p13_value + rcd_sales_extract_02.p13_ton
             where company_code = rcd_sales_extract_02.company_code
               and matl_code = rcd_sales_extract_02.matl_code
               and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
               and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
               and data_type = '*TON';

         end loop;
         close csr_sales_extract_02;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_sale;

   /*****************************************************/
   /* This procedure performs the forecast data routine */
   /*****************************************************/
   procedure extract_forecast(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_cyr_str_yyyypp number(6,0);
      var_cyr_end_yyyypp number(6,0);
      var_ytg_str_yyyypp number(6,0);
      var_ytg_end_yyyypp number(6,0);
      var_nyr_str_yyyypp number(6,0);
      var_nyr_end_yyyypp number(6,0);
      var_ytg_str_yyyyppw number(7,0);
      var_wyr_str_yyyypp number(6,0);
      var_wyr_p01 number(6,0);
      var_wyr_p02 number(6,0);
      var_wyr_p03 number(6,0);
      var_wyr_p04 number(6,0);
      var_wyr_p05 number(6,0);
      var_wyr_p06 number(6,0);
      var_wyr_p07 number(6,0);
      var_wyr_p08 number(6,0);
      var_wyr_p09 number(6,0);
      var_wyr_p10 number(6,0);
      var_wyr_p11 number(6,0);
      var_wyr_p12 number(6,0);
      var_wyr_p13 number(6,0);
      var_wyr_p14 number(6,0);
      var_wyr_p15 number(6,0);
      var_wyr_p16 number(6,0);
      var_wyr_p17 number(6,0);
      var_wyr_p18 number(6,0);
      var_wyr_p19 number(6,0);
      var_wyr_p20 number(6,0);
      var_wyr_p21 number(6,0);
      var_wyr_p22 number(6,0);
      var_wyr_p23 number(6,0);
      var_wyr_p24 number(6,0);
      var_wyr_p25 number(6,0);
      var_wyr_p26 number(6,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_01 is 
         select t01.company_code,
                t01.matl_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(t01.fcst_qty),0) as yee_qty,
                nvl(sum(t01.fcst_value),0) as yee_gsv,
                nvl(sum(t01.fcst_qty_net_tonnes),0) as yee_ton
           from fcst_fact t01
          where t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_cyr_str_yyyypp
            and t01.fcst_yyyypp <= var_cyr_end_yyyypp
            and t01.fcst_type_code = 'OP'
            and t01.acct_assgnmnt_grp_code = '01'
          group by t01.company_code,
                   t01.matl_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_01 csr_fcst_extract_01%rowtype;

      cursor csr_fcst_extract_02 is 
         select t01.company_code,
                t01.matl_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(t01.fcst_qty),0) as yee_qty,
                nvl(sum(t01.fcst_value),0) as yee_gsv,
                nvl(sum(t01.fcst_qty_net_tonnes),0) as yee_ton
           from fcst_fact t01
          where t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_cyr_str_yyyypp
            and t01.fcst_yyyypp <= var_cyr_end_yyyypp
            and t01.fcst_type_code = 'ROB'
            and t01.acct_assgnmnt_grp_code = '01'
          group by t01.company_code,
                   t01.matl_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_02 csr_fcst_extract_02%rowtype;

      cursor csr_fcst_extract_03 is 
         select t01.company_code,
                t01.matl_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_value end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty end),0) as nyr_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_value end),0) as nyr_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as nyr_ton
           from fcst_fact t01
          where t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_nyr_end_yyyypp
            and t01.fcst_type_code = 'BR'
            and t01.acct_assgnmnt_grp_code = '01'
          group by t01.company_code,
                   t01.matl_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_03 csr_fcst_extract_03%rowtype;

      cursor csr_fcst_extract_04 is 
         select t01.company_code,
                t01.matl_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ytg_str_yyyyppw and t01.fcst_yyyypp <= var_cyr_end_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ytg_str_yyyyppw and t01.fcst_yyyypp <= var_cyr_end_yyyypp then t01.fcst_value end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ytg_str_yyyyppw and t01.fcst_yyyypp <= var_cyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty end),0) as nyr_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_value end),0) as nyr_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as nyr_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p14_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty end),0) as p15_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty end),0) as p16_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty end),0) as p17_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty end),0) as p18_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty end),0) as p19_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty end),0) as p20_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty end),0) as p21_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty end),0) as p22_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty end),0) as p23_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty end),0) as p24_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty end),0) as p25_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty end),0) as p26_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty end),0) as p27_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value end),0) as p14_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_value end),0) as p15_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_value end),0) as p16_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_value end),0) as p17_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_value end),0) as p18_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_value end),0) as p19_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_value end),0) as p20_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_value end),0) as p21_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_value end),0) as p22_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_value end),0) as p23_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_value end),0) as p24_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_value end),0) as p25_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_value end),0) as p26_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_value end),0) as p27_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p13_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p14_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty_net_tonnes end),0) as p15_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty_net_tonnes end),0) as p16_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty_net_tonnes end),0) as p17_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty_net_tonnes end),0) as p18_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty_net_tonnes end),0) as p19_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty_net_tonnes end),0) as p20_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty_net_tonnes end),0) as p21_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty_net_tonnes end),0) as p22_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty_net_tonnes end),0) as p23_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty_net_tonnes end),0) as p24_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty_net_tonnes end),0) as p25_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty_net_tonnes end),0) as p26_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty_net_tonnes end),0) as p27_ton
           from fcst_fact t01
          where t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_nyr_end_yyyypp
            and t01.fcst_yyyyppw >= var_ytg_str_yyyyppw
            and t01.fcst_type_code = 'FCST'
            and t01.acct_assgnmnt_grp_code = '01'
          group by t01.company_code,
                   t01.matl_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_04 csr_fcst_extract_04%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate the period and week filters
      /*-*/
      var_cyr_str_yyyypp := (to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100) + 1;
      var_cyr_end_yyyypp := (to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100) + 13;
      var_ytg_str_yyyypp := var_current_yyyypp;
      var_ytg_end_yyyypp := (to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100) + 13;
      var_nyr_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) + 1) * 100) + 1;
      var_nyr_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) + 1) * 100) + 13;
      var_ytg_str_yyyyppw := var_current_yyyyppw;
      var_wyr_str_yyyypp := to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100;
      var_wyr_p01 := var_wyr_str_yyyypp + 1;
      var_wyr_p02 := var_wyr_str_yyyypp + 2;
      var_wyr_p03 := var_wyr_str_yyyypp + 3;
      var_wyr_p04 := var_wyr_str_yyyypp + 4;
      var_wyr_p05 := var_wyr_str_yyyypp + 5;
      var_wyr_p06 := var_wyr_str_yyyypp + 6;
      var_wyr_p07 := var_wyr_str_yyyypp + 7;
      var_wyr_p08 := var_wyr_str_yyyypp + 8;
      var_wyr_p09 := var_wyr_str_yyyypp + 9;
      var_wyr_p10 := var_wyr_str_yyyypp + 10;
      var_wyr_p11 := var_wyr_str_yyyypp + 11;
      var_wyr_p12 := var_wyr_str_yyyypp + 12;
      var_wyr_p13 := var_wyr_str_yyyypp + 13;
      var_wyr_p14 := var_wyr_str_yyyypp + 101;
      var_wyr_p15 := var_wyr_str_yyyypp + 102;
      var_wyr_p16 := var_wyr_str_yyyypp + 103;
      var_wyr_p17 := var_wyr_str_yyyypp + 104;
      var_wyr_p18 := var_wyr_str_yyyypp + 105;
      var_wyr_p19 := var_wyr_str_yyyypp + 106;
      var_wyr_p20 := var_wyr_str_yyyypp + 107;
      var_wyr_p21 := var_wyr_str_yyyypp + 108;
      var_wyr_p22 := var_wyr_str_yyyypp + 109;
      var_wyr_p23 := var_wyr_str_yyyypp + 110;
      var_wyr_p24 := var_wyr_str_yyyypp + 111;
      var_wyr_p25 := var_wyr_str_yyyypp + 112;
      var_wyr_p26 := var_wyr_str_yyyypp + 113;

      /*-*/
      /* Extract the OP forecast values
      /*-*/
      open csr_fcst_extract_01;
      loop
         fetch csr_fcst_extract_01 into rcd_fcst_extract_01;
         if csr_fcst_extract_01%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_fcst_extract_01.company_code,
                       rcd_fcst_extract_01.matl_code,
                       rcd_fcst_extract_01.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_01.demand_plng_grp_code);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update sales_01_mart_t02
            set cyr_yte_op_value = cyr_yte_op_value + rcd_fcst_extract_01.yee_qty
          where company_code = rcd_fcst_extract_01.company_code
            and matl_code = rcd_fcst_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update sales_01_mart_t02
            set cyr_yte_op_value = cyr_yte_op_value + rcd_fcst_extract_01.yee_gsv
          where company_code = rcd_fcst_extract_01.company_code
            and matl_code = rcd_fcst_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update sales_01_mart_t02
            set cyr_yte_op_value = cyr_yte_op_value + rcd_fcst_extract_01.yee_ton
          where company_code = rcd_fcst_extract_01.company_code
            and matl_code = rcd_fcst_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and data_type = '*TON';

      end loop;
      close csr_fcst_extract_01;

      /*-*/
      /* Extract the ROB forecast values
      /*-*/
      open csr_fcst_extract_02;
      loop
         fetch csr_fcst_extract_02 into rcd_fcst_extract_02;
         if csr_fcst_extract_02%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_fcst_extract_02.company_code,
                       rcd_fcst_extract_02.matl_code,
                       rcd_fcst_extract_02.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_02.demand_plng_grp_code);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update sales_01_mart_t02
            set cyr_yte_rob_value = cyr_yte_rob_value + rcd_fcst_extract_02.yee_qty
          where company_code = rcd_fcst_extract_02.company_code
            and matl_code = rcd_fcst_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update sales_01_mart_t02
            set cyr_yte_rob_value = cyr_yte_rob_value + rcd_fcst_extract_02.yee_gsv
          where company_code = rcd_fcst_extract_02.company_code
            and matl_code = rcd_fcst_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update sales_01_mart_t02
            set cyr_yte_rob_value = cyr_yte_rob_value + rcd_fcst_extract_02.yee_ton
          where company_code = rcd_fcst_extract_02.company_code
            and matl_code = rcd_fcst_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and data_type = '*TON';

      end loop;
      close csr_fcst_extract_02;

      /*-*/
      /* Extract the BR forecast values
      /*-*/
      open csr_fcst_extract_03;
      loop
         fetch csr_fcst_extract_03 into rcd_fcst_extract_03;
         if csr_fcst_extract_03%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_fcst_extract_03.company_code,
                       rcd_fcst_extract_03.matl_code,
                       rcd_fcst_extract_03.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_03.demand_plng_grp_code);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update sales_01_mart_t02
            set cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_qty,
                nyr_yte_br_value = nyr_yte_br_value + rcd_fcst_extract_03.nyr_qty,
                cyr_yee_inv_br_value = cyr_yee_inv_br_value + rcd_fcst_extract_03.ytg_qty
          where company_code = rcd_fcst_extract_03.company_code
            and matl_code = rcd_fcst_extract_03.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update sales_01_mart_t02
            set cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_gsv,
                nyr_yte_br_value = nyr_yte_br_value + rcd_fcst_extract_03.nyr_gsv,
                cyr_yee_inv_br_value = cyr_yee_inv_br_value + rcd_fcst_extract_03.ytg_gsv
          where company_code = rcd_fcst_extract_03.company_code
            and matl_code = rcd_fcst_extract_03.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update sales_01_mart_t02
            set cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_ton,
                nyr_yte_br_value = nyr_yte_br_value + rcd_fcst_extract_03.nyr_ton,
                cyr_yee_inv_br_value = cyr_yee_inv_br_value + rcd_fcst_extract_03.ytg_ton
          where company_code = rcd_fcst_extract_03.company_code
            and matl_code = rcd_fcst_extract_03.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and data_type = '*TON';

      end loop;
      close csr_fcst_extract_03;

      /*-*/
      /* Extract the FCST forecast values
      /*-*/
      open csr_fcst_extract_04;
      loop
         fetch csr_fcst_extract_04 into rcd_fcst_extract_04;
         if csr_fcst_extract_04%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_fcst_extract_04.company_code,
                       rcd_fcst_extract_04.matl_code,
                       rcd_fcst_extract_04.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_04.demand_plng_grp_code);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update sales_01_mart_t02
            set cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_qty,
                nyr_yte_fcst_value = nyr_yte_fcst_value + rcd_fcst_extract_04.nyr_qty,
                cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_fcst_extract_04.ytg_qty,
                p02_value = p02_value + rcd_fcst_extract_04.p02_qty,
                p03_value = p03_value + rcd_fcst_extract_04.p03_qty,
                p04_value = p04_value + rcd_fcst_extract_04.p04_qty,
                p05_value = p05_value + rcd_fcst_extract_04.p05_qty,
                p06_value = p06_value + rcd_fcst_extract_04.p06_qty,
                p07_value = p07_value + rcd_fcst_extract_04.p07_qty,
                p08_value = p08_value + rcd_fcst_extract_04.p08_qty,
                p09_value = p09_value + rcd_fcst_extract_04.p09_qty,
                p10_value = p10_value + rcd_fcst_extract_04.p10_qty,
                p11_value = p11_value + rcd_fcst_extract_04.p11_qty,
                p12_value = p12_value + rcd_fcst_extract_04.p12_qty,
                p13_value = p13_value + rcd_fcst_extract_04.p13_qty,
                p14_value = p14_value + rcd_fcst_extract_04.p14_qty,
                p15_value = p15_value + rcd_fcst_extract_04.p15_qty,
                p16_value = p16_value + rcd_fcst_extract_04.p16_qty,
                p17_value = p17_value + rcd_fcst_extract_04.p17_qty,
                p18_value = p18_value + rcd_fcst_extract_04.p18_qty,
                p19_value = p19_value + rcd_fcst_extract_04.p19_qty,
                p20_value = p20_value + rcd_fcst_extract_04.p20_qty,
                p21_value = p21_value + rcd_fcst_extract_04.p21_qty,
                p22_value = p22_value + rcd_fcst_extract_04.p22_qty,
                p23_value = p23_value + rcd_fcst_extract_04.p23_qty,
                p24_value = p24_value + rcd_fcst_extract_04.p24_qty,
                p25_value = p25_value + rcd_fcst_extract_04.p25_qty,
                p26_value = p26_value + rcd_fcst_extract_04.p26_qty,
                p27_value = p27_value + rcd_fcst_extract_04.p27_qty
          where company_code = rcd_fcst_extract_04.company_code
            and matl_code = rcd_fcst_extract_04.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update sales_01_mart_t02
            set cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_gsv,
                nyr_yte_fcst_value = nyr_yte_fcst_value + rcd_fcst_extract_04.nyr_gsv,
                cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_fcst_extract_04.ytg_gsv,
                p02_value = p02_value + rcd_fcst_extract_04.p02_gsv,
                p03_value = p03_value + rcd_fcst_extract_04.p03_gsv,
                p04_value = p04_value + rcd_fcst_extract_04.p04_gsv,
                p05_value = p05_value + rcd_fcst_extract_04.p05_gsv,
                p06_value = p06_value + rcd_fcst_extract_04.p06_gsv,
                p07_value = p07_value + rcd_fcst_extract_04.p07_gsv,
                p08_value = p08_value + rcd_fcst_extract_04.p08_gsv,
                p09_value = p09_value + rcd_fcst_extract_04.p09_gsv,
                p10_value = p10_value + rcd_fcst_extract_04.p10_gsv,
                p11_value = p11_value + rcd_fcst_extract_04.p11_gsv,
                p12_value = p12_value + rcd_fcst_extract_04.p12_gsv,
                p13_value = p13_value + rcd_fcst_extract_04.p13_gsv,
                p14_value = p14_value + rcd_fcst_extract_04.p14_gsv,
                p15_value = p15_value + rcd_fcst_extract_04.p15_gsv,
                p16_value = p16_value + rcd_fcst_extract_04.p16_gsv,
                p17_value = p17_value + rcd_fcst_extract_04.p17_gsv,
                p18_value = p18_value + rcd_fcst_extract_04.p18_gsv,
                p19_value = p19_value + rcd_fcst_extract_04.p19_gsv,
                p20_value = p20_value + rcd_fcst_extract_04.p20_gsv,
                p21_value = p21_value + rcd_fcst_extract_04.p21_gsv,
                p22_value = p22_value + rcd_fcst_extract_04.p22_gsv,
                p23_value = p23_value + rcd_fcst_extract_04.p23_gsv,
                p24_value = p24_value + rcd_fcst_extract_04.p24_gsv,
                p25_value = p25_value + rcd_fcst_extract_04.p25_gsv,
                p26_value = p26_value + rcd_fcst_extract_04.p26_gsv,
                p27_value = p27_value + rcd_fcst_extract_04.p27_gsv
          where company_code = rcd_fcst_extract_04.company_code
            and matl_code = rcd_fcst_extract_04.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update sales_01_mart_t02
            set cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_ton,
                nyr_yte_fcst_value = nyr_yte_fcst_value + rcd_fcst_extract_04.nyr_ton,
                cyr_yee_inv_fcst_value = cyr_yee_inv_fcst_value + rcd_fcst_extract_04.ytg_ton,
                p02_value = p02_value + rcd_fcst_extract_04.p02_ton,
                p03_value = p03_value + rcd_fcst_extract_04.p03_ton,
                p04_value = p04_value + rcd_fcst_extract_04.p04_ton,
                p05_value = p05_value + rcd_fcst_extract_04.p05_ton,
                p06_value = p06_value + rcd_fcst_extract_04.p06_ton,
                p07_value = p07_value + rcd_fcst_extract_04.p07_ton,
                p08_value = p08_value + rcd_fcst_extract_04.p08_ton,
                p09_value = p09_value + rcd_fcst_extract_04.p09_ton,
                p10_value = p10_value + rcd_fcst_extract_04.p10_ton,
                p11_value = p11_value + rcd_fcst_extract_04.p11_ton,
                p12_value = p12_value + rcd_fcst_extract_04.p12_ton,
                p13_value = p13_value + rcd_fcst_extract_04.p13_ton,
                p14_value = p14_value + rcd_fcst_extract_04.p14_ton,
                p15_value = p15_value + rcd_fcst_extract_04.p15_ton,
                p16_value = p16_value + rcd_fcst_extract_04.p16_ton,
                p17_value = p17_value + rcd_fcst_extract_04.p17_ton,
                p18_value = p18_value + rcd_fcst_extract_04.p18_ton,
                p19_value = p19_value + rcd_fcst_extract_04.p19_ton,
                p20_value = p20_value + rcd_fcst_extract_04.p20_ton,
                p21_value = p21_value + rcd_fcst_extract_04.p21_ton,
                p22_value = p22_value + rcd_fcst_extract_04.p22_ton,
                p23_value = p23_value + rcd_fcst_extract_04.p23_ton,
                p24_value = p24_value + rcd_fcst_extract_04.p24_ton,
                p25_value = p25_value + rcd_fcst_extract_04.p25_ton,
                p26_value = p26_value + rcd_fcst_extract_04.p26_ton,
                p27_value = p27_value + rcd_fcst_extract_04.p27_ton
          where company_code = rcd_fcst_extract_04.company_code
            and matl_code = rcd_fcst_extract_04.matl_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and data_type = '*TON';

      end loop;
      close csr_fcst_extract_04;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_forecast;

   /*****************************************************/
   /* This procedure performs the create detail routine */
   /*****************************************************/
   procedure create_detail(par_company_code in varchar2,
                           par_matl_code in varchar2,
                           par_acct_assgnmnt_grp_code in varchar2,
                           par_demand_plng_grp_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_data is 
         select 'x'
           from sales_01_mart_t02 t01
          where t01.company_code = par_company_code
            and t01.matl_code = par_matl_code
            and t01.acct_assgnmnt_grp_code = par_acct_assgnmnt_grp_code
            and t01.demand_plng_grp_code = par_demand_plng_grp_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new detail row when required
      /*-*/
      open csr_data;
      fetch csr_data into var_work;
      if csr_data%notfound then

         /*-*/
         /* Data type QTY
         /*-*/
         insert into sales_01_mart_t02
            (company_code,
             matl_code,
             acct_assgnmnt_grp_code,
             demand_plng_grp_code,
             data_type,
             lyr_yte_inv_value,
             cyr_ytd_inv_value,
             cyr_ytw_inv_value,
             cyr_mat_inv_value,
             cyr_yte_op_value,
             cyr_yte_rob_value,
             cyr_ytg_br_value,
             cyr_ytg_fcst_value,
             nyr_yte_br_value,
             nyr_yte_fcst_value,
             cyr_yee_inv_fcst_value,
             cyr_yee_inv_br_value,
             p01_value,
             p02_value,
             p03_value,
             p04_value,
             p05_value,
             p06_value,
             p07_value,
             p08_value,
             p09_value,
             p10_value,
             p11_value,
             p12_value,
             p13_value,
             p14_value,
             p15_value,
             p16_value,
             p17_value,
             p18_value,
             p19_value,
             p20_value,
             p21_value,
             p22_value,
             p23_value,
             p24_value,
             p25_value,
             p26_value,
             p27_value)
         values
            (par_company_code,
             par_matl_code,
             par_acct_assgnmnt_grp_code,
             par_demand_plng_grp_code,
             '*QTY',
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
             0,
             0,
             0);

         /*-*/
         /* Data type GSV
         /*-*/
         insert into sales_01_mart_t02
            (company_code,
             matl_code,
             acct_assgnmnt_grp_code,
             demand_plng_grp_code,
             data_type,
             lyr_yte_inv_value,
             cyr_ytd_inv_value,
             cyr_ytw_inv_value,
             cyr_mat_inv_value,
             cyr_yte_op_value,
             cyr_yte_rob_value,
             cyr_ytg_br_value,
             cyr_ytg_fcst_value,
             nyr_yte_br_value,
             nyr_yte_fcst_value,
             cyr_yee_inv_fcst_value,
             cyr_yee_inv_br_value,
             p01_value,
             p02_value,
             p03_value,
             p04_value,
             p05_value,
             p06_value,
             p07_value,
             p08_value,
             p09_value,
             p10_value,
             p11_value,
             p12_value,
             p13_value,
             p14_value,
             p15_value,
             p16_value,
             p17_value,
             p18_value,
             p19_value,
             p20_value,
             p21_value,
             p22_value,
             p23_value,
             p24_value,
             p25_value,
             p26_value,
             p27_value)
         values
            (par_company_code,
             par_matl_code,
             par_acct_assgnmnt_grp_code,
             par_demand_plng_grp_code,
             '*GSV',
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
             0,
             0,
             0);

         /*-*/
         /* Data type TON
         /*-*/
         insert into sales_01_mart_t02
            (company_code,
             matl_code,
             acct_assgnmnt_grp_code,
             demand_plng_grp_code,
             data_type,
             lyr_yte_inv_value,
             cyr_ytd_inv_value,
             cyr_ytw_inv_value,
             cyr_mat_inv_value,
             cyr_yte_op_value,
             cyr_yte_rob_value,
             cyr_ytg_br_value,
             cyr_ytg_fcst_value,
             nyr_yte_br_value,
             nyr_yte_fcst_value,
             cyr_yee_inv_fcst_value,
             cyr_yee_inv_br_value,
             p01_value,
             p02_value,
             p03_value,
             p04_value,
             p05_value,
             p06_value,
             p07_value,
             p08_value,
             p09_value,
             p10_value,
             p11_value,
             p12_value,
             p13_value,
             p14_value,
             p15_value,
             p16_value,
             p17_value,
             p18_value,
             p19_value,
             p20_value,
             p21_value,
             p22_value,
             p23_value,
             p24_value,
             p25_value,
             p26_value,
             p27_value)
         values
            (par_company_code,
             par_matl_code,
             par_acct_assgnmnt_grp_code,
             par_demand_plng_grp_code,
             '*TON',
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
             0,
             0,
             0);

      end if;
      close csr_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_detail;

end dw_sales_01_mart;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_sales_01_mart for dw_app.dw_sales_01_mart;
grant execute on dw_sales_01_mart to public;