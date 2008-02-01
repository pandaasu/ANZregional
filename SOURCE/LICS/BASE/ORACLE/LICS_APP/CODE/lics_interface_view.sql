/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_interface_view
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Interface View

 The package implements the interface view functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_interface_view as

   /**/
   /* Public declarations
   /**/
   function retrieve(par_header in number) return varchar2;

end lics_interface_view;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_interface_view as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_header lics_header%rowtype;

   /***********************************************/
   /* This function performs the retrieve routine */
   /***********************************************/
   function retrieve(par_header in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_opened boolean;
      var_fil_handle utl_file.file_type;
      var_size number(5,0);
      var_work number(5,0);
      var_count number(9,0);
      var_data varchar2(4000);
      type tab_sequence is table of number(9,0) index by binary_integer;
      type tab_record is table of varchar2(4000) index by binary_integer;
      var_sequence tab_sequence;
      var_record tab_record;

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
      var_title := 'Interface Control System - Interface View - Retrieve';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_header.hea_header := par_header;

      /*-*/
      /* Header must exist
      /*-*/
      open csr_lics_header_01;
      fetch csr_lics_header_01 into rcd_lics_header_01;
      if csr_lics_header_01%notfound then
         var_message := var_message || chr(13) || 'Interface header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist';
      end if;
      close csr_lics_header_01;

      /*-*/
      /* File path must exist
      /*-*/
      if rcd_lics_header_01.int_fil_path != 'ICS_INBOUND'
      and rcd_lics_header_01.int_fil_path != 'ICS_OUTBOUND' then
         var_message := var_message || chr(13) || 'Interface file path (' || rcd_lics_header_01.int_fil_path || ') not recognised';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Clear temporary table
      /*-*/
      delete from lics_temp;
      commit;

      /**/
      /* Execute the file restore script
      /*
      /* **notes**
      /* 1. Restores the file from archive
      /* 2. Ignore when file not found
      /**/
      begin
         if rcd_lics_header_01.int_fil_path = 'ICS_INBOUND' then
            java_utility.execute_external_procedure(lics_parameter.restore_script || ' ' || rcd_lics_header_01.hea_fil_name || ' VIEW');
         else
            java_utility.execute_external_procedure(lics_parameter.restore_script || ' ' || rcd_lics_header_01.hea_fil_name || ' VIEW');
         end if;
      exception
         when others then
            return '*OK';
      end;

      /**/
      /* Initialise the opened variable
      /**/
      var_opened := false;

      /**/
      /* Open the interface file 
      /**/
      begin
         var_fil_handle := utl_file.fopen('ICS_VIEW', rcd_lics_header_01.hea_fil_name, 'r', lics_parameter.inbound_line_max);
      exception
         when utl_file.access_denied then
            raise_application_error(-20000, 'Retrieve - Access denied to inbound file (ICS_VIEW - ' || rcd_lics_header_01.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_path then
            raise_application_error(-20000, 'Retrieve - Invalid path to inbound file (ICS_VIEW - ' || rcd_lics_header_01.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_filename then
            raise_application_error(-20000, 'Retrieve - Invalid file name for inbound file (ICS_VIEW - ' || rcd_lics_header_01.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when others then
            raise_application_error(-20000, 'Retrieve - Could not open inbound file (ICS_VIEW - ' || rcd_lics_header_01.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
      end;
      var_opened := true;

      /**/
      /* Process the interface file
      /**/
      var_size := lics_parameter.inbound_array_size;
      var_work := 0;
      var_count := 0;
      loop

         /**/
         /* Read the interface file rows
         /**/
         begin
            utl_file.get_line(var_fil_handle, var_data, lics_parameter.inbound_line_max);
         exception
            when no_data_found then
               exit;
            when others then
               raise_application_error(-20000, 'Retrieve - Could not read file (ICS_VIEW - ' || rcd_lics_header_01.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Load the bulk array
         /*-*/
         var_work := var_work + 1;
         var_count := var_count + 1;
         var_sequence(var_work) := var_count;
         var_record(var_work) := var_data;
         if var_record(var_work) is null then
            var_record(var_work) := '** NULL DATA FOUND **';
         end if;

         /*-*/
         /* Insert the bulk data when required
         /*-*/
         if var_work = var_size then
            forall idx in 1..var_work
               insert into lics_temp
                  (dat_dta_seq,
                   dat_record)
                  values(var_sequence(idx),
                         var_record(idx));
            var_work := 0;
         end if;

      end loop;

      /*-*/
      /* Insert the remaining bulk data
      /*-*/
      if var_work > 0 then
         forall idx in 1..var_work
            insert into lics_temp
               (dat_dta_seq,
                dat_record)
               values(var_sequence(idx),
                      var_record(idx));
      end if;

      /*-*/
      /* Close the interface file
      /*-*/
      if var_opened = true then
         begin
            utl_file.fclose(var_fil_handle);
         exception
            when others then
               raise_application_error(-20000, 'Retrieve - Could not close file (ICS_VIEW - ' || rcd_lics_header_01.hea_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         end;
         var_opened := false;
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
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
         end if;
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024) || chr(13) || lics_parameter.restore_script || ' ' || rcd_lics_header_01.hea_fil_name || ' VIEW');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve;

end lics_interface_view;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_interface_view for lics_app.lics_interface_view;
grant execute on lics_interface_view to public;