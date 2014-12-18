create or replace package body pxi_promax_connect as
/*******************************************************************************
  Package Constants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PX_PROMAX_CONNECT';

/*******************************************************************************
  Package Types
*******************************************************************************/
  subtype st_sql is varchar2(32000 byte);

/*******************************************************************************
  NAME: PT_ACCOUNT                                                        PUBLIC
*******************************************************************************/
  function pt_account (
    i_jdbc_connection_name varchar2
  ) return tt_account pipelined is

    v_sql st_sql :=
      ' select '                                                              ||
      '   cast(ac_rowid as char(10)) + '                                      ||
      '   cast(ac_pubid as char(30)) + '                                      ||
      '   cast(ac_longname as char(40)) + '                                   ||
      '   isnull(cast(ac_code as char(20)), ''                    '') '       ||
      '   as output_record '                                                  ||
      ' from account '
      ;

  begin
    for rv_row in (
      select
        to_number(substr(output_record, 1, 10)) as ac_row_id,
        trim(substr(output_record, 11, 30)) as ac_pub_id,
        trim(substr(output_record, 41, 40)) as as_long_name,
        trim(substr(output_record, 81, 20)) as as_code
      from table(jdbc_connect.jdbc_select(i_jdbc_connection_name, v_sql))

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ACCOUNT');

  end pt_account;

/*******************************************************************************
  NAME: PT_ACCOUNT_SKUS                                                   PUBLIC
*******************************************************************************/
  function pt_account_skus (
    i_jdbc_connection_name varchar2
  ) return tt_account_skus pipelined is

    v_sql st_sql :=
      ' select '                                                              ||
      '   cast(as_rowid as char(10)) + '                                      ||
      '   cast(as_pubid as char(30)) + '                                      ||
      '   cast(as_accountrowid as char(10)) + '                               ||
      '   cast(as_accountpubid as char(30)) + '                               ||
      '   cast(as_skurowid as char(10)) + '                                   ||
      '   cast(as_skupubid as char(30)) + '                                   ||
      '   isnull(cast(as_clientforecastmodel as char(5)), ''     '') + '      ||
      '   isnull(cast(as_externalbasescan as char(5)), ''     '') + '         ||
      '   isnull(cast(as_salesstddevavgvolume as char(20)), ''                    '') + ' ||
      '   isnull(cast(as_status as char(10)), ''          '') '               ||
      '   as output_record '                                                  ||
      ' from accountskus '
      ;

  begin

    for rv_row in (

      select
        to_number(substr(output_record, 1, 10)) as as_row_id,
        trim(substr(output_record, 11, 30)) as as_pub_id,
        to_number(substr(output_record, 41, 10)) as as_account_row_id,
        trim(substr(output_record, 51, 30)) as as_account_pub_id,
        to_number(substr(output_record, 81, 10)) as as_sku_row_id,
        trim(substr(output_record, 91, 30)) as as_sku_pub_id,
        to_number(substr(output_record, 121, 5)) as as_client_forecast_model,
        to_number(substr(output_record, 126, 5)) as as_external_base_scan,
        to_number(substr(output_record, 131, 20)) as as_sales_std_dev_avg_volume,
        to_number(substr(output_record, 151, 10)) as as_status
      from table(jdbc_connect.jdbc_select(i_jdbc_connection_name, v_sql))

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ACCOUNT_SKUS');

  end pt_account_skus;

/*******************************************************************************
  NAME: PT_ACCOUNT_SKU_DETAILS                                            PUBLIC
*******************************************************************************/
  function pt_account_sku_details (
    i_jdbc_connection_name varchar2
  ) return tt_account_sku_details pipelined is

    v_sql st_sql :=
      ' select '                                                              ||
      '   cast(asd_rowid as char(10)) + '                                     ||
      '   cast(asd_pubid as char(30)) + '                                     ||
      '   convert(char(10),asd_startdate,102) + '                             ||
      '   isnull(convert(char(10),asd_stopdate,102), ''          '') + '      ||
      '   cast(asd_accountskurowid as char(10)) + '                           ||
      '   cast(asd_accountskupubid as char(30)) + '                           ||
      '   cast(asd_clientforecastmodel as char(5)) + '                        ||
      '   isnull(cast(asd_normalqty as char(10)), ''          '') + '         ||
      '   isnull(cast(asd_normalqtymethod as char(5)), ''     '') '           ||
      '   as output_record '                                                  ||
      ' from accountskudetails '
      ;

  begin

    for rv_row in (

      select
        to_number(substr(output_record, 1, 10)) as asd_row_id,
        trim(substr(output_record, 11, 30)) as asd_pub_id,
        case when length(trim(substr(output_record, 41, 10))) = 10 then to_date(substr(output_record, 41, 10), 'yyyy.mm.dd') else null end as asd_start_date,
        case when length(trim(substr(output_record, 51, 10))) = 10 then to_date(substr(output_record, 51, 10), 'yyyy.mm.dd') else null end as asd_stop_date,
        to_number(substr(output_record, 61, 10)) as asd_account_sku_row_id,
        trim(substr(output_record, 71, 30)) as asd_account_sku_pub_id,
        to_number(substr(output_record, 101, 5)) as asd_client_forecast_model,
        to_number(substr(output_record, 106, 10)) as asd_normal_qty,
        to_number(substr(output_record, 116, 5)) as asd_normal_qty_method
      from table(jdbc_connect.jdbc_select(i_jdbc_connection_name, v_sql))

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ACCOUNT_SKU_DETAILS');
  end pt_account_sku_details;


/*******************************************************************************
  NAME: PT_SKU                                                            PUBLIC
*******************************************************************************/
  function pt_sku (
    i_jdbc_connection_name varchar2
  ) return tt_sku pipelined is

    v_sql st_sql :=
      ' select '                                                              ||
      '   cast(sku_rowid as char(10)) + '                                     ||
      '   cast(sku_pubid as char(30)) + '                                     ||
      '   cast(sku_longname as char(40)) + '                                  ||
      '   isnull(cast(sku_stockcode as char(18)), ''                  '') '   ||
      '   as output_record '                                                  ||
      ' from sku '
      ;

  begin

    for rv_row in (

      select
        to_number(substr(output_record, 1, 10)) as sku_row_id,
        trim(substr(output_record, 11, 30)) as sku_pub_id,
        trim(substr(output_record, 41, 40)) as sku_long_name,
        trim(substr(output_record, 81, 18)) as sku_stock_code
      from table(jdbc_connect.jdbc_select(i_jdbc_connection_name, v_sql))

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_SKU');
  end pt_sku;

/*******************************************************************************
  NAME: PT_ACCOUNT_SKU_DETAILS_X                                          PUBLIC
*******************************************************************************/
  function pt_account_sku_details_x (
    i_jdbc_connection_name varchar2
  ) return tt_account_sku_details_x pipelined is

  begin

    for rv_row in (

      select
        account_skus.as_row_id,
        account_skus.as_pub_id,
        account_skus.as_client_forecast_model,
        account_skus.as_external_base_scan,
        account_skus.as_sales_std_dev_avg_volume,
        account_skus.as_status,
        account_sku_details.asd_row_id,
        account_sku_details.asd_pub_id,
        account_sku_details.asd_start_date,
        nvl(account_sku_details.asd_stop_date, to_date('99991231', 'yyyymmdd')) as asd_stop_date,
        account_sku_details.asd_client_forecast_model,
        account_sku_details.asd_normal_qty,
        account_sku_details.asd_normal_qty_method,
        account.ac_row_id,
        account.ac_pub_id,
        account.ac_long_name,
        account.ac_code,
        sku.sku_row_id,
        sku.sku_pub_id,
        sku.sku_long_name,
        sku.sku_stock_code
      from table(pxi_promax_connect.pt_account_skus(i_jdbc_connection_name)) account_skus,
        table(pxi_promax_connect.pt_account_sku_details(i_jdbc_connection_name)) account_sku_details,
        table(pxi_promax_connect.pt_account(i_jdbc_connection_name)) account,
        table(pxi_promax_connect.pt_sku(i_jdbc_connection_name)) sku
      -- Joins
      -- account_skus > account_sku_details
      where account_skus.as_row_id = account_sku_details.asd_account_sku_row_id
      and account_skus.as_pub_id = account_sku_details.asd_account_sku_pub_id
      -- account_skus > account
      and account_skus.as_account_row_id = account.ac_row_id
      and account_skus.as_account_pub_id = account.ac_pub_id
      -- account_skus > sku
      and account_skus.as_sku_row_id = sku.sku_row_id
      and account_skus.as_sku_pub_id = sku.sku_pub_id
    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_ACCOUNT_SKU_DETAILS_X');
  end pt_account_sku_details_x;

end pxi_promax_connect;
/