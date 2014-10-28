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

  YYYY-MM-DD  Author                Description 
  ----------  --------------------  --------------------------------------------
  2014-06-04  Trevor Keon           Created 
  2014-06-25  Trevor Keon           Fixed issue with duplicates at shift changeover 

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
           t05.line_desc,
           t05.prodn_line_code,
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
                     when substr(line_desc, 4, 5) = 'Blend'
                        then 'Line ' || substr(line_desc, 2, 1)
                     when substr(line_desc, 1, 5) = 'Dryer'
                        then 'Line ' || substr(line_desc, 7, 1)
                     when substr(line_desc, 1, 7) = 'Repack '
                        then 'SBL'
                  end as prodn_line_code,
                  case
                     when substr(line_desc, 4, 5) = 'Blend'
                        then line_desc
                     when substr(line_desc, 1, 5) = 'Dryer'
                        then 'L' || substr(line_desc, 7, 1) || ' Blending' 
                  end as nake_line_code,
                  case
                     when substr(line_desc, 1, 5) = 'Dryer'
                        then line_desc
                  end as dryer_line_code,
                  case
                     when substr(line_desc, 1, 4) = 'Line' or substr(line_desc, 1, 6) = 'Repack'
                        then 1
                  end as fg_line_flag,
                  decode(substr(line_desc, 4, 5), 'Blend', 1) as nake_line_flag,
                  decode(substr(line_desc, 1, 5), 'Dryer', 1) as dryer_line_flag
               from ref_line 
           ) t05
        where t01.plt_code = t02.plt_code
           and t01.proc_order = t03.proc_order
           and trunc(t01.start_prodn_datime) >= trunc(sysdate - p_history_days)
           and (t01.start_prodn_datime > t04.start_datime and t01.start_prodn_datime <= t04.end_datime)
           and t03.line_code = t05.line_code
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
                     when substr(line_desc, 4, 5) = 'Blend'
                        then 'Line ' || substr(line_desc, 2, 1)
                     when substr(line_desc, 1, 5) = 'Dryer'
                        then 'Line ' || substr(line_desc, 7, 1)
                     when substr(line_desc, 1, 7) = 'Repack '
                        then 'SBL'
                  end as prodn_line_code,
                  case
                     when substr(line_desc, 4, 5) = 'Blend'
                        then line_desc
                     when substr(line_desc, 1, 5) = 'Dryer'
                        then 'L' || substr(line_desc, 7, 1) || ' Blending' 
                  end as nake_line_code,
                  case
                     when substr(line_desc, 1, 5) = 'Dryer'
                        then line_desc
                  end as dryer_line_code,
                  case
                     when substr(line_desc, 1, 4) = 'Line' or substr(line_desc, 1, 6) = 'Repack'
                        then 1
                  end as fg_line_flag,
                  decode(substr(line_desc, 4, 5), 'Blend', 1) as nake_line_flag,
                  decode(substr(line_desc, 1, 5), 'Dryer', 1) as dryer_line_flag
               from ref_line  
           ) t06
        where t01.plt_code = t02.plt_code
           and trunc(t01.start_prodn_datime) = t03.calendar_date
           and t01.proc_order = t04.proc_order
           and (t01.start_prodn_datime > t05.start_datime and t01.start_prodn_datime <= t05.end_datime)
           and t04.line_code = t06.line_code
           and t03.mars_period = p_period
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;

end actual_prod_pkg;

grant execute on qv_app.actual_prod_pkg to qv_user;