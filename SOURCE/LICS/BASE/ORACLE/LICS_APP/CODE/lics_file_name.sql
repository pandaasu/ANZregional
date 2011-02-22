/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_file
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - File

 The package implements the file functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_file as

   /*-*/
   /* Public declarations
   /*-*/
   function generate_name(par_interface in varchar2,
                          par_prefix in varchar2,
                          par_length in number,
                          par_extension in varchar2) return varchar2;

end lics_file;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_file as

   /*****************************************************/
   /* This procedure performs the generate name routine */
   /*****************************************************/
   function generate_name(par_interface in varchar2,
                          par_prefix in varchar2,
                          par_length in number,
                          par_extension in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_length number;
      var_maximum number;
      var_number number;
      var_sequence varchar2(32);
      var_return varchar2(64);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Calculate the length
      /*-*/
      var_length := par_length;
      if var_length > 15 then
         var_length := 15;
      end if;
      if var_length < 1 then
         var_length := 0;
      end if;

      /*-*/
      /* Calculate the maximum value for the length
      /*-*/
      var_maximum := (9 * power(10, var_length - 1) - 1) + (1 * power(10, var_length - 1));

      /*-*/
      /* Update current sequence for the interface
      /* *note* cycle the sequence when maximum exceeded
      /*-*/
      if var_length > 0 then
         update lics_int_sequence
            set ins_sequence = ins_sequence + 1
            where ins_interface = upper(par_interface)
            returning ins_sequence into var_number;
         if sql%found then
            if var_number > var_maximum then
               update lics_int_sequence
                  set ins_sequence = 1
                  where ins_interface = upper(par_interface);
               var_number := 1;
            end if;
         else
            insert into lics_int_sequence (ins_interface, ins_sequence)
               values(upper(par_interface), 1);
            var_number := 1;
         end if;
         commit;
         var_sequence := substr(to_char(var_number,'FM000000000000000'), var_length * -1, var_length);
      else  
         var_sequence := null;
      end if;

      /*-*/
      /* Set the return value
      /*-*/
      var_return := trim(par_prefix) || var_sequence || '.' || trim(par_extension);

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate_name;

end lics_file;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_file for lics_app.lics_file;
grant execute on lics_file to public;