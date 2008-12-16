/******************/
/* Package Header */
/******************/
create or replace package pricelist_material as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pricelist_material
    Owner   : pr_app

    Description
    -----------
    Price List Generator - Rule Value Listing

    This package contain the procedures for the price list rule value listing.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list(par_report_id in number) return pricelist_value pipelined;

end pricelist_material;
/

/****************/
/* Package Body */
/****************/
create or replace package body pricelist_material as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /************************************************************/
   /* This procedure performs the report material list routine */
   /************************************************************/
   function list(par_report_id in number) return pricelist_value pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is 
         select t01.matl_code as matl_code,
                '('||ltrim(t01.matl_code,0)||') '||nvl(t02.matl_desc,'*UNKNOWN') as matl_desc
           from report_matl t01,
                matl t02
          where t01.matl_code = t02.matl_code(+)
            and t01.report_id = par_report_id
          order by t01.matl_code asc;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the material list
      /*-*/
      open csr_material;
      loop
         fetch csr_material into rcd_material;
         if csr_material%notfound then
            exit;
         end if;
         pipe row(pricelist_value_object(rcd_material.matl_code, rcd_material.matl_desc));
      end loop;
      close csr_material;

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
         raise_application_error(-20000, 'PRICELIST_MATERIAL - LIST - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list;

end pricelist_material;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_material for dw_app.pricelist_material;
grant execute on pricelist_material to public;
