create or replace package qv_app.scrap_rework_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : infor 
  Owner   : qv_app 
  Package : scrap_rework_pkg 
  Author  : Trevor Keon 

  Description
  ------------------------------------------------------------------------------
  Scrap / Rework Package - Contains functions to extract scrap and rework related 
  information. 
  
  view_moisture_history - return moisture information for a given period 
  view_scrap_history - return scrap information for a given period  
  view_rework_history - return rework information for a given period 
  view_waivers_history - return waivers information for a given period     

  YYYY-MM-DD  Author                Description 
  ----------  --------------------  --------------------------------------------
  2014-07-18  Trevor Keon           Created 
  2014-08-26  Trevor Keon           Added Waivers 

*******************************************************************************/

  -- Public : Type (Record)  
  type moisture_rcd is record
  (
      prodn_shift_code char(10),
      start_datime date,  
      work_ctr_code char(10),
      matl_code number(8),
      target number(6,2),
      moisture number
  );

  type scrap_rcd is record
  (
      prodn_shift_code char(10), 
      start_datime date, 
      extruder char(2), 
      matl_code number,
      run_id varchar2(12),
      dryer_line varchar2(32),
      prodn_line_code varchar2(32),
      cereal number, 
      water number, 
      dye number, 
      meat number, 
      tallow number, 
      oil number,
      glycol number, 
      glucose number, 
      glycerine number, 
      steam number, 
      tioxide number,
      total number, 
      autol number,
      compnt_cod number
  );
  
  type rework_rcd is record
  (
      prodn_line_code varchar2(32),
      prodn_shift_code char(10),
      start_datime date,
      matl_code number,
      rework number  
  );
  
  type waiver_rcd is record
  (
      waiver_code number(6),
      material_code varchar2(8),
      waiver_material_code varchar2(8),
      work_ctr_code varchar2(9),
      waiver_applcb_desc varchar2(512),
      raised_by char(8),
      waiver_desc varchar2(4000),
      waiver_prob_change varchar2(2000),
      waiver_start_datime date,
      waiver_end_datime date  
  );

  -- Public : Type (Table) 
  type moisture_type is table of moisture_rcd;
  type scrap_type is table of scrap_rcd;
  type rework_type is table of rework_rcd;
  type waiver_type is table of waiver_rcd;

  -- Public : Functions 
  function view_moisture_history(p_period in integer) return moisture_type pipelined;
  function view_scrap_history(p_period in integer) return scrap_type pipelined;
  function view_rework_history(p_period in integer) return rework_type pipelined;
  function view_waivers_history(p_period in integer) return waiver_type pipelined;

end scrap_rework_pkg;

create or replace package body qv_app.scrap_rework_pkg as

  -- Private : Application Exception 
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants 
  g_package_name constant varchar2(64 char) := 'scrap_rework_pkg';  
  
  -- Function : View Moisture History  
  function view_moisture_history(p_period in integer) return moisture_type pipelined is

  begin

    for l_entity in 
    (
        select t01.prodn_shift_code,
           t03.start_datime, 
           t01.work_ctr_code,
           t02.item_code as matl_code,
           avg(t02.moisture_target) as target,
           round(avg(t01.moisture), 3) as moisture
        from proc_infra t01, 
           qcd_proc_infra t02, 
           prodn_shift t03,
           mars_date t04
        where t01.prod_code = t02.item_code
            and t01.moisture <= t02.moisture_high_hold
            and t01.prodn_shift_code = t03.prodn_shift_code
            and trunc(t03.start_datime) = t04.calendar_date
            and t01.moisture > 0
            and t02.moisture_target is not null
            and t04.mars_period = p_period
        group by t01.prodn_shift_code,
            t03.start_datime,
            t01.work_ctr_code,
            t02.item_code
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_moisture_history] : '||SQLERRM, 1, 4000));

  end view_moisture_history; 

  -- Function : View Scrap History  
  function view_scrap_history(p_period in integer) return scrap_type pipelined is

  begin

    for l_entity in 
    (
        select t03.prodn_shift_code, 
            t03.start_datime, 
            t03.extruder, 
            t03.matl_code,
            t03.run_id,
            t02.line_desc as dryer_line,
            'Line ' || substr(t02.line_desc, 7, 1) as prodn_line_code,
            t03.cereal, 
            t03.water, 
            t03.dye, 
            t03.meat, 
            t03.tallow, 
            t03.oil,
            t03.glycol, 
            t03.glucose, 
            t03.glycerine, 
            t03.steam, 
            t03.tioxide,
            t03.total,
            t03.autol, 
            t03.compnt_cod
        from cntl_rec_lcl t01,
            ref_line t02,
            (
            select t02.prodn_shift_code, 
               t02.start_datime,
               '1' as extruder, 
               t01.item_code as matl_code,
               trim(t01.run_id) as run_id, 
               t01.scrp_cer as cereal,
               t01.scrp_ewtr + t01.scrp_pcwtr as water, 
               t01.scrp_dye1 as dye,
               0 as meat, 
               t01.scrp_tall as tallow, 
               0 as oil, 
               0 as glycol,
               0 as glucose, 
               0 as glycerine,
               t01.scrp_estm + t01.scrp_pcstm as steam, 
               0 as tioxide,
               t01.scrp_autol as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from e1a_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '2' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               0 as water,
               t01.scrp_dye1 + t01.scrp_dye2 as dye, 
               t01.scrp_meat as meat,
               0 as tallow, 
               0 as oil, 
               t01.scrp_glyl as glycol,
               0 as glucose, 
               t01.scrp_glycr as glycerine, 
               0 as steam,
               t01.scrp_tiox as tioxide, 
               0 as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex2_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '3' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               t01.scrp_wtr1 + t01.scrp_wtr2 as water,
               t01.scrp_dye1 + t01.scrp_dye2 as dye, 
               0 as meat,
               t01.scrp_tall as tallow, 
               t01.scrp_oil as oil, 
               0 as glycol,
               0 as glucose, 
               0 as glycerine, 
               t01.scrp_stm1 + scrp_stm2 as steam,
               t01.scrp_tiox as tioxide, 
               0 as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex3_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '4' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               t01.scrp_wtr as water,
               t01.scrp_dye1 + t01.scrp_dye2 + t01.scrp_hpdye as dye, 
               0 as meat,
               t01.scrp_tall as tallow, 
               t01.scrp_oil as oil, 
               0 as glycol,
               0 as glucose, 
               0 as glycerine, 
               t01.scrp_stm as steam,
               t01.scrp_tiox as tioxide, 
               0 as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex4_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1 
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '5' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               t01.scrp_wtr as water,
               t01.scrp_dye1 + t01.scrp_dye2 + t01.scrp_hpdye as dye, 
               0 as meat,
               t01.scrp_tall as tallow, 
               t01.scrp_oil as oil, 
               0 as glycol,
               0 as glucose, 
               0 as glycerine, 
               t01.scrp_stm as steam,
               t01.scrp_tiox as tioxide, 
               0 as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex5_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1 
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '6' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               to_number(t01.scrp_wtr) as water,
               t01.scrp_dye1 + t01.scrp_dye2 as dye, 
               0 as meat,
               t01.scrp_tall as tallow, 
               t01.scrp_oil as oil, 
               t01.scrp_glyc as glycol,
               t01.scrp_gluc as glucose, 
               0 as glycerine, 
               t01.scrp_stm as steam,
               t01.scrp_tiox as tioxide, 
               t01.scrp_autol as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex6_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1 
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '7' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               0 as water,
               t01.scrp_dye1 + t01.scrp_dye2 as dye, 
               0 as meat,
               t01.scrp_tall as tallow, 
               t01.scrp_oil as oil, 
               t01.scrp_glyc as glycol,
               t01.scrp_gluc as glucose, 
               t01.scrp_glycr as glycerine, 
               t01.scrp_stm as steam,
               t01.scrp_tiox as tioxide, 
               0 as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex7_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1  
            union
            select t02.prodn_shift_code, 
               t02.start_datime, 
               '9' as extruder,
               t01.item_code as matl_code, 
               trim(t01.run_id) as run_id,
               t01.scrp_cer as cereal, 
               t01.scrp_wtr as water,
               t01.scrp_dye1 + t01.scrp_dye2 as dye, 
               t01.scrp_meat as meat,
               t01.scrp_tall as tallow, 
               t01.scrp_oil as oil, 
               0 as glycol,
               0 as glucose, 
               0 as glycerine, 
               t01.scrp_stm_e + t01.scrp_stm_p as steam,
               t01.scrp_tiox as tioxide, 
               0 as autol, 
               t01.scrp_ttl as total,
               t01.compnt_cod
            from ex9_scrp t01, 
               prodn_shift t02
            where t01.timestamp >= t02.start_datime
                and t01.timestamp < t02.end_datime
                and t02.shift_type_code not in ('200015', '200016', '200017')
                and t02.plant_code = 'AU30'
                and t01.status <> 1                                           
            ) t03,
            mars_date t04
        where t01.line_code = t02.line_code
            and t03.run_id = t01.proc_order
            and upper(t02.line_desc) like 'DR%'
            and trunc(t03.start_datime) = t04.calendar_date
            and t04.mars_period = p_period
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_scrap_history] : '||SQLERRM, 1, 4000));

  end view_scrap_history;

  -- Function : View Rework History  
  function view_rework_history(p_period in integer) return rework_type pipelined is

  begin

    for l_entity in 
    (
        select t01.prodn_line_code,
           t01.prodn_shift_code,
           t01.start_datime,
           t01.matl_code,
           t01.rework
        from
            (
                select 'Line 1' as prodn_line_code,
                   t02.prodn_shift_code,
                   t02.start_datime,
                   t01.item_code as matl_code,
                   sum(t04.infd_scrap + t04.outf_scrap + t05.infd_scrap + t05.outf_scrap + t01.pack_scrap) as rework
                from dcc1 t01,
                   prodn_shift t02,
                   mars_date t03,
                   bf6_10 t04,
                   bf11_13 t05
                where t01.prodn_shift_code = t02.prodn_shift_code
                   and trunc(t02.start_datime) = t03.calendar_date
                   and t01.timestamp = t04.timestamp
                   and t01.timestamp = t05.timestamp
                   and t02.plant_code = 'AU30'
                   and t03.mars_period = p_period
                group by t02.prodn_shift_code,
                   t02.start_datime,
                   t01.item_code
                union
                select 'Line 5' as prodn_line_code,
                   t02.prodn_shift_code,
                   t02.start_datime,
                   t06.item_code as matl_code,
                   sum(t04.infd_scrap + t04.outf_scrap + t05.inf5_scrap + t01.ctrof_scrp + t01.drout_scrp + t01.ctrin_scrp) as rework
                from cooler5 t01,
                   prodn_shift t02,
                   mars_date t03,
                   bf1_5 t04,
                   bf14_16 t05,
                   dryer5 t06
                where t01.prodn_shift_code = t02.prodn_shift_code
                   and trunc(t02.start_datime) = t03.calendar_date
                   and t01.timestamp = t04.timestamp
                   and t01.timestamp = t05.timestamp
                   and t01.timestamp = t06.timestamp
                   and t02.plant_code = 'AU30'
                   and t03.mars_period = p_period
                group by t02.prodn_shift_code,
                   t02.start_datime,
                   t06.item_code
                union
                select 'Line 6' as prodn_line_code,
                   t02.prodn_shift_code,
                   t02.start_datime,
                   t05.item_code as matl_code,
                   sum(t04.inf6_scrap + t04.outf_scrap + t01.pack_scrap + t01.ctrof_scrp + t01.drout_scrp + t01.ctrin_scrp) as rework
                from cooler6 t01,
                   prodn_shift t02,
                   mars_date t03,
                   bf14_16 t04,
                   dryer6 t05
                where t01.prodn_shift_code = t02.prodn_shift_code
                   and trunc(t02.start_datime) = t03.calendar_date
                   and t01.timestamp = t04.timestamp
                   and t01.timestamp = t05.timestamp
                   and t02.plant_code = 'AU30'
                   and t03.mars_period = p_period
                group by t02.prodn_shift_code,
                   t02.start_datime,
                   t05.item_code
            ) t01
        where t01.rework > 0
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_rework_history] : '||SQLERRM, 1, 4000));

  end view_rework_history; 

  -- Function : View Waiver History  
  function view_waivers_history(p_period in integer) return waiver_type pipelined is

  begin

    for l_entity in 
    (
        select t01.waiver_code,
            t04.bom_material_code as material_code,
            t02.item_code as waiver_material_code,
            t02.work_ctr_code,
            t01.waiver_applcb_desc,
            t01.creatn_prsn_id as raised_by, 
            t01.waiver_desc,
            t01.waiver_prob_change,
            t01.eff_start_datime as waiver_start_datime,
            t01.eff_end_datime as waiver_end_datime
        from wm.waiver t01,
            wm.waiver_crtria t02,
            mars_date t03,
            table (bds_app.bds_bom.get_hierarchy_reverse (sysdate, t02.item_code, 'AU30')) t04
        where t01.waiver_code = t02.waiver_code
            and trunc(t01.eff_start_datime) = t03.calendar_date
            and t01.waiver_stat = 'A'
            and length (t02.item_code) > 1
            and t01.waiver_mand_ind = 'Y'  
            and t03.mars_period = p_period
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_waivers_history] : '||SQLERRM, 1, 4000));
  
  end view_waivers_history;

end scrap_rework_pkg;

grant execute on qv_app.scrap_rework_pkg to qv_user;