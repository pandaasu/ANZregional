/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : recipe_fcs_vw
 Owner   : manu_app
 Author  : Unknown 

 Description 
 ----------- 
 Manufacturing - Recipe Factory Control System View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created
 2009/05   Trevor Keon    Added filter for RVR process orders 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu_app.recipe_fcs_vw as
  select ltrim (v.proc_order, 0) as proc_order, 
    cntl_rec_id,
    ltrim(material, '0') as material, 
    c.material_text, 
    r.resource_code,
    v.operation, 
    to_number(phase) as phase,
    to_number(lpad(seq, 4, 0)) as seq, 
    ltrim (material_code, '0') as code,
    material_desc as description,
    to_char(get_bom_qty(ltrim (c.material, '0'), ltrim (v.material_code, '0'), v.seq), '9999990.990') as value,
    material_uom uom, 
    'M' as mpi_type, 
    run_start_datime, 
    run_end_datime,
    s.closed as proc_order_status,
    to_char (get_bom_batch_qty (ltrim (c.material, '0'))) as batch_qty,
    storage_locn
  from cntl_rec_bom v, 
    cntl_rec_resource r, 
    cntl_rec c,
    cntl_rec_status_vw s
  where r.proc_order = v.proc_order
    and r.operation = v.operation
    and c.proc_order = v.proc_order
    and to_number (r.proc_order) = to_number (s.proc_order(+))
    and teco_status = 'NO'
    and substr(c.proc_order, 1, 1) between '0' and '9'
  union all
  select ltrim (r.proc_order, 0) as proc_order, 
    c.cntl_rec_id,
    ltrim (c.material, '0') as material, 
    c.material_text, 
    r.resource_code,
    v.operation, 
    to_number(phase) as phase,
    to_number(lpad(seq, 4, 0)) as seq, 
    mpi_tag as code, 
    mpi_desc as description,
    mpi_val as value, 
    mpi_uom as uom, 
    'V' as mpi_type, 
    run_start_datime, 
    run_end_datime,
    s.closed as proc_order_status,
    to_char (get_bom_batch_qty (ltrim (c.material, '0'))) as batch_qty,
    storage_locn
  from cntl_rec_mpi_val v,
    cntl_rec_resource r,
    cntl_rec c,
    cntl_rec_status_vw s
  where r.proc_order = v.proc_order
    and r.operation = v.operation
    and r.proc_order = c.proc_order
    and to_number (r.proc_order) = to_number (s.proc_order(+))
    and teco_status = 'NO'
    and substr(c.proc_order, 1, 1) between '0' and '9';

/**/
/* Authority 
/**/
grant select on manu_app.recipe_fcs_vw to bds_app with grant option;
grant select on manu_app.recipe_fcs_vw to manu_user;

/**/
/* Synonym 
/**/
create or replace public synonym recipe_fcs_vw for manu_app.recipe_fcs_vw;