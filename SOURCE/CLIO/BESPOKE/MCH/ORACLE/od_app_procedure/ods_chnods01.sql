CREATE OR REPLACE package ods_chnods01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_chnods01;

/


CREATE OR REPLACE package body ods_chnods01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_cast_type varchar2(3);
   rcd_fcst fcst_month%rowtype;

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
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','FCST_TYPE',3);
      lics_inbound_utility.set_definition('HDR','PRC_TYPE',8);
      lics_inbound_utility.set_definition('HDR','CAST_TYPE',3);
      lics_inbound_utility.set_definition('HDR','CAST_YYYYXX',6);
      lics_inbound_utility.set_definition('HDR','SALES_ORG',4);
      lics_inbound_utility.set_definition('HDR','DISTBN_CHNL',2);
      lics_inbound_utility.set_definition('HDR','DVSN_CODE',2);
      lics_inbound_utility.set_definition('HDR','DIV_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','DIV_SALES_ORG',4);
      lics_inbound_utility.set_definition('HDR','DIV_DISTBN_CHNL',2);
      lics_inbound_utility.set_definition('HDR','DIV_DVSN',2);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','FCST_YYYYXX',6);
      lics_inbound_utility.set_definition('DET','MATERIAL',18);
      lics_inbound_utility.set_definition('DET','FCST_VALUE',19);
      lics_inbound_utility.set_definition('DET','FCST_QTY',12);


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
         when 'HDR' then process_record_hdr(par_record);
         when 'DET' then process_record_det(par_record);
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

      /*-*/
      /* Local definitions
      /*-*/
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_month_01 is
         select 'x'
         from fcst_month a
         where a.fcst_type_code = rcd_fcst.fcst_type_code
           and a.fcst_price_type_code = rcd_fcst.fcst_price_type_code
           and a.casting_yyyymm = rcd_fcst.casting_yyyymm
           and a.sap_sales_dtl_sales_org_code = rcd_fcst.sap_sales_dtl_sales_org_code
           and a.sap_sales_dtl_distbn_chnl_code = rcd_fcst.sap_sales_dtl_distbn_chnl_code
           and a.sap_sales_dtl_division_code = rcd_fcst.sap_sales_dtl_division_code
           and nvl(a.sap_sales_div_cust_code,'x') = nvl(rcd_fcst.sap_sales_div_cust_code,'x')
           and nvl(a.sap_sales_div_sales_org_code,'x') = nvl(rcd_fcst.sap_sales_div_sales_org_code,'x')
           and nvl(a.sap_sales_div_distbn_chnl_code,'x') = nvl(rcd_fcst.sap_sales_div_distbn_chnl_code,'x')
           and nvl(a.sap_sales_div_division_code,'x') = nvl(rcd_fcst.sap_sales_div_division_code,'x');
      rcd_fcst_month_01 csr_fcst_month_01%rowtype;

      cursor csr_fcst_period_01 is
         select 'x'
         from fcst_period a
         where a.fcst_type_code = rcd_fcst.fcst_type_code
           and a.fcst_price_type_code = rcd_fcst.fcst_price_type_code
           and a.casting_yyyypp = rcd_fcst.casting_yyyymm
           and a.sap_sales_dtl_sales_org_code = rcd_fcst.sap_sales_dtl_sales_org_code
           and a.sap_sales_dtl_distbn_chnl_code = rcd_fcst.sap_sales_dtl_distbn_chnl_code
           and a.sap_sales_dtl_division_code = rcd_fcst.sap_sales_dtl_division_code
           and nvl(a.sap_sales_div_cust_code,'x') = nvl(rcd_fcst.sap_sales_div_cust_code,'x')
           and nvl(a.sap_sales_div_sales_org_code,'x') = nvl(rcd_fcst.sap_sales_div_sales_org_code,'x')
           and nvl(a.sap_sales_div_distbn_chnl_code,'x') = nvl(rcd_fcst.sap_sales_div_distbn_chnl_code,'x')
           and nvl(a.sap_sales_div_division_code,'x') = nvl(rcd_fcst.sap_sales_div_division_code,'x');
      rcd_fcst_period_01 csr_fcst_period_01%rowtype;

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

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);


      /*-*/
      /* Process the data based on the casting type (Month or Period based forecast)
      /*-*/
      var_cast_type := lics_inbound_utility.get_variable('CAST_TYPE');

      /*-*/
      /* Validate Casting Type
      /*   note : PRD = PERIOD forecast
      /*          MTH = MONTH forecast
      /*-*/
      if (upper(var_cast_type) != 'PRD' and
          upper(var_cast_type) != 'MTH') then
         raise_application_error(-20000, 'Casting Type (' || var_cast_type || ') not recognised - must be MTH or PRD');
      end if;

      rcd_fcst.fcst_type_code := lics_inbound_utility.get_number('FCST_TYPE',null);
      rcd_fcst.fcst_price_type_code := lics_inbound_utility.get_number('PRC_TYPE',null);
      rcd_fcst.casting_yyyymm := lics_inbound_utility.get_number('CAST_YYYYXX',null);
      rcd_fcst.sap_sales_dtl_sales_org_code := lics_inbound_utility.get_variable('SALES_ORG');
      rcd_fcst.sap_sales_dtl_distbn_chnl_code := lics_inbound_utility.get_variable('DISTBN_CHNL');
      rcd_fcst.sap_sales_dtl_division_code := lics_inbound_utility.get_variable('DVSN_CODE');
      rcd_fcst.sap_sales_div_cust_code := lics_inbound_utility.get_variable('DIV_CUST_CODE');
      rcd_fcst.sap_sales_div_sales_org_code := lics_inbound_utility.get_variable('DIV_SALES_ORG');
      rcd_fcst.sap_sales_div_distbn_chnl_code := lics_inbound_utility.get_variable('DIV_DISTBN_CHNL');
      rcd_fcst.sap_sales_div_division_code := lics_inbound_utility.get_variable('DIV_DVSN');

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
      /* Validate the required fields
      /*-*/
      if rcd_fcst.fcst_type_code is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.FCST_TYPE_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.fcst_price_type_code is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.FCST_PRICE_TYPE_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.casting_yyyymm is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.CASTING_YYYYxx');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.sap_sales_dtl_sales_org_code is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.SAP_SALES_DTL_SALES_ORG_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.sap_sales_dtl_distbn_chnl_code is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.SAP_SALES_DTL_DISTBN_CHNL_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.sap_sales_dtl_division_code is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.SAP_SALES_DTL_DIVISION_CODE');
         var_trn_error := true;
      end if;


      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_fcst.fcst_type_code is null) and
         not(rcd_fcst.fcst_price_type_code is null) and
         not(rcd_fcst.casting_yyyymm is null) and
         not(rcd_fcst.sap_sales_dtl_sales_org_code is null) and
         not(rcd_fcst.sap_sales_dtl_distbn_chnl_code is null) and
         not(rcd_fcst.sap_sales_dtl_division_code is null) then
         var_exists := true;

         if (var_cast_type = 'MTH') then

            open csr_fcst_month_01;
            fetch csr_fcst_month_01 into rcd_fcst_month_01;
            if csr_fcst_month_01%notfound then
               var_exists := false;
            end if;
            close csr_fcst_month_01;


            if var_exists = true then
               delete from fcst_month a where a.fcst_type_code = rcd_fcst.fcst_type_code
                                          and a.fcst_price_type_code = rcd_fcst.fcst_price_type_code
                                          and a.casting_yyyymm = rcd_fcst.casting_yyyymm
                                          and a.sap_sales_dtl_sales_org_code = rcd_fcst.sap_sales_dtl_sales_org_code
                                          and a.sap_sales_dtl_distbn_chnl_code = rcd_fcst.sap_sales_dtl_distbn_chnl_code
                                          and a.sap_sales_dtl_division_code = rcd_fcst.sap_sales_dtl_division_code
                                          and nvl(a.sap_sales_div_cust_code,'x') = nvl(rcd_fcst.sap_sales_div_cust_code,'x')
                                          and nvl(a.sap_sales_div_sales_org_code,'x') = nvl(rcd_fcst.sap_sales_div_sales_org_code,'x')
                                          and nvl(a.sap_sales_div_distbn_chnl_code,'x') = nvl(rcd_fcst.sap_sales_div_distbn_chnl_code,'x')
                                          and nvl(a.sap_sales_div_division_code,'x') = nvl(rcd_fcst.sap_sales_div_division_code,'x');
            end if;

            /*-*/
            /* Retrieve Maximum sequence number
            /*-*/
            select nvl(max(fcst_month_code),0)
            into rcd_fcst.fcst_month_code
            from fcst_month;

         else

            open csr_fcst_period_01;
            fetch csr_fcst_period_01 into rcd_fcst_period_01;
            if csr_fcst_period_01%notfound then
               var_exists := false;
            end if;
            close csr_fcst_period_01;


            if var_exists = true then
               delete from fcst_period a where a.fcst_type_code = rcd_fcst.fcst_type_code
                                           and a.fcst_price_type_code = rcd_fcst.fcst_price_type_code
                                           and a.casting_yyyypp = rcd_fcst.casting_yyyymm
                                           and a.sap_sales_dtl_sales_org_code = rcd_fcst.sap_sales_dtl_sales_org_code
                                           and a.sap_sales_dtl_distbn_chnl_code = rcd_fcst.sap_sales_dtl_distbn_chnl_code
                                           and a.sap_sales_dtl_division_code = rcd_fcst.sap_sales_dtl_division_code
                                           and nvl(a.sap_sales_div_cust_code,'x') = nvl(rcd_fcst.sap_sales_div_cust_code,'x')
                                           and nvl(a.sap_sales_div_sales_org_code,'x') = nvl(rcd_fcst.sap_sales_div_sales_org_code,'x')
                                           and nvl(a.sap_sales_div_distbn_chnl_code,'x') = nvl(rcd_fcst.sap_sales_div_distbn_chnl_code,'x')
                                           and nvl(a.sap_sales_div_division_code,'x') = nvl(rcd_fcst.sap_sales_div_division_code,'x');
            end if;

            /*-*/
            /* Retrieve Maximum sequence number
            /*-*/
            select nvl(max(fcst_period_code),0)
            into rcd_fcst.fcst_month_code
            from fcst_period;

         end if;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

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
      rcd_fcst.fcst_yyyymm := lics_inbound_utility.get_number('FCST_YYYYXX',null);
      rcd_fcst.sap_material_code := lics_inbound_utility.get_variable('MATERIAL');
      rcd_fcst.fcst_value := lics_inbound_utility.get_number('FCST_VALUE',null);
      rcd_fcst.fcst_qty := lics_inbound_utility.get_number('FCST_QTY',null);
      rcd_fcst.fcst_month_code := rcd_fcst.fcst_month_code+1;

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
      /* Validate the required fields
      /*-*/
      if rcd_fcst.fcst_yyyymm is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.FCST_YYYYxx');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.sap_material_code is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.SAP_MATERIAL_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.fcst_value is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.FCST_VALUE');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_fcst.fcst_qty is null then
         lics_inbound_utility.add_exception('Missing Required Field - FCST.FCST_QTY');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* INSERT - forecast records    */
      /*------------------------------*/
      if (var_cast_type = 'MTH') then

         insert into fcst_month
            (fcst_month_code,
             fcst_type_code,
             fcst_price_type_code,
             casting_yyyymm,
             fcst_yyyymm,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_sales_div_cust_code,
             sap_sales_div_sales_org_code,
             sap_sales_div_distbn_chnl_code,
             sap_sales_div_division_code,
             sap_material_code,
             fcst_value,
             fcst_qty,
             fcst_month_lupdp,
             fcst_month_lupdt)
         values
            (rcd_fcst.fcst_month_code,
             rcd_fcst.fcst_type_code,
             rcd_fcst.fcst_price_type_code,
             rcd_fcst.casting_yyyymm,
             rcd_fcst.fcst_yyyymm,
             rcd_fcst.sap_sales_dtl_sales_org_code,
             rcd_fcst.sap_sales_dtl_distbn_chnl_code,
             rcd_fcst.sap_sales_dtl_division_code,
             rcd_fcst.sap_sales_div_cust_code,
             rcd_fcst.sap_sales_div_sales_org_code,
             rcd_fcst.sap_sales_div_distbn_chnl_code,
             rcd_fcst.sap_sales_div_division_code,
             rcd_fcst.sap_material_code,
             rcd_fcst.fcst_value,
             rcd_fcst.fcst_qty,
             null,
             null);

      else

         insert into fcst_period
            (fcst_period_code,
             fcst_type_code,
             fcst_price_type_code,
             casting_yyyypp,
             fcst_yyyypp,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_sales_div_cust_code,
             sap_sales_div_sales_org_code,
             sap_sales_div_distbn_chnl_code,
             sap_sales_div_division_code,
             sap_material_code,
             fcst_value,
             fcst_qty,
             fcst_period_lupdp,
             fcst_period_lupdt)
         values
            (rcd_fcst.fcst_month_code,
             rcd_fcst.fcst_type_code,
             rcd_fcst.fcst_price_type_code,
             rcd_fcst.casting_yyyymm,
             rcd_fcst.fcst_yyyymm,
             rcd_fcst.sap_sales_dtl_sales_org_code,
             rcd_fcst.sap_sales_dtl_distbn_chnl_code,
             rcd_fcst.sap_sales_dtl_division_code,
             rcd_fcst.sap_sales_div_cust_code,
             rcd_fcst.sap_sales_div_sales_org_code,
             rcd_fcst.sap_sales_div_distbn_chnl_code,
             rcd_fcst.sap_sales_div_division_code,
             rcd_fcst.sap_material_code,
             rcd_fcst.fcst_value,
             rcd_fcst.fcst_qty,
             null,
             null);

      end if;


   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end ods_chnods01;

/
