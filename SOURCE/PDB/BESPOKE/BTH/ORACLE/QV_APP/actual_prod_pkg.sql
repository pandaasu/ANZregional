create or replace package qv_app.actual_prod_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : infor 
  Owner   : qv_app 
  Package : actual_prod_pkg 
  Author  : Trevor Keon 

  Description
  ------------------------------------------------------------------------------
  Actual Production Package - Contains functions to extract actual production 
  information. 
  
  view_recemt - return actual production from the current date minus provided 
               days history 
  view_history - return actual production for a given period  
  view_history_old - return actual production for a given period, before Infor 
               scheduling tool had been implemented 

  YYYY-MM-DD  Author                Description 
  ----------  --------------------  --------------------------------------------
  2014-06-04  Trevor Keon           Created 
  2014-06-25  Trevor Keon           Fixed issue with duplicates at shift changeover 
  2014-10-28  Trevor Keon           Updated ref_line table code to match new structure 
  2014-12-10  Trevor Keon           Fixed issue with some L7 products showing in L6 

*******************************************************************************/

  -- Public : Type (Record)  
  type actual_prod_rcd is record
  (
    start_prodn_datime date,
    xactn_date date,
    xactn_time number,
    prodn_shift_code char(10),
    matl_code varchar2(8),
    reason varchar2(12 char),
    qty number(12,3),
    uom varchar2(4),
    proc_order varchar(12),
    start_datime date,
    line_desc varchar2(32),
    prodn_line_code varchar2(32),
    nake_line_code varchar2(32),
    dryer_line_code varchar2(32),
    fg_line_flag number(1,0),
    nake_line_flag number(1,0),
    dryer_line_flag number(1,0),
    prodn_shift_shtdwn_ind char(1)
  );

  -- Public : Type (Table) 
  type actual_prod_type is table of actual_prod_rcd;

  -- Public : Functions 
  function view_recent(p_history_days in integer default 1) return actual_prod_type pipelined;
  function view_history(p_period in integer) return actual_prod_type pipelined;
  function view_history_old(p_period in integer) return actual_prod_type pipelined;

end actual_prod_pkg;

create or replace package body qv_app.actual_prod_pkg as

  -- Private : Application Exception 
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants 
  g_package_name constant varchar2(64 char) := 'actual_prod_pkg';  
  
  -- Function : View Recent 
  function view_recent(p_history_days in integer default 1) return actual_prod_type pipelined is

  begin

    for l_entity in 
    (
        select t01.start_prodn_datime,
           t02.xactn_date,
           t02.xactn_time,
           t04.prodn_shift_code,
           t01.matl_code,
           t02.reason,
           t01.qty,
           t01.uom,
           t03.proc_order,
           t04.start_datime,
           initcap(decode(t06.resource_code, null, t05.line_desc, t06.resource_code)) as line_desc,
           initcap(decode(t06.resource_code, null, t05.prodn_line_code, t06.resource_code)) as prodn_line_code,
           t05.nake_line_code,
           t05.dryer_line_code,
           t05.fg_line_flag,
           t05.nake_line_flag,
           t05.dryer_line_flag,
           t04.prodn_shift_shtdwn_ind
        from pt.plt_hdr t01,
           pt.plt_det t02,
           cntl_rec_lcl t03,
           prodn_shift t04,
           (
              select line_code,
                 line_desc,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then substr(line_desc, 1, 6)
                    when line_desc = 'L9 Ext'
                       then 'Line 9'
                    when line_desc = 'L7 Repack'
                       then 'Repack L1'
                    when substr(line_desc, 1, 2) = 'L7'
                       then 'Line 7'
                    when substr(sched_xref, 1, 4) = 'Line'
                       then 'Line ' || substr(sched_xref, 5, 1)
                    when substr(sched_xref, 1, 6) = 'Repack'
                       then 'SBL'
                    when substr(line_desc, 4, 7) = 'Outfeed'
                       then 'Line ' || decode(substr(line_desc, 2, 1), 1, 1, 2, 5, 3, 6, 4, 6)
                 end as prodn_line_code,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then 'L' || substr(line_desc, 6, 1) || ' Blending'
                    when substr(line_desc, 4, 7) = 'Outfeed'
                       then 'L' || decode(substr(line_desc, 2, 1), 1, 1, 2, 5, 3, 6, 4, 6) || ' Blending' 
                 end as nake_line_code,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then 'Dryer ' || substr(line_desc, 6, 1)
                 end as dryer_line_code,
                 case
                    when sched_xref is not null or line_desc = 'L9 Ext'
                       then 1
                 end as fg_line_flag,
                 decode(substr(line_desc, 4, 7), 'Outfeed', 1) as nake_line_flag,
                 decode(substr(line_desc, 1, 4), 'Line', 1) as dryer_line_flag   
              from manu.ref_line
              where line_desc <> '------'
           ) t05,
           (
              select distinct t01.process_order,
                 decode(t06.resource_code, 'L7 EXT', 'Line 7', t06.resource_code) as resource_code
              from infor.ash_actuals t01, 
                 infor.ash_actual_relationships t02,
                 infor.ash_actual_relationships t03,
                 infor.ash_actual_relationships t04,
                 infor.ash_actual_relationships t05,
                 infor.ash_actuals t06 
              where t01.batch_code = t02.process_batch_code
                 and t02.tank_batch_code = t03.tank_batch_code
                 and t03.process_batch_code = t04.process_batch_code
                 and t04.tank_batch_code = t05.tank_batch_code
                 and t05.process_batch_code = t06.batch_code
                 and t03.flow_direction = 'PROCESS_TO_TANK'
                 and t04.flow_direction = 'TANK_TO_PROCESS'
                 and t05.flow_direction = 'PROCESS_TO_TANK'  
           ) t06           
        where t01.plt_code = t02.plt_code
           and t01.proc_order = t03.proc_order
           and trunc(t01.start_prodn_datime) >= trunc(sysdate - p_history_days) 
           and (t01.start_prodn_datime > t04.start_datime and t01.start_prodn_datime <= t04.end_datime)
           and t03.line_code = t05.line_code
           and t01.proc_order = t06.process_order (+)
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_recent] : '||SQLERRM, 1, 4000));

  end view_recent;  

  -- Function : View History 
  function view_history(p_period in integer) return actual_prod_type pipelined is

  begin

    for l_entity in 
    (
        select t01.start_prodn_datime,
           t02.xactn_date,
           t02.xactn_time,
           t05.prodn_shift_code,
           t01.matl_code,
           t02.reason,
           t01.qty,
           t01.uom,
           t04.proc_order,
           t05.start_datime,
           initcap(decode(t07.resource_code, null, t06.line_desc, t07.resource_code)) as line_desc,
           initcap(decode(t07.resource_code, null, t06.prodn_line_code, t07.resource_code)) as prodn_line_code,
           t06.nake_line_code,
           t06.dryer_line_code,
           t06.fg_line_flag,
           t06.nake_line_flag,
           t06.dryer_line_flag,
           t05.prodn_shift_shtdwn_ind
        from pt.plt_hdr t01,
           pt.plt_det t02,
           mm.mars_date t03,
           cntl_rec_lcl t04,
           prodn_shift t05,
           (
              select line_code,
                 line_desc,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then substr(line_desc, 1, 6)
                    when line_desc = 'L9 Ext'
                       then 'Line 9'
                    when line_desc = 'L7 Repack'
                       then 'Repack L1'
                    when substr(line_desc, 1, 2) = 'L7'
                       then 'Line 7'
                    when substr(sched_xref, 1, 4) = 'Line'
                       then 'Line ' || substr(sched_xref, 5, 1)
                    when substr(sched_xref, 1, 6) = 'Repack'
                       then 'SBL'
                    when substr(line_desc, 4, 7) = 'Outfeed'
                       then 'Line ' || decode(substr(line_desc, 2, 1), 1, 1, 2, 5, 3, 6, 4, 6)
                 end as prodn_line_code,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then 'L' || substr(line_desc, 6, 1) || ' Blending'
                    when substr(line_desc, 4, 7) = 'Outfeed'
                       then 'L' || decode(substr(line_desc, 2, 1), 1, 1, 2, 5, 3, 6, 4, 6) || ' Blending' 
                 end as nake_line_code,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then 'Dryer ' || substr(line_desc, 6, 1)
                 end as dryer_line_code,
                 case
                    when sched_xref is not null or line_desc = 'L9 Ext'
                       then 1
                 end as fg_line_flag,
                 decode(substr(line_desc, 4, 7), 'Outfeed', 1) as nake_line_flag,
                 decode(substr(line_desc, 1, 4), 'Line', 1) as dryer_line_flag   
              from manu.ref_line
              where line_desc <> '------'
           ) t06,
           (
              select distinct t01.process_order,
                 decode(t06.resource_code, 'L7 EXT', 'Line 7', t06.resource_code) as resource_code
              from infor.ash_actuals t01, 
                 infor.ash_actual_relationships t02,
                 infor.ash_actual_relationships t03,
                 infor.ash_actual_relationships t04,
                 infor.ash_actual_relationships t05,
                 infor.ash_actuals t06 
              where t01.batch_code = t02.process_batch_code
                 and t02.tank_batch_code = t03.tank_batch_code
                 and t03.process_batch_code = t04.process_batch_code
                 and t04.tank_batch_code = t05.tank_batch_code
                 and t05.process_batch_code = t06.batch_code
                 and t03.flow_direction = 'PROCESS_TO_TANK'
                 and t04.flow_direction = 'TANK_TO_PROCESS'
                 and t05.flow_direction = 'PROCESS_TO_TANK'  
           ) t07            
        where t01.plt_code = t02.plt_code
           and trunc(t01.start_prodn_datime) = t03.calendar_date
           and t01.proc_order = t04.proc_order
           and (t01.start_prodn_datime > t05.start_datime and t01.start_prodn_datime <= t05.end_datime)
           and t04.line_code = t06.line_code
           and t01.proc_order = t07.process_order (+)
           and t03.mars_period = p_period
           and t03.mars_week >= '2014114'     -- Week when Infor scheduling tool went live 
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;

  -- Function : View History Old 
  function view_history_old(p_period in integer) return actual_prod_type pipelined is

  begin

    for l_entity in 
    (
        select t01.start_prodn_datime,
           t02.xactn_date,
           t02.xactn_time,
           t05.prodn_shift_code,
           t01.matl_code,
           t02.reason,
           t01.qty,
           t01.uom,
           t04.proc_order,
           t05.start_datime,
           t06.line_desc,
           t06.prodn_line_code,
           t06.nake_line_code,
           t06.dryer_line_code,
           t06.fg_line_flag,
           t06.nake_line_flag,
           t06.dryer_line_flag,
           t05.prodn_shift_shtdwn_ind
        from pt.plt_hdr t01,
           pt.plt_det t02,
           mm.mars_date t03,
           cntl_rec_lcl t04,
           prodn_shift t05,
           (
              select line_code,
                 line_desc,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then substr(line_desc, 1, 6)
                    when line_desc = 'L9 Ext'
                       then 'Line 9'
                    when line_desc = 'L7 Repack'
                       then 'Repack L1'
                    when substr(line_desc, 1, 2) = 'L7'
                       then 'Line 7'
                    when substr(sched_xref, 1, 4) = 'Line'
                       then 'Line ' || substr(sched_xref, 5, 1)
                    when substr(sched_xref, 1, 6) = 'Repack'
                       then 'SBL'
                    when substr(line_desc, 4, 7) = 'Outfeed'
                       then 'Line ' || decode(substr(line_desc, 2, 1), 1, 1, 2, 5, 3, 6, 4, 6)
                 end as prodn_line_code,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then 'L' || substr(line_desc, 6, 1) || ' Blending'
                    when substr(line_desc, 4, 7) = 'Outfeed'
                       then 'L' || decode(substr(line_desc, 2, 1), 1, 1, 2, 5, 3, 6, 4, 6) || ' Blending' 
                 end as nake_line_code,
                 case
                    when substr(line_desc, 1, 4) = 'Line'
                       then 'Dryer ' || substr(line_desc, 6, 1)
                 end as dryer_line_code,
                 case
                    when sched_xref is not null or line_desc = 'L9 Ext'
                       then 1
                 end as fg_line_flag,
                 decode(substr(line_desc, 4, 7), 'Outfeed', 1) as nake_line_flag,
                 decode(substr(line_desc, 1, 4), 'Line', 1) as dryer_line_flag    
              from manu.ref_line
              where line_desc <> '------'
           ) t06
        where t01.plt_code = t02.plt_code
           and trunc(t01.start_prodn_datime) = t03.calendar_date
           and t01.proc_order = t04.proc_order
           and (t01.start_prodn_datime > t05.start_datime and t01.start_prodn_datime <= t05.end_datime)
           and t04.line_code = t06.line_code
           and t03.mars_period = p_period
           and t03.mars_week < '2014114'     -- Week when Infor scheduling tool went live 
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history_old;

end actual_prod_pkg;

grant execute on qv_app.actual_prod_pkg to qv_user;