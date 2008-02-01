/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_router
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Router

 The package implements the router functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_router as

   /**/
   /* Public declarations
   /**/
   function execute(par_source in varchar2, par_fil_name in varchar2) return varchar2;

end lics_router;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_router as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function execute(par_source in varchar2, par_fil_name in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(256);
      var_prefix lics_rtg_detail.rde_prefix%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_routing_01 is 
         select t01.rou_pre_length
           from lics_routing t01
          where t01.rou_source = par_source;
      rcd_lics_routing_01 csr_lics_routing_01%rowtype;

      cursor csr_lics_rtg_detail_01 is 
         select t01.rde_interface,
                nvl(t02.int_type,'*NONE') as int_type
           from lics_rtg_detail t01,
                lics_interface t02
          where t01.rde_interface = t02.int_interface(+)
            and t01.rde_source = par_source
            and t01.rde_prefix = var_prefix;
      rcd_lics_rtg_detail_01 csr_lics_rtg_detail_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform the interface routing lookup
      /*-*/
      begin

         /*-*/
         /* Retrieve the routine header for the source
         /*-*/
         open csr_lics_routing_01;
         fetch csr_lics_routing_01 into rcd_lics_routing_01;
         if csr_lics_routing_01%notfound then
            raise_application_error(-20000, 'Router - Routing source (' || par_source || ') does not exist');
         end if;
         close csr_lics_routing_01;

         /*-*/
         /* Extract the prefix from the file name
         /*-*/
         var_prefix := substr(par_fil_name,1,rcd_lics_routing_01.rou_pre_length);

         /*-*/
         /* Retrieve the interface identifier from the routing detail
         /*-*/
         open csr_lics_rtg_detail_01;
         fetch csr_lics_rtg_detail_01 into rcd_lics_rtg_detail_01;
         if csr_lics_rtg_detail_01%notfound then
            raise_application_error(-20000, 'Router - Routing prefix (' || var_prefix  || ') does not exist for routing source (' || par_source || ')');
         end if;
         close csr_lics_rtg_detail_01;

         /*-*/
         /* Interface must be *INBOUND or *PASSTHRU
         /**/
         if rcd_lics_rtg_detail_01.int_type <> lics_constant.type_inbound
         and rcd_lics_rtg_detail_01.int_type <> lics_constant.type_passthru then
            raise_application_error(-20000, 'Router - Routing interface (' || rcd_lics_rtg_detail_01.rde_interface  || ') type (' || rcd_lics_rtg_detail_01.int_type  || ') must be *INBOUND or *PASSTHRU');
         end if;

      /*-------------------*/
      /* Exception handler */
      /*-------------------*/
      exception

         /**/
         /* Exception trap
         /**/
         when others then

            /*-*/
            /* Log the event fatal
            /*-*/
            begin
               lics_notification.log_fatal(lics_constant.job_loader,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           'ROUTER FAILED - ' ||  substr(SQLERRM, 1, 512));
            exception
               when others then
                  null;
            end;

            /*-*/
            /* Raise an exception to the calling application
            /*-*/
            raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Router - ' || substr(SQLERRM, 1, 512));

      end;

      /*-*/
      /* Execute the inbound/passthru loader
      /**/
      if rcd_lics_rtg_detail_01.int_type = lics_constant.type_inbound then
         lics_inbound_loader.execute(rcd_lics_rtg_detail_01.rde_interface, par_fil_name);
         var_return := 'ARCHIVE=1';
      else
         lics_passthru_loader.execute(rcd_lics_rtg_detail_01.rde_interface, par_fil_name);
         var_return := 'ARCHIVE=0';
      end if;

      /*-*/
      /* Return the archive indicator
      /**/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_router;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_router for lics_app.lics_router;
grant execute on lics_router to public;