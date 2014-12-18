create or replace package pxi_promax_connect as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : PXI
 Package : PXI_PROMAX_CONNECT
 Owner   : PXI_APP
 Author  : Mal Chambeyron

 Description
 -----------
 Expose Promax PX Tables to Oracle

 Date          Author                Description
 ------------  --------------------  -----------
 2014-02-05    Mal Chambeyron        Created
 2014-02-06    Mal Chambeyron        Add [account_sku_details],
                                     and [account]/[sku] long names ..
 2014-12-16    Chris Horn            Created a copy and installed in 
                                     LADS PXI_APP system for end to end demand.

*******************************************************************************/
  ------------------------------------------------------------------------------
  type rt_account is record (
    ac_row_id                       number(10, 0),
    ac_pub_id                       varchar2(30 char),
    ac_long_name                    varchar2(40 char),
    ac_code                         varchar2(20 char)
  );

  type tt_account is table of rt_account;

  function pt_account (
    i_jdbc_connection_name varchar2
  ) return tt_account pipelined;
  ------------------------------------------------------------------------------
  type rt_account_skus is record (
    as_row_id                       number(10, 0),
    as_pub_id                       varchar2(30 char),
    as_account_row_id               number(10, 0),
    as_account_pub_id               varchar2(30 char),
    as_sku_row_id                   number(10, 0),
    as_sku_pub_id                   varchar2(30 char),
    as_client_forecast_model        number(5, 0),
    as_external_base_scan           number(5, 0),
    as_sales_std_dev_avg_volume     number(20,10),
    as_status                       number(10, 0)
  );

  type tt_account_skus is table of rt_account_skus;

  function pt_account_skus (
    i_jdbc_connection_name varchar2
  ) return tt_account_skus pipelined;
  ------------------------------------------------------------------------------
  type rt_account_sku_details is record (
    asd_row_id                      number(10, 0),
    asd_pub_id                      varchar2(30 char),
    asd_start_date                  date,
    asd_stop_date                   date,
    asd_account_sku_row_id          number(10, 0),
    asd_account_sku_pub_id          varchar2(30 char),
    asd_client_forecast_model       number(5, 0),
    asd_normal_qty                  number(10, 0),
    asd_normal_qty_method           number(5, 0)
  );

  type tt_account_sku_details is table of rt_account_sku_details;

  function pt_account_sku_details (
    i_jdbc_connection_name varchar2
  ) return tt_account_sku_details pipelined;
  ------------------------------------------------------------------------------
  type rt_account_sku_details_x is record (
    as_row_id                       number(10, 0),
    as_pub_id                       varchar2(30 char),
    as_client_forecast_model        number(5, 0),
    as_external_base_scan           number(5, 0),
    as_sales_std_dev_avg_volume     number(20,10),
    as_status                       number(10, 0),
    asd_row_id                      number(10, 0),
    asd_pub_id                      varchar2(30 char),
    asd_start_date                  date,
    asd_stop_date                   date,
    asd_client_forecast_model       number(5, 0),
    asd_normal_qty                  number(10, 0),
    asd_normal_qty_method           number(5, 0),
    ac_row_id                       number(10, 0),
    ac_pub_id                       varchar2(30 char),
    ac_long_name                    varchar2(40 char),
    ac_code                         varchar2(20 char),
    sku_row_id                      number(10, 0),
    sku_pub_id                      varchar2(30 char),
    sku_long_name                   varchar2(40 char),
    sku_stock_code                  varchar2(18 char)
  );

  type tt_account_sku_details_x is table of rt_account_sku_details_x;

  function pt_account_sku_details_x (
    i_jdbc_connection_name varchar2
  ) return tt_account_sku_details_x pipelined;
  ------------------------------------------------------------------------------
  type rt_sku is record (
    sku_row_id                      number(10, 0),
    sku_pub_id                      varchar2(30 char),
    sku_long_name                   varchar2(40 char),
    sku_stock_code                  varchar2(18 char)
  );

  type tt_sku is table of rt_sku;

  function pt_sku (
    i_jdbc_connection_name varchar2
  ) return tt_sku pipelined;
  ------------------------------------------------------------------------------

end pxi_promax_connect;
/
