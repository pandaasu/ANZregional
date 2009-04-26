/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_int_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_int_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Interviewer functions

    This package contain the interviewer functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list_geo_zone return pts_geo_list_type pipelined;

end pts_int_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_int_function as

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
          where t01. gzo_geo_type = 30
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
      /* Retrieve the interviewer geographic zone values
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
         raise_application_error(-20000, 'PTS_INT_FUNCTION - LIST_GEO_ZONE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_geo_zone;

end pts_int_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_int_function for pts_app.pts_int_function;
grant execute on pts_app.pts_int_function to public;
