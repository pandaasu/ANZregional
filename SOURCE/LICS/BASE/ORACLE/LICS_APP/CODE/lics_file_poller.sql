/******************/
/* Package Header */
/******************/
create or replace package lics_file_poller as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_file_poller
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - File Poller

 The package implements the file poller functionality.

 1. The procedure is executed on an polling thread and supports the use of multiple
    parallel polling threads. With this model it is possible to have any combination
    of single to multiple threads executing any combination of parameters.

 2. The invocation interval is controlled by the polling thread.

 3. The polling threads provide load balancing and thread safety.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/02   Steve Gregan   End point architecture version

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end lics_file_poller;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_file_poller as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the file system file retrieval
      /*-*/
      lics_filesystem.retrieve_file_list(lics_parameter.ics_inbound_path);
      
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - File Poller - Execute - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_file_poller;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_file_poller for lics_app.lics_file_poller;
grant execute on lics_file_poller to public;
