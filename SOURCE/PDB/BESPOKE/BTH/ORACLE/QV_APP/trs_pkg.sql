create or replace package qv_app.trs_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : infor 
  Owner   : qv_app 
  Package : trs_pkg 
  Author  : Trevor Keon 

  Description
  ------------------------------------------------------------------------------
  TRS Package - Contains functions to extract TRS (equipment efficiency) 
  information. 
  
  view_history - return actual production for a given period  

  YYYY-MM-DD  Author                Description 
  ----------  --------------------  --------------------------------------------
  2014-06-19  Trevor Keon           Created 
  2014-09-24  Trevor Keon           Added cleaning minutes 
  2014-10-02  Trevor Keon           Added fix for multiple uses of SHUTDOWN reason 

*******************************************************************************/

  -- Public : Type (Record)  
  type trs_rcd is record
  (
    work_ctr_code varchar2(10),
    work_ctr_name varchar2(25),
    prodn_shift_code char(10),
    start_datime date,
    matl_code varchar2(10),
    trs_start_datime date,
    trs_end_datime date,    
    event_start_datime date,
    event_end_datime date,
    minutes number,
    pm_minutes number,    
    target_rate number,
    actual_rate number,
    target_tonnes number,
    actual_tonnes number,
    rate_loss number,
    status_text varchar2(60),
    prim_reasn varchar2(40), 
    secdy_reasn varchar2(60), 
    tert_reasn varchar2(60),
    comments varchar2(160),
    proc_order varchar2(12), 
    line_code number,
    prodn_line_code varchar2(8),
    dryer_line_code varchar2(32),
    start_rate number,
    stop_rate number,
    shutdown_minutes number,
    cleaning_minutes number,
    product_change_ind number,
    flag_startup number,
    flag_shutdown number,
    flag_product_change number
  );

  -- Public : Type (Table) 
  type trs_type is table of trs_rcd;

  -- Public : Functions 
  function view_history(p_period in integer) return trs_type pipelined;

end trs_pkg;

create or replace package body qv_app.trs_pkg as

  -- Private : Application Exception 
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants 
  g_package_name constant varchar2(64 char) := 'trs_pkg';
  g_startup_max_time constant number := 360; -- 6hrs is assumed for startup time  
  
  -- Function : View History 
  function view_history(p_period in integer) return trs_type pipelined is

  -- This cursor generates the raw TRS data ordered by the work centre and date 
  cursor csr_downtime_data is
    select work_ctr_code,
        work_ctr_name, 
        prodn_shift_code,
        start_datime,
        matl_code,
        trs_start_datime,
        trs_end_datime,
        event_start_datime,
        event_end_datime,
        minutes,
        target_rate,
        round(actual_tonnes * (60 / minutes), 3) as actual_rate,
        round((target_rate * minutes) / 60, 3) as target_tonnes,
        actual_tonnes,
        round((((target_rate * minutes) / 60) - actual_tonnes) / target_rate, 6) as rate_loss,
        status_text,
        prim_reasn, 
        secdy_reasn, 
        tert_reasn,
        comments, 
        proc_order, 
        line_code,
        prodn_line_code,
        dryer_line_code,
        pm_minutes,
        rank_start
    from
    (
        select trim(t01.work_ctr_code) as work_ctr_code,
            trim(t01.work_ctr_name) as work_ctr_name, 
            t04.prodn_shift_code,
            t04.start_datime,
            t01.matl_code,
            t01.qty / 1000 as actual_tonnes,
            t07.lights_on as trs_start_datime,
            t07.lights_off as trs_end_datime,
            t01.start_datime as event_start_datime,
            t01.timestamp as event_end_datime,
            case
              when t01.start_datime < t07.lights_on
                 then round((t01.event_dur / 60) - ((t07.lights_on - t01.start_datime) * 1440), 3)
              when t01.timestamp > t07.lights_off
                 then round((t01.event_dur / 60) - ((t01.timestamp - t07.lights_off) * 1440), 3)
              else round(t01.event_dur / 60, 3)
            end as minutes,
            decode(t05.rate, null, decode(t01.work_ctr_code, 200026, 8, 200073, 16, 200081, 12), t05.rate) as target_rate,
            trim(upper(t01.status_text)) as status_text,
            t01.prim_reasn, 
            t01.secdy_reasn, 
            t01.tert_reasn,
            t01.comments, 
            t01.proc_order, 
            t02.line_code,
            t03.prodn_line_code,
            t03.line_desc as dryer_line_code,
            t07.pm_hours * 60 as pm_minutes,
            rank () over (partition by t01.work_ctr_code, t06.mars_week order by t01.start_datime) as rank_start   
        from px.downtime_web t01,
            manu.cntl_rec_lcl t02,
            (
                select line_code, 
                    line_desc,
                    'Line ' || substr(line_desc, length(line_desc), 1) as prodn_line_code
                from manu.ref_line
                where substr(line_desc, 1, 5) = 'Dryer'
            ) t03,
            pr.prodn_shift t04,
            px.dryer_rates t05,
            mm.mars_date t06,
            qv.bth_trs_times t07
        where t01.proc_order = t02.proc_order (+)
            and t02.line_code = t03.line_code (+)
            and t01.timestamp >= t04.start_datime
            and t01.timestamp < t04.end_datime
            and t01.matl_code = t05.matl_code (+)
            and trim(t01.work_ctr_code) = t05.work_ctr_code (+)
            and trunc(t01.start_datime) = t06.calendar_date
            and t06.mars_week = t07.mars_week
            and t01.timestamp >= t07.lights_on
            and t01.start_datime <= t07.lights_off  
            and trim(t01.work_ctr_code) in (200026, 200073, 200081)
            and t01.event_dur <> 0
            and t06.mars_period = p_period 
        order by t01.work_ctr_code,
           t01.start_datime
    );  
    
    -- Record variable to hold the hierarch output.        
    rv_downtime_data csr_downtime_data%rowtype;    
    
    -- Define the table structure for the downtime information. 
    type tt_downtime_collection is table of trs_rcd index by pls_integer;
    tv_downtime tt_downtime_collection;
    v_counter pls_integer;
    
    v_stop_count pls_integer;
    v_pc_stop_count pls_integer;
    
    v_pm_minutes_remain number;
    v_startup_minutes number;
    
    v_cleaning_time boolean;
    
    v_prior_startup boolean;
    v_prior_shutdown boolean;
    v_prior_pc boolean;
    v_prior_matl_code px.downtime_web.matl_code%type;

  begin
  
    v_counter := 0;
    v_stop_count := 0;
    v_pc_stop_count := 0;
    
    v_pm_minutes_remain := 0;
    v_startup_minutes := 0;
    
    v_cleaning_time := false;
    
    v_prior_startup := false;
    v_prior_shutdown := true;
    v_prior_pc := false;
    v_prior_matl_code := null;

    open csr_downtime_data;
    loop
      v_counter := v_counter + 1;
      
      fetch csr_downtime_data into rv_downtime_data;
      exit when csr_downtime_data%notfound;
      
      tv_downtime(v_counter).work_ctr_code := rv_downtime_data.work_ctr_code;
      tv_downtime(v_counter).work_ctr_name := rv_downtime_data.work_ctr_name;
      tv_downtime(v_counter).prodn_shift_code := rv_downtime_data.prodn_shift_code;
      tv_downtime(v_counter).start_datime := rv_downtime_data.start_datime;
      tv_downtime(v_counter).matl_code := rv_downtime_data.matl_code;
      tv_downtime(v_counter).trs_start_datime := rv_downtime_data.trs_start_datime;
      tv_downtime(v_counter).trs_end_datime := rv_downtime_data.trs_end_datime;
      tv_downtime(v_counter).event_start_datime := rv_downtime_data.event_start_datime;
      tv_downtime(v_counter).event_end_datime := rv_downtime_data.event_end_datime;
      tv_downtime(v_counter).minutes := rv_downtime_data.minutes;
      tv_downtime(v_counter).target_rate := rv_downtime_data.target_rate;
      tv_downtime(v_counter).actual_rate := rv_downtime_data.actual_rate;
      tv_downtime(v_counter).target_tonnes := rv_downtime_data.target_tonnes;
      tv_downtime(v_counter).actual_tonnes := rv_downtime_data.actual_tonnes;
      tv_downtime(v_counter).rate_loss := rv_downtime_data.rate_loss;
      tv_downtime(v_counter).status_text := rv_downtime_data.status_text;
      tv_downtime(v_counter).prim_reasn := rv_downtime_data.prim_reasn;
      tv_downtime(v_counter).secdy_reasn := rv_downtime_data.secdy_reasn;
      tv_downtime(v_counter).tert_reasn := rv_downtime_data.tert_reasn;
      tv_downtime(v_counter).comments := rv_downtime_data.comments;
      tv_downtime(v_counter).proc_order := rv_downtime_data.proc_order;
      tv_downtime(v_counter).line_code := rv_downtime_data.line_code;
      tv_downtime(v_counter).prodn_line_code := rv_downtime_data.prodn_line_code;
      tv_downtime(v_counter).dryer_line_code := rv_downtime_data.dryer_line_code;
      
      v_pm_minutes_remain := rv_downtime_data.pm_minutes;
      
      tv_downtime(v_counter).shutdown_minutes := 0;
      tv_downtime(v_counter).cleaning_minutes := 0;       
      tv_downtime(v_counter).pm_minutes := 0;      

      -- Handle startup / shutdown flags    
      if (((rv_downtime_data.rank_start = 1 or v_prior_startup = true) and rv_downtime_data.status_text = 'STOPPED')
         or (v_prior_startup = true and rv_downtime_data.minutes < 10)) then         
         tv_downtime(v_counter).flag_startup := 1;
         tv_downtime(v_counter).flag_shutdown := 0;
         
         v_startup_minutes := v_startup_minutes + rv_downtime_data.minutes;
         
         -- Set the cleaning time during startup 
         if (v_startup_minutes > g_startup_max_time) then
             if (v_cleaning_time = false) then
                 tv_downtime(v_counter).cleaning_minutes := v_startup_minutes - g_startup_max_time; 
                 v_cleaning_time := true;
             else
                 tv_downtime(v_counter).cleaning_minutes := rv_downtime_data.minutes;
             end if;
         end if;
         
         -- Handle scenario where SHUTDOWN not defined as primary reason 
         if (v_prior_shutdown = false and v_prior_startup = false and v_stop_count > 0) then
             v_prior_shutdown := true;
             tv_downtime(v_counter-1).shutdown_minutes := 0;
             tv_downtime(v_counter-(v_stop_count+1)).stop_rate := tv_downtime(v_counter-1).target_rate;
             
             -- loop over prior items 
             for i in 1..v_stop_count
             loop
                 tv_downtime(v_counter-i).flag_shutdown := 1;
                 
                 -- check if there are PM minutes, and any remaining to be "swapped" 
                 if (v_pm_minutes_remain > 0) then
                   if (v_pm_minutes_remain > tv_downtime(v_counter-i).minutes) then
                      tv_downtime(v_counter-i).pm_minutes := tv_downtime(v_counter-i).minutes; 
--                      tv_downtime(v_counter-i).minutes := 0; 
                                       
                      v_pm_minutes_remain := v_pm_minutes_remain - tv_downtime(v_counter-i).pm_minutes;                  
                   else
                      tv_downtime(v_counter-i).pm_minutes := v_pm_minutes_remain;
--                      tv_downtime(v_counter-i).minutes := tv_downtime(v_counter-i).minutes - v_pm_minutes_remain; 
                      tv_downtime(v_counter).shutdown_minutes := tv_downtime(v_counter-i).minutes;
                      v_pm_minutes_remain := 0;
                   end if;
                 else
                   tv_downtime(v_counter-1).shutdown_minutes := tv_downtime(v_counter-1).shutdown_minutes + tv_downtime(v_counter-i).minutes;
                 end if;
             end loop;            
         end if;
         v_prior_startup := true;
      elsif (rv_downtime_data.prim_reasn = 'SHUTDOWN') then
         v_prior_shutdown := true;
         tv_downtime(v_counter).flag_startup := 0;
         tv_downtime(v_counter-(v_stop_count+1)).stop_rate := rv_downtime_data.target_rate;
         
         -- loop over prior items 
         for i in 0..v_stop_count
         loop
             tv_downtime(v_counter-i).flag_shutdown := 1;
             
             -- Set prior items to 0 if SHUTDOWN reason has been used multiple times 
             -- Only want this set once! 
             tv_downtime(v_counter-i).shutdown_minutes := 0;
             
             -- check if there are PM minutes, and any remaining to be "swapped" 
             if (v_pm_minutes_remain > 0) then
               if (v_pm_minutes_remain > tv_downtime(v_counter-i).minutes) then
                  tv_downtime(v_counter-i).pm_minutes := tv_downtime(v_counter-i).minutes; 
--                  tv_downtime(v_counter-i).minutes := 0;
                                   
                  v_pm_minutes_remain := v_pm_minutes_remain - tv_downtime(v_counter-i).pm_minutes;                  
               else
                  tv_downtime(v_counter-i).pm_minutes := v_pm_minutes_remain;
--                  tv_downtime(v_counter-i).minutes := tv_downtime(v_counter-i).minutes - v_pm_minutes_remain;
                  tv_downtime(v_counter).shutdown_minutes := tv_downtime(v_counter-i).minutes;
                  v_pm_minutes_remain := 0;
               end if;
             else
               tv_downtime(v_counter).shutdown_minutes := tv_downtime(v_counter).shutdown_minutes + tv_downtime(v_counter-i).minutes;
             end if;
                  
         end loop;
      else
         tv_downtime(v_counter).flag_startup := 0;
         tv_downtime(v_counter).flag_shutdown := 0;
         
         v_prior_shutdown := false;
         v_cleaning_time := false;
         v_startup_minutes := 0; 
         
         if (v_prior_startup = true) then
            tv_downtime(v_counter).start_rate := rv_downtime_data.target_rate;
            v_prior_startup := false;
         end if;        
      end if;
           
      -- Keep track of when the line is stopped or running for <10 minutes to handle the shutdown flags 
      if (rv_downtime_data.status_text = 'STOPPED' or rv_downtime_data.minutes < 10) then
         v_stop_count := v_stop_count + 1;      
      else
         v_stop_count := 0;
      end if;

      -- Keep track of when the line is stopped or running for <10 minutes to handle the product change flags 
      if (rv_downtime_data.status_text = 'STOPPED' or rv_downtime_data.minutes < 3) then
         v_pc_stop_count := v_pc_stop_count + 1;      
      else
         v_pc_stop_count := 0;
      end if;

      -- Handle product change flag 
      if (v_prior_matl_code is not null and v_prior_matl_code <> rv_downtime_data.matl_code and v_pc_stop_count > 0) then
         v_prior_pc := true;
         tv_downtime(v_counter).product_change_ind := 1;
              
         -- loop over prior items 
         for i in 0..v_pc_stop_count-1
         loop
             tv_downtime(v_counter-i).flag_product_change := 1;  
         end loop;
      elsif (v_prior_pc = true and v_pc_stop_count > 0) then
         tv_downtime(v_counter).flag_product_change := 1; 
      else
         v_prior_pc := false;
         tv_downtime(v_counter).flag_product_change := 0;      
      end if;
      
      v_prior_matl_code := rv_downtime_data.matl_code; 
    end loop;

    close csr_downtime_data; 

    v_counter := 0;
    loop 
        v_counter := v_counter + 1;
        exit when v_counter > tv_downtime.count;        
        pipe row(tv_downtime(v_counter));            
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;

end trs_pkg;

grant execute on qv_app.trs_pkg to qv_user;