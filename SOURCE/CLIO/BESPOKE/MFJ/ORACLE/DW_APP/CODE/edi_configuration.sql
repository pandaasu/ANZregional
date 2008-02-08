/******************/
/* Package Header */
/******************/
create or replace package edi_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_configuration
    Owner   : dw_app

    DESCRIPTION
    -----------
    Electronic Data Interchange - Configuration

    The package implements the configuration functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/01   Steve Gregan   Created

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_edi_gento_day in varchar2,
                         par_edi_gento_year in varchar2,
                         par_update_user in varchar2) return varchar2;
   function update_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_edi_gento_day in varchar2,
                         par_edi_gento_year in varchar2,
                         par_update_user in varchar2) return varchar2;
   function delete_whslr(par_edi_sndto_code in varchar2) return varchar2;

end edi_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_whslr whslr%rowtype;
   rcd_whslr_billing whslr_billing%rowtype;

   /********************************************************/
   /* This function performs the insert wholesaler routine */
   /********************************************************/
   function insert_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_edi_gento_day in varchar2,
                         par_edi_gento_year in varchar2,
                         par_update_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_bilto_date whslr_billing.edi_bilto_date%type;
      var_bilto_str_date whslr_billing.edi_bilto_str_date%type;
      var_bilto_end_date whslr_billing.edi_bilto_end_date%type;
      var_sndon_date whslr_billing.edi_sndon_date%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_01 is 
         select *
           from whslr t01
          where t01.edi_sndto_code = rcd_whslr.edi_sndto_code;
      rcd_whslr_01 csr_whslr_01%rowtype;

      cursor csr_whslr_billing_01 is 
         select *
           from whslr_billing t01
          where t01.edi_sndto_code = rcd_whslr.edi_sndto_code
          order by t01.edi_bilto_date desc;
      rcd_whslr_billing_01 csr_whslr_billing_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - Configuration - Insert Wholesaler';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr.edi_sndto_code := par_edi_sndto_code;
      rcd_whslr.edi_whslr_code := par_edi_whslr_code;
      rcd_whslr.edi_whslr_name := par_edi_whslr_name;
      rcd_whslr.edi_disc_code := par_edi_disc_code;
      rcd_whslr.edi_email_group := par_edi_email_group;
      rcd_whslr.update_user := par_update_user;
      rcd_whslr.update_date := sysdate;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr.edi_sndto_code is null then
         var_message := var_message || chr(13) || 'Send to code must be specified';
      end if;
      if rcd_whslr.edi_whslr_code is null then
         var_message := var_message || chr(13) || 'Wholesaler code must be specified';
      end if;
      if rcd_whslr.edi_whslr_name is null then
         var_message := var_message || chr(13) || 'Wholesaler name must be specified';
      end if;
      if rcd_whslr.edi_disc_code != 'A' and rcd_whslr.edi_disc_code != 'V' then
         var_message := var_message || chr(13) || 'Discount code must be A(All) or V(Volume only)';
      end if;
      if rcd_whslr.edi_email_group is null then
         var_message := var_message || chr(13) || 'Email group must be specified';
      end if;
      if rcd_whslr.update_user is null then
         var_message := var_message || chr(13) || 'Update user must be specified';
      end if;
      if not(par_edi_gento_day is null) and upper(par_edi_gento_day) != '*NONE' then
         if par_edi_gento_year < '2000' then
            var_message := var_message || chr(13) || 'Generate billing year must be specified and greater than 2000';
         end if;
      end if;

      /*-*/
      /* Wholesaler must not already exist
      /*-*/
      open csr_whslr_01;
      fetch csr_whslr_01 into rcd_whslr_01;
      if csr_whslr_01%found then
         var_message := var_message || chr(13) || 'Wholesaler (' || rcd_whslr.edi_sndto_code || ') already exists';
      end if;
      close csr_whslr_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new wholesaler
      /*-*/
      insert into whslr
         (edi_sndto_code,
          edi_whslr_code,
          edi_whslr_name,
          edi_disc_code,
          edi_email_group,
          update_user,
          update_date)
         values(rcd_whslr.edi_sndto_code,
                rcd_whslr.edi_whslr_code,
                rcd_whslr.edi_whslr_name,
                rcd_whslr.edi_disc_code,
                rcd_whslr.edi_email_group,
                rcd_whslr.update_user,
                rcd_whslr.update_date);

      /*-*/
      /* Generate the wholesaler billing events when requested
      /*-*/
      if not(par_edi_gento_day is null) and upper(par_edi_gento_day) != '*NONE' then

         /*-*/
         /* Set the starting point for the billing events
         /*-*/
         var_bilto_end_date := to_char(sysdate,'yyyymmdd');
         open csr_whslr_billing_01;
         fetch csr_whslr_billing_01 into rcd_whslr_billing_01;
         if csr_whslr_billing_01%found then
            var_bilto_end_date := rcd_whslr_billing_01.edi_bilto_end_date;
         end if;
         close csr_whslr_billing_01;

         /*-*/
         /* Generate the billing events until required
         /*-*/
         loop
            if to_char(to_date(var_bilto_end_date,'yyyymmdd')+1,'yyyy') > par_edi_gento_year then
               exit;
            end if;
            if upper(par_edi_gento_day) = '*LAST' then
               var_bilto_str_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+1,'yyyymmdd');
               var_bilto_end_date := to_char(last_day(add_months(to_date(substr(var_bilto_end_date,1,6)||'01','yyyymmdd'),1)),'yyyymmdd');
            else
               var_bilto_str_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+1,'yyyymmdd');
               var_bilto_end_date := to_char(add_months(to_date(substr(var_bilto_end_date,1,6)||'01','yyyymmdd'),1),'yyyymm')||par_edi_gento_day;
            end if;
            var_bilto_date := var_bilto_end_date;
            var_sndon_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+2,'yyyymmdd');
            rcd_whslr_billing.edi_sndto_code := rcd_whslr.edi_sndto_code;
            rcd_whslr_billing.edi_bilto_date := var_bilto_date;
            rcd_whslr_billing.edi_bilto_str_date := var_bilto_str_date;
            rcd_whslr_billing.edi_bilto_end_date := var_bilto_end_date;
            rcd_whslr_billing.edi_sndon_date := var_sndon_date;
            insert into whslr_billing values rcd_whslr_billing;
         end loop;

      end if;

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
   end insert_whslr;

   /********************************************************/
   /* This function performs the update wholesaler routine */
   /********************************************************/
   function update_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_edi_gento_day in varchar2,
                         par_edi_gento_year in varchar2,
                         par_update_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_bilto_date whslr_billing.edi_bilto_date%type;
      var_bilto_str_date whslr_billing.edi_bilto_str_date%type;
      var_bilto_end_date whslr_billing.edi_bilto_end_date%type;
      var_sndon_date whslr_billing.edi_sndon_date%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_01 is 
         select *
           from whslr t01
          where t01.edi_sndto_code = rcd_whslr.edi_sndto_code;
      rcd_whslr_01 csr_whslr_01%rowtype;

      cursor csr_whslr_billing_01 is 
         select *
           from whslr_billing t01
          where t01.edi_sndto_code = rcd_whslr.edi_sndto_code
          order by t01.edi_bilto_date desc;
      rcd_whslr_billing_01 csr_whslr_billing_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Wholesaler';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr.edi_sndto_code := par_edi_sndto_code;
      rcd_whslr.edi_whslr_code := par_edi_whslr_code;
      rcd_whslr.edi_whslr_name := par_edi_whslr_name;
      rcd_whslr.edi_disc_code := par_edi_disc_code;
      rcd_whslr.edi_email_group := par_edi_email_group;
      rcd_whslr.update_user := par_update_user;
      rcd_whslr.update_date := sysdate;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr.edi_sndto_code is null then
         var_message := var_message || chr(13) || 'Send to code must be specified';
      end if;
      if rcd_whslr.edi_whslr_code is null then
         var_message := var_message || chr(13) || 'Wholesaler code must be specified';
      end if;
      if rcd_whslr.edi_whslr_name is null then
         var_message := var_message || chr(13) || 'Wholesaler name must be specified';
      end if;
      if rcd_whslr.edi_disc_code != 'A' and rcd_whslr.edi_disc_code != 'V' then
         var_message := var_message || chr(13) || 'Discount code must be A(All) or V(Volume only)';
      end if;
      if rcd_whslr.edi_email_group is null then
         var_message := var_message || chr(13) || 'Email group must be specified';
      end if;
      if rcd_whslr.update_user is null then
         var_message := var_message || chr(13) || 'Update user must be specified';
      end if;
      if not(par_edi_gento_day is null) and upper(par_edi_gento_day) != '*NONE' then
         if par_edi_gento_year < '2000' then
            var_message := var_message || chr(13) || 'Generate billing year must be specified and greater than 2000';
         end if;
      end if;

      /*-*/
      /* Wholesaler must already exist
      /*-*/
      open csr_whslr_01;
      fetch csr_whslr_01 into rcd_whslr_01;
      if csr_whslr_01%notfound then
         var_message := var_message || chr(13) || 'Wholesaler (' || rcd_whslr.edi_sndto_code || ') does not exist';
      end if;
      close csr_whslr_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing wholesaler
      /*-*/
      update whslr
         set edi_whslr_code = rcd_whslr.edi_whslr_code,
             edi_whslr_name = rcd_whslr.edi_whslr_name,
             edi_disc_code = rcd_whslr.edi_disc_code,
             edi_email_group = rcd_whslr.edi_email_group,
             update_user = rcd_whslr.update_user,
             update_date = rcd_whslr.update_date
         where edi_sndto_code = rcd_whslr.edi_sndto_code;

      /*-*/
      /* Generate the wholesaler billing events when requested
      /*-*/
      if not(par_edi_gento_day is null) and upper(par_edi_gento_day) != '*NONE' then

         /*-*/
         /* Set the starting point for the billing events
         /*-*/
         var_bilto_end_date := to_char(sysdate,'yyyymmdd');
         open csr_whslr_billing_01;
         fetch csr_whslr_billing_01 into rcd_whslr_billing_01;
         if csr_whslr_billing_01%found then
            var_bilto_end_date := rcd_whslr_billing_01.edi_bilto_end_date;
         end if;
         close csr_whslr_billing_01;

         /*-*/
         /* Generate the billing events until required
         /*-*/
         loop
            if to_char(to_date(var_bilto_end_date,'yyyymmdd')+1,'yyyy') > par_edi_gento_year then
               exit;
            end if;
            if upper(par_edi_gento_day) = '*LAST' then
               var_bilto_str_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+1,'yyyymmdd');
               var_bilto_end_date := to_char(last_day(add_months(to_date(substr(var_bilto_end_date,1,6)||'01','yyyymmdd'),1)),'yyyymmdd');
            else
               var_bilto_str_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+1,'yyyymmdd');
               var_bilto_end_date := to_char(add_months(to_date(substr(var_bilto_end_date,1,6)||'01','yyyymmdd'),1),'yyyymm')||par_edi_gento_day;
            end if;
            var_bilto_date := var_bilto_end_date;
            var_sndon_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+2,'yyyymmdd');
            rcd_whslr_billing.edi_sndto_code := rcd_whslr.edi_sndto_code;
            rcd_whslr_billing.edi_bilto_date := var_bilto_date;
            rcd_whslr_billing.edi_bilto_str_date := var_bilto_str_date;
            rcd_whslr_billing.edi_bilto_end_date := var_bilto_end_date;
            rcd_whslr_billing.edi_sndon_date := var_sndon_date;
            insert into whslr_billing values rcd_whslr_billing;
         end loop;

      end if;

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
   end update_whslr;

   /********************************************************/
   /* This function performs the delete wholesaler routine */
   /********************************************************/
   function delete_whslr(par_edi_sndto_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_01 is 
         select *
           from whslr t01
          where t01.edi_sndto_code = rcd_whslr.edi_sndto_code;
      rcd_whslr_01 csr_whslr_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Wholesaler';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr.edi_sndto_code := par_edi_sndto_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr.edi_sndto_code is null then
         var_message := var_message || chr(13) || 'Send to code must be specified';
      end if;

      /*-*/
      /* Wholesaler must already exist
      /*-*/
      open csr_whslr_01;
      fetch csr_whslr_01 into rcd_whslr_01;
      if csr_whslr_01%notfound then
         var_message := var_message || chr(13) || 'Wholesaler (' || rcd_whslr.edi_sndto_code || ') does not exist';
      end if;
      close csr_whslr_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the related monthly invoice data
      /*-*/
      delete from whslr_mly_inv_det where edi_sndto_code = rcd_whslr.edi_sndto_code;
      delete from whslr_mly_inv_bch where edi_sndto_code = rcd_whslr.edi_sndto_code;
      delete from whslr_mly_inv_hdr where edi_sndto_code = rcd_whslr.edi_sndto_code;

      /*-*/
      /* elete the related daily invoice data
      /*-*/
      delete from whslr_dly_inv_det where sap_invoice_number in (select sap_invoice_number from whslr_dly_inv_hdr where edi_sndto_code = rcd_whslr.edi_sndto_code);
      delete from whslr_dly_inv_hdr where edi_sndto_code = rcd_whslr.edi_sndto_code;

      /*-*/
      /* Delete the related billing data
      /*-*/
      delete from whslr_billing where edi_sndto_code = rcd_whslr.edi_sndto_code;

      /*-*/
      /* Delete the existing wholesaler
      /*-*/
      delete from whslr where edi_sndto_code = rcd_whslr.edi_sndto_code;

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
   end delete_whslr;

end edi_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_configuration for dw_app.edi_configuration;
grant execute on edi_configuration to public;