/******************/
/* Package Header */
/******************/
CREATE OR REPLACE package ics_cisatl15_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ics
    Package : ics_cisatl15_validation
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Interface Control System - Interface CISATL15 validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/11   Steve Gregan   Created
    2009/07   Trevor Keon    Updated to support storage location (102 length limit)
    2009/08   Ben Halicki    Updated to support plant code (106 length limit)
	
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_data(par_record in varchar2) return varchar2;

end ics_cisatl15_validation;
/

/****************/
/* Package Body */
/****************/
CREATE OR REPLACE package body ics_cisatl15_validation as

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
         if length(par_record) != 106 then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Record HDR length must be 106';
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

end ics_cisatl15_validation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_cisatl15_validation for ics_app.ics_cisatl15_validation;
grant execute on ics_cisatl15_validation to public;
