/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_mfgcis01
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - mfgcis01 - MFGPRO Invoice Interface

 YYYY/MM   Author          Description
 -------   ------          -----------
 2004/04   Steve Gregan    Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_mfgcis01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_mfgcis01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_mfgcis01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_trl(par_record in varchar2);
   procedure process_tax;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   type rcd_outbound is record(data_string varchar2(4000), data_amount number);
   type typ_outbound is table of rcd_outbound index by binary_integer;
   tbl_outbound typ_outbound;
   var_index number(5,0);
   var_save_index number(5,0);
   var_hdr_base number;
   var_tax_base number;
   var_tax_value number;
   var_mca_account varchar2(256);
   var_uba_account varchar2(256);

   /*-*/
   /* Private constants
   /*-*/
   con_gst_group constant varchar2(32) := 'MFGPRO_GST_ACCOUNT';

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
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','XVO_HDR',3);
      lics_inbound_utility.set_definition('HDR','XVO_SYS_REF',2);
      lics_inbound_utility.set_definition('HDR','XVO_BATCH',6);
      lics_inbound_utility.set_definition('HDR','XVO_LINE',5);
      lics_inbound_utility.set_definition('HDR','XVO_ENTITY',4);
      lics_inbound_utility.set_definition('HDR','XVO_SUPP',8);
      lics_inbound_utility.set_definition('HDR','XVO_REF',20);
      lics_inbound_utility.set_definition('HDR','XVO_DATE',8);
      lics_inbound_utility.set_definition('HDR','XVO_EFF_DATE',8);
      lics_inbound_utility.set_definition('HDR','XVO_TAX_DATE',8);
      lics_inbound_utility.set_definition('HDR','XVO_REMARK',20);
      lics_inbound_utility.set_definition('HDR','XVO_CUR',3);
      lics_inbound_utility.set_definition('HDR','XVO_AP_ACCT',8);
      lics_inbound_utility.set_definition('HDR','XVO_AP_CC',4);
      lics_inbound_utility.set_definition('HDR','XVO_AMT',14);
      lics_inbound_utility.set_definition('HDR','XVO_DET_LINE',3);
      lics_inbound_utility.set_definition('HDR','XVO_CONF',3);
      lics_inbound_utility.set_definition('HDR','XVO_ASSIGN',8);
      lics_inbound_utility.set_definition('HDR','XVO_FILL01',6);
      lics_inbound_utility.set_definition('HDR','XVO_EX_RATE',16);
      /*-*/
      lics_inbound_utility.set_definition('DET','XVOD_DET',3);
      lics_inbound_utility.set_definition('DET','XVOD_SYS_REF',2);
      lics_inbound_utility.set_definition('DET','XVOD_BATCH',6);
      lics_inbound_utility.set_definition('DET','XVOD_LIN',5);
      lics_inbound_utility.set_definition('DET','XVOD_DST_LINE',3);
      lics_inbound_utility.set_definition('DET','XVOD_ENTITY',4);
      lics_inbound_utility.set_definition('DET','XVOD_ACCT',8);
      lics_inbound_utility.set_definition('DET','XVOD_CC',4);
      lics_inbound_utility.set_definition('DET','XVOD_PROJ',8);
      lics_inbound_utility.set_definition('DET','XVOD_DESC',21);
      lics_inbound_utility.set_definition('DET','XVOD_AMT',14);
      lics_inbound_utility.set_definition('DET','XVOD_TAXABLE',1);
      lics_inbound_utility.set_definition('DET','XVOD_TAXC',3);
      lics_inbound_utility.set_definition('DET','XVOD_TAX_USAGE',8);
      lics_inbound_utility.set_definition('DET','XVOD_TAX_ENV',16);
      lics_inbound_utility.set_definition('DET','XVOD_TAX_IN',1);
      lics_inbound_utility.set_definition('DET','XVOD_TAX_AMT',14);
      lics_inbound_utility.set_definition('DET','XVOD_IGN_TAX',1);
      /*-*/
      lics_inbound_utility.set_definition('TRL','XBA_TRL',3);
      lics_inbound_utility.set_definition('TRL','XBA_SYS_REF',2);
      lics_inbound_utility.set_definition('TRL','XBA_BATCH',6);
      lics_inbound_utility.set_definition('TRL','XBA_TTL_TRANS',5);
      lics_inbound_utility.set_definition('TRL','XBA_TTL_VAL',14);
      lics_inbound_utility.set_definition('TRL','XBA_DATE',8);

      /*-*/
      /* Clear the outbound array
      /*-*/
      tbl_outbound.delete;

      /*-*/
      /* Initialise the global variables
      /*-*/
      var_hdr_base := 0;
      var_tax_base := 0;
      var_tax_value := 0;
      var_save_index := 0;

      /*-*/
      /* Retrieve the MFGPRO GST accounts
      /*-*/
      var_mca_account := lics_setting_configuration.retrieve_setting(con_gst_group, 'MCA');
      var_uba_account := lics_setting_configuration.retrieve_setting(con_gst_group, 'UBA');

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
         when 'HDR' then process_record_hdr(par_record);
         when 'DET' then process_record_det(par_record);
         when 'TRL' then process_record_trl(par_record);
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
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return when transaction error
      /*-*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Return when no outbound data exist
      /*-*/
      if tbl_outbound.count = 0 then
         return;
      end if;

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('CISATL03');

      /*-*/
      /* Append the interface data
      /*-*/
      for idx in 1..tbl_outbound.count loop
         lics_outbound_loader.append_data(tbl_outbound(idx).data_string);
      end loop;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_doc_date date;
      var_trn_date date;
      var_ex_rate number;
      var_chr_rate varchar2(9);
      var_vendor varchar2(64);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xrf_det is
	 select t01.xrf_target
	   from lads_xrf_det t01
          where t01.xrf_code = 'MFA_VENDOR'
            and t01.xrf_source = var_vendor;
      rcd_lads_xrf_det csr_lads_xrf_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------------------------------*/
      /* FINALISE - Finalise the previous header when required */
      /*-------------------------------------------------------*/

      /*-*/
      /* Process the tax information
      /*-*/
      if var_save_index <> 0 then
         process_tax;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Set the document date
      /*-*/
      var_doc_date := lics_inbound_utility.get_date('XVO_DATE','DD/MM/YY');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Set the transaction date
      /*-*/
      var_trn_date := lics_inbound_utility.get_date('XVO_EFF_DATE','DD/MM/YY');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Retrieve the exchange rate
      /*-*/
      var_ex_rate := nvl(lics_inbound_utility.get_number('XVO_EX_RATE',null),0);
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if var_ex_rate <= 1000 then
         var_chr_rate := to_char(round(var_ex_rate,5),'FM000.00000');
      elsif var_ex_rate <= 10000 then
         var_chr_rate := to_char(round(var_ex_rate,4),'FM0000.0000');
      else
         var_chr_rate := to_char(round(var_ex_rate,3),'FM00000.0000');
      end if;

      /*-*/
      /* Retrieve the header base
      /*-*/
      var_hdr_base := nvl(lics_inbound_utility.get_number('XVO_AMT',null),0);
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Set SAP vendor using MFGPRO vendor
      /* Default to MFGPRO vendor when cross reference not found
      /*-*/
      var_found := false;
      var_vendor := trim(lics_inbound_utility.get_variable('XVO_SUPP'));
      open csr_lads_xrf_det;
      fetch csr_lads_xrf_det into rcd_lads_xrf_det;
      if csr_lads_xrf_det%found then
         var_vendor := rcd_lads_xrf_det.xrf_target;
         var_found := true;
      end if;
      close csr_lads_xrf_det;
      if var_found = false then
         var_vendor := 'V' || var_vendor;
      end if;

      /*-*/
      /* Set the outbound properties "H"
      /*-*/
      var_index := tbl_outbound.count + 1;
      tbl_outbound(var_index).data_string := 'H' ||
                                             rpad('IDOC',5,' ') ||
                                             rpad(to_char(sysdate,'yyyymmdd') || lics_inbound_utility.get_variable('XVO_LINE'),20,' ') ||
                                             'RFBU' ||
                                             rpad('BATCHSCHE',12,' ') ||
                                             rpad(lics_inbound_utility.get_variable('XVO_SUPP'),25,' ') ||
                                             rpad('147',4,' ') ||
                                             rpad(upper(lics_inbound_utility.get_variable('XVO_CUR')),5,' ') ||
                                             rpad(to_char(var_doc_date,'YYYYMMDD'),8,' ') ||
                                             rpad(to_char(var_trn_date,'YYYYMMDD'),8,' ') ||
                                             rpad(to_char(var_trn_date,'YYYYMMDD'),8,' ') ||
                                             'KN' ||
                                             rpad(substr(lics_inbound_utility.get_variable('XVO_REF'),1,16),16,' ') ||
                                             rpad('MFGPRO',10,' ') ||
                                             rpad(' ',9,' ') ||
                                             rpad(var_chr_rate,9,' ');

      /*-*/
      /* Set the outbound properties "P"
      /*-*/
      var_index := tbl_outbound.count + 1;
      tbl_outbound(var_index).data_string := 'P' ||
                                             lpad(trim(var_vendor),10,'0') ||
                                             rpad(to_char(var_hdr_base * -1),23,' ');

      /*-*/
      /* Set the detail save index
      /*-*/
      var_save_index := tbl_outbound.count + 1;

      /*-*/
      /* Reset the tax variables
      /*-*/
      var_tax_base := 0;
      var_tax_value := 0;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_account varchar2(64);
      var_centre varchar2(64);
      var_order varchar2(64);
      var_entity varchar2(64);
      var_amount number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xrf_det is
	 select t01.xrf_target
	   from lads_xrf_det t01
          where t01.xrf_code = 'MFGPRO_ACCOUNT'
            and t01.xrf_source = var_account;
      rcd_lads_xrf_det csr_lads_xrf_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve the account
      /*-*/
      var_account := trim(lics_inbound_utility.get_variable('XVOD_ACCT'));
      var_centre := null;
      var_order := null;
      var_entity := null;

      /*-*/
      /* Retrieve the amount
      /*-*/
      var_amount := nvl(lics_inbound_utility.get_number('XVOD_AMT',null),0);
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Process the GST account line when required
      /*-*/
      if var_account = var_mca_account or
         var_account = var_uba_account then
         var_tax_value := var_tax_value + var_amount;
         return;
      end if;

      /*-*/
      /* Accumulate the tax base
      /*-*/
      var_tax_base := var_tax_base + var_amount;

      /*-*/
      /* Set SAP account using MFGPRO account (strip leading zeros)
      /* Default to MFGPRO account when cross reference not found
      /*-*/
      begin
         var_account := to_char(to_number(var_account),'FM99999990');
      exception
         when others then
            null;
      end;
      open csr_lads_xrf_det;
      fetch csr_lads_xrf_det into rcd_lads_xrf_det;
      if csr_lads_xrf_det%found then
         if instr(rcd_lads_xrf_det.xrf_target,'C',1,1) <> 0 then
            var_account := substr(rcd_lads_xrf_det.xrf_target,1,instr(rcd_lads_xrf_det.xrf_target,'C',1,1)-1);
            var_centre := substr(rcd_lads_xrf_det.xrf_target,instr(rcd_lads_xrf_det.xrf_target,'C',1,1)+1,(length(rcd_lads_xrf_det.xrf_target)-instr(rcd_lads_xrf_det.xrf_target,'C',1,1)));
         elsif instr(rcd_lads_xrf_det.xrf_target,'S',1,1) <> 0 then
            var_account := substr(rcd_lads_xrf_det.xrf_target,1,instr(rcd_lads_xrf_det.xrf_target,'S',1,1)-1);
            var_order := substr(rcd_lads_xrf_det.xrf_target,instr(rcd_lads_xrf_det.xrf_target,'S',1,1)+1,(length(rcd_lads_xrf_det.xrf_target)-instr(rcd_lads_xrf_det.xrf_target,'S',1,1)));
         elsif instr(rcd_lads_xrf_det.xrf_target,'P',1,1) <> 0 then
            var_account := substr(rcd_lads_xrf_det.xrf_target,1,instr(rcd_lads_xrf_det.xrf_target,'P',1,1)-1);
            var_entity := substr(rcd_lads_xrf_det.xrf_target,instr(rcd_lads_xrf_det.xrf_target,'P',1,1)+1,(length(rcd_lads_xrf_det.xrf_target)-instr(rcd_lads_xrf_det.xrf_target,'P',1,1)));
         end if;
      end if;
      close csr_lads_xrf_det;

      /*-*/
      /* Set the outbound properties "G"
      /*-*/
      var_index := tbl_outbound.count + 1;
      tbl_outbound(var_index).data_string := 'G' ||
                                             lpad(trim(var_account),10,'0') ||
                                             rpad(lics_inbound_utility.get_variable('XVOD_AMT'),23,' ') ||
                                             rpad(lics_inbound_utility.get_variable('XVOD_DESC'),50,' ') ||
                                             rpad(' ',18,' ') ||
                                             rpad('A0',2,' ') ||
                                             lpad(nvl(var_centre,'          '),10,'0') ||
                                             lpad(nvl(var_order,'            '),12,'0') ||
                                             rpad(' ',72,' ') ||
                                             lpad(nvl(var_entity,'          '),10,'0');
      tbl_outbound(var_index).data_amount := var_amount;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record TRL routine */
   /**************************************************/
   procedure process_record_trl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------------------------------*/
      /* FINALISE - Finalise the previous header when required */
      /*-------------------------------------------------------*/

      /*-*/
      /* Process the tax information
      /*-*/
      if var_save_index <> 0 then
         process_tax;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_trl;

   /***************************************************/
   /* This procedure performs the process tax routine */
   /***************************************************/
   procedure process_tax is

      /*-*/
      /* Local definitions
      /*-*/
      var_work01 number;
      var_work02 number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No tax value found
      /*-*/
      if var_tax_value = 0 then

         /*-*/
         /* Set the outbound properties "TA0"
         /*-*/
         var_index := tbl_outbound.count + 1;
         tbl_outbound(var_index).data_string := 'TA0' ||
                                                rpad(to_char(0,'0000000000000000000.00'),23,' ') ||
                                                rpad(to_char(var_tax_base,'0000000000000000000.00'),23,' ');

      /*-*/
      /* Tax value found
      /*-*/
      else

         /*-*/
         /* Set the outbound detail tax flags
         /*-*/
         var_work01 := 0;
         if var_tax_base = var_hdr_base - var_tax_value then
            for idx in var_save_index..tbl_outbound.count loop
               tbl_outbound(idx).data_string := substr(tbl_outbound(idx).data_string,1,102) || 'A2' || substr(tbl_outbound(idx).data_string,105,208);
            end loop;
         else
            var_work01 := var_tax_base - (var_tax_value / .1);
            var_work02 := 0;
            for idx in var_save_index..tbl_outbound.count loop
               var_work02 := var_work02 + tbl_outbound(idx).data_amount;
               tbl_outbound(idx).data_string := substr(tbl_outbound(idx).data_string,1,102) || 'A2' || substr(tbl_outbound(idx).data_string,105,208);
               if var_work02 > var_work01 then 
                  exit;
               end if;
            end loop;
         end if;

         /*-*/
         /* Set the outbound properties "TA2"
         /*-*/
         var_index := tbl_outbound.count + 1;
         tbl_outbound(var_index).data_string := 'TA2' ||
                                                rpad(to_char(var_tax_value,'0000000000000000000.00'),23,' ') ||
                                                rpad(to_char(var_tax_value / .1,'0000000000000000000.00'),23,' ');

         /*-*/
         /* Set the outbound properties "TA0" when required
         /*-*/
         if var_work01 <> 0 then
            var_index := tbl_outbound.count + 1;
            tbl_outbound(var_index).data_string := 'TA0' ||
                                                   rpad(to_char(0,'0000000000000000000.00'),23,' ') ||
                                                   rpad(to_char(var_work01,'0000000000000000000.00'),23,' ');
         end if;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_tax;

end ics_mfgcis01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
drop public synonym ics_mfgcis01;
create public synonym ics_mfgcis01 for ics_app.ics_mfgcis01;
grant execute on ics_mfgcis01 to public;