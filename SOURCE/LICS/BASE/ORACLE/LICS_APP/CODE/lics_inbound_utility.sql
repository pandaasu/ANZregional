/******************/
/* Package Header */
/******************/
create or replace package lics_inbound_utility as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_inbound_utility
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Inbound Utility

    The package implements the inbound utility functionality. This package
    is used by host application inbound interface implementations to raise
    exceptions against the interface data.

    1. Applications can only raise inbound interface exceptions using
       the supplied procedure in this package.

    3. The host application is responsible for deciding the type of exception
       processing. The implementation can choose to abort the interface on the
       first exception or load all exceptions before
       aborting the interface. The architecture supports multiple exceptions
       for each inbound interface.

    4. This package has been designed as a single instance class to facilitate
       reengineering in an object oriented language. That is, in an OO environment
       the host would be passed an instance of this class. However, in the PL/SQL
       environment only one instance is available at any one time.

    5. All called methods have been implemented as autonomous transactions so as not
       to interfere with the commit boundaries of the host application.

    -------------------------------------------------------------------------------

    The following notes relate to CSV processing.

    1. It is assumed that a CSV file will conform to a single structure throughout
    2. set_csv_definition AND parse_csv_record must be utilised to initialise, then
       get_* and exception functionality can be used as required.
    3. The order of column definition is not important when setting the definition
    4. Possible Enhancement : allow for delimiter to appear in data columns by accepting
       and processing quotes to represent a column of data.

    PARAMETERS:

       set_csv_definition
       1. par_column - name of data column to be processed
       2. par_position - position number of field in delimited file to retrieve.
                         first position = 1

       parse_csv_record
       1. par_record - delimited record string to be parsed
       2. par_delimiter - string delimiter to seperate fields by

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/02   Linden Glen    ADD: CSV processing

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure add_exception(par_exception in varchar2);
   procedure clear_definition;
   procedure set_definition(par_group in varchar2, par_column in varchar2, par_length in number);
   procedure parse_record(par_group in varchar2, par_record in varchar2);
   function has_errors return boolean;
   function get_fixed(par_column in varchar2) return varchar2;
   function get_variable(par_column in varchar2) return varchar2;
   function get_number(par_column in varchar2, par_format in varchar2) return number;
   function get_date(par_column in varchar2, par_format in varchar2) return date;
   procedure set_csv_definition(par_column in varchar2, par_position in integer);
   procedure parse_csv_record(par_record in varchar2, par_delimiter in varchar2);

end lics_inbound_utility;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_inbound_utility as

   /*-*/
   /* Private exceptions
   /*-*/
   parse_exception exception;

   /*-*/
   /* Constant Definitions
   /*-*/
   con_csv_group constant varchar2(32) := 'CSV';

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

   /*****************************************************/
   /* This procedure performs the add exception routine */
   /*****************************************************/
   procedure add_exception(par_exception in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Add the exception
      /*-*/
      lics_inbound_processor.callback_exception(par_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_exception;

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
                  add_exception('Field - ' || upper(var_group) || '.' || upper(par_column) || ' - Unable to convert (' || trim(tbl_value(upper(par_column))) || ') to a number');
                  var_error := true;
            end;
         else
            begin
               var_return := to_number(trim(tbl_value(upper(par_column))),par_format);
            exception
               when others then
                  add_exception('Field - ' || upper(var_group) || '.' || upper(par_column) || ' - Unable to convert (' || trim(tbl_value(upper(par_column))) || ') to a number using format (' || par_format || ')');
                  var_error := true;
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
               add_exception('Field - ' || upper(var_group) || '.' || upper(par_column) || ' - Unable to convert (' || trim(tbl_value(upper(par_column))) || ') to a date using format (' || par_format || ')');
               var_error := true;
         end;
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_date;

   /**********************************************************/
   /* This procedure performs the set CSV definition routine */
   /**********************************************************/
   procedure set_csv_definition(par_column in varchar2, par_position in integer) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Call standard set_definition
      /*-*/
      set_definition(con_csv_group, par_column, par_position);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_csv_definition;

   /********************************************************/
   /* This procedure performs the parse CSV record routine */
   /********************************************************/
   procedure parse_csv_record(par_record in varchar2, par_delimiter in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_error := false;
      var_group := con_csv_group;
      tbl_value.delete;
      if not(tbl_group.exists(upper(var_group))) then
         return;
      end if;

      /*-*/
      /* Parse the record
      /*-*/
      for idx in tbl_group(upper(var_group)).str_index..tbl_group(upper(var_group)).end_index loop
         if (tbl_definition(idx).length = 1) then
            tbl_value(tbl_definition(idx).column) := substr(par_record,1,
                                                            instr(par_record,par_delimiter,1,tbl_definition(idx).length)-1);
         else
            if (instr(par_record,par_delimiter,1,tbl_definition(idx).length-1) = 0) then
               tbl_value(tbl_definition(idx).column) := null;
            else
               if (instr(par_record,par_delimiter,1,tbl_definition(idx).length) = 0) then
                  tbl_value(tbl_definition(idx).column) := substr(par_record,
                                                                  instr(par_record,par_delimiter,1,tbl_definition(idx).length-1)+1,
                                                                  length(par_record));
               else
                  tbl_value(tbl_definition(idx).column) := substr(par_record,
                                                                  instr(par_record,par_delimiter,1,tbl_definition(idx).length-1)+1,
                                                                  instr(par_record,par_delimiter,1,tbl_definition(idx).length)-instr(par_record,par_delimiter,1,tbl_definition(idx).length-1)-1);
               end if;
            end if;
         end if;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end parse_csv_record;

end lics_inbound_utility;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_inbound_utility for lics_app.lics_inbound_utility;
grant execute on lics_inbound_utility to public;