CREATE OR REPLACE PACKAGE           "ODS_PMXODS02" as
/*********************************************************************************
  NAME:      ODS_PMXODS02
  PURPOSE:   This package is called by LICS to load the PMXODS02 accruals file
             into ODS.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   16/03/2007 Cynthia Ennis        Created this package.
  2.0   19/10/2009 Steve Gregan         Added new customer fields and validation

********************************************************************************/
   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_pmxods02;

/


CREATE OR REPLACE PACKAGE BODY           "ODS_PMXODS02" as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_dtl(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_company_code rcd_pmx_cust.company_code%type;
   var_division_code rcd_pmx_cust.division_code%type;
   rcd_pmx_cust pmx_cust%rowtype;
   rcd_ods_control ods_definition.idoc_control;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_start := false;
      var_trn_ignore := false;
      var_trn_error := false;
      var_company_code := null;
      var_division_code := null;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','IDENTIFIER',3);
      lics_inbound_utility.set_definition('CTL','ID_CTL',3);
      lics_inbound_utility.set_definition('CTL','ID_NAME',30);
      lics_inbound_utility.set_definition('CTL','ID_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','ID_DATE',8);
      lics_inbound_utility.set_definition('CTL','ID_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HDR','COMPANY_CODE',3);
      lics_inbound_utility.set_definition('HDR','DIVISION_CODE',2);
      /*-*/
      lics_inbound_utility.set_definition('DTL','IDENTIFIER',3);
      lics_inbound_utility.set_definition('DTL','COMPANY_CODE',3);
      lics_inbound_utility.set_definition('DTL','DIVISION_CODE',2);
      lics_inbound_utility.set_definition('DTL','CUST_NAME',30);
      lics_inbound_utility.set_definition('DTL','CUST_CODE',10);
      lics_inbound_utility.set_definition('DTL','PROM_FLAG',1);
      lics_inbound_utility.set_definition('DTL','ACCT_MGR_KEY',38);
      lics_inbound_utility.set_definition('DTL','MAJOR_REF_CODE',10);
      lics_inbound_utility.set_definition('DTL','MID_REF_CODE',10);
      lics_inbound_utility.set_definition('DTL','MINOR_REF_CODE',10);
      lics_inbound_utility.set_definition('DTL','MAIN_CODE',10);
      lics_inbound_utility.set_definition('DTL','CUST_LEVEL',2);
      lics_inbound_utility.set_definition('DTL','PARENT_CUST_CODE',10);
      lics_inbound_utility.set_definition('DTL','PARENT_GL_CUST_CODE',10);
      lics_inbound_utility.set_definition('DTL','GL_CODE',15);
      lics_inbound_utility.set_definition('DTL','DISTBN_CHNL_CODE',38);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'CTL' then process_record_ctl(par_record);
         when 'HDR' then process_record_hdr(par_record);
         when 'DTL' then process_record_dtl(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the transaction
      /*-*/
      complete_transaction;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

      /*-*/
      /* Local definitions
      /*-*/
      var_errflg boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pmx_cust is
         select t01.*,
                t02.majorref_custlevel,
                t03.midref_custlevel,
                t04.minorref_custlevel
           from pmx_cust t01,
                pmx_cust t02,
                pmx_cust t03,
                pmx_cust t04
          where t01.company_code = t02.company_code(+)
            and t01.division_code = t02.division_code(+)
            and t01.major_ref_code = t02.cust_code(+)
            and t01.company_code = t03.company_code(+)
            and t01.division_code = t03.division_code(+)
            and t01.mid_ref_code = t03.cust_code(+)
            and t01.company_code = t04.company_code(+)
            and t01.division_code = t04.division_code(+)
            and t01.minor_ref_code = t04.cust_code(+)
            and t01.company_code = var_company_code
            and t01.division_code = var_division_code
          order by cust_code asc;
      rcd_pmx_cust csr_pmx_cust%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Rollback and bypass when required
      /*-*/
      if var_trn_start = false or
         var_trn_ignore = true or
         var_trn_error = true then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Validate the interface data when required
      /*-*/
      var_email_group := lics_setting_configuration.retrieve_setting('PMX_CUST_EMAIL_GROUP', var_company_code||var_division_code),
      if not(var_email_group is null) and var_email_group != '*NONE' then

         /*-*/
         /* Create the new email and create the email text header part
         /*-*/
         lics_mailer.create_email('PMX_VENUS_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment,
                                  var_email_group,
                                  'Promax to Venus Customer Interface Warnings - Company('||var_company_code||') Division('||var_division_code||')',
                                  null,
                                  null);
         lics_mailer.create_part(null);
         lics_mailer.append_data('Promax to Venus Customer Interface Warnings - Company('||var_company_code||') Division('||var_division_code||')');
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);

         /*-*/
         /* Create the email file and output the header data
         /*-*/
         lics_mailer.create_part('PMX_VENUS_CUST_WARNING'.xls');
         lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
         lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td align=center colspan=1 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Promax to Venus Customer Interface Warnings - Company('||var_company_code||') Division('||var_division_code||')</td>');
         lics_mailer.append_data('</tr>');

         /*-*/
         /* Output the heading
         /*-*/
         lics_mailer.append_data('<tr><td></td></tr>');
         lics_mailer.append_data('<tr><td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Warning Message</td></tr>');

         /*-*/
         /* Retrieve the customer data for the company and division
         /*-*/
         var_errflg := false;
         open csr_pmx_cust;
         loop
            fetch csr_pmx_cust into rcd_pmx_cust;
            if csr_pmx_cust%notfound then
               exit;
            end if;

            /*-*/
            /* Validate the customer
            /*-*/
            if rcd_pmx_cust.custlevel = 'JR' then
               if rcd_pmx_cust.promoted != 'F' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Major Ref Customer Code ['||rcd_pmx_cust.cust_code||'] promoted flag is not F and is therefore invalid.</td></tr>');
               end if;
               if rcd_pmx_cust.major_ref_code != rcd_pmx_cust.cust_code then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Major Ref Customer Code ['||rcd_pmx_cust.cust_code||'] Major Ref code is not itself and is therefore invalid.</td></tr>');
               end if;
            elsif rcd_pmx_cust.custlevel = 'MD' then
               if rcd_pmx_cust.promoted != 'F' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Mid Ref Customer Code ['||rcd_pmx_cust.cust_code||'] promoted flag is not F and is therefore invalid.</td></tr>');
               end if;
               if rcd_pmx_cust.mid_ref_code != rcd_pmx_cust.cust_code then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Mid Ref Customer Code ['||rcd_pmx_cust.cust_code||'] Mid Ref code is not itself and is therefore invalid.</td></tr>');
               end if;
            elsif rcd_pmx_cust.custlevel = 'F' then
               if rcd_pmx_cust.majorref_custlevel != 'JR' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Minor Ref Customer Code ['||rcd_pmx_cust.cust_code||'] Major Ref Customer ['||rcd_pmx_cust.major_ref_code||'] is not a major ref customer and is therefore invalid.</td></tr>');
               end if;
               if rcd_pmx_cust.midref_custlevel != 'MD' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Minor Ref Customer Code ['||rcd_pmx_cust.cust_code||'] Mid Ref Customer ['||rcd_pmx_cust.mid_ref_code||'] is not a mid ref customer and is therefore invalid.</td></tr>');
               end if;
            elsif rcd_pmx_cust.custlevel = 'I' then
               if rcd_pmx_cust.majorref_custlevel != 'JR' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Invoice Customer Code ['||rcd_pmx_cust.cust_code||'] Major Ref Customer ['||rcd_pmx_cust.major_ref_code||'] is not a major ref customer and is therefore invalid.</td></tr>');
               end if;
               if rcd_pmx_cust.midref_custlevel != 'MD' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Invoice Customer Code ['||rcd_pmx_cust.cust_code||'] Mid Ref Customer ['||rcd_pmx_cust.mid_ref_code||'] is not a mid ref customer and is therefore invalid.</td></tr>');
               end if;
               if rcd_pmx_cust.minorref_custlevel != 'F' then
                  var_errflg := true;
                  lics_mailer.append_data('<tr><td align=left>Invoice Customer Code ['||rcd_pmx_cust.cust_code||'] Minor Ref Customer ['||rcd_pmx_cust.minor_ref_code||'] is not a minor ref customer and is therefore invalid.</td></tr>');
               end if;
            end if;
         end loop;
         close csr_pmx_cust;

         /*-*/
         /* Output the empty report
         /*-*/
         if var_errflg = false then
            lics_mailer.append_data('<tr><td></td></tr>');
            lics_mailer.append_data('<tr><td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;">NO WARNINGS</td></tr>');
         end if;

         /*-*/
         /* Output the email file part trailer data
         /*-*/
         lics_mailer.append_data('</table>');
         lics_mailer.create_part(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data('** Email End **');
         lics_mailer.finalise_email('utf-8');

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Extract and validate the control interface file name
      /*-*/
      rcd_ods_control.idoc_name := lics_inbound_utility.get_variable('ID_NAME');
      if rcd_ods_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.ID_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control interface file number
      /*-*/
      rcd_ods_control.idoc_number := lics_inbound_utility.get_number('ID_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_ods_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.ID_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control interface file timestamp
      /*-*/
      rcd_ods_control.idoc_timestamp := lics_inbound_utility.get_variable('ID_DATE') || lics_inbound_utility.get_variable('ID_TIME');
      if rcd_ods_control.idoc_timestamp is null then
         lics_inbound_utility.add_exception('Field - CTL.ID_TIMESTAMP - Must not be null');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
      var_division_code := lics_inbound_utility.get_variable('DIVISION_CODE');

   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DTL routine */
   /**************************************************/
   procedure process_record_dtl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DTL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_pmx_cust.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
      rcd_pmx_cust.division_code := lics_inbound_utility.get_variable('DIVISION_CODE');
      rcd_pmx_cust.cust_code := lics_inbound_utility.get_variable('CUST_CODE');
      rcd_pmx_cust.cust_name := lics_inbound_utility.get_variable('CUST_NAME');
      rcd_pmx_cust.prom_flag := lics_inbound_utility.get_variable('PROM_FLAG');
      rcd_pmx_cust.acct_mgr_key := lics_inbound_utility.get_variable('ACCT_MGR_KEY');
      rcd_pmx_cust.major_ref_code := lics_inbound_utility.get_variable('MAJOR_REF_CODE');
      rcd_pmx_cust.mid_ref_code := lics_inbound_utility.get_variable('MID_REF_CODE');
      rcd_pmx_cust.minor_ref_code := lics_inbound_utility.get_variable('MINOR_REF_CODE');
      rcd_pmx_cust.main_code := lics_inbound_utility.get_variable('MAIN_CODE');
      rcd_pmx_cust.cust_level := lics_inbound_utility.get_variable('CUST_LEVEL');
      rcd_pmx_cust.parent_cust_code := lics_inbound_utility.get_variable('PARENT_CUST_CODE');
      rcd_pmx_cust.parent_gl_cust_code := lics_inbound_utility.get_variable('PARENT_GL_CUST_CODE');
      rcd_pmx_cust.gl_code := lics_inbound_utility.get_variable('GL_CODE');
      rcd_pmx_cust.distbn_chnl_code := lics_inbound_utility.get_variable('DISTBN_CHNL_CODE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*--------------------------------------------*/
      /* VALIDATION - Validate the key field values */
      /*--------------------------------------------*/

      /*-*/
      /* Validate the primary keys: company_code
      /*-*/
      if rcd_pmx_cust.company_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - COMPANY_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      /* Validate the primary keys: division_code
      /*-*/
      if rcd_pmx_cust.division_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DIVISION_CODE');
         var_trn_error := true;
      end if;
      /*-*/
      /* Validate the primary keys: cust_code,
      /*-*/
      if rcd_pmx_cust.cust_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CUST_CODE');
         var_trn_error := true;
      end if;

      /*-----------------------------------------------*/
      /* ERROR- Bypass the insert/update when required */
      /*-----------------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Insert or update pmx_cust table. We expect a mix of inserts and updates.
      /*-*/
      begin
        insert into ods.pmx_cust (
          company_code,
          division_code,
          cust_name,
          cust_code,
          prom_flag,
          acct_mgr_key,
          major_ref_code,
          mid_ref_code,
          minor_ref_code,
          main_code,
          main_name,
          cust_level,
          parent_cust_code,
          parent_gl_cust_code,
          gl_code,
          distbn_chnl_code
        )
        values
          (rcd_pmx_cust.company_code,
          rcd_pmx_cust.division_code,
          rcd_pmx_cust.cust_name,
          rcd_pmx_cust.cust_code,
          rcd_pmx_cust.prom_flag,
          rcd_pmx_cust.acct_mgr_key,
          rcd_pmx_cust.major_ref_code,
          rcd_pmx_cust.mid_ref_code,
          rcd_pmx_cust.minor_ref_code,
          rcd_pmx_cust.main_code,
          rcd_pmx_cust.cust_level,
          rcd_pmx_cust.parent_cust_code,
          rcd_pmx_cust.parent_gl_cust_code,
          rcd_pmx_cust.gl_code,
          rcd_pmx_cust.distbn_chnl_code
        );
      exception
      when dup_val_on_index then
        begin
          update pmx_cust set
            cust_name = rcd_pmx_cust.cust_name,
            prom_flag = rcd_pmx_cust.prom_flag,
            acct_mgr_key = rcd_pmx_cust.acct_mgr_key,
            major_ref_code = rcd_pmx_cust.major_ref_code,
            mid_ref_code = rcd_pmx_cust.mid_ref_code,
            minor_ref_code = rcd_pmx_cust.minor_ref_code,
            main_code = rcd_pmx_cust.main_code,
            cust_level = rcd_pmx_cust.cust_level,
            parent_cust_code = rcd_pmx_cust.parent_cust_code,
            parent_gl_cust_code = rcd_pmx_cust.parent_gl_cust_code,
            gl_code = rcd_pmx_cust.gl_code,
            distbn_chnl_code = rcd_pmx_cust.distbn_chnl_code
          where
            company_code = rcd_pmx_cust.company_code and
            division_code = rcd_pmx_cust.division_code and
            cust_code = rcd_pmx_cust.cust_code;
        end;

      end;

   end process_record_dtl;

end ods_pmxods02;
/
