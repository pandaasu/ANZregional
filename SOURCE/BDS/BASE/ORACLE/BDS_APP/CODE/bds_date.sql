create or replace package bds_date as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_date
 Owner   : BDS_APP
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Date Functions


 FUNCTION : BDS_TO_DATE (PAR_ACTION [MANDATORY], PAR_DATE [MANDATORY], PAR_FORMAT [OPTIONAL - DEFAULT YYYYMMDD])
            PAR_ACTION - Execution type of date conversion - *START_DATE, *END_DATE, *DATE
            PAR_DATE   - Date string to be converted into Oracle date format
            PAR_FORMAT - Expected format of date string


 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function bds_to_date(par_action in varchar2, par_date in varchar2, par_format in varchar2 default 'yyyymmdd') return date;

end bds_date;
/


/****************/
/* Package Body */
/****************/
create or replace package body bds_date as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function bds_to_date(par_action in varchar2, par_date in varchar2, par_format in varchar2 default 'yyyymmdd') return date is

      /*-*/
      /* Declare Variables
      /*-*/
      var_bds_date date;
      var_count number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise Variables
      /*-*/
      var_count := 0;
      var_bds_date := null;

      /*-*/
      /* Process known dates
      /*  note : null or 00000000 indicate a no boundary start/end date
      /*-*/  
      if (par_date = '00000000' or
          par_date is null) then
     
         case par_action
            when '*START_DATE' then var_bds_date := to_date('19000101','yyyymmdd');
            when '*END_DATE' then var_bds_date := to_date('99991231','yyyymmdd');
            when '*DATE' then var_bds_date := null;
            else raise_application_error(-20000, 'Unknown par_action parameter used: ' || par_action || ', must be *START_DATE, *END_DATE or *DATE');
         end case;

         var_count := 1;

      end if;

      /*-*/
      /* Attempt to convert using supplied date format
      /*-*/  
      if (var_count != 1) then  
         begin
            var_bds_date := to_date(par_date, par_format);
            var_count := 1;
         exception
            when others then
               null;
         end;  
      end if;

      /*-*/
      /* Attempt to apply date format in following order if supplied format failed :
      /*     - yyyymmdd
      /*     - ddmmyyyy
      /*     - mmddyyyy
      /*-*/  
      if (var_count != 1) then
         begin
            var_bds_date := to_date(par_date, 'yyyymmdd');
            var_count := var_count+1;
         exception
            when others then
               null;
         end;  
         /*-*/ 
         begin
            var_bds_date := to_date(par_date, 'ddmmyyyy');
            var_count := var_count+1;
         exception
            when others then
               null;
         end; 
         /*-*/ 
         begin
            var_bds_date := to_date(par_date, 'mmddyyyy');
            var_count := var_count+1;
         exception
            when others then
               null;
         end; 

         /*-*/
         /* Check multiple successful conversions were not encountered
         /*-*/  
         if (var_count > 1) then
            raise_application_error(-20000, 'Multiple valid date conversion formats found for ' || par_date);
         end if;

      end if; 

      /*-*/
      /* Raise exception if conversion was unsuccessful
      /*-*/  
      if (var_count != 1) then
         raise_application_error(-20000, 'Valid date conversion format not found for ' || par_date);
      end if;


      /*-*/
      /* Return BDS date
      /*-*/  
      return var_bds_date;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_DATE - BDS_TO_DATE(' || par_action || ',' || par_date || ',' || par_format|| ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_to_date;

end bds_date;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_date for bds_app.bds_date;
grant execute on bds_date to public;
