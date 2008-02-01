/******************/
/* Package Header */
/******************/
create or replace package asn_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_configuration
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - asn_configuration - ASN Configuration Functionality

    YYYY/MM   Author          Description
    -------   ------          -----------
    2006/10   Steve Gregan    Created

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_source(par_source in varchar2,
                          par_description in varchar2,
                          par_identifier in varchar2,
                          par_procedure in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2,
                          par_alrt_type in varchar2,
                          par_alrt_time in number,
                          par_alrt_text in varchar2) return varchar2;
   function update_source(par_source in varchar2,
                          par_description in varchar2,
                          par_identifier in varchar2,
                          par_procedure in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2,
                          par_alrt_type in varchar2,
                          par_alrt_time in number,
                          par_alrt_text in varchar2) return varchar2;
   function delete_source(par_source in varchar2) return varchar2;
   function insert_target(par_target in varchar2,
                          par_description in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2) return varchar2;
   function update_target(par_target in varchar2,
                          par_description in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2) return varchar2;
   function delete_target(par_target in varchar2) return varchar2;
   function insert_route(par_source in varchar2,
                         par_target in varchar2,
                         par_procedure in varchar2,
                         par_warn_type in varchar2,
                         par_warn_time in number,
                         par_warn_text in varchar2,
                         par_alrt_type in varchar2,
                         par_alrt_time in number,
                         par_alrt_text in varchar2) return varchar2;
   function update_route(par_source in varchar2,
                         par_target in varchar2,
                         par_procedure in varchar2,
                         par_warn_type in varchar2,
                         par_warn_time in number,
                         par_warn_text in varchar2,
                         par_alrt_type in varchar2,
                         par_alrt_time in number,
                         par_alrt_text in varchar2) return varchar2;
   function delete_route(par_source in varchar2,
                         par_target in varchar2) return varchar2;
   function get_source_description(par_source in varchar2) return varchar2;
   function get_source_identifier(par_source in varchar2) return varchar2;
   function get_source_procedure(par_source in varchar2) return varchar2;
   function get_source_warn_type(par_source in varchar2) return varchar2;
   function get_source_warn_time(par_source in varchar2) return number;
   function get_source_warn_text(par_source in varchar2) return varchar2;
   function get_source_alrt_type(par_source in varchar2) return varchar2;
   function get_source_alrt_time(par_source in varchar2) return number;
   function get_source_alrt_text(par_source in varchar2) return varchar2;
   function get_target_description(par_target in varchar2) return varchar2;
   function get_target_warn_type(par_target in varchar2) return varchar2;
   function get_target_warn_time(par_target in varchar2) return number;
   function get_target_warn_text(par_target in varchar2) return varchar2;
   function get_route_procedure(par_source in varchar2, par_target in varchar2) return varchar2;
   function get_route_warn_type(par_source in varchar2, par_target in varchar2) return varchar2;
   function get_route_warn_time(par_source in varchar2, par_target in varchar2) return number;
   function get_route_warn_text(par_source in varchar2, par_target in varchar2) return varchar2;
   function get_route_alrt_type(par_source in varchar2, par_target in varchar2) return varchar2;
   function get_route_alrt_time(par_source in varchar2, par_target in varchar2) return number;
   function get_route_alrt_text(par_source in varchar2, par_target in varchar2) return varchar2;

end asn_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_asn_cfg_src asn_cfg_src%rowtype;
   rcd_asn_cfg_tar asn_cfg_tar%rowtype;
   rcd_asn_cfg_rte asn_cfg_rte%rowtype;

   /****************************************************/
   /* This function performs the insert source routine */
   /****************************************************/
   function insert_source(par_source in varchar2,
                          par_description in varchar2,
                          par_identifier in varchar2,
                          par_procedure in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2,
                          par_alrt_type in varchar2,
                          par_alrt_time in number,
                          par_alrt_text in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src_01 is 
         select *
           from asn_cfg_src t01
          where t01.cfs_src_code = rcd_asn_cfg_src.cfs_src_code;
      rcd_asn_cfg_src_01 csr_asn_cfg_src_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Insert Source';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_src.cfs_src_code := upper(par_source);
      rcd_asn_cfg_src.cfs_src_text := par_description;
      rcd_asn_cfg_src.cfs_src_iden := par_identifier;
      rcd_asn_cfg_src.cfs_msg_proc := par_procedure;
      rcd_asn_cfg_src.cfs_wrn_type := par_warn_type;
      rcd_asn_cfg_src.cfs_wrn_time := par_warn_time;
      rcd_asn_cfg_src.cfs_wrn_text := par_warn_text;
      rcd_asn_cfg_src.cfs_alt_type := par_alrt_type;
      rcd_asn_cfg_src.cfs_alt_time := par_alrt_time;
      rcd_asn_cfg_src.cfs_alt_text := par_alrt_text;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_src.cfs_src_code is null then
         var_message := var_message || chr(13) || 'Source code must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_src_text is null then
         var_message := var_message || chr(13) || 'Source description must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_src_iden is null then
         var_message := var_message || chr(13) || 'Source interchange identifier must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_msg_proc is null then
         var_message := var_message || chr(13) || 'Source default EDI procedure must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_wrn_type != '0' and
         rcd_asn_cfg_src.cfs_wrn_type != '1' then
         var_message := var_message || chr(13) || 'Source default warning type must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_wrn_type = '0' then
         rcd_asn_cfg_src.cfs_wrn_time := 0;
         rcd_asn_cfg_src.cfs_wrn_text := null;
      end if;
      if rcd_asn_cfg_src.cfs_wrn_type = '1' then
         if rcd_asn_cfg_src.cfs_wrn_text is null then
            var_message := var_message || chr(13) || 'Source default warning email group must be specified';
         end if;
         if rcd_asn_cfg_src.cfs_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Source default warning wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_src.cfs_alt_type != '0' and
         rcd_asn_cfg_src.cfs_alt_type != '1' and
         rcd_asn_cfg_src.cfs_alt_type != '2' then
         var_message := var_message || chr(13) || 'Source default alert type must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_alt_type = '0' then
         rcd_asn_cfg_src.cfs_alt_time := 0;
         rcd_asn_cfg_src.cfs_alt_text := null;
      end if;
      if rcd_asn_cfg_src.cfs_alt_type = '1' then
         if rcd_asn_cfg_src.cfs_alt_text is null then
            var_message := var_message || chr(13) || 'Source default alert email group must be specified';
         end if;
         if rcd_asn_cfg_src.cfs_alt_time = 0 then
            var_message := var_message || chr(13) || 'Source default alert wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_src.cfs_alt_type = '2' then
         if rcd_asn_cfg_src.cfs_alt_text is null then
            var_message := var_message || chr(13) || 'Source default alert alert text must be specified';
         end if;
         if rcd_asn_cfg_src.cfs_alt_time = 0 then
            var_message := var_message || chr(13) || 'Source default alert wait seconds must be specified';
         end if;
      end if;

      /*-*/
      /* Source must not already exist
      /*-*/
      open csr_asn_cfg_src_01;
      fetch csr_asn_cfg_src_01 into rcd_asn_cfg_src_01;
      if csr_asn_cfg_src_01%found then
         var_message := var_message || chr(13) || 'Source (' || rcd_asn_cfg_src.cfs_src_code || ') already exists';
      end if;
      close csr_asn_cfg_src_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new source
      /*-*/
      insert into asn_cfg_src
         (cfs_src_code,
          cfs_src_text,
          cfs_src_iden,
          cfs_msg_proc,
          cfs_wrn_type,
          cfs_wrn_time,
          cfs_wrn_text,
          cfs_alt_type,
          cfs_alt_time,
          cfs_alt_text)
         values(rcd_asn_cfg_src.cfs_src_code,
                rcd_asn_cfg_src.cfs_src_text,
                rcd_asn_cfg_src.cfs_src_iden,
                rcd_asn_cfg_src.cfs_msg_proc,
                rcd_asn_cfg_src.cfs_wrn_type,
                rcd_asn_cfg_src.cfs_wrn_time,
                rcd_asn_cfg_src.cfs_wrn_text,
                rcd_asn_cfg_src.cfs_alt_type,
                rcd_asn_cfg_src.cfs_alt_time,
                rcd_asn_cfg_src.cfs_alt_text);

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
   end insert_source;

   /****************************************************/
   /* This function performs the update source routine */
   /****************************************************/
   function update_source(par_source in varchar2,
                          par_description in varchar2,
                          par_identifier in varchar2,
                          par_procedure in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2,
                          par_alrt_type in varchar2,
                          par_alrt_time in number,
                          par_alrt_text in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src_01 is 
         select *
           from asn_cfg_src t01
          where t01.cfs_src_code = rcd_asn_cfg_src.cfs_src_code;
      rcd_asn_cfg_src_01 csr_asn_cfg_src_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Update Source';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_src.cfs_src_code := upper(par_source);
      rcd_asn_cfg_src.cfs_src_text := par_description;
      rcd_asn_cfg_src.cfs_src_iden := par_identifier;
      rcd_asn_cfg_src.cfs_msg_proc := par_procedure;
      rcd_asn_cfg_src.cfs_wrn_type := par_warn_type;
      rcd_asn_cfg_src.cfs_wrn_time := par_warn_time;
      rcd_asn_cfg_src.cfs_wrn_text := par_warn_text;
      rcd_asn_cfg_src.cfs_alt_type := par_alrt_type;
      rcd_asn_cfg_src.cfs_alt_time := par_alrt_time;
      rcd_asn_cfg_src.cfs_alt_text := par_alrt_text;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_src.cfs_src_code is null then
         var_message := var_message || chr(13) || 'Source code must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_src_text is null then
         var_message := var_message || chr(13) || 'Source description must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_src_iden is null then
         var_message := var_message || chr(13) || 'Source interchange identifier must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_msg_proc is null then
         var_message := var_message || chr(13) || 'Source default EDI procedure must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_wrn_type != '0' and
         rcd_asn_cfg_src.cfs_wrn_type != '1' then
         var_message := var_message || chr(13) || 'Source default warning type must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_wrn_type = '0' then
         rcd_asn_cfg_src.cfs_wrn_time := 0;
         rcd_asn_cfg_src.cfs_wrn_text := null;
      end if;
      if rcd_asn_cfg_src.cfs_wrn_type = '1' then
         if rcd_asn_cfg_src.cfs_wrn_text is null then
            var_message := var_message || chr(13) || 'Source default warning email group must be specified';
         end if;
         if rcd_asn_cfg_src.cfs_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Source default warning wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_src.cfs_alt_type != '0' and
         rcd_asn_cfg_src.cfs_alt_type != '1' and
         rcd_asn_cfg_src.cfs_alt_type != '2' then
         var_message := var_message || chr(13) || 'Source default alert type must be specified';
      end if;
      if rcd_asn_cfg_src.cfs_alt_type = '0' then
         rcd_asn_cfg_src.cfs_alt_time := 0;
         rcd_asn_cfg_src.cfs_alt_text := null;
      end if;
      if rcd_asn_cfg_src.cfs_alt_type = '1' then
         if rcd_asn_cfg_src.cfs_alt_text is null then
            var_message := var_message || chr(13) || 'Source default alert email group must be specified';
         end if;
         if rcd_asn_cfg_src.cfs_alt_time = 0 then
            var_message := var_message || chr(13) || 'Source default alert wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_src.cfs_alt_type = '2' then
         if rcd_asn_cfg_src.cfs_alt_text is null then
            var_message := var_message || chr(13) || 'Source default alert alert text must be specified';
         end if;
         if rcd_asn_cfg_src.cfs_alt_time = 0 then
            var_message := var_message || chr(13) || 'Source default alert wait seconds must be specified';
         end if;
      end if;

      /*-*/
      /* Source must already exist
      /*-*/
      open csr_asn_cfg_src_01;
      fetch csr_asn_cfg_src_01 into rcd_asn_cfg_src_01;
      if csr_asn_cfg_src_01%notfound then
         var_message := var_message || chr(13) || 'Source (' || rcd_asn_cfg_src.cfs_src_code || ') does not exist';
      end if;
      close csr_asn_cfg_src_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing source
      /*-*/
      update asn_cfg_src
         set cfs_src_text = rcd_asn_cfg_src.cfs_src_text,
             cfs_src_iden = rcd_asn_cfg_src.cfs_src_iden,
             cfs_msg_proc = rcd_asn_cfg_src.cfs_msg_proc,
             cfs_wrn_type = rcd_asn_cfg_src.cfs_wrn_type,
             cfs_wrn_time = rcd_asn_cfg_src.cfs_wrn_time,
             cfs_wrn_text = rcd_asn_cfg_src.cfs_wrn_text,
             cfs_alt_type = rcd_asn_cfg_src.cfs_alt_type,
             cfs_alt_time = rcd_asn_cfg_src.cfs_alt_time,
             cfs_alt_text = rcd_asn_cfg_src.cfs_alt_text
         where cfs_src_code = rcd_asn_cfg_src.cfs_src_code;

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
   end update_source;

   /****************************************************/
   /* This function performs the delete source routine */
   /****************************************************/
   function delete_source(par_source in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src_01 is 
         select *
           from asn_cfg_src t01
          where t01.cfs_src_code = rcd_asn_cfg_src.cfs_src_code;
      rcd_asn_cfg_src_01 csr_asn_cfg_src_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Delete Source';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_src.cfs_src_code := upper(par_source);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_src.cfs_src_code is null then
         var_message := var_message || chr(13) || 'Source code must be specified';
      end if;

      /*-*/
      /* Source must already exist
      /*-*/
      open csr_asn_cfg_src_01;
      fetch csr_asn_cfg_src_01 into rcd_asn_cfg_src_01;
      if csr_asn_cfg_src_01%notfound then
         var_message := var_message || chr(13) || 'Source (' || rcd_asn_cfg_src.cfs_src_code || ') does not exist';
      end if;
      close csr_asn_cfg_src_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing source
      /*-*/
      delete from asn_cfg_src
         where cfs_src_code = rcd_asn_cfg_src.cfs_src_code;
      delete from asn_cfg_rte
         where cfr_src_code = rcd_asn_cfg_src.cfs_src_code;

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
   end delete_source;

   /****************************************************/
   /* This function performs the insert target routine */
   /****************************************************/
   function insert_target(par_target in varchar2,
                          par_description in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar_01 is 
         select *
           from asn_cfg_tar t01
          where t01.cft_tar_code = rcd_asn_cfg_tar.cft_tar_code;
      rcd_asn_cfg_tar_01 csr_asn_cfg_tar_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Insert Target';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_tar.cft_tar_code := upper(par_target);
      rcd_asn_cfg_tar.cft_tar_text := par_description;
      rcd_asn_cfg_tar.cft_wrn_type := par_warn_type;
      rcd_asn_cfg_tar.cft_wrn_time := par_warn_time;
      rcd_asn_cfg_tar.cft_wrn_text := par_warn_text;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_tar.cft_tar_code is null then
         var_message := var_message || chr(13) || 'Target code must be specified';
      end if;
      if rcd_asn_cfg_tar.cft_tar_text is null then
         var_message := var_message || chr(13) || 'Target description must be specified';
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type != '0' and
         rcd_asn_cfg_tar.cft_wrn_type != '1' and
         rcd_asn_cfg_tar.cft_wrn_type != '2' then
         var_message := var_message || chr(13) || 'Target acknowledgement warning type must be specified';
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type = '0' then
         rcd_asn_cfg_tar.cft_wrn_time := 0;
         rcd_asn_cfg_tar.cft_wrn_text := null;
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type = '1' then
         if rcd_asn_cfg_tar.cft_wrn_text is null then
            var_message := var_message || chr(13) || 'Target acknowledgement warning email group must be specified';
         end if;
         if rcd_asn_cfg_tar.cft_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Target acknowledgement warning wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type = '2' then
         if rcd_asn_cfg_tar.cft_wrn_text is null then
            var_message := var_message || chr(13) || 'Target acknowledgement warning alert text must be specified';
         end if;
         if rcd_asn_cfg_tar.cft_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Target acknowledgement warning wait seconds must be specified';
         end if;
      end if;

      /*-*/
      /* Target must not already exist
      /*-*/
      open csr_asn_cfg_tar_01;
      fetch csr_asn_cfg_tar_01 into rcd_asn_cfg_tar_01;
      if csr_asn_cfg_tar_01%found then
         var_message := var_message || chr(13) || 'Target (' || rcd_asn_cfg_tar.cft_tar_code || ') already exists';
      end if;
      close csr_asn_cfg_tar_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new target
      /*-*/
      insert into asn_cfg_tar
         (cft_tar_code,
          cft_tar_text,
          cft_wrn_type,
          cft_wrn_time,
          cft_wrn_text)
         values(rcd_asn_cfg_tar.cft_tar_code,
                rcd_asn_cfg_tar.cft_tar_text,
                rcd_asn_cfg_tar.cft_wrn_type,
                rcd_asn_cfg_tar.cft_wrn_time,
                rcd_asn_cfg_tar.cft_wrn_text);

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
   end insert_target;

   /****************************************************/
   /* This function performs the update target routine */
   /****************************************************/
   function update_target(par_target in varchar2,
                          par_description in varchar2,
                          par_warn_type in varchar2,
                          par_warn_time in number,
                          par_warn_text in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar_01 is 
         select *
           from asn_cfg_tar t01
          where t01.cft_tar_code = rcd_asn_cfg_tar.cft_tar_code;
      rcd_asn_cfg_tar_01 csr_asn_cfg_tar_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Update Target';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_tar.cft_tar_code := upper(par_target);
      rcd_asn_cfg_tar.cft_tar_text := par_description;
      rcd_asn_cfg_tar.cft_wrn_type := par_warn_type;
      rcd_asn_cfg_tar.cft_wrn_time := par_warn_time;
      rcd_asn_cfg_tar.cft_wrn_text := par_warn_text;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_tar.cft_tar_code is null then
         var_message := var_message || chr(13) || 'Target code must be specified';
      end if;
      if rcd_asn_cfg_tar.cft_tar_text is null then
         var_message := var_message || chr(13) || 'Target description must be specified';
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type != '0' and
         rcd_asn_cfg_tar.cft_wrn_type != '1' and
         rcd_asn_cfg_tar.cft_wrn_type != '2' then
         var_message := var_message || chr(13) || 'Target acknowledgement warning type must be specified';
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type = '0' then
         rcd_asn_cfg_tar.cft_wrn_time := 0;
         rcd_asn_cfg_tar.cft_wrn_text := null;
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type = '1' then
         if rcd_asn_cfg_tar.cft_wrn_text is null then
            var_message := var_message || chr(13) || 'Target acknowledgement warning email group must be specified';
         end if;
         if rcd_asn_cfg_tar.cft_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Target acknowledgement warning wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_tar.cft_wrn_type = '2' then
         if rcd_asn_cfg_tar.cft_wrn_text is null then
            var_message := var_message || chr(13) || 'Target acknowledgement warning alert text must be specified';
         end if;
         if rcd_asn_cfg_tar.cft_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Target acknowledgement warning wait seconds must be specified';
         end if;
      end if;

      /*-*/
      /* Target must already exist
      /*-*/
      open csr_asn_cfg_tar_01;
      fetch csr_asn_cfg_tar_01 into rcd_asn_cfg_tar_01;
      if csr_asn_cfg_tar_01%notfound then
         var_message := var_message || chr(13) || 'Target (' || rcd_asn_cfg_tar.cft_tar_code || ') does not exist';
      end if;
      close csr_asn_cfg_tar_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing target
      /*-*/
      update asn_cfg_tar
         set cft_tar_text = rcd_asn_cfg_tar.cft_tar_text,
             cft_wrn_type = rcd_asn_cfg_tar.cft_wrn_type,
             cft_wrn_time = rcd_asn_cfg_tar.cft_wrn_time,
             cft_wrn_text = rcd_asn_cfg_tar.cft_wrn_text
         where cft_tar_code = rcd_asn_cfg_tar.cft_tar_code;

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
   end update_target;

   /****************************************************/
   /* This function performs the delete target routine */
   /****************************************************/
   function delete_target(par_target in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar_01 is 
         select *
           from asn_cfg_tar t01
          where t01.cft_tar_code = rcd_asn_cfg_tar.cft_tar_code;
      rcd_asn_cfg_tar_01 csr_asn_cfg_tar_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Delete Target';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_tar.cft_tar_code := upper(par_target);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_tar.cft_tar_code is null then
         var_message := var_message || chr(13) || 'Target code must be specified';
      end if;

      /*-*/
      /* Target must already exist
      /*-*/
      open csr_asn_cfg_tar_01;
      fetch csr_asn_cfg_tar_01 into rcd_asn_cfg_tar_01;
      if csr_asn_cfg_tar_01%notfound then
         var_message := var_message || chr(13) || 'Target (' || rcd_asn_cfg_tar.cft_tar_code || ') does not exist';
      end if;
      close csr_asn_cfg_tar_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing target
      /*-*/
      delete from asn_cfg_tar
         where cft_tar_code = rcd_asn_cfg_tar.cft_tar_code;
      delete from asn_cfg_rte
         where cfr_tar_code = rcd_asn_cfg_tar.cft_tar_code;

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
   end delete_target;

   /**************************************************/
   /* This function performs the insert route rouine */
   /**************************************************/
   function insert_route(par_source in varchar2,
                         par_target in varchar2,
                         par_procedure in varchar2,
                         par_warn_type in varchar2,
                         par_warn_time in number,
                         par_warn_text in varchar2,
                         par_alrt_type in varchar2,
                         par_alrt_time in number,
                         par_alrt_text in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte_01 is 
         select *
           from asn_cfg_rte t01
          where t01.cfr_src_code = rcd_asn_cfg_rte.cfr_src_code
            and t01.cfr_tar_code = rcd_asn_cfg_rte.cfr_tar_code;
      rcd_asn_cfg_rte_01 csr_asn_cfg_rte_01%rowtype;

      cursor csr_asn_cfg_src is 
         select *
           from asn_cfg_src t01
          where t01.cfs_src_code = rcd_asn_cfg_rte.cfr_src_code;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

      cursor csr_asn_cfg_tar is 
         select *
           from asn_cfg_tar t01
          where t01.cft_tar_code = rcd_asn_cfg_rte.cfr_tar_code;
      rcd_asn_cfg_tar csr_asn_cfg_tar%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Insert Route';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_rte.cfr_src_code := upper(par_source);
      rcd_asn_cfg_rte.cfr_tar_code := upper(par_target);
      rcd_asn_cfg_rte.cfr_msg_proc := par_procedure;
      rcd_asn_cfg_rte.cfr_wrn_type := par_warn_type;
      rcd_asn_cfg_rte.cfr_wrn_time := par_warn_time;
      rcd_asn_cfg_rte.cfr_wrn_text := par_warn_text;
      rcd_asn_cfg_rte.cfr_alt_type := par_alrt_type;
      rcd_asn_cfg_rte.cfr_alt_time := par_alrt_time;
      rcd_asn_cfg_rte.cfr_alt_text := par_alrt_text;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_rte.cfr_src_code is null then
         var_message := var_message || chr(13) || 'Source code must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_tar_code is null then
         var_message := var_message || chr(13) || 'Target code must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_msg_proc is null then
         var_message := var_message || chr(13) || 'Route EDI procedure must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_wrn_type != '0' and
         rcd_asn_cfg_rte.cfr_wrn_type != '1' then
         var_message := var_message || chr(13) || 'Route warning type must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_wrn_type = '0' then
         rcd_asn_cfg_rte.cfr_wrn_time := 0;
         rcd_asn_cfg_rte.cfr_wrn_text := null;
      end if;
      if rcd_asn_cfg_rte.cfr_wrn_type = '1' then
         if rcd_asn_cfg_rte.cfr_wrn_text is null then
            var_message := var_message || chr(13) || 'Route warning email group must be specified';
         end if;
         if rcd_asn_cfg_rte.cfr_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Route warning wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type != '0' and
         rcd_asn_cfg_rte.cfr_alt_type != '1' and
         rcd_asn_cfg_rte.cfr_alt_type != '2' then
         var_message := var_message || chr(13) || 'Route alert type must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type = '0' then
         rcd_asn_cfg_rte.cfr_alt_time := 0;
         rcd_asn_cfg_rte.cfr_alt_text := null;
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type = '1' then
         if rcd_asn_cfg_rte.cfr_alt_text is null then
            var_message := var_message || chr(13) || 'Route alert email group must be specified';
         end if;
         if rcd_asn_cfg_rte.cfr_alt_time = 0 then
            var_message := var_message || chr(13) || 'Route alert wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type = '2' then
         if rcd_asn_cfg_rte.cfr_alt_text is null then
            var_message := var_message || chr(13) || 'Route alert alert text must be specified';
         end if;
         if rcd_asn_cfg_rte.cfr_alt_time = 0 then
            var_message := var_message || chr(13) || 'Route alert wait seconds must be specified';
         end if;
      end if;

      /*-*/
      /* Source must exist
      /*-*/
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%notfound then
         var_message := var_message || chr(13) || 'Source (' || rcd_asn_cfg_rte.cfr_src_code || ') does not exist';
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Target must exist
      /*-*/
      open csr_asn_cfg_tar;
      fetch csr_asn_cfg_tar into rcd_asn_cfg_tar;
      if csr_asn_cfg_tar%notfound then
         var_message := var_message || chr(13) || 'Target (' || rcd_asn_cfg_rte.cfr_tar_code || ') does not exist';
      end if;
      close csr_asn_cfg_tar;

      /*-*/
      /* Route must not already exist
      /*-*/
      open csr_asn_cfg_rte_01;
      fetch csr_asn_cfg_rte_01 into rcd_asn_cfg_rte_01;
      if csr_asn_cfg_rte_01%found then
         var_message := var_message || chr(13) || 'Route (' || rcd_asn_cfg_rte.cfr_src_code || ' to ' || rcd_asn_cfg_rte.cfr_tar_code || ') already exists';
      end if;
      close csr_asn_cfg_rte_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new route
      /*-*/
      insert into asn_cfg_rte
         (cfr_src_code,
          cfr_tar_code,
          cfr_msg_proc,
          cfr_wrn_type,
          cfr_wrn_time,
          cfr_wrn_text,
          cfr_alt_type,
          cfr_alt_time,
          cfr_alt_text)
         values(rcd_asn_cfg_rte.cfr_src_code,
                rcd_asn_cfg_rte.cfr_tar_code,
                rcd_asn_cfg_rte.cfr_msg_proc,
                rcd_asn_cfg_rte.cfr_wrn_type,
                rcd_asn_cfg_rte.cfr_wrn_time,
                rcd_asn_cfg_rte.cfr_wrn_text,
                rcd_asn_cfg_rte.cfr_alt_type,
                rcd_asn_cfg_rte.cfr_alt_time,
                rcd_asn_cfg_rte.cfr_alt_text);

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
   end insert_route;

   /***************************************************/
   /* This function performs the update route routine */
   /***************************************************/
   function update_route(par_source in varchar2,
                         par_target in varchar2,
                         par_procedure in varchar2,
                         par_warn_type in varchar2,
                         par_warn_time in number,
                         par_warn_text in varchar2,
                         par_alrt_type in varchar2,
                         par_alrt_time in number,
                         par_alrt_text in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte_01 is 
         select *
           from asn_cfg_rte t01
          where t01.cfr_src_code = rcd_asn_cfg_rte.cfr_src_code
            and t01.cfr_tar_code = rcd_asn_cfg_rte.cfr_tar_code;
      rcd_asn_cfg_rte_01 csr_asn_cfg_rte_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Update Route';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_rte.cfr_src_code := upper(par_source);
      rcd_asn_cfg_rte.cfr_tar_code := upper(par_target);
      rcd_asn_cfg_rte.cfr_msg_proc := par_procedure;
      rcd_asn_cfg_rte.cfr_wrn_type := par_warn_type;
      rcd_asn_cfg_rte.cfr_wrn_time := par_warn_time;
      rcd_asn_cfg_rte.cfr_wrn_text := par_warn_text;
      rcd_asn_cfg_rte.cfr_alt_type := par_alrt_type;
      rcd_asn_cfg_rte.cfr_alt_time := par_alrt_time;
      rcd_asn_cfg_rte.cfr_alt_text := par_alrt_text;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_rte.cfr_src_code is null then
         var_message := var_message || chr(13) || 'Source code must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_tar_code is null then
         var_message := var_message || chr(13) || 'Target code must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_msg_proc is null then
         var_message := var_message || chr(13) || 'Route EDI procedure must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_wrn_type != '0' and
         rcd_asn_cfg_rte.cfr_wrn_type != '1' then
         var_message := var_message || chr(13) || 'Route warning type must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_wrn_type = '0' then
         rcd_asn_cfg_rte.cfr_wrn_time := 0;
         rcd_asn_cfg_rte.cfr_wrn_text := null;
      end if;
      if rcd_asn_cfg_rte.cfr_wrn_type = '1' then
         if rcd_asn_cfg_rte.cfr_wrn_text is null then
            var_message := var_message || chr(13) || 'Route warning email group must be specified';
         end if;
         if rcd_asn_cfg_rte.cfr_wrn_time = 0 then
            var_message := var_message || chr(13) || 'Route warning wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type != '0' and
         rcd_asn_cfg_rte.cfr_alt_type != '1' and
         rcd_asn_cfg_rte.cfr_alt_type != '2' then
         var_message := var_message || chr(13) || 'Route alert type must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type = '0' then
         rcd_asn_cfg_rte.cfr_alt_time := 0;
         rcd_asn_cfg_rte.cfr_alt_text := null;
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type = '1' then
         if rcd_asn_cfg_rte.cfr_alt_text is null then
            var_message := var_message || chr(13) || 'Route alert email group must be specified';
         end if;
         if rcd_asn_cfg_rte.cfr_alt_time = 0 then
            var_message := var_message || chr(13) || 'Route alert wait seconds must be specified';
         end if;
      end if;
      if rcd_asn_cfg_rte.cfr_alt_type = '2' then
         if rcd_asn_cfg_rte.cfr_alt_text is null then
            var_message := var_message || chr(13) || 'Route alert alert text must be specified';
         end if;
         if rcd_asn_cfg_rte.cfr_alt_time = 0 then
            var_message := var_message || chr(13) || 'Route alert wait seconds must be specified';
         end if;
      end if;

      /*-*/
      /* Route must already exist
      /*-*/
      open csr_asn_cfg_rte_01;
      fetch csr_asn_cfg_rte_01 into rcd_asn_cfg_rte_01;
      if csr_asn_cfg_rte_01%notfound then
         var_message := var_message || chr(13) || 'Route (' || rcd_asn_cfg_rte.cfr_src_code || ' to ' || rcd_asn_cfg_rte.cfr_tar_code || ') does not exist';
      end if;
      close csr_asn_cfg_rte_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing route
      /*-*/
      update asn_cfg_rte
         set cfr_msg_proc = rcd_asn_cfg_rte.cfr_msg_proc,
             cfr_wrn_type = rcd_asn_cfg_rte.cfr_wrn_type,
             cfr_wrn_time = rcd_asn_cfg_rte.cfr_wrn_time,
             cfr_wrn_text = rcd_asn_cfg_rte.cfr_wrn_text,
             cfr_alt_type = rcd_asn_cfg_rte.cfr_alt_type,
             cfr_alt_time = rcd_asn_cfg_rte.cfr_alt_time,
             cfr_alt_text = rcd_asn_cfg_rte.cfr_alt_text
         where cfr_src_code = rcd_asn_cfg_rte.cfr_src_code
           and cfr_tar_code = rcd_asn_cfg_rte.cfr_tar_code;

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
   end update_route;

   /***************************************************/
   /* This function performs the delete route routine */
   /***************************************************/
   function delete_route(par_source in varchar2,
                         par_target in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte_01 is 
         select *
           from asn_cfg_rte t01
          where t01.cfr_src_code = rcd_asn_cfg_rte.cfr_src_code
            and t01.cfr_tar_code = rcd_asn_cfg_rte.cfr_tar_code;
      rcd_asn_cfg_rte_01 csr_asn_cfg_rte_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Configuration - Delete Route';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_asn_cfg_rte.cfr_src_code := upper(par_source);
      rcd_asn_cfg_rte.cfr_tar_code := upper(par_target);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_asn_cfg_rte.cfr_src_code is null then
         var_message := var_message || chr(13) || 'Source code must be specified';
      end if;
      if rcd_asn_cfg_rte.cfr_tar_code is null then
         var_message := var_message || chr(13) || 'Target code must be specified';
      end if;

      /*-*/
      /* Route must already exist
      /*-*/
      open csr_asn_cfg_rte_01;
      fetch csr_asn_cfg_rte_01 into rcd_asn_cfg_rte_01;
      if csr_asn_cfg_rte_01%notfound then
         var_message := var_message || chr(13) || 'Route (' || rcd_asn_cfg_rte.cfr_src_code || ' to ' || rcd_asn_cfg_rte.cfr_tar_code || ') does not exist';
      end if;
      close csr_asn_cfg_rte_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing route
      /*-*/
      delete from asn_cfg_rte
         where cfr_src_code = rcd_asn_cfg_rte.cfr_src_code
           and cfr_tar_code = rcd_asn_cfg_rte.cfr_tar_code;

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
   end delete_route;

   /*****************************************************/
   /* This function performs the get source description */
   /*****************************************************/
   function get_source_description(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_src_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_src_text
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source description
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_src_text;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_description;

   /****************************************************/
   /* This function performs the get source identifier */
   /****************************************************/
   function get_source_identifier(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_src_iden%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_src_iden
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source identifier
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_src_iden;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_identifier;

   /***************************************************/
   /* This function performs the get source procedure */
   /***************************************************/
   function get_source_procedure(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_msg_proc%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_msg_proc
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source procedure
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_msg_proc;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_procedure;

   /******************************************************/
   /* This function performs the get source warning type */
   /******************************************************/
   function get_source_warn_type(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_wrn_type%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_wrn_type
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source warning type
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_wrn_type;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_warn_type;

   /******************************************************/
   /* This function performs the get source warning time */
   /******************************************************/
   function get_source_warn_time(par_source in varchar2) return number is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_wrn_time%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_wrn_time
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source warning time
      /*-*/
      var_return := 0;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_wrn_time;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_warn_time;

   /******************************************************/
   /* This function performs the get source warning text */
   /******************************************************/
   function get_source_warn_text(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_wrn_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_wrn_text
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source warning text
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_wrn_text;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_warn_text;

   /****************************************************/
   /* This function performs the get source alert type */
   /****************************************************/
   function get_source_alrt_type(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_alt_type%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_alt_type
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source alert type
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_alt_type;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_alrt_type;

   /****************************************************/
   /* This function performs the get source alert time */
   /****************************************************/
   function get_source_alrt_time(par_source in varchar2) return number is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_alt_time%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_alt_time
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source alert time
      /*-*/
      var_return := 0;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_alt_time;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_alrt_time;

   /****************************************************/
   /* This function performs the get source alert text */
   /****************************************************/
   function get_source_alrt_text(par_source in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_src.cfs_alt_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_src is 
         select t01.cfs_alt_text
           from asn_cfg_src t01
          where t01.cfs_src_code = par_source;
      rcd_asn_cfg_src csr_asn_cfg_src%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the source alert text
      /*-*/
      var_return := null;
      open csr_asn_cfg_src;
      fetch csr_asn_cfg_src into rcd_asn_cfg_src;
      if csr_asn_cfg_src%found then
         var_return := rcd_asn_cfg_src.cfs_alt_text;
      end if;
      close csr_asn_cfg_src;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_source_alrt_text;

   /*****************************************************/
   /* This function performs the get target description */
   /*****************************************************/
   function get_target_description(par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_tar.cft_tar_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar is 
         select t01.cft_tar_text
           from asn_cfg_tar t01
          where t01.cft_tar_code = par_target;
      rcd_asn_cfg_tar csr_asn_cfg_tar%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the target description
      /*-*/
      var_return := null;
      open csr_asn_cfg_tar;
      fetch csr_asn_cfg_tar into rcd_asn_cfg_tar;
      if csr_asn_cfg_tar%found then
         var_return := rcd_asn_cfg_tar.cft_tar_text;
      end if;
      close csr_asn_cfg_tar;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_target_description;

   /******************************************************/
   /* This function performs the get target warning type */
   /******************************************************/
   function get_target_warn_type(par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_tar.cft_wrn_type%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar is 
         select t01.cft_wrn_type
           from asn_cfg_tar t01
          where t01.cft_tar_code = par_target;
      rcd_asn_cfg_tar csr_asn_cfg_tar%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the target warning type
      /*-*/
      var_return := null;
      open csr_asn_cfg_tar;
      fetch csr_asn_cfg_tar into rcd_asn_cfg_tar;
      if csr_asn_cfg_tar%found then
         var_return := rcd_asn_cfg_tar.cft_wrn_type;
      end if;
      close csr_asn_cfg_tar;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_target_warn_type;

   /******************************************************/
   /* This function performs the get target warning time */
   /******************************************************/
   function get_target_warn_time(par_target in varchar2) return number is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_tar.cft_wrn_time%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar is 
         select t01.cft_wrn_time
           from asn_cfg_tar t01
          where t01.cft_tar_code = par_target;
      rcd_asn_cfg_tar csr_asn_cfg_tar%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the target warning time
      /*-*/
      var_return := 0;
      open csr_asn_cfg_tar;
      fetch csr_asn_cfg_tar into rcd_asn_cfg_tar;
      if csr_asn_cfg_tar%found then
         var_return := rcd_asn_cfg_tar.cft_wrn_time;
      end if;
      close csr_asn_cfg_tar;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_target_warn_time;

   /******************************************************/
   /* This function performs the get target warning text */
   /******************************************************/
   function get_target_warn_text(par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_tar.cft_wrn_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_tar is 
         select t01.cft_wrn_text
           from asn_cfg_tar t01
          where t01.cft_tar_code = par_target;
      rcd_asn_cfg_tar csr_asn_cfg_tar%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the target warning text
      /*-*/
      var_return := null;
      open csr_asn_cfg_tar;
      fetch csr_asn_cfg_tar into rcd_asn_cfg_tar;
      if csr_asn_cfg_tar%found then
         var_return := rcd_asn_cfg_tar.cft_wrn_text;
      end if;
      close csr_asn_cfg_tar;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_target_warn_text;

   /**************************************************/
   /* This function performs the get route procedure */
   /**************************************************/
   function get_route_procedure(par_source in varchar2, par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_msg_proc%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_msg_proc
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route procedure
      /*-*/
      var_return := null;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_msg_proc;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_procedure;

   /*****************************************************/
   /* This function performs the get route warning type */
   /*****************************************************/
   function get_route_warn_type(par_source in varchar2, par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_wrn_type%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_wrn_type
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route warning type
      /*-*/
      var_return := null;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_wrn_type;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_warn_type;

   /*****************************************************/
   /* This function performs the get route warning time */
   /*****************************************************/
   function get_route_warn_time(par_source in varchar2, par_target in varchar2) return number is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_wrn_time%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_wrn_time
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route warning time
      /*-*/
      var_return := 0;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_wrn_time;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_warn_time;

   /*****************************************************/
   /* This function performs the get route warning text */
   /*****************************************************/
   function get_route_warn_text(par_source in varchar2, par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_wrn_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_wrn_text
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route warning text
      /*-*/
      var_return := null;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_wrn_text;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_warn_text;

   /***************************************************/
   /* This function performs the get route alert type */
   /***************************************************/
   function get_route_alrt_type(par_source in varchar2, par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_alt_type%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_alt_type
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route alert type
      /*-*/
      var_return := null;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_alt_type;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_alrt_type;

   /***************************************************/
   /* This function performs the get route alert time */
   /***************************************************/
   function get_route_alrt_time(par_source in varchar2, par_target in varchar2) return number is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_alt_time%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_alt_time
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route alert time
      /*-*/
      var_return := 0;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_alt_time;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_alrt_time;

   /***************************************************/
   /* This function performs the get route alert text */
   /***************************************************/
   function get_route_alrt_text(par_source in varchar2, par_target in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_cfg_rte.cfr_alt_text%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_cfg_rte is 
         select t01.cfr_alt_text
           from asn_cfg_rte t01
          where t01.cfr_src_code = par_source
            and t01.cfr_tar_code = par_target;
      rcd_asn_cfg_rte csr_asn_cfg_rte%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the route alert text
      /*-*/
      var_return := null;
      open csr_asn_cfg_rte;
      fetch csr_asn_cfg_rte into rcd_asn_cfg_rte;
      if csr_asn_cfg_rte%found then
         var_return := rcd_asn_cfg_rte.cfr_alt_text;
      end if;
      close csr_asn_cfg_rte;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_route_alrt_text;

end asn_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_configuration for ics_app.asn_configuration;
grant execute on asn_configuration to public;