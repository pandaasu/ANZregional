/******************/
/* Package Header */
/******************/
create or replace package cad_to_efex_cust_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : cad_to_efex_cust_loader
    Owner   : iface_app

    Description
    -----------
    Customer Master Data - EFEX to CAD

    This package extracts the Efex direct and indirect customers that have been modified within the last
    history number of days and sends the extract file to the CAD environment. The ICS interface EFXCAD01
    has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure cad_to_efex_cust_loader;

end cad_to_efex_cust_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body cad_to_efex_cust_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure cad_to_efex_cust_loader is

      /*-*/
      /* Local definitions
      /*-*/

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_cad_cust_data is
         select t01.*
           from cad_to_efex_cust_master t01;
      rcd_cad_cust_data csr_cad_cust_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_cad_cust_data;
      loop
         fetch csr_cad_cust_data into rcd_cad_cust_data;
         if csr_cad_cust_data%notfound then
            exit;
         end if;

         insert into users

         insert into customer



      end loop;
      close csr_cad_cust_data;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end cad_to_efex_cust_loader;

end cad_to_efex_cust_loader;
/
