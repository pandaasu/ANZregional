/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : cts_extract
 Owner   : ics_app

 Description
 -----------
 Cost To Serve - Extract

 This package contains the extract procedure for Cost To Serve. The package exposes
 one procedure EXECUTE that performs the extract based on the following parameters:

 1. PAR_DATA (*ALL, *DELIVERY, *MATERIAL, *CUSTOMER) (MANDATORY)

    *ALL extracts all data.
    *DELIVERY extracts delivery data.
    *MATERIAL extracts material data.
    *CUSTOMER extracts customer data.

 2. PAR_ACTION (*PERIOD_THIS, *PERIOD_LAST, *PERIOD_RANGE, *DATE_RANGE) (OPTIONAL)

    *PERIOD_THIS extracts delivery data for the current period.
    *PERIOD_LAST extracts delivery data for the previous period.
    *PERIOD_RANGE extracts delivery data for the period range.
    *DATE_RANGE extracts delivery data for the date range.

 3. PAR_STR_VALUE (period in string format (YYYYPP) or date in string format YYYYMMDD) (OPTIONAL)

    The starting period or date for which the extract is to be performed. Only required for
    PAR_ACTION = *PERIOD_RANGE or *DATE_RANGE

 4. PAR_END_VALUE (period in string format (YYYYPP) or date in string format YYYYMMDD) (OPTIONAL)

    The ending period or date for which the extract is to be performed. Only required for
    PAR_ACTION = *PERIOD_RANGE or *DATE_RANGE

 **notes**
 1. A web log is produced under the search value CTS_EXTRACT where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/05   Steve Gregan   Created
 2006/08   Steve Gregan   Modified for specification versions 1 to 20 (major upgrades)
 2007/06   Steve Gregan   Modified delivery line consolidation for material substitution

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package cts_extract as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_data in varchar2, par_action in varchar2, par_str_value in varchar2, par_end_value in varchar2);

end cts_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body cts_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_separator constant varchar2(1) := '|';
   con_missing constant varchar2(4) := null;

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract_delivery(par_str_date in date, par_end_date in date);
   procedure extract_material;
   procedure extract_customer;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_data in varchar2, par_action in varchar2, par_str_value in varchar2, par_end_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_str_period number;
      var_end_period number;
      var_str_date date;
      var_end_date date;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'CTS Extract';
      con_alt_group constant varchar2(32) := 'CTS_ALERT';
      con_alt_code constant varchar2(32) := 'CTS_EXTRACT';
      con_ema_group constant varchar2(32) := 'CTS_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'CTS_EXTRACT';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_this_period is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_this_period csr_this_period%rowtype;

      cursor csr_mars_date is
         select min(t01.mars_period) as str_period,
                max(t01.mars_period) as end_period,
                min(t01.calendar_date) as str_date,
                max(t01.calendar_date) as end_date
           from mars_date t01
          where t01.mars_period >= var_str_period
            and t01.mars_period <= var_end_period;
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CTS - EXTRACT';
      var_log_search := 'CTS_EXTRACT';
      var_loc_string := 'CTS_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the data parameter
      /*-*/
      if upper(par_data) != '*ALL' and
         upper(par_data) != '*DELIVERY' and
         upper(par_data) != '*MATERIAL' and
         upper(par_data) != '*CUSTOMER' then
         raise_application_error(-20000, 'Data parameter (' || par_data || ') must be *ALL, *DELIVERY, *MATERIAL or *CUSTOMER');
      end if;

      /*-*/
      /* Validate the delivery parameters when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) != '*PERIOD_THIS' and
            upper(par_action) != '*PERIOD_LAST' and
            upper(par_action) != '*PERIOD_RANGE' and
            upper(par_action) != '*DATE_RANGE' then
            raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *PERIOD_THIS, *PERIOD_LAST, *PERIOD_RANGE or *DATE_RANGE');
         end if;
      end if;

      /*-*/
      /* Validate the period this when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*PERIOD_THIS' then
            open csr_this_period;
            fetch csr_this_period into rcd_this_period;
            if csr_this_period%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               var_str_period := rcd_this_period.mars_period;
               var_end_period := var_str_period;
            end if;
            close csr_this_period;
            open csr_mars_date;
            fetch csr_mars_date into rcd_mars_date;
            if csr_mars_date%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               if rcd_mars_date.str_period is null or rcd_mars_date.str_period != var_str_period then
                  raise_application_error(-20000, 'Start period ' || to_char(par_str_value) || ' not found in MARS_DATE');
               end if;
               if rcd_mars_date.end_period is null or rcd_mars_date.end_period != var_end_period then
                  raise_application_error(-20000, 'End period ' || to_char(par_end_value) || ' not found in MARS_DATE');
               end if;
            end if;
            close csr_mars_date;
            var_str_date := rcd_mars_date.str_date;
            var_end_date := rcd_mars_date.end_date;
         end if;
      end if;

      /*-*/
      /* Validate the period last when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*PERIOD_LAST' then
            open csr_this_period;
            fetch csr_this_period into rcd_this_period;
            if csr_this_period%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               var_str_period := rcd_this_period.mars_period - 1;
               if to_number(substr(to_char(var_str_period,'FM000000'),5,2)) = 0 then
                  var_str_period := var_str_period - 87;
               end if;
               var_end_period := var_str_period;
            end if;
            close csr_this_period;
            open csr_mars_date;
            fetch csr_mars_date into rcd_mars_date;
            if csr_mars_date%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               if rcd_mars_date.str_period is null or rcd_mars_date.str_period != var_str_period then
                  raise_application_error(-20000, 'Start period ' || to_char(par_str_value) || ' not found in MARS_DATE');
               end if;
               if rcd_mars_date.end_period is null or rcd_mars_date.end_period != var_end_period then
                  raise_application_error(-20000, 'End period ' || to_char(par_end_value) || ' not found in MARS_DATE');
               end if;
            end if;
            close csr_mars_date;
            var_str_date := rcd_mars_date.str_date;
            var_end_date := rcd_mars_date.end_date;
         end if;
      end if;

      /*-*/
      /* Validate the period range when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*PERIOD_RANGE' then
            if par_str_value is null then
               raise_application_error(-20000, 'Start period parameter must be supplied for action *PERIOD_RANGE');
            end if;
            if par_end_value is null then
               raise_application_error(-20000, 'End period parameter must be supplied for action *PERIOD_RANGE');
            end if;
            if par_str_value > par_end_value then
               raise_application_error(-20000, 'End period must be greater than or equal to start period for action *PERIOD_RANGE');
            end if;
            begin
               var_str_period := to_number(par_str_value);
            exception
               when others then
                  raise_application_error(-20000, 'Start period parameter (' || par_str_value || ') - unable to convert to number');
            end;
            begin
               var_end_period := to_number(par_end_value);
            exception
               when others then
                  raise_application_error(-20000, 'End period parameter (' || par_end_value || ') - unable to convert to number');
            end;
            open csr_mars_date;
            fetch csr_mars_date into rcd_mars_date;
            if csr_mars_date%notfound then
               raise_application_error(-20000, 'Start and end period not found in MARS_DATE');
            else
               if rcd_mars_date.str_period is null or rcd_mars_date.str_period != var_str_period then
                  raise_application_error(-20000, 'Start period ' || to_char(par_str_value) || ' not found in MARS_DATE');
               end if;
               if rcd_mars_date.end_period is null or rcd_mars_date.end_period != var_end_period then
                  raise_application_error(-20000, 'End period ' || to_char(par_end_value) || ' not found in MARS_DATE');
               end if;
            end if;
            close csr_mars_date;
            var_str_date := rcd_mars_date.str_date;
            var_end_date := rcd_mars_date.end_date;
         end if;
      end if;

      /*-*/
      /* Validate the date range when required
      /*-*/
      if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
         if upper(par_action) = '*DATE_RANGE' then
            if par_str_value is null then
               raise_application_error(-20000, 'Start date parameter must be supplied for action *DATE_RANGE');
            end if;
            if par_end_value is null then
               raise_application_error(-20000, 'End date parameter must be supplied for action *DATE_RANGE');
            end if;
            if par_str_value > par_end_value then
               raise_application_error(-20000, 'End date must be greater than or equal to start date for action *DATE_RANGE');
            end if;
            begin
               var_str_date := to_date(par_str_value,'yyyymmdd');
            exception
               when others then
                  raise_application_error(-20000, 'Start date parameter (' || par_str_value || ') - unable to convert to date format YYYYMMDD');
            end;
            begin
               var_end_date := to_date(par_end_value,'yyyymmdd');
            exception
               when others then
                  raise_application_error(-20000, 'End date parameter (' || par_end_value || ') - unable to convert to date format YYYYMMDD');
            end;
          end if;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - CTS Extract - Parameters(' || upper(par_data) || ' + ' || upper(par_action) || ' + ' || upper(par_str_value) || ' + ' || upper(par_end_value) || ')');

      /*-*/
      /* Request the lock
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the delivery extract procedure when required
         /*-*/
         if upper(par_data) = '*ALL' or upper(par_data) = '*DELIVERY' then
            begin
               extract_delivery(var_str_date, var_end_date);
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Execute the material extract procedure when required
         /*-*/
         if upper(par_data) = '*ALL' or upper(par_data) = '*MATERIAL' then
            begin
               extract_material;
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Execute the customer extract procedure when required
         /*-*/
         if upper(par_data) = '*ALL' or upper(par_data) = '*CUSTOMER' then
            begin
               extract_customer;
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - CTS Extract');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'CTS_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the CTS extract execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;
      end if;

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - COST TO SERVE - CTS_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /********************************************************/
   /* This procedure performs the extract delivery routine */
   /********************************************************/
   procedure extract_delivery(par_str_date in date, par_end_date in date) is

      /*-*/
      /* Local constants
      /*-*/
      con_hdr_heading constant varchar2(4000) := 'DeliveryNumber' || con_separator ||
                                                 'ShipmentDate' || con_separator ||
                                                 'PickDate' || con_separator ||
                                                 'Year' || con_separator ||
                                                 'Period' || con_separator ||
                                                 'Week' || con_separator ||
                                                 'ShipmentNumber' || con_separator ||
                                                 'SAPShipmentNumber' || con_separator ||
                                                 'LoadNumber' || con_separator ||
                                                 'ShipFrom' || con_separator ||
                                                 'Carrier' || con_separator ||
                                                 'IntermedNode1' || con_separator ||
                                                 'IntermedNode2' || con_separator ||
                                                 'IntermedNode3' || con_separator ||
                                                 'ShipTo' || con_separator ||
                                                 'SalesOrganisation' || con_separator ||
                                                 'TOLASRoute' || con_separator ||
                                                 'Route' || con_separator ||
                                                 'RouteDescription' || con_separator ||
                                                 'DeliveriesInShipment' || con_separator ||
                                                 'LineItemsInShipment' || con_separator ||
                                                 'PalletsInShipment' || con_separator ||
                                                 'SAPPalletsInShipment' || con_separator ||
                                                 'FullPalletsInShipment' || con_separator ||
                                                 'EPSInShipment' || con_separator ||
                                                 'CasesInShipment' || con_separator ||
                                                 'SAPCasesInShipment' || con_separator ||
                                                 'CubeInShipment' || con_separator ||
                                                 'SAPNetCubeInShipment' || con_separator ||
                                                 'NetWeightInShipment' || con_separator ||
                                                 'GrossWeightInShipment' || con_separator ||
                                                 'ShipmentType' || con_separator ||
                                                 'LineItemsInDelivery' || con_separator ||
                                                 'PalletsInDelivery' || con_separator ||
                                                 'SAPPalletsInDelivery' || con_separator ||
                                                 'FullPalletsInDelivery' || con_separator ||
                                                 'EPSInDelivery' || con_separator ||
                                                 'CasesInDelivery' || con_separator ||
                                                 'SAPCasesInDelivery' || con_separator ||
                                                 'NetCubeInDelivery' || con_separator ||
                                                 'NetWeightInDelivery' || con_separator ||
                                                 'SAPGrossWeightInDelivery' || con_separator ||
                                                 'GrossWeightInDelivery' || con_separator ||
                                                 'GrossCubeInDelivery' || con_separator ||
                                                 'VehicleType' || con_separator ||
                                                 'ShippingCondition';
      con_det_heading constant varchar2(4000) := 'DeliveryNumber' || con_separator ||
                                                 'SAP708Number' || con_separator ||
                                                 'LineItemNumber' || con_separator ||
                                                 'TDU' || con_separator ||
                                                 'ShipmentDate' || con_separator ||
                                                 'ShipmentNumber' || con_separator ||
                                                 'ShipFrom' || con_separator ||
                                                 'ShipTo' || con_separator ||
                                                 'SalesOrganisation' || con_separator ||
                                                 'Year' || con_separator ||
                                                 'Period' || con_separator ||
                                                 'Week' || con_separator ||
                                                 'EAN11' || con_separator ||
                                                 'EAN13' || con_separator ||
                                                 'NumUnits' || con_separator ||
                                                 'NumCases' || con_separator ||
                                                 'NumPallets' || con_separator ||
                                                 'NumFullPallets' || con_separator ||
                                                 'LineItemNetCube' || con_separator ||
                                                 'LineItemNetWeight' || con_separator ||
                                                 'LineItemGrossWeight' || con_separator ||
                                                 'LineItemBPS' || con_separator ||
                                                 'LineItemGSV' || con_separator ||
                                                 'LineItemNIV' || con_separator ||
                                                 'LineItemCost';
      con_tol_heading constant varchar2(4000) := 'RecordIdentifier' || con_separator ||
                                                 'DeliveryNumber' || con_separator ||
                                                 'ShipmentNumber' || con_separator ||
                                                 'ShipmentDate' || con_separator ||
                                                 'TOLASRoute' || con_separator ||
                                                 'TOLASLoadNumber' || con_separator ||
                                                 'Carrier' || con_separator ||
                                                 'VehicleType' || con_separator ||
                                                 'FullPalletsInShipment' || con_separator ||
                                                 'PalletsInShipment' || con_separator ||
                                                 'CasesInShipment' || con_separator ||
                                                 'PalletsInDelivery' || con_separator ||
                                                 'FullPalletsInDelivery' || con_separator ||
                                                 'EPSInDelivery' || con_separator ||
                                                 'CasesInDelivery' || con_separator ||
                                                 'CubeInDelivery' || con_separator ||
                                                 'GrossWeightInDelivery';
      con_aud_heading constant varchar2(4000) := 'DeliveryNumber' || con_separator ||
                                                 'SAP708Number' || con_separator ||
                                                 'ShipmentNumber' || con_separator ||
                                                 'TOLASRoute' || con_separator ||
                                                 'TOLASLoadNumber' || con_separator ||
                                                 'VehicleType';

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(4000);
      type rcd_shp_data is record(sap_type varchar2(128 char),
                                  sap_del_cnt number,
                                  sap_lin_cnt number,
                                  sap_pal_cnt number,
                                  sap_fup_cnt number,
                                  sap_del_tgw number,
                                  sap_del_cub number,
                                  sap_sal_qty number,
                                  sap_sal_tnw number,
                                  sap_sal_tgw number,
                                  sap_sal_cub number,
                                  sap_bas_qty number,
                                  sap_pce_qty number,
                                  sap_cas_qty number,
                                  tol_shp_pal number,
                                  tol_shp_fup number,
                                  tol_shp_cas number,
                                  tol_del_pal number,
                                  tol_del_fup number,
                                  tol_del_eps number,
                                  tol_del_cas number,
                                  tol_del_tgw number,
                                  tol_del_cub number);
      type rcd_hdr_data is record(tol_shipment varchar2(128 char),
                                  tol_dsp_date varchar2(128 char),
                                  tol_dsp_year varchar2(128 char),
                                  tol_dsp_period varchar2(128 char),
                                  tol_dsp_week varchar2(128 char),
                                  tol_delivery varchar2(128 char),
                                  tol_route varchar2(128 char),
                                  tol_load varchar2(128 char),
                                  tol_carrier varchar2(128 char),
                                  tol_vehicle varchar2(128 char),
                                  tol_shp_pal number,
                                  tol_shp_fup number,
                                  tol_shp_cas number,
                                  tol_del_pal number,
                                  tol_del_fup number,
                                  tol_del_eps number,
                                  tol_del_cas number,
                                  tol_del_tgw number,
                                  tol_del_cub number,
                                  tol_grp_pal number,
                                  tol_grp_fup number,
                                  tol_grp_cas number,
                                  sap_shipment varchar2(128 char),
                                  sap_delivery varchar2(128 char),
                                  sap_pck_date varchar2(128 char),
                                  sap_pck_year varchar2(128 char),
                                  sap_pck_period varchar2(128 char),
                                  sap_pck_week varchar2(128 char),
                                  sap_shp_from varchar2(128 char),
                                  sap_int_node1 varchar2(128 char),
                                  sap_int_node2 varchar2(128 char),
                                  sap_int_node3 varchar2(128 char),
                                  sap_shp_to varchar2(128 char),
                                  sap_sal_org varchar2(128 char),
                                  sap_shp_cond varchar2(128 char),
                                  sap_route varchar2(128 char),
                                  sap_rte_desc varchar2(128 char),
                                  sap_lin_cnt number,
                                  sap_pal_cnt number,
                                  sap_fup_cnt number,
                                  sap_del_tgw number,
                                  sap_del_cub number,
                                  sap_sal_qty number,
                                  sap_sal_tnw number,
                                  sap_sal_tgw number,
                                  sap_sal_cub number,
                                  sap_bas_qty number,
                                  sap_pce_qty number,
                                  sap_cas_qty number);
      type rcd_det_data is record(sap_delivery varchar2(128 char),
                                  sap_708_number varchar2(128),
                                  sap_line_number varchar2(128),
                                  sap_material varchar2(128 char),
                                  sap_sal_ean varchar2(128 char),
                                  sap_pce_ean varchar2(128 char),
                                  sap_pal_cnt number,
                                  sap_fup_cnt number,
                                  sap_sal_qty number,
                                  sap_sal_tnw number,
                                  sap_sal_tgw number,
                                  sap_sal_cub number,
                                  sap_sal_wgt number,
                                  sap_sal_len number,
                                  sap_sal_bth number,
                                  sap_sal_hgt number,
                                  sap_sal_vol number,
                                  sap_bas_qty number,
                                  sap_bas_wgt number,
                                  sap_bas_len number,
                                  sap_bas_bth number,
                                  sap_bas_hgt number,
                                  sap_bas_vol number,
                                  sap_pce_qty number,
                                  sap_pce_wgt number,
                                  sap_pce_len number,
                                  sap_pce_bth number,
                                  sap_pce_hgt number,
                                  sap_pce_vol number,
                                  sap_cas_qty number,
                                  sap_cas_wgt number,
                                  sap_cas_len number,
                                  sap_cas_bth number,
                                  sap_cas_hgt number,
                                  sap_cas_vol number,
                                  sap_sal_bps number,
                                  sap_sal_gsv number,
                                  sap_sal_niv number,
                                  sap_sal_cst number);
      type rcd_aud_data is record(tol_delivery varchar2(128 char),
                                  sap_708_number varchar2(128),
                                  tol_shipment varchar2(128),
                                  tol_route varchar2(128 char),
                                  tol_load varchar2(128 char),
                                  tol_vehicle varchar2(128 char));
      type typ_shp_data is table of rcd_shp_data index by binary_integer;
      type typ_hdr_data is table of rcd_hdr_data index by binary_integer;
      type typ_det_data is table of rcd_det_data index by binary_integer;
      type typ_aud_data is table of rcd_aud_data index by binary_integer;
      type typ_hdr_outp is table of varchar2(4000) index by binary_integer;
      type typ_det_outp is table of varchar2(4000) index by binary_integer;
      type typ_tod_outp is table of varchar2(4000) index by binary_integer;
      type typ_tor_outp is table of varchar2(4000) index by binary_integer;
      type typ_toa_outp is table of varchar2(4000) index by binary_integer;
      tbl_shp_data typ_shp_data;
      tbl_hdr_data typ_hdr_data;
      tbl_det_data typ_det_data;
      tbl_aud_data typ_aud_data;
      tbl_hdr_outp typ_hdr_outp;
      tbl_det_outp typ_det_outp;
      tbl_tod_outp typ_tod_outp;
      tbl_tor_outp typ_tor_outp;
      tbl_toa_outp typ_toa_outp;
      var_sidx number;
      var_hidx number;
      var_didx number;
      var_aidx number;
      var_sav_grouping varchar2(128);
      var_sav_customer varchar2(128);
      var_new_customer boolean;
      var_aud_flag boolean;
      var_sap_reject boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_cts_del_hdr is
         select nvl(t01.grp_shipment,'*MISSING') as cts_grouping,
                nvl(t08.partner_id||t01.grp_shipment,'*MISSING') as cts_customer,
                t01.cdh_ship_nbr as cts_shipment,
                t01.cdh_ship_dte as cts_dsp_date,
                t01.cdh_delv_nbr as cts_delivery,
                t01.cdh_delv_rte as cts_route,
                t01.cdh_ship_lod as cts_load,
                t01.cdh_ship_car as cts_carrier,
                t01.cdh_ship_veh as cts_vehicle,
                t01.cdh_ship_pal as cts_shp_pal,
                t01.cdh_ship_fup as cts_shp_fup,
                t01.cdh_ship_cas as cts_shp_cas,
                t01.cdh_delv_pal as cts_del_pal,
                t01.cdh_delv_fup as cts_del_fup,
                t01.cdh_delv_eps as cts_del_eps,
                t01.cdh_delv_cas as cts_del_cas,
                t01.cdh_delv_wgt as cts_del_tgw,
                t01.cdh_delv_vol as cts_del_cub,
                t02.grp_ship_cas as cts_grp_cas,
                t02.grp_ship_pal as cts_grp_pal,
                t02.grp_ship_fup as cts_grp_fup,
                t03.mars_week as cts_dsp_yyyyppw,
                t04.vbeln as hdr_vbeln,
                t04.vkorg as hdr_vkorg,
                t04.werks as hdr_werks,
                t04.route as hdr_route,
                t04.route_bez as hdr_route_bez,
                t04.gewei as hdr_gewei,
                t04.voleh as hdr_voleh,
                t04.vsbed as hdr_vsbed,
                nvl(t04.ntgew,0) as hdr_ntgew,
                nvl(t04.btgew,0) as hdr_btgew,
                nvl(t04.volum,0) as hdr_volum,
                to_char(lads_to_date(ltrim(t05.isdd,'0'),'yyyymmdd'),'dd/mm/yyyy') as hdr_pck_date,
                t06.mars_week as hdr_pck_yyyyppw,
                t07.tknum as hdr_tknum,
                t08.partner_id as hdr_shp_to
           from (select t01.*,
                        min(t01.cdh_ship_nbr) over (partition by substr(t01.cdh_ship_nbr,1,length(t01.cdh_ship_nbr)-12) order by lads_to_date(substr(t01.cdh_ship_nbr,-12,12),'yyyymmddhh24mi') range between (2/24) preceding and (2/24) following) as grp_shipment
                   from cts_del_hdr t01
                  where (not(t01.cdh_ship_dte is null) and
                         (lads_to_date(t01.cdh_ship_dte,'dd/mm/yyyy') >= trunc(par_str_date) and lads_to_date(t01.cdh_ship_dte,'dd/mm/yyyy') <= trunc(par_end_date)))) t01,
                (select t01.grp_shipment,
                        sum(t01.grp_ship_cas) as grp_ship_cas,
                        sum(t01.grp_ship_pal) as grp_ship_pal,
                        sum(t01.grp_ship_fup) as grp_ship_fup
                   from (select t01.grp_shipment,
                                min(t01.cdh_ship_cas) as grp_ship_cas,
                                min(t01.cdh_ship_pal) as grp_ship_pal,
                                min(t01.cdh_ship_fup) as grp_ship_fup
                           from (select t01.cdh_delv_rte,
                                        t01.cdh_ship_cas,
                                        t01.cdh_ship_pal,
                                        t01.cdh_ship_fup,
                                        min(t01.cdh_ship_nbr) over (partition by substr(t01.cdh_ship_nbr,1,length(t01.cdh_ship_nbr)-12) order by lads_to_date(substr(t01.cdh_ship_nbr,-12,12),'yyyymmddhh24mi') range between (2/24) preceding and (2/24) following) as grp_shipment
                                   from cts_del_hdr t01
                                  where (not(t01.cdh_ship_dte is null) and
                                         (lads_to_date(t01.cdh_ship_dte,'dd/mm/yyyy') >= trunc(par_str_date) and lads_to_date(t01.cdh_ship_dte,'dd/mm/yyyy') <= trunc(par_end_date)))) t01
                          group by t01.grp_shipment,
                                   t01.cdh_delv_rte,
                                   t01.cdh_ship_cas) t01
                  group by t01.grp_shipment) t02,
                mars_date t03,
                lads_del_hdr t04,
                lads_del_tim t05,
                mars_date t06,
                (select t01.vbeln,
                        min(t01.tknum) as tknum
                   from lads_shp_dlv t01
                  group by t01.vbeln) t07,
                (select t01.vbeln,
                        min(t01.partner_id) as partner_id
                   from lads_del_add t01
                  where t01.partner_q = 'WE'
                  group by t01.vbeln) t08
          where t01.grp_shipment = t02.grp_shipment(+)
            and lads_to_date(t01.cdh_ship_dte,'dd/mm/yyyy') = t03.calendar_date(+)
            and t01.cdh_delv_nbr = t04.vbeln(+)
            and t04.vbeln = t05.vbeln(+)
            and '006' = t05.qualf(+)
            and lads_to_date(ltrim(t05.isdd,'0'),'yyyymmdd') = t06.calendar_date(+)
            and t04.vbeln = t07.vbeln(+)
            and t04.vbeln = t08.vbeln(+)
          order by cts_grouping asc,
                   cts_customer asc,
                   cts_delivery asc;
      rcd_cts_del_hdr csr_cts_del_hdr%rowtype;

      cursor csr_lads_del_det is
         select t01.vbeln as det_vbeln,
                decode(t01.hipos,null,t01.posnr,decode(t01.hievw,'3',t01.posnr,'5',t01.posnr,t01.hipos)) as det_posnr,
                max(t01.detseq) as det_detseq,
                max(t01.matnr) as det_matnr,
                max(t01.vrkme) as det_vrkme,
                max(nvl(t01.lfimg,0)) as det_lfimg,
                max(t01.meins) as det_meins,
                max(nvl(t01.lgmng,0)) as det_lgmng,
                max(t01.ean11) as det_ean11,
                sum(nvl(t01.zzpalbase_deliv,0)) as det_pal_base,
                sum(nvl(t01.zzpalspace_deliv,0)) as det_pal_space,
                max(t01.gewei) as det_gewei,
                max(t01.voleh) as det_voleh,
                sum(nvl(t01.ntgew,0)) as det_ntgew,
                sum(nvl(t01.brgew,0)) as det_brgew,
                sum(nvl(t01.volum,0)) as det_volum
           from lads_del_det t01
          where t01.vbeln = rcd_cts_del_hdr.hdr_vbeln
            and t01.lfimg != 0
          group by t01.vbeln,
                   decode(t01.hipos,null,t01.posnr,decode(t01.hievw,'3',t01.posnr,'5',t01.posnr,t01.hipos))
          order by det_vbeln asc,
                   det_posnr asc;
      rcd_lads_del_det csr_lads_del_det%rowtype;

      cursor csr_lads_mat_uom is
         select nvl(t01.ntgew,0) as mat_ntgew,
                nvl(t02.umren,1) as sal_umren,
                nvl(t02.umrez,1) as sal_umrez,
                nvl(t02.brgew,0) as sal_brgew,
                t02.gewei as sal_gewei,
                nvl(t02.laeng,0) as sal_laeng,
                nvl(t02.breit,0) as sal_breit,
                nvl(t02.hoehe,0) as sal_hoehe,
                t02.meabm as sal_meabm,
                nvl(t02.volum,0) as sal_volum,
                t02.voleh as sal_voleh,
                t02.ean11 as sal_ean11,
                nvl(t03.umren,1) as bas_umren,
                nvl(t03.umrez,1) as bas_umrez,
                nvl(t03.brgew,0) as bas_brgew,
                t03.gewei as bas_gewei,
                nvl(t03.laeng,0) as bas_laeng,
                nvl(t03.breit,0) as bas_breit,
                nvl(t03.hoehe,0) as bas_hoehe,
                t03.meabm as bas_meabm,
                nvl(t03.volum,0) as bas_volum,
                t03.voleh as bas_voleh,
                t03.ean11 as bas_ean11,
                nvl(t04.umren,1) as pce_umren,
                nvl(t04.umrez,1) as pce_umrez,
                nvl(t04.brgew,0) as pce_brgew,
                t04.gewei as pce_gewei,
                nvl(t04.laeng,0) as pce_laeng,
                nvl(t04.breit,0) as pce_breit,
                nvl(t04.hoehe,0) as pce_hoehe,
                t04.meabm as pce_meabm,
                nvl(t04.volum,0) as pce_volum,
                t04.voleh as pce_voleh,
                t04.ean11 as pce_ean11,
                nvl(t05.umren,1) as cas_umren,
                nvl(t05.umrez,1) as cas_umrez,
                nvl(t05.brgew,0) as cas_brgew,
                t05.gewei as cas_gewei,
                nvl(t05.laeng,0) as cas_laeng,
                nvl(t05.breit,0) as cas_breit,
                nvl(t05.hoehe,0) as cas_hoehe,
                t05.meabm as cas_meabm,
                nvl(t05.volum,0) as cas_volum,
                t05.voleh as cas_voleh,
                t05.ean11 as cas_ean11
           from lads_mat_hdr t01,
                (select t21.matnr,
                        t21.umren,
                        t21.umrez,
                        t21.brgew,
                        t21.gewei,
                        t21.laeng,
                        t21.breit,
                        t21.hoehe,
                        t21.meabm,
                        t21.volum,
                        t21.voleh,
                        t21.ean11
                   from lads_mat_uom t21
                  where t21.matnr = rcd_lads_del_det.det_matnr
                    and t21.meinh = rcd_lads_del_det.det_vrkme) t02,
                (select t31.matnr,
                        t31.umren,
                        t31.umrez,
                        t31.brgew,
                        t31.gewei,
                        t31.laeng,
                        t31.breit,
                        t31.hoehe,
                        t31.meabm,
                        t31.volum,
                        t31.voleh,
                        t31.ean11
                   from lads_mat_uom t31
                  where t31.matnr = rcd_lads_del_det.det_matnr
                    and t31.meinh = rcd_lads_del_det.det_meins) t03,
                (select t41.matnr,
                        t41.umren,
                        t41.umrez,
                        t41.brgew,
                        t41.gewei,
                        t41.laeng,
                        t41.breit,
                        t41.hoehe,
                        t41.meabm,
                        t41.volum,
                        t41.voleh,
                        t41.ean11
                   from lads_mat_uom t41
                  where t41.matnr = rcd_lads_del_det.det_matnr
                    and t41.meinh = 'PCE') t04,
                (select t51.matnr,
                        t51.umren,
                        t51.umrez,
                        t51.brgew,
                        t51.gewei,
                        t51.laeng,
                        t51.breit,
                        t51.hoehe,
                        t51.meabm,
                        t51.volum,
                        t51.voleh,
                        t51.ean11
                   from lads_mat_uom t51
                  where t51.matnr = rcd_lads_del_det.det_matnr
                    and t51.meinh = 'CS') t05
          where t01.matnr = t02.matnr(+)
            and t01.matnr = t03.matnr(+)
            and t01.matnr = t04.matnr(+)
            and t01.matnr = t05.matnr(+)
            and t01.matnr = rcd_lads_del_det.det_matnr;
      rcd_lads_mat_uom csr_lads_mat_uom%rowtype;

      cursor csr_lads_mat_mbe is 
         select nvl(t01.peinh,1) as peinh,
                nvl(t01.stprs,0) as stprs
           from lads_mat_mbe t01
          where t01.matnr = rcd_lads_del_det.det_matnr
            and t01.bwkey = rcd_cts_del_hdr.hdr_werks;
      rcd_lads_mat_mbe csr_lads_mat_mbe%rowtype;

      cursor csr_lads_sal_ord_org is
         select t01.belnr as belnr,
                t02.order_type_sign as order_type_sign,
                t02.order_type_gsv as order_type_gsv
           from lads_sal_ord_org t01,
                sap_order_type t02,
                (select t31.belnr as belnr
                   from lads_del_irf t31
                  where t31.vbeln = rcd_cts_del_hdr.hdr_vbeln
                    and t31.qualf in ('C','H','I','K','L')
                    and not(t31.datum is null)
                  group by t31.belnr) t03
          where t01.orgid = t02.sap_order_type_code
            and t01.belnr = t03.belnr
            and t01.qualf = '012';
      rcd_lads_sal_ord_org csr_lads_sal_ord_org%rowtype;

      cursor csr_lads_sal_ord_gen is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.menge as menge
           from lads_sal_ord_gen t01,
                (select t21.belnr as belnr,
                        t21.posnr as posnr
                   from lads_del_irf t21
                  where t21.vbeln = rcd_lads_del_det.det_vbeln
                    and t21.detseq = rcd_lads_del_det.det_detseq
                    and t21.qualf in ('C','H','I','K','L')
                    and not(t21.datum is null)) t02
          where t01.belnr = t02.belnr
            and t01.posex = t02.posnr;
      rcd_lads_sal_ord_gen csr_lads_sal_ord_gen%rowtype;

      cursor csr_lads_sal_ord_ico is
         select sum(decode(t01.alckz,'-',-1,1)*decode(t02.dsv_code,'BPS',nvl(lads_to_number(t01.betrg),0),0)) as bps_value,
                sum(decode(t01.alckz,'-',-1,1)*decode(t02.dsv_code,'GSV',nvl(lads_to_number(t01.betrg),0),0)) as gsv_value,
                sum(decode(t01.alckz,'-',-1,1)*decode(t02.dsv_code,'NIV',nvl(lads_to_number(t01.betrg),0),0)) as niv_value
           from lads_sal_ord_ico t01,
                table(lics_datastore.retrieve_value('LADS','ORDER_VALUATION',null)) t02
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.genseq = rcd_lads_sal_ord_gen.genseq
            and ((not(t01.kschl is null) and t01.kschl = t02.dsv_value) or
                 (t01.kschl is null and upper('*TEXT*'||t01.kotxt) = upper(t02.dsv_value)));
      rcd_lads_sal_ord_ico csr_lads_sal_ord_ico%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - CTS Extract - Extract delivery');

      /*-*/
      /* Clear the work data
      /*-*/
      tbl_shp_data.delete;
      tbl_hdr_data.delete;
      tbl_det_data.delete;
      tbl_aud_data.delete;
      tbl_hdr_outp.delete;
      tbl_det_outp.delete;
      tbl_tod_outp.delete;
      tbl_tor_outp.delete;
      tbl_toa_outp.delete;

      /*-*/
      /* Retrieve the cost to serve rows for the requested date range
      /* **notes** 1. date selection is based on the shipment despatch date
      /*-*/
      var_sav_grouping := '**START**';
      var_sav_customer := '**START**';
      var_new_customer := false;
      var_sap_reject := false;
      var_aud_flag := false;
      open csr_cts_del_hdr;
      loop
         fetch csr_cts_del_hdr into rcd_cts_del_hdr;
         if csr_cts_del_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Change of grouping
         /*-*/
         if rcd_cts_del_hdr.cts_grouping != var_sav_grouping then

            /*-*/
            /* Output the previous grouping when required
            /*-*/
            if var_sav_grouping != '**START**' then

               /*-*/
               /* Append the header records
               /*-*/
               for idx in 1..tbl_hdr_data.count loop
                  if not(tbl_hdr_data(idx).sap_delivery is null) then
                     var_output := tbl_hdr_data(idx).tol_delivery || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_dsp_date || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_pck_date || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_dsp_year || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_dsp_period || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_dsp_week || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_shipment || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_shipment || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_load || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_shp_from || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_carrier || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_int_node1 || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_int_node2 || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_int_node3 || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_shp_to || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_sal_org || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_route || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_route || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_rte_desc || con_separator;
                     var_output := var_output || tbl_shp_data(var_sidx).sap_del_cnt || con_separator;
                     var_output := var_output || tbl_shp_data(var_sidx).sap_lin_cnt || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).tol_shp_pal,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).sap_pal_cnt,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).tol_shp_fup,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).tol_del_eps,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).tol_shp_cas,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).sap_cas_qty,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).tol_del_cub,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).sap_sal_cub,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).sap_sal_tnw,5) || con_separator;
                     var_output := var_output || round(tbl_shp_data(var_sidx).tol_del_tgw,5) || con_separator;
                     var_output := var_output || tbl_shp_data(var_sidx).sap_type || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_lin_cnt || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).tol_del_pal,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).sap_pal_cnt,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).tol_del_fup,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).tol_del_eps,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).tol_del_cas,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).sap_cas_qty,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).sap_sal_cub,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).sap_sal_tnw,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).sap_sal_tgw,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).tol_del_tgw,5) || con_separator;
                     var_output := var_output || round(tbl_hdr_data(idx).tol_del_cub,5) || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).tol_vehicle || con_separator;
                     var_output := var_output || tbl_hdr_data(idx).sap_shp_cond;
                     tbl_hdr_outp(tbl_hdr_outp.count + 1) := var_output;
                  end if;
               end loop;

            end if;

            /*-*/
            /* Initialise the new grouping
            /*-*/
            var_sav_grouping := rcd_cts_del_hdr.cts_grouping;
            var_sav_customer := '**START**';
            tbl_shp_data.delete;
            tbl_hdr_data.delete;

            /*-*/
            /* Initialise the shipment values
            /*-*/
            var_sidx := tbl_shp_data.count + 1;
            tbl_shp_data(var_sidx).sap_type := '3';
            tbl_shp_data(var_sidx).sap_del_cnt := 0;
            tbl_shp_data(var_sidx).sap_lin_cnt := 0;
            tbl_shp_data(var_sidx).sap_pal_cnt := 0;
            tbl_shp_data(var_sidx).sap_fup_cnt := 0;
            tbl_shp_data(var_sidx).sap_del_tgw := 0;
            tbl_shp_data(var_sidx).sap_del_cub := 0;
            tbl_shp_data(var_sidx).sap_sal_qty := 0;
            tbl_shp_data(var_sidx).sap_sal_tnw := 0;
            tbl_shp_data(var_sidx).sap_sal_tgw := 0;
            tbl_shp_data(var_sidx).sap_sal_cub := 0;
            tbl_shp_data(var_sidx).sap_bas_qty := 0;
            tbl_shp_data(var_sidx).sap_pce_qty := 0;
            tbl_shp_data(var_sidx).sap_cas_qty := 0;
            tbl_shp_data(var_sidx).tol_shp_pal := 0;
            tbl_shp_data(var_sidx).tol_shp_fup := 0;
            tbl_shp_data(var_sidx).tol_shp_cas := 0;
            tbl_shp_data(var_sidx).tol_del_pal := 0;
            tbl_shp_data(var_sidx).tol_del_fup := 0;
            tbl_shp_data(var_sidx).tol_del_eps := 0;
            tbl_shp_data(var_sidx).tol_del_cas := 0;
            tbl_shp_data(var_sidx).tol_del_tgw := 0;
            tbl_shp_data(var_sidx).tol_del_cub := 0;

         end if;

         /*-*/
         /* Change of customer
         /*-*/
         if rcd_cts_del_hdr.cts_customer != var_sav_customer then

            /*-*/
            /* Append the previous audit records when required
            /*-*/
            if var_aud_flag = true then
               for idx in 1..tbl_aud_data.count loop
                  var_output := tbl_aud_data(idx).tol_delivery || con_separator;
                  var_output := var_output || tbl_aud_data(idx).sap_708_number || con_separator;
                  var_output := var_output || tbl_aud_data(idx).tol_shipment || con_separator;
                  var_output := var_output || tbl_aud_data(idx).tol_route || con_separator;
                  var_output := var_output || tbl_aud_data(idx).tol_load || con_separator;
                  var_output := var_output || tbl_aud_data(idx).tol_vehicle;
                  tbl_toa_outp(tbl_toa_outp.count + 1) := var_output;
               end loop;
            end if;

            /*-*/
            /* Initialise the Tolas header values (consolidated customer delivery)
            /*-*/
            var_hidx := tbl_hdr_data.count + 1;
            tbl_hdr_data(var_hidx).tol_shipment := rcd_cts_del_hdr.cts_grouping;
            tbl_hdr_data(var_hidx).tol_dsp_date := rcd_cts_del_hdr.cts_dsp_date;
            tbl_hdr_data(var_hidx).tol_dsp_year := substr(to_char(rcd_cts_del_hdr.cts_dsp_yyyyppw,'fm0000000'),1,4);
            tbl_hdr_data(var_hidx).tol_dsp_period := substr(to_char(rcd_cts_del_hdr.cts_dsp_yyyyppw,'fm0000000'),5,2);
            tbl_hdr_data(var_hidx).tol_dsp_week := substr(to_char(rcd_cts_del_hdr.cts_dsp_yyyyppw,'fm0000000'),7,1);
            tbl_hdr_data(var_hidx).tol_delivery := rcd_cts_del_hdr.cts_customer;
            tbl_hdr_data(var_hidx).tol_route := rcd_cts_del_hdr.cts_route;
            tbl_hdr_data(var_hidx).tol_load := rcd_cts_del_hdr.cts_load;
            tbl_hdr_data(var_hidx).tol_carrier := rcd_cts_del_hdr.cts_carrier;
            tbl_hdr_data(var_hidx).tol_vehicle := rcd_cts_del_hdr.cts_vehicle;
            tbl_hdr_data(var_hidx).tol_shp_pal := rcd_cts_del_hdr.cts_shp_pal;
            tbl_hdr_data(var_hidx).tol_shp_fup := rcd_cts_del_hdr.cts_shp_fup;
            tbl_hdr_data(var_hidx).tol_shp_cas := rcd_cts_del_hdr.cts_shp_cas;
            tbl_hdr_data(var_hidx).tol_del_pal := 0;
            tbl_hdr_data(var_hidx).tol_del_fup := 0;
            tbl_hdr_data(var_hidx).tol_del_eps := 0;
            tbl_hdr_data(var_hidx).tol_del_cas := 0;
            tbl_hdr_data(var_hidx).tol_del_tgw := 0;
            tbl_hdr_data(var_hidx).tol_del_cub := 0;
            tbl_hdr_data(var_hidx).tol_grp_pal := rcd_cts_del_hdr.cts_grp_pal;
            tbl_hdr_data(var_hidx).tol_grp_fup := rcd_cts_del_hdr.cts_grp_fup;
            tbl_hdr_data(var_hidx).tol_grp_cas := rcd_cts_del_hdr.cts_grp_cas;
            tbl_hdr_data(var_hidx).sap_shipment := null;
            tbl_hdr_data(var_hidx).sap_delivery := null;
            tbl_hdr_data(var_hidx).sap_pck_date := null;
            tbl_hdr_data(var_hidx).sap_pck_year := null;
            tbl_hdr_data(var_hidx).sap_pck_period := null;
            tbl_hdr_data(var_hidx).sap_pck_week := null;
            tbl_hdr_data(var_hidx).sap_shp_from := null;
            tbl_hdr_data(var_hidx).sap_int_node1 := con_missing;
            tbl_hdr_data(var_hidx).sap_int_node2 := con_missing;
            tbl_hdr_data(var_hidx).sap_int_node3 := con_missing;
            tbl_hdr_data(var_hidx).sap_shp_to := null;
            tbl_hdr_data(var_hidx).sap_sal_org := null;
            tbl_hdr_data(var_hidx).sap_shp_cond := null;
            tbl_hdr_data(var_hidx).sap_route := null;
            tbl_hdr_data(var_hidx).sap_rte_desc := null;
            tbl_hdr_data(var_hidx).sap_lin_cnt := 0;
            tbl_hdr_data(var_hidx).sap_pal_cnt := 0;
            tbl_hdr_data(var_hidx).sap_fup_cnt := 0;
            tbl_hdr_data(var_hidx).sap_del_tgw := 0;
            tbl_hdr_data(var_hidx).sap_del_cub := 0;
            tbl_hdr_data(var_hidx).sap_sal_qty := 0;
            tbl_hdr_data(var_hidx).sap_sal_tnw := 0;
            tbl_hdr_data(var_hidx).sap_sal_tgw := 0;
            tbl_hdr_data(var_hidx).sap_sal_cub := 0;
            tbl_hdr_data(var_hidx).sap_bas_qty := 0;
            tbl_hdr_data(var_hidx).sap_pce_qty := 0;
            tbl_hdr_data(var_hidx).sap_cas_qty := 0;

            /*-*/
            /* Initialise the new customer
            /*-*/
            var_sav_customer := rcd_cts_del_hdr.cts_customer;
            var_new_customer := true;
            var_aud_flag := false;
            tbl_aud_data.delete;

            /*-*/
            /* Accumulate/set the Tolas shipment values
            /*-*/
            tbl_shp_data(var_sidx).sap_del_cnt := tbl_shp_data(var_sidx).sap_del_cnt + 1;
            tbl_shp_data(var_sidx).tol_shp_pal := rcd_cts_del_hdr.cts_grp_pal;
            tbl_shp_data(var_sidx).tol_shp_fup := rcd_cts_del_hdr.cts_grp_fup;
            tbl_shp_data(var_sidx).tol_shp_cas := rcd_cts_del_hdr.cts_grp_cas;

         end if;

         /*-*/
         /* Accumulate the Tolas header delivery values (consolidated customer delivery)
         /*-*/
         tbl_hdr_data(var_hidx).tol_del_pal := tbl_hdr_data(var_hidx).tol_del_pal + rcd_cts_del_hdr.cts_del_pal;
         tbl_hdr_data(var_hidx).tol_del_fup := tbl_hdr_data(var_hidx).tol_del_fup + rcd_cts_del_hdr.cts_del_fup;
         tbl_hdr_data(var_hidx).tol_del_eps := tbl_hdr_data(var_hidx).tol_del_eps + rcd_cts_del_hdr.cts_del_eps;
         tbl_hdr_data(var_hidx).tol_del_cas := tbl_hdr_data(var_hidx).tol_del_cas + rcd_cts_del_hdr.cts_del_cas;
         tbl_hdr_data(var_hidx).tol_del_tgw := tbl_hdr_data(var_hidx).tol_del_tgw + rcd_cts_del_hdr.cts_del_tgw;
         tbl_hdr_data(var_hidx).tol_del_cub := tbl_hdr_data(var_hidx).tol_del_cub + rcd_cts_del_hdr.cts_del_cub;

         /*-*/
         /* Accumulate the Tolas shipment values
         /*-*/ 
         tbl_shp_data(var_sidx).tol_del_pal := tbl_shp_data(var_sidx).tol_del_pal + rcd_cts_del_hdr.cts_del_pal;
         tbl_shp_data(var_sidx).tol_del_fup := tbl_shp_data(var_sidx).tol_del_fup + rcd_cts_del_hdr.cts_del_fup;
         tbl_shp_data(var_sidx).tol_del_eps := tbl_shp_data(var_sidx).tol_del_eps + rcd_cts_del_hdr.cts_del_eps;
         tbl_shp_data(var_sidx).tol_del_cas := tbl_shp_data(var_sidx).tol_del_cas + rcd_cts_del_hdr.cts_del_cas;
         tbl_shp_data(var_sidx).tol_del_tgw := tbl_shp_data(var_sidx).tol_del_tgw + rcd_cts_del_hdr.cts_del_tgw;
         tbl_shp_data(var_sidx).tol_del_cub := tbl_shp_data(var_sidx).tol_del_cub + rcd_cts_del_hdr.cts_del_cub;

         /*-*/
         /* Create the audit data
         /*-*/
         if tbl_hdr_data(var_hidx).tol_route != rcd_cts_del_hdr.cts_route or
            tbl_hdr_data(var_hidx).tol_vehicle != rcd_cts_del_hdr.cts_vehicle then
            var_aud_flag := true;
         end if;
         var_aidx := tbl_aud_data.count + 1;
         tbl_aud_data(var_aidx).tol_delivery := rcd_cts_del_hdr.cts_customer;
         tbl_aud_data(var_aidx).sap_708_number := rcd_cts_del_hdr.cts_delivery;
         tbl_aud_data(var_aidx).tol_shipment := rcd_cts_del_hdr.cts_grouping;
         tbl_aud_data(var_aidx).tol_route := rcd_cts_del_hdr.cts_route;
         tbl_aud_data(var_aidx).tol_load := rcd_cts_del_hdr.cts_load;
         tbl_aud_data(var_aidx).tol_vehicle := rcd_cts_del_hdr.cts_vehicle;

         /*-*/
         /* Retrieve the related sales order information when required
         /*-*/
         var_sap_reject := true;
         if not(rcd_cts_del_hdr.hdr_vbeln is null) then
            open csr_lads_sal_ord_org;
            fetch csr_lads_sal_ord_org into rcd_lads_sal_ord_org;
            if csr_lads_sal_ord_org%found and 
               rcd_lads_sal_ord_org.order_type_sign = '+' then

               /*-*/
               /* Set the SAP header values
               /* **notes** 1. Character values are always set from the first deluvery in the customer/shipment group
               /*           2. Numeric values are always accumulated
               /*-*/
               var_sap_reject := false;
               if var_new_customer = true then
                  var_new_customer := false;
                  tbl_hdr_data(var_hidx).sap_shipment := rcd_cts_del_hdr.hdr_tknum;
                  tbl_hdr_data(var_hidx).sap_delivery := rcd_cts_del_hdr.hdr_vbeln;
                  tbl_hdr_data(var_hidx).sap_pck_date := rcd_cts_del_hdr.hdr_pck_date;
                  tbl_hdr_data(var_hidx).sap_pck_year := substr(to_char(rcd_cts_del_hdr.hdr_pck_yyyyppw,'fm0000000'),1,4);
                  tbl_hdr_data(var_hidx).sap_pck_period := substr(to_char(rcd_cts_del_hdr.hdr_pck_yyyyppw,'fm0000000'),5,2);
                  tbl_hdr_data(var_hidx).sap_pck_week := substr(to_char(rcd_cts_del_hdr.hdr_pck_yyyyppw,'fm0000000'),7,1);
                  tbl_hdr_data(var_hidx).sap_shp_from := rcd_cts_del_hdr.hdr_werks;
                  tbl_hdr_data(var_hidx).sap_shp_to := rcd_cts_del_hdr.hdr_shp_to;
                  tbl_hdr_data(var_hidx).sap_sal_org := rcd_cts_del_hdr.hdr_vkorg;
                  tbl_hdr_data(var_hidx).sap_shp_cond := rcd_cts_del_hdr.hdr_vsbed;
                  tbl_hdr_data(var_hidx).sap_route := rcd_cts_del_hdr.hdr_route;
                  tbl_hdr_data(var_hidx).sap_rte_desc := rcd_cts_del_hdr.hdr_route_bez;
               end if;

               /*-*/
               /* Convert the delivery gross weight (including packaging/including wood)
               /* (convert to KGM kilograms)
               /*-*/
               case rcd_cts_del_hdr.hdr_gewei
                  when 'GRM' then rcd_cts_del_hdr.hdr_btgew := rcd_cts_del_hdr.hdr_btgew / 1000;
                  when 'KGM' then rcd_cts_del_hdr.hdr_btgew := rcd_cts_del_hdr.hdr_btgew;
                  when 'TON' then rcd_cts_del_hdr.hdr_btgew := rcd_cts_del_hdr.hdr_btgew * 1000;
                  else rcd_cts_del_hdr.hdr_btgew := rcd_cts_del_hdr.hdr_btgew;
               end case;

               /*-*/
               /* Convert the delivery volume
               /* (convert to MTQ cubic metres)
               /*-*/
               case rcd_cts_del_hdr.hdr_voleh
                  when 'CMQ' then rcd_cts_del_hdr.hdr_volum := rcd_cts_del_hdr.hdr_volum / 1000000;
                  when 'DMQ' then rcd_cts_del_hdr.hdr_volum := rcd_cts_del_hdr.hdr_volum / 1000;
                  when 'HLT' then rcd_cts_del_hdr.hdr_volum := rcd_cts_del_hdr.hdr_volum / 10;
                  when 'MTQ' then rcd_cts_del_hdr.hdr_volum := rcd_cts_del_hdr.hdr_volum;
                  else rcd_cts_del_hdr.hdr_volum := rcd_cts_del_hdr.hdr_volum;
               end case;

               /*-*/
               /* Accumulate the header/shipment SAP weight and volume
               /*-*/
               tbl_hdr_data(var_hidx).sap_del_tgw := tbl_hdr_data(var_hidx).sap_del_tgw + rcd_cts_del_hdr.hdr_btgew;
               tbl_hdr_data(var_hidx).sap_del_cub := tbl_hdr_data(var_hidx).sap_del_cub + rcd_cts_del_hdr.hdr_volum;
               tbl_shp_data(var_sidx).sap_del_tgw := tbl_shp_data(var_sidx).sap_del_tgw + rcd_cts_del_hdr.hdr_btgew;
               tbl_shp_data(var_sidx).sap_del_cub := tbl_shp_data(var_sidx).sap_del_cub + rcd_cts_del_hdr.hdr_volum;

               /*-*/
               /* Retrieve the delivery detail rows
               /* **notes** 1. only non zero quantity rows are retrieved
               /*-*/
               open csr_lads_del_det;
               loop
                  fetch csr_lads_del_det into rcd_lads_del_det;
                  if csr_lads_del_det%notfound then
                     exit;
                  end if;

                  /*-*/
                  /* Convert the detail gross weight (including packaging/excluding wood)
                  /* (convert to KGM kilograms)
                  /*-*/
                  case rcd_lads_del_det.det_gewei
                     when 'GRM' then rcd_lads_del_det.det_brgew := rcd_lads_del_det.det_brgew / 1000;
                     when 'KGM' then rcd_lads_del_det.det_brgew := rcd_lads_del_det.det_brgew;
                     when 'TON' then rcd_lads_del_det.det_brgew := rcd_lads_del_det.det_brgew * 1000;
                     else rcd_lads_del_det.det_brgew := rcd_lads_del_det.det_brgew;
                  end case;

                  /*-*/
                  /* Convert the detail volume
                  /* (convert to CMQ cubic centimetres)
                  /*-*/
                  case rcd_lads_del_det.det_voleh
                     when 'CMQ' then rcd_lads_del_det.det_volum := rcd_lads_del_det.det_volum / 1000000;
                     when 'DMQ' then rcd_lads_del_det.det_volum := rcd_lads_del_det.det_volum / 1000;
                     when 'HLT' then rcd_lads_del_det.det_volum := rcd_lads_del_det.det_volum / 10;
                     when 'MTQ' then rcd_lads_del_det.det_volum := rcd_lads_del_det.det_volum;
                     else rcd_lads_del_det.det_volum := rcd_lads_del_det.det_volum;
                  end case;

                  /*-*/
                  /* Clear the detail data
                  /*-*/
                  tbl_det_data.delete;

                  /*-*/
                  /* Initialise the detail values
                  /* **note** only using order type sign (+) so no quantity reversal required
                  /*-*/
                  var_didx := tbl_det_data.count + 1;
                  tbl_det_data(var_didx).sap_delivery := tbl_hdr_data(var_hidx).tol_delivery;
                  tbl_det_data(var_didx).sap_708_number := rcd_lads_del_det.det_vbeln;
                  tbl_det_data(var_didx).sap_line_number := rcd_lads_del_det.det_posnr;
                  tbl_det_data(var_didx).sap_material := lads_trim_code(rcd_lads_del_det.det_matnr);
                  tbl_det_data(var_didx).sap_sal_ean := rcd_lads_del_det.det_ean11;
                  tbl_det_data(var_didx).sap_pce_ean := null;
                  tbl_det_data(var_didx).sap_pal_cnt := rcd_lads_del_det.det_pal_base;
                  tbl_det_data(var_didx).sap_fup_cnt := trunc(rcd_lads_del_det.det_pal_base,0);
                  tbl_det_data(var_didx).sap_sal_qty := rcd_lads_del_det.det_lfimg;
                  tbl_det_data(var_didx).sap_sal_tnw := rcd_lads_del_det.det_brgew;
                  tbl_det_data(var_didx).sap_sal_tgw := rcd_lads_del_det.det_brgew + (rcd_lads_del_det.det_pal_base * 50);
                  tbl_det_data(var_didx).sap_sal_cub := rcd_lads_del_det.det_volum;
                  tbl_det_data(var_didx).sap_sal_wgt := 0;
                  tbl_det_data(var_didx).sap_sal_len := 0;
                  tbl_det_data(var_didx).sap_sal_bth := 0;
                  tbl_det_data(var_didx).sap_sal_hgt := 0;
                  tbl_det_data(var_didx).sap_sal_vol := 0;
                  tbl_det_data(var_didx).sap_bas_qty := 0;
                  tbl_det_data(var_didx).sap_bas_wgt := 0;
                  tbl_det_data(var_didx).sap_bas_len := 0;
                  tbl_det_data(var_didx).sap_bas_bth := 0;
                  tbl_det_data(var_didx).sap_bas_hgt := 0;
                  tbl_det_data(var_didx).sap_bas_vol := 0;
                  tbl_det_data(var_didx).sap_pce_qty := 0;
                  tbl_det_data(var_didx).sap_pce_wgt := 0;
                  tbl_det_data(var_didx).sap_pce_len := 0;
                  tbl_det_data(var_didx).sap_pce_bth := 0;
                  tbl_det_data(var_didx).sap_pce_hgt := 0;
                  tbl_det_data(var_didx).sap_pce_vol := 0;
                  tbl_det_data(var_didx).sap_cas_qty := 0;
                  tbl_det_data(var_didx).sap_cas_wgt := 0;
                  tbl_det_data(var_didx).sap_cas_len := 0;
                  tbl_det_data(var_didx).sap_cas_bth := 0;
                  tbl_det_data(var_didx).sap_cas_hgt := 0;
                  tbl_det_data(var_didx).sap_cas_vol := 0;
                  tbl_det_data(var_didx).sap_sal_bps := 0;
                  tbl_det_data(var_didx).sap_sal_gsv := 0;
                  tbl_det_data(var_didx).sap_sal_niv := 0;
                  tbl_det_data(var_didx).sap_sal_cst := 0;

                  /*-*/
                  /* Retrieve the material UOM data
                  /* **notes** SAL = sold UOM
                  /*           BAS = base UOM 
                  /*           PCE = piece UOM
                  /*           CAS = case UOM
                  /*-*/
                  open csr_lads_mat_uom;
                  fetch csr_lads_mat_uom into rcd_lads_mat_uom;
                  if csr_lads_mat_uom%found then

                     /*-*/
                     /* Set the piece ean code
                     /*-*/
                     tbl_det_data(var_didx).sap_pce_ean := rcd_lads_mat_uom.pce_ean11;

                     /*-*/
                     /* Calculate the quantities
                     /*-*/
                     tbl_det_data(var_didx).sap_bas_qty := (tbl_det_data(var_didx).sap_sal_qty * rcd_lads_mat_uom.sal_umrez) / rcd_lads_mat_uom.sal_umren;
                     tbl_det_data(var_didx).sap_pce_qty := (tbl_det_data(var_didx).sap_bas_qty / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;
                     tbl_det_data(var_didx).sap_cas_qty := (tbl_det_data(var_didx).sap_bas_qty / rcd_lads_mat_uom.cas_umrez) * rcd_lads_mat_uom.cas_umren;

                     /*-*/
                     /* Convert the gross weight (including packaging)
                     /* (convert to KGM kilograms)
                     /*-*/
                     case rcd_lads_mat_uom.sal_gewei
                        when 'GRM' then tbl_det_data(var_didx).sap_sal_wgt := rcd_lads_mat_uom.sal_brgew / 1000;
                        when 'KGM' then tbl_det_data(var_didx).sap_sal_wgt := rcd_lads_mat_uom.sal_brgew;
                        when 'TON' then tbl_det_data(var_didx).sap_sal_wgt := rcd_lads_mat_uom.sal_brgew * 1000;
                        else tbl_det_data(var_didx).sap_sal_wgt := rcd_lads_mat_uom.sal_brgew;
                     end case;
                     case rcd_lads_mat_uom.bas_gewei
                        when 'GRM' then tbl_det_data(var_didx).sap_bas_wgt := rcd_lads_mat_uom.bas_brgew / 1000;
                        when 'KGM' then tbl_det_data(var_didx).sap_bas_wgt := rcd_lads_mat_uom.bas_brgew;
                        when 'TON' then tbl_det_data(var_didx).sap_bas_wgt := rcd_lads_mat_uom.bas_brgew * 1000;
                        else tbl_det_data(var_didx).sap_bas_wgt := rcd_lads_mat_uom.bas_brgew;
                     end case;
                     case rcd_lads_mat_uom.pce_gewei
                        when 'GRM' then tbl_det_data(var_didx).sap_pce_wgt := rcd_lads_mat_uom.pce_brgew / 1000;
                        when 'KGM' then tbl_det_data(var_didx).sap_pce_wgt := rcd_lads_mat_uom.pce_brgew;
                        when 'TON' then tbl_det_data(var_didx).sap_pce_wgt := rcd_lads_mat_uom.pce_brgew * 1000;
                        else tbl_det_data(var_didx).sap_pce_wgt := rcd_lads_mat_uom.pce_brgew;
                     end case;
                     case rcd_lads_mat_uom.cas_gewei
                        when 'GRM' then tbl_det_data(var_didx).sap_cas_wgt := rcd_lads_mat_uom.cas_brgew / 1000;
                        when 'KGM' then tbl_det_data(var_didx).sap_cas_wgt := rcd_lads_mat_uom.cas_brgew;
                        when 'TON' then tbl_det_data(var_didx).sap_cas_wgt := rcd_lads_mat_uom.cas_brgew * 1000;
                        else tbl_det_data(var_didx).sap_cas_wgt := rcd_lads_mat_uom.cas_brgew;
                     end case;

                     /*-*/
                     /* Convert the material dimensions
                     /* (convert to MMT millimetres)
                     /*-*/
                     case rcd_lads_mat_uom.sal_meabm
                        when 'MMT' then
                           tbl_det_data(var_didx).sap_sal_len := rcd_lads_mat_uom.sal_laeng;
                           tbl_det_data(var_didx).sap_sal_bth := rcd_lads_mat_uom.sal_breit;
                           tbl_det_data(var_didx).sap_sal_hgt := rcd_lads_mat_uom.sal_hoehe;
                        when 'CMT' then
                           tbl_det_data(var_didx).sap_sal_len := rcd_lads_mat_uom.sal_laeng * 10;
                           tbl_det_data(var_didx).sap_sal_bth := rcd_lads_mat_uom.sal_breit * 10;
                           tbl_det_data(var_didx).sap_sal_hgt := rcd_lads_mat_uom.sal_hoehe * 10;
                        when 'MTR' then
                           tbl_det_data(var_didx).sap_sal_len := rcd_lads_mat_uom.sal_laeng * 1000;
                           tbl_det_data(var_didx).sap_sal_bth := rcd_lads_mat_uom.sal_breit * 1000;
                           tbl_det_data(var_didx).sap_sal_hgt := rcd_lads_mat_uom.sal_hoehe * 1000;
                        else
                           tbl_det_data(var_didx).sap_sal_len := rcd_lads_mat_uom.sal_laeng;
                           tbl_det_data(var_didx).sap_sal_bth := rcd_lads_mat_uom.sal_breit;
                           tbl_det_data(var_didx).sap_sal_hgt := rcd_lads_mat_uom.sal_hoehe;
                     end case;
                     case rcd_lads_mat_uom.bas_meabm
                        when 'MMT' then
                           tbl_det_data(var_didx).sap_bas_len := rcd_lads_mat_uom.bas_laeng;
                           tbl_det_data(var_didx).sap_bas_bth := rcd_lads_mat_uom.bas_breit;
                           tbl_det_data(var_didx).sap_bas_hgt := rcd_lads_mat_uom.bas_hoehe;
                        when 'CMT' then
                           tbl_det_data(var_didx).sap_bas_len := rcd_lads_mat_uom.bas_laeng * 10;
                           tbl_det_data(var_didx).sap_bas_bth := rcd_lads_mat_uom.bas_breit * 10;
                           tbl_det_data(var_didx).sap_bas_hgt := rcd_lads_mat_uom.bas_hoehe * 10;
                        when 'MTR' then
                           tbl_det_data(var_didx).sap_bas_len := rcd_lads_mat_uom.bas_laeng * 1000;
                           tbl_det_data(var_didx).sap_bas_bth := rcd_lads_mat_uom.bas_breit * 1000;
                           tbl_det_data(var_didx).sap_bas_hgt := rcd_lads_mat_uom.bas_hoehe * 1000;
                        else
                           tbl_det_data(var_didx).sap_bas_len := rcd_lads_mat_uom.bas_laeng;
                           tbl_det_data(var_didx).sap_bas_bth := rcd_lads_mat_uom.bas_breit;
                           tbl_det_data(var_didx).sap_bas_hgt := rcd_lads_mat_uom.bas_hoehe;
                     end case;
                     case rcd_lads_mat_uom.pce_meabm
                        when 'MMT' then
                           tbl_det_data(var_didx).sap_pce_len := rcd_lads_mat_uom.pce_laeng;
                           tbl_det_data(var_didx).sap_pce_bth := rcd_lads_mat_uom.pce_breit;
                           tbl_det_data(var_didx).sap_pce_hgt := rcd_lads_mat_uom.pce_hoehe;
                        when 'CMT' then
                           tbl_det_data(var_didx).sap_pce_len := rcd_lads_mat_uom.pce_laeng * 10;
                           tbl_det_data(var_didx).sap_pce_bth := rcd_lads_mat_uom.pce_breit * 10;
                           tbl_det_data(var_didx).sap_pce_hgt := rcd_lads_mat_uom.pce_hoehe * 10;
                        when 'MTR' then
                           tbl_det_data(var_didx).sap_pce_len := rcd_lads_mat_uom.pce_laeng * 1000;
                           tbl_det_data(var_didx).sap_pce_bth := rcd_lads_mat_uom.pce_breit * 1000;
                           tbl_det_data(var_didx).sap_pce_hgt := rcd_lads_mat_uom.pce_hoehe * 1000;
                        else
                           tbl_det_data(var_didx).sap_pce_len := rcd_lads_mat_uom.pce_laeng;
                           tbl_det_data(var_didx).sap_pce_bth := rcd_lads_mat_uom.pce_breit;
                           tbl_det_data(var_didx).sap_pce_hgt := rcd_lads_mat_uom.pce_hoehe;
                     end case;
                     case rcd_lads_mat_uom.cas_meabm
                        when 'MMT' then
                           tbl_det_data(var_didx).sap_cas_len := rcd_lads_mat_uom.cas_laeng;
                           tbl_det_data(var_didx).sap_cas_bth := rcd_lads_mat_uom.cas_breit;
                           tbl_det_data(var_didx).sap_cas_hgt := rcd_lads_mat_uom.cas_hoehe;
                        when 'CMT' then
                           tbl_det_data(var_didx).sap_cas_len := rcd_lads_mat_uom.cas_laeng * 10;
                           tbl_det_data(var_didx).sap_cas_bth := rcd_lads_mat_uom.cas_breit * 10;
                           tbl_det_data(var_didx).sap_cas_hgt := rcd_lads_mat_uom.cas_hoehe * 10;
                        when 'MTR' then
                           tbl_det_data(var_didx).sap_cas_len := rcd_lads_mat_uom.cas_laeng * 1000;
                           tbl_det_data(var_didx).sap_cas_bth := rcd_lads_mat_uom.cas_breit * 1000;
                           tbl_det_data(var_didx).sap_cas_hgt := rcd_lads_mat_uom.cas_hoehe * 1000;
                        else
                           tbl_det_data(var_didx).sap_cas_len := rcd_lads_mat_uom.cas_laeng;
                           tbl_det_data(var_didx).sap_cas_bth := rcd_lads_mat_uom.cas_breit;
                           tbl_det_data(var_didx).sap_cas_hgt := rcd_lads_mat_uom.cas_hoehe;
                     end case;

                     /*-*/
                     /* Convert the material volume
                     /* (convert to CMQ cubic centimetres)
                     /*-*/
                     case rcd_lads_mat_uom.sal_voleh
                        when 'CMQ' then tbl_det_data(var_didx).sap_sal_vol := rcd_lads_mat_uom.sal_volum / 1000000;
                        when 'DMQ' then tbl_det_data(var_didx).sap_sal_vol := rcd_lads_mat_uom.sal_volum / 1000;
                        when 'HLT' then tbl_det_data(var_didx).sap_sal_vol := rcd_lads_mat_uom.sal_volum / 10;
                        when 'MTQ' then tbl_det_data(var_didx).sap_sal_vol := rcd_lads_mat_uom.sal_volum;
                        else tbl_det_data(var_didx).sap_sal_vol := rcd_lads_mat_uom.sal_volum;
                     end case;
                     case rcd_lads_mat_uom.bas_voleh
                        when 'CMQ' then tbl_det_data(var_didx).sap_bas_vol := rcd_lads_mat_uom.bas_volum / 1000000;
                        when 'DMQ' then tbl_det_data(var_didx).sap_bas_vol := rcd_lads_mat_uom.bas_volum / 1000;
                        when 'HLT' then tbl_det_data(var_didx).sap_bas_vol := rcd_lads_mat_uom.bas_volum / 10;
                        when 'MTQ' then tbl_det_data(var_didx).sap_bas_vol := rcd_lads_mat_uom.bas_volum;
                        else tbl_det_data(var_didx).sap_bas_vol := rcd_lads_mat_uom.bas_volum;
                     end case;
                     case rcd_lads_mat_uom.pce_voleh
                        when 'CMQ' then tbl_det_data(var_didx).sap_pce_vol := rcd_lads_mat_uom.pce_volum / 1000000;
                        when 'DMQ' then tbl_det_data(var_didx).sap_pce_vol := rcd_lads_mat_uom.pce_volum / 1000;
                        when 'HLT' then tbl_det_data(var_didx).sap_pce_vol := rcd_lads_mat_uom.pce_volum / 10;
                        when 'MTQ' then tbl_det_data(var_didx).sap_pce_vol := rcd_lads_mat_uom.pce_volum;
                        else tbl_det_data(var_didx).sap_pce_vol := rcd_lads_mat_uom.pce_volum;
                     end case;
                     case rcd_lads_mat_uom.cas_voleh
                        when 'CMQ' then tbl_det_data(var_didx).sap_cas_vol := rcd_lads_mat_uom.cas_volum / 1000000;
                        when 'DMQ' then tbl_det_data(var_didx).sap_cas_vol := rcd_lads_mat_uom.cas_volum / 1000;
                        when 'HLT' then tbl_det_data(var_didx).sap_cas_vol := rcd_lads_mat_uom.cas_volum / 10;
                        when 'MTQ' then tbl_det_data(var_didx).sap_cas_vol := rcd_lads_mat_uom.cas_volum;
                        else tbl_det_data(var_didx).sap_cas_vol := rcd_lads_mat_uom.cas_volum;
                     end case;

                  end if;
                  close csr_lads_mat_uom;

                  /*-*/
                  /* Calculate the detail cost value
                  /*-*/
                  open csr_lads_mat_mbe;
                  fetch csr_lads_mat_mbe into rcd_lads_mat_mbe;
                  if csr_lads_mat_mbe%notfound then
                     rcd_lads_mat_mbe.peinh := 1;
                     rcd_lads_mat_mbe.stprs := 0;
                  end if;
                  close csr_lads_mat_mbe;
                  tbl_det_data(var_didx).sap_sal_cst := (rcd_lads_del_det.det_lgmng / rcd_lads_mat_mbe.peinh) * rcd_lads_mat_mbe.stprs;

                  /*-*/
                  /* Retrieve the related sales order line data
                  /*-*/
                  open csr_lads_sal_ord_gen;
                  fetch csr_lads_sal_ord_gen into rcd_lads_sal_ord_gen;
                  if csr_lads_sal_ord_gen%found then

                     /*-*/
                     /* Retrieve the sales order line valuation when required
                     /* **note** only using order type sign (+) so no value reversal required
                     /*-*/
                     if rcd_lads_sal_ord_gen.menge != 0 then
                        open csr_lads_sal_ord_ico;
                        fetch csr_lads_sal_ord_ico into rcd_lads_sal_ord_ico;
                        if csr_lads_sal_ord_ico%found then
                           tbl_det_data(var_didx).sap_sal_bps := (rcd_lads_sal_ord_ico.bps_value / rcd_lads_sal_ord_gen.menge) * tbl_det_data(var_didx).sap_sal_qty;
                           tbl_det_data(var_didx).sap_sal_gsv := (rcd_lads_sal_ord_ico.gsv_value / rcd_lads_sal_ord_gen.menge) * tbl_det_data(var_didx).sap_sal_qty;
                           tbl_det_data(var_didx).sap_sal_niv := (rcd_lads_sal_ord_ico.niv_value / rcd_lads_sal_ord_gen.menge) * tbl_det_data(var_didx).sap_sal_qty;
                        end if;
                        close csr_lads_sal_ord_ico;
                     end if;

                  end if;
                  close csr_lads_sal_ord_gen;

                  /*-*/
                  /* Append the detail record
                  /*-*/
                  var_output := tbl_det_data(var_didx).sap_delivery || con_separator;
                  var_output := var_output || tbl_det_data(var_didx).sap_708_number || con_separator;
                  var_output := var_output || tbl_det_data(var_didx).sap_line_number || con_separator;
                  var_output := var_output || tbl_det_data(var_didx).sap_material || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).tol_dsp_date || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).tol_shipment || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).sap_shp_from || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).sap_shp_to || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).sap_sal_org || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).tol_dsp_year || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).tol_dsp_period || con_separator;
                  var_output := var_output || tbl_hdr_data(var_hidx).tol_dsp_week || con_separator;
                  var_output := var_output || tbl_det_data(var_didx).sap_sal_ean || con_separator;
                  var_output := var_output || tbl_det_data(var_didx).sap_pce_ean || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_pce_qty,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_cas_qty,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_pal_cnt,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_fup_cnt,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_cub,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_tnw,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_tgw,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_bps,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_gsv,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_niv,5) || con_separator;
                  var_output := var_output || round(tbl_det_data(var_didx).sap_sal_cst,5);
                  tbl_det_outp(tbl_det_outp.count + 1) := var_output;

                  /*-*/
                  /* Accumulate the header SAP values
                  /*-*/
                  tbl_hdr_data(var_hidx).sap_lin_cnt := tbl_hdr_data(var_hidx).sap_lin_cnt + 1;
                  tbl_hdr_data(var_hidx).sap_pal_cnt := tbl_hdr_data(var_hidx).sap_pal_cnt + tbl_det_data(var_didx).sap_pal_cnt;
                  tbl_hdr_data(var_hidx).sap_fup_cnt := tbl_hdr_data(var_hidx).sap_fup_cnt + tbl_det_data(var_didx).sap_fup_cnt;
                  tbl_hdr_data(var_hidx).sap_sal_qty := tbl_hdr_data(var_hidx).sap_sal_qty + tbl_det_data(var_didx).sap_sal_qty;
                  tbl_hdr_data(var_hidx).sap_sal_tnw := tbl_hdr_data(var_hidx).sap_sal_tnw + tbl_det_data(var_didx).sap_sal_tnw;
                  tbl_hdr_data(var_hidx).sap_sal_tgw := tbl_hdr_data(var_hidx).sap_sal_tgw + tbl_det_data(var_didx).sap_sal_tgw;
                  tbl_hdr_data(var_hidx).sap_sal_cub := tbl_hdr_data(var_hidx).sap_sal_cub + tbl_det_data(var_didx).sap_sal_cub;
                  tbl_hdr_data(var_hidx).sap_bas_qty := tbl_hdr_data(var_hidx).sap_bas_qty + tbl_det_data(var_didx).sap_bas_qty;
                  tbl_hdr_data(var_hidx).sap_pce_qty := tbl_hdr_data(var_hidx).sap_pce_qty + tbl_det_data(var_didx).sap_pce_qty;
                  tbl_hdr_data(var_hidx).sap_cas_qty := tbl_hdr_data(var_hidx).sap_cas_qty + tbl_det_data(var_didx).sap_cas_qty;

                  /*-*/
                  /* Accumulate the shipment SAP values
                  /*-*/
                  tbl_shp_data(var_sidx).sap_lin_cnt := tbl_shp_data(var_sidx).sap_lin_cnt + 1;
                  tbl_shp_data(var_sidx).sap_pal_cnt := tbl_shp_data(var_sidx).sap_pal_cnt + tbl_det_data(var_didx).sap_pal_cnt;
                  tbl_shp_data(var_sidx).sap_fup_cnt := tbl_shp_data(var_sidx).sap_fup_cnt + tbl_det_data(var_didx).sap_fup_cnt;
                  tbl_shp_data(var_sidx).sap_sal_qty := tbl_shp_data(var_sidx).sap_sal_qty + tbl_det_data(var_didx).sap_sal_qty;
                  tbl_shp_data(var_sidx).sap_sal_tnw := tbl_shp_data(var_sidx).sap_sal_tnw + tbl_det_data(var_didx).sap_sal_tnw;
                  tbl_shp_data(var_sidx).sap_sal_tgw := tbl_shp_data(var_sidx).sap_sal_tgw + tbl_det_data(var_didx).sap_sal_tgw;
                  tbl_shp_data(var_sidx).sap_sal_cub := tbl_shp_data(var_sidx).sap_sal_cub + tbl_det_data(var_didx).sap_sal_cub;
                  tbl_shp_data(var_sidx).sap_bas_qty := tbl_shp_data(var_sidx).sap_bas_qty + tbl_det_data(var_didx).sap_bas_qty;
                  tbl_shp_data(var_sidx).sap_pce_qty := tbl_shp_data(var_sidx).sap_pce_qty + tbl_det_data(var_didx).sap_pce_qty;
                  tbl_shp_data(var_sidx).sap_cas_qty := tbl_shp_data(var_sidx).sap_cas_qty + tbl_det_data(var_didx).sap_cas_qty;

                  /*-*/
                  /* Substitute the SAP delivery gross weight for the Tolas delivery gross weight when required
                  /*-*/
                  if rcd_cts_del_hdr.cts_del_tgw is null or rcd_cts_del_hdr.cts_del_tgw = 0 then
                     tbl_hdr_data(var_hidx).tol_del_tgw := tbl_hdr_data(var_hidx).tol_del_tgw + tbl_det_data(var_didx).sap_sal_tgw;
                     tbl_shp_data(var_sidx).tol_del_tgw := tbl_shp_data(var_sidx).tol_del_tgw + tbl_det_data(var_didx).sap_sal_tgw;
                  end if;

               end loop;
               close csr_lads_del_det;

            end if;
            close csr_lads_sal_ord_org;
         end if;

         /*-*/
         /* Output the Tolas data when required
         /*-*/
         var_output := 'HDR' || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_delivery || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_shipment || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_dsp_date || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_route || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_load || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_carrier || con_separator;
         var_output := var_output || rcd_cts_del_hdr.cts_vehicle || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_shp_fup,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_shp_pal,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_shp_cas,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_del_pal,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_del_fup,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_del_eps,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_del_cas,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_del_cub,5) || con_separator;
         var_output := var_output || round(rcd_cts_del_hdr.cts_del_tgw,5);
         tbl_tod_outp(tbl_tod_outp.count + 1) := var_output;

         /*-*/
         /* Output the Tolas rejects when required
         /*-*/
         if var_sap_reject = true then
            var_output := 'HDR' || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_delivery || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_shipment || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_dsp_date || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_route || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_load || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_carrier || con_separator;
            var_output := var_output || rcd_cts_del_hdr.cts_vehicle || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_shp_fup,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_shp_pal,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_shp_cas,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_del_pal,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_del_fup,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_del_eps,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_del_cas,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_del_cub,5) || con_separator;
            var_output := var_output || round(rcd_cts_del_hdr.cts_del_tgw,5);
            tbl_tor_outp(tbl_tor_outp.count + 1) := var_output;
         end if;

      end loop;
      close csr_cts_del_hdr;

      /*-*/
      /* Output the last grouping when required
      /*-*/
      if var_sav_grouping != '**START**' then

         /*-*/
         /* Append the previous audit records when required
         /*-*/
         if var_aud_flag = true then
            for idx in 1..tbl_aud_data.count loop
               var_output := tbl_aud_data(idx).tol_delivery || con_separator;
               var_output := var_output || tbl_aud_data(idx).sap_708_number || con_separator;
               var_output := var_output || tbl_aud_data(idx).tol_shipment || con_separator;
               var_output := var_output || tbl_aud_data(idx).tol_route || con_separator;
               var_output := var_output || tbl_aud_data(idx).tol_load || con_separator;
               var_output := var_output || tbl_aud_data(idx).tol_vehicle;
               tbl_toa_outp(tbl_toa_outp.count + 1) := var_output;
            end loop;
         end if;

         /*-*/
         /* Append the header records
         /*-*/
         for idx in 1..tbl_hdr_data.count loop
            if not(tbl_hdr_data(idx).sap_delivery is null) then
               var_output := tbl_hdr_data(idx).tol_delivery || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_dsp_date || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_pck_date || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_dsp_year || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_dsp_period || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_dsp_week || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_shipment || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_shipment || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_load || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_shp_from || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_carrier || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_int_node1 || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_int_node2 || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_int_node3 || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_shp_to || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_sal_org || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_route || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_route || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_rte_desc || con_separator;
               var_output := var_output || tbl_shp_data(var_sidx).sap_del_cnt || con_separator;
               var_output := var_output || tbl_shp_data(var_sidx).sap_lin_cnt || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).tol_shp_pal,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).sap_pal_cnt,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).tol_shp_fup,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).tol_del_eps,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).tol_shp_cas,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).sap_cas_qty,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).tol_del_cub,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).sap_sal_cub,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).sap_sal_tnw,5) || con_separator;
               var_output := var_output || round(tbl_shp_data(var_sidx).tol_del_tgw,5) || con_separator;
               var_output := var_output || tbl_shp_data(var_sidx).sap_type || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_lin_cnt || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).tol_del_pal,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).sap_pal_cnt,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).tol_del_fup,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).tol_del_eps,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).tol_del_cas,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).sap_cas_qty,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).sap_sal_cub,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).sap_sal_tnw,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).sap_sal_tgw,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).tol_del_tgw,5) || con_separator;
               var_output := var_output || round(tbl_hdr_data(idx).tol_del_cub,5) || con_separator;
               var_output := var_output || tbl_hdr_data(idx).tol_vehicle || con_separator;
               var_output := var_output || tbl_hdr_data(idx).sap_shp_cond;
               tbl_hdr_outp(tbl_hdr_outp.count + 1) := var_output;
            end if;
         end loop;

      end if;

      /*-*/
      /* Create the delivery header interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS01','Delivery_'||to_char(par_str_date,'yyyymmdd')||'_'||to_char(par_end_date,'yyyymmdd')||'.txt');
      lics_outbound_loader.append_data(con_hdr_heading);
      for idx in 1..tbl_hdr_outp.count loop
         lics_outbound_loader.append_data(tbl_hdr_outp(idx));
      end loop;
      var_output := to_char(tbl_hdr_outp.count);
      for idx in 1..45 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* Create the delivery detail interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS02','LineItem_'||to_char(par_str_date,'yyyymmdd')||'_'||to_char(par_end_date,'yyyymmdd')||'.txt');
      lics_outbound_loader.append_data(con_det_heading);
      for idx in 1..tbl_det_outp.count loop
         lics_outbound_loader.append_data(tbl_det_outp(idx));
      end loop;
      var_output := to_char(tbl_det_outp.count);
      for idx in 1..24 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* Create the tolas data interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS06','TolasData_'||to_char(par_str_date,'yyyymmdd')||'_'||to_char(par_end_date,'yyyymmdd')||'.txt');
      lics_outbound_loader.append_data(con_tol_heading);
      for idx in 1..tbl_tod_outp.count loop
         lics_outbound_loader.append_data(tbl_tod_outp(idx));
      end loop;
      var_output := 'TRL'||con_separator||to_char(tbl_tod_outp.count);
      for idx in 1..15 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* Create the tolas reject interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS07','TolasReject_'||to_char(par_str_date,'yyyymmdd')||'_'||to_char(par_end_date,'yyyymmdd')||'.txt');
      lics_outbound_loader.append_data(con_tol_heading);
      for idx in 1..tbl_tor_outp.count loop
         lics_outbound_loader.append_data(tbl_tor_outp(idx));
      end loop;
      var_output := 'TRL'||con_separator||to_char(tbl_tor_outp.count)||con_separator||to_char(tbl_tod_outp.count);
      for idx in 1..14 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* Create the tolas audit interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS08','TolasAudit_'||to_char(par_str_date,'yyyymmdd')||'_'||to_char(par_end_date,'yyyymmdd')||'.txt');
      lics_outbound_loader.append_data(con_aud_heading);
      for idx in 1..tbl_toa_outp.count loop
         lics_outbound_loader.append_data(tbl_toa_outp(idx));
      end loop;
      var_output := to_char(tbl_toa_outp.count);
      for idx in 1..5 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - CTS Extract - Extract delivery');

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - CTS Extract - Extract delivery - ' || var_exception);
            lics_logging.write_log('End - CTS Extract - Extract delivery');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_delivery;

   /********************************************************/
   /* This procedure performs the extract material routine */
   /********************************************************/
   procedure extract_material is

      /*-*/
      /* Local constants
      /*-*/
      con_mat_heading constant varchar2(4000) := 'TDU' || con_separator ||
                                                 'EAN11' || con_separator ||
                                                 'EAN13' || con_separator ||
                                                 'ProductName' || con_separator ||
                                                 'UnitsPerCase' || con_separator ||
                                                 'UnitsPerInner' || con_separator ||
                                                 'CaseLength' || con_separator ||
                                                 'CaseWidth' || con_separator ||
                                                 'CaseHeight' || con_separator ||
                                                 'CaseVolume' || con_separator ||
                                                 'CaseWeight' || con_separator ||
                                                 'Brand' || con_separator ||
                                                 'MarsCategory' || con_separator ||
                                                 'FightingUnit' || con_separator ||
                                                 'PackSize' || con_separator ||
                                                 'PackFormat' || con_separator ||
                                                 'RetailUnitVolume' || con_separator ||
                                                 'RetailUnitWeight' || con_separator ||
                                                 'TopLoadOnly' || con_separator ||
                                                 'UnitPickType';
      con_loc_heading constant varchar2(4000) := 'ShipFrom' || con_separator ||
                                                 'TDU' || con_separator ||
                                                 'SalesOrganisation' || con_separator ||
                                                 'EffectiveFromDate' || con_separator ||
                                                 'CasesPerPallet' || con_separator ||
                                                 'CasesPerLayer' || con_separator ||
                                                 'LayersPerPallet' || con_separator ||
                                                 'DaysOfCover';

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(4000);
      type rcd_mat_data is record(matnr varchar2(128 char),
                                  ean11 varchar2(128 char),
                                  stfak varchar2(128 char),
                                  name varchar2(128 char),
                                  brand varchar2(128 char),
                                  category varchar2(128 char),
                                  fighting varchar2(128 char),
                                  pck_size varchar2(128 char),
                                  pck_format varchar2(128 char),
                                  top_load varchar2(128 char),
                                  unt_pick varchar2(128 char),
                                  pce_ean varchar2(128 char),
                                  tdu_rez number,
                                  tdu_ren number,
                                  mcu_cnt number,
                                  rsu_cnt number,
                                  bas_qty number,
                                  bas_wgt number,
                                  bas_len number,
                                  bas_bth number,
                                  bas_hgt number,
                                  bas_vol number,
                                  pce_qty number,
                                  pce_wgt number,
                                  pce_len number,
                                  pce_bth number,
                                  pce_hgt number,
                                  pce_vol number,
                                  cas_qty number,
                                  cas_wgt number,
                                  cas_len number,
                                  cas_bth number,
                                  cas_hgt number,
                                  cas_vol number);
      type rcd_loc_data is record(sal_org varchar2(128 char),
                                  str_dat varchar2(128 char),
                                  end_dat varchar2(128 char),
                                  cas_pal number,
                                  cas_lay number,
                                  lay_pal number);
      type typ_mat_data is table of rcd_mat_data index by binary_integer;
      type typ_loc_data is table of rcd_loc_data index by binary_integer;
      type typ_mat_outp is table of varchar2(4000) index by binary_integer;
      type typ_loc_outp is table of varchar2(4000) index by binary_integer;
      tbl_mat_data typ_mat_data;
      tbl_loc_data typ_loc_data;
      tbl_mat_outp typ_mat_outp;
      tbl_loc_outp typ_loc_outp;
      var_midx number;
      var_lidx number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_hdr is
         select t01.matnr as mat_matnr,
                t01.meins as mat_meins,
                t01.gewei as mat_gewei,
                t01.ntgew as mat_ntgew,
                t01.brgew as mat_brgew,
                t01.voleh as mat_voleh,
                t01.volum as mat_volum,
                t01.ean11 as mat_ean11,
                t01.stfak as mat_stfak,
                nvl(t02.maktx,'UNKNOWN') as mat_desc,
                nvl(t04.brand_flag_desc,'UNKNOWN') as brn_desc,
                nvl(t05.sap_prdct_ctgry_desc,'UNKNOWN') as cat_desc,
                nvl(t06.sap_prdct_pack_size_desc,'UNKNOWN') as psz_desc,
                nvl(t07.sap_cnsmr_pack_frmt_desc,'UNKNOWN') as pfm_desc,
                nvl(t08.sap_fighting_desc,'UNKNOWN') as fgt_desc
           from lads_mat_hdr t01,
                (select t21.matnr,
                        t21.maktx
                   from lads_mat_mkt t21
                  where t21.spras_iso = 'EN') t02,
                (select t21.objek as matnr,
                        max(case when t22.atnam = 'CLFFERT03' then t22.atwrt end) as sap_brand_flag_code,
                        max(case when t22.atnam = 'CLFFERT12' then t22.atwrt end) as sap_prdct_ctgry_code,
                        max(case when t22.atnam = 'CLFFERT14' then t22.atwrt end) as sap_prdct_pack_size_code,
                        max(case when t22.atnam = 'CLFFERT25' then t22.atwrt end) as sap_cnsmr_pack_frmt_code,
                        max(case when t22.atnam = 'Z_APCHAR6' then t22.atwrt end) as sap_fighting_code
                   from lads_cla_hdr t21,
                        lads_cla_chr t22
                  where t21.obtab = 'MARA'
                    and t21.klart = '001'
                    and t21.obtab = t22.obtab(+)
                    and t21.klart = t22.klart(+)
                    and t21.objek = t22.objek(+)
                  group by t21.objek) t03,
                (select substr(t01.z_data,4,3) as sap_brand_flag_code,
                        substr(t01.z_data,19,30) as brand_flag_desc
                   from lads_ref_dat t01
                  where t01.z_tabname = '/MARS/MD_CHC003') t04,
                (select substr(t01.z_data,4,2) as sap_prdct_ctgry_code,
                        substr(t01.z_data,18,30) as sap_prdct_ctgry_desc
                   from lads_ref_dat t01
                   where t01.z_tabname = '/MARS/MD_CHC012') t05,
                (select substr(t01.z_data,4,3) as sap_prdct_pack_size_code,
                        substr(t01.z_data,19,30) as sap_prdct_pack_size_desc
                   from lads_ref_dat t01
                  where t01.z_tabname = '/MARS/MD_CHC014') t06,
                (select substr(t01.z_data,4,2) as sap_cnsmr_pack_frmt_code,
                        substr(t01.z_data,18,30) as sap_cnsmr_pack_frmt_desc
                   from lads_ref_dat t01
                  where t01.z_tabname = '/MARS/MD_CHC025') t07,
                (select t01.atwrt as sap_fighting_code,
                        t02.atwtb as sap_fighting_desc
                   from lads_chr_mas_val t01,
                        lads_chr_mas_dsc t02
                  where t01.atnam = t02.atnam(+)
                    and t01.valseq = t02.valseq(+)
                    and t01.atnam = 'Z_APCHAR6'
                    and t02.spras = 'E') t08
          where t01.matnr = t02.matnr(+)
            and t01.matnr = t03.matnr(+)
            and t03.sap_brand_flag_code = t04.sap_brand_flag_code(+)
            and t03.sap_prdct_ctgry_code = t05.sap_prdct_ctgry_code(+)
            and t03.sap_prdct_pack_size_code = t06.sap_prdct_pack_size_code(+)
            and t03.sap_cnsmr_pack_frmt_code = t07.sap_cnsmr_pack_frmt_code(+)
            and t03.sap_fighting_code = t08.sap_fighting_code(+)
            and t01.mtart = 'FERT'
            and t01.zzistdu = 'X'
          order by t01.matnr asc;
      rcd_lads_mat_hdr csr_lads_mat_hdr%rowtype;

      cursor csr_lads_mat_lvl is
         select t01.matnr as matnr,
                t01.umrez as tdu_umrez,
                t01.umren as tdu_umren,
                t01.meinh as tdu_meinh,
                decode(t02.rsu_meinh,null,null,t02.mcu_meinh) as mcu_meinh,
                decode(t02.rsu_meinh,null,t02.mcu_meinh,t02.rsu_meinh) as rsu_meinh,
                decode(t01.umrez,1,t01.umrez,t01.umren) as tdu_count,
                decode(t02.rsu_meinh,null,1,decode(t01.umrez,1,t02.mcu_umren,t01.umrez*t02.mcu_umren)) as mcu_count,
                decode(t02.rsu_meinh,null,decode(t01.umrez,1,t02.mcu_umren,t01.umrez*t02.mcu_umren),decode(t01.umrez,1,t02.rsu_umren,t01.umrez*t02.rsu_umren)) as rsu_count,
                t01.ean11 as tdu_ean11,
                decode(t02.rsu_meinh,null,null,t02.mcu_ean11) as mcu_ean11,
                decode(t02.rsu_meinh,null,t02.mcu_ean11,t02.rsu_ean11) as rsu_ean11
           from (select t01.matnr,
                        t01.meinh,
                        nvl(t01.umren,1) as umren,
                        nvl(t01.umrez,1) as umrez,
                        t01.ean11
                   from lads_mat_uom t01
                  where t01.meinh = 'CS') t01,
                (select t01.matnr as matnr,
                        nvl(max(decode(t01.rnkseq,1,t01.umren)),0) as mcu_umrez,
                        nvl(max(decode(t01.rnkseq,1,t01.umren)),0) as mcu_umren,
                        max(decode(t01.rnkseq,1,t01.meinh)) as mcu_meinh,
                        max(decode(t01.rnkseq,1,t01.ean11)) as mcu_ean11,
                        nvl(max(decode(t01.rnkseq,2,t01.umrez)),0) as rsu_umrez,
                        nvl(max(decode(t01.rnkseq,2,t01.umren)),0) as rsu_umren,
                        max(decode(t01.rnkseq,2,t01.meinh)) as rsu_meinh,
                        max(decode(t01.rnkseq,2,t01.ean11)) as rsu_ean11
                   from (select t01.matnr as matnr,
                                t01.rnkseq as rnkseq,
                                max(t01.meinh) as meinh,
                                max(t01.umren) as umren,
                                max(t01.umrez) as umrez,
                                max(t01.ean11) as ean11
                           from (select t01.matnr,
                                        t01.meinh,
                                        t01.umren,
                                        t01.umrez,
                                        t01.ean11,
                                        dense_rank() over (partition by t01.matnr order by t01.umren asc) as rnkseq
                                   from lads_mat_uom t01
                                  where t01.meinh != 'EA'
                                    and t01.meinh != 'CS'
                                    and t01.umrez = 1) t01
                          group by t01.matnr,
                                   t01.rnkseq) t01
                  group by t01.matnr) t02
          where t01.matnr = t02.matnr(+)
            and t01.matnr = rcd_lads_mat_hdr.mat_matnr;
      rcd_lads_mat_lvl csr_lads_mat_lvl%rowtype;

      cursor csr_lads_mat_uom is
         select nvl(t01.ntgew,0) as mat_ntgew,
                nvl(t02.umren,1) as bas_umren,
                nvl(t02.umrez,1) as bas_umrez,
                nvl(t02.brgew,0) as bas_brgew,
                t02.gewei as bas_gewei,
                nvl(t02.laeng,0) as bas_laeng,
                nvl(t02.breit,0) as bas_breit,
                nvl(t02.hoehe,0) as bas_hoehe,
                t02.meabm as bas_meabm,
                nvl(t02.volum,0) as bas_volum,
                t02.voleh as bas_voleh,
                t02.ean11 as bas_ean11,
                nvl(t03.umren,1) as pce_umren,
                nvl(t03.umrez,1) as pce_umrez,
                nvl(t03.brgew,0) as pce_brgew,
                t03.gewei as pce_gewei,
                nvl(t03.laeng,0) as pce_laeng,
                nvl(t03.breit,0) as pce_breit,
                nvl(t03.hoehe,0) as pce_hoehe,
                t03.meabm as pce_meabm,
                nvl(t03.volum,0) as pce_volum,
                t03.voleh as pce_voleh,
                t03.ean11 as pce_ean11,
                nvl(t04.umren,1) as cas_umren,
                nvl(t04.umrez,1) as cas_umrez,
                nvl(t04.brgew,0) as cas_brgew,
                t04.gewei as cas_gewei,
                nvl(t04.laeng,0) as cas_laeng,
                nvl(t04.breit,0) as cas_breit,
                nvl(t04.hoehe,0) as cas_hoehe,
                t04.meabm as cas_meabm,
                nvl(t04.volum,0) as cas_volum,
                t04.voleh as cas_voleh,
                t04.ean11 as cas_ean11
           from lads_mat_hdr t01,
                (select t21.matnr,
                        t21.umren,
                        t21.umrez,
                        t21.brgew,
                        t21.gewei,
                        t21.laeng,
                        t21.breit,
                        t21.hoehe,
                        t21.meabm,
                        t21.volum,
                        t21.voleh,
                        t21.ean11
                   from lads_mat_uom t21
                  where t21.matnr = rcd_lads_mat_hdr.mat_matnr
                    and t21.meinh = rcd_lads_mat_hdr.mat_meins) t02,
                (select t31.matnr,
                        t31.umren,
                        t31.umrez,
                        t31.brgew,
                        t31.gewei,
                        t31.laeng,
                        t31.breit,
                        t31.hoehe,
                        t31.meabm,
                        t31.volum,
                        t31.voleh,
                        t31.ean11
                   from lads_mat_uom t31
                  where t31.matnr = rcd_lads_mat_hdr.mat_matnr
                    and t31.meinh = rcd_lads_mat_lvl.rsu_meinh) t03,
                (select t41.matnr,
                        t41.umren,
                        t41.umrez,
                        t41.brgew,
                        t41.gewei,
                        t41.laeng,
                        t41.breit,
                        t41.hoehe,
                        t41.meabm,
                        t41.volum,
                        t41.voleh,
                        t41.ean11
                   from lads_mat_uom t41
                  where t41.matnr = rcd_lads_mat_hdr.mat_matnr
                    and t41.meinh = 'CS') t04
          where t01.matnr = t02.matnr(+)
            and t01.matnr = t03.matnr(+)
            and t01.matnr = t04.matnr(+)
            and t01.matnr = rcd_lads_mat_hdr.mat_matnr;
      rcd_lads_mat_uom csr_lads_mat_uom%rowtype;

      cursor csr_lads_mat_pch is
         select t01.vkorg as pch_vkorg,
                to_char(lads_to_date(t02.datab,'yyyymmdd'),'dd/mm/yyyy') as pch_datab,
                to_char(lads_to_date(t02.datbi,'yyyymmdd'),'dd/mm/yyyy') as pch_datbi,
                nvl(t04.trgqty,0) as pch_trgqty,
                nvl(t04.minqty,0) as pch_minqty
           from lads_mat_pch t01,
                lads_mat_pcr t02,
                lads_mat_pih t03,
                lads_mat_pid t04
          where t01.matnr = t02.matnr
            and t01.pchseq = t02.pchseq
            and t02.matnr = t03.matnr
            and t02.pchseq = t03.pchseq
            and t02.pcrseq = t03.pcrseq
            and t03.matnr = t04.matnr
            and t03.pchseq = t04.pchseq
            and t03.pcrseq = t04.pcrseq
            and t03.pihseq = t04.pihseq
            and t01.matnr = rcd_lads_mat_hdr.mat_matnr
            and t04.detail_itemtype = 'I'
          order by t01.matnr asc;
      rcd_lads_mat_pch csr_lads_mat_pch%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - CTS Extract - Extract material');

      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_mat_data.delete;
      tbl_loc_data.delete;
      tbl_mat_outp.delete;
      tbl_loc_outp.delete;

      /*-*/
      /* Retrieve the material rows
      /*-*/
      open csr_lads_mat_hdr;
      loop
         fetch csr_lads_mat_hdr into rcd_lads_mat_hdr;
         if csr_lads_mat_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Clear the material and location data
         /*-*/
         tbl_mat_data.delete;
         tbl_loc_data.delete;

         /*-*/
         /* Initialise the material values
         /*-*/
         var_midx := tbl_mat_data.count + 1;
         tbl_mat_data(var_midx).matnr := rcd_lads_mat_hdr.mat_matnr;
         tbl_mat_data(var_midx).ean11 := rcd_lads_mat_hdr.mat_ean11;
         tbl_mat_data(var_midx).name := rcd_lads_mat_hdr.mat_desc;
         tbl_mat_data(var_midx).brand := rcd_lads_mat_hdr.brn_desc;
         tbl_mat_data(var_midx).category := rcd_lads_mat_hdr.cat_desc;
         tbl_mat_data(var_midx).fighting := rcd_lads_mat_hdr.fgt_desc;
         tbl_mat_data(var_midx).pck_size := rcd_lads_mat_hdr.psz_desc;
         tbl_mat_data(var_midx).pck_format := rcd_lads_mat_hdr.pfm_desc;
         tbl_mat_data(var_midx).top_load := rcd_lads_mat_hdr.mat_stfak;
         tbl_mat_data(var_midx).unt_pick := con_missing;
         tbl_mat_data(var_midx).pce_ean := null;
         tbl_mat_data(var_midx).tdu_rez := 0;
         tbl_mat_data(var_midx).tdu_ren := 0;
         tbl_mat_data(var_midx).mcu_cnt := 0;
         tbl_mat_data(var_midx).rsu_cnt := 0;
         tbl_mat_data(var_midx).bas_qty := 0;
         tbl_mat_data(var_midx).bas_wgt := 0;
         tbl_mat_data(var_midx).bas_len := 0;
         tbl_mat_data(var_midx).bas_bth := 0;
         tbl_mat_data(var_midx).bas_hgt := 0;
         tbl_mat_data(var_midx).bas_vol := 0;
         tbl_mat_data(var_midx).pce_qty := 0;
         tbl_mat_data(var_midx).pce_wgt := 0;
         tbl_mat_data(var_midx).pce_len := 0;
         tbl_mat_data(var_midx).pce_bth := 0;
         tbl_mat_data(var_midx).pce_hgt := 0;
         tbl_mat_data(var_midx).pce_vol := 0;
         tbl_mat_data(var_midx).cas_qty := 0;
         tbl_mat_data(var_midx).cas_wgt := 0;
         tbl_mat_data(var_midx).cas_len := 0;
         tbl_mat_data(var_midx).cas_bth := 0;
         tbl_mat_data(var_midx).cas_hgt := 0;
         tbl_mat_data(var_midx).cas_vol := 0;

         /*-*/
         /* Retrieve the material UOM level data
         /* **notes** Three levels starting at CS
         /*-*/
         open csr_lads_mat_lvl;
         fetch csr_lads_mat_lvl into rcd_lads_mat_lvl;
         if csr_lads_mat_lvl%found then
            tbl_mat_data(var_midx).tdu_rez := rcd_lads_mat_lvl.tdu_umrez;
            tbl_mat_data(var_midx).tdu_ren := rcd_lads_mat_lvl.tdu_umren;
            tbl_mat_data(var_midx).mcu_cnt := rcd_lads_mat_lvl.mcu_count;
            tbl_mat_data(var_midx).rsu_cnt := rcd_lads_mat_lvl.rsu_count;
         else
            rcd_lads_mat_lvl.rsu_meinh := 'PCE';
            tbl_mat_data(var_midx).tdu_rez := 1;
            tbl_mat_data(var_midx).tdu_ren := 1;
            tbl_mat_data(var_midx).mcu_cnt := 1;
            tbl_mat_data(var_midx).rsu_cnt := 1;
         end if;
         close csr_lads_mat_lvl;

         /*-*/
         /* Retrieve the material UOM data
         /* **notes** BAS = base UOM 
         /*           PCE = piece UOM
         /*           CAS = case UOM
         /*-*/
         open csr_lads_mat_uom;
         fetch csr_lads_mat_uom into rcd_lads_mat_uom;
         if csr_lads_mat_uom%found then

            /*-*/
            /* Set the piece ean code
            /*-*/
            tbl_mat_data(var_midx).pce_ean := rcd_lads_mat_uom.pce_ean11;

            /*-*/
            /* Calculate the quantities
            /*-*/
            tbl_mat_data(var_midx).pce_qty := (1 / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;

            /*-*/
            /* Convert the gross weight (including packaging)
            /* (convert to KGM kilograms)
            /*-*/
            case rcd_lads_mat_uom.bas_gewei
               when 'GRM' then tbl_mat_data(var_midx).bas_wgt := rcd_lads_mat_uom.bas_brgew / 1000;
               when 'KGM' then tbl_mat_data(var_midx).bas_wgt := rcd_lads_mat_uom.bas_brgew;
               when 'TON' then tbl_mat_data(var_midx).bas_wgt := rcd_lads_mat_uom.bas_brgew * 1000;
               else tbl_mat_data(var_midx).bas_wgt := rcd_lads_mat_uom.bas_brgew;
            end case;
            case rcd_lads_mat_uom.pce_gewei
               when 'GRM' then tbl_mat_data(var_midx).pce_wgt := rcd_lads_mat_uom.pce_brgew / 1000;
               when 'KGM' then tbl_mat_data(var_midx).pce_wgt := rcd_lads_mat_uom.pce_brgew;
               when 'TON' then tbl_mat_data(var_midx).pce_wgt := rcd_lads_mat_uom.pce_brgew * 1000;
               else tbl_mat_data(var_midx).pce_wgt := rcd_lads_mat_uom.pce_brgew;
            end case;
            case rcd_lads_mat_uom.cas_gewei
               when 'GRM' then tbl_mat_data(var_midx).cas_wgt := rcd_lads_mat_uom.cas_brgew / 1000;
               when 'KGM' then tbl_mat_data(var_midx).cas_wgt := rcd_lads_mat_uom.cas_brgew;
               when 'TON' then tbl_mat_data(var_midx).cas_wgt := rcd_lads_mat_uom.cas_brgew * 1000;
               else tbl_mat_data(var_midx).cas_wgt := rcd_lads_mat_uom.cas_brgew;
            end case;

            /*-*/
            /* Convert the material dimensions
            /* (convert to MMT millimetres)
            /*-*/
            case rcd_lads_mat_uom.bas_meabm
               when 'MMT' then
                  tbl_mat_data(var_midx).bas_len := rcd_lads_mat_uom.bas_laeng;
                  tbl_mat_data(var_midx).bas_bth := rcd_lads_mat_uom.bas_breit;
                  tbl_mat_data(var_midx).bas_hgt := rcd_lads_mat_uom.bas_hoehe;
               when 'CMT' then
                  tbl_mat_data(var_midx).bas_len := rcd_lads_mat_uom.bas_laeng * 10;
                  tbl_mat_data(var_midx).bas_bth := rcd_lads_mat_uom.bas_breit * 10;
                  tbl_mat_data(var_midx).bas_hgt := rcd_lads_mat_uom.bas_hoehe * 10;
               when 'MTR' then
                  tbl_mat_data(var_midx).bas_len := rcd_lads_mat_uom.bas_laeng * 1000;
                  tbl_mat_data(var_midx).bas_bth := rcd_lads_mat_uom.bas_breit * 1000;
                  tbl_mat_data(var_midx).bas_hgt := rcd_lads_mat_uom.bas_hoehe * 1000;
               else
                  tbl_mat_data(var_midx).bas_len := rcd_lads_mat_uom.bas_laeng;
                  tbl_mat_data(var_midx).bas_bth := rcd_lads_mat_uom.bas_breit;
                  tbl_mat_data(var_midx).bas_hgt := rcd_lads_mat_uom.bas_hoehe;
            end case;
            case rcd_lads_mat_uom.pce_meabm
               when 'MMT' then
                  tbl_mat_data(var_midx).pce_len := rcd_lads_mat_uom.pce_laeng;
                  tbl_mat_data(var_midx).pce_bth := rcd_lads_mat_uom.pce_breit;
                  tbl_mat_data(var_midx).pce_hgt := rcd_lads_mat_uom.pce_hoehe;
               when 'CMT' then
                  tbl_mat_data(var_midx).pce_len := rcd_lads_mat_uom.pce_laeng * 10;
                  tbl_mat_data(var_midx).pce_bth := rcd_lads_mat_uom.pce_breit * 10;
                  tbl_mat_data(var_midx).pce_hgt := rcd_lads_mat_uom.pce_hoehe * 10;
               when 'MTR' then
                  tbl_mat_data(var_midx).pce_len := rcd_lads_mat_uom.pce_laeng * 1000;
                  tbl_mat_data(var_midx).pce_bth := rcd_lads_mat_uom.pce_breit * 1000;
                  tbl_mat_data(var_midx).pce_hgt := rcd_lads_mat_uom.pce_hoehe * 1000;
               else
                  tbl_mat_data(var_midx).pce_len := rcd_lads_mat_uom.pce_laeng;
                  tbl_mat_data(var_midx).pce_bth := rcd_lads_mat_uom.pce_breit;
                  tbl_mat_data(var_midx).pce_hgt := rcd_lads_mat_uom.pce_hoehe;
            end case;
            case rcd_lads_mat_uom.cas_meabm
               when 'MMT' then
                  tbl_mat_data(var_midx).cas_len := rcd_lads_mat_uom.cas_laeng;
                  tbl_mat_data(var_midx).cas_bth := rcd_lads_mat_uom.cas_breit;
                  tbl_mat_data(var_midx).cas_hgt := rcd_lads_mat_uom.cas_hoehe;
               when 'CMT' then
                  tbl_mat_data(var_midx).cas_len := rcd_lads_mat_uom.cas_laeng * 10;
                  tbl_mat_data(var_midx).cas_bth := rcd_lads_mat_uom.cas_breit * 10;
                  tbl_mat_data(var_midx).cas_hgt := rcd_lads_mat_uom.cas_hoehe * 10;
               when 'MTR' then
                  tbl_mat_data(var_midx).cas_len := rcd_lads_mat_uom.cas_laeng * 1000;
                  tbl_mat_data(var_midx).cas_bth := rcd_lads_mat_uom.cas_breit * 1000;
                  tbl_mat_data(var_midx).cas_hgt := rcd_lads_mat_uom.cas_hoehe * 1000;
               else
                  tbl_mat_data(var_midx).cas_len := rcd_lads_mat_uom.cas_laeng;
                  tbl_mat_data(var_midx).cas_bth := rcd_lads_mat_uom.cas_breit;
                  tbl_mat_data(var_midx).cas_hgt := rcd_lads_mat_uom.cas_hoehe;
            end case;

            /*-*/
            /* Convert the material volume
            /* (convert to CMQ cubic centimetres)
            /*-*/
            case rcd_lads_mat_uom.bas_voleh
               when 'CMQ' then tbl_mat_data(var_midx).bas_vol := rcd_lads_mat_uom.bas_volum / 1000000;
               when 'DMQ' then tbl_mat_data(var_midx).bas_vol := rcd_lads_mat_uom.bas_volum / 1000;
               when 'HLT' then tbl_mat_data(var_midx).bas_vol := rcd_lads_mat_uom.bas_volum / 10;
               when 'MTQ' then tbl_mat_data(var_midx).bas_vol := rcd_lads_mat_uom.bas_volum;
               else tbl_mat_data(var_midx).bas_vol := rcd_lads_mat_uom.bas_volum;
            end case;
            case rcd_lads_mat_uom.pce_voleh
               when 'CMQ' then tbl_mat_data(var_midx).pce_vol := rcd_lads_mat_uom.pce_volum / 1000000;
               when 'DMQ' then tbl_mat_data(var_midx).pce_vol := rcd_lads_mat_uom.pce_volum / 1000;
               when 'HLT' then tbl_mat_data(var_midx).pce_vol := rcd_lads_mat_uom.pce_volum / 10;
               when 'MTQ' then tbl_mat_data(var_midx).pce_vol := rcd_lads_mat_uom.pce_volum;
               else tbl_mat_data(var_midx).pce_vol := rcd_lads_mat_uom.pce_volum;
            end case;
            case rcd_lads_mat_uom.cas_voleh
               when 'CMQ' then tbl_mat_data(var_midx).cas_vol := rcd_lads_mat_uom.cas_volum / 1000000;
               when 'DMQ' then tbl_mat_data(var_midx).cas_vol := rcd_lads_mat_uom.cas_volum / 1000;
               when 'HLT' then tbl_mat_data(var_midx).cas_vol := rcd_lads_mat_uom.cas_volum / 10;
               when 'MTQ' then tbl_mat_data(var_midx).cas_vol := rcd_lads_mat_uom.cas_volum;
               else tbl_mat_data(var_midx).cas_vol := rcd_lads_mat_uom.cas_volum;
            end case;

         end if;
         close csr_lads_mat_uom;

         /*-*/
         /* Retrieve the material packaging instructions
         /*-*/
         open csr_lads_mat_pch;
         loop
            fetch csr_lads_mat_pch into rcd_lads_mat_pch;
            if csr_lads_mat_pch%notfound then
               exit;
            end if;

            /*-*/
            /* Initialise the location values
            /*-*/
            var_lidx := tbl_loc_data.count + 1;
            tbl_loc_data(var_lidx).sal_org := rcd_lads_mat_pch.pch_vkorg;
            tbl_loc_data(var_lidx).str_dat := rcd_lads_mat_pch.pch_datab;
            tbl_loc_data(var_lidx).end_dat := rcd_lads_mat_pch.pch_datbi;
            tbl_loc_data(var_lidx).cas_pal := rcd_lads_mat_pch.pch_trgqty / (tbl_mat_data(var_midx).tdu_rez * tbl_mat_data(var_midx).tdu_ren);
            tbl_loc_data(var_lidx).cas_lay := rcd_lads_mat_pch.pch_minqty / (tbl_mat_data(var_midx).tdu_rez * tbl_mat_data(var_midx).tdu_ren);
            tbl_loc_data(var_lidx).lay_pal := tbl_loc_data(var_lidx).cas_pal;
            if tbl_loc_data(var_lidx).cas_lay != 0 then
               tbl_loc_data(var_lidx).lay_pal := tbl_loc_data(var_lidx).cas_pal / tbl_loc_data(var_lidx).cas_lay;
            end if;

         end loop;
         close csr_lads_mat_pch;

         /*-*/
         /* Append the material record
         /*-*/
         var_output := lads_trim_code(tbl_mat_data(var_midx).matnr) || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).ean11 || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).pce_ean || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).name || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).rsu_cnt,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).rsu_cnt/tbl_mat_data(var_midx).mcu_cnt,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).cas_len,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).cas_bth,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).cas_hgt,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).cas_vol,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).cas_wgt,5) || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).brand || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).category || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).fighting || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).pck_size || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).pck_format || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).pce_vol,5) || con_separator;
         var_output := var_output || round(tbl_mat_data(var_midx).pce_wgt,5) || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).top_load || con_separator;
         var_output := var_output || tbl_mat_data(var_midx).unt_pick;
         tbl_mat_outp(tbl_mat_outp.count + 1) := var_output;

         /*-*/
         /* Append the location records
         /*-*/
         for idx in 1..tbl_loc_data.count loop
            var_output := 'AU11' || con_separator;
            var_output := var_output || lads_trim_code(tbl_mat_data(var_midx).matnr) || con_separator;
            var_output := var_output || tbl_loc_data(idx).sal_org || con_separator;
            var_output := var_output || tbl_loc_data(idx).str_dat || con_separator;
            var_output := var_output || round(tbl_loc_data(idx).cas_pal,5) || con_separator;
            var_output := var_output || round(tbl_loc_data(idx).cas_lay,5) || con_separator;
            var_output := var_output || round(tbl_loc_data(idx).lay_pal,5) || con_separator;
            var_output := var_output || con_missing;
            tbl_loc_outp(tbl_loc_outp.count + 1) := var_output;
         end loop;

      end loop;
      close csr_lads_mat_hdr;

      /*-*/
      /* Create the material interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS03','Product.txt');
      lics_outbound_loader.append_data(con_mat_heading);
      for idx in 1..tbl_mat_outp.count loop
         lics_outbound_loader.append_data(tbl_mat_outp(idx));
      end loop;
      var_output := to_char(tbl_mat_outp.count);
      for idx in 1..19 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* Create the material location interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS04','ProductByLocation.txt');
      lics_outbound_loader.append_data(con_loc_heading);
      for idx in 1..tbl_loc_outp.count loop
         lics_outbound_loader.append_data(tbl_loc_outp(idx));
      end loop;
      var_output := to_char(tbl_loc_outp.count);
      for idx in 1..7 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - CTS Extract - Extract material');

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - CTS Extract - Extract material - ' || var_exception);
            lics_logging.write_log('End - CTS Extract - Extract material');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_material;

   /********************************************************/
   /* This procedure performs the extract customer routine */
   /********************************************************/
   procedure extract_customer is

      /*-*/
      /* Local constants
      /*-*/
      con_cus_heading constant varchar2(4000) := 'ShipTo' || con_separator ||
                                                 'CustomerDescr' || con_separator ||
                                                 'CustomerAddress' || con_separator ||
                                                 'City' || con_separator ||
                                                 'State' || con_separator ||
                                                 'PostalCode' || con_separator ||
                                                 'Route' || con_separator ||
                                                 'RouteDescription' || con_separator ||
                                                 'ShipToZone' || con_separator ||
                                                 'Channel' || con_separator ||
                                                 'Customer' || con_separator ||
                                                 'Banner' || con_separator ||
                                                 'LocationType' || con_separator ||
                                                 'ExcessWaitingHours' || con_separator ||
                                                 'DeliveryHours' || con_separator ||
                                                 'RequiresSpecialWrap' || con_separator ||
                                                 'SingleSKUPerPallet';

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(4000);
      type rcd_cus_data is record(customer varchar2(128 char),
                                  name varchar2(128 char),
                                  addr varchar2(128 char),
                                  city varchar2(128 char),
                                  state varchar2(128 char),
                                  pcode varchar2(128 char),
                                  route varchar2(128 char),
                                  rte_desc varchar2(128 char),
                                  trn_zone varchar2(128 char),
                                  channel varchar2(128 char),
                                  cus_grp varchar2(128 char),
                                  banner varchar2(128 char),
                                  loc_typ varchar2(128 char),
                                  excess_wait varchar2(128 char),
                                  del_hours varchar2(128 char),
                                  special_wrap varchar2(128 char),
                                  single_sku varchar2(128 char));
      type typ_cus_data is table of rcd_cus_data index by binary_integer;
      type typ_cus_outp is table of varchar2(4000) index by binary_integer;
      tbl_cus_data typ_cus_data;
      tbl_cus_outp typ_cus_outp;
      var_cidx number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_cus_hdr is
         select t01.kunnr as cus_kunnr,
                t01.ktokd as cus_ktokd,
                t02.name as cus_name,
                t02.house_no as cus_house_no,
                t02.street as cus_street,
                t02.city as cus_city,
                t02.pcode as cus_pcode,
                t02.region as cus_region,
                t02.country as cus_country,
                t02.transpzone as cus_transpzone,
                nvl(t04.sap_cust_group_desc,'UNKNOWN') as cgp_desc,
                nvl(t05.sap_channel_desc,'UNKNOWN') as chl_desc,
                nvl(t06.sap_banner_desc,'UNKNOWN') as ban_desc,
                nvl(t07.sap_loc_type_desc,'UNKNOWN') as ltp_desc
           from lads_cus_hdr t01,
                (select t21.obj_id as kunnr,
                        t22.name as name,
                        t22.city as city,
                        t22.postl_cod1 as pcode,
                        t22.street as street,
                        t22.house_no as house_no,
                        t22.country as country,
                        t22.transpzone as transpzone,
                        t22.region
                   from lads_adr_hdr t21,
                        lads_adr_det t22
                  where t21.obj_type = t22.obj_type(+)
                    and t21.obj_id = t22.obj_id(+)
                    and t21.context = t22.context(+)
                    and t21.obj_type = 'KNA1'
                    and t21.context = '0001'
                    and t22.addr_vers is null) t02,
                (select t21.objek as kunnr,
                        max(case when t22.atnam = 'CLFFERT36' then t22.atwrt end) as sap_cust_group_code,
                        max(case when t22.atnam = 'CLFFERT101' then t22.atwrt end) as sap_channel_code,
                        max(case when t22.atnam = 'CLFFERT104' then t22.atwrt end) as sap_banner_code,
                        max(case when t22.atnam = 'CLFFERT106' then t22.atwrt end) as sap_loc_type_code
                   from lads_cla_hdr t21,
                        lads_cla_chr t22
                  where t21.obtab = 'KNA1'
                    and t21.klart = '011'
                    and t21.obtab = t22.obtab(+)
                    and t21.klart = t22.klart(+)
                    and t21.objek = t22.objek(+)
                  group by t21.objek) t03,
                (select t01.atwrt as sap_cust_group_code,
                        t02.atwtb as sap_cust_group_desc
                   from lads_chr_mas_val t01,
                        lads_chr_mas_dsc t02
                  where t01.atnam = t02.atnam(+)
                    and t01.valseq = t02.valseq(+)
                    and t01.atnam = 'CLFFERT36'
                    and t02.spras = 'E') t04,
                (select t01.atwrt as sap_channel_code,
                        t02.atwtb as sap_channel_desc
                   from lads_chr_mas_val t01,
                        lads_chr_mas_dsc t02
                  where t01.atnam = t02.atnam(+)
                    and t01.valseq = t02.valseq(+)
                    and t01.atnam = 'CLFFERT101'
                    and t02.spras = 'E') t05,
                (select t01.atwrt as sap_banner_code,
                        t02.atwtb as sap_banner_desc
                   from lads_chr_mas_val t01,
                        lads_chr_mas_dsc t02
                  where t01.atnam = t02.atnam(+)
                    and t01.valseq = t02.valseq(+)
                    and t01.atnam = 'CLFFERT104'
                    and t02.spras = 'E') t06,
                (select t01.atwrt as sap_loc_type_code,
                        t02.atwtb as sap_loc_type_desc
                   from lads_chr_mas_val t01,
                        lads_chr_mas_dsc t02
                  where t01.atnam = t02.atnam(+)
                    and t01.valseq = t02.valseq(+)
                    and t01.atnam = 'CLFFERT106'
                    and t02.spras = 'E') t07
          where t01.kunnr = t02.kunnr(+)
            and t01.kunnr = t03.kunnr(+)
            and t03.sap_cust_group_code = t04.sap_cust_group_code(+)
            and t03.sap_channel_code = t05.sap_channel_code(+)
            and t03.sap_banner_code = t06.sap_banner_code(+)
            and t03.sap_loc_type_code = t07.sap_loc_type_code(+)
          order by t01.kunnr;
      rcd_lads_cus_hdr csr_lads_cus_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - CTS Extract - Extract customer');

      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_cus_data.delete;
      tbl_cus_outp.delete;

      /*-*/
      /* Retrieve the customer rows
      /*-*/
      open csr_lads_cus_hdr;
      loop
         fetch csr_lads_cus_hdr into rcd_lads_cus_hdr;
         if csr_lads_cus_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Clear the customer data
         /*-*/
         tbl_cus_data.delete;

         /*-*/
         /* Initialise the customer values
         /*-*/
         var_cidx := tbl_cus_data.count + 1;
         tbl_cus_data(var_cidx).customer := rcd_lads_cus_hdr.cus_kunnr;
         tbl_cus_data(var_cidx).name := rcd_lads_cus_hdr.cus_name;
         tbl_cus_data(var_cidx).addr := rcd_lads_cus_hdr.cus_street;
         if not(rcd_lads_cus_hdr.cus_house_no is null) then
            tbl_cus_data(var_cidx).addr := rcd_lads_cus_hdr.cus_house_no || ' ' || rcd_lads_cus_hdr.cus_street;
         end if;
         tbl_cus_data(var_cidx).city := rcd_lads_cus_hdr.cus_city;
         tbl_cus_data(var_cidx).state := rcd_lads_cus_hdr.cus_region;
         tbl_cus_data(var_cidx).pcode := rcd_lads_cus_hdr.cus_pcode;
         tbl_cus_data(var_cidx).route := con_missing;
         tbl_cus_data(var_cidx).rte_desc := con_missing;
         tbl_cus_data(var_cidx).trn_zone := rcd_lads_cus_hdr.cus_transpzone;
         tbl_cus_data(var_cidx).channel := rcd_lads_cus_hdr.chl_desc;
         tbl_cus_data(var_cidx).cus_grp := rcd_lads_cus_hdr.cgp_desc;
         tbl_cus_data(var_cidx).banner := rcd_lads_cus_hdr.ban_desc;
         tbl_cus_data(var_cidx).loc_typ := rcd_lads_cus_hdr.ltp_desc;
         tbl_cus_data(var_cidx).excess_wait := con_missing;
         tbl_cus_data(var_cidx).del_hours := con_missing;
         tbl_cus_data(var_cidx).special_wrap := con_missing;
         tbl_cus_data(var_cidx).single_sku := con_missing;

         /*-*/
         /* Append the customer record
         /*-*/
         var_output := tbl_cus_data(var_cidx).customer || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).name || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).addr || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).city || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).state || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).pcode || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).route || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).rte_desc || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).trn_zone || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).channel || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).cus_grp || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).banner || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).loc_typ || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).excess_wait || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).del_hours || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).special_wrap || con_separator;
         var_output := var_output || tbl_cus_data(var_cidx).single_sku;
         tbl_cus_outp(tbl_cus_outp.count + 1) := var_output;

      end loop;
      close csr_lads_cus_hdr;

      /*-*/
      /* Create the customer interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADCTS05','ShipToLocation.txt');
      lics_outbound_loader.append_data(con_cus_heading);
      for idx in 1..tbl_cus_outp.count loop
         lics_outbound_loader.append_data(tbl_cus_outp(idx));
      end loop;
      var_output := to_char(tbl_cus_outp.count);
      for idx in 1..16 loop
         var_output := var_output || con_separator;
      end loop;
      lics_outbound_loader.append_data(var_output);
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - CTS Extract - Extract customer');

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - CTS Extract - Extract customer - ' || var_exception);
            lics_logging.write_log('End - CTS Extract - Extract customer');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_customer;

end cts_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym cts_extract for ics_app.cts_extract;
grant execute on cts_extract to public;
