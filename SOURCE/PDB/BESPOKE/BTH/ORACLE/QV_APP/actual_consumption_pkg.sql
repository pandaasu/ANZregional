create or replace package qv_app.actual_consumption_pkg as
/*******************************************************************************
** Package Definition
********************************************************************************

  System  : infor 
  Owner   : qv_app 
  Package : actual_consumption_pkg 
  Author  : Trevor Keon 

  Description
  ------------------------------------------------------------------------------
  Actual Consumption Package - Contains functions to extract actual consumption 
  information. 
  
  view_recemt - return actual production from the current date minus provided 
               days history 
  view_history - return actual production for a given period  

  YYYY-MM-DD  Author                Description 
  ----------  --------------------  --------------------------------------------
  2014-07-28  Trevor Keon           Created 

*******************************************************************************/

  -- Public : Type (Record)  
  type actual_consumption_rcd is record
  (
    recorded char(2),
    sched_start_datime date,
    prodn_shift_code char(10),
    line_desc varchar2(32),
    proc_order varchar(12),    
    po_matl_code varchar2(8),   
    matl_code varchar2(8),
    plant_code varchar2(4),
    qty number,
    ac_qty number,
    unit_cost number,
    bom_uom varchar2(4),
    base_uom varchar2(4),
    uom_multiplier number
  );

  -- Public : Type (Table) 
  type actual_consumption_type is table of actual_consumption_rcd;

  -- Public : Functions 
  function view_history(p_period in integer) return actual_consumption_type pipelined;

end actual_consumption_pkg;

create or replace package body qv_app.actual_consumption_pkg as

  -- Private : Application Exception 
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants 
  g_package_name constant varchar2(64 char) := 'actual_consumption_pkg';  

  -- Function : View History 
  function view_history(p_period in integer) return actual_consumption_type pipelined is

  begin

    for l_entity in 
    (
        select 'R' as recorded, 
            t02.sched_start_datime,
            t07.prodn_shift_code,
            t06.prodn_line_code as line_desc,
            t02.proc_order, 
            t02.po_mat as po_matl_code, 
            t02.material_code as matl_code,
            t02.plant_code, 
            round(decode(t02.qty, null, 0, t02.qty),3) as qty,
            decode(t01.ac_qty, null, 0, t01.ac_qty) as ac_qty,
            round(t03.unit_cost * t04.mlt, 2) as unit_cost,
            t02.bom_uom, 
            t03.base_uom, 
            t04.mlt as uom_multiplier
        from 
            (
                select proc_order, 
                   matl_code, 
                   sum (qty) as ac_qty, 
                   uom
                from plt_cnsmptn
                group by proc_order, 
                   matl_code,
                   uom
            ) t01,
            (
                select proc_order,
                   ltrim (po_mat, '0') as po_mat, 
                   material_code,
                   sum(qty) as qty, 
                   made_qty,
                   po_qty, 
                   sched_start_datime, 
                   plant_code, 
                   bom_uom
                from 
                   (
                      select ltrim(t99.proc_order, '0') as proc_order, 
                         t99.operation,
                         t99.phase,
                         ltrim (t99.material_code, '0') as material_code, 
                         t99.material_qty,
                         t99.pan_size,
                         t99.last_pan_size, 
                         t99.pan_size_flag as pan, 
                         t98.pan_qty,
                         t97.op_pan,
                         (decode(t99.pan_size_flag, 'N', t99.material_qty, decode(t98.pan_qty,'',((t99.pan_size / t97.mke_pan) * t97.made_req_qty), ((t99.pan_size / t98.mke_pan) * t98.made_req_qty)))) / t95.quantity * t96.made_qty as qty,
                         t96.made_qty, 
                         t95.quantity as po_qty,
                         t95.sched_start_datime, 
                         t95.plant_code,
                         t99.material_uom as bom_uom, 
                         t95.material as po_mat
                      from bds_recipe_bom t99,
                         (
                             select ltrim(proc_order, '0') as proc_order,
                                 operation, 
                                 phase, 
                                 pan_qty,
                                 material_qty as made_req_qty,
                                 pan_size as mke_pan
                             from bds_recipe_bom
                             where phantom = 'M'
                         ) t98,
                         (
                             select ltrim (proc_order, '0') as proc_order,
                                 operation, 
                                 sum (pan_qty) as op_pan,
                                 sum (material_qty) as made_req_qty,
                                 max (pan_size) as mke_pan,
                                 material_code
                             from bds_recipe_bom
                             where phantom = 'M'
                             group by proc_order, 
                                 operation, 
                                 material_code
                         ) t97,
                         (
                             select decode(t02.xactn_type, 'CREATE', sum(qty), -sum(qty)) as made_qty,
                                 uom, 
                                 proc_order
                             from plt_hdr t01, 
                                 plt_det t02
                             where t01.plt_code = t02.plt_code
                             group by uom, 
                                 t02.xactn_type, 
                                 proc_order
                         ) t96,
                         bds_recipe_header t95
                      where ltrim(t99.proc_order, '0') = t98.proc_order (+)
                         and t99.phase = t98.phase (+)
                         and ltrim(t99.proc_order, '0') = t97.proc_order (+)
                         and t99.operation = t97.operation (+)
                         and t99.material_code = t97.material_code (+)
                         and ltrim(t99.proc_order, '0') = t96.proc_order (+)
                         and t99.proc_order = t95.proc_order
                         and t99.bf_item = 'N'
                         and t99.phantom is null
                         and t99.material_code not in (1001191, 1048800, 1005785) -- ignore water and steam 
                   )
                   group by proc_order,
                      material_code,
                      made_qty,
                      po_qty,
                      sched_start_datime,
                      plant_code,
                      bom_uom,
                      po_mat
            ) t02,
            matl_vw t03,
            qv_uom t04,
            cntl_rec_lcl t05,
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
                     when substr(line_desc, 1, 6) = 'Repack' or substr(line_desc, 4, 6) = 'Repack'
                        then 'SBL'
                  end as prodn_line_code
               from ref_line  
            ) t06,    
            prodn_shift t07,
            mars_date t08
        where t01.proc_order (+) = t02.proc_order
            and t01.matl_code (+) = t02.material_code
            and t02.material_code = t03.matl_code
            and t02.plant_code = t03.plant
            and t02.bom_uom = t04.bom_uom
            and t03.base_uom = t04.matl_uom
            and t02.proc_order = t05.proc_order
            and t05.line_code = t06.line_code
            and (t02.sched_start_datime > t07.start_datime and t02.sched_start_datime <= t07.end_datime)
            and trunc(t02.sched_start_datime) = t08.calendar_date
            and substr(t02.proc_order, 1, 1) <> '%'
            and trim(t03.prcrmnt_type) || trim(t03.spcl_prcrmnt_type) <> 'E50'
            and t08.mars_period = p_period
        union all
        select 'NR' as recorded,
            t02.sched_start_datime, 
            t07.prodn_shift_code,
            t06.prodn_line_code as line_desc,
            t01.proc_order, 
            ltrim(t02.material, '0') as po_matl_code,
            t01.matl_code, 
            t02.plant_code, 
            0 qty, 
            t01.qty as ac_qty, 
            t03.unit_cost * t04.mlt as unit_cost,
            t01.uom as bom_uom,
            t03.base_uom as base_uom, 
            t04.mlt as uom_multiplier
        from 
            (
               select proc_order, 
                  matl_code, 
                  uom, 
                  sum(qty) as qty
               from plt_cnsmptn
               group by proc_order, 
                  matl_code, 
                  uom
            ) t01,
            bds_recipe_header t02,
            matl_vw t03,
            qv_uom t04,
            cntl_rec_lcl t05,
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
                     when substr(line_desc, 1, 6) = 'Repack' or substr(line_desc, 4, 6) = 'Repack'
                        then 'SBL'
                  end as prodn_line_code
               from ref_line  
            ) t06,    
            prodn_shift t07,
            mars_date t08
        where t01.proc_order = ltrim(t02.proc_order, '0')
            and t01.matl_code = t03.matl_code
            and t02.plant_code = t03.plant
            and t01.uom = t04.bom_uom
            and t03.base_uom = t04.matl_uom
            and t01.proc_order = t05.proc_order
            and t05.line_code = t06.line_code
            and (t02.sched_start_datime > t07.start_datime and t02.sched_start_datime <= t07.end_datime)
            and trunc(t02.sched_start_datime) = t08.calendar_date
            and substr(t01.proc_order, 1, 1) <> '%'
            and t01.proc_order || t01.matl_code not in (select proc_order || material_code from qv_bom)
            and trim(t03.prcrmnt_type) || trim(t03.spcl_prcrmnt_type) <> 'E50'
            and t08.mars_period = p_period
    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_history] : '||SQLERRM, 1, 4000));

  end view_history;

end actual_consumption_pkg;

grant execute on qv_app.actual_consumption_pkg to qv_user;