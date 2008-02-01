/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_configuration
 Owner   : vds_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Validation Data Store - Configuration

 The package implements the validation data store configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/02   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package vds_configuration as

   /**/
   /* Public declarations
   /**/
   function retrieve_interface return varchar2;
   function insert_interface return varchar2;
   function update_interface return varchar2;
   function delete_interface return varchar2;

end vds_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_vds_interface vds_interface%rowtype;

   /*********************************************************/
   /* This function performs the retrieve interface routine */
   /*********************************************************/
   function retrieve_interface return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_interface_01 is 
         select *
           from vds_interface t01
          where t01.vin_interface = rcd_vds_interface.vin_interface;
      rcd_vds_interface_01 csr_vds_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Configuration - Retrieve Interface';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_interface.vin_interface := upper(lics_form.get_variable('VIN_INTERFACE'));

      /*-*/
      /* Interface must exist
      /*-*/
      open csr_vds_interface_01;
      fetch csr_vds_interface_01 into rcd_vds_interface_01;
      if csr_vds_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_vds_interface.vin_interface || ') does not exist';
      end if;
      close csr_vds_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the form data
      /*-*/
      lics_form.clear_form;
      lics_form.set_value('VIN_INTERFACE',rcd_vds_interface_01.vin_interface);
      lics_form.set_value('VIN_DESCRIPTION',rcd_vds_interface_01.vin_description);
      lics_form.set_value('VIN_LOGON01',rcd_vds_interface_01.vin_logon01);
      lics_form.set_value('VIN_LOGON02',rcd_vds_interface_01.vin_logon02);

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
   end retrieve_interface;

   /*******************************************************/
   /* This function performs the insert interface routine */
   /*******************************************************/
   function insert_interface return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_interface_01 is 
         select *
           from vds_interface t01
          where t01.vin_interface = rcd_vds_interface.vin_interface;
      rcd_vds_interface_01 csr_vds_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Configuration - Insert Interface';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_interface.vin_interface := upper(lics_form.get_variable('VIN_INTERFACE'));
      rcd_vds_interface.vin_description := lics_form.get_variable('VIN_DESCRIPTION');
      rcd_vds_interface.vin_logon01 := lics_form.get_variable('VIN_LOGON01');
      rcd_vds_interface.vin_logon02 := lics_form.get_variable('VIN_LOGON02');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_interface.vin_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;
      if rcd_vds_interface.vin_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Interface must not already exist
      /*-*/
      open csr_vds_interface_01;
      fetch csr_vds_interface_01 into rcd_vds_interface_01;
      if csr_vds_interface_01%found then
         var_message := var_message || chr(13) || 'Interface (' || rcd_vds_interface.vin_interface || ') already exists';
      end if;
      close csr_vds_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new interface
      /*-*/
      insert into vds_interface
         (vin_interface,
          vin_description,
          vin_logon01,
          vin_logon02)
         values(rcd_vds_interface.vin_interface,
                rcd_vds_interface.vin_description,
                rcd_vds_interface.vin_logon01,
                rcd_vds_interface.vin_logon02);

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

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
   end insert_interface;

   /*******************************************************/
   /* This function performs the update interface routine */
   /*******************************************************/
   function update_interface return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_interface_01 is 
         select *
           from vds_interface t01
          where t01.vin_interface = rcd_vds_interface.vin_interface;
      rcd_vds_interface_01 csr_vds_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Configuration - Update Interface';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_interface.vin_interface := upper(lics_form.get_variable('VIN_INTERFACE'));
      rcd_vds_interface.vin_description := lics_form.get_variable('VIN_DESCRIPTION');
      rcd_vds_interface.vin_logon01 := lics_form.get_variable('VIN_LOGON01');
      rcd_vds_interface.vin_logon02 := lics_form.get_variable('VIN_LOGON02');

      /*-*/
      /* Validate the data values
      /*-*/
      if rcd_vds_interface.vin_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;
      if rcd_vds_interface.vin_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;

      /*-*/
      /* Interface must already exist
      /*-*/
      open csr_vds_interface_01;
      fetch csr_vds_interface_01 into rcd_vds_interface_01;
      if csr_vds_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_vds_interface.vin_interface || ') does not exist';
      end if;
      close csr_vds_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing interface
      /*-*/
      update vds_interface
         set vin_description = rcd_vds_interface.vin_description,
             vin_logon01 = rcd_vds_interface.vin_logon01,
             vin_logon02 = rcd_vds_interface.vin_logon02
         where vin_interface = rcd_vds_interface.vin_interface;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

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
   end update_interface;

   /*******************************************************/
   /* This function performs the delete interface routine */
   /*******************************************************/
   function delete_interface return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_interface_01 is 
         select *
           from vds_interface t01
          where t01.vin_interface = rcd_vds_interface.vin_interface;
      rcd_vds_interface_01 csr_vds_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'VDS - Configuration - Delete Interface';
      var_message := null;

      /*-*/
      /* Set the data variables
      /**/
      rcd_vds_interface.vin_interface := upper(lics_form.get_variable('VIN_INTERFACE'));

      /*-*/
      /* Interface must already exist
      /*-*/
      open csr_vds_interface_01;
      fetch csr_vds_interface_01 into rcd_vds_interface_01;
      if csr_vds_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_vds_interface.vin_interface || ') does not exist';
      end if;
      close csr_vds_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing interface data
      /*-*/
      delete from vds_interface where vin_interface = rcd_vds_interface.vin_interface;

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
   end delete_interface;

end vds_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_configuration for vds_app.vds_configuration;
grant execute on vds_configuration to public;