create or replace force view manu_app.cntl_rec_resrce_vw as
/******************************************************************/
/* This is a straight view of the bds_recipe_header table
/* with resource records
/* 15 Oct 2007 JP added resource column
/******************************************************************/
  select ltrim(t01.proc_order, 0) as proc_order, 
    t01.cntl_rec_id as cntl_rec_id,
    t01.plant_code as plant, 
    t01.cntl_rec_status as cntl_rec_stat,
    t01.test_flag as test_flag, 
    t01.recipe_text as recpe_text,
    ltrim(t01.material, '0') as matl_code, 
    t01.material_text as matl_text,
    round(to_number(t01.quantity), 3) as qty, 
    t01.insplot as insplot, 
    t01.uom as uom,
    t01.batch as batch, 
    t01.sched_start_datime as sched_start_datime, 
    t01.run_start_datime as run_start_datime,
    t01.run_end_datime as run_end_datime, 
    t01.version as vrsn, 
    t01.upd_datime as upd_datime,
    t01.cntl_rec_xfer as cntl_rec_xfer, 
    t01.teco_status as teco_stat,
    t01.storage_locn as strge_locn, 
    t02.resource_code as resrce_code
  from bds_recipe_header t01,
  (
    select distinct t01.proc_order, 
      t01.resource_code
    from bds_recipe_resource t01
    where
    (   
      operation in 
      (
        select operation
        from bds_recipe_bom
        where proc_order = t01.proc_order
          and operation = t01.operation
          and material_code not in
          (
            select matl_code
            from recpe_phantom
          )
      )
      or
      (
        operation in 
        (
          select operation
          from bds_recipe_src_value
          where proc_order = t01.proc_order
            and operation = t01.operation
        )
      )
      or 
      (
        operation in 
        (
          select operation
          from bds_recipe_src_text
          where proc_order = t01.proc_order
            and operation = t01.operation
        )
      )
    )
  ) t02
  where t01.proc_order = t02.proc_order
    and t01.plant_code = 'AU40'
    and substr(t01.proc_order, 1, 1) between '0' and '9'
    and teco_status = 'NO';

grant select on manu_app.cntl_rec_resrce_vw to appsupport;
grant select on manu_app.cntl_rec_resrce_vw to fcs_reader;
grant select on manu_app.cntl_rec_resrce_vw to fcs_user;
grant select on manu_app.cntl_rec_resrce_vw to manu_maint;

create or replace public synonym cntl_rec_resrce_vw for manu_app.cntl_rec_resrce_vw;
