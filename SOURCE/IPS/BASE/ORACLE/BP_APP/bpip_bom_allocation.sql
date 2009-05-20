create or replace package bpip_bom as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function allocation(par_company in varchar2, par_material in varchar2, par_date in varchar2, par_detail in varchar2 default '0') return bpip_allocation_table pipelined;

end bpip_bom;
/

/****************/
/* Package Body */
/****************/
create or replace package body bpip_bom as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************************/
   /* This procedure performs the performs the allocation routine */
   /***************************************************************/
   function allocation(par_company in varchar2, par_material in varchar2, par_date in varchar2, par_detail in varchar2 default '0') return bpip_allocation_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_comp varchar2(30 char);
      var_code varchar2(30 char);
      var_number number;
      var_date varchar2(8 char);
      var_date01 date;
      var_proportion number;
      var_result common.st_result;
      var_result_msg common.st_message_string;
      var_where_used recipe_functions.t_where_used;
      var_dynamic_sql varchar2(32767 char);
      type typCursor is ref cursor;
      csr_bom_det typCursor;
      type typ_bom_det is record(plant varchar2(4 char),
                                                         matl_code varchar2(18 char),
                                                         altv varchar2(2 char),
                                                         cmpnt_matl_code varchar2(18 char),
                                                         cmpnt_qty number,
                                                         cmpnt_uom varchar2(10 char),
                                                         cmpnt_matl_type varchar2(32 char),
                                                         cmpnt_base_uom varchar2(10 char),
                                                         cmpnt_net_wght number,
                                                         cmpnt_gross_wght number,
                                                         bom_qty number,
                                                         bom_uom varchar2(10 char),
                                                         bom_matl_type varchar2(10 char),
                                                         bom_trdd_unit varchar2(10 char),
                                                         bom_base_uom varchar2(10 char),
                                                         bom_net_wght number,
                                                         bom_gross_wght number,
                                                         bom_hierarchy_level number,
                                                         bom_hierarchy_root varchar2(1024 char),
                                                         bom_hierarchy_path varchar2(1024 char));
      rcd_bom_det typ_bom_det;

      /*-*/
      /* Local cursors
      /*-*/
    /*  cursor csr_bom_det is
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
                  where t01.valid_from <= '20090519'
                    and t01.valid_to >= '20090519'
                    and recipe_functions.get_alternative (t01.plant, t01.matl_code, '20090519') = t01.altv
                    and t01.plant = t02.plant
                    and t01.matl_code = t02.matl_code
                    and t01.altv = t02.altv
                    and t01.matl_code = t03.matl_code
                    and t01.cmpnt_matl_code = t04.matl_code
                    and t01.plant = t05.plant
                    and t05.sales_org = '147') t01
          start with t01.cmpnt_matl_code = '000000000001135242'
        connect by nocycle prior t01.matl_code = t01.cmpnt_matl_code;
         rcd_bom_det csr_bom_det%rowtype; */

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the parameters
      /*-*/
      var_comp := par_company;
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
      var_result := recipe_functions.where_used(var_comp,var_code,var_date01,true,var_where_used,var_result_msg);
      if var_result != common.gc_success then
         raise_application_error(-20000, var_result_msg);
      end if;
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

      var_dynamic_sql := 'select t01.*,
                level as bom_hierarchy_level,
                substr(sys_connect_by_path(t01.cmpnt_matl_code,''/''),2,decode(instr(sys_connect_by_path(t01.cmpnt_matl_code,''/''),''/'',2,1),0,length(sys_connect_by_path(t01.cmpnt_matl_code,''/'')),instr(sys_connect_by_path(t01.cmpnt_matl_code,''/''),''/'',2,1)-2)) as bom_hierarchy_root,
                substr(sys_connect_by_path(t01.cmpnt_matl_code,''/''),1,1024) as bom_hierarchy_path
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
                  where t01.valid_from <= '':DATE''
                    and t01.valid_to >= '':DATE''
                    and recipe_functions.get_alternative (t01.plant, t01.matl_code, '':DATE'') = t01.altv
                    and t01.plant = t02.plant
                    and t01.matl_code = t02.matl_code
                    and t01.altv = t02.altv
                    and t01.matl_code = t03.matl_code
                    and t01.cmpnt_matl_code = t04.matl_code
                    and t01.plant = t05.plant
                    and t05.sales_org = '':COMP'') t01
          start with t01.cmpnt_matl_code = '':CODE''
        connect by nocycle prior t01.matl_code = t01.cmpnt_matl_code
                           and (prior t01.bom_matl_type != ''FERT'' or
                                prior nvl(t01.bom_trdd_unit,''1'') != ''X'')';
      var_dynamic_sql := replace(var_dynamic_sql,':DATE',var_date);
      var_dynamic_sql := replace(var_dynamic_sql,':COMP',var_comp);
      var_dynamic_sql := replace(var_dynamic_sql,':CODE',var_code);

      /*-*/
      /* Retrieve the reverse BOM hierarchy - Quantity Based
      /*-*/
      var_proportion := 1;
      open csr_bom_det for var_dynamic_sql;
      loop
         fetch csr_bom_det into rcd_bom_det;
         if csr_bom_det%notfound then
            exit;
         end if;
         var_proportion := 1 * var_proportion;
         if rcd_bom_det.cmpnt_uom = rcd_bom_det.bom_uom and rcd_bom_det.cmpnt_uom = 'KGM' then
            var_proportion := (rcd_bom_det.cmpnt_qty / rcd_bom_det.bom_qty) * var_proportion;
         end if;
         if (rcd_bom_det.bom_matl_type = 'FERT' and nvl(rcd_bom_det.bom_trdd_unit,'1') = 'X') then
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
                                            round(var_proportion,9),
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
                                               round(var_proportion,9),
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
      open csr_bom_det for var_dynamic_sql;
      loop
         fetch csr_bom_det into rcd_bom_det;
         if csr_bom_det%notfound then
            exit;
         end if;
         var_proportion := 1 * var_proportion;
         if rcd_bom_det.cmpnt_base_uom = rcd_bom_det.bom_base_uom then
            var_proportion := (rcd_bom_det.cmpnt_net_wght / rcd_bom_det.bom_net_wght) * var_proportion;
         end if;
         if (rcd_bom_det.bom_matl_type = 'FERT' and nvl(rcd_bom_det.bom_trdd_unit,'1') = 'X') then
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
                                            round(var_proportion,9),
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
                                               round(var_proportion,9),
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
   end allocation;

end bpip_bom;
/

/******************/
/* Package Grants */
/******************/
grant execute on bp_app.bpip_bom to public;
/
