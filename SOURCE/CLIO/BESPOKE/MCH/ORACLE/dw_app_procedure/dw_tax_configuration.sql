/******************/
/* Package Header */
/******************/
create or replace package dw_tax_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : clio
    Package : dw_tax_configuration
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Dimensional Data Store - China Tax Configuration

    The package implements the China Tax Configuration functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function insert_tax_customer(par_cust_code in varchar2,
                                par_cust_name in varchar2,
                                par_cust_addr in varchar2,
                                par_cust_bank in varchar2,
                                par_tax_code in varchar2) return varchar2;

   function update_tax_customer(par_cust_code in varchar2,
                                par_cust_name in varchar2,
                                par_cust_addr in varchar2,
                                par_cust_bank in varchar2,
                                par_tax_code in varchar2) return varchar2;

   function delete_tax_customer(par_cust_code in varchar2) return varchar2;

end dw_tax_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_tax_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_china_tax_customer china_tax_customer%rowtype;

   /****************************************************************/
   /* This function performs the insert china tax customer routine */
   /****************************************************************/
   function insert_tax_customer(par_cust_code in varchar2,
                                par_cust_name in varchar2,
                                par_cust_addr in varchar2,
                                par_cust_bank in varchar2,
                                par_tax_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_china_tax_customer_01 is 
         select *
           from china_tax_customer t01
          where t01.cust_code = rcd_china_tax_customer.cust_code;
      rcd_china_tax_customer_01 csr_china_tax_customer_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'China Local - Configuration - Insert Tax Customer';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_china_tax_customer.cust_code := upper(par_cust_code);
      rcd_china_tax_customer.cust_name := par_cust_name;
      rcd_china_tax_customer.cust_addr := par_cust_addr;
      rcd_china_tax_customer.cust_bank := par_cust_bank;
      rcd_china_tax_customer.tax_code := par_tax_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_china_tax_customer.cust_code is null then
         var_message := var_message || chr(13) || 'Customer code must be specified';
      end if;
      if rcd_china_tax_customer.cust_name is null then
         var_message := var_message || chr(13) || 'Customer name must be specified';
      end if;
      if rcd_china_tax_customer.cust_addr is null then
         var_message := var_message || chr(13) || 'Customer address must be specified';
      end if;
      if rcd_china_tax_customer.cust_bank is null then
         var_message := var_message || chr(13) || 'Customer bank account must be specified';
      end if;
      if rcd_china_tax_customer.tax_code is null then
         var_message := var_message || chr(13) || 'Tac code must be specified';
      end if;

      /*-*/
      /* Tax customer must not already exist
      /*-*/
      open csr_china_tax_customer_01;
      fetch csr_china_tax_customer_01 into rcd_china_tax_customer_01;
      if csr_china_tax_customer_01%found then
         var_message := var_message || chr(13) || 'Tax customer (' || rcd_china_tax_customer.cust_code || ') already exists';
      end if;
      close csr_china_tax_customer_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Create the new tax customer
      /*-*/
      insert into china_tax_customer values rcd_china_tax_customer;

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
   end insert_tax_customer;

   /****************************************************************/
   /* This function performs the update china tax customer routine */
   /****************************************************************/
   function update_tax_customer(par_cust_code in varchar2,
                                par_cust_name in varchar2,
                                par_cust_addr in varchar2,
                                par_cust_bank in varchar2,
                                par_tax_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_china_tax_customer_01 is 
         select *
           from china_tax_customer t01
          where t01.cust_code = rcd_china_tax_customer.cust_code;
      rcd_china_tax_customer_01 csr_china_tax_customer_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'China Local - Configuration - Update Tax Customer';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_china_tax_customer.cust_code := upper(par_cust_code);
      rcd_china_tax_customer.cust_name := par_cust_name;
      rcd_china_tax_customer.cust_addr := par_cust_addr;
      rcd_china_tax_customer.cust_bank := par_cust_bank;
      rcd_china_tax_customer.tax_code := par_tax_code;

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_china_tax_customer.cust_code is null then
         var_message := var_message || chr(13) || 'Customer code must be specified';
      end if;
      if rcd_china_tax_customer.cust_name is null then
         var_message := var_message || chr(13) || 'Customer name must be specified';
      end if;
      if rcd_china_tax_customer.cust_addr is null then
         var_message := var_message || chr(13) || 'Customer address must be specified';
      end if;
      if rcd_china_tax_customer.cust_bank is null then
         var_message := var_message || chr(13) || 'Customer bank account must be specified';
      end if;
      if rcd_china_tax_customer.tax_code is null then
         var_message := var_message || chr(13) || 'Tac code must be specified';
      end if;

      /*-*/
      /* Tax customer must already exist
      /*-*/
      open csr_china_tax_customer_01;
      fetch csr_china_tax_customer_01 into rcd_china_tax_customer_01;
      if csr_china_tax_customer_01%notfound then
         var_message := var_message || chr(13) || 'Tax customer (' || rcd_china_tax_customer.cust_code || ') does not exist';
      end if;
      close csr_china_tax_customer_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing tax customer
      /*-*/
      update china_tax_customer
         set cust_name = rcd_china_tax_customer.cust_name,
             cust_addr = rcd_china_tax_customer.cust_addr,
             cust_bank = rcd_china_tax_customer.cust_bank,
             tax_code = rcd_china_tax_customer.tax_code
         where cust_code = rcd_china_tax_customer.cust_code;

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
   end update_tax_customer;

   /****************************************************************/
   /* This function performs the delete china tax customer routine */
   /****************************************************************/
   function delete_tax_customer(par_cust_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_china_tax_customer_01 is 
         select *
           from china_tax_customer t01
          where t01.cust_code = rcd_china_tax_customer.cust_code;
      rcd_china_tax_customer_01 csr_china_tax_customer_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'China Local - Configuration - Delete Tax Customer';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_china_tax_customer.cust_code := upper(par_cust_code);

      /*-*/
      /* Validate the parameter values
      /*-*/
      if rcd_china_tax_customer.cust_code is null then
         var_message := var_message || chr(13) || 'Customer code must be specified';
      end if;

      /*-*/
      /* Tax customer must already exist
      /*-*/
      open csr_china_tax_customer_01;
      fetch csr_china_tax_customer_01 into rcd_china_tax_customer_01;
      if csr_china_tax_customer_01%notfound then
         var_message := var_message || chr(13) || 'Tax customer (' || rcd_china_tax_customer.cust_code || ') does not exist';
      end if;
      close csr_china_tax_customer_01;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing tax customer
      /*-*/
      delete from china_tax_customer where cust_code = rcd_china_tax_customer.cust_code;

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
   end delete_tax_customer;

end dw_tax_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_tax_configuration for dw_app.dw_tax_configuration;
grant execute on dw_tax_configuration to public;