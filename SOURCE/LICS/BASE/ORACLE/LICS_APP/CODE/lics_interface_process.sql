/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_interface_process
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Interface Process

 The package implements the interface process functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_interface_process as

   /**/
   /* Public declarations
   /**/
   function update_status(par_header in number) return varchar2;

end lics_interface_process;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_interface_process as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_header lics_header%rowtype;

   /****************************************************/
   /* This function performs the update status routine */
   /****************************************************/
   function update_status(par_header in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_header_01 is 
         select t01.hea_header,
                t01.hea_fil_name,
                t01.hea_status,
                t02.int_type,
                t02.int_group,
                t02.int_fil_path
           from lics_header t01,
                lics_interface t02
          where t01.hea_interface = t02.int_interface(+)
            and t01.hea_header = rcd_lics_header.hea_header;
      rcd_lics_header_01 csr_lics_header_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Interface Process - Update Status';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_header.hea_header := par_header;

      /*-*/
      /* Header must exist with correct status
      /*-*/
      open csr_lics_header_01;
      fetch csr_lics_header_01 into rcd_lics_header_01;
      if csr_lics_header_01%notfound then
         var_message := var_message || chr(13) || 'Interface header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist';
      end if;
      close csr_lics_header_01;
      if rcd_lics_header_01.hea_status != lics_constant.header_process_completed and
         rcd_lics_header_01.hea_status != lics_constant.header_process_completed_error then
         var_message := var_message || chr(13) || 'Interface header status must be process completed or process completed error';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /**/
      /* Execute the file restore script
      /* - (restores the file from archive)
      /**/
      if rcd_lics_header_01.int_type != '*INBOUND' then
         if rcd_lics_header_01.int_fil_path = 'ICS_INBOUND' then
            java_utility.execute_external_procedure(lics_parameter.restore_script || ' ' || rcd_lics_header_01.hea_fil_name || ' INBOUND');
         else
            java_utility.execute_external_procedure(lics_parameter.restore_script || ' ' || rcd_lics_header_01.hea_fil_name || ' OUTBOUND');
         end if;
      end if;

      /*-*/
      /* Update the existing interface
      /*-*/
      update lics_header
         set hea_status = lics_constant.header_load_completed
         where hea_header = rcd_lics_header.hea_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Wake the appropriate background processor
      /*-*/
      case rcd_lics_header_01.int_type
         when lics_constant.type_inbound then
            lics_pipe.spray(lics_constant.type_inbound, rcd_lics_header_01.int_group, lics_constant.pipe_wake);
         when lics_constant.type_outbound then
            lics_pipe.spray(lics_constant.type_outbound, rcd_lics_header_01.int_group, lics_constant.pipe_wake);
         when lics_constant.type_passthru then
            lics_pipe.spray(lics_constant.type_passthru, rcd_lics_header_01.int_group, lics_constant.pipe_wake);
         else
            raise_application_error(-20000, 'Invalid interface type (' || rcd_lics_header_01.int_type || ')');
      end case;

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
   end update_status;

end lics_interface_process;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_interface_process for lics_app.lics_interface_process;
grant execute on lics_interface_process to public;