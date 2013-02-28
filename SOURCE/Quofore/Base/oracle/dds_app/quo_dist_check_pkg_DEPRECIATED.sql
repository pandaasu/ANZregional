
set define off;

-- Create Entity Access Package
create or replace
package         quo_dist_check_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : quo
  Owner   : dds_app
  Package : quo_dist_check_pkg
  Author  : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  Quofore Loader Package - Table [quo_act_dtl_dist_check] Entity [ActivityDetailDistCheck] Interface [quocdw34]

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2012-11-28  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

  -- Public : Type

  type quo_dist_check_rec is record (
    cust_id	number(10,0),
    prod_id	number(10,0),
    report_date	date,
    dist_date	date,
    is_ranged	number(1,0),
    is_tag_missing	number(1,0),
    dist_id	number(10,0),
    act_id	number(10,0),
    terr_id	number(10,0),
    pos_id	number(10,0),
    rep_id	number(10,0)
  );

  type quo_dist_check_type is table of quo_dist_check_rec;

  -- Public : Functions
  function view_at_date(p_source_id in number, p_at_date in date) return quo_dist_check_type pipelined;
--  function view_current(p_source_id in number) return quo_dist_check_type pipelined;
--  function view_at_yyyyppw(p_source_id in number, p_yyyyppw in number) return quo_dist_check_type pipelined;
--  function view_history(p_source_id in number) return quo_dist_check_type pipelined;
--  function view_structure return quo_dist_check_type pipelined;

end quo_dist_check_pkg;
/

create or replace
package body         quo_dist_check_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'quo_dist_check_pkg';

  /*****************************************************************************
  ** Function : Return Entity : As at Date
  *****************************************************************************/
  function view_at_date(p_source_id in number, p_at_date date) return quo_dist_check_type pipelined is

  begin

    for l_entity in (

      select
        latest_dist.cust_id,
        dist.prod_id,
        p_at_date report_date,
        activity.start_date dist_date,
        dist.is_ranged,
        dist.is_tag_missing,
        dist.id dist_id,
        dist.act_id,
        cust_terr.terr_id,
        terr_pos.pos_id,
        pos_rep.rep_id
      from quo_act_dtl_dist_check dist,
      --------------------------------------------------------------------------
        (
          select dist.q4x_source_id,
            callcard.cust_id,
            dist.prod_id,
            max(dist.id) dist_id
          from quo_act_dtl_dist_check dist,
            quo_act_hdr activity,
            quo_callcard callcard
          -- activity date
          where dist.q4x_source_id = p_source_id
          and activity.start_date <= p_at_date
          -- dist > activity
          and dist.q4x_source_id = activity.q4x_source_id
          and dist.act_id = activity.id
          -- activity > callcard
          and dist.q4x_source_id = callcard.q4x_source_id
          and activity.callcard_id = callcard.id
          --
          group by dist.q4x_source_id,
            callcard.cust_id,
            dist.prod_id
        ) latest_dist,
      --------------------------------------------------------------------------
        quo_act_hdr activity,
      --------------------------------------------------------------------------
        quo_callcard callcard,
      --------------------------------------------------------------------------
        (
          select cust_terr.q4x_source_id,
            cust_terr.cust_id,
            cust_terr.terr_id,
            cust_terr.id custs_terr_id
          from quo_cust_terr_hist cust_terr,
            (
              select q4x_source_id,
                cust_id,
                max(id) cust_terr_id
              from quo_cust_terr_hist
              where q4x_source_id = p_source_id
              and q4x_timestamp <= p_at_date
              and is_active = 1
              group by q4x_source_id,
                cust_id
            ) curr_cust_terr
          where cust_terr.q4x_source_id = p_source_id
          and cust_terr.q4x_source_id = curr_cust_terr.q4x_source_id
          and cust_terr.id = curr_cust_terr.cust_terr_id
        ) cust_terr,
      --------------------------------------------------------------------------
        (
          select pos_terr.q4x_source_id,
            pos_terr.terr_id,
            max(pos_terr.pos_id) pos_id
          from quo_pos_terr_hist pos_terr,
            (
              select q4x_source_id,
                terr_id,
                max(id) pos_terr_id
              from quo_pos_terr_hist
              where q4x_source_id = p_source_id
              and q4x_timestamp <= p_at_date
              and is_active = 1
              and is_primary_terr = 1
              group by q4x_source_id,
                terr_id
            ) curr_pos_terr
          where pos_terr.q4x_source_id = p_source_id
          and pos_terr.q4x_source_id = curr_pos_terr.q4x_source_id
          and pos_terr.id = curr_pos_terr.pos_terr_id
          group by pos_terr.q4x_source_id,
            pos_terr.terr_id
        ) terr_pos,
      --------------------------------------------------------------------------
        (
          select rep.q4x_source_id,
            rep.id rep_id,
            rep.pos_id
          from quo_rep_hist rep,
            (
              select q4x_source_id,
                pos_id,
                max(q4x_batch_id) q4x_batch_id
              from quo_rep_hist
              where q4x_source_id = p_source_id
              and q4x_timestamp <= p_at_date
              and is_active = 1
              group by q4x_source_id,
                pos_id
            ) pos_batch
          where rep.q4x_source_id = p_source_id
          and rep.q4x_source_id = pos_batch.q4x_source_id
          and rep.pos_id = pos_batch.pos_id
        ) pos_rep
      --------------------------------------------------------------------------
      -- dist > latest_dist
      where dist.q4x_source_id = p_source_id
      and dist.q4x_source_id = latest_dist.q4x_source_id
      and dist.id = latest_dist.dist_id
      -- dist > activity
      and dist.q4x_source_id = activity.q4x_source_id
      and dist.act_id = activity.id
      -- activity > callcard
      and dist.q4x_source_id = callcard.q4x_source_id
      and activity.callcard_id = callcard.id
      -- callcard > cust_terr
      and dist.q4x_source_id = cust_terr.q4x_source_id
      and callcard.cust_id = cust_terr.cust_id
      -- cust_terr > terr_pos
      and dist.q4x_source_id = terr_pos.q4x_source_id
      and cust_terr.terr_id = terr_pos.terr_id
      -- terr_pos > pos_rep
      and dist.q4x_source_id = pos_rep.q4x_source_id
      and terr_pos.pos_id = pos_rep.pos_id

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_at_date] : '||SQLERRM, 1, 4000));

  end view_at_date;

end quo_dist_check_pkg;
/

-- Synonyms
create or replace public synonym quo_dist_check_pkg for dds_app.quo_dist_check_pkg;

-- Grants
grant execute on dds_app.quo_dist_check_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
