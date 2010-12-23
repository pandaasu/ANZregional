/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : fcst_fact_converter
 Owner   : ods

 Description
 -----------
 FCST_FACT - Converter

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/12   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package fcst_fact_converter as

   /**/
   /* Public declarations
   /**/
   procedure execute;

end fcst_fact_converter;
/

/****************/
/* Package Body */
/****************/
create or replace package body fcst_fact_converter as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_size number(5,0);
      var_work number(5,0);
      var_exit boolean;
      type rcd_fcst_fact is table of fcst_fact%rowtype index by binary_integer;
      tab_fcst_fact rcd_fcst_fact;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is 
         select t01.*
           from fcst_fact t01;
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and load the bulk source array
      /*-*/
      var_size := 10000;
      var_work := 0;
      var_exit := false;
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            var_exit := true;
         end if;

         /*-*/
         /* Load the bulk arrays when required
         /*-*/
         if var_exit = false then
            var_work := var_work + 1;
            tab_fcst_fact(var_work).company_code := rcd_source.company_code;
            tab_fcst_fact(var_work).sales_org_code := rcd_source.sales_org_code;
            tab_fcst_fact(var_work).distbn_chnl_code := rcd_source.distbn_chnl_code;
            tab_fcst_fact(var_work).division_code := rcd_source.division_code;
            tab_fcst_fact(var_work).fcst_type_code := rcd_source.fcst_type_code;
            tab_fcst_fact(var_work).fcst_yyyypp := rcd_source.fcst_yyyypp;
            tab_fcst_fact(var_work).fcst_yyyyppw := rcd_source.fcst_yyyyppw;
            tab_fcst_fact(var_work).demand_plng_grp_code := rcd_source.demand_plng_grp_code;
            tab_fcst_fact(var_work).cntry_code := rcd_source.cntry_code;
            tab_fcst_fact(var_work).region_code := rcd_source.region_code;
            tab_fcst_fact(var_work).multi_mkt_acct_code := rcd_source.multi_mkt_acct_code;
            tab_fcst_fact(var_work).banner_code := rcd_source.banner_code;
            tab_fcst_fact(var_work).cust_buying_grp_code := rcd_source.cust_buying_grp_code;
            tab_fcst_fact(var_work).acct_assgnmnt_grp_code := rcd_source.acct_assgnmnt_grp_code;
            tab_fcst_fact(var_work).pos_format_grpg_code := rcd_source.pos_format_grpg_code;
            tab_fcst_fact(var_work).distbn_route_code := rcd_source.distbn_route_code;
            tab_fcst_fact(var_work).cust_code := rcd_source.cust_code;
            tab_fcst_fact(var_work).matl_zrep_code := rcd_source.matl_zrep_code;
            tab_fcst_fact(var_work).currcy_code := rcd_source.currcy_code;
            tab_fcst_fact(var_work).fcst_value := rcd_source.fcst_value;
            tab_fcst_fact(var_work).fcst_value_aud := rcd_source.fcst_value_aud;
            tab_fcst_fact(var_work).fcst_value_usd := rcd_source.fcst_value_usd;
            tab_fcst_fact(var_work).fcst_value_eur := rcd_source.fcst_value_eur;
            tab_fcst_fact(var_work).fcst_qty := rcd_source.fcst_qty;
            tab_fcst_fact(var_work).fcst_qty_gross_tonnes := rcd_source.fcst_qty_gross_tonnes;
            tab_fcst_fact(var_work).fcst_qty_net_tonnes := rcd_source.fcst_qty_net_tonnes;
            tab_fcst_fact(var_work).moe_code := rcd_source.moe_code;
            tab_fcst_fact(var_work).matl_tdu_code := rcd_source.matl_tdu_code;
            tab_fcst_fact(var_work).base_value := rcd_source.base_value;
            tab_fcst_fact(var_work).base_qty := rcd_source.base_qty;
            tab_fcst_fact(var_work).aggreg_mkt_actvty_value := rcd_source.aggreg_mkt_actvty_value;
            tab_fcst_fact(var_work).aggreg_mkt_actvty_qty := rcd_source.aggreg_mkt_actvty_qty;
            tab_fcst_fact(var_work).lock_value := rcd_source.lock_value;
            tab_fcst_fact(var_work).lock_qty := rcd_source.lock_qty;
            tab_fcst_fact(var_work).rcncl_value := rcd_source.rcncl_value;
            tab_fcst_fact(var_work).rcncl_qty := rcd_source.rcncl_qty;
            tab_fcst_fact(var_work).auto_adjmt_value := rcd_source.auto_adjmt_value;
            tab_fcst_fact(var_work).auto_adjmt_qty := rcd_source.auto_adjmt_qty;
            tab_fcst_fact(var_work).override_value := rcd_source.override_value;
            tab_fcst_fact(var_work).override_qty := rcd_source.override_qty;
            tab_fcst_fact(var_work).mkt_actvty_value := rcd_source.mkt_actvty_value;
            tab_fcst_fact(var_work).mkt_actvty_qty := rcd_source.mkt_actvty_qty;
            tab_fcst_fact(var_work).data_driven_event_value := rcd_source.data_driven_event_value;
            tab_fcst_fact(var_work).data_driven_event_qty := rcd_source.data_driven_event_qty;
            tab_fcst_fact(var_work).tgt_impact_value := rcd_source.tgt_impact_value;
            tab_fcst_fact(var_work).tgt_impact_qty := rcd_source.tgt_impact_qty;
            tab_fcst_fact(var_work).dfn_adjmt_value := rcd_source.dfn_adjmt_value;
            tab_fcst_fact(var_work).dfn_adjmt_qty := rcd_source.dfn_adjmt_qty;
         end if;

         /*-*/
         /* Insert the bulk target data when required
         /*-*/
         if (var_exit = false and var_work = var_size) or
            (var_exit = true and var_work > 0) then
            forall idx in 1..var_work
               insert into dds.fcst_fact_new values tab_fcst_fact(idx);
            commit;
            var_work := 0;
         end if;

         /*-*/
         /* Exit the loop when required
         /*-*/
         if var_exit = true then
            exit;
         end if;

      end loop;
      close csr_source;

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
         raise_application_error(-20000, 'FATAL ERROR - FCST_FACT - CONVERTER - EXECUTE Procedure -' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end fcst_fact_converter;
/  