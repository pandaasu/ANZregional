/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_hou_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_hou_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Household functions

    This package contain the household functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list_classification(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;

end pts_hou_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_hou_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_classification(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
            and t01.sva_val_status = '1'
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification values
      /*-*/
      open csr_system_all;
      loop
         fetch csr_system_all into rcd_system_all;
         if csr_system_all%notfound then
            exit;
         end if;
         pipe row(pts_cla_list_object(rcd_system_all.sva_val_code,rcd_system_all.sva_val_text));
      end loop;
      close csr_system_all;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - LIST_CLASSIFICATION - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_classification;

end pts_hou_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_hou_function for pts_app.pts_hou_function;
grant execute on pts_app.pts_hou_function to public;
