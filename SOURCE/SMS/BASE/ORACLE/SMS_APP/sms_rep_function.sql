/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_rep_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_rep_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Report functions

    This package contain the report functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure generate(par_qry_code in varchar2, par_rpt_date in varchar2);

end sms_rep_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_rep_function as

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

   /************************************************/
   /* This procedure performs the generate routine */
   /************************************************/
   procedure generate(par_qry_code in varchar2,
                      par_rpt_date in varchar2,
                      par_alert in varchar2,
                      par_email in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_errors boolean;
      var_found boolen;
      rcd_sms_rpt_message sms_rpt_message%rowtype;
      rcd_sms_rpt_recipient sms_rpt_recipient%rowtype;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'SMS Report Generation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_qry_code = par_qry_code
            and t01.rhe_rpt_date = par_rpt_date
            for update;
      rcd_report csr_report%rowtype;

      cursor csr_profile is
         select t01.*
           from sms_profile t01
          where t01.pro_qry_code = par_qry_code
            and t01.pro_status = '1'
          order by t01.pro_prf_code asc;
      rcd_profile csr_profile%rowtype;

      cursor csr_pro_message is
         select t02.*
           from sms_pro_message t01,
                sms_message t02
          where t01.pme_msg_code = t02.mes_msg_code
            and t01.pme_prf_code = rcd_profile.pro_prf_code
            and t02.mes_status = '1'
          order by t02.mes_msg_code asc;
      rcd_pro_message csr_pro_message%rowtype;

      cursor csr_pro_filter is
         select t02.*
           from sms_pro_filter t01,
                sms_filter t02
          where t01.pfi_flt_code = t02.fil_flt_code
            and t01.pfi_prf_code = rcd_profile.pro_prf_code
            and t02.fil_status = '1'
          order by t02.fil_flt_code asc;
      rcd_pro_filter csr_pro_filter%rowtype;

      cursor csr_pro_recipient is
         select t02.*
           from sms_pro_recipient t01,
                sms_recipient t02
          where t01.pre_rcp_code = t02.rec_rcp_code
            and t01.pre_prf_code = rcd_profile.pro_prf_code
            and t02.rec_status = '1'
          order by t02.rec_rcp_code asc;
      rcd_pro_recipient csr_pro_recipient%rowtype;

      cursor csr_rpt_message is
         select t01.*
           from sms_rpt_message t01
          where t01.rme_qry_code = par_qry_code
            and t01.rme_rpt_date = par_rpt_date
          order by t01.rme_msg_seqn asc;
      rcd_rpt_message csr_rpt_message%rowtype;

      cursor csr_rpt_recipient is
         select t01.*
           from sms_rpt_recipient t01
          where t01.rre_qry_code = par_qry_code
            and t01.rre_rpt_date = par_rpt_date
            and t01.rre_msg_seqn = rcd_rpt_message.rme_msg_seqn
          order by t01.rre_rcp_code asc;
      rcd_rpt_recipient csr_rpt_recipient%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'SMS - REPORT_GENERATION';
      var_log_search := 'SMS_REPORT_GENERATION';
      var_errors := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_qry_code is null then
         raise_application_error(-20000, 'Quesry code must be supplied');
      end if;
      if par_rpt_date is null then
         raise_application_error(-20000, 'Report date must be supplied');
      end if;

      /*-*/
      /* Retrieve and lock the report
      /*-*/
      var_found := false;
      begin
         open csr_report;
         fetch csr_report into rcd_report;
         if csr_report%found then
            var_found := true;
         end if;
         close csr_report;
      exception
         when others then
            raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_rpt_date||') is currently locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_rpt_date||') not found on the report header table');
      end if;
      if rcd_report.rhe_status != '1' then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_rpt_date||') must be status loaded');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SMS Report Generation - Parameters(' || par_qry_code || ' + ' || par_rpt_date || ')');

      /*-*/
      /* Initialise the report message data
      /*-*/
      rcd_sms_rpt_message.rme_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_message.rme_rpt_date := rcd_report.rhe_rpt_date;
      rcd_sms_rpt_message.rme_msg_seqn := 0;

      /*-*/
      /* Initialise the report recipient data
      /*-*/
      rcd_sms_rpt_recipient.rre_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_recipient.rre_rpt_date := rcd_report.rhe_rpt_date;

      /*-*/
      /* WHERE pro_qry_code equal par_qry_code
      /*-*/
      open csr_profile;
      loop
         fetch csr_profile into rcd_profile;
         if csr_profile%notfound then
            exit;
         end if;

         open csr_pro_message;
         loop
            fetch csr_pro_message into rcd_pro_message;
            if csr_pro_message%notfound then
               exit;
            end if;

            open csr_pro_filter;
            loop
               fetch csr_pro_filter into rcd_pro_filter;
               if csr_pro_filter%notfound then
                  exit;
               end if;

               -- BUILD THE SMS TEXT USING MESSAGE AND FILTER
               rcd_sms_rpt_message.rme_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn + 1;
               rcd_sms_rpt_message.rme_msg_data := var_msg_text;
               rcd_sms_rpt_message.rme_msg_time := sysdate;
               insert into sms_rpt_message values rcd_sms_rpt_message;

               open csr_pro_recipient;
               loop
                  fetch csr_pro_recipient into rcd_pro_recipient;
                  if csr_pro_recipient%notfound then
                     exit;
                  end if;

                  -- BUILD THE MESSAGE RECIPIENT RELATIONSHIP
                  rcd_sms_rpt_recipient.rre_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn;
                  rcd_sms_rpt_recipient.rme_rcp_code := rcd_pro_recipient.pre_rcp_code;
                  rcd_sms_rpt_recipient.rre_rcp_mobile := rcd_pro_recipient.pre_rcp_code.rec_rcp_mobile;
                  rcd_sms_rpt_recipient.rre_rcp_email := rcd_pro_recipient.rec_rcp_email;
                  insert into sms_rpt_recipient values rcd_sms_rpt_recipient;

               end loop;
               close csr_pro_recipient;

            end loop;
            close csr_pro_filter;

         end loop;
         close csr_pro_message;

      end loop;
      close csr_profile;

      /*-*/
      /* Send the messages
      /*-*/
      open csr_rpt_message;
      loop
         fetch csr_rpt_message into rcd_rpt_message;
         if csr_rpt_message%notfound then
            exit;
         end if;

         open csr_rpt_recipient;
         loop
            fetch csr_rpt_recipient into rcd_rpt_recipient;
            if csr_rpt_recipient%notfound then
               exit;
            end if;

            -- SEND THE SMS

         end loop;
         close csr_rpt_recipient;

      end loop;
      close csr_rpt_message;

      /*-*/
      /* Update the report header to processed
      /*-*/
      update sms_rpt_header
         set rhe_status = '2'
       where t01.rhe_qry_code = par_qry_code
         and t01.rhe_rpt_date = par_rpt_date;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SMS Report Generation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(par_alert) is null) and trim(upper(par_alert)) != '*NONE' then
            lics_notification.send_alert(par_alert);
         end if;
         if not(trim(par_email) is null) and trim(upper(par_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function,
                                         'SMS_REPORT_GENERATION',
                                         par_email,
                                         'One or more errors occurred during the SMS Report Generation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      end if;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - SMS_REP_FUNCTION - GENERATE - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate;


      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(var_smtp_host, var_smtp_port);
      utl_smtp.helo(var_connection, var_smtp_host);

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, var_sender);

      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, var_recipient);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || var_sender || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || var_recipient || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: ' || var_subject || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, var_email_content);

      /*-*/
      /* Write email body from the part and data array
      /*-*/      
      for pidx in 1..tbl_part.count loop
         if tbl_part(pidx).part_file is null then
            utl_smtp.write_data(var_connection, con_open_email_boundary || utl_tcp.CRLF);
            utl_smtp.write_data(var_connection, var_part_content || utl_tcp.CRLF || utl_tcp.CRLF);
         else
            utl_smtp.write_data(var_connection, con_open_email_boundary || utl_tcp.CRLF);
            utl_smtp.write_data(var_connection, var_part_content || utl_tcp.CRLF);
            utl_smtp.write_data(var_connection, 'Content-Disposition: attachment; filename= ' || tbl_part(pidx).part_file || utl_tcp.CRLF);
         end if;
         if par_charset is null then
            utl_smtp.write_data(var_connection, utl_tcp.CRLF);
         else
            utl_smtp.write_raw_data(var_connection, utl_raw.cast_to_raw(utl_tcp.CRLF));
         end if;
         for didx in tbl_part(pidx).part_dsix..tbl_part(pidx).part_deix loop
            if par_charset is null then
               utl_smtp.write_data(var_connection, tbl_data(didx) || utl_tcp.CRLF);
            else
               utl_smtp.write_raw_data(var_connection, utl_raw.cast_to_raw(tbl_data(didx) || utl_tcp.CRLF));
            end if;
         end loop;
      end loop;

      /*-*/
      /* Close the email boundary
      /*-*/  
      utl_smtp.write_data(var_connection, con_close_email_boundary || utl_tcp.CRLF);

      /*-*/
      /* Close the data stream and quit the connection
      /*-*/   
      utl_smtp.close_data(var_connection);
      utl_smtp.quit(var_connection);



    -- A sub procedure to help in sending email headers.
    PROCEDURE send_header (NAME IN VARCHAR2, header IN VARCHAR2) AS
    BEGIN
      utl_smtp.write_data (v_connection, NAME || ': ' || header || utl_tcp.crlf);
    END;
  BEGIN
    --check if the last run query entry exists so we can get the last run time
    v_last_accessed := fetch_last_accessed_query (c_query_id);
    --get the sysdate, used in the orders cursor so that we know the time of when
    --the last order was processed, is saved into SUB_DAILY_QUERIES
    v_order_time := SYSDATE;

    --open the cursor and loop on the orders since the last run
    OPEN csr_latest_orders;

    LOOP
      FETCH csr_latest_orders
      INTO rv_latest_orders;

      EXIT WHEN csr_latest_orders%NOTFOUND;
      --catch the document_no for the document_sms cursor
      v_document_no := rv_latest_orders.document_no;
      --preset the send sms flag to false
      v_send_order_sms := FALSE;

      OPEN csr_document_sms;

      FETCH csr_document_sms
      INTO rv_document_sms;

      --if the document doesn't exist, insert and set the flag to true
      IF csr_document_sms%NOTFOUND THEN
        INSERT INTO sub_daily_sms_orders
                    (document_no, ordered_qty, ordered_gsv)
             VALUES (v_document_no, rv_latest_orders.ordered_qty, rv_latest_orders.ordered_gsv);

        v_send_order_sms := TRUE;
      --or if the quantity or gsv has changed, update and set the flag to true
      ELSIF rv_document_sms.ordered_qty != rv_latest_orders.ordered_qty OR rv_document_sms.ordered_gsv != rv_latest_orders.ordered_gsv THEN
        UPDATE sub_daily_sms_orders
           SET ordered_qty = rv_latest_orders.ordered_qty,
               ordered_gsv = rv_latest_orders.ordered_gsv
         WHERE document_no = v_document_no;

        v_send_order_sms := TRUE;
      END IF;

      --if the flag is true, send the SMS
      IF v_send_order_sms THEN
        --catch the customer code for the phone number cursor
        v_cust_code := rv_latest_orders.cust_code;

        --get all the phone numbers that are to recieve SMS's for this customer
        OPEN csr_cust_phones;

        --do the first fetch
        FETCH csr_cust_phones
        INTO rv_cust_phones;

        --and if there are phone numbers there for that customer, prepare and send the email
        --if not, we don't need to send anything for this customer
        IF NOT csr_cust_phones%NOTFOUND THEN
          -- Open an email server connection.
          v_connection := utl_smtp.open_connection (smtp_server);
          utl_smtp.helo (v_connection, 'ap.effem.com');
          --reset the smtp object and prepare a new email
          utl_smtp.rset (v_connection);
          utl_smtp.mail (v_connection, 'MFA.Atlas@MFA');

          -- utl_smtp.rcpt (v_connection, 'chris.horn@ap.effem.com');  -- Send to user for testing.
          LOOP
            --there's at least one row in the cursor as we wouldn't be here if not
            --and add the number as a recipient
            utl_smtp.rcpt (v_connection, rv_cust_phones.sms_phone || '@sms.ap');

            -- dbms_output.put_line ('For Order : ' || rv_latest_orders.document_no || ' sending sms to ' || rv_cust_phones.sms_phone || '@sms.ap');

            --fetch the next row
            FETCH csr_cust_phones
            INTO rv_cust_phones;

            EXIT WHEN csr_cust_phones%NOTFOUND;
          END LOOP;

          utl_smtp.open_data (v_connection);
          --the subject line 'JUSTBODY' leaves out the standard headers...
          send_header ('Subject', 'JUSTBODY');
          utl_smtp.write_data (v_connection, utl_tcp.crlf);
          utl_smtp.write_data (v_connection, rv_latest_orders.cust_name || ' (' || LTRIM (rv_latest_orders.cust_code, '0') || ')');
          utl_smtp.write_data (v_connection, utl_tcp.crlf);
          utl_smtp.write_data (v_connection, 'ord no: ' || rv_latest_orders.document_no);
          utl_smtp.write_data (v_connection, utl_tcp.crlf);
          utl_smtp.write_data (v_connection, 'ord GSV: $' || ROUND (rv_latest_orders.ordered_gsv, 2) );
          utl_smtp.write_data (v_connection, utl_tcp.crlf);
          utl_smtp.write_data (v_connection, 'ord qty: ' || rv_latest_orders.ordered_qty);
          utl_smtp.write_data (v_connection, utl_tcp.crlf);
          utl_smtp.write_data (v_connection, 'ord date: ' || rv_latest_orders.mars_yyyyppdd);
          -- Now close the email data stream, this will send the email.
          --Does it clear all the data and recipients ? no, call .rset() to do that
          utl_smtp.close_data (v_connection);
          --close the email connection
          utl_smtp.quit (v_connection);
        END IF;

        CLOSE csr_cust_phones;
      END IF;

      CLOSE csr_document_sms;
    END LOOP;

    CLOSE csr_latest_orders;



end sms_rep_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_rep_function for sms_app.sms_rep_function;
grant execute on sms_app.sms_rep_function to public;
