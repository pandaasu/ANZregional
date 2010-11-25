create or replace package ods_app.ods_dfnods01 as

/******************************************************************************
 System  : ODS
 Package : ods_dfnods01
 Owner   : ODS_APP
 Author  : ISI

 Description
 -----------
 Process the Demand Forecast Inbound Message File interfaced from the Demand
 Financials System and load into the following tables:
 - ods.fcst_hdr
 - ods.fcst_dtl

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/06   Kris Lee       This package is renamed from the original ODS_LEGODS02 package and
                          include modifications for the Snackfood rollout;
                          - Rename malt_code to malt_zrep_code
                          - Add matl_tdu_code and fcst_dtl_type_code columns
 2010/11   Steve Gregan   Added partitioning to the forecast detail table
********************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_dfnods01;
/

create or replace package body ods_app.ods_dfnods01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_rec(par_record in varchar2);
   procedure process_record_gsv(par_record in varchar2);
   procedure process_record_qty(par_record in varchar2);
   procedure delete_previous_forecast;
   procedure update_previous_forecast;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_batch_code number;
   var_fcst_hdr_code number;
   var_fcst_dtl_code number;
   var_record_count number;
   var_gsv number;
   var_qty number;
   rcd_ods_control ods_definition.idoc_control;
   rcd_fcst_hdr fcst_hdr%rowtype;
   rcd_fcst_dtl fcst_dtl%rowtype;
   var_loaded_record_count number;
   var_loaded_gsv number;
   var_loaded_qty number;

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
      var_trn_start := false;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','FCST_TYPE_CODE',4);
      lics_inbound_utility.set_definition('DET','FCST_VERSION',1);
      lics_inbound_utility.set_definition('DET','CASTING_YEAR',4);
      lics_inbound_utility.set_definition('DET','CASTING_PERIOD',2);
      lics_inbound_utility.set_definition('DET','CASTING_WEEK',1);
      lics_inbound_utility.set_definition('DET','DEMAND_PLNG_GRP_CODE',10);
      lics_inbound_utility.set_definition('DET','SALES_ORG_CODE',4);
      lics_inbound_utility.set_definition('DET','MOE_CODE',4);
      lics_inbound_utility.set_definition('DET','DISTBN_CHNL_CODE',2);
      lics_inbound_utility.set_definition('DET','DIVISION_CODE',2);
      lics_inbound_utility.set_definition('DET','CUST_CODE',10);
      lics_inbound_utility.set_definition('DET','REGION_CODE',3);
      lics_inbound_utility.set_definition('DET','CNTRY_CODE',3);
      lics_inbound_utility.set_definition('DET','MULTI_MKT_ACCT_CODE',30);
      lics_inbound_utility.set_definition('DET','BANNER_CODE',5);
      lics_inbound_utility.set_definition('DET','CUST_BUYING_GRP_CODE',30);
      lics_inbound_utility.set_definition('DET','POS_FORMAT_GRPG_CODE',30);
      lics_inbound_utility.set_definition('DET','DISTBN_ROUTE_CODE',3);
      lics_inbound_utility.set_definition('DET','ACCT_ASSGNMNT_GRP_CODE',2);
      lics_inbound_utility.set_definition('DET','MATL_ZREP_CODE',18);
      lics_inbound_utility.set_definition('DET','MATL_TDU_CODE',18);
      lics_inbound_utility.set_definition('DET','FCST_YEAR',4);
      lics_inbound_utility.set_definition('DET','FCST_PERIOD',2);
      lics_inbound_utility.set_definition('DET','FCST_WEEK',1);
      lics_inbound_utility.set_definition('DET','FCST_DTL_TYPE_CODE',1);
      lics_inbound_utility.set_definition('DET','FCST_VALUE',13);
      lics_inbound_utility.set_definition('DET','FCST_QTY',13);
      lics_inbound_utility.set_definition('DET','CURRCY_CODE',3);
      /*-*/
      lics_inbound_utility.set_definition('REC','IDOC_REC',3);
      lics_inbound_utility.set_definition('REC','VALUE',13);
      /*-*/
      lics_inbound_utility.set_definition('GSV','IDOC_GSV',3);
      lics_inbound_utility.set_definition('GSV','VALUE',13);
      /*-*/
      lics_inbound_utility.set_definition('QTY','IDOC_QTY',3);
      lics_inbound_utility.set_definition('QTY','VALUE',13);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'CTL' then process_record_ctl(par_record);
         when 'DET' then process_record_det(par_record);
         when 'REC' then process_record_rec(par_record);
         when 'GSV' then process_record_gsv(par_record);
         when 'QTY' then process_record_qty(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));

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
      /* Complete the transaction
      /*-*/
      complete_transaction;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when commited
      /*-*/
      if var_trn_ignore = true then
         rollback;
      elsif var_trn_start = true then
         if var_trn_error = true then
            rollback;
         else
            -- Update current_flg to N for previous sent forecast (same group and casting period/week as this)
            -- NOTE: Do this and include in the commit to avoid any error in delete section and can't rollback
            --       committed forecast.
            update_previous_forecast;
            -- Commit the insert and update first to avoid running out of rollback segment space
            commit;

            -- Now delete previous sent forecast with same group and casting period/week
            delete_previous_forecast;

            /*-*/
            /* Call the ODS_VALIDATION procedure.
            /*-*/
            begin
              lics_pipe.spray('*DAEMON','OV','*WAKE');
            exception
               when others then
                  lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
            end;

            /*-*/
            /* Call the interface monitor procedure.
            /*-*/
            begin
               ods_dfnods01_monitor.execute(rcd_fcst_hdr.fcst_type_code,
                                            rcd_fcst_hdr.fcst_version,
                                            rcd_fcst_hdr.company_code,
                                            rcd_fcst_hdr.sales_org_code,
                                            rcd_fcst_hdr.moe_code,
                                            rcd_fcst_hdr.distbn_chnl_code,
                                            rcd_fcst_hdr.division_code,
                                            rcd_fcst_hdr.casting_year,
                                            rcd_fcst_hdr.casting_period);

      		exception
               when others then
                  lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
            end;

         end if;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/

      /*-*/
      /* Retrieve the next sequence number, which is used for batch code
      /*-*/
      cursor csr_fcst_batch_seq is
         select fcst_batch_seq.nextval as batch_code
         from dual;
      rcd_fcst_batch_seq csr_fcst_batch_seq%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      var_loaded_record_count := 0;
      var_loaded_gsv := 0;
      var_loaded_qty := 0;

      /*-*/
      /* Set the batch code for the received forecast file
      /*-*/
      open csr_fcst_batch_seq;
      fetch csr_fcst_batch_seq into rcd_fcst_batch_seq;
      if csr_fcst_batch_seq%notfound then
         lics_inbound_utility.add_exception('Unable to retrieve sequence number - FCST_BATCH_SEQ');
         var_trn_error := true;
      else
         var_batch_code := rcd_fcst_batch_seq.batch_code;
      end if;
      close csr_fcst_batch_seq;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Extract and validate the control IDOC name
      /*-*/
      rcd_ods_control.idoc_name := lics_inbound_utility.get_variable('IDOC_NAME');
      if rcd_ods_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_ods_control.idoc_number := lics_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_ods_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_ods_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_DATE') || lics_inbound_utility.get_variable('IDOC_TIME');
      if rcd_ods_control.idoc_timestamp is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_TIMESTAMP - Must not be null');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/

      /*-*/
      /* Check whether forecast header record has already been inserted in the fcst_hdr table
      /*-*/
      cursor csr_fcst_hdr_02 is
         select t01.fcst_hdr_code
         from fcst_hdr t01
         where t01.fcst_type_code = rcd_fcst_hdr.fcst_type_code
           and t01.fcst_version = rcd_fcst_hdr.fcst_version
           and t01.company_code = rcd_fcst_hdr.company_code
           and t01.sales_org_code = rcd_fcst_hdr.sales_org_code
           and t01.moe_code = rcd_fcst_hdr.moe_code
           and t01.distbn_chnl_code = rcd_fcst_hdr.distbn_chnl_code
           and ((t01.division_code = rcd_fcst_hdr.division_code) OR
                 t01.division_code IS NULL AND rcd_fcst_hdr.division_code IS NULL)
           and t01.casting_year = rcd_fcst_hdr.casting_year
           and t01.casting_period = rcd_fcst_hdr.casting_period
           and ((t01.casting_week = rcd_fcst_hdr.casting_week) OR
                 t01.casting_week IS NULL AND rcd_fcst_hdr.casting_week IS NULL)
           and t01.batch_code = var_batch_code;
      rcd_fcst_hdr_02 csr_fcst_hdr_02%rowtype;

      /*-*/
      /* Retrieve the next sequence number, which is used for fcst_hdr_code
      /*-*/
      cursor csr_fcst_hdr_seq is
         select fcst_hdr_seq.nextval as fcst_hdr_code
         from dual;
      rcd_fcst_hdr_seq csr_fcst_hdr_seq%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_fcst_hdr.fcst_type_code := lics_inbound_utility.get_variable('FCST_TYPE_CODE');
      rcd_fcst_hdr.fcst_version := lics_inbound_utility.get_variable('FCST_VERSION');
      rcd_fcst_hdr.company_code := lics_inbound_utility.get_variable('SALES_ORG_CODE');
      rcd_fcst_hdr.sales_org_code := lics_inbound_utility.get_variable('SALES_ORG_CODE');
      rcd_fcst_hdr.moe_code := lics_inbound_utility.get_variable('MOE_CODE');
      rcd_fcst_hdr.distbn_chnl_code := lics_inbound_utility.get_variable('DISTBN_CHNL_CODE');
      rcd_fcst_hdr.division_code := lics_inbound_utility.get_variable('DIVISION_CODE');
      rcd_fcst_hdr.casting_year := lics_inbound_utility.get_variable('CASTING_YEAR');
      rcd_fcst_hdr.casting_period := lics_inbound_utility.get_variable('CASTING_PERIOD');
      rcd_fcst_hdr.casting_week := lics_inbound_utility.get_variable('CASTING_WEEK');
      rcd_fcst_hdr.current_fcst_flag := ods_constants.fcst_current_fcst_flag_yes;
      rcd_fcst_hdr.valdtn_status := ods_constants.valdtn_unchecked;
      /*-*/
      rcd_fcst_dtl.fcst_year := lics_inbound_utility.get_variable('FCST_YEAR');
      rcd_fcst_dtl.fcst_period := lics_inbound_utility.get_variable('FCST_PERIOD');
      rcd_fcst_dtl.fcst_week := lics_inbound_utility.get_variable('FCST_WEEK');
      rcd_fcst_dtl.demand_plng_grp_code:= lics_inbound_utility.get_variable('DEMAND_PLNG_GRP_CODE');
      rcd_fcst_dtl.cntry_code := lics_inbound_utility.get_variable('CNTRY_CODE');
      rcd_fcst_dtl.region_code := lics_inbound_utility.get_variable('REGION_CODE');
      rcd_fcst_dtl.multi_mkt_acct_code := lics_inbound_utility.get_variable('MULTI_MKT_ACCT_CODE');
      rcd_fcst_dtl.banner_code := lics_inbound_utility.get_variable('BANNER_CODE');
      rcd_fcst_dtl.cust_buying_grp_code := lics_inbound_utility.get_variable('CUST_BUYING_GRP_CODE');
      rcd_fcst_dtl.acct_assgnmnt_grp_code := lics_inbound_utility.get_variable('ACCT_ASSGNMNT_GRP_CODE');
      rcd_fcst_dtl.pos_format_grpg_code := lics_inbound_utility.get_variable('POS_FORMAT_GRPG_CODE');
      rcd_fcst_dtl.distbn_route_code := lics_inbound_utility.get_variable('DISTBN_ROUTE_CODE');
      rcd_fcst_dtl.cust_code := lics_inbound_utility.get_variable('CUST_CODE');
      rcd_fcst_dtl.matl_zrep_code := lics_inbound_utility.get_variable('MATL_ZREP_CODE');
      rcd_fcst_dtl.matl_tdu_code := lics_inbound_utility.get_variable('MATL_TDU_CODE');
      rcd_fcst_dtl.fcst_dtl_type_code := lics_inbound_utility.get_variable('FCST_DTL_TYPE_CODE');
      rcd_fcst_dtl.currcy_code := lics_inbound_utility.get_variable('CURRCY_CODE');
      rcd_fcst_dtl.fcst_value := lics_inbound_utility.get_variable('FCST_VALUE');
      rcd_fcst_dtl.fcst_qty := lics_inbound_utility.get_variable('FCST_QTY');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_fcst_hdr.fcst_type_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_TYPE_CODE');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.fcst_version is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_VERSION');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.company_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.COMPANY_CODE');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.sales_org_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.SALES_ORG_CODE');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.moe_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.MOE_CODE');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.distbn_chnl_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.DISTBN_CHNL_CODE');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.casting_year is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.CASTING_YEAR');
         var_trn_error := true;
      end if;
      if rcd_fcst_hdr.casting_period is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.CASTING_PERIOD');
         var_trn_error := true;
      end if;
      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      /*-*/
      /* Check whether the forecast header record is to be inserted into the fcst_hdr table
      /*-*/
      var_exists := true;
      open csr_fcst_hdr_02;
      fetch csr_fcst_hdr_02 into rcd_fcst_hdr_02;
      if csr_fcst_hdr_02%notfound then
         var_exists := false;
      end if;
      close csr_fcst_hdr_02;
      /*-*/
      /* If the forecast header record does not already exist in the fcst_hdr table then insert
      /*-*/
      if var_exists = false then

         /*-*/
         /* Obtain the next sequence number for fcst_hdr_code
         /*-*/
         open csr_fcst_hdr_seq;
         fetch csr_fcst_hdr_seq into rcd_fcst_hdr_seq;
         if csr_fcst_hdr_seq%notfound then
            lics_inbound_utility.add_exception('Unable to retrieve sequence number - FCST_HDR_SEQ');
            var_trn_error := true;
         else
            var_fcst_hdr_code := rcd_fcst_hdr_seq.fcst_hdr_code;
         end if;
         close csr_fcst_hdr_seq;

         /*----------------------------------------*/
         /* ERROR- Bypass the update when required */
         /*----------------------------------------*/
         if var_trn_error = true then
            return;
         end if;

         /*-*/
         /* Insert the new forecast header record into the fcst_hdr table
         /*-*/
         insert into fcst_hdr
            (fcst_hdr_code,
             fcst_type_code,
             fcst_version,
             company_code,
             sales_org_code,
             moe_code,
             distbn_chnl_code,
             division_code,
             casting_year,
             casting_period,
             casting_week,
             current_fcst_flag,
             valdtn_status,
             batch_code)
          values
             (var_fcst_hdr_code,
              rcd_fcst_hdr.fcst_type_code,
              rcd_fcst_hdr.fcst_version,
              rcd_fcst_hdr.company_code,
              rcd_fcst_hdr.sales_org_code,
              rcd_fcst_hdr.moe_code,
              rcd_fcst_hdr.distbn_chnl_code,
              rcd_fcst_hdr.division_code,
              rcd_fcst_hdr.casting_year,
              rcd_fcst_hdr.casting_period,
              rcd_fcst_hdr.casting_week,
              rcd_fcst_hdr.current_fcst_flag,
              rcd_fcst_hdr.valdtn_status,
              var_batch_code);

         /*-*/
         /* Create the forecast detail partition
         /*-*/
         ods_partition.check_create_list('fcst_dtl','F'||to_char(fcst_hdr_code),to_char(fcst_hdr_code));

      else

        /*-*/
        /* The forecast header record already exists in the fcst_hdr table, therefore retrieve
        /* the fcst_hdr_code, which is used for the insert into the fcst_dtl table
        /*-*/
        var_fcst_hdr_code := rcd_fcst_hdr_02.fcst_hdr_code;

      end if;

      /*-*/
      /* Insert the forecast detail record into the fcst_dtl table
      /*-*/
      insert into fcst_dtl
         (fcst_hdr_code,
          fcst_dtl_code,
          fcst_year,
          fcst_period,
          fcst_week,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          fcst_dtl_type_code,
          currcy_code,
          fcst_value,
          fcst_qty,
          batch_code,
          fcst_dtl_lupdp,
          fcst_dtl_lupdt)
      values
         (var_fcst_hdr_code,
          fcst_dtl_seq.nextval,
          rcd_fcst_dtl.fcst_year,
          rcd_fcst_dtl.fcst_period,
          rcd_fcst_dtl.fcst_week,
          rcd_fcst_dtl.demand_plng_grp_code,
          rcd_fcst_dtl.cntry_code,
          rcd_fcst_dtl.region_code,
          rcd_fcst_dtl.multi_mkt_acct_code,
          rcd_fcst_dtl.banner_code,
          rcd_fcst_dtl.cust_buying_grp_code,
          rcd_fcst_dtl.acct_assgnmnt_grp_code,
          rcd_fcst_dtl.pos_format_grpg_code,
          rcd_fcst_dtl.distbn_route_code,
          rcd_fcst_dtl.cust_code,
          rcd_fcst_dtl.matl_zrep_code,
          rcd_fcst_dtl.matl_tdu_code,
          rcd_fcst_dtl.fcst_dtl_type_code,
          rcd_fcst_dtl.currcy_code,
          rcd_fcst_dtl.fcst_value,
          rcd_fcst_dtl.fcst_qty,
          var_batch_code,
          user,
          sysdate);

      -- Accumulate the result to compare rather than summing from database to improve the performance
      var_loaded_record_count := var_loaded_record_count + 1;
      var_loaded_gsv := var_loaded_gsv + rcd_fcst_dtl.fcst_value;
      var_loaded_qty := var_loaded_qty + rcd_fcst_dtl.fcst_qty;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record REC routine */
   /**************************************************/
   procedure process_record_rec(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('REC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_record_count := lics_inbound_utility.get_variable('VALUE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_rec;

   /**************************************************/
   /* This procedure performs the record GSV routine */
   /**************************************************/
   procedure process_record_gsv(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('GSV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_gsv := lics_inbound_utility.get_variable('VALUE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gsv;

   /**************************************************/
   /* This procedure performs the record QTY routine */
   /**************************************************/
   procedure process_record_qty(par_record in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/

      /*-*/
      /* Select reconciliation values from the fcst_dtl table
      /*-*/
      cursor csr_reconcile is
         select
            count(*) as fcst_dtl_record_count,
            sum(t02.fcst_value) as fcst_dtl_gsv,
            sum(t02.fcst_qty) as fcst_dtl_qty
         from
            fcst_hdr t01,
            fcst_dtl t02
         where t01.fcst_hdr_code = t02.fcst_hdr_code
           and t01.batch_code = var_batch_code;
      rcd_reconcile csr_reconcile%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('QTY', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_qty := lics_inbound_utility.get_variable('VALUE');


      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
        var_trn_error := true;
      end if;

      -- Check whether there is a difference between the footer values and the received forecast file
      if var_loaded_record_count <> var_record_count or
         var_loaded_gsv <> var_gsv or
         var_loaded_qty <> var_qty then

         /*-*/
         /* Update the current_fcst_flag field to 'I' (INVALID) for each of the forecast
         /* header records loaded
         /*-*/

         update fcst_hdr
         set current_fcst_flag = ods_constants.fcst_current_fcst_flag_invalid
         where batch_code = var_batch_code;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_qty;

   /**************************************************/
   /* This procedure performs delete old record */
   /**************************************************/
   procedure delete_previous_forecast is

      /*-*/
      /* Local cursors
      /*-*/

      /*-*/
      /* Check whether forecast already exists
      /*-*/
      cursor csr_fcst_hdr_01 is
        select fcst_hdr_code
        from fcst_hdr t1
        where exists (select * from fcst_hdr t2
                      where
                        t1.fcst_type_code = t2.fcst_type_code
                        and t1.company_code = t2.company_code
                        and t1.moe_code = t2.moe_code
                        and t1.sales_org_code = t2.sales_org_code
                        and t1.distbn_chnl_code = t2.distbn_chnl_code
                        and (t1.division_code = t2.division_code or (t1.division_code is null and t2.division_code is null))
                        and t1.casting_year = t2.casting_year
                        and t1.casting_period = t2.casting_period
                        and (t1.casting_week = t2.casting_week or (t1.casting_week is null and t2.casting_week is null))
                        and batch_code = var_batch_code)
         and batch_code <> var_batch_code;
      rcd_fcst_hdr_01 csr_fcst_hdr_01%rowtype;

   begin
     open csr_fcst_hdr_01;
     fetch csr_fcst_hdr_01 into rcd_fcst_hdr_01;
     while csr_fcst_hdr_01%found loop

         /*-*/
         /* Drop the forecast detail partition
         /*-*/
         ods_partition.drop_list('fcst_dtl','F'||to_char(rcd_fcst_hdr_01.fcst_hdr_code));


        -- Delete old version of forecast from forecast header
        delete from fcst_hdr
         where fcst_hdr_code = rcd_fcst_hdr_01.fcst_hdr_code;

        fetch csr_fcst_hdr_01 into rcd_fcst_hdr_01;
     end loop;
     close csr_fcst_hdr_01;
     -- Commit
     commit;

   exception
     when others then
        rollback;
        lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));

   END delete_previous_forecast;

   /***************************************************************************/
   /* This procedure performs update the current flag of the old record first */
   /***************************************************************************/
   procedure update_previous_forecast IS

   begin
     update fcst_hdr t1
     set current_fcst_flag = 'N'
     where exists (select *
                   from fcst_hdr t2
                   where
                     t1.fcst_type_code = t2.fcst_type_code
                     and t1.company_code = t2.company_code
                     and t1.moe_code = t2.moe_code
                     and t1.sales_org_code = t2.sales_org_code
                     and t1.distbn_chnl_code = t2.distbn_chnl_code
                     and (t1.division_code = t2.division_code or (t1.division_code is null and t2.division_code is null))
                     and t1.casting_year = t2.casting_year
                     and t1.casting_period = t2.casting_period
                     and (t1.casting_week = t2.casting_week or (t1.casting_week is null and t2.casting_week is null))
                     and batch_code = var_batch_code)
        and batch_code <> var_batch_code
        and current_fcst_flag = 'Y';
      -- Don't commit here
   exception
     when others then
        lics_inbound_utility.add_exception(substr(sqlerrm, 1, 512));

   end update_previous_forecast;

end ods_dfnods01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_dfnods01 for ods_app.ods_dfnods01;
grant execute on ods_dfnods01 to lics_app;