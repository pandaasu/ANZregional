/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_gen_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_gen_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - General functions

    This package contain the general functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_mesg_data;
   function get_mesg_count return number;
   procedure add_mesg_data(par_message in varchar2);
   function get_mesg_data return sms_xml_type pipelined;
   procedure update_abbreviation(par_qry_code in varchar2, par_rpt_date in varchar2);
   function retrieve_abbreviation(par_dim_code in varchar2, par_dim_data in varchar2) return varchar2;

end sms_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_gen_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;
   pvar_cfrm varchar2(2000 char);
   type ptyp_mesg is table of varchar2(2000 char) index by binary_integer;
   ptbl_mesg ptyp_mesg;

   /**********************************************************/
   /* This procedure performs the clear message data routine */
   /**********************************************************/
   procedure clear_mesg_data is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      ptbl_mesg.delete;
      pvar_cfrm := null;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - CLEAR_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_mesg_data;

   /*********************************************************/
   /* This procedure performs the get message count routine */
   /*********************************************************/
   function get_mesg_count return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Return the message data count
      /*-*/
      return ptbl_mesg.count;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - GET_MESG_COUNT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_count;

   /********************************************************/
   /* This procedure performs the add message data routine */
   /********************************************************/
   procedure add_mesg_data(par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Add the message data
      /*-*/
      ptbl_mesg(ptbl_mesg.count+1) := par_message;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - ADD_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_mesg_data;

   /********************************************************/
   /* This procedure performs the get message data routine */
   /********************************************************/
   function get_mesg_data return sms_xml_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Pipe the message data when required
      /*-*/
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));
      end if;
      for idx in 1..ptbl_mesg.count loop
         pipe row(sms_xml_object('<ERROR ERRTXT="'||sms_to_xml(ptbl_mesg(idx))||'"/>'));
      end loop;
      if not(pvar_cfrm is null) then
         pipe row(sms_xml_object('<CONFIRM CONTXT="'||sms_to_xml(pvar_cfrm)||'"/>'));
      end if;
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(sms_xml_object('</SMS_RESPONSE>'));
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - GET_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_data;

   /***********************************************************/
   /* This procedure performs the update abbreviation routine */
   /***********************************************************/
   procedure update_abbreviation(par_qry_code in varchar2, par_rpt_date in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Update the abbreviation table with missing dimension 01 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod01,
                rda_dim_val01,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod01 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod01
                               and abb_dim_data = rda_dim_val01)
          group by rda_dim_cod01,
                   rda_dim_val01;

      /*-*/
      /* Update the abbreviation table with missing dimension 02 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod02,
                rda_dim_val02,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod02 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod02
                               and abb_dim_data = rda_dim_val02)
          group by rda_dim_cod02,
                   rda_dim_val02;

      /*-*/
      /* Update the abbreviation table with missing dimension 03 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod03,
                rda_dim_val03,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod03 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod03
                               and abb_dim_data = rda_dim_val03)
          group by rda_dim_cod03,
                   rda_dim_val03;

      /*-*/
      /* Update the abbreviation table with missing dimension 04 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod04,
                rda_dim_val04,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod04 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod04
                               and abb_dim_data = rda_dim_val04)
          group by rda_dim_cod04,
                   rda_dim_val04;

      /*-*/
      /* Update the abbreviation table with missing dimension 05 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod05,
                rda_dim_val05,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod05 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod05
                               and abb_dim_data = rda_dim_val05)
          group by rda_dim_cod05,
                   rda_dim_val05;

      /*-*/
      /* Update the abbreviation table with missing dimension 06 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod06,
                rda_dim_val06,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod06 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod06
                               and abb_dim_data = rda_dim_val06)
          group by rda_dim_cod06,
                   rda_dim_val06;

      /*-*/
      /* Update the abbreviation table with missing dimension 07 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod07,
                rda_dim_val07,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod07 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod07
                               and abb_dim_data = rda_dim_val07)
          group by rda_dim_cod07,
                   rda_dim_val07;

      /*-*/
      /* Update the abbreviation table with missing dimension 08 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod08,
                rda_dim_val08,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod08 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod08
                               and abb_dim_data = rda_dim_val08)
          group by rda_dim_cod08,
                   rda_dim_val08;

      /*-*/
      /* Update the abbreviation table with missing dimension 09 data
      /*-*/
      insert into sms_abbreviation
         select rda_dim_cod09,
                rda_dim_val09,
                null
           from sms_rpt_data
          where rda_qry_code = par_qry_code
            and rda_rpt_date =  par_rpt_date
            and not(rda_dim_cod09 is null)
            and not exists (select 'x'
                              from sms_abbreviation
                             where abb_dim_code = rda_dim_cod09
                               and abb_dim_data = rda_dim_val09)
          group by rda_dim_cod09,
                   rda_dim_val09;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_abbreviation;

   /*************************************************************/
   /* This procedure performs the retrieve abbreviation routine */
   /*************************************************************/
   function retrieve_abbreviation(par_dim_code in varchar2, par_dim_data in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_abbreviation is
         select t01.*
           from sms_abbreviation t01
          where t01.abb_dim_code = par_dim_code
            and t01.abb_dim_data = par_dim_data;
      rcd_abbreviation csr_abbreviation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the abbreviation
      /*-*/
      var_return := par_dim_data;
      open csr_abbreviation;
      fetch csr_abbreviation into rcd_abbreviation;
      if csr_abbreviation%found then
         var_return := rcd_abbreviation.abb_dim_abbr;
      end if;
      close csr_abbreviation;

      /*-*/
      /* Return the value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_abbreviation;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   ptbl_mesg.delete;
   pvar_end_code := 0;

end sms_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_gen_function for sms_app.sms_gen_function;
grant execute on sms_app.sms_gen_function to public;
