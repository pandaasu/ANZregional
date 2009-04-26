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
   function list_geo_zone return pts_geo_list_type pipelined;
   function list_classification(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;
   function get_class_code(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_code_type pipelined;
   function get_class_number(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_numb_type pipelined;
   function get_class_text(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_text_type pipelined;

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

   /************************************************************/
   /* This procedure performs the list geographic zone routine */
   /************************************************************/
   function list_geo_zone return pts_geo_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_geo_zone is
         select t01.gzo_geo_zone,
                t01.gzo_geo_text
           from pts_geo_zone t01
          where t01. gzo_geo_type = 40
            and t01.gzo_zon_status = '1'
          order by t01.gzo_geo_zone asc;
      rcd_geo_zone csr_geo_zone%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household geographic zone values
      /*-*/
      open csr_geo_zone;
      loop
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            exit;
         end if;
         pipe row(pts_geo_list_object(rcd_geo_zone.gzo_geo_zone,rcd_geo_zone.gzo_geo_text));
      end loop;
      close csr_geo_zone;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - LIST_GEO_ZONE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_geo_zone;

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

   /***************************************************************/
   /* This procedure performs the get classification code routine */
   /***************************************************************/
   function get_class_code(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_code_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select nvl(t01.hcl_val_code,0) as hcl_val_code
           from pts_hou_classification t01
          where t01.hcl_hou_code = par_hou_code
            and t01.hcl_tab_code = upper(par_tab_code)
            and t01.hcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification value code
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_code_object(rcd_classification.hcl_val_code));
         else
            pipe row(pts_cla_code_object(0));
         end if;
      end loop;
      close csr_classification;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - GET_CLASS_CODE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_code;

   /*****************************************************************/
   /* This procedure performs the get classification number routine */
   /*****************************************************************/
   function get_class_number(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_numb_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select nvl(t01.hcl_val_text,0) as hcl_val_text
           from pts_hou_classification t01
          where t01.hcl_hou_code = par_hou_code
            and t01.hcl_tab_code = upper(par_tab_code)
            and t01.hcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification value number
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_numb_object(rcd_classification.hcl_val_text));
         else
            pipe row(pts_cla_numb_object(0));
         end if;
      end loop;
      close csr_classification;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - GET_CLASS_NUMBER - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_number;

   /***************************************************************/
   /* This procedure performs the get classification text routine */
   /***************************************************************/
   function get_class_text(par_hou_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_text_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select t01.hcl_val_text as hcl_val_text
           from pts_hou_classification t01
          where t01.hcl_hou_code = par_hou_code
            and t01.hcl_tab_code = upper(par_tab_code)
            and t01.hcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the household classification value text
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_text_object(rcd_classification.hcl_val_text));
         else
            pipe row(pts_cla_text_object(0));
         end if;
      end loop;
      close csr_classification;

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
         raise_application_error(-20000, 'PTS_HOU_FUNCTION - GET_CLASS_TEXT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_text;

end pts_hou_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_hou_function for pts_app.pts_hou_function;
grant execute on pts_app.pts_hou_function to public;
