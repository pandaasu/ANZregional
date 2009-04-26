/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_pet_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet Function

    This package contain the pet functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list_pet_type return pts_pet_typ_list_type pipelined;
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;
   function list_class(par_pet_type in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined;
   function get_class_code(par_pet_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_code_type pipelined;
   function get_class_number(par_pet_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_numb_type pipelined;
   function get_class_text(par_pet_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_text_type pipelined;

end pts_pet_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_pet_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the list pet type routine */
   /*****************************************************/
   function list_pet_type return pts_pet_typ_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pet_type is
         select t01.pty_pet_type,
                t01.pty_typ_text
           from pts_pet_type t01
          where t01.pty_typ_status = '1'
          order by t01.pty_pet_type asc;
      rcd_pet_type csr_pet_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet type values
      /*-*/
      open csr_pet_type;
      loop
         fetch csr_pet_type into rcd_pet_type;
         if csr_system_all%notfound then
            exit;
         end if;
         pipe row(pts_pet_typ_list_object(rcd_pet_type.pty_pet_type,rcd_pet_type.pty_pet_text));
      end loop;
      close csr_pet_type;

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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - LIST_PET_TYPE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_pet_type;

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_class(par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined is

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
      /* Retrieve the pet system values
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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - LIST_CLASS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_class;

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_class(par_pet_type in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_list_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_field is
         select t01.*
           from pts_pty_sys_field t01
          where t01.psf_pet_type = par_pet_type
            and t01.psf_tab_code = upper(par_tab_code)
            and t01.psf_fld_code = par_fld_code;
      rcd_system_field csr_system_field%rowtype;

      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

      cursor csr_system_select is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = par_fld_code
            and t01.sva_val_code in (select psv_val_code 
                                       from pts_pty_sys_value
                                      where psv_pet_type = par_pet_type
                                        and psv_tab_code = upper(par_tab_code)
                                        and psv_fld_code = par_fld_code)
          order by t01.sva_val_code asc;
      rcd_system_select csr_system_select%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet type system field
      /*-*/
      open csr_system_field;
      fetch csr_system_field into rcd_system_field;
      if csr_system_field%notfound then
         return;
      end if;
      close csr_system_field;

      /*-*/
      /* Retrieve the pet type system values
      /*-*/
      if upper(rcd_system_field.psf_val_type) = '*ALL' then
         open csr_system_all;
         loop
            fetch csr_system_all into rcd_system_all;
            if csr_system_all%notfound then
               exit;
            end if;
            pipe row(pts_cla_list_object(rcd_system_all.sva_val_code,rcd_system_all.sva_val_text));
         end loop;
         close csr_system_all;
      elsif upper(rcd_system_field.psf_val_type) = '*SELECT' then
         open csr_system_select;
         loop
            fetch csr_system_select into rcd_system_select;
            if csr_system_select%notfound then
               exit;
            end if;
            pipe row(pts_cla_list_object(rcd_system_select.sva_val_code,rcd_system_select.sva_val_text));
         end loop;
         close csr_system_select;
      else
         return;
      end if;

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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - LIST_CLASS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_class;

   /***************************************************************/
   /* This procedure performs the get classification code routine */
   /***************************************************************/
   function get_class_code(par_pet_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_code_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select nvl(t01.pcl_val_code,0) as pcl_val_code
           from pts_pet_classification t01
          where t01.pcl_pet_code = par_pet_code
            and t01.pcl_tab_code = upper(par_tab_code)
            and t01.pcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet classification value code
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_code_object(rcd_classification.pcl_val_code));
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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - GET_CLASS_CODE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_code;

   /*****************************************************************/
   /* This procedure performs the get classification number routine */
   /*****************************************************************/
   function get_class_number(par_pet_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_numb_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select nvl(t01.pcl_val_text,0) as pcl_val_text
           from pts_pet_classification t01
          where t01.pcl_pet_code = par_pet_code
            and t01.pcl_tab_code = upper(par_tab_code)
            and t01.pcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet classification value number
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_numb_object(rcd_classification.pcl_val_text));
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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - GET_CLASS_NUMBER - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_number;

   /***************************************************************/
   /* This procedure performs the get classification text routine */
   /***************************************************************/
   function get_class_text(par_pet_code in number, par_tab_code in varchar2, par_fld_code in number) return pts_cla_text_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select t01.pcl_val_text as pcl_val_text
           from pts_pet_classification t01
          where t01.pcl_pet_code = par_pet_code
            and t01.pcl_tab_code = upper(par_tab_code)
            and t01.pcl_val_code = par_fld_code;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet classification value text
      /*-*/
      open csr_classification;
      loop
         fetch csr_classification into rcd_classification;
         if csr_classification%found then
            pipe row(pts_cla_text_object(rcd_classification.pcl_val_text));
         else
            pipe row(pts_cla_text_object(null));
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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - GET_CLASS_TEXT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_class_text;

end pts_pet_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_function for pts_app.pts_pet_function;
grant execute on pts_app.pts_pet_function to public;
