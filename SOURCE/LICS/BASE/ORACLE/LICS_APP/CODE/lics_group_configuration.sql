/******************/
/* Package Header */
/******************/
create or replace package lics_group_configuration as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_group_configuration
 Owner   : lics_app
 Author  : Steve Gregan - August 2006

 DESCRIPTION
 -----------
 Local Interface Control System - Group Configuration

 The package implements the group configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_group(par_group in varchar2,
                         par_description in varchar2) return varchar2;
   function update_group(par_group in varchar2,
                         par_description in varchar2) return varchar2;
   function delete_group(par_group in varchar2) return varchar2;
   function clear_group_details(par_group in varchar2) return varchar2;
   function insert_group_detail(par_group in varchar2,
                                par_interface in varchar2) return varchar2;

end lics_group_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_group_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_group lics_group%rowtype;
   rcd_lics_grp_interface lics_grp_interface%rowtype;

   /***************************************************/
   /* This function performs the insert group routine */
   /***************************************************/
   function insert_group(par_group in varchar2,
                         par_description in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_group_01 is 
         select *
           from lics_group t01
          where t01.gro_group = rcd_lics_group.gro_group;
      rcd_lics_group_01 csr_lics_group_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Group Configuration - Insert Group';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_group.gro_group := upper(par_group);
      rcd_lics_group.gro_description := par_description;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_group.gro_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_lics_group.gro_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Group must not already exist
      /*-*/
      open csr_lics_group_01;
      fetch csr_lics_group_01 into rcd_lics_group_01;
      if csr_lics_group_01%found then
         var_message := var_message || chr(13) || 'Group (' || rcd_lics_group.gro_group || ') already exists';
      end if;
      close csr_lics_group_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new group
      /*-*/
      insert into lics_group
         (gro_group,
          gro_description)
         values(rcd_lics_group.gro_group,
                rcd_lics_group.gro_description);

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
   end insert_group;

   /***************************************************/
   /* This function performs the update group routine */
   /***************************************************/
   function update_group(par_group in varchar2,
                         par_description in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_group_01 is 
         select *
           from lics_group t01
          where t01.gro_group = rcd_lics_group.gro_group;
      rcd_lics_group_01 csr_lics_group_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Group Configuration - Update Group';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_group.gro_group := upper(par_group);
      rcd_lics_group.gro_description := par_description;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_group.gro_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_lics_group.gro_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Group must already exist
      /*-*/
      open csr_lics_group_01;
      fetch csr_lics_group_01 into rcd_lics_group_01;
      if csr_lics_group_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_lics_group.gro_group || ') does not exist';
      end if;
      close csr_lics_group_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing group
      /*-*/
      update lics_group
         set gro_description = rcd_lics_group.gro_description
         where gro_group = rcd_lics_group.gro_group;

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
   end update_group;

   /***************************************************/
   /* This function performs the delete group routine */
   /***************************************************/
   function delete_group(par_group in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_group_01 is 
         select *
           from lics_group t01
          where t01.gro_group = rcd_lics_group.gro_group;
      rcd_lics_group_01 csr_lics_group_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Group Configuration - Delete Group';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_group.gro_group := upper(par_group);

      /*-*/
      /* Group must already exist
      /*-*/
      open csr_lics_group_01;
      fetch csr_lics_group_01 into rcd_lics_group_01;
      if csr_lics_group_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_lics_group.gro_group || ') does not exist';
      end if;
      close csr_lics_group_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing group
      /*-*/
      delete from lics_grp_interface
         where gri_group = rcd_lics_group.gro_group;
      delete from lics_group
         where gro_group = rcd_lics_group.gro_group;

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
   end delete_group;

   /*********************************************************/
   /* This function performs the clear group detail routine */
   /*********************************************************/
   function clear_group_details(par_group in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_group_01 is 
         select *
           from lics_group t01
          where t01.gro_group = rcd_lics_grp_interface.gri_group;
      rcd_lics_group_01 csr_lics_group_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Group Configuration - Clear Group Details';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_grp_interface.gri_group := upper(par_group);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_grp_interface.gri_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;

      /*-*/
      /* Group must exist
      /*-*/
      open csr_lics_group_01;
      fetch csr_lics_group_01 into rcd_lics_group_01;
      if csr_lics_group_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_lics_grp_interface.gri_group || ') does not exist';
      end if;
      close csr_lics_group_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Clear the group detail
      /*-*/
      delete from lics_grp_interface
         where gri_group = rcd_lics_grp_interface.gri_group;

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
   end clear_group_details;

   /**********************************************************/
   /* This function performs the insert group detail routine */
   /**********************************************************/
   function insert_group_detail(par_group in varchar2,
                                par_interface in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_group_01 is 
         select *
           from lics_group t01
          where t01.gro_group = rcd_lics_grp_interface.gri_group;
      rcd_lics_group_01 csr_lics_group_01%rowtype;

      cursor csr_lics_interface_01 is 
         select *
           from lics_interface t01
          where t01.int_interface = rcd_lics_grp_interface.gri_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Group Configuration - Insert Group Detail';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_grp_interface.gri_group := upper(par_group);
      rcd_lics_grp_interface.gri_interface := upper(par_interface);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_grp_interface.gri_group is null then
         var_message := var_message || chr(13) || 'Group must be specified';
      end if;
      if rcd_lics_grp_interface.gri_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;

      /*-*/
      /* Group must exist
      /*-*/
      open csr_lics_group_01;
      fetch csr_lics_group_01 into rcd_lics_group_01;
      if csr_lics_group_01%notfound then
         var_message := var_message || chr(13) || 'Group (' || rcd_lics_grp_interface.gri_group || ') does not exist';
      end if;
      close csr_lics_group_01;

      /*-*/
      /* Interface must exist
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_lics_grp_interface.gri_interface || ') does not exist';
      end if;
      close csr_lics_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new group detail
      /*-*/
      insert into lics_grp_interface
         (gri_group,
          gri_interface)
         values(rcd_lics_grp_interface.gri_group,
                rcd_lics_grp_interface.gri_interface);

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
   end insert_group_detail;

end lics_group_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_group_configuration for lics_app.lics_group_configuration;
grant execute on lics_group_configuration to public;