/******************/
/* Package Header */
/******************/
create or replace package ladefx01_chn_item as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx01_chn_item
    Owner   : site_app

    Description
    -----------
    China Item Master Data - LADS to EFEX

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created
                           
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladefx01_chn_item;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx01_chn_item as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_item_master is
         select ltrim(t01.matnr,'0') as item_code,
                t01.maktx as item_name,
                ltrim(t01.zzrepmatnr,'0') as item_zrep_code,
                decode(t02.rsu_meinh,null,decode(t02.mcu_meinh,null,t02.tdu_ean11,t02.mcu_ean11),t02.rsu_ean11) as rsu_ean_code,
                decode(t02.rsu_meinh,null,0,t02.mcu_count) as cases_layer,
                0 as layers_pallet,
                decode(t02.rsu_meinh,null,decode(t02.mcu_meinh,null,t02.tdu_count,t02.mcu_count),t02.rsu_count) as units_case,
                t02.tdu_meinh as unit_measure,
                round(nvl(t03.list_price,0),2) as price1,
                0 as price2,
                0 as price3,
                0 as price4,
                0 as min_ord_qty,
                0 as order_multiples,
                t01.brand_flag_desc as brand,
                t01.brand_sub_flag_desc as sub_brand,
                to_char(nvl(t01.ntgew,0))||' '||t01.gewei as pack_size,
                t01.cnsmr_pack_frmt_desc as pack_type,
                t01.bus_sgmnt_desc as item_category,
                decode(t01.item_status,' ','A','X','X') as item_status
           from
                --
                -- Material information
                --
                (select t01.matnr as matnr,
                        t01.ean11 as ean11,
                        t01.meins as meins,
                        t01.ntgew as ntgew,
                        t01.gewei as gewei,
                        t01.zzrepmatnr as zzrepmatnr,
                        decode(t02.maktx,null,decode(t03.maktx,null,'*UNKNOWN'),t02.maktx) as maktx,
                        nvl(t05.bus_sgmnt_desc,'*UNKNOWN') as bus_sgmnt_desc,
                        nvl(t06.brand_flag_desc,'*UNKNOWN') as brand_flag_desc,
                        nvl(t07.brand_sub_flag_desc,'*UNKNOWN') as brand_sub_flag_desc,
                        nvl(t08.prdct_pack_size_desc,'*UNKNOWN') as prdct_pack_size_desc,
                        nvl(t09.cnsmr_pack_frmt_desc,'*UNKNOWN') as cnsmr_pack_frmt_desc,
                        decode(t10.vmsta,'20',' ','99','X') as item_status
                   from lads_mat_hdr t01,
                        (select t01.matnr,
                                max(t01.maktx) as maktx
                           from lads_mat_mkt t01
                          where t01.spras_iso = 'ZH'
                          group by t01.matnr) t02,
                        (select t01.matnr,
                                max(t01.maktx) as maktx
                           from lads_mat_mkt t01
                          where t01.spras_iso = 'EN'
                          group by t01.matnr) t03,
                        (select t31.objek as matnr,
                                nvl(max(case when t32.atnam = 'CLFFERT01' then t32.atwrt end),'00') as sap_bus_sgmnt_code,
                                nvl(max(case when t32.atnam = 'CLFFERT03' then t32.atwrt end),'000') as sap_brand_flag_code,
                                nvl(max(case when t32.atnam = 'CLFFERT04' then t32.atwrt end),'000') as sap_brand_sub_flag_code,
                                nvl(max(case when t32.atnam = 'CLFFERT14' then t32.atwrt end),'000') as sap_prdct_pack_size_code,
                                nvl(max(case when t32.atnam = 'CLFFERT25' then t32.atwrt end),'000') as sap_cnsmr_pack_frmt_code
                           from lads_cla_hdr t31,
                                lads_cla_chr t32
                          where t31.obtab = 'MARA'
                            and t31.klart = '001'
                            and t31.obtab = t32.obtab(+)
                            and t31.klart = t32.klart(+)
                            and t31.objek = t32.objek(+)
                          group by t31.objek) t04,
                        (select substr(t01.z_data,4,2) as sap_bus_sgmnt_code,
                                substr(t01.z_data,18,30) as bus_sgmnt_desc
                           from lads_ref_dat t01
                          where t01.z_tabname = '/MARS/MD_CHC001') t05,
                        (select substr(t01.z_data,4,3) as sap_brand_flag_code,
                                substr(t01.z_data,19,30) as brand_flag_desc
                           from lads_ref_dat t01
                          where t01.z_tabname = '/MARS/MD_CHC003') t06,
                        (select substr(t01.z_data,4,3) as sap_brand_sub_flag_code,
                                substr(t01.z_data,19,30) as brand_sub_flag_desc
                           from lads_ref_dat t01
                          where t01.z_tabname = '/MARS/MD_CHC004') t07,
                        (select substr(t01.z_data,4,3) as sap_prdct_pack_size_code,
                                substr(t01.z_data,19,30) as prdct_pack_size_desc
                           from lads_ref_dat t01
                          where t01.z_tabname = '/MARS/MD_CHC014') t08,
                        (select substr(t01.z_data,4,2) as sap_cnsmr_pack_frmt_code,
                                substr(t01.z_data,18,30) as cnsmr_pack_frmt_desc
                           from lads_ref_dat t01
                          where t01.z_tabname = '/MARS/MD_CHC025') t09,
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
                          where t01.rnkseq = 1) t10
                  where t01.matnr = t02.matnr(+)
                    and t01.matnr = t03.matnr(+)
                    and t01.matnr = t04.matnr(+)
                    and t04.sap_bus_sgmnt_code = t05.sap_bus_sgmnt_code(+)
                    and t04.sap_brand_flag_code = t06.sap_brand_flag_code(+)
                    and t04.sap_brand_sub_flag_code = t07.sap_brand_sub_flag_code(+)
                    and t04.sap_prdct_pack_size_code = t08.sap_prdct_pack_size_code(+)
                    and t04.sap_cnsmr_pack_frmt_code = t09.sap_cnsmr_pack_frmt_code(+)
                    and t01.matnr = t10.matnr
                    and t01.mtart = 'FERT'
                    and t01.zzistdu = 'X'
                    and t01.lvorm is null
                    and t01.lads_status = '1') t01,
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
                  group by t01.matnr) t02,
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
                                   and t01.kschl = 'PR00'
                                   and t01.vkorg = '135'
                                   and (t01.vtweg is null or t01.vtweg = '10')
                                   and decode(t01.datab,null,'19000101','00000000','19000101',t01.datab) <= to_char(sysdate,'yyyymmdd')
                                   and decode(t01.datbi,null,'19000101','00000000','19000101',t01.datbi) >= to_char(sysdate,'yyyymmdd')) t01,
                               lads_mat_uom t02
                         where t01.matnr = t02.matnr(+)
                           and t01.kmein = t02.meinh(+)
                           and t01.rnkseq = 1) t01) t03
          where t01.matnr = t02.matnr(+)
            and t01.matnr = t03.matnr(+);
      rcd_item_master csr_item_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_item_master;
      loop
         fetch csr_item_master into rcd_item_master;
         if csr_item_master%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADEFX01',null,'LADEFX01.dat');
            lics_outbound_loader.append_data('CTL');
            var_start := false;
         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          to_char(nvl(con_market_id,0))||rpad(' ',10-length(to_char(nvl(con_market_id,0))),' ') ||
                                          nvl(rcd_item_master.item_code,' ')||rpad(' ',18-length(nvl(rcd_item_master.item_code,' ')),' ') ||
                                          nvl(rcd_item_master.item_name,' ')||rpad(' ',40-length(nvl(rcd_item_master.item_name,' ')),' ') ||
                                          nvl(rcd_item_master.item_zrep_code,' ')||rpad(' ',18-length(nvl(rcd_item_master.item_zrep_code,' ')),' ') ||
                                          nvl(rcd_item_master.rsu_ean_code,' ')||rpad(' ',18-length(nvl(rcd_item_master.rsu_ean_code,' ')),' ') ||
                                          to_char(nvl(rcd_item_master.cases_layer,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.cases_layer,0))),' ') ||
                                          to_char(nvl(rcd_item_master.layers_pallet,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.layers_pallet,0))),' ') ||
                                          to_char(nvl(rcd_item_master.units_case,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.units_case,0))),' ') ||
                                          nvl(rcd_item_master.unit_measure,' ')||rpad(' ',3-length(nvl(rcd_item_master.unit_measure,' ')),' ') ||
                                          to_char(nvl(rcd_item_master.price1,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.price1,0))),' ') ||
                                          to_char(nvl(rcd_item_master.price2,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.price2,0))),' ') ||
                                          to_char(nvl(rcd_item_master.price3,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.price3,0))),' ') ||
                                          to_char(nvl(rcd_item_master.price4,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.price4,0))),' ') ||
                                          to_char(nvl(rcd_item_master.min_ord_qty,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.min_ord_qty,0))),' ') ||
                                          to_char(nvl(rcd_item_master.order_multiples,0))||rpad(' ',20-length(to_char(nvl(rcd_item_master.order_multiples,0))),' ') ||
                                          nvl(rcd_item_master.brand,' ')||rpad(' ',30-length(nvl(rcd_item_master.brand,' ')),' ') ||
                                          nvl(rcd_item_master.sub_brand,' ')||rpad(' ',30-length(nvl(rcd_item_master.sub_brand,' ')),' ') || 
                                          nvl(rcd_item_master.pack_size,' ')||rpad(' ',30-length(nvl(rcd_item_master.pack_size,' ')),' ') ||
                                          nvl(rcd_item_master.pack_type,' ')||rpad(' ',30-length(nvl(rcd_item_master.pack_type,' ')),' ') ||
                                          nvl(rcd_item_master.item_category,' ')||rpad(' ',30-length(nvl(rcd_item_master.item_category,' ')),' ') ||
                                          nvl(rcd_item_master.item_status,' ')||rpad(' ',1-length(nvl(rcd_item_master.item_status,' ')),' '));

      end loop;
      close csr_item_master;

      /*-*/
      /* Finalise Interface
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADEFX01 CHINA ITEM - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladefx01_chn_item;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx01_chn_item for site_app.ladefx01_chn_item;
grant execute on ladefx01_chn_item to public;
