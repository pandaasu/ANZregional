
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu3_act_dtl_pkg as
  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu3
    Owner    : dds_app
    Package  : qu3_act_dtl_pkg
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
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
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  ------------------------------------------------------------------------------
  -- Public : Type : Customer > Terrirory > Position > Rep
  type qu3_cust_to_rep_rec is record (
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

  type qu3_cust_to_rep_type is table of qu3_cust_to_rep_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : Latest Customer / Task / callcard / Activity by Activity Start Date
  type qu3_cust_task_rec is record (
    cust_id number(10,0),
    task_id number(10,0),
    start_date date,
    act_id number(10,0),
    callcard_id number(10,0),
    -- terr_id number(10,0), -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
    rep_id number(10,0)
  );

  type qu3_cust_task_type is table of qu3_cust_task_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : [hotspot]
  type qu3_hotspot_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_achieved number(10, 0),
    no_otc_gum_facing number(10, 0),
    no_mp_gum_facing number(10, 0),
    no_mint_facing number(10, 0),
    no_confec_facing number(10, 0),
    no_confec_facing_2 number(10, 0)
  );

  type qu3_hotspot_type is table of qu3_hotspot_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [gpa]
  type qu3_gpa_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_with_wwy_cover number(10, 0),
    otc_gum_facings number(10, 0),
    no_mp_gum_facing number(10, 0),
    no_mint_facing number(10, 0),
    no_confec_facing number(10, 0),
    no_confec_facing_2 number(10, 0),
    no_choc_bar_facing number(10, 0),
    no_comp_gum_facing number(10, 0),
    no_comp_mint_facing number(10, 0),
    no_comp_candy_facing number(10, 0)
  );

  type qu3_gpa_type is table of qu3_gpa_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [ranging]
  type qu3_ranging_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    ranged_hotspot number(1, 0),
    ranged_non_hotspot number(1, 0)
  );

  type qu3_ranging_type is table of qu3_ranging_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [pos]
  type qu3_pos_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    placed number(1, 0)
  );

  type qu3_pos_type is table of qu3_pos_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [off_loc]
  type qu3_off_loc_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_gondola number(10, 0),
    no_wing number(10, 0),
    no_flat_pack_tower number(10, 0),
    no_pre_pack_tower number(10, 0),
    no_flat_pack_cdus number(10, 0),
    no_pre_pack_cdus number(10, 0),
    no_buckets number(10, 0),
    no_clip_strip number(10, 0),
    no_other number(10, 0),
    stock_qty number(10, 0),
    promo_start_date date,
    promo_end_date date,
    coop_spend number(18, 4),
    sold_in_by number(10, 0),
    built_by number(10, 0)
  );

  type qu3_off_loc_type is table of qu3_off_loc_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [hwaudit_gr]
  type qu3_hwaudit_gr_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_std_chkout number(10, 0)
  );

  type qu3_hwaudit_gr_type is table of qu3_hwaudit_gr_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [hwaudit_ro]
  type qu3_hwaudit_ro_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_hotspot number(10, 0),
    no_non_hotspot number(10, 0)
  );

  type qu3_hwaudit_ro_type is table of qu3_hwaudit_ro_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [storeop_gr]
  type qu3_storeop_gr_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_std_chkout_reg number(10, 0),
    no_std_chkout_os number(10, 0),
    no_std_chkout_fe number(10, 0),
    no_confec_free_chkout number(10, 0),
    no_confec_free_chkout_top_ number(10, 0),
    no_express_chkout number(10, 0),
    no_express_q number(10, 0),
    no_selfscan_chkout number(10, 0),
    no_selfscan_q number(10, 0),
    no_confec_bay_ number(10, 0)
  );

  type qu3_storeop_gr_type is table of qu3_storeop_gr_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [storeop_ro]
  type qu3_storeop_ro_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_register number(10, 0),
    no_chiller_door number(10, 0),
    no_parallel_store number(10, 0),
    no_paralle_wwy_stand number(10, 0),
    no_comp_wwy_stand number(10, 0),
    no_oos_wwy_stand number(10, 0),
    no_pack_date_issue number(10, 0),
    pref_wholesaler number(10, 0)
  );

  type qu3_storeop_ro_type is table of qu3_storeop_ro_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [top_sku]
  type qu3_top_sku_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_std_chk_belt number(10, 0),
    no_std_chk_front number(10, 0),
    no_exp_chk_pop number(10, 0),
    no_ss_chk_pop number(10, 0),
    no_q_zone number(10, 0),
    no_std_chk_non_belt number(10, 0),
    no_aisle number(10, 0)
  );

  type qu3_top_sku_type is table of qu3_top_sku_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [pcking_chg]
  type qu3_pcking_chg_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    percent_stock_in_new_pack number(10, 0)
  );

  type qu3_pcking_chg_type is table of qu3_pcking_chg_rec;


  ------------------------------------------------------------------------------
  -- Public : Functions
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu3_cust_to_rep_type pipelined;
  function cust_task_view_at_date(p_at_date in date) return qu3_cust_task_type pipelined;
  function cust_eff_task_view_at_date(p_at_date in date) return qu3_cust_task_type pipelined;

  function hotspot_view_at_date(p_at_date in date) return qu3_hotspot_type pipelined;
  function gpa_view_at_date(p_at_date in date) return qu3_gpa_type pipelined;
  function ranging_view_at_date(p_at_date in date) return qu3_ranging_type pipelined;
  function pos_view_at_date(p_at_date in date) return qu3_pos_type pipelined;
  function off_loc_view_at_date(p_at_date in date) return qu3_off_loc_type pipelined;
  function hwaudit_gr_view_at_date(p_at_date in date) return qu3_hwaudit_gr_type pipelined;
  function hwaudit_ro_view_at_date(p_at_date in date) return qu3_hwaudit_ro_type pipelined;
  function storeop_gr_view_at_date(p_at_date in date) return qu3_storeop_gr_type pipelined;
  function storeop_ro_view_at_date(p_at_date in date) return qu3_storeop_ro_type pipelined;
  function top_sku_view_at_date(p_at_date in date) return qu3_top_sku_type pipelined;
  function pcking_chg_view_at_date(p_at_date in date) return qu3_pcking_chg_type pipelined;

end qu3_act_dtl_pkg;
/

create or replace package body dds_app.qu3_act_dtl_pkg as

  ------------------------------------------------------------------------------
  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  ------------------------------------------------------------------------------
  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu3_act_dtl_pkg';

  ------------------------------------------------------------------------------
  -- Function : Customer > Terrirory > Position > Rep, as at Date
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu3_cust_to_rep_type pipelined is

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
      from table(qu3_cust_pkg.view_at_date(p_at_date)) cust,
        table(qu3_cust_terr_pkg.view_at_date(p_at_date)) cust_terr,
        table(qu3_terr_pkg.view_at_date(p_at_date)) terr,
        table(qu3_pos_terr_pkg.view_at_date(p_at_date)) pos_terr,
        table(qu3_pos_pkg.view_at_date(p_at_date)) pos,
        table(qu3_rep_pkg.view_at_date(p_at_date)) rep
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
  function cust_task_view_at_date(p_at_date in date) return qu3_cust_task_type pipelined is

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
      from table(qu3_act_hdr_pkg.view_at_date(p_at_date)) act_hdr,
        table(qu3_callcard_pkg.view_at_date(p_at_date)) callcard,
        table(qu3_cust_pkg.view_at_date(p_at_date)) cust
      where act_hdr.start_date <= p_at_date
        and act_hdr.callcard_id = callcard.id
        and callcard.cust_id = cust.id
        -- limit to active customers
        and cust.is_active = 1
        -- limit to activities that have activity details
        and act_hdr.id in (
          select act_id from table(qu3_act_dtl_hotspot_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_gpa_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_ranging_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_pos_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_off_loc_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_hwaudit_gr_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_hwaudit_ro_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_storeop_gr_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_storeop_ro_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_top_sku_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu3_act_dtl_pcking_chg_pkg.view_at_date(p_at_date))
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
  function cust_eff_task_view_at_date(p_at_date in date) return qu3_cust_task_type pipelined is

  begin

    for l_entity in (

      select cust_task.cust_id,
        cust_task.task_id,
        cust_task.start_date,
        cust_task.act_id,
        cust_task.callcard_id,
        -- cust_task.terr_id, -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
        cust_task.rep_id
      from table(qu3_act_dtl_pkg.cust_task_view_at_date(p_at_date)) cust_task
      where cust_task.task_id in (
        select task.id task_id
        from table(qu3_task_pkg.view_at_date(p_at_date)) task,
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
  -- Function : [hotspot], as at Date
  function hotspot_view_at_date(p_at_date in date) return qu3_hotspot_type pipelined is

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
        act_dtl.no_achieved,
        act_dtl.no_otc_gum_facing,
        act_dtl.no_mp_gum_facing,
        act_dtl.no_mint_facing,
        act_dtl.no_confec_facing,
        act_dtl.no_confec_facing_2
        --
      from table(qu3_act_dtl_hotspot_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_achieved)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_otc_gum_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_mp_gum_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_mint_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_facing_2)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.hotspot_view_at_date] : '||SQLERRM, 1, 4000));

  end hotspot_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [gpa], as at Date
  function gpa_view_at_date(p_at_date in date) return qu3_gpa_type pipelined is

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
        act_dtl.no_with_wwy_cover,
        act_dtl.otc_gum_facings,
        act_dtl.no_mp_gum_facing,
        act_dtl.no_mint_facing,
        act_dtl.no_confec_facing,
        act_dtl.no_confec_facing_2,
        act_dtl.no_choc_bar_facing,
        act_dtl.no_comp_gum_facing,
        act_dtl.no_comp_mint_facing,
        act_dtl.no_comp_candy_facing
        --
      from table(qu3_act_dtl_gpa_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_with_wwy_cover)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.otc_gum_facings)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_mp_gum_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_mint_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_facing_2)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_choc_bar_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_comp_gum_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_comp_mint_facing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_comp_candy_facing)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.gpa_view_at_date] : '||SQLERRM, 1, 4000));

  end gpa_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [ranging], as at Date
  function ranging_view_at_date(p_at_date in date) return qu3_ranging_type pipelined is

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
        act_dtl.ranged_hotspot,
        act_dtl.ranged_non_hotspot
        --
      from table(qu3_act_dtl_ranging_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.ranged_hotspot)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.ranged_non_hotspot)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.ranging_view_at_date] : '||SQLERRM, 1, 4000));

  end ranging_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [pos], as at Date
  function pos_view_at_date(p_at_date in date) return qu3_pos_type pipelined is

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
        act_dtl.placed
        --
      from table(qu3_act_dtl_pos_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.placed)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.pos_view_at_date] : '||SQLERRM, 1, 4000));

  end pos_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [off_loc], as at Date
  function off_loc_view_at_date(p_at_date in date) return qu3_off_loc_type pipelined is

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
        act_dtl.no_gondola,
        act_dtl.no_wing,
        act_dtl.no_flat_pack_tower,
        act_dtl.no_pre_pack_tower,
        act_dtl.no_flat_pack_cdus,
        act_dtl.no_pre_pack_cdus,
        act_dtl.no_buckets,
        act_dtl.no_clip_strip,
        act_dtl.no_other,
        act_dtl.stock_qty,
        act_dtl.promo_start_date,
        act_dtl.promo_end_date,
        act_dtl.coop_spend,
        act_dtl.sold_in_by,
        act_dtl.built_by
        --
      from table(qu3_act_dtl_off_loc_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_gondola)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_wing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_flat_pack_tower)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_pre_pack_tower)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_flat_pack_cdus)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_pre_pack_cdus)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_buckets)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_clip_strip)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_other)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.stock_qty)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.promo_start_date)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.promo_end_date)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.coop_spend)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.sold_in_by)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.built_by)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.off_loc_view_at_date] : '||SQLERRM, 1, 4000));

  end off_loc_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [hwaudit_gr], as at Date
  function hwaudit_gr_view_at_date(p_at_date in date) return qu3_hwaudit_gr_type pipelined is

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
        act_dtl.no_std_chkout
        --
      from table(qu3_act_dtl_hwaudit_gr_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_std_chkout)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.hwaudit_gr_view_at_date] : '||SQLERRM, 1, 4000));

  end hwaudit_gr_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [hwaudit_ro], as at Date
  function hwaudit_ro_view_at_date(p_at_date in date) return qu3_hwaudit_ro_type pipelined is

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
        act_dtl.no_hotspot,
        act_dtl.no_non_hotspot
        --
      from table(qu3_act_dtl_hwaudit_ro_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_hotspot)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_non_hotspot)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.hwaudit_ro_view_at_date] : '||SQLERRM, 1, 4000));

  end hwaudit_ro_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [storeop_gr], as at Date
  function storeop_gr_view_at_date(p_at_date in date) return qu3_storeop_gr_type pipelined is

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
        act_dtl.no_std_chkout_reg,
        act_dtl.no_std_chkout_os,
        act_dtl.no_std_chkout_fe,
        act_dtl.no_confec_free_chkout,
        act_dtl.no_confec_free_chkout_top_,
        act_dtl.no_express_chkout,
        act_dtl.no_express_q,
        act_dtl.no_selfscan_chkout,
        act_dtl.no_selfscan_q,
        act_dtl.no_confec_bay_
        --
      from table(qu3_act_dtl_storeop_gr_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_std_chkout_reg)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_std_chkout_os)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_std_chkout_fe)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_free_chkout)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_free_chkout_top_)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_express_chkout)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_express_q)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_selfscan_chkout)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_selfscan_q)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_confec_bay_)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.storeop_gr_view_at_date] : '||SQLERRM, 1, 4000));

  end storeop_gr_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [storeop_ro], as at Date
  function storeop_ro_view_at_date(p_at_date in date) return qu3_storeop_ro_type pipelined is

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
        act_dtl.no_register,
        act_dtl.no_chiller_door,
        act_dtl.no_parallel_store,
        act_dtl.no_paralle_wwy_stand,
        act_dtl.no_comp_wwy_stand,
        act_dtl.no_oos_wwy_stand,
        act_dtl.no_pack_date_issue,
        act_dtl.pref_wholesaler
        --
      from table(qu3_act_dtl_storeop_ro_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_register)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_chiller_door)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_parallel_store)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_paralle_wwy_stand)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_comp_wwy_stand)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_oos_wwy_stand)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_pack_date_issue)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.pref_wholesaler)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.storeop_ro_view_at_date] : '||SQLERRM, 1, 4000));

  end storeop_ro_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [top_sku], as at Date
  function top_sku_view_at_date(p_at_date in date) return qu3_top_sku_type pipelined is

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
        act_dtl.no_std_chk_belt,
        act_dtl.no_std_chk_front,
        act_dtl.no_exp_chk_pop,
        act_dtl.no_ss_chk_pop,
        act_dtl.no_q_zone,
        act_dtl.no_std_chk_non_belt,
        act_dtl.no_aisle
        --
      from table(qu3_act_dtl_top_sku_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_std_chk_belt)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_std_chk_front)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_exp_chk_pop)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_ss_chk_pop)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_q_zone)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_std_chk_non_belt)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_aisle)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.top_sku_view_at_date] : '||SQLERRM, 1, 4000));

  end top_sku_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [pcking_chg], as at Date
  function pcking_chg_view_at_date(p_at_date in date) return qu3_pcking_chg_type pipelined is

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
        act_dtl.percent_stock_in_new_pack
        --
      from table(qu3_act_dtl_pcking_chg_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu3_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu3_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu3_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.percent_stock_in_new_pack)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.pcking_chg_view_at_date] : '||SQLERRM, 1, 4000));

  end pcking_chg_view_at_date;


end qu3_act_dtl_pkg;
/

-- Synonyms
create or replace public synonym qu3_act_dtl_pkg for dds_app.qu3_act_dtl_pkg;

-- Grants
grant execute on dds_app.qu3_act_dtl_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
