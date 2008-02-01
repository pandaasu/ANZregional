/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_buffer
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - Buffer

 The package implements the buffer functionality.

 **note** this package assumes a single threaded execution.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_buffer as

   /*-*/
   /* Public parent declarations
   /*-*/
   procedure create_buffer(par_sql in varchar2);
   function read_buffer return clob;

end lics_buffer;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_buffer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   lobReference clob;

   /********************************************/
   /* This procedure defines the create buffer */
   /********************************************/
   procedure create_buffer(par_sql in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      type typ_list is ref cursor;
      csr_list typ_list;
      var_code varchar2(128 char);
      var_start boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create/clear the buffer
      /*-*/
      if lobReference is null then 
         dbms_lob.createtemporary(lobReference,true);
      end if;
      dbms_lob.trim(lobReference,0);

      /*-*/
      /* Execute the list query to the buffer
      /*-*/
      var_start := true;
      begin
         open csr_list for par_sql;
      exception
         when others then
            raise_application_error(-20000, 'List query failed - ' || substr(SQLERRM, 1, 1024));
      end;
      loop
         fetch csr_list into var_code;
         if csr_list%notfound then
            exit;
         end if;
         if var_start = false then
            dbms_lob.writeappend(lobReference, 1, ',');
         end if;
         dbms_lob.writeappend(lobReference, length(var_code), var_code);
         var_start := false;
      end loop;
      close csr_list;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_buffer;

   /*****************************************/
   /* This procedure define the read buffer */
   /*****************************************/
   function read_buffer return clob is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the data buffer
      /*-*/
      return lobReference;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_buffer;

end lics_buffer;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_buffer for lics_app.lics_buffer;
grant execute on lics_buffer to public;