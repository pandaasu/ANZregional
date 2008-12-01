/******************/
/* Package Header */
/******************/
create or replace package ics_cisatl11_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ics
    Package : ics_cisatl11_validation
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Interface Control System - Interface CISATL11 validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;

end ics_cisatl11_validation;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_cisatl11_validation as

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
      if (substr(par_record,1,3) != 'CTL' and
          substr(par_record,1,3) != 'HDR' and
          substr(par_record,1,3) != 'DET') then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Record must start with CTL, HDR or DET not (' || substr(par_record,1,3) || ')';
      end if;
      if substr(par_record,1,3) = 'CTL' then
         if length(par_record) != 26 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record CTL length must be 26';
         end if;
      end if;
      if substr(par_record,1,3) = 'HDR' then
         if length(par_record) != 57 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record HDR length must be 57';
         end if;
      end if;
      if substr(par_record,1,3) = 'DET' then
         if length(par_record) != 39 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record DET length must be 39';
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

end ics_cisatl11_validation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_cisatl11_validation for ics_app.ics_cisatl11_validation;
grant execute on ics_cisatl11_validation to public;
