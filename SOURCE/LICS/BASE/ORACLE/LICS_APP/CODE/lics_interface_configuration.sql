/******************/
/* Package Header */
/******************/
create or replace package lics_interface_configuration as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_interface_configuration
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Interface Configuration

 The package implements the interface configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/08   Steve Gregan   Added optional search procedure
 2008/11   Steve Gregan   Added user invocation functionality columns (CHINA INTERFACE LOADER)
 2011/02   Steve Gregan   End point architecture version

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_interface(par_interface in varchar2,
                             par_description in varchar2,
                             par_type in varchar2,
                             par_group in varchar2,
                             par_priority in number,
                             par_hdr_history in number,
                             par_dta_history in number,
                             par_fil_path in varchar2,
                             par_fil_prefix in varchar2,
                             par_fil_sequence in number,
                             par_fil_extension in varchar2,
                             par_opr_alert in varchar2,
                             par_ema_group in varchar2,
                             par_search in varchar2,
                             par_procedure in varchar2,
                             par_status in varchar2,
                             par_usr_invocation in varchar2,
                             par_usr_validation in varchar2,
                             par_usr_message in varchar2,
                             par_lod_type in varchar2,
                             par_lod_group in varchar2) return varchar2;
   function update_interface(par_interface in varchar2,
                             par_description in varchar2,
                             par_type in varchar2,
                             par_group in varchar2,
                             par_priority in number,
                             par_hdr_history in number,
                             par_dta_history in number,
                             par_fil_path in varchar2,
                             par_fil_prefix in varchar2,
                             par_fil_sequence in number,
                             par_fil_extension in varchar2,
                             par_opr_alert in varchar2,
                             par_ema_group in varchar2,
                             par_search in varchar2,
                             par_procedure in varchar2,
                             par_status in varchar2,
                             par_usr_invocation in varchar2,
                             par_usr_validation in varchar2,
                             par_usr_message in varchar2,
                             par_lod_type in varchar2,
                             par_lod_group in varchar2) return varchar2;
   function delete_interface(par_interface in varchar2) return varchar2;

end lics_interface_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_interface_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_interface lics_interface%rowtype;

   /*******************************************************/
   /* This function performs the insert interface routine */
   /*******************************************************/
   function insert_interface(par_interface in varchar2,
                             par_description in varchar2,
                             par_type in varchar2,
                             par_group in varchar2,
                             par_priority in number,
                             par_hdr_history in number,
                             par_dta_history in number,
                             par_fil_path in varchar2,
                             par_fil_prefix in varchar2,
                             par_fil_sequence in number,
                             par_fil_extension in varchar2,
                             par_opr_alert in varchar2,
                             par_ema_group in varchar2,
                             par_search in varchar2,
                             par_procedure in varchar2,
                             par_status in varchar2,
                             par_usr_invocation in varchar2,
                             par_usr_validation in varchar2,
                             par_usr_message in varchar2,
                             par_lod_type in varchar2,
                             par_lod_group in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_name_error boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is 
         select *
           from lics_interface t01
          where t01.int_interface = rcd_lics_interface.int_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Interface Configuration - Insert Interface';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_interface.int_interface := upper(par_interface);
      rcd_lics_interface.int_description := par_description;
      rcd_lics_interface.int_type := par_type;
      rcd_lics_interface.int_group := upper(par_group);
      rcd_lics_interface.int_priority := par_priority;
      rcd_lics_interface.int_hdr_history := par_hdr_history;
      rcd_lics_interface.int_dta_history := par_dta_history;
      rcd_lics_interface.int_fil_path := par_fil_path;
      rcd_lics_interface.int_fil_prefix := par_fil_prefix;
      rcd_lics_interface.int_fil_sequence := par_fil_sequence;
      rcd_lics_interface.int_fil_extension := par_fil_extension;
      rcd_lics_interface.int_opr_alert := par_opr_alert;
      rcd_lics_interface.int_ema_group := par_ema_group;
      rcd_lics_interface.int_search := par_search;
      rcd_lics_interface.int_procedure := par_procedure;
      rcd_lics_interface.int_status := par_status;
      rcd_lics_interface.int_usr_invocation := nvl(par_usr_invocation,lics_constant.status_inactive);
      rcd_lics_interface.int_usr_validation := par_usr_validation;
      rcd_lics_interface.int_usr_message := par_usr_message;
      rcd_lics_interface.int_lod_type := upper(par_lod_type);
      rcd_lics_interface.int_lod_group := upper(par_lod_group);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_interface.int_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      else
         var_name_error := false;
         for idx_count in 1..length(rcd_lics_interface.int_interface) loop
            if substr(rcd_lics_interface.int_interface, idx_count, 1) < 'A' or substr(rcd_lics_interface.int_interface, idx_count, 1) > 'Z' then
               if substr(rcd_lics_interface.int_interface, idx_count, 1) < '0' or substr(rcd_lics_interface.int_interface, idx_count, 1) > '9' then
                  if substr(rcd_lics_interface.int_interface, idx_count, 1) <> '_' then
                     if substr(rcd_lics_interface.int_interface, idx_count, 1) <> '.' then
                        var_name_error := true;
                     end if;
                  end if;
               end if;
            end if;
         end loop;
         if var_name_error = true then
            var_message := var_message || chr(13) || 'Interface - characters must be A-Z, 0-9, _(underscore), .(dot)';
         end if;
      end if;
      if rcd_lics_interface.int_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_interface.int_type != lics_constant.type_inbound and
         rcd_lics_interface.int_type != lics_constant.type_outbound and
         rcd_lics_interface.int_type != lics_constant.type_passthru then
         var_message := var_message || chr(13) || 'Interface type must be *INBOUND, *OUTBOUND or *PASSTHRU';
      end if;
      if rcd_lics_interface.int_group is null then
         var_message := var_message || chr(13) || 'Interface group must be specified ';
      else
         var_name_error := false;
         for idx_count in 1..length(rcd_lics_interface.int_group) loop
            if substr(rcd_lics_interface.int_group, idx_count, 1) < 'A' or substr(rcd_lics_interface.int_group, idx_count, 1) > 'Z' then
               if substr(rcd_lics_interface.int_group, idx_count, 1) < '0' or substr(rcd_lics_interface.int_group, idx_count, 1) > '9' then
                  if substr(rcd_lics_interface.int_group, idx_count, 1) <> '_' then
                     var_name_error := true;
                  end if;
               end if;
            end if;
         end loop;
         if var_name_error = true then
            var_message := var_message || chr(13) || 'Interface group - characters must be A-Z, 0-9, _(underscore)';
         end if;
      end if;
      if rcd_lics_interface.int_type = lics_constant.type_inbound or rcd_lics_interface.int_type = lics_constant.type_passthru then
         if rcd_lics_interface.int_lod_type != '*PUSH' and rcd_lics_interface.int_lod_type != '*POLL' then
            var_message := var_message || chr(13) || 'Interface loading type must be *PUSH or *POLL for *INBOUND and *PASSTHRU';
         else
            if rcd_lics_interface.int_lod_type = '*POLL' then
               if rcd_lics_interface.int_lod_group is null or rcd_lics_interface.int_lod_group = '*NONE' then
                  var_message := var_message || chr(13) || 'Interface loading group must not be blank or *NONE for interface loading type *POLL';
               end if;
            else
               if rcd_lics_interface.int_lod_group != '*NONE' then
                  var_message := var_message || chr(13) || 'Interface loading group must be *NONE for interface loading type *PUSH';
               end if;
            end if;
         end if;
      else
         if rcd_lics_interface.int_lod_type != '*NONE' then
            var_message := var_message || chr(13) || 'Interface loading type must be *NONE for *OUTBOUND';
         end if;
         if rcd_lics_interface.int_lod_group != '*NONE' then
            var_message := var_message || chr(13) || 'Interface loading group must be *NONE for *OUTBOUND';
         end if;
      end if; 
      if rcd_lics_interface.int_priority <= 0 then
         var_message := var_message || chr(13) || 'Priority must be greater than zero';
      end if;
      if rcd_lics_interface.int_hdr_history <= 0 then
         var_message := var_message || chr(13) || 'Header history must be greater than zero';
      end if;
      if rcd_lics_interface.int_dta_history <= 0 then
         var_message := var_message || chr(13) || 'Data history must be greater than zero';
      end if;
      if rcd_lics_interface.int_type = lics_constant.type_inbound then
         rcd_lics_interface.int_fil_prefix := null;
         rcd_lics_interface.int_fil_sequence := null;
         rcd_lics_interface.int_fil_extension := null;
      else
         if rcd_lics_interface.int_fil_prefix is null then
            rcd_lics_interface.int_fil_sequence := null;
            rcd_lics_interface.int_fil_extension := null;
         else
            if rcd_lics_interface.int_fil_sequence < 0 then
               var_message := var_message || chr(13) || 'File sequence must be greater than or equal to zero';
            end if;
            if rcd_lics_interface.int_fil_extension is null then
               var_message := var_message || chr(13) || 'File extension must be specified ';
            end if;
         end if;
      end if;
      if rcd_lics_interface.int_procedure is null then
         var_message := var_message || chr(13) || 'Processing procedure must be specified ';
      end if;
      if rcd_lics_interface.int_type = lics_constant.type_outbound then
         rcd_lics_interface.int_search := null;
      end if;
      if rcd_lics_interface.int_status != lics_constant.status_inactive and
         rcd_lics_interface.int_status != lics_constant.status_active then
         var_message := var_message || chr(13) || 'Status must be active or inactive';
      end if;
      if rcd_lics_interface.int_usr_invocation != lics_constant.status_inactive and
         rcd_lics_interface.int_usr_invocation != lics_constant.status_active then
         var_message := var_message || chr(13) || 'User invocation must be active or inactive';
      end if;

      /*-*/
      /* Interface must not already exist
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%found then
         var_message := var_message || chr(13) || 'Interface (' || rcd_lics_interface.int_interface || ') already exists';
      end if;
      close csr_lics_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new interface
      /*-*/
      if rcd_lics_interface.int_type = lics_constant.type_inbound then
         rcd_lics_interface.int_fil_path := 'ICS_INBOUND';
         if rcd_lics_interface.int_lod_type = '*POLL' then
            rcd_lics_interface.int_fil_path := 'ICS_'||replace(rcd_lics_interface.int_interface,'.','#');
         end if;
      elsif rcd_lics_interface.int_type = lics_constant.type_passthru then
         rcd_lics_interface.int_fil_path := 'ICS_INBOUND';
         if rcd_lics_interface.int_lod_type = '*POLL' then
            rcd_lics_interface.int_fil_path := 'ICS_'||replace(rcd_lics_interface.int_interface,'.','#');
         end if;
      elsif rcd_lics_interface.int_type = lics_constant.type_outbound then
         rcd_lics_interface.int_fil_path := 'ICS_OUTBOUND';
      end if;
      insert into lics_interface
         (int_interface,
          int_description,
          int_type,
          int_group,
          int_priority,
          int_hdr_history,
          int_dta_history,
          int_fil_path,
          int_fil_prefix,
          int_fil_sequence,
          int_fil_extension,
          int_opr_alert,
          int_ema_group,
          int_search,
          int_procedure,
          int_status,
          int_usr_invocation,
          int_usr_validation,
          int_usr_message,
          int_lod_type,
          int_lod_group)
         values(rcd_lics_interface.int_interface,
                rcd_lics_interface.int_description,
                rcd_lics_interface.int_type,
                rcd_lics_interface.int_group,
                rcd_lics_interface.int_priority,
                rcd_lics_interface.int_hdr_history,
                rcd_lics_interface.int_dta_history,
                rcd_lics_interface.int_fil_path,
                rcd_lics_interface.int_fil_prefix,
                rcd_lics_interface.int_fil_sequence,
                rcd_lics_interface.int_fil_extension,
                rcd_lics_interface.int_opr_alert,
                rcd_lics_interface.int_ema_group,
                rcd_lics_interface.int_search,
                rcd_lics_interface.int_procedure,
                rcd_lics_interface.int_status,
                rcd_lics_interface.int_usr_invocation,
                rcd_lics_interface.int_usr_validation,
                rcd_lics_interface.int_usr_message,
                rcd_lics_interface.int_lod_type,
                rcd_lics_interface.int_lod_group);

      /*-*/
      /* Create the directory when required
      /*-*/
      if rcd_lics_interface.int_type = lics_constant.type_inbound or rcd_lics_interface.int_type = lics_constant.type_passthru then
         if rcd_lics_interface.int_lod_type = '*POLL' then
            lics_directory.create_directory(rcd_lics_interface.int_fil_path, lics_parameter.inbound_directory||lower(rcd_lics_interface.int_interface));
            lics_filesystem.execute_external_procedure(replace(lics_parameter.file_attribute_command,'<FILE>',lics_parameter.inbound_directory||lower(rcd_lics_interface.int_interface)));
         end if;
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
   function update_interface(par_interface in varchar2,
                             par_description in varchar2,
                             par_type in varchar2,
                             par_group in varchar2,
                             par_priority in number,
                             par_hdr_history in number,
                             par_dta_history in number,
                             par_fil_path in varchar2,
                             par_fil_prefix in varchar2,
                             par_fil_sequence in number,
                             par_fil_extension in varchar2,
                             par_opr_alert in varchar2,
                             par_ema_group in varchar2,
                             par_search in varchar2,
                             par_procedure in varchar2,
                             par_status in varchar2,
                             par_usr_invocation in varchar2,
                             par_usr_validation in varchar2,
                             par_usr_message in varchar2,
                             par_lod_type in varchar2,
                             par_lod_group in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_name_error boolean;
      var_sav_type varchar2(10);
      var_sav_path varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is 
         select *
           from lics_interface t01
          where t01.int_interface = rcd_lics_interface.int_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Interface Configuration - Update Interface';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_interface.int_interface := upper(par_interface);
      rcd_lics_interface.int_description := par_description;
      rcd_lics_interface.int_type := par_type;
      rcd_lics_interface.int_group := upper(par_group);
      rcd_lics_interface.int_priority := par_priority;
      rcd_lics_interface.int_hdr_history := par_hdr_history;
      rcd_lics_interface.int_dta_history := par_dta_history;
      rcd_lics_interface.int_fil_path := par_fil_path;
      rcd_lics_interface.int_fil_prefix := par_fil_prefix;
      rcd_lics_interface.int_fil_sequence := par_fil_sequence;
      rcd_lics_interface.int_fil_extension := par_fil_extension;
      rcd_lics_interface.int_opr_alert := par_opr_alert;
      rcd_lics_interface.int_ema_group := par_ema_group;
      rcd_lics_interface.int_search := par_search;
      rcd_lics_interface.int_procedure := par_procedure;
      rcd_lics_interface.int_status := par_status;
      rcd_lics_interface.int_usr_invocation := nvl(par_usr_invocation,lics_constant.status_inactive);
      rcd_lics_interface.int_usr_validation := par_usr_validation;
      rcd_lics_interface.int_usr_message := par_usr_message;
      rcd_lics_interface.int_lod_type := upper(par_lod_type);
      rcd_lics_interface.int_lod_group := upper(par_lod_group);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_lics_interface.int_interface is null then
         var_message := var_message || chr(13) || 'Interface must be specified';
      end if;
      if rcd_lics_interface.int_description is null then
         var_message := var_message || chr(13) || 'Description must be specified';
      end if;
      if rcd_lics_interface.int_type != lics_constant.type_inbound and
         rcd_lics_interface.int_type != lics_constant.type_outbound and
         rcd_lics_interface.int_type != lics_constant.type_passthru then
         var_message := var_message || chr(13) || 'Interface type must be *INBOUND, *OUTBOUND or *PASSTHRU';
      end if;
      if rcd_lics_interface.int_group is null then
         var_message := var_message || chr(13) || 'Interface group must be specified ';
      else
         var_name_error := false;
         for idx_count in 1..length(rcd_lics_interface.int_group) loop
            if substr(rcd_lics_interface.int_group, idx_count, 1) < 'A' or substr(rcd_lics_interface.int_group, idx_count, 1) > 'Z' then
               if substr(rcd_lics_interface.int_group, idx_count, 1) < '0' or substr(rcd_lics_interface.int_group, idx_count, 1) > '9' then
                  if substr(rcd_lics_interface.int_group, idx_count, 1) <> '_' then
                     var_name_error := true;
                  end if;
               end if;
            end if;
         end loop;
         if var_name_error = true then
            var_message := var_message || chr(13) || 'Interface group - characters must be A-Z, 0-9, _(underscore)';
         end if;
      end if;
      if rcd_lics_interface.int_type = lics_constant.type_inbound or rcd_lics_interface.int_type = lics_constant.type_passthru then
         if rcd_lics_interface.int_lod_type != '*PUSH' and rcd_lics_interface.int_lod_type != '*POLL' then
            var_message := var_message || chr(13) || 'Interface loading type must be *PUSH or *POLL for *INBOUND and *PASSTHRU';
         else
            if rcd_lics_interface.int_lod_type = '*POLL' then
               if rcd_lics_interface.int_lod_group is null or rcd_lics_interface.int_lod_group = '*NONE' then
                  var_message := var_message || chr(13) || 'Interface loading group must not be blank or *NONE for interface loading type *POLL';
               end if;
            else
               if rcd_lics_interface.int_lod_group != '*NONE' then
                  var_message := var_message || chr(13) || 'Interface loading group must be *NONE for interface loading type *PUSH';
               end if;
            end if;
         end if;
      else
         if rcd_lics_interface.int_lod_type != '*NONE' then
            var_message := var_message || chr(13) || 'Interface loading type must be *NONE for *OUTBOUND';
         end if;
         if rcd_lics_interface.int_lod_group != '*NONE' then
            var_message := var_message || chr(13) || 'Interface loading group must be *NONE for *OUTBOUND';
         end if;
      end if; 
      if rcd_lics_interface.int_priority <= 0 then
         var_message := var_message || chr(13) || 'Priority must be greater than zero';
      end if;
      if rcd_lics_interface.int_hdr_history <= 0 then
         var_message := var_message || chr(13) || 'Header history must be greater than zero';
      end if;
      if rcd_lics_interface.int_dta_history <= 0 then
         var_message := var_message || chr(13) || 'Data history must be greater than zero';
      end if;
      if rcd_lics_interface.int_fil_path is null then
         var_message := var_message || chr(13) || 'File path must be specified ';
      end if;
      if rcd_lics_interface.int_type = lics_constant.type_inbound then
         rcd_lics_interface.int_fil_prefix := null;
         rcd_lics_interface.int_fil_sequence := null;
         rcd_lics_interface.int_fil_extension := null;
      else
         if rcd_lics_interface.int_fil_prefix is null then
            rcd_lics_interface.int_fil_sequence := null;
            rcd_lics_interface.int_fil_extension := null;
         else
            if rcd_lics_interface.int_fil_sequence < 0 then
               var_message := var_message || chr(13) || 'File sequence must be greater than or equal to zero';
            end if;
            if rcd_lics_interface.int_fil_extension is null then
               var_message := var_message || chr(13) || 'File extension must be specified ';
            end if;
         end if;
      end if;
      if rcd_lics_interface.int_procedure is null then
         var_message := var_message || chr(13) || 'Processing procedure must be specified ';
      end if;
      if rcd_lics_interface.int_type = lics_constant.type_outbound then
         rcd_lics_interface.int_search := null;
      end if;
      if rcd_lics_interface.int_status != lics_constant.status_inactive and
         rcd_lics_interface.int_status != lics_constant.status_active then
         var_message := var_message || chr(13) || 'Status must be active or inactive';
      end if;
      if rcd_lics_interface.int_usr_invocation != lics_constant.status_inactive and
         rcd_lics_interface.int_usr_invocation != lics_constant.status_active then
         var_message := var_message || chr(13) || 'User invocation must be active or inactive';
      end if;

      /*-*/
      /* Interface must already exist and be the same type
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_lics_interface.int_interface || ') does not exist';
      end if;
      close csr_lics_interface_01;
      if rcd_lics_interface.int_type != rcd_lics_interface_01.int_type then
         var_message := var_message || chr(13) || 'Interface type must be the same as the existing interface type (' || rcd_lics_interface_01.int_type || ')';
      end if;
      var_sav_type := rcd_lics_interface_01.int_lod_type;
      var_sav_path := rcd_lics_interface_01.int_fil_path;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing interface
      /*-*/
      if rcd_lics_interface.int_type = lics_constant.type_inbound then
         rcd_lics_interface.int_fil_path := 'ICS_INBOUND';
         if rcd_lics_interface.int_lod_type = '*POLL' then
            rcd_lics_interface.int_fil_path := 'ICS_'||replace(rcd_lics_interface.int_interface,'.','#');
         end if;
      elsif rcd_lics_interface.int_type = lics_constant.type_passthru then
         rcd_lics_interface.int_fil_path := 'ICS_INBOUND';
         if rcd_lics_interface.int_lod_type = '*POLL' then
            rcd_lics_interface.int_fil_path := 'ICS_'||replace(rcd_lics_interface.int_interface,'.','#');
         end if;
      elsif rcd_lics_interface.int_type = lics_constant.type_outbound then
         rcd_lics_interface.int_fil_path := 'ICS_OUTBOUND';
      end if;
      update lics_interface
         set int_description = rcd_lics_interface.int_description,
             int_type = rcd_lics_interface.int_type,
             int_group = rcd_lics_interface.int_group,
             int_priority = rcd_lics_interface.int_priority,
             int_hdr_history = rcd_lics_interface.int_hdr_history,
             int_dta_history = rcd_lics_interface.int_dta_history,
             int_fil_path = rcd_lics_interface.int_fil_path,
             int_fil_prefix = rcd_lics_interface.int_fil_prefix,
             int_fil_sequence = rcd_lics_interface.int_fil_sequence,
             int_fil_extension = rcd_lics_interface.int_fil_extension,
             int_opr_alert = rcd_lics_interface.int_opr_alert,
             int_ema_group = rcd_lics_interface.int_ema_group,
             int_search = rcd_lics_interface.int_search,
             int_procedure = rcd_lics_interface.int_procedure,
             int_status = rcd_lics_interface.int_status,
             int_usr_invocation = rcd_lics_interface.int_usr_invocation,
             int_usr_validation = rcd_lics_interface.int_usr_validation,
             int_usr_message = rcd_lics_interface.int_usr_message,
             int_lod_type = rcd_lics_interface.int_lod_type,
             int_lod_group = rcd_lics_interface.int_lod_group
         where int_interface = rcd_lics_interface.int_interface;

      /*-*/
      /* Create or delete the directory when required
      /*-*/
      if rcd_lics_interface.int_type = lics_constant.type_inbound or rcd_lics_interface.int_type = lics_constant.type_passthru then
         if rcd_lics_interface.int_lod_type = '*POLL' and var_sav_type != '*POLL' then
            lics_directory.create_directory(rcd_lics_interface.int_fil_path, lics_parameter.inbound_directory||lower(rcd_lics_interface.int_interface));
            lics_filesystem.execute_external_procedure(replace(lics_parameter.file_attribute_command,'<FILE>',lics_parameter.inbound_directory||lower(rcd_lics_interface.int_interface)));
         elsif rcd_lics_interface.int_lod_type != '*POLL' and var_sav_type = '*POLL' then
            lics_directory.delete_directory(var_sav_path);
         end if;
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
   function delete_interface(par_interface in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is 
         select *
           from lics_interface t01
          where t01.int_interface = rcd_lics_interface.int_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

      cursor csr_lics_header_01 is 
         select 'x'
           from lics_header t01
          where t01.hea_interface = rcd_lics_interface.int_interface;
      rcd_lics_header_01 csr_lics_header_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Interface Configuration - Delete Interface';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_interface.int_interface := upper(par_interface);

      /*-*/
      /* Interface must already exist
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         var_message := var_message || chr(13) || 'Interface (' || rcd_lics_interface.int_interface || ') does not exist';
      end if;
      close csr_lics_interface_01;

      /*-*/
      /* Interface must have no header data
      /*-*/
      open csr_lics_header_01;
      fetch csr_lics_header_01 into rcd_lics_header_01;
      if csr_lics_header_01%found then
         var_message := var_message || chr(13) || 'Active interface (' || rcd_lics_interface.int_interface || ') has header history attached';
      end if;
      close csr_lics_header_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing interface data
      /*-*/
      delete from lics_rtg_detail
         where rde_interface = rcd_lics_interface.int_interface;
      delete from lics_int_reference
         where inr_interface = rcd_lics_interface.int_interface;
      delete from lics_int_sequence
         where ins_interface = rcd_lics_interface.int_interface;
      delete from lics_interface
         where int_interface = rcd_lics_interface.int_interface;

      /*-*/
      /* Delete the directory when required
      /*-*/
      if rcd_lics_interface_01.int_type = lics_constant.type_inbound or rcd_lics_interface_01.int_type = lics_constant.type_passthru then
         if rcd_lics_interface_01.int_lod_type = '*POLL'then
            lics_directory.delete_directory(rcd_lics_interface_01.int_fil_path);
         end if;
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
   end delete_interface;

end lics_interface_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_interface_configuration for lics_app.lics_interface_configuration;
grant execute on lics_interface_configuration to public;