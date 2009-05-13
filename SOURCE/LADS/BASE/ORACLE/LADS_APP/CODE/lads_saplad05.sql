/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_saplad05
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - saplad05 - Inbound SAP Factory BOM Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/02   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_saplad05 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_saplad05;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_saplad05 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_nod(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);
   procedure load_data;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_bom_tmp lads_bom_tmp%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('NOD','IDOC_NOD',3);
      lics_inbound_utility.set_definition('NOD','TAB_NAME',30);
      /*-*/
      lics_inbound_utility.set_definition('DAT','IDOC_DAT',3);
      lics_inbound_utility.set_definition('DAT','TAB_NAME',30);
      lics_inbound_utility.set_definition('DAT','TAB_DATA',512);

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
         when 'NOD' then process_record_nod(par_record);
         when 'DAT' then process_record_dat(par_record);
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
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.stlal,
                t01.matnr,
                t01.werks
           from lads_bom_hdr t01;
      rcd_header csr_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Load the data when required
      /*-*/
      if var_trn_ignore = false and
         var_trn_error = false then
         begin
            load_data;
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
               var_trn_error := true;
         end;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /*-*/
      if var_trn_ignore = true then

         /*-*/
         /* Rollback the IDOC transaction
         /*-*/
         rollback;

         /*-*/
         /* Clear the temporary table
         /*-*/
         delete from lads_bom_tmp;
         commit;

      elsif var_trn_error = true then

         /*-*/
         /* Rollback the IDOC transaction
         /*-*/
         rollback;

         /*-*/
         /* Clear the temporary table
         /*-*/
         delete from lads_bom_tmp;
         commit;

      else

         /*-*/
         /* Clear the temporary table
         /*-*/
         delete from lads_bom_tmp;
         
         /*-*/
         /* Commit the IDOC transaction
         /*-*/
         commit;
         
         /*-*/
         /* Rebuild the BDS factory BOM
         /* **notes**
         /* 1. Delete any redundant LADS data
         /* 2. Flatten the new BOM data (commit after each)
         /*-*/
         begin
            update lads_bom_hdr set lads_status = '4' where idoc_timestamp != rcd_lads_control.idoc_timestamp;
            commit;
            open csr_header;
            loop
               fetch csr_header into rcd_header;
               if csr_header%notfound then
                  exit;
               end if;
               bds_atllad17_flatten.execute('*DOCUMENT',rcd_header.stlal, rcd_header.matnr, rcd_header.werks);
               commit;
            end loop;
            close csr_header;
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end; 

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Clear the temporary table
      /*-*/
      delete from lads_bom_tmp;
      commit;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Extract and validate the control IDOC name
      /*-*/
      rcd_lads_control.idoc_name := lics_inbound_utility.get_variable('IDOC_NAME');
      if rcd_lads_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_lads_control.idoc_number := lics_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_lads_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_lads_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_DATE') || lics_inbound_utility.get_variable('IDOC_TIME');
      if rcd_lads_control.idoc_timestamp is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_TIMESTAMP - Must not be null');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record NOD routine */
   /**************************************************/
   procedure process_record_nod(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_nod;

   /**************************************************/
   /* This procedure performs the record DAT routine */
   /**************************************************/
   procedure process_record_dat(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DAT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_bom_tmp.tab_name := lics_inbound_utility.get_variable('TAB_NAME');
      rcd_lads_bom_tmp.tab_data := lics_inbound_utility.get_variable('TAB_DATA');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into lads_bom_tmp
         (tab_name,
          tab_data)
      values
         (rcd_lads_bom_tmp.tab_name,
          rcd_lads_bom_tmp.tab_data);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

   /*************************************************/
   /* This procedure performs the load data routine */
   /*************************************************/
   procedure load_data is

      /*-*/
      /* Local variables
      /*-*/
      var_savkey varchar2(24);
      rcd_lads_bom_hdr lads_bom_hdr%rowtype;
      rcd_lads_bom_det lads_bom_det%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_bom_data is
         select t01.bomkey,
                t01.stlnr,
                t01.stlal,
                t01.matnr,
                t01.werks,
                t01.stlan,
                t01.hdruv,
                t01.bmeng,
                t01.bmein,
                t01.stlst,
                t02.posnr,
                t02.postp,
                t02.idnrk,
                t02.menge,
                t02.meins,
                t02.datuv
           from (select substr(t01.tab_data,9,24) as bomkey,
                        substr(t01.tab_data,1,8) as stlnr,
                        substr(t01.tab_data,9,2) as stlal,
                        substr(t01.tab_data,11,18) as matnr,
                        substr(t01.tab_data,29,4) as werks,
                        substr(t01.tab_data,33,1) as stlan,
                        t02.datuv as hdruv,
                        t02.bmeng,
                        t02.bmein,
                        t02.stlst
                   from lads_bom_tmp t01,
                        (select substr(t01.tab_data,1,8) as stlnr,
                                substr(t01.tab_data,9,2) as stlal,
                                substr(t01.tab_data,11,8) as datuv,
                                substr(t01.tab_data,19,17) as bmeng,
                                substr(t01.tab_data,36,3) as bmein,
                                substr(t01.tab_data,39,2) as stlst
                           from lads_bom_tmp t01
                          where t01.tab_name = 'STKO') t02
                  where substr(t01.tab_data,1,8) = t02.stlnr
                    and substr(t01.tab_data,9,2) = t02.stlal
                    and t01.tab_name = 'MAST') t01,
                (select substr(t01.tab_data,1,8) as stlnr,
                        substr(t01.tab_data,9,2) as stlal,
                        substr(t01.tab_data,11,8) as stlkn,
                        t02.posnr,
                        t02.postp,
                        t02.idnrk,
                        t02.menge,
                        t02.meins,
                        t02.datuv
                   from lads_bom_tmp t01,
                        (select substr(t01.tab_data,1,8) as stlnr,
                                substr(t01.tab_data,9,8) as stlkn,
                                substr(t01.tab_data,17,4) as posnr,
                                substr(t01.tab_data,21,1) as postp,
                                substr(t01.tab_data,22,18) as idnrk,
                                substr(t01.tab_data,40,18) as menge,
                                substr(t01.tab_data,58,3) as meins,
                                substr(t01.tab_data,61,8) as datuv
                           from lads_bom_tmp t01
                          where t01.tab_name = 'STPO') t02
                  where substr(t01.tab_data,1,8) = t02.stlnr
                    and substr(t01.tab_data,11,8) = t02.stlkn
                    and t01.tab_name = 'STAS') t02
          where t01.stlnr = t02.stlnr
            and t01.stlal = t02.stlal
          order by t01.stlal asc,
                   t01.matnr asc,
                   t01.werks asc;
      rcd_bom_data csr_bom_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the BOM data
      /*-*/
      delete from lads_bom_det;
      delete from lads_bom_hdr;

      /*-*/
      /* Retrieve the BOM data
      /*-*/
      var_savkey := '**START**';
      open csr_bom_data;
      loop
         fetch csr_bom_data into rcd_bom_data;
         if csr_bom_data%notfound then
            exit;
         end if;

         /*-*/
         /* Convert the header UOM values
         /*-*/
         if trim(rcd_bom_data.bmein) = 'KG' then
            rcd_bom_data.bmein := 'KGM';
         elsif trim(rcd_bom_data.bmein) = 'M' then
            rcd_bom_data.bmein := 'MTR';
         end if;

         /*-*/
         /* Convert the detail UOM values
         /*-*/
         if trim(rcd_bom_data.meins) = 'CM' then
            rcd_bom_data.bmein := 'CMT';
         elsif trim(rcd_bom_data.meins) = 'G' then
            rcd_bom_data.bmein := 'GRM';
         elsif trim(rcd_bom_data.meins) = 'KG' then
            rcd_bom_data.bmein := 'KGM';
         elsif trim(rcd_bom_data.meins) = 'M' then
            rcd_bom_data.bmein := 'MTR';
         elsif trim(rcd_bom_data.meins) = 'MM' then
            rcd_bom_data.bmein := 'MMT';
         elsif trim(rcd_bom_data.meins) = 'ST' then
            rcd_bom_data.bmein := 'PCE';
         end if;

         /*-*/
         /* Insert the BOM header when required
         /*-*/
         if rcd_bom_data.bomkey != var_savkey then
            var_savkey := rcd_bom_data.bomkey;
            rcd_lads_bom_hdr.msgfn := '005';
            rcd_lads_bom_hdr.stlnr := trim(rcd_bom_data.stlnr);
            rcd_lads_bom_hdr.stlal := lads_trim_code(trim(rcd_bom_data.stlal));
            rcd_lads_bom_hdr.matnr := lads_trim_code(trim(rcd_bom_data.matnr));
            rcd_lads_bom_hdr.werks := trim(rcd_bom_data.werks);
            rcd_lads_bom_hdr.stlan := trim(rcd_bom_data.stlan);
            rcd_lads_bom_hdr.datuv := trim(rcd_bom_data.hdruv);
            rcd_lads_bom_hdr.datub := '99991231';
            rcd_lads_bom_hdr.bmeng := lads_to_number(replace(trim(rcd_bom_data.bmeng),'.',null))/1000;
            rcd_lads_bom_hdr.bmein := trim(rcd_bom_data.bmein);
            rcd_lads_bom_hdr.stlst := trim(rcd_bom_data.stlst);
            rcd_lads_bom_hdr.idoc_name := rcd_lads_control.idoc_name;
            rcd_lads_bom_hdr.idoc_number := rcd_lads_control.idoc_number;
            rcd_lads_bom_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
            rcd_lads_bom_hdr.lads_date := sysdate;
            rcd_lads_bom_hdr.lads_status := '1';
            rcd_lads_bom_hdr.lads_flattened := '0'; 
            insert into lads_bom_hdr values rcd_lads_bom_hdr;
            rcd_lads_bom_det.detseq := 0;
         end if;

         /*-*/
         /* Insert the BOM detail
         /*-*/
         rcd_lads_bom_det.detseq := rcd_lads_bom_det.detseq + 1;
         rcd_lads_bom_det.msgfn := '005';
         rcd_lads_bom_det.matnr := rcd_lads_bom_hdr.matnr;
         rcd_lads_bom_det.stlal := rcd_lads_bom_hdr.stlal;
         rcd_lads_bom_det.werks := rcd_lads_bom_hdr.werks;
         rcd_lads_bom_det.posnr := trim(rcd_bom_data.posnr);
         rcd_lads_bom_det.postp := trim(rcd_bom_data.postp);
         rcd_lads_bom_det.idnrk := lads_trim_code(trim(rcd_bom_data.idnrk));
         rcd_lads_bom_det.menge := lads_to_number(replace(trim(rcd_bom_data.menge),'.',null))/1000;
         rcd_lads_bom_det.meins := trim(rcd_bom_data.meins);
         rcd_lads_bom_det.datuv := trim(rcd_bom_data.datuv);
         rcd_lads_bom_det.datub := '99991231';
         insert into lads_bom_det values rcd_lads_bom_det;

      end loop;
      close csr_bom_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_data;

end lads_saplad05;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_saplad05 for lads_app.lads_saplad05;
grant execute on lads_saplad05 to lics_app;
