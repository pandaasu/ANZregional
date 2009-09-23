
--create or replace type sales_bom_object as object
--   (sale_material_code           varchar2(32 char),
--    sale_buom_qty                number,
--    sale_buom_code               varchar2(32 char),
--    bom_sequence                 number,
--    bom_plant_code               varchar2(32 char),
--    fert_material_code           varchar2(32 char),
--    fert_qty                     number,
--    fert_uom                     varchar2(32 char),
--    item_material_code           varchar2(32 char),
--    item_qty                     number,
--    item_uom                     varchar2(32 char));
--/

--create or replace type sales_bom_table as table of sales_bom_object;
--/

create or replace function dw_sales_bom(par_company_code in varchar2,
                                        par_bus_sgmnt_code in varchar2,
                                        par_str_yyyymm in number,
                                        par_end_yyyymm in number,
                                        par_material_code in varchar2) return sales_bom_table pipelined is

   var_material_save varchar2(32);
   var_plant_save varchar2(32);
   var_level_save number;
   var_material_uom varchar2(32);
   var_base_uom varchar2(32);
   var_factor number;
   type typ_factor is table of number index by binary_integer;
   tbl_factor typ_factor;
   var_fert_index number;
   type rcd_fert is record(sale_code varchar2(32),
                           sale_qty number,
                           sale_uom varchar2(32),
                           plant_code varchar2(32),
                           fert_code varchar2(32),
                           fert_qty number,
                           fert_uom varchar2(32),
                           verp_code varchar2(32),
                           verp_qty number,
                           verp_uom varchar2(32),
                           roh_code varchar2(32),
                           roh_qty number,
                           roh_uom varchar2(32));
   type typ_fert is table of rcd_fert index by binary_integer;
   tbl_fert typ_fert;

   cursor csr_data is
      select t01.matl_code as sale_material_code,
             nvl(t02.matl_type_code,'*UNKNOWN') as sale_material_type,
             t01.billed_base_uom_code as sale_base_uom_code,
             round(t01.billed_qty_base_uom,3) as sale_qty_base_uom,
             t03.bom_hierarchy_rownum,
             t03.bom_hierarchy_level,
             t03.bom_hierarchy_path,
             t03.bom_material_code,
             nvl(t04.matl_type_code,'*UNKNOWN') as bom_material_type,
             t03.bom_alternative,
             t03.bom_plant,
             t03.bom_number,
             t03.bom_msg_function,
             t03.bom_usage,
             t03.bom_eff_from_date,
             t03.bom_eff_to_date,
             t03.bom_base_qty,
             t03.bom_base_uom,
             t03.bom_status,
             t03.item_sequence,
             t03.item_number,
             t03.item_msg_function,
             t03.item_material_code,
             nvl(t05.matl_type_code,'*UNKNOWN') as item_material_type,
             nvl(t05.matl_desc_en,'*UNKNOWN') as item_material_desc,
             t03.item_category,
             t03.item_base_qty,
             t03.item_base_uom,
             t03.item_eff_from_date,
             t03.item_eff_to_date
        from (select t01.matl_code,
                     t01.billed_base_uom_code,
                     sum(t01.billed_qty_base_uom) as billed_qty_base_uom
                from dw_sales_month01 t01,
                     demand_plng_grp_sales_area_dim t02,
                     cust_sales_area_dim t03
               where t01.ship_to_cust_code = t02.cust_code(+)
                 and t01.hdr_distbn_chnl_code = t02.distbn_chnl_code(+)
                 and t01.demand_plng_grp_division_code = t02.division_code(+)
                 and t01.hdr_sales_org_code = t02.sales_org_code(+)
                 and t01.sold_to_cust_code = t03.cust_code(+)
                 and t01.hdr_distbn_chnl_code = t03.distbn_chnl_code(+) 
                 and t01.hdr_division_code = t03.division_code(+) 
                 and t01.hdr_sales_org_code = t03.sales_org_code(+)
                 and t01.company_code = par_company_code
                 and (par_material_code is null or t01.matl_code = par_material_code)
                 and t01.billing_eff_yyyymm >= par_str_yyyymm
                 and t01.billing_eff_yyyymm <= par_end_yyyymm
                 and t03.acct_assgnmnt_grp_code = '01'
               group by t01.matl_code,
                        t01.billed_base_uom_code) t01,
             matl_dim t02,
             (select rownum as bom_hierarchy_rownum,
                     level as bom_hierarchy_level,
                     substr(sys_connect_by_path(t01.bom_material_code,'/'),2,decode(instr(sys_connect_by_path(t01.bom_material_code,'/'),'/',2,1),0,length(sys_connect_by_path(t01.bom_material_code,'/')),instr(sys_connect_by_path(t01.bom_material_code,'/'),'/',2,1)-2)) as bom_hierarchy_root,
                     sys_connect_by_path(t01.bom_material_code,'/') as bom_hierarchy_path,
                     t01.*
                from (select t01.bom_material_code,
                             t01.bom_alternative,
                             t01.bom_plant,
                             t01.bom_number,
                             t01.bom_msg_function,
                             t01.bom_usage,
                             t01.bom_eff_from_date,
                             t01.bom_eff_to_date,
                             t01.bom_base_qty,
                             t01.bom_base_uom,
                             t01.bom_status,
                             t01.item_sequence,
                             t01.item_number,
                             t01.item_msg_function,
                             t01.item_material_code,
                             t01.item_category,
                             t01.item_base_qty,
                             t01.item_base_uom,
                             t01.item_eff_from_date,
                             t01.item_eff_to_date
                        from (select t01.*,
                                     rank() over (partition by t01.bom_material_code,
                                                               t01.bom_plant
                                                      order by t01.bom_eff_from_date desc,
                                                               t01.bom_alternative desc) as rnkseq
                                from bds_bom_all@ap0064p.world t01
                               where trunc(t01.bom_eff_from_date) <= trunc(sysdate)) t01
                       where t01.rnkseq = 1
                         and t01.item_sequence != 0) t01
             connect by nocycle prior t01.item_material_code = t01.bom_material_code
               order siblings by to_number(t01.item_number)) t03,
             matl_dim t04,
             matl_dim t05
       where t01.matl_code = t02.matl_code(+)
         and t01.matl_code = t03.bom_hierarchy_root(+)
         and t03.bom_material_code = t04.matl_code(+)
         and t03.item_material_code = t05.matl_code(+)
         and t02.bus_sgmnt_code = par_bus_sgmnt_code
       order by t01.matl_code asc,
                t03.bom_hierarchy_rownum asc;
   rcd_data csr_data%rowtype;

   cursor csr_uom is
      select nvl(t01.umren,1) as mat_umren,
             nvl(t01.umrez,1) as mat_umrez
        from sap_mat_uom t01
       where t01.matnr = var_material_uom
         and t01.meinh = var_base_uom;
   rcd_uom csr_uom%rowtype;
                                                                                                                                                      
begin

      var_material_save := '**NONE**';
      var_plant_save := '**NONE**';
      var_level_save := 0;
      tbl_factor.delete;
      tbl_fert.delete;
      open csr_data;
      loop
         fetch csr_data into rcd_data;
         if csr_data%notfound then
            exit;
         end if;

         if rcd_data.sale_material_code != var_material_save then
            if var_material_save != '**NONE**' then
               for idx in 1..tbl_fert.count loop
                  if not(tbl_fert(idx).verp_code is null) and tbl_fert(idx).verp_code != '*FERT' then
                     pipe row(sales_bom_object(tbl_fert(idx).sale_code,
                                               tbl_fert(idx).sale_qty,
                                               tbl_fert(idx).sale_uom,
                                               idx,
                                               tbl_fert(idx).plant_code,
                                               tbl_fert(idx).fert_code,
                                               round(tbl_fert(idx).fert_qty,3),
                                               tbl_fert(idx).fert_uom,
                                               tbl_fert(idx).verp_code,
                                               round(tbl_fert(idx).verp_qty,3),
                                               tbl_fert(idx).verp_uom));
                  end if;
                  if not(tbl_fert(idx).roh_code is null) then
                     pipe row(sales_bom_object(tbl_fert(idx).sale_code,
                                               tbl_fert(idx).sale_qty,
                                               tbl_fert(idx).sale_uom,
                                               idx,
                                               tbl_fert(idx).plant_code,
                                               tbl_fert(idx).fert_code,
                                               round(tbl_fert(idx).fert_qty,3),
                                               tbl_fert(idx).fert_uom,
                                               tbl_fert(idx).roh_code,
                                               round(tbl_fert(idx).roh_qty,3),
                                               tbl_fert(idx).roh_uom));
                  end if;
               end loop;
            end if;
            var_material_save := rcd_data.sale_material_code;
            var_level_save := 0;
            tbl_factor.delete;
            tbl_fert.delete;
         end if;

         if not(rcd_data.bom_hierarchy_path is null) then

            var_factor := 1;
            if rcd_data.bom_hierarchy_level-1 > 0 then
               for idx in 1..rcd_data.bom_hierarchy_level-1 loop
                  var_factor := var_factor * tbl_factor(idx);
               end loop;
            end if;
            tbl_factor(rcd_data.bom_hierarchy_level) := rcd_data.item_base_qty / nvl(rcd_data.bom_base_qty,0);
            if rcd_data.item_base_uom != 'EA' then
               var_material_uom := dw_expand_code(rcd_data.item_material_code);
               var_base_uom := rcd_data.item_base_uom;
               open csr_uom;
               fetch csr_uom into rcd_uom;
               if csr_uom%found then
                  tbl_factor(rcd_data.bom_hierarchy_level) := ((rcd_data.item_base_qty * rcd_uom.mat_umrez) / rcd_uom.mat_umren) / nvl(rcd_data.bom_base_qty,0);
               end if;
               close csr_uom;
            end if;

            if rcd_data.bom_material_type = 'FERT' then

               var_fert_index := 0;
               for idx in 1..tbl_fert.count loop
                  if tbl_fert(idx).fert_code = rcd_data.bom_material_code then
                     if tbl_fert(idx).verp_code = '*FERT' then
                        var_fert_index := idx;
                        exit;
                     end if;
                  end if;
               end loop;

               if var_fert_index = 0 then
                  var_fert_index := tbl_fert.count + 1;
                  tbl_fert(var_fert_index).sale_code := rcd_data.sale_material_code;
                  tbl_fert(var_fert_index).sale_qty := rcd_data.sale_qty_base_uom;
                  tbl_fert(var_fert_index).sale_uom := rcd_data.sale_base_uom_code;
                  tbl_fert(var_fert_index).plant_code := rcd_data.bom_plant;
                  tbl_fert(var_fert_index).fert_code := rcd_data.bom_material_code;
                  tbl_fert(var_fert_index).fert_qty := rcd_data.bom_base_qty;
                  tbl_fert(var_fert_index).fert_uom := rcd_data.bom_base_uom;
                  tbl_fert(var_fert_index).verp_code := null;
                  tbl_fert(var_fert_index).verp_qty := 0;
                  tbl_fert(var_fert_index).verp_uom := null;
                  tbl_fert(var_fert_index).roh_code := null;
                  tbl_fert(var_fert_index).roh_qty := 0;
                  tbl_fert(var_fert_index).roh_uom := null;
               end if;

               if rcd_data.item_material_type = 'FERT' then
                  tbl_fert(var_fert_index).verp_code := '*FERT';
               end if;

               if rcd_data.item_material_type = 'VERP' then
                  if substr(rcd_data.item_material_desc,1,2) != 'PH' then
                     tbl_fert(var_fert_index).verp_code := rcd_data.item_material_code;
                     tbl_fert(var_fert_index).verp_qty := rcd_data.item_base_qty * var_factor;
                     tbl_fert(var_fert_index).verp_uom := rcd_data.item_base_uom;
                  end if;
               end if;

               if rcd_data.item_material_type = 'ROH' then
                  tbl_fert(var_fert_index).roh_code := rcd_data.item_material_code;
                  tbl_fert(var_fert_index).roh_qty := rcd_data.item_base_qty * var_factor;
                  tbl_fert(var_fert_index).roh_uom := rcd_data.item_base_uom;
               end if;

            end if;

            if rcd_data.bom_material_type = 'VERP' then

               if tbl_fert.exists(var_fert_index) then

                  if rcd_data.bom_hierarchy_level <= var_level_save then

                     var_fert_index := tbl_fert.count + 1;
                     tbl_fert(var_fert_index).sale_code := tbl_fert(var_fert_index-1).sale_code;
                     tbl_fert(var_fert_index).sale_qty := tbl_fert(var_fert_index-1).sale_qty;
                     tbl_fert(var_fert_index).sale_uom := tbl_fert(var_fert_index-1).sale_uom;
                     tbl_fert(var_fert_index).plant_code := tbl_fert(var_fert_index-1).plant_code;
                     tbl_fert(var_fert_index).fert_code := tbl_fert(var_fert_index-1).fert_code;
                     tbl_fert(var_fert_index).fert_qty := tbl_fert(var_fert_index-1).fert_qty;
                     tbl_fert(var_fert_index).fert_uom := tbl_fert(var_fert_index-1).fert_uom;
                     tbl_fert(var_fert_index).verp_code := null;
                     tbl_fert(var_fert_index).verp_qty := 0;
                     tbl_fert(var_fert_index).verp_uom := null;
                     tbl_fert(var_fert_index).roh_code := null;
                     tbl_fert(var_fert_index).roh_qty := 0;
                     tbl_fert(var_fert_index).roh_uom := null;

                  end if;

                  if rcd_data.item_material_type = 'VERP' then
                     if substr(rcd_data.item_material_desc,1,2) != 'PH' then
                        tbl_fert(var_fert_index).verp_code := rcd_data.item_material_code;
                        tbl_fert(var_fert_index).verp_qty := rcd_data.item_base_qty * var_factor;
                        tbl_fert(var_fert_index).verp_uom := rcd_data.item_base_uom;
                     end if;
                  end if;
                  if rcd_data.item_material_type = 'ROH' then
                     tbl_fert(var_fert_index).roh_code := rcd_data.item_material_code;
                     tbl_fert(var_fert_index).roh_qty := rcd_data.item_base_qty * var_factor;
                     tbl_fert(var_fert_index).roh_uom := rcd_data.item_base_uom;
                  end if;

               end if;

            end if;

            var_level_save := rcd_data.bom_hierarchy_level;

         end if;

   end loop;
   close csr_data;

   if var_material_save != '**NONE**' then
      for idx in 1..tbl_fert.count loop
         if not(tbl_fert(idx).verp_code is null) and tbl_fert(idx).verp_code != '*FERT' then
            pipe row(sales_bom_object(tbl_fert(idx).sale_code,
                                      tbl_fert(idx).sale_qty,
                                      tbl_fert(idx).sale_uom,
                                      idx,
                                      tbl_fert(idx).plant_code,
                                      tbl_fert(idx).fert_code,
                                      round(tbl_fert(idx).fert_qty,3),
                                      tbl_fert(idx).fert_uom,
                                      tbl_fert(idx).verp_code,
                                      round(tbl_fert(idx).verp_qty,3),
                                      tbl_fert(idx).verp_uom));
         end if;
         if not(tbl_fert(idx).roh_code is null) then
            pipe row(sales_bom_object(tbl_fert(idx).sale_code,
                                      tbl_fert(idx).sale_qty,
                                      tbl_fert(idx).sale_uom,
                                      idx,
                                      tbl_fert(idx).plant_code,
                                      tbl_fert(idx).fert_code,
                                      round(tbl_fert(idx).fert_qty,3),
                                      tbl_fert(idx).fert_uom,
                                      tbl_fert(idx).roh_code,
                                      round(tbl_fert(idx).roh_qty,3),
                                      tbl_fert(idx).roh_uom));
         end if;
      end loop;
   end if;

   return;

exception

   /**/
   /* Exception trap
   /**/
   when others then

      /*-*/
      /* Raise an exception to the calling application
      /*-*/
      raise_application_error(-20000, 'DW_SALES_BOM (' || nvl(par_material_code,'*ALL') || ') - ' || substr(SQLERRM, 1, 1024));

end dw_sales_bom;
/