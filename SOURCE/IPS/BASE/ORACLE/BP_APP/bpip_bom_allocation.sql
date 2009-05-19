create or replace function bpip_bom_allocation(par_company in varchar2, par_material in varchar2, par_date in varchar2, par_detail in varchar2 default '0') return bpip_allocation_table pipelined is

   /*-*/
   /* Local definitions
   /*-*/
   var_code varchar2(30);
   var_number number;
   var_date varchar2(8);
   var_date01 date;
   var_proportion number;
   var_result common.st_result;
   var_result_msg common.st_message_string;
   var_where_used recipe_functions.t_where_used;

   /*-*/
   /* Local cursors
   /*-*/
   cursor csr_bom_det is
      select t01.*,
             level as bom_hierarchy_level,
             substr(sys_connect_by_path(t01.cmpnt_matl_code,'/'),2,decode(instr(sys_connect_by_path(t01.cmpnt_matl_code,'/'),'/',2,1),0,length(sys_connect_by_path(t01.cmpnt_matl_code,'/')),instr(sys_connect_by_path(t01.cmpnt_matl_code,'/'),'/',2,1)-2)) as bom_hierarchy_root,
             substr(sys_connect_by_path(t01.cmpnt_matl_code,'/'),1,1024) as bom_hierarchy_path
        from (select t01.plant,
                     t01.matl_code,
                     t01.altv,
                     t01.cmpnt_matl_code,
                     t01.qty as cmpnt_qty,
                     t01.uom as cmpnt_uom,
                     t04.matl_type as cmpnt_matl_type,
                     t04.base_uom as cmpnt_base_uom,
                     t04.net_wght as cmpnt_net_wght,
                     t04.gross_wght as cmpnt_gross_wght,
                     t02.qty as bom_qty,
                     t02.uom as bom_uom,
                     t03.matl_type as bom_matl_type,
                     t03.trdd_unit as bom_trdd_unit,
                     t03.base_uom as bom_base_uom,
                     t03.net_wght as bom_net_wght,
                     t03.gross_wght as bom_gross_wght
                from bom_det t01,
                     bom_hdr t02,
                     matl t03,
                     matl t04,
                     plant t05
               where var_date between t01.valid_from and t01.valid_to
                 and recipe_functions.get_alternative (t01.plant, t01.matl_code, var_date) = t01.altv
                 and t01.plant = t02.plant
                 and t01.matl_code = t02.matl_code
                 and t01.altv = t02.altv
                 and t01.matl_code = t03.matl_code
                 and t01.cmpnt_matl_code = t04.matl_code
                 and t01.plant = t05.plant
                 and t05.sales_org = par_company) t01
       start with t01.cmpnt_matl_code = var_code
     connect by nocycle prior t01.matl_code = t01.cmpnt_matl_code
       order siblings by t01.matl_code asc;
      rcd_bom_det csr_bom_det%rowtype;

/*-------------*/
/* Begin block */
/*-------------*/
begin

   /*-*/
   /* Process the parameters
   /*-*/
   var_code := par_material;
   begin
      var_number := to_number(var_code);
      var_code := to_char(var_number,'fm000000000000000000000000000000');
      var_code := substr(var_code,18*-1,18);
   exception
      when others then
         null;
   end;
   var_date := par_date;
   if var_date is null then
      var_date := to_char(sysdate,'yyyymmdd');
   end if;
   var_date01 := to_date(var_date,'yyyymmdd');

   /*-*/
   /* Retrieve the current BOM allocation
   /*-*/
   var_result := recipe_functions.where_used(par_company,var_code,var_date01,true,var_where_used,var_result_msg);
  -- if var_result != common.gc_success THEN
  --    v_processing_msg := common.nest_err_msg (v_result_msg);
  --    RAISE common.ge_failure;
  -- end if;
   for idx in 1..var_where_used.count loop
      pipe row(bpip_allocation_object('**OLD_QTY**',
                                      var_where_used(idx).plant,
                                      var_where_used(idx).matl_code,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      var_where_used(idx).proportion,
                                      null,
                                      null,
                                      substr(var_where_used(idx).bom_path,1,1024)));
   end loop;

   /*-*/
   /* Retrieve the reverse BOM hierarchy - Quantity Based
   /*-*/
   var_proportion := 1;
   open csr_bom_det;
   loop
      fetch csr_bom_det into rcd_bom_det;
      if csr_bom_det%notfound then
         exit;
      end if;
      var_proportion := 1 * var_proportion;
      if rcd_bom_det.cmpnt_uom = rcd_bom_det.bom_uom and rcd_bom_det.cmpnt_uom = 'KGM' then
         var_proportion := (rcd_bom_det.cmpnt_qty / rcd_bom_det.bom_qty) * var_proportion;
      end if;
      if (rcd_bom_det.bom_matl_type = 'FERT' and rcd_bom_det.bom_trdd_unit = 'X') then
         pipe row(bpip_allocation_object('**NEW_QTY**',
                                         rcd_bom_det.plant,
                                         rcd_bom_det.matl_code,
                                         rcd_bom_det.altv,
                                         rcd_bom_det.bom_qty,
                                         rcd_bom_det.bom_uom,
                                         rcd_bom_det.bom_matl_type,
                                         rcd_bom_det.bom_trdd_unit,
                                         rcd_bom_det.bom_base_uom,
                                         rcd_bom_det.bom_net_wght,
                                         rcd_bom_det.bom_gross_wght,
                                         rcd_bom_det.cmpnt_matl_code,
                                         rcd_bom_det.cmpnt_qty,
                                         rcd_bom_det.cmpnt_uom,
                                         rcd_bom_det.cmpnt_matl_type,
                                         rcd_bom_det.cmpnt_base_uom,
                                         rcd_bom_det.cmpnt_net_wght,
                                         rcd_bom_det.cmpnt_gross_wght,
                                         var_proportion,
                                         rcd_bom_det.bom_hierarchy_level,
                                         rcd_bom_det.bom_hierarchy_root,
                                         rcd_bom_det.bom_hierarchy_path));
      else
         if par_detail = '1' then 
            pipe row(bpip_allocation_object('NEW_QTY',
                                            rcd_bom_det.plant,
                                            rcd_bom_det.matl_code,
                                            rcd_bom_det.altv,
                                            rcd_bom_det.bom_qty,
                                            rcd_bom_det.bom_uom,
                                            rcd_bom_det.bom_matl_type,
                                            rcd_bom_det.bom_trdd_unit,
                                            rcd_bom_det.bom_base_uom,
                                            rcd_bom_det.bom_net_wght,
                                            rcd_bom_det.bom_gross_wght,
                                            rcd_bom_det.cmpnt_matl_code,
                                            rcd_bom_det.cmpnt_qty,
                                            rcd_bom_det.cmpnt_uom,
                                            rcd_bom_det.cmpnt_matl_type,
                                            rcd_bom_det.cmpnt_base_uom,
                                            rcd_bom_det.cmpnt_net_wght,
                                            rcd_bom_det.cmpnt_gross_wght,
                                            var_proportion,
                                            rcd_bom_det.bom_hierarchy_level,
                                            rcd_bom_det.bom_hierarchy_root,
                                            rcd_bom_det.bom_hierarchy_path));
         end if;
      end if;
   end loop;
   close csr_bom_det;

   /*-*/
   /* Retrieve the reverse BOM hierarchy - Net Weight Based
   /*-*/
   var_proportion := 1;
   open csr_bom_det;
   loop
      fetch csr_bom_det into rcd_bom_det;
      if csr_bom_det%notfound then
         exit;
      end if;
      var_proportion := 1 * var_proportion;
      if rcd_bom_det.cmpnt_base_uom = rcd_bom_det.bom_base_uom then
         var_proportion := (rcd_bom_det.cmpnt_net_wght / rcd_bom_det.bom_net_wght) * var_proportion;
      end if;
      if (rcd_bom_det.bom_matl_type = 'FERT' and rcd_bom_det.bom_trdd_unit = 'X') then
         pipe row(bpip_allocation_object('**NEW_NET_WEIGHT**',
                                         rcd_bom_det.plant,
                                         rcd_bom_det.matl_code,
                                         rcd_bom_det.altv,
                                         rcd_bom_det.bom_qty,
                                         rcd_bom_det.bom_uom,
                                         rcd_bom_det.bom_matl_type,
                                         rcd_bom_det.bom_trdd_unit,
                                         rcd_bom_det.bom_base_uom,
                                         rcd_bom_det.bom_net_wght,
                                         rcd_bom_det.bom_gross_wght,
                                         rcd_bom_det.cmpnt_matl_code,
                                         rcd_bom_det.cmpnt_qty,
                                         rcd_bom_det.cmpnt_uom,
                                         rcd_bom_det.cmpnt_matl_type,
                                         rcd_bom_det.cmpnt_base_uom,
                                         rcd_bom_det.cmpnt_net_wght,
                                         rcd_bom_det.cmpnt_gross_wght,
                                         var_proportion,
                                         rcd_bom_det.bom_hierarchy_level,
                                         rcd_bom_det.bom_hierarchy_root,
                                         rcd_bom_det.bom_hierarchy_path));
      else
         if par_detail = '1' then 
            pipe row(bpip_allocation_object('NEW_NET_WEIGHT',
                                            rcd_bom_det.plant,
                                            rcd_bom_det.matl_code,
                                            rcd_bom_det.altv,
                                            rcd_bom_det.bom_qty,
                                            rcd_bom_det.bom_uom,
                                            rcd_bom_det.bom_matl_type,
                                            rcd_bom_det.bom_trdd_unit,
                                            rcd_bom_det.bom_base_uom,
                                            rcd_bom_det.bom_net_wght,
                                            rcd_bom_det.bom_gross_wght,
                                            rcd_bom_det.cmpnt_matl_code,
                                            rcd_bom_det.cmpnt_qty,
                                            rcd_bom_det.cmpnt_uom,
                                            rcd_bom_det.cmpnt_matl_type,
                                            rcd_bom_det.cmpnt_base_uom,
                                            rcd_bom_det.cmpnt_net_wght,
                                            rcd_bom_det.cmpnt_gross_wght,
                                            var_proportion,
                                            rcd_bom_det.bom_hierarchy_level,
                                            rcd_bom_det.bom_hierarchy_root,
                                            rcd_bom_det.bom_hierarchy_path));
         end if;
      end if;
   end loop;
   close csr_bom_det;

   /*-*/
   /* Return
   /*-*/
   return;

/*-------------*/
/* End routine */
/*-------------*/
end bpip_bom_allocation;
/

grant execute on bp_app.bpip_bom_allocation to public; 