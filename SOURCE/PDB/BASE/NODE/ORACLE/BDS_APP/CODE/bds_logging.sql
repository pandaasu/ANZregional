create or replace package bds_app.bds_logging as

   /**/
   /* public declarations
   /**/
   procedure start_log(par_heading in varchar2,
                       par_search in varchar2);
   procedure write_log(par_text in varchar2);
   procedure end_log;
   function callback_identifier return varchar2;

end bds_logging;
/

create or replace package body bds_app.bds_logging as

   /*-*/
   /* private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* private definitions
   /*-*/
   rcd_bds_log bds_log%rowtype;
   var_identifier varchar2(512);
   var_log_depth number;
   type tab_log_header is table of varchar2(4000) index by binary_integer;
   type tab_log_indent is table of varchar2(4000) index by binary_integer;
   var_log_header tab_log_header;
   var_log_indent tab_log_indent;

   /*************************************************/
   /* this procedure performs the start log routine */
   /*************************************************/
   procedure start_log(par_heading in varchar2,
                       par_search in varchar2) is

      /*-*/
      /* autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* begin block */
   /*-------------*/
   begin

      /*-*/
      /* log sequence already exists
      /* - increase the depth
      /* - write the log and exit
      /*-*/
      if not(rcd_bds_log.log_sequence is null) then
         if var_log_depth >= 99 then
            raise_application_error(-20000, 'bds_logging - start log - log depth exceeds maximum 99');
         end if;
         var_log_depth := var_log_depth + 1;
         var_log_header(var_log_depth) := par_heading || ' - ';
         var_log_indent(var_log_depth) := null;
         for idx_indent in 1..var_log_depth-1 loop
            var_log_indent(var_log_depth) := var_log_indent(var_log_depth) || '---';
         end loop;
         var_log_indent(var_log_depth) := var_log_indent(var_log_depth) || '>';
         write_log('start log');
         return;
      end if;

      /*-*/
      /* insert the log row
      /*-*/
      var_log_depth := 1;
      var_log_header(var_log_depth) := par_heading || ' - ';
      var_log_indent(var_log_depth) := null;
      var_identifier := null;
      select bds_log_sequence.nextval into rcd_bds_log.log_sequence from dual;
      rcd_bds_log.log_trace := 1;
      rcd_bds_log.log_time := sysdate;
      rcd_bds_log.log_text := var_log_header(var_log_depth) || 'start log';
      rcd_bds_log.log_search := par_search;
      insert into bds_log
         (log_sequence,
          log_trace,
          log_time,
          log_text,
          log_search)
      values(rcd_bds_log.log_sequence,
             rcd_bds_log.log_trace,
             rcd_bds_log.log_time,
             rcd_bds_log.log_text,
             rcd_bds_log.log_search);
      var_identifier := rcd_bds_log.log_search || ' - ' || to_char(rcd_bds_log.log_time,'yyyy/mm/dd hh24:mi:ss');

      /*-*/
      /* commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* end routine */
   /*-------------*/
   end start_log;

   /*************************************************/
   /* this procedure performs the write log routine */
   /*************************************************/
   procedure write_log(par_text in varchar2) is

      /*-*/
      /* autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* begin block */
   /*-------------*/
   begin

      /*-*/
      /* log sequence must exist
      /*-*/
      if rcd_bds_log.log_sequence is null then
         raise_application_error(-20000, 'bds_logging - write log - log not started');
      end if;

      /*-*/
      /* insert the log row
      /*-*/
      rcd_bds_log.log_trace := rcd_bds_log.log_trace + 1;
      rcd_bds_log.log_time := sysdate;
      rcd_bds_log.log_text := var_log_indent(var_log_depth) || var_log_header(var_log_depth) || par_text;
      insert into bds_log
         (log_sequence,
          log_trace,
          log_time,
          log_text,
          log_search)
      values(rcd_bds_log.log_sequence,
             rcd_bds_log.log_trace,
             rcd_bds_log.log_time,
             rcd_bds_log.log_text,
             rcd_bds_log.log_search);

      /*-*/
      /* commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* end routine */
   /*-------------*/
   end write_log;

   /***********************************************/
   /* this procedure performs the end log routine */
   /***********************************************/
   procedure end_log is

      /*-*/
      /* autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* begin block */
   /*-------------*/
   begin

      /*-*/
      /* log sequence must exist
      /*-*/
      if rcd_bds_log.log_sequence is null then
         raise_application_error(-20000, 'bds_logging - end log - log not started');
      end if;

      /*-*/
      /* log child
      /* - write the log and exit
      /* - decrease the depth
      /*-*/
      if var_log_depth > 1 then
         write_log('end log');
         var_log_depth := var_log_depth - 1;
         return;
      end if;

      /*-*/
      /* insert the log row
      /*-*/
      rcd_bds_log.log_trace := rcd_bds_log.log_trace + 1;
      rcd_bds_log.log_time := sysdate;
      rcd_bds_log.log_text := var_log_indent(var_log_depth) || var_log_header(var_log_depth) || 'end log';
      insert into bds_log
         (log_sequence,
          log_trace,
          log_time,
          log_text,
          log_search)
      values(rcd_bds_log.log_sequence,
             rcd_bds_log.log_trace,
             rcd_bds_log.log_time,
             rcd_bds_log.log_text,
             rcd_bds_log.log_search);

      /*-*/
      /* commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

      /*-*/
      /* reset the package
      /*-*/
      rcd_bds_log.log_sequence := null;

   /*-------------*/
   /* end routine */
   /*-------------*/
   end end_log;

   /**********************************************************/
   /* this function performs the callback identifier routine */
   /**********************************************************/
   function callback_identifier return varchar2 is

   /*-------------*/
   /* begin block */
   /*-------------*/
   begin

      /*-*/
      /* return the log identifier
      /*-*/
      return var_identifier;

   /*-------------*/
   /* end routine */
   /*-------------*/
   end callback_identifier;

/*----------------------*/
/* initialisation block */
/*----------------------*/
begin

   /*-*/
   /* initialise the package
   /*-*/
   rcd_bds_log.log_sequence := null;

end bds_logging;
/