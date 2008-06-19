DROP PACKAGE CR_APP.CARE_SALES_LOAD;

CREATE OR REPLACE PACKAGE CR_APP.care_sales_load as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CARE
 Package : care_sales_load
 Owner   : CR_APP
 Author  : Ann-Marie Ingeme

 Description
 -----------
 CARE Sales data load (Staging Tables to CARE application table)

 NOTES :

   1. Primary key on CARE table keyprd is of type CHAR(10). This means that values
      stored there are right padded to the full length (an attribute of type CHAR).

 YYYY/MM   Author               Description
 -------   ------               -----------
 2005/12   Ann-Marie Ingeme     Created
 2006/01   Linden Glen          Completed
 2006/02   Linden Glen          ADD: check_grd_tdu function/processing
 2006/06   Linden Glen          MOD: Remove check for null EAN11 code
 2006/06   Linden Glen          MOD: kepr_plant default from 'PLANT' to ' '
 2006/08   Linden Glen          MOD: use MATL_CODE_TYPE to determine if LEGACY code
                                     check processing is necessary.
 2006/09   Linden Glen          MOD: When checking legacy to GRD code, use 'FERT' only
 2006/12   Steve Ostler         MOD: Added extra filter (kepr_plant='SALE      ') to all update
                                     statements to fix issue with updates overwriting AVG13 records.
 2007/03   Steve Gregan         ADD: SOURCE_TYPE and SALES_TAR processing
 2007/05   Steve Gregan         MOD: Fixed KEYPRD reset to zero logic
 2007/06   Steve Gregan         MOD: Removed KEYPRD reset to zero logic for MARKET (corrupts MFANZ)

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_src_type in varchar2, par_src_code in varchar2, par_yyyypp in varchar2);

end care_sales_load;
/


DROP PACKAGE BODY CR_APP.CARE_SALES_LOAD;

CREATE OR REPLACE PACKAGE BODY CR_APP.care_sales_load as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Local constants
   /*-*/
   con_function constant varchar2(128) := 'CARE Sales Load';

   /*-*/
   /* Private declarations
   /*-*/
   procedure load_keyprd(par_xrf_type in varchar2, par_src_code in varchar2, par_yyyypp in varchar2);
   function check_grd_tdu(par_matl_code in varchar2, par_src_code in varchar2) return varchar2;

   /*-*/
   /* Define Variables
   /*-*/
   var_log_prefix varchar2(256);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_src_type in varchar2, par_src_code in varchar2, par_yyyypp in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_xrf_type varchar2(32 char);

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_mars_date is
         select 'x'
         from mars_date a
         where a.mars_period = par_yyyypp;
      rec_mars_date csr_mars_date%rowtype;

      cursor csr_src_code is
         select a.xrf_trg
         from code_lookup a
         where a.xrf_src = par_src_code
           and a.xrf_type = var_xrf_type;
      rec_src_code csr_src_code%rowtype;

      cursor csr_src_code_all is
         select a.xrf_trg,
                a.xrf_src
         from code_lookup a
         where a.xrf_type = var_xrf_type;
      rec_src_code_all csr_src_code_all%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_log_prefix := 'CARE - SALES LOAD';
      var_xrf_type := 'SRC_CODE';
      if par_src_type = 'FCT' then
         var_xrf_type := 'FCT_CODE';
      end if;

      /*-*/
      /* Log start
      /*-*/
      sil_logging.start_log(var_log_prefix, con_function);

      /*-*/
      /* Begin procedure
      /*-*/
      sil_logging.write_log('Begin - CARE Sales Load');
      sil_logging.write_log('Executing CARE_SALES_LOAD (' || nvl(par_src_type,'NULL') || ', ' || par_src_code || ', ' || par_yyyypp || ')');

      /*-*/
      /* Create Email Interface
      /*-*/
      isi_mailer.create_email(sil_parameter.email_sales_load,
                              'AP CARE SALES LOAD RESULTS FOR PERIOD '|| nvl(par_yyyypp,'<N/A>'),
                              null,
                              null);

      /*-*/
      /* Write Email Header
      /*-*/
      isi_mailer.append_data('AP CARE SALES LOAD - Executed at : ' || to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'));
      isi_mailer.append_data('================================================================================================');
      isi_mailer.append_data(null);

      /*-*/
      /* Validate parameters
      /*-*/
      if not(par_src_type is null) and par_src_type != 'FCT' then
         isi_mailer.append_data('ERROR: Source Type parameter must be NULL or FCT');
         sil_logging.write_log('ERROR: Source Type parameter must be NULL or FCT');
         raise_application_error(-20000, 'Source Type parameter must be NULL or FCT');
      end if;
      /*-*/
      if par_src_code is null then
         isi_mailer.append_data('ERROR: Source Code parameter must be a valid source code or *ALL');
         sil_logging.write_log('ERROR: Source Code parameter must be a valid source code or *ALL');
         raise_application_error(-20000, 'Source Code parameter must be a valid source code or *ALL');
      end if;
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rec_mars_date;
      if csr_mars_date%notfound then
         isi_mailer.append_data('ERROR: Mars Period parameter [' || par_yyyypp || '] not found in MARS_DATE - Required Format : YYYYPP');
         sil_logging.write_log('ERROR: Mars Period parameter [' || par_yyyypp || '] not found in MARS_DATE - Required Format : YYYYPP');
         raise_application_error(-20000, 'Mars Period parameter [' || par_yyyypp || '] not found in MARS_DATE - Required Format : YYYYPP');
      end if;
      close csr_mars_date;

      /*-*/
      /* Process data
      /*-*/
      if upper(par_src_code) = '*ALL' then

         open csr_src_code_all;
         loop
            fetch csr_src_code_all into rec_src_code_all;
            if (csr_src_code_all%notfound) then
               exit;
            end if;

            /*-*/
            /* Execute Load for Source Code
            /*-*/
            load_keyprd(var_xrf_type,rec_src_code_all.xrf_src,par_yyyypp);

         end loop;
         close csr_src_code_all;

      else

         /*-*/
         /* Validate Source Code
         /*-*/
         open csr_src_code;
         fetch csr_src_code into rec_src_code;
         if csr_src_code%notfound then
            isi_mailer.append_data('ERROR: Source Code parameter [' || par_src_code || '] not valid.');
            sil_logging.write_log('ERROR: Source Code parameter [' || par_src_code || '] not valid.');
            raise_application_error(-20000, 'Source Code parameter [' || par_src_code || '] not valid.');
         end if;
         close csr_src_code;

         /*-*/
         /* Execute Load for Source Code
         /*-*/
         load_keyprd(var_xrf_type,par_src_code,par_yyyypp);

      end if;

      /*-*/
      /* Finalise Email
      /*-*/
      isi_mailer.append_data(null);
      isi_mailer.append_data(null);
      isi_mailer.append_data('AP CARE SALES LOAD - Completed at : ' || to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'));
      isi_mailer.append_data('================================================================================================');
      isi_mailer.finalise_email(sil_parameter.email_sender);

      /*-*/
      /* End procedure
      /*-*/
      sil_logging.write_log('End - CARE Sales Load');

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
            isi_mailer.append_data('** SALES LOAD STOPPED - FATAL ERROR OCCURED ** : ' || substr(SQLERRM, 1, 1024));
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
         raise_application_error(-20000, 'FATAL ERROR - CARE SALES LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /********************************************************************/
   /* This procedure performs the update/insert into CARE keyprd table */
   /********************************************************************/
   procedure load_keyprd(par_xrf_type in varchar2, par_src_code in varchar2, par_yyyypp in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_regn_code varchar2(32 char);
      var_tar_code varchar2(32 char);
      var_src_desc varchar2(64 char);
      var_kepr_type char(10);
      var_kepr_sub_type char(10);
      var_kepr_category char(10);
      var_kepr_plant char(10);
      var_reason varchar2(4000);
      var_missing boolean;
      var_update_cnt number;
      var_insert_cnt number;
      rec_sales_data_hdr sales_data_hdr%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales_data_hdr01 is
         select *
         from sales_data_hdr
         where sales_src = par_src_code
           and sales_period = par_yyyypp;
      rec_sales_data_hdr01 csr_sales_data_hdr01%rowtype;

      cursor csr_sales_data_det is
         select count(*) as det_count
         from sales_data_det
         where sales_src = par_src_code
           and sales_period = par_yyyypp;
      rec_sales_data_det csr_sales_data_det%rowtype;

      cursor csr_regn_type_code is
         select a.xrf_trg
         from code_lookup a
         where a.xrf_type = 'REG_CODE'
           and a.xrf_src = par_src_code;
      rec_regn_type_code csr_regn_type_code%rowtype;

       cursor csr_chk_grd_xrf is
         select a.matl_code
         from sales_data_det a
         where a.sales_src = par_src_code
           and a.sales_period = par_yyyypp
         minus
         select ltrim(b.legacy_code,'0') as matl_code
         from grd_mat_hdr a,
              grd_mat_lcm b
         where a.matnr = b.matnr
           and a.mtart = 'FERT'
           and ltrim(b.regcode,0) = ltrim(var_regn_code,0);
      rec_chk_grd_xrf csr_chk_grd_xrf%rowtype;

      cursor csr_chk_care_xrf is
         select ltrim(c.matnr,'0') as matl_code
         from sales_data_det a,
              grd_mat_hdr b,
              grd_mat_lcm c
         where a.matl_code = ltrim(c.legacy_code,0)
           and b.matnr = c.matnr
           and b.mtart = 'FERT'
           and a.sales_period = par_yyyypp
           and a.sales_src = par_src_code
           and ltrim(c.regcode,0) = ltrim(var_regn_code,0)
         minus
         select a.xrf_tdu as matl_code
         from care_xref a
         where a.xrf_status = 'A';
      rec_chk_care_xrf csr_chk_care_xrf%rowtype;

      cursor csr_chk_care_xrf_grd is
         select ltrim(a.matl_code,'0') as matl_code
         from sales_data_det a
         where a.sales_period = par_yyyypp
           and a.sales_src = par_src_code
         minus
         select a.xrf_tdu as matl_code
         from care_xref a
         where a.xrf_status = 'A';
      rec_chk_care_xrf_grd csr_chk_care_xrf_grd%rowtype;

      cursor csr_src_desc is
         select a.xrf_trg
         from code_lookup a
         where a.xrf_type = par_xrf_type
           and a.xrf_src = par_src_code;
      rec_src_desc csr_src_desc%rowtype;

      cursor csr_tar_desc is
         select a.xrf_trg
         from code_lookup a
         where a.xrf_type = 'SLD_CODE'
           and a.xrf_src = var_tar_code;
      rec_tar_desc csr_tar_desc%rowtype;

      cursor csr_keyprd_load is
         select a.sales_tar as sales_tar,
                rpad(c.xrf_rsu,10) as xrf_rsu,
                substr(sales_period,1,4) as sales_year,
                substr(sales_period,5,2) as sales_period,
                round(sum(a.case_qty*a.pcs_per_case)) as prod_cnt
         from sales_data_det a,
              grd_mat_hdr d,
              grd_mat_lcm b,
              care_xref c
         where a.matl_code = ltrim(b.legacy_code,0)
           and a.sales_period = par_yyyypp
           and d.matnr = b.matnr
           and d.mtart = 'FERT'
           and ltrim(b.regcode,0) = ltrim(var_regn_code,0)
           and ltrim(b.matnr,0) = c.xrf_tdu
           and c.xrf_status = 'A'
           and a.sales_src = par_src_code
         group by a.sales_tar,c.xrf_rsu,a.sales_period;
      rec_keyprd_load csr_keyprd_load%rowtype;

      cursor csr_keyprd_load_grd is
         select a.sales_tar as sales_tar,
                rpad(c.xrf_rsu,10) as xrf_rsu,
                substr(a.sales_period,1,4) as sales_year,
                substr(a.sales_period,5,2) as sales_period,
                round(sum(a.case_qty*a.pcs_per_case)) as prod_cnt
         from sales_data_det a,
              care_xref c
         where a.sales_period = par_yyyypp
           and ltrim(a.matl_code,0) = c.xrf_tdu
           and c.xrf_status = 'A'
           and a.sales_src = par_src_code
         group by a.sales_tar,c.xrf_rsu,a.sales_period;
      rec_keyprd_load_grd csr_keyprd_load_grd%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Start the log
      /*-*/
      sil_logging.write_log('Begin LOAD_KEYPRD (' || par_xrf_type || ', ' || par_src_code || ', ' || par_yyyypp || ')');

      /*-*/
      /* Retrieve source description
      /*-*/
      open csr_src_desc;
      fetch csr_src_desc into rec_src_desc;
      if csr_src_desc%notfound then
         raise_application_error(-20000, 'Source Code parameter [' || par_xrf_type || ', ' || par_src_code || '] not valid.');
      end if;
      close csr_src_desc;
      var_src_desc := rec_src_desc.xrf_trg;

      /*-*/
      /* Write Email Sub-Header
      /*-*/
      isi_mailer.append_data('*---------------------------------------------------------');
      isi_mailer.append_data('| SALES LOAD FOR ' || var_src_desc || ' (' || par_xrf_type || ', ' || par_src_code || '), PERIOD ' || par_yyyypp);

      /*-*/
      /* Initialise Variables
      /*-*/
      var_missing := false;
      var_update_cnt := 0;
      var_insert_cnt := 0;

      /*-*/
      /* Validate Sales Data
      /*   1. Data exists for Source Code and YYYYPP
      /*   2. Header count value = Detail record count
      /*   3. Region Type code is defined
      /*   4. Material codes have :
      /*      a) valid legacy cross reference in GRD_MAT_LCM
      /*          NOTE : only required when matl_code_type != 'GRD'
      /*      b) REP RSU cross reference in CARE_XREF
      /*-*/
      open csr_sales_data_hdr01;
      fetch csr_sales_data_hdr01 into rec_sales_data_hdr01;
      if (csr_sales_data_hdr01%notfound) then
         isi_mailer.append_data('|  - ERROR: Sales data for Source Code ['|| par_src_code || '] and Mars Period [' || par_yyyypp || '] doesn''t exist.');
         isi_mailer.append_data('*---------------------------------------------------------');
         sil_logging.write_log('ERROR: Sales data for Source Code ['|| par_src_code || '] and Mars Period [' || par_yyyypp || '] doesn''t exist.');
         return;
      end if;
      rec_sales_data_hdr.sales_det_cnt := rec_sales_data_hdr01.sales_det_cnt;
      close csr_sales_data_hdr01;

      /*-*/

      open csr_sales_data_det;
      fetch csr_sales_data_det into rec_sales_data_det;
      if (rec_sales_data_det.det_count != rec_sales_data_hdr.sales_det_cnt) then
         isi_mailer.append_data('|  - ERROR: Sales Header checksum doesn''t match detail record count - Header [' || rec_sales_data_hdr.sales_det_cnt || '], Detail [' || rec_sales_data_det.det_count || ']');
         isi_mailer.append_data('*---------------------------------------------------------');
         sil_logging.write_log('ERROR: Sales Header checksum doesn''t match detail record count - Header [' || rec_sales_data_hdr.sales_det_cnt || '], Detail [' || rec_sales_data_det.det_count || ']');
         return;
      end if;
      close csr_sales_data_det;

      /*-*/

      open csr_regn_type_code;
      fetch csr_regn_type_code into rec_regn_type_code;
      if (csr_regn_type_code%notfound) then
         isi_mailer.append_data('|  - ERROR: Region Type Code not defined for Source Code [' || par_src_code || ']');
         isi_mailer.append_data('*---------------------------------------------------------');
         sil_logging.write_log('ERROR: Region Type Code not defined for Source Code [' || par_src_code || ']');
         return;
      end if;
      var_regn_code := rec_regn_type_code.xrf_trg;
      close csr_regn_type_code;

      /*-*/

      if (rec_sales_data_hdr01.matl_code_type != 'GRD' or
          rec_sales_data_hdr01.matl_code_type is null) then

         open csr_chk_grd_xrf;
         loop
            fetch csr_chk_grd_xrf into rec_chk_grd_xrf;
            if (csr_chk_grd_xrf%notfound) then
               exit;
            end if;

            var_missing := true;

            isi_mailer.append_data('|  - ERROR: GRD XREF not found for material code ' ||rec_chk_grd_xrf.matl_code || ' in GRD_MAT_LCM table');
            sil_logging.write_log('GRD XREF not found for material code ' ||rec_chk_grd_xrf.matl_code || ' in GRD_MAT_LCM table');

         end loop;
         close csr_chk_grd_xrf;

         if (var_missing) then
            sil_logging.write_log('One or more material codes are missing a GRD cross reference in GRD_MAT_LCM');
            isi_mailer.append_data('|  - ERROR: One or more material codes are missing a GRD cross reference in GRD_MAT_LCM');
            isi_mailer.append_data('*---------------------------------------------------------');
            return;
         end if;

      end if;

      /*-*/

      if (rec_sales_data_hdr01.matl_code_type != 'GRD' or
          rec_sales_data_hdr01.matl_code_type is null) then

         open csr_chk_care_xrf;
         loop
            fetch csr_chk_care_xrf into rec_chk_care_xrf;
            if (csr_chk_care_xrf%notfound) then
               exit;
            end if;

            var_missing := true;

            isi_mailer.append_data('|  - ERROR: CARE XREF not found for material code ' ||rec_chk_care_xrf.matl_code || ' in CARE_XREF table');
            sil_logging.write_log('CARE XREF not found for material code ' ||rec_chk_care_xrf.matl_code || ' in CARE_XREF table');

            /*-*/
            /* Check reason for MATL not existing in CARE_XREF
            /*-*/
            var_reason := check_grd_tdu(rec_chk_care_xrf.matl_code, par_src_code);

            isi_mailer.append_data(var_reason);
            sil_logging.write_log(var_reason);

         end loop;
         close csr_chk_care_xrf;

         if (var_missing) then
            sil_logging.write_log('One or more material codes are missing a CARE cross reference in CARE_XREF');
            isi_mailer.append_data('|  - ERROR: One or more material codes are missing a CARE cross reference in CARE_XREF');
            isi_mailer.append_data('*---------------------------------------------------------');
            return;
         end if;

         /*-*/
         /* Set the type, sub type and category values
         /*-*/
         var_kepr_type := 'PROD      ';
         var_kepr_plant := 'SALE      ';
         if par_xrf_type = 'SRC_CODE' then
            var_kepr_sub_type := 'MARKET    ';
            var_kepr_category := rpad(var_src_desc,10,' ');
         else
            var_kepr_sub_type := rpad(var_src_desc,10,' ');
            var_kepr_category := null;
         end if;

         /*-*/
         /* Update all sales for receiving Year/Period/Market to 0
         /* This will allow for "deletion" of sales lines not received on a subsequent send
         /*-*/
         --if par_xrf_type = 'SRC_CODE' then
         --   execute immediate 'update sfi.keyprd set'
         --                     || ' kepr_period' || substr(rec_sales_data_hdr01.sales_period,5,2) || '_production_cnt = 0,'
         --                     || ' kepr_maint_user = ''' || sys_context('USERENV','CURRENT_USER') || ''','
         --                     || ' kepr_maint_date = ' || to_char(sysdate,'YYYYMMDD') || ','
         --                     || ' kepr_maint_time = ' || to_char(sysdate,'HH24MISS')
         --                     || ' where kepr_type = ''' || var_kepr_type || ''''
         --                     || '   and kepr_plant = ''' || var_kepr_plant || ''''
         --                     || '   and kepr_sub_type = ''' || var_kepr_sub_type || ''''
         --                     || '   and kepr_category = ''' || var_kepr_category || ''''
         --                     || '   and kepr_production_year = ''' || rpad(substr(par_yyyypp,1,4),10,' ') || '''';
         --else
         if par_xrf_type = 'FCT_CODE' then
            execute immediate 'update sfi.keyprd set'
                              || ' kepr_period' || substr(rec_sales_data_hdr01.sales_period,5,2) || '_production_cnt = 0,'
                              || ' kepr_maint_user = ''' || sys_context('USERENV','CURRENT_USER') || ''','
                              || ' kepr_maint_date = ' || to_char(sysdate,'YYYYMMDD') || ','
                              || ' kepr_maint_time = ' || to_char(sysdate,'HH24MISS')
                              || ' where kepr_type = ''' || var_kepr_type || ''''
                              || '   and kepr_plant = ''' || var_kepr_plant || ''''
                              || '   and kepr_sub_type = ''' || var_kepr_sub_type || ''''
                              || '   and kepr_production_year = ''' || rpad(substr(par_yyyypp,1,4),10,' ') || '''';
         end if;

         /*--------------------------------------------------------------*/
         /* UPDATE keyprd                                                */
         /* - if record NOTFOUND then insert a new record into the table */
         /*--------------------------------------------------------------*/
         open csr_keyprd_load;
         loop
            fetch csr_keyprd_load into rec_keyprd_load;
            if (csr_keyprd_load%notfound) then
               exit;
            end if;

            /*-*/
            /* Retrieve target description when required
            /*-*/
            if par_xrf_type = 'FCT_CODE' then
               var_tar_code := rec_keyprd_load.sales_tar;
               open csr_tar_desc;
               fetch csr_tar_desc into rec_tar_desc;
               if csr_tar_desc%notfound then
                  raise_application_error(-20000, 'Sold To Code parameter [SLD_CODE, ' || var_tar_code || '] not valid.');
               end if;
               close csr_tar_desc;
               var_kepr_category := rpad(rec_tar_desc.xrf_trg,10,' ');
            end if;

            /*-*/
            /* Update the database
            /*-*/
            execute immediate 'update sfi.keyprd set'
                              || ' kepr_period' || rec_keyprd_load.sales_period || '_production_cnt = ''' || rec_keyprd_load.prod_cnt || ''','
                              || ' kepr_maint_user = ''' || sys_context('USERENV','CURRENT_USER') || ''','
                              || ' kepr_maint_date = ' || to_char(sysdate,'YYYYMMDD') || ','
                              || ' kepr_maint_time = ' || to_char(sysdate,'HH24MISS')
                              || ' where kepr_keyword = ''' || rpad(rec_keyprd_load.xrf_rsu,10,' ') || ''''
                              || '   and kepr_type = ''' || var_kepr_type || ''''
                              || '   and kepr_plant = ''' || var_kepr_plant || ''''
                              || '   and kepr_sub_type = ''' || var_kepr_sub_type || ''''
                              || '   and kepr_category = ''' || var_kepr_category || ''''
                              || '   and kepr_production_year = ''' || rpad(rec_keyprd_load.sales_year,10,' ') || '''';
            if (sql%notfound) then
               execute immediate 'insert into sfi.keyprd'
                                 || ' (kepr_keyword,'
                                 || ' kepr_type,'
                                 || ' kepr_sub_type,'
                                 || ' kepr_category,'
                                 || ' kepr_production_year,'
                                 || ' kepr_plant,'
                                 || ' kepr_filler,'
                                 || ' kepr_lag_time,'
                                 || ' kepr_units,'
                                 || ' kepr_period' || rec_keyprd_load.sales_period || '_production_cnt,'
                                 || ' kepr_maint_user,'
                                 || ' kepr_maint_date,'
                                 || ' kepr_maint_time)'
                                 || ' values '
                                 ||  '(''' || rec_keyprd_load.xrf_rsu || ''','
                                 ||  '''' || rtrim(var_kepr_type) || ''','
                                 ||  '''' || rtrim(var_kepr_sub_type) || ''','
                                 ||  '''' || rtrim(var_kepr_category) || ''','
                                 ||  '''' || rec_keyprd_load.sales_year || ''','
                                 ||  '''' || rtrim(var_kepr_plant) || ''','
                                 ||  'null,'
                                 ||  'null,'
                                 ||  '''1'','
                                 ||  '''' || rec_keyprd_load.prod_cnt || ''','
                                 ||  '''' || sys_context('USERENV','CURRENT_USER') || ''','
                                 ||  '''' || to_char(sysdate,'YYYYMMDD') || ''','
                                 ||  '''' || to_char(sysdate,'HH24MISS') || ''')';
               var_insert_cnt := var_insert_cnt+1;
            else
               var_update_cnt := var_update_cnt+1;
            end if;

         end loop;
         close csr_keyprd_load;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      else

         open csr_chk_care_xrf_grd;
         loop
            fetch csr_chk_care_xrf_grd into rec_chk_care_xrf_grd;
            if (csr_chk_care_xrf_grd%notfound) then
               exit;
            end if;

            var_missing := true;

            isi_mailer.append_data('|  - ERROR: CARE XREF not found for material code ' ||rec_chk_care_xrf_grd.matl_code || ' in CARE_XREF table');
            sil_logging.write_log('CARE XREF not found for material code ' ||rec_chk_care_xrf_grd.matl_code || ' in CARE_XREF table');

            /*-*/
            /* Check reason for MATL not existing in CARE_XREF
            /*-*/
            var_reason := check_grd_tdu(rec_chk_care_xrf_grd.matl_code, par_src_code);

            isi_mailer.append_data(var_reason);
            sil_logging.write_log(var_reason);

         end loop;
         close csr_chk_care_xrf_grd;

         if (var_missing) then
            sil_logging.write_log('One or more material codes are missing a CARE cross reference in CARE_XREF');
            isi_mailer.append_data('|  - ERROR: One or more material codes are missing a CARE cross reference in CARE_XREF');
            isi_mailer.append_data('*---------------------------------------------------------');
            return;
         end if;

         /*-*/
         /* Set the type, sub type and category values
         /*-*/
         var_kepr_type := 'PROD      ';
         var_kepr_plant := 'SALE      ';
         if par_xrf_type = 'SRC_CODE' then
            var_kepr_sub_type := 'MARKET    ';
            var_kepr_category := rpad(var_src_desc,10,' ');
         else
            var_kepr_sub_type := rpad(var_src_desc,10,' ');
            var_kepr_category := null;
         end if;

         /*-*/
         /* Update all sales for receiving Year/Period/Market to 0
         /* This will allow for "deletion" of sales lines not received on a subsequent send
         /*-*/
         --if par_xrf_type = 'SRC_CODE' then
         --   execute immediate 'update sfi.keyprd set'
         --                     || ' kepr_period' || substr(rec_sales_data_hdr01.sales_period,5,2) || '_production_cnt = 0,'
         --                     || ' kepr_maint_user = ''' || sys_context('USERENV','CURRENT_USER') || ''','
         --                     || ' kepr_maint_date = ' || to_char(sysdate,'YYYYMMDD') || ','
         --                     || ' kepr_maint_time = ' || to_char(sysdate,'HH24MISS')
         --                     || ' where kepr_type = ''' || var_kepr_type || ''''
         --                     || '   and kepr_plant = ''' || var_kepr_plant || ''''
         --                     || '   and kepr_sub_type = ''' || var_kepr_sub_type || ''''
         --                     || '   and kepr_category = ''' || var_kepr_category || ''''
         --                     || '   and kepr_production_year = ''' || rpad(substr(par_yyyypp,1,4),10,' ') || '''';
         --else
         if par_xrf_type = 'FCT_CODE' then
            execute immediate 'update sfi.keyprd set'
                              || ' kepr_period' || substr(rec_sales_data_hdr01.sales_period,5,2) || '_production_cnt = 0,'
                              || ' kepr_maint_user = ''' || sys_context('USERENV','CURRENT_USER') || ''','
                              || ' kepr_maint_date = ' || to_char(sysdate,'YYYYMMDD') || ','
                              || ' kepr_maint_time = ' || to_char(sysdate,'HH24MISS')
                              || ' where kepr_type = ''' || var_kepr_type || ''''
                              || '   and kepr_plant = ''' || var_kepr_plant || ''''
                              || '   and kepr_sub_type = ''' || var_kepr_sub_type || ''''
                              || '   and kepr_production_year = ''' || rpad(substr(par_yyyypp,1,4),10,' ') || '''';
         end if;

         /*--------------------------------------------------------------*/
         /* UPDATE keyprd                                                */
         /* - if record NOTFOUND then insert a new record into the table */
         /*--------------------------------------------------------------*/
         open csr_keyprd_load_grd;
         loop
            fetch csr_keyprd_load_grd into rec_keyprd_load_grd;
            if (csr_keyprd_load_grd%notfound) then
               exit;
            end if;

            /*-*/
            /* Retrieve target description when required
            /*-*/
            if par_xrf_type = 'FCT_CODE' then
               var_tar_code := rec_keyprd_load_grd.sales_tar;
               open csr_tar_desc;
               fetch csr_tar_desc into rec_tar_desc;
               if csr_tar_desc%notfound then
                  raise_application_error(-20000, 'Sold To Code parameter [SLD_CODE, ' || var_tar_code || '] not valid.');
               end if;
               close csr_tar_desc;
               var_kepr_category := rpad(rec_tar_desc.xrf_trg,10,' ');
            end if;

            /*-*/
            /* Update the database
            /*-*/
            execute immediate 'update sfi.keyprd set'
                              || ' kepr_period' || rec_keyprd_load_grd.sales_period || '_production_cnt = ''' || rec_keyprd_load_grd.prod_cnt || ''','
                              || ' kepr_maint_user = ''' || sys_context('USERENV','CURRENT_USER') || ''','
                              || ' kepr_maint_date = ' || to_char(sysdate,'YYYYMMDD') || ','
                              || ' kepr_maint_time = ' || to_char(sysdate,'HH24MISS')
                              || ' where kepr_keyword = ''' || rpad(rec_keyprd_load_grd.xrf_rsu,10,' ') || ''''
                              || '   and kepr_type = ''' || var_kepr_type || ''''
                              || '   and kepr_plant = ''' || var_kepr_plant || ''''
                              || '   and kepr_sub_type = ''' || var_kepr_sub_type || ''''
                              || '   and kepr_category = ''' || var_kepr_category || ''''
                              || '   and kepr_production_year = ''' || rpad(rec_keyprd_load_grd.sales_year,10,' ') || '''';
            if (sql%notfound) then
               execute immediate 'insert into sfi.keyprd'
                                 || ' (kepr_keyword,'
                                 || ' kepr_type,'
                                 || ' kepr_sub_type,'
                                 || ' kepr_category,'
                                 || ' kepr_production_year,'
                                 || ' kepr_plant,'
                                 || ' kepr_filler,'
                                 || ' kepr_lag_time,'
                                 || ' kepr_units,'
                                 || ' kepr_period' || rec_keyprd_load_grd.sales_period || '_production_cnt,'
                                 || ' kepr_maint_user,'
                                 || ' kepr_maint_date,'
                                 || ' kepr_maint_time)'
                                 || ' values '
                                 ||  '(''' || rec_keyprd_load_grd.xrf_rsu || ''','
                                 ||  '''' || rtrim(var_kepr_type) || ''','
                                 ||  '''' || rtrim(var_kepr_sub_type) || ''','
                                 ||  '''' || rtrim(var_kepr_category) || ''','
                                 ||  '''' || rec_keyprd_load_grd.sales_year || ''','
                                 ||  '''' || rtrim(var_kepr_plant) || ''','
                                 ||  'null,'
                                 ||  'null,'
                                 ||  '''1'','
                                 ||  '''' || rec_keyprd_load_grd.prod_cnt || ''','
                                 ||  '''' || sys_context('USERENV','CURRENT_USER') || ''','
                                 ||  '''' || to_char(sysdate,'YYYYMMDD') || ''','
                                 ||  '''' || to_char(sysdate,'HH24MISS') || ''')';
               var_insert_cnt := var_insert_cnt+1;
            else
               var_update_cnt := var_update_cnt+1;
            end if;

         end loop;
         close csr_keyprd_load_grd;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end if;

      isi_mailer.append_data('|  DATA COMMITTED - ' || var_insert_cnt || ' records inserted, ' || var_update_cnt || ' records updated');
      isi_mailer.append_data('*---------------------------------------------------------');

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
         /* Write Sub-Footer
         /*-*/
         isi_mailer.append_data('*---------------------------------------------------------');

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_keyprd;

   /*******************************************************************/
   /* This function performs the check/validation of GRD Matl Codes   */
   /*******************************************************************/
   function check_grd_tdu(par_matl_code in varchar2, par_src_code in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_chk_hdr is
         select *
         from grd_mat_hdr a
         where ltrim(a.matnr,'0') = par_matl_code;
      rec_chk_hdr  csr_chk_hdr%rowtype;

      cursor csr_chk_sel is
         select 'x'
         from grd_mat_det a
         where a.usagecode = 'SEL'
           and a.orgentity = par_src_code
           and ltrim(a.matnr,'0') = par_matl_code;
      rec_chk_sel  csr_chk_sel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_message := null;

      /*-*/
      /* Check GRD Code exists in staging area
      /*-*/
      open csr_chk_hdr;
      fetch csr_chk_hdr into rec_chk_hdr;
      if (csr_chk_hdr%notfound) then
         var_message := '|       - GRD Code ' || par_matl_code || ' doesnt exist in staging area';
      else

         /*-*/
         /* Check SEL code is defined for MATL
         /*-*/
         open csr_chk_sel;
         fetch csr_chk_sel into rec_chk_sel;
         if (csr_chk_sel%notfound) then
            var_message := '|       - Required SEL code ' || par_src_code || ' not found' || chr(13);
         end if;
         close csr_chk_sel;

         /*-*/
         /* Validate Header values
         /*    1. Check valid business segment is defined for MATL 01 = Snack, 02 = Food, 05 = Pet
         /*    2. Check EAN11/Barcode not null (EXCLUDED)
         /*    3. Check Brand code not null
         /*    4. Check Sub-Brand code not null
         /*    5. Check Consumer Pack Format code not null
         /*    6. Check Product Category code not null
         /*    7. Check Consumer Pack Type code not null
         /*    8. Check Product Type code not null
         /*    9. Check Material Size code not null
         /*    10. Check Ingredient Variety code not null
         /*-*/
         if (rec_chk_hdr.busseg not in ('01','02','05') or rec_chk_hdr.busseg is null) then
            var_message := var_message || '|       - Invalid business segment (required 01 = Snack, 02 = Food, 05 = Pet)' || chr(13);
         end if;
         /*-*/
   --      if (rec_chk_hdr.ean11 is null) then
   --         var_message := var_message || '|       - EAN11 code NULL' || chr(13);
   --      end if;
         /*-*/
         if (rec_chk_hdr.brnd is null) then
            var_message := var_message || '|       - Brand code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.brndsub is null) then
            var_message := var_message || '|       - Sub-Brand code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.cnspckfrt is null) then
            var_message := var_message || '|       - Consumer Pack Format code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.prdcat is null) then
            var_message := var_message || '|       - Product Category code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.cnspcktype is null) then
            var_message := var_message || '|       - Consumer Pack Type code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.prdtype is null) then
            var_message := var_message || '|       - Product Type code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.mat_size is null) then
            var_message := var_message || '|       - Material Size code NULL' || chr(13);
         end if;
         /*-*/
         if (rec_chk_hdr.ingvrty is null) then
            var_message := var_message || '|       - Ingredient Variety code NULL' || chr(13);
         end if;

      end if;
      close csr_chk_hdr;

      /*-*/
      /* If no errors detected, MATL has not been loaded into CARE yet
      /*-*/
      if (var_message is null) then
         var_message := ' *GRD TDU OK - RUN CARE MATERIAL LOAD TO POPULATE*';
      end if;

      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_grd_tdu;

end care_sales_load;
/


DROP PUBLIC SYNONYM CARE_SALES_LOAD;

CREATE PUBLIC SYNONYM CARE_SALES_LOAD FOR CR_APP.CARE_SALES_LOAD;


GRANT EXECUTE ON CR_APP.CARE_SALES_LOAD TO PUBLIC;

