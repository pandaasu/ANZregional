/******************/
/* Package Header */
/******************/
create or replace package lics_security_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_security_configuration
    Owner   : lics_app
    Author  : Steve Gregan - June 2007

    DESCRIPTION
    -----------
    Local Interface Control System - Security Configuration

    The package implements the security configuration functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/06   Steve Gregan   Created
    2008/07   Trevor Keon    Added interface security support

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_user(par_user in varchar2,
                        par_description in varchar2,
                        par_menu in varchar2,
                        par_status in varchar2) return varchar2;
   function update_user(par_user in varchar2,
                        par_description in varchar2,
                        par_menu in varchar2,
                        par_status in varchar2) return varchar2;
   function delete_user(par_user in varchar2) return varchar2;
   function insert_menu(par_menu in varchar2,
                        par_description in varchar2) return varchar2;
   function update_menu(par_menu in varchar2,
                        par_description in varchar2) return varchar2;
   function delete_menu(par_menu in varchar2) return varchar2;
   function clear_menu_links(par_menu in varchar2) return varchar2;
   function insert_menu_link(par_menu in varchar2,
                             par_sequence in number,
                             par_type in varchar2,
                             par_link in varchar2) return varchar2;
   function insert_option(par_option in varchar2,
                          par_description in varchar2,
                          par_script in varchar2,
                          par_status in varchar2) return varchar2;
   function update_option(par_option in varchar2,
                          par_description in varchar2,
                          par_script in varchar2,
                          par_status in varchar2) return varchar2;
   function delete_option(par_option in varchar2) return varchar2;
   function insert_int_sec(par_interface in varchar2,
                           par_user in varchar2) return varchar2;
   function update_int_sec(par_interface in varchar2,
                           par_user in varchar2,
                           par_interface_new in varchar2,
                           par_user_new in varchar2) return varchar2;
   function delete_int_sec(par_interface in varchar2,
                           par_user in varchar2) return varchar2;                                                      

end lics_security_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_security_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_sec_user lics_sec_user%rowtype;
   rcd_lics_sec_menu lics_sec_menu%rowtype;
   rcd_lics_sec_link lics_sec_link%rowtype;
   rcd_lics_sec_option lics_sec_option%rowtype;
   rcd_lics_sec_interface lics_sec_interface%rowtype;

   /**************************************************/
   /* This function performs the insert user routine */
   /**************************************************/
   function insert_user(par_user in varchar2,
                        par_description in varchar2,
                        par_menu in varchar2,
                        par_status in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_user_01 is 
         select *
           from lics_sec_user t01
          where t01.seu_user = rcd_lics_sec_user.seu_user;
      rcd_lics_sec_user_01 csr_lics_sec_user_01%rowtype;

      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_user.seu_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Insert User';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_user.seu_user := upper(par_user);
      rcd_lics_sec_user.seu_description := par_description;
      rcd_lics_sec_user.seu_menu := upper(par_menu);
      rcd_lics_sec_user.seu_status := par_status;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_user.seu_user is null then
         var_message := var_message || chr(13) || 'User must be specified';
      end if;
      if rcd_lics_sec_user.seu_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_sec_user.seu_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;
      if rcd_lics_sec_user.seu_status != '0' and rcd_lics_sec_user.seu_status != '1' then
         var_message := var_message || chr(13) || 'Status must be 0(inactive) or 1(active)';
      end if;

      /*-*/
      /* User must not already exist
      /*-*/
      open csr_lics_sec_user_01;
      fetch csr_lics_sec_user_01 into rcd_lics_sec_user_01;
      if csr_lics_sec_user_01%found then
         var_message := var_message || chr(13) || 'User (' || rcd_lics_sec_user.seu_user || ') already exists';
      end if;
      close csr_lics_sec_user_01;

      /*-*/
      /* Menu must already exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%notfound then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_user.seu_menu || ') does not exist';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new user
      /*-*/
      insert into lics_sec_user
         (seu_user,
          seu_description,
          seu_menu,
          seu_status)
         values(rcd_lics_sec_user.seu_user,
                rcd_lics_sec_user.seu_description,
                rcd_lics_sec_user.seu_menu,
                rcd_lics_sec_user.seu_status);

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
   end insert_user;

   /**************************************************/
   /* This function performs the update user routine */
   /**************************************************/
   function update_user(par_user in varchar2,
                        par_description in varchar2,
                        par_menu in varchar2,
                        par_status in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_user_01 is 
         select *
           from lics_sec_user t01
          where t01.seu_user = rcd_lics_sec_user.seu_user;
      rcd_lics_sec_user_01 csr_lics_sec_user_01%rowtype;

      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_user.seu_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Update User';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_user.seu_user := upper(par_user);
      rcd_lics_sec_user.seu_description := par_description;
      rcd_lics_sec_user.seu_menu := upper(par_menu);
      rcd_lics_sec_user.seu_status := par_status;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_user.seu_user is null then
         var_message := var_message || chr(13) || 'User must be specified';
      end if;
      if rcd_lics_sec_user.seu_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_sec_user.seu_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;
      if rcd_lics_sec_user.seu_status != '0' and rcd_lics_sec_user.seu_status != '1' then
         var_message := var_message || chr(13) || 'Status must be 0(inactive) or 1(active)';
      end if;

      /*-*/
      /* User must already exist
      /*-*/
      open csr_lics_sec_user_01;
      fetch csr_lics_sec_user_01 into rcd_lics_sec_user_01;
      if csr_lics_sec_user_01%notfound then
         var_message := var_message || chr(13) || 'User (' || rcd_lics_sec_user.seu_user || ') does not exist';
      end if;
      close csr_lics_sec_user_01;

      /*-*/
      /* Menu must already exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%notfound then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_user.seu_menu || ') does not exist';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing user
      /*-*/
      update lics_sec_user
         set seu_description = rcd_lics_sec_user.seu_description,
             seu_menu = rcd_lics_sec_user.seu_menu,
             seu_status = rcd_lics_sec_user.seu_status
         where seu_user = rcd_lics_sec_user.seu_user;

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
   end update_user;

   /**************************************************/
   /* This function performs the delete user routine */
   /**************************************************/
   function delete_user(par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_user_01 is 
         select *
           from lics_sec_user t01
          where t01.seu_user = rcd_lics_sec_user.seu_user;
      rcd_lics_sec_user_01 csr_lics_sec_user_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Delete User';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_user.seu_user := upper(par_user);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_user.seu_user is null then
         var_message := var_message || chr(13) || 'User must be specified';
      end if;

      /*-*/
      /* User must already exist
      /*-*/
      open csr_lics_sec_user_01;
      fetch csr_lics_sec_user_01 into rcd_lics_sec_user_01;
      if csr_lics_sec_user_01%notfound then
         var_message := var_message || chr(13) || 'User (' || rcd_lics_sec_user.seu_user || ') does not exist';
      end if;
      close csr_lics_sec_user_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing user
      /*-*/
      delete from lics_sec_user
         where seu_user = rcd_lics_sec_user.seu_user;

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
   end delete_user;

   /**************************************************/
   /* This function performs the insert menu routine */
   /**************************************************/
   function insert_menu(par_menu in varchar2,
                        par_description in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_menu.sem_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Insert Menu';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_menu.sem_menu := upper(par_menu);
      rcd_lics_sec_menu.sem_description := par_description;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_menu.sem_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;
      if rcd_lics_sec_menu.sem_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Menu must not already exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%found then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_menu.sem_menu || ') already exists';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new menu
      /*-*/
      insert into lics_sec_menu
         (sem_menu,
          sem_description)
         values(rcd_lics_sec_menu.sem_menu,
                rcd_lics_sec_menu.sem_description);

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
   end insert_menu;

   /**************************************************/
   /* This function performs the update menu routine */
   /**************************************************/
   function update_menu(par_menu in varchar2,
                        par_description in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_menu.sem_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Update Menu';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_menu.sem_menu := upper(par_menu);
      rcd_lics_sec_menu.sem_description := par_description;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_menu.sem_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;
      if rcd_lics_sec_menu.sem_menu = '*SECURITY' then
         var_message := var_message || chr(13) || 'Menu *SECURITY cannot be updated';
      end if;
      if rcd_lics_sec_menu.sem_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Menu must already exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%notfound then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_menu.sem_menu || ') does not exist';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing menu
      /*-*/
      update lics_sec_menu
         set sem_description = rcd_lics_sec_menu.sem_description
         where sem_menu = rcd_lics_sec_menu.sem_menu;

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
   end update_menu;

   /**************************************************/
   /* This function performs the delete menu routine */
   /**************************************************/
   function delete_menu(par_menu in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_menu.sem_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

      cursor csr_lics_sec_user_01 is 
         select *
           from lics_sec_user t01
          where t01.seu_menu = rcd_lics_sec_menu.sem_menu;
      rcd_lics_sec_user_01 csr_lics_sec_user_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Delete Menu';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_menu.sem_menu := upper(par_menu);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_menu.sem_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;
      if rcd_lics_sec_menu.sem_menu = '*SECURITY' then
         var_message := var_message || chr(13) || 'Menu *SECURITY cannot be deleted';
      end if;

      /*-*/
      /* Menu must already exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%notfound then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_menu.sem_menu || ') does not exist';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Menu must not be used
      /*-*/
      open csr_lics_sec_user_01;
      fetch csr_lics_sec_user_01 into rcd_lics_sec_user_01;
      if csr_lics_sec_user_01%found then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_menu.sem_menu || ') is attached to one or more users';
      end if;
      close csr_lics_sec_user_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing menu
      /*-*/
      delete from lics_sec_link
         where sel_type = '*MNU'
           and sel_link = rcd_lics_sec_menu.sem_menu;
      delete from lics_sec_link
         where sel_menu = rcd_lics_sec_menu.sem_menu;
      delete from lics_sec_menu
         where sem_menu = rcd_lics_sec_menu.sem_menu;

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
   end delete_menu;

   /*******************************************************/
   /* This function performs the clear menu links routine */
   /*******************************************************/
   function clear_menu_links(par_menu in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_link.sel_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Clear Menu Links';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_link.sel_menu := upper(par_menu);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_link.sel_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;

      /*-*/
      /* Menu must exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%notfound then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_link.sel_menu || ') does not exist';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Clear the menu links
      /*-*/
      delete from lics_sec_link
         where sel_menu = rcd_lics_sec_link.sel_menu;

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
   end clear_menu_links;

   /*******************************************************/
   /* This function performs the insert menu link routine */
   /*******************************************************/
   function insert_menu_link(par_menu in varchar2,
                             par_sequence in number,
                             par_type in varchar2,
                             par_link in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_menu_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_link.sel_menu;
      rcd_lics_sec_menu_01 csr_lics_sec_menu_01%rowtype;

      cursor csr_lics_sec_link_01 is 
         select *
           from lics_sec_menu t01
          where t01.sem_menu = rcd_lics_sec_link.sel_link;
      rcd_lics_sec_link_01 csr_lics_sec_link_01%rowtype;

      cursor csr_lics_sec_link_02 is 
         select *
           from lics_sec_option t01
          where t01.seo_option = rcd_lics_sec_link.sel_link;
      rcd_lics_sec_link_02 csr_lics_sec_link_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Insert Menu Link';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_link.sel_menu := upper(par_menu);
      rcd_lics_sec_link.sel_sequence := par_sequence;
      rcd_lics_sec_link.sel_type := upper(par_type);
      rcd_lics_sec_link.sel_link := upper(par_link);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_link.sel_menu is null then
         var_message := var_message || chr(13) || 'Menu must be specified';
      end if;
      if rcd_lics_sec_link.sel_sequence is null then
         var_message := var_message || chr(13) || 'Sequence must be specified';
      end if;
      if rcd_lics_sec_link.sel_type is null then
         var_message := var_message || chr(13) || 'Type must be specified';
      end if;
      if rcd_lics_sec_link.sel_link is null then
         var_message := var_message || chr(13) || 'Link must be specified';
      end if;

      /*-*/
      /* Menu must exist
      /*-*/
      open csr_lics_sec_menu_01;
      fetch csr_lics_sec_menu_01 into rcd_lics_sec_menu_01;
      if csr_lics_sec_menu_01%notfound then
         var_message := var_message || chr(13) || 'Menu (' || rcd_lics_sec_link.sel_menu || ') does not exist';
      end if;
      close csr_lics_sec_menu_01;

      /*-*/
      /* Type must be valid
      /*-*/
      if rcd_lics_sec_link.sel_type != '*MNU' and
         rcd_lics_sec_link.sel_type != '*OPT' then
         var_message := var_message || chr(13) || 'Type (' || rcd_lics_sec_link.sel_type || ') must be *MNU or *OPT';
      end if;

      /*-*/
      /* Link must exist
      /*-*/
      if rcd_lics_sec_link.sel_type = '*MNU' then
         open csr_lics_sec_link_01;
         fetch csr_lics_sec_link_01 into rcd_lics_sec_link_01;
         if csr_lics_sec_link_01%notfound then
            var_message := var_message || chr(13) || 'Linked menu (' || rcd_lics_sec_link.sel_link || ') does not exist';
         end if;
         close csr_lics_sec_link_01;
      end if;
      if rcd_lics_sec_link.sel_type = '*OPT' then
         open csr_lics_sec_link_02;
         fetch csr_lics_sec_link_02 into rcd_lics_sec_link_02;
         if csr_lics_sec_link_02%notfound then
            var_message := var_message || chr(13) || 'Linked option (' || rcd_lics_sec_link.sel_link || ') does not exist';
         end if;
         close csr_lics_sec_link_02;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new menu link
      /*-*/
      insert into lics_sec_link
         (sel_menu,
          sel_sequence,
          sel_type,
          sel_link)
         values(rcd_lics_sec_link.sel_menu,
                rcd_lics_sec_link.sel_sequence,
                rcd_lics_sec_link.sel_type,
                rcd_lics_sec_link.sel_link);

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
   end insert_menu_link;

   /****************************************************/
   /* This function performs the insert option routine */
   /****************************************************/
   function insert_option(par_option in varchar2,
                          par_description in varchar2,
                          par_script in varchar2,
                          par_status in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_option_01 is 
         select *
           from lics_sec_option t01
          where t01.seo_option = rcd_lics_sec_option.seo_option;
      rcd_lics_sec_option_01 csr_lics_sec_option_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Insert Option';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_option.seo_option := upper(par_option);
      rcd_lics_sec_option.seo_description := par_description;
      rcd_lics_sec_option.seo_script := par_script;
      rcd_lics_sec_option.seo_status := par_status;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_option.seo_option is null then
         var_message := var_message || chr(13) || 'Option must be specified';
      end if;
      if rcd_lics_sec_option.seo_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_sec_option.seo_script is null then
         var_message := var_message || chr(13) || 'Script must be specified';
      end if;
      if rcd_lics_sec_option.seo_status != '0' and rcd_lics_sec_option.seo_status != '1' then
         var_message := var_message || chr(13) || 'Status must be 0(inactive) or 1(active)';
      end if;

      /*-*/
      /* Option must not already exist
      /*-*/
      open csr_lics_sec_option_01;
      fetch csr_lics_sec_option_01 into rcd_lics_sec_option_01;
      if csr_lics_sec_option_01%found then
         var_message := var_message || chr(13) || 'Option (' || rcd_lics_sec_option.seo_option || ') already exists';
      end if;
      close csr_lics_sec_option_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new option
      /*-*/
      insert into lics_sec_option
         (seo_option,
          seo_description,
          seo_script,
          seo_status)
         values(rcd_lics_sec_option.seo_option,
                rcd_lics_sec_option.seo_description,
                rcd_lics_sec_option.seo_script,
                rcd_lics_sec_option.seo_status);

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
   end insert_option;

   /****************************************************/
   /* This function performs the update option routine */
   /****************************************************/
   function update_option(par_option in varchar2,
                          par_description in varchar2,
                          par_script in varchar2,
                          par_status in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_option_01 is 
         select *
           from lics_sec_option t01
          where t01.seo_option = rcd_lics_sec_option.seo_option;
      rcd_lics_sec_option_01 csr_lics_sec_option_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Update Option';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_option.seo_option := upper(par_option);
      rcd_lics_sec_option.seo_description := par_description;
      rcd_lics_sec_option.seo_script := par_script;
      rcd_lics_sec_option.seo_status := par_status;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_option.seo_option is null then
         var_message := var_message || chr(13) || 'Option must be specified';
      end if;
      if rcd_lics_sec_option.seo_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_sec_option.seo_script is null then
         var_message := var_message || chr(13) || 'Script must be specified';
      end if;
      if rcd_lics_sec_option.seo_status != '0' and rcd_lics_sec_option.seo_status != '1' then
         var_message := var_message || chr(13) || 'Status must be 0(inactive) or 1(active)';
      end if;

      /*-*/
      /* Option must already exist
      /*-*/
      open csr_lics_sec_option_01;
      fetch csr_lics_sec_option_01 into rcd_lics_sec_option_01;
      if csr_lics_sec_option_01%notfound then
         var_message := var_message || chr(13) || 'Option (' || rcd_lics_sec_option.seo_option || ') does not exist';
      end if;
      close csr_lics_sec_option_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing option
      /*-*/
      update lics_sec_option
         set seo_description = rcd_lics_sec_option.seo_description,
             seo_script = rcd_lics_sec_option.seo_script,
             seo_status = rcd_lics_sec_option.seo_status
         where seo_option = rcd_lics_sec_option.seo_option;

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
   end update_option;

   /****************************************************/
   /* This function performs the delete option routine */
   /****************************************************/
   function delete_option(par_option in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_option_01 is 
         select *
           from lics_sec_option t01
          where t01.seo_option = rcd_lics_sec_option.seo_option;
      rcd_lics_sec_option_01 csr_lics_sec_option_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Delete Option';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_option.seo_option := upper(par_option);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_option.seo_option is null then
         var_message := var_message || chr(13) || 'Option must be specified';
      end if;

      /*-*/
      /* Option must already exist
      /*-*/
      open csr_lics_sec_option_01;
      fetch csr_lics_sec_option_01 into rcd_lics_sec_option_01;
      if csr_lics_sec_option_01%notfound then
         var_message := var_message || chr(13) || 'Option (' || rcd_lics_sec_option.seo_option || ') does not exist';
      end if;
      close csr_lics_sec_option_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing option
      /*-*/
      delete from lics_sec_link
         where sel_type = '*OPT'
           and sel_link = rcd_lics_sec_option.seo_option;
      delete from lics_sec_option
         where seo_option = rcd_lics_sec_option.seo_option;

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
   end delete_option;
   
   function insert_int_sec(par_interface in varchar2,
                           par_user in varchar2) return varchar2 is
      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_interface_01 is 
         select *
           from lics_sec_interface t01
          where t01.sei_interface = rcd_lics_sec_interface.sei_interface
            and t01.sei_user = rcd_lics_sec_interface.sei_user;
      rcd_lics_sec_interface_01 csr_lics_sec_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Insert Interface Security';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_interface.sei_interface := upper(par_interface);
      rcd_lics_sec_interface.sei_user := upper(par_user);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_interface.sei_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;
      if rcd_lics_sec_interface.sei_user is null then
         var_message := var_message || chr(13) || 'User must be specified';
      end if;

      /*-*/
      /* Interface security must not already exist
      /*-*/
      open csr_lics_sec_interface_01;
      fetch csr_lics_sec_interface_01 into rcd_lics_sec_interface_01;
      if csr_lics_sec_interface_01%found then
         var_message := var_message || chr(13) || 'Security on interface (' || rcd_lics_sec_interface.sei_interface || ') already exists for user (' || rcd_lics_sec_interface.sei_user || ')';
      end if;
      close csr_lics_sec_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new option
      /*-*/
      insert into lics_sec_interface
         (sei_interface,
          sei_user)
         values(rcd_lics_sec_interface.sei_interface,
                rcd_lics_sec_interface.sei_user);

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
   end insert_int_sec;
                              
   function update_int_sec(par_interface in varchar2,
                           par_user in varchar2,
                           par_interface_new in varchar2,
                           par_user_new in varchar2) return varchar2 is
      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_interface_01 is 
         select *
           from lics_sec_interface t01
          where t01.sei_interface = rcd_lics_sec_interface.sei_interface
            and t01.sei_user = rcd_lics_sec_interface.sei_user;
      rcd_lics_sec_interface_01 csr_lics_sec_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Update Interface Security';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_interface.sei_interface := upper(par_interface);
      rcd_lics_sec_interface.sei_user := upper(par_user);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_interface.sei_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;
      if rcd_lics_sec_interface.sei_user is null then
         var_message := var_message || chr(13) || 'User must be specified';
      end if;

      /*-*/
      /* Option must already exist
      /*-*/
      open csr_lics_sec_interface_01;
      fetch csr_lics_sec_interface_01 into rcd_lics_sec_interface_01;
      if csr_lics_sec_interface_01%notfound then
         var_message := var_message || chr(13) || 'Security on interface (' || rcd_lics_sec_interface.sei_interface || ') does not exists for user (' || rcd_lics_sec_interface.sei_user || ')';
      end if;
      close csr_lics_sec_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing interface
      /*-*/
      update lics_sec_interface
         set sei_interface = upper(par_interface_new),
             sei_user = upper(par_user_new)
         where sei_interface = rcd_lics_sec_interface.sei_interface
          and sei_user = rcd_lics_sec_interface.sei_user;

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
   end update_int_sec;    
                          
   function delete_int_sec(par_interface in varchar2,
                           par_user in varchar2) return varchar2 is
      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_sec_interface_01 is 
         select *
           from lics_sec_interface t01
          where t01.sei_interface = rcd_lics_sec_interface.sei_interface
            and t01.sei_user = rcd_lics_sec_interface.sei_user;
      rcd_lics_sec_interface_01 csr_lics_sec_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Security Configuration - Delete Interface Security';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_sec_interface.sei_interface := upper(par_interface);
      rcd_lics_sec_interface.sei_user := upper(par_user);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_sec_interface.sei_interface is null or rcd_lics_sec_interface.sei_user is null then
         var_message := var_message || chr(13) || 'Interface and user must be specified';
      end if;

      /*-*/
      /* interface must already exist
      /*-*/
      open csr_lics_sec_interface_01;
      fetch csr_lics_sec_interface_01 into rcd_lics_sec_interface_01;
      if csr_lics_sec_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface security for interface (' || rcd_lics_sec_interface.sei_interface || ') and user (' || rcd_lics_sec_interface.sei_user || ') does not exist';
      end if;
      close csr_lics_sec_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing interface
      /*-*/
      delete from lics_sec_interface
         where sei_interface = rcd_lics_sec_interface.sei_interface
           and sei_user = rcd_lics_sec_interface.sei_user;

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
   end delete_int_sec;                                   

end lics_security_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_security_configuration for lics_app.lics_security_configuration;
grant execute on lics_security_configuration to ics_app;