create or replace package qv_app.kibble_analysis_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : infor 
  Owner   : qv_app 
  Package : kibble_analysis_pkg 
  Author  : Trevor Keon 

  Description
  ------------------------------------------------------------------------------
  Kibble Analysis Package - Contains functions to extract kibble analysis 
  information. 
  
  view_history - return kibble analysis results for a given period  

  YYYY-MM-DD  Author                Description 
  ----------  --------------------  --------------------------------------------
  2014-08-04  Trevor Keon           Created 

*******************************************************************************/

  -- Public : Type (Record)  
  type kibble_analysis_rcd is record
  (
    measure_datime date,
    sample_no number(3),
    meas_type_id number(8),
    kibble_dimn number(8,2),
    matl_code number(8),
    prodn_shift_code varchar2(10),
    result char(3)
  );

  -- Public : Type (Table) 
  type kibble_analysis_type is table of kibble_analysis_rcd;

  -- Public : Functions 
  function view_history(p_period in integer) return kibble_analysis_type pipelined;

end kibble_analysis_pkg;

create or replace package body qv_app.kibble_analysis_pkg as

  -- Private : Application Exception 
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants 
  g_package_name constant varchar2(64 char) := 'kibble_analysis_pkg';

  -- Function : View History 
  function view_history(p_period in integer) return kibble_analysis_type pipelined is

  begin

    for l_entity in 
    (
        select t01.timestamp as measure_datime,
            t01.sample_no,
            t01.meas_type_id,
            t01.kibble_dimn,
            t01.child_item_code as matl_code,
            t01.prodn_shift_code,
            t01.result
        from calpr_kibble_rslt t01,
            mars_date t02
        where trunc(t01.timestamp) = t02.calendar_date
            and t01.kibble_dimn > 0
            and t02.mars_period = p_period
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;

end kibble_analysis_pkg;

grant execute on qv_app.kibble_analysis_pkg to qv_user;