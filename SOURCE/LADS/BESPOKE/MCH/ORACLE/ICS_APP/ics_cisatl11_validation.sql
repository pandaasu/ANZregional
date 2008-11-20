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
      var_title varchar2(128);
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_title := 'Interface CISATL11 Validation';
      var_message := null;

      /*-*/
      /* Validate the data
      /*-*/
      if (substr(par_record,1,3) != 'CTL' and
          substr(par_record,1,3) != 'HDR' and
          substr(par_record,1,3) != 'DET') then
         var_message := var_message || chr(13) || 'Record must start with CTL, HDR or DET not (' || substr(par_record,1,3) || ')';
      end if;
      if (substr(par_record,1,3) = 'CTL' then
         if length(par_record) != 26 then
            var_message := var_message || chr(13) || 'Record CTL length must be 26';
         end if;
      end if;
      if (substr(par_record,1,3) = 'HDR' then
         if length(par_record) != 57 then
            var_message := var_message || chr(13) || 'Record HDR length must be 57';
         end if;
      end if;
      if (substr(par_record,1,3) = 'DET' then
         if length(par_record) != 39 then
            var_message := var_message || chr(13) || 'Record DET length must be 39';
         end if;
      end if;

      /*-*/
      /* Insert the message title when required
      /*-*/
      if not(var_message is null) then
         var_message := var_title || var_message;
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
