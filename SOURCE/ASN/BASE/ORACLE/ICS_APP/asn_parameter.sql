/******************/
/* Package Header */
/******************/
create or replace package asn_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_parameter
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - asn_parameter - ASN Parameter Functionality

    YYYY/MM   Author          Description
    -------   ------          -----------
    2005/11   Steve Gregan    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function update_value(par_group in varchar2,
                         par_code in varchar2,
                         par_value in varchar2) return varchar2;
   function retrieve_value(par_group in varchar2,
                           par_code in varchar2) return varchar2;

end asn_parameter;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_parameter as

   /****************************************************/
   /* This procedure performs the update value routine */
   /****************************************************/
   function update_value(par_group in varchar2,
                          par_code in varchar2,
                          par_value in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_number number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_par_cde is 
         select * 
           from asn_par_cde t01
          where t01.apc_group = upper(par_group)
            and t01.apc_code = upper(par_code);
      rcd_asn_par_cde csr_asn_par_cde%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - ASN Parameter Configuration - Update Value';
      var_message := null;

      /*-*/
      /* Retrieve the parameter code
      /*-*/
      open csr_asn_par_cde;
      fetch csr_asn_par_cde into rcd_asn_par_cde;
      if csr_asn_par_cde%notfound then
         var_message := var_message || chr(13) || 'Parameter code (' || upper(par_group) || '/' || upper(par_code) || ') does not exist';
      end if;
      close csr_asn_par_cde;

      /*-*/
      /* Check number when required
      /*-*/
      if rcd_asn_par_cde.apc_type = '*NUM' then
         begin
            var_number := to_number(par_value);
         exception
            when others then
               var_message := var_message || chr(13) || 'Parameter value (' || upper(par_group) || '/' || upper(par_code) || ') must be a number';
         end;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the parameter value
      /*-*/
      update asn_par_val
         set apv_value= par_value,
             apv_updt_tim = sysdate
         where apv_group = upper(par_group)
           and apv_code = upper(par_code);
      if sql%notfound then
         insert into asn_par_val
            (apv_group,
             apv_code,
             apv_value,
             apv_updt_tim)
            values(upper(par_group),
                   upper(par_code),
                   par_value,
                   sysdate);
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_value;

   /******************************************************/
   /* This procedure performs the retrieve value routine */
   /******************************************************/
   function retrieve_value(par_group in varchar2,
                           par_code in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return asn_par_val.apv_value%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_par_val is 
         select *
           from asn_par_val t01
          where t01.apv_group = upper(par_group)
            and t01.apv_code = upper(par_code);
      rcd_asn_par_val csr_asn_par_val%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the value
      /*-*/
      var_return := null;
      open csr_asn_par_val;
      fetch csr_asn_par_val into rcd_asn_par_val;
      if csr_asn_par_val%found then
         var_return := rcd_asn_par_val.apv_value;
      end if;
      close csr_asn_par_val;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_value;

end asn_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_parameter for ics_app.asn_parameter;
grant execute on asn_parameter to public;