create or replace package bds_bom as
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

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_dataset(par_eff_date in date, par_material_code in varchar2, par_plant_code in varchar2) return bds_bom_dataset pipelined;
   function get_hierarchy(par_eff_date in date, par_material_code in varchar2, par_plant_code in varchar2) return bds_bom_hierarchy pipelined;

end bds_bom;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_bom as

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
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_hdr.bom_eff_from_date%type;
      var_material_code bds_bom_hdr.bom_material_code%type;
      var_plant_code bds_bom_hdr.bom_plant%type;

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
      /* Retrieve the BOM header information and pipe to output
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
         raise_application_error(-20000, 'BDS_BOM - GET_DATASET (' || par_eff_date || ',' || nvl(par_material_code,'*ALL') || ',' || nvl(par_plant_code,'*ALL') || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_dataset;

   /*********************************************************/
   /* This procedure performs the get bom hierarchy routine */
   /*********************************************************/
   function get_hierarchy(par_eff_date in date, par_material_code in varchar2, par_plant_code in varchar2) return bds_bom_hierarchy pipelined is

      /*-*/
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_hdr.bom_eff_from_date%type;
      var_material_code bds_bom_hdr.bom_material_code%type;
      var_plant_code bds_bom_hdr.bom_plant%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_bom_hierarchy is
         select rownum as hierarchy_rownum,
                level as hierarchy_level,
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
                           from bds_bom_all t01
                          where trunc(t01.bom_eff_from_date) <= trunc(var_eff_date)) t01
                  where t01.rnkseq = 1
                    and t01.item_sequence != 0) t01
          start with t01.bom_material_code = var_material_code
                 and t01.bom_plant = var_plant_code
        connect by prior t01.item_material_code = t01.bom_material_code
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
      /* Retrieve the BOM header information and pipe to output
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
         raise_application_error(-20000, 'BDS_BOM - GET_HIERARCHY (' || par_eff_date || ',' || nvl(par_material_code,'NULL') || ',' || nvl(par_plant_code,'NULL') || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_hierarchy;

end bds_bom;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_bom for bds_app.bds_bom;
grant execute on bds_bom to public;
