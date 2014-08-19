
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu4_act_dtl_pkg as
  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu4
    Owner    : dds_app
    Package  : qu4_act_dtl_pkg
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Container Package to Provide Custom (Persisted) Views for Activities

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-08-13  Mal Chambeyron        Original Template
    2013-09-24  Tom Docherty          Added [view_at_shrt] .. limiting return set to
                                      necessary columns.
    2013-11-14  Tom Docherty          Modify persistent logic to return latest values
                                      per customer, not per product per customer. Quofore
                                      interface sends all latest recirds, not product delta's,
                                      and removing [act_dtl_id] from return type.
                                      Added Cust To Terr short Function and type
    2014-05-18  Mal Chambeyron        Cleanup source_id
    2014-05-18  Mal Chambeyron        Make into a Template
    2014-05-26  Mal Chambeyron        Updated [view_at_date] to handle [act_dtl] without [prod_id]
    2014-05-27  Mal Chambeyron        Updated [view_at_date] to select latest actvity by cust / task
    2014-05-27  Mal Chambeyron        Updated [view_at_date] to limit task where to it is effective during period
    2014-06-03  Mal Chambeyron        Updated [view_at_date], remove [terr_id] and [rep_id],
                                      as can be misleading regards time phasing
    2014-07-08  Tom Docherty          Updated [cust_terr_pos_rep] to Left join Pos and Rep, rather than Inner Join
    2014-07-14  Mal Chambeyron        Remove [view_at_shrt] functions, as no longer used.                                      
    2014-07-14  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  ------------------------------------------------------------------------------
  -- Public : Type : Customer > Terrirory > Position > Rep
  type qu4_cust_to_rep_rec is record (
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

  type qu4_cust_to_rep_type is table of qu4_cust_to_rep_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : Latest Customer / Task / call_card / Activity by Activity Start Date
  type qu4_cust_task_rec is record (
    cust_id number(10,0),
    task_id number(10,0),
    start_date date,
    act_id number(10,0),
    call_card_id number(10,0),
    terr_id number(10,0),
    rep_id number(10,0)
  );

  type qu4_cust_task_type is table of qu4_cust_task_rec;

  ------------------------------------------------------------------------------
  -- Public : Type : [dist]
  type qu4_dist_rec is record (
    report_date date,
    --
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    prod_id number(10,0),
    --
    no_of_facings number(10, 0),
    is_in_distribution number(1, 0)
  );

  type qu4_dist_type is table of qu4_dist_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [permanency]
  type qu4_permanency_rec is record (
    report_date date,
    --
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    prod_id number(10,0),
    --
    hier_node_id number(10, 0),
    permanency_qty number(10, 0)
  );

  type qu4_permanency_type is table of qu4_permanency_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [disply_std]
  type qu4_disply_std_rec is record (
    report_date date,
    --
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    prod_id number(10,0),
    --
    hier_node_id number(10, 0),
    display_trade_is_to_standard number(10, 0),
    display_trade_no_of_displays number(10, 0),
    display_trade_display_type number(10, 0)
  );

  type qu4_disply_std_type is table of qu4_disply_std_rec;
  ------------------------------------------------------------------------------
  -- Public : Type : [planogram]
  type qu4_planogram_rec is record (
    report_date date,
    --
    act_id number(10,0),
    task_id number(10,0),
    cust_id number(10,0),
    --
    hier_node_id number(10, 0),
    shelf_aisle_compliant_1 number(10, 0)
  );

  type qu4_planogram_type is table of qu4_planogram_rec;


  ------------------------------------------------------------------------------
  -- Public : Functions
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu4_cust_to_rep_type pipelined;
  function cust_task_view_at_date(p_at_date in date) return qu4_cust_task_type pipelined;
  function cust_eff_task_view_at_date(p_at_date in date) return qu4_cust_task_type pipelined;

  function dist_view_at_date(p_at_date in date) return qu4_dist_type pipelined;
  function permanency_view_at_date(p_at_date in date) return qu4_permanency_type pipelined;
  function disply_std_view_at_date(p_at_date in date) return qu4_disply_std_type pipelined;
  function planogram_view_at_date(p_at_date in date) return qu4_planogram_type pipelined;

end qu4_act_dtl_pkg;
/

create or replace package body dds_app.qu4_act_dtl_pkg as

  ------------------------------------------------------------------------------
  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  ------------------------------------------------------------------------------
  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu4_act_dtl_pkg';

  ------------------------------------------------------------------------------
  -- Function : Customer > Terrirory > Position > Rep, as at Date
  function cust_terr_pos_rep_view_at_date(p_at_date in date) return qu4_cust_to_rep_type pipelined is

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
      from table(qu4_cust_pkg.view_at_date(p_at_date)) cust,
        table(qu4_cust_terr_pkg.view_at_date(p_at_date)) cust_terr,
        table(qu4_terr_pkg.view_at_date(p_at_date)) terr,
        table(qu4_pos_terr_pkg.view_at_date(p_at_date)) pos_terr,
        table(qu4_pos_pkg.view_at_date(p_at_date)) pos,
        table(qu4_rep_pkg.view_at_date(p_at_date)) rep
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
  -- Function : Latest Customer Task, as at Date
  function cust_task_view_at_date(p_at_date in date) return qu4_cust_task_type pipelined is

    prev_cust_id number(10,0);
    prev_task_id number(10,0);

  begin

    -- set to impossible values to save null check
    prev_cust_id := -1;
    prev_task_id := -1;

    for l_entity in (

      select call_card.cust_id,
        act_hdr.task_id,
        act_hdr.start_date,
        act_hdr.id act_id,
        act_hdr.call_card_id,
        call_card.terr_id,
        call_card.rep_id -- act_hdr.rep_id
      from table(qu4_act_hdr_pkg.view_at_date(p_at_date)) act_hdr,
        table(qu4_call_card_pkg.view_at_date(p_at_date)) call_card
      where act_hdr.start_date <= p_at_date
      and act_hdr.call_card_id = call_card.id
      order by call_card.cust_id,
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
  function cust_eff_task_view_at_date(p_at_date in date) return qu4_cust_task_type pipelined is

  begin

    for l_entity in (

      select cust_task.cust_id,
        cust_task.task_id,
        cust_task.start_date,
        cust_task.act_id,
        cust_task.call_card_id,
        cust_task.terr_id,
        cust_task.rep_id
      from table(qu4_act_dtl_pkg.cust_task_view_at_date(p_at_date)) cust_task
      where cust_task.task_id in (
        select task.id task_id
        from table(qu4_task_pkg.view_at_date(p_at_date)) task,
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
  -- Function : [dist], as at Date
  function dist_view_at_date(p_at_date in date) return qu4_dist_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        act_dtl.prod_id,
        --
        act_dtl.no_of_facings,
        act_dtl.is_in_distribution
        --
      from table(qu4_act_dtl_dist_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu4_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task
      where act_dtl.act_id = cust_task.act_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.dist_view_at_date] : '||SQLERRM, 1, 4000));

  end dist_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [permanency], as at Date
  function permanency_view_at_date(p_at_date in date) return qu4_permanency_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        act_dtl.prod_id,
        --
        act_dtl.hier_node_id,
        act_dtl.permanency_qty
        --
      from table(qu4_act_dtl_permanency_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu4_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task
      where act_dtl.act_id = cust_task.act_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.permanency_view_at_date] : '||SQLERRM, 1, 4000));

  end permanency_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [disply_std], as at Date
  function disply_std_view_at_date(p_at_date in date) return qu4_disply_std_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        act_dtl.prod_id,
        --
        act_dtl.hier_node_id,
        act_dtl.display_trade_is_to_standard,
        act_dtl.display_trade_no_of_displays,
        act_dtl.display_trade_display_type
        --
      from table(qu4_act_dtl_disply_std_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu4_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task
      where act_dtl.act_id = cust_task.act_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.disply_std_view_at_date] : '||SQLERRM, 1, 4000));

  end disply_std_view_at_date;
  ------------------------------------------------------------------------------
  -- Function : [planogram], as at Date
  function planogram_view_at_date(p_at_date in date) return qu4_planogram_type pipelined is

  begin

    for l_entity in (

      select p_at_date report_date,
        --
        act_dtl.act_id,
        cust_task.task_id,
        cust_task.cust_id,
        --
        act_dtl.hier_node_id,
        act_dtl.shelf_aisle_compliant_1
        --
      from table(qu4_act_dtl_planogram_pkg.view_at_date(p_at_date)) act_dtl,
        table(qu4_act_dtl_pkg.cust_eff_task_view_at_date(p_at_date)) cust_task
      where act_dtl.act_id = cust_task.act_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.planogram_view_at_date] : '||SQLERRM, 1, 4000));

  end planogram_view_at_date;


end qu4_act_dtl_pkg;
/

-- Synonyms
create or replace public synonym qu4_act_dtl_pkg for dds_app.qu4_act_dtl_pkg;

-- Grants
grant execute on dds_app.qu4_act_dtl_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
