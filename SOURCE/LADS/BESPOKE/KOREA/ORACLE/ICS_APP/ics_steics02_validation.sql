/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_steics02_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ics_steics02_validation
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Site to ICS - STEICS02 - Orders Interface Validation (Korea)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;

end ics_steics02_validation;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_steics02_validation as

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
      if substr(par_record,1,3) = 'HDR' then
         if length(par_record) != 127 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record HDR length must be 127';
         end if;
      elsif substr(par_record,1,3) = 'HTX' then
         if length(par_record) != 79 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record HDR length must be 79';
         end if;
      elsif substr(par_record,1,3) = 'DET' then
         if length(par_record) != 90 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record HDR length must be 90';
         end if;
      else
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Record must start with HDR, HTX or DET not (' || substr(par_record,1,3) || ')';
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

end ics_steics02_validation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_steics02_validation for ics_app.ics_steics02_validation;
grant execute on ics_steics02_validation to public;
