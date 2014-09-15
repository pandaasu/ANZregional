      -- This query will extract the latest forecast in the correct format for the Apollo Supply Unit Testing.
      select
        tdu_matl_code,
        plant_code,
        null as not_used,
        to_char(start_date,'DD/MM/YYYY') as start_date,
        '7D' as date_range,
        qty
      from (
      select 
        t20.fcst_id,
        t20.moe_code,
        t20.mars_week,
        t20.tdu_matl_code,
        t20.plant_code,
        t20.start_date,
        sum(t20.qty) as qty
      from
        (
        select
            t10.fcst_id,
            t10.moe_code,
            t10.dmnd_grp_code,
            t10.mars_week,
            -- Output Fields
            t10.tdu_matl_code,
            ( select 
                t0.plant_code 
              from 
                (select '00' as plng_srce_code ,'' as plant_code from dual union all
select '01' as plng_srce_code ,'AU27' as plant_code from dual union all
select '02' as plng_srce_code ,'AU27' as plant_code from dual union all
select '03' as plng_srce_code ,'AU27' as plant_code from dual union all
select '04' as plng_srce_code ,'AU27' as plant_code from dual union all
select '05' as plng_srce_code ,'AU27' as plant_code from dual union all
select '06' as plng_srce_code ,'AU27' as plant_code from dual union all
select '07' as plng_srce_code ,'AU32' as plant_code from dual union all
select '08' as plng_srce_code ,'AU32' as plant_code from dual union all
select '09' as plng_srce_code ,'' as plant_code from dual union all
select '10' as plng_srce_code ,'AU27' as plant_code from dual union all
select '11' as plng_srce_code ,'AU27' as plant_code from dual union all
select '99' as plng_srce_code ,'' as plant_code from dual union all
select '12' as plng_srce_code ,'AU27' as plant_code from dual union all
select '13' as plng_srce_code ,'AU27' as plant_code from dual union all
select '14' as plng_srce_code ,'AU46' as plant_code from dual union all
select '15' as plng_srce_code ,'' as plant_code from dual union all
select '16' as plng_srce_code ,'AU46' as plant_code from dual union all
select '17' as plng_srce_code ,'AU46' as plant_code from dual) t0
              where 
                t0.plng_srce_code = 
                  ( select 
                      t00.plng_srce_code 
                    from 
                      matl_fg_clssfctn t00 
                    where 
                      t00.matl_code = reference_functions.full_matl_code(t10.tdu_matl_code)
                  )
            ) as plant_code,
            (select min(t0.calendar_date) from mars_date t0 where t0.mars_week = t10.mars_week) as start_date,
            t10.qty
          from
            (select
              t1.fcst_id,
              t1.moe_code,
              t4.dmnd_grp_code,
              t2.mars_week,
              -- Output Fields
              t2.tdu as tdu_matl_code,
              sum(t2.qty_in_base_uom) as qty
            from
              fcst t1,
              dmnd_data t2,
              dmnd_grp_org t3,
              dmnd_grp t4
            where 
              -- Base Joines
              t1.fcst_id = t2.fcst_id 
              and t2.dmnd_grp_org_id = t3.dmnd_grp_org_id
              and t3.dmnd_grp_id = t4.dmnd_grp_id 
              -- Filter Predicates
              and t1.fcst_id = (select max(fcst_id) from fcst where moe_code = '0196' and forecast_type = 'FCST' and status = 'V')
              and t3.acct_assign_id in (
                select acct_assign_id
                from dmnd_acct_assign
                where acct_assign_code = '01' -- Domestic
              ) 
              and t2.tdu is not null
              and t2.mars_week > t1.casting_year || t1.casting_period || t1.casting_week
            group by
              t1.fcst_id,
              t1.moe_code,
              t4.dmnd_grp_code,
              t2.mars_week,
              t2.tdu
            having sum(t2.qty_in_base_uom) != 0
          ) t10
        ) t20
        group by
          t20.fcst_id,
          t20.moe_code,
          t20.mars_week,
          t20.tdu_matl_code,
          t20.plant_code,
          t20.start_date
      )
      order by
        tdu_matl_code,
        mars_week
        
