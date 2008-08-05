create or replace force view manu_app.recpe_fcs_vw as
  select t01.proc_order, 
    t01.cntl_rec_id, 
    t01.matl_code, 
    t01.matl_text,
    t01.resrce_code, 
    t01.opertn, 
    t01.phase,
    t01.seq, 
    t01.code,
    t01.description, 
    t01.value, 
    t01.uom, 
    t01.mpi_type,
    t01.run_start_datime, 
    t01.run_end_datime, 
    t01.proc_order_stats,
    t02.batch_qty, 
    t01.strge_locn, 
    t01.mc_code, 
    t01.work_ctr_code,
    t01.work_ctr_name, 
    t01.pans, 
    t01.used_made, 
    t01.pan_size,
    t01.last_pan_size, 
    t01.plant
  from 
  (
    select ltrim (t03.proc_order, 0) as proc_order, 
      t01.cntl_rec_id,
      ltrim (t01.matl_code, '0') as matl_code, 
      t01.matl_text,
      t02.resrce_code, 
      t03.opertn, 
      to_number (t03.phase) as phase,
      to_number (lpad (t03.seq, 4, 0)) as seq,
      ltrim (t03.matl_code, '0') as code,
      t03.matl_desc as description,
      case
        when t04.bom_qty is null and pan_size_flag <> 'Y'
          then to_char(round(to_number(t03.qty), 3), '9999990.999')
        when t04.bom_qty is null and pan_size_flag = 'Y' and pan_qty = 1
          then to_char(round(to_number(pan_size), 3), '9999990.999')
        when t04.bom_qty is null and pan_size_flag = 'Y' and pan_qty > 1
          then to_char(round(to_number((pan_size * (pan_qty - 1)) + last_pan_size), 3), '9999990.999')
        when t04.bom_qty is null and pan_size_flag = 'Y' and (pan_qty is null or pan_qty = '')
          then to_char(round(to_number(pan_size), 3), '9999990.999')
        else to_char(t04.bom_qty, '999990D999')
      end as value,
      t03.uom, 
      'M' as mpi_type, 
      t01.run_start_datime,
      t01.run_end_datime, 
      to_char('', '') as proc_order_stats,
      t01.strge_locn, 
      '' as mc_code, 
      '' as work_ctr_code,
      '' as work_ctr_name,
      case
        when pan_qty is null
          then to_char(null)
        when pan_qty = 1
          then to_char(pan_qty)
        else to_char(round((pan_size * (pan_qty - 1) + last_pan_size) / pan_size, 1))
      end as pans,
      t03.phantom as used_made,
      to_char(t03.pan_size, '999999.999') as pan_size,
      to_char(t03.last_pan_size, '999999.999') as last_pan_size,
      t03.plant
    from cntl_rec_bom t03,
      cntl_rec_resrce t02,
      cntl_rec t01,
      (
        select proc_order,
          rd.opertn,
          rd.phase,
          rd.matl_code,
          bom_qty
        from recpe_hdr rh, 
          recpe_dtl rd
        where rh.cntl_rec_id = rd.cntl_rec_id
      ) t04
    where t02.proc_order = t03.proc_order
      and t02.opertn = t03.opertn
      and t01.proc_order = t03.proc_order
      and ltrim (t03.proc_order, '0') = t04.proc_order(+)
      and t03.opertn = t04.opertn(+)
      and t03.phase = t04.phase(+)
      and ltrim (t03.matl_code, '0') = t04.matl_code(+)
      and t01.teco_stat = 'NO'
      and ltrim (t03.matl_code, '0') not in (select matl_code from recpe_phantom)
    union all
    select ltrim (t02.proc_order, 0) as proc_order, 
      t01.cntl_rec_id,
      ltrim (t01.matl_code, '0') as matl_code, 
      t01.matl_text,
      t02.resrce_code, 
      t03.opertn, 
      to_number (t03.phase) as phase,
      to_number (lpad (t03.seq, 4, 0)) as seq, 
      t03.mpi_tag as code,
      t03.mpi_desc description,
      decode (t03.mpi_val, '?', '', t03.mpi_val) as value,
      decode (t03.mpi_uom, '?', '', t03.mpi_uom) as uom, 
      'V',
      t01.run_start_datime, 
      t01.run_end_datime,
      to_char ('', '') as proc_order_status, 
      t01.strge_locn,
      mc_code,
      '' as work_ctr_code, 
      '' as work_ctr_name, 
      '', 
      '', 
      '',
      '', 
      t01.plant
    from cntl_rec_mpi_val t03, 
      cntl_rec_resrce t02, 
      cntl_rec t01
    where t02.proc_order = t03.proc_order
      and t02.opertn = t03.opertn
      and t02.proc_order = t01.proc_order
      and t01.teco_stat = 'NO'
  ) t01,
  (
    select t01.*
    from 
    (
      select distinct to_char (batch_qty) as batch_qty, 
        matl_code,
        plant, 
        eff_start_date,
        rank () over (partition by matl_code, plant order by eff_start_date desc, alt desc) as rnkseq
      from bom
      where trunc(eff_start_date) <= trunc(sysdate)
    ) t01
    where rnkseq = 1
  ) t02
  where t01.matl_code = t02.matl_code
    and t01.plant = t02.plant
    and t01.run_start_datime between (trunc(sysdate) - 2) and (trunc(sysdate) + 20)
    and substr (t01.proc_order, 1, 1) between '0' and '9';

grant select on manu_app.recpe_fcs_vw to appsupport;
grant select on manu_app.recpe_fcs_vw to citsrv1 with grant option;
grant select on manu_app.recpe_fcs_vw to manu_maint;
grant select on manu_app.recpe_fcs_vw to manu_user;

create or replace public synonym recpe_fcs_vw for manu_app.recpe_fcs_vw;