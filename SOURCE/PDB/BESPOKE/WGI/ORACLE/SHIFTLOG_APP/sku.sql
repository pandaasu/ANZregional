/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : shiftlog 
 View   : sku
 Owner   : shiftlog_app 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Shiftlog - SKU View
 
 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created
 2009/01   Trevor Keon    Added SVMS view - temporary

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view shiftlog_app.sku as
  select sku_code, 
    sku_desc, 
    units_case, 
    weight_kg, 
    tag,
    line_id, 
    type, 
    recstatus_id
  from 
    (
      select oldsku.sku_code,
        oldsku.sku_desc, 
        oldsku.units_case,
        oldsku.weight_kg, 
        oldsku.sku_desc as tag, 
        prodfamily.line_id,
        oldsku.type, 
        1 as recstatus_id
      from oldsku, 
        unconvmatl, 
        prodfamily
      where oldsku.sku_code = unconvmatl.old_material_code
        and oldsku.prodfamily_id = prodfamily.prodfamily_id
      union
      select fg.matl_code sku_code, 
        material_vw.material_desc as sku_desc,
        fg.units_per_case as units_case,
        material_vw.dclrd_wght / decode (material_vw.dclrd_uom, 'KGM', 1, 'GRM', 1000) / fg.units_per_case as weight_kg,
        material_vw.material_desc as tag, 
        linesku.line_id,
        decode 
        (
          line_id,
          6, 'Pouch',
          3, 'Pouch',
          2, 'Pouch',
          8, 'Pouch',
          'Other'
        ) as type,
        1 as recstatus_id
      from material_vw, 
        linesku, 
        site_shiftlog_fg_matl_vw fg
      where material_vw.material_type = 'FERT'
        and material_vw.material_code = linesku.sku_code(+)
        and fg.matl_code = material_vw.material_code
        and material_vw.material_code not in (select old_material_code from unconvmatl)
        and material_vw.material_code not in (select material from material_svms)
        and material_vw.material_code not in ('10056057', '10057595', '10032518', '10054178', '10054176', '10061260', '10061261')
      union
      select t01.material as sku_code, 
        t01.material_desc as sku_desc,
        t01.units_per_case,   
        t01.dclrd_wght / decode(t01.dclrd_uom, 'KGM', 1, 'GRM', 1000) / t01.units_per_case as weight_kg,
        t01.material_desc as tag,
        t02.line_id,
        decode 
        (
          line_id,
          6, 'Pouch',
          3, 'Pouch',
          2, 'Pouch',
          8, 'Pouch',
          'Other'
        ) as type,
        1 as recstatus_id
      from material_svms t01,
        linesku t02
      where t01.material = t02.sku_code(+)        
      union
      select '10056057' as sku_code,
        'WHI OSF Fav Fs MVMS 5X(12x100g)' as sku_desc, 
        60 as units_case,
        0.1 as weight_kg, 
        'WHI OSF Fav Fs MVMS 5X(12x100g)' as tag,
        2 as line_id, 
        'Pouch' as type, 
        1 as recstatus_id
      from dual
      union
      select '10057595' as sku_code,
        'WHI Oh So Selection 5x(12x100g)' as sku_desc, 
        60 as units_case,
        0.1 as weight_kg, 
        'WHI Oh So Selection 5x(12x100g)' as tag,
        2 as line_id, 'Pouch' as type, 
        1 as recstatus_id
      from dual
      union
      select '10054178' as sku_code,
        'WHI Oh So Meaty Selection 4(24x100g)' as sku_desc,
        96 as units_case, 
        0.1 as weight_kg,
        'WHI Oh So Meaty Selection 4(24x100g)' as tag, 
        2 as line_id,
        'Pouch' as type, 
        1 as recstatus_id
      from dual
      union
      select '10054176' as sku_code,
        'WHI OSF Selection 4(24x100g)' as sku_desc, 
        96 as units_case,
        0.1 as weight_kg, 
        'WHI OSF Selection 4(24x100g)' as tag,
        2 as line_id, 
        'Pouch' as type, 
        1 as recstatus_id
      from dual
      union
      select '10061260' as sku_code,
        'WHI OSF Selection 2x(24x100g)' as sku_desc, 
        48 as units_case,
        0.1 as weight_kg, 
        'WHI OSF Selection 2x(24x100g)' as tag,
        2 as line_id, 
        'Pouch' as type, 
        1 as recstatus_id
      from dual
      union
      select '10061261' as sku_code,
        'WHI OSM Selection 2x(24x100g)' as sku_desc, 
        48 as units_case,
        0.1 as weight_kg, 
        'WHI OSM Selection 2x(24x100g)' as tag,
        2 as line_id, 
        'Pouch' as type, 
        1 as recstatus_id
      from dual
      union
      select '10032518' as sku_code, 
        'WHI CIJ CkTn 5x12x100g NZ' as sku_desc,
        60 as units_case, 
        0.1 as weight_kg,
        'WHI CIJ CkTn 5x12x100g NZ' as tag, 
        6 as line_id, 
        'Pouch' as type,
        1 as recstatus_id
      from dual   
    )
  group by sku_code,
    sku_desc,
    units_case,
    weight_kg,
    tag,
    line_id,
    type,
    recstatus_id;


/**/
/* Authority 
/**/
grant select on shiftlog_app.sku to shiftlog;
grant select on shiftlog_app.sku to appsupport;

/**/
/* Synonym 
/**/
create or replace public synonym sku for shiftlog_app.sku;  