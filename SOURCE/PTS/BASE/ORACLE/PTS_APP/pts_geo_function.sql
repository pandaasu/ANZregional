/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_geo_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_geo_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Geographic Zone Function

    This package contain the geographic zone functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list_zones(par_geo_type in number) return pts_geo_hier_type pipelined;

end pts_geo_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_geo_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*************************************************************/
   /* This procedure performs the list geographic zones routine */
   /*************************************************************/
   function list_zones(par_geo_type in number) return pts_geo_hier_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_geo_zone is
         select level as hie_level,
                t01.gzo_geo_type,
                t01.gzo_geo_zone,
                t01.gzo_zon_text
           from pts_pts_geo_zone t01
          where t01.gzo_zon_status = '1'
          start with t01.gzo_geo_type = par_geo_type
        connect by prior t01.gzo_geo_type = t01.gzo_par_type
                     and t01.gzo_geo_zone = t01.gzo_par_zone
          order siblings by t01.gzo_geo_zone;
      rcd_geo_zone csr_geo_zone%rowtype;

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
      open csr_geo_zone;
      loop
         fetch csr_geo_zone into rcd_geo_zone;
         if csr_geo_zone%notfound then
            exit;
         end if;
         pipe row(pts_geo_hier_object(rcd_geo_zone.hie_level,rcd_geo_zone.gzo_geo_type,rcd_geo_zone.gzo_geo_zone,rcd_geo_zone.gzo_geo_text));
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
         raise_application_error(-20000, 'PTS_GEO_FUNCTION - LIST_ZONES - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_zones;

end pts_geo_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_geo_function for pts_app.pts_geo_function;
grant execute on pts_app.pts_geo_function to public;
