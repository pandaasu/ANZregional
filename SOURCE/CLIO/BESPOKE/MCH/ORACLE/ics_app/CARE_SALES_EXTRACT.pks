CREATE OR REPLACE PACKAGE CARE_SALES_EXTRACT as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_source in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2);

end CARE_SALES_EXTRACT;
/

