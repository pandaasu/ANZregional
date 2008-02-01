/******************/
/* Package Header */
/******************/
create or replace package lics_interface_search as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_interface_search
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - Interface Search

 The package implements the interface search functionality.

 1. The primary purpose of the package is to provide ICS packages
    controlled access to loading interface instance search data.

 2. ICS packages that implement this functionality must use the following model

       2.1. execute lics_interface_search.initialise('current instance header')
       2.2. execute the search definition logic
       2.3. execute lics_interface_search.finalise

 3. This package has been designed as a single instance class to facilitate
    re-engineering in an object oriented language. That is, in an OO environment
    the host would create one or more instances of this class and pass the reference
    to the target objects. However, in the PL/SQL environment only one global instance
    is available at any one time.

 4. All methods have been implemented as autonomous transactions so as not
    to interfere with the commit boundaries of the host application.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure initialise(par_header in number);
   procedure finalise;
   procedure add_search(par_tag in varchar2, par_value in varchar2);

end lics_interface_search;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_interface_search as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_int_reference lics_int_reference%rowtype;
   rcd_lics_header lics_header%rowtype;
   rcd_lics_hdr_search lics_hdr_search%rowtype;
   type typ_lookup is table of varchar2(64) index by binary_integer;
   tbl_lookup typ_lookup;
   type rcd_search is record(tag varchar2(64 char),
                             value varchar2(128 char));
   type typ_search is table of rcd_search index by binary_integer;
   tbl_search typ_search;

   /**************************************************/
   /* This procedure performs the initialise routine */
   /**************************************************/
   procedure initialise(par_header in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_header is 
         select t01.*
           from lics_header t01
          where t01.hea_header = par_header;

      cursor csr_lics_int_reference is 
         select t01.*
           from lics_int_reference t01
          where t01.inr_interface = rcd_lics_header.hea_interface;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the interface header
      /* **notes** 1. Procedure returns when interface header not found
      /*-*/
      open csr_lics_header;
      fetch csr_lics_header into rcd_lics_header;
      if csr_lics_header%notfound then
         rcd_lics_header.hea_header := null;
      end if;
      close csr_lics_header;
      if rcd_lics_header.hea_header is null then
         return;
      end if;

      /*-*/
      /* Retrieve any allowable interface reference information 
      /*-*/
      tbl_lookup.delete;
      tbl_search.delete;
      open csr_lics_int_reference;
      loop
         fetch csr_lics_int_reference into rcd_lics_int_reference;
         if csr_lics_int_reference%notfound then
            exit;
         end if;
         tbl_lookup(tbl_lookup.count+1) := upper(rcd_lics_int_reference.inr_reference);
      end loop;
      close csr_lics_int_reference;

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
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
         raise_application_error(-20000, 'LICS_INTERFACE_SEARCH - INITIALISE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end initialise;

   /************************************************/
   /* This procedure performs the finalise routine */
   /************************************************/
   procedure finalise is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return when not initialised
      /*-*/
      if rcd_lics_header.hea_header is null then
         return;
      end if;

      /*-*/
      /* Remove any existing search information 
      /*-*/
      delete from lics_hdr_search
       where hes_header = rcd_lics_header.hea_header;

      /*-*/
      /* Insert the new search information when required
      /*-*/
      if tbl_search.count != 0 then

         /*-*/
         /* Add the search values to the interface header
         /* **note** failed duplicate insert is ignored as the same value could be added multiple times
         /*-*/
         for idx in 1..tbl_search.count loop
            begin
               rcd_lics_hdr_search.hes_header := rcd_lics_header.hea_header;
               rcd_lics_hdr_search.hes_sea_tag := tbl_search(idx).tag;
               rcd_lics_hdr_search.hes_sea_value := tbl_search(idx).value;
               insert into lics_hdr_search
                  (hes_header,
                   hes_sea_tag,
                   hes_sea_value)
               values(rcd_lics_hdr_search.hes_header,
                      rcd_lics_hdr_search.hes_sea_tag,
                      rcd_lics_hdr_search.hes_sea_value);
            exception
               when dup_val_on_index then
                  null;
               when others then
                  raise;
            end;
         end loop;

         /*-*/
         /* Update the interface search tag references as required
         /* **note** 1. failed duplicate insert is ignored as multiple threads could be active at the same time
         /*          2. should only perform insert after application package modification 
         /*-*/
         for idx in 1..tbl_search.count loop
            var_found := false;
            for idy in 1..tbl_lookup.count loop
               if tbl_search(idx).tag = tbl_lookup(idy) then
                  var_found := true;
               end if;
            end loop;
            if var_found = false then
               rcd_lics_int_reference.inr_interface := rcd_lics_header.hea_interface;
               rcd_lics_int_reference.inr_reference := tbl_search(idx).tag;
               begin
                  insert into lics_int_reference
                     (inr_interface,
                      inr_reference)
                  values(rcd_lics_int_reference.inr_interface,
                         rcd_lics_int_reference.inr_reference);
               exception
                  when dup_val_on_index then
                     null;
                  when others then
                     raise;
               end;
            end if;
         end loop;

      end if;

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

      /*-*/
      /* Finalise the package
      /*-*/
      rcd_lics_header.hea_header := null;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Finalise the package
         /*-*/
         rcd_lics_header.hea_header := null;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LICS_INTERFACE_SEARCH - FINALISE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise;

   /**************************************************/
   /* This procedure performs the add search routine */
   /**************************************************/
   procedure add_search(par_tag in varchar2, par_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_tag lics_hdr_search.hes_sea_tag%type;
      var_value lics_hdr_search.hes_sea_value%type;
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return when not initialised
      /*-*/
      if rcd_lics_header.hea_header is null then
         return;
      end if;

      /*-*/
      /* Validate the search tag and value
      /*-*/
      var_tag := upper(par_tag);
      var_value := par_value;
      if var_tag is null then
         var_tag := '*ERROR';
         var_value := 'Search tag was not supplied - value (' || substr(par_value,1,64) || ')';
      end if;
      if var_value is null then
         var_tag := '*ERROR';
         var_value := 'Search value was not supplied - tag (' || par_tag || ')';
      end if;
      if length(var_tag) > 64 then
         var_tag := '*ERROR';
         var_value := 'Search tag (' || par_tag || ') maximum length 64 exceeded';
      end if;
      if length(var_value) > 128 then
         var_tag := '*ERROR';
         var_value := 'Search value (' || substr(par_value,1,64) || ') maximum length 128 exceeded';
      end if;

      /*-*/
      /* Add the search value to the array
      /*-*/
      var_index := tbl_search.count + 1;
      tbl_search(var_index).tag := var_tag;
      tbl_search(var_index).value := var_value;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_search;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package
   /*-*/
   rcd_lics_header.hea_header := null;

end lics_interface_search;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_interface_search for lics_app.lics_interface_search;
grant execute on lics_interface_search to public;