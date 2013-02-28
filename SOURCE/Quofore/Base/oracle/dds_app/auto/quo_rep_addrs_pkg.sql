
set define off;

-- Create Entity Access Package
create or replace package dds_app.quo_rep_addrs_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************
  
  System  : quo
  Owner   : dds_app
  Package : quo_rep_addrs_pkg
  Author  : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader Package - Table [quo_rep_addrs] Entity [RepAddress] Interface [quocdw05]  
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created
  
*******************************************************************************/

  -- Public : Type
  type quo_rep_addrs_type is table of ods.quo_rep_addrs%rowtype;

  -- Public : Functions
  function view_current(p_source_id in number) return quo_rep_addrs_type pipelined;
  function view_at_date(p_source_id in number, p_date in date) return quo_rep_addrs_type pipelined;
  function view_history(p_source_id in number) return quo_rep_addrs_type pipelined;

end quo_rep_addrs_pkg;
/

create or replace package body dds_app.quo_rep_addrs_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'quo_rep_addrs_pkg';
  g_entity_name constant varchar2(32 char) := 'RepAddress';
  
  /*****************************************************************************
  ** Function : Return Entity : Current 
  *****************************************************************************/
  function view_current(p_source_id in number) return quo_rep_addrs_type pipelined is

  begin
  
    for l_entity in (
      select *
      from quo_rep_addrs
      where q4x_source_id = p_source_id
      and (q4x_source_id,id) not in (
        select q4x_source_id,
          id
        from quo_graveyard
        where q4x_source_id = p_source_id
        and entity = g_entity_name
      )
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_current] : '||SQLERRM, 1, 4000));

  end view_current;

  /*****************************************************************************
  ** Function : Return Entity : As at Date
  *****************************************************************************/
  function view_at_date(p_source_id in number, p_date in date) return quo_rep_addrs_type pipelined is

  begin
  
    for l_entity in (
      select *
      from quo_rep_addrs_hist
      where (q4x_source_id,id,q4x_batch_id) in (
        select q4x_source_id,id, 
          max(q4x_batch_id) max_q4x_batch_id
        from quo_rep_addrs_hist
        where q4x_source_id = p_source_id
        and q4x_timestamp <= p_date
        and (q4x_source_id,id) not in (
          select q4x_source_id,
            id
          from quo_graveyard_hist
          where q4x_source_id = p_source_id
          and entity = g_entity_name
          and q4x_timestamp <= p_date
        )
        group by q4x_source_id,
          id
      )
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_at_date] : '||SQLERRM, 1, 4000));

  end view_at_date;
  
  /*****************************************************************************
  ** Function : Return Entity : History .. WARNING .. Does NOT Apply Graveyard
  *****************************************************************************/
  function view_history(p_source_id in number) return quo_rep_addrs_type pipelined is

  begin
  
    for l_entity in (
      select *
      from quo_rep_addrs_hist
      where (p_source_id = -1 or q4x_source_id = p_source_id)
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;
  
end quo_rep_addrs_pkg;
/

-- Synonyms
create or replace public synonym quo_rep_addrs_pkg for dds_app.quo_rep_addrs_pkg;

-- Grants
grant execute on dds_app.quo_rep_addrs_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
