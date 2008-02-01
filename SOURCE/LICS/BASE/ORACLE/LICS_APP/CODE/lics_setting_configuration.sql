/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_setting_configuration
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Setting Configuration

 The package implements the setting configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_setting_configuration as

   /*-*/
   /* Public declarations
   /*-*/
   procedure update_setting(par_group in varchar2,
                            par_code in varchar2,
                            par_value in varchar2);
   procedure delete_setting(par_group in varchar2,
                            par_code in varchar2);
   function retrieve_setting(par_group in varchar2,
                             par_code in varchar2) return varchar2;

end lics_setting_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_setting_configuration as

   /******************************************************/
   /* This procedure performs the update setting routine */
   /******************************************************/
   procedure update_setting(par_group in varchar2,
                            par_code in varchar2,
                            par_value in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the setting value
      /*-*/
      update lics_setting
         set set_value= par_value
         where set_group = upper(par_group)
           and set_code = upper(par_code);
      if sql%notfound then
         insert into lics_setting
            (set_group,
             set_code,
             set_value)
            values(upper(par_group),
                   upper(par_code),
                   par_value);
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_setting;

   /******************************************************/
   /* This procedure performs the delete setting routine */
   /******************************************************/
   procedure delete_setting(par_group in varchar2,
                            par_code in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the setting value
      /*-*/
      delete from lics_setting
         where set_group = upper(par_group)
           and set_code = upper(par_code);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_setting;

   /********************************************************/
   /* This procedure performs the retrieve setting routine */
   /********************************************************/
   function retrieve_setting(par_group in varchar2,
                             par_code in varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return lics_setting.set_value%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_setting_01 is 
         select *
           from lics_setting t01
          where t01.set_group = upper(par_group)
            and t01.set_code = upper(par_code);
      rcd_lics_setting_01 csr_lics_setting_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the setting
      /*-*/
      var_return := null;
      open csr_lics_setting_01;
      fetch csr_lics_setting_01 into rcd_lics_setting_01;
      if csr_lics_setting_01%found then
         var_return := rcd_lics_setting_01.set_value;
      end if;
      close csr_lics_setting_01;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_setting;

end lics_setting_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_setting_configuration for lics_app.lics_setting_configuration;
grant execute on lics_setting_configuration to public;