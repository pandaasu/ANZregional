create or replace package qv_app.sched_shift_segment_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : infor 
  Owner   : qv_app 
  Package : sched_shift_segment_pkg 
  Author  : Trevor Keon 

  Description
  ------------------------------------------------------------------------------
  Infor Schedule Shift Package - Contains functions to allow split of schedule 
  by shift.   
  
  view_current - return current schedule information, split by shift 
  view_at_date - return first scheduled on or before the given date, split by shift 
  view_history - return all schedules in the given period, split by shift 

  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2014-06-03  Trevor Keon           Created 
  2014-07-16  Trevor Keon           Added loading for locked in version 
  2014-09-02  Trevor Keon           Added logic to identify the line for SBL, etc 
  2014-10-28  Trevor Keon           Fixed issue when schedule matches shift start or end times 

*******************************************************************************/

  -- Public : Type (Record)  
  type sched_shift_segment_rcd is record
  (
     model_name nvarchar2(80),
     batch_code nvarchar2(80),
     total_quantity float(126),
     shift_quantity float(126),
     prodn_shift_code char(10)
  );

 -- Public : Type (Record)  
  type sched_locked_rcd is record
  (
     batch_code varchar2(20),
     matl_code varchar2(20),
     resource_code varchar2(20),
     resource_group_code varchar2(20),  
     base_resource_code varchar2(20),
     base_resource_group_code varchar2(20),     
     total_quantity number(30,10),
     shift_quantity number(30,10),
     sched_shift_type number,
     start_outflow date,
     end_outflow date,
     schedule_start date,
     schedule_end date,
     prodn_shift_code char(10)
  );

  -- Public : Type (Table) 
  type sched_shift_segment_type is table of sched_shift_segment_rcd;
  type sched_locked_type is table of sched_locked_rcd;

  -- Public : Functions 
  function view_current(p_model in nvarchar2) return sched_shift_segment_type pipelined;
  function view_locked(p_sched_week in number, p_cast_week in number) return sched_locked_type pipelined;
--  function view_at_date(p_model in nvarchar2(80), p_date date) return sched_shift_segment_type pipelined;
--  function view_history(p_model in nvarchar2(80), p_period integer) return sched_shift_segment_type pipelined;

end sched_shift_segment_pkg;

create or replace package body qv_app.sched_shift_segment_pkg as

  -- Private : Application Exception 
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'sched_shift_segment_pkg';  
  
  -- Function : View Current for Model 
  function view_current(p_model in nvarchar2) return sched_shift_segment_type pipelined is

  begin

    for l_entity in 
    (
        select t01.as_model_name as model_name,
           t01.as_code as batch_code,
           t01.as_quantity as total_quantity,
           case
              when t02.start_datime >= t01.as_start_outflow and t02.end_datime <= t01.as_end_outflow
                 then t01.as_outflow_rate * ((t02.end_datime - t02.start_datime) * 24)
              when t02.start_datime <= t01.as_start_outflow and t02.end_datime <= t01.as_end_outflow
                 then t01.as_outflow_rate * ((t02.end_datime - t01.as_start_outflow) * 24)
              when t02.start_datime >= t01.as_start_outflow and t02.end_datime >= t01.as_end_outflow
                 then t01.as_outflow_rate * ((t01.as_end_outflow - t02.start_datime) * 24)
              else t01.as_quantity
           end as shift_quantity,        
           t02.prodn_shift_code
        from infor.as_processbatch t01,
           pr.prodn_shift t02
        where t01.as_end_outflow > t02.start_datime
           and t01.as_start_outflow < t02.end_datime
           and t01.as_model_name = p_model
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_current] : '||SQLERRM, 1, 4000));

  end view_current; 
  
  function view_locked(p_sched_week in number, p_cast_week in number) return sched_locked_type pipelined is
  
  begin

    for l_entity in 
    (  
        select t02.batch_code,
            t02.matl_code,
            decode(t05.resource_code, null, t02.resource_code, t05.resource_code) as resource_code,
            decode(t05.resource_group_code, null, t02.resource_group_code, t05.resource_group_code) as resource_group_code,
            t02.resource_code as base_resource_code,
            t02.resource_group_code as base_resource_group_code,
            t02.quantity as total_quantity,
            case
              when t03.start_datime >= t02.start_outflow and t03.end_datime <= t02.end_outflow
                 then t02.outflow_rate * ((t03.end_datime - t03.start_datime) * 24)
              when t03.start_datime <= t02.start_outflow and t03.end_datime <= t02.end_outflow
                 then t02.outflow_rate * ((t03.end_datime - t02.start_outflow) * 24)
              when t03.start_datime >= t02.start_outflow and t03.end_datime >= t02.end_outflow
                 then t02.outflow_rate * ((t02.end_outflow - t03.start_datime) * 24)
              else t02.quantity
            end as shift_quantity,
            case
              when t03.start_datime >= t02.start_outflow and t03.end_datime <= t02.end_outflow
                 then 1    -- Schedule runs throughout the shift 
              when t03.start_datime <= t02.start_outflow and t03.end_datime <= t02.end_outflow
                 then 2    -- Schedule starts during the shift, and ends after the shift 
              when t03.start_datime >= t02.start_outflow and t03.end_datime >= t02.end_outflow
                 then 3    -- Schedule starts before the shift, and ends during the shift 
              else 4       -- Schedule starts and ends during the shift 
            end as sched_shift_type,
            case
              when t03.start_datime >= t02.start_outflow
                 then t03.start_datime
              when t03.start_datime <= t02.start_outflow
                 then t02.start_outflow
            end as start_outflow, 
            case
              when t03.end_datime >= t02.end_outflow
                 then t02.end_outflow
              when t03.end_datime <= t02.end_outflow
                 then t03.end_datime
            end as end_outflow,                                 
            t02.start_outflow as schedule_start,
            t02.end_outflow as schedule_end,
            t03.prodn_shift_code
        from infor.ash_schedule_versions t01,
           infor.ash_schedules t02,
           pr.prodn_shift t03,
           mm.mars_date t04,
           (
                select distinct t01.schedule_id,
                   t01.batch_code,
                   t06.resource_code,
                   t06.resource_group_code
                from infor.ash_schedules t01, 
                   infor.ash_schedule_relationships t02,
                   infor.ash_schedule_relationships t03,
                   infor.ash_schedule_relationships t04,
                   infor.ash_schedule_relationships t05,
                   infor.ash_schedules t06 
                where t01.schedule_id = t02.schedule_id
                   and t01.batch_code = t02.process_batch_code
                   and t01.schedule_id = t03.schedule_id
                   and t02.tank_batch_code = t03.tank_batch_code
                   and t01.schedule_id = t04.schedule_id
                   and t03.process_batch_code = t04.process_batch_code
                   and t01.schedule_id = t05.schedule_id
                   and t04.tank_batch_code = t05.tank_batch_code
                   and t01.schedule_id = t06.schedule_id
                   and t05.process_batch_code = t06.batch_code
                   and t01.batch_type = 'PROCESS'
                   and t03.flow_direction = 'PROCESS_TO_TANK'
                   and t04.flow_direction = 'TANK_TO_PROCESS'
                   and t05.flow_direction = 'PROCESS_TO_TANK'           
           ) t05           
        where t01.schedule_id = t02.schedule_id
           and t02.end_outflow > t03.start_datime
           and t02.start_outflow < t03.end_datime
           and trunc(t03.start_datime) = t04.calendar_date
           and t02.schedule_id = t05.schedule_id (+)
           and t02.batch_code = t05.batch_code (+)           
           and t01.status = 'LOCKED'
           and t02.batch_type = 'PROCESS'
           and t01.casting_week = p_cast_week
           and t04.mars_week = p_sched_week
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_current] : '||SQLERRM, 1, 4000));

  end view_locked;  

end sched_shift_segment_pkg;

grant execute on qv_app.sched_shift_segment_pkg to qv_user;