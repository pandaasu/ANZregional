/******************/
/* Package Header */
/******************/
create or replace package dw_utility as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_utility
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Utility Procedures and Functions

    This package contain utility procedures and functions. 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/11   Steve Gregan   Created
    2008/08   Steve Gregan   Modified to trim material codes (SAP order material code)

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure calculate_quantity;
   function convert_buom_to_uom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_buom in number) return number;
   function convert_uom_to_buom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_uom in number) return number;

   /*-*/
   /* Public definitions
   /*-*/
   type rcd_qty_fact is record(ods_matl_code varchar2(18 char),
                               uom_code varchar2(10 char),
                               uom_qty number,
                               base_uom_code varchar2(10 char),
                               qty_base_uom number,
                               qty_gross_tonnes number,
                               qty_net_tonnes number);
   pkg_qty_fact rcd_qty_fact;

end dw_utility;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_utility as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /************************************************************/
   /* This procedure performs the quantity calculation routine */
   /************************************************************/
   procedure calculate_quantity is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select t01.meins as mat_meins,
                t01.gewei as mat_gewei,
                nvl(t01.ntgew,0) as mat_ntgew,
                nvl(t01.brgew,0) as mat_brgew,
                nvl(t02.umren,1) as mat_umren,
                nvl(t02.umrez,1) as mat_umrez
           from sap_mat_hdr t01,
                (select t01.matnr,
                        t01.umren,
                        t01.umrez
                   from sap_mat_uom t01
                  where t01.matnr = pkg_qty_fact.ods_matl_code
                    and t01.meinh = pkg_qty_fact.uom_code) t02
          where t01.matnr = t02.matnr(+)
            and dw_trim_code(t01.matnr) = dw_trim_code(pkg_qty_fact.ods_matl_code);
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Calculate the quantity values from the material GRD data
      /*-*/
      pkg_qty_fact.qty_base_uom := pkg_qty_fact.uom_qty;
      pkg_qty_fact.qty_gross_tonnes := 0;
      pkg_qty_fact.qty_net_tonnes := 0;
      open csr_material;
      fetch csr_material into rcd_material;
      if csr_material%found then
         pkg_qty_fact.base_uom_code := rcd_material.mat_meins;
         pkg_qty_fact.qty_base_uom := (pkg_qty_fact.uom_qty * rcd_material.mat_umrez) / rcd_material.mat_umren;
         pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_base_uom * rcd_material.mat_brgew;
         pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_base_uom * rcd_material.mat_ntgew;
         case rcd_material.mat_gewei
            when 'KGM' then
               pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes / 1000;
               pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_net_tonnes / 1000;
            when 'GRM' then
               pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes / 1000000;
               pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_net_tonnes / 1000000;
            when 'MGM' then
               pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes / 1000000000;
               pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_net_tonnes / 1000000000;
         end case;
      end if;
      close csr_material;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end calculate_quantity;

   /****************************************************************/
   /* This procedure performs the quantity buom conversion routine */
   /****************************************************************/
   function convert_buom_to_uom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_buom in number) return number is

      /*-*/
      /* Local variables
      /*-*/
      var_result number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select nvl(t01.umren,1) as mat_umren,
                nvl(t01.umrez,1) as mat_umrez
           from sap_mat_uom t01
          where dw_trim_code(t01.matnr) = dw_trim_code(par_ods_matl_code)
            and t01.meinh = par_uom_code;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Convert the base uom quantity to the requested uom quantity
      /*-*/
      var_result := par_qty_buom;
      open csr_material;
      fetch csr_material into rcd_material;
      if csr_material%found then
         var_result := (par_qty_buom / rcd_material.mat_umrez) * rcd_material.mat_umren;
      end if;
      close csr_material;

      /*-*/
      /* Return the result
      /*-*/
      return var_result;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end convert_buom_to_uom;

   /***************************************************************/
   /* This procedure performs the quantity uom conversion routine */
   /***************************************************************/
   function convert_uom_to_buom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_uom in number) return number is

      /*-*/
      /* Local variables
      /*-*/
      var_result number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select nvl(t01.umren,1) as mat_umren,
                nvl(t01.umrez,1) as mat_umrez
           from sap_mat_uom t01
          where dw_trim_code(t01.matnr) = dw_trim_code(par_ods_matl_code)
            and t01.meinh = par_uom_code;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Convert the uom quantity to the base uom quantity
      /*-*/
      var_result := par_qty_uom;
      open csr_material;
      fetch csr_material into rcd_material;
      if csr_material%found then
         var_result := (par_qty_uom * rcd_material.mat_umrez) / rcd_material.mat_umren;
      end if;
      close csr_material;

      /*-*/
      /* Return the result
      /*-*/
      return var_result;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end convert_uom_to_buom;

end dw_utility;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_utility for dw_app.dw_utility;
grant execute on dw_utility to public;
