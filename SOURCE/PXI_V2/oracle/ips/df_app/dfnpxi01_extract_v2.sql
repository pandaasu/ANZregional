prompt :: Compile Package [dfnpxi01_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package df_app.dfnpxi01_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
  System  : IPS
  Package : DFNPXI01_EXTRACT_V2
  Owner   : DF_APP
  Author  : Chris Horn

  Description
  -----------
  Demand Financials (Outbound) -> LADS (Passthrough)
  -> Promax PX - Demand Base - PX Interface 355DMND

  This interface creates an extract of an apollo base forecast.

  As the extract cannot handle negatives or decimals all quantites
  are brought to zero and then rounded.

  Where there is a split defined [df.px_dmnd_lookup], largest percentace is
  allocated first.

  Zero values are filtered, as NOT required by Promax PX.

  Note :

    [pt_mars_week] Start / End Dates are squewed 1 Day to "Allign" Mars and
      Promax Calendars

  Date        Author                Description
  ----------  --------------------  ---------------------------------------------
  2013-11-29  Chris Horn            Created.
  2013-12-01  Chris Horn            Completed first version.
  2013-12-02  Chris Horn            Completed.
  2014-01-02  Jonathan Girling      Updated csr_dmnd_lookup to exclude
                                    zero percent records.
  2013-01-20  Mal Chambeyron        Rewrite with pipeline to simplify logic and
                                    improve supportability.
  2013-01-28  Mal Chambeyron        Use CEIL vs ROUND on splits, to ensure
                                    largest percent is allocated in preference.
  2014-02-05  Mal Chambeyron        Filter unecessary rows - those that would
                                    result in zero.
  2014-02-05  Mal Chambeyron        Filter rows that would error in Promax PX.
  2014-02-07  Mal Chambeyron        Add history tracking logic.
  2014-02-07  Mal Chambeyron        Add lics locking to interface, execute only.
  2014-02-11  Mal Chambeyron        Add email of error report csv format.
  2014-02-28  Chris Horn            Move Filter of Unnecessary Rows from Row to
                                    Group Function.
  2014-03-03  Mal Chambeyron        Use ROUND vs CEIL on TOTAL .. to Reduce Total
                                    Variance Due to Representing Decimals as
                                    Integers.
                                    NOTE : CEIL Still Used on Splits
  2014-03-17  Mal Chambeyron        Remove the filter on Market Activities
                                    (pxi_common_df.fc_dmnd_type_7)
                                    was in place for testing phase.

*******************************************************************************/

/*******************************************************************************
  NAME: FORECAST_MOE                                                      PUBLIC
  PURPOSE : Function to return [moe_code] for a given [fcst_id]
*******************************************************************************/
   function forecast_moe(
    i_fcst_id in common.st_id
   ) return varchar2;

/*******************************************************************************
  NAME: PT_MARS_WEEK                                                      PUBLIC
  PURPOSE : Pipeline to return Mars Week Start / End Dates for 3 Years
            Start / End Dates are Squewed 1 Day to "Align" Mars and Promax
            Calendars
*******************************************************************************/
  type rt_mars_week is record (
    mars_week                       mars_date.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type
  );

  type tt_mars_week is table of rt_mars_week;

  function pt_mars_week return tt_mars_week pipelined;

/*******************************************************************************
  NAME: PT_FORECAST                                                       PUBLIC
  PURPOSE : Pipeline to return Raw Aggregate Forecast Demand
*******************************************************************************/
  type rt_forecast is record (
    fcst_id                         fcst.fcst_id%type,
    moe_code                        fcst.moe_code%type,
    sales_org                       dmnd_grp_org.sales_org%type,
    bus_sgmnt_code                  dmnd_grp_org.bus_sgmnt_code%type,
    dmnd_grp_code                   dmnd_grp.dmnd_grp_code%type,
    dmnd_plng_node                  dmnd_grp.dmnd_plng_node%type,
    zrep_matl_code                  dmnd_data.zrep%type,
    mars_week                       dmnd_data.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type,
    total_qty                       number(10,0)
  );

  type tt_forecast is table of rt_forecast;

  function pt_forecast (
    i_fcst_id in common.st_id
  ) return tt_forecast pipelined;

/*******************************************************************************
  NAME: PT_FORECAST_SPLIT                                                PUBLIC
  PURPOSE : Pipeline to return Split Forecast Demand
*******************************************************************************/
  type rt_forecast_split is record (
    fcst_id                         fcst.fcst_id%type,
    moe_code                        fcst.moe_code%type,
    sales_org                       dmnd_grp_org.sales_org%type,
    bus_sgmnt_code                  dmnd_grp_org.bus_sgmnt_code%type,
    dmnd_grp_code                   dmnd_grp.dmnd_grp_code%type,
    zrep_matl_code                  dmnd_data.zrep%type,
    mars_week                       dmnd_data.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type,
    dmnd_plng_node                  dmnd_grp.dmnd_plng_node%type,
    px_dmnd_plng_node               dmnd_grp.dmnd_plng_node%type,
    split_qty                       number(10,0)
  );

  type tt_forecast_split is table of rt_forecast_split;

  function pt_forecast_split (
    i_fcst_id in common.st_id
  ) return tt_forecast_split pipelined;

/*******************************************************************************
  NAME: PT_FORECAST_AND_HISTORY                                           PUBLIC
  PURPOSE : Pipeline to return Forecast and History
*******************************************************************************/
  type rt_forecast_and_history is record (
    fcst_id                         fcst.fcst_id%type,
    moe_code                        fcst.moe_code%type,
    sales_org                       dmnd_grp_org.sales_org%type,
    bus_sgmnt_code                  dmnd_grp_org.bus_sgmnt_code%type,
    dmnd_grp_code                   dmnd_grp.dmnd_grp_code%type,
    zrep_matl_code                  dmnd_data.zrep%type,
    mars_week                       dmnd_data.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type,
    dmnd_plng_node                  dmnd_grp.dmnd_plng_node%type,
    px_dmnd_plng_node               dmnd_grp.dmnd_plng_node%type,
    split_qty                       number(10,0),
    created_date                    date,
    modified_date                   date,
    has_px_account_sku              number(1,0),
    has_px_account                  number(1,0),
    has_px_sku                      number(1,0)
  );

  type tt_forecast_and_history is table of rt_forecast_and_history;

  function pt_forecast_and_history (
    i_fcst_id in common.st_id
  ) return tt_forecast_and_history pipelined;

/*******************************************************************************
  NAME: PT_OUTPUT                                                         PUBLIC
  PURPOSE: Pipeline of of apollo base forecast
           Interface Output Format is in the [output_record] field.
*******************************************************************************/
  type rt_output is record (
    output_record                   varchar2(4000 char),
    --
    fcst_id                         fcst.fcst_id%type,
    moe_code                        fcst.moe_code%type,
    sales_org                       dmnd_grp_org.sales_org%type,
    bus_sgmnt_code                  dmnd_grp_org.bus_sgmnt_code%type,
    dmnd_grp_code                   dmnd_grp.dmnd_grp_code%type,
    zrep_matl_code                  dmnd_data.zrep%type,
    mars_week                       dmnd_data.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type,
    dmnd_plng_node                  dmnd_grp.dmnd_plng_node%type,
    px_dmnd_plng_node               dmnd_grp.dmnd_plng_node%type,
    split_qty                       number(10,0),
    created_date                    date,
    modified_date                   date,
    has_px_account_sku              number(1,0),
    has_px_account                  number(1,0),
    has_px_sku                      number(1,0)
  );

  type tt_output is table of rt_output;

  function pt_output (
    i_fcst_id in common.st_id
  ) return tt_output pipelined;

/*******************************************************************************
  NAME: PT_PX_355DMND_HISTORY_PLUS                                        PUBLIC
  PURPOSE: Pipeline of [px_355dmnd_history] with [px_dmnd_plng_node_desc] and
           [zrep_matl_desc] added
*******************************************************************************/

  type rt_px_355dmnd_history_plus is record (
    fcst_id                         fcst.fcst_id%type,
    moe_code                        fcst.moe_code%type,
    sales_org                       dmnd_grp_org.sales_org%type,
    bus_sgmnt_code                  dmnd_grp_org.bus_sgmnt_code%type,
    dmnd_grp_code                   dmnd_grp.dmnd_grp_code%type,
    zrep_matl_code                  dmnd_data.zrep%type,
    mars_week                       dmnd_data.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type,
    dmnd_plng_node                  dmnd_grp.dmnd_plng_node%type,
    px_dmnd_plng_node               dmnd_grp.dmnd_plng_node%type,
    split_qty                       number(10,0),
    created_date                    date,
    modified_date                   date,
    has_px_account_sku              number(1,0),
    has_px_account                  number(1,0),
    has_px_sku                      number(1,0),
    px_dmnd_plng_node_desc          dmnd_grp.dmnd_grp_name%type,
    zrep_matl_desc                  matl.matl_desc%type
  );

  type tt_px_355dmnd_history_plus is table of rt_px_355dmnd_history_plus;

  function pt_px_355dmnd_history_plus (
    i_moe_code in varchar2
  ) return tt_px_355dmnd_history_plus pipelined;

/*******************************************************************************
  NAME: PT_ERROR_REPORT                                                   PUBLIC
  PURPOSE: Pipeline of error report
*******************************************************************************/

  type rt_error_report is record (
    sort_seq                        number(1,0),
    error_desc                      varchar2(64 char),
    account_code                    dmnd_grp.dmnd_plng_node%type,
    px_account_code                 dmnd_grp.dmnd_plng_node%type,
    px_account_desc                 dmnd_grp.dmnd_grp_name%type,
    sku_code                        dmnd_data.zrep%type,
    sku_desc                        matl.matl_desc%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type,
    record_count                    number(10,0),
    total_qty                       number(10,0)
  );

  type tt_error_report is table of rt_error_report;

  function pt_error_report (
    i_moe_code in varchar2
  ) return tt_error_report pipelined;

/*******************************************************************************
  NAME: EMAIL_ERROR_REPORT                                                PUBLIC
  PURPOSE: EMail error report, if necessary
*******************************************************************************/
  procedure email_error_report (
    i_moe_code in varchar2
  );

/*******************************************************************************
  NAME: EXECUTE                                                           PUBLIC
  PURPOSE: Creates the outbound interface using [output_record] from [pt_output]
*******************************************************************************/
  procedure execute(
    i_fcst_id in common.st_id
  );

end dfnpxi01_extract_v2;
/

create or replace package body df_app.dfnpxi01_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'DFNPXI01_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'DFNPXI01';

/*******************************************************************************
  NAME:  FORECAST_MOE                                                     PUBLIC
*******************************************************************************/
   function forecast_moe(
    i_fcst_id in common.st_id
   ) return varchar2 is

    v_moe_code pxi_common.st_moe_code;

   begin

    -- Get moe code for the supplied forecast id
    begin
      select moe_code into v_moe_code from fcst where fcst_id = i_fcst_id;
    exception
      when no_data_found then
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unable to find the forecast for the supplied id [' || i_fcst_id || '].');
    end;

    return v_moe_code;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'forecast_moe');
  end forecast_moe;

/*******************************************************************************
  NAME: PT_MARS_WEEK                                                      PUBLIC
*******************************************************************************/
  function pt_mars_week return tt_mars_week pipelined is

  begin

      for rv_row in (

        select
          mars_week,
          min(calendar_date)+1 as start_date,
          max(calendar_date)+1 as end_date
        from mars_date
        group by mars_week
        having mars_week between
          (select mars_week from mars_date where calendar_date = trunc(sysdate)) -- Today
          and (select mars_week from mars_date where calendar_date = trunc(sysdate) + (365 * 2)) -- 2 Years from Today
        order by mars_week

      )
      loop
        pipe row(rv_row);
      end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'pt_mars_week');
  end pt_mars_week;

/*******************************************************************************
  NAME: PT_FORECAST                                                       PUBLIC
*******************************************************************************/
  function pt_forecast (
    i_fcst_id in common.st_id
  ) return tt_forecast pipelined is

  begin

    for rv_row in (

      select
        fcst.fcst_id,
        fcst.moe_code,
        dmnd_grp_org.sales_org,
        dmnd_grp_org.bus_sgmnt_code,
        dmnd_grp.dmnd_grp_code,
        dmnd_grp.dmnd_plng_node,
        dmnd_data.zrep as zrep_matl_code,
        dmnd_data.mars_week,
        max(mars_week.start_date) as start_date,
        max(mars_week.end_date) as end_date,
        round(sum(dmnd_data.qty_in_base_uom)) as total_qty
      from
        fcst,
        dmnd_data,
        dmnd_grp_org,
        dmnd_grp,
        table(dfnpxi01_extract_v2.pt_mars_week) mars_week
      -- Joins
      where fcst.fcst_id = dmnd_data.fcst_id -- fcst > dmnd_data
      and dmnd_data.dmnd_grp_org_id = dmnd_grp_org.dmnd_grp_org_id -- dmnd_data > dmnd_grp_org
      and dmnd_grp_org.dmnd_grp_id = dmnd_grp.dmnd_grp_id -- dmnd_grp_org -> dmnd_grp
      and dmnd_data.mars_week = mars_week.mars_week -- dmnd_data -> mars_week
      -- Filters
      and fcst.fcst_id = i_fcst_id -- Limit to fcst_id
      and dmnd_data.type in (
        pxi_common_df.fc_dmnd_type_1, -- Base
        pxi_common_df.fc_dmnd_type_2, -- Aggregated Market Activities
        pxi_common_df.fc_dmnd_type_3, -- Lock
        pxi_common_df.fc_dmnd_type_4, -- Reconcile
        pxi_common_df.fc_dmnd_type_5, -- Auto Adjustment
        pxi_common_df.fc_dmnd_type_6, -- Override
        pxi_common_df.fc_dmnd_type_7, -- Market Activities
        pxi_common_df.fc_dmnd_type_8, -- Data Driven Event
        pxi_common_df.fc_dmnd_type_9  -- Target Impact
      )
      and dmnd_grp_org.acct_assign_id in (
        select acct_assign_id
        from dmnd_acct_assign
        where acct_assign_code = pxi_common_df.fc_acct_assgnmnt_domestic -- Domestic
      )
      group by
        fcst.fcst_id,
        fcst.moe_code,
        dmnd_grp_org.sales_org,
        dmnd_grp_org.bus_sgmnt_code,
        dmnd_grp.dmnd_grp_code,
        dmnd_grp.dmnd_plng_node,
        dmnd_data.zrep,
        dmnd_data.mars_week
      having
        sum(dmnd_data.qty_in_base_uom) > 0 -- Filter unnecessary rows

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'pt_forecast');
  end pt_forecast;

/*******************************************************************************
  NAME: PT_FORECAST_SPLIT                                                 PUBLIC
*******************************************************************************/
  function pt_forecast_split (
    i_fcst_id in common.st_id
  ) return tt_forecast_split pipelined is

    rv_current rt_forecast_split;

    v_qty_split number(10,0);
    v_qty_to_allocate number(10,0);
    v_qty_allocated number(10,0);
    v_group_row_count number(10,0);

  begin

    rv_current.sales_org := ' ';
    rv_current.bus_sgmnt_code := ' ';
    rv_current.dmnd_grp_code := ' ';
    rv_current.zrep_matl_code := ' ';
    rv_current.mars_week := 0;

    for rv_row in (

      select
        forecast.fcst_id,
        forecast.moe_code,
        forecast.sales_org,
        forecast.bus_sgmnt_code,
        forecast.dmnd_grp_code,
        ltrim(forecast.dmnd_plng_node,'0') as dmnd_plng_node,
        ltrim(nvl(dmnd_lookup.dmnd_plng_node, forecast.dmnd_plng_node),'0') as px_dmnd_plng_node,
        forecast.zrep_matl_code,
        forecast.mars_week,
        forecast.start_date,
        forecast.end_date,
        forecast.total_qty as qty_to_allocate,
        nvl(dmnd_lookup.split_percent, 100) as split_percent,
        nvl(dmnd_lookup.split_count, 1) as split_count
      from table(dfnpxi01_extract_v2.pt_forecast(i_fcst_id)) forecast,
        (
          select
            dmnd_split.dmnd_grp_code,
            dmnd_split.bus_sgmnt_code,
            dmnd_split.dmnd_plng_node,
            dmnd_split.split_percent,
            dmnd_split_total.split_count
          from df.px_dmnd_lookup dmnd_split,
            (
              select
                dmnd_grp_code,
                bus_sgmnt_code,
                count(1) split_count
              from df.px_dmnd_lookup
              where split_percent > 0
              group by dmnd_grp_code,
                bus_sgmnt_code
            ) dmnd_split_total
          where dmnd_split.split_percent > 0
          and dmnd_split.dmnd_grp_code = dmnd_split_total.dmnd_grp_code
          and dmnd_split.bus_sgmnt_code = dmnd_split_total.bus_sgmnt_code
        ) dmnd_lookup
      -- Joins
      where forecast.bus_sgmnt_code = dmnd_lookup.bus_sgmnt_code(+) -- forecast -> dmnd_lookup
      and forecast.dmnd_grp_code = dmnd_lookup.dmnd_grp_code(+) -- forecast -> dmnd_lookup
      -- Filter
      and forecast.total_qty > 0 -- Filter unnecessary rows
      order by
        forecast.sales_org,
        dmnd_lookup.bus_sgmnt_code,
        dmnd_lookup.dmnd_grp_code,
        forecast.zrep_matl_code,
        forecast.mars_week,
        dmnd_lookup.split_percent desc, -- Ensure largest split gets its allocation first
        nvl(dmnd_lookup.dmnd_plng_node, forecast.dmnd_plng_node)

    )
    loop

      if not (rv_current.sales_org = rv_row.sales_org
        and rv_current.bus_sgmnt_code = rv_row.bus_sgmnt_code
        and rv_current.dmnd_grp_code = rv_row.dmnd_grp_code
        and rv_current.zrep_matl_code = rv_row.zrep_matl_code
        and rv_current.mars_week = rv_row.mars_week) then -- New group found

        -- Update current group
        rv_current.sales_org := rv_row.sales_org;
        rv_current.bus_sgmnt_code := rv_row.bus_sgmnt_code;
        rv_current.dmnd_grp_code := rv_row.dmnd_grp_code;
        rv_current.zrep_matl_code := rv_row.zrep_matl_code;
        rv_current.mars_week := rv_row.mars_week;
        rv_current.start_date := rv_row.start_date;
        rv_current.end_date := rv_row.end_date;

        -- Update group level values, but not part of grouping key
        rv_current.fcst_id := rv_row.fcst_id;
        rv_current.moe_code := rv_row.moe_code;

        -- Reset working variables
        if rv_row.qty_to_allocate > 0 then
          v_qty_to_allocate := rv_row.qty_to_allocate;
        else -- Qty to allocate cannot be negative, make zero
          v_qty_to_allocate := 0;
        end if;
        v_qty_allocated := 0;
        v_group_row_count := 0;

      end if;

      -- Update row counter
      v_group_row_count := v_group_row_count + 1;

      -- Update Current Demand Planning Node, and PX Demand Planning Node
      rv_current.dmnd_plng_node := rv_row.dmnd_plng_node;
      rv_current.px_dmnd_plng_node := rv_row.px_dmnd_plng_node;

      -- Calculate split qty
      if v_group_row_count < rv_row.split_count then
        v_qty_split := ceil(v_qty_to_allocate * rv_row.split_percent / 100);
        if v_qty_split + v_qty_allocated > v_qty_to_allocate then -- If over allocated, allocate what is remains
          v_qty_split := v_qty_to_allocate - v_qty_allocated;
        end if;
      else -- Last row of group, allocate all that remains
        v_qty_split := v_qty_to_allocate - v_qty_allocated;
      end if;

      -- Update qty allocated
      v_qty_allocated := v_qty_allocated + v_qty_split;

      -- Write row
      rv_current.split_qty := v_qty_split;
      if v_qty_split > 0 then -- Filter unnecessary rows
        pipe row(rv_current);
      end if;

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'pt_forecast_split');
  end pt_forecast_split;

/*******************************************************************************
  NAME: PT_FORECAST_AND_HISTORY                                           PUBLIC
*******************************************************************************/
  function pt_forecast_and_history (
    i_fcst_id in common.st_id
  ) return tt_forecast_and_history pipelined is

    v_moe_code pxi_common.st_moe_code;
    v_jdbc_connection_name varchar2(32 char);

  begin

    -- Lookup MOE code for Forecast Id
    v_moe_code := forecast_moe(i_fcst_id);

    -- Now determine the JDBC Connection
    v_jdbc_connection_name := null;
    case v_moe_code
      when pxi_common.fc_moe_nz then
        v_jdbc_connection_name := 'PX_NZ';
      when pxi_common.fc_moe_pet then
        v_jdbc_connection_name := 'PX_AU_PETCARE';
      when pxi_common.fc_moe_food then
        v_jdbc_connection_name := 'PX_AU_FOOD';
      when pxi_common.fc_moe_snack then
        v_jdbc_connection_name := 'PX_AU_SNACK';
      else
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unknown moe code [' || v_moe_code || '] for forecast id [' || i_fcst_id || '].');
    end case;

    for rv_row in (

        select
          forecast.fcst_id,
          forecast.moe_code,
          forecast.sales_org,
          forecast.bus_sgmnt_code,
          forecast.dmnd_grp_code,
          forecast.zrep_matl_code,
          forecast.mars_week,
          forecast.start_date,
          forecast.end_date,
          forecast.dmnd_plng_node,
          forecast.px_dmnd_plng_node,
          forecast.split_qty,
          forecast.created_date,
          sysdate as modified_date,
          case when account_sku_details_x.as_row_id is null then 0 else 1 end as has_px_account_sku,
          case when ac.ac_code is null then 0 else 1 end as has_px_account,
          case when sku.sku_stock_code is null then 0 else 1 end as has_px_sku
      from (

        select -- forecast
          fcst_id,
          moe_code,
          sales_org,
          bus_sgmnt_code,
          dmnd_grp_code,
          zrep_matl_code,
          mars_week,
          start_date,
          end_date,
          dmnd_plng_node,
          px_dmnd_plng_node,
          split_qty,
          sysdate as created_date
        from table(dfnpxi01_extract_v2.pt_forecast_split(i_fcst_id))
        where end_date > sysdate

        union

        select -- history
          fcst_id,
          moe_code,
          sales_org,
          bus_sgmnt_code,
          dmnd_grp_code,
          zrep_matl_code,
          mars_week,
          start_date,
          end_date,
          dmnd_plng_node,
          px_dmnd_plng_node,
          split_qty,
          created_date
        from px_355dmnd_history
        where moe_code = v_moe_code
        and end_date <= sysdate
        and end_date >= sysdate - (365 * 2) -- Remove history greater than two years old

      ) forecast,
        table(pxi_promax_connect.pt_account_sku_details_x(v_jdbc_connection_name)) account_sku_details_x,
        table(pxi_promax_connect.pt_account(v_jdbc_connection_name)) ac,
        table(pxi_promax_connect.pt_sku(v_jdbc_connection_name)) sku
      -- Joins
      where forecast.px_dmnd_plng_node = account_sku_details_x.ac_code(+) -- forecast > account_sku_details_x
      and forecast.zrep_matl_code = account_sku_details_x.sku_stock_code(+)
      and forecast.start_date >= account_sku_details_x.asd_start_date(+)
      and forecast.end_date <= account_sku_details_x.asd_stop_date(+)
      and forecast.px_dmnd_plng_node = ac.ac_code(+) -- forecast > account
      and forecast.zrep_matl_code = sku.sku_stock_code(+) -- forecast > sku

    )
    loop

      pipe row(rv_row);

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'pt_forecast_and_history');
  end pt_forecast_and_history;

/*******************************************************************************
  NAME: PT_OUTPUT                                                         PUBLIC
*******************************************************************************/
  function pt_output (
    i_fcst_id in common.st_id
  ) return tt_output pipelined is

  begin

    for rv_row in (

      select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
        pxi_common.char_format('Record Type', '355001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '355001' -> Record Type
        pxi_common.char_format('Company Code', sales_org, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- sales_org -> Company Code
        pxi_common.char_format('Division Code', case sales_org when pxi_common.fc_moe_nz then pxi_common.fc_moe_nz else bus_sgmnt_code end, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- division_code -> Division Code
        pxi_common.char_format('Forecast Customer', px_dmnd_plng_node, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- px_dmnd_plng_node -> Forecast Customer
        pxi_common.char_format('ZREP Product', zrep_matl_code, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- zrep_matl_code -> ZREP Product
        pxi_common.date_format('Forecast Start Date', start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- start_date -> Forecast Start Date
        pxi_common.date_format('Forecast End Date', end_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- end_date -> Forecast End Date
        pxi_common.numb_format('Base Sales Volume', split_qty, '9999999999', pxi_common.fc_is_not_nullable) -- split_qty -> Base Sales Volume
        as output_record,
        ------------------------------------------------------------------------
        fcst_id,
        moe_code,
        sales_org,
        bus_sgmnt_code,
        dmnd_grp_code,
        zrep_matl_code,
        mars_week,
        start_date,
        end_date,
        dmnd_plng_node,
        px_dmnd_plng_node,
        split_qty,
        created_date,
        modified_date,
        has_px_account_sku,
        has_px_account,
        has_px_sku
      from table(dfnpxi01_extract_v2.pt_forecast_and_history(i_fcst_id))

    )
    loop
      pipe row(rv_row);
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_OUTPUT');

  end pt_output;

/*******************************************************************************
  NAME: PT_PX_355DMND_HISTORY_PLUS                                        PUBLIC
*******************************************************************************/
  function pt_px_355dmnd_history_plus (
    i_moe_code in varchar2
  ) return tt_px_355dmnd_history_plus pipelined is

  begin

    for rv_row in (

      select
        hist.fcst_id,
        hist.moe_code,
        hist.sales_org,
        hist.bus_sgmnt_code,
        hist.dmnd_grp_code,
        hist.zrep_matl_code,
        hist.mars_week,
        hist.start_date,
        hist.end_date,
        hist.dmnd_plng_node,
        hist.px_dmnd_plng_node,
        hist.split_qty,
        hist.created_date,
        hist.modified_date,
        hist.has_px_account_sku,
        hist.has_px_account,
        hist.has_px_sku,
        dmnd_plng_node.dmnd_grp_name as dmnd_plng_node_desc,
        matl.matl_desc as zrep_matl_desc
      from px_355dmnd_history hist,
        (
          select
            ltrim(dmnd_plng_node, 0) as dmnd_plng_node,
            trim(max(dmnd_grp_name)) as dmnd_grp_name
          from (
              select
                dmnd_plng_node,
                dmnd_grp_name
              from dmnd_grp

              union

              select
                dmnd_plng_node,
                dmnd_grp_desc as dmnd_grp_name
              from df.px_dmnd_lookup
              where dmnd_plng_node not in (
                select dmnd_plng_node
                from dmnd_grp
              )
            )
          group by dmnd_plng_node
        ) dmnd_plng_node,
        (
          select ltrim(matl_code, '0') matl_code,
            matl_desc
          from matl
        ) matl
      -- Joins
      where hist.px_dmnd_plng_node = dmnd_plng_node.dmnd_plng_node(+) -- hist > dmnd_plng_node
      and hist.zrep_matl_code = matl.matl_code(+) -- hist > matl

    )
    loop

      pipe row(rv_row);

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'pt_px_355dmnd_history_plus');
  end pt_px_355dmnd_history_plus;

/*******************************************************************************
  NAME: PT_ERROR_REPORT                                                   PUBLIC
*******************************************************************************/
  function pt_error_report (
    i_moe_code in varchar2
  ) return tt_error_report pipelined is

  begin

    for rv_row in (

      select
        sort_seq,
        error_desc,
        account_code,
        px_account_code,
        px_account_desc,
        sku_code,
        sku_desc,
        start_date,
        end_date,
        record_count,
        total_qty
      from (
          select
            1 as sort_seq,
            'Missing Account in Promax PX' as error_desc,
            dmnd_plng_node as account_code,
            px_dmnd_plng_node as px_account_code,
            max(px_dmnd_plng_node_desc) as px_account_desc,
            null as sku_code,
            null as sku_desc,
            min(start_date) as start_date,
            max(end_date) as end_date,
            count(1) as record_count,
            sum(split_qty) as total_qty
          from table(dfnpxi01_extract_v2.pt_px_355dmnd_history_plus(i_moe_code)) hist
          where moe_code = i_moe_code
          and hist.has_px_account = 0
          group by
            dmnd_plng_node,
            px_dmnd_plng_node

          union all

          select
            2 as sort_seq,
            'Missing SKU in Promax PX' as error_desc,
            null as account_code,
            null as px_account_code,
            null as px_account_desc,
            zrep_matl_code as sku_code,
            max(zrep_matl_desc) as sku_desc,
            min(start_date) as start_date,
            max(end_date) as end_date,
            count(1) as record_count,
            sum(split_qty) as total_qty
          from table(dfnpxi01_extract_v2.pt_px_355dmnd_history_plus(i_moe_code)) hist
          where moe_code = i_moe_code
          and hist.has_px_sku = 0
          group by
            zrep_matl_code

          union all

          select
            3 as sort_seq,
            'Missing Account / SKU (Range) in Promax PX' as error_desc,
            dmnd_plng_node as account_code,
            px_dmnd_plng_node as px_account_code,
            max(px_dmnd_plng_node_desc) as px_account_desc,
            zrep_matl_code as sku_code,
            max(zrep_matl_desc) as sku_desc,
            min(start_date) as start_date,
            max(end_date) as end_date,
            count(1) as record_count,
            sum(split_qty) as total_qty
          from table(dfnpxi01_extract_v2.pt_px_355dmnd_history_plus(i_moe_code)) hist
          where moe_code = i_moe_code
          and hist.has_px_account_sku = 0
          group by
            dmnd_plng_node,
            px_dmnd_plng_node,
            zrep_matl_code
        ) error_report
      order by
        error_report.sort_seq,
        error_report.px_account_code,
        error_report.sku_code

    )
    loop

      pipe row(rv_row);

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'pt_error_report');
  end pt_error_report;

/*******************************************************************************
  NAME: EMAIL_ERROR_REPORT                                                PUBLIC
*******************************************************************************/
  procedure email_error_report (
    i_moe_code in varchar2
  ) is

    v_subject varchar2(256 char);
    v_output_line varchar2(256 char);
    v_email varchar2(256 char);

    v_missing_px_account_sku_count number;
    v_missing_px_account_count number;
    v_missing_px_sku_count number;

  begin

    select count(1) into v_missing_px_account_sku_count
    from table(dfnpxi01_extract_v2.pt_px_355dmnd_history_plus(i_moe_code))
    where has_px_account_sku = 0; -- Mising account / sku

    if v_missing_px_account_sku_count = 0 then -- No errors to report
      return;
    end if;

    select count(1) into v_missing_px_account_count
    from table(dfnpxi01_extract_v2.pt_px_355dmnd_history_plus(i_moe_code))
    where has_px_account = 0; -- Mising account

    select count(1) into v_missing_px_sku_count
    from table(dfnpxi01_extract_v2.pt_px_355dmnd_history_plus(i_moe_code))
    where has_px_sku = 0; -- Mising sku

    v_subject := 'Demand Financials > Promax PX - MOE ' || i_moe_code || ' - ERRORS' ||
      ' - Missing Account (' || v_missing_px_account_count || ')' ||
      ' - Missing SKU (' || v_missing_px_sku_count || ')' ||
      ' - Missing Account SKU (' || v_missing_px_account_sku_count || ')'
    ;

    -- Retrieve email group
    v_email := lics_setting_configuration.retrieve_setting('PROMAX_PX_MOE_'||i_moe_code, 'BASELINE_EXTRACT_ERR_EMAIL_GROUP');
    if v_email is null then
      pxi_common.raise_promax_error(pc_package_name,'EMAIL_ERROR_REPORT','[PROMAX_PX_MOE_'||i_moe_code||'.BASELINE_EXTRACT_ERR_EMAIL_GROUP] Not Found in [LICS_SETTING]');
    end if;

    -- Create email
    lics_mailer.create_email(
      'Demand_Financials_to_Promax_PX',
      v_email,
      v_subject,
      lics_parameter.email_smtp_host,
      lics_parameter.email_smtp_port
    );

    -- Create email part
    lics_mailer.create_part('Error_Report_' || to_char(sysdate, 'YYYYMMDD') || '.csv');

    v_output_line := 'Error Desc,Account Code,Promax PX Account Code,Promax PX Account Desc,SKU Code,SKU Desc,Start Date,End Date,Record Count,Total Qty';
    lics_mailer.append_data(v_output_line);

    -- Append report to email
    for rv_row in (

      select
        trim(replace(error_desc, ',', ' ')) || ',' ||
        trim(replace(account_code, ',', ' ')) || ',' ||
        trim(replace(px_account_code, ',', ' ')) || ',' ||
        trim(replace(px_account_desc, ',', ' ')) || ',' ||
        trim(replace(sku_code, ',', ' ')) || ',' ||
        trim(replace(sku_desc, ',', ' ')) || ',' ||
        to_char(start_date, 'YYYY-MM-DD') || ',' ||
        to_char(end_date, 'YYYY-MM-DD') || ',' ||
        record_count || ',' ||
        total_qty
        as output_record
      from table(dfnpxi01_extract_v2.pt_error_report(i_moe_code))
      order by sort_seq

    )
    loop

      lics_mailer.append_data(rv_row.output_record);

    end loop;

    -- Finalise email
    lics_mailer.finalise_email;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'email_error_report');
  end email_error_report;

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
    i_fcst_id in common.st_id
   ) is

    v_moe_code pxi_common.st_moe_code;
    v_interface_name_with_suffix pxi_common.st_interface_name;
    v_instance number(15,0);

  begin

    -- request lock (on interface)
    begin
      lics_locking.request(pc_interface_name);
    exception
      when others then
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE',substr('Unable to obtain interface lock ['||pc_interface_name||'] - '||sqlerrm, 1, 4000));
    end;

    -- Now determine the interface name to use for this file.
    v_moe_code := forecast_moe(i_fcst_id); -- assign so we don't need to lookup twice
    v_interface_name_with_suffix := null;
    case v_moe_code
      when pxi_common.fc_moe_nz then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_nz;
      when pxi_common.fc_moe_pet then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_pet;
      when pxi_common.fc_moe_food then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_food;
      when pxi_common.fc_moe_snack then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_snack;
      else
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unknown moe code [' || v_moe_code || '] for forecast id [' || i_fcst_id || '].');
    end case;

    -- Ensure 335DMND temporary table is empty
    delete from px_355dmnd_history_temp;

    for rv_row in (

      select
        output_record,
        fcst_id,
        moe_code,
        sales_org,
        bus_sgmnt_code,
        dmnd_grp_code,
        zrep_matl_code,
        mars_week,
        start_date,
        end_date,
        dmnd_plng_node,
        px_dmnd_plng_node,
        split_qty,
        created_date,
        modified_date,
        has_px_account_sku,
        has_px_account,
        has_px_sku
      from table(dfnpxi01_extract_v2.pt_output(i_fcst_id))

    )
    loop

      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(v_interface_name_with_suffix);
      end if;

      -- Populate 355DMND temporary table
      insert into px_355dmnd_history_temp (
        fcst_id,
        moe_code,
        sales_org,
        bus_sgmnt_code,
        dmnd_grp_code,
        zrep_matl_code,
        mars_week,
        start_date,
        end_date,
        dmnd_plng_node,
        px_dmnd_plng_node,
        split_qty,
        created_date,
        modified_date,
        has_px_account_sku,
        has_px_account,
        has_px_sku
      ) values (
        rv_row.fcst_id,
        rv_row.moe_code,
        rv_row.sales_org,
        rv_row.bus_sgmnt_code,
        rv_row.dmnd_grp_code,
        rv_row.zrep_matl_code,
        rv_row.mars_week,
        rv_row.start_date,
        rv_row.end_date,
        rv_row.dmnd_plng_node,
        rv_row.px_dmnd_plng_node,
        rv_row.split_qty,
        rv_row.created_date,
        rv_row.modified_date,
        rv_row.has_px_account_sku,
        rv_row.has_px_account,
        rv_row.has_px_sku
      );

      -- Append interface data for records that have active Promax PX Account SKU (Range)
      if rv_row.has_px_account_sku = 1 then
        lics_outbound_loader.append_data(rv_row.output_record);
      end if;

    end loop;

    -- Replace 355DMND history for the current MOE (based on Forecast Id)
    delete from px_355dmnd_history where moe_code = v_moe_code;
    insert into px_355dmnd_history select * from px_355dmnd_history_temp where moe_code = v_moe_code; -- px_355dmnd_history and px_355dmnd_history_temp have identical structures

    -- Finalise interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

    -- Commit changes to product history extract table
    commit;

    -- Release lock (on interface)
    lics_locking.release(pc_interface_name);

    -- Email error report (if necessary)
    dfnpxi01_extract_v2.email_error_report(v_moe_code);

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end dfnpxi01_extract_v2;
/

grant execute on df_app.dfnpxi01_extract_v2 to lics_app, fflu_app;
