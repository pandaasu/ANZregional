/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_form
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - Form

 The package implements the form functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/08   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_form as

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_form;
   procedure set_value(par_column in varchar2, par_value in varchar2);
   procedure set_clob(par_column in varchar2, par_value in clob);
   function get_variable(par_column in varchar2) return varchar2;
   function get_number(par_column in varchar2) return number;
   function get_date(par_column in varchar2, par_format in varchar2) return date;
   function get_clob(par_column in varchar2) return clob;
   function get_array(par_column in varchar2, par_index in number) return varchar2;
   function get_array_count(par_column in varchar2) return varchar2;

end lics_form;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_form as

   /*-*/
   /* Private definitions
   /*-*/
   type rcd_column is record(str_index number(5,0), end_index number(5,0));
   type typ_column is table of rcd_column index by varchar2(32);
   tbl_column typ_column;
   type typ_value is table of varchar2(2000 char) index by binary_integer;
   tbl_value typ_value;

   /**************************************************/
   /* This procedure performs the clear form routine */
   /**************************************************/
   procedure clear_form is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the form
      /*-*/
      tbl_column.delete;
      tbl_value.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_form;

   /*************************************************/
   /* This procedure performs the set value routine */
   /*************************************************/
   procedure set_value(par_column in varchar2, par_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the value index
      /*-*/
      var_index := tbl_value.count + 1;

      /*-*/
      /* Set the column indexes
      /*-*/
      if not(tbl_column.exists(upper(par_column))) then
         tbl_column(upper(par_column)).str_index := var_index;
      end if;
      tbl_column(upper(par_column)).end_index := var_index;

      /*-*/
      /* Set the value
      /*-*/
      tbl_value(var_index) := par_value;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_value;

   /************************************************/
   /* This procedure performs the set clob routine */
   /************************************************/
   procedure set_clob(par_column in varchar2, par_value in clob) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);
      var_pointer integer;
      var_length binary_integer := 2000;
      var_buffer varchar2(2000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the clob in 2000 character chunks
      /*-*/
      var_pointer := 1;
      loop

         /*-*/
         /* Retrieve the next chunk
         /*-*/
         begin
            dbms_lob.read(par_value, var_length, var_pointer, var_buffer);
            var_pointer := var_pointer + var_length;
         exception
            when no_data_found then
               var_pointer := -1;
         end;
         if var_pointer < 0 then
            exit;
         end if;

         /*-*/
         /* Set the value index
         /*-*/
         var_index := tbl_value.count + 1;

         /*-*/
         /* Set the column indexes
         /*-*/
         if not(tbl_column.exists(upper(par_column))) then
            tbl_column(upper(par_column)).str_index := var_index;
         end if;
         tbl_column(upper(par_column)).end_index := var_index;

         /*-*/
         /* Set the value
         /*-*/
         tbl_value(var_index) := var_buffer;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_clob;

   /***************************************************/
   /* This function performs the get variable routine */
   /***************************************************/
   function get_variable(par_column in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(2000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and return the value
      /*-*/
      var_return := null;
      if tbl_column.exists(upper(par_column)) then
         var_return := rtrim(tbl_value(tbl_column(upper(par_column)).str_index));
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_variable;

   /*************************************************/
   /* This function performs the get number routine */
   /*************************************************/
   function get_number(par_column in varchar2) return number is

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
      if tbl_column.exists(upper(par_column)) then
         begin
            if substr(trim(tbl_value(tbl_column(upper(par_column)).str_index)),length(trim(tbl_value(tbl_column(upper(par_column)).str_index))),1) = '-' then
               var_return := to_number('-' || substr(trim(tbl_value(tbl_column(upper(par_column)).str_index)),1,length(trim(tbl_value(tbl_column(upper(par_column)).str_index))) - 1));
            else
               var_return := to_number(trim(tbl_value(tbl_column(upper(par_column)).str_index)));
            end if;
         exception
            when others then
               null;
         end;
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
      if tbl_column.exists(upper(par_column)) then
         begin
            var_return := to_date(trim(tbl_value(tbl_column(upper(par_column)).str_index)),par_format);
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

   /***********************************************/
   /* This function performs the get clob routine */
   /***********************************************/
   function get_clob(par_column in varchar2) return clob is

      /*-*/
      /* Local definitions
      /*-*/
      var_return clob;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and return the value
      /*-*/
      dbms_lob.createtemporary(var_return,true);
      if tbl_column.exists(upper(par_column)) then
         for idx in tbl_column(upper(par_column)).str_index..tbl_column(upper(par_column)).end_index loop
            dbms_lob.writeappend(var_return, length(tbl_value(idx)), tbl_value(idx));
         end loop;
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_clob;

   /************************************************/
   /* This function performs the get array routine */
   /************************************************/
   function get_array(par_column in varchar2, par_index in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);
      var_return varchar2(2000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and return the value
      /*-*/
      var_return := null;
      if tbl_column.exists(upper(par_column)) then
         var_index := tbl_column(upper(par_column)).str_index + par_index - 1;
         if tbl_column(upper(par_column)).str_index <= var_index and
            tbl_column(upper(par_column)).end_index >= var_index then
            var_return := tbl_value(var_index);
         end if;
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_array;

   /******************************************************/
   /* This function performs the get array count routine */
   /******************************************************/
   function get_array_count(par_column in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(2000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the value count
      /*-*/
      var_return := '0';
      if tbl_column.exists(upper(par_column)) then
         var_return := to_char(tbl_column(upper(par_column)).end_index - tbl_column(upper(par_column)).str_index + 1,'fm99990');
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_array_count;

end lics_form;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_form for lics_app.lics_form;
grant execute on lics_form to public;