/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_extract as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_extract
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Extract Package

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure update_list(par_type in varchar2, par_list in varchar2);

end vds_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the update list routine */
   /***************************************************/
   procedure update_list(par_type in varchar2, par_list in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_type varchar2(30);
      var_list varchar2(4000);
      var_number varchar2(30 char);
      var_date varchar2(20 char);
      var_char varchar2(1);
      var_flag varchar2(1);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is 
         select t01.*
           from vds_doc_list t01
          where t01.doc_type = var_type
            and t01.doc_number = var_number;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Extract the document list data and process
      /*-*/
      var_type := upper(par_type);
      var_list := par_list;
      var_number := null;
      var_date := null;
      var_flag := '1';
      for idx in 1..length(var_list) loop
         var_char := substr(var_list,idx,1);
         if var_char = ';' then
            if not(var_number is null) and not(var_date is null) then
               var_found := false;
               open csr_list;
               fetch csr_list into rcd_list;
               if csr_list%found then
                  var_found := true;
               end if;
               close csr_list;
               if var_found = true then
                  if rcd_list.doc_date != var_date then
                     update vds_doc_list
                        set doc_date = var_date,
                            doc_status = '*CHANGED',
                            vds_date = sysdate
                      where doc_type = var_type
                        and doc_number = var_number;
                  end if;
               else
                  insert into vds_doc_list values(var_type, var_number, var_date, '*CHANGED', sysdate);
               end if;
            end if;
            var_number := null;
            var_date := null;
            var_flag := '1';
         elsif var_char = ',' then
            var_flag := '2';
         else
            if var_flag = '1' then
               var_number := var_number||var_char;
            else
               var_date := var_date||var_char;
            end if;
         end if;
      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - Update List - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_list;

end vds_extract;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_extract for vds_app.vds_extract;
grant execute on vds_extract to public;