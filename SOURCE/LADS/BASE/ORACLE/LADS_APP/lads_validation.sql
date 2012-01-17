/*****************/
/* Package Types */
/*****************/
--drop type lads_validation_table;
--drop type lads_validation_object;

--create or replace type lads_validation_object as object
--   (wrk_lng_code varchar2(30 char),
--    wrk_trm_code varchar2(30 char),
--    wrk_search01 varchar2(256 char),
--    wrk_search02 varchar2(256 char),
--    wrk_search03 varchar2(256 char),
--    wrk_search04 varchar2(256 char),
--    wrk_search05 varchar2(256 char),
--    wrk_search06 varchar2(256 char),
--    wrk_search07 varchar2(256 char),
--    wrk_search08 varchar2(256 char),
--    wrk_search09 varchar2(256 char));
--/
--create or replace type lads_validation_table as table of lads_validation_object;
--/

/******************/
/* Package Header */
/******************/
CREATE OR REPLACE PACKAGE LADS_APP."LADS_VALIDATION" as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_validation
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - LADS Validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/08   Steve Gregan   Created
    2005/11   Steve Gregan   Changed classification loop to array processing
    2006/06   Steve Gregan   Included classification message deletion in classification loop
    2006/12   Steve Gregan   Included classification search logic and emailing logic
    2007/01   Steve Gregan   Changed rule execution logic to array processing
    2007/05   Steve Gregan   Included execute with email indicator method
    2012/01   Rajwant Saini  Added author details to spreadsheet header
                             Added logging to display rule execution time 
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_group in varchar2);
   function execute_single(par_class in varchar2, par_code in varchar2) return varchar2;
   procedure email_messages(par_execution in varchar2);
   procedure load_statistics(par_group in varchar2);
   function get_table return lads_validation_table;

end lads_validation;
/

/****************/
/* Package Body */
/****************/
CREATE OR REPLACE PACKAGE BODY LADS_APP."LADS_VALIDATION" as

   /*-*/
   /* Private definitions
   /*-*/
   con_single_code constant varchar2(50 char) := '*SINGLE';
   con_admin_code constant varchar2(30 char) := '*ADMINISTRATOR';
   con_purge_version constant number := 10;
   con_max_row constant number := 32767;
   var_vir_table lads_validation_table := lads_validation_table();

   /*-*/
   /* Private declarations
   /*-*/
   procedure validate(par_execution in varchar2,
                      par_group in varchar2,
                      par_class in varchar2);
   procedure create_message(par_message in sap_val_mes%rowtype);
   function get_clob(par_clob in clob) return varchar2;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_group in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_locked boolean;
      var_sap_code varchar2(30 char);
      var_sap_search01 varchar2(256 char);
      var_sap_search02 varchar2(256 char);
      var_sap_search03 varchar2(256 char);
      var_sap_search04 varchar2(256 char);
      var_sap_search05 varchar2(256 char);
      var_sap_search06 varchar2(256 char);
      var_sap_search07 varchar2(256 char);
      var_sap_search08 varchar2(256 char);
      var_sap_search09 varchar2(256 char);
      var_list varchar2(32767 char);
      type typ_list is ref cursor;
      csr_list typ_list;
      var_test varchar2(32767 char);
      var_work varchar2(32767 char);
      type typ_test is ref cursor;
      csr_test typ_test;
      rcd_sap_val_mes sap_val_mes%rowtype;
      var_sav_code sap_val_mes.vam_code%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_group is
         select *
           from sap_val_grp t01
          where t01.vag_group = upper(par_group);
      rcd_group csr_group%rowtype;

      cursor csr_classification is
         select *
           from sap_val_cla t01
          where t01.vac_group = rcd_group.vag_group
            and t01.vac_exe_batch = 'Y'
          order by t01.vac_group asc,
                   t01.vac_class asc;
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'LADS - VALIDATION';
      var_log_search := 'LADS_VALIDATION-' || upper(par_group);
      var_loc_string := 'LADS_VALIDATION-' || upper(par_group);
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      open csr_group;
      fetch csr_group into rcd_group;
      if csr_group%notfound then
         raise_application_error(-20000, 'Group parameter (' || par_group || ') does not exist in SAP_VAL_GRP table');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - LADS Validation - Parameters(' || upper(par_group) || ')');

      /*-*/
      /* Request the lock on the LADS validation
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Set the message execution identifier
         /*-*/
         rcd_sap_val_mes.vam_execution := rcd_group.vag_group||'_'||to_char(sysdate,'yyyymmddhh24miss');

         /*-*/
         /* Execute the requested validation classifications
         /*-*/
         open csr_classification;
         loop
            fetch csr_classification into rcd_classification;
            if csr_classification%notfound then
               exit;
            end if;

            /*-*/
            /* Execute the classification list query
            /*-*/
            var_list := get_clob(rcd_classification.vac_lst_query);
            begin
               open csr_list for var_list;
            exception
               when others then
                  raise_application_error(-20000, 'Classification (' || rcd_classification.vac_class || ') list query failed - ' || substr(SQLERRM, 1, 1024));
            end;
            var_vir_table.delete;
            loop
               fetch csr_list into var_sap_code,
                                   var_sap_search01,
                                   var_sap_search02,
                                   var_sap_search03,
                                   var_sap_search04,
                                   var_sap_search05,
                                   var_sap_search06,
                                   var_sap_search07,
                                   var_sap_search08,
                                   var_sap_search09;
               if csr_list%notfound then
                  exit;
               end if;
               var_vir_table.extend;
               var_vir_table(var_vir_table.last) := lads_validation_object(var_sap_code,
                                                                           ltrim(var_sap_code,' 0'),
                                                                           var_sap_search01,
                                                                           var_sap_search02,
                                                                           var_sap_search03,
                                                                           var_sap_search04,
                                                                           var_sap_search05,
                                                                           var_sap_search06,
                                                                           var_sap_search07,
                                                                           var_sap_search08,
                                                                           var_sap_search09);
            end loop;
            close csr_list;

            /*-*/
            /* Update to history any existing batch classification validation messages
            /* **note** 1. only selected classifications are processed in batch so
            /*             the current version of classification messages can belong
            /*             to different execution identifiers
            /*-*/
            update sap_val_mes
               set vam_version = vam_version + 1
             where vam_class = rcd_classification.vac_class
               and vam_execution != con_single_code;
            commit;

            /*-*/
            /* Process and validate the classification list query
            /*-*/
            validate(rcd_sap_val_mes.vam_execution,
                     rcd_classification.vac_group,
                     rcd_classification.vac_class);
            commit;

         end loop;
         close csr_classification;

         /*-*/
         /* Update to history any existing batch validation filters missing messages
         /* **note** 1. this logical classification is always processed in batch
         /*-*/
         update sap_val_mes
            set vam_version = vam_version + 1
          where vam_class = '*FILTER'
            and vam_group = rcd_group.vag_group
            and vam_execution != con_single_code;
         commit;

         /*-*/
         /* Load the validation filters missing codes
         /*-*/
         var_sav_code := null;
         var_work := get_clob(rcd_group.vag_cod_query);
         var_test := 'select t01.vfd_code,
                             t01.vfd_filter
                        from sap_val_fil_det t01,
                             sap_val_fil t02
                       where t01.vfd_filter = t02.vaf_filter
                         and t01.vfd_code not in (' || chr(10) || var_work || chr(10) || ')
                         and t02.vaf_group = ''' || rcd_group.vag_group || '''
                       group by t01.vfd_code, t01.vfd_filter
                       order by vfd_code asc, vfd_filter asc';
         begin
            open csr_test for var_test;
         exception
            when others then
               raise_application_error(-20000, 'Filter missing code query failed - ' || substr(SQLERRM, 1, 1024));
         end;
         loop
            fetch csr_test into rcd_sap_val_mes.vam_code,
                                rcd_sap_val_mes.vam_filter;
            if csr_test%notfound then
               exit;
            end if;
            rcd_sap_val_mes.vam_class := '*FILTER';
            if var_sav_code is null or var_sav_code != rcd_sap_val_mes.vam_code then
               var_sav_code := rcd_sap_val_mes.vam_code;
               rcd_sap_val_mes.vam_sequence := 1;
            else
               rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
            end if;
            rcd_sap_val_mes.vam_group := rcd_group.vag_group;
            rcd_sap_val_mes.vam_type := '*FILTER';
            rcd_sap_val_mes.vam_rule := '*MISSING';
            rcd_sap_val_mes.vam_text := 'Filter detail code is not a valid SAP code';
            rcd_sap_val_mes.vam_version := 0;
            rcd_sap_val_mes.vam_emailed := 0;
            rcd_sap_val_mes.vam_search01 := null;
            rcd_sap_val_mes.vam_search02 := null;
            rcd_sap_val_mes.vam_search03 := null;
            rcd_sap_val_mes.vam_search04 := null;
            rcd_sap_val_mes.vam_search05 := null;
            rcd_sap_val_mes.vam_search06 := null;
            rcd_sap_val_mes.vam_search07 := null;
            rcd_sap_val_mes.vam_search08 := null;
            rcd_sap_val_mes.vam_search09 := null;
            create_message(rcd_sap_val_mes);
         end loop;
         close csr_test;
         commit;

         /*-*/
         /* Purge historical messages
         /*-*/
         delete from sap_val_mes
          where vam_execution != con_single_code
            and vam_group = rcd_group.vag_group
            and vam_version = con_purge_version;
         commit;

         /*-*/
         /* Email the messages
         /*-*/
         email_messages(rcd_sap_val_mes.vam_execution);

         /*-*/
         /* Load the statistics
         /*-*/
         load_statistics(rcd_group.vag_group);

         /*-*/
         /* Release the lock on the LADS validation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - LADS Validation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the LADS validation
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADS_VALIDATION - EXECUTE - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*****************************************************/
   /* This function performs the execute single routine */
   /*****************************************************/
   function execute_single(par_class in varchar2, par_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);
      var_number number;
      var_sap_code varchar2(30);
      var_single varchar2(32767 char);
      type typ_single is ref cursor;
      csr_single typ_single;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_classification is
         select *
           from sap_val_cla t01,
                sap_val_grp t02
          where t01.vac_group = t02.vag_group(+)
            and t01.vac_class = upper(par_class);
      rcd_classification csr_classification%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the classification
      /*-*/
      open csr_classification;
      fetch csr_classification into rcd_classification;
      if csr_classification%notfound then
         return 'Classification parameter (' || par_class || ') does not exist in SAP_VAL_CLA table';
      end if;

      /*-*/
      /* Pad numeric codes with leading zeros when required
      /*-*/
      var_sap_code := par_code;
      begin
         var_number := to_number(var_sap_code);
         var_sap_code := to_char(var_number,'fm000000000000000000000000000000');
         var_sap_code := substr(var_sap_code,rcd_classification.vag_cod_length*-1,rcd_classification.vag_cod_length);
      exception
         when others then
            null;
      end;

      /*-*/
      /* Delete any existing single validation messages
      /*-*/
      delete from sap_val_mes
       where vam_execution = con_single_code
         and vam_code = par_code
         and vam_class = par_class;

      /*-*/
      /* Execute and validate the classification single query
      /*-*/
      var_return := '*OK';
      var_single := get_clob(rcd_classification.vac_one_query);
      var_single := replace(var_single,'<SAP_CODE>',var_sap_code);
      begin
         open csr_single for var_single;
      exception
         when others then
            raise_application_error(-20000, 'Classification (' || rcd_classification.vac_class || ') single query failed - ' || substr(SQLERRM, 1, 1024));
      end;
      var_vir_table.delete;
      fetch csr_single into var_sap_code;
      if csr_single%notfound then
         var_return := 'SAP code (' || var_sap_code || ') not found for classification';
      else
         var_vir_table.extend;
         var_vir_table(var_vir_table.last) := lads_validation_object(var_sap_code,
                                                                     ltrim(var_sap_code,' 0'),
                                                                     null,
                                                                     null,
                                                                     null,
                                                                     null,
                                                                     null,
                                                                     null,
                                                                     null,
                                                                     null,
                                                                     null);
         validate(con_single_code,
                  rcd_classification.vac_group,
                  rcd_classification.vac_class);
      end if;
      close csr_single;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return the errors
      /*-*/
      return var_return;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADS_VALIDATION - EXECUTE_SINGLE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_single;

   /************************************************/
   /* This procedure performs the validate routine */
   /************************************************/
   procedure validate(par_execution in varchar2,
                      par_group in varchar2,
                      par_class in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_sav_trm_code varchar2(30 char);
      var_wrk_trm_code varchar2(30 char);
      var_wrk_search01 varchar2(256 char);
      var_wrk_search02 varchar2(256 char);
      var_wrk_search03 varchar2(256 char);
      var_wrk_search04 varchar2(256 char);
      var_wrk_search05 varchar2(256 char);
      var_wrk_search06 varchar2(256 char);
      var_wrk_search07 varchar2(256 char);
      var_wrk_search08 varchar2(256 char);
      var_wrk_search09 varchar2(256 char);
      var_val_key varchar2(30 char);
      var_val_message varchar2(4000 char);
      var_row_count number;
      rcd_sap_val_mes sap_val_mes%rowtype;
      var_dynamic varchar2(32767 char);
      type typ_dynamic is ref cursor;
      csr_dynamic typ_dynamic;
      var_start_time date;
      var_end_time date;
      var_time_diff number;
           

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_message is
         select vam_sequence
           from sap_val_mes t01
          where t01.vam_execution = par_execution
            and t01.vam_code = var_wrk_trm_code
            and t01.vam_class = par_class
          order by t01.vam_sequence desc;
      rcd_message csr_message%rowtype;

      cursor csr_class_rule is
         select *
           from sap_val_cla_rul t01,
                sap_val_rul t02
          where t01.vcr_rule = t02.var_rule
            and t01.vcr_class = par_class
            and t02.var_group = par_group
          order by t01.vcr_sequence asc;
      rcd_class_rule csr_class_rule%rowtype;

      cursor csr_type_header is
         select t02.vaf_type,
                t02.vaf_filter
           from sap_val_fil_det t01,
                sap_val_fil t02
          where t01.vfd_filter = t02.vaf_filter
            and t01.vfd_code in (select wrk_trm_code from table(lads_validation.get_table))
            and t02.vaf_group = par_group
          group by t02.vaf_type,
                   t02.vaf_filter;
      rcd_type_header csr_type_header%rowtype;

      cursor csr_type_rule is
         select *
           from sap_val_typ_rul t01,
                sap_val_rul t02
          where t01.vtr_rule = t02.var_rule
            and t01.vtr_type = rcd_type_header.vaf_type
            and t02.var_group = par_group
          order by t01.vtr_sequence asc;
      rcd_type_rule csr_type_rule%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the validation message data
      /*-*/
      rcd_sap_val_mes.vam_execution := par_execution;
      rcd_sap_val_mes.vam_class := par_class;
      rcd_sap_val_mes.vam_group := par_group;
      rcd_sap_val_mes.vam_type := '*CLASS';
      rcd_sap_val_mes.vam_filter := '*CLASS';
      rcd_sap_val_mes.vam_version := 0;
      rcd_sap_val_mes.vam_emailed := 0;
      if par_execution = con_single_code then
         rcd_sap_val_mes.vam_version := 1;
      end if;

      /*-*/
      /* Perform the validation base rules
      /* **note** this validation is based on the classification requirements
      /*-*/
      open csr_class_rule;
      loop
         fetch csr_class_rule into rcd_class_rule;
         if csr_class_rule%notfound then
            exit;
         end if;

         /*-*/
         /* Set the message rule
         /*-*/
          rcd_sap_val_mes.vam_rule := rcd_class_rule.var_rule;
          var_start_time := sysdate;
         /*-*/
         /* Build the rule query statement
         /*-*/
         var_dynamic := 'select t01.wrk_trm_code,
                                t01.wrk_search01,
                                t01.wrk_search02,
                                t01.wrk_search03,
                                t01.wrk_search04,
                                t01.wrk_search05,
                                t01.wrk_search06,
                                t01.wrk_search07,
                                t01.wrk_search08,
                                t01.wrk_search09,
                                t02.val_key,
                                t02.val_message
                           from table(lads_validation.get_table) t01,
                                (' || chr(10) || get_clob(rcd_class_rule.var_query) || chr(10) || ') t02
                          where t01.wrk_lng_code = t02.val_key(+)
                          order by t01.wrk_trm_code asc';

         /*-*/
         /* Execute the validation rule query
         /*-*/
         var_sav_trm_code := null;
         var_row_count := 0;
         begin
            open csr_dynamic for var_dynamic;
         exception
            when others then
               raise_application_error(-20000, 'Rule (' || rcd_class_rule.var_rule || ') query failed - ' || substr(SQLERRM, 1, 1024));
         end;
         loop
            fetch csr_dynamic into var_wrk_trm_code,
                                   var_wrk_search01,
                                   var_wrk_search02,
                                   var_wrk_search03,
                                   var_wrk_search04,
                                   var_wrk_search05,
                                   var_wrk_search06,
                                   var_wrk_search07,
                                   var_wrk_search08,
                                   var_wrk_search09,
                                   var_val_key,
                                   var_val_message;
            if csr_dynamic%notfound then
               exit;
            end if;

            /*-*/
            /* Change work code
            /*-*/
            if var_sav_trm_code is null or var_sav_trm_code != var_wrk_trm_code then

               /*-*/
               /* Output the previous code after messages
               /*-*/
               if not(var_sav_trm_code) is null then

                  /*-*/
                  /* Output the *LAST_ROW message
                  /*-*/
                  if rcd_class_rule.var_test = '*LAST_ROW' and var_row_count > 0 then
                     rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                     rcd_sap_val_mes.vam_text := var_val_message;
                     create_message(rcd_sap_val_mes);
                  end if;

                  /*-*/
                  /* Output the *ANY_ROWS static message
                  /*-*/
                  if rcd_class_rule.var_test = '*ANY_ROWS' and var_row_count > 0 then
                     rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                     rcd_sap_val_mes.vam_text := rcd_class_rule.var_message;
                     create_message(rcd_sap_val_mes);
                  end if;

                  /*-*/
                  /* Output the *NO_ROWS static message
                  /*-*/
                  if rcd_class_rule.var_test = '*NO_ROWS' and var_row_count = 0 then
                     rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                     rcd_sap_val_mes.vam_text := rcd_class_rule.var_message;
                     create_message(rcd_sap_val_mes);
                  end if;

               end if;

               /*-*/
               /* Reset the work code
               /*-*/
               var_sav_trm_code := var_wrk_trm_code;
               var_row_count := 0;

               /*-*/
               /* Set the code and find the highest message sequence number
               /*-*/
               rcd_sap_val_mes.vam_code := var_wrk_trm_code;
               rcd_sap_val_mes.vam_sequence := 0;
               open csr_message;
               fetch csr_message into rcd_message;
               if csr_message%found then
                  rcd_sap_val_mes.vam_sequence := rcd_message.vam_sequence;
               end if;
               close csr_message;

            end if;

            /*-*/
            /* Set the message search values
            /*-*/
            rcd_sap_val_mes.vam_search01 := var_wrk_search01;
            rcd_sap_val_mes.vam_search02 := var_wrk_search02;
            rcd_sap_val_mes.vam_search03 := var_wrk_search03;
            rcd_sap_val_mes.vam_search04 := var_wrk_search04;
            rcd_sap_val_mes.vam_search05 := var_wrk_search05;
            rcd_sap_val_mes.vam_search06 := var_wrk_search06;
            rcd_sap_val_mes.vam_search07 := var_wrk_search07;
            rcd_sap_val_mes.vam_search08 := var_wrk_search08;
            rcd_sap_val_mes.vam_search09 := var_wrk_search09;

            /*-*/
            /* Rule message found
            /*-*/
            if not(var_val_key) is null then

               /*-*/
               /* Increment the row
               /*-*/
               var_row_count := var_row_count + 1;

               /*-*/
               /* Output the *FIRST_ROW message
               /*-*/
               if rcd_class_rule.var_test = '*FIRST_ROW' and var_row_count = 1 then
                  rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                  rcd_sap_val_mes.vam_text := var_val_message;
                  create_message(rcd_sap_val_mes);
               end if;

               /*-*/
               /* Output the *EACH_ROW message
               /*-*/
               if rcd_class_rule.var_test = '*EACH_ROW' then
                  rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                  rcd_sap_val_mes.vam_text := var_val_message;
                  create_message(rcd_sap_val_mes);
               end if;

            end if;

         end loop;
         close csr_dynamic;

         /*-*/
         /* Output the previous code after messages
         /*-*/
         if not(var_sav_trm_code) is null then

            /*-*/
            /* Output the *LAST_ROW message
            /*-*/
            if rcd_class_rule.var_test = '*LAST_ROW' and var_row_count > 0 then
               rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
               rcd_sap_val_mes.vam_text := var_val_message;
               create_message(rcd_sap_val_mes);
            end if;

            /*-*/
            /* Output the *ANY_ROWS static message
            /*-*/
            if rcd_class_rule.var_test = '*ANY_ROWS' and var_row_count > 0 then
               rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
               rcd_sap_val_mes.vam_text := rcd_class_rule.var_message;
               create_message(rcd_sap_val_mes);
            end if;

            /*-*/
            /* Output the *NO_ROWS static message
            /*-*/
            if rcd_class_rule.var_test = '*NO_ROWS' and var_row_count = 0 then
               rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
               rcd_sap_val_mes.vam_text := rcd_class_rule.var_message;
               create_message(rcd_sap_val_mes);
            end if;

         end if;

         /*-*/
         /* Commit the database
         /*-*/
         commit;
         
         var_end_time := sysdate;
         var_time_diff := round((var_end_time - var_start_time)*24*60*60,0);        
                
         lics_logging.write_log('RULE - ' || rcd_class_rule.var_rule || ' - EXECUTION TIME - ' || to_char(to_date(var_time_diff,'sssss'),'hh24:mi:ss'));
         var_time_diff := 0;
          
      end loop;
      close csr_class_rule;

      /*-*/
      /* Retrieve the distinct validation type/filters
      /*-*/
      open csr_type_header;
      loop
         fetch csr_type_header into rcd_type_header;
         if csr_type_header%notfound then
            exit;
         end if;

         /*-*/
         /* Set the message type and filter
         /*-*/
         rcd_sap_val_mes.vam_type := rcd_type_header.vaf_type;
         rcd_sap_val_mes.vam_filter := rcd_type_header.vaf_filter;

         /*-*/
         /* Perform the validation type rules
         /* **note** this validation is based on the type requirements
         /*-*/
         open csr_type_rule;
         loop
            fetch csr_type_rule into rcd_type_rule;
            if csr_type_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Set the message rule
            /*-*/
            rcd_sap_val_mes.vam_rule := rcd_type_rule.var_rule;

            /*-*/
            /* Build the rule query statement
            /*-*/
            var_dynamic := 'select t01.wrk_trm_code,
                                   t01.wrk_search01,
                                   t01.wrk_search02,
                                   t01.wrk_search03,
                                   t01.wrk_search04,
                                   t01.wrk_search05,
                                   t01.wrk_search06,
                                   t01.wrk_search07,
                                   t01.wrk_search08,
                                   t01.wrk_search09,
                                   t02.val_key,
                                   t02.val_message
                              from (select t11.*
                                      from table(lads_validation.get_table) t11,
                                           (select vfd_code from sap_val_fil_det where vfd_filter = ''' || rcd_type_header.vaf_filter || ''') t12
                                     where t11.wrk_trm_code = t12.vfd_code) t01,
                                   (' || chr(10) || get_clob(rcd_type_rule.var_query) || chr(10) ||') t02
                             where t01.wrk_lng_code = t02.val_key(+)
                             order by t01.wrk_trm_code asc';

            /*-*/
            /* Execute the validation rule query
            /*-*/
            var_sav_trm_code := null;
            var_row_count := 0;
            begin
               open csr_dynamic for var_dynamic;
            exception
               when others then
                  raise_application_error(-20000, 'Rule (' || rcd_type_rule.var_rule || ') query failed - ' || substr(SQLERRM, 1, 1024));
            end;
            loop
               fetch csr_dynamic into var_wrk_trm_code,
                                      var_wrk_search01,
                                      var_wrk_search02,
                                      var_wrk_search03,
                                      var_wrk_search04,
                                      var_wrk_search05,
                                      var_wrk_search06,
                                      var_wrk_search07,
                                      var_wrk_search08,
                                      var_wrk_search09,
                                      var_val_key,
                                      var_val_message;
               if csr_dynamic%notfound then
                  exit;
               end if;

               /*-*/
               /* Change work code
               /*-*/
               if var_sav_trm_code is null or var_sav_trm_code != var_wrk_trm_code then

                  /*-*/
                  /* Output the previous code after messages
                  /*-*/
                  if not(var_sav_trm_code) is null then

                     /*-*/
                     /* Output the *LAST_ROW message
                     /*-*/
                     if rcd_class_rule.var_test = '*LAST_ROW' and var_row_count > 0 then
                        rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                        rcd_sap_val_mes.vam_text := var_val_message;
                        create_message(rcd_sap_val_mes);
                     end if;

                     /*-*/
                     /* Output the *ANY_ROWS static message
                     /*-*/
                     if rcd_class_rule.var_test = '*ANY_ROWS' and var_row_count > 0 then
                        rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                        rcd_sap_val_mes.vam_text := rcd_class_rule.var_message;
                        create_message(rcd_sap_val_mes);
                     end if;

                     /*-*/
                     /* Output the *NO_ROWS static message
                     /*-*/
                     if rcd_class_rule.var_test = '*NO_ROWS' and var_row_count = 0 then
                        rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                        rcd_sap_val_mes.vam_text := rcd_class_rule.var_message;
                        create_message(rcd_sap_val_mes);
                     end if;

                  end if;

                  /*-*/
                  /* Reset the work code
                  /*-*/
                  var_sav_trm_code := var_wrk_trm_code;
                  var_row_count := 0;

                  /*-*/
                  /* Set the code and find the highest message sequence number
                  /*-*/
                  rcd_sap_val_mes.vam_code := var_wrk_trm_code;
                  rcd_sap_val_mes.vam_sequence := 0;
                  open csr_message;
                  fetch csr_message into rcd_message;
                  if csr_message%found then
                     rcd_sap_val_mes.vam_sequence := rcd_message.vam_sequence;
                  end if;
                  close csr_message;

               end if;

               /*-*/
               /* Set the message search values
               /*-*/
               rcd_sap_val_mes.vam_search01 := var_wrk_search01;
               rcd_sap_val_mes.vam_search02 := var_wrk_search02;
               rcd_sap_val_mes.vam_search03 := var_wrk_search03;
               rcd_sap_val_mes.vam_search04 := var_wrk_search04;
               rcd_sap_val_mes.vam_search05 := var_wrk_search05;
               rcd_sap_val_mes.vam_search06 := var_wrk_search06;
               rcd_sap_val_mes.vam_search07 := var_wrk_search07;
               rcd_sap_val_mes.vam_search08 := var_wrk_search08;
               rcd_sap_val_mes.vam_search09 := var_wrk_search09;

               /*-*/
               /* Rule message found
               /*-*/
               if not(var_val_key) is null then

                  /*-*/
                  /* Increment the row
                  /*-*/
                  var_row_count := var_row_count + 1;

                  /*-*/
                  /* Output the *FIRST_ROW message
                  /*-*/
                  if rcd_type_rule.var_test = '*FIRST_ROW' and var_row_count = 1 then
                     rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                     rcd_sap_val_mes.vam_text := var_val_message;
                     create_message(rcd_sap_val_mes);
                  end if;

                  /*-*/
                  /* Output the *EACH_ROW message
                  /*-*/
                  if rcd_type_rule.var_test = '*EACH_ROW' then
                     rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                     rcd_sap_val_mes.vam_text := var_val_message;
                     create_message(rcd_sap_val_mes);
                  end if;

               end if;

            end loop;
            close csr_dynamic;

            /*-*/
            /* Output the previous code after messages
            /*-*/
            if not(var_sav_trm_code) is null then

               /*-*/
               /* Output the *LAST_ROW message
               /*-*/
               if rcd_type_rule.var_test = '*LAST_ROW' and var_row_count > 0 then
                  rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                  rcd_sap_val_mes.vam_text := var_val_message;
                  create_message(rcd_sap_val_mes);
               end if;

               /*-*/
               /* Output the *ANY_ROWS static message
               /*-*/
               if rcd_type_rule.var_test = '*ANY_ROWS' and var_row_count > 0 then
                  rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                  rcd_sap_val_mes.vam_text := rcd_type_rule.var_message;
                  create_message(rcd_sap_val_mes);
               end if;

               /*-*/
               /* Output the *NO_ROWS static message
               /*-*/
               if rcd_type_rule.var_test = '*NO_ROWS' and var_row_count = 0 then
                  rcd_sap_val_mes.vam_sequence := rcd_sap_val_mes.vam_sequence + 1;
                  rcd_sap_val_mes.vam_text := rcd_type_rule.var_message;
                  create_message(rcd_sap_val_mes);
               end if;

            end if;

            /*-*/
            /* Commit the database
            /*-*/
            commit;

         end loop;
         close csr_type_rule;

      end loop;
      close csr_type_header;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate;

   /******************************************************/
   /* This procedure performs the create message routine */
   /******************************************************/
   procedure create_message(par_message in sap_val_mes%rowtype) is

      /*-*/
      /* Local definitions
      /*-*/
      var_assigned boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_email_detail is
         select distinct(t01.ved_email) as ved_email
           from sap_val_ema_det t01
          where (t01.ved_group = '*ALL' or t01.ved_group = par_message.vam_group)
            and (t01.ved_class = '*ALL' or t01.ved_class = par_message.vam_class)
            and (t01.ved_type = '*ALL' or (t01.ved_type = '*CODE' and substr(par_message.vam_type,1,1) != '*') or t01.ved_type = par_message.vam_type)
            and (t01.ved_filter = '*ALL' or t01.ved_filter = par_message.vam_filter)
            and (t01.ved_rule = '*ALL' or t01.ved_rule = par_message.vam_rule)
            and (t01.ved_search01 is null or t01.ved_search01 = par_message.vam_search01)
            and (t01.ved_search02 is null or t01.ved_search02 = par_message.vam_search02)
            and (t01.ved_search03 is null or t01.ved_search03 = par_message.vam_search03)
            and (t01.ved_search04 is null or t01.ved_search04 = par_message.vam_search04)
            and (t01.ved_search05 is null or t01.ved_search05 = par_message.vam_search05)
            and (t01.ved_search06 is null or t01.ved_search06 = par_message.vam_search06)
            and (t01.ved_search07 is null or t01.ved_search07 = par_message.vam_search07)
            and (t01.ved_search08 is null or t01.ved_search08 = par_message.vam_search08)
            and (t01.ved_search09 is null or t01.ved_search09 = par_message.vam_search09);
      rcd_email_detail csr_email_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the new validation message
      /*-*/
      insert into sap_val_mes
         (vam_execution,
          vam_code,
          vam_class,
          vam_sequence,
          vam_group,
          vam_type,
          vam_filter,
          vam_rule,
          vam_text,
          vam_version,
          vam_emailed,
          vam_search01,
          vam_search02,
          vam_search03,
          vam_search04,
          vam_search05,
          vam_search06,
          vam_search07,
          vam_search08,
          vam_search09)
         values(par_message.vam_execution,
                par_message.vam_code,
                par_message.vam_class,
                par_message.vam_sequence,
                par_message.vam_group,
                par_message.vam_type,
                par_message.vam_filter,
                par_message.vam_rule,
                par_message.vam_text,
                par_message.vam_version,
                par_message.vam_emailed,
                par_message.vam_search01,
                par_message.vam_search02,
                par_message.vam_search03,
                par_message.vam_search04,
                par_message.vam_search05,
                par_message.vam_search06,
                par_message.vam_search07,
                par_message.vam_search08,
                par_message.vam_search09);

      /*-*/
      /* Retrieve the email selections satisfied by the classification search when required
      /*-*/
      if par_message.vam_execution != con_single_code then

         /*-*/
         /* Insert the email message links
         /*-*/
         var_assigned := false;
         open csr_email_detail;
         loop
            fetch csr_email_detail into rcd_email_detail;
            if csr_email_detail%notfound then
               exit;
            end if;

            /*-*/
            /* Insert the email message link
            /*-*/
            var_assigned := true;
            insert into sap_val_mes_ema
               (vme_execution,
                vme_code,
                vme_class,
                vme_sequence,
                vme_email)
               values(par_message.vam_execution,
                      par_message.vam_code,
                      par_message.vam_class,
                      par_message.vam_sequence,
                      rcd_email_detail.ved_email);

         end loop;
         close csr_email_detail;

         /*-*/
         /* Insert the email message default link when not assigned
         /*-*/
         if var_assigned = false then
            insert into sap_val_mes_ema
               (vme_execution,
                vme_code,
                vme_class,
                vme_sequence,
                vme_email)
               values(par_message.vam_execution,
                      par_message.vam_code,
                      par_message.vam_class,
                      par_message.vam_sequence,
                      con_admin_code);
         end if;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_message;

   /******************************************************/
   /* This procedure performs the email messages routine */
   /******************************************************/
   procedure email_messages(par_execution in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_class sap_val_cla.vac_class%type;
      var_prt_count number;
      var_row_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_email is
         select t01.*
           from sap_val_ema t01
          where t01.vae_status = '1'
          order by t01.vae_email asc;
      rcd_email csr_email%rowtype;

      cursor csr_assigned is
         select t01.*,
                t02.*
           from sap_val_mes_ema t01,
                sap_val_mes t02
          where t01.vme_execution = t02.vam_execution
            and t01.vme_code = t02.vam_code
            and t01.vme_class = t02.vam_class
            and t01.vme_sequence = t02.vam_sequence
            and t01.vme_email = rcd_email.vae_email
            and t01.vme_execution = par_execution
          order by t01.vme_class,
                   t01.vme_code,
                   t01.vme_sequence;
      rcd_assigned csr_assigned%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve active email groups
      /*-*/
      open csr_email;
      loop
         fetch csr_email into rcd_email;
         if csr_email%notfound then
            exit;
         end if;

         /*-*/
         /* Email any current execution messages
         /*-*/
         var_class := null;
         var_prt_count := 1;
         var_row_count := 0;
         open csr_assigned;
         loop
            fetch csr_assigned into rcd_assigned;
            if csr_assigned%notfound then
               exit;
            end if;

            /*-*/
            /* Classification/table control break
            /*-*/
            if var_class is null or
               var_class != rcd_assigned.vam_class or
               var_row_count >= con_max_row then

               /*-*/
               /* Start of email
               /*-*/
               if var_class is null then

                  /*-*/
                  /* Create the new email and create the email text header part
                  /*-*/
                  lics_mailer.create_email(lads_parameter.system_code || '_' || lads_parameter.system_unit || '_' || lads_parameter.system_environment,
                                           rcd_email.vae_address,
                                           'LADS Validation ('||rcd_email.vae_description||')',
                                           null,
                                           null);
                  lics_mailer.create_part(null);
                  lics_mailer.append_data('LADS Batch Validation ('||par_execution||')');
                  lics_mailer.append_data(rpad('=',length('LADS Batch Validation ('||par_execution||')'),'='));
                  lics_mailer.append_data(null);
                  if rcd_email.vae_address = con_admin_code then
                     lics_mailer.append_data('The following spreadsheets contain the validation messages not assigned to any email group...');
                  else
                     lics_mailer.append_data('The following spreadsheets contain the related validation messages...');
                  end if;
                  lics_mailer.append_data(null);
                  lics_mailer.append_data(null);
                  lics_mailer.append_data(null);

                  /*-*/
                  /* Reset the part count
                  /*-*/
                  var_prt_count := 1;

               /*-*/
               /* Change of classification
               /*-*/
               elsif var_class != rcd_assigned.vam_class then

                  /*-*/
                  /* Output the email file part trailer data
                  /*-*/
                  lics_mailer.append_data('</table>');

                  /*-*/
                  /* Reset the part count
                  /*-*/
                  var_prt_count := 1;

               /*-*/
               /* Maximum row count reached
               /*-*/
               else

                  /*-*/
                  /* Output the email file part trailer data
                  /*-*/
                  lics_mailer.append_data('</table>');

                  /*-*/
                  /* Increment the part count
                  /*-*/
                  var_prt_count := var_prt_count + 1;

               end if;

               /*-*/
               /* Save the new classification code
               /*-*/
               var_class := rcd_assigned.vam_class;

               /*-*/
               /* Create the email file part and output the header data
               /*-*/
               if var_prt_count = 1 then
                  lics_mailer.create_part(par_execution||'_'||replace(var_class,'*','#')||'.xml');
               else
                  lics_mailer.create_part(par_execution||'_'||replace(var_class,'*','#')||'_PART'||to_char(var_prt_count,'fm9999999990')||'.xml');
               end if;
               
                 lics_mailer.append_data('<?xml version="1.0" ?>');
                 lics_mailer.append_data('<?mso-application progid="Excel.Sheet"?>');
                 lics_mailer.append_data('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office"');
                 lics_mailer.append_data('xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
                 lics_mailer.append_data('xmlns:html="http://www.w3.org/TR/REC-html40">');
                 lics_mailer.append_data('<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">');
                 lics_mailer.append_data('<Title>' || lads_parameter.system_code || ' Validation</Title>');
                 lics_mailer.append_data('<Subject>' || rcd_assigned.vam_group || '</Subject>');
                 lics_mailer.append_data('<Author>' || lads_parameter.system_code || '_' || lads_parameter.system_unit || '_' || lads_parameter.system_environment || '</Author>');
                 lics_mailer.append_data('<Company>Mars Information Services</Company>');                 
                 lics_mailer.append_data('</DocumentProperties>');
                 lics_mailer.append_data('<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel"></ExcelWorkbook>');
                 
                 --******DEFINE STYLE******
                    
                 lics_mailer.append_data('<Styles>');
                 
                 lics_mailer.append_data('<Style ss:ID="Normal" ss:Name="Normal">');
                 lics_mailer.append_data('<Alignment ss:Vertical="Top" ss:WrapText="0" />');
                 lics_mailer.append_data('<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Size="11" />');
                 lics_mailer.append_data('</Style>');
                 
                 lics_mailer.append_data('<Style ss:ID="red">');
                 lics_mailer.append_data('<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="white" ss:Size="11" ss:Bold="1" />');
                 lics_mailer.append_data('<Interior ss:Color="red" ss:Pattern="Solid" />');
                 lics_mailer.append_data('</Style>');
                 
                 lics_mailer.append_data('<Style ss:ID="blue">');
                 lics_mailer.append_data('<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="white" ss:Size="11" ss:Bold="1" />');
                 lics_mailer.append_data('<Interior ss:Color="blue" ss:Pattern="Solid" />');
                 lics_mailer.append_data('</Style>');
                    
                 lics_mailer.append_data('<Style ss:ID="black">');
                 lics_mailer.append_data('<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="white" ss:Size="11" ss:Bold="1" />');
                 lics_mailer.append_data('<Interior ss:Color="black" ss:Pattern="Solid" />');
                 lics_mailer.append_data('</Style>');
                 
                 lics_mailer.append_data('</Styles>');
                
                 lics_mailer.append_data('<Worksheet ss:Name="'||var_class||'">');
                 
                 /********FREEZE ROW AND COLUMN ********/
                 lics_mailer.append_data('<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">');
                 lics_mailer.append_data('<Selected />');
                 lics_mailer.append_data('<FreezePanes />');
                 lics_mailer.append_data('<FrozenNoSplit />');
                 lics_mailer.append_data('<SplitHorizontal>1</SplitHorizontal>');
                 lics_mailer.append_data('<TopRowBottomPane>1</TopRowBottomPane>');
                 lics_mailer.append_data('<SplitVertical>1</SplitVertical>');
                 lics_mailer.append_data('<LeftColumnRightPane>1</LeftColumnRightPane>');  
                 lics_mailer.append_data('<ActivePane>0</ActivePane>');
                 lics_mailer.append_data('<Panes>');
                 lics_mailer.append_data('<Pane>');
                 lics_mailer.append_data('<Number>3</Number>');
                 lics_mailer.append_data('</Pane>');
                 lics_mailer.append_data('<Pane>');
                 lics_mailer.append_data('<Number>2</Number>');
                 lics_mailer.append_data('</Pane>');
                 lics_mailer.append_data('<Pane>');
                 lics_mailer.append_data('<Number>1</Number>');
                 lics_mailer.append_data('</Pane>');
                 lics_mailer.append_data('<Pane>');
                 lics_mailer.append_data('<Number>0</Number>');
                 lics_mailer.append_data('</Pane>');
                 lics_mailer.append_data('</Panes>');
                 lics_mailer.append_data('<ProtectContents>False</ProtectContents>');
                 lics_mailer.append_data('<ProtectObjects>False</ProtectObjects>');
                 lics_mailer.append_data('<ProtectScenarios>False</ProtectScenarios>');    
                 lics_mailer.append_data('</WorksheetOptions>');
                 lics_mailer.append_data('<ss:ProtectStructure>False</ss:ProtectStructure>');
                 lics_mailer.append_data('<ss:ProtectWindows>False</ss:ProtectWindows>');
                
                 lics_mailer.append_data('<Table>');
                 /********HIDE COLUMNS*********/
                 lics_mailer.append_data('<Column ss:Hidden="0" ss:Width="100" />');
                 lics_mailer.append_data('<Column ss:Hidden="1" ss:Width="50" />');
                 lics_mailer.append_data('<Column ss:Hidden="1" ss:Width="50" />');
                 lics_mailer.append_data('<Column ss:Hidden="1" ss:Width="100" />');
                 lics_mailer.append_data('<Column ss:Hidden="1" ss:Width="50" />');
                 lics_mailer.append_data('<Column ss:Hidden="1" ss:Width="50" />');
                 lics_mailer.append_data('<Column ss:Hidden="0" ss:Width="100" />');
                 lics_mailer.append_data('<Column ss:Hidden="0" ss:Width="1000" />');
                    
                 lics_mailer.append_data('<Row>');
                 
                 /********HEADER ROWS**********/
                 lics_mailer.append_data('<Cell ss:StyleID="black">');
                 lics_mailer.append_data('<Data ss:Type="String">SAP Code</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="red">');
                 lics_mailer.append_data('<Data ss:Type="String">Sequence</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="red">');
                 lics_mailer.append_data('<Data ss:Type="String">Group</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="red">');
                 lics_mailer.append_data('<Data ss:Type="String">Classification</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="red">');
                 lics_mailer.append_data('<Data ss:Type="String">Type</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="red">');
                 lics_mailer.append_data('<Data ss:Type="String">Filter</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="blue">');
                 lics_mailer.append_data('<Data ss:Type="String">Rule</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('<Cell ss:StyleID="black">');
                 lics_mailer.append_data('<Data ss:Type="String">Message</Data>');
                 lics_mailer.append_data('</Cell>');
                
                 lics_mailer.append_data('</Row>');
               
                /*-*/
                /* Reset the email file row count
                /*-*/
                var_row_count := 1;

            end if;

            /*-*/
            /* Output the message data
           /*-*/
            lics_mailer.append_data('<Row>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_code||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_sequence||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_group||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_class||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_type||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_filter||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_rule||'</Data>');
            lics_mailer.append_data(' </Cell>');
            
            lics_mailer.append_data('<Cell>');
            lics_mailer.append_data('<Data ss:Type="String">'||rcd_assigned.vam_text||'</Data>');
            lics_mailer.append_data(' </Cell>');
              
            lics_mailer.append_data('</Row>');

            /*-*/
            /* Increment the email file row count
           /*-*/
            var_row_count := var_row_count + 1;

            /*-*/
            /* Update the message emailed count
           /*-*/
            update sap_val_mes
               set vam_emailed = vam_emailed + 1
             where vam_execution = rcd_assigned.vam_execution
               and vam_code = rcd_assigned.vam_code
               and vam_class = rcd_assigned.vam_class
               and vam_sequence = rcd_assigned.vam_sequence;

         end loop;
         close csr_assigned;

         /*-*/
         /* Complete the email when required
        /*-*/
         if not(var_class is null) then
            lics_mailer.append_data('</Table>');
           lics_mailer.append_data ('</Worksheet>');
            lics_mailer.append_data('</Workbook>');
            lics_mailer.create_part(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data('** Email End **');
            lics_mailer.finalise_email;
            commit;
         end if;

      end loop;
      close csr_email;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end email_messages;

   /*******************************************************/
   /* This procedure performs the load statistics routine */
   /*******************************************************/
   procedure load_statistics(par_group in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_count number;
      var_test varchar2(32767 char);
      type typ_test is ref cursor;
      csr_test typ_test;
      rcd_sap_val_sta sap_val_sta%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_class_header is
         select *
           from sap_val_cla t01
          where t01.vac_group = upper(par_group)
          order by t01.vac_class asc;
      rcd_class_header csr_class_header%rowtype;

      cursor csr_class_statistic is
         select vac_class,
                vac_description,
                0 as mis_count,
                nvl(err_count,0) as err_count,
                0 as val_count,
                nvl(mes_count,0) as mes_count
           from sap_val_cla t01,
                (select vam_class,
                        count(distinct vam_code) as err_count
                   from sap_val_mes
                  where vam_class = rcd_class_header.vac_class
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_class) t02,
                (select vam_class,
                        count(*) as mes_count
                   from sap_val_mes
                  where vam_class = rcd_class_header.vac_class
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_class) t03
          where t01.vac_class = t02.vam_class(+)
            and t01.vac_class = t03.vam_class(+)
            and t01.vac_class = rcd_class_header.vac_class;
      rcd_class_statistic csr_class_statistic%rowtype;

      cursor csr_type_statistic is
         select vat_type,
                vat_description,
                0 as mis_count,
                nvl(err_count,0) as err_count,
                0 as val_count,
                nvl(mes_count,0) as mes_count
           from sap_val_typ t01,
                (select vam_type,
                        count(distinct vam_code) as err_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_type) t02,
                (select vam_type,
                        count(*) as mes_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_type) t03
          where t01.vat_type = t02.vam_type(+)
            and t01.vat_type = t03.vam_type(+)
            and t01.vat_group = upper(par_group);
      rcd_type_statistic csr_type_statistic%rowtype;

      cursor csr_filter_statistic is
         select vaf_filter,
                vaf_description,
                nvl(mis_count,0) as mis_count,
                nvl(err_count,0) as err_count,
                nvl(val_count,0) - nvl(mis_count,0) - nvl(err_count,0) as val_count,
                nvl(mes_count,0) as mes_count
           from sap_val_fil t01,
                (select vam_filter,
                        count(distinct vam_code) as mis_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                    and vam_rule = '*MISSING'
                  group by vam_filter) t02,
                (select vam_filter,
                        count(distinct vam_code) as err_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                    and vam_rule != '*MISSING'
                  group by vam_filter) t03,
                (select vfd_filter,
                        count(*) as val_count
                   from sap_val_fil_det
                  group by vfd_filter) t04,
                (select vam_filter,
                        count(*) as mes_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_filter) t05
          where t01.vaf_filter = t02.vam_filter(+)
            and t01.vaf_filter = t03.vam_filter(+)
            and t01.vaf_filter = t04.vfd_filter(+)
            and t01.vaf_filter = t05.vam_filter(+)
            and t01.vaf_group = upper(par_group);
      rcd_filter_statistic csr_filter_statistic%rowtype;

      cursor csr_rule_statistic is
         select var_rule,
                var_description,
                0 as mis_count,
                nvl(err_count,0) as err_count,
                0 as val_count,
                nvl(mes_count,0) as mes_count
           from sap_val_rul t01,
                (select vam_rule,
                        count(distinct vam_code) as err_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_rule) t02,
                (select vam_rule,
                        count(*) as mes_count
                   from sap_val_mes
                  where vam_group = upper(par_group)
                    and vam_version = 0
                    and vam_execution != con_single_code
                  group by vam_rule) t03
          where t01.var_rule = t02.vam_rule(+)
            and t01.var_rule = t03.vam_rule(+)
            and t01.var_group = upper(par_group);
      rcd_rule_statistic csr_rule_statistic%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the statistic variables
     /*-*/
      rcd_sap_val_sta.vas_group := upper(par_group);

      /*-*/
      /* Delete any existing statistics for the group
     /*-*/
      delete from sap_val_sta
       where vas_group = rcd_sap_val_sta.vas_group;

      /*-*/
      /* Retrieve the statistics for all classifications
     /*-*/
      open csr_class_header;
      loop
         fetch csr_class_header into rcd_class_header;
         if csr_class_header%notfound then
            exit;
         end if;

         /*-*/
         /* Execute and count the classification list query
        /*-*/
         var_test := get_clob(rcd_class_header.vac_lst_query);
         begin
            open csr_test for 'select count(*) from (' || var_test || ')';
         exception
            when others then
               raise_application_error(-20000, 'Classification (' || rcd_class_header.vac_class || ') list query count failed - ' || substr(SQLERRM, 1, 1024));
         end;
         fetch csr_test into var_count;
         if csr_test%notfound then
            var_count := 0;
         end if;
         close csr_test;

         /*-*/
         /* Insert the classification statistics
        /*-*/
         open csr_class_statistic;
         fetch csr_class_statistic into rcd_class_statistic;
         if csr_class_statistic%found then
            rcd_sap_val_sta.vas_statistic := '*CLASS';
            rcd_sap_val_sta.vas_identifier := rcd_class_statistic.vac_class;
            rcd_sap_val_sta.vas_description := rcd_class_statistic.vac_description;
            rcd_sap_val_sta.vas_missing := rcd_class_statistic.mis_count;
            rcd_sap_val_sta.vas_error := rcd_class_statistic.err_count;
            rcd_sap_val_sta.vas_valid := var_count - rcd_class_statistic.err_count;
            rcd_sap_val_sta.vas_message := rcd_class_statistic.mes_count;
            insert into sap_val_sta
               (vas_group,
                vas_statistic,
                vas_identifier,
                vas_description,
                vas_missing,
                vas_error,
                vas_valid,
                vas_message)
               values(rcd_sap_val_sta.vas_group,
                      rcd_sap_val_sta.vas_statistic,
                      rcd_sap_val_sta.vas_identifier,
                      rcd_sap_val_sta.vas_description,
                      rcd_sap_val_sta.vas_missing,
                      rcd_sap_val_sta.vas_error,
                      rcd_sap_val_sta.vas_valid,
                      rcd_sap_val_sta.vas_message);
         end if;
         close csr_class_statistic;

      end loop;
      close csr_class_header;

      /*-*/
      /* Insert the type statistics
     /*-*/
      open csr_type_statistic;
      loop
         fetch csr_type_statistic into rcd_type_statistic;
         if csr_type_statistic%notfound then
            exit;
         end if;
         rcd_sap_val_sta.vas_statistic := '*TYPE';
         rcd_sap_val_sta.vas_identifier := rcd_type_statistic.vat_type;
         rcd_sap_val_sta.vas_description := rcd_type_statistic.vat_description;
         rcd_sap_val_sta.vas_missing := rcd_type_statistic.mis_count;
         rcd_sap_val_sta.vas_error := rcd_type_statistic.err_count;
         rcd_sap_val_sta.vas_valid := rcd_type_statistic.val_count;
         rcd_sap_val_sta.vas_message := rcd_type_statistic.mes_count;
         insert into sap_val_sta
            (vas_group,
             vas_statistic,
             vas_identifier,
             vas_description,
             vas_missing,
             vas_error,
             vas_valid,
             vas_message)
            values(rcd_sap_val_sta.vas_group,
                   rcd_sap_val_sta.vas_statistic,
                   rcd_sap_val_sta.vas_identifier,
                   rcd_sap_val_sta.vas_description,
                   rcd_sap_val_sta.vas_missing,
                   rcd_sap_val_sta.vas_error,
                   rcd_sap_val_sta.vas_valid,
                   rcd_sap_val_sta.vas_message);
      end loop;
      close csr_type_statistic;

      /*-*/
      /* Insert the filter statistics
     /*-*/
      open csr_filter_statistic;
      loop
         fetch csr_filter_statistic into rcd_filter_statistic;
         if csr_filter_statistic%notfound then
            exit;
         end if;
         rcd_sap_val_sta.vas_statistic := '*FILTER';
         rcd_sap_val_sta.vas_identifier := rcd_filter_statistic.vaf_filter;
         rcd_sap_val_sta.vas_description := rcd_filter_statistic.vaf_description;
         rcd_sap_val_sta.vas_missing := rcd_filter_statistic.mis_count;
         rcd_sap_val_sta.vas_error := rcd_filter_statistic.err_count;
         rcd_sap_val_sta.vas_valid := rcd_filter_statistic.val_count;
         rcd_sap_val_sta.vas_message := rcd_filter_statistic.mes_count;
         insert into sap_val_sta
            (vas_group,
             vas_statistic,
             vas_identifier,
             vas_description,
             vas_missing,
             vas_error,
             vas_valid,
             vas_message)
            values(rcd_sap_val_sta.vas_group,
                   rcd_sap_val_sta.vas_statistic,
                   rcd_sap_val_sta.vas_identifier,
                   rcd_sap_val_sta.vas_description,
                   rcd_sap_val_sta.vas_missing,
                   rcd_sap_val_sta.vas_error,
                   rcd_sap_val_sta.vas_valid,
                   rcd_sap_val_sta.vas_message);
      end loop;
      close csr_filter_statistic;

      /*-*/
      /* Insert the rule statistics
     /*-*/
      open csr_rule_statistic;
      loop
         fetch csr_rule_statistic into rcd_rule_statistic;
         if csr_rule_statistic%notfound then
            exit;
         end if;
         rcd_sap_val_sta.vas_statistic := '*RULE';
         rcd_sap_val_sta.vas_identifier := rcd_rule_statistic.var_rule;
         rcd_sap_val_sta.vas_description := rcd_rule_statistic.var_description;
         rcd_sap_val_sta.vas_missing := rcd_rule_statistic.mis_count;
         rcd_sap_val_sta.vas_error := rcd_rule_statistic.err_count;
         rcd_sap_val_sta.vas_valid := rcd_rule_statistic.val_count;
         rcd_sap_val_sta.vas_message := rcd_rule_statistic.mes_count;
         insert into sap_val_sta
            (vas_group,
             vas_statistic,
             vas_identifier,
             vas_description,
             vas_missing,
             vas_error,
             vas_valid,
             vas_message)
            values(rcd_sap_val_sta.vas_group,
                   rcd_sap_val_sta.vas_statistic,
                   rcd_sap_val_sta.vas_identifier,
                   rcd_sap_val_sta.vas_description,
                   rcd_sap_val_sta.vas_missing,
                   rcd_sap_val_sta.vas_error,
                   rcd_sap_val_sta.vas_valid,
                   rcd_sap_val_sta.vas_message);
      end loop;
      close csr_rule_statistic;

      /*-*/
      /* Commit the database
     /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_statistics;

   /************************************************/
   /* This procedure performs the get clob routine */
   /************************************************/
   function get_clob(par_clob in clob) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);
      var_pointer integer;
      var_length binary_integer := 2000;
      var_buffer varchar2(2000 char);
      var_return varchar2(32767 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the clob in 2000 character chunks
     /*-*/
      var_return := null;
      var_pointer := 1;
      loop

         /*-*/
         /* Retrieve the next chunk
        /*-*/
         begin
            dbms_lob.read(par_clob, var_length, var_pointer, var_buffer);
            var_pointer := var_pointer + var_length;
         exception
            when no_data_found then
               var_pointer := -1;
         end;
         if var_pointer < 0 then
            exit;
         end if;

         /*-*/
         /* Build the return value
        /*-*/
         var_return := var_return || var_buffer;

      end loop;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_clob;

   /************************************************/
   /* This function performs the get table routine */
   /************************************************/
   function get_table return lads_validation_table is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the virtual table
     /*-*/
      return var_vir_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;

end lads_validation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_validation for lads_app.lads_validation;
grant execute on lads_validation to public;
