CREATE OR REPLACE PACKAGE           "ODS_PMXODS02" as
/*********************************************************************************
  NAME:      ODS_PMXODS02
  PURPOSE:   This package is called by LICS to load the PMXODS02 accruals file
             into ODS.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   16/03/2007 Cynthia Ennis        Created this package.
  2.0   19/10/2009 Steve Gregan         Added new customer fields.

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
      lics_inbound_utility.set_definition('DTL','IDENTIFIER',3);
      lics_inbound_utility.set_definition('DTL','COMPANY_CODE',3);
      lics_inbound_utility.set_definition('DTL','DIVISION_CODE',2);
      lics_inbound_utility.set_definition('DTL','CUST_NAME',30);
      lics_inbound_utility.set_definition('DTL','CUST_CODE',10);
      lics_inbound_utility.set_definition('DTL','PROM_FLAG',1);
      lics_inbound_utility.set_definition('DTL','ACCT_MGR_KEY',38);
      lics_inbound_utility.set_definition('DTL','MAJOR_REF_CODE',10);
      lics_inbound_utility.set_definition('DTL','MAJOR_REF_DESC',30);
      lics_inbound_utility.set_definition('DTL','MID_REF_CODE',10);
      lics_inbound_utility.set_definition('DTL','MID_REF_DESC',30);
      lics_inbound_utility.set_definition('DTL','MINOR_REF_CODE',10);
      lics_inbound_utility.set_definition('DTL','MINOR_REF_DESC',30);
      lics_inbound_utility.set_definition('DTL','MAIN_CODE',10);
      lics_inbound_utility.set_definition('DTL','MAIN_NAME',30);
      lics_inbound_utility.set_definition('DTL','CUST_LEVEL',38);
      lics_inbound_utility.set_definition('DTL','PARENT_CUST_CODE',10);
      lics_inbound_utility.set_definition('DTL','PARENT_CUST_DESC',30);
      lics_inbound_utility.set_definition('DTL','PARENT_GL_CUST_CODE',10);
      lics_inbound_utility.set_definition('DTL','PARENT_GL_CUST_DESC',30);
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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when commited
      /*-*/
      if var_trn_ignore = true then
         rollback;
      elsif var_trn_start = true then
         if var_trn_error = true then
            rollback;
         else
            commit;
         end if;
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
   /* This procedure performs the record DTL routine */
   /**************************************************/
   procedure process_record_dtl(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

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
      rcd_pmx_cust.major_ref_desc := lics_inbound_utility.get_variable('MAJOR_REF_DESC');
      rcd_pmx_cust.mid_ref_code := lics_inbound_utility.get_variable('MID_REF_CODE');
      rcd_pmx_cust.mid_ref_desc := lics_inbound_utility.get_variable('MID_REF_DESC');
      rcd_pmx_cust.minor_ref_code := lics_inbound_utility.get_variable('MINOR_REF_CODE');
      rcd_pmx_cust.minor_ref_desc := lics_inbound_utility.get_variable('MINOR_REF_DESC');
      rcd_pmx_cust.main_code := lics_inbound_utility.get_variable('MAIN_CODE');
      rcd_pmx_cust.main_name := lics_inbound_utility.get_variable('MAIN_NAME');
      rcd_pmx_cust.cust_level := lics_inbound_utility.get_variable('CUST_LEVEL');
      rcd_pmx_cust.parent_cust_code := lics_inbound_utility.get_variable('PARENT_CUST_CODE');
      rcd_pmx_cust.parent_cust_desc := lics_inbound_utility.get_variable('PARENT_CUST_DESC');
      rcd_pmx_cust.parent_gl_cust_code := lics_inbound_utility.get_variable('PARENT_GL_CUST_CODE');
      rcd_pmx_cust.parent_gl_cust_desc := lics_inbound_utility.get_variable('PARENT_GL_CUST_DESC');
      rcd_pmx_cust.gl_code := lics_inbound_utility.get_variable('GL_CODE');
      rcd_pmx_cust.distbn_chnl_code := lics_inbound_utility.get_variable('DISTBN_CHNL_CODE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the key field values */
      /*----------------------------------------*/

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

      /*----------------------------------------*/
      /* ERROR- Bypass the insert/update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Insert or update pmx_cust table.  We expect a mix of inserts and updates.
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
          major_ref_desc,
          mid_ref_code,
          mid_ref_desc,
          minor_ref_code,
          minor_ref_desc,
          main_code,
          main_name,
          cust_level,
          parent_cust_code,
          parent_cust_desc,
          parent_gl_cust_code,
          parent_gl_cust_desc,
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
          rcd_pmx_cust.major_ref_desc,
          rcd_pmx_cust.mid_ref_code,
          rcd_pmx_cust.mid_ref_desc,
          rcd_pmx_cust.minor_ref_code,
          rcd_pmx_cust.minor_ref_desc,
          rcd_pmx_cust.main_code,
          rcd_pmx_cust.main_name,
          rcd_pmx_cust.cust_level,
          rcd_pmx_cust.parent_cust_code,
          rcd_pmx_cust.parent_cust_desc,
          rcd_pmx_cust.parent_gl_cust_code,
          rcd_pmx_cust.parent_gl_cust_desc,
          rcd_pmx_cust.gl_code,
          rcd_pmx_cust.distbn_chnl_code
        );
      exception
      when DUP_VAL_ON_INDEX then
        begin
          update pmx_cust set
            cust_name = rcd_pmx_cust.cust_name,
            prom_flag = rcd_pmx_cust.prom_flag,
            acct_mgr_key = rcd_pmx_cust.acct_mgr_key,
            major_ref_code = rcd_pmx_cust.major_ref_code,
            major_ref_desc = rcd_pmx_cust.major_ref_desc,
            mid_ref_code = rcd_pmx_cust.mid_ref_code,
            mid_ref_desc = rcd_pmx_cust.mid_ref_desc,
            minor_ref_code = rcd_pmx_cust.minor_ref_code,
            minor_ref_desc = rcd_pmx_cust.minor_ref_desc,
            main_code = rcd_pmx_cust.main_code,
            main_name = rcd_pmx_cust.main_name,
            cust_level = rcd_pmx_cust.cust_level,
            parent_cust_code = rcd_pmx_cust.parent_cust_code,
            parent_cust_desc = rcd_pmx_cust.parent_cust_desc,
            parent_gl_cust_code = rcd_pmx_cust.parent_gl_cust_code,
            parent_gl_cust_desc = rcd_pmx_cust.parent_gl_cust_desc,
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
