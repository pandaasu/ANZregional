/******************/
/* Package Header */
/******************/
create or replace package pricelist_rule as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pricelist_rule
    Owner   : pr_app

    Description
    -----------
    Price List Generator - Rule Value Listing

    This package contain the procedures for the price list rule value listing.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list(par_price_rule_type_id in number) return pricelist_value pipelined;

end pricelist_rule;
/

/****************/
/* Package Body */
/****************/
create or replace package body pricelist_rule as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************/
   /* This procedure performs the report rule list routine */
   /********************************************************/
   function list(par_price_rule_type_id in number) return pricelist_value pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      type typ_cursor is ref cursor;
      csr_list typ_cursor;
      var_value varchar2(200);
      var_text varchar2(200);
 
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_price_rule_type is 
         select t01.sql_vlu
           from price_rule_type t01
          where t01.price_rule_type_id = par_price_rule_type_id;
      rcd_price_rule_type csr_price_rule_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the price rule type
      /*-*/
      open csr_price_rule_type;
      fetch csr_price_rule_type into rcd_price_rule_type;
      if csr_price_rule_type%notfound then
         raise_application_error(-20000, 'Price rule type (' || to_char(par_price_rule_type_id) || ') does not exist');
      end if;
      close csr_price_rule_type;

      /*-*/
      /* Retrieve the rule value list
      /*-*/
      open csr_list for rcd_price_rule_type.sql_vlu;
      loop
         fetch csr_list into var_value, var_text;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pricelist_value_object(var_value, var_text));
      end loop;
      close csr_list;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'PRICELIST_RULE - LIST - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list;

end pricelist_rule;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_rule for dw_app.pricelist_rule;
grant execute on pricelist_rule to public;
