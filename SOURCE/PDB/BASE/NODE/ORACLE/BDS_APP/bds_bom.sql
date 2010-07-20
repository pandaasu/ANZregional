CREATE OR REPLACE PACKAGE BDS_APP.bds_bom as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_bom
 Owner   : BDS_APP
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - BOM Functions

 ***********************************************************************************
 NOTE: this package should be kept in sync with the version on AP0064P under BDS_APP
 ***********************************************************************************
 
  
 FUNCTION : GET_DATASET This function retrieves the factory BOM dataset for the requested parameters.
                         - The effective date parameter defaults to sysdate when null.
                         - The material code parameter defaults to all materials when null.
                         - The plant code parameter defaults to all plant when null.
                         - The function should be used as follows:
                              select * from table(bds_bom.get_dataset(date,'material_code','plant_code')).

 FUNCTION : GET_HIERARCHY This function retrieves the factory BOM hierarchy for the requested parameters.
                           - The effective date parameter defaults to sysdate when null.
                           - The material code parameter must be supplied.
                           - The plant code parameter must be supplied.
                           - The function should be used as follows:
                              select * from table(bds_bom.get_hierarchy(date,'material_code','plant_code')).
                              
FUNCTION : GET_HIERARCHY_REVERSE This function retrieves the factory BOM dataset of parents for the requested parameters.
                           - it reverses and goes upwards through the tree
                           - The effective date parameter defaults to sysdate when null.
                           - The child material code parameter must be supplied.
                           - The plant code parameter must be supplied.
                           - The function should be used as follows:
                              select * from table(bds_bom.get_hierarchy_reverse(date,'material_code','plant_code')).

FUNCTION : GET_COMPONENT_QTY This function retrieves the factory BOM for the requested parameters
                             with component quantity of materials based on top level bom quantity of 1
                           - The assembly scrap value is used to modify the component quantity to all
                             levels within the assembly ie until the heirarch level return to the same value again
                           - The effective date parameter defaults to sysdate when null.
                           - The child material code parameter must be supplied.
                           - The plant code parameter must be supplied.
                           - The function should be used as follows:
                              select * from table(bds_bom.get_component_qty(date,'material_code','plant_code')).

                              
                              
 dd-mmm-YYYY   Author          Description
 -----------   ------          -----------
 01-Mar-2007   Steve Gregan    Created
 01-Mar-2007   Jeff Phillipson added get_hierarchy_reverse
 01-Jun-2007   Jeff Phillipson added get_comonent_qty
 02-Nov-2007   JP              added '<' to the next statement to reset scrap if the hierarchy level drops 
 29-Apr-2009   Trevor Keon     Changed var_scale rounding to 12 places to avoid returning 0
        
*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_dataset (
      par_eff_date        in   date,
      par_material_code   in   varchar2,
      par_plant_code      in   varchar2
   )
      return bds_bom_dataset pipelined;

   function get_hierarchy (
      par_eff_date        in   date,
      par_material_code   in   varchar2,
      par_plant_code      in   varchar2
   )
      return bds_bom_hierarchy pipelined;
      
   function get_hierarchy_reverse (
      par_eff_date        in   date,
      par_material_code   in   varchar2,
      par_plant_code      in   varchar2
   )
      return bds_bom_dataset pipelined;
   
   function get_component_qty (
      par_eff_date        in   date,
      par_material_code   in   varchar2,
      par_plant_code      in   varchar2
   )
      return bds_bom_component_qty pipelined;
        
end bds_bom;
/


CREATE PUBLIC SYNONYM BDS_BOM FOR BDS_APP.BDS_BOM;


GRANT EXECUTE ON BDS_APP.BDS_BOM TO APPSUPPORT;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO MANU WITH GRANT OPTION;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO MANU_APP WITH GRANT OPTION;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO PKGSPEC WITH GRANT OPTION;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO PKGSPEC_APP WITH GRANT OPTION;


CREATE OR REPLACE PACKAGE BODY BDS_APP.bds_bom as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*******************************************************/
   /* This procedure performs the get bom dataset routine */
   /*******************************************************/
   function get_dataset(par_eff_date in date, par_material_code in varchar2, par_plant_code in varchar2) return bds_bom_dataset pipelined is

      /*-*/
      /* Declare variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%type;
      var_material_code bds_bom_all.bom_material_code%type;
      var_plant_code bds_bom_all.bom_plant%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_bom_dataset is
         select t01.bom_material_code,
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
                   from bds_bom_all t01
                  where trunc(t01.bom_eff_from_date) <= trunc(var_eff_date)
                    and (var_material_code is null or t01.bom_material_code = var_material_code)
                    and (var_plant_code is null or t01.bom_plant = var_plant_code)) t01
          where t01.rnkseq = 1
            and t01.item_sequence != 0;
      rcd_bom_dataset csr_bom_dataset%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      if par_eff_date is null then
         var_eff_date := sysdate;
      end if;
      var_material_code := par_material_code;
      var_plant_code := par_plant_code;

      /*-*/
      /* Retrieve the bom header information and pipe to output
      /*-*/
      open csr_bom_dataset;
      loop
         fetch csr_bom_dataset into rcd_bom_dataset;
         if csr_bom_dataset%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe row(bds_bom_dataset_object(rcd_bom_dataset.bom_material_code,
                                         rcd_bom_dataset.bom_alternative,
                                         rcd_bom_dataset.bom_plant,
                                         rcd_bom_dataset.bom_number,
                                         rcd_bom_dataset.bom_msg_function,
                                         rcd_bom_dataset.bom_usage,
                                         rcd_bom_dataset.bom_eff_from_date,
                                         rcd_bom_dataset.bom_eff_to_date,
                                         rcd_bom_dataset.bom_base_qty,
                                         rcd_bom_dataset.bom_base_uom,
                                         rcd_bom_dataset.bom_status,
                                         rcd_bom_dataset.item_sequence,
                                         rcd_bom_dataset.item_number,
                                         rcd_bom_dataset.item_msg_function,
                                         rcd_bom_dataset.item_material_code,
                                         rcd_bom_dataset.item_category,
                                         rcd_bom_dataset.item_base_qty,
                                         rcd_bom_dataset.item_base_uom,
                                         rcd_bom_dataset.item_eff_from_date,
                                         rcd_bom_dataset.item_eff_to_date));

      end loop;
      close csr_bom_dataset;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_BOM - GET_DATASET (' || par_eff_date || ',' || nvl(par_material_code,'*ALL') || ',' || nvl(par_plant_code,'*ALL') || ') - ' || substr(sqlerrm, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_dataset;

   /*********************************************************/
   /* this procedure performs the get bom hierarchy routine */
   /*********************************************************/
   function get_hierarchy(par_eff_date in date, par_material_code in varchar2, par_plant_code in varchar2) return bds_bom_hierarchy pipelined is

      /*-*/
      /* Declare variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%type;
      var_material_code bds_bom_all.bom_material_code%type;
      var_plant_code bds_bom_all.bom_plant%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_bom_hierarchy is
         select rownum as hierarchy_rownum,
                level as hierarchy_level,
                t01.*, 
                connect_by_iscycle as cycle 
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
                           from bds_bom_all t01
                          where trunc(t01.bom_eff_from_date) <= trunc(var_eff_date)) t01
                  where t01.rnkseq = 1
                    and t01.item_sequence != 0) t01
          start with t01.bom_material_code = var_material_code
                 and t01.bom_plant = var_plant_code
        connect by nocycle prior t01.item_material_code = t01.bom_material_code
          order siblings by to_number(t01.item_number);
          
      rcd_bom_hierarchy csr_bom_hierarchy%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      if par_eff_date is null then
         var_eff_date := sysdate;
      end if;
      var_material_code := par_material_code;
      if par_material_code is null then
         raise_application_error(-20000, 'Hierarchy material code must be supplied');
      end if;
      var_plant_code := par_plant_code;
      if par_plant_code is null then
         raise_application_error(-20000, 'Hierarchy plant code must be supplied');
      end if;

      /*-*/
      /* Retrieve the bom header information and pipe to output
      /*-*/
      open csr_bom_hierarchy;
      loop
         fetch csr_bom_hierarchy into rcd_bom_hierarchy;
         if csr_bom_hierarchy%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe row(bds_bom_hierarchy_object(rcd_bom_hierarchy.hierarchy_rownum,
                                           rcd_bom_hierarchy.hierarchy_level,
                                           rcd_bom_hierarchy.bom_material_code,
                                           rcd_bom_hierarchy.bom_alternative,
                                           rcd_bom_hierarchy.bom_plant,
                                           rcd_bom_hierarchy.bom_number,
                                           rcd_bom_hierarchy.bom_msg_function,
                                           rcd_bom_hierarchy.bom_usage,
                                           rcd_bom_hierarchy.bom_eff_from_date,
                                           rcd_bom_hierarchy.bom_eff_to_date,
                                           rcd_bom_hierarchy.bom_base_qty,
                                           rcd_bom_hierarchy.bom_base_uom,
                                           rcd_bom_hierarchy.bom_status,
                                           rcd_bom_hierarchy.item_sequence,
                                           rcd_bom_hierarchy.item_number,
                                           rcd_bom_hierarchy.item_msg_function,
                                           rcd_bom_hierarchy.item_material_code,
                                           rcd_bom_hierarchy.item_category,
                                           rcd_bom_hierarchy.item_base_qty,
                                           rcd_bom_hierarchy.item_base_uom,
                                           rcd_bom_hierarchy.item_eff_from_date,
                                           rcd_bom_hierarchy.item_eff_to_date));

      end loop;
      close csr_bom_hierarchy;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_BOM - GET_HIERARCHY (' || par_eff_date || ',' || nvl(par_material_code,'NULL') || ',' || nvl(par_plant_code,'NULL') || ') - ' || substr(sqlerrm, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_hierarchy;
   
   
   /*******************************************************/
   /* This procedure performs the get bom hierarchy       */
   /* upwards                                             */
   /*******************************************************/
   function get_hierarchy_reverse(par_eff_date in date, par_material_code in varchar2, 
                                          par_plant_code in varchar2) return bds_bom_dataset pipelined is

      /*-*/
      /* Declare variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%type;
      var_material_code bds_bom_all.item_material_code%type;
      var_plant_code bds_bom_all.bom_plant%type;
      var_bom_number bds_bom_all.bom_number%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_bom_parents is
          select rownum as hierarchy_rownum,
                level as hierarchy_level,
                t01.*, 
                connect_by_iscycle as cycle 
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
                           from bds_bom_all t01
                          where trunc(t01.bom_eff_from_date) <= trunc(par_eff_date)) t01
                  where t01.rnkseq = 1
                    and t01.item_sequence != 0) t01
          start with t01.item_material_code = var_material_code
                 and t01.bom_plant = var_plant_code 
        connect by nocycle prior t01.bom_material_code = t01.item_material_code
         order siblings by to_number(t01.bom_material_code);
      rcd_bom_parents csr_bom_parents%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      if par_eff_date is null then
         var_eff_date := sysdate;
      end if;
      var_material_code := par_material_code;
      var_plant_code := par_plant_code;

      /*-*/
      /* Retrieve the bom header information and pipe to output
      /*-*/
      open csr_bom_parents;
      loop
         fetch csr_bom_parents into rcd_bom_parents;
         if csr_bom_parents%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe row(bds_bom_dataset_object(rcd_bom_parents.bom_material_code,
                                         rcd_bom_parents.bom_alternative,
                                         rcd_bom_parents.bom_plant,
                                         rcd_bom_parents.bom_number,
                                         rcd_bom_parents.bom_msg_function,
                                         rcd_bom_parents.bom_usage,
                                         rcd_bom_parents.bom_eff_from_date,
                                         rcd_bom_parents.bom_eff_to_date,
                                         rcd_bom_parents.bom_base_qty,
                                         rcd_bom_parents.bom_base_uom,
                                         rcd_bom_parents.bom_status,
                                         rcd_bom_parents.item_sequence,
                                         rcd_bom_parents.item_number,
                                         rcd_bom_parents.item_msg_function,
                                         rcd_bom_parents.item_material_code,
                                         rcd_bom_parents.item_category,
                                         rcd_bom_parents.item_base_qty,
                                         rcd_bom_parents.item_base_uom,
                                         rcd_bom_parents.item_eff_from_date,
                                         rcd_bom_parents.item_eff_to_date));

      end loop;
      close csr_bom_parents;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_BOM - get_hierarchy_up (' || par_eff_date || ',' || nvl(par_material_code,'*ALL') || ',' || nvl(par_plant_code,'*ALL') || ') - ' || substr(sqlerrm, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_hierarchy_reverse;
   
   

   /*********************************************************/
   /* This procedure performs the get component quantity routine */
   /*********************************************************/
   function get_component_qty(par_eff_date in date, par_material_code in varchar2, par_plant_code in varchar2) return bds_bom_component_qty pipelined is

      /*-*/
      /* Declare variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%type;
      var_material_code bds_bom_all.bom_material_code%type;
      var_plant_code bds_bom_all.bom_plant%type;
      var_scale bds_bom_all.bom_base_qty%type;
      var_bom_qty bds_bom_all.bom_base_qty%type;
      var_count number default 0;
      var_assembly_scrap_percntg bds_material_plant_mfanz.assembly_scrap_percntg%type;
      var_scrap_hierarchy_level number;
      
      type id_table_object is table of number index by binary_integer;
      id_table id_table_object;
      
      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_bom_hierarchy is
        select t01.*,
          case
            when t02.assembly_scrap_percntg is null then 0
            when t02.assembly_scrap_percntg = '' then 0
            when t02.assembly_scrap_percntg = 0 then 0
            else t02.assembly_scrap_percntg
          end assembly_scrap_percntg,
          case
            when t01.item_base_uom = 'PCE' then t02.bds_pce_factor_from_base_uom
            else 1
          end factor_from_base_uom    
        from 
          (
            select rownum as hierarchy_rownum,
              level as hierarchy_level,
              t01.*, 
              connect_by_iscycle as cycle from 
                (
                  select t01.bom_material_code,
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
                  from 
                    (
                      select t01.*,
                        rank() over (partition by t01.bom_material_code, t01.bom_plant order by t01.bom_eff_from_date desc, t01.bom_alternative desc) as rnkseq
                      from bds_bom_all t01
                      where trunc(t01.bom_eff_from_date) <= trunc(var_eff_date)
                    ) t01
                  where t01.rnkseq = 1
                    and t01.item_sequence != 0
                    and t01.bom_plant = var_plant_code
                ) t01
              start with t01.bom_material_code = var_material_code
                and t01.bom_plant = var_plant_code
              connect by nocycle prior t01.item_material_code = t01.bom_material_code
              order siblings by to_number(t01.item_number)
            ) t01,
            (
              select assembly_scrap_percntg, 
                sap_material_code, 
                plant_code,
                bds_pce_factor_from_base_uom 
              from bds_material_plant_mfanz
            ) t02
          where t01.item_material_code = ltrim(t02.sap_material_code(+),'0')
            and t01.bom_plant = t02.plant_code(+)
          order by 1;
          
      rcd_bom_hierarchy csr_bom_hierarchy%rowtype;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      if par_eff_date is null then
         var_eff_date := sysdate;
      end if;
      
      var_material_code := par_material_code;
      
      if par_material_code is null then
         raise_application_error(-20000, 'Hierarchy material code must be supplied');
      end if;
      
      var_plant_code := par_plant_code;
      
      if par_plant_code is null then
         raise_application_error(-20000, 'Hierarchy plant code must be supplied');
      end if;
      
      var_assembly_scrap_percntg := 0;
      var_scrap_hierarchy_level := 0;
      
      id_table.delete;
      
      /*-*/
      /* Retrieve the BOM header information and pipe to output
      /*-*/
      open csr_bom_hierarchy;
      loop
         fetch csr_bom_hierarchy into rcd_bom_hierarchy;
         if csr_bom_hierarchy%notfound then
            exit;
         end if;
         
         if var_count = 0 then
            var_bom_qty := rcd_bom_hierarchy.bom_base_qty;
            var_count := 1;
         end if;
         
         /*-*/
         /* save each levels bo qty
         /*-*/
         id_table(rcd_bom_hierarchy.hierarchy_level) := (rcd_bom_hierarchy.item_base_qty / rcd_bom_hierarchy.factor_from_base_uom) 
                                                        / rcd_bom_hierarchy.bom_base_qty;
         /*-*/
         /* convert bom ratio
         /*-*/
         var_scale := 1;
         for i in 1 .. rcd_bom_hierarchy.hierarchy_level
            loop
            var_scale :=  var_scale * id_table(i);
         end loop;
         --var_scale := var_scale; --* var_bom_qty;
         /*-*/
         /* add losses to values
         /*-*/
         /* 2-Nov-2007 JP added '<' to the next statement to reset scrap if the hierarchy level drops */
         if var_scrap_hierarchy_level <= rcd_bom_hierarchy.hierarchy_level then
            var_assembly_scrap_percntg := 0;
         end if;
         if rcd_bom_hierarchy.assembly_scrap_percntg <> 0 then
            var_assembly_scrap_percntg := rcd_bom_hierarchy.assembly_scrap_percntg;
            var_scrap_hierarchy_level := rcd_bom_hierarchy.hierarchy_level;
         end if;
         
         var_scale := var_scale * (1 +  var_assembly_scrap_percntg/100);
         
         if rcd_bom_hierarchy.item_material_code = '1104205' or rcd_bom_hierarchy.item_material_code = '1104209' then
            dbms_output.put_line('Scale:' || var_scale || '-' || rcd_bom_hierarchy.hierarchy_level);
         end if;
         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe row(bds_bom_component_qty_object(rcd_bom_hierarchy.hierarchy_rownum,
                                           rcd_bom_hierarchy.hierarchy_level,
                                           rcd_bom_hierarchy.bom_material_code,
                                           rcd_bom_hierarchy.bom_alternative,
                                           rcd_bom_hierarchy.bom_plant,
                                           rcd_bom_hierarchy.bom_number,
                                           rcd_bom_hierarchy.bom_msg_function,
                                           rcd_bom_hierarchy.bom_usage,
                                           rcd_bom_hierarchy.bom_eff_from_date,
                                           rcd_bom_hierarchy.bom_eff_to_date,
                                           rcd_bom_hierarchy.bom_base_qty,
                                           rcd_bom_hierarchy.bom_base_uom,
                                           rcd_bom_hierarchy.bom_status,
                                           rcd_bom_hierarchy.item_sequence,
                                           rcd_bom_hierarchy.item_number,
                                           rcd_bom_hierarchy.item_msg_function,
                                           rcd_bom_hierarchy.item_material_code,
                                           rcd_bom_hierarchy.item_category,
                                           rcd_bom_hierarchy.item_base_qty,
                                           rcd_bom_hierarchy.item_base_uom,
                                           rcd_bom_hierarchy.item_eff_from_date,
                                           rcd_bom_hierarchy.item_eff_to_date,
                                           round(var_scale,12)));
      end loop;
      close csr_bom_hierarchy;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_BOM - GET_HIERARCHY (' || par_eff_date || ',' || nvl(par_material_code,'NULL') || ',' || nvl(par_plant_code,'NULL') || ') - ' || substr(sqlerrm, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_component_qty;

end bds_bom;
/


CREATE PUBLIC SYNONYM BDS_BOM FOR BDS_APP.BDS_BOM;


GRANT EXECUTE ON BDS_APP.BDS_BOM TO APPSUPPORT;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO MANU WITH GRANT OPTION;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO MANU_APP WITH GRANT OPTION;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO PKGSPEC WITH GRANT OPTION;

GRANT EXECUTE ON BDS_APP.BDS_BOM TO PKGSPEC_APP WITH GRANT OPTION;
