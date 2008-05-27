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
    2008/05   Steve Gregan   Added wholesaler cycles for sub monthly invoicing

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_link(par_sap_cust_type in varchar2,
                        par_sap_cust_code in varchar2,
                        par_edi_link_type in varchar2,
                        par_edi_link_code in varchar2) return varchar2;

   function update_link(par_sap_cust_type in varchar2,
                        par_sap_cust_code in varchar2,
                        par_edi_link_type in varchar2,
                        par_edi_link_code in varchar2) return varchar2;

   function delete_link(par_sap_cust_type in varchar2,
                        par_sap_cust_code in varchar2) return varchar2;

   function insert_agency(par_edi_agency_code in varchar2,
                          par_edi_agency_name in varchar2,
                          par_update_user in varchar2) return varchar2;

   function update_agency(par_edi_agency_code in varchar2,
                          par_edi_agency_name in varchar2,
                          par_update_user in varchar2) return varchar2;

   function delete_agency(par_edi_agency_code in varchar2) return varchar2;

   function insert_agency_interface(par_edi_agency_code in varchar2,
                                    par_sap_sales_org_code in varchar2,
                                    par_sap_distbn_chnl_code in varchar2,
                                    par_sap_division_code in varchar2,
                                    par_edi_interface in varchar2) return varchar2;

   function update_agency_interface(par_edi_agency_code in varchar2,
                                    par_sap_sales_org_code in varchar2,
                                    par_sap_distbn_chnl_code in varchar2,
                                    par_sap_division_code in varchar2,
                                    par_edi_interface in varchar2) return varchar2;

   function delete_agency_interface(par_edi_agency_code in varchar2,
                                    par_sap_sales_org_code in varchar2,
                                    par_sap_distbn_chnl_code in varchar2,
                                    par_sap_division_code in varchar2) return varchar2;

   function insert_agency_transaction(par_sap_invoice_type in varchar2,
                                      par_sap_order_type in varchar2,
                                      par_edi_tran_code in varchar2) return varchar2;

   function update_agency_transaction(par_sap_invoice_type in varchar2,
                                      par_sap_order_type in varchar2,
                                      par_edi_tran_code in varchar2) return varchar2;

   function delete_agency_transaction(par_sap_invoice_type in varchar2,
                                      par_sap_order_type in varchar2) return varchar2;


   function insert_agency_discount(par_edi_disc_code in varchar2,
                                   par_edi_disc_name in varchar2) return varchar2;

   function update_agency_discount(par_edi_disc_code in varchar2,
                                   par_edi_disc_name in varchar2) return varchar2;

   function delete_agency_discount(par_edi_disc_code in varchar2) return varchar2;

   function insert_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_update_user in varchar2) return varchar2;

   function update_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_update_user in varchar2) return varchar2;

   function delete_whslr(par_edi_sndto_code in varchar2) return varchar2;

   function insert_whslr_cycle(par_edi_sndto_code in varchar2,
                               par_edi_effat_month in varchar2,
                               par_edi_sndon_delay number,
                               par_edi_cycle01 in varchar2,
                               par_edi_cycle02 in varchar2,
                               par_edi_cycle03 in varchar2,
                               par_edi_cycle04 in varchar2,
                               par_edi_cycle05 in varchar2) return varchar2;

   function delete_whslr_cycle(par_edi_sndto_code in varchar2,
                               par_edi_effat_month in varchar2) return varchar2;

   function insert_whslr_transaction(par_sap_order_type in varchar2,
                                     par_sap_invoice_type in varchar2,
                                     par_edi_ship_to_type in varchar2,
                                     par_edi_tran_code in varchar2) return varchar2;

   function update_whslr_transaction(par_sap_order_type in varchar2,
                                     par_sap_invoice_type in varchar2,
                                     par_edi_ship_to_type in varchar2,
                                     par_edi_tran_code in varchar2) return varchar2;

   function delete_whslr_transaction(par_sap_order_type in varchar2,
                                     par_sap_invoice_type in varchar2,
                                     par_edi_ship_to_type in varchar2) return varchar2;

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
   rcd_edi_link edi_link%rowtype;
   rcd_agency agency%rowtype;
   rcd_agency_interface agency_interface%rowtype;
   rcd_agency_transaction agency_transaction%rowtype;
   rcd_agency_discount agency_discount%rowtype;
   rcd_whslr whslr%rowtype;
   rcd_whslr_cycle_hdr whslr_cycle_hdr%rowtype;
   rcd_whslr_cycle_det whslr_cycle_det%rowtype;
   rcd_whslr_transaction whslr_transaction%rowtype;

   /**************************************************/
   /* This function performs the insert link routine */
   /**************************************************/
   function insert_link(par_sap_cust_type in varchar2,
                        par_sap_cust_code in varchar2,
                        par_edi_link_type in varchar2,
                        par_edi_link_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_edi_link_01 is 
         select *
           from edi_link t01
          where t01.sap_cust_type = rcd_edi_link.sap_cust_type
            and t01.sap_cust_code = rcd_edi_link.sap_cust_code;
      rcd_edi_link_01 csr_edi_link_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert EDI Link';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_edi_link.sap_cust_type := upper(par_sap_cust_type);
      rcd_edi_link.sap_cust_code := par_sap_cust_code;
      rcd_edi_link.edi_link_type := upper(par_edi_link_type);
      rcd_edi_link.edi_link_code := upper(par_edi_link_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_edi_link.sap_cust_type != '*SOLDTO' and rcd_edi_link.sap_cust_type != '*PAYER' then
         var_message := var_message || chr(13) || 'SAP customer type must be *SOLDTO or *PAYER';
      end if;
      if rcd_edi_link.sap_cust_code is null then
         var_message := var_message || chr(13) || 'SAP customer code code must be specified';
      end if;
      if rcd_edi_link.edi_link_type != '*AGENCY' and rcd_edi_link.edi_link_type != '*WHSLR' then
         var_message := var_message || chr(13) || 'EDI link type must be *AGENCY or *WHSLR';
      end if;
      if rcd_edi_link.edi_link_code is null then
         var_message := var_message || chr(13) || 'EDI link code must be specified';
      end if;

      /*-*/
      /* EDI link must not already exist
      /*-*/
      open csr_edi_link_01;
      fetch csr_edi_link_01 into rcd_edi_link_01;
      if csr_edi_link_01%found then
         var_message := var_message || chr(13) || 'EDI link (' || rcd_edi_link.sap_cust_type || '/' || rcd_edi_link.sap_cust_code || ') already exists';
      end if;
      close csr_edi_link_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new EDI link
      /*-*/
      insert into edi_link values rcd_edi_link;

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
   end insert_link;

   /**************************************************/
   /* This function performs the update link routine */
   /**************************************************/
   function update_link(par_sap_cust_type in varchar2,
                        par_sap_cust_code in varchar2,
                        par_edi_link_type in varchar2,
                        par_edi_link_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_edi_link_01 is 
         select *
           from edi_link t01
          where t01.sap_cust_type = rcd_edi_link.sap_cust_type
            and t01.sap_cust_code = rcd_edi_link.sap_cust_code;
      rcd_edi_link_01 csr_edi_link_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update EDI Link';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_edi_link.sap_cust_type := upper(par_sap_cust_type);
      rcd_edi_link.sap_cust_code := par_sap_cust_code;
      rcd_edi_link.edi_link_type := upper(par_edi_link_type);
      rcd_edi_link.edi_link_code := upper(par_edi_link_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_edi_link.sap_cust_type != '*SOLDTO' and rcd_edi_link.sap_cust_type != '*PAYER' then
         var_message := var_message || chr(13) || 'SAP customer type must be *SOLDTO or *PAYER';
      end if;
      if rcd_edi_link.sap_cust_code is null then
         var_message := var_message || chr(13) || 'SAP customer code code must be specified';
      end if;
      if rcd_edi_link.edi_link_type != '*AGENCY' and rcd_edi_link.edi_link_type != '*WHSLR' then
         var_message := var_message || chr(13) || 'EDI link type must be *AGENCY or *WHSLR';
      end if;
      if rcd_edi_link.edi_link_code is null then
         var_message := var_message || chr(13) || 'EDI link code must be specified';
      end if;

      /*-*/
      /* EDI link must already exist
      /*-*/
      open csr_edi_link_01;
      fetch csr_edi_link_01 into rcd_edi_link_01;
      if csr_edi_link_01%notfound then
         var_message := var_message || chr(13) || 'EDI link (' || rcd_edi_link.sap_cust_type || '/' || rcd_edi_link.sap_cust_code || ') does not exist';
      end if;
      close csr_edi_link_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing EDI link
      /*-*/
      update edi_link
         set edi_link_type = rcd_edi_link.edi_link_type,
             edi_link_code = rcd_edi_link.edi_link_code
         where sap_cust_type = rcd_edi_link.sap_cust_type
           and sap_cust_code = rcd_edi_link.sap_cust_code;

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
   end update_link;

   /**************************************************/
   /* This function performs the delete link routine */
   /**************************************************/
   function delete_link(par_sap_cust_type in varchar2,
                        par_sap_cust_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_edi_link_01 is 
         select *
           from edi_link t01
          where t01.sap_cust_type = rcd_edi_link.sap_cust_type
            and t01.sap_cust_code = rcd_edi_link.sap_cust_code;
      rcd_edi_link_01 csr_edi_link_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete EDI Link';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_edi_link.sap_cust_type := upper(par_sap_cust_type);
      rcd_edi_link.sap_cust_code := par_sap_cust_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_edi_link.sap_cust_type != '*SOLDTO' and rcd_edi_link.sap_cust_type != '*PAYER' then
         var_message := var_message || chr(13) || 'SAP customer type must be *SOLDTO or *PAYER';
      end if;
      if rcd_edi_link.sap_cust_code is null then
         var_message := var_message || chr(13) || 'SAP customer code code must be specified';
      end if;

      /*-*/
      /* EDI link must already exist
      /*-*/
      open csr_edi_link_01;
      fetch csr_edi_link_01 into rcd_edi_link_01;
      if csr_edi_link_01%notfound then
         var_message := var_message || chr(13) || 'EDI link (' || rcd_edi_link.sap_cust_type || '/' || rcd_edi_link.sap_cust_code || ') does not exist';
      end if;
      close csr_edi_link_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing EDI link
      /*-*/
      delete from edi_link
       where sap_cust_type = rcd_edi_link.sap_cust_type
         and sap_cust_code = rcd_edi_link.sap_cust_code;

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
   end delete_link;

   /****************************************************/
   /* This function performs the insert agency routine */
   /****************************************************/
   function insert_agency(par_edi_agency_code in varchar2,
                          par_edi_agency_name in varchar2,
                          par_update_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_01 is 
         select *
           from agency t01
          where t01.edi_agency_code = rcd_agency.edi_agency_code;
      rcd_agency_01 csr_agency_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert Collection Agency';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency.edi_agency_code := upper(par_edi_agency_code);
      rcd_agency.edi_agency_name := par_edi_agency_name;
      rcd_agency.update_user := par_update_user;
      rcd_agency.update_date := sysdate;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency.edi_agency_code is null then
         var_message := var_message || chr(13) || 'Agency code must be specified';
      end if;
      if rcd_agency.edi_agency_name is null then
         var_message := var_message || chr(13) || 'Agency name must be specified';
      end if;

      /*-*/
      /* Agency must not already exist
      /*-*/
      open csr_agency_01;
      fetch csr_agency_01 into rcd_agency_01;
      if csr_agency_01%found then
         var_message := var_message || chr(13) || 'Collection agency (' || rcd_agency.edi_agency_code || ') already exists';
      end if;
      close csr_agency_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new agency
      /*-*/
      insert into agency values rcd_agency;

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
   end insert_agency;

   /****************************************************/
   /* This function performs the update agency routine */
   /****************************************************/
   function update_agency(par_edi_agency_code in varchar2,
                          par_edi_agency_name in varchar2,
                          par_update_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_01 is 
         select *
           from agency t01
          where t01.edi_agency_code = rcd_agency.edi_agency_code;
      rcd_agency_01 csr_agency_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Collection Agency';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency.edi_agency_code := upper(par_edi_agency_code);
      rcd_agency.edi_agency_name := par_edi_agency_name;
      rcd_agency.update_user := par_update_user;
      rcd_agency.update_date := sysdate;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency.edi_agency_code is null then
         var_message := var_message || chr(13) || 'Agency code must be specified';
      end if;
      if rcd_agency.edi_agency_name is null then
         var_message := var_message || chr(13) || 'Agency name must be specified';
      end if;

      /*-*/
      /* Agency must already exist
      /*-*/
      open csr_agency_01;
      fetch csr_agency_01 into rcd_agency_01;
      if csr_agency_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency (' || rcd_agency.edi_agency_code || ') does not exist';
      end if;
      close csr_agency_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing agency
      /*-*/
      update agency
         set edi_agency_name = rcd_agency.edi_agency_name,
             update_user = rcd_agency.update_user,
             update_date = rcd_agency.update_date
         where edi_agency_code = rcd_agency.edi_agency_code;

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
   end update_agency;

   /****************************************************/
   /* This function performs the delete agency routine */
   /****************************************************/
   function delete_agency(par_edi_agency_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_01 is 
         select *
           from agency t01
          where t01.edi_agency_code = rcd_agency.edi_agency_code;
      rcd_agency_01 csr_agency_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete Collection Agency';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency.edi_agency_code := upper(par_edi_agency_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency.edi_agency_code is null then
         var_message := var_message || chr(13) || 'Agency code must be specified';
      end if;

      /*-*/
      /* Agency must already exist
      /*-*/
      open csr_agency_01;
      fetch csr_agency_01 into rcd_agency_01;
      if csr_agency_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency (' || rcd_agency.edi_agency_code || ') does not exist';
      end if;
      close csr_agency_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the related data
      /*-*/
      delete from agency_interface where edi_agency_code = rcd_agency.edi_agency_code;

      /*-*/
      /* Delete the existing agency
      /*-*/
      delete from agency where edi_agency_code = rcd_agency.edi_agency_code;

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
   end delete_agency;

   /**************************************************************/
   /* This function performs the insert agency interface routine */
   /**************************************************************/
   function insert_agency_interface(par_edi_agency_code in varchar2,
                                    par_sap_sales_org_code in varchar2,
                                    par_sap_distbn_chnl_code in varchar2,
                                    par_sap_division_code in varchar2,
                                    par_edi_interface in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_interface_01 is 
         select *
           from agency_interface t01
          where t01.edi_agency_code = rcd_agency_interface.edi_agency_code
            and t01.sap_sales_org_code = rcd_agency_interface.sap_sales_org_code
            and t01.sap_distbn_chnl_code = rcd_agency_interface.sap_distbn_chnl_code
            and t01.sap_division_code = rcd_agency_interface.sap_division_code;
      rcd_agency_interface_01 csr_agency_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert Collection Agency Interface';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_interface.edi_agency_code := upper(par_edi_agency_code);
      rcd_agency_interface.sap_sales_org_code := par_sap_sales_org_code;
      rcd_agency_interface.sap_distbn_chnl_code := par_sap_distbn_chnl_code;
      rcd_agency_interface.sap_division_code := par_sap_division_code;
      rcd_agency_interface.edi_interface := upper(par_edi_interface);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_interface.edi_agency_code is null then
         var_message := var_message || chr(13) || 'Collection agency code must be specified';
      end if;
      if rcd_agency_interface.sap_sales_org_code is null then
         var_message := var_message || chr(13) || 'SAP sales organisation code must be specified';
      end if;
      if rcd_agency_interface.sap_distbn_chnl_code is null then
         var_message := var_message || chr(13) || 'SAP distribution channel code must be specified';
      end if;
      if rcd_agency_interface.sap_division_code is null then
         var_message := var_message || chr(13) || 'SAP division code must be specified';
      end if;
      if rcd_agency_interface.edi_interface is null then
         var_message := var_message || chr(13) || 'ICS interface code must be specified';
      end if;

      /*-*/
      /* Agency interface must not already exist
      /*-*/
      open csr_agency_interface_01;
      fetch csr_agency_interface_01 into rcd_agency_interface_01;
      if csr_agency_interface_01%found then
         var_message := var_message || chr(13) || 'Collection agency interface (' || rcd_agency_interface.edi_agency_code || '/' || rcd_agency_interface.sap_sales_org_code || '/' || rcd_agency_interface.sap_distbn_chnl_code || '/' || rcd_agency_interface.sap_division_code || ') already exists';
      end if;
      close csr_agency_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new agency interface
      /*-*/
      insert into agency_interface values rcd_agency_interface;

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
   end insert_agency_interface;

   /**************************************************************/
   /* This function performs the update agency interface routine */
   /**************************************************************/
   function update_agency_interface(par_edi_agency_code in varchar2,
                                    par_sap_sales_org_code in varchar2,
                                    par_sap_distbn_chnl_code in varchar2,
                                    par_sap_division_code in varchar2,
                                    par_edi_interface in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_interface_01 is 
         select *
           from agency_interface t01
          where t01.edi_agency_code = rcd_agency_interface.edi_agency_code
            and t01.sap_sales_org_code = rcd_agency_interface.sap_sales_org_code
            and t01.sap_distbn_chnl_code = rcd_agency_interface.sap_distbn_chnl_code
            and t01.sap_division_code = rcd_agency_interface.sap_division_code;
      rcd_agency_interface_01 csr_agency_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Collection Agency Interface';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_interface.edi_agency_code := upper(par_edi_agency_code);
      rcd_agency_interface.sap_sales_org_code := par_sap_sales_org_code;
      rcd_agency_interface.sap_distbn_chnl_code := par_sap_distbn_chnl_code;
      rcd_agency_interface.sap_division_code := par_sap_division_code;
      rcd_agency_interface.edi_interface := upper(par_edi_interface);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_interface.edi_agency_code is null then
         var_message := var_message || chr(13) || 'Collection agency code must be specified';
      end if;
      if rcd_agency_interface.sap_sales_org_code is null then
         var_message := var_message || chr(13) || 'SAP sales organisation code must be specified';
      end if;
      if rcd_agency_interface.sap_distbn_chnl_code is null then
         var_message := var_message || chr(13) || 'SAP distribution channel code must be specified';
      end if;
      if rcd_agency_interface.sap_division_code is null then
         var_message := var_message || chr(13) || 'SAP division code must be specified';
      end if;
      if rcd_agency_interface.edi_interface is null then
         var_message := var_message || chr(13) || 'ICS interface code must be specified';
      end if;

      /*-*/
      /* Agency interface must already exist
      /*-*/
      open csr_agency_interface_01;
      fetch csr_agency_interface_01 into rcd_agency_interface_01;
      if csr_agency_interface_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency interface (' || rcd_agency_interface.edi_agency_code || '/' || rcd_agency_interface.sap_sales_org_code || '/' || rcd_agency_interface.sap_distbn_chnl_code || '/' || rcd_agency_interface.sap_division_code || ') does not exist';
      end if;
      close csr_agency_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing agency interface
      /*-*/
      update agency_interface
         set edi_interface = rcd_agency_interface.edi_interface
         where edi_agency_code = rcd_agency_interface.edi_agency_code
           and sap_sales_org_code = rcd_agency_interface.sap_sales_org_code
           and sap_distbn_chnl_code = rcd_agency_interface.sap_distbn_chnl_code
           and sap_division_code = rcd_agency_interface.sap_division_code;

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
   end update_agency_interface;

   /**************************************************************/
   /* This function performs the delete agency interface routine */
   /**************************************************************/
   function delete_agency_interface(par_edi_agency_code in varchar2,
                                    par_sap_sales_org_code in varchar2,
                                    par_sap_distbn_chnl_code in varchar2,
                                    par_sap_division_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_interface_01 is 
         select *
           from agency_interface t01
          where t01.edi_agency_code = rcd_agency_interface.edi_agency_code
            and t01.sap_sales_org_code = rcd_agency_interface.sap_sales_org_code
            and t01.sap_distbn_chnl_code = rcd_agency_interface.sap_distbn_chnl_code
            and t01.sap_division_code = rcd_agency_interface.sap_division_code;
      rcd_agency_interface_01 csr_agency_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete Collection Agency Interface';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_interface.edi_agency_code := upper(par_edi_agency_code);
      rcd_agency_interface.sap_sales_org_code := par_sap_sales_org_code;
      rcd_agency_interface.sap_distbn_chnl_code := par_sap_distbn_chnl_code;
      rcd_agency_interface.sap_division_code := par_sap_division_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_interface.edi_agency_code is null then
         var_message := var_message || chr(13) || 'Collection agency code must be specified';
      end if;
      if rcd_agency_interface.sap_sales_org_code is null then
         var_message := var_message || chr(13) || 'SAP sales organisation code must be specified';
      end if;
      if rcd_agency_interface.sap_distbn_chnl_code is null then
         var_message := var_message || chr(13) || 'SAP distribution channel code must be specified';
      end if;
      if rcd_agency_interface.sap_division_code is null then
         var_message := var_message || chr(13) || 'SAP division code must be specified';
      end if;

      /*-*/
      /* Agency interface must already exist
      /*-*/
      open csr_agency_interface_01;
      fetch csr_agency_interface_01 into rcd_agency_interface_01;
      if csr_agency_interface_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency interface (' || rcd_agency_interface.edi_agency_code || '/' || rcd_agency_interface.sap_sales_org_code || '/' || rcd_agency_interface.sap_distbn_chnl_code || '/' || rcd_agency_interface.sap_division_code || ') does not exist';
      end if;
      close csr_agency_interface_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing agency interface
      /*-*/
      delete from agency_interface
         where edi_agency_code = rcd_agency_interface.edi_agency_code
           and sap_sales_org_code = rcd_agency_interface.sap_sales_org_code
           and sap_distbn_chnl_code = rcd_agency_interface.sap_distbn_chnl_code
           and sap_division_code = rcd_agency_interface.sap_division_code;

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
   end delete_agency_interface;

   /****************************************************************/
   /* This function performs the insert agency transaction routine */
   /****************************************************************/
   function insert_agency_transaction(par_sap_invoice_type in varchar2,
                                      par_sap_order_type in varchar2,
                                      par_edi_tran_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_transaction_01 is 
         select *
           from agency_transaction t01
          where t01.sap_invoice_type = rcd_agency_transaction.sap_invoice_type
            and t01.sap_order_type = rcd_agency_transaction.sap_order_type;
      rcd_agency_transaction_01 csr_agency_transaction_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert Collection Agency Transaction';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_transaction.sap_invoice_type := upper(par_sap_invoice_type);
      rcd_agency_transaction.sap_order_type := upper(par_sap_order_type);
      rcd_agency_transaction.edi_tran_code := upper(par_edi_tran_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_transaction.sap_invoice_type is null then
         var_message := var_message || chr(13) || 'SAP invoice type must be specified';
      end if;
      if rcd_agency_transaction.sap_order_type is null then
         var_message := var_message || chr(13) || 'SAP order type must be specified';
      end if;
      if rcd_agency_transaction.edi_tran_code is null then
         var_message := var_message || chr(13) || 'EDI transaction code must be specified';
      end if;

      /*-*/
      /* Agency transaction must not already exist
      /*-*/
      open csr_agency_transaction_01;
      fetch csr_agency_transaction_01 into rcd_agency_transaction_01;
      if csr_agency_transaction_01%found then
         var_message := var_message || chr(13) || 'Collection agency transaction (' || rcd_agency_transaction.sap_invoice_type || '/' || rcd_agency_transaction.sap_order_type || ') already exists';
      end if;
      close csr_agency_transaction_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new agency transaction
      /*-*/
      insert into agency_transaction values rcd_agency_transaction;

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
   end insert_agency_transaction;

   /****************************************************************/
   /* This function performs the update agency transaction routine */
   /****************************************************************/
   function update_agency_transaction(par_sap_invoice_type in varchar2,
                                      par_sap_order_type in varchar2,
                                      par_edi_tran_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_transaction_01 is 
         select *
           from agency_transaction t01
          where t01.sap_invoice_type = rcd_agency_transaction.sap_invoice_type
            and t01.sap_order_type = rcd_agency_transaction.sap_order_type;
      rcd_agency_transaction_01 csr_agency_transaction_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Collection Agency Transaction';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_transaction.sap_invoice_type := upper(par_sap_invoice_type);
      rcd_agency_transaction.sap_order_type := upper(par_sap_order_type);
      rcd_agency_transaction.edi_tran_code := upper(par_edi_tran_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_transaction.sap_invoice_type is null then
         var_message := var_message || chr(13) || 'SAP invoice type must be specified';
      end if;
      if rcd_agency_transaction.sap_order_type is null then
         var_message := var_message || chr(13) || 'SAP order type must be specified';
      end if;
      if rcd_agency_transaction.edi_tran_code is null then
         var_message := var_message || chr(13) || 'EDI transaction code must be specified';
      end if;

      /*-*/
      /* Agency transaction must already exist
      /*-*/
      open csr_agency_transaction_01;
      fetch csr_agency_transaction_01 into rcd_agency_transaction_01;
      if csr_agency_transaction_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency transaction (' || rcd_agency_transaction.sap_invoice_type || '/' || rcd_agency_transaction.sap_order_type || ') does not exist';
      end if;
      close csr_agency_transaction_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing agency transaction
      /*-*/
      update agency_transaction
         set edi_tran_code = rcd_agency_transaction.edi_tran_code
         where sap_invoice_type = rcd_agency_transaction.sap_invoice_type
           and sap_order_type = rcd_agency_transaction.sap_order_type;

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
   end update_agency_transaction;

   /****************************************************************/
   /* This function performs the delete agency transaction routine */
   /****************************************************************/
   function delete_agency_transaction(par_sap_invoice_type in varchar2,
                                      par_sap_order_type in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_transaction_01 is 
         select *
           from agency_transaction t01
          where t01.sap_invoice_type = rcd_agency_transaction.sap_invoice_type
            and t01.sap_order_type = rcd_agency_transaction.sap_order_type;
      rcd_agency_transaction_01 csr_agency_transaction_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete Collection Agency Transaction';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_transaction.sap_invoice_type := upper(par_sap_invoice_type);
      rcd_agency_transaction.sap_order_type := upper(par_sap_order_type);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_transaction.sap_invoice_type is null then
         var_message := var_message || chr(13) || 'SAP invoice type must be specified';
      end if;
      if rcd_agency_transaction.sap_order_type is null then
         var_message := var_message || chr(13) || 'SAP order type must be specified';
      end if;

      /*-*/
      /* Agency transaction must already exist
      /*-*/
      open csr_agency_transaction_01;
      fetch csr_agency_transaction_01 into rcd_agency_transaction_01;
      if csr_agency_transaction_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency transaction (' || rcd_agency_transaction.sap_invoice_type || '/' || rcd_agency_transaction.sap_order_type || ') does not exist';
      end if;
      close csr_agency_transaction_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing agency transaction
      /*-*/
      delete from agency_transaction
         where sap_invoice_type = rcd_agency_transaction.sap_invoice_type
           and sap_order_type = rcd_agency_transaction.sap_order_type;

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
   end delete_agency_transaction;

   /*************************************************************/
   /* This function performs the insert agency discount routine */
   /*************************************************************/
   function insert_agency_discount(par_edi_disc_code in varchar2,
                                   par_edi_disc_name in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_discount_01 is 
         select *
           from agency_discount t01
          where t01.edi_disc_code = rcd_agency_discount.edi_disc_code;
      rcd_agency_discount_01 csr_agency_discount_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert Collection Agency Discount';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_discount.edi_disc_code := upper(par_edi_disc_code);
      rcd_agency_discount.edi_disc_name := par_edi_disc_name;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_discount.edi_disc_code is null then
         var_message := var_message || chr(13) || 'Agency discount code must be specified';
      end if;
      if rcd_agency_discount.edi_disc_name is null then
         var_message := var_message || chr(13) || 'Agency discount name must be specified';
      end if;

      /*-*/
      /* Agency discount must not already exist
      /*-*/
      open csr_agency_discount_01;
      fetch csr_agency_discount_01 into rcd_agency_discount_01;
      if csr_agency_discount_01%found then
         var_message := var_message || chr(13) || 'Collection agency discount (' || rcd_agency_discount.edi_disc_code || ') already exists';
      end if;
      close csr_agency_discount_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new agency discount
      /*-*/
      insert into agency_discount values rcd_agency_discount;

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
   end insert_agency_discount;

   /*************************************************************/
   /* This function performs the update agency discount routine */
   /*************************************************************/
   function update_agency_discount(par_edi_disc_code in varchar2,
                                   par_edi_disc_name in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_discount_01 is 
         select *
           from agency_discount t01
          where t01.edi_disc_code = rcd_agency_discount.edi_disc_code;
      rcd_agency_discount_01 csr_agency_discount_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Collection Agency Discount';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_discount.edi_disc_code := upper(par_edi_disc_code);
      rcd_agency_discount.edi_disc_name := par_edi_disc_name;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_discount.edi_disc_code is null then
         var_message := var_message || chr(13) || 'Agency discount code must be specified';
      end if;
      if rcd_agency_discount.edi_disc_name is null then
         var_message := var_message || chr(13) || 'Agency discount name must be specified';
      end if;

      /*-*/
      /* Agency discount must already exist
      /*-*/
      open csr_agency_discount_01;
      fetch csr_agency_discount_01 into rcd_agency_discount_01;
      if csr_agency_discount_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency discount (' || rcd_agency_discount.edi_disc_code || ') does not exist';
      end if;
      close csr_agency_discount_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing agency discount
      /*-*/
      update agency_discount
         set edi_disc_name = rcd_agency_discount.edi_disc_name
         where edi_disc_code = rcd_agency_discount.edi_disc_code;

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
   end update_agency_discount;

   /*************************************************************/
   /* This function performs the delete agency discount routine */
   /*************************************************************/
   function delete_agency_discount(par_edi_disc_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_discount_01 is 
         select *
           from agency_discount t01
          where t01.edi_disc_code = rcd_agency_discount.edi_disc_code;
      rcd_agency_discount_01 csr_agency_discount_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete Collection Agency Discount';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_agency_discount.edi_disc_code := upper(par_edi_disc_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_agency_discount.edi_disc_code is null then
         var_message := var_message || chr(13) || 'Agency discount code must be specified';
      end if;

      /*-*/
      /* Agency discount must already exist
      /*-*/
      open csr_agency_discount_01;
      fetch csr_agency_discount_01 into rcd_agency_discount_01;
      if csr_agency_discount_01%notfound then
         var_message := var_message || chr(13) || 'Collection agency discount (' || rcd_agency_discount.edi_disc_code || ') does not exist';
      end if;
      close csr_agency_discount_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing agency discount
      /*-*/
      delete from agency_discount where edi_disc_code = rcd_agency_discount.edi_disc_code;

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
   end delete_agency_discount;

   /********************************************************/
   /* This function performs the insert wholesaler routine */
   /********************************************************/
   function insert_whslr(par_edi_sndto_code in varchar2,
                         par_edi_whslr_code in varchar2,
                         par_edi_whslr_name in varchar2,
                         par_edi_disc_code in varchar2,
                         par_edi_email_group in varchar2,
                         par_update_user in varchar2) return varchar2 is

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
      var_title := 'Electronic Data Interchange - Configuration - Insert Wholesaler';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr.edi_sndto_code := upper(par_edi_sndto_code);
      rcd_whslr.edi_whslr_code := upper(par_edi_whslr_code);
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
      if rcd_whslr.edi_disc_code != 'A' and rcd_whslr.edi_disc_code != 'V' and rcd_whslr.edi_disc_code != 'N' then
         var_message := var_message || chr(13) || 'Discount code must be A(All), V(Volume only) or N(None)';
      end if;
      if rcd_whslr.edi_email_group is null then
         var_message := var_message || chr(13) || 'Email group must be specified';
      end if;
      if rcd_whslr.update_user is null then
         var_message := var_message || chr(13) || 'Update user must be specified';
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
      insert into whslr values rcd_whslr;

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
                         par_update_user in varchar2) return varchar2 is

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
      rcd_whslr.edi_sndto_code := upper(par_edi_sndto_code);
      rcd_whslr.edi_whslr_code := upper(par_edi_whslr_code);
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
      if rcd_whslr.edi_disc_code != 'A' and rcd_whslr.edi_disc_code != 'V' and rcd_whslr.edi_disc_code != 'N' then
         var_message := var_message || chr(13) || 'Discount code must be A(All), V(Volume only) or N(None)';
      end if;
      if rcd_whslr.edi_email_group is null then
         var_message := var_message || chr(13) || 'Email group must be specified';
      end if;
      if rcd_whslr.update_user is null then
         var_message := var_message || chr(13) || 'Update user must be specified';
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
      var_title := 'Electronic Data Interchange - Configuration - Delete Wholesaler';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr.edi_sndto_code := upper(par_edi_sndto_code);

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
      /* Delete the related cycle detail data
      /*-*/
      delete from whslr_cycle_det where edi_sndto_code = rcd_whslr.edi_sndto_code;

      /*-*/
      /* Delete the related cycle header data
      /*-*/
      delete from whslr_cycle_hdr where edi_sndto_code = rcd_whslr.edi_sndto_code;

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

   /**************************************************************/
   /* This function performs the insert wholesaler cycle routine */
   /**************************************************************/
   function insert_whslr_cycle(par_edi_sndto_code in varchar2,
                               par_edi_effat_month in varchar2,
                               par_edi_sndon_delay number,
                               par_edi_cycle01 in varchar2,
                               par_edi_cycle02 in varchar2,
                               par_edi_cycle03 in varchar2,
                               par_edi_cycle04 in varchar2,
                               par_edi_cycle05 in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_work11 varchar2(20);
      var_work12 varchar2(20);
      var_work13 varchar2(20);
      var_work21 varchar2(20);
      var_work22 varchar2(20);
      var_work23 varchar2(20);
      var_work31 varchar2(20);
      var_work32 varchar2(20);
      var_work33 varchar2(20);
      var_work41 varchar2(20);
      var_work42 varchar2(20);
      var_work43 varchar2(20);
      var_work51 varchar2(20);
      var_work52 varchar2(20);
      var_work53 varchar2(20);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_01 is 
         select *
           from whslr t01
          where t01.edi_sndto_code = rcd_whslr_cycle_hdr.edi_sndto_code;
      rcd_whslr_01 csr_whslr_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert Wholesaler Cycle';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr_cycle_hdr.edi_sndto_code := upper(par_edi_sndto_code);
      rcd_whslr_cycle_hdr.edi_effat_month := par_edi_effat_month;
      rcd_whslr_cycle_hdr.edi_sndon_delay := par_edi_sndon_delay;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr_cycle_hdr.edi_sndto_code is null then
         var_message := var_message || chr(13) || 'Send to code must be specified';
      end if;
      if rcd_whslr_cycle_hdr.edi_effat_month is null then
         var_message := var_message || chr(13) || 'Effective at month must be specified';
      end if;
      if rcd_whslr_cycle_hdr.edi_sndon_delay is null then
         var_message := var_message || chr(13) || 'Send on delay must be specified';
      else
         if rcd_whslr_cycle_hdr.edi_sndon_delay < 0 then
            var_message := var_message || chr(13) || 'Send on delay must be greater than or equal to zero';
         end if;
      end if;
      var_work11 := '*';
      var_work12 := '*';
      var_work13 := '*';
      var_work21 := '*';
      var_work22 := '*';
      var_work23 := '*';
      var_work31 := '*';
      var_work32 := '*';
      var_work33 := '*';
      var_work41 := '*';
      var_work42 := '*';
      var_work43 := '*';
      var_work51 := '*';
      var_work52 := '*';
      var_work53 := '*';
      if not(par_edi_cycle01 is null) and par_edi_cycle01 != '*' then
         if instr(par_edi_cycle01,':') != 0 then
            begin
               var_work11 := to_char(to_number(substr(par_edi_cycle01,1,instr(par_edi_cycle01,':')-1)),'fm00');
               var_work12 := 'C';
               if var_work11 <= '27' then
                  var_work12 := 'P';
               end if;
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 01 start day is not a valid number';
            end;
            if var_work11 < '01' or var_work11 > '55' then
               var_message := var_message || chr(13) || 'Cycle 01 start day is not a valid day';
            end if;
            if var_work11 = '55' then
               var_work11 := '99';
            end if;
            begin
               var_work13 := to_char(to_number(substr(par_edi_cycle01,instr(par_edi_cycle01,':')+1)),'fm00');
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 01 end day is not a valid number';
            end;
            if var_work13 < '28' or var_work13 > '55' then
               var_message := var_message || chr(13) || 'Cycle 01 end day is not a valid day';
            end if;
            if var_work13 = '55' then
               var_work13 := '99';
            end if;
            if var_work11 >= var_work13 then
               var_message := var_message || chr(13) || 'Cycle 01 end day must be greater than cycle 01 start day';
            end if;
         end if;
      end if;
      if not(par_edi_cycle02 is null) and par_edi_cycle02 != '*' then
         if instr(par_edi_cycle02,':') != 0 then
            begin
               var_work21 := to_char(to_number(substr(par_edi_cycle02,1,instr(par_edi_cycle02,':')-1)),'fm00');
               var_work22 := 'C';
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 02 start day is not a valid number';
            end;
            if var_work21 < '28' or var_work21 > '55' then
               var_message := var_message || chr(13) || 'Cycle 02 start day is not a valid day';
            end if;
            if var_work21 = '55' then
               var_work21 := '99';
            end if;
            begin
               var_work23 := to_char(to_number(substr(par_edi_cycle02,instr(par_edi_cycle02,':')+1)),'fm00');
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 02 end day is not a valid number';
            end;
            if var_work23 < '28' or var_work23 > '55' then
               var_message := var_message || chr(13) || 'Cycle 02 end day is not a valid day';
            end if;
            if var_work23 = '55' then
               var_work23 := '99';
            end if;
            if var_work21 >= var_work23 then
               var_message := var_message || chr(13) || 'Cycle 02 end day must be greater than cycle 02 start day';
            end if;
         end if;
      end if;
      if not(par_edi_cycle03 is null) and par_edi_cycle03 != '*' then
         if instr(par_edi_cycle03,':') != 0 then
            begin
               var_work31 := to_char(to_number(substr(par_edi_cycle03,1,instr(par_edi_cycle03,':')-1)),'fm00');
               var_work32 := 'C';
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 03 start day is not a valid number';
            end;
            if var_work31 < '28' or var_work31 > '55' then
               var_message := var_message || chr(13) || 'Cycle 03 start day is not a valid day';
            end if;
            if var_work31 = '55' then
               var_work31 := '99';
            end if;
            begin
               var_work33 := to_char(to_number(substr(par_edi_cycle03,instr(par_edi_cycle03,':')+1)),'fm00');
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 03 end day is not a valid number';
            end;
            if var_work33 < '28' or var_work33 > '55' then
               var_message := var_message || chr(13) || 'Cycle 03 end day is not a valid day';
            end if;
            if var_work33 = '55' then
               var_work33 := '99';
            end if;
            if var_work31 >= var_work33 then
               var_message := var_message || chr(13) || 'Cycle 03 end day must be greater than cycle 03 start day';
            end if;
         end if;
      end if;
      if not(par_edi_cycle04 is null) and par_edi_cycle04 != '*' then
         if instr(par_edi_cycle04,':') != 0 then
            begin
               var_work41 := to_char(to_number(substr(par_edi_cycle04,1,instr(par_edi_cycle04,':')-1)),'fm00');
               var_work42 := 'C';
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 04 start day is not a valid number';
            end;
            if var_work41 < '28' or var_work41 > '55' then
               var_message := var_message || chr(13) || 'Cycle 04 start day is not a valid day';
            end if;
            if var_work41 = '55' then
               var_work41 := '99';
            end if;
            begin
               var_work43 := to_char(to_number(substr(par_edi_cycle04,instr(par_edi_cycle04,':')+1)),'fm00');
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 04 end day is not a valid number';
            end;
            if var_work43 < '28' or var_work43 > '55' then
               var_message := var_message || chr(13) || 'Cycle 04 end day is not a valid day';
            end if;
            if var_work43 = '55' then
               var_work43 := '99';
            end if;
            if var_work41 >= var_work43 then
               var_message := var_message || chr(13) || 'Cycle 04 end day must be greater than cycle 03 start day';
            end if;
         end if;
      end if;
      if not(par_edi_cycle05 is null) and par_edi_cycle05 != '*' then
         if instr(par_edi_cycle05,':') != 0 then
            begin
               var_work51 := to_char(to_number(substr(par_edi_cycle05,1,instr(par_edi_cycle05,':')-1)),'fm00');
               var_work52 := 'C';
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 05 start day is not a valid number';
            end;
            if var_work51 < '28' or var_work51 > '55' then
               var_message := var_message || chr(13) || 'Cycle 05 start day is not a valid day';
            end if;
            if var_work51 = '55' then
               var_work51 := '99';
            end if;
            begin
               var_work53 := to_char(to_number(substr(par_edi_cycle05,instr(par_edi_cycle05,':')+1)),'fm00');
            exception
               when others then
                  var_message := var_message || chr(13) || 'Cycle 05 end day is not a valid number';
            end;
            if var_work53 < '28' or var_work53 > '55' then
               var_message := var_message || chr(13) || 'Cycle 05 end day is not a valid day';
            end if;
            if var_work53 = '55' then
               var_work53 := '99';
            end if;
            if var_work51 >= var_work53 then
               var_message := var_message || chr(13) || 'Cycle 05 end day must be greater than cycle 03 start day';
            end if;
         end if;
      end if;
      if var_work11 = '*' and var_work21 = '*' and var_work31 = '*' and var_work41 = '*' and var_work51 = '*' then
         var_message := var_message || chr(13) || 'At least one cycle must be specified';
      end if;

      /*-*/
      /* Wholesaler must exist
      /*-*/
      open csr_whslr_01;
      fetch csr_whslr_01 into rcd_whslr_01;
      if csr_whslr_01%notfound then
         var_message := var_message || chr(13) || 'Wholesaler (' || rcd_whslr_cycle_hdr.edi_sndto_code || ') does not exist';
      end if;
      close csr_whslr_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete any existing cycle header and detail
      /*-*/
      delete from whslr_cycle_det
       where edi_sndto_code = rcd_whslr_cycle_hdr.edi_sndto_code
         and edi_effat_month = rcd_whslr_cycle_hdr.edi_effat_month;
      delete from whslr_cycle_hdr
       where edi_sndto_code = rcd_whslr_cycle_hdr.edi_sndto_code
         and edi_effat_month = rcd_whslr_cycle_hdr.edi_effat_month;

      /*-*/
      /* Create the new wholesaler cycle header and detail
      /*-*/
      insert into whslr_cycle_hdr values rcd_whslr_cycle_hdr;
      /*-*/
      if var_work11 != '*' and var_work13 != '*' then
         if var_work12 = 'C' and var_work11 != '99' then
            var_work11 := to_char(to_number(var_work11)-27,'fm00');
         end if;
         if var_work13 != '99' then
            var_work13 := to_char(to_number(var_work13)-27,'fm00');
         end if;
         rcd_whslr_cycle_det.edi_sndto_code := rcd_whslr_cycle_hdr.edi_sndto_code;
         rcd_whslr_cycle_det.edi_effat_month := rcd_whslr_cycle_hdr.edi_effat_month;
         rcd_whslr_cycle_det.edi_endon_day := substr(var_work13,1,2);
         rcd_whslr_cycle_det.edi_stron_month := substr(var_work12,1,1);
         rcd_whslr_cycle_det.edi_stron_day := substr(var_work11,1,2);
         insert into whslr_cycle_det values rcd_whslr_cycle_det;
      end if;
      /*-*/
      if var_work21 != '*' and var_work23 != '*' then
         if var_work21 != '99' then
            var_work21 := to_char(to_number(var_work21)-27,'fm00');
         end if;
         if var_work23 != '99' then
            var_work23 := to_char(to_number(var_work23)-27,'fm00');
         end if;
         rcd_whslr_cycle_det.edi_sndto_code := rcd_whslr_cycle_hdr.edi_sndto_code;
         rcd_whslr_cycle_det.edi_effat_month := rcd_whslr_cycle_hdr.edi_effat_month;
         rcd_whslr_cycle_det.edi_endon_day := substr(var_work23,1,2);
         rcd_whslr_cycle_det.edi_stron_month := substr(var_work22,1,1);
         rcd_whslr_cycle_det.edi_stron_day := substr(var_work21,1,2);
         insert into whslr_cycle_det values rcd_whslr_cycle_det;
      end if;
      /*-*/
      if var_work31 != '*' and var_work33 != '*' then
         if var_work31 != '99' then
            var_work31 := to_char(to_number(var_work31)-27,'fm00');
         end if;
         if var_work33 != '99' then
            var_work33 := to_char(to_number(var_work33)-27,'fm00');
         end if;
         rcd_whslr_cycle_det.edi_sndto_code := rcd_whslr_cycle_hdr.edi_sndto_code;
         rcd_whslr_cycle_det.edi_effat_month := rcd_whslr_cycle_hdr.edi_effat_month;
         rcd_whslr_cycle_det.edi_endon_day := substr(var_work33,1,2);
         rcd_whslr_cycle_det.edi_stron_month := substr(var_work32,1,1);
         rcd_whslr_cycle_det.edi_stron_day := substr(var_work31,1,2);
         insert into whslr_cycle_det values rcd_whslr_cycle_det;
      end if;
      /*-*/
      if var_work41 != '*' and var_work43 != '*' then
         if var_work41 != '99' then
            var_work41 := to_char(to_number(var_work41)-27,'fm00');
         end if;
         if var_work43 != '99' then
            var_work43 := to_char(to_number(var_work43)-27,'fm00');
         end if;
         rcd_whslr_cycle_det.edi_sndto_code := rcd_whslr_cycle_hdr.edi_sndto_code;
         rcd_whslr_cycle_det.edi_effat_month := rcd_whslr_cycle_hdr.edi_effat_month;
         rcd_whslr_cycle_det.edi_endon_day := substr(var_work43,1,2);
         rcd_whslr_cycle_det.edi_stron_month := substr(var_work42,1,1);
         rcd_whslr_cycle_det.edi_stron_day := substr(var_work41,1,2);
         insert into whslr_cycle_det values rcd_whslr_cycle_det;
      end if;
      /*-*/
      if var_work51 != '*' and var_work53 != '*' then
         if var_work51 != '99' then
            var_work51 := to_char(to_number(var_work51)-27,'fm00');
         end if;
         if var_work53 != '99' then
            var_work53 := to_char(to_number(var_work53)-27,'fm00');
         end if;
         rcd_whslr_cycle_det.edi_sndto_code := rcd_whslr_cycle_hdr.edi_sndto_code;
         rcd_whslr_cycle_det.edi_effat_month := rcd_whslr_cycle_hdr.edi_effat_month;
         rcd_whslr_cycle_det.edi_endon_day := substr(var_work53,1,2);
         rcd_whslr_cycle_det.edi_stron_month := substr(var_work52,1,1);
         rcd_whslr_cycle_det.edi_stron_day := substr(var_work51,1,2);
         insert into whslr_cycle_det values rcd_whslr_cycle_det;
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
   end insert_whslr_cycle;

   /**************************************************************/
   /* This function performs the delete wholesaler cycle routine */
   /**************************************************************/
   function delete_whslr_cycle(par_edi_sndto_code in varchar2,
                               par_edi_effat_month in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete Wholesaler Cycle';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr_cycle_hdr.edi_sndto_code := upper(par_edi_sndto_code);
      rcd_whslr_cycle_hdr.edi_effat_month := par_edi_effat_month;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr_cycle_hdr.edi_sndto_code is null then
         var_message := var_message || chr(13) || 'Send to code must be specified';
      end if;
      if rcd_whslr_cycle_hdr.edi_effat_month is null then
         var_message := var_message || chr(13) || 'Effective at month must be specified';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the related cycle detail data
      /*-*/
      delete from whslr_cycle_det
       where edi_sndto_code = rcd_whslr_cycle_hdr.edi_sndto_code
         and edi_effat_month = rcd_whslr_cycle_hdr.edi_effat_month;

      /*-*/
      /* Delete the related cycle header data
      /*-*/
      delete from whslr_cycle_hdr
       where edi_sndto_code = rcd_whslr_cycle_hdr.edi_sndto_code
         and edi_effat_month = rcd_whslr_cycle_hdr.edi_effat_month;

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
   end delete_whslr_cycle;

   /********************************************************************/
   /* This function performs the insert wholesaler transaction routine */
   /********************************************************************/
   function insert_whslr_transaction(par_sap_order_type in varchar2,
                                     par_sap_invoice_type in varchar2,
                                     par_edi_ship_to_type in varchar2,
                                     par_edi_tran_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_transaction_01 is 
         select *
           from whslr_transaction t01
          where t01.sap_order_type = rcd_whslr_transaction.sap_order_type
            and t01.sap_invoice_type = rcd_whslr_transaction.sap_invoice_type
            and t01.edi_ship_to_type = rcd_whslr_transaction.edi_ship_to_type;
      rcd_whslr_transaction_01 csr_whslr_transaction_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Insert Wholesaler Transaction';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr_transaction.sap_order_type := upper(par_sap_order_type);
      rcd_whslr_transaction.sap_invoice_type := upper(par_sap_invoice_type);
      rcd_whslr_transaction.edi_ship_to_type := upper(par_edi_ship_to_type);
      rcd_whslr_transaction.edi_tran_code := upper(par_edi_tran_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr_transaction.sap_order_type is null then
         var_message := var_message || chr(13) || 'SAP order type must be specified';
      end if;
      if rcd_whslr_transaction.sap_invoice_type is null then
         var_message := var_message || chr(13) || 'SAP invoice type must be specified';
      end if;
      if rcd_whslr_transaction.edi_ship_to_type is null then
         var_message := var_message || chr(13) || 'EDI ship to must be specified';
      end if;
      if rcd_whslr_transaction.edi_tran_code is null then
         var_message := var_message || chr(13) || 'EDI transaction code must be specified';
      end if;

      /*-*/
      /* Wholesaler transaction must not already exist
      /*-*/
      open csr_whslr_transaction_01;
      fetch csr_whslr_transaction_01 into rcd_whslr_transaction_01;
      if csr_whslr_transaction_01%found then
         var_message := var_message || chr(13) || 'Wholesaler transaction (' || rcd_whslr_transaction.sap_order_type || '/' || rcd_whslr_transaction.sap_invoice_type || '/' || rcd_whslr_transaction.edi_ship_to_type || ') already exists';
      end if;
      close csr_whslr_transaction_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new wholesaler transaction
      /*-*/
      insert into whslr_transaction values rcd_whslr_transaction;

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
   end insert_whslr_transaction;

   /********************************************************************/
   /* This function performs the update wholesaler transaction routine */
   /********************************************************************/
   function update_whslr_transaction(par_sap_order_type in varchar2,
                                     par_sap_invoice_type in varchar2,
                                     par_edi_ship_to_type in varchar2,
                                     par_edi_tran_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_transaction_01 is 
         select *
           from whslr_transaction t01
          where t01.sap_order_type = rcd_whslr_transaction.sap_order_type
            and t01.sap_invoice_type = rcd_whslr_transaction.sap_invoice_type
            and t01.edi_ship_to_type = rcd_whslr_transaction.edi_ship_to_type;
      rcd_whslr_transaction_01 csr_whslr_transaction_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Update Wholesaler Transaction';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr_transaction.sap_order_type := upper(par_sap_order_type);
      rcd_whslr_transaction.sap_invoice_type := upper(par_sap_invoice_type);
      rcd_whslr_transaction.edi_ship_to_type := upper(par_edi_ship_to_type);
      rcd_whslr_transaction.edi_tran_code := upper(par_edi_tran_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr_transaction.sap_order_type is null then
         var_message := var_message || chr(13) || 'SAP order type must be specified';
      end if;
      if rcd_whslr_transaction.sap_invoice_type is null then
         var_message := var_message || chr(13) || 'SAP invoice type must be specified';
      end if;
      if rcd_whslr_transaction.edi_ship_to_type is null then
         var_message := var_message || chr(13) || 'EDI ship to must be specified';
      end if;
      if rcd_whslr_transaction.edi_tran_code is null then
         var_message := var_message || chr(13) || 'EDI transaction code must be specified';
      end if;

      /*-*/
      /* Wholesaler transaction must already exist
      /*-*/
      open csr_whslr_transaction_01;
      fetch csr_whslr_transaction_01 into rcd_whslr_transaction_01;
      if csr_whslr_transaction_01%notfound then
         var_message := var_message || chr(13) || 'Wholesaler transaction (' || rcd_whslr_transaction.sap_order_type || '/' || rcd_whslr_transaction.sap_invoice_type || '/' || rcd_whslr_transaction.edi_ship_to_type || ') does not exist';
      end if;
      close csr_whslr_transaction_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing wholesaler transaction
      /*-*/
      update whslr_transaction
         set edi_tran_code = rcd_whslr_transaction.edi_tran_code
         where sap_order_type = rcd_whslr_transaction.sap_order_type
           and sap_invoice_type = rcd_whslr_transaction.sap_invoice_type
           and edi_ship_to_type = rcd_whslr_transaction.edi_ship_to_type;

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
   end update_whslr_transaction;

   /********************************************************************/
   /* This function performs the delete wholesaler transaction routine */
   /********************************************************************/
   function delete_whslr_transaction(par_sap_order_type in varchar2,
                                     par_sap_invoice_type in varchar2,
                                     par_edi_ship_to_type in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_transaction_01 is 
         select *
           from whslr_transaction t01
          where t01.sap_order_type = rcd_whslr_transaction.sap_order_type
            and t01.sap_invoice_type = rcd_whslr_transaction.sap_invoice_type
            and t01.edi_ship_to_type = rcd_whslr_transaction.edi_ship_to_type;
      rcd_whslr_transaction_01 csr_whslr_transaction_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Electronic Data Interchange - Configuration - Delete Wholesaler Transaction';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_whslr_transaction.sap_order_type := upper(par_sap_order_type);
      rcd_whslr_transaction.sap_invoice_type := upper(par_sap_invoice_type);
      rcd_whslr_transaction.edi_ship_to_type := upper(par_edi_ship_to_type);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_whslr_transaction.sap_order_type is null then
         var_message := var_message || chr(13) || 'SAP order type must be specified';
      end if;
      if rcd_whslr_transaction.sap_invoice_type is null then
         var_message := var_message || chr(13) || 'SAP invoice type must be specified';
      end if;
      if rcd_whslr_transaction.edi_ship_to_type is null then
         var_message := var_message || chr(13) || 'EDI ship to must be specified';
      end if;

      /*-*/
      /* Wholesaler transaction must already exist
      /*-*/
      open csr_whslr_transaction_01;
      fetch csr_whslr_transaction_01 into rcd_whslr_transaction_01;
      if csr_whslr_transaction_01%notfound then
         var_message := var_message || chr(13) || 'Wholesaler transaction (' || rcd_whslr_transaction.sap_order_type || '/' || rcd_whslr_transaction.sap_invoice_type || '/' || rcd_whslr_transaction.edi_ship_to_type || ') does not exist';
      end if;
      close csr_whslr_transaction_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing wholesaler transaction
      /*-*/
      delete from whslr_transaction
         where sap_order_type = rcd_whslr_transaction.sap_order_type
           and sap_invoice_type = rcd_whslr_transaction.sap_invoice_type
           and edi_ship_to_type = rcd_whslr_transaction.edi_ship_to_type;

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
   end delete_whslr_transaction;

end edi_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_configuration for dw_app.edi_configuration;
grant execute on edi_configuration to public;