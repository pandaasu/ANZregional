DROP PACKAGE CR_APP.CARE_DATA_LOAD;

CREATE OR REPLACE PACKAGE CR_APP.care_data_load as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CARE
 Package : care_data_load
 Owner   : CR_APP
 Author  : Linden Glen

 Description
 -----------
 CARE data load (Staging Tables to CARE application table)

 NOTES :

   1. Primary key on CARE table keywrd is of type CHAR(10). This means that values
      stored there are right padded to the full length (an attribute of type CHAR).

 PARAMETERS :

   1. PAR_ACTION : (*ALL or SELL MOE CODE)
         *ALL - will execute keywrd data loading for all MOE codes available from care_tdu_tmp
         <SELL MOE> - will result in only data for the specific SELL MOE being loaded


 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Linden Glen    Created
 2005/12   Linden Glen    ADD: Logic for XREF status
 2006/02   Linden Glen    MOD: Manu detail population - bug fix
                          REM: KEYW_DESCRIPTION_40 Update logic
                          MOD: KEYW_INACTIVE - defined as 'N' (ACTIVE)
                               Logic remains (commented out) to process from
                               staging area for use when GRD data is corrected
 2006/08                  ADD: processing to move staged data into global temporary
                               table for loading. Allows duplicate materials to be
                               removed and increase load speed.
                          MOD: Allow SELL MOE codes to be passed in
                          MOD: Disallow executing only one load component (ie. manu menu or hierachy)

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2);

end care_data_load;
/


DROP PACKAGE BODY CR_APP.CARE_DATA_LOAD;

CREATE OR REPLACE PACKAGE BODY CR_APP.care_data_load as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Local constants
   /*-*/
   con_function constant varchar2(128) := 'CARE Data Load';

   /*-*/
   /* Private declarations
   /*-*/
   procedure load_tdu_to_rsu;
   procedure load_keywrd(par_tdu in varchar2, par_rsu in varchar2, par_key in varchar2);
   procedure load_hierachies;
   procedure load_manu_menu;

   /*-*/
   /* Define Variables
   /*-*/
   var_log_prefix varchar2(256);
   var_bsg_cnt number(4,0);
   var_brf_cnt number(4,0);
   var_bsf_cnt number(4,0);
   var_cpf_cnt number(4,0);
   var_pct_cnt number(4,0);
   var_cpt_cnt number(4,0);
   var_pty_cnt number(4,0);
   var_igv_cnt number(4,0);
   var_sze_cnt number(4,0);
   var_other_cnt number(4,0);

   type typ_msg is table of varchar2(4000) index by binary_integer;
   critical_msg typ_msg;
   warning_msg typ_msg;
   update_msg typ_msg;
   insert_msg typ_msg;
   menu_hdr_msg typ_msg;
   menu_det_msg typ_msg;

   rec_care_xrf care_xref%rowtype;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_sql varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_log_prefix := 'CARE - DATA LOAD - ';

      /*-*/
      /* Initialise arrays
      /*-*/
      critical_msg.delete;
      warning_msg.delete;
      update_msg.delete;
      insert_msg.delete;
      menu_hdr_msg.delete;
      menu_det_msg.delete;


      /*-*/
      /* Validate the parameters
      /*-*/
      if (par_action is null) then
         raise_application_error(-20000, 'Action parameter must be *ALL or a valid SELL MOE code');
      end if;

      /*-*/
      /* Log start
      /*-*/
      sil_logging.start_log(var_log_prefix, con_function);

      /*-*/
      /* Begin procedure
      /*-*/
      sil_logging.write_log('Begin - CARE Data Load - Parameters(' || upper(par_action) || ')');

      /*-*/
      /* Create Email Interface
      /*-*/
      isi_mailer.create_email(sil_parameter.email_data_load,
                              'AP CARE DATA LOAD RESULTS FOR ' || to_char(sysdate,'YYYYMMDD'),
                              null,
                              null);

      /*-*/
      /* Write Email Header
      /*-*/
      isi_mailer.append_data('AP CARE DATA LOAD RESULTS (YYYYMMDD) ' || to_char(sysdate,'YYYYMMDD') || ' at ' || to_char(sysdate,'HH24:MI:SS'));
      isi_mailer.append_data('=========================================================================');
      isi_mailer.append_data(null);



      /*-*/
      /* Initialise global temporary table
      /*-*/
      delete care_tdu_tmp;

      /*-*/
      /* Populate temporary load table
      /*-*/
      var_sql := 'insert into care_tdu_tmp';
      var_sql := var_sql || ' select grd_tdu, max(xrf_key), max(keyw_type), max(keyw_description_40),';
      var_sql := var_sql || ' max(keyw_description_74),max(keyw_ask_for_input), max(keyw_apn), max(keyw_replace_key),';
      var_sql := var_sql || ' max(keyw_inactive), max(keyw_at_end), max(keyw_keyword_01), max(keyw_keyword_01_desc),';
      var_sql := var_sql || ' max(keyw_keyword_01_descl), max(keyw_keyword_02),max(keyw_keyword_02_desc), max(keyw_keyword_02_descl),';
      var_sql := var_sql || ' max(keyw_keyword_03),max(keyw_keyword_03_desc), max(keyw_keyword_03_descl), max(keyw_keyword_04),';
      var_sql := var_sql || ' max(keyw_keyword_04_desc), max(keyw_keyword_04_descl), max(keyw_keyword_05),max(keyw_keyword_05_desc),';
      var_sql := var_sql || ' max(keyw_keyword_05_descl), max(keyw_keyword_06),max(keyw_keyword_06_desc), max(keyw_keyword_06_descl),';
      var_sql := var_sql || ' max(keyw_keyword_07),max(keyw_keyword_07_desc), max(keyw_keyword_07_descl), max(keyw_keyword_08),';
      var_sql := var_sql || ' max(keyw_keyword_08_desc), max(keyw_keyword_08_descl), max(keyw_keyword_09),max(keyw_keyword_09_desc),';
      var_sql := var_sql || ' max(keyw_keyword_09_descl), max(keyw_keyword_10),max(keyw_keyword_11), max(keyw_keyword_12), max(keyw_misc1_x),';
      var_sql := var_sql || ' max(keyw_misc2), max(keyw_misc3) from care_tdu_vw';

      if (upper(par_action) != '*ALL') then
         var_sql := var_sql || ' where sell_moe = ''' || par_action || '''';
      end if;

      var_sql := var_sql || ' group by grd_tdu';

      execute immediate var_sql;

      /*-*/
      /* Commit records
      /*-*/
      commit;

      /*-*/
      /* Load Hierachy Data
      /*-*/
      load_hierachies;

      /*-*/
      /* Write Load result to email
      /*-*/
      isi_mailer.append_data('HIERACHY LOAD');
      isi_mailer.append_data('  TOTAL INSERTED : ' || var_bsg_cnt || ' records BSG');
      isi_mailer.append_data('                   ' || var_brf_cnt || ' records BRF');
      isi_mailer.append_data('                   ' || var_bsf_cnt || ' records BSF');
      isi_mailer.append_data('                   ' || var_cpf_cnt || ' records CPF');
      isi_mailer.append_data('                   ' || var_pct_cnt || ' records PCT');
      isi_mailer.append_data('                   ' || var_cpt_cnt || ' records CPT');
      isi_mailer.append_data('                   ' || var_pty_cnt || ' records PTY');
      isi_mailer.append_data('                   ' || var_igv_cnt || ' records IGV');
      isi_mailer.append_data('                   ' || var_sze_cnt || ' records SZE');
      isi_mailer.append_data('                   ' || var_other_cnt || ' records OTHER');
      isi_mailer.append_data('--------------------------------------------');
      /*-*/
      isi_mailer.append_data(insert_msg.count || ' records INSERTED :');
      if (insert_msg.count != 0) then
         isi_mailer.append_data('HIERACHY,TYPE');
         for idx in 1..insert_msg.count loop
            isi_mailer.append_data(insert_msg(idx));
         end loop;
      else
         isi_mailer.append_data(' - No INSERTS performed');
      end if;
      isi_mailer.append_data(null);


      /*-*/
      /* Load TDU Data to KEYWRD as RSU
      /*-*/
      load_tdu_to_rsu;

      /*-*/
      /* Write Load result to email
      /*-*/
      isi_mailer.append_data('GRD TDU to CARE RSU LOAD');
      isi_mailer.append_data('--------------------------------------------');
      /*-*/
      isi_mailer.append_data('CRITICAL ALERTS :');
      if (critical_msg.count != 0) then
         for idx in 1..critical_msg.count loop
            isi_mailer.append_data(critical_msg(idx));
         end loop;
      else
         isi_mailer.append_data(' - No CRITICAL messages raised');
      end if;
      isi_mailer.append_data(null);
      /*-*/
      isi_mailer.append_data('WARNINGS :');
      if (warning_msg.count != 0) then
         for idx in 1..warning_msg.count loop
            isi_mailer.append_data(warning_msg(idx));
         end loop;
      else
         isi_mailer.append_data(' - No WARNINGS raised');
      end if;
      isi_mailer.append_data(null);
      /*-*/
      isi_mailer.append_data(update_msg.count || ' records UPDATED [OLD/NEW] :');
      if (update_msg.count != 0) then
         isi_mailer.append_data('RSU,TDU,KEYW_DESCRIPTION_40,KEYW_DESCRIPTION_74,KEYW_INACTIVE,KEYW_KEYWORD_01,KEYW_KEYWORD_02,KEYW_KEYWORD_03,KEYW_KEYWORD_04,KEYW_KEYWORD_05,KEYW_KEYWORD_06,KEYW_KEYWORD_07,KEYW_KEYWORD_08,KEYW_KEYWORD_09,KEYW_KEYWORD_10,KEYW_KEYWORD_11,KEYW_KEYWORD_12,KEYW_MISC1_X');
         for idx in 1..update_msg.count loop
            isi_mailer.append_data(update_msg(idx));
         end loop;
      else
         isi_mailer.append_data(' - No UPDATES performed');
      end if;
      isi_mailer.append_data(null);
      /*-*/
      isi_mailer.append_data(insert_msg.count || ' records INSERTED :');
      if (insert_msg.count != 0) then
         isi_mailer.append_data('RSU,TDU,KEYW_DESCRIPTION_40,KEYW_DESCRIPTION_74,KEYW_INACTIVE,KEYW_KEYWORD_01,KEYW_KEYWORD_02,KEYW_KEYWORD_03,KEYW_KEYWORD_04,KEYW_KEYWORD_05,KEYW_KEYWORD_06,KEYW_KEYWORD_07,KEYW_KEYWORD_08,KEYW_KEYWORD_09,KEYW_KEYWORD_10,KEYW_KEYWORD_11,KEYW_KEYWORD_12,KEYW_MISC1_X');
         for idx in 1..insert_msg.count loop
            isi_mailer.append_data(insert_msg(idx));
         end loop;
      else
         isi_mailer.append_data(' - No INSERTS performed');
      end if;
      isi_mailer.append_data(null);

      /*-*/
      /* Load Manufacturing Menus
      /*-*/
      load_manu_menu;

      /*-*/
      /* Write Load result to email
      /*-*/
      isi_mailer.append_data('MANUFACTURED LOCATION MENU LOAD');
      isi_mailer.append_data('TOTAL INSERTED : ' || menu_hdr_msg.count || ' HEADERS');
      isi_mailer.append_data('               : ' || menu_det_msg.count || ' DETAILS');
      isi_mailer.append_data('--------------------------------------------');
      /*-*/
      if (menu_hdr_msg.count != 0) then
         isi_mailer.append_data('MENU ID');
         for idx in 1..menu_hdr_msg.count loop
            isi_mailer.append_data(menu_hdr_msg(idx));
         end loop;
      end if;
      isi_mailer.append_data(null);
      if (menu_det_msg.count != 0) then
         isi_mailer.append_data('MENU ID,SEQUENCE,KEYWRD,DESCRIPTION');
         for idx in 1..menu_det_msg.count loop
            isi_mailer.append_data(menu_det_msg(idx));
         end loop;
      end if;
      isi_mailer.append_data(null);


      /*-*/
      /* Finalise Email
      /*-*/
      isi_mailer.append_data('=========================================================================');
      isi_mailer.finalise_email(sil_parameter.email_sender);


      /*-*/
      /* End procedure
      /*-*/
      sil_logging.write_log('End - CARE Data Load');

      /*-*/
      /* Log end
      /*-*/
      sil_logging.end_log;


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
         /* Send Email if created
         /*-*/
         if (isi_mailer.is_created) then
            isi_mailer.append_data('=========================================================================');
            isi_mailer.append_data('** DATA LOAD STOPPED - FATAL ERROR OCCURED ** : ' || substr(SQLERRM, 1, 1024));
            isi_mailer.finalise_email(sil_parameter.email_sender);
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            sil_logging.write_log('**FATAL ERROR** - ' || substr(SQLERRM, 1, 1024));
            sil_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CARE DATA LOAD - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /*******************************************************************/
   /* This procedure performs the update dimension data store routine */
   /*******************************************************************/
   procedure load_tdu_to_rsu is

      /*-*/
      /* Local definitions
      /*-*/
      var_critical boolean;
      var_count number(3,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stage_data is
         select grd_tdu,
                xrf_key,
                keyw_type,
                keyw_description_40,
                keyw_description_74,
                keyw_ask_for_input,
                keyw_apn,
                keyw_replace_key,
                keyw_inactive,
                keyw_at_end,
                keyw_keyword_01,
                keyw_keyword_01_desc,
                keyw_keyword_01_descl,
                keyw_keyword_02,
                keyw_keyword_02_desc,
                keyw_keyword_02_descl,
                keyw_keyword_03,
                keyw_keyword_03_desc,
                keyw_keyword_03_descl,
                keyw_keyword_04,
                keyw_keyword_04_desc,
                keyw_keyword_04_descl,
                keyw_keyword_05,
                keyw_keyword_05_desc,
                keyw_keyword_05_descl,
                keyw_keyword_06,
                keyw_keyword_06_desc,
                keyw_keyword_06_descl,
                keyw_keyword_07,
                keyw_keyword_07_desc,
                keyw_keyword_07_descl,
                keyw_keyword_08,
                keyw_keyword_08_desc,
                keyw_keyword_08_descl,
                keyw_keyword_09,
                keyw_keyword_09_desc,
                keyw_keyword_09_descl,
                keyw_keyword_10,
                keyw_keyword_11,
                keyw_keyword_12,
                keyw_misc1_x,
                keyw_misc2,
                keyw_misc3
         from care_tdu_tmp;
      rec_stage_data csr_stage_data%rowtype;

      cursor csr_chk_xrf(par_key varchar2, par_tdu varchar2) is
         select xrf_rsu,
                xrf_status
         from care_xref
         where xrf_key = par_key
           and xrf_tdu = par_tdu;
      rec_chk_xrf csr_chk_xrf%rowtype;

      cursor csr_chk_key(par_key varchar2) is
         select xrf_rsu
         from care_xref
         where xrf_key = par_key
         group by xrf_rsu;
      rec_chk_key csr_chk_key%rowtype;

      cursor csr_chk_tdu(par_tdu varchar2) is
         select max(xrf_key) as xrf_key,
                max(xrf_rsu) as xrf_rsu
         from care_xref
         where xrf_status = 'A'
           and xrf_tdu = par_tdu
         group by xrf_key,xrf_rsu;
      rec_chk_tdu csr_chk_tdu%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise arrays
      /*-*/
      critical_msg.delete;
      warning_msg.delete;
      update_msg.delete;
      insert_msg.delete;

      /*-*/
      /* Begin procedure
      /*-*/
      sil_logging.write_log('Begin TDU to RSU Data Load');


      /*-*/
      /* Retrieve entire GRD TDU set to be processed
      /*-*/
      open csr_stage_data;
      loop
         fetch csr_stage_data into rec_stage_data;
         if (csr_stage_data%notfound) then
            exit;
         end if;

         var_critical := false;

         sil_logging.write_log('Process Material : ' || rec_stage_data.grd_tdu);

         /*-*/
         /* Check XRF_KEY and GRD_TDU already exist in CARE_XREF
         /*-*/
         open csr_chk_xrf(rec_stage_data.xrf_key, rec_stage_data.grd_tdu);
         fetch csr_chk_xrf into rec_chk_xrf;
         if (csr_chk_xrf%found) then

            /*-*/
            /* Check status and notify if changing
            /*-*/
            open csr_chk_tdu(rec_stage_data.grd_tdu);
            fetch csr_chk_tdu into rec_chk_tdu;
            close csr_chk_tdu;

            if (rec_chk_tdu.xrf_key != rec_stage_data.xrf_key) then

               warning_msg(warning_msg.count + 1) := '  - GRD TDU ' || rec_stage_data.grd_tdu || ' has changed from REP RSU ' || rec_chk_tdu.xrf_rsu || ' to ' || rec_chk_xrf.xrf_rsu;

               /*-*/
               /* UPDATE
               /* notes - set xref entry to ACTIVE status
               /*-*/
               update care_xref
                 set xrf_status = 'A'
                 where xrf_tdu = rec_stage_data.grd_tdu
                   and xrf_key = rec_stage_data.xrf_key;

            end if;

            load_keywrd(rec_stage_data.grd_tdu, rec_chk_xrf.xrf_rsu, rec_stage_data.xrf_key);

         else

            /*-*/
            /* If XRF_KEY/GRD_TDU combination doesn't exist, check if KEY value exists
            /* notes - due to the need for a surrogate code (RSU as sequence)
            /*         it is possible for a unique RSU to be assigned to multiple
            /*         KEYs within CARE_XREF. This is incorrect and should raise a CRTICAL alert
            /*-*/

            /*-*/
            /* Reset Count
            /*-*/
            var_count := 0;

            open csr_chk_key(rec_stage_data.xrf_key);
            loop
               fetch csr_chk_key into rec_chk_key;
               if (csr_chk_key%notfound) then
                  exit;
               end if;

               var_count := var_count+1;

            end loop;
            close csr_chk_key;

            if (var_count > 1) then

               sil_logging.write_log(' ** ERROR ** Multiple non-unique RSU values found against XRF_KEY : ' || rec_stage_data.xrf_key);
               critical_msg(critical_msg.count + 1) := '  - Multiple non-unique RSU values found against XRF_KEY : ' || rec_stage_data.xrf_key;
               var_critical := true;

            else

               if (var_count = 1) then

                  rec_care_xrf.xrf_rsu := rec_chk_key.xrf_rsu;

               else

                  /*-*/
                  /* Get next CARE_XREF sequence
                  /* notes - this sequence is configured to cycle after 999999999
                  /*         due to keywrd_keyword field in CARE being of type CHAR(10)
                  /*-*/
                  select care_xref_seq.nextval
                  into rec_care_xrf.xrf_rsu
                  from dual;

                  /*-*/
                  /* Check status and notify if changing
                  /*-*/
                  open csr_chk_tdu(rec_stage_data.grd_tdu);
                  fetch csr_chk_tdu into rec_chk_tdu;
                  if (csr_chk_tdu%found) then
                     warning_msg(warning_msg.count + 1) := '  - GRD TDU ' || rec_stage_data.grd_tdu || ' has changed from REP RSU ' || rec_chk_tdu.xrf_rsu || ' to ' || rec_care_xrf.xrf_rsu;
                  end if;
                  close csr_chk_tdu;

               end if;

               /*-------------------------*/
               /* INSERT CARE_XREF entry  */
               /*-------------------------*/
               insert into care_xref (xrf_tdu, xrf_rsu, xrf_key,xrf_status)
                  values (rec_stage_data.grd_tdu, rec_care_xrf.xrf_rsu, rec_stage_data.xrf_key,'A');

               load_keywrd(rec_stage_data.grd_tdu, rec_care_xrf.xrf_rsu, rec_stage_data.xrf_key);

            end if;
         end if;
         close csr_chk_xrf;

         if not(var_critical) then
            /*-*/
            /* UPDATE
            /* notes - set all xref entries to INACTIVE
            /*         where GRD_TDU MATCHES
            /*-*/
            update care_xref
              set xrf_status = 'I'
              where xrf_tdu = rec_stage_data.grd_tdu
                and xrf_key != rec_stage_data.xrf_key;
         end if;


         /*-*/
         /* Commit
         /*-*/
         commit;

      end loop;
      close csr_stage_data;


      /*-*/
      /* End procedure
      /*-*/
      sil_logging.write_log('End TDU to RSU Data Load');



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
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CARE DATA LOAD - LOAD_TDU_TO_RSU - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_tdu_to_rsu;

   /*******************************************************************/
   /* This procedure performs the update/insert into CARE keywrd table*/
   /*******************************************************************/
   procedure load_keywrd(par_tdu in varchar2, par_rsu in varchar2, par_key in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;
      var_menu_count number(2,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_rsu is
         select *
         from sfi.keywrd a
         where a.keyw_keyword = rpad(par_rsu,10)
           and a.keyw_type = 'PROD      ';
      rec_rsu csr_rsu%rowtype;

      cursor csr_tdu is
         select *
         from care_tdu_tmp a
         where a.grd_tdu = par_tdu;
      rec_tdu csr_tdu%rowtype;

      cursor csr_rsu_update is
         select
            b.keyw_keyword_01,
            b.keyw_keyword_02,
            b.keyw_keyword_03,
            b.keyw_keyword_04,
            b.keyw_keyword_05,
            b.keyw_keyword_06,
            b.keyw_keyword_07,
            b.keyw_keyword_08,
            b.keyw_keyword_09,
            b.keyw_keyword_11,
            b.keyw_keyword_12
         from care_tdu_tmp b
         where b.grd_tdu = par_tdu
         minus
         select
            trim(a.keyw_keyword_01) as keyw_keyword_01,
            trim(a.keyw_keyword_02) as keyw_keyword_02,
            trim(a.keyw_keyword_03) as keyw_keyword_03,
            trim(a.keyw_keyword_04) as keyw_keyword_04,
            trim(a.keyw_keyword_05) as keyw_keyword_05,
            trim(a.keyw_keyword_06) as keyw_keyword_06,
            trim(a.keyw_keyword_07) as keyw_keyword_07,
            trim(a.keyw_keyword_08) as keyw_keyword_08,
            trim(a.keyw_keyword_09) as keyw_keyword_09,
            a.keyw_keyword_11 as keyw_keyword_11,
            a.keyw_keyword_12 as keyw_keyword_12
         from sfi.keywrd a
         where a.keyw_keyword = rpad(par_rsu,10)
           and a.keyw_type = 'PROD      ';
      rec_rsu_update csr_rsu_update%rowtype;

      cursor csr_chk_status(par_key varchar2) is
         select a.keyw_inactive
         from care_tdu_tmp a
         where a.xrf_key = par_key
         group by a.keyw_inactive;
      rec_chk_status csr_chk_status%rowtype;

      cursor csr_chk_desc(par_key varchar2) is
         select min(a.keyw_description_40) as keyw_description_40
         from care_tdu_tmp a
         where a.xrf_key = par_key
           and length(a.keyw_description_40) = (select min(length(keyw_description_40))
                                                from care_tdu_tmp
                                                where xrf_key = par_key);
      rec_chk_desc csr_chk_desc%rowtype;

      cursor csr_chk_manu_menu(par_tdu varchar2) is
         select c.xrf_src
         from care_xref a,
              grd_mat_det b,
              code_lookup c
         where a.xrf_key = (select xrf_key
                            from care_xref
                            where xrf_tdu = par_tdu
                              and xrf_key = par_key
                              and xrf_status = 'A')
           and a.xrf_tdu = ltrim(b.matnr,'0')
           and b.usagecode = 'MKE'
           and b.orgentity = c.xrf_src
           and c.xrf_type = 'GRD_MOE'
           and a.xrf_status = 'A'
         group by c.xrf_src;
      rec_chk_manu_menu csr_chk_manu_menu%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise Variables
      /*-*/
      var_exists := true;

      /*-*/
      /* Check RSU exists in CARE table
      /*-*/
      open csr_rsu;
      fetch csr_rsu into rec_rsu;
      if (csr_rsu%notfound) then
         var_exists := false;
      end if;
      close csr_rsu;

      /*-*/
      /* Fetch GRD TDU data for load
      /*-*/
      open csr_tdu;
      fetch csr_tdu into rec_tdu;
      close csr_tdu;

      /*-*/
      /* Determine manufacturing sites
      /* notes - if > 1 then refer to Manufacturing Menu (/P)
      /*       - if = 0 then null and raise warning
      /*       - else use manufacturing MOE description
      /*-*/
      var_menu_count := 0;
      open csr_chk_manu_menu(par_tdu);
      loop
         fetch csr_chk_manu_menu into rec_chk_manu_menu;
         if (csr_chk_manu_menu%notfound) then
            exit;
         end if;

         var_menu_count := var_menu_count+1;

      end loop;
      close csr_chk_manu_menu;

      if (var_menu_count > 1) then
         rec_tdu.keyw_misc1_x := '/P' || par_rsu;
      elsif (var_menu_count = 0) then
         rec_tdu.keyw_misc1_x := null;
         warning_msg(warning_msg.count + 1) := '  - No manufacturing site defined for GRD TDU [' || par_tdu || ']';
      else
         rec_tdu.keyw_misc1_x := substr(rec_chk_manu_menu.xrf_src,1,10);
      end if;


      /*-*/
      /* Determine product description
      /* notes - use shortest available
      /*       - initialise as GRD TDU description
      /*-*/
      open csr_chk_desc(rec_tdu.xrf_key);
      fetch csr_chk_desc into rec_chk_desc;
      if (csr_chk_desc%found) then
         rec_tdu.keyw_description_40 := rec_chk_desc.keyw_description_40;
      end if;
      close csr_chk_desc;

      /*-*/
      /* Determine product INACTIVE flag status
      /* notes - initialise as INACTIVE = T
      /*         T = Temporarily Inactive
      /*             (nolonger manufactured, but sold in market)
      /*         Y = Inactive (nolonger manufactured or sold)
      /*         N = Active (manufactured and sold)
      /*-*/
      -- rec_tdu.keyw_inactive := 'T';

      -- open csr_chk_status(rec_tdu.xrf_key);
      -- loop
      --    fetch csr_chk_status into rec_chk_status;
      --    if (csr_chk_status%notfound) then
      --       exit;
      --    end if;

      --    if (rec_chk_status.keyw_inactive = '10' or
      --       rec_chk_status.keyw_inactive = '40') then
      --       rec_tdu.keyw_inactive := 'N';
      --    end if;

      -- end loop;
      -- close csr_chk_status;

      rec_tdu.keyw_inactive := 'N';


      /*-*/
      /* Perform UPDATE/INSERT
      /*-*/
      if (var_exists) then

         /*-------------------------------------------------------------*/
         /* UPDATE keywrd                                               */
         /* - compare GRD data to CARE data, only update if difference  */
         /*-------------------------------------------------------------*/
         open csr_rsu_update;
         fetch csr_rsu_update into rec_rsu_update;
         if (csr_rsu_update%found) or
            (trim(rec_tdu.keyw_inactive) != trim(rec_rsu.keyw_inactive)) or
            (trim(rec_tdu.keyw_misc1_x) != nvl(trim(rec_rsu.keyw_misc1_x),' ')) then

            update sfi.keywrd set
               keyw_description_74 = rec_tdu.keyw_description_74,
               keyw_apn = rec_tdu.keyw_apn,
               keyw_inactive = rec_tdu.keyw_inactive,
               keyw_keyword_01 = rec_tdu.keyw_keyword_01,
               keyw_keyword_02 = rec_tdu.keyw_keyword_02,
               keyw_keyword_03 = rec_tdu.keyw_keyword_03,
               keyw_keyword_04 = rec_tdu.keyw_keyword_04,
               keyw_keyword_05 = rec_tdu.keyw_keyword_05,
               keyw_keyword_06 = rec_tdu.keyw_keyword_06,
               keyw_keyword_07 = rec_tdu.keyw_keyword_07,
               keyw_keyword_08 = rec_tdu.keyw_keyword_08,
               keyw_keyword_09 = rec_tdu.keyw_keyword_09,
               keyw_keyword_10 = par_rsu,
               keyw_keyword_11 = rec_tdu.keyw_keyword_11,
               keyw_keyword_12 = rec_tdu.keyw_keyword_12,
               keyw_misc1_x = rec_tdu.keyw_misc1_x,
               keyw_maint_user = sys_context('USERENV','CURRENT_USER'),
               keyw_maint_date = to_char(sysdate,'YYYYMMDD'),
               keyw_maint_time = to_char(sysdate,'HH24MISS')
            where keyw_keyword = rpad(par_rsu,10,' ')
              and keyw_type = 'PROD      ';

            /*-*/
            /* Commit
            /*-*/
            commit;

            /*-*/
            /* Add Update details to string
            /* note - APN value not important, no need to notify
            /*-*/
            sil_logging.write_log('UPDATE: RSU/TDU : [' || par_rsu || '/' || par_tdu || ']');
            update_msg(update_msg.count + 1) := par_rsu
                                                || ',' || par_tdu
                                                || ',' || nvl(trim(rec_rsu.keyw_description_74),'null') || '/' || nvl(trim(rec_tdu.keyw_description_74),'null')
                                                || ',' || trim(rec_rsu.keyw_inactive) || '/' || trim(rec_tdu.keyw_inactive)
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_01),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_01),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_02),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_02),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_03),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_03),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_04),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_04),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_05),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_05),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_06),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_06),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_07),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_07),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_08),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_08),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_09),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_09),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_11),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_11),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_keyword_12),'null') || '/' || nvl(trim(rec_tdu.keyw_keyword_12),'null')
                                                || ',' || nvl(trim(rec_rsu.keyw_misc1_x),'null') || '/' || nvl(trim(rec_tdu.keyw_misc1_x),'null');


         end if;
         close csr_rsu_update;


      else

         /*------------*/
         /* INSERT     */
         /*------------*/
         insert into sfi.keywrd
                     (keyw_keyword,
                      keyw_type,
                      keyw_description_40,
                      keyw_description_74,
                      keyw_ask_for_input,
                      keyw_apn,
                      keyw_replace_key,
                      keyw_inactive,
                      keyw_at_end,
                      keyw_keyword_01,
                      keyw_keyword_02,
                      keyw_keyword_03,
                      keyw_keyword_04,
                      keyw_keyword_05,
                      keyw_keyword_06,
                      keyw_keyword_07,
                      keyw_keyword_08,
                      keyw_keyword_09,
                      keyw_keyword_10,
                      keyw_keyword_11,
                      keyw_keyword_12,
                      keyw_misc1_x,
                      keyw_misc2,
                      keyw_misc3,
                      keyw_maint_user,
                      keyw_maint_date,
                      keyw_maint_time)
                  values
                     (par_rsu,
                      rec_tdu.keyw_type,
                      rec_tdu.keyw_description_40,
                      rec_tdu.keyw_description_74,
                      rec_tdu.keyw_ask_for_input,
                      rec_tdu.keyw_apn,
                      rec_tdu.keyw_replace_key,
                      rec_tdu.keyw_inactive,
                      rec_tdu.keyw_at_end,
                      rec_tdu.keyw_keyword_01,
                      rec_tdu.keyw_keyword_02,
                      rec_tdu.keyw_keyword_03,
                      rec_tdu.keyw_keyword_04,
                      rec_tdu.keyw_keyword_05,
                      rec_tdu.keyw_keyword_06,
                      rec_tdu.keyw_keyword_07,
                      rec_tdu.keyw_keyword_08,
                      rec_tdu.keyw_keyword_09,
                      par_rsu,
                      rec_tdu.keyw_keyword_11,
                      rec_tdu.keyw_keyword_12,
                      rec_tdu.keyw_misc1_x,
                      rec_tdu.keyw_misc2,
                      rec_tdu.keyw_misc3,
                      sys_context('USERENV','CURRENT_USER'),
                      to_char(sysdate,'YYYYMMDD'),
                      to_char(sysdate,'HH24MISS'));

            /*-*/
            /* Commit
            /*-*/
            commit;

            /*-*/
            /* Add Insert details to string
            /* note - APN value not important, no need to notify
            /*-*/
            sil_logging.write_log('INSERT: RSU/TDU : [' || par_rsu || '/' || par_tdu || ']');
            insert_msg(insert_msg.count + 1) := par_rsu
                                             || ',' || par_tdu
                                             || ',' || nvl(trim(rec_tdu.keyw_description_40),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_description_74),'null')
                                             || ',' || trim(rec_tdu.keyw_inactive)
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_01),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_02),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_03),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_04),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_05),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_06),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_07),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_08),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_09),'null')
                                             || ',' || nvl(trim(par_rsu),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_11),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_keyword_12),'null')
                                             || ',' || nvl(trim(rec_tdu.keyw_misc1_x),'null');

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
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CARE DATA LOAD - LOAD_KEYWRD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_keywrd;

   /*******************************************************************/
   /* This procedure performs the insert of hierachy data into keywrd */
   /*******************************************************************/
   procedure load_hierachies is

      /*-*/
      /* Local definitions
      /*-*/

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_hierachies is
         select keyw_keyword,
                keyw_type
         from care_hierachy_vw
         minus
         select trim(keyw_keyword),
                trim(keyw_type)
         from sfi.keywrd;
      rec_hierachies csr_hierachies%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise arrays
      /*-*/
      insert_msg.delete;

      /*-*/
      /* Initialise count variables
      /*-*/
      var_bsg_cnt := 0;
      var_brf_cnt := 0;
      var_bsf_cnt := 0;
      var_cpf_cnt := 0;
      var_pct_cnt := 0;
      var_cpt_cnt := 0;
      var_pty_cnt := 0;
      var_igv_cnt := 0;
      var_sze_cnt := 0;
      var_other_cnt := 0;

      /*-*/
      /* Begin procedure
      /*-*/
      sil_logging.write_log('Begin Hierachies Data Load');


      /*-*/
      /* Retrieve Hierachies to be inserted
      /*-*/
      open csr_hierachies;
      loop
         fetch csr_hierachies into rec_hierachies;
         if (csr_hierachies%notfound) then
            exit;
         end if;

         insert into sfi.keywrd
            (keyw_keyword,
             keyw_type,
             keyw_ask_for_input,
             keyw_replace_key,
             keyw_inactive,
             keyw_at_end,
             keyw_description_40,
             keyw_description_74,
             keyw_apn,
             keyw_keyword_01,
             keyw_keyword_02,
             keyw_keyword_03,
             keyw_keyword_04,
             keyw_keyword_05,
             keyw_keyword_06,
             keyw_keyword_07,
             keyw_keyword_08,
             keyw_keyword_09,
             keyw_keyword_10,
             keyw_keyword_11,
             keyw_keyword_12,
             keyw_misc1_x,
             keyw_misc2,
             keyw_misc3,
             keyw_maint_user,
             keyw_maint_date,
             keyw_maint_time)
         select keyw_keyword,
                keyw_type,
                keyw_ask_for_input,
                keyw_replace_key,
                keyw_inactive,
                keyw_at_end,
                keyw_description_40,
                keyw_description_74,
                keyw_apn,
                keyw_keyword_01,
                keyw_keyword_02,
                keyw_keyword_03,
                keyw_keyword_04,
                keyw_keyword_05,
                keyw_keyword_06,
                keyw_keyword_07,
                keyw_keyword_08,
                keyw_keyword_09,
                keyw_keyword_10,
                keyw_keyword_11,
                keyw_keyword_12,
                keyw_misc1_x,
                keyw_misc2,
                keyw_misc3,
                sys_context('USERENV','CURRENT_USER'),
                to_char(sysdate,'YYYYMMDD'),
                to_char(sysdate,'HH24MISS')
         from care_hierachy_vw
         where keyw_keyword = rec_hierachies.keyw_keyword
           and keyw_type = rec_hierachies.keyw_type;

         /*-*/
         /* Commit
         /*-*/
         commit;

         /*-*/
         /* Increment Hierachy Insert count
         /* note: key user requires count of each hierachy type
         /*-*/
         case substr(rec_hierachies.keyw_keyword,1,3)
            when 'BSG' then var_bsg_cnt := var_bsg_cnt+1;
            when 'BRF' then var_brf_cnt := var_brf_cnt+1;
            when 'BSF' then var_bsf_cnt := var_bsf_cnt+1;
            when 'CPF' then var_cpf_cnt := var_cpf_cnt+1;
            when 'PCT' then var_pct_cnt := var_pct_cnt+1;
            when 'CPT' then var_cpt_cnt := var_cpt_cnt+1;
            when 'PTY' then var_pty_cnt := var_pty_cnt+1;
            when 'IGV' then var_igv_cnt := var_igv_cnt+1;
            when 'SZE' then var_sze_cnt := var_sze_cnt+1;
            else var_other_cnt := var_other_cnt+1;
         end case;

         /*-*/
         /* Add Insert details to string
         /*-*/
         insert_msg(insert_msg.count + 1) := rec_hierachies.keyw_keyword
                                             || ',' || rec_hierachies.keyw_type;

      end loop;
      close csr_hierachies;


      /*-*/
      /* End procedure
      /*-*/
      sil_logging.write_log('End Hierachies Data Load');



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
         /* Raise an exception to the caller
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_hierachies;


   /*******************************************************************/
   /* This procedure performs the insert of Manufacturing Menu data   */
   /*******************************************************************/
   procedure load_manu_menu is

      /*-*/
      /* Local definitions
      /*-*/
      var_menu_seq  number;


      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_menu_hdr is
         select '/P'||b.xrf_rsu as mhmenuno,
                'PLNT' as mhkwordtyp,
                rpad(chr(32),10,chr(32)) as mhkeyword1,
                rpad(chr(32),10,chr(32)) as mhkeyword2,
                rpad(chr(32),10,chr(32)) as mhkeyword3,
                rpad(chr(32),10,chr(32)) as mhkeyword4,
                rpad(chr(32),10,chr(32)) as mhkeyword5,
                rpad(chr(32),10,chr(32)) as mhkeyword6,
                rpad(chr(32),10,chr(32)) as mhkeyword7,
                rpad(chr(32),10,chr(32)) as mhkeyword8,
                rpad(chr(32),10,chr(32)) as mhkeyword9,
                rpad(chr(32),10,chr(32)) as mhkeyword10,
                rpad(chr(32),10,chr(32)) as mhkeyword11,
                'Please select a valid Plant' as mhdesc,
                null as mhrkeyword
         from grd_mat_det a,
              care_xref b
         where a.usagecode = 'MKE'
           and ltrim(a.matnr,'0') = b.xrf_tdu
           and b.xrf_status = 'A'
         group by b.xrf_rsu
         having count(distinct a.orgentity) > 1
         minus
         select trim(mhmenuno),
                trim(mhkwordtyp),
                mhkeyword1,
                mhkeyword2,
                mhkeyword3,
                mhkeyword4,
                mhkeyword5,
                mhkeyword6,
                mhkeyword7,
                mhkeyword8,
                mhkeyword9,
                mhkeyword10,
                mhkeyword11,
                trim(mhdesc),
                mhrkeyword
         from sfi.msttblh a;
      rec_menu_hdr csr_menu_hdr%rowtype;

      cursor csr_menu_det is
         select '/P'||b.xrf_rsu as mdmenuno,
                'PLNT' as mdmenutyp,
                a.orgentity as mdkeyword,
                c.xrf_trg as mddesc,
                null as mdjumpmenu,
                'Y' as mdendsel,
                'Y' as mdkeepkey,
                'N' as mdinactive
         from grd_mat_det a,
              care_xref b,
              code_lookup c
         where a.usagecode = 'MKE'
           and ltrim(a.matnr,'0') = b.xrf_tdu
           and b.xrf_status = 'A'
           and a.orgentity = c.xrf_src
           and c.xrf_type = 'GRD_MOE'
           and ltrim(a.matnr,'0') in (select grd_tdu from care_tdu_tmp)
         group by b.xrf_rsu,a.orgentity,c.xrf_trg
         having (select count(distinct y.orgentity)
                        from grd_mat_det y,
                             care_xref x
                 where y.usagecode = 'MKE'
                   and ltrim(y.matnr,'0') = x.xrf_tdu
                   and x.xrf_status = 'A'
                   and  x.xrf_rsu = b.xrf_rsu
                 group by x.xrf_rsu) > 1
         minus
         select trim(mdmenuno),
                trim(mdmenutyp),
                trim(mdkeyword),
                trim(mddesc),
                mdjumpmenu,
                trim(mdendsel),
                trim(mdkeepkey),
                trim(mdinactive)
         from sfi.msttbld a;
      rec_menu_det csr_menu_det%rowtype;

      cursor csr_max_sequence(par_rsu varchar2) is
         select nvl(max(a.mdseqno),0)+10 as max_seq
         from sfi.msttbld a
         where a.mdmenuno = rpad(par_rsu,10,' ')
           and a.mdmenutyp = 'PLNT     ';
      rec_max_sequence csr_max_sequence%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise arrays
      /*-*/
      menu_hdr_msg.delete;
      menu_det_msg.delete;

      /*-*/
      /* Begin procedure
      /*-*/
      sil_logging.write_log('Begin Manufacturing Menu Data Load');


      /*-*/
      /* Retrieve Headers to be inserted
      /*-*/
      open csr_menu_hdr;
      loop
         fetch csr_menu_hdr into rec_menu_hdr;
         if (csr_menu_hdr%notfound) then
            exit;
         end if;

         insert into sfi.msttblh
            (mhmenuno,
             mhkwordtyp,
             mhkeyword1,
             mhkeyword2,
             mhkeyword3,
             mhkeyword4,
             mhkeyword5,
             mhkeyword6,
             mhkeyword7,
             mhkeyword8,
             mhkeyword9,
             mhkeyword10,
             mhkeyword11,
             mhdesc,
             mhrkeyword,
             mh_maint_user,
             mh_maint_date,
             mh_maint_time)
         values
            (rec_menu_hdr.mhmenuno,
             rec_menu_hdr.mhkwordtyp,
             rec_menu_hdr.mhkeyword1,
             rec_menu_hdr.mhkeyword2,
             rec_menu_hdr.mhkeyword3,
             rec_menu_hdr.mhkeyword4,
             rec_menu_hdr.mhkeyword5,
             rec_menu_hdr.mhkeyword6,
             rec_menu_hdr.mhkeyword7,
             rec_menu_hdr.mhkeyword8,
             rec_menu_hdr.mhkeyword9,
             rec_menu_hdr.mhkeyword10,
             rec_menu_hdr.mhkeyword11,
             rec_menu_hdr.mhdesc,
             rec_menu_hdr.mhrkeyword,
             sys_context('USERENV','CURRENT_USER'),
             to_char(sysdate,'YYYYMMDD'),
             to_char(sysdate,'HH24MISS'));

         /*-*/
         /* Commit
         /*-*/
         commit;

         /*-*/
         /* Add Insert details to string
         /*-*/
         menu_hdr_msg(menu_hdr_msg.count + 1) := rec_menu_hdr.mhmenuno;

      end loop;
      close csr_menu_hdr;

      /*-*/
      /* Retrieve Details to be inserted
      /*-*/
      open csr_menu_det;
      loop
         fetch csr_menu_det into rec_menu_det;
         if (csr_menu_det%notfound) then
            exit;
         end if;

         /*-*/
         /* Get Max Menu Sequence
         /*-*/
         open csr_max_sequence(rec_menu_det.mdmenuno);
         fetch csr_max_sequence into rec_max_sequence;
         close csr_max_sequence;

         var_menu_seq := rec_max_sequence.max_seq;


         insert into sfi.msttbld
            (mdmenuno,
             mdmenutyp,
             mdseqno,
             mdkeyword,
             mddesc,
             mdjumpmenu,
             mdendsel,
             mdkeepkey,
             mdinactive,
             md_maint_user,
             md_maint_date,
             md_maint_time)
         values
            (rec_menu_det.mdmenuno,
             rec_menu_det.mdmenutyp,
             var_menu_seq,
             rec_menu_det.mdkeyword,
             rec_menu_det.mddesc,
             rec_menu_det.mdjumpmenu,
             rec_menu_det.mdendsel,
             rec_menu_det.mdkeepkey,
             rec_menu_det.mdinactive,
             sys_context('USERENV','CURRENT_USER'),
             to_char(sysdate,'YYYYMMDD'),
             to_char(sysdate,'HH24MISS'));

         /*-*/
         /* Commit
         /*-*/
         commit;

         /*-*/
         /* Add Insert details to string
         /*-*/
         menu_det_msg(menu_det_msg.count + 1) := rec_menu_det.mdmenuno
                                             || ',' || var_menu_seq
                                             || ',' || rec_menu_det.mdkeyword
                                             || ',' || rec_menu_det.mddesc;

      end loop;
      close csr_menu_det;


      /*-*/
      /* End procedure
      /*-*/
      sil_logging.write_log('End Manufacturing Menu Data Load');



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
         /* Raise an exception to the caller
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_manu_menu;

end care_data_load;
/


DROP PUBLIC SYNONYM CARE_DATA_LOAD;

CREATE PUBLIC SYNONYM CARE_DATA_LOAD FOR CR_APP.CARE_DATA_LOAD;


