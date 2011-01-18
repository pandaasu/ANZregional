/******************/
/* Package Header */
/******************/
create or replace package pricelist_exclusion as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pricelist_exclusion
    Owner   : pr_app

    Description
    -----------
    Price List Generator - Material Exclusion Listing

    This package contain the procedures for the price list material exclusion listing.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list(par_report_id in number) return pricelist_value pipelined;

end pricelist_exclusion;
/

/****************/
/* Package Body */
/****************/
create or replace package body pricelist_exclusion as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*************************************************************/
   /* This procedure performs the report exclusion list routine */
   /*************************************************************/
   function list(par_report_id in number) return pricelist_value pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_exclusion is 
         select t01.matl_code as matl_code,
                '('||ltrim(t01.matl_code,0)||') '||nvl(t02.matl_desc,'*UNKNOWN') as matl_desc
           from report_matl_exclude t01,
                matl t02
          where t01.matl_code = t02.matl_code(+)
            and t01.report_id = par_report_id
          order by t01.matl_code asc;
      rcd_exclusion csr_exclusion%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the exclusion list
      /*-*/
      open csr_exclusion;
      loop
         fetch csr_exclusion into rcd_exclusion;
         if csr_exclusion%notfound then
            exit;
         end if;
         pipe row(pricelist_value_object(rcd_exclusion.matl_code, rcd_exclusion.matl_desc));
      end loop;
      close csr_exclusion;

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
         raise_application_error(-20000, 'PRICELIST_EXCLUSION - LIST - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list;

end pricelist_exclusion;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_exclusion for pr_app.pricelist_exclusion;
grant execute on pricelist_exclusion to public;
