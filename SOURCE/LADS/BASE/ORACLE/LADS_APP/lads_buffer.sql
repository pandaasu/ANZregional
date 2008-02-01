/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_buffer
 Owner   : lads_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - Buffer

 The package implements the buffer functionality.

 **note** this package assumes a single threaded execution.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_buffer as

   /*-*/
   /* Public parent declarations
   /*-*/
   function create_buffer(par_sql in varchar2) return clob;

end lads_buffer;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_buffer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************/
   /* This procedure defines the create buffer */
   /********************************************/
   function create_buffer(par_sql in varchar2) return clob is

      /*-*/
      /* Local definitions
      /*-*/
      lobReference clob;
      type typ_list is ref cursor;
      csr_list typ_list;
      var_code varchar2(128 char);
      var_count number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the buffer
      /*-*/
      dbms_lob.createtemporary(lobReference,true);

      /*-*/
      /* Execute the list query to the buffer
      /*-*/
      var_count := 0;
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
         if var_count >= 200 then
            dbms_lob.writeappend(lobReference, 1, utl_tcp.CRLF);
            var_count := 0;
         end if;
         if var_count > 0 then
            dbms_lob.writeappend(lobReference, 1, ',');
         end if;
         dbms_lob.writeappend(lobReference, length(rtrim(var_code)), rtrim(var_code));
         var_count := var_count + 1;
      end loop;
      close csr_list;
      if var_count > 0 then
         dbms_lob.writeappend(lobReference, 1, utl_tcp.CRLF);
         var_count := 0;
      end if;

      /*-*/
      /* Return the data buffer
      /*-*/
      return lobReference;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_buffer;

end lads_buffer;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_buffer for lads_app.lads_buffer;
grant execute on lads_buffer to public;