/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_cdwics01
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Interface Control System - cdwics01 - Inbound Sales Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_cdwics01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_cdwics01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_cdwics01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_sale_cdw_gsv_load sale_cdw_gsv_load%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Attempt to lock the sales load table in exclusive mode
      /*-*/
      begin
         lock table sale_cdw_gsv_load in exclusive mode nowait;
      exception
         when others then
            lics_inbound_utility.add_exception('Unable to lock the sales load table (sale_cdw_gsv_load) interface rejected');
            var_trn_ignore := true;
      end;
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('DAT','ID_CODE',3);
      lics_inbound_utility.set_definition('DAT','SO_CODE',4);
      lics_inbound_utility.set_definition('DAT','DI_CODE',2);
      lics_inbound_utility.set_definition('DAT','DC_CODE',2);
      lics_inbound_utility.set_definition('DAT','PL_CODE',4);
      lics_inbound_utility.set_definition('DAT','YYYYPPW',7);
      lics_inbound_utility.set_definition('DAT','YYYYPP',6);
      lics_inbound_utility.set_definition('DAT','MA_CODE',18);
      lics_inbound_utility.set_definition('DAT','CU_CODE',10);
      lics_inbound_utility.set_definition('DAT','MC_GSV',16);
      lics_inbound_utility.set_definition('DAT','AD_GSV',16);
      lics_inbound_utility.set_definition('DAT','BUOM_QTY',6);
      lics_inbound_utility.set_definition('DAT','GW_TONNES',14);

      /*-*/
      /* Truncate the load table
      /*-*/
      sale_truncate_table.trunc_sale_cdw_gsv_load;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore the data row when required
      /*-*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('DAT', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sale_cdw_gsv_load.sales_org_code := lics_inbound_utility.get_variable('SO_CODE');
      rcd_sale_cdw_gsv_load.division_code := lics_inbound_utility.get_variable('DI_CODE');
      rcd_sale_cdw_gsv_load.distbn_chnl_code := lics_inbound_utility.get_variable('DC_CODE');
      rcd_sale_cdw_gsv_load.plant_code := lics_inbound_utility.get_variable('PL_CODE');
      rcd_sale_cdw_gsv_load.billing_yyyyppw := lics_inbound_utility.get_variable('YYYYPPW');
      rcd_sale_cdw_gsv_load.billing_yyyypp := lics_inbound_utility.get_variable('YYYYPP');
      rcd_sale_cdw_gsv_load.matl_code := lics_inbound_utility.get_variable('MA_CODE');
      rcd_sale_cdw_gsv_load.sold_to_cust_code := lics_inbound_utility.get_variable('CU_CODE');
      rcd_sale_cdw_gsv_load.mkt_cur_gsv := lics_inbound_utility.get_number('MC_GSV',null);
      rcd_sale_cdw_gsv_load.aud_cur_gsv := lics_inbound_utility.get_number('AD_GSV',null);
      rcd_sale_cdw_gsv_load.qty_buom_invcd := lics_inbound_utility.get_number('BUOM_QTY',null);
      rcd_sale_cdw_gsv_load.gross_wght_tonnes := lics_inbound_utility.get_number('GW_TONNES',null);

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Insert the table row
      /*-*/
      insert into sale_cdw_gsv_load
         (sales_org_code,
          division_code,
          distbn_chnl_code,
          plant_code,
          billing_yyyyppw,
          billing_yyyypp,
          matl_code,
          sold_to_cust_code,
          mkt_cur_gsv,
          aud_cur_gsv,
          qty_buom_invcd,
          gross_wght_tonnes)
      values
         (rcd_sale_cdw_gsv_load.sales_org_code,
          rcd_sale_cdw_gsv_load.division_code,
          rcd_sale_cdw_gsv_load.distbn_chnl_code,
          rcd_sale_cdw_gsv_load.plant_code,
          rcd_sale_cdw_gsv_load.billing_yyyyppw,
          rcd_sale_cdw_gsv_load.billing_yyyypp,
          rcd_sale_cdw_gsv_load.matl_code,
          rcd_sale_cdw_gsv_load.sold_to_cust_code,
          rcd_sale_cdw_gsv_load.mkt_cur_gsv,
          rcd_sale_cdw_gsv_load.aud_cur_gsv,
          rcd_sale_cdw_gsv_load.qty_buom_invcd,
          rcd_sale_cdw_gsv_load.gross_wght_tonnes);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback the data as required
      /*
      /* **notes**
      /* 1. Truncate the data table
      /* 2. Copy the load table to the data table
      /* 3. Truncate the load table 
      /*-*/
      if var_trn_ignore = true or
         var_trn_error = true then
         rollback;
      else
         sale_truncate_table.trunc_sale_cdw_gsv;
         insert into sale_cdw_gsv (select * from sale_cdw_gsv_load);
         sale_truncate_table.trunc_sale_cdw_gsv_load;
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end ics_cdwics01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
drop public synonym ics_cdwics01;
create public synonym ics_cdwics01 for ics_app.ics_cdwics01;
grant execute on ics_cdwics01 to lics_app;
