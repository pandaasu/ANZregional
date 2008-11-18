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
      var_result varchar2(4000);
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_result := null;

      /*-*/
      /* Add the search data
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'CTL' then
            process_record_ctl(par_record);
         when 'HDR' then
            process_record_hdr(par_record);
         when 'DET' then
            process_record_det(par_record);
         else
            var_result := 'Record identifier (' || var_record_identifier || ') must be CTL, HDR or DET');
      end case;

      /*-*/
      /* Return the result
      /*-*/
      return var_result;

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
