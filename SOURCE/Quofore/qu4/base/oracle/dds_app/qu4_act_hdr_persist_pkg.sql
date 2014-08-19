
set define off;

-- Create Entity Access Package
create or replace package dds_app.qu4_act_hdr_persist_pkg as
  /***************************************************************-****************
  ** Package Definition
  ********************************************************************************

    System   : qu4
    Owner    : dds_app
    Package  : qu4_act_hdr_persist_pkg
    Author   : Mal Chambeyron

    Description
    ------------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Persistant View Package, Entity [ActivityHeader] Table [qu4_act_hdr][_load/_hist]
    - Latest [cust_id], [task_type_id] by [start_date]

    YYYY-MM-DD  Author                Description
    ----------  --------------------  --------------------------------------------
    2014-08-19  Mal Chambeyron        Created

  *******************************************************************************/

  -- Public : Type
  type qu4_act_hdr_persist_rec is record (
    report_date                       date,
    --
    act_id                            qu4_act_hdr_hist.id%type,
    task_id                           qu4_act_hdr_hist.task_id%type,
    rep_id                            qu4_act_hdr_hist.rep_id%type,
    start_date                        qu4_act_hdr_hist.start_date%type,
    is_complete                       qu4_act_hdr_hist.is_complete%type,
    end_date                          qu4_act_hdr_hist.end_date%type,
    call_card_id                      qu4_act_hdr_hist.call_card_id%type,
    cust_id                           qu4_call_card_hist.cust_id%type,
    task_type_id                      qu4_task_hist.task_type_id%type,
    --
    key_site_plcmnt_is_activated      qu4_act_hdr_hist.key_site_plcmnt_is_activated%type,
    mstm_reg_plcmnt_no_of_register    qu4_act_hdr_hist.mstm_reg_plcmnt_no_of_register%type,
    mstm_reg_plcmnt_no_of_mstm        qu4_act_hdr_hist.mstm_reg_plcmnt_no_of_mstm%type,
    fridge_plcmnt_is_activated        qu4_act_hdr_hist.fridge_plcmnt_is_activated%type,
    fridge_plcmnt_no_of_doors         qu4_act_hdr_hist.fridge_plcmnt_no_of_doors%type,
    fridge_plcmnt_no_of_frdg_units    qu4_act_hdr_hist.fridge_plcmnt_no_of_frdg_units%type,
    fridge_plcmnt_is_sleeved_up       qu4_act_hdr_hist.fridge_plcmnt_is_sleeved_up%type,
    fridge_plcmnt_is_mars_and_coke    qu4_act_hdr_hist.fridge_plcmnt_is_mars_and_coke%type,
    front_back_fronts_in_store        qu4_act_hdr_hist.front_back_fronts_in_store%type,
    front_back_fronts_tied_to_prom    qu4_act_hdr_hist.front_back_fronts_tied_to_prom%type,
    front_back_front_end_type         qu4_act_hdr_hist.front_back_front_end_type%type,
    front_back_backs_in_store         qu4_act_hdr_hist.front_back_backs_in_store%type,
    front_back_backs_tied_to_prom     qu4_act_hdr_hist.front_back_backs_tied_to_prom%type,
    front_back_back_end_type          qu4_act_hdr_hist.front_back_back_end_type%type,
    lead_in_lead_out_is_any           qu4_act_hdr_hist.lead_in_lead_out_is_any%type
  );

  type qu4_act_hdr_persist_type is table of qu4_act_hdr_persist_rec;

  -- Public : Functions
  function view_at_date(p_date in date) return qu4_act_hdr_persist_type pipelined;

end qu4_act_hdr_persist_pkg;
/

create or replace package body dds_app.qu4_act_hdr_persist_pkg as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'qu4_act_hdr_persist_pkg';
  g_entity_name constant varchar2(64 char) := 'ActivityHeader';
  g_source_id constant number(4) := qu4_constants.source_id;

  /*****************************************************************************
  ** Function : Return Entity : As at Date
  *****************************************************************************/
  function view_at_date(p_date in date) return qu4_act_hdr_persist_type pipelined is

    l_prev_cust_id qu4_call_card_hist.cust_id%type;
    l_prev_task_type_id qu4_task_hist.task_type_id%type;
  
  begin
    
    l_prev_cust_id := -1;
    l_prev_task_type_id := -1;

    for l_entity in (
    
      select
        p_date report_date,
        --
        act_hdr.id act_id,
        act_hdr.task_id,
        act_hdr.rep_id,
        act_hdr.start_date,
        act_hdr.is_complete,
        act_hdr.end_date,
        act_hdr.call_card_id,
        call_card.cust_id,
        task.task_type_id,
        --
        act_hdr.key_site_plcmnt_is_activated,
        act_hdr.mstm_reg_plcmnt_no_of_register,
        act_hdr.mstm_reg_plcmnt_no_of_mstm,
        act_hdr.fridge_plcmnt_is_activated,
        act_hdr.fridge_plcmnt_no_of_doors,
        act_hdr.fridge_plcmnt_no_of_frdg_units,
        act_hdr.fridge_plcmnt_is_sleeved_up,
        act_hdr.fridge_plcmnt_is_mars_and_coke,
        act_hdr.front_back_fronts_in_store,
        act_hdr.front_back_fronts_tied_to_prom,
        act_hdr.front_back_front_end_type,
        act_hdr.front_back_backs_in_store,
        act_hdr.front_back_backs_tied_to_prom,
        act_hdr.front_back_back_end_type,
        act_hdr.lead_in_lead_out_is_any
      from table(qu4_act_hdr_pkg.view_at_start_date(p_date)) act_hdr,
        table(qu4_act_dtl_pkg.cust_eff_task_view_at_date(p_date)) cust_task, -- limits to effective tasks
        table(qu4_call_card_pkg.view_at_date(p_date)) call_card,
        table(qu4_task_pkg.view_at_date(p_date)) task
      where act_hdr.id = cust_task.act_id
      and act_hdr.call_card_id = call_card.id 
      and act_hdr.task_id = task.id  
      order by call_card.cust_id,
        task.task_type_id,
        act_hdr.start_date desc

    )
    loop
    
      -- return first record on [cust_id], [task_type_id]
      if l_prev_cust_id != l_entity.cust_id or l_prev_task_type_id != l_entity.task_type_id then
        l_prev_cust_id := l_entity.cust_id;
        l_prev_task_type_id := l_entity.task_type_id;
        pipe row(l_entity);
      end if;
    
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_at_date] : '||SQLERRM, 1, 4000));

  end view_at_date; 

end qu4_act_hdr_persist_pkg;
/

-- Synonyms
create or replace public synonym qu4_act_hdr_persist_pkg for dds_app.qu4_act_hdr_persist_pkg;

-- Grants
grant execute on dds_app.qu4_act_hdr_persist_pkg to qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
