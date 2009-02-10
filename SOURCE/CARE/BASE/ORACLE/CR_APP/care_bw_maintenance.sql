/******************/
/* Package Header */
/******************/
create or replace package care_bw_maintenance as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : care_bw_maintenance
    Owner   : cr_app

    DESCRIPTION
    -----------
    Care - BW Cross Reference

    The package implements the BW cross reference maintenance functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function insert_data(par_code in varchar2,
                        par_xref_type in varchar2,
                        par_xref_desc in varchar2,
                        par_bw_code in varchar2) return varchar2;
   function update_data(par_code in varchar2,
                        par_xref_type in varchar2,
                        par_xref_desc in varchar2,
                        par_bw_code in varchar2) return varchar2;
   function delete_data(par_code in varchar2) return varchar2;

end care_bw_maintenance;
/

/****************/
/* Package Body */
/****************/
create or replace package body care_bw_maintenance as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_care_bw_xref cr.care_bw_xref%rowtype;

   /**************************************************/
   /* This function performs the insert data routine */
   /**************************************************/
   function insert_data(par_code in varchar2,
                        par_xref_type in varchar2,
                        par_xref_desc in varchar2,
                        par_bw_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_care_bw_xref_01 is 
         select t01.*
           from cr.care_bw_xref t01
          where t01.code = rcd_care_bw_xref.code;
      rcd_care_bw_xref_01 csr_care_bw_xref_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Care BW Cross Reference Maintenance - Insert Data';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_care_bw_xref.code := upper(par_code);
      rcd_care_bw_xref.xref_type := upper(par_xref_type);
      rcd_care_bw_xref.xref_desc := par_xref_desc;
      rcd_care_bw_xref.bw_code := par_bw_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_care_bw_xref.code is null then
         var_message := var_message || chr(13) || 'Cross reference code must be specified';
      end if;
      if rcd_care_bw_xref.xref_type is null then
         var_message := var_message || chr(13) || 'Cross reference type must be specified';
      end if;
      if rcd_care_bw_xref.xref_desc is null then
         var_message := var_message || chr(13) || 'Cross reference description must be specified';
      end if;
      if rcd_care_bw_xref.bw_code is null then
         var_message := var_message || chr(13) || 'BW code must be specified';
      end if;

      /*-*/
      /* Cross reference must not already exist
      /*-*/
      open csr_care_bw_xref_01;
      fetch csr_care_bw_xref_01 into rcd_care_bw_xref_01;
      if csr_care_bw_xref_01%found then
         var_message := var_message || chr(13) || 'Cross reference code (' || rcd_care_bw_xref.code || ') already exists';
      end if;
      close csr_care_bw_xref_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Insert the cross reference data
      /*-*/
      insert into cr.care_bw_xref
         (code,
          xref_type,
          xref_desc,
          bw_code)
         values(rcd_care_bw_xref.code,
                rcd_care_bw_xref.xref_type,
                rcd_care_bw_xref.xref_desc,
                rcd_care_bw_xref.bw_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end insert_data;

   /**************************************************/
   /* This function performs the update data routine */
   /**************************************************/
   function update_data(par_code in varchar2,
                        par_xref_type in varchar2,
                        par_xref_desc in varchar2,
                        par_bw_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_care_bw_xref_01 is 
         select t01.*
           from cr.care_bw_xref t01
          where t01.code = rcd_care_bw_xref.code;
      rcd_care_bw_xref_01 csr_care_bw_xref_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Care BW Cross Reference Maintenance - Update Data';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_care_bw_xref.code := upper(par_code);
      rcd_care_bw_xref.xref_type := upper(par_xref_type);
      rcd_care_bw_xref.xref_desc := par_xref_desc;
      rcd_care_bw_xref.bw_code := par_bw_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_care_bw_xref.code is null then
         var_message := var_message || chr(13) || 'Cross reference code must be specified';
      end if;
      if rcd_care_bw_xref.xref_type is null then
         var_message := var_message || chr(13) || 'Cross reference type must be specified';
      end if;
      if rcd_care_bw_xref.xref_desc is null then
         var_message := var_message || chr(13) || 'Cross reference description must be specified';
      end if;
      if rcd_care_bw_xref.bw_code is null then
         var_message := var_message || chr(13) || 'BW code must be specified';
      end if;

      /*-*/
      /* Cross reference data must exist
      /*-*/
      open csr_care_bw_xref_01;
      fetch csr_care_bw_xref_01 into rcd_care_bw_xref_01;
      if csr_care_bw_xref_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference code (' || rcd_care_bw_xref.code || ') does not exist';
      end if;
      close csr_care_bw_xref_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the cross reference data
      /*-*/
      update cr.care_bw_xref
         set xref_type = rcd_care_bw_xref.xref_type,
             xref_desc = rcd_care_bw_xref.xref_desc,
             bw_code = rcd_care_bw_xref.bw_code
         where code = rcd_care_bw_xref.code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /**************************************************/
   /* This function performs the delete data routine */
   /**************************************************/
   function delete_data(par_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_care_bw_xref_01 is 
         select *
           from cr.care_bw_xref t01
          where t01.code = rcd_care_bw_xref.code;
      rcd_care_bw_xref_01 csr_care_bw_xref_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Care BW Cross Reference Maintenance - Delete Data';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_care_bw_xref.code := upper(par_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_care_bw_xref.code is null then
         var_message := var_message || chr(13) || 'Cross reference code must be specified';
      end if;

      /*-*/
      /* Cross reference data must exist
      /*-*/
      open csr_care_bw_xref_01;
      fetch csr_care_bw_xref_01 into rcd_care_bw_xref_01;
      if csr_care_bw_xref_01%notfound then
         var_message := var_message || chr(13) || 'Cross reference code (' || rcd_care_bw_xref.code || ') does not exist';
      end if;
      close csr_care_bw_xref_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the cross reference data
      /*-*/
      delete from cr.care_bw_xref
         where code = rcd_care_bw_xref.code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end care_bw_maintenance;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym care_bw_maintenance for lads_app.care_bw_maintenance;
grant execute on care_bw_maintenance to public;