create or replace view df_app.sales_forecast 
as
   select   t1.fcst_id as forecast_id, t1.forecast_type, t2.dmnd_plng_node,
            t4.mltplr_code, t1.casting_year,
            t1.casting_year || t1.casting_period as casting_period,
               t1.casting_year
            || t1.casting_period
            || t1.casting_week as casting_week,
            t4.bus_sgmnt_code, t3.mars_week, t3.zrep, t3.tdu,
            round (sum (t3.qty_in_base_uom)) as qty_in_base_uom,
            round (sum (t3.gsv), 2) as gsv,
            t2.cntry_id
       from fcst t1,
            dmnd_grp t2,
            dmnd_data t3,
            dmnd_grp_org t4,
            dmnd_grp_type t5
      where t1.fcst_id = t3.fcst_id
        and t2.dmnd_grp_id = t4.dmnd_grp_id
        and t3.dmnd_grp_org_id = t4.dmnd_grp_org_id
        and t2.dmnd_grp_type_id = t5.dmnd_grp_type_id
        and t3.mars_week >
                       t1.casting_year || t1.casting_period || t1.casting_week
   group by t1.fcst_id,
            t1.forecast_type,
            t2.dmnd_plng_node,
            t4.mltplr_code,
            t1.casting_year,
            casting_period,
            casting_week,
            t4.bus_sgmnt_code,
            t3.mars_week,
            t3.zrep,
            t3.tdu,
            t2.cntry_id;
/

create or replace public synonym sales_forecast for df_app.sales_forecast;
grant select on df_app.sales_forecast to df_reader;
/
