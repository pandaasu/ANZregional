/******************/
/* Package Header */
/******************/
create or replace package dw_mart_sales01 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_mart_sales01
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Dimensional Data Store - Mart Sales 01 Refresh

    The package refreshes the data mart for the sales 02 data mart. The package exposes
    one procedure REFRESH that performs the data mart refresh based on the following parameters:

    1. PAR_COMPANY_CODE (company code) (MANDATORY)

       The company for which the refresh is to be performed.

    **notes**

    1. This data mart is based on the time dimensions for sysdate minus one.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/06   Steve Gregan   Created
    2008/08   Steve Gregan   Modified sales extracts to consolidate on ZREP
    2008/08   Steve Gregan   Added ICB_FLAG to detail table
    2008/08   Steve Gregan   Modified for single execution
    2008/08   Steve Gregan   Removed assignment group code filter for forecasts
    2008/08   Steve Gregan   Added ship to customer code
    2008/08   Steve Gregan   Modified to GSV AUD
    2008/08   Linden Glen    Changed csr_order_extract_02 in order_extract to use hier_link_cust_code in join
    2008/10   Steve Gregan   Added PTW/PTG/LYRM1/LYRM2/P01-26FCST/P01-26BR
    2009/02   Steve Gregan   Removed *NZMKT from *MFANZ forecasts
    2009/05   Steve Gregan   Added new measures

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure refresh(par_company_code in varchar2);

end dw_mart_sales01;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_mart_sales01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract_header(par_company_code in varchar2);
   procedure extract_order(par_company_code in varchar2, par_data_segment in varchar2);
   procedure extract_sale(par_company_code in varchar2, par_data_segment in varchar2);
   procedure extract_forecast(par_company_code in varchar2, par_data_segment in varchar2);
   procedure extract_nzmkt_sale(par_company_code in varchar2, par_data_segment in varchar2);
   procedure extract_nzmkt_forecast(par_company_code in varchar2, par_data_segment in varchar2);
   procedure create_detail(par_company_code in varchar2,
                           par_data_segment in varchar2,
                           par_matl_group in varchar2,
                           par_ship_to_cust_code in varchar2,
                           par_matl_code in varchar2,
                           par_acct_assgnmnt_grp_code in varchar2,
                           par_demand_plng_grp_code in varchar2,
                           par_mfanz_icb_flag in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_header dw_mart_sales01_hdr%rowtype;
   rcd_detail dw_mart_sales01_det%rowtype;
   var_current_yyyypp number(6,0);
   var_current_yyyyppw number(7,0);
   var_current_date date;

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
      /* Refresh the header data
      /*-*/
      extract_header(par_company_code);

      /*-*/
      /* Update the extract header data
      /*-*/
      rcd_header.extract_date := sysdate;
      rcd_header.extract_str_time := sysdate;
      rcd_header.extract_end_time := sysdate;
      rcd_header.extract_yyyypp := rcd_header.current_yyyypp;

      /*-*/
      /* Clear the data mart data
      /*-*/
      delete from dw_mart_sales01_det where company_code = par_company_code;
      commit;

      /*-*/
      /* Refresh the order data
      /*-*/
      extract_order(par_company_code, '*MFANZ');
      commit;

      /*-*/
      /* Extract the sales data
      /*-*/
      extract_sale(par_company_code, '*MFANZ');
      commit;

      /*-*/
      /* Refresh the forecast data
      /*-*/
      extract_forecast(par_company_code, '*MFANZ');
      commit;

      /*-*/
      /* Refresh the NZ market sales data
      /*-*/
      extract_nzmkt_sale(par_company_code, '*NZMKT');
      commit;

      /*-*/
      /* Refresh the NZ market forecast data
      /*-*/
      extract_nzmkt_forecast(par_company_code, '*NZMKT');
      commit;

      /*-*/
      /* Update the extract header data
      /*-*/
      rcd_header.extract_end_time := sysdate;

      /*-*/
      /* Update the header data
      /*-*/
      update dw_mart_sales01_hdr
         set extract_date = rcd_header.extract_date,
             extract_str_time = rcd_header.extract_str_time,
             extract_end_time = rcd_header.extract_end_time,
             extract_yyyypp = rcd_header.extract_yyyypp
       where company_code = rcd_header.company_code;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_SALES_02_MART - REFRESH - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end refresh;

   /***************************************************/
   /* This procedure performs the header data routine */
   /***************************************************/
   procedure extract_header(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.*
           from dw_mart_sales01_hdr t01
          where t01.company_code = par_company_code;

      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company_code;
      rcd_company csr_company%rowtype;

      cursor csr_period is
         select t01.mars_year,
                t01.mars_period,
                t01.mars_week,
                t01.mars_yyyyppdd,
                t01.period_num,
                t01.mars_week_of_year,
                t01.mars_week_of_period,
                trunc(t01.calendar_date) as calendar_date
           from mars_date_dim t01
          where trunc(t01.calendar_date) = var_date;
      rcd_period csr_period%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the company information
      /*-*/
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         raise_application_error(-20000, 'Company ' || par_company_code || ' not found on the company table');
      end if;
      close csr_company;

      /*-*/
      /* Current date is always based on the previous day (converted using the company timezone)
      /*-*/
      var_date := trunc(sysdate-1);
      if rcd_company.company_timezone_code != 'Australia/NSW' then
         var_date := trunc(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')-1);
      end if;

      /*-*/
      /* Retrieve the current period information based on previous day
      /*-*/
      open csr_period;
      fetch csr_period into rcd_period;
      if csr_period%notfound then
         raise_application_error(-20000, 'No mars date found for ' || to_char(var_date,'yyyy/mm/dd'));
      end if;
      close csr_period;

      /*-*/
      /* Retrieve the data mart header
      /*-*/
      open csr_header;
      fetch csr_header into rcd_header;
      if csr_header%notfound then
         rcd_header.company_code := par_company_code;
         rcd_header.extract_date := to_date('19000101','yyyymmdd');
         rcd_header.extract_str_time := to_date('19000101','yyyymmdd');
         rcd_header.extract_end_time := to_date('19000101','yyyymmdd');
         rcd_header.extract_yyyypp := 0;
         rcd_header.current_yyyy := null;
         rcd_header.current_yyyypp := null;
         rcd_header.current_yyyyppw := null;
         rcd_header.current_yyyyppdd := null;
         rcd_header.current_pp := null;
         rcd_header.current_yw := null;
         rcd_header.current_pw := null;
         rcd_header.p01_heading := null;
         rcd_header.p02_heading := null;
         rcd_header.p03_heading := null;
         rcd_header.p04_heading := null;
         rcd_header.p05_heading := null;
         rcd_header.p06_heading := null;
         rcd_header.p07_heading := null;
         rcd_header.p08_heading := null;
         rcd_header.p09_heading := null;
         rcd_header.p10_heading := null;
         rcd_header.p11_heading := null;
         rcd_header.p12_heading := null;
         rcd_header.p13_heading := null;
         rcd_header.p14_heading := null;
         rcd_header.p15_heading := null;
         rcd_header.p16_heading := null;
         rcd_header.p17_heading := null;
         rcd_header.p18_heading := null;
         rcd_header.p19_heading := null;
         rcd_header.p20_heading := null;
         rcd_header.p21_heading := null;
         rcd_header.p22_heading := null;
         rcd_header.p23_heading := null;
         rcd_header.p24_heading := null;
         rcd_header.p25_heading := null;
         rcd_header.p26_heading := null;
      end if;
      close csr_header;

      /*-*/
      /* Set the period headings
      /*-*/
      rcd_header.current_yyyy := rcd_period.mars_year;
      rcd_header.current_yyyypp := rcd_period.mars_period;
      rcd_header.current_yyyyppw := rcd_period.mars_week;
      rcd_header.current_yyyyppdd := rcd_period.mars_yyyyppdd;
      rcd_header.current_pp := rcd_period.period_num;
      rcd_header.current_yw := rcd_period.mars_week_of_year;
      rcd_header.current_pw := rcd_period.mars_week_of_period;
      rcd_header.p01_heading := 'Fcst P1';
      rcd_header.p02_heading := 'Fcst P2';
      rcd_header.p03_heading := 'Fcst P3';
      rcd_header.p04_heading := 'Fcst P4';
      rcd_header.p05_heading := 'Fcst P5';
      rcd_header.p06_heading := 'Fcst P6';
      rcd_header.p07_heading := 'Fcst P7';
      rcd_header.p08_heading := 'Fcst P8';
      rcd_header.p09_heading := 'Fcst P9';
      rcd_header.p10_heading := 'Fcst P10';
      rcd_header.p11_heading := 'Fcst P11';
      rcd_header.p12_heading := 'Fcst P12';
      rcd_header.p13_heading := 'Fcst P13';
      if substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '02' then
         rcd_header.p01_heading := 'Actual P1';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '03' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '04' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '05' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '06' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '07' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '08' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
         rcd_header.p07_heading := 'Actual P7';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '09' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
         rcd_header.p07_heading := 'Actual P7';
         rcd_header.p08_heading := 'Actual P8';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '10' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
         rcd_header.p07_heading := 'Actual P7';
         rcd_header.p08_heading := 'Actual P8';
         rcd_header.p09_heading := 'Actual P9';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '11' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
         rcd_header.p07_heading := 'Actual P7';
         rcd_header.p08_heading := 'Actual P8';
         rcd_header.p09_heading := 'Actual P9';
         rcd_header.p10_heading := 'Actual P10';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '12' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
         rcd_header.p07_heading := 'Actual P7';
         rcd_header.p08_heading := 'Actual P8';
         rcd_header.p09_heading := 'Actual P9';
         rcd_header.p10_heading := 'Actual P10';
         rcd_header.p11_heading := 'Actual P11';
      elsif substr(to_char(rcd_period.mars_period,'fm000000'),5,2) = '13' then
         rcd_header.p01_heading := 'Actual P1';
         rcd_header.p02_heading := 'Actual P2';
         rcd_header.p03_heading := 'Actual P3';
         rcd_header.p04_heading := 'Actual P4';
         rcd_header.p05_heading := 'Actual P5';
         rcd_header.p06_heading := 'Actual P6';
         rcd_header.p07_heading := 'Actual P7';
         rcd_header.p08_heading := 'Actual P8';
         rcd_header.p09_heading := 'Actual P9';
         rcd_header.p10_heading := 'Actual P10';
         rcd_header.p11_heading := 'Actual P11';
         rcd_header.p12_heading := 'Actual P12';
      end if;
      rcd_header.p14_heading := 'Fcst P1';
      rcd_header.p15_heading := 'Fcst P2';
      rcd_header.p16_heading := 'Fcst P3';
      rcd_header.p17_heading := 'Fcst P4';
      rcd_header.p18_heading := 'Fcst P5';
      rcd_header.p19_heading := 'Fcst P6';
      rcd_header.p20_heading := 'Fcst P7';
      rcd_header.p21_heading := 'Fcst P8';
      rcd_header.p22_heading := 'Fcst P9';
      rcd_header.p23_heading := 'Fcst P10';
      rcd_header.p24_heading := 'Fcst P11';
      rcd_header.p25_heading := 'Fcst P12';
      rcd_header.p26_heading := 'Fcst P13';

      /*-*/
      /* Update/insert the data mart header
      /*-*/
      update dw_mart_sales01_hdr
         set extract_date = rcd_header.extract_date,
             extract_str_time = rcd_header.extract_str_time,
             extract_end_time = rcd_header.extract_end_time,
             extract_yyyypp = rcd_header.extract_yyyypp,
             current_yyyy = rcd_header.current_yyyy,
             current_yyyypp = rcd_header.current_yyyypp,
             current_yyyyppw = rcd_header.current_yyyyppw,
             current_yyyyppdd = rcd_header.current_yyyyppdd,
             current_pp = rcd_header.current_pp,
             current_yw = rcd_header.current_yw,
             current_pw = rcd_header.current_pw,
             p01_heading = rcd_header.p01_heading,
             p02_heading = rcd_header.p02_heading,
             p03_heading = rcd_header.p03_heading,
             p04_heading = rcd_header.p04_heading,
             p05_heading = rcd_header.p05_heading,
             p06_heading = rcd_header.p06_heading,
             p07_heading = rcd_header.p07_heading,
             p08_heading = rcd_header.p08_heading,
             p09_heading = rcd_header.p09_heading,
             p10_heading = rcd_header.p10_heading,
             p11_heading = rcd_header.p11_heading,
             p12_heading = rcd_header.p12_heading,
             p13_heading = rcd_header.p13_heading,
             p14_heading = rcd_header.p14_heading,
             p15_heading = rcd_header.p15_heading,
             p16_heading = rcd_header.p16_heading,
             p17_heading = rcd_header.p17_heading,
             p18_heading = rcd_header.p18_heading,
             p19_heading = rcd_header.p19_heading,
             p20_heading = rcd_header.p20_heading,
             p21_heading = rcd_header.p21_heading,
             p22_heading = rcd_header.p22_heading,
             p23_heading = rcd_header.p23_heading,
             p24_heading = rcd_header.p24_heading,
             p25_heading = rcd_header.p25_heading,
             p26_heading = rcd_header.p26_heading
       where company_code = rcd_header.company_code;
      if sql%notfound then
         insert into dw_mart_sales01_hdr values rcd_header;
      end if;

      /*-*/
      /* Set the private variables
      /*-*/
      var_current_yyyypp := rcd_period.mars_period;
      var_current_yyyyppw := rcd_period.mars_week;
      var_current_date := rcd_period.calendar_date;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_header;

   /**************************************************/
   /* This procedure performs the order data routine */
   /**************************************************/
   procedure extract_order(par_company_code in varchar2, par_data_segment in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_cpd_yyyypp number(6,0);
      var_cpd_yyyyppdd number(8,0);
      var_str_yyyyppdd number(8,0);
      var_end_yyyyppdd number(8,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_order_extract_01 is
         select t01.company_code,
                nvl(t01.ship_to_cust_code,'*NULL') as ship_to_cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(case when t01.order_eff_yyyypp = var_cpd_yyyypp then t01.con_qty_base_uom end),0) as cur_qty,
                nvl(sum(case when t01.order_eff_yyyypp = var_cpd_yyyypp then t01.con_gsv_aud end),0) as cur_gsv,
                nvl(sum(case when t01.order_eff_yyyypp = var_cpd_yyyypp then t01.con_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.order_eff_yyyypp > var_cpd_yyyypp then t01.con_qty_base_uom end),0) as fut_qty,
                nvl(sum(case when t01.order_eff_yyyypp > var_cpd_yyyypp then t01.con_gsv_aud end),0) as fut_gsv,
                nvl(sum(case when t01.order_eff_yyyypp > var_cpd_yyyypp then t01.con_qty_net_tonnes end),0) as fut_ton
           from dw_order_base t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.sales_org_code = t02.sales_org_code(+)
            and t01.sold_to_cust_code = t03.cust_code(+)
            and t01.distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.division_code = t03.division_code(+)
            and t01.sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.order_eff_yyyyppdd >= var_cpd_yyyyppdd
          group by t01.company_code,
                   t01.ship_to_cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_order_extract_01 csr_order_extract_01%rowtype;

      cursor csr_order_extract_02 is
         select t01.company_code,
                nvl(t01.ship_to_cust_code,'*NULL') as ship_to_cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(case when t01.cdw_eff_yyyyppdd <= var_end_yyyyppdd then t01.base_uom_qty end),0) as cur_qty,
                nvl(sum(case when t01.cdw_eff_yyyyppdd <= var_end_yyyyppdd then t01.gsv_aud end),0) as cur_gsv,
                nvl(sum(case when t01.cdw_eff_yyyyppdd <= var_end_yyyyppdd then t01.qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.cdw_eff_yyyyppdd > var_end_yyyyppdd then t01.base_uom_qty end),0) as fut_qty,
                nvl(sum(case when t01.cdw_eff_yyyyppdd > var_end_yyyyppdd then t01.gsv_aud end),0) as fut_gsv,
                nvl(sum(case when t01.cdw_eff_yyyyppdd > var_end_yyyyppdd then t01.qty_net_tonnes end),0) as fut_ton
           from outstanding_order_fact t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.sales_org_code = t02.sales_org_code(+)
            and t01.hier_link_cust_code = t03.cust_code(+)
            and t01.distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.division_code = t03.division_code(+)
            and t01.sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.cdw_eff_yyyyppdd >= var_str_yyyyppdd
          group by t01.company_code,
                   t01.ship_to_cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_order_extract_02 csr_order_extract_02%rowtype;

      cursor csr_order_extract_03 is
         select t01.company_code,
                nvl(t01.ship_to_cust_code,'*NULL') as ship_to_cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(t01.con_qty_base_uom),0) as cur_qty,
                nvl(sum(t01.con_gsv_aud),0) as cur_gsv,
                nvl(sum(t01.con_qty_net_tonnes),0) as cur_ton
           from dw_order_base t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.sales_org_code = t02.sales_org_code(+)
            and t01.sold_to_cust_code = t03.cust_code(+)
            and t01.distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.division_code = t03.division_code(+)
            and t01.sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.creatn_date = trunc(var_current_date)
          group by t01.company_code,
                   t01.ship_to_cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_order_extract_03 csr_order_extract_03%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate the period filters
      /*-*/
      var_cpd_yyyypp := var_current_yyyypp;
      var_cpd_yyyyppdd := var_current_yyyypp * 100;
      var_str_yyyyppdd := var_current_yyyypp * 100;
      var_end_yyyyppdd := (var_current_yyyypp * 100) + 99;

      /*-*/
      /* Extract the period order values
      /*-*/
      open csr_order_extract_01;
      loop
         fetch csr_order_extract_01 into rcd_order_extract_01;
         if csr_order_extract_01%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_order_extract_01.company_code,
                       par_data_segment,
                       '*ALL',
                       rcd_order_extract_01.ship_to_cust_code,
                       rcd_order_extract_01.matl_code,
                       rcd_order_extract_01.acct_assgnmnt_grp_code,
                       rcd_order_extract_01.demand_plng_grp_code,
                       rcd_order_extract_01.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_ord_value = cpd_ord_value + rcd_order_extract_01.cur_qty,
                fpd_ord_value = fpd_ord_value + rcd_order_extract_01.fut_qty
          where company_code = rcd_order_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_01.ship_to_cust_code
            and matl_code = rcd_order_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_01.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_ord_value = cpd_ord_value + rcd_order_extract_01.cur_gsv,
                fpd_ord_value = fpd_ord_value + rcd_order_extract_01.fut_gsv
          where company_code = rcd_order_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_01.ship_to_cust_code
            and matl_code = rcd_order_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_01.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_ord_value = cpd_ord_value + rcd_order_extract_01.cur_ton,
                fpd_ord_value = fpd_ord_value + rcd_order_extract_01.fut_ton
          where company_code = rcd_order_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_01.ship_to_cust_code
            and matl_code = rcd_order_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_01.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_order_extract_01;

      /*-*/
      /* Extract the period outstanding values
      /*-*/
      open csr_order_extract_02;
      loop
         fetch csr_order_extract_02 into rcd_order_extract_02;
         if csr_order_extract_02%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_order_extract_02.company_code,
                       par_data_segment,
                       '*ALL',
                       rcd_order_extract_02.ship_to_cust_code,
                       rcd_order_extract_02.matl_code,
                       rcd_order_extract_02.acct_assgnmnt_grp_code,
                       rcd_order_extract_02.demand_plng_grp_code,
                       rcd_order_extract_02.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_out_value = cpd_out_value + rcd_order_extract_02.cur_qty,
                fpd_out_value = fpd_out_value + rcd_order_extract_02.fut_qty
          where company_code = rcd_order_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_02.ship_to_cust_code
            and matl_code = rcd_order_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_02.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_out_value = cpd_out_value + rcd_order_extract_02.cur_gsv,
                fpd_out_value = fpd_out_value + rcd_order_extract_02.fut_gsv
          where company_code = rcd_order_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_02.ship_to_cust_code
            and matl_code = rcd_order_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_02.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_out_value = cpd_out_value + rcd_order_extract_02.cur_ton,
                fpd_out_value = fpd_out_value + rcd_order_extract_02.fut_ton
          where company_code = rcd_order_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_02.ship_to_cust_code
            and matl_code = rcd_order_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_02.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_order_extract_02;

      /*-*/
      /* Extract the daily order values
      /*-*/
      open csr_order_extract_03;
      loop
         fetch csr_order_extract_03 into rcd_order_extract_03;
         if csr_order_extract_03%notfound then
            exit;
         end if;

         /*-*/
         /* Create the data mart detail
         /*-*/
         create_detail(rcd_order_extract_03.company_code,
                       par_data_segment,
                       '*ALL',
                       rcd_order_extract_03.ship_to_cust_code,
                       rcd_order_extract_03.matl_code,
                       rcd_order_extract_03.acct_assgnmnt_grp_code,
                       rcd_order_extract_03.demand_plng_grp_code,
                       rcd_order_extract_03.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cdy_ord_value = cdy_ord_value + rcd_order_extract_03.cur_qty
          where company_code = rcd_order_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_03.ship_to_cust_code
            and matl_code = rcd_order_extract_03.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_03.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cdy_ord_value = cdy_ord_value + rcd_order_extract_03.cur_gsv
          where company_code = rcd_order_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_03.ship_to_cust_code
            and matl_code = rcd_order_extract_03.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_03.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cdy_ord_value = cdy_ord_value + rcd_order_extract_03.cur_ton
          where company_code = rcd_order_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_order_extract_03.ship_to_cust_code
            and matl_code = rcd_order_extract_03.matl_code
            and acct_assgnmnt_grp_code = rcd_order_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_order_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = rcd_order_extract_03.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_order_extract_03;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_order;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure extract_sale(par_company_code in varchar2, par_data_segment in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_lyrm2_str_yyyypp number(6,0);
      var_lyrm2_end_yyyypp number(6,0);
      var_lyrm1_str_yyyypp number(6,0);
      var_lyrm1_end_yyyypp number(6,0);
      var_lyr_str_yyyypp number(6,0);
      var_lyr_end_yyyypp number(6,0);
      var_ytp_str_yyyypp number(6,0);
      var_ytp_end_yyyypp number(6,0);
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
      var_lyr_p01 number(6,0);
      var_lyr_p02 number(6,0);
      var_lyr_p03 number(6,0);
      var_lyr_p04 number(6,0);
      var_lyr_p05 number(6,0);
      var_lyr_p06 number(6,0);
      var_lyr_p07 number(6,0);
      var_lyr_p08 number(6,0);
      var_lyr_p09 number(6,0);
      var_lyr_p10 number(6,0);
      var_lyr_p11 number(6,0);
      var_lyr_p12 number(6,0);
      var_lyr_p13 number(6,0);
      var_str_yyyypp number(6,0);
      var_cpd_yyyypp number(6,0);
      var_lpd_yyyypp number(6,0);
      var_ltp_str_yyyypp number(6,0);
      var_ltp_end_yyyypp number(6,0);
      var_ptw_str_yyyyppw number(7,0);
      var_ptw_end_yyyyppw number(7,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales_extract_01 is
         select t01.company_code,
                nvl(t01.ship_to_cust_code,'*NULL') as ship_to_cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lpd_yyyypp then t01.billed_qty_base_uom end),0) as lst_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lpd_yyyypp then t01.billed_gsv_aud end),0) as lst_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lpd_yyyypp then t01.billed_qty_net_tonnes end),0) as lst_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cpd_yyyypp then t01.billed_qty_base_uom end),0) as cur_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cpd_yyyypp then t01.billed_gsv_aud end),0) as cur_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_cpd_yyyypp then t01.billed_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.billing_eff_yyyypp > var_cpd_yyyypp then t01.billed_qty_base_uom end),0) as fut_qty,
                nvl(sum(case when t01.billing_eff_yyyypp > var_cpd_yyyypp then t01.billed_gsv_aud end),0) as fut_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp > var_cpd_yyyypp then t01.billed_qty_net_tonnes end),0) as fut_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyrm2_str_yyyypp and t01.billing_eff_yyyypp <= var_lyrm2_end_yyyypp then t01.billed_qty_base_uom end),0) as lyrm2_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyrm2_str_yyyypp and t01.billing_eff_yyyypp <= var_lyrm2_end_yyyypp then t01.billed_gsv_aud end),0) as lyrm2_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyrm2_str_yyyypp and t01.billing_eff_yyyypp <= var_lyrm2_end_yyyypp then t01.billed_qty_net_tonnes end),0) as lyrm2_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyrm1_str_yyyypp and t01.billing_eff_yyyypp <= var_lyrm1_end_yyyypp then t01.billed_qty_base_uom end),0) as lyrm1_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyrm1_str_yyyypp and t01.billing_eff_yyyypp <= var_lyrm1_end_yyyypp then t01.billed_gsv_aud end),0) as lyrm1_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyrm1_str_yyyypp and t01.billing_eff_yyyypp <= var_lyrm1_end_yyyypp then t01.billed_qty_net_tonnes end),0) as lyrm1_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyr_str_yyyypp and t01.billing_eff_yyyypp <= var_lyr_end_yyyypp then t01.billed_qty_base_uom end),0) as lyr_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyr_str_yyyypp and t01.billing_eff_yyyypp <= var_lyr_end_yyyypp then t01.billed_gsv_aud end),0) as lyr_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_lyr_str_yyyypp and t01.billing_eff_yyyypp <= var_lyr_end_yyyypp then t01.billed_qty_net_tonnes end),0) as lyr_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ltp_str_yyyypp and t01.billing_eff_yyyypp <= var_ltp_end_yyyypp then t01.billed_qty_base_uom end),0) as ltp_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ltp_str_yyyypp and t01.billing_eff_yyyypp <= var_ltp_end_yyyypp then t01.billed_gsv_aud end),0) as ltp_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ltp_str_yyyypp and t01.billing_eff_yyyypp <= var_ltp_end_yyyypp then t01.billed_qty_net_tonnes end),0) as ltp_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ytp_str_yyyypp and t01.billing_eff_yyyypp <= var_ytp_end_yyyypp then t01.billed_qty_base_uom end),0) as ytp_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ytp_str_yyyypp and t01.billing_eff_yyyypp <= var_ytp_end_yyyypp then t01.billed_gsv_aud end),0) as ytp_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_ytp_str_yyyypp and t01.billing_eff_yyyypp <= var_ytp_end_yyyypp then t01.billed_qty_net_tonnes end),0) as ytp_ton,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_mat_str_yyyypp and t01.billing_eff_yyyypp <= var_mat_end_yyyypp then t01.billed_qty_base_uom end),0) as mat_qty,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_mat_str_yyyypp and t01.billing_eff_yyyypp <= var_mat_end_yyyypp then t01.billed_gsv_aud end),0) as mat_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp >= var_mat_str_yyyypp and t01.billing_eff_yyyypp <= var_mat_end_yyyypp then t01.billed_qty_net_tonnes end),0) as mat_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p01 then t01.billed_qty_base_uom end),0) as l01_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p02 then t01.billed_qty_base_uom end),0) as l02_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p03 then t01.billed_qty_base_uom end),0) as l03_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p04 then t01.billed_qty_base_uom end),0) as l04_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p05 then t01.billed_qty_base_uom end),0) as l05_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p06 then t01.billed_qty_base_uom end),0) as l06_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p07 then t01.billed_qty_base_uom end),0) as l07_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p08 then t01.billed_qty_base_uom end),0) as l08_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p09 then t01.billed_qty_base_uom end),0) as l09_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p10 then t01.billed_qty_base_uom end),0) as l10_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p11 then t01.billed_qty_base_uom end),0) as l11_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p12 then t01.billed_qty_base_uom end),0) as l12_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p13 then t01.billed_qty_base_uom end),0) as l13_qty,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p01 then t01.billed_gsv_aud end),0) as l01_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p02 then t01.billed_gsv_aud end),0) as l02_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p03 then t01.billed_gsv_aud end),0) as l03_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p04 then t01.billed_gsv_aud end),0) as l04_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p05 then t01.billed_gsv_aud end),0) as l05_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p06 then t01.billed_gsv_aud end),0) as l06_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p07 then t01.billed_gsv_aud end),0) as l07_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p08 then t01.billed_gsv_aud end),0) as l08_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p09 then t01.billed_gsv_aud end),0) as l09_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p10 then t01.billed_gsv_aud end),0) as l10_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p11 then t01.billed_gsv_aud end),0) as l11_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p12 then t01.billed_gsv_aud end),0) as l12_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p13 then t01.billed_gsv_aud end),0) as l13_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p01 then t01.billed_qty_net_tonnes end),0) as l01_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p02 then t01.billed_qty_net_tonnes end),0) as l02_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p03 then t01.billed_qty_net_tonnes end),0) as l03_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p04 then t01.billed_qty_net_tonnes end),0) as l04_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p05 then t01.billed_qty_net_tonnes end),0) as l05_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p06 then t01.billed_qty_net_tonnes end),0) as l06_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p07 then t01.billed_qty_net_tonnes end),0) as l07_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p08 then t01.billed_qty_net_tonnes end),0) as l08_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p09 then t01.billed_qty_net_tonnes end),0) as l09_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p10 then t01.billed_qty_net_tonnes end),0) as l10_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p11 then t01.billed_qty_net_tonnes end),0) as l11_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p12 then t01.billed_qty_net_tonnes end),0) as l12_ton,
                nvl(sum(case when t01.billing_eff_yyyypp = var_lyr_p13 then t01.billed_qty_net_tonnes end),0) as l13_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_base_uom end),0) as p01_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_base_uom end),0) as p02_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_base_uom end),0) as p03_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_base_uom end),0) as p04_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_base_uom end),0) as p05_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_base_uom end),0) as p06_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_base_uom end),0) as p07_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_base_uom end),0) as p08_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_base_uom end),0) as p09_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_base_uom end),0) as p10_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_base_uom end),0) as p11_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_base_uom end),0) as p12_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_base_uom end),0) as p13_qty,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_gsv_aud end),0) as p01_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_gsv_aud end),0) as p02_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_gsv_aud end),0) as p03_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_gsv_aud end),0) as p04_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_gsv_aud end),0) as p05_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_gsv_aud end),0) as p06_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_gsv_aud end),0) as p07_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_gsv_aud end),0) as p08_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_gsv_aud end),0) as p09_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_gsv_aud end),0) as p10_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_gsv_aud end),0) as p11_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_gsv_aud end),0) as p12_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_gsv_aud end),0) as p13_gsv,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.billing_eff_yyyypp < var_cpd_yyyypp and t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_net_tonnes end),0) as p13_ton
           from dw_sales_period01 t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.hdr_distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.hdr_sales_org_code = t02.sales_org_code(+)
            and t01.sold_to_cust_code = t03.cust_code(+)
            and t01.hdr_distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.hdr_division_code = t03.division_code(+)
            and t01.hdr_sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.billing_eff_yyyypp >= var_str_yyyypp
          group by t01.company_code,
                   t01.ship_to_cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_sales_extract_01 csr_sales_extract_01%rowtype;

      cursor csr_sales_extract_02 is
         select t01.company_code,
                nvl(t01.ship_to_cust_code,'*NULL') as ship_to_cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(case when t01.billing_eff_date = trunc(var_current_date) then t01.billed_qty_base_uom end),0) as cur_qty,
                nvl(sum(case when t01.billing_eff_date = trunc(var_current_date) then t01.billed_gsv_aud end),0) as cur_gsv,
                nvl(sum(case when t01.billing_eff_date = trunc(var_current_date) then t01.billed_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw then t01.billed_qty_base_uom end),0) as ptw_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw then t01.billed_gsv_aud end),0) as ptw_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw then t01.billed_qty_net_tonnes end),0) as ptw_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_base_uom end),0) as w01_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_base_uom end),0) as w02_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_base_uom end),0) as w03_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_base_uom end),0) as w04_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_base_uom end),0) as w05_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_base_uom end),0) as w06_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_base_uom end),0) as w07_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_base_uom end),0) as w08_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_base_uom end),0) as w09_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_base_uom end),0) as w10_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_base_uom end),0) as w11_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_base_uom end),0) as w12_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_base_uom end),0) as w13_qty,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_gsv_aud end),0) as w01_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_gsv_aud end),0) as w02_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_gsv_aud end),0) as w03_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_gsv_aud end),0) as w04_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_gsv_aud end),0) as w05_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_gsv_aud end),0) as w06_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_gsv_aud end),0) as w07_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_gsv_aud end),0) as w08_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_gsv_aud end),0) as w09_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_gsv_aud end),0) as w10_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_gsv_aud end),0) as w11_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_gsv_aud end),0) as w12_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_gsv_aud end),0) as w13_gsv,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p01 then t01.billed_qty_net_tonnes end),0) as w01_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p02 then t01.billed_qty_net_tonnes end),0) as w02_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p03 then t01.billed_qty_net_tonnes end),0) as w03_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p04 then t01.billed_qty_net_tonnes end),0) as w04_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p05 then t01.billed_qty_net_tonnes end),0) as w05_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p06 then t01.billed_qty_net_tonnes end),0) as w06_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p07 then t01.billed_qty_net_tonnes end),0) as w07_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p08 then t01.billed_qty_net_tonnes end),0) as w08_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p09 then t01.billed_qty_net_tonnes end),0) as w09_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p10 then t01.billed_qty_net_tonnes end),0) as w10_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p11 then t01.billed_qty_net_tonnes end),0) as w11_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p12 then t01.billed_qty_net_tonnes end),0) as w12_ton,
                nvl(sum(case when t01.billing_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.billing_eff_yyyypp = var_cyr_p13 then t01.billed_qty_net_tonnes end),0) as w13_ton
           from dw_sales_base t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.ship_to_cust_code = t02.cust_code(+)
            and t01.hdr_distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.hdr_sales_org_code = t02.sales_org_code(+)
            and t01.sold_to_cust_code = t03.cust_code(+)
            and t01.hdr_distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.hdr_division_code = t03.division_code(+)
            and t01.hdr_sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.billing_eff_yyyypp = var_cpd_yyyypp
          group by t01.company_code,
                   t01.ship_to_cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_sales_extract_02 csr_sales_extract_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate the period and week filters
      /*-*/
      var_lyrm2_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 3) * 100) + 1;
      var_lyrm2_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 3) * 100) + 13;
      var_lyrm1_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 2) * 100) + 1;
      var_lyrm1_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 2) * 100) + 13;
      var_lyr_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 1) * 100) + 1;
      var_lyr_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 1) * 100) + 13;
      var_ytp_str_yyyypp := (to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100) + 1;
      var_ytp_end_yyyypp := var_current_yyyypp - 1;
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
      var_lyr_p01 := var_cyr_p01 - 100;
      var_lyr_p02 := var_cyr_p02 - 100;
      var_lyr_p03 := var_cyr_p03 - 100;
      var_lyr_p04 := var_cyr_p04 - 100;
      var_lyr_p05 := var_cyr_p05 - 100;
      var_lyr_p06 := var_cyr_p06 - 100;
      var_lyr_p07 := var_cyr_p07 - 100;
      var_lyr_p08 := var_cyr_p08 - 100;
      var_lyr_p09 := var_cyr_p09 - 100;
      var_lyr_p10 := var_cyr_p10 - 100;
      var_lyr_p11 := var_cyr_p11 - 100;
      var_lyr_p12 := var_cyr_p12 - 100;
      var_lyr_p13 := var_cyr_p13 - 100;
      var_str_yyyypp := var_lyrm2_str_yyyypp;
      var_cpd_yyyypp := var_current_yyyypp;
      var_lpd_yyyypp := var_current_yyyypp - 100;
      var_ltp_str_yyyypp := var_ytp_str_yyyypp - 100;
      var_ltp_end_yyyypp := var_ytp_end_yyyypp - 100;
      var_ptw_str_yyyyppw := (var_current_yyyypp * 10) + 1;
      var_ptw_end_yyyyppw := var_current_yyyyppw - 1;

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
         create_detail(rcd_sales_extract_01.company_code,
                       par_data_segment,
                       '*ALL',
                       rcd_sales_extract_01.ship_to_cust_code,
                       rcd_sales_extract_01.matl_code,
                       rcd_sales_extract_01.acct_assgnmnt_grp_code,
                       rcd_sales_extract_01.demand_plng_grp_code,
                       rcd_sales_extract_01.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set lyr_cpd_inv_value = lyr_cpd_inv_value + rcd_sales_extract_01.lst_qty,
                ptd_inv_value = ptd_inv_value + rcd_sales_extract_01.cur_qty,
                cpd_inv_value = cpd_inv_value + rcd_sales_extract_01.cur_qty,
                fpd_inv_value = fpd_inv_value + rcd_sales_extract_01.fut_qty,
                lyr_yee_inv_value = lyr_yee_inv_value + rcd_sales_extract_01.lyr_qty,
                lyrm1_yee_inv_value = lyrm1_yee_inv_value + rcd_sales_extract_01.lyrm1_qty,
                lyrm2_yee_inv_value = lyrm2_yee_inv_value + rcd_sales_extract_01.lyrm2_qty,
                lyr_ytp_inv_value = lyr_ytp_inv_value + rcd_sales_extract_01.ltp_qty,
                cyr_ytp_inv_value = cyr_ytp_inv_value + rcd_sales_extract_01.ytp_qty,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_qty,
                cyr_yee_br_value = cyr_yee_br_value + rcd_sales_extract_01.ytp_qty,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_01.ytp_qty,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_01.p01_qty,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_01.p02_qty,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_01.p03_qty,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_01.p04_qty,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_01.p05_qty,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_01.p06_qty,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_01.p07_qty,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_01.p08_qty,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_01.p09_qty,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_01.p10_qty,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_01.p11_qty,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_01.p12_qty,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_01.p13_qty,
                p01_br_value = p01_br_value + rcd_sales_extract_01.p01_qty,
                p02_br_value = p02_br_value + rcd_sales_extract_01.p02_qty,
                p03_br_value = p03_br_value + rcd_sales_extract_01.p03_qty,
                p04_br_value = p04_br_value + rcd_sales_extract_01.p04_qty,
                p05_br_value = p05_br_value + rcd_sales_extract_01.p05_qty,
                p06_br_value = p06_br_value + rcd_sales_extract_01.p06_qty,
                p07_br_value = p07_br_value + rcd_sales_extract_01.p07_qty,
                p08_br_value = p08_br_value + rcd_sales_extract_01.p08_qty,
                p09_br_value = p09_br_value + rcd_sales_extract_01.p09_qty,
                p10_br_value = p10_br_value + rcd_sales_extract_01.p10_qty,
                p11_br_value = p11_br_value + rcd_sales_extract_01.p11_qty,
                p12_br_value = p12_br_value + rcd_sales_extract_01.p12_qty,
                p13_br_value = p13_br_value + rcd_sales_extract_01.p13_qty,
                p01_rob_value = p01_rob_value + rcd_sales_extract_01.p01_qty,
                p02_rob_value = p02_rob_value + rcd_sales_extract_01.p02_qty,
                p03_rob_value = p03_rob_value + rcd_sales_extract_01.p03_qty,
                p04_rob_value = p04_rob_value + rcd_sales_extract_01.p04_qty,
                p05_rob_value = p05_rob_value + rcd_sales_extract_01.p05_qty,
                p06_rob_value = p06_rob_value + rcd_sales_extract_01.p06_qty,
                p07_rob_value = p07_rob_value + rcd_sales_extract_01.p07_qty,
                p08_rob_value = p08_rob_value + rcd_sales_extract_01.p08_qty,
                p09_rob_value = p09_rob_value + rcd_sales_extract_01.p09_qty,
                p10_rob_value = p10_rob_value + rcd_sales_extract_01.p10_qty,
                p11_rob_value = p11_rob_value + rcd_sales_extract_01.p11_qty,
                p12_rob_value = p12_rob_value + rcd_sales_extract_01.p12_qty,
                p13_rob_value = p13_rob_value + rcd_sales_extract_01.p13_qty,
                p01_lyr_value = p01_lyr_value + rcd_sales_extract_01.l01_qty,
                p02_lyr_value = p02_lyr_value + rcd_sales_extract_01.l02_qty,
                p03_lyr_value = p03_lyr_value + rcd_sales_extract_01.l03_qty,
                p04_lyr_value = p04_lyr_value + rcd_sales_extract_01.l04_qty,
                p05_lyr_value = p05_lyr_value + rcd_sales_extract_01.l05_qty,
                p06_lyr_value = p06_lyr_value + rcd_sales_extract_01.l06_qty,
                p07_lyr_value = p07_lyr_value + rcd_sales_extract_01.l07_qty,
                p08_lyr_value = p08_lyr_value + rcd_sales_extract_01.l08_qty,
                p09_lyr_value = p09_lyr_value + rcd_sales_extract_01.l09_qty,
                p10_lyr_value = p10_lyr_value + rcd_sales_extract_01.l10_qty,
                p11_lyr_value = p11_lyr_value + rcd_sales_extract_01.l11_qty,
                p12_lyr_value = p12_lyr_value + rcd_sales_extract_01.l12_qty,
                p13_lyr_value = p13_lyr_value + rcd_sales_extract_01.l13_qty
          where company_code = rcd_sales_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_sales_extract_01.ship_to_cust_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_01.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set lyr_cpd_inv_value = lyr_cpd_inv_value + rcd_sales_extract_01.lst_gsv,
                ptd_inv_value = ptd_inv_value + rcd_sales_extract_01.cur_gsv,
                cpd_inv_value = cpd_inv_value + rcd_sales_extract_01.cur_gsv,
                fpd_inv_value = fpd_inv_value + rcd_sales_extract_01.fut_gsv,
                lyr_yee_inv_value = lyr_yee_inv_value + rcd_sales_extract_01.lyr_gsv,
                lyrm1_yee_inv_value = lyrm1_yee_inv_value + rcd_sales_extract_01.lyrm1_gsv,
                lyrm2_yee_inv_value = lyrm2_yee_inv_value + rcd_sales_extract_01.lyrm2_gsv,
                lyr_ytp_inv_value = lyr_ytp_inv_value + rcd_sales_extract_01.ltp_gsv,
                cyr_ytp_inv_value = cyr_ytp_inv_value + rcd_sales_extract_01.ytp_gsv,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_gsv,
                cyr_yee_br_value = cyr_yee_br_value + rcd_sales_extract_01.ytp_gsv,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_01.ytp_gsv,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_01.p01_gsv,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_01.p02_gsv,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_01.p03_gsv,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_01.p04_gsv,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_01.p05_gsv,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_01.p06_gsv,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_01.p07_gsv,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_01.p08_gsv,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_01.p09_gsv,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_01.p10_gsv,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_01.p11_gsv,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_01.p12_gsv,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_01.p13_gsv,
                p01_br_value = p01_br_value + rcd_sales_extract_01.p01_gsv,
                p02_br_value = p02_br_value + rcd_sales_extract_01.p02_gsv,
                p03_br_value = p03_br_value + rcd_sales_extract_01.p03_gsv,
                p04_br_value = p04_br_value + rcd_sales_extract_01.p04_gsv,
                p05_br_value = p05_br_value + rcd_sales_extract_01.p05_gsv,
                p06_br_value = p06_br_value + rcd_sales_extract_01.p06_gsv,
                p07_br_value = p07_br_value + rcd_sales_extract_01.p07_gsv,
                p08_br_value = p08_br_value + rcd_sales_extract_01.p08_gsv,
                p09_br_value = p09_br_value + rcd_sales_extract_01.p09_gsv,
                p10_br_value = p10_br_value + rcd_sales_extract_01.p10_gsv,
                p11_br_value = p11_br_value + rcd_sales_extract_01.p11_gsv,
                p12_br_value = p12_br_value + rcd_sales_extract_01.p12_gsv,
                p13_br_value = p13_br_value + rcd_sales_extract_01.p13_gsv,
                p01_rob_value = p01_rob_value + rcd_sales_extract_01.p01_gsv,
                p02_rob_value = p02_rob_value + rcd_sales_extract_01.p02_gsv,
                p03_rob_value = p03_rob_value + rcd_sales_extract_01.p03_gsv,
                p04_rob_value = p04_rob_value + rcd_sales_extract_01.p04_gsv,
                p05_rob_value = p05_rob_value + rcd_sales_extract_01.p05_gsv,
                p06_rob_value = p06_rob_value + rcd_sales_extract_01.p06_gsv,
                p07_rob_value = p07_rob_value + rcd_sales_extract_01.p07_gsv,
                p08_rob_value = p08_rob_value + rcd_sales_extract_01.p08_gsv,
                p09_rob_value = p09_rob_value + rcd_sales_extract_01.p09_gsv,
                p10_rob_value = p10_rob_value + rcd_sales_extract_01.p10_gsv,
                p11_rob_value = p11_rob_value + rcd_sales_extract_01.p11_gsv,
                p12_rob_value = p12_rob_value + rcd_sales_extract_01.p12_gsv,
                p13_rob_value = p13_rob_value + rcd_sales_extract_01.p13_gsv,
                p01_lyr_value = p01_lyr_value + rcd_sales_extract_01.l01_gsv,
                p02_lyr_value = p02_lyr_value + rcd_sales_extract_01.l02_gsv,
                p03_lyr_value = p03_lyr_value + rcd_sales_extract_01.l03_gsv,
                p04_lyr_value = p04_lyr_value + rcd_sales_extract_01.l04_gsv,
                p05_lyr_value = p05_lyr_value + rcd_sales_extract_01.l05_gsv,
                p06_lyr_value = p06_lyr_value + rcd_sales_extract_01.l06_gsv,
                p07_lyr_value = p07_lyr_value + rcd_sales_extract_01.l07_gsv,
                p08_lyr_value = p08_lyr_value + rcd_sales_extract_01.l08_gsv,
                p09_lyr_value = p09_lyr_value + rcd_sales_extract_01.l09_gsv,
                p10_lyr_value = p10_lyr_value + rcd_sales_extract_01.l10_gsv,
                p11_lyr_value = p11_lyr_value + rcd_sales_extract_01.l11_gsv,
                p12_lyr_value = p12_lyr_value + rcd_sales_extract_01.l12_gsv,
                p13_lyr_value = p13_lyr_value + rcd_sales_extract_01.l13_gsv
          where company_code = rcd_sales_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_sales_extract_01.ship_to_cust_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_01.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set lyr_cpd_inv_value = lyr_cpd_inv_value + rcd_sales_extract_01.lst_ton,
                ptd_inv_value = ptd_inv_value + rcd_sales_extract_01.cur_ton,
                cpd_inv_value = cpd_inv_value + rcd_sales_extract_01.cur_ton,
                fpd_inv_value = fpd_inv_value + rcd_sales_extract_01.fut_ton,
                lyr_yee_inv_value = lyr_yee_inv_value + rcd_sales_extract_01.lyr_ton,
                lyrm1_yee_inv_value = lyrm1_yee_inv_value + rcd_sales_extract_01.lyrm1_ton,
                lyrm2_yee_inv_value = lyrm2_yee_inv_value + rcd_sales_extract_01.lyrm2_ton,
                lyr_ytp_inv_value = lyr_ytp_inv_value + rcd_sales_extract_01.ltp_ton,
                cyr_ytp_inv_value = cyr_ytp_inv_value + rcd_sales_extract_01.ytp_ton,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_ton,
                cyr_yee_br_value = cyr_yee_br_value + rcd_sales_extract_01.ytp_ton,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_01.ytp_ton,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_01.p01_ton,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_01.p02_ton,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_01.p03_ton,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_01.p04_ton,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_01.p05_ton,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_01.p06_ton,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_01.p07_ton,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_01.p08_ton,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_01.p09_ton,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_01.p10_ton,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_01.p11_ton,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_01.p12_ton,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_01.p13_ton,
                p01_br_value = p01_br_value + rcd_sales_extract_01.p01_ton,
                p02_br_value = p02_br_value + rcd_sales_extract_01.p02_ton,
                p03_br_value = p03_br_value + rcd_sales_extract_01.p03_ton,
                p04_br_value = p04_br_value + rcd_sales_extract_01.p04_ton,
                p05_br_value = p05_br_value + rcd_sales_extract_01.p05_ton,
                p06_br_value = p06_br_value + rcd_sales_extract_01.p06_ton,
                p07_br_value = p07_br_value + rcd_sales_extract_01.p07_ton,
                p08_br_value = p08_br_value + rcd_sales_extract_01.p08_ton,
                p09_br_value = p09_br_value + rcd_sales_extract_01.p09_ton,
                p10_br_value = p10_br_value + rcd_sales_extract_01.p10_ton,
                p11_br_value = p11_br_value + rcd_sales_extract_01.p11_ton,
                p12_br_value = p12_br_value + rcd_sales_extract_01.p12_ton,
                p13_br_value = p13_br_value + rcd_sales_extract_01.p13_ton,
                p01_rob_value = p01_rob_value + rcd_sales_extract_01.p01_ton,
                p02_rob_value = p02_rob_value + rcd_sales_extract_01.p02_ton,
                p03_rob_value = p03_rob_value + rcd_sales_extract_01.p03_ton,
                p04_rob_value = p04_rob_value + rcd_sales_extract_01.p04_ton,
                p05_rob_value = p05_rob_value + rcd_sales_extract_01.p05_ton,
                p06_rob_value = p06_rob_value + rcd_sales_extract_01.p06_ton,
                p07_rob_value = p07_rob_value + rcd_sales_extract_01.p07_ton,
                p08_rob_value = p08_rob_value + rcd_sales_extract_01.p08_ton,
                p09_rob_value = p09_rob_value + rcd_sales_extract_01.p09_ton,
                p10_rob_value = p10_rob_value + rcd_sales_extract_01.p10_ton,
                p11_rob_value = p11_rob_value + rcd_sales_extract_01.p11_ton,
                p12_rob_value = p12_rob_value + rcd_sales_extract_01.p12_ton,
                p13_rob_value = p13_rob_value + rcd_sales_extract_01.p13_ton,
                p01_lyr_value = p01_lyr_value + rcd_sales_extract_01.l01_ton,
                p02_lyr_value = p02_lyr_value + rcd_sales_extract_01.l02_ton,
                p03_lyr_value = p03_lyr_value + rcd_sales_extract_01.l03_ton,
                p04_lyr_value = p04_lyr_value + rcd_sales_extract_01.l04_ton,
                p05_lyr_value = p05_lyr_value + rcd_sales_extract_01.l05_ton,
                p06_lyr_value = p06_lyr_value + rcd_sales_extract_01.l06_ton,
                p07_lyr_value = p07_lyr_value + rcd_sales_extract_01.l07_ton,
                p08_lyr_value = p08_lyr_value + rcd_sales_extract_01.l08_ton,
                p09_lyr_value = p09_lyr_value + rcd_sales_extract_01.l09_ton,
                p10_lyr_value = p10_lyr_value + rcd_sales_extract_01.l10_ton,
                p11_lyr_value = p11_lyr_value + rcd_sales_extract_01.l11_ton,
                p12_lyr_value = p12_lyr_value + rcd_sales_extract_01.l12_ton,
                p13_lyr_value = p13_lyr_value + rcd_sales_extract_01.l13_ton
          where company_code = rcd_sales_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_sales_extract_01.ship_to_cust_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_01.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_sales_extract_01;

      /*-*/
      /* Extract the daily sales values
      /*-*/
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
                       par_data_segment,
                       '*ALL',
                       rcd_sales_extract_02.ship_to_cust_code,
                       rcd_sales_extract_02.matl_code,
                       rcd_sales_extract_02.acct_assgnmnt_grp_code,
                       rcd_sales_extract_02.demand_plng_grp_code,
                       rcd_sales_extract_02.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cdy_inv_value = cdy_inv_value + rcd_sales_extract_02.cur_qty,
                ptw_inv_value = ptw_inv_value + rcd_sales_extract_02.ptw_qty,
                cpd_fcst_value = cpd_fcst_value + rcd_sales_extract_02.ptw_qty,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_02.ptw_qty,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_02.w01_qty,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_02.w02_qty,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_02.w03_qty,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_02.w04_qty,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_02.w05_qty,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_02.w06_qty,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_02.w07_qty,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_02.w08_qty,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_02.w09_qty,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_02.w10_qty,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_02.w11_qty,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_02.w12_qty,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_02.w13_qty
          where company_code = rcd_sales_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_sales_extract_02.ship_to_cust_code
            and matl_code = rcd_sales_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_02.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cdy_inv_value = cdy_inv_value + rcd_sales_extract_02.cur_gsv,
                ptw_inv_value = ptw_inv_value + rcd_sales_extract_02.ptw_gsv,
                cpd_fcst_value = cpd_fcst_value + rcd_sales_extract_02.ptw_gsv,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_02.ptw_gsv,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_02.w01_gsv,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_02.w02_gsv,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_02.w03_gsv,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_02.w04_gsv,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_02.w05_gsv,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_02.w06_gsv,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_02.w07_gsv,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_02.w08_gsv,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_02.w09_gsv,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_02.w10_gsv,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_02.w11_gsv,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_02.w12_gsv,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_02.w13_gsv
          where company_code = rcd_sales_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_sales_extract_02.ship_to_cust_code
            and matl_code = rcd_sales_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_02.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cdy_inv_value = cdy_inv_value + rcd_sales_extract_02.cur_ton,
                ptw_inv_value = ptw_inv_value + rcd_sales_extract_02.ptw_ton,
                cpd_fcst_value = cpd_fcst_value + rcd_sales_extract_02.ptw_ton,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_02.ptw_ton,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_02.w01_ton,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_02.w02_ton,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_02.w03_ton,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_02.w04_ton,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_02.w05_ton,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_02.w06_ton,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_02.w07_ton,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_02.w08_ton,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_02.w09_ton,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_02.w10_ton,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_02.w11_ton,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_02.w12_ton,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_02.w13_ton
          where company_code = rcd_sales_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_sales_extract_02.ship_to_cust_code
            and matl_code = rcd_sales_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_02.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_sales_extract_02;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_sale;

   /*****************************************************/
   /* This procedure performs the forecast data routine */
   /*****************************************************/
   procedure extract_forecast(par_company_code in varchar2, par_data_segment in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_cyr_str_yyyypp number(6,0);
      var_cyr_end_yyyypp number(6,0);
      var_ytg_str_yyyypp number(6,0);
      var_ytg_end_yyyypp number(6,0);
      var_nyr_str_yyyypp number(6,0);
      var_nyr_end_yyyypp number(6,0);
      var_ptg_str_yyyyppw number(7,0);
      var_ptg_end_yyyyppw number(7,0);
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
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty end),0) as cur_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as cur_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(t01.fcst_qty),0) as yee_qty,
                nvl(sum(t01.fcst_value_aud),0) as yee_gsv,
                nvl(sum(t01.fcst_qty_net_tonnes),0) as yee_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_cyr_str_yyyypp
            and t01.fcst_yyyypp <= var_cyr_end_yyyypp
            and t01.fcst_type_code = 'OP'
            and not(t01.acct_assgnmnt_grp_code = '03'
                    and t01.demand_plng_grp_code = '0040010915'
                    and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45')))
          group by t01.company_code,
                   t01.cust_code,
                   t01.matl_zrep_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_01 csr_fcst_extract_01%rowtype;

      cursor csr_fcst_extract_02 is
         select t01.company_code,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty end),0) as cur_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as cur_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_cyr_end_yyyypp
            and t01.fcst_type_code = 'ROB'
            and not(t01.acct_assgnmnt_grp_code = '03'
                    and t01.demand_plng_grp_code = '0040010915'
                    and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45')))
          group by t01.company_code,
                   t01.cust_code,
                   t01.matl_zrep_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_02 csr_fcst_extract_02%rowtype;

      cursor csr_fcst_extract_03 is
         select t01.company_code,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty end),0) as cur_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as cur_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_value_aud end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty end),0) as nyr_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_value_aud end),0) as nyr_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as nyr_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty end),0) as p14_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty end),0) as p15_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty end),0) as p16_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty end),0) as p17_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty end),0) as p18_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty end),0) as P19_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty end),0) as p20_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty end),0) as p21_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty end),0) as p22_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty end),0) as p23_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty end),0) as p24_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty end),0) as p25_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty end),0) as p26_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_value_aud end),0) as p14_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_value_aud end),0) as p15_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_value_aud end),0) as p16_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_value_aud end),0) as p17_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_value_aud end),0) as p18_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_value_aud end),0) as p19_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_value_aud end),0) as p20_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_value_aud end),0) as p21_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_value_aud end),0) as p22_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_value_aud end),0) as p23_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_value_aud end),0) as p24_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_value_aud end),0) as p25_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_value_aud end),0) as p26_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty_net_tonnes end),0) as p14_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty_net_tonnes end),0) as p15_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty_net_tonnes end),0) as p16_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty_net_tonnes end),0) as p17_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty_net_tonnes end),0) as p18_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty_net_tonnes end),0) as p19_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty_net_tonnes end),0) as p20_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty_net_tonnes end),0) as p21_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty_net_tonnes end),0) as p22_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty_net_tonnes end),0) as p23_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty_net_tonnes end),0) as p24_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty_net_tonnes end),0) as p25_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty_net_tonnes end),0) as p26_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_nyr_end_yyyypp
            and t01.fcst_type_code = 'BR'
            and not(t01.acct_assgnmnt_grp_code = '03'
                    and t01.demand_plng_grp_code = '0040010915'
                    and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45')))
          group by t01.company_code,
                   t01.cust_code,
                   t01.matl_zrep_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_03 csr_fcst_extract_03%rowtype;

      cursor csr_fcst_extract_04 is
         select t01.company_code,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyyppw <= var_ptg_end_yyyyppw then t01.fcst_qty end),0) as ptg_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyyppw <= var_ptg_end_yyyyppw then t01.fcst_value_aud end),0) as ptg_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyyppw <= var_ptg_end_yyyyppw then t01.fcst_qty_net_tonnes end),0) as ptg_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_value_aud end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty end),0) as nyr_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_value_aud end),0) as nyr_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as nyr_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty end),0) as p14_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty end),0) as p15_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty end),0) as p16_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty end),0) as p17_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty end),0) as p18_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty end),0) as P19_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty end),0) as p20_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty end),0) as p21_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty end),0) as p22_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty end),0) as p23_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty end),0) as p24_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty end),0) as p25_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty end),0) as p26_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_value_aud end),0) as p14_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_value_aud end),0) as p15_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_value_aud end),0) as p16_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_value_aud end),0) as p17_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_value_aud end),0) as p18_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_value_aud end),0) as p19_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_value_aud end),0) as p20_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_value_aud end),0) as p21_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_value_aud end),0) as p22_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_value_aud end),0) as p23_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_value_aud end),0) as p24_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_value_aud end),0) as p25_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_value_aud end),0) as p26_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty_net_tonnes end),0) as p14_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty_net_tonnes end),0) as p15_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty_net_tonnes end),0) as p16_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty_net_tonnes end),0) as p17_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty_net_tonnes end),0) as p18_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty_net_tonnes end),0) as p19_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty_net_tonnes end),0) as p20_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty_net_tonnes end),0) as p21_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty_net_tonnes end),0) as p22_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty_net_tonnes end),0) as p23_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty_net_tonnes end),0) as p24_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty_net_tonnes end),0) as p25_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty_net_tonnes end),0) as p26_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_nyr_end_yyyypp
            and t01.fcst_type_code = 'FCST'
            and not(t01.acct_assgnmnt_grp_code = '03'
                    and t01.demand_plng_grp_code = '0040010915'
                    and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45')))
          group by t01.company_code,
                   t01.cust_code,
                   t01.matl_zrep_code,
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
      var_ptg_str_yyyyppw := var_current_yyyyppw;
      var_ptg_end_yyyyppw := (var_current_yyyypp * 10) + 4;
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
                       par_data_segment,
                       '*ALL',
                       rcd_fcst_extract_01.cust_code,
                       rcd_fcst_extract_01.matl_zrep_code,
                       rcd_fcst_extract_01.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_01.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_op_value = cpd_op_value + rcd_fcst_extract_01.cur_qty,
                cyr_yee_op_value = cyr_yee_op_value + rcd_fcst_extract_01.yee_qty,
                p01_op_value = p01_br_value + rcd_fcst_extract_01.p01_qty,
                p02_op_value = p02_op_value + rcd_fcst_extract_01.p02_qty,
                p03_op_value = p03_op_value + rcd_fcst_extract_01.p03_qty,
                p04_op_value = p04_op_value + rcd_fcst_extract_01.p04_qty,
                p05_op_value = p05_op_value + rcd_fcst_extract_01.p05_qty,
                p06_op_value = p06_op_value + rcd_fcst_extract_01.p06_qty,
                p07_op_value = p07_op_value + rcd_fcst_extract_01.p07_qty,
                p08_op_value = p08_op_value + rcd_fcst_extract_01.p08_qty,
                p09_op_value = p09_op_value + rcd_fcst_extract_01.p09_qty,
                p10_op_value = p10_op_value + rcd_fcst_extract_01.p10_qty,
                p11_op_value = p11_op_value + rcd_fcst_extract_01.p11_qty,
                p12_op_value = p12_op_value + rcd_fcst_extract_01.p12_qty,
                p13_op_value = p13_op_value + rcd_fcst_extract_01.p13_qty
          where company_code = rcd_fcst_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_01.cust_code
            and matl_code = rcd_fcst_extract_01.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_op_value = cpd_op_value + rcd_fcst_extract_01.cur_gsv,
                cyr_yee_op_value = cyr_yee_op_value + rcd_fcst_extract_01.yee_gsv,
                p01_op_value = p01_br_value + rcd_fcst_extract_01.p01_gsv,
                p02_op_value = p02_op_value + rcd_fcst_extract_01.p02_gsv,
                p03_op_value = p03_op_value + rcd_fcst_extract_01.p03_gsv,
                p04_op_value = p04_op_value + rcd_fcst_extract_01.p04_gsv,
                p05_op_value = p05_op_value + rcd_fcst_extract_01.p05_gsv,
                p06_op_value = p06_op_value + rcd_fcst_extract_01.p06_gsv,
                p07_op_value = p07_op_value + rcd_fcst_extract_01.p07_gsv,
                p08_op_value = p08_op_value + rcd_fcst_extract_01.p08_gsv,
                p09_op_value = p09_op_value + rcd_fcst_extract_01.p09_gsv,
                p10_op_value = p10_op_value + rcd_fcst_extract_01.p10_gsv,
                p11_op_value = p11_op_value + rcd_fcst_extract_01.p11_gsv,
                p12_op_value = p12_op_value + rcd_fcst_extract_01.p12_gsv,
                p13_op_value = p13_op_value + rcd_fcst_extract_01.p13_gsv
          where company_code = rcd_fcst_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_01.cust_code
            and matl_code = rcd_fcst_extract_01.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_op_value = cpd_op_value + rcd_fcst_extract_01.cur_ton,
                cyr_yee_op_value = cyr_yee_op_value + rcd_fcst_extract_01.yee_ton,
                p01_op_value = p01_br_value + rcd_fcst_extract_01.p01_ton,
                p02_op_value = p02_op_value + rcd_fcst_extract_01.p02_ton,
                p03_op_value = p03_op_value + rcd_fcst_extract_01.p03_ton,
                p04_op_value = p04_op_value + rcd_fcst_extract_01.p04_ton,
                p05_op_value = p05_op_value + rcd_fcst_extract_01.p05_ton,
                p06_op_value = p06_op_value + rcd_fcst_extract_01.p06_ton,
                p07_op_value = p07_op_value + rcd_fcst_extract_01.p07_ton,
                p08_op_value = p08_op_value + rcd_fcst_extract_01.p08_ton,
                p09_op_value = p09_op_value + rcd_fcst_extract_01.p09_ton,
                p10_op_value = p10_op_value + rcd_fcst_extract_01.p10_ton,
                p11_op_value = p11_op_value + rcd_fcst_extract_01.p11_ton,
                p12_op_value = p12_op_value + rcd_fcst_extract_01.p12_ton,
                p13_op_value = p13_op_value + rcd_fcst_extract_01.p13_ton
          where company_code = rcd_fcst_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_01.cust_code
            and matl_code = rcd_fcst_extract_01.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
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
                       par_data_segment,
                       '*ALL',
                       rcd_fcst_extract_02.cust_code,
                       rcd_fcst_extract_02.matl_zrep_code,
                       rcd_fcst_extract_02.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_02.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_rob_value = cpd_rob_value + rcd_fcst_extract_02.cur_qty,
                cyr_ytg_rob_value = cyr_ytg_rob_value + rcd_fcst_extract_02.ytg_qty,
                cyr_yee_rob_value = cyr_yee_rob_value + rcd_fcst_extract_02.ytg_qty,
                p01_rob_value = p01_rob_value + rcd_fcst_extract_02.p01_qty,
                p02_rob_value = p02_rob_value + rcd_fcst_extract_02.p02_qty,
                p03_rob_value = p03_rob_value + rcd_fcst_extract_02.p03_qty,
                p04_rob_value = p04_rob_value + rcd_fcst_extract_02.p04_qty,
                p05_rob_value = p05_rob_value + rcd_fcst_extract_02.p05_qty,
                p06_rob_value = p06_rob_value + rcd_fcst_extract_02.p06_qty,
                p07_rob_value = p07_rob_value + rcd_fcst_extract_02.p07_qty,
                p08_rob_value = p08_rob_value + rcd_fcst_extract_02.p08_qty,
                p09_rob_value = p09_rob_value + rcd_fcst_extract_02.p09_qty,
                p10_rob_value = p10_rob_value + rcd_fcst_extract_02.p10_qty,
                p11_rob_value = p11_rob_value + rcd_fcst_extract_02.p11_qty,
                p12_rob_value = p12_rob_value + rcd_fcst_extract_02.p12_qty,
                p13_rob_value = p13_rob_value + rcd_fcst_extract_02.p13_qty
          where company_code = rcd_fcst_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_02.cust_code
            and matl_code = rcd_fcst_extract_02.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_rob_value = cpd_rob_value + rcd_fcst_extract_02.cur_gsv,
                cyr_ytg_rob_value = cyr_ytg_rob_value + rcd_fcst_extract_02.ytg_gsv,
                cyr_yee_rob_value = cyr_yee_rob_value + rcd_fcst_extract_02.ytg_gsv,
                p01_rob_value = p01_rob_value + rcd_fcst_extract_02.p01_gsv,
                p02_rob_value = p02_rob_value + rcd_fcst_extract_02.p02_gsv,
                p03_rob_value = p03_rob_value + rcd_fcst_extract_02.p03_gsv,
                p04_rob_value = p04_rob_value + rcd_fcst_extract_02.p04_gsv,
                p05_rob_value = p05_rob_value + rcd_fcst_extract_02.p05_gsv,
                p06_rob_value = p06_rob_value + rcd_fcst_extract_02.p06_gsv,
                p07_rob_value = p07_rob_value + rcd_fcst_extract_02.p07_gsv,
                p08_rob_value = p08_rob_value + rcd_fcst_extract_02.p08_gsv,
                p09_rob_value = p09_rob_value + rcd_fcst_extract_02.p09_gsv,
                p10_rob_value = p10_rob_value + rcd_fcst_extract_02.p10_gsv,
                p11_rob_value = p11_rob_value + rcd_fcst_extract_02.p11_gsv,
                p12_rob_value = p12_rob_value + rcd_fcst_extract_02.p12_gsv,
                p13_rob_value = p13_rob_value + rcd_fcst_extract_02.p13_gsv
          where company_code = rcd_fcst_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_02.cust_code
            and matl_code = rcd_fcst_extract_02.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_rob_value = cpd_rob_value + rcd_fcst_extract_02.cur_ton,
                cyr_ytg_rob_value = cyr_ytg_rob_value + rcd_fcst_extract_02.ytg_ton,
                cyr_yee_rob_value = cyr_yee_rob_value + rcd_fcst_extract_02.ytg_ton,
                p01_rob_value = p01_rob_value + rcd_fcst_extract_02.p01_ton,
                p02_rob_value = p02_rob_value + rcd_fcst_extract_02.p02_ton,
                p03_rob_value = p03_rob_value + rcd_fcst_extract_02.p03_ton,
                p04_rob_value = p04_rob_value + rcd_fcst_extract_02.p04_ton,
                p05_rob_value = p05_rob_value + rcd_fcst_extract_02.p05_ton,
                p06_rob_value = p06_rob_value + rcd_fcst_extract_02.p06_ton,
                p07_rob_value = p07_rob_value + rcd_fcst_extract_02.p07_ton,
                p08_rob_value = p08_rob_value + rcd_fcst_extract_02.p08_ton,
                p09_rob_value = p09_rob_value + rcd_fcst_extract_02.p09_ton,
                p10_rob_value = p10_rob_value + rcd_fcst_extract_02.p10_ton,
                p11_rob_value = p11_rob_value + rcd_fcst_extract_02.p11_ton,
                p12_rob_value = p12_rob_value + rcd_fcst_extract_02.p12_ton,
                p13_rob_value = p13_rob_value + rcd_fcst_extract_02.p13_ton
          where company_code = rcd_fcst_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_02.cust_code
            and matl_code = rcd_fcst_extract_02.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
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
                       par_data_segment,
                       '*ALL',
                       rcd_fcst_extract_03.cust_code,
                       rcd_fcst_extract_03.matl_zrep_code,
                       rcd_fcst_extract_03.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_03.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_br_value = cpd_br_value + rcd_fcst_extract_03.cur_qty,
                cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_qty,
                cyr_yee_br_value = cyr_yee_br_value + rcd_fcst_extract_03.ytg_qty,
                nyr_yee_br_value = nyr_yee_br_value + rcd_fcst_extract_03.nyr_qty,
                p01_br_value = p01_br_value + rcd_fcst_extract_03.p01_qty,
                p02_br_value = p02_br_value + rcd_fcst_extract_03.p02_qty,
                p03_br_value = p03_br_value + rcd_fcst_extract_03.p03_qty,
                p04_br_value = p04_br_value + rcd_fcst_extract_03.p04_qty,
                p05_br_value = p05_br_value + rcd_fcst_extract_03.p05_qty,
                p06_br_value = p06_br_value + rcd_fcst_extract_03.p06_qty,
                p07_br_value = p07_br_value + rcd_fcst_extract_03.p07_qty,
                p08_br_value = p08_br_value + rcd_fcst_extract_03.p08_qty,
                p09_br_value = p09_br_value + rcd_fcst_extract_03.p09_qty,
                p10_br_value = p10_br_value + rcd_fcst_extract_03.p10_qty,
                p11_br_value = p11_br_value + rcd_fcst_extract_03.p11_qty,
                p12_br_value = p12_br_value + rcd_fcst_extract_03.p12_qty,
                p13_br_value = p13_br_value + rcd_fcst_extract_03.p13_qty,
                p14_br_value = p14_br_value + rcd_fcst_extract_03.p14_qty,
                p15_br_value = p15_br_value + rcd_fcst_extract_03.p15_qty,
                p16_br_value = p16_br_value + rcd_fcst_extract_03.p16_qty,
                p17_br_value = p17_br_value + rcd_fcst_extract_03.p17_qty,
                p18_br_value = p18_br_value + rcd_fcst_extract_03.p18_qty,
                p19_br_value = p19_br_value + rcd_fcst_extract_03.p19_qty,
                p20_br_value = p20_br_value + rcd_fcst_extract_03.p20_qty,
                p21_br_value = p21_br_value + rcd_fcst_extract_03.p21_qty,
                p22_br_value = p22_br_value + rcd_fcst_extract_03.p22_qty,
                p23_br_value = p23_br_value + rcd_fcst_extract_03.p23_qty,
                p24_br_value = p24_br_value + rcd_fcst_extract_03.p24_qty,
                p25_br_value = p25_br_value + rcd_fcst_extract_03.p25_qty,
                p26_br_value = p26_br_value + rcd_fcst_extract_03.p26_qty
          where company_code = rcd_fcst_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_03.cust_code
            and matl_code = rcd_fcst_extract_03.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_br_value = cpd_br_value + rcd_fcst_extract_03.cur_gsv,
                cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_gsv,
                cyr_yee_br_value = cyr_yee_br_value + rcd_fcst_extract_03.ytg_gsv,
                nyr_yee_br_value = nyr_yee_br_value + rcd_fcst_extract_03.nyr_gsv,
                p01_br_value = p01_br_value + rcd_fcst_extract_03.p01_gsv,
                p02_br_value = p02_br_value + rcd_fcst_extract_03.p02_gsv,
                p03_br_value = p03_br_value + rcd_fcst_extract_03.p03_gsv,
                p04_br_value = p04_br_value + rcd_fcst_extract_03.p04_gsv,
                p05_br_value = p05_br_value + rcd_fcst_extract_03.p05_gsv,
                p06_br_value = p06_br_value + rcd_fcst_extract_03.p06_gsv,
                p07_br_value = p07_br_value + rcd_fcst_extract_03.p07_gsv,
                p08_br_value = p08_br_value + rcd_fcst_extract_03.p08_gsv,
                p09_br_value = p09_br_value + rcd_fcst_extract_03.p09_gsv,
                p10_br_value = p10_br_value + rcd_fcst_extract_03.p10_gsv,
                p11_br_value = p11_br_value + rcd_fcst_extract_03.p11_gsv,
                p12_br_value = p12_br_value + rcd_fcst_extract_03.p12_gsv,
                p13_br_value = p13_br_value + rcd_fcst_extract_03.p13_gsv,
                p14_br_value = p14_br_value + rcd_fcst_extract_03.p14_gsv,
                p15_br_value = p15_br_value + rcd_fcst_extract_03.p15_gsv,
                p16_br_value = p16_br_value + rcd_fcst_extract_03.p16_gsv,
                p17_br_value = p17_br_value + rcd_fcst_extract_03.p17_gsv,
                p18_br_value = p18_br_value + rcd_fcst_extract_03.p18_gsv,
                p19_br_value = p19_br_value + rcd_fcst_extract_03.p19_gsv,
                p20_br_value = p20_br_value + rcd_fcst_extract_03.p20_gsv,
                p21_br_value = p21_br_value + rcd_fcst_extract_03.p21_gsv,
                p22_br_value = p22_br_value + rcd_fcst_extract_03.p22_gsv,
                p23_br_value = p23_br_value + rcd_fcst_extract_03.p23_gsv,
                p24_br_value = p24_br_value + rcd_fcst_extract_03.p24_gsv,
                p25_br_value = p25_br_value + rcd_fcst_extract_03.p25_gsv,
                p26_br_value = p26_br_value + rcd_fcst_extract_03.p26_gsv
          where company_code = rcd_fcst_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_03.cust_code
            and matl_code = rcd_fcst_extract_03.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_br_value = cpd_br_value + rcd_fcst_extract_03.cur_ton,
                cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_ton,
                cyr_yee_br_value = cyr_yee_br_value + rcd_fcst_extract_03.ytg_ton,
                nyr_yee_br_value = nyr_yee_br_value + rcd_fcst_extract_03.nyr_ton,
                p01_br_value = p01_br_value + rcd_fcst_extract_03.p01_ton,
                p02_br_value = p02_br_value + rcd_fcst_extract_03.p02_ton,
                p03_br_value = p03_br_value + rcd_fcst_extract_03.p03_ton,
                p04_br_value = p04_br_value + rcd_fcst_extract_03.p04_ton,
                p05_br_value = p05_br_value + rcd_fcst_extract_03.p05_ton,
                p06_br_value = p06_br_value + rcd_fcst_extract_03.p06_ton,
                p07_br_value = p07_br_value + rcd_fcst_extract_03.p07_ton,
                p08_br_value = p08_br_value + rcd_fcst_extract_03.p08_ton,
                p09_br_value = p09_br_value + rcd_fcst_extract_03.p09_ton,
                p10_br_value = p10_br_value + rcd_fcst_extract_03.p10_ton,
                p11_br_value = p11_br_value + rcd_fcst_extract_03.p11_ton,
                p12_br_value = p12_br_value + rcd_fcst_extract_03.p12_ton,
                p13_br_value = p13_br_value + rcd_fcst_extract_03.p13_ton,
                p14_br_value = p14_br_value + rcd_fcst_extract_03.p14_ton,
                p15_br_value = p15_br_value + rcd_fcst_extract_03.p15_ton,
                p16_br_value = p16_br_value + rcd_fcst_extract_03.p16_ton,
                p17_br_value = p17_br_value + rcd_fcst_extract_03.p17_ton,
                p18_br_value = p18_br_value + rcd_fcst_extract_03.p18_ton,
                p19_br_value = p19_br_value + rcd_fcst_extract_03.p19_ton,
                p20_br_value = p20_br_value + rcd_fcst_extract_03.p20_ton,
                p21_br_value = p21_br_value + rcd_fcst_extract_03.p21_ton,
                p22_br_value = p22_br_value + rcd_fcst_extract_03.p22_ton,
                p23_br_value = p23_br_value + rcd_fcst_extract_03.p23_ton,
                p24_br_value = p24_br_value + rcd_fcst_extract_03.p24_ton,
                p25_br_value = p25_br_value + rcd_fcst_extract_03.p25_ton,
                p26_br_value = p26_br_value + rcd_fcst_extract_03.p26_ton
          where company_code = rcd_fcst_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_03.cust_code
            and matl_code = rcd_fcst_extract_03.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
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
                       par_data_segment,
                       '*ALL',
                       rcd_fcst_extract_04.cust_code,
                       rcd_fcst_extract_04.matl_zrep_code,
                       rcd_fcst_extract_04.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_04.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set ptg_fcst_value = ptg_fcst_value + rcd_fcst_extract_04.ptg_qty,
                cpd_fcst_value = cpd_fcst_value + rcd_fcst_extract_04.ptg_qty,
                cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_qty,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_fcst_extract_04.ytg_qty,
                nyr_yee_fcst_value = nyr_yee_fcst_value + rcd_fcst_extract_04.nyr_qty,
                p01_fcst_value = p01_fcst_value + rcd_fcst_extract_04.p01_qty,
                p02_fcst_value = p02_fcst_value + rcd_fcst_extract_04.p02_qty,
                p03_fcst_value = p03_fcst_value + rcd_fcst_extract_04.p03_qty,
                p04_fcst_value = p04_fcst_value + rcd_fcst_extract_04.p04_qty,
                p05_fcst_value = p05_fcst_value + rcd_fcst_extract_04.p05_qty,
                p06_fcst_value = p06_fcst_value + rcd_fcst_extract_04.p06_qty,
                p07_fcst_value = p07_fcst_value + rcd_fcst_extract_04.p07_qty,
                p08_fcst_value = p08_fcst_value + rcd_fcst_extract_04.p08_qty,
                p09_fcst_value = p09_fcst_value + rcd_fcst_extract_04.p09_qty,
                p10_fcst_value = p10_fcst_value + rcd_fcst_extract_04.p10_qty,
                p11_fcst_value = p11_fcst_value + rcd_fcst_extract_04.p11_qty,
                p12_fcst_value = p12_fcst_value + rcd_fcst_extract_04.p12_qty,
                p13_fcst_value = p13_fcst_value + rcd_fcst_extract_04.p13_qty,
                p14_fcst_value = p14_fcst_value + rcd_fcst_extract_04.p14_qty,
                p15_fcst_value = p15_fcst_value + rcd_fcst_extract_04.p15_qty,
                p16_fcst_value = p16_fcst_value + rcd_fcst_extract_04.p16_qty,
                p17_fcst_value = p17_fcst_value + rcd_fcst_extract_04.p17_qty,
                p18_fcst_value = p18_fcst_value + rcd_fcst_extract_04.p18_qty,
                p19_fcst_value = p19_fcst_value + rcd_fcst_extract_04.p19_qty,
                p20_fcst_value = p20_fcst_value + rcd_fcst_extract_04.p20_qty,
                p21_fcst_value = p21_fcst_value + rcd_fcst_extract_04.p21_qty,
                p22_fcst_value = p22_fcst_value + rcd_fcst_extract_04.p22_qty,
                p23_fcst_value = p23_fcst_value + rcd_fcst_extract_04.p23_qty,
                p24_fcst_value = p24_fcst_value + rcd_fcst_extract_04.p24_qty,
                p25_fcst_value = p25_fcst_value + rcd_fcst_extract_04.p25_qty,
                p26_fcst_value = p26_fcst_value + rcd_fcst_extract_04.p26_qty
          where company_code = rcd_fcst_extract_04.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_04.cust_code
            and matl_code = rcd_fcst_extract_04.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set ptg_fcst_value = ptg_fcst_value + rcd_fcst_extract_04.ptg_gsv,
                cpd_fcst_value = cpd_fcst_value + rcd_fcst_extract_04.ptg_gsv,
                cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_gsv,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_fcst_extract_04.ytg_gsv,
                nyr_yee_fcst_value = nyr_yee_fcst_value + rcd_fcst_extract_04.nyr_gsv,
                p01_fcst_value = p01_fcst_value + rcd_fcst_extract_04.p01_gsv,
                p02_fcst_value = p02_fcst_value + rcd_fcst_extract_04.p02_gsv,
                p03_fcst_value = p03_fcst_value + rcd_fcst_extract_04.p03_gsv,
                p04_fcst_value = p04_fcst_value + rcd_fcst_extract_04.p04_gsv,
                p05_fcst_value = p05_fcst_value + rcd_fcst_extract_04.p05_gsv,
                p06_fcst_value = p06_fcst_value + rcd_fcst_extract_04.p06_gsv,
                p07_fcst_value = p07_fcst_value + rcd_fcst_extract_04.p07_gsv,
                p08_fcst_value = p08_fcst_value + rcd_fcst_extract_04.p08_gsv,
                p09_fcst_value = p09_fcst_value + rcd_fcst_extract_04.p09_gsv,
                p10_fcst_value = p10_fcst_value + rcd_fcst_extract_04.p10_gsv,
                p11_fcst_value = p11_fcst_value + rcd_fcst_extract_04.p11_gsv,
                p12_fcst_value = p12_fcst_value + rcd_fcst_extract_04.p12_gsv,
                p13_fcst_value = p13_fcst_value + rcd_fcst_extract_04.p13_gsv,
                p14_fcst_value = p14_fcst_value + rcd_fcst_extract_04.p14_gsv,
                p15_fcst_value = p15_fcst_value + rcd_fcst_extract_04.p15_gsv,
                p16_fcst_value = p16_fcst_value + rcd_fcst_extract_04.p16_gsv,
                p17_fcst_value = p17_fcst_value + rcd_fcst_extract_04.p17_gsv,
                p18_fcst_value = p18_fcst_value + rcd_fcst_extract_04.p18_gsv,
                p19_fcst_value = p19_fcst_value + rcd_fcst_extract_04.p19_gsv,
                p20_fcst_value = p20_fcst_value + rcd_fcst_extract_04.p20_gsv,
                p21_fcst_value = p21_fcst_value + rcd_fcst_extract_04.p21_gsv,
                p22_fcst_value = p22_fcst_value + rcd_fcst_extract_04.p22_gsv,
                p23_fcst_value = p23_fcst_value + rcd_fcst_extract_04.p23_gsv,
                p24_fcst_value = p24_fcst_value + rcd_fcst_extract_04.p24_gsv,
                p25_fcst_value = p25_fcst_value + rcd_fcst_extract_04.p25_gsv,
                p26_fcst_value = p26_fcst_value + rcd_fcst_extract_04.p26_gsv
          where company_code = rcd_fcst_extract_04.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_04.cust_code
            and matl_code = rcd_fcst_extract_04.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set ptg_fcst_value = ptg_fcst_value + rcd_fcst_extract_04.ptg_ton,
                cpd_fcst_value = cpd_fcst_value + rcd_fcst_extract_04.ptg_ton,
                cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_ton,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_fcst_extract_04.ytg_ton,
                nyr_yee_fcst_value = nyr_yee_fcst_value + rcd_fcst_extract_04.nyr_ton,
                p01_fcst_value = p01_fcst_value + rcd_fcst_extract_04.p01_ton,
                p02_fcst_value = p02_fcst_value + rcd_fcst_extract_04.p02_ton,
                p03_fcst_value = p03_fcst_value + rcd_fcst_extract_04.p03_ton,
                p04_fcst_value = p04_fcst_value + rcd_fcst_extract_04.p04_ton,
                p05_fcst_value = p05_fcst_value + rcd_fcst_extract_04.p05_ton,
                p06_fcst_value = p06_fcst_value + rcd_fcst_extract_04.p06_ton,
                p07_fcst_value = p07_fcst_value + rcd_fcst_extract_04.p07_ton,
                p08_fcst_value = p08_fcst_value + rcd_fcst_extract_04.p08_ton,
                p09_fcst_value = p09_fcst_value + rcd_fcst_extract_04.p09_ton,
                p10_fcst_value = p10_fcst_value + rcd_fcst_extract_04.p10_ton,
                p11_fcst_value = p11_fcst_value + rcd_fcst_extract_04.p11_ton,
                p12_fcst_value = p12_fcst_value + rcd_fcst_extract_04.p12_ton,
                p13_fcst_value = p13_fcst_value + rcd_fcst_extract_04.p13_ton,
                p14_fcst_value = p14_fcst_value + rcd_fcst_extract_04.p14_ton,
                p15_fcst_value = p15_fcst_value + rcd_fcst_extract_04.p15_ton,
                p16_fcst_value = p16_fcst_value + rcd_fcst_extract_04.p16_ton,
                p17_fcst_value = p17_fcst_value + rcd_fcst_extract_04.p17_ton,
                p18_fcst_value = p18_fcst_value + rcd_fcst_extract_04.p18_ton,
                p19_fcst_value = p19_fcst_value + rcd_fcst_extract_04.p19_ton,
                p20_fcst_value = p20_fcst_value + rcd_fcst_extract_04.p20_ton,
                p21_fcst_value = p21_fcst_value + rcd_fcst_extract_04.p21_ton,
                p22_fcst_value = p22_fcst_value + rcd_fcst_extract_04.p22_ton,
                p23_fcst_value = p23_fcst_value + rcd_fcst_extract_04.p23_ton,
                p24_fcst_value = p24_fcst_value + rcd_fcst_extract_04.p24_ton,
                p25_fcst_value = p25_fcst_value + rcd_fcst_extract_04.p25_ton,
                p26_fcst_value = p26_fcst_value + rcd_fcst_extract_04.p26_ton
          where company_code = rcd_fcst_extract_04.company_code
            and data_segment = par_data_segment
            and matl_group = '*ALL'
            and ship_to_cust_code = rcd_fcst_extract_04.cust_code
            and matl_code = rcd_fcst_extract_04.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*TON';

      end loop;
      close csr_fcst_extract_04;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_forecast;

   /********************************************************/
   /* This procedure performs the NZMKT sales data routine */
   /********************************************************/
   procedure extract_nzmkt_sale(par_company_code in varchar2, par_data_segment in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_lyrm2_str_yyyypp number(6,0);
      var_lyrm2_end_yyyypp number(6,0);
      var_lyrm1_str_yyyypp number(6,0);
      var_lyrm1_end_yyyypp number(6,0);
      var_lyr_str_yyyypp number(6,0);
      var_lyr_end_yyyypp number(6,0);
      var_ytp_str_yyyypp number(6,0);
      var_ytp_end_yyyypp number(6,0);
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
      var_lyr_p01 number(6,0);
      var_lyr_p02 number(6,0);
      var_lyr_p03 number(6,0);
      var_lyr_p04 number(6,0);
      var_lyr_p05 number(6,0);
      var_lyr_p06 number(6,0);
      var_lyr_p07 number(6,0);
      var_lyr_p08 number(6,0);
      var_lyr_p09 number(6,0);
      var_lyr_p10 number(6,0);
      var_lyr_p11 number(6,0);
      var_lyr_p12 number(6,0);
      var_lyr_p13 number(6,0);
      var_str_yyyypp number(6,0);
      var_cpd_yyyypp number(6,0);
      var_lpd_yyyypp number(6,0);
      var_ltp_str_yyyypp number(6,0);
      var_ltp_end_yyyypp number(6,0);
      var_ptw_str_yyyyppw number(7,0);
      var_ptw_end_yyyyppw number(7,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales_extract_01 is
         select t01.company_code,
                t01.nzmkt_matl_group,
                nvl(t01.cust_code,'*NULL') as cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lpd_yyyypp then t01.ord_qty_base_uom end),0) as lst_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lpd_yyyypp then t01.ord_gsv_aud end),0) as lst_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lpd_yyyypp then t01.ord_qty_net_tonnes end),0) as lst_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_cpd_yyyypp then t01.ord_qty_base_uom end),0) as cur_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_cpd_yyyypp then t01.ord_gsv_aud end),0) as cur_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_cpd_yyyypp then t01.ord_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp > var_cpd_yyyypp then t01.ord_qty_base_uom end),0) as fut_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp > var_cpd_yyyypp then t01.ord_gsv_aud end),0) as fut_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp > var_cpd_yyyypp then t01.ord_qty_net_tonnes end),0) as fut_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyrm2_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyrm2_end_yyyypp then t01.ord_qty_base_uom end),0) as lyrm2_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyrm2_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyrm2_end_yyyypp then t01.ord_gsv_aud end),0) as lyrm2_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyrm2_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyrm2_end_yyyypp then t01.ord_qty_net_tonnes end),0) as lyrm2_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyrm1_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyrm1_end_yyyypp then t01.ord_qty_base_uom end),0) as lyrm1_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyrm1_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyrm1_end_yyyypp then t01.ord_gsv_aud end),0) as lyrm1_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyrm1_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyrm1_end_yyyypp then t01.ord_qty_net_tonnes end),0) as lyrm1_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyr_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyr_end_yyyypp then t01.ord_qty_base_uom end),0) as lyr_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyr_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyr_end_yyyypp then t01.ord_gsv_aud end),0) as lyr_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_lyr_str_yyyypp and t01.purch_order_eff_yyyypp <= var_lyr_end_yyyypp then t01.ord_qty_net_tonnes end),0) as lyr_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_ltp_str_yyyypp and t01.purch_order_eff_yyyypp <= var_ltp_end_yyyypp then t01.ord_qty_base_uom end),0) as ltp_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_ltp_str_yyyypp and t01.purch_order_eff_yyyypp <= var_ltp_end_yyyypp then t01.ord_gsv_aud end),0) as ltp_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_ltp_str_yyyypp and t01.purch_order_eff_yyyypp <= var_ltp_end_yyyypp then t01.ord_qty_net_tonnes end),0) as ltp_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_ytp_str_yyyypp and t01.purch_order_eff_yyyypp <= var_ytp_end_yyyypp then t01.ord_qty_base_uom end),0) as ytp_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_ytp_str_yyyypp and t01.purch_order_eff_yyyypp <= var_ytp_end_yyyypp then t01.ord_gsv_aud end),0) as ytp_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_ytp_str_yyyypp and t01.purch_order_eff_yyyypp <= var_ytp_end_yyyypp then t01.ord_qty_net_tonnes end),0) as ytp_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_mat_str_yyyypp and t01.purch_order_eff_yyyypp <= var_mat_end_yyyypp then t01.ord_qty_base_uom end),0) as mat_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_mat_str_yyyypp and t01.purch_order_eff_yyyypp <= var_mat_end_yyyypp then t01.ord_gsv_aud end),0) as mat_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp >= var_mat_str_yyyypp and t01.purch_order_eff_yyyypp <= var_mat_end_yyyypp then t01.ord_qty_net_tonnes end),0) as mat_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p01 then t01.ord_qty_base_uom end),0) as l01_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p02 then t01.ord_qty_base_uom end),0) as l02_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p03 then t01.ord_qty_base_uom end),0) as l03_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p04 then t01.ord_qty_base_uom end),0) as l04_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p05 then t01.ord_qty_base_uom end),0) as l05_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p06 then t01.ord_qty_base_uom end),0) as l06_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p07 then t01.ord_qty_base_uom end),0) as l07_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p08 then t01.ord_qty_base_uom end),0) as l08_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p09 then t01.ord_qty_base_uom end),0) as l09_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p10 then t01.ord_qty_base_uom end),0) as l10_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p11 then t01.ord_qty_base_uom end),0) as l11_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p12 then t01.ord_qty_base_uom end),0) as l12_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p13 then t01.ord_qty_base_uom end),0) as l13_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p01 then t01.ord_gsv_aud end),0) as l01_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p02 then t01.ord_gsv_aud end),0) as l02_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p03 then t01.ord_gsv_aud end),0) as l03_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p04 then t01.ord_gsv_aud end),0) as l04_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p05 then t01.ord_gsv_aud end),0) as l05_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p06 then t01.ord_gsv_aud end),0) as l06_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p07 then t01.ord_gsv_aud end),0) as l07_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p08 then t01.ord_gsv_aud end),0) as l08_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p09 then t01.ord_gsv_aud end),0) as l09_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p10 then t01.ord_gsv_aud end),0) as l10_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p11 then t01.ord_gsv_aud end),0) as l11_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p12 then t01.ord_gsv_aud end),0) as l12_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p13 then t01.ord_gsv_aud end),0) as l13_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p01 then t01.ord_qty_net_tonnes end),0) as l01_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p02 then t01.ord_qty_net_tonnes end),0) as l02_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p03 then t01.ord_qty_net_tonnes end),0) as l03_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p04 then t01.ord_qty_net_tonnes end),0) as l04_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p05 then t01.ord_qty_net_tonnes end),0) as l05_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p06 then t01.ord_qty_net_tonnes end),0) as l06_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p07 then t01.ord_qty_net_tonnes end),0) as l07_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p08 then t01.ord_qty_net_tonnes end),0) as l08_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p09 then t01.ord_qty_net_tonnes end),0) as l09_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p10 then t01.ord_qty_net_tonnes end),0) as l10_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p11 then t01.ord_qty_net_tonnes end),0) as l11_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p12 then t01.ord_qty_net_tonnes end),0) as l12_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp = var_lyr_p13 then t01.ord_qty_net_tonnes end),0) as l13_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p01 then t01.ord_qty_base_uom end),0) as p01_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p02 then t01.ord_qty_base_uom end),0) as p02_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p03 then t01.ord_qty_base_uom end),0) as p03_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p04 then t01.ord_qty_base_uom end),0) as p04_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p05 then t01.ord_qty_base_uom end),0) as p05_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p06 then t01.ord_qty_base_uom end),0) as p06_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p07 then t01.ord_qty_base_uom end),0) as p07_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p08 then t01.ord_qty_base_uom end),0) as p08_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p09 then t01.ord_qty_base_uom end),0) as p09_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p10 then t01.ord_qty_base_uom end),0) as p10_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p11 then t01.ord_qty_base_uom end),0) as p11_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p12 then t01.ord_qty_base_uom end),0) as p12_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p13 then t01.ord_qty_base_uom end),0) as p13_qty,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p01 then t01.ord_gsv_aud end),0) as p01_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p02 then t01.ord_gsv_aud end),0) as p02_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p03 then t01.ord_gsv_aud end),0) as p03_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p04 then t01.ord_gsv_aud end),0) as p04_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p05 then t01.ord_gsv_aud end),0) as p05_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p06 then t01.ord_gsv_aud end),0) as p06_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p07 then t01.ord_gsv_aud end),0) as p07_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p08 then t01.ord_gsv_aud end),0) as p08_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p09 then t01.ord_gsv_aud end),0) as p09_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p10 then t01.ord_gsv_aud end),0) as p10_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p11 then t01.ord_gsv_aud end),0) as p11_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p12 then t01.ord_gsv_aud end),0) as p12_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p13 then t01.ord_gsv_aud end),0) as p13_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p01 then t01.ord_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p02 then t01.ord_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p03 then t01.ord_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p04 then t01.ord_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p05 then t01.ord_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p06 then t01.ord_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p07 then t01.ord_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p08 then t01.ord_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p09 then t01.ord_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p10 then t01.ord_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p11 then t01.ord_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p12 then t01.ord_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.purch_order_eff_yyyypp < var_cpd_yyyypp and t01.purch_order_eff_yyyypp = var_cyr_p13 then t01.ord_qty_net_tonnes end),0) as p13_ton
           from dw_nzmkt_base t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.nzmkt_cust_code = t02.cust_code(+)
            and t01.distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.sales_org_code = t02.sales_org_code(+)
            and t01.nzmkt_cust_code = t03.cust_code(+)
            and t01.distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.division_code = t03.division_code(+)
            and t01.sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.purch_order_eff_yyyypp >= var_str_yyyypp
          group by t01.company_code,
                   t01.nzmkt_matl_group,
                   t01.cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_sales_extract_01 csr_sales_extract_01%rowtype;

      cursor csr_sales_extract_02 is
         select t01.company_code,
                t01.nzmkt_matl_group,
                nvl(t01.cust_code,'*NULL') as cust_code,
                nvl(t04.rep_item,t01.matl_code) as matl_code,
                nvl(t03.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t02.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                t01.mfanz_icb_flag,
                nvl(sum(case when t01.purch_order_eff_date = trunc(var_current_date) then t01.ord_qty_base_uom end),0) as cur_qty,
                nvl(sum(case when t01.purch_order_eff_date = trunc(var_current_date) then t01.ord_gsv_aud end),0) as cur_gsv,
                nvl(sum(case when t01.purch_order_eff_date = trunc(var_current_date) then t01.ord_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw then t01.ord_qty_base_uom end),0) as ptw_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw then t01.ord_gsv_aud end),0) as ptw_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw then t01.ord_qty_net_tonnes end),0) as ptw_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p01 then t01.ord_qty_base_uom end),0) as w01_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p02 then t01.ord_qty_base_uom end),0) as w02_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p03 then t01.ord_qty_base_uom end),0) as w03_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p04 then t01.ord_qty_base_uom end),0) as w04_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p05 then t01.ord_qty_base_uom end),0) as w05_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p06 then t01.ord_qty_base_uom end),0) as w06_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p07 then t01.ord_qty_base_uom end),0) as w07_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p08 then t01.ord_qty_base_uom end),0) as w08_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p09 then t01.ord_qty_base_uom end),0) as w09_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p10 then t01.ord_qty_base_uom end),0) as w10_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p11 then t01.ord_qty_base_uom end),0) as w11_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p12 then t01.ord_qty_base_uom end),0) as w12_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p13 then t01.ord_qty_base_uom end),0) as w13_qty,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p01 then t01.ord_gsv_aud end),0) as w01_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p02 then t01.ord_gsv_aud end),0) as w02_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p03 then t01.ord_gsv_aud end),0) as w03_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p04 then t01.ord_gsv_aud end),0) as w04_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p05 then t01.ord_gsv_aud end),0) as w05_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p06 then t01.ord_gsv_aud end),0) as w06_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p07 then t01.ord_gsv_aud end),0) as w07_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p08 then t01.ord_gsv_aud end),0) as w08_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p09 then t01.ord_gsv_aud end),0) as w09_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p10 then t01.ord_gsv_aud end),0) as w10_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p11 then t01.ord_gsv_aud end),0) as w11_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p12 then t01.ord_gsv_aud end),0) as w12_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p13 then t01.ord_gsv_aud end),0) as w13_gsv,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p01 then t01.ord_qty_net_tonnes end),0) as w01_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p02 then t01.ord_qty_net_tonnes end),0) as w02_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p03 then t01.ord_qty_net_tonnes end),0) as w03_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p04 then t01.ord_qty_net_tonnes end),0) as w04_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p05 then t01.ord_qty_net_tonnes end),0) as w05_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p06 then t01.ord_qty_net_tonnes end),0) as w06_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p07 then t01.ord_qty_net_tonnes end),0) as w07_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p08 then t01.ord_qty_net_tonnes end),0) as w08_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p09 then t01.ord_qty_net_tonnes end),0) as w09_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p10 then t01.ord_qty_net_tonnes end),0) as w10_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p11 then t01.ord_qty_net_tonnes end),0) as w11_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p12 then t01.ord_qty_net_tonnes end),0) as w12_ton,
                nvl(sum(case when t01.purch_order_eff_yyyyppw <= var_ptw_end_yyyyppw and t01.purch_order_eff_yyyypp = var_cyr_p13 then t01.ord_qty_net_tonnes end),0) as w13_ton
           from dw_nzmkt_base t01,
                demand_plng_grp_sales_area_dim t02,
                cust_sales_area_dim t03,
                matl_dim t04
          where t01.nzmkt_cust_code = t02.cust_code(+)
            and t01.distbn_chnl_code = t02.distbn_chnl_code(+)
            and t01.demand_plng_grp_division_code = t02.division_code(+)
            and t01.sales_org_code = t02.sales_org_code(+)
            and t01.nzmkt_cust_code = t03.cust_code(+)
            and t01.distbn_chnl_code = t03.distbn_chnl_code(+)
            and t01.division_code = t03.division_code(+)
            and t01.sales_org_code = t03.sales_org_code(+)
            and t01.matl_code = t04.matl_code(+)
            and t01.company_code = par_company_code
            and t01.purch_order_eff_yyyypp = var_cpd_yyyypp
          group by t01.company_code,
                   t01.nzmkt_matl_group,
                   t01.cust_code,
                   nvl(t04.rep_item,t01.matl_code),
                   t03.acct_assgnmnt_grp_code,
                   t02.demand_plng_grp_code,
                   t01.mfanz_icb_flag;
      rcd_sales_extract_02 csr_sales_extract_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate the period and week filters
      /*-*/
      var_lyrm2_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 3) * 100) + 1;
      var_lyrm2_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 3) * 100) + 13;
      var_lyrm1_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 2) * 100) + 1;
      var_lyrm1_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 2) * 100) + 13;
      var_lyr_str_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 1) * 100) + 1;
      var_lyr_end_yyyypp := ((to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) - 1) * 100) + 13;
      var_ytp_str_yyyypp := (to_number(substr(to_char(var_current_yyyypp,'fm000000'),1,4)) * 100) + 1;
      var_ytp_end_yyyypp := var_current_yyyypp - 1;
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
      var_lyr_p01 := var_cyr_p01 - 100;
      var_lyr_p02 := var_cyr_p02 - 100;
      var_lyr_p03 := var_cyr_p03 - 100;
      var_lyr_p04 := var_cyr_p04 - 100;
      var_lyr_p05 := var_cyr_p05 - 100;
      var_lyr_p06 := var_cyr_p06 - 100;
      var_lyr_p07 := var_cyr_p07 - 100;
      var_lyr_p08 := var_cyr_p08 - 100;
      var_lyr_p09 := var_cyr_p09 - 100;
      var_lyr_p10 := var_cyr_p10 - 100;
      var_lyr_p11 := var_cyr_p11 - 100;
      var_lyr_p12 := var_cyr_p12 - 100;
      var_lyr_p13 := var_cyr_p13 - 100;
      var_str_yyyypp := var_lyrm2_str_yyyypp;
      var_cpd_yyyypp := var_current_yyyypp;
      var_lpd_yyyypp := var_current_yyyypp - 100;
      var_ltp_str_yyyypp := var_ytp_str_yyyypp - 100;
      var_ltp_end_yyyypp := var_ytp_end_yyyypp - 100;
      var_ptw_str_yyyyppw := (var_current_yyyypp * 10) + 1;
      var_ptw_end_yyyyppw := var_current_yyyyppw - 1;

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
         create_detail(rcd_sales_extract_01.company_code,
                       par_data_segment,
                       rcd_sales_extract_01.nzmkt_matl_group,
                       rcd_sales_extract_01.cust_code,
                       rcd_sales_extract_01.matl_code,
                       rcd_sales_extract_01.acct_assgnmnt_grp_code,
                       rcd_sales_extract_01.demand_plng_grp_code,
                       rcd_sales_extract_01.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set lyr_cpd_inv_value = lyr_cpd_inv_value + rcd_sales_extract_01.lst_qty,
                ptd_inv_value = ptd_inv_value + rcd_sales_extract_01.cur_qty,
                cpd_inv_value = cpd_inv_value + rcd_sales_extract_01.cur_qty,
                fpd_inv_value = fpd_inv_value + rcd_sales_extract_01.fut_qty,
                lyr_yee_inv_value = lyr_yee_inv_value + rcd_sales_extract_01.lyr_qty,
                lyrm1_yee_inv_value = lyrm1_yee_inv_value + rcd_sales_extract_01.lyrm1_qty,
                lyrm2_yee_inv_value = lyrm2_yee_inv_value + rcd_sales_extract_01.lyrm2_qty,
                lyr_ytp_inv_value = lyr_ytp_inv_value + rcd_sales_extract_01.ltp_qty,
                cyr_ytp_inv_value = cyr_ytp_inv_value + rcd_sales_extract_01.ytp_qty,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_qty,
                cyr_yee_br_value = cyr_yee_br_value + rcd_sales_extract_01.ytp_qty,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_01.ytp_qty,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_01.p01_qty,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_01.p02_qty,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_01.p03_qty,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_01.p04_qty,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_01.p05_qty,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_01.p06_qty,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_01.p07_qty,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_01.p08_qty,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_01.p09_qty,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_01.p10_qty,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_01.p11_qty,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_01.p12_qty,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_01.p13_qty,
                p01_br_value = p01_br_value + rcd_sales_extract_01.p01_qty,
                p02_br_value = p02_br_value + rcd_sales_extract_01.p02_qty,
                p03_br_value = p03_br_value + rcd_sales_extract_01.p03_qty,
                p04_br_value = p04_br_value + rcd_sales_extract_01.p04_qty,
                p05_br_value = p05_br_value + rcd_sales_extract_01.p05_qty,
                p06_br_value = p06_br_value + rcd_sales_extract_01.p06_qty,
                p07_br_value = p07_br_value + rcd_sales_extract_01.p07_qty,
                p08_br_value = p08_br_value + rcd_sales_extract_01.p08_qty,
                p09_br_value = p09_br_value + rcd_sales_extract_01.p09_qty,
                p10_br_value = p10_br_value + rcd_sales_extract_01.p10_qty,
                p11_br_value = p11_br_value + rcd_sales_extract_01.p11_qty,
                p12_br_value = p12_br_value + rcd_sales_extract_01.p12_qty,
                p13_br_value = p13_br_value + rcd_sales_extract_01.p13_qty,
                p01_rob_value = p01_rob_value + rcd_sales_extract_01.p01_qty,
                p02_rob_value = p02_rob_value + rcd_sales_extract_01.p02_qty,
                p03_rob_value = p03_rob_value + rcd_sales_extract_01.p03_qty,
                p04_rob_value = p04_rob_value + rcd_sales_extract_01.p04_qty,
                p05_rob_value = p05_rob_value + rcd_sales_extract_01.p05_qty,
                p06_rob_value = p06_rob_value + rcd_sales_extract_01.p06_qty,
                p07_rob_value = p07_rob_value + rcd_sales_extract_01.p07_qty,
                p08_rob_value = p08_rob_value + rcd_sales_extract_01.p08_qty,
                p09_rob_value = p09_rob_value + rcd_sales_extract_01.p09_qty,
                p10_rob_value = p10_rob_value + rcd_sales_extract_01.p10_qty,
                p11_rob_value = p11_rob_value + rcd_sales_extract_01.p11_qty,
                p12_rob_value = p12_rob_value + rcd_sales_extract_01.p12_qty,
                p13_rob_value = p13_rob_value + rcd_sales_extract_01.p13_qty,
                p01_lyr_value = p01_lyr_value + rcd_sales_extract_01.l01_qty,
                p02_lyr_value = p02_lyr_value + rcd_sales_extract_01.l02_qty,
                p03_lyr_value = p03_lyr_value + rcd_sales_extract_01.l03_qty,
                p04_lyr_value = p04_lyr_value + rcd_sales_extract_01.l04_qty,
                p05_lyr_value = p05_lyr_value + rcd_sales_extract_01.l05_qty,
                p06_lyr_value = p06_lyr_value + rcd_sales_extract_01.l06_qty,
                p07_lyr_value = p07_lyr_value + rcd_sales_extract_01.l07_qty,
                p08_lyr_value = p08_lyr_value + rcd_sales_extract_01.l08_qty,
                p09_lyr_value = p09_lyr_value + rcd_sales_extract_01.l09_qty,
                p10_lyr_value = p10_lyr_value + rcd_sales_extract_01.l10_qty,
                p11_lyr_value = p11_lyr_value + rcd_sales_extract_01.l11_qty,
                p12_lyr_value = p12_lyr_value + rcd_sales_extract_01.l12_qty,
                p13_lyr_value = p13_lyr_value + rcd_sales_extract_01.l13_qty
          where company_code = rcd_sales_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_sales_extract_01.nzmkt_matl_group
            and ship_to_cust_code = rcd_sales_extract_01.cust_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_01.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set lyr_cpd_inv_value = lyr_cpd_inv_value + rcd_sales_extract_01.lst_gsv,
                ptd_inv_value = ptd_inv_value + rcd_sales_extract_01.cur_gsv,
                cpd_inv_value = cpd_inv_value + rcd_sales_extract_01.cur_gsv,
                fpd_inv_value = fpd_inv_value + rcd_sales_extract_01.fut_gsv,
                lyr_yee_inv_value = lyr_yee_inv_value + rcd_sales_extract_01.lyr_gsv,
                lyrm1_yee_inv_value = lyrm1_yee_inv_value + rcd_sales_extract_01.lyrm1_gsv,
                lyrm2_yee_inv_value = lyrm2_yee_inv_value + rcd_sales_extract_01.lyrm2_gsv,
                lyr_ytp_inv_value = lyr_ytp_inv_value + rcd_sales_extract_01.ltp_gsv,
                cyr_ytp_inv_value = cyr_ytp_inv_value + rcd_sales_extract_01.ytp_gsv,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_gsv,
                cyr_yee_br_value = cyr_yee_br_value + rcd_sales_extract_01.ytp_gsv,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_01.ytp_gsv,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_01.p01_gsv,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_01.p02_gsv,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_01.p03_gsv,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_01.p04_gsv,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_01.p05_gsv,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_01.p06_gsv,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_01.p07_gsv,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_01.p08_gsv,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_01.p09_gsv,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_01.p10_gsv,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_01.p11_gsv,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_01.p12_gsv,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_01.p13_gsv,
                p01_br_value = p01_br_value + rcd_sales_extract_01.p01_gsv,
                p02_br_value = p02_br_value + rcd_sales_extract_01.p02_gsv,
                p03_br_value = p03_br_value + rcd_sales_extract_01.p03_gsv,
                p04_br_value = p04_br_value + rcd_sales_extract_01.p04_gsv,
                p05_br_value = p05_br_value + rcd_sales_extract_01.p05_gsv,
                p06_br_value = p06_br_value + rcd_sales_extract_01.p06_gsv,
                p07_br_value = p07_br_value + rcd_sales_extract_01.p07_gsv,
                p08_br_value = p08_br_value + rcd_sales_extract_01.p08_gsv,
                p09_br_value = p09_br_value + rcd_sales_extract_01.p09_gsv,
                p10_br_value = p10_br_value + rcd_sales_extract_01.p10_gsv,
                p11_br_value = p11_br_value + rcd_sales_extract_01.p11_gsv,
                p12_br_value = p12_br_value + rcd_sales_extract_01.p12_gsv,
                p13_br_value = p13_br_value + rcd_sales_extract_01.p13_gsv,
                p01_rob_value = p01_rob_value + rcd_sales_extract_01.p01_gsv,
                p02_rob_value = p02_rob_value + rcd_sales_extract_01.p02_gsv,
                p03_rob_value = p03_rob_value + rcd_sales_extract_01.p03_gsv,
                p04_rob_value = p04_rob_value + rcd_sales_extract_01.p04_gsv,
                p05_rob_value = p05_rob_value + rcd_sales_extract_01.p05_gsv,
                p06_rob_value = p06_rob_value + rcd_sales_extract_01.p06_gsv,
                p07_rob_value = p07_rob_value + rcd_sales_extract_01.p07_gsv,
                p08_rob_value = p08_rob_value + rcd_sales_extract_01.p08_gsv,
                p09_rob_value = p09_rob_value + rcd_sales_extract_01.p09_gsv,
                p10_rob_value = p10_rob_value + rcd_sales_extract_01.p10_gsv,
                p11_rob_value = p11_rob_value + rcd_sales_extract_01.p11_gsv,
                p12_rob_value = p12_rob_value + rcd_sales_extract_01.p12_gsv,
                p13_rob_value = p13_rob_value + rcd_sales_extract_01.p13_gsv,
                p01_lyr_value = p01_lyr_value + rcd_sales_extract_01.l01_gsv,
                p02_lyr_value = p02_lyr_value + rcd_sales_extract_01.l02_gsv,
                p03_lyr_value = p03_lyr_value + rcd_sales_extract_01.l03_gsv,
                p04_lyr_value = p04_lyr_value + rcd_sales_extract_01.l04_gsv,
                p05_lyr_value = p05_lyr_value + rcd_sales_extract_01.l05_gsv,
                p06_lyr_value = p06_lyr_value + rcd_sales_extract_01.l06_gsv,
                p07_lyr_value = p07_lyr_value + rcd_sales_extract_01.l07_gsv,
                p08_lyr_value = p08_lyr_value + rcd_sales_extract_01.l08_gsv,
                p09_lyr_value = p09_lyr_value + rcd_sales_extract_01.l09_gsv,
                p10_lyr_value = p10_lyr_value + rcd_sales_extract_01.l10_gsv,
                p11_lyr_value = p11_lyr_value + rcd_sales_extract_01.l11_gsv,
                p12_lyr_value = p12_lyr_value + rcd_sales_extract_01.l12_gsv,
                p13_lyr_value = p13_lyr_value + rcd_sales_extract_01.l13_gsv
          where company_code = rcd_sales_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_sales_extract_01.nzmkt_matl_group
            and ship_to_cust_code = rcd_sales_extract_01.cust_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_01.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set lyr_cpd_inv_value = lyr_cpd_inv_value + rcd_sales_extract_01.lst_ton,
                ptd_inv_value = ptd_inv_value + rcd_sales_extract_01.cur_ton,
                cpd_inv_value = cpd_inv_value + rcd_sales_extract_01.cur_ton,
                fpd_inv_value = fpd_inv_value + rcd_sales_extract_01.fut_ton,
                lyr_yee_inv_value = lyr_yee_inv_value + rcd_sales_extract_01.lyr_ton,
                lyrm1_yee_inv_value = lyrm1_yee_inv_value + rcd_sales_extract_01.lyrm1_ton,
                lyrm2_yee_inv_value = lyrm2_yee_inv_value + rcd_sales_extract_01.lyrm2_ton,
                lyr_ytp_inv_value = lyr_ytp_inv_value + rcd_sales_extract_01.ltp_ton,
                cyr_ytp_inv_value = cyr_ytp_inv_value + rcd_sales_extract_01.ytp_ton,
                cyr_mat_inv_value = cyr_mat_inv_value + rcd_sales_extract_01.mat_ton,
                cyr_yee_br_value = cyr_yee_br_value + rcd_sales_extract_01.ytp_ton,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_01.ytp_ton,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_01.p01_ton,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_01.p02_ton,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_01.p03_ton,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_01.p04_ton,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_01.p05_ton,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_01.p06_ton,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_01.p07_ton,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_01.p08_ton,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_01.p09_ton,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_01.p10_ton,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_01.p11_ton,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_01.p12_ton,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_01.p13_ton,
                p01_br_value = p01_br_value + rcd_sales_extract_01.p01_ton,
                p02_br_value = p02_br_value + rcd_sales_extract_01.p02_ton,
                p03_br_value = p03_br_value + rcd_sales_extract_01.p03_ton,
                p04_br_value = p04_br_value + rcd_sales_extract_01.p04_ton,
                p05_br_value = p05_br_value + rcd_sales_extract_01.p05_ton,
                p06_br_value = p06_br_value + rcd_sales_extract_01.p06_ton,
                p07_br_value = p07_br_value + rcd_sales_extract_01.p07_ton,
                p08_br_value = p08_br_value + rcd_sales_extract_01.p08_ton,
                p09_br_value = p09_br_value + rcd_sales_extract_01.p09_ton,
                p10_br_value = p10_br_value + rcd_sales_extract_01.p10_ton,
                p11_br_value = p11_br_value + rcd_sales_extract_01.p11_ton,
                p12_br_value = p12_br_value + rcd_sales_extract_01.p12_ton,
                p13_br_value = p13_br_value + rcd_sales_extract_01.p13_ton,
                p01_rob_value = p01_rob_value + rcd_sales_extract_01.p01_ton,
                p02_rob_value = p02_rob_value + rcd_sales_extract_01.p02_ton,
                p03_rob_value = p03_rob_value + rcd_sales_extract_01.p03_ton,
                p04_rob_value = p04_rob_value + rcd_sales_extract_01.p04_ton,
                p05_rob_value = p05_rob_value + rcd_sales_extract_01.p05_ton,
                p06_rob_value = p06_rob_value + rcd_sales_extract_01.p06_ton,
                p07_rob_value = p07_rob_value + rcd_sales_extract_01.p07_ton,
                p08_rob_value = p08_rob_value + rcd_sales_extract_01.p08_ton,
                p09_rob_value = p09_rob_value + rcd_sales_extract_01.p09_ton,
                p10_rob_value = p10_rob_value + rcd_sales_extract_01.p10_ton,
                p11_rob_value = p11_rob_value + rcd_sales_extract_01.p11_ton,
                p12_rob_value = p12_rob_value + rcd_sales_extract_01.p12_ton,
                p13_rob_value = p13_rob_value + rcd_sales_extract_01.p13_ton,
                p01_lyr_value = p01_lyr_value + rcd_sales_extract_01.l01_ton,
                p02_lyr_value = p02_lyr_value + rcd_sales_extract_01.l02_ton,
                p03_lyr_value = p03_lyr_value + rcd_sales_extract_01.l03_ton,
                p04_lyr_value = p04_lyr_value + rcd_sales_extract_01.l04_ton,
                p05_lyr_value = p05_lyr_value + rcd_sales_extract_01.l05_ton,
                p06_lyr_value = p06_lyr_value + rcd_sales_extract_01.l06_ton,
                p07_lyr_value = p07_lyr_value + rcd_sales_extract_01.l07_ton,
                p08_lyr_value = p08_lyr_value + rcd_sales_extract_01.l08_ton,
                p09_lyr_value = p09_lyr_value + rcd_sales_extract_01.l09_ton,
                p10_lyr_value = p10_lyr_value + rcd_sales_extract_01.l10_ton,
                p11_lyr_value = p11_lyr_value + rcd_sales_extract_01.l11_ton,
                p12_lyr_value = p12_lyr_value + rcd_sales_extract_01.l12_ton,
                p13_lyr_value = p13_lyr_value + rcd_sales_extract_01.l13_ton
          where company_code = rcd_sales_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_sales_extract_01.nzmkt_matl_group
            and ship_to_cust_code = rcd_sales_extract_01.cust_code
            and matl_code = rcd_sales_extract_01.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_01.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_sales_extract_01;

      /*-*/
      /* Extract the daily sales values
      /*-*/
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
                       par_data_segment,
                       rcd_sales_extract_02.nzmkt_matl_group,
                       rcd_sales_extract_02.cust_code,
                       rcd_sales_extract_02.matl_code,
                       rcd_sales_extract_02.acct_assgnmnt_grp_code,
                       rcd_sales_extract_02.demand_plng_grp_code,
                       rcd_sales_extract_02.mfanz_icb_flag);

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cdy_inv_value = cdy_inv_value + rcd_sales_extract_02.cur_qty,
                ptw_inv_value = ptw_inv_value + rcd_sales_extract_02.ptw_qty,
                cpd_fcst_value = cpd_fcst_value + rcd_sales_extract_02.ptw_qty,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_02.ptw_qty,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_02.w01_qty,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_02.w02_qty,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_02.w03_qty,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_02.w04_qty,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_02.w05_qty,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_02.w06_qty,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_02.w07_qty,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_02.w08_qty,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_02.w09_qty,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_02.w10_qty,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_02.w11_qty,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_02.w12_qty,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_02.w13_qty
          where company_code = rcd_sales_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_sales_extract_02.nzmkt_matl_group
            and ship_to_cust_code = rcd_sales_extract_02.cust_code
            and matl_code = rcd_sales_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_02.mfanz_icb_flag
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cdy_inv_value = cdy_inv_value + rcd_sales_extract_02.cur_gsv,
                ptw_inv_value = ptw_inv_value + rcd_sales_extract_02.ptw_gsv,
                cpd_fcst_value = cpd_fcst_value + rcd_sales_extract_02.ptw_gsv,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_02.ptw_gsv,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_02.w01_gsv,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_02.w02_gsv,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_02.w03_gsv,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_02.w04_gsv,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_02.w05_gsv,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_02.w06_gsv,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_02.w07_gsv,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_02.w08_gsv,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_02.w09_gsv,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_02.w10_gsv,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_02.w11_gsv,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_02.w12_gsv,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_02.w13_gsv
          where company_code = rcd_sales_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_sales_extract_02.nzmkt_matl_group
            and ship_to_cust_code = rcd_sales_extract_02.cust_code
            and matl_code = rcd_sales_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_02.mfanz_icb_flag
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cdy_inv_value = cdy_inv_value + rcd_sales_extract_02.cur_ton,
                ptw_inv_value = ptw_inv_value + rcd_sales_extract_02.ptw_ton,
                cpd_fcst_value = cpd_fcst_value + rcd_sales_extract_02.ptw_ton,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_sales_extract_02.ptw_ton,
                p01_fcst_value = p01_fcst_value + rcd_sales_extract_02.w01_ton,
                p02_fcst_value = p02_fcst_value + rcd_sales_extract_02.w02_ton,
                p03_fcst_value = p03_fcst_value + rcd_sales_extract_02.w03_ton,
                p04_fcst_value = p04_fcst_value + rcd_sales_extract_02.w04_ton,
                p05_fcst_value = p05_fcst_value + rcd_sales_extract_02.w05_ton,
                p06_fcst_value = p06_fcst_value + rcd_sales_extract_02.w06_ton,
                p07_fcst_value = p07_fcst_value + rcd_sales_extract_02.w07_ton,
                p08_fcst_value = p08_fcst_value + rcd_sales_extract_02.w08_ton,
                p09_fcst_value = p09_fcst_value + rcd_sales_extract_02.w09_ton,
                p10_fcst_value = p10_fcst_value + rcd_sales_extract_02.w10_ton,
                p11_fcst_value = p11_fcst_value + rcd_sales_extract_02.w11_ton,
                p12_fcst_value = p12_fcst_value + rcd_sales_extract_02.w12_ton,
                p13_fcst_value = p13_fcst_value + rcd_sales_extract_02.w13_ton
          where company_code = rcd_sales_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_sales_extract_02.nzmkt_matl_group
            and ship_to_cust_code = rcd_sales_extract_02.cust_code
            and matl_code = rcd_sales_extract_02.matl_code
            and acct_assgnmnt_grp_code = rcd_sales_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_sales_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = rcd_sales_extract_02.mfanz_icb_flag
            and data_type = '*TON';

      end loop;
      close csr_sales_extract_02;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_nzmkt_sale;

   /***********************************************************/
   /* This procedure performs the NZMKT forecast data routine */
   /***********************************************************/
   procedure extract_nzmkt_forecast(par_company_code in varchar2, par_data_segment in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_cyr_str_yyyypp number(6,0);
      var_cyr_end_yyyypp number(6,0);
      var_ytg_str_yyyypp number(6,0);
      var_ytg_end_yyyypp number(6,0);
      var_nyr_str_yyyypp number(6,0);
      var_nyr_end_yyyypp number(6,0);
      var_ptg_str_yyyyppw number(7,0);
      var_ptg_end_yyyyppw number(7,0);
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
                decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN') as nzmkt_matl_group,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty end),0) as cur_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as cur_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(t01.fcst_qty),0) as yee_qty,
                nvl(sum(t01.fcst_value_aud),0) as yee_gsv,
                nvl(sum(t01.fcst_qty_net_tonnes),0) as yee_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_cyr_str_yyyypp
            and t01.fcst_yyyypp <= var_cyr_end_yyyypp
            and t01.fcst_type_code = 'OP'
            and t01.acct_assgnmnt_grp_code = '03'
            and t01.demand_plng_grp_code = '0040010915'
            and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45'))
          group by t01.company_code,
                   decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN'),
                   t01.cust_code,
                   t01.matl_zrep_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_01 csr_fcst_extract_01%rowtype;

      cursor csr_fcst_extract_02 is
         select t01.company_code,
                decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN') as nzmkt_matl_group,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty end),0) as cur_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as cur_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_cyr_end_yyyypp
            and t01.fcst_type_code = 'ROB'
            and t01.acct_assgnmnt_grp_code = '03'
            and t01.demand_plng_grp_code = '0040010915'
            and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45'))
          group by t01.company_code,
                   decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN'),
                   t01.cust_code,
                   t01.matl_zrep_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_02 csr_fcst_extract_02%rowtype;

      cursor csr_fcst_extract_03 is
         select t01.company_code,
                decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN') as nzmkt_matl_group,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty end),0) as cur_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_value_aud end),0) as cur_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_ytg_str_yyyypp then t01.fcst_qty_net_tonnes end),0) as cur_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_value_aud end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty end),0) as nyr_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_value_aud end),0) as nyr_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as nyr_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty end),0) as p14_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty end),0) as p15_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty end),0) as p16_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty end),0) as p17_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty end),0) as p18_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty end),0) as P19_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty end),0) as p20_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty end),0) as p21_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty end),0) as p22_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty end),0) as p23_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty end),0) as p24_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty end),0) as p25_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty end),0) as p26_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_value_aud end),0) as p14_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_value_aud end),0) as p15_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_value_aud end),0) as p16_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_value_aud end),0) as p17_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_value_aud end),0) as p18_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_value_aud end),0) as p19_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_value_aud end),0) as p20_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_value_aud end),0) as p21_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_value_aud end),0) as p22_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_value_aud end),0) as p23_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_value_aud end),0) as p24_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_value_aud end),0) as p25_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_value_aud end),0) as p26_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_ytg_str_yyyypp and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty_net_tonnes end),0) as p14_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty_net_tonnes end),0) as p15_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty_net_tonnes end),0) as p16_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty_net_tonnes end),0) as p17_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty_net_tonnes end),0) as p18_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty_net_tonnes end),0) as p19_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty_net_tonnes end),0) as p20_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty_net_tonnes end),0) as p21_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty_net_tonnes end),0) as p22_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty_net_tonnes end),0) as p23_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty_net_tonnes end),0) as p24_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty_net_tonnes end),0) as p25_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty_net_tonnes end),0) as p26_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_nyr_end_yyyypp
            and t01.fcst_type_code = 'BR'
            and t01.acct_assgnmnt_grp_code = '03'
            and t01.demand_plng_grp_code = '0040010915'
            and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45'))
          group by t01.company_code,
                   decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN'),
                   t01.cust_code,
                   t01.matl_zrep_code,
                   t01.acct_assgnmnt_grp_code,
                   t01.demand_plng_grp_code;
      rcd_fcst_extract_03 csr_fcst_extract_03%rowtype;

      cursor csr_fcst_extract_04 is
         select t01.company_code,
                decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN') as nzmkt_matl_group,
                nvl(t01.cust_code,'*NULL') as cust_code,
                t01.matl_zrep_code,
                nvl(t01.acct_assgnmnt_grp_code,'*NULL') as acct_assgnmnt_grp_code,
                nvl(t01.demand_plng_grp_code,'*NULL') as demand_plng_grp_code,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyyppw <= var_ptg_end_yyyyppw then t01.fcst_qty end),0) as ptg_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyyppw <= var_ptg_end_yyyyppw then t01.fcst_value_aud end),0) as ptg_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyyppw <= var_ptg_end_yyyyppw then t01.fcst_qty_net_tonnes end),0) as ptg_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty end),0) as ytg_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_value_aud end),0) as ytg_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp <= var_ytg_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as ytg_ton,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty end),0) as nyr_qty,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_value_aud end),0) as nyr_gsv,
                nvl(sum(case when t01.fcst_yyyypp >= var_nyr_str_yyyypp and t01.fcst_yyyypp <= var_nyr_end_yyyypp then t01.fcst_qty_net_tonnes end),0) as nyr_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty end),0) as p01_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty end),0) as p02_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty end),0) as p03_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty end),0) as p04_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty end),0) as p05_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty end),0) as p06_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty end),0) as p07_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty end),0) as p08_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty end),0) as p09_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty end),0) as p10_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty end),0) as p11_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty end),0) as p12_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty end),0) as p13_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty end),0) as p14_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty end),0) as p15_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty end),0) as p16_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty end),0) as p17_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty end),0) as p18_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty end),0) as P19_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty end),0) as p20_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty end),0) as p21_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty end),0) as p22_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty end),0) as p23_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty end),0) as p24_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty end),0) as p25_qty,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty end),0) as p26_qty,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_value_aud end),0) as p01_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_value_aud end),0) as p02_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_value_aud end),0) as p03_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_value_aud end),0) as p04_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_value_aud end),0) as p05_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_value_aud end),0) as p06_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_value_aud end),0) as p07_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_value_aud end),0) as p08_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_value_aud end),0) as p09_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_value_aud end),0) as p10_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_value_aud end),0) as p11_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_value_aud end),0) as p12_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_value_aud end),0) as p13_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_value_aud end),0) as p14_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_value_aud end),0) as p15_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_value_aud end),0) as p16_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_value_aud end),0) as p17_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_value_aud end),0) as p18_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_value_aud end),0) as p19_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_value_aud end),0) as p20_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_value_aud end),0) as p21_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_value_aud end),0) as p22_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_value_aud end),0) as p23_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_value_aud end),0) as p24_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_value_aud end),0) as p25_gsv,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_value_aud end),0) as p26_gsv,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p01 then t01.fcst_qty_net_tonnes end),0) as p01_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p02 then t01.fcst_qty_net_tonnes end),0) as p02_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p03 then t01.fcst_qty_net_tonnes end),0) as p03_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p04 then t01.fcst_qty_net_tonnes end),0) as p04_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p05 then t01.fcst_qty_net_tonnes end),0) as p05_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p06 then t01.fcst_qty_net_tonnes end),0) as p06_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p07 then t01.fcst_qty_net_tonnes end),0) as p07_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p08 then t01.fcst_qty_net_tonnes end),0) as p08_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p09 then t01.fcst_qty_net_tonnes end),0) as p09_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p10 then t01.fcst_qty_net_tonnes end),0) as p10_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p11 then t01.fcst_qty_net_tonnes end),0) as p11_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p12 then t01.fcst_qty_net_tonnes end),0) as p12_ton,
                nvl(sum(case when t01.fcst_yyyyppw >= var_ptg_str_yyyyppw and t01.fcst_yyyypp = var_wyr_p13 then t01.fcst_qty_net_tonnes end),0) as p13_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p14 then t01.fcst_qty_net_tonnes end),0) as p14_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p15 then t01.fcst_qty_net_tonnes end),0) as p15_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p16 then t01.fcst_qty_net_tonnes end),0) as p16_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p17 then t01.fcst_qty_net_tonnes end),0) as p17_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p18 then t01.fcst_qty_net_tonnes end),0) as p18_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p19 then t01.fcst_qty_net_tonnes end),0) as p19_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p20 then t01.fcst_qty_net_tonnes end),0) as p20_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p21 then t01.fcst_qty_net_tonnes end),0) as p21_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p22 then t01.fcst_qty_net_tonnes end),0) as p22_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p23 then t01.fcst_qty_net_tonnes end),0) as p23_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p24 then t01.fcst_qty_net_tonnes end),0) as p24_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p25 then t01.fcst_qty_net_tonnes end),0) as p25_ton,
                nvl(sum(case when t01.fcst_yyyypp = var_wyr_p26 then t01.fcst_qty_net_tonnes end),0) as p26_ton
           from fcst_fact t01,
                matl_dim t02
          where t01.matl_zrep_code = t02.matl_code(+)
            and t01.company_code = par_company_code
            and t01.fcst_yyyypp >= var_ytg_str_yyyypp
            and t01.fcst_yyyypp <= var_nyr_end_yyyypp
            and t01.fcst_type_code = 'FCST'
            and t01.acct_assgnmnt_grp_code = '03'
            and t01.demand_plng_grp_code = '0040010915'
            and (t02.bus_sgmnt_code = '05' and (t02.cnsmr_pack_frmt_code = '51' or t02.cnsmr_pack_frmt_code = '45'))
          group by t01.company_code,
                   decode(t02.cnsmr_pack_frmt_code,'51','DOG_ROLL','45','POUCH','UNKNOWN'),
                   t01.cust_code,
                   t01.matl_zrep_code,
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
      var_ptg_str_yyyyppw := var_current_yyyyppw;
      var_ptg_end_yyyyppw := (var_current_yyyypp * 10) + 4;
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
                       par_data_segment,
                       rcd_fcst_extract_01.nzmkt_matl_group,
                       rcd_fcst_extract_01.cust_code,
                       rcd_fcst_extract_01.matl_zrep_code,
                       rcd_fcst_extract_01.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_01.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_op_value = cpd_op_value + rcd_fcst_extract_01.cur_qty,
                cyr_yee_op_value = cyr_yee_op_value + rcd_fcst_extract_01.yee_qty,
                p01_op_value = p01_br_value + rcd_fcst_extract_01.p01_qty,
                p02_op_value = p02_op_value + rcd_fcst_extract_01.p02_qty,
                p03_op_value = p03_op_value + rcd_fcst_extract_01.p03_qty,
                p04_op_value = p04_op_value + rcd_fcst_extract_01.p04_qty,
                p05_op_value = p05_op_value + rcd_fcst_extract_01.p05_qty,
                p06_op_value = p06_op_value + rcd_fcst_extract_01.p06_qty,
                p07_op_value = p07_op_value + rcd_fcst_extract_01.p07_qty,
                p08_op_value = p08_op_value + rcd_fcst_extract_01.p08_qty,
                p09_op_value = p09_op_value + rcd_fcst_extract_01.p09_qty,
                p10_op_value = p10_op_value + rcd_fcst_extract_01.p10_qty,
                p11_op_value = p11_op_value + rcd_fcst_extract_01.p11_qty,
                p12_op_value = p12_op_value + rcd_fcst_extract_01.p12_qty,
                p13_op_value = p13_op_value + rcd_fcst_extract_01.p13_qty
          where company_code = rcd_fcst_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_01.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_01.cust_code
            and matl_code = rcd_fcst_extract_01.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_op_value = cpd_op_value + rcd_fcst_extract_01.cur_gsv,
                cyr_yee_op_value = cyr_yee_op_value + rcd_fcst_extract_01.yee_gsv,
                p01_op_value = p01_br_value + rcd_fcst_extract_01.p01_gsv,
                p02_op_value = p02_op_value + rcd_fcst_extract_01.p02_gsv,
                p03_op_value = p03_op_value + rcd_fcst_extract_01.p03_gsv,
                p04_op_value = p04_op_value + rcd_fcst_extract_01.p04_gsv,
                p05_op_value = p05_op_value + rcd_fcst_extract_01.p05_gsv,
                p06_op_value = p06_op_value + rcd_fcst_extract_01.p06_gsv,
                p07_op_value = p07_op_value + rcd_fcst_extract_01.p07_gsv,
                p08_op_value = p08_op_value + rcd_fcst_extract_01.p08_gsv,
                p09_op_value = p09_op_value + rcd_fcst_extract_01.p09_gsv,
                p10_op_value = p10_op_value + rcd_fcst_extract_01.p10_gsv,
                p11_op_value = p11_op_value + rcd_fcst_extract_01.p11_gsv,
                p12_op_value = p12_op_value + rcd_fcst_extract_01.p12_gsv,
                p13_op_value = p13_op_value + rcd_fcst_extract_01.p13_gsv
          where company_code = rcd_fcst_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_01.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_01.cust_code
            and matl_code = rcd_fcst_extract_01.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_op_value = cpd_op_value + rcd_fcst_extract_01.cur_ton,
                cyr_yee_op_value = cyr_yee_op_value + rcd_fcst_extract_01.yee_ton,
                p01_op_value = p01_br_value + rcd_fcst_extract_01.p01_ton,
                p02_op_value = p02_op_value + rcd_fcst_extract_01.p02_ton,
                p03_op_value = p03_op_value + rcd_fcst_extract_01.p03_ton,
                p04_op_value = p04_op_value + rcd_fcst_extract_01.p04_ton,
                p05_op_value = p05_op_value + rcd_fcst_extract_01.p05_ton,
                p06_op_value = p06_op_value + rcd_fcst_extract_01.p06_ton,
                p07_op_value = p07_op_value + rcd_fcst_extract_01.p07_ton,
                p08_op_value = p08_op_value + rcd_fcst_extract_01.p08_ton,
                p09_op_value = p09_op_value + rcd_fcst_extract_01.p09_ton,
                p10_op_value = p10_op_value + rcd_fcst_extract_01.p10_ton,
                p11_op_value = p11_op_value + rcd_fcst_extract_01.p11_ton,
                p12_op_value = p12_op_value + rcd_fcst_extract_01.p12_ton,
                p13_op_value = p13_op_value + rcd_fcst_extract_01.p13_ton
          where company_code = rcd_fcst_extract_01.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_01.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_01.cust_code
            and matl_code = rcd_fcst_extract_01.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_01.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_01.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
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
                       par_data_segment,
                       rcd_fcst_extract_02.nzmkt_matl_group,
                       rcd_fcst_extract_02.cust_code,
                       rcd_fcst_extract_02.matl_zrep_code,
                       rcd_fcst_extract_02.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_02.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_rob_value = cpd_rob_value + rcd_fcst_extract_02.cur_qty,
                cyr_ytg_rob_value = cyr_ytg_rob_value + rcd_fcst_extract_02.ytg_qty,
                cyr_yee_rob_value = cyr_yee_rob_value + rcd_fcst_extract_02.ytg_qty,
                p01_rob_value = p01_rob_value + rcd_fcst_extract_02.p01_qty,
                p02_rob_value = p02_rob_value + rcd_fcst_extract_02.p02_qty,
                p03_rob_value = p03_rob_value + rcd_fcst_extract_02.p03_qty,
                p04_rob_value = p04_rob_value + rcd_fcst_extract_02.p04_qty,
                p05_rob_value = p05_rob_value + rcd_fcst_extract_02.p05_qty,
                p06_rob_value = p06_rob_value + rcd_fcst_extract_02.p06_qty,
                p07_rob_value = p07_rob_value + rcd_fcst_extract_02.p07_qty,
                p08_rob_value = p08_rob_value + rcd_fcst_extract_02.p08_qty,
                p09_rob_value = p09_rob_value + rcd_fcst_extract_02.p09_qty,
                p10_rob_value = p10_rob_value + rcd_fcst_extract_02.p10_qty,
                p11_rob_value = p11_rob_value + rcd_fcst_extract_02.p11_qty,
                p12_rob_value = p12_rob_value + rcd_fcst_extract_02.p12_qty,
                p13_rob_value = p13_rob_value + rcd_fcst_extract_02.p13_qty
          where company_code = rcd_fcst_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_02.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_02.cust_code
            and matl_code = rcd_fcst_extract_02.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_rob_value = cpd_rob_value + rcd_fcst_extract_02.cur_gsv,
                cyr_ytg_rob_value = cyr_ytg_rob_value + rcd_fcst_extract_02.ytg_gsv,
                cyr_yee_rob_value = cyr_yee_rob_value + rcd_fcst_extract_02.ytg_gsv,
                p01_rob_value = p01_rob_value + rcd_fcst_extract_02.p01_gsv,
                p02_rob_value = p02_rob_value + rcd_fcst_extract_02.p02_gsv,
                p03_rob_value = p03_rob_value + rcd_fcst_extract_02.p03_gsv,
                p04_rob_value = p04_rob_value + rcd_fcst_extract_02.p04_gsv,
                p05_rob_value = p05_rob_value + rcd_fcst_extract_02.p05_gsv,
                p06_rob_value = p06_rob_value + rcd_fcst_extract_02.p06_gsv,
                p07_rob_value = p07_rob_value + rcd_fcst_extract_02.p07_gsv,
                p08_rob_value = p08_rob_value + rcd_fcst_extract_02.p08_gsv,
                p09_rob_value = p09_rob_value + rcd_fcst_extract_02.p09_gsv,
                p10_rob_value = p10_rob_value + rcd_fcst_extract_02.p10_gsv,
                p11_rob_value = p11_rob_value + rcd_fcst_extract_02.p11_gsv,
                p12_rob_value = p12_rob_value + rcd_fcst_extract_02.p12_gsv,
                p13_rob_value = p13_rob_value + rcd_fcst_extract_02.p13_gsv
          where company_code = rcd_fcst_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_02.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_02.cust_code
            and matl_code = rcd_fcst_extract_02.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_rob_value = cpd_rob_value + rcd_fcst_extract_02.cur_ton,
                cyr_ytg_rob_value = cyr_ytg_rob_value + rcd_fcst_extract_02.ytg_ton,
                cyr_yee_rob_value = cyr_yee_rob_value + rcd_fcst_extract_02.ytg_ton,
                p01_rob_value = p01_rob_value + rcd_fcst_extract_02.p01_ton,
                p02_rob_value = p02_rob_value + rcd_fcst_extract_02.p02_ton,
                p03_rob_value = p03_rob_value + rcd_fcst_extract_02.p03_ton,
                p04_rob_value = p04_rob_value + rcd_fcst_extract_02.p04_ton,
                p05_rob_value = p05_rob_value + rcd_fcst_extract_02.p05_ton,
                p06_rob_value = p06_rob_value + rcd_fcst_extract_02.p06_ton,
                p07_rob_value = p07_rob_value + rcd_fcst_extract_02.p07_ton,
                p08_rob_value = p08_rob_value + rcd_fcst_extract_02.p08_ton,
                p09_rob_value = p09_rob_value + rcd_fcst_extract_02.p09_ton,
                p10_rob_value = p10_rob_value + rcd_fcst_extract_02.p10_ton,
                p11_rob_value = p11_rob_value + rcd_fcst_extract_02.p11_ton,
                p12_rob_value = p12_rob_value + rcd_fcst_extract_02.p12_ton,
                p13_rob_value = p13_rob_value + rcd_fcst_extract_02.p13_ton
          where company_code = rcd_fcst_extract_02.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_02.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_02.cust_code
            and matl_code = rcd_fcst_extract_02.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_02.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_02.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
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
                       par_data_segment,
                       rcd_fcst_extract_03.nzmkt_matl_group,
                       rcd_fcst_extract_03.cust_code,
                       rcd_fcst_extract_03.matl_zrep_code,
                       rcd_fcst_extract_03.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_03.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set cpd_br_value = cpd_br_value + rcd_fcst_extract_03.cur_qty,
                cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_qty,
                cyr_yee_br_value = cyr_yee_br_value + rcd_fcst_extract_03.ytg_qty,
                nyr_yee_br_value = nyr_yee_br_value + rcd_fcst_extract_03.nyr_qty,
                p01_br_value = p01_br_value + rcd_fcst_extract_03.p01_qty,
                p02_br_value = p02_br_value + rcd_fcst_extract_03.p02_qty,
                p03_br_value = p03_br_value + rcd_fcst_extract_03.p03_qty,
                p04_br_value = p04_br_value + rcd_fcst_extract_03.p04_qty,
                p05_br_value = p05_br_value + rcd_fcst_extract_03.p05_qty,
                p06_br_value = p06_br_value + rcd_fcst_extract_03.p06_qty,
                p07_br_value = p07_br_value + rcd_fcst_extract_03.p07_qty,
                p08_br_value = p08_br_value + rcd_fcst_extract_03.p08_qty,
                p09_br_value = p09_br_value + rcd_fcst_extract_03.p09_qty,
                p10_br_value = p10_br_value + rcd_fcst_extract_03.p10_qty,
                p11_br_value = p11_br_value + rcd_fcst_extract_03.p11_qty,
                p12_br_value = p12_br_value + rcd_fcst_extract_03.p12_qty,
                p13_br_value = p13_br_value + rcd_fcst_extract_03.p13_qty,
                p14_br_value = p14_br_value + rcd_fcst_extract_03.p14_qty,
                p15_br_value = p15_br_value + rcd_fcst_extract_03.p15_qty,
                p16_br_value = p16_br_value + rcd_fcst_extract_03.p16_qty,
                p17_br_value = p17_br_value + rcd_fcst_extract_03.p17_qty,
                p18_br_value = p18_br_value + rcd_fcst_extract_03.p18_qty,
                p19_br_value = p19_br_value + rcd_fcst_extract_03.p19_qty,
                p20_br_value = p20_br_value + rcd_fcst_extract_03.p20_qty,
                p21_br_value = p21_br_value + rcd_fcst_extract_03.p21_qty,
                p22_br_value = p22_br_value + rcd_fcst_extract_03.p22_qty,
                p23_br_value = p23_br_value + rcd_fcst_extract_03.p23_qty,
                p24_br_value = p24_br_value + rcd_fcst_extract_03.p24_qty,
                p25_br_value = p25_br_value + rcd_fcst_extract_03.p25_qty,
                p26_br_value = p26_br_value + rcd_fcst_extract_03.p26_qty
          where company_code = rcd_fcst_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_03.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_03.cust_code
            and matl_code = rcd_fcst_extract_03.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set cpd_br_value = cpd_br_value + rcd_fcst_extract_03.cur_gsv,
                cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_gsv,
                cyr_yee_br_value = cyr_yee_br_value + rcd_fcst_extract_03.ytg_gsv,
                nyr_yee_br_value = nyr_yee_br_value + rcd_fcst_extract_03.nyr_gsv,
                p01_br_value = p01_br_value + rcd_fcst_extract_03.p01_gsv,
                p02_br_value = p02_br_value + rcd_fcst_extract_03.p02_gsv,
                p03_br_value = p03_br_value + rcd_fcst_extract_03.p03_gsv,
                p04_br_value = p04_br_value + rcd_fcst_extract_03.p04_gsv,
                p05_br_value = p05_br_value + rcd_fcst_extract_03.p05_gsv,
                p06_br_value = p06_br_value + rcd_fcst_extract_03.p06_gsv,
                p07_br_value = p07_br_value + rcd_fcst_extract_03.p07_gsv,
                p08_br_value = p08_br_value + rcd_fcst_extract_03.p08_gsv,
                p09_br_value = p09_br_value + rcd_fcst_extract_03.p09_gsv,
                p10_br_value = p10_br_value + rcd_fcst_extract_03.p10_gsv,
                p11_br_value = p11_br_value + rcd_fcst_extract_03.p11_gsv,
                p12_br_value = p12_br_value + rcd_fcst_extract_03.p12_gsv,
                p13_br_value = p13_br_value + rcd_fcst_extract_03.p13_gsv,
                p14_br_value = p14_br_value + rcd_fcst_extract_03.p14_gsv,
                p15_br_value = p15_br_value + rcd_fcst_extract_03.p15_gsv,
                p16_br_value = p16_br_value + rcd_fcst_extract_03.p16_gsv,
                p17_br_value = p17_br_value + rcd_fcst_extract_03.p17_gsv,
                p18_br_value = p18_br_value + rcd_fcst_extract_03.p18_gsv,
                p19_br_value = p19_br_value + rcd_fcst_extract_03.p19_gsv,
                p20_br_value = p20_br_value + rcd_fcst_extract_03.p20_gsv,
                p21_br_value = p21_br_value + rcd_fcst_extract_03.p21_gsv,
                p22_br_value = p22_br_value + rcd_fcst_extract_03.p22_gsv,
                p23_br_value = p23_br_value + rcd_fcst_extract_03.p23_gsv,
                p24_br_value = p24_br_value + rcd_fcst_extract_03.p24_gsv,
                p25_br_value = p25_br_value + rcd_fcst_extract_03.p25_gsv,
                p26_br_value = p26_br_value + rcd_fcst_extract_03.p26_gsv
          where company_code = rcd_fcst_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_03.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_03.cust_code
            and matl_code = rcd_fcst_extract_03.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set cpd_br_value = cpd_br_value + rcd_fcst_extract_03.cur_ton,
                cyr_ytg_br_value = cyr_ytg_br_value + rcd_fcst_extract_03.ytg_ton,
                cyr_yee_br_value = cyr_yee_br_value + rcd_fcst_extract_03.ytg_ton,
                nyr_yee_br_value = nyr_yee_br_value + rcd_fcst_extract_03.nyr_ton,
                p01_br_value = p01_br_value + rcd_fcst_extract_03.p01_ton,
                p02_br_value = p02_br_value + rcd_fcst_extract_03.p02_ton,
                p03_br_value = p03_br_value + rcd_fcst_extract_03.p03_ton,
                p04_br_value = p04_br_value + rcd_fcst_extract_03.p04_ton,
                p05_br_value = p05_br_value + rcd_fcst_extract_03.p05_ton,
                p06_br_value = p06_br_value + rcd_fcst_extract_03.p06_ton,
                p07_br_value = p07_br_value + rcd_fcst_extract_03.p07_ton,
                p08_br_value = p08_br_value + rcd_fcst_extract_03.p08_ton,
                p09_br_value = p09_br_value + rcd_fcst_extract_03.p09_ton,
                p10_br_value = p10_br_value + rcd_fcst_extract_03.p10_ton,
                p11_br_value = p11_br_value + rcd_fcst_extract_03.p11_ton,
                p12_br_value = p12_br_value + rcd_fcst_extract_03.p12_ton,
                p13_br_value = p13_br_value + rcd_fcst_extract_03.p13_ton,
                p14_br_value = p14_br_value + rcd_fcst_extract_03.p14_ton,
                p15_br_value = p15_br_value + rcd_fcst_extract_03.p15_ton,
                p16_br_value = p16_br_value + rcd_fcst_extract_03.p16_ton,
                p17_br_value = p17_br_value + rcd_fcst_extract_03.p17_ton,
                p18_br_value = p18_br_value + rcd_fcst_extract_03.p18_ton,
                p19_br_value = p19_br_value + rcd_fcst_extract_03.p19_ton,
                p20_br_value = p20_br_value + rcd_fcst_extract_03.p20_ton,
                p21_br_value = p21_br_value + rcd_fcst_extract_03.p21_ton,
                p22_br_value = p22_br_value + rcd_fcst_extract_03.p22_ton,
                p23_br_value = p23_br_value + rcd_fcst_extract_03.p23_ton,
                p24_br_value = p24_br_value + rcd_fcst_extract_03.p24_ton,
                p25_br_value = p25_br_value + rcd_fcst_extract_03.p25_ton,
                p26_br_value = p26_br_value + rcd_fcst_extract_03.p26_ton
          where company_code = rcd_fcst_extract_03.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_03.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_03.cust_code
            and matl_code = rcd_fcst_extract_03.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_03.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_03.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
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
                       par_data_segment,
                       rcd_fcst_extract_04.nzmkt_matl_group,
                       rcd_fcst_extract_04.cust_code,
                       rcd_fcst_extract_04.matl_zrep_code,
                       rcd_fcst_extract_04.acct_assgnmnt_grp_code,
                       rcd_fcst_extract_04.demand_plng_grp_code,
                       'N');

         /*-*/
         /* Update the data mart detail - QTY
         /*-*/
         update dw_mart_sales01_det
            set ptg_fcst_value = ptg_fcst_value + rcd_fcst_extract_04.ptg_qty,
                cpd_fcst_value = cpd_fcst_value + rcd_fcst_extract_04.ptg_qty,
                cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_qty,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_fcst_extract_04.ytg_qty,
                nyr_yee_fcst_value = nyr_yee_fcst_value + rcd_fcst_extract_04.nyr_qty,
                p01_fcst_value = p01_fcst_value + rcd_fcst_extract_04.p01_qty,
                p02_fcst_value = p02_fcst_value + rcd_fcst_extract_04.p02_qty,
                p03_fcst_value = p03_fcst_value + rcd_fcst_extract_04.p03_qty,
                p04_fcst_value = p04_fcst_value + rcd_fcst_extract_04.p04_qty,
                p05_fcst_value = p05_fcst_value + rcd_fcst_extract_04.p05_qty,
                p06_fcst_value = p06_fcst_value + rcd_fcst_extract_04.p06_qty,
                p07_fcst_value = p07_fcst_value + rcd_fcst_extract_04.p07_qty,
                p08_fcst_value = p08_fcst_value + rcd_fcst_extract_04.p08_qty,
                p09_fcst_value = p09_fcst_value + rcd_fcst_extract_04.p09_qty,
                p10_fcst_value = p10_fcst_value + rcd_fcst_extract_04.p10_qty,
                p11_fcst_value = p11_fcst_value + rcd_fcst_extract_04.p11_qty,
                p12_fcst_value = p12_fcst_value + rcd_fcst_extract_04.p12_qty,
                p13_fcst_value = p13_fcst_value + rcd_fcst_extract_04.p13_qty,
                p14_fcst_value = p14_fcst_value + rcd_fcst_extract_04.p14_qty,
                p15_fcst_value = p15_fcst_value + rcd_fcst_extract_04.p15_qty,
                p16_fcst_value = p16_fcst_value + rcd_fcst_extract_04.p16_qty,
                p17_fcst_value = p17_fcst_value + rcd_fcst_extract_04.p17_qty,
                p18_fcst_value = p18_fcst_value + rcd_fcst_extract_04.p18_qty,
                p19_fcst_value = p19_fcst_value + rcd_fcst_extract_04.p19_qty,
                p20_fcst_value = p20_fcst_value + rcd_fcst_extract_04.p20_qty,
                p21_fcst_value = p21_fcst_value + rcd_fcst_extract_04.p21_qty,
                p22_fcst_value = p22_fcst_value + rcd_fcst_extract_04.p22_qty,
                p23_fcst_value = p23_fcst_value + rcd_fcst_extract_04.p23_qty,
                p24_fcst_value = p24_fcst_value + rcd_fcst_extract_04.p24_qty,
                p25_fcst_value = p25_fcst_value + rcd_fcst_extract_04.p25_qty,
                p26_fcst_value = p26_fcst_value + rcd_fcst_extract_04.p26_qty
          where company_code = rcd_fcst_extract_04.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_04.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_04.cust_code
            and matl_code = rcd_fcst_extract_04.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*QTY';

         /*-*/
         /* Update the data mart detail - GSV
         /*-*/
         update dw_mart_sales01_det
            set ptg_fcst_value = ptg_fcst_value + rcd_fcst_extract_04.ptg_gsv,
                cpd_fcst_value = cpd_fcst_value + rcd_fcst_extract_04.ptg_gsv,
                cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_gsv,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_fcst_extract_04.ytg_gsv,
                nyr_yee_fcst_value = nyr_yee_fcst_value + rcd_fcst_extract_04.nyr_gsv,
                p01_fcst_value = p01_fcst_value + rcd_fcst_extract_04.p01_gsv,
                p02_fcst_value = p02_fcst_value + rcd_fcst_extract_04.p02_gsv,
                p03_fcst_value = p03_fcst_value + rcd_fcst_extract_04.p03_gsv,
                p04_fcst_value = p04_fcst_value + rcd_fcst_extract_04.p04_gsv,
                p05_fcst_value = p05_fcst_value + rcd_fcst_extract_04.p05_gsv,
                p06_fcst_value = p06_fcst_value + rcd_fcst_extract_04.p06_gsv,
                p07_fcst_value = p07_fcst_value + rcd_fcst_extract_04.p07_gsv,
                p08_fcst_value = p08_fcst_value + rcd_fcst_extract_04.p08_gsv,
                p09_fcst_value = p09_fcst_value + rcd_fcst_extract_04.p09_gsv,
                p10_fcst_value = p10_fcst_value + rcd_fcst_extract_04.p10_gsv,
                p11_fcst_value = p11_fcst_value + rcd_fcst_extract_04.p11_gsv,
                p12_fcst_value = p12_fcst_value + rcd_fcst_extract_04.p12_gsv,
                p13_fcst_value = p13_fcst_value + rcd_fcst_extract_04.p13_gsv,
                p14_fcst_value = p14_fcst_value + rcd_fcst_extract_04.p14_gsv,
                p15_fcst_value = p15_fcst_value + rcd_fcst_extract_04.p15_gsv,
                p16_fcst_value = p16_fcst_value + rcd_fcst_extract_04.p16_gsv,
                p17_fcst_value = p17_fcst_value + rcd_fcst_extract_04.p17_gsv,
                p18_fcst_value = p18_fcst_value + rcd_fcst_extract_04.p18_gsv,
                p19_fcst_value = p19_fcst_value + rcd_fcst_extract_04.p19_gsv,
                p20_fcst_value = p20_fcst_value + rcd_fcst_extract_04.p20_gsv,
                p21_fcst_value = p21_fcst_value + rcd_fcst_extract_04.p21_gsv,
                p22_fcst_value = p22_fcst_value + rcd_fcst_extract_04.p22_gsv,
                p23_fcst_value = p23_fcst_value + rcd_fcst_extract_04.p23_gsv,
                p24_fcst_value = p24_fcst_value + rcd_fcst_extract_04.p24_gsv,
                p25_fcst_value = p25_fcst_value + rcd_fcst_extract_04.p25_gsv,
                p26_fcst_value = p26_fcst_value + rcd_fcst_extract_04.p26_gsv
          where company_code = rcd_fcst_extract_04.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_04.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_04.cust_code
            and matl_code = rcd_fcst_extract_04.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*GSV';

         /*-*/
         /* Update the data mart detail - TON
         /*-*/
         update dw_mart_sales01_det
            set ptg_fcst_value = ptg_fcst_value + rcd_fcst_extract_04.ptg_ton,
                cpd_fcst_value = cpd_fcst_value + rcd_fcst_extract_04.ptg_ton,
                cyr_ytg_fcst_value = cyr_ytg_fcst_value + rcd_fcst_extract_04.ytg_ton,
                cyr_yee_fcst_value = cyr_yee_fcst_value + rcd_fcst_extract_04.ytg_ton,
                nyr_yee_fcst_value = nyr_yee_fcst_value + rcd_fcst_extract_04.nyr_ton,
                p01_fcst_value = p01_fcst_value + rcd_fcst_extract_04.p01_ton,
                p02_fcst_value = p02_fcst_value + rcd_fcst_extract_04.p02_ton,
                p03_fcst_value = p03_fcst_value + rcd_fcst_extract_04.p03_ton,
                p04_fcst_value = p04_fcst_value + rcd_fcst_extract_04.p04_ton,
                p05_fcst_value = p05_fcst_value + rcd_fcst_extract_04.p05_ton,
                p06_fcst_value = p06_fcst_value + rcd_fcst_extract_04.p06_ton,
                p07_fcst_value = p07_fcst_value + rcd_fcst_extract_04.p07_ton,
                p08_fcst_value = p08_fcst_value + rcd_fcst_extract_04.p08_ton,
                p09_fcst_value = p09_fcst_value + rcd_fcst_extract_04.p09_ton,
                p10_fcst_value = p10_fcst_value + rcd_fcst_extract_04.p10_ton,
                p11_fcst_value = p11_fcst_value + rcd_fcst_extract_04.p11_ton,
                p12_fcst_value = p12_fcst_value + rcd_fcst_extract_04.p12_ton,
                p13_fcst_value = p13_fcst_value + rcd_fcst_extract_04.p13_ton,
                p14_fcst_value = p14_fcst_value + rcd_fcst_extract_04.p14_ton,
                p15_fcst_value = p15_fcst_value + rcd_fcst_extract_04.p15_ton,
                p16_fcst_value = p16_fcst_value + rcd_fcst_extract_04.p16_ton,
                p17_fcst_value = p17_fcst_value + rcd_fcst_extract_04.p17_ton,
                p18_fcst_value = p18_fcst_value + rcd_fcst_extract_04.p18_ton,
                p19_fcst_value = p19_fcst_value + rcd_fcst_extract_04.p19_ton,
                p20_fcst_value = p20_fcst_value + rcd_fcst_extract_04.p20_ton,
                p21_fcst_value = p21_fcst_value + rcd_fcst_extract_04.p21_ton,
                p22_fcst_value = p22_fcst_value + rcd_fcst_extract_04.p22_ton,
                p23_fcst_value = p23_fcst_value + rcd_fcst_extract_04.p23_ton,
                p24_fcst_value = p24_fcst_value + rcd_fcst_extract_04.p24_ton,
                p25_fcst_value = p25_fcst_value + rcd_fcst_extract_04.p25_ton,
                p26_fcst_value = p26_fcst_value + rcd_fcst_extract_04.p26_ton
          where company_code = rcd_fcst_extract_04.company_code
            and data_segment = par_data_segment
            and matl_group = rcd_fcst_extract_04.nzmkt_matl_group
            and ship_to_cust_code = rcd_fcst_extract_04.cust_code
            and matl_code = rcd_fcst_extract_04.matl_zrep_code
            and acct_assgnmnt_grp_code = rcd_fcst_extract_04.acct_assgnmnt_grp_code
            and demand_plng_grp_code = rcd_fcst_extract_04.demand_plng_grp_code
            and mfanz_icb_flag = 'N'
            and data_type = '*TON';

      end loop;
      close csr_fcst_extract_04;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_nzmkt_forecast;

   /*****************************************************/
   /* This procedure performs the create detail routine */
   /*****************************************************/
   procedure create_detail(par_company_code in varchar2,
                           par_data_segment in varchar2,
                           par_matl_group in varchar2,
                           par_ship_to_cust_code in varchar2,
                           par_matl_code in varchar2,
                           par_acct_assgnmnt_grp_code in varchar2,
                           par_demand_plng_grp_code in varchar2,
                           par_mfanz_icb_flag in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_data is
         select 'x'
           from dw_mart_sales01_det t01
          where t01.company_code = par_company_code
            and t01.data_segment = par_data_segment
            and t01.matl_group = par_matl_group
            and t01.ship_to_cust_code = par_ship_to_cust_code
            and t01.matl_code = par_matl_code
            and t01.acct_assgnmnt_grp_code = par_acct_assgnmnt_grp_code
            and t01.demand_plng_grp_code = par_demand_plng_grp_code
            and t01.mfanz_icb_flag = par_mfanz_icb_flag;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new detail rows when required
      /*-*/
      open csr_data;
      fetch csr_data into var_work;
      if csr_data%notfound then

         /*-*/
         /* Initialise the record
         /*-*/
         rcd_detail.company_code := par_company_code;
         rcd_detail.data_segment := par_data_segment;
         rcd_detail.matl_group := par_matl_group;
         rcd_detail.ship_to_cust_code := par_ship_to_cust_code;
         rcd_detail.matl_code := par_matl_code;
         rcd_detail.acct_assgnmnt_grp_code := par_acct_assgnmnt_grp_code;
         rcd_detail.demand_plng_grp_code := par_demand_plng_grp_code;
         rcd_detail.mfanz_icb_flag := par_mfanz_icb_flag;
         rcd_detail.data_type := null;
         rcd_detail.cdy_ord_value := 0;
         rcd_detail.cdy_inv_value := 0;
         rcd_detail.ptd_inv_value := 0;
         rcd_detail.ptw_inv_value := 0;
         rcd_detail.ptg_fcst_value := 0;
         rcd_detail.cpd_out_value := 0;
         rcd_detail.cpd_ord_value := 0;
         rcd_detail.cpd_inv_value := 0;
         rcd_detail.cpd_op_value := 0;
         rcd_detail.cpd_rob_value := 0;
         rcd_detail.cpd_br_value := 0;
         rcd_detail.cpd_brm1_value := 0;
         rcd_detail.cpd_brm2_value := 0;
         rcd_detail.cpd_fcst_value := 0;
         rcd_detail.fpd_out_value := 0;
         rcd_detail.fpd_ord_value := 0;
         rcd_detail.fpd_inv_value := 0;
         rcd_detail.lyr_cpd_inv_value := 0;
         rcd_detail.lyr_ytp_inv_value := 0;
         rcd_detail.lyr_yee_inv_value := 0;
         rcd_detail.lyrm1_yee_inv_value := 0;
         rcd_detail.lyrm2_yee_inv_value := 0;
         rcd_detail.cyr_ytp_inv_value := 0;
         rcd_detail.cyr_mat_inv_value := 0;
         rcd_detail.cyr_ytg_rob_value := 0;
         rcd_detail.cyr_ytg_br_value := 0;
         rcd_detail.cyr_ytg_fcst_value := 0;
         rcd_detail.cyr_yee_op_value := 0;
         rcd_detail.cyr_yee_rob_value := 0;
         rcd_detail.cyr_yee_br_value := 0;
         rcd_detail.cyr_yee_brm1_value := 0;
         rcd_detail.cyr_yee_brm2_value := 0;
         rcd_detail.cyr_yee_fcst_value := 0;
         rcd_detail.nyr_yee_br_value := 0;
         rcd_detail.nyr_yee_brm1_value := 0;
         rcd_detail.nyr_yee_brm2_value := 0;
         rcd_detail.nyr_yee_fcst_value := 0;
         rcd_detail.p01_lyr_value := 0;
         rcd_detail.p02_lyr_value := 0;
         rcd_detail.p03_lyr_value := 0;
         rcd_detail.p04_lyr_value := 0;
         rcd_detail.p05_lyr_value := 0;
         rcd_detail.p06_lyr_value := 0;
         rcd_detail.p07_lyr_value := 0;
         rcd_detail.p08_lyr_value := 0;
         rcd_detail.p09_lyr_value := 0;
         rcd_detail.p10_lyr_value := 0;
         rcd_detail.p11_lyr_value := 0;
         rcd_detail.p12_lyr_value := 0;
         rcd_detail.p13_lyr_value := 0;
         rcd_detail.p01_op_value := 0;
         rcd_detail.p02_op_value := 0;
         rcd_detail.p03_op_value := 0;
         rcd_detail.p04_op_value := 0;
         rcd_detail.p05_op_value := 0;
         rcd_detail.p06_op_value := 0;
         rcd_detail.p07_op_value := 0;
         rcd_detail.p08_op_value := 0;
         rcd_detail.p09_op_value := 0;
         rcd_detail.p10_op_value := 0;
         rcd_detail.p11_op_value := 0;
         rcd_detail.p12_op_value := 0;
         rcd_detail.p13_op_value := 0;
         rcd_detail.p01_rob_value := 0;
         rcd_detail.p02_rob_value := 0;
         rcd_detail.p03_rob_value := 0;
         rcd_detail.p04_rob_value := 0;
         rcd_detail.p05_rob_value := 0;
         rcd_detail.p06_rob_value := 0;
         rcd_detail.p07_rob_value := 0;
         rcd_detail.p08_rob_value := 0;
         rcd_detail.p09_rob_value := 0;
         rcd_detail.p10_rob_value := 0;
         rcd_detail.p11_rob_value := 0;
         rcd_detail.p12_rob_value := 0;
         rcd_detail.p13_rob_value := 0;
         rcd_detail.p01_br_value := 0;
         rcd_detail.p02_br_value := 0;
         rcd_detail.p03_br_value := 0;
         rcd_detail.p04_br_value := 0;
         rcd_detail.p05_br_value := 0;
         rcd_detail.p06_br_value := 0;
         rcd_detail.p07_br_value := 0;
         rcd_detail.p08_br_value := 0;
         rcd_detail.p09_br_value := 0;
         rcd_detail.p10_br_value := 0;
         rcd_detail.p11_br_value := 0;
         rcd_detail.p12_br_value := 0;
         rcd_detail.p13_br_value := 0;
         rcd_detail.p14_br_value := 0;
         rcd_detail.p15_br_value := 0;
         rcd_detail.p16_br_value := 0;
         rcd_detail.p17_br_value := 0;
         rcd_detail.p18_br_value := 0;
         rcd_detail.p19_br_value := 0;
         rcd_detail.p20_br_value := 0;
         rcd_detail.p21_br_value := 0;
         rcd_detail.p22_br_value := 0;
         rcd_detail.p23_br_value := 0;
         rcd_detail.p24_br_value := 0;
         rcd_detail.p25_br_value := 0;
         rcd_detail.p26_br_value := 0;
         rcd_detail.p01_brm1_value := 0;
         rcd_detail.p02_brm1_value := 0;
         rcd_detail.p03_brm1_value := 0;
         rcd_detail.p04_brm1_value := 0;
         rcd_detail.p05_brm1_value := 0;
         rcd_detail.p06_brm1_value := 0;
         rcd_detail.p07_brm1_value := 0;
         rcd_detail.p08_brm1_value := 0;
         rcd_detail.p09_brm1_value := 0;
         rcd_detail.p10_brm1_value := 0;
         rcd_detail.p11_brm1_value := 0;
         rcd_detail.p12_brm1_value := 0;
         rcd_detail.p13_brm1_value := 0;
         rcd_detail.p14_brm1_value := 0;
         rcd_detail.p15_brm1_value := 0;
         rcd_detail.p16_brm1_value := 0;
         rcd_detail.p17_brm1_value := 0;
         rcd_detail.p18_brm1_value := 0;
         rcd_detail.p19_brm1_value := 0;
         rcd_detail.p20_brm1_value := 0;
         rcd_detail.p21_brm1_value := 0;
         rcd_detail.p22_brm1_value := 0;
         rcd_detail.p23_brm1_value := 0;
         rcd_detail.p24_brm1_value := 0;
         rcd_detail.p25_brm1_value := 0;
         rcd_detail.p26_brm1_value := 0;
         rcd_detail.p01_brm2_value := 0;
         rcd_detail.p02_brm2_value := 0;
         rcd_detail.p03_brm2_value := 0;
         rcd_detail.p04_brm2_value := 0;
         rcd_detail.p05_brm2_value := 0;
         rcd_detail.p06_brm2_value := 0;
         rcd_detail.p07_brm2_value := 0;
         rcd_detail.p08_brm2_value := 0;
         rcd_detail.p09_brm2_value := 0;
         rcd_detail.p10_brm2_value := 0;
         rcd_detail.p11_brm2_value := 0;
         rcd_detail.p12_brm2_value := 0;
         rcd_detail.p13_brm2_value := 0;
         rcd_detail.p14_brm2_value := 0;
         rcd_detail.p15_brm2_value := 0;
         rcd_detail.p16_brm2_value := 0;
         rcd_detail.p17_brm2_value := 0;
         rcd_detail.p18_brm2_value := 0;
         rcd_detail.p19_brm2_value := 0;
         rcd_detail.p20_brm2_value := 0;
         rcd_detail.p21_brm2_value := 0;
         rcd_detail.p22_brm2_value := 0;
         rcd_detail.p23_brm2_value := 0;
         rcd_detail.p24_brm2_value := 0;
         rcd_detail.p25_brm2_value := 0;
         rcd_detail.p26_brm2_value := 0;
         rcd_detail.p01_fcst_value := 0;
         rcd_detail.p02_fcst_value := 0;
         rcd_detail.p03_fcst_value := 0;
         rcd_detail.p04_fcst_value := 0;
         rcd_detail.p05_fcst_value := 0;
         rcd_detail.p06_fcst_value := 0;
         rcd_detail.p07_fcst_value := 0;
         rcd_detail.p08_fcst_value := 0;
         rcd_detail.p09_fcst_value := 0;
         rcd_detail.p10_fcst_value := 0;
         rcd_detail.p11_fcst_value := 0;
         rcd_detail.p12_fcst_value := 0;
         rcd_detail.p13_fcst_value := 0;
         rcd_detail.p14_fcst_value := 0;
         rcd_detail.p15_fcst_value := 0;
         rcd_detail.p16_fcst_value := 0;
         rcd_detail.p17_fcst_value := 0;
         rcd_detail.p18_fcst_value := 0;
         rcd_detail.p19_fcst_value := 0;
         rcd_detail.p20_fcst_value := 0;
         rcd_detail.p21_fcst_value := 0;
         rcd_detail.p22_fcst_value := 0;
         rcd_detail.p23_fcst_value := 0;
         rcd_detail.p24_fcst_value := 0;
         rcd_detail.p25_fcst_value := 0;
         rcd_detail.p26_fcst_value := 0;

         /*-*/
         /* Data type QTY
         /*-*/
         rcd_detail.data_type := '*QTY';
         insert into dw_mart_sales01_det values rcd_detail;

         /*-*/
         /* Data type GSV
         /*-*/
         rcd_detail.data_type := '*GSV';
         insert into dw_mart_sales01_det values rcd_detail;

         /*-*/
         /* Data type TON
         /*-*/
         rcd_detail.data_type := '*TON';
         insert into dw_mart_sales01_det values rcd_detail;

      end if;
      close csr_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_detail;

end dw_mart_sales01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_mart_sales01 for dw_app.dw_mart_sales01;
grant execute on dw_mart_sales01 to public;