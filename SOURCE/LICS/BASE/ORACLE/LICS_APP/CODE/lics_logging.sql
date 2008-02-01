/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_logging
 Owner   : lics_app
 Author  : Steve Gregan - January 2005

 DESCRIPTION
 -----------
 Local Interface Control System - Logging

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_logging as

   /**/
   /* Public declarations
   /**/
   procedure start_log(par_heading in varchar2,
                       par_search in varchar2);
   procedure write_log(par_text in varchar2);
   procedure end_log;
   function callback_identifier return varchar2;
   function is_created return boolean;

end lics_logging;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_logging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_log lics_log%rowtype;
   var_identifier varchar2(512);
   var_log_depth number;
   type tab_log_header is table of varchar2(4000) index by binary_integer;
   type tab_log_indent is table of varchar2(4000) index by binary_integer;
   var_log_header tab_log_header;
   var_log_indent tab_log_indent;

   /*************************************************/
   /* This procedure performs the start log routine */
   /*************************************************/
   procedure start_log(par_heading in varchar2,
                       par_search in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log sequence already exists
      /* - increase the depth
      /* - write the log and exit
      /*-*/
      if not(rcd_lics_log.log_sequence is null) then
         if var_log_depth >= 99 then
            raise_application_error(-20000, 'LICS_LOGGING - Start Log - Log depth exceeds maximum 99');
         end if;
         var_log_depth := var_log_depth + 1;
         var_log_header(var_log_depth) := par_heading || ' - ';
         var_log_indent(var_log_depth) := null;
         for idx_indent in 1..var_log_depth-1 loop
            var_log_indent(var_log_depth) := var_log_indent(var_log_depth) || '---';
         end loop;
         var_log_indent(var_log_depth) := var_log_indent(var_log_depth) || '>';
         write_log('START LOG');
         return;
      end if;

      /*-*/
      /* Insert the log row
      /*-*/
      var_log_depth := 1;
      var_log_header(var_log_depth) := par_heading || ' - ';
      var_log_indent(var_log_depth) := null;
      var_identifier := null;
      select lics_log_sequence.nextval into rcd_lics_log.log_sequence from dual;
      rcd_lics_log.log_trace := 1;
      rcd_lics_log.log_time := sysdate;
      rcd_lics_log.log_text := var_log_header(var_log_depth) || 'START LOG';
      rcd_lics_log.log_search := par_search;
      insert into lics_log
         (log_sequence,
          log_trace,
          log_time,
          log_text,
          log_search)
      values(rcd_lics_log.log_sequence,
             rcd_lics_log.log_trace,
             rcd_lics_log.log_time,
             rcd_lics_log.log_text,
             rcd_lics_log.log_search);
      var_identifier := rcd_lics_log.log_search || ' - ' || to_char(rcd_lics_log.log_time,'yyyy/mm/dd hh24:mi:ss');

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_log;

   /*************************************************/
   /* This procedure performs the write log routine */
   /*************************************************/
   procedure write_log(par_text in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log sequence must exist
      /*-*/
      if rcd_lics_log.log_sequence is null then
         raise_application_error(-20000, 'LICS_LOGGING - Write Log - Log not started');
      end if;

      /*-*/
      /* Insert the log row
      /*-*/
      rcd_lics_log.log_trace := rcd_lics_log.log_trace + 1;
      rcd_lics_log.log_time := sysdate;
      rcd_lics_log.log_text := var_log_indent(var_log_depth) || var_log_header(var_log_depth) || par_text;
      insert into lics_log
         (log_sequence,
          log_trace,
          log_time,
          log_text,
          log_search)
      values(rcd_lics_log.log_sequence,
             rcd_lics_log.log_trace,
             rcd_lics_log.log_time,
             rcd_lics_log.log_text,
             rcd_lics_log.log_search);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end write_log;

   /***********************************************/
   /* This procedure performs the end log routine */
   /***********************************************/
   procedure end_log is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log sequence must exist
      /*-*/
      if rcd_lics_log.log_sequence is null then
         raise_application_error(-20000, 'LICS_LOGGING - End Log - Log not started');
      end if;

      /*-*/
      /* Log child
      /* - write the log and exit
      /* - decrease the depth
      /*-*/
      if var_log_depth > 1 then
         write_log('END LOG');
         var_log_depth := var_log_depth - 1;
         return;
      end if;

      /*-*/
      /* Insert the log row
      /*-*/
      rcd_lics_log.log_trace := rcd_lics_log.log_trace + 1;
      rcd_lics_log.log_time := sysdate;
      rcd_lics_log.log_text := var_log_indent(var_log_depth) || var_log_header(var_log_depth) || 'END LOG';
      insert into lics_log
         (log_sequence,
          log_trace,
          log_time,
          log_text,
          log_search)
      values(rcd_lics_log.log_sequence,
             rcd_lics_log.log_trace,
             rcd_lics_log.log_time,
             rcd_lics_log.log_text,
             rcd_lics_log.log_search);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

      /*-*/
      /* Reset the package
      /*-*/
      rcd_lics_log.log_sequence := null;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end end_log;

   /**********************************************************/
   /* This function performs the callback identifier routine */
   /**********************************************************/
   function callback_identifier return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the log identifier
      /*-*/
      return var_identifier;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_identifier;

   /*************************************************/
   /* This function performs the is created routine */
   /*************************************************/
   function is_created return boolean is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing log exists
      /*-*/
      if rcd_lics_log.log_sequence is null then
         return false;
      end if;
      return true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end is_created;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package
   /*-*/
   rcd_lics_log.log_sequence := null;

end lics_logging;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_logging for lics_app.lics_logging;
grant execute on lics_logging to public;