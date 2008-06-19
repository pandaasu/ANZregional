DROP PACKAGE CR_APP.SIL_INBOUND_UTILITY;

CREATE OR REPLACE PACKAGE CR_APP.sil_inbound_utility as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : STANDARD INTERFACE LOADER
 Package : sil_inbound_utility
 Owner   : cr_app
 Author  : Linden Glen

 DESCRIPTION
 -----------
 STANDARD INTERFACE LOADER - Inbound Utility

 The package implements the inbound utility functionality. This package
 is used by host application inbound interface implementations to raise
 exceptions against the interface data.

 1. This package has been designed as a single instance class to facilitate
    reengineering in an object oriented language. That is, in an OO environment
    the host would be passed an instance of this class. However, in the PL/SQL
    environment only one instance is available at any one time.

 2. All called methods have been implemented as autonomous transactions so as not
    to interfere with the commit boundaries of the host application.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/10   Linden Glen    Created

*******************************************************************************/


   /**/
   /* Public declarations
   /**/
   procedure clear_definition;
   procedure set_definition(par_group in varchar2, par_column in varchar2, par_length in number);
   procedure parse_record(par_group in varchar2, par_record in varchar2);
   function has_errors return boolean;
   function get_fixed(par_column in varchar2) return varchar2;
   function get_variable(par_column in varchar2) return varchar2;
   function get_number(par_column in varchar2, par_format in varchar2) return number;
   function get_date(par_column in varchar2, par_format in varchar2) return date;

end sil_inbound_utility;
/


DROP PACKAGE BODY CR_APP.SIL_INBOUND_UTILITY;

CREATE OR REPLACE PACKAGE BODY CR_APP.sil_inbound_utility as

   /*-*/
   /* Private exceptions
   /*-*/
   parse_exception exception;

   /*-*/
   /* Private definitions
   /*-*/
   var_error boolean;
   var_group varchar2(32);
   type rcd_group is record(str_index number(5,0), end_index number(5,0));
   type typ_group is table of rcd_group index by varchar2(32);
   tbl_group typ_group;
   type rcd_definition is record(column varchar2(32), length number(5,0));
   type typ_definition is table of rcd_definition index by binary_integer;
   tbl_definition typ_definition;
   type typ_value is table of varchar2(4000) index by varchar2(32);
   tbl_value typ_value;


   /********************************************************/
   /* This procedure performs the clear definition routine */
   /********************************************************/
   procedure clear_definition is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the definitions
      /*-*/
      var_error := false;
      tbl_group.delete;
      tbl_definition.delete;
      tbl_value.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_definition;

   /******************************************************/
   /* This procedure performs the set definition routine */
   /******************************************************/
   procedure set_definition(par_group in varchar2, par_column in varchar2, par_length in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the definition index
      /*-*/
      var_index := tbl_definition.count + 1;

      /*-*/
      /* Set the group indexes
      /*-*/
      if not(tbl_group.exists(upper(par_group))) then
         tbl_group(upper(par_group)).str_index := var_index;
      end if;
      tbl_group(upper(par_group)).end_index := var_index;

      /*-*/
      /* Set the definition
      /*-*/
      tbl_definition(var_index).column := upper(par_column);
      tbl_definition(var_index).length := par_length;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_definition;

   /****************************************************/
   /* This procedure performs the parse record routine */
   /****************************************************/
   procedure parse_record(par_group in varchar2, par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_pointer number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_error := false;
      var_group := par_group;
      tbl_value.delete;
      if not(tbl_group.exists(upper(par_group))) then
         return;
      end if;

      /*-*/
      /* Parse the record
      /*-*/
      var_pointer := 1;
      for idx in tbl_group(upper(par_group)).str_index..tbl_group(upper(par_group)).end_index loop
         tbl_value(tbl_definition(idx).column) := substr(par_record, var_pointer, tbl_definition(idx).length);
         var_pointer := var_pointer + tbl_definition(idx).length;
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end parse_record;

   /*************************************************/
   /* This function performs the has errors routine */
   /*************************************************/
   function has_errors return boolean is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the error indicator
      /*-*/
      return var_error;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end has_errors;

   /************************************************/
   /* This function performs the get fixed routine */
   /************************************************/
   function get_fixed(par_column in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the fixed length string value
      /*-*/
      var_return := null;
      if tbl_value.exists(upper(par_column)) then
         var_return := tbl_value(upper(par_column));
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_fixed;

   /***************************************************/
   /* This function performs the get variable routine */
   /***************************************************/
   function get_variable(par_column in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the variable length string value
      /*-*/
      var_return := null;
      if tbl_value.exists(upper(par_column)) then
         var_return := rtrim(tbl_value(upper(par_column)));
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_variable;

   /*************************************************/
   /* This function performs the get number routine */
   /*************************************************/
   function get_number(par_column in varchar2, par_format in varchar2) return number is

      /*-*/
      /* Local definitions
      /*-*/
      var_return number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the number value
      /*-*/
      var_return := null;
      if tbl_value.exists(upper(par_column)) then
         if par_format is null then
            begin
               if substr(trim(tbl_value(upper(par_column))),length(trim(tbl_value(upper(par_column)))),1) = '-' then
                  var_return := to_number('-' || substr(trim(tbl_value(upper(par_column))),1,length(trim(tbl_value(upper(par_column)))) - 1));
               else
                  var_return := to_number(trim(tbl_value(upper(par_column))));
               end if;
            exception
               when others then
                  null;
            end;
         else
            begin
               var_return := to_number(trim(tbl_value(upper(par_column))),par_format);
            exception
               when others then
                  null;
            end;
         end if;
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_number;

   /***********************************************/
   /* This function performs the get date routine */
   /***********************************************/
   function get_date(par_column in varchar2, par_format in varchar2) return date is

      /*-*/
      /* Local definitions
      /*-*/
      var_return date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the date value
      /*-*/
      var_return := null;
      if tbl_value.exists(upper(par_column)) then
         begin
            var_return := to_date(trim(tbl_value(upper(par_column))),par_format);
         exception
            when others then
               null;
         end;
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_date;

end sil_inbound_utility;
/


DROP PUBLIC SYNONYM SIL_INBOUND_UTILITY;

CREATE PUBLIC SYNONYM SIL_INBOUND_UTILITY FOR CR_APP.SIL_INBOUND_UTILITY;


GRANT EXECUTE ON CR_APP.SIL_INBOUND_UTILITY TO PUBLIC;

