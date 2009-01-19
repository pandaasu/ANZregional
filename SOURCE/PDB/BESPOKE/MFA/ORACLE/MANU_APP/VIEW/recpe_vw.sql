/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : recpe_vw  
 Owner   : manu_app
 Author  : Jeff Phillipson

 Description 
 ----------- 
 Manufacturing - Recipe View

 This view is designed to link the RECPE_DTL and RECPE_VAL tables          
 together so that a consolidated recordset is supplied to the FRR app      
---------------------------------------------------------------------------
 This section gets all the Operation and Resource codes as Headers         
  and if a single phantom is made within the op then the material and qty  
  is concatanated  

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2007/08   Jeff Phillipson  Changed the phase header query   
 2007/09   Jeff Phillipson  Added the difference flag #Z#   
 2007/09   Jeff Phillipson  (D.Woolcock Request)                                     
                            Removed the word 'for' extended to matl_desc from 22 
                            to 38chars and matl qty changed to 3 dec places
 2008/12   Trevor Keon      Changed how old material codes are loaded  

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu_app.recpe_vw as
  select ltrim (t02.proc_order, '0') proc_order, 
    t01.cntl_rec_id, 
    t01.opertn,
    '0' phase, 
    '0000' seq,
    decode (matl_made_qty, 0, t01.resrce_desc, substr (t01.resrce_desc, 0, 28))
      || decode (matl_made_qty, 0, '', null, '', ' '
                    || t01.matl_made
                    || ':'
                    || initcap (substr (matl_made_desc, 0, 38))
                    || ' '
                    || to_char (round (matl_made_qty, 3))
                    || lower (t03.uom)
                )
      || decode (t01.pan_qty, null, '', 0, '', ' - (M=' || t01.pan_qty || ')') description,
    null as uom, 
    null as qty, 
    null as sub_total, 
    0 as dummy, 
    '0' as old_matl_code,
    'H' as detailtype, 
    '' as sub_header
  from recpe_resrce t01,
    cntl_rec t02,
    (
      select t01.proc_order, 
        opertn, 
        max (t01.material_uom) as uom,
        max (rnk) as rnk, 
        cntl_rec_id
      from 
        (
          select proc_order, 
            operation as opertn, 
            material_uom,
            phantom,
            rank () over (partition by proc_order, operation order by phantom asc) as rnk
          from cntl_rec_bom
        ) t01,
        cntl_rec t02
      where t01.proc_order = t02.proc_order 
        and rnk = 1
      group by t01.proc_order, 
        opertn, 
        cntl_rec_id
    ) t03
  where t01.cntl_rec_id = t02.cntl_rec_id
    and t01.cntl_rec_id = t03.cntl_rec_id(+)
    and t01.opertn = t03.opertn(+)
    and t02.teco_status = 'NO'
    and recipe_line_hide (ltrim (t02.proc_order, '0'), t01.opertn, '') = 'D'
  union all
  /*-*/
  /* Phase header as defined by SRC values
  /* this section will find sub phases header within an operation  within the BOM recordes
  /* - these are any SRC's within the range 1500 to 1899
  /*-*/
  select t02.proc_order, 
    t02.cntl_rec_id, 
    operation as opertn,
    min (phase) as phase, 
    '0001' as seq, 
    mpi_desc, 
    null as uom, 
    null as qty,
    null as sub_total, 
    1 as dummy, 
    '0', 
    'HH', 
    '' as sub_header
  from cntl_rec_mpi_val t01, 
    recpe_hdr t02
  where ltrim (t01.proc_order, '0') = t02.proc_order
    and to_number (mpi_tag) between 1500 and 1899
    and mpi_val <> '*NP*'
  group by t02.proc_order, 
    operation, 
    mpi_desc, 
    mpi_tag, 
    t02.cntl_rec_id
  union all
  /* add material records from recpe_dtl which have been created by the
  /* recpe_conversion package */
  select ltrim (t01.proc_order, '0') as proc_order, 
    t01.cntl_rec_id, 
    t01.opertn,
    t01.phase, 
    lpad (t01.seq, 4, '0') as seq,
    case
      when t03.proc_order is null
        then '    ' || rpad (t01.matl_code, 9, ' ') || t01.matl_desc
        else ' #Z# ' || rpad (t01.matl_code, 9, ' ') || t01.matl_desc
    end,
    t01.uom, 
    to_char(round (t01.bom_qty, 3), '999G999G990D990'),
    to_char(round (t01.total, 3), '999G999G990D990'), 2,
    case upper(trim(to_char(lics_setting_configuration.retrieve_setting('PDB', 'SITE_CODE'))))
      when 'MCA' then ltrim(decode(t02.regional_code_19, null, '0', t02.regional_code_19) ,'0')
      when 'MFA' then ltrim(decode(t02.regional_code_18, null, '0', t02.regional_code_18) ,'0')
      when 'WOD' then ltrim(decode(t02.regional_code_17, null, '0', t02.regional_code_17) ,'0')
      when 'BTH' then ltrim(decode(t02.regional_code_17, null, '0', t02.regional_code_17) ,'0')
      when 'WGI' then ltrim(decode(t02.regional_code_10, null, '0', t02.regional_code_10) ,'0')
      else '0'
    end as old_matl_code,
    decode (t01.phantom, 'B', 'B', 'M'), 
    '' as sub_header
  from 
    (
      select t10.*, 
        ltrim (t11.proc_order, '0') as proc_order, 
        t11.plant
      from recpe_dtl t10, 
        cntl_rec t11
      where t10.cntl_rec_id = t11.cntl_rec_id
        and (t10.phantom = 'U' or t10.phantom = 'B' or t10.phantom is null)
    ) t01,
    bds_material_plant_mfanz t02,
    recpe_diff t03
  where t01.matl_code = ltrim (t02.sap_material_code(+), '0')
    and t01.plant = t02.plant_code(+)
    and t01.proc_order = t03.proc_order(+)
    and t01.opertn = t03.opertn(+)
    and t01.phase = t03.phase(+)
    and t01.seq = t03.seq(+)
  /* hide bold entries which do not have and sub materials  */
    and 
    (
      t01.phantom is null
      or t01.phantom = 'U'
      or 
      (
        select count (*)
        from recpe_dtl
        where cntl_rec_id = t01.cntl_rec_id
          and (phantom is null or phantom = 'U')
          and phase = lpad(to_char(to_number(t01.phase) + 1), 4, '0')
      ) <> 0
    )
  union all
  /* add the src value fields */
  select ltrim (t01.proc_order, '0') proc_order, 
    t01.cntl_rec_id, 
    t02.opertn,
    t02.phase, 
    lpad(t02.seq, 4, '0') as seq,
    decode(t03.proc_order, null, '', '', '', '#Z# ') || mpi_desc,
    mpi_uom, 
    mpi_val, 
    '', 
    2, 
    '0', 
    'S',
    sub_header
  from cntl_rec t01,
    (
      select t01.*, 
        t02.proc_order
      from recpe_val t01, 
        recpe_hdr t02
      where t01.cntl_rec_id = t02.cntl_rec_id
    ) t02,
    recpe_diff t03
  where t01.cntl_rec_id = t02.cntl_rec_id
    and t02.proc_order = t03.proc_order(+)
    and t02.opertn = t03.opertn(+)
    and t02.phase = t03.phase(+)
    and t02.seq = t03.seq(+)
    and (to_number (mpi_tag) not between 1500 and 1899 or mpi_tag is null)
  union all
  /* add the src text fields */
  select ltrim (t01.proc_order, '0') as proc_order, 
    cntl_rec_id,
    t02.operation as opertn, 
    phase, 
    lpad (seq, 4, '0') asseq,
    decode (detail_desc, '*', mpi_text, detail_desc),
    '' as mpi_uom,
    '' as mpi_val, 
    '', 
    2, 
    '0',
    decode (mpi_type, 'H', 'B', 'N', 'I', mpi_type), 
    '' sub_header
  from cntl_rec_mpi_txt t02, cntl_rec t01
  where t01.proc_order = t02.proc_order;
  
/**/
/* Synonym 
/**/
create or replace public synonym recpe_vw for manu_app.recpe_vw;
