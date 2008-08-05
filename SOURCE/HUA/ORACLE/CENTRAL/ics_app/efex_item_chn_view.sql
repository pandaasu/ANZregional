/******************************************************************************/
/*  NAME:       EFEX_ITEM_CHN_VIEW                                            */
/*  PURPOSE:    China EFEX Item view                                          */
/*  REVISIONS:                                                                */
/*  Ver    Date        Author           Description                           */
/*  -----  ----------  ---------------  ------------------------------------  */
/*  1.0    08-07-2008  Steve Gregan     Created view for China                */
/******************************************************************************/

create or replace force view ics_app.efex_item_chn_view
   (item_code,
    item_name,
    item_zrep_code,
    rsu_ean_code,
    cases_layer,
    layers_pallet, 
    units_case,
    unit_measure,
    price1,
    price2,
    price3, 
    price4,
    min_ord_qty,
    order_multiples,
    brand,
    sub_brand, 
    pack_size,
    pack_type,
    item_category,
    item_status) as
  select ltrim(t02.smatn,'0') as item_code,
          t02.maktx as item_name,
          ltrim(t01.matnr,'0') as item_zrep_code,
          decode(t02.rsu_meinh,null,decode(t02.mcu_meinh,null,t02.tdu_ean11,t02.mcu_ean11),t02.rsu_ean11) as rsu_ean_code,
          decode(t02.rsu_meinh,null,0,t02.mcu_count) as cases_layer,
          0 as layers_pallet,
          decode(t02.rsu_meinh,null,decode(t02.mcu_meinh,null,t02.tdu_count,t02.mcu_count),t02.rsu_count) as units_case,
          t02.tdu_meinh as unit_measure,
          nvl(t03.list_price,0) as price1,
          0 as price2,
          0 as price3,
          0 as price4,
          0 as min_ord_qty,
          0 as order_multiples,
          t01.brand_flag_desc as brand,
          t01.brand_sub_flag_desc as sub_brand,
          t01.prdct_pack_size_desc as pack_size,
          t01.cnsmr_pack_frmt_desc as pack_type,
          t01.bus_sgmnt_desc as item_category,
          t02.item_status
     from
          --
          -- Material ZREP information
          --
          (select t01.matnr as matnr,
                  t01.ean11 as ean11,
                  t01.meins as meins,
                  nvl(t02.maktx,'*UNKNOWN') as maktx,
                  nvl(t04.bus_sgmnt_desc,'*UNKNOWN') as bus_sgmnt_desc,
                  nvl(t05.brand_flag_desc,'*UNKNOWN') as brand_flag_desc,
                  nvl(t06.brand_sub_flag_desc,'*UNKNOWN') as brand_sub_flag_desc,
                  nvl(t07.prdct_pack_size_desc,'*UNKNOWN') as prdct_pack_size_desc,
                  nvl(t08.cnsmr_pack_frmt_desc,'*UNKNOWN') as cnsmr_pack_frmt_desc,
                  decode(t09.vmsta,'20',' ','99','X') as item_status
             from lads_mat_hdr t01,
                  (select t21.matnr,
                          t21.maktx
                     from lads_mat_mkt t21
                    where t21.spras_iso = 'EN') t02,
                  (select t31.objek as matnr,
                          nvl(max(case when t32.atnam = 'CLFFERT01' then t32.atwrt end),'00') as sap_bus_sgmnt_code,
                          nvl(max(case when t32.atnam = 'CLFFERT03' then t32.atwrt end),'000') as sap_brand_flag_code,
                          nvl(max(case when t32.atnam = 'CLFFERT04' then t32.atwrt end),'000') as sap_brand_sub_flag_code,
                          nvl(max(case when t32.atnam = 'CLFFERT14' then t32.atwrt end),'000') as sap_prdct_pack_size_code,
                          nvl(max(case when t32.atnam = 'CLFFERT25' then t32.atwrt end),'00') as sap_cnsmr_pack_frmt_code
                     from lads_cla_hdr t31,
                          lads_cla_chr t32
                    where t31.obtab = 'MARA'
                      and t31.klart = '001'
                      and t31.obtab = t32.obtab(+)
                      and t31.klart = t32.klart(+)
                      and t31.objek = t32.objek(+)
                    group by t31.objek) t03,
                  (select substr(t01.z_data,4,2) as sap_bus_sgmnt_code,
                          substr(t01.z_data,18,30) as bus_sgmnt_desc
                     from lads_ref_dat t01
                    where t01.z_tabname = '/MARS/MD_CHC001') t04,
                  (select substr(t01.z_data,4,3) as sap_brand_flag_code,
                          substr(t01.z_data,19,30) as brand_flag_desc
                     from lads_ref_dat t01
                    where t01.z_tabname = '/MARS/MD_CHC003') t05,
                  (select substr(t01.z_data,4,3) as sap_brand_sub_flag_code,
                          substr(t01.z_data,19,30) as brand_sub_flag_desc
                     from lads_ref_dat t01
                    where t01.z_tabname = '/MARS/MD_CHC004') t06,
                  (select substr(t01.z_data,4,3) as sap_prdct_pack_size_code,
                          substr(t01.z_data,19,30) as prdct_pack_size_desc
                     from lads_ref_dat t01
                    where t01.z_tabname = '/MARS/MD_CHC014') t07,
                  (select substr(t01.z_data,4,2) as sap_cnsmr_pack_frmt_code,
                          substr(t01.z_data,18,30) as cnsmr_pack_frmt_desc
                     from lads_ref_dat t01
                    where t01.z_tabname = '/MARS/MD_CHC025') t08,
                  (select t01.matnr as matnr,
                          t01.vmstd as vmstd,
                          t01.vmsta as vmsta
                     from (select t01.matnr as matnr,
                                  t01.sadseq as sadseq,
                                  t01.vmstd as vmstd,
                                  t01.vmsta as vmsta,
                                  rank() over (partition by t01.matnr order by t01.vmstd desc, t01.sadseq desc) as rnkseq
                             from lads_mat_sad t01
                            where t01.vkorg = '135'
                              and t01.vtweg = '10'
                              and t01.lvorm is null
                              and (t01.vmsta = '20' or t01.vmsta = '99')
                              and decode(t01.vmstd,null,'19000101','00000000','19000101',t01.vmstd) <= to_char(sysdate,'yyyymmdd')) t01
                    where t01.rnkseq = 1) t09
            where t01.matnr = t02.matnr(+)
              and t01.matnr = t03.matnr(+)
              and t01.matnr = t09.matnr
              and t03.sap_bus_sgmnt_code = t04.sap_bus_sgmnt_code(+)
              and t03.sap_brand_flag_code = t05.sap_brand_flag_code(+)
              and t03.sap_brand_sub_flag_code = t06.sap_brand_sub_flag_code(+)
              and t03.sap_prdct_pack_size_code = t07.sap_prdct_pack_size_code(+)
              and t03.sap_cnsmr_pack_frmt_code = t08.sap_cnsmr_pack_frmt_code(+)
              and t01.mtart = 'ZREP'
              and t01.zzistdu = 'X'
              and t01.lvorm is null
              and t01.lads_status = '1') t01,
          --
          -- Material TDU information
          --
          (select t01.matnr as matnr,
                  t01.smatn as smatn,
                  t01.maktx as maktx,
                  t01.ean11 as ean11,
                  t01.meins as meins,
                  decode(t01.vmsta,'20',' ','99','X','X') as item_status,
                  t02.tdu_count,
                  t02.mcu_count,
                  t02.rsu_count,
                  t02.tdu_meinh,
                  t02.mcu_meinh,
                  t02.rsu_meinh,
                  t02.tdu_ean11,
                  t02.mcu_ean11,
                  t02.rsu_ean11
             from
                  --
                  -- Material ZREP/TDU information (material determination)
                  --
                  (select t01.matwa as matnr,
                          t01.datab as datab,
                          t01.datbi as datbi,
                          t01.smatn as smatn,
                          nvl(t02.maktx,'*UNKNOWN') as maktx,
                          t02.ean11 as ean11,
                          t02.meins as meins,
                          t02.vmsta as vmsta
                     from (select t01.matwa as matwa,
                                  t01.datab as datab,
                                  t01.datbi as datbi,
                                  t02.smatn as smatn,
                                  rank() over (partition by t01.matwa order by t01.datab desc, t01.datbi asc) as rnkseq
                             from (select substr(z_data,1,3) as mandt,
                                          substr(z_data,4,2) as kappl,
                                          substr(z_data,6,4) as kschl,
                                          trim(substr(z_data,10,4)) as vkorg,
                                          trim(substr(z_data,14,2)) as vtweg,
                                          null as kunag,
                                          trim(substr(z_data,16,18)) as matwa,
                                          substr(z_data,34,8) as datbi,
                                          substr(z_data,42,8) as datab,
                                          substr(z_data,50,10) as knumh
                                     from lads_ref_dat
                                    where z_tabname = 'KOTD002'
                                    union all
                                   select substr(z_data,1,3) as mandt,
                                          substr(z_data,4,2) as kappl,
                                          substr(z_data,6,4) as kschl,
                                          trim(substr(z_data,10,4)) as vkorg,
                                          null as vtweg,
                                          null as kunag,
                                          trim(substr(z_data,14,18)) as matwa,
                                          substr(z_data,32,8) as datbi,
                                          substr(z_data,40,8) as datab,
                                          substr(z_data,48,10) as knumh
                                     from lads_ref_dat
                                    where z_tabname = 'KOTD880'
                                    union all
                                   select substr(z_data,1,3) as mandt,
                                          substr(z_data,4,2) as kappl,
                                          substr(z_data,6,4) as kschl,
                                          trim(substr(z_data,10,4)) as vkorg,
                                          trim(substr(z_data,14,2)) as vtweg,
                                          trim(substr(z_data,16,10)) as kunag,
                                          trim(substr(z_data,26,18)) as matwa,
                                          substr(z_data,44,8) as datbi,
                                          substr(z_data,52,8) as datab,
                                          substr(z_data,60,10) as knumh
                                     from lads_ref_dat
                                    where z_tabname = 'KOTD501'
                                    union all
                                   select substr(z_data,1,3) as mandt,
                                          substr(z_data,4,2) as kappl,
                                          substr(z_data,6,4) as kschl,
                                          trim(substr(z_data,10,4)) as vkorg,
                                          trim(substr(z_data,14,2)) as vtweg,
                                          trim(substr(z_data,16,10)) as kunag,
                                          trim(substr(z_data,26,18)) as matwa,
                                          substr(z_data,44,8) as datbi,
                                          substr(z_data,52,8) as datab,
                                          substr(z_data,60,10) as knumh
                                     from lads_ref_dat
                                    where z_tabname = 'KOTD907') t01,
                                  (select substr(z_data,1,3) as mandt,
                                          substr(z_data,4,10) as knumh,
                                          trim(substr(z_data,14,18)) as smatn,
                                          substr(z_data,32,3) as meins,
                                          substr(z_data,35,4) as sugrd,
                                          substr(z_data,39,1) as psdsp,
                                          substr(z_data,40,1) as lstacs
                                     from lads_ref_dat
                                    where z_tabname = 'KONDD') t02
                            where t01.mandt = t02.mandt
                              and t01.knumh = t02.knumh
                              and t01.mandt = '002'
                              and t01.kappl = 'V '
                              and t01.vkorg = '135'
                              and (t01.vtweg is null or t01.vtweg = '10')
                              and t01.kunag is null
                              and decode(t01.datab,null,'19000101','00000000','19000101',t01.datab) <= to_char(sysdate,'yyyymmdd')
                              and decode(t01.datbi,null,'19000101','00000000','19000101',t01.datbi) >= to_char(sysdate,'yyyymmdd')) t01,
                          (select t01.matnr,
                                  t01.ean11,
                                  t01.meins,
                                  t02.maktx,
                                  t03.vmsta
                             from lads_mat_hdr t01,
                                  (select matnr,
                                          decode(max(mkt_text),null,max(sls_text),max(mkt_text)) as maktx
                                     from (select t01.matnr,
                                                  t01.maktx as sls_text,
                                                  null as mkt_text
                                             from lads_mat_mkt t01
                                            where t01.spras_iso = 'EN'
                                            union all
                                           select t01.matnr,
                                                  null as sls_txt,
                                                  substr(max(t02.tdline),1,40) as mkt_text
                                             from lads_mat_txh t01,
                                                  lads_mat_txl t02
                                            where t01.matnr = t02.matnr(+)
                                              and t01.txhseq = t02.txhseq(+)
                                              and trim(substr(t01.tdname,19,6)) = '135 10'
                                              and t01.tdobject = 'MVKE'
                                              and t01.spras_iso = 'EN'
                                              and t02.txlseq = 1
                                            group by t01.matnr) t01
                                    group by t01.matnr) t02,
                                  (select t01.matnr as matnr,
                                          t01.vmstd as vmstd,
                                          t01.vmsta as vmsta
                                     from (select t01.matnr as matnr,
                                                  t01.sadseq as sadseq,
                                                  t01.vmstd as vmstd,
                                                  t01.vmsta as vmsta,
                                                  rank() over (partition by t01.matnr order by t01.vmstd desc, t01.sadseq desc) as rnkseq
                                             from lads_mat_sad t01
                                            where t01.vkorg = '135'
                                              and t01.vtweg = '10'
                                              and t01.lvorm is null
                                              and (t01.vmsta = '20' or t01.vmsta = '99')
                                              and decode(t01.vmstd,null,'19000101','00000000','19000101',t01.vmstd) <= to_char(sysdate,'yyyymmdd')) t01
                                    where t01.rnkseq = 1) t03
                            where t01.matnr = t02.matnr(+)
                              and t01.matnr = t03.matnr(+)
                              and t01.mtart = 'FERT') t02
                    where t01.smatn = t02.matnr
                      and t01.rnkseq = 1) t01,
                  --
                  -- Material TDU/UOM information
                  --
                  (select t01.matnr as matnr,
                          max(decode(t01.rnkseq,1,t01.umren)) tdu_count,
                          max(decode(t01.rnkseq,2,t01.umren)) mcu_count,
                          max(decode(t01.rnkseq,3,t01.umren)) rsu_count,
                          max(decode(t01.rnkseq,1,t01.meinh)) tdu_meinh,
                          max(decode(t01.rnkseq,2,t01.meinh)) mcu_meinh,
                          max(decode(t01.rnkseq,3,t01.meinh)) rsu_meinh,
                          max(decode(t01.rnkseq,1,t01.ean11)) tdu_ean11,
                          max(decode(t01.rnkseq,2,t01.ean11)) mcu_ean11,
                          max(decode(t01.rnkseq,3,t01.ean11)) rsu_ean11
                     from (select t01.matnr,
                                  t01.meinh,
                                  t01.umren,
                                  t01.umrez,
                                  t01.ean11,
                                  rank() over (partition by t01.matnr order by t01.umren asc, t01.uomseq desc) as rnkseq
                             from lads_mat_uom t01
                            where t01.meinh != 'EA'
                              and t01.umrez = 1) t01
                    group by t01.matnr) t02
            where t01.smatn = t02.matnr(+)) t02,
          --
          -- Material pricing information
          --
         (select t01.matnr as matnr,
                 t01.kmein as kmein,
                 ((t01.kbetr/t01.kpein)*nvl(t01.umrez,1))/nvl(t01.umren,1) as list_price
            from (select t01.*,
                         t02.umrez,
                         t02.umren
                    from (select t01.vakey,
                                 t01.kotabnr,
                                 t01.kschl,
                                 t01.vkorg,
                                 t01.vtweg,
                                 t01.spart,
                                 t01.datab,
                                 t01.datbi,
                                 t01.matnr,
                                 t02.kbetr,
                                 t02.konwa,
                                 t02.kpein,
                                 t02.kmein,
                                 rank() over (partition by t01.matnr order by t01.datab desc, t01.datbi asc) as rnkseq
                            from lads_prc_lst_hdr t01,
                                 lads_prc_lst_det t02
                           where t01.vakey = t02.vakey
                             and t01.kschl = t02.kschl
                             and t01.datab = t02.datab
                             and t01.knumh = t02.knumh
                             and t01.kschl = 'ZH00'
                             and t01.vkorg = '135'
                             and (t01.vtweg is null or t01.vtweg = '10')
                             and decode(t01.datab,null,'19000101','00000000','19000101',t01.datab) <= to_char(sysdate,'yyyymmdd')
                             and decode(t01.datbi,null,'19000101','00000000','19000101',t01.datbi) >= to_char(sysdate,'yyyymmdd')) t01,
                         lads_mat_uom t02
                   where t01.matnr = t02.matnr(+)
                     and t01.kmein = t02.meinh(+)
                     and t01.rnkseq = 1) t01) t03
    where t01.matnr = t02.matnr
      and t01.matnr = t03.matnr(+);

/*-*/
/* Authority
/*-*/
grant select on ics_app.efex_item_chn_view to ics_reader;
grant select on ics_app.efex_item_chn_view to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym efex_item_chn_view for ics_app.efex_item_chn_view;