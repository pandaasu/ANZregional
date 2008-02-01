/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : CLIO Reporting                                     */
/* Package : hk_sal_base_excel                                  */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : March 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_base_excel as

   /*-*/
   /* Public package methods
   /*-*/
   procedure set_parameter_string(par_parameter in varchar2, par_value in varchar2);
   procedure set_parameter_number(par_parameter in varchar2, par_value in number);
   procedure set_parameter_date(par_parameter in varchar2, par_value in date);
   procedure set_hierarchy(par_index in number, par_hierarchy in varchar2, par_adj_text in boolean);
   procedure set_hierarchy_column(par_index in number, par_column in varchar2, par_num_static in boolean, par_prt_supress in boolean);
   procedure add_group(par_heading in varchar2);
   procedure add_column(par_column in varchar2, par_heading in varchar2, par_dec_print in number, par_dec_round in number, par_sca_factor in number);
   procedure start_report(par_company_code in varchar2);
   procedure define_sheet(par_name in varchar2, par_depth in number);
   procedure start_sheet(par_htxt1 in varchar2, par_htxt2 in varchar2, par_htxt3 in varchar2);
   procedure retrieve_data;
   procedure end_sheet;

   /*-*/
   /* Public package definition variables
   /*-*/
   type rcd_parameter is record(par_text varchar2(128 char),
                                par_type varchar2(1 char),
                                par_char varchar2(128 char),
                                par_numb number,
                                par_date date);
   type typ_parameter is table of rcd_parameter index by varchar2(30);
   tbl_parameter typ_parameter;
   type rcd_hierarchy is record(hie_ssql varchar2(4000 char),
                                hie_tsql varchar2(4000 char),
                                hie_gsql varchar2(4000 char));
   type typ_hierarchy is table of rcd_hierarchy index by varchar2(30);
   tbl_hierarchy typ_hierarchy;
   type rcd_table is record(tab_name varchar2(4000 char),
                            tab_join varchar2(4000 char));
   type typ_table is table of rcd_table index by binary_integer;
   tbl_table typ_table;
   type rcd_column is record(col_tabi number,
                             col_htxt varchar2(1024 char),
                             col_ccnt number,
                             col_dsql varchar2(4000 char),
                             col_zsql varchar2(4000 char),
                             col_ctyp varchar2(1 char),
                             col_decp number,
                             col_decr number,
                             col_scle number,
                             col_ref1 varchar2(30 char),
                             col_ref2 varchar2(30 char),
                             col_lnd1 varchar2(30 char),
                             col_lnd2 varchar2(30 char));
   type typ_column is table of rcd_column index by varchar2(30);
   tbl_column typ_column;
   tbl_main_name varchar2(4000);
   tbl_main_join varchar2(4000);

end hk_sal_base_excel;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_base_excel as

   /*-*/
   /* Private package variables
   /*-*/
   LEVEL_MAX number := 7;
   HIERARCHY_MAX number := 15;
   COLUMN_MAX number := 100;
   VALUE_MAX number := 100;

   /*-*/
   /* Private package work variables
   /*-*/
   rcd_company company%rowtype;
   var_wrks_stat varchar2(1 char) := '0';
   var_wrks_name varchar2(64 char);
   var_wrks_hdep number;
   var_wrks_hlvl number;
   var_wrks_hstr number;
   var_wrks_hend number;
   var_wrks_hdet number;
   var_wrks_dets boolean;
   var_wrks_ctp3 boolean;
   var_wrks_cnt3 number;
   var_wrks_cend number;
   var_wrks_ccnt number;
   var_wrks_clid varchar2(2 char);
   var_wrks_rcnt number;
   var_wrks_rsav number;
   type rcd_wrkh is record(hie_name varchar2(30 char),
                           hie_srtv varchar2(128 char),
                           hie_txtv varchar2(128 char),
                           hie_savv varchar2(128 char),
                           hie_savt varchar2(128 char),
                           hie_rcnt number,
                           hie_atxt boolean);
   type typ_wrkh is table of rcd_wrkh index by binary_integer;
   tbl_wrkh typ_wrkh;
   type rcd_wrko is record(ovr_stat boolean,
                           ovr_psup boolean);
   type typ_wrko is table of rcd_wrko index by binary_integer;
   tbl_wrko typ_wrko;
   type rcd_wrkg is record(grp_htxt varchar2(1024 char),
                           grp_csix number,
                           grp_ceix number);
   type typ_wrkg is table of rcd_wrkg index by binary_integer;
   tbl_wrkg typ_wrkg;
   type rcd_wrkc is record(col_name varchar2(30 char),
                           col_htxt varchar2(1024 char),
                           col_decp number,
                           col_decr number,
                           col_scle number,
                           col_fmnt varchar2(30 char),
                           col_idx1 number,
                           col_idx2 number,
                           col_dsix number,
                           col_deix number);
   type typ_wrkc is table of rcd_wrkc index by binary_integer;
   tbl_wrkc typ_wrkc;
   type typ_wrkd is table of varchar2(256) index by binary_integer;
   tbl_wrkd typ_wrkd;
   type typ_wrkr is table of number index by binary_integer;
   tbl_wrkr typ_wrkr;
   type typ_wrkv is table of number index by binary_integer;
   tbl_wrkv typ_wrkv;
   type typ_wrkt is table of number index by binary_integer;
   tbl_wrkt typ_wrkt;

   /*-*/
   /* Private package methods
   /*-*/
   procedure do_reference(par_column in varchar2);
   procedure do_heading;
   procedure do_total;
   procedure do_dependant;
   procedure do_format;
   procedure do_border;

   /************************************************************/
   /* This procedure performs the set parameter string routine */
   /************************************************************/
   procedure set_parameter_string(par_parameter in varchar2, par_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;
      if not(tbl_parameter.exists(upper(par_parameter))) then
         raise_application_error(-20000, 'Parameter ' || par_parameter || ' does not exist');
      end if;
      if tbl_parameter(upper(par_parameter)).par_type != '1' then
         raise_application_error(-20000, 'Parameter ' || par_parameter || ' is not a string type');
      end if;

      /*-*/
      /* Set the parameter
      /*-*/
      tbl_parameter(upper(par_parameter)).par_char := par_value;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter_string;

   /************************************************************/
   /* This procedure performs the set parameter number routine */
   /************************************************************/
   procedure set_parameter_number(par_parameter in varchar2, par_value in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;
      if not(tbl_parameter.exists(upper(par_parameter))) then
         raise_application_error(-20000, 'Parameter ' || par_parameter || ' does not exist');
      end if;
      if tbl_parameter(upper(par_parameter)).par_type != '2' then
         raise_application_error(-20000, 'Parameter ' || par_parameter || ' is not a number type');
      end if;

      /*-*/
      /* Set the parameter
      /*-*/
      tbl_parameter(upper(par_parameter)).par_numb := par_value;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter_number;

   /**********************************************************/
   /* This procedure performs the set parameter date routine */
   /**********************************************************/
   procedure set_parameter_date(par_parameter in varchar2, par_value in date) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;
      if not(tbl_parameter.exists(upper(par_parameter))) then
         raise_application_error(-20000, 'Parameter ' || par_parameter || ' does not exist');
      end if;
      if tbl_parameter(upper(par_parameter)).par_type != '3' then
         raise_application_error(-20000, 'Parameter ' || par_parameter || ' is not a date type');
      end if;

      /*-*/
      /* Set the parameter
      /*-*/
      tbl_parameter(upper(par_parameter)).par_date := par_value;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_parameter_date;

   /*****************************************************/
   /* This procedure performs the set hierarchy routine */
   /*****************************************************/
   procedure set_hierarchy(par_index in number, par_hierarchy in varchar2, par_adj_text in boolean) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the hierarchy
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;
      if par_index < 1 then
         raise_application_error(-20000, 'Sheet hierarchy index must be greater than zero');
      end if;
      if par_index > var_wrks_hdep then
         raise_application_error(-20000, 'Sheet hierarchy index must not exceed defined hierarchy depth (' || var_wrks_hdep || ')');
      end if;
      if not(tbl_hierarchy.exists(upper(par_hierarchy))) then
         raise_application_error(-20000, 'Hierarchy ' || par_hierarchy || ' does not exist');
      end if;

      /*-*/
      /* Set the hierarchy
      /*-*/
      tbl_wrkh(par_index).hie_name := upper(par_hierarchy);
      tbl_wrkh(par_index).hie_atxt := par_adj_text;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_hierarchy;

   /************************************************************/
   /* This procedure performs the set hierarchy column routine */
   /************************************************************/
   procedure set_hierarchy_column(par_index in number, par_column in varchar2, par_num_static in boolean, par_prt_supress in boolean) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the hierarchy
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;
      if par_index < 1 then
         raise_application_error(-20000, 'Sheet hierarchy index must be greater than zero');
      end if;
      if par_index > var_wrks_hdep then
         raise_application_error(-20000, 'Sheet hierarchy index must not exceed defined hierarchy depth (' || var_wrks_hdep || ')');
      end if;

      /*-*/
      /* Set the hierarchy column override
      /*-*/
      for idx in 1..tbl_wrkc.count loop
         if tbl_wrkc(idx).col_name = upper(par_column) then
            tbl_wrko(((par_index-1)*tbl_wrkc.count)+idx).ovr_stat := par_num_static;
            tbl_wrko(((par_index-1)*tbl_wrkc.count)+idx).ovr_psup := par_prt_supress;
         end if;
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end set_hierarchy_column;

   /*************************************************/
   /* This procedure performs the add group routine */
   /*************************************************/
   procedure add_group(par_heading in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the column
      /*-*/
      if var_wrks_stat != '2' then
         raise_application_error(-20000, 'Sheet must be defined');
      end if;

      /*-*/
      /* Set the group
      /*-*/
      var_index := tbl_wrkg.count + 1;
      tbl_wrkg(var_index).grp_htxt := par_heading;
      tbl_wrkg(var_index).grp_csix := 0;
      tbl_wrkg(var_index).grp_ceix := 0;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_group;

   /**************************************************/
   /* This procedure performs the add column routine */
   /**************************************************/
   procedure add_column(par_column in varchar2, par_heading in varchar2, par_dec_print in number, par_dec_round in number, par_sca_factor in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the column
      /*-*/
      if var_wrks_stat != '2' then
         raise_application_error(-20000, 'Sheet must be defined');
      end if;
      if tbl_wrkg.count = 0 then
         raise_application_error(-20000, 'Sheet must have a group defined');
      end if;
      if not(tbl_column.exists(upper(par_column))) then
         raise_application_error(-20000, 'Column ' || par_column || ' does not exist');
      end if;
      if not(par_dec_print is null) and (par_dec_print < 0 or par_dec_print > 9) then
         raise_application_error(-20000, 'Column ' || par_column || ' decimal printing must be 0 - 9');
      end if;
      if not(par_dec_round is null) and (par_dec_round < 0 or par_dec_round > 9) then
         raise_application_error(-20000, 'Column ' || par_column || ' decimal rounding must be 0 - 9');
      end if;
      if not(par_sca_factor is null) and par_sca_factor < 0 then
         raise_application_error(-20000, 'Column ' || par_column || ' scaling factor must not be negative');
      end if;
      if not(par_dec_print is null) then
         if tbl_column(upper(par_column)).col_ctyp != '1' and
            tbl_column(upper(par_column)).col_ctyp != '2' and
            tbl_column(upper(par_column)).col_ctyp != '3' then
            raise_application_error(-20000, 'Column ' || par_column || ' must be a numeric type to specify decimal printing');
         end if;
      end if;
      if not(par_dec_round is null) then
         if tbl_column(upper(par_column)).col_ctyp != '1' and
            tbl_column(upper(par_column)).col_ctyp != '2' and
            tbl_column(upper(par_column)).col_ctyp != '3' then
            raise_application_error(-20000, 'Column ' || par_column || ' must be a numeric type to specify decimal rounding');
         end if;
      end if;
      if not(par_sca_factor is null) then
         if tbl_column(upper(par_column)).col_ctyp != '1' then
            raise_application_error(-20000, 'Column ' || par_column || ' must be a number type to specify a scaling factor');
         end if;
      end if;

      /*-*/
      /* Set the column
      /*-*/
      var_index := tbl_wrkc.count + 1;
      tbl_wrkc(var_index).col_name := upper(par_column);
      tbl_wrkc(var_index).col_htxt := tbl_column(upper(par_column)).col_htxt;
      tbl_wrkc(var_index).col_decp := tbl_column(upper(par_column)).col_decp;
      tbl_wrkc(var_index).col_decr := tbl_column(upper(par_column)).col_decr;
      tbl_wrkc(var_index).col_scle := tbl_column(upper(par_column)).col_scle;
      if not(par_heading is null) then
         tbl_wrkc(var_index).col_htxt := par_heading;
      end if;
      if tbl_column(upper(par_column)).col_ctyp != '4' then
         if not(par_dec_print is null) then
            tbl_wrkc(var_index).col_decp := par_dec_print;
         end if;
         if not(par_dec_round is null) then
            tbl_wrkc(var_index).col_decr := par_dec_round;
         end if;
         if not(par_sca_factor is null) then
            tbl_wrkc(var_index).col_scle := par_sca_factor;
         end if;
         if tbl_wrkc(var_index).col_decr = 0 then
            tbl_wrkc(var_index).col_fmnt := 'fm999999999999999999990';
         else
            tbl_wrkc(var_index).col_fmnt := 'fm';
            for idx in 1..21 loop
               if idx < 21 - tbl_wrkc(var_index).col_decr then
                  tbl_wrkc(var_index).col_fmnt := tbl_wrkc(var_index).col_fmnt || '9';
               elsif idx = 21 - tbl_wrkc(var_index).col_decr then
                  tbl_wrkc(var_index).col_fmnt := tbl_wrkc(var_index).col_fmnt || '0.';
               else
                  tbl_wrkc(var_index).col_fmnt := tbl_wrkc(var_index).col_fmnt || '0';
               end if;
            end loop;
         end if;
      end if;
      tbl_wrkc(var_index).col_dsix := var_wrks_ccnt + 1;
      tbl_wrkc(var_index).col_deix := var_wrks_ccnt + tbl_column(upper(par_column)).col_ccnt;
      if tbl_wrkg(tbl_wrkg.count).grp_csix = 0 then
         tbl_wrkg(tbl_wrkg.count).grp_csix := tbl_wrkc(var_index).col_dsix;
      end if;
      tbl_wrkg(tbl_wrkg.count).grp_ceix := tbl_wrkc(var_index).col_deix;
      var_wrks_ccnt := var_wrks_ccnt + tbl_column(upper(par_column)).col_ccnt;
      if var_wrks_ccnt > COLUMN_MAX then
         raise_application_error(-20000, 'Maximum of ' || COLUMN_MAX || ' columns exceeded');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_column;

   /****************************************************/
   /* This procedure performs the start report routine */
   /****************************************************/
   procedure start_report(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_company is 
         select *
           from company t01
          where t01.sap_company_code = par_company_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the company
      /*-*/
      var_found := true;
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         var_found := false;
      end if;
      close csr_company;
      if var_found = false then
         raise_application_error(-20000, 'Company ' || par_company_code || ' not found');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      var_wrks_stat := '1';
      xlxml_object.BeginReport;

      /*-*/
      /* Clear the variables
      /*-*/
      tbl_main_name := null;
      tbl_main_join := null;
      tbl_parameter.delete;
      tbl_hierarchy.delete;
      tbl_table.delete;
      tbl_column.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_report;

   /****************************************************/
   /* This procedure performs the define sheet routine */
   /****************************************************/
   procedure define_sheet(par_name in varchar2, par_depth in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the sheet
      /*-*/
      if var_wrks_stat != '1' then
         raise_application_error(-20000, 'Report not started or existing sheet not ended');
      end if;
      if par_name is null then
         raise_application_error(-20000, 'Sheet name must be specified');
      end if;
      if par_depth < 1 then
         raise_application_error(-20000, 'Sheet hierarchy depth must be greater than zero');
      end if;
      if par_depth > HIERARCHY_MAX then
         raise_application_error(-20000, 'Sheet hierarchy depth must not exceed maximum hierarchy depth (' || HIERARCHY_MAX || ')');
      end if;

      /*-*/
      /* Clear the sheet variables
      /*-*/
      var_wrks_stat := '2';
      var_wrks_name := par_name;
      var_wrks_hdep := par_depth;
      var_wrks_ccnt := 0;

      /*-*/
      /* Clear the sheet arrays
      /*-*/
      tbl_wrkh.delete;
      tbl_wrko.delete;
      tbl_wrkg.delete;
      tbl_wrkc.delete;
      tbl_wrkd.delete;
      tbl_wrkr.delete;
      tbl_wrkv.delete;
      tbl_wrkt.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_sheet;

   /***************************************************/
   /* This procedure performs the start sheet routine */
   /***************************************************/
   procedure start_sheet(par_htxt1 in varchar2, par_htxt2 in varchar2, par_htxt3 in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_wrk_string varchar2(4000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the sheet
      /*-*/
      if var_wrks_stat != '2' then
         raise_application_error(-20000, 'Sheet must be defined');
      end if;
      if par_htxt1 is null then
         raise_application_error(-20000, 'Sheet heading one must be specified');
      end if;
      if tbl_wrkg.count != 0 then
         if tbl_wrkc.count = 0 then
            raise_application_error(-20000, 'Sheet must have at least one column defined when group defined');
         end if;
      end if;

      /*-*/
      /* Clear the sheet variables
      /*-*/
      var_wrks_stat := '3';
      var_wrks_ctp3 := false;
      var_wrks_cnt3 := 0;
      var_wrks_cend := tbl_wrkc.count;
      var_wrks_clid := xlxml_object.GetColumnId(var_wrks_ccnt + 1);
      var_wrks_rsav := 0;
      var_wrks_rcnt := 0;
      var_wrks_dets := false;
      var_wrks_hlvl := 0;
      var_wrks_hstr := 1;
      var_wrks_hend := var_wrks_hdep-1;
      var_wrks_hdet := var_wrks_hdep;
      if var_wrks_hend > LEVEL_MAX then
         var_wrks_hstr := (var_wrks_hend - LEVEL_MAX) + 1;
      end if;

      /*-*/
      /* Resolve the calculated column type references
      /*-*/
      for idx in 1..var_wrks_cend loop
         if tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '2' or tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '3' then
            if tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '3' then
               var_wrks_ctp3 := true;
               var_wrks_cnt3 := var_wrks_cnt3 + 1;
            end if;
            tbl_wrkc(idx).col_idx1 := 0;
            tbl_wrkc(idx).col_idx2 := 0;
            for idy in 1..tbl_wrkc.count loop
               if tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '1' then
                  if tbl_column(tbl_wrkc(idx).col_name).col_ref1 = tbl_wrkc(idy).col_name then
                     tbl_wrkc(idx).col_idx1 := idy;
                  end if;
                  if tbl_column(tbl_wrkc(idx).col_name).col_ref2 = tbl_wrkc(idy).col_name then
                     tbl_wrkc(idx).col_idx2 := idy;
                  end if;
               end if;
               if tbl_wrkc(idx).col_idx1 != 0 and
                  tbl_wrkc(idx).col_idx2 != 0 then
                  exit;
               end if;
            end loop;
            if tbl_wrkc(idx).col_idx1 = 0 then
               do_reference(tbl_column(tbl_wrkc(idx).col_name).col_ref1);
               tbl_wrkc(idx).col_idx1 := tbl_wrkc.count;
            end if;
            if tbl_wrkc(idx).col_idx2 = 0 then
               do_reference(tbl_column(tbl_wrkc(idx).col_name).col_ref2);
               tbl_wrkc(idx).col_idx2 := tbl_wrkc.count;
            end if;
         end if;
      end loop;

      /*-*/
      /* Initialise the hierarchy/override/value arrays
      /*-*/
      tbl_wrko.delete;
      tbl_wrkr.delete;
      for idx in 1..VALUE_MAX loop
         tbl_wrkd(idx) := null;
      end loop;
      for idx in 1..VALUE_MAX loop
         tbl_wrkv(idx) := 0;
      end loop;
      for idx in 1..var_wrks_hdep loop
         tbl_wrkh(idx).hie_name := null;
         tbl_wrkh(idx).hie_srtv := null;
         tbl_wrkh(idx).hie_txtv := null;
         tbl_wrkh(idx).hie_savv := '********';
         tbl_wrkh(idx).hie_rcnt := 0;
         tbl_wrkh(idx).hie_atxt := false;
         if idx < var_wrks_hdep then
            for idy in 1..VALUE_MAX loop
               tbl_wrkv((idx*VALUE_MAX)+idy) := 0;
            end loop;
         end if;
         for idy in 1..tbl_wrkc.count loop
            tbl_wrko(((idx-1)*tbl_wrkc.count)+idy).ovr_stat := false;
            tbl_wrko(((idx-1)*tbl_wrkc.count)+idy).ovr_psup := false;
         end loop;
      end loop;

      /*-*/
      /* Add the new sheet
      /*-*/
      xlxml_object.AddSheet(var_wrks_name);

      /*-*/
      /* Report heading line 1
      /*-*/
      var_wrks_rcnt := var_wrks_rcnt + 1;
      var_wrk_string := par_htxt1;
      xlxml_object.SetRange('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), 'A' || to_char(var_wrks_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetHeadingType(1), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 2
      /*-*/
      if not(par_htxt2 is null) then
         var_wrks_rcnt := var_wrks_rcnt + 1;
         var_wrk_string := par_htxt2;
         xlxml_object.SetRange('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), 'A' || to_char(var_wrks_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.TYPE_HEADING_SM, -2, 0, false, var_wrk_string);
      end if;

      /*-*/
      /* Report heading line 3
      /*-*/
      if not(par_htxt3 is null) then
         var_wrks_rcnt := var_wrks_rcnt + 1;
         var_wrk_string := par_htxt3;
      xlxml_object.SetRange('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), 'A' || to_char(var_wrks_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);
      end if;

      /*-*/
      /* Report heading line 4
      /*-*/
      var_wrks_rcnt := var_wrks_rcnt + 1;
      var_wrk_string := 'Company: ' || rcd_company.company_desc;
      xlxml_object.SetRange('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), 'A' || to_char(var_wrks_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetHeadingType(2), -2, 0, false, var_wrk_string);

      /*-*/
      /* Report heading line 5 (only required when any group headings)
      /*-*/
      var_found := false;
      for idx in 1..tbl_wrkg.count loop
         if not(tbl_wrkg(idx).grp_htxt is null) then
            var_found := true;
         end if;
      end loop;
      if var_found = true then
         var_wrks_rcnt := var_wrks_rcnt + 1;
         xlxml_object.SetRange('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), null, xlxml_object.GetHeadingType(7), -1, 0, false, null);
         for idx in 1..tbl_wrkg.count loop
            if tbl_wrkg(idx).grp_csix = tbl_wrkg(idx).grp_ceix then
               xlxml_object.SetRange(xlxml_object.GetColumnId(tbl_wrkg(idx).grp_csix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkg(idx).grp_csix+1) || to_char(var_wrks_rcnt,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, tbl_wrkg(idx).grp_htxt);
            else
               xlxml_object.SetRange(xlxml_object.GetColumnId(tbl_wrkg(idx).grp_csix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkg(idx).grp_csix+1) || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetColumnId(tbl_wrkg(idx).grp_csix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkg(idx).grp_ceix+1) || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetHeadingType(7), -2, 0, false, tbl_wrkg(idx).grp_htxt);
            end if;
            xlxml_object.SetHeadingBorder(xlxml_object.GetColumnId(tbl_wrkg(idx).grp_csix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkg(idx).grp_ceix+1) || to_char(var_wrks_rcnt,'FM999999990'), 'ALL');
         end loop;
      end if;

      /*-*/
      /* Report heading line 6
      /*-*/
      var_wrks_rcnt := var_wrks_rcnt + 1;
      xlxml_object.SetRange('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), null, xlxml_object.GetHeadingType(7), -1, 0, false, 'Report Hierarchy');
      xlxml_object.SetHeadingBorder('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'), 'TLR');
      for idx in 1..var_wrks_cend loop
         if tbl_wrkc(idx).col_dsix = tbl_wrkc(idx).col_deix then
            xlxml_object.SetRange(xlxml_object.GetColumnId(tbl_wrkc(idx).col_dsix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkc(idx).col_dsix+1) || to_char(var_wrks_rcnt,'FM999999990'), null, xlxml_object.GetHeadingType(7), -2, 0, false, tbl_wrkc(idx).col_htxt);
         else
            xlxml_object.SetRangeArray(xlxml_object.GetColumnId(tbl_wrkc(idx).col_dsix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkc(idx).col_dsix+1) || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetColumnId(tbl_wrkc(idx).col_dsix+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkc(idx).col_deix+1) || to_char(var_wrks_rcnt,'FM999999990'), xlxml_object.GetHeadingType(7), -2, tbl_wrkc(idx).col_htxt);
         end if;
         for idy in tbl_wrkc(idx).col_dsix..tbl_wrkc(idx).col_deix loop
            xlxml_object.SetHeadingBorder(xlxml_object.GetColumnId(idy+1) || to_char(var_wrks_rcnt,'FM999999990') || ':' || xlxml_object.GetColumnId(idy+1) || to_char(var_wrks_rcnt,'FM999999990'), 'TLR');
         end loop;
      end loop;

      /*-*/
      /* Initialise the row save
      /*-*/
      var_wrks_rsav := var_wrks_rcnt + 1;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_sheet;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   procedure retrieve_data is

      /*-*/
      /* Variable definitions
      /*-*/
      var_hie_srt_01 varchar2(128 char);
      var_hie_srt_02 varchar2(128 char);
      var_hie_srt_03 varchar2(128 char);
      var_hie_srt_04 varchar2(128 char);
      var_hie_srt_05 varchar2(128 char);
      var_hie_srt_06 varchar2(128 char);
      var_hie_srt_07 varchar2(128 char);
      var_hie_srt_08 varchar2(128 char);
      var_hie_srt_09 varchar2(128 char);
      var_hie_srt_10 varchar2(128 char);
      var_hie_srt_11 varchar2(128 char);
      var_hie_srt_12 varchar2(128 char);
      var_hie_srt_13 varchar2(128 char);
      var_hie_srt_14 varchar2(128 char);
      var_hie_srt_15 varchar2(128 char);
      var_hie_txt_01 varchar2(128 char);
      var_hie_txt_02 varchar2(128 char);
      var_hie_txt_03 varchar2(128 char);
      var_hie_txt_04 varchar2(128 char);
      var_hie_txt_05 varchar2(128 char);
      var_hie_txt_06 varchar2(128 char);
      var_hie_txt_07 varchar2(128 char);
      var_hie_txt_08 varchar2(128 char);
      var_hie_txt_09 varchar2(128 char);
      var_hie_txt_10 varchar2(128 char);
      var_hie_txt_11 varchar2(128 char);
      var_hie_txt_12 varchar2(128 char);
      var_hie_txt_13 varchar2(128 char);
      var_hie_txt_14 varchar2(128 char);
      var_hie_txt_15 varchar2(128 char);
      var_col_val_001 varchar2(256 char);
      var_col_val_002 varchar2(256 char);
      var_col_val_003 varchar2(256 char);
      var_col_val_004 varchar2(256 char);
      var_col_val_005 varchar2(256 char);
      var_col_val_006 varchar2(256 char);
      var_col_val_007 varchar2(256 char);
      var_col_val_008 varchar2(256 char);
      var_col_val_009 varchar2(256 char);
      var_col_val_010 varchar2(256 char);
      var_col_val_011 varchar2(256 char);
      var_col_val_012 varchar2(256 char);
      var_col_val_013 varchar2(256 char);
      var_col_val_014 varchar2(256 char);
      var_col_val_015 varchar2(256 char);
      var_col_val_016 varchar2(256 char);
      var_col_val_017 varchar2(256 char);
      var_col_val_018 varchar2(256 char);
      var_col_val_019 varchar2(256 char);
      var_col_val_020 varchar2(256 char);
      var_col_val_021 varchar2(256 char);
      var_col_val_022 varchar2(256 char);
      var_col_val_023 varchar2(256 char);

      var_col_val_024 varchar2(256 char);
      var_col_val_025 varchar2(256 char);
      var_col_val_026 varchar2(256 char);
      var_col_val_027 varchar2(256 char);
      var_col_val_028 varchar2(256 char);
      var_col_val_029 varchar2(256 char);
      var_col_val_030 varchar2(256 char);
      var_col_val_031 varchar2(256 char);
      var_col_val_032 varchar2(256 char);
      var_col_val_033 varchar2(256 char);
      var_col_val_034 varchar2(256 char);
      var_col_val_035 varchar2(256 char);
      var_col_val_036 varchar2(256 char);
      var_col_val_037 varchar2(256 char);
      var_col_val_038 varchar2(256 char);
      var_col_val_039 varchar2(256 char);
      var_col_val_040 varchar2(256 char);
      var_col_val_041 varchar2(256 char);
      var_col_val_042 varchar2(256 char);
      var_col_val_043 varchar2(256 char);
      var_col_val_044 varchar2(256 char);
      var_col_val_045 varchar2(256 char);
      var_col_val_046 varchar2(256 char);
      var_col_val_047 varchar2(256 char);
      var_col_val_048 varchar2(256 char);
      var_col_val_049 varchar2(256 char);
      var_col_val_050 varchar2(256 char);
      var_col_val_051 varchar2(256 char);
      var_col_val_052 varchar2(256 char);
      var_col_val_053 varchar2(256 char);
      var_col_val_054 varchar2(256 char);
      var_col_val_055 varchar2(256 char);
      var_col_val_056 varchar2(256 char);
      var_col_val_057 varchar2(256 char);
      var_col_val_058 varchar2(256 char);
      var_col_val_059 varchar2(256 char);
      var_col_val_060 varchar2(256 char);
      var_col_val_061 varchar2(256 char);
      var_col_val_062 varchar2(256 char);
      var_col_val_063 varchar2(256 char);
      var_col_val_064 varchar2(256 char);
      var_col_val_065 varchar2(256 char);
      var_col_val_066 varchar2(256 char);
      var_col_val_067 varchar2(256 char);
      var_col_val_068 varchar2(256 char);
      var_col_val_069 varchar2(256 char);
      var_col_val_070 varchar2(256 char);
      var_col_val_071 varchar2(256 char);
      var_col_val_072 varchar2(256 char);
      var_col_val_073 varchar2(256 char);
      var_col_val_074 varchar2(256 char);
      var_col_val_075 varchar2(256 char);
      var_col_val_076 varchar2(256 char);
      var_col_val_077 varchar2(256 char);
      var_col_val_078 varchar2(256 char);
      var_col_val_079 varchar2(256 char);
      var_col_val_080 varchar2(256 char);
      var_col_val_081 varchar2(256 char);
      var_col_val_082 varchar2(256 char);
      var_col_val_083 varchar2(256 char);
      var_col_val_084 varchar2(256 char);
      var_col_val_085 varchar2(256 char);
      var_col_val_086 varchar2(256 char);
      var_col_val_087 varchar2(256 char);
      var_col_val_088 varchar2(256 char);
      var_col_val_089 varchar2(256 char);
      var_col_val_090 varchar2(256 char);
      var_col_val_091 varchar2(256 char);
      var_col_val_092 varchar2(256 char);
      var_col_val_093 varchar2(256 char);
      var_col_val_094 varchar2(256 char);
      var_col_val_095 varchar2(256 char);
      var_col_val_096 varchar2(256 char);
      var_col_val_097 varchar2(256 char);
      var_col_val_098 varchar2(256 char);
      var_col_val_099 varchar2(256 char);
      var_col_val_100 varchar2(256 char);
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_dynamic_sql varchar2(32767 char);
      var_tab_literal varchar2(4096 char);
      var_jon_literal varchar2(4096 char);
      var_hie_literal varchar2(4096 char);
      var_col_literal varchar2(16384 char);
      var_zer_literal varchar2(4096 char);
      var_grp_literal varchar2(2048 char);
      var_srt_literal varchar2(2048 char);
      var_par_literal varchar2(2048 char);
      var_ref1_val number;
      var_ref2_val number;
      var_index number;
      type typ_dynamic is ref cursor;
      csr_dynamic typ_dynamic;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the query
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;
      for idx in 1..var_wrks_hdep loop
         if tbl_wrkh(idx).hie_name is null then
            raise_application_error(-20000, 'Sheet hierarchy index ' || idx || ' has not been defined');
         end if;
      end loop;

      /*-*/
      /* Initialise the hierarchy literal
      /*-*/
      var_hie_literal := null;
      for idx in 1..var_wrks_hdet loop
         var_hie_literal := var_hie_literal || tbl_hierarchy(tbl_wrkh(idx).hie_name).hie_ssql || ' as hie_srt_' || to_char(idx,'fm00') || ',';
      end loop;
      if var_wrks_hdet < HIERARCHY_MAX then
         for idx in var_wrks_hdet+1..HIERARCHY_MAX loop
            var_hie_literal := var_hie_literal || 'null as hie_srt_' || to_char(idx,'fm00') || ',';
         end loop;
      end if;
      for idx in 1..var_wrks_hdet loop
         var_hie_literal := var_hie_literal || tbl_hierarchy(tbl_wrkh(idx).hie_name).hie_tsql || ' as hie_txt_' || to_char(idx,'fm00') || ',';
      end loop;
      if var_wrks_hdet < HIERARCHY_MAX then
         for idx in var_wrks_hdet+1..HIERARCHY_MAX loop
            var_hie_literal := var_hie_literal || 'null as hie_txt_' || to_char(idx,'fm00') || ',';
         end loop;
      end if;

      /*-*/
      /* Initialise the group/sort literals
      /*-*/
      var_grp_literal := null;
      var_srt_literal := null;
      for idx in 1..var_wrks_hdet loop
         if not(tbl_hierarchy(tbl_wrkh(idx).hie_name).hie_gsql is null) then
            var_grp_literal := var_grp_literal || tbl_hierarchy(tbl_wrkh(idx).hie_name).hie_gsql;
            var_srt_literal := var_srt_literal || 'hie_srt_' || to_char(idx,'fm00');
            if idx < var_wrks_hdet then
               var_grp_literal := var_grp_literal || ',';
               var_srt_literal := var_srt_literal || ',';
            end if;
         end if;
      end loop;

      /*-*/
      /* Initialise the column literal
      /*-*/
      var_col_literal := null;
      for idx in 1..tbl_wrkc.count loop
         var_col_literal := var_col_literal || tbl_column(tbl_wrkc(idx).col_name).col_dsql;
         if idx < tbl_wrkc.count then
            var_col_literal := var_col_literal || ',';
         end if;
      end loop;
      if var_wrks_ccnt < COLUMN_MAX then
         if var_wrks_ccnt > 0 then
            var_col_literal := var_col_literal || ',';
         end if;
         for idx in var_wrks_ccnt+1..COLUMN_MAX loop
            var_col_literal := var_col_literal || 'null';
            if idx < COLUMN_MAX then
               var_col_literal := var_col_literal || ',';
            end if;
         end loop;
      end if;

      /*-*/
      /* Initialise the table/join literals
      /*-*/
      tbl_wrkt.delete;
      var_tab_literal := tbl_main_name;
      var_jon_literal := tbl_main_join;
      for idx in 1..tbl_wrkc.count loop
         if tbl_column(tbl_wrkc(idx).col_name).col_tabi != 1 then
            if not(tbl_wrkt.exists(tbl_column(tbl_wrkc(idx).col_name).col_tabi)) then
               var_tab_literal := var_tab_literal || ',' || tbl_table(tbl_column(tbl_wrkc(idx).col_name).col_tabi).tab_name;
               var_jon_literal := var_jon_literal || ' ' || tbl_table(tbl_column(tbl_wrkc(idx).col_name).col_tabi).tab_join;
               tbl_wrkt(tbl_column(tbl_wrkc(idx).col_name).col_tabi) := tbl_column(tbl_wrkc(idx).col_name).col_tabi;
            end if;
         end if;
      end loop;
      var_tab_literal := replace(var_tab_literal,':A',''''||rcd_company.sap_company_code||'''');
      var_jon_literal := replace(var_jon_literal,':A',''''||rcd_company.sap_company_code||'''');

      /*-*/
      /* Initialise the parameter literals
      /*-*/
      var_par_literal := null;
      if tbl_parameter.exists('BUS_SGMNT_CODE') and not(tbl_parameter('BUS_SGMNT_CODE').par_char is null) then
         var_par_literal := var_par_literal || ' and t02.sap_bus_sgmnt_code = ''' || tbl_parameter('BUS_SGMNT_CODE').par_char || '''';
      end if;
      if tbl_parameter.exists('BDT_CODE') and not(tbl_parameter('BDT_CODE').par_char is null) then
         var_par_literal := var_par_literal || ' and t02.sap_bdt_code = ''' || tbl_parameter('BDT_CODE').par_char || '''';
      end if;
      if tbl_parameter.exists('BRAND_CODE') and not(tbl_parameter('BRAND_CODE').par_char is null) then
         var_par_literal := var_par_literal || ' and t02.sap_brand_flag_code = ''' || tbl_parameter('BRAND_CODE').par_char || '''';
      end if;
      if tbl_parameter.exists('STD_HIER01_CODE') and not(tbl_parameter('STD_HIER01_CODE').par_char is null) then
         var_par_literal := var_par_literal || ' and t03.sap_cust_code_level_1 = ''' || tbl_parameter('STD_HIER01_CODE').par_char || '''';
      end if;
      if tbl_parameter.exists('STD_HIER02_CODE') and not(tbl_parameter('STD_HIER02_CODE').par_char is null) then
         var_par_literal := var_par_literal || ' and t03.sap_cust_code_level_2 = ''' || tbl_parameter('STD_HIER02_CODE').par_char || '''';
      end if;
      if tbl_parameter.exists('STD_HIER03_CODE') and not(tbl_parameter('STD_HIER03_CODE').par_char is null) then
         var_par_literal := var_par_literal || ' and t03.sap_cust_code_level_3 = ''' || tbl_parameter('STD_HIER03_CODE').par_char || '''';
      end if;

      /*-*/
      /* Initialise the zero literal
      /*-*/
      var_zer_literal := null;
      for idx in 1..tbl_wrkc.count loop
         if tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '1' then
            if var_zer_literal is null then
               var_zer_literal := var_zer_literal || ' and (' || tbl_column(tbl_wrkc(idx).col_name).col_zsql;
            else
               var_zer_literal := var_zer_literal || ' or ' || tbl_column(tbl_wrkc(idx).col_name).col_zsql;
            end if;
         end if;
      end loop;
      if not(var_zer_literal is null) then
         var_zer_literal := var_zer_literal || ')';
      end if;

      /*-*/
      /* Initialise the query
      /*-*/ 
      var_dynamic_sql := 'select ' || var_hie_literal || var_col_literal || ' from ' || var_tab_literal || ' where ' || var_jon_literal || var_par_literal || var_zer_literal || ' group by ' || var_grp_literal || ' order by ' || var_srt_literal;

      /*-*/
      /* Retrieve the detail rows
      /*-*/
      open csr_dynamic for var_dynamic_sql;
      loop
         fetch csr_dynamic into var_hie_srt_01,
                                var_hie_srt_02,
                                var_hie_srt_03,
                                var_hie_srt_04,
                                var_hie_srt_05,
                                var_hie_srt_06,
                                var_hie_srt_07,
                                var_hie_srt_08,
                                var_hie_srt_09,
                                var_hie_srt_10,
                                var_hie_srt_11,
                                var_hie_srt_12,
                                var_hie_srt_13,
                                var_hie_srt_14,
                                var_hie_srt_15,
                                var_hie_txt_01,
                                var_hie_txt_02,
                                var_hie_txt_03,
                                var_hie_txt_04,
                                var_hie_txt_05,
                                var_hie_txt_06,
                                var_hie_txt_07,
                                var_hie_txt_08,
                                var_hie_txt_09,
                                var_hie_txt_10,
                                var_hie_txt_11,
                                var_hie_txt_12,
                                var_hie_txt_13,
                                var_hie_txt_14,
                                var_hie_txt_15,
                                var_col_val_001,
                                var_col_val_002,
                                var_col_val_003,
                                var_col_val_004,
                                var_col_val_005,
                                var_col_val_006,
                                var_col_val_007,
                                var_col_val_008,
                                var_col_val_009,
                                var_col_val_010,
                                var_col_val_011,
                                var_col_val_012,
                                var_col_val_013,
                                var_col_val_014,
                                var_col_val_015,
                                var_col_val_016,
                                var_col_val_017,
                                var_col_val_018,
                                var_col_val_019,
                                var_col_val_020,
                                var_col_val_021,
                                var_col_val_022,
                                var_col_val_023,
                 
               var_col_val_024,
                                var_col_val_025,
                                var_col_val_026,
                                var_col_val_027,
                                var_col_val_028,
                                var_col_val_029,
                                var_col_val_030,
                                var_col_val_031,
                                var_col_val_032,
                                var_col_val_033,
                                var_col_val_034,
                                var_col_val_035,
                                var_col_val_036,
                                var_col_val_037,
                                var_col_val_038,
                                var_col_val_039,
                                var_col_val_040,
                                var_col_val_041,
                                var_col_val_042,
                                var_col_val_043,
                                var_col_val_044,
                                var_col_val_045,
                                var_col_val_046,
                                var_col_val_047,
                                var_col_val_048,
                                var_col_val_049,
                                var_col_val_050,
                                var_col_val_051,
                                var_col_val_052,
                                var_col_val_053,
                                var_col_val_054,
                                var_col_val_055,
                                var_col_val_056,
                                var_col_val_057,
                                var_col_val_058,
                                var_col_val_059,
                                var_col_val_060,
                                var_col_val_061,
                                var_col_val_062,
                                var_col_val_063,
                                var_col_val_064,
                                var_col_val_065,
                                var_col_val_066,
                                var_col_val_067,
                                var_col_val_068,
                                var_col_val_069,
                                var_col_val_070,
                                var_col_val_071,
                                var_col_val_072,
                                var_col_val_073,
                                var_col_val_074,
                                var_col_val_075,
                                var_col_val_076,
                                var_col_val_077,
                                var_col_val_078,
                                var_col_val_079,
                                var_col_val_080,
                                var_col_val_081,
                                var_col_val_082,
                                var_col_val_083,
                                var_col_val_084,
                                var_col_val_085,
                                var_col_val_086,
                                var_col_val_087,
                                var_col_val_088,
                                var_col_val_089,
                                var_col_val_090,
                                var_col_val_091,
                                var_col_val_092,
                                var_col_val_093,
                                var_col_val_094,
                                var_col_val_095,
                                var_col_val_096,
                                var_col_val_097,
                                var_col_val_098,
                                var_col_val_099,
                                var_col_val_100;
         if csr_dynamic%notfound then
            exit;
         end if;

         /*-*/
         /* Set the hierarchy sort values
         /*-*/
         tbl_wrkh(1).hie_srtv := var_hie_srt_01;
         tbl_wrkh(2).hie_srtv := var_hie_srt_02;
         tbl_wrkh(3).hie_srtv := var_hie_srt_03;
         tbl_wrkh(4).hie_srtv := var_hie_srt_04;
         tbl_wrkh(5).hie_srtv := var_hie_srt_05;
         tbl_wrkh(6).hie_srtv := var_hie_srt_06;
         tbl_wrkh(7).hie_srtv := var_hie_srt_07;
         tbl_wrkh(8).hie_srtv := var_hie_srt_08;
         tbl_wrkh(9).hie_srtv := var_hie_srt_09;
         tbl_wrkh(10).hie_srtv := var_hie_srt_10;
         tbl_wrkh(11).hie_srtv := var_hie_srt_11;
         tbl_wrkh(12).hie_srtv := var_hie_srt_12;
         tbl_wrkh(13).hie_srtv := var_hie_srt_13;
         tbl_wrkh(14).hie_srtv := var_hie_srt_14;
         tbl_wrkh(15).hie_srtv := var_hie_srt_15;

         /*-*/
         /* Set the hierarchy text values
         /*-*/
         tbl_wrkh(1).hie_txtv := var_hie_txt_01;
         tbl_wrkh(2).hie_txtv := var_hie_txt_02;
         tbl_wrkh(3).hie_txtv := var_hie_txt_03;
         tbl_wrkh(4).hie_txtv := var_hie_txt_04;
         tbl_wrkh(5).hie_txtv := var_hie_txt_05;
         tbl_wrkh(6).hie_txtv := var_hie_txt_06;
         tbl_wrkh(7).hie_txtv := var_hie_txt_07;
         tbl_wrkh(8).hie_txtv := var_hie_txt_08;
         tbl_wrkh(9).hie_txtv := var_hie_txt_09;
         tbl_wrkh(10).hie_txtv := var_hie_txt_10;
         tbl_wrkh(11).hie_txtv := var_hie_txt_11;
         tbl_wrkh(12).hie_txtv := var_hie_txt_12;
         tbl_wrkh(13).hie_txtv := var_hie_txt_13;
         tbl_wrkh(14).hie_txtv := var_hie_txt_14;
         tbl_wrkh(15).hie_txtv := var_hie_txt_15;

         /*-*/
         /* Set the base values
         /*-*/
         tbl_wrkd(1) := var_col_val_001;
         tbl_wrkd(2) := var_col_val_002;
         tbl_wrkd(3) := var_col_val_003;
         tbl_wrkd(4) := var_col_val_004;
         tbl_wrkd(5) := var_col_val_005;
         tbl_wrkd(6) := var_col_val_006;
         tbl_wrkd(7) := var_col_val_007;
         tbl_wrkd(8) := var_col_val_008;
         tbl_wrkd(9) := var_col_val_009;
         tbl_wrkd(10) := var_col_val_010;
         tbl_wrkd(11) := var_col_val_011;
         tbl_wrkd(12) := var_col_val_012;
         tbl_wrkd(13) := var_col_val_013;
         tbl_wrkd(14) := var_col_val_014;
         tbl_wrkd(15) := var_col_val_015;
         tbl_wrkd(16) := var_col_val_016;
         tbl_wrkd(17) := var_col_val_017;
         tbl_wrkd(18) := var_col_val_018;
         tbl_wrkd(19) := var_col_val_019;
         tbl_wrkd(20) := var_col_val_020;
         tbl_wrkd(21) := var_col_val_021;
         tbl_wrkd(22) := var_col_val_022;
         tbl_wrkd(23) := var_col_val_023;
         tbl_wrkd(24) := var_col_val_024;
         tbl_wrkd(25) := var_col_val_025;
         tbl_wrkd(26) := var_col_val_026;
         tbl_wrkd(27) := var_col_val_027;
         tbl_wrkd(28) := var_col_val_028;
         tbl_wrkd(29) := var_col_val_029;
         tbl_wrkd(30) := var_col_val_030;
         tbl_wrkd(31) := var_col_val_031;
         tbl_wrkd(32) := var_col_val_032;
         tbl_wrkd(33) := var_col_val_033;
         tbl_wrkd(34) := var_col_val_034;
         tbl_wrkd(35) := var_col_val_035;
         tbl_wrkd(36) := var_col_val_036;
         tbl_wrkd(37) := var_col_val_037;
         tbl_wrkd(38) := var_col_val_038;
         tbl_wrkd(39) := var_col_val_039;
         tbl_wrkd(40) := var_col_val_040;
         tbl_wrkd(41) := var_col_val_041;
         tbl_wrkd(42) := var_col_val_042;
         tbl_wrkd(43) := var_col_val_043;
         tbl_wrkd(44) := var_col_val_044;
         tbl_wrkd(45) := var_col_val_045;
         tbl_wrkd(46) := var_col_val_046;
         tbl_wrkd(47) := var_col_val_047;
         tbl_wrkd(48) := var_col_val_048;
         tbl_wrkd(49) := var_col_val_049;
         tbl_wrkd(50) := var_col_val_050;
         tbl_wrkd(51) := var_col_val_051;
         tbl_wrkd(52) := var_col_val_052;
         tbl_wrkd(53) := var_col_val_053;
         tbl_wrkd(54) := var_col_val_054;
         tbl_wrkd(55) := var_col_val_055;
         tbl_wrkd(56) := var_col_val_056;
         tbl_wrkd(57) := var_col_val_057;
         tbl_wrkd(58) := var_col_val_058;
         tbl_wrkd(59) := var_col_val_059;
         tbl_wrkd(60) := var_col_val_060;
         tbl_wrkd(61) := var_col_val_061;
         tbl_wrkd(62) := var_col_val_062;
         tbl_wrkd(63) := var_col_val_063;
         tbl_wrkd(64) := var_col_val_064;
         tbl_wrkd(65) := var_col_val_065;
         tbl_wrkd(66) := var_col_val_066;
         tbl_wrkd(67) := var_col_val_067;
         tbl_wrkd(68) := var_col_val_068;
         tbl_wrkd(69) := var_col_val_069;
         tbl_wrkd(70) := var_col_val_070;
         tbl_wrkd(71) := var_col_val_071;
         tbl_wrkd(72) := var_col_val_072;
         tbl_wrkd(73) := var_col_val_073;
         tbl_wrkd(74) := var_col_val_074;
         tbl_wrkd(75) := var_col_val_075;
         tbl_wrkd(76) := var_col_val_076;
         tbl_wrkd(77) := var_col_val_077;
         tbl_wrkd(78) := var_col_val_078;
         tbl_wrkd(79) := var_col_val_079;
         tbl_wrkd(80) := var_col_val_080;
         tbl_wrkd(81) := var_col_val_081;
         tbl_wrkd(82) := var_col_val_082;
         tbl_wrkd(83) := var_col_val_083;
         tbl_wrkd(84) := var_col_val_084;
         tbl_wrkd(85) := var_col_val_085;
         tbl_wrkd(86) := var_col_val_086;
         tbl_wrkd(87) := var_col_val_087;
         tbl_wrkd(88) := var_col_val_088;
         tbl_wrkd(89) := var_col_val_089;
         tbl_wrkd(90) := var_col_val_090;
         tbl_wrkd(91) := var_col_val_091;
         tbl_wrkd(92) := var_col_val_092;
         tbl_wrkd(93) := var_col_val_093;
         tbl_wrkd(94) := var_col_val_094;
         tbl_wrkd(95) := var_col_val_095;
         tbl_wrkd(96) := var_col_val_096;
         tbl_wrkd(97) := var_col_val_097;
         tbl_wrkd(98) := var_col_val_098;
         tbl_wrkd(99) := var_col_val_099;
         tbl_wrkd(100) := var_col_val_100;

         /*-*/
         /* Scale and round the detail numeric values
         /*-*/
         for idx in 1..tbl_wrkc.count loop
            if tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '1' then
               for idy in tbl_wrkc(idx).col_dsix..tbl_wrkc(idx).col_deix loop
                  tbl_wrkv(idy) := round(to_number(tbl_wrkd(idy))/tbl_wrkc(idx).col_scle,tbl_wrkc(idx).col_decr);
               end loop;
            end if;
         end loop;

         /*-*/
         /* Process summary levels when defined
         /*-*/
         if var_wrks_hend > 0 then

            /*-*/
            /* Adjust the hierarchy text values as required
            /* **note** has to be from level 2 onwards as lookback is used
            /*-*/
            for idx in 2..var_wrks_hend loop
               if tbl_wrkh(idx).hie_atxt = true then
                  if tbl_wrkh(idx).hie_txtv != tbl_wrkh(idx-1).hie_txtv then
                     tbl_wrkh(idx).hie_txtv := tbl_wrkh(idx-1).hie_txtv || ' ' || tbl_wrkh(idx).hie_txtv;
                  end if;
               end if;
            end loop;

            /*-*/
            /* Check for hierarchy level changes and process when required
            /* 1. Find the highest summary level change
            /* 2. Process totals when any details exist
            /* 3. Process headings
            /*-*/
            var_wrks_hlvl := 0;
            for idx in reverse 1..var_wrks_hend loop
               if tbl_wrkh(idx).hie_srtv != tbl_wrkh(idx).hie_savv then
                  var_wrks_hlvl := idx;
               end if;
            end loop;
            if var_wrks_hlvl != 0 then
               if var_wrks_dets = true then
                  do_total;
               end if;
               do_heading;
            end if;

            /*-*/
            /* Accumulate/set the parent hierarchy numeric values
            /*-*/
            for idy in 1..tbl_wrkc.count loop
               if tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '1' then
                  if tbl_wrko(((var_wrks_hend-1)*tbl_wrkc.count)+idy).ovr_stat = false then
                     for idz in tbl_wrkc(idy).col_dsix..tbl_wrkc(idy).col_deix loop
                        tbl_wrkv((var_wrks_hend*VALUE_MAX)+idz) := tbl_wrkv((var_wrks_hend*VALUE_MAX)+idz) + tbl_wrkv(idz);
                     end loop;
                  else
                     for idz in tbl_wrkc(idy).col_dsix..tbl_wrkc(idy).col_deix loop
                        tbl_wrkv((var_wrks_hend*VALUE_MAX)+idz) := tbl_wrkv(idz);
                     end loop;
                  end if;
               end if;
            end loop;

         end if;

         /*-*/
         /* Set the control information
         /*-*/
         var_wrks_dets := true;
         var_wrks_rcnt := var_wrks_rcnt + 1;

         /*-*/
         /* Generate the column data
         /* **notes** column type - 1(number), 2(percentage), 3(share - calculated in dependants), 4(string)
         /*           reference 2 must be rescaled to reference 1 for type 2(percentage)
         /*-*/
         var_wrk_array := tbl_wrkh(var_wrks_hdet).hie_txtv;
         for idx in 1..var_wrks_cend loop
            if tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '1' then
               for idy in tbl_wrkc(idx).col_dsix..tbl_wrkc(idx).col_deix loop
                  var_wrk_array := var_wrk_array || chr(9);
                  if tbl_wrko(((var_wrks_hdet-1)*tbl_wrkc.count)+idx).ovr_psup = false then
                     var_wrk_array := var_wrk_array || to_char(tbl_wrkv(idy),tbl_wrkc(idx).col_fmnt);
                  end if;
               end loop;
            elsif tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '2' then
               var_ref1_val := tbl_wrkv(tbl_wrkc(tbl_wrkc(idx).col_idx1).col_dsix);
               var_ref2_val := round((tbl_wrkv(tbl_wrkc(tbl_wrkc(idx).col_idx2).col_dsix)*tbl_wrkc(tbl_wrkc(idx).col_idx2).col_scle)/tbl_wrkc(tbl_wrkc(idx).col_idx1).col_scle,tbl_wrkc(tbl_wrkc(idx).col_idx1).col_decr);
               if var_ref1_val != 0 and var_ref2_val != 0 then
                  var_wrk_string := to_char(round((var_ref1_val/var_ref2_val)*100,tbl_wrkc(idx).col_decr),tbl_wrkc(idx).col_fmnt);
               elsif var_ref1_val = 0 and var_ref2_val = 0 then
                  var_wrk_string := tbl_column(tbl_wrkc(idx).col_name).col_lnd1 || '/' || tbl_column(tbl_wrkc(idx).col_name).col_lnd2;
               elsif var_ref1_val = 0 then
                  var_wrk_string := tbl_column(tbl_wrkc(idx).col_name).col_lnd1;
               else
                  var_wrk_string := tbl_column(tbl_wrkc(idx).col_name).col_lnd2;
               end if;
               var_wrk_array := var_wrk_array || chr(9);
               if tbl_wrko(((var_wrks_hdet-1)*tbl_wrkc.count)+idx).ovr_psup = false then
                  var_wrk_array := var_wrk_array || var_wrk_string;
               end if;
            elsif tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '3' then
               var_wrk_array := var_wrk_array || chr(9);
               if tbl_wrko(((var_wrks_hdet-1)*tbl_wrkc.count)+idx).ovr_psup = false then
                  var_wrk_array := var_wrk_array || '0';
               end if;
            elsif tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '4' then
               var_wrk_array := var_wrk_array || chr(9);
               if tbl_wrko(((var_wrks_hdet-1)*tbl_wrkc.count)+idx).ovr_psup = false then
                  var_wrk_array := var_wrk_array || tbl_wrkd(idx);
               end if;
            end if;
         end loop;

         /*-*/
         /* Create the detail row
         /*-*/
         xlxml_object.SetRangeLine('A' || to_char(var_wrks_rcnt,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'),
                                   'A' || to_char(var_wrks_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rcnt,'FM999999990'),
                                   null,
                                   xlxml_object.TYPE_DETAIL, var_wrks_hend, var_wrk_array);

         /*-*/
         /* Retain the dependent column row values when required
         /*-*/
         if var_wrks_ctp3 = true then
            tbl_wrkr(var_wrks_rcnt) := var_wrks_hdet;
            var_index := 0;
            for idx in 1..var_wrks_cend loop
               if tbl_column(tbl_wrkc(idx).col_name).col_ctyp = '3' then
                  var_index := var_index + 1;
                  tbl_wrkv((HIERARCHY_MAX*VALUE_MAX)+((var_wrks_rcnt-1)*var_wrks_cnt3)+var_index) := tbl_wrkv(tbl_wrkc(tbl_wrkc(idx).col_idx1).col_dsix);
               end if;
            end loop;
         end if;

      end loop;
      close csr_dynamic;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /*************************************************/
   /* This procedure performs the end sheet routine */
   /*************************************************/
   procedure end_sheet is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the end sheet
      /*-*/
      if var_wrks_stat != '3' then
         raise_application_error(-20000, 'Sheet must be started');
      end if;

      /*-*/
      /* Process last total
      /*-*/
      if var_wrks_dets = true then
         if var_wrks_hend > 0 then
            var_wrks_hlvl := 1;
            do_total;
            do_dependant;
         end if;
         do_format;
         do_border;
         xlxml_object.SetFreezeCell('B' || to_char(var_wrks_rsav,'FM999999990'));
      end if;

      /*-*/
      /* Report when no details found
      /*-*/
      if var_wrks_dets = false then
         xlxml_object.SetRange('A' || to_char(var_wrks_rsav,'FM999999990') || ':A' || to_char(var_wrks_rsav,'FM999999990'), 'A' || to_char(var_wrks_rsav,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rsav,'FM999999990'), xlxml_object.TYPE_DETAIL, -2, 0, false, 'NO DETAILS EXIST');
         xlxml_object.SetRangeBorder('A' || to_char(var_wrks_rsav,'FM999999990') || ':' || var_wrks_clid || to_char(var_wrks_rsav,'FM999999990'));
      end if;

      /*-*/
      /* Report print settings
      /*-*/
      xlxml_object.SetPrintData('$1:$' || to_char(var_wrks_rsav-1,'FM999999990'), '$A:$A', 2, 1, 0);
      if not(tbl_parameter('PRINT_XML').par_char is null) then
         xlxml_object.SetPrintDataXML(tbl_parameter('PRINT_XML').par_char);
      end if;

      /*-*/
      /* Reset the sheet
      /*-*/
      var_wrks_stat := '1';

   /*-------------*/
   /* End routine */
   /*-------------*/
   end end_sheet;

   /****************************************************/
   /* This procedure performs the do reference routine */
   /****************************************************/
   procedure do_reference(par_column in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the column
      /*-*/
      if not(tbl_column.exists(upper(par_column))) then
         raise_application_error(-20000, 'Column ' || par_column || ' does not exist');
      end if;

      /*-*/
      /* Set the column
      /*-*/
      var_index := tbl_wrkc.count + 1;
      tbl_wrkc(var_index).col_name := upper(par_column);
      tbl_wrkc(var_index).col_htxt := tbl_column(upper(par_column)).col_htxt;
      tbl_wrkc(var_index).col_decp := tbl_column(upper(par_column)).col_decp;
      tbl_wrkc(var_index).col_decr := tbl_column(upper(par_column)).col_decr;
      tbl_wrkc(var_index).col_scle := tbl_column(upper(par_column)).col_scle;
      tbl_wrkc(var_index).col_dsix := var_wrks_ccnt + 1;
      tbl_wrkc(var_index).col_deix := var_wrks_ccnt + tbl_column(upper(par_column)).col_ccnt;
      var_wrks_ccnt := var_wrks_ccnt + tbl_column(upper(par_column)).col_ccnt;
      if var_wrks_ccnt > COLUMN_MAX then
         raise_application_error(-20000, 'Maximum of ' || COLUMN_MAX || ' columns exceeded');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_reference;

   /***********************************************/
   /* This procedure performs the heading routine */
   /***********************************************/
   procedure do_heading is

      /*-*/
      /* Variable definitions
      /*-*/
      var_wrk_indent number(2,0);
      var_wrk_bullet boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the sheet level in forward order from the changed level to the bottom
      /*-*/
      for idx in var_wrks_hlvl..var_wrks_hend loop

         /*-*/
         /* Create the new hierarchy heading row
         /*-*/
         var_wrks_rcnt := var_wrks_rcnt + 1;

         /*-*/
         /* Reset the hierarchy values
         /*-*/
         tbl_wrkh(idx).hie_savv := tbl_wrkh(idx).hie_srtv;
         tbl_wrkh(idx).hie_savt := tbl_wrkh(idx).hie_txtv;
         tbl_wrkh(idx).hie_rcnt := var_wrks_rcnt;
         for idy in 1..VALUE_MAX loop
            tbl_wrkv((idx*VALUE_MAX)+idy) := 0;
         end loop;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_heading;

   /*********************************************/
   /* This procedure performs the total routine */
   /*********************************************/
   procedure do_total is

      /*-*/
      /* Variable definitions
      /*-*/
      var_wrk_string varchar2(2048 char);
      var_wrk_array varchar2(4000 char);
      var_ref1_val number;
      var_ref2_val number;
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the sheet level in reverse order from the bottom to the changed level
      /*-*/
      for idx in reverse var_wrks_hlvl..var_wrks_hend loop

         /*-*/
         /* Accumulate/set the parent hierarchy numeric values when required
         /*-*/
         if (idx-1) > 0 then
            for idy in 1..tbl_wrkc.count loop
               if tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '1' then
                  if tbl_wrko(((idx-2)*tbl_wrkc.count)+idy).ovr_stat = false then
                     for idz in tbl_wrkc(idy).col_dsix..tbl_wrkc(idy).col_deix loop
                        tbl_wrkv(((idx-1)*VALUE_MAX)+idz) := tbl_wrkv(((idx-1)*VALUE_MAX)+idz) + tbl_wrkv((idx*VALUE_MAX)+idz);
                     end loop;
                  else
                     for idz in tbl_wrkc(idy).col_dsix..tbl_wrkc(idy).col_deix loop
                        tbl_wrkv(((idx-1)*VALUE_MAX)+idz) := tbl_wrkv((idx*VALUE_MAX)+idz);
                     end loop;
                  end if;
               end if;
            end loop;
         end if;

         /*-*/
         /* Generate the column data
         /* **notes** column type - 1(number), 2(percentage), 3(share - calculated in dependants)
         /*           reference 2 must be rescaled to reference 1 for type 2(percentage)
         /*-*/
         var_wrk_array := tbl_wrkh(idx).hie_savt;
         for idy in 1..var_wrks_cend loop
            if tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '1' then
               for idz in tbl_wrkc(idy).col_dsix..tbl_wrkc(idy).col_deix loop
                  var_wrk_array := var_wrk_array || chr(9);
                  if tbl_wrko(((idx-1)*tbl_wrkc.count)+idy).ovr_psup = false then
                     var_wrk_array := var_wrk_array || to_char(tbl_wrkv((idx*VALUE_MAX)+idz),tbl_wrkc(idy).col_fmnt);
                  end if;
               end loop;
            elsif tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '2' then
               var_ref1_val := tbl_wrkv((idx*VALUE_MAX)+tbl_wrkc(tbl_wrkc(idy).col_idx1).col_dsix);
               var_ref2_val := round((tbl_wrkv((idx*VALUE_MAX)+tbl_wrkc(tbl_wrkc(idy).col_idx2).col_dsix)*tbl_wrkc(tbl_wrkc(idy).col_idx2).col_scle)/tbl_wrkc(tbl_wrkc(idy).col_idx1).col_scle,tbl_wrkc(tbl_wrkc(idy).col_idx1).col_decr);
               if var_ref1_val != 0 and var_ref2_val != 0 then
                  var_wrk_string := to_char(round((var_ref1_val/var_ref2_val)*100,tbl_wrkc(idy).col_decr),tbl_wrkc(idy).col_fmnt);
               elsif var_ref1_val = 0 and var_ref2_val = 0 then
                  var_wrk_string := tbl_column(tbl_wrkc(idy).col_name).col_lnd1 || '/' || tbl_column(tbl_wrkc(idy).col_name).col_lnd2;
               elsif var_ref1_val = 0 then
                  var_wrk_string := tbl_column(tbl_wrkc(idy).col_name).col_lnd1;
               else
                  var_wrk_string := tbl_column(tbl_wrkc(idy).col_name).col_lnd2;
               end if;
               var_wrk_array := var_wrk_array || chr(9);
               if tbl_wrko(((idx-1)*tbl_wrkc.count)+idy).ovr_psup = false then
                  var_wrk_array := var_wrk_array || var_wrk_string;
               end if;
            elsif tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '3' then
               var_wrk_array := var_wrk_array || chr(9);
               if tbl_wrko(((idx-1)*tbl_wrkc.count)+idy).ovr_psup = false then
                  var_wrk_array := var_wrk_array || '0';
               end if;
            elsif tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '4' then
               var_wrk_array := var_wrk_array || chr(9);
            end if;
         end loop;

         /*-*/
         /* Create the sheet row based on position
         /*-*/
         if idx < var_wrks_hstr then
            xlxml_object.SetRangeLine('A' || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990') || ':A' || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990'),
                                      'A' || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990'),
                                      null,
                                      xlxml_object.TYPE_HEADING, idx-1, var_wrk_array);
         else
            xlxml_object.SetRangeLine('A' || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990') || ':A' || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990'),
                                      'A' || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990') || ':' || var_wrks_clid || to_char(tbl_wrkh(idx).hie_rcnt,'FM999999990'),
                                      to_char(tbl_wrkh(idx).hie_rcnt + 1,'FM999999990') || ':' || to_char(var_wrks_rcnt,'FM999999990'),
                                      xlxml_object.GetSummaryType(idx-(var_wrks_hstr-1)), idx-1, var_wrk_array);
         end if;

         /*-*/
         /* Retain the dependent column row values when required
         /*-*/
         if var_wrks_ctp3 = true then
            tbl_wrkr(tbl_wrkh(idx).hie_rcnt) := idx;
            var_index := 0;
            for idy in 1..var_wrks_cend loop
               if tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '3' then
                  var_index := var_index + 1;
                  tbl_wrkv((HIERARCHY_MAX*VALUE_MAX)+((tbl_wrkh(idx).hie_rcnt-1)*var_wrks_cnt3)+var_index) := tbl_wrkv((idx*VALUE_MAX)+tbl_wrkc(tbl_wrkc(idy).col_idx1).col_dsix);
               end if;
            end loop;
         end if;

      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_total;

   /*************************************************/
   /* This procedure performs the dependant routine */
   /*************************************************/
   procedure do_dependant is

      /*-*/
      /* Variable definitions
      /*-*/
      var_wrk_string varchar2(2048 char);
      var_ref1_val number;
      var_ref2_val number;
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Performs parent dependant calculations when required (eg. share %)
      /*-*/
      if var_wrks_ctp3 = true then

         /*-*/
         /* Process the all rows from top to bottom
         /*-*/
         for idx in var_wrks_rsav..var_wrks_rcnt loop

            /*-*/
            /* Save the current hierarchy row count
            /*-*/
            if tbl_wrkr(idx) < var_wrks_hdet then
               tbl_wrkh(tbl_wrkr(idx)).hie_rcnt := idx;
            end if;

            /*-*/
            /* Generate the column data from the parent
            /* **notes** No reference 2 rescaling is required as reference 1 and 2 are the same
            /*-*/
            var_index := 0;
            for idy in 1..var_wrks_cend loop
               if tbl_column(tbl_wrkc(idy).col_name).col_ctyp = '3' then
                  if tbl_wrkr(idx) = 1 then
                     var_wrk_string := 'N/A';
                  else
                     var_index := var_index + 1;
                     var_ref1_val := tbl_wrkv((HIERARCHY_MAX*VALUE_MAX)+((idx-1)*var_wrks_cnt3)+var_index);
                     var_ref2_val := tbl_wrkv((HIERARCHY_MAX*VALUE_MAX)+((tbl_wrkh(tbl_wrkr(idx)-1).hie_rcnt-1)*var_wrks_cnt3)+var_index);
                     if var_ref1_val != 0 and var_ref2_val != 0 then
                        var_wrk_string := to_char(round((var_ref1_val/var_ref2_val)*100,tbl_wrkc(idy).col_decr),tbl_wrkc(idy).col_fmnt);
                     elsif var_ref1_val = 0 and var_ref2_val = 0 then
                        var_wrk_string := tbl_column(tbl_wrkc(idy).col_name).col_lnd1 || '/' || tbl_column(tbl_wrkc(idy).col_name).col_lnd2;
                     elsif var_ref1_val = 0 then
                        var_wrk_string := tbl_column(tbl_wrkc(idy).col_name).col_lnd1;
                     else
                        var_wrk_string := tbl_column(tbl_wrkc(idy).col_name).col_lnd2;
                     end if;
                  end if;
                  if tbl_wrkr(idx) < var_wrks_hstr then
                     xlxml_object.SetRange(xlxml_object.GetColumnId(tbl_wrkc(idy).col_dsix+1) || to_char(idx,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkc(idy).col_dsix+1) || to_char(idx,'FM999999990'),
                                           null, null, -9, 0, false, var_wrk_string);
                  elsif tbl_wrkr(idx) < var_wrks_hdet then
                     xlxml_object.SetRange(xlxml_object.GetColumnId(tbl_wrkc(idy).col_dsix+1) || to_char(idx,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkc(idy).col_dsix+1) || to_char(idx,'FM999999990'),
                                           null, null, -9, 0, false, var_wrk_string);
                  else
                     xlxml_object.SetRange(xlxml_object.GetColumnId(tbl_wrkc(idy).col_dsix+1) || to_char(idx,'FM999999990') || ':' || xlxml_object.GetColumnId(tbl_wrkc(idy).col_dsix+1) || to_char(idx,'FM999999990'),
                                           null, null, -9, 0, false, var_wrk_string);
                  end if;
               end if;
            end loop;

         end loop;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_dependant;

   /**********************************************/
   /* This procedure performs the format routine */
   /**********************************************/
   procedure do_format is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Report column formats
      /*-*/
      for idx in 1..var_wrks_cend loop
         for idy in tbl_wrkc(idx).col_dsix..tbl_wrkc(idx).col_deix loop
            xlxml_object.SetRangeFormat(xlxml_object.GetColumnId(idy+1) || to_char(var_wrks_rsav,'FM999999990') || ':' || xlxml_object.GetColumnId(idy+1) || to_char(var_wrks_rcnt,'FM999999990'), tbl_wrkc(idx).col_decp);
         end loop;
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_format;

   /**********************************************/
   /* This procedure performs the border routine */
   /**********************************************/
   procedure do_border is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Report column borders
      /*-*/
      xlxml_object.SetRangeBorder('A' || to_char(var_wrks_rsav,'FM999999990') || ':A' || to_char(var_wrks_rcnt,'FM999999990'));
      for idx in 1..var_wrks_cend loop
         for idy in tbl_wrkc(idx).col_dsix..tbl_wrkc(idx).col_deix loop
            xlxml_object.SetRangeBorder(xlxml_object.GetColumnId(idy+1) || to_char(var_wrks_rsav,'FM999999990') || ':' || xlxml_object.GetColumnId(idy+1) || to_char(var_wrks_rcnt,'FM999999990'));
         end loop;
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end do_border;

end hk_sal_base_excel;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_base_excel for pld_rep_app.hk_sal_base_excel;
grant execute on hk_sal_base_excel to public;