
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu5_act_dtl_pkg as
  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu5
    Owner    : dds_app
    Package  : qu5_act_dtl_pkg
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    Container Package to Provide Custom (Persisted) Views for Activities

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-27  Mal Chambeyron        Created
    2013-08-13  Mal Chambeyron        Cast into Template
    2013-09-24  Tom Docherty          Added [view_at_shrt] .. limiting return set to
                                      necessary columns.
    2013-11-14  Tom Docherty          Modify persistent logic to return latest values
                                      per customer, not per product per customer. Quofore
                                      interface sends all latest records, not product delta's,
                                      and removing [act_dtl_id] from return type.
                                      Added Cust To Terr short Function and type
    2014-05-18  Mal Chambeyron        Cleanup Source Id
    2014-05-18  Mal Chambeyron        Make into a Template
    2014-05-26  Mal Chambeyron        Updated [view_at_date] to handle [act_dtl] without [prod_id]
    2014-05-27  Mal Chambeyron        Updated [view_at_date] to select latest actvity by cust / task
    2014-05-27  Mal Chambeyron        Updated [view_at_date] to limit task where to it is effective during period
    2014-06-03  Mal Chambeyron        Updated [view_at_date], remove [terr_id] and [rep_id],
                                      as can be misleading regards time phasing
    2014-07-08  Tom Docherty          Updated [cust_terr_pos_rep] to Left join Pos and Rep, rather than Inner Join
    2014-07-14  Mal Chambeyron        Remove [view_at_shrt] functions, as no longer used.
    2015-03-16  Mal Chambeyron        Updated [view_at_date], to combine logic / filters from previous Quofore deployments ..
                                      - limit to latest effective (within period) activity detail per customer / task (by start date)
                                      - [cust_id] limit to records where customer is active
                                      - [prod_id] where exists, limit to records where product is active
                                      - [prod_hier_id] where exists, limit to records where product hierarchy node is active
                                      - [hier_nod_id] where exists, limit to records where hierarchy node is active
                                      - limit to records where at least one persisted column containts a value other than zeros, spaces or null
    2015-03-17  Mal Chambeyron        Add logic to handle fact that
                                      - *callcard* is [call_card] in [4] chocolate au, and [callcard] in all other implementations
                                      - terr_id included in *callcard* since [4] chocolate au
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-03-23  Mal Chambeyron        Update limit to records where at least one persisted column containts a value other than zeros, spaces or null
                                      to overcome [ORA-01847: day of month must be between 1 and last day of month], where persisted column is a data and null
                                      - decode(trim(to_char(table_name.column_name)), null, 0, 1) > 0
    2015-03-30  Mal Chambeyron        Remove reference to terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  ------------------------------------------------------------------------------
  -- Public : Type : Customer > Terrirory > Position > Rep
  type qu5_cust_to_rep_rec is record (
    report_date date,
    --
    cust_id number(10,0),
    cust_batch_id number(15,0),
    cust_terr_id number(10,0),
    cust_terr_batch_id number(15,0),
    terr_id number(10,0),
    terr_batch_id number(15,0),
    pos_terr_id number(10,0),
    pos_terr_batch_id number(15,0),
    is_primary_terr number(1,0),
    pos_id number(10,0),
    pos_batch_id number(15,0),
    rep_id number(10,0),
    rep_batch_id number(15,0)
  );

  type qu5_cust_to_rep_type is table of qu5_cust_to_rep_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : Latest Customer / Task / callcard / Activity by Activity Start Date
  type qu5_cust_task_rec is record (
    cust_id number(10,0),
    task_id number(10,0),
    start_date date,
    act_id number(10,0),
    callcard_id number(10,0),
    -- terr_id number(10,0), -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
    rep_id number(10,0)
  );

  type qu5_cust_task_type is table of qu5_cust_task_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : [dist_check_1]
  type qu5_dist_check_1_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    is_prod_in_distribution number(1, 0)
  );

  type qu5_dist_check_1_type is table of qu5_dist_check_1_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [dist_check_2]
  type qu5_dist_check_2_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    is_prod_in_distribution number(1, 0),
    is_prime_loc_on_shelf number(1, 0)
  );

  type qu5_dist_check_2_type is table of qu5_dist_check_2_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [relay_hours]
  type qu5_relay_hours_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    relay_hours number(10, 0)
  );

  type qu5_relay_hours_type is table of qu5_relay_hours_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [second_site]
  type qu5_second_site_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    second_site_qty number(10, 0)
  );

  type qu5_second_site_type is table of qu5_second_site_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [interuption]
  type qu5_interuption_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    point_of_interest_qty number(10, 0)
  );

  type qu5_interuption_type is table of qu5_interuption_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [hardware]
  type qu5_hardware_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    hardware_qty number(10, 0)
  );

  type qu5_hardware_type is table of qu5_hardware_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [upgrades]
  type qu5_upgrades_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    upgrades_at_visit_qty number(10, 0)
  );

  type qu5_upgrades_type is table of qu5_upgrades_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [training]
  type qu5_training_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    training_in_store_hours number(10, 0)
  );

  type qu5_training_type is table of qu5_training_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [shelf_share]
  type qu5_shelf_share_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    is_share_of_shelf_photo_sent number(10, 0)
  );

  type qu5_shelf_share_type is table of qu5_shelf_share_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [compliant]
  type qu5_compliant_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    is_promo_complient number(10, 0)
  );

  type qu5_compliant_type is table of qu5_compliant_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [new_prod_dev]
  type qu5_new_prod_dev_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    is_prod_ticketed number(10, 0),
    is_prod_on_shelf number(10, 0)
  );

  type qu5_new_prod_dev_type is table of qu5_new_prod_dev_rec;


  ------------------------------------------------------------------------------
  -- Public : Functions
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu5_cust_to_rep_type pipelined;
  function cust_task_view_at_date(p_at_date in date) return qu5_cust_task_type pipelined;
  function cust_eff_task_view_at_date(p_at_date in date) return qu5_cust_task_type pipelined;

  function dist_check_1_view_at_date(p_at_date in date) return qu5_dist_check_1_type pipelined;
  function dist_check_2_view_at_date(p_at_date in date) return qu5_dist_check_2_type pipelined;
  function relay_hours_view_at_date(p_at_date in date) return qu5_relay_hours_type pipelined;
  function second_site_view_at_date(p_at_date in date) return qu5_second_site_type pipelined;
  function interuption_view_at_date(p_at_date in date) return qu5_interuption_type pipelined;
  function hardware_view_at_date(p_at_date in date) return qu5_hardware_type pipelined;
  function upgrades_view_at_date(p_at_date in date) return qu5_upgrades_type pipelined;
  function training_view_at_date(p_at_date in date) return qu5_training_type pipelined;
  function shelf_share_view_at_date(p_at_date in date) return qu5_shelf_share_type pipelined;
  function compliant_view_at_date(p_at_date in date) return qu5_compliant_type pipelined;
  function new_prod_dev_view_at_date(p_at_date in date) return qu5_new_prod_dev_type pipelined;

end qu5_act_dtl_pkg;
/

create or replace package body dds_app.qu5_act_dtl_pkg as

  ------------------------------------------------------------------------------
  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  ------------------------------------------------------------------------------
  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu5_act_dtl_pkg';

  ------------------------------------------------------------------------------
  -- Function : Customer > Terrirory > Position > Rep, as at Date
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu5_cust_to_rep_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        cust.id cust_id,
        cust.q4x_batch_id cust_batch_id,
        cust_terr.id cust_terr_id,
        cust_terr.q4x_batch_id cust_terr_batch_id,
        terr.id terr_id,
        terr.q4x_batch_id terr_batch_id,
        pos_terr.id pos_terr_id,
        pos_terr.q4x_batch_id pos_terr_batch_id,
        pos_terr.is_primary_terr,
        pos.id pos_id,
        pos.q4x_batch_id pos_batch_id,
        rep.id rep_id,
        rep.q4x_batch_id rep_batch_id
      from table(qu5_cust_pkg.view_at_date(p_at_date)) cust,
        table(qu5_cust_terr_pkg.view_at_date(p_at_date)) cust_terr,
        table(qu5_terr_pkg.view_at_date(p_at_date)) terr,
        table(qu5_pos_terr_pkg.view_at_date(p_at_date)) pos_terr,
        table(qu5_pos_pkg.view_at_date(p_at_date)) pos,
        table(qu5_rep_pkg.view_at_date(p_at_date)) rep
      where cust.id = cust_terr.cust_id
      and cust_terr.terr_id = terr.id
      and terr.id = pos_terr.terr_id (+)
      and pos_terr.pos_id = pos.id (+)
      and pos.id = rep.pos_id (+)

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_terr_pos_rep_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_terr_pos_rep_view_at_date;

  ------------------------------------------------------------------------------
  -- Function : Latest Customer Task, as at Date (by Start Date)
  function cust_task_view_at_date(p_at_date in date) return qu5_cust_task_type pipelined is

    prev_cust_id number(10,0);
    prev_task_id number(10,0);

  begin

    -- set to impossible values to save null check
    prev_cust_id := -1;
    prev_task_id := -1;

    for l_entity in (


      select callcard.cust_id,
        act_hdr.task_id,
        act_hdr.start_date,
        act_hdr.id act_id,
        act_hdr.callcard_id,
        -- callcard.terr_id, -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
        callcard.rep_id
      from table(qu5_act_hdr_pkg.view_at_date(p_at_date)) act_hdr,
        table(qu5_callcard_pkg.view_at_date(p_at_date)) callcard,
        table(qu5_cust_pkg.view_at_date(p_at_date)) cust
      where act_hdr.start_date <= p_at_date
        and act_hdr.callcard_id = callcard.id
        and callcard.cust_id = cust.id
        -- limit to active customers
        and cust.is_active = 1
        -- limit to activities that have activity details
        and act_hdr.id in (
          select act_id from table(qu5_act_dtl_dist_check_1_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_dist_check_2_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_relay_hours_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_second_site_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_interuption_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_hardware_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_upgrades_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_training_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_shelf_share_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_compliant_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu5_act_dtl_new_prod_dev_pkg.view_at_date(p_at_date))
        )
      order by callcard.cust_id,
        act_hdr.task_id,
        act_hdr.start_date desc

    )
    loop
      if l_entity.cust_id != prev_cust_id or l_entity.task_id != prev_task_id then
        prev_cust_id := l_entity.cust_id;
        prev_task_id := l_entity.task_id;
        pipe row(l_entity);
      end if;
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_task_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_task_view_at_date;

  ------------------------------------------------------------------------------
  -- Function : Latest Customer Task - Restricted to Task Effective during Period, as at Date
  function cust_eff_task_view_at_date(p_at_date in date) return qu5_cust_task_type pipelined is

  begin

    for l_entity in (

      select cust_task.cust_id,
        cust_task.task_id,
        cust_task.start_date,
        cust_task.act_id,
        cust_task.callcard_id,
        -- cust_task.terr_id, -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
        cust_task.rep_id
      from table(qu5_act_dtl_pkg.cust_task_view_at_date(p_at_date)) cust_task
      where cust_task.task_id in (
        select task.id task_id
        from table(qu5_task_pkg.view_at_date(p_at_date)) task,
          (
            select min(calendar_date) period_start_date,
              max(calendar_date) period_end_date
            from mars_date
            where mars_period = (
              select mars_period
              from mars_date
              where calendar_date = trunc(p_at_date)
            )
          ) mars_calendar
        where nvl(task.start_date, to_date('00010101','YYYYMMDD')) <= mars_calendar.period_end_date
        and nvl(task.end_date, to_date('99991231','YYYYMMDD')) >= mars_calendar.period_start_date
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.cust_eff_task_view_at_date] : '||SQLERRM, 1, 4000));

  end cust_eff_task_view_at_date;

  ------------------------------------------------------------------------------
  -- Function : [dist_check_1], as at Date
  function dist_check_1_view_at_date(p_at_date in date) return qu5_dist_check_1_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.prod_id,
        -- persisted attributes
        act_dtl.is_prod_in_distribution
        --
      from table(qu5_act_dtl_dist_check_1_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_prod_pkg.view_at_date(p_at_date)) prod
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active product, where id populated
      and act_dtl.prod_id = prod.id(+)
      and (act_dtl.prod_id is null or prod.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.is_prod_in_distribution)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.dist_check_1_view_at_date] : '||SQLERRM, 1, 4000));

  end dist_check_1_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [dist_check_2], as at Date
  function dist_check_2_view_at_date(p_at_date in date) return qu5_dist_check_2_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.prod_id,
        -- persisted attributes
        act_dtl.is_prod_in_distribution,
        act_dtl.is_prime_loc_on_shelf
        --
      from table(qu5_act_dtl_dist_check_2_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_prod_pkg.view_at_date(p_at_date)) prod
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active product, where id populated
      and act_dtl.prod_id = prod.id(+)
      and (act_dtl.prod_id is null or prod.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.is_prod_in_distribution)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_prime_loc_on_shelf)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.dist_check_2_view_at_date] : '||SQLERRM, 1, 4000));

  end dist_check_2_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [relay_hours], as at Date
  function relay_hours_view_at_date(p_at_date in date) return qu5_relay_hours_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.relay_hours
        --
      from table(qu5_act_dtl_relay_hours_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.relay_hours)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.relay_hours_view_at_date] : '||SQLERRM, 1, 4000));

  end relay_hours_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [second_site], as at Date
  function second_site_view_at_date(p_at_date in date) return qu5_second_site_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.second_site_qty
        --
      from table(qu5_act_dtl_second_site_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.second_site_qty)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.second_site_view_at_date] : '||SQLERRM, 1, 4000));

  end second_site_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [interuption], as at Date
  function interuption_view_at_date(p_at_date in date) return qu5_interuption_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.point_of_interest_qty
        --
      from table(qu5_act_dtl_interuption_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.point_of_interest_qty)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.interuption_view_at_date] : '||SQLERRM, 1, 4000));

  end interuption_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [hardware], as at Date
  function hardware_view_at_date(p_at_date in date) return qu5_hardware_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.hardware_qty
        --
      from table(qu5_act_dtl_hardware_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.hardware_qty)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.hardware_view_at_date] : '||SQLERRM, 1, 4000));

  end hardware_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [upgrades], as at Date
  function upgrades_view_at_date(p_at_date in date) return qu5_upgrades_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.upgrades_at_visit_qty
        --
      from table(qu5_act_dtl_upgrades_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.upgrades_at_visit_qty)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.upgrades_view_at_date] : '||SQLERRM, 1, 4000));

  end upgrades_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [training], as at Date
  function training_view_at_date(p_at_date in date) return qu5_training_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.training_in_store_hours
        --
      from table(qu5_act_dtl_training_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.training_in_store_hours)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.training_view_at_date] : '||SQLERRM, 1, 4000));

  end training_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [shelf_share], as at Date
  function shelf_share_view_at_date(p_at_date in date) return qu5_shelf_share_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.is_share_of_shelf_photo_sent
        --
      from table(qu5_act_dtl_shelf_share_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.is_share_of_shelf_photo_sent)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.shelf_share_view_at_date] : '||SQLERRM, 1, 4000));

  end shelf_share_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [compliant], as at Date
  function compliant_view_at_date(p_at_date in date) return qu5_compliant_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.hier_node_id,
        -- persisted attributes
        act_dtl.is_promo_complient
        --
      from table(qu5_act_dtl_compliant_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_hier_pkg.view_at_date(p_at_date)) hier
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active hierarchy node, where id populated
      and act_dtl.hier_node_id = hier.id(+)
      and (act_dtl.hier_node_id is null or hier.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.is_promo_complient)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.compliant_view_at_date] : '||SQLERRM, 1, 4000));

  end compliant_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [new_prod_dev], as at Date
  function new_prod_dev_view_at_date(p_at_date in date) return qu5_new_prod_dev_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        -- activity detail keys
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        -- product / hierarchy keys
        act_dtl.prod_id,
        -- persisted attributes
        act_dtl.is_prod_ticketed,
        act_dtl.is_prod_on_shelf
        --
      from table(qu5_act_dtl_new_prod_dev_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu5_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu5_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu5_prod_pkg.view_at_date(p_at_date)) prod
      -- limit to latest effective (within period) activity detail ..  per customer / task (by Start Date)
      where act_dtl.act_id = cust_task.act_id
      -- limit to active customer *** removed as already filtered in [cust_eff_task_view_at_date]
      -- and cust_task.cust_id = cust.id
      -- and cust.is_active = 1
      -- limit to active product, where id populated
      and act_dtl.prod_id = prod.id(+)
      and (act_dtl.prod_id is null or prod.is_active = 1)
      -- limit to records where at least one persisted column containts a value other than zeros, spaces or null
      and (
        decode(trim(to_char(act_dtl.is_prod_ticketed)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_prod_on_shelf)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.new_prod_dev_view_at_date] : '||SQLERRM, 1, 4000));

  end new_prod_dev_view_at_date;


end qu5_act_dtl_pkg;
/

-- Synonyms
create or replace public synonym qu5_act_dtl_pkg for dds_app.qu5_act_dtl_pkg;

-- Grants
grant execute on dds_app.qu5_act_dtl_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
