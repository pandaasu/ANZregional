
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu2_act_dtl_pkg as
  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu2
    Owner    : dds_app
    Package  : qu2_act_dtl_pkg
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
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
  type qu2_cust_to_rep_rec is record (
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

  type qu2_cust_to_rep_type is table of qu2_cust_to_rep_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : Latest Customer / Task / callcard / Activity by Activity Start Date
  type qu2_cust_task_rec is record (
    cust_id number(10,0),
    task_id number(10,0),
    start_date date,
    act_id number(10,0),
    callcard_id number(10,0),
    -- terr_id number(10,0), -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
    rep_id number(10,0)
  );

  type qu2_cust_task_type is table of qu2_cust_task_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : [a_loc]
  type qu2_a_loc_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_total number(10, 0),
    no_a_loc number(10, 0),
    secondary_loc number(10, 0),
    other_loc number(10, 0),
    no_ts number(10, 0)
  );

  type qu2_a_loc_type is table of qu2_a_loc_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [sell_in]
  type qu2_sell_in_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_deals_sold number(10, 0)
  );

  type qu2_sell_in_type is table of qu2_sell_in_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [off_loc]
  type qu2_off_loc_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    promotion_week number(10, 0),
    no_gondola number(10, 0),
    no_wing number(10, 0),
    no_bin number(10, 0),
    no_clip_strip number(10, 0),
    stock_qty number(10, 0),
    promotional_type number(10, 0),
    brand number(10, 0),
    promotional_impact number(10, 0),
    no_pre_pack_units number(10, 0),
    tm_influence number(10, 0)
  );

  type qu2_off_loc_type is table of qu2_off_loc_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [facing]
  type qu2_facing_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    facings number(10, 0),
    is_available number(1, 0)
  );

  type qu2_facing_type is table of qu2_facing_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [checkout]
  type qu2_checkout_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    chkout_no number(10, 0),
    no_sku_belt_side number(10, 0),
    no_sku_front_side number(10, 0),
    no_sku_adjacent number(10, 0),
    is_active number(1, 0)
  );

  type qu2_checkout_type is table of qu2_checkout_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [express_q]
  type qu2_express_q_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    zone_no number(10, 0),
    no_sku number(10, 0),
    no_sku_adjacent number(10, 0),
    is_active number(1, 0)
  );

  type qu2_express_q_type is table of qu2_express_q_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [express]
  type qu2_express_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    express_q_no number(10, 0),
    chkout_no number(10, 0),
    no_sku number(10, 0),
    is_active number(1, 0)
  );

  type qu2_express_type is table of qu2_express_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [selfscan_q]
  type qu2_selfscan_q_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    zone_no number(10, 0),
    no_sku number(10, 0),
    no_sku_adjacent number(10, 0),
    is_active number(1, 0)
  );

  type qu2_selfscan_q_type is table of qu2_selfscan_q_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [selfscan]
  type qu2_selfscan_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    selfscan_q_no number(10, 0),
    chkout_no number(10, 0),
    no_sku number(10, 0),
    is_active number(1, 0)
  );

  type qu2_selfscan_type is table of qu2_selfscan_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [loc_oos]
  type qu2_loc_oos_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_loc_front number(10, 0),
    no_loc_front_oos number(10, 0),
    no_facing_front_oos number(10, 0),
    no_loc_aisle number(10, 0),
    no_loc_aisle_oos number(10, 0),
    no_facing_aisle_oos number(10, 0)
  );

  type qu2_loc_oos_type is table of qu2_loc_oos_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [perm_disp]
  type qu2_perm_disp_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    no_std_chkout number(10, 0),
    no_express_chkout number(10, 0),
    no_selfscan_chkout number(10, 0),
    no_other number(10, 0)
  );

  type qu2_perm_disp_type is table of qu2_perm_disp_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [face_aisle]
  type qu2_face_aisle_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    facings_aisle number(10, 0),
    is_available_aisle number(1, 0)
  );

  type qu2_face_aisle_type is table of qu2_face_aisle_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [face_expre]
  type qu2_face_expre_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    facings_express number(10, 0),
    is_available_express number(1, 0)
  );

  type qu2_face_expre_type is table of qu2_face_expre_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [face_selfs]
  type qu2_face_selfs_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    facings_selfscan number(10, 0),
    is_available_selfscan number(1, 0)
  );

  type qu2_face_selfs_type is table of qu2_face_selfs_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [face_stand]
  type qu2_face_stand_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    facings_std number(10, 0),
    is_available_std number(1, 0)
  );

  type qu2_face_stand_type is table of qu2_face_stand_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [comp_act]
  type qu2_comp_act_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    wwy_comp number(10, 0),
    wwy_comp_call_cycle number(10, 0),
    wwy_comp_focus number(10, 0),
    wwy_offer_to_retailer number(10, 0),
    wwy_comp_act_app_by number(10, 0),
    wwy_impact_hardware number(10, 0),
    wwy_impact_facings number(10, 0),
    wwy_result_exit number(10, 0),
    wwy_value_reward varchar2(4000 char),
    wwy_result_exit_app_by number(10, 0)
  );

  type qu2_comp_act_type is table of qu2_comp_act_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [comp_face]
  type qu2_comp_face_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    prod_id number(10,0),
    -- persisted attributes
    facings_store number(10, 0)
  );

  type qu2_comp_face_type is table of qu2_comp_face_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [exec_compl]
  type qu2_exec_compl_rec is record (
    report_date date,
    -- activity detail key
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    -- product / hierarchy key
    hier_node_id number(10,0),
    -- persisted attributes
    act_name number(10, 0),
    objective number(10, 0),
    hardware_on_entry number(10, 0),
    pos_on_entry number(10, 0),
    planogram_on_entry number(10, 0),
    allocation_on_entry number(10, 0),
    promotion_compliance_on_entry number(10, 0),
    over_all_compliance_on_entry number(10, 0),
    commentary_on_entry number(10, 0),
    hardware_on_exit number(10, 0),
    pos_on_exit number(10, 0),
    planogram_on_exit number(10, 0),
    allocation_on_exit number(10, 0),
    promotion_compliance_exit number(10, 0),
    over_all_compliance_exit number(10, 0),
    commentary_on_exit number(10, 0),
    action_plan number(10, 0)
  );

  type qu2_exec_compl_type is table of qu2_exec_compl_rec;


  ------------------------------------------------------------------------------
  -- Public : Functions
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu2_cust_to_rep_type pipelined;
  function cust_task_view_at_date(p_at_date in date) return qu2_cust_task_type pipelined;
  function cust_eff_task_view_at_date(p_at_date in date) return qu2_cust_task_type pipelined;

  function a_loc_view_at_date(p_at_date in date) return qu2_a_loc_type pipelined;
  function sell_in_view_at_date(p_at_date in date) return qu2_sell_in_type pipelined;
  function off_loc_view_at_date(p_at_date in date) return qu2_off_loc_type pipelined;
  function facing_view_at_date(p_at_date in date) return qu2_facing_type pipelined;
  function checkout_view_at_date(p_at_date in date) return qu2_checkout_type pipelined;
  function express_q_view_at_date(p_at_date in date) return qu2_express_q_type pipelined;
  function express_view_at_date(p_at_date in date) return qu2_express_type pipelined;
  function selfscan_q_view_at_date(p_at_date in date) return qu2_selfscan_q_type pipelined;
  function selfscan_view_at_date(p_at_date in date) return qu2_selfscan_type pipelined;
  function loc_oos_view_at_date(p_at_date in date) return qu2_loc_oos_type pipelined;
  function perm_disp_view_at_date(p_at_date in date) return qu2_perm_disp_type pipelined;
  function face_aisle_view_at_date(p_at_date in date) return qu2_face_aisle_type pipelined;
  function face_expre_view_at_date(p_at_date in date) return qu2_face_expre_type pipelined;
  function face_selfs_view_at_date(p_at_date in date) return qu2_face_selfs_type pipelined;
  function face_stand_view_at_date(p_at_date in date) return qu2_face_stand_type pipelined;
  function comp_act_view_at_date(p_at_date in date) return qu2_comp_act_type pipelined;
  function comp_face_view_at_date(p_at_date in date) return qu2_comp_face_type pipelined;
  function exec_compl_view_at_date(p_at_date in date) return qu2_exec_compl_type pipelined;

end qu2_act_dtl_pkg;
/

create or replace package body dds_app.qu2_act_dtl_pkg as

  ------------------------------------------------------------------------------
  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  ------------------------------------------------------------------------------
  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu2_act_dtl_pkg';

  ------------------------------------------------------------------------------
  -- Function : Customer > Terrirory > Position > Rep, as at Date
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu2_cust_to_rep_type pipelined is

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
      from table(qu2_cust_pkg.view_at_date(p_at_date)) cust,
        table(qu2_cust_terr_pkg.view_at_date(p_at_date)) cust_terr,
        table(qu2_terr_pkg.view_at_date(p_at_date)) terr,
        table(qu2_pos_terr_pkg.view_at_date(p_at_date)) pos_terr,
        table(qu2_pos_pkg.view_at_date(p_at_date)) pos,
        table(qu2_rep_pkg.view_at_date(p_at_date)) rep
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
  function cust_task_view_at_date(p_at_date in date) return qu2_cust_task_type pipelined is

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
      from table(qu2_act_hdr_pkg.view_at_date(p_at_date)) act_hdr,
        table(qu2_callcard_pkg.view_at_date(p_at_date)) callcard,
        table(qu2_cust_pkg.view_at_date(p_at_date)) cust
      where act_hdr.start_date <= p_at_date
        and act_hdr.callcard_id = callcard.id
        and callcard.cust_id = cust.id
        -- limit to active customers
        and cust.is_active = 1
        -- limit to activities that have activity details
        and act_hdr.id in (
          select act_id from table(qu2_act_dtl_a_loc_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_sell_in_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_off_loc_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_facing_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_checkout_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_express_q_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_express_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_selfscan_q_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_selfscan_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_loc_oos_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_perm_disp_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_face_aisle_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_face_expre_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_face_selfs_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_face_stand_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_comp_act_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_comp_face_pkg.view_at_date(p_at_date))
          union
          select act_id from table(qu2_act_dtl_exec_compl_pkg.view_at_date(p_at_date))
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
  function cust_eff_task_view_at_date(p_at_date in date) return qu2_cust_task_type pipelined is

  begin

    for l_entity in (

      select cust_task.cust_id,
        cust_task.task_id,
        cust_task.start_date,
        cust_task.act_id,
        cust_task.callcard_id,
        -- cust_task.terr_id, -- terr_id included in callcard since [4] chocolate au, however not reliable DO NOT USE !!!
        cust_task.rep_id
      from table(qu2_act_dtl_pkg.cust_task_view_at_date(p_at_date)) cust_task
      where cust_task.task_id in (
        select task.id task_id
        from table(qu2_task_pkg.view_at_date(p_at_date)) task,
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
  -- Function : [a_loc], as at Date
  function a_loc_view_at_date(p_at_date in date) return qu2_a_loc_type pipelined is

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
        act_dtl.no_total,
        act_dtl.no_a_loc,
        act_dtl.secondary_loc,
        act_dtl.other_loc,
        act_dtl.no_ts
        --
      from table(qu2_act_dtl_a_loc_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_total)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_a_loc)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.secondary_loc)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.other_loc)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_ts)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.a_loc_view_at_date] : '||SQLERRM, 1, 4000));

  end a_loc_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [sell_in], as at Date
  function sell_in_view_at_date(p_at_date in date) return qu2_sell_in_type pipelined is

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
        act_dtl.no_deals_sold
        --
      from table(qu2_act_dtl_sell_in_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_deals_sold)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.sell_in_view_at_date] : '||SQLERRM, 1, 4000));

  end sell_in_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [off_loc], as at Date
  function off_loc_view_at_date(p_at_date in date) return qu2_off_loc_type pipelined is

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
        act_dtl.promotion_week,
        act_dtl.no_gondola,
        act_dtl.no_wing,
        act_dtl.no_bin,
        act_dtl.no_clip_strip,
        act_dtl.stock_qty,
        act_dtl.promotional_type,
        act_dtl.brand,
        act_dtl.promotional_impact,
        act_dtl.no_pre_pack_units,
        act_dtl.tm_influence
        --
      from table(qu2_act_dtl_off_loc_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.promotion_week)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_gondola)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_wing)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_bin)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_clip_strip)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.stock_qty)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.promotional_type)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.brand)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.promotional_impact)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_pre_pack_units)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.tm_influence)), null, 0, 1) > 0
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
  -- Function : [facing], as at Date
  function facing_view_at_date(p_at_date in date) return qu2_facing_type pipelined is

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
        act_dtl.facings,
        act_dtl.is_available
        --
      from table(qu2_act_dtl_facing_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.facings)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_available)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.facing_view_at_date] : '||SQLERRM, 1, 4000));

  end facing_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [checkout], as at Date
  function checkout_view_at_date(p_at_date in date) return qu2_checkout_type pipelined is

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
        act_dtl.chkout_no,
        act_dtl.no_sku_belt_side,
        act_dtl.no_sku_front_side,
        act_dtl.no_sku_adjacent,
        act_dtl.is_active
        --
      from table(qu2_act_dtl_checkout_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.chkout_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku_belt_side)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku_front_side)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku_adjacent)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_active)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.checkout_view_at_date] : '||SQLERRM, 1, 4000));

  end checkout_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [express_q], as at Date
  function express_q_view_at_date(p_at_date in date) return qu2_express_q_type pipelined is

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
        act_dtl.zone_no,
        act_dtl.no_sku,
        act_dtl.no_sku_adjacent,
        act_dtl.is_active
        --
      from table(qu2_act_dtl_express_q_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.zone_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku_adjacent)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_active)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.express_q_view_at_date] : '||SQLERRM, 1, 4000));

  end express_q_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [express], as at Date
  function express_view_at_date(p_at_date in date) return qu2_express_type pipelined is

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
        act_dtl.express_q_no,
        act_dtl.chkout_no,
        act_dtl.no_sku,
        act_dtl.is_active
        --
      from table(qu2_act_dtl_express_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.express_q_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.chkout_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_active)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.express_view_at_date] : '||SQLERRM, 1, 4000));

  end express_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [selfscan_q], as at Date
  function selfscan_q_view_at_date(p_at_date in date) return qu2_selfscan_q_type pipelined is

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
        act_dtl.zone_no,
        act_dtl.no_sku,
        act_dtl.no_sku_adjacent,
        act_dtl.is_active
        --
      from table(qu2_act_dtl_selfscan_q_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.zone_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku_adjacent)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_active)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.selfscan_q_view_at_date] : '||SQLERRM, 1, 4000));

  end selfscan_q_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [selfscan], as at Date
  function selfscan_view_at_date(p_at_date in date) return qu2_selfscan_type pipelined is

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
        act_dtl.selfscan_q_no,
        act_dtl.chkout_no,
        act_dtl.no_sku,
        act_dtl.is_active
        --
      from table(qu2_act_dtl_selfscan_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.selfscan_q_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.chkout_no)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_sku)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_active)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.selfscan_view_at_date] : '||SQLERRM, 1, 4000));

  end selfscan_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [loc_oos], as at Date
  function loc_oos_view_at_date(p_at_date in date) return qu2_loc_oos_type pipelined is

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
        act_dtl.no_loc_front,
        act_dtl.no_loc_front_oos,
        act_dtl.no_facing_front_oos,
        act_dtl.no_loc_aisle,
        act_dtl.no_loc_aisle_oos,
        act_dtl.no_facing_aisle_oos
        --
      from table(qu2_act_dtl_loc_oos_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.no_loc_front)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_loc_front_oos)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_facing_front_oos)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_loc_aisle)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_loc_aisle_oos)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_facing_aisle_oos)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.loc_oos_view_at_date] : '||SQLERRM, 1, 4000));

  end loc_oos_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [perm_disp], as at Date
  function perm_disp_view_at_date(p_at_date in date) return qu2_perm_disp_type pipelined is

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
        act_dtl.no_std_chkout,
        act_dtl.no_express_chkout,
        act_dtl.no_selfscan_chkout,
        act_dtl.no_other
        --
      from table(qu2_act_dtl_perm_disp_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        or decode(trim(to_char(act_dtl.no_express_chkout)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_selfscan_chkout)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.no_other)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.perm_disp_view_at_date] : '||SQLERRM, 1, 4000));

  end perm_disp_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [face_aisle], as at Date
  function face_aisle_view_at_date(p_at_date in date) return qu2_face_aisle_type pipelined is

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
        act_dtl.facings_aisle,
        act_dtl.is_available_aisle
        --
      from table(qu2_act_dtl_face_aisle_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.facings_aisle)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_available_aisle)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.face_aisle_view_at_date] : '||SQLERRM, 1, 4000));

  end face_aisle_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [face_expre], as at Date
  function face_expre_view_at_date(p_at_date in date) return qu2_face_expre_type pipelined is

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
        act_dtl.facings_express,
        act_dtl.is_available_express
        --
      from table(qu2_act_dtl_face_expre_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.facings_express)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_available_express)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.face_expre_view_at_date] : '||SQLERRM, 1, 4000));

  end face_expre_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [face_selfs], as at Date
  function face_selfs_view_at_date(p_at_date in date) return qu2_face_selfs_type pipelined is

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
        act_dtl.facings_selfscan,
        act_dtl.is_available_selfscan
        --
      from table(qu2_act_dtl_face_selfs_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.facings_selfscan)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_available_selfscan)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.face_selfs_view_at_date] : '||SQLERRM, 1, 4000));

  end face_selfs_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [face_stand], as at Date
  function face_stand_view_at_date(p_at_date in date) return qu2_face_stand_type pipelined is

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
        act_dtl.facings_std,
        act_dtl.is_available_std
        --
      from table(qu2_act_dtl_face_stand_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.facings_std)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.is_available_std)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.face_stand_view_at_date] : '||SQLERRM, 1, 4000));

  end face_stand_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [comp_act], as at Date
  function comp_act_view_at_date(p_at_date in date) return qu2_comp_act_type pipelined is

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
        act_dtl.wwy_comp,
        act_dtl.wwy_comp_call_cycle,
        act_dtl.wwy_comp_focus,
        act_dtl.wwy_offer_to_retailer,
        act_dtl.wwy_comp_act_app_by,
        act_dtl.wwy_impact_hardware,
        act_dtl.wwy_impact_facings,
        act_dtl.wwy_result_exit,
        act_dtl.wwy_value_reward,
        act_dtl.wwy_result_exit_app_by
        --
      from table(qu2_act_dtl_comp_act_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_hier_pkg.view_at_date(p_at_date)) hier
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
        decode(trim(to_char(act_dtl.wwy_comp)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_comp_call_cycle)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_comp_focus)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_offer_to_retailer)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_comp_act_app_by)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_impact_hardware)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_impact_facings)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_result_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_value_reward)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.wwy_result_exit_app_by)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.comp_act_view_at_date] : '||SQLERRM, 1, 4000));

  end comp_act_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [comp_face], as at Date
  function comp_face_view_at_date(p_at_date in date) return qu2_comp_face_type pipelined is

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
        act_dtl.facings_store
        --
      from table(qu2_act_dtl_comp_face_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_prod_pkg.view_at_date(p_at_date)) prod
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
        decode(trim(to_char(act_dtl.facings_store)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.comp_face_view_at_date] : '||SQLERRM, 1, 4000));

  end comp_face_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [exec_compl], as at Date
  function exec_compl_view_at_date(p_at_date in date) return qu2_exec_compl_type pipelined is

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
        act_dtl.act_name,
        act_dtl.objective,
        act_dtl.hardware_on_entry,
        act_dtl.pos_on_entry,
        act_dtl.planogram_on_entry,
        act_dtl.allocation_on_entry,
        act_dtl.promotion_compliance_on_entry,
        act_dtl.over_all_compliance_on_entry,
        act_dtl.commentary_on_entry,
        act_dtl.hardware_on_exit,
        act_dtl.pos_on_exit,
        act_dtl.planogram_on_exit,
        act_dtl.allocation_on_exit,
        act_dtl.promotion_compliance_exit,
        act_dtl.over_all_compliance_exit,
        act_dtl.commentary_on_exit,
        act_dtl.action_plan
        --
      from table(qu2_act_dtl_exec_compl_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu2_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task,
        -- table(qu2_cust_pkg.view_at_date(p_at_date)) cust -- *** removed as already filtered in [cust_eff_task_view_at_date],
        table(qu2_hier_pkg.view_at_date(p_at_date)) hier
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
        decode(trim(to_char(act_dtl.act_name)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.objective)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.hardware_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.pos_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.planogram_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.allocation_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.promotion_compliance_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.over_all_compliance_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.commentary_on_entry)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.hardware_on_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.pos_on_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.planogram_on_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.allocation_on_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.promotion_compliance_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.over_all_compliance_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.commentary_on_exit)), null, 0, 1) > 0
        or decode(trim(to_char(act_dtl.action_plan)), null, 0, 1) > 0
      )

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.exec_compl_view_at_date] : '||SQLERRM, 1, 4000));

  end exec_compl_view_at_date;


end qu2_act_dtl_pkg;
/

-- Synonyms
create or replace public synonym qu2_act_dtl_pkg for dds_app.qu2_act_dtl_pkg;

-- Grants
grant execute on dds_app.qu2_act_dtl_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
