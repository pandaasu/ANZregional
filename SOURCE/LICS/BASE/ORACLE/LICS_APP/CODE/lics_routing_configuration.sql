/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_routing_configuration
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Routing Configuration

 The package implements the routing configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_routing_configuration as

   /**/
   /* Public declarations
   /**/
   function insert_routing(par_source in varchar2,
                           par_description in varchar2,
                           par_pre_length in number) return varchar2;
   function update_routing(par_source in varchar2,
                           par_description in varchar2,
                           par_pre_length in number) return varchar2;
   function delete_routing(par_source in varchar2) return varchar2;
   function clear_routing_details(par_source in varchar2) return varchar2;
   function insert_routing_detail(par_source in varchar2,
                                  par_prefix in varchar2,
                                  par_interface in varchar2) return varchar2;

end lics_routing_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_routing_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_routing lics_routing%rowtype;
   rcd_lics_rtg_detail lics_rtg_detail%rowtype;

   /*****************************************************/
   /* This function performs the insert routing routine */
   /*****************************************************/
   function insert_routing(par_source in varchar2,
                           par_description in varchar2,
                           par_pre_length in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_routing_01 is 
         select *
           from lics_routing t01
          where t01.rou_source = rcd_lics_routing.rou_source;
      rcd_lics_routing_01 csr_lics_routing_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Routing Configuration - Insert Routing';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_routing.rou_source := upper(par_source);
      rcd_lics_routing.rou_description := par_description;
      rcd_lics_routing.rou_pre_length := par_pre_length;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_routing.rou_source is null then
         var_message := var_message || chr(13) || 'Source must be specified';
      end if;
      if rcd_lics_routing.rou_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_routing.rou_pre_length <= 0 then
         var_message := var_message || chr(13) || 'Prefix length must be greater than zero';
      end if;

      /*-*/
      /* Routing must not already exist
      /*-*/
      open csr_lics_routing_01;
      fetch csr_lics_routing_01 into rcd_lics_routing_01;
      if csr_lics_routing_01%found then
         var_message := var_message || chr(13) || 'Routing source (' || rcd_lics_routing.rou_source || ') already exists';
      end if;
      close csr_lics_routing_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new routing
      /*-*/
      insert into lics_routing
         (rou_source,
          rou_description,
          rou_pre_length)
         values(rcd_lics_routing.rou_source,
                rcd_lics_routing.rou_description,
                rcd_lics_routing.rou_pre_length);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_routing;

   /*****************************************************/
   /* This function performs the update routing routine */
   /*****************************************************/
   function update_routing(par_source in varchar2,
                           par_description in varchar2,
                           par_pre_length in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_routing_01 is 
         select *
           from lics_routing t01
          where t01.rou_source = rcd_lics_routing.rou_source;
      rcd_lics_routing_01 csr_lics_routing_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Routing Configuration - Update Routing';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_routing.rou_source := upper(par_source);
      rcd_lics_routing.rou_description := par_description;
      rcd_lics_routing.rou_pre_length := par_pre_length;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_routing.rou_source is null then
         var_message := var_message || chr(13) || 'Source must be specified';
      end if;
      if rcd_lics_routing.rou_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_routing.rou_pre_length <= 0 then
         var_message := var_message || chr(13) || 'Prefix length must be greater than zero';
      end if;

      /*-*/
      /* Routing must already exist
      /*-*/
      open csr_lics_routing_01;
      fetch csr_lics_routing_01 into rcd_lics_routing_01;
      if csr_lics_routing_01%notfound then
         var_message := var_message || chr(13) || 'Routing source (' || rcd_lics_routing.rou_source || ') does not exist';
      end if;
      close csr_lics_routing_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing routing
      /*-*/
      update lics_routing
         set rou_description = rcd_lics_routing.rou_description,
             rou_pre_length = rcd_lics_routing.rou_pre_length
         where rou_source = rcd_lics_routing.rou_source;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_routing;

   /*****************************************************/
   /* This function performs the delete routing routine */
   /*****************************************************/
   function delete_routing(par_source in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_routing_01 is 
         select *
           from lics_routing t01
          where t01.rou_source = rcd_lics_routing.rou_source;
      rcd_lics_routing_01 csr_lics_routing_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Routing Configuration - Delete Routing';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_routing.rou_source := upper(par_source);

      /*-*/
      /* Routing must already exist
      /*-*/
      open csr_lics_routing_01;
      fetch csr_lics_routing_01 into rcd_lics_routing_01;
      if csr_lics_routing_01%notfound then
         var_message := var_message || chr(13) || 'Routing source (' || rcd_lics_routing.rou_source || ') does not exist';
      end if;
      close csr_lics_routing_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing routing
      /*-*/
      delete from lics_rtg_detail
         where rde_source = rcd_lics_routing.rou_source;
      delete from lics_routing
         where rou_source = rcd_lics_routing.rou_source;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_routing;

   /***********************************************************/
   /* This function performs the clear routing detail routine */
   /***********************************************************/
   function clear_routing_details(par_source in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_routing_01 is 
         select *
           from lics_routing t01
          where t01.rou_source = rcd_lics_rtg_detail.rde_source;
      rcd_lics_routing_01 csr_lics_routing_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Routing Configuration - Clear Routing Details';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_rtg_detail.rde_source := upper(par_source);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_rtg_detail.rde_source is null then
         var_message := var_message || chr(13) || 'Source must be specified';
      end if;

      /*-*/
      /* Routing must exist
      /*-*/
      open csr_lics_routing_01;
      fetch csr_lics_routing_01 into rcd_lics_routing_01;
      if csr_lics_routing_01%notfound then
         var_message := var_message || chr(13) || 'Routing source (' || rcd_lics_rtg_detail.rde_source || ') does not exist';
      end if;
      close csr_lics_routing_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Clear the routing detail
      /*-*/
      delete from lics_rtg_detail
         where rde_source = rcd_lics_rtg_detail.rde_source;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_routing_details;

   /************************************************************/
   /* This function performs the insert routing detail routine */
   /************************************************************/
   function insert_routing_detail(par_source in varchar2,
                                  par_prefix in varchar2,
                                  par_interface in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_routing_01 is 
         select *
           from lics_routing t01
          where t01.rou_source = rcd_lics_rtg_detail.rde_source;
      rcd_lics_routing_01 csr_lics_routing_01%rowtype;

      cursor csr_lics_interface_01 is 
         select *
           from lics_interface t01
          where t01.int_interface = rcd_lics_rtg_detail.rde_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Routing Configuration - Insert Routing Detail';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_rtg_detail.rde_source := upper(par_source);
      rcd_lics_rtg_detail.rde_prefix := upper(par_prefix);
      rcd_lics_rtg_detail.rde_interface := upper(par_interface);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_rtg_detail.rde_source is null then
         var_message := var_message || chr(13) || 'Source must be specified';
      end if;
      if rcd_lics_rtg_detail.rde_prefix is null then
         var_message := var_message || chr(13) || 'Prefix must be specified';
      end if;
      if rcd_lics_rtg_detail.rde_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;

      /*-*/
      /* Routing must exist
      /*-*/
      open csr_lics_routing_01;
      fetch csr_lics_routing_01 into rcd_lics_routing_01;
      if csr_lics_routing_01%notfound then
         var_message := var_message || chr(13) || 'Routing source (' || rcd_lics_rtg_detail.rde_source || ') does not exist';
      end if;
      close csr_lics_routing_01;

      /*-*/
      /* Interface must exist
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_lics_rtg_detail.rde_interface|| ') does not exist';
      end if;
      close csr_lics_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new routing detail
      /*-*/
      insert into lics_rtg_detail
         (rde_source,
          rde_prefix,
          rde_interface)
         values(rcd_lics_rtg_detail.rde_source,
                rcd_lics_rtg_detail.rde_prefix,
                rcd_lics_rtg_detail.rde_interface);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_routing_detail;

end lics_routing_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_routing_configuration for lics_app.lics_routing_configuration;
grant execute on lics_routing_configuration to public;