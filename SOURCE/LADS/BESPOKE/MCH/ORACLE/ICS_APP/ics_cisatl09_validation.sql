/******************/
/* Package Header */
/******************/
create or replace package ics_cisatl09_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ics
    Package : ics_cisatl09_validation
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Interface Control System - Interface CISATL09 validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;

end ics_cisatl09_validation;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_cisatl09_validation as

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   function on_data(par_record in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_message := null;

      /*-*/
      /* Validate the data
      /*-*/
      if substr(par_record,1,3) != 'HDR' then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Record must start with HDR not (' || substr(par_record,1,3) || ')';
      end if;
      if substr(par_record,1,3) = 'HDR' then
         if length(par_record) != 206 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record HDR length must be 206';
         end if;
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

end ics_cisatl09_validation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_cisatl09_validation for ics_app.ics_cisatl09_validation;
grant execute on ics_cisatl09_validation to public;
