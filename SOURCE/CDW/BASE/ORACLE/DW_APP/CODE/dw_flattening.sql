/******************/
/* Package Header */
/******************/
create or replace package dw_flattening as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Object : dw_flattening
    Owner  : dw_app

    Description
    -----------
    Dimensional Data Store - Flattening

    This package contain the flattening procedures for dimension and hierarchy data.
    The package exposes one procedure EXECUTE that performs the flattening based on
    the following parameters.

    1. PAR_ACTION (*UPDATE, *REBUILD)

       *UPDATE updates the requested dimension(s) with changes and additions from the
       operational data store. *REBUILD replaces the requested dimension(s) with the
       current data from the operational data store. Both *UPDATE and *REBUILD replaces
       requested hierarchy(s) with the current data from the operational data store.

    2. PAR_TABLE (*ALL, 'table name')

       *ALL performs the flattening for all dimensions and hierarchies. A table name
       performs the flattening for the requested dimension or hierarchy.

    **notes**
    1. The internal FLATTEN_TABLE procedure is a generic routine where the source and target
       tables must have the same column names and the target table must have a primary key constraint.

    2. A web log is produced under the search value DW_FLATTENING where all errors are logged.

    3. All errors will raise an exception to the calling application so that an alert can
       be raised.

    4. All requested tables will attempt to be flattened and and errors logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/01   Steve Gregan   Created 
    2008/02   Trevor Keon    Modified for VENUS environment 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_table in varchar2);

end dw_flattening;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_flattening as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure flatten_table(par_tar_owner in varchar2,
                           par_tar_name in varchar2,
                           par_src_owner in varchar2,
                           par_src_name in varchar2,
                           par_replace in varchar2);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_table in varchar2) is

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
      var_replace varchar2(1);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW GRD Flattening';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'GRD_FLATTENING';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'GRD_FLATTENING';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_FLATTENING';
      var_log_search := 'DW_FLATTENING';
      var_loc_string := 'DW_FLATTENING';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*UPDATE' and upper(par_action) != '*REBUILD' then
         raise_application_error(-20000, 'Action parameter must be *UPDATE or *REBUILD');
      end if;
      if upper(par_table) != '*ALL' and
         upper(par_table) != 'ACCT_ASSGNMNT_GRP_DIM' and
         upper(par_table) != 'BANNER_DIM' and
         upper(par_table) != 'BOM_DIM' and
         upper(par_table) != 'COMPANY_DIM' and
         upper(par_table) != 'CNTRY_DIM' and
         upper(par_table) != 'CURRCY_DIM' and
         upper(par_table) != 'CUST_BUYING_GRP_DIM' and
         upper(par_table) != 'CUST_DIM' and
         upper(par_table) != 'CUSTOMER_SALES_AREA_DIM' and
         upper(par_table) != 'DLVRY_TYPE_DIM' and
         upper(par_table) != 'DISTBN_CHNL_DIM' and
         upper(par_table) != 'DISTBN_ROUTE_DIM' and
         upper(par_table) != 'DEMAND_PLNG_GRP_DIM' and
         upper(par_table) != 'DEMAND_PLNG_GRP_MATL_DIV_DIM' and
         upper(par_table) != 'DEMAND_PLNG_GRP_SALES_AREA_DIM' and
         upper(par_table) != 'DOC_XACTN_TYPE_DIM' and
         upper(par_table) != 'EXCH_RATE_DIM' and
         upper(par_table) != 'GRD_MATL_DIM' and
         upper(par_table) != 'INV_TYPE_DIM' and
         upper(par_table) != 'INVC_TYPE_DIM' and
         upper(par_table) != 'LOCAL_MATL_CLASSN_DIM' and
         upper(par_table) != 'MARS_DATE_DIM' and
         upper(par_table) != 'MARS_DATE_MONTH_DIM' and
         upper(par_table) != 'MARS_DATE_PERIOD_DIM' and
         upper(par_table) != 'MARS_DATE_WEEK_DIM' and
         upper(par_table) != 'MARS_DATE_PERIOD_DIM' and
         upper(par_table) != 'MATL_DIM' and
         upper(par_table) != 'MATL_PLANT_DIM' and
         upper(par_table) != 'MULTI_MKT_ACCT_DIM' and
         upper(par_table) != 'ORDER_REASN_DIM' and
         upper(par_table) != 'ORDER_TYPE_DIM' and
         upper(par_table) != 'ORDER_USAGE_DIM' and
         upper(par_table) != 'PLANT_DIM' and
         upper(par_table) != 'PMX_ACCT_MGR_DIM' and
         upper(par_table) != 'PMX_CLAIM_TYPE_DIM' and
         upper(par_table) != 'PMX_CUST_DIM' and
         upper(par_table) != 'PMX_FUND_TYPE_DIM' and
         upper(par_table) != 'PMX_PROM_ATTRB_DIM' and
         upper(par_table) != 'PMX_PROM_STATUS_DIM' and
         upper(par_table) != 'PMX_PROM_TYPE_DIM' and
         upper(par_table) != 'POS_FORMAT_GRPG_DIM' and
         upper(par_table) != 'PURCH_ORDER_TYPE_DIM' and
         upper(par_table) != 'REGION_DIM' and
         upper(par_table) != 'SALES_ORG_DIM' and
         upper(par_table) != 'STORAGE_LOCN_DIM' and
         upper(par_table) != 'TRANSPORT_MODEL_DIM' and
         upper(par_table) != 'UOM_DIM' and
         upper(par_table) != 'VENDOR_DIM' and
         upper(par_table) != 'SALES_FORCE_GEO_HIER' and
         upper(par_table) != 'SALES_OFFICE_HIER' and
         upper(par_table) != 'SHIP_TO_HIER' and
         upper(par_table) != 'STD_HIER' then
         raise_application_error(-20000, 'Table parameter must be *ALL or ' ||
                                         'ACCT_ASSGNMNT_GRP_DIM, ' ||
                                         'BANNER_DIM, ' ||
                                         'BOM_DIM, ' ||
                                         'COMPANY_DIM, ' ||
                                         'CNTRY_DIM, ' ||
                                         'CURRCY_DIM, ' ||
                                         'CUST_BUYING_GRP_DIM, ' ||
                                         'CUST_DIM, ' ||
                                         'CUSTOMER_SALES_AREA_DIM, ' ||
                                         'DLVRY_TYPE_DIM, ' ||
                                         'DISTBN_CHNL_DIM, ' ||
                                         'DISTBN_ROUTE_DIM, ' ||
                                         'DEMAND_PLNG_GRP_DIM, ' ||
                                         'DEMAND_PLNG_GRP_MATL_DIV_DIM, ' ||
                                         'DEMAND_PLNG_GRP_SALES_AREA_DIM, ' ||
                                         'DOC_XACTN_TYPE_DIM, ' ||
                                         'EXCH_RATE_DIM, ' ||
                                         'GRD_MATL_DIM, ' ||
                                         'INV_TYPE_DIM, ' ||
                                         'INVC_TYPE_DIM, ' ||
                                         'LOCAL_MATL_CLASSN_DIM, ' ||
                                         'MARS_DATE_DIM, ' ||
                                         'MARS_DATE_MONTH_DIM, ' ||
                                         'MARS_DATE_PERIOD_DIM, ' ||
                                         'MARS_DATE_WEEK_DIM, ' ||
                                         'MATL_DIM, ' ||
                                         'MATL_PLANT_DIM, ' ||
                                         'MULTI_MKT_ACCT_DIM, ' ||
                                         'ORDER_REASN_DIM, ' ||
                                         'ORDER_TYPE_DIM, ' ||
                                         'ORDER_USAGE_DIM, ' ||
                                         'PLANT_DIM, ' ||
                                         'PMX_ACCT_MGR_DIM, ' ||
                                         'PMX_CLAIM_TYPE_DIM, ' ||
                                         'PMX_CUST_DIM, ' ||
                                         'PMX_FUND_TYPE_DIM, ' ||
                                         'PMX_PROM_ATTRB_DIM, ' ||
                                         'PMX_PROM_STATUS_DIM, ' ||
                                         'PMX_PROM_TYPE_DIM, ' ||
                                         'POS_FORMAT_GRPG_DIM, ' ||
                                         'PURCH_ORDER_TYPE_DIM, ' ||
                                         'REGION_DIM, ' ||
                                         'SALES_ORG_DIM, ' ||
                                         'STORAGE_LOCN_DIM, ' ||
                                         'TRANSPORT_MODEL_DIM, ' ||
                                         'UOM_DIM, ' ||
                                         'VENDOR_DIM, ' ||
                                         'SALES_FORCE_GEO_HIER, ' ||
                                         'SALES_OFFICE_HIER, ' ||
                                         'SHIP_TO_HIER, ' ||
                                         'STD_HIER');
      end if;

      /*-*/
      /* Set the replace parameter
      /*-*/
      var_replace := 'N';
      if upper(par_action) = '*REBUILD' then
         var_replace := 'Y';
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - GRD Flattening - Parameters(' || upper(par_action) || ' + ' || upper(par_table) || ')');

      /*-*/
      /* Request the lock on the GRD flattening
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
         /* Execute the flattening procedures (dimension)
         /* **note** 1. There is NO dependancy OR sequence
         /*-*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'ACCT_ASSGNMNT_GRP_DIM' then
            begin
               flatten_table('dds','acct_assgnmnt_grp_dim','ods_app','acct_assgnmnt_grp_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'BANNER_DIM' then
            begin
               flatten_table('dds','banner_dim','ods_app','banner_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'BOM_DIM' then
            begin
               flatten_table('dds','bom_dim','ods_app','bom_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'COMPANY_DIM' then
            begin
               flatten_table('dds','company_dim','ods_app','company_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'CNTRY_DIM' then
            begin
               flatten_table('dds','cntry_dim','ods_app','country_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'CURRCY_DIM' then
            begin
               flatten_table('dds','currcy_dim','ods_app','currency_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'CUST_BUYING_GRP_DIM' then
            begin
               flatten_table('dds','cust_buying_grp_dim','ods_app','cust_buying_grp_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'CUST_DIM' then
            begin
               flatten_table('dds','cust_dim','ods_app','cust_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'CUSTOMER_SALES_AREA_DIM' then
            begin
               flatten_table('dds','cust_sales_area_dim','ods_app','customer_sales_area_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DLVRY_TYPE_DIM' then
            begin
               flatten_table('dds','dlvry_type_dim','ods_app','delivery_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DISTBN_CHNL_DIM' then
            begin
               flatten_table('dds','distbn_chnl_dim','ods_app','distribution_chnl_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DISTBN_ROUTE_DIM' then
            begin
               flatten_table('dds','distbn_route_dim','ods_app','distribution_route_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DIVISION_DIM' then
            begin
               flatten_table('dds','division_dim','ods_app','division_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DEMAND_PLNG_GRP_DIM' then
            begin
               flatten_table('dds','demand_plng_grp_dim','ods_app','dmd_plng_grp_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DEMAND_PLNG_GRP_MATL_DIV_DIM' then
            begin
               flatten_table('dds','demand_plng_grp_matl_div_dim','ods_app','dmd_plng_grp_matl_div_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DEMAND_PLNG_GRP_SALES_AREA_DIM' then
            begin
               flatten_table('dds','demand_plng_grp_sales_area_dim','ods_app','dmd_plng_grp_sales_area_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'DOC_XACTN_TYPE_DIM' then
            begin
               flatten_table('dds','doc_xactn_type_dim','ods_app','doc_xactn_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'EXCH_RATE_DIM' then
            begin
               flatten_table('dds','exch_rate_dim','ods_app','exchange_rate_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'FCST_TYPE_DIM' then
            begin
               flatten_table('dds','fcst_type_dim','ods_app','forecast_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'GRD_MATL_DIM' then
            begin
               flatten_table('dds','grd_matl_dim','ods_app','grd_matl_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'INV_TYPE_DIM' then
            begin
               flatten_table('dds','inv_type_dim','ods_app','inventory_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'INVC_TYPE_DIM' then
            begin
               flatten_table('dds','invc_type_dim','ods_app','invoice_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'LOCAL_MATL_CLASSN_DIM' then
            begin
               flatten_table('dds','local_matl_classn_dim','ods_app','local_matl_classn_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MARS_DATE_DIM' then
            begin
               flatten_table('dds','mars_date_dim','ods_app','mars_date_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MARS_DATE_MONTH_DIM' then
            begin
               flatten_table('dds','mars_date_month_dim','ods_app','mars_date_month_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MARS_DATE_PERIOD_DIM' then
            begin
               flatten_table('dds','mars_date_period_dim','ods_app','mars_date_period_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MARS_DATE_WEEK_DIM' then
            begin
               flatten_table('dds','mars_date_week_dim','ods_app','mars_date_week_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MATL_DIM' then
            begin
               flatten_table('dds','test_matl_dim','ods_app','matl_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MATL_PLANT_DIM' then
            begin
               flatten_table('dds','matl_plant_dim','ods_app','matl_plant_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'MULTI_MKT_ACCT_DIM' then
            begin
               flatten_table('dds','multi_mkt_acct_dim','ods_app','multi_mkt_account_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'ORDER_REASN_DIM' then
            begin
               flatten_table('dds','order_reasn_dim','ods_app','order_reason_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'ORDER_TYPE_DIM' then
            begin
               flatten_table('dds','order_type_dim','ods_app','order_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'ORDER_USAGE_DIM' then
            begin
               flatten_table('dds','order_usage_dim','ods_app','order_usage_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PLANT_DIM' then
            begin
               flatten_table('dds','plant_dim','ods_app','plant_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_ACCT_MGR_DIM' then
            begin
               flatten_table('dds','acct_mgr_dim','ods_app','pmx_acct_mgr_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;         
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_CLAIM_TYPE_DIM' then
            begin
               flatten_table('dds','claim_type_dim','ods_app','pmx_claim_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_CUST_DIM' then
            begin
               flatten_table('dds','pmx_cust_dim','ods_app','pmx_cust_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_FUND_TYPE_DIM' then
            begin
               flatten_table('dds','prom_fund_type_dim','ods_app','pmx_fund_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_PROM_ATTRB_DIM' then
            begin
               flatten_table('dds','prom_attrb_dim','ods_app','pmx_prom_attrb_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_PROM_STATUS_DIM' then
            begin
               flatten_table('dds','prom_status_dim','ods_app','pmx_prom_status_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PMX_PROM_TYPE_DIM' then
            begin
               flatten_table('dds','prom_type_dim','ods_app','pmx_prom_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'POS_FORMAT_GRPG_DIM' then
            begin
               flatten_table('dds','pos_format_grpg_dim','ods_app','pos_format_grouping_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'PURCH_ORDER_TYPE_DIM' then
            begin
               flatten_table('dds','purch_order_type_dim','ods_app','purch_order_type_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'REGION_DIM' then
            begin
               flatten_table('dds','region_dim','ods_app','region_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_ORG_DIM' then
            begin
               flatten_table('dds','sales_org_dim','ods_app','sales_org_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'STORAGE_LOCN_DIM' then
            begin
               flatten_table('dds','storage_locn_dim','ods_app','storage_location_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'TRANSPORT_MODEL_DIM' then
            begin
               flatten_table('dds','transport_model_dim','ods_app','transport_model_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'UOM_DIM' then
            begin
               flatten_table('dds','uom_dim','ods_app','uom_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'VENDOR_DIM' then
            begin
               flatten_table('dds','vendor_dim','ods_app','vendor_dim_view',var_replace);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         
         /*-*/
         /* Execute the flattening procedures (hierarchy)
         /* **note** 1. There is NO dependancy OR sequence
         /*          2. Data is ALWAYS replaced
         /*-*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_FORCE_GEO_HIER' then
            begin
               flatten_table('dds','sales_force_geo_hier','ods_app','sales_force_hier_view','Y');
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_OFFICE_HIER' then
            begin
               flatten_table('dds','sales_office_hier','ods_app','sales_office_hier_view','Y');
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'SHIP_TO_HIER' then
            begin
               flatten_table('dds','ship_to_hier','ods_app','ship_to_hier_view','Y');
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
        if upper(par_table) = '*ALL' or upper(par_table) = 'STD_HIER' then
            begin
               flatten_table('dds','std_hier','ods_app','standard_hier_view','Y');
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock on the GRD flattening
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - GRD Flattening');

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
                                         'DW_FLATTENING',
                                         var_email,
                                         'One or more errors occurred during the GRD flattening execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Release the lock on the GRD flattening
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FLATTENING - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*******************************************************************/
   /* This procedure performs the update dimension data store routine */
   /*******************************************************************/
   procedure flatten_table(par_tar_owner in varchar2,
                           par_tar_name in varchar2,
                           par_src_owner in varchar2,
                           par_src_name in varchar2,
                           par_replace in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_tar_owner varchar2(30);
      var_tar_name varchar2(30);
      var_src_owner varchar2(30);
      var_src_name varchar2(30);
      var_replace varchar2(1);
      var_dynamic_sql varchar2(32767);
      var_message varchar2(4000);
      var_found boolean;
      var_counter number;
      type typ_column is table of varchar2(30) index by binary_integer;
      tbl_column typ_column;
      type typ_key is table of varchar2(30) index by binary_integer;
      tbl_key typ_key;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_columns is
         select t01.column_name as tar_column,
                t02.column_name as src_column
           from all_tab_columns t01,
                all_tab_columns t02
          where t01.column_name = t02.column_name(+)
            and var_src_owner = t02.owner(+)
            and var_src_name = t02.table_name(+)
            and t01.owner = var_tar_owner
            and t01.table_name = var_tar_name
          order by t01.column_id;
      rcd_columns csr_columns%rowtype;

      cursor csr_keys is
         select t02.column_name as tar_key
           from all_constraints t01,
                all_cons_columns t02
          where t01.owner = t02.owner
            and t01.table_name = t02.table_name
            and t01.constraint_name = t02.constraint_name
            and t01.owner = var_tar_owner
            and t01.table_name = var_tar_name
            and t01.constraint_type = 'P'
          order by t02.position;
      rcd_keys csr_keys%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the parameter variables
      /*-*/
      var_tar_owner := upper(par_tar_owner);
      var_tar_name := upper(par_tar_name);
      var_src_owner := upper(par_src_owner);
      var_src_name := upper(par_src_name);
      var_replace := upper(par_replace);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - ' || var_tar_name || ' flattening - Parameters - ' ||
                             'Source(' || var_src_owner || '.' || var_src_name ||
                             ') Target(' || var_tar_owner || '.' || var_tar_name ||
                             ') Replace(' || var_replace || ')');

      /*-*/
      /* Clear the arrays
      /*-*/
      tbl_column.delete;
      tbl_key.delete;

      /*-*/
      /* Initialise the message
      /*-*/
      var_message := null;

      /*-*/
      /* Retrieve the target and source columns
      /*-*/
      open csr_columns;
      loop
         fetch csr_columns into rcd_columns;
         if csr_columns%notfound then
            exit;
         end if;
         if rcd_columns.src_column is null then
            var_message := var_message || chr(13) || 'Target table ' || var_tar_owner || '.' || var_tar_name || ' column ' || rcd_columns.tar_column || ' not found on source file ' || var_src_owner || '.' || var_src_name;
         end if;
         tbl_column(tbl_column.count + 1) := rcd_columns.tar_column;
      end loop;
      close csr_columns;

      /*-*/
      /* Retrieve the target keys
      /*-*/
      open csr_keys;
      loop
         fetch csr_keys into rcd_keys;
         if csr_keys%notfound then
            exit;
         end if;
         tbl_key(tbl_key.count + 1) := rcd_keys.tar_key;
      end loop;
      close csr_keys;
      if tbl_key.count = 0 then
         var_message := var_message || chr(13) || 'No primary key found for target table ' || var_tar_owner || '.' || var_tar_name || ' unable to flatten';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         raise_application_error(-20000, var_message);
      end if;

      /*-*/
      /* Truncate the target table when replace required
      /*-*/
      if var_replace = 'Y' then
         lics_logging.write_log('Truncating the ' || var_tar_name || ' table');
         begin
            dd_table.truncate(var_tar_name);
         exception
            when others then
               raise_application_error(-20000, 'Error truncating table ' || var_tar_owner || '.' || var_tar_name || ' - ' || substr(SQLERRM, 1, 1024));
         end;
      end if;

      /*-*/
      /* Delete missing or changed rows from the target data store when not replace
      /* **note** exists in DDS but not in ODS or different in ODS
      /*          target (DDS) source (ODS)
      /*
      /* **SQL Syntax**
      /*
      /* delete from target_table t01
      /*     where (t01.primary_key_01,
      /*            t01.primary_key_nn) in (select t01.primary_key_01,
      /*                                           t01.primary_key_nn
      /*                                      from (select t11.column_01,
      /*                                                   t11.column_nn
      /*                                              from target_table t11
      /*                                            minus
      /*                                            select t12.column_01
      /*                                                   t12.column_nn
      /*                                              from source_table t12) t01)
      /*-*/
      if var_replace != 'Y' then

         /*-*/
         /* Build the delete statement
         /*-*/
         var_dynamic_sql := 'delete from ' || var_tar_owner || '.' || var_tar_name || ' t01';
         var_dynamic_sql := var_dynamic_sql || ' where (';
         for idx in 1..tbl_key.count loop
            if idx > 1 then
               var_dynamic_sql := var_dynamic_sql || ',';
            end if;
            var_dynamic_sql := var_dynamic_sql || 't01.' || tbl_key(idx);
         end loop;
         var_dynamic_sql := var_dynamic_sql || ') in (select ';
         for idx in 1..tbl_key.count loop
            if idx > 1 then
               var_dynamic_sql := var_dynamic_sql || ',';
            end if;
            var_dynamic_sql := var_dynamic_sql || 't01.' || tbl_key(idx);
         end loop;
         var_dynamic_sql := var_dynamic_sql || ' from (select ';
         for idx in 1..tbl_column.count loop
            if idx > 1 then
               var_dynamic_sql := var_dynamic_sql || ',';
            end if;
            var_dynamic_sql := var_dynamic_sql || 't11.' || tbl_column(idx);
         end loop;
         var_dynamic_sql := var_dynamic_sql || ' from ' || var_tar_owner || '.' || var_tar_name || ' t11 minus select ';
         for idx in 1..tbl_column.count loop
            if idx > 1 then
               var_dynamic_sql := var_dynamic_sql || ',';
            end if;
            var_dynamic_sql := var_dynamic_sql || 't12.' || tbl_column(idx);
         end loop;
         var_dynamic_sql := var_dynamic_sql || ' from ' || var_src_owner || '.' || var_src_name || ' t12) t01)';

         /*-*/
         /* Execute the delete statement
         /*-*/
         lics_logging.write_log('Deleting the ' || var_tar_name || ' table redundant data');
         begin
            execute immediate var_dynamic_sql;
            commit;
         exception
           when others then
               raise_application_error(-20000, 'Error deleting rows from ' || var_tar_owner || '.' || var_tar_name || ' - ' || substr(SQLERRM, 1, 1024));
         end;

      end if;

      /*-*/
      /* Insert new rows from the source data store
      /* **note** exists in ODS but not in DDS
      /*          target (DDS) source (ODS)
      /*
      /* **SQL Syntax**
      /*
      /* insert into target_table
      /*    select t01.column_01,
      /*           t01.column_nn
      /*      from (select t11.column_01,
      /*                   t11.column_nn
      /*              from source_table t11
      /*             minus
      /*            select t12.column_01
      /*                   t12.column_nn
      /*              from target_table t12) t01
      /*-*/
      var_dynamic_sql := 'insert into ' || var_tar_owner || '.' || var_tar_name || ' select ';
      for idx in 1..tbl_column.count loop
         if idx > 1 then
            var_dynamic_sql := var_dynamic_sql || ',';
         end if;
         var_dynamic_sql := var_dynamic_sql || 't01.' || tbl_column(idx);
      end loop;
      var_dynamic_sql := var_dynamic_sql || ' from (select ';
      for idx in 1..tbl_column.count loop
         if idx > 1 then
            var_dynamic_sql := var_dynamic_sql || ',';
            end if;
         var_dynamic_sql := var_dynamic_sql || 't11.' || tbl_column(idx);
      end loop;
      var_dynamic_sql := var_dynamic_sql || ' from ' || var_src_owner || '.' || var_src_name || ' t11 minus select ';
      for idx in 1..tbl_column.count loop
         if idx > 1 then
            var_dynamic_sql := var_dynamic_sql || ',';
         end if;
         var_dynamic_sql := var_dynamic_sql || 't12.' || tbl_column(idx);
      end loop;
      var_dynamic_sql := var_dynamic_sql || ' from ' || var_tar_owner || '.' || var_tar_name || ' t12) t01';

      /*-*/
      /* Execute the insert statement
      /*-*/
      lics_logging.write_log('Inserting the ' || var_tar_name || ' new data');
      begin
         execute immediate var_dynamic_sql;
         commit;
      exception
         when others then
            raise_application_error(-20000, 'Error inserting rows in ' || var_tar_owner || '.' || var_tar_name || ' - ' || substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - ' || var_tar_name);

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
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - ' || var_tar_name || ' flattening - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - ' || var_tar_name);
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
   end flatten_table;

end dw_flattening;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_flattening for dw_app.dw_flattening;
grant execute on dw_flattening to public;
