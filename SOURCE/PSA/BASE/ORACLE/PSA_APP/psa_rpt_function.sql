/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_rpt_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_rpt_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Reporting Function

    This package contain the reporting functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function report_schedule(par_psc_code in varchar2, par_wek_code in varchar2, par_pty_code in varchar2) return psa_xls_type pipelined;
  -- function report_shift return psa_xls_type pipelined;
  -- function report_resource return psa_xls_type pipelined;
  -- function report_production return psa_xls_type pipelined;

end psa_rpt_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_rpt_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   con_mst_cde constant varchar2(32) := '*MASTER';
   con_max_bar constant number := 768;

   /*******************************************************/
   /* This procedure performs the report schedule routine */
   /*******************************************************/
   function report_schedule(par_psc_code in varchar2, par_wek_code in varchar2, par_pty_code in varchar2) return psa_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_psc_code varchar2(32);
      var_wek_code varchar2(32);
      var_pty_code varchar2(32);
      var_work varchar2(2000);
      var_fil_name varchar2(800);
      var_min_time date;
      var_max_time date;
      var_lin_code varchar2(32);
      var_con_code varchar2(32);
      var_cmo_code varchar2(32);
      var_sidx integer;
      var_ridx integer;
      var_cidx integer;
      var_cmax integer;
      var_stk_flag varchar2(1);
      var_str_time varchar2(10);
      var_str_date boolean;
      var_str_barn number;
      var_chg_barn number;
      var_end_barn number;
      var_wek_flow varchar2(1);
      var_bcolor varchar2(20);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                nvl(t02.pty_prd_name,'*UNKNOWN') as pty_prd_name
           from psa_psc_prod t01,
                psa_prd_type t02
          where t01.psp_prd_type = t02.pty_prd_type(+)
            and t01.psp_psc_code = var_psc_code
            and t01.psp_psc_week = var_wek_code
            and t01.psp_prd_type = var_pty_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_mdat is
         select min(trunc(t01.psd_day_date)) as min_day_date,
                max(trunc(t01.psd_day_date)) + 1 as max_day_date
           from psa_psc_date t01
          where t01.psd_psc_code = rcd_retrieve.psp_psc_code
            and t01.psd_psc_week = rcd_retrieve.psp_psc_week;
      rcd_mdat csr_mdat%rowtype;

      cursor csr_date is
         select to_char(t01.psd_day_date,'dd/mm/yyyy') as psd_day_date,
                t01.psd_day_name as psd_day_name
           from psa_psc_date t01
          where t01.psd_psc_code = rcd_retrieve.psp_psc_code
            and t01.psd_psc_week = rcd_retrieve.psp_psc_week
          order by t01.psd_day_date asc;
      rcd_date csr_date%rowtype;

      cursor csr_stck is
         select t01.sth_stk_time,
                t01.sth_stk_name,
                to_date(t01.sth_stk_time,'yyyy/mm/dd hh24:mi') as sth_wrk_time
           from psa_stk_header t01
          where t01.sth_stk_time >= to_char(var_min_time,'yyyy/mm/dd hh24:mi')
            and t01.sth_stk_time < to_char(var_max_time,'yyyy/mm/dd hh24:mi')
          order by t01.sth_stk_time asc;
      rcd_stck csr_stck%rowtype;

      cursor csr_line is
         select t01.psl_lin_code,
                nvl(t02.lde_lin_name,'*UNKNOWN') as lde_lin_name,
                t01.psl_con_code,
                nvl(t03.lco_con_name,'*UNKNOWN') as lco_con_name
           from psa_psc_line t01,
                psa_lin_defn t02,
                psa_lin_config t03
          where t01.psl_lin_code = t02.lde_lin_code(+)
            and t01.psl_lin_code = t03.lco_lin_code(+)
            and t01.psl_con_code = t03.lco_con_code(+)
            and t01.psl_psc_code = rcd_retrieve.psp_psc_code
            and t01.psl_psc_week = rcd_retrieve.psp_psc_week
            and t01.psl_prd_type = rcd_retrieve.psp_prd_type
          order by t01.psl_lin_code asc,
                   t01.psl_con_code asc;
      rcd_line csr_line%rowtype;

      cursor csr_shft is
         select t01.pss_smo_seqn,
                t01.pss_shf_code,
                nvl(t02.sde_shf_name,'*UNKNOWN') as sde_shf_name,
                to_char(t01.pss_shf_date,'yyyy/mm/dd') as pss_shf_date,
                t01.pss_shf_start,
                t01.pss_shf_duration,
                t01.pss_cmo_code,
                t01.pss_win_code,
                t01.pss_win_type,
                t01.pss_str_bar,
                t01.pss_end_bar
           from psa_psc_shft t01,
                psa_shf_defn t02
          where t01.pss_shf_code = t02.sde_shf_code(+)
            and t01.pss_psc_code = rcd_retrieve.psp_psc_code
            and t01.pss_psc_week = rcd_retrieve.psp_psc_week
            and t01.pss_prd_type = rcd_retrieve.psp_prd_type
            and t01.pss_lin_code = rcd_line.psl_lin_code
            and t01.pss_con_code = rcd_line.psl_con_code
          order by t01.pss_smo_seqn asc;
      rcd_shft csr_shft%rowtype;

      cursor csr_cmod is
         select t02.rde_res_code,
                t02.rde_res_name,
                to_char(t01.cmr_res_qnty) as cmr_res_qnty
           from psa_cmo_resource t01,
                psa_res_defn t02
          where t01.cmr_res_code = t02.rde_res_code
            and t01.cmr_cmo_code = var_cmo_code
          order by t01.cmr_res_code asc;
      rcd_cmod csr_cmod%rowtype;

      cursor csr_olin is
         select t01.psa_lin_code,
                nvl(t02.lde_lin_name,'*UNKNOWN') as lde_lin_name,
                t01.psa_con_code,
                nvl(t03.lco_con_name,'*UNKNOWN') as lco_con_name
           from (select t01.psa_act_lin_code as psa_lin_code,
                        t01.psa_act_con_code as psa_con_code
                   from psa_psc_actv t01
                  where t01.psa_psc_code = rcd_retrieve.psp_psc_code
                    and t01.psa_psc_week < rcd_retrieve.psp_psc_week
                    and t01.psa_prd_type = rcd_retrieve.psp_prd_type
                    and t01.psa_act_win_code != '*NONE'
                    and ((t01.psa_act_str_time >= var_min_time and t01.psa_act_str_time < var_max_time) or
                         (t01.psa_act_end_time >= var_min_time and t01.psa_act_end_time < var_max_time))
                    and not((t01.psa_act_lin_code,
                             t01.psa_act_con_code) in (select psl_lin_code,
                                                              psl_con_code
                                                         from psa_psc_line
                                                        where psl_psc_code = rcd_retrieve.psp_psc_code
                                                          and psl_psc_week = rcd_retrieve.psp_psc_week
                                                          and psl_prd_type = rcd_retrieve.psp_prd_type))
                  group by t01.psa_act_lin_code,
                           t01.psa_act_con_code) t01,
                psa_lin_defn t02,
                psa_lin_config t03
          where t01.psa_lin_code = t02.lde_lin_code(+)
            and t01.psa_lin_code = t03.lco_lin_code(+)
            and t01.psa_con_code = t03.lco_con_code(+)
          order by t01.psa_lin_code asc,
                   t01.psa_con_code asc;
      rcd_olin csr_olin%rowtype;

      cursor csr_fill is
         select t01.lfi_fil_code
           from psa_lin_filler t01
          where t01.lfi_lin_code = var_lin_code
            and t01.lfi_con_code = var_con_code
          order by t01.lfi_fil_code asc;

      cursor csr_sact is
         select to_char(t01.psa_act_code) as psa_act_code,
                t01.psa_psc_week,
                t01.psa_act_type,
                t01.psa_sch_chg_flag,
                t01.psa_act_chg_flag,
                t01.psa_act_win_code,
                to_char(t01.psa_act_win_seqn) as psa_act_win_seqn,
                t01.psa_act_win_flow,
                t01.psa_act_str_time,
                t01.psa_act_chg_time,
                t01.psa_act_end_time,
                to_char(trunc(nvl(t01.psa_sch_dur_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_sch_dur_mins,0),60))||' min' as psa_sch_dur_mins,
                to_char(trunc(nvl(t01.psa_act_dur_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_act_dur_mins,0),60))||' min' as psa_act_dur_mins,
                to_char(trunc(nvl(t01.psa_sch_chg_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_sch_chg_mins,0),60))||' min' as psa_sch_chg_mins,
                to_char(trunc(nvl(t01.psa_act_chg_mins,0)/60))||' hrs '||to_char(mod(nvl(t01.psa_act_chg_mins,0),60))||' min' as psa_act_chg_mins,
                t01.psa_act_ent_flag,
                t01.psa_sac_code,
                t01.psa_sac_name,
                t01.psa_mat_code,
                t01.psa_mat_name,
                to_char(t01.psa_mat_sch_plt_qty) as psa_mat_sch_plt_qty,
                to_char(t01.psa_mat_sch_cas_qty) as psa_mat_sch_cas_qty,
                to_char(t01.psa_mat_sch_pch_qty) as psa_mat_sch_pch_qty,
                to_char(t01.psa_mat_sch_mix_qty) as psa_mat_sch_mix_qty,
                to_char(t01.psa_mat_sch_ton_qty,'fm999999990.000') as psa_mat_sch_ton_qty,
                to_char(t01.psa_mat_act_plt_qty) as psa_mat_act_plt_qty,
                to_char(t01.psa_mat_act_cas_qty) as psa_mat_act_cas_qty,
                to_char(t01.psa_mat_act_pch_qty) as psa_mat_act_pch_qty,
                to_char(t01.psa_mat_act_mix_qty) as psa_mat_act_mix_qty,
                to_char(t01.psa_mat_act_ton_qty,'fm999999990.000') as psa_mat_act_ton_qty
           from psa_psc_actv t01
          where t01.psa_psc_code = rcd_retrieve.psp_psc_code
            and t01.psa_prd_type = rcd_retrieve.psp_prd_type
            and t01.psa_act_lin_code = var_lin_code
            and t01.psa_act_con_code = var_con_code
            and t01.psa_act_win_code != '*NONE'
            and ((t01.psa_act_str_time >= var_min_time and t01.psa_act_str_time < var_max_time) or
                 (t01.psa_act_end_time >= var_min_time and t01.psa_act_end_time < var_max_time) or
                 (t01.psa_act_str_time < var_min_time and t01.psa_act_end_time >= var_max_time))
          order by t01.psa_act_str_time asc;
      rcd_sact csr_sact%rowtype;

      cursor csr_sivt is
         select t01.psi_mat_code,
                t02.mde_mat_name,
                to_char(t01.psi_inv_qnty) as psi_inv_qnty,
                to_char(t01.psi_inv_aval) as psi_inv_aval
           from psa_psc_invt t01,
                psa_mat_defn t02
          where t01.psi_mat_code = t02.mde_mat_code
            and t01.psi_act_code = rcd_sact.psa_act_code
          order by t01.psi_mat_code asc;
      rcd_sivt csr_sivt%rowtype;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_fill is table of csr_fill%rowtype index by binary_integer;
      tbl_fill typ_fill;
      type dat_shft is record (smo_seqn number,
                               shf_code varchar2(32),
                               shf_name varchar2(120 char),
                               shf_date varchar2(10),
                               shf_star number,
                               shf_dura number,
                               cmo_code varchar2(32),
                               win_code varchar2(32),
                               win_type varchar2(1),
                               str_barn number,
                               end_barn number);
      type typ_shft is table of dat_shft index by binary_integer;
      type dat_line is record (lin_code varchar2(32),
                               lin_name varchar2(120 char),
                               con_code varchar2(32),
                               con_name varchar2(120 char),
                               fil_name varchar2(800),
                               ovr_flag varchar2(1),
                               shfary typ_shft);
      type typ_line is table of dat_line index by binary_integer;
      tbl_line typ_line;
      type dat_stck is record (stk_name varchar2(256 char),
                               stk_barn number);
      type typ_stck is table of dat_stck index by binary_integer;
      tbl_stck typ_stck;
      type dat_scol is record
         (haltxt varchar2(15),
          valtxt varchar2(14),
          stytxt varchar2(256),
          rowspn varchar2(5),
          colspn varchar2(5),
          outtxt varchar2(2000));
      type typ_scol is table of dat_scol index by binary_integer;
      type dat_srow is record (rowcde number, colary typ_scol);
      type typ_srow is table of dat_srow index by binary_integer;
      tbl_srow typ_srow;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Parse the XML input
      /*-*/
      var_psc_code := par_psc_code;
      var_wek_code := par_wek_code;
      var_pty_code := par_pty_code;

      /*-*/
      /* Retrieve the existing production schedule
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Production schedule week production type ('||var_psc_code||' / '||var_wek_code||' / '||var_pty_code||') does not exist');
      end if;

      /*-*/
      /* Retrieve the week min/max times
      /*-*/
      var_min_time := null;
      var_max_time := null;
      open csr_mdat;
      fetch csr_mdat into rcd_mdat;
      if csr_mdat%found then
         var_min_time := rcd_mdat.min_day_date;
         var_max_time := rcd_mdat.max_day_date;
      end if;
      close csr_mdat;

      /*-*/
      /* Clear the data arrays
      /*-*/
      tbl_line.delete;

      /*-*/
      /* Retrieve the schedule lines
      /*-*/
      open csr_line;
      loop
         fetch csr_line into rcd_line;
         if csr_line%notfound then
            exit;
         end if;
         var_lin_code := rcd_line.psl_lin_code;
         var_con_code := rcd_line.psl_con_code;
         var_fil_name := null;
         tbl_fill.delete;
         open csr_fill;
         fetch csr_fill bulk collect into tbl_fill;
         close csr_fill;
         for idx in 1..tbl_fill.count loop
            if var_fil_name is null then
               var_fil_name := '(';
            else
               var_fil_name := var_fil_name||',';
            end if;
            var_fil_name := var_fil_name||tbl_fill(idx).lfi_fil_code;
         end loop;
         if not(var_fil_name is null) then
            var_fil_name := var_fil_name||')';
         end if;
         tbl_line(tbl_line.count+1).lin_code := rcd_line.psl_lin_code;
         tbl_line(tbl_line.count).lin_name := rcd_line.lde_lin_name;
         tbl_line(tbl_line.count).con_code := rcd_line.psl_con_code;
         tbl_line(tbl_line.count).con_name := rcd_line.lco_con_name;
         tbl_line(tbl_line.count).fil_name := var_fil_name;
         tbl_line(tbl_line.count).ovr_flag := '0';
         tbl_line(tbl_line.count).shfary.delete;
         var_sidx := 0;
         open csr_shft;
         loop
            fetch csr_shft into rcd_shft;
            if csr_shft%notfound then
               exit;
            end if;
            var_sidx := var_sidx + 1;
            tbl_line(tbl_line.count).shfary(var_sidx).smo_seqn := rcd_shft.pss_smo_seqn;
            tbl_line(tbl_line.count).shfary(var_sidx).shf_code := rcd_shft.pss_shf_code;
            tbl_line(tbl_line.count).shfary(var_sidx).shf_name := rcd_shft.sde_shf_name;
            tbl_line(tbl_line.count).shfary(var_sidx).shf_date := rcd_shft.pss_shf_date;
            tbl_line(tbl_line.count).shfary(var_sidx).shf_star := rcd_shft.pss_shf_start;
            tbl_line(tbl_line.count).shfary(var_sidx).shf_dura := rcd_shft.pss_shf_duration;
            tbl_line(tbl_line.count).shfary(var_sidx).cmo_code := rcd_shft.pss_cmo_code;
            tbl_line(tbl_line.count).shfary(var_sidx).win_code := rcd_shft.pss_win_code;
            tbl_line(tbl_line.count).shfary(var_sidx).win_type := rcd_shft.pss_win_type;
            tbl_line(tbl_line.count).shfary(var_sidx).str_barn := rcd_shft.pss_str_bar;
            tbl_line(tbl_line.count).shfary(var_sidx).end_barn := rcd_shft.pss_end_bar;
         end loop;
         close csr_shft;
      end loop;
      close csr_line;

      /*-*/
      /* Retrieve the overflow lines
      /*-*/
      open csr_olin;
      loop
         fetch csr_olin into rcd_olin;
         if csr_olin%notfound then
            exit;
         end if;
         var_lin_code := rcd_olin.psa_lin_code;
         var_con_code := rcd_olin.psa_con_code;
         var_fil_name := null;
         tbl_fill.delete;
         open csr_fill;
         fetch csr_fill bulk collect into tbl_fill;
         close csr_fill;
         for idx in 1..tbl_fill.count loop
            if var_fil_name is null then
               var_fil_name := '(';
            else
               var_fil_name := var_fil_name||',';
            end if;
            var_fil_name := var_fil_name||tbl_fill(idx).lfi_fil_code;
         end loop;
         if not(var_fil_name is null) then
            var_fil_name := var_fil_name||')';
         end if;
         tbl_line(tbl_line.count+1).lin_code := rcd_olin.psa_lin_code;
         tbl_line(tbl_line.count).lin_name := rcd_olin.lde_lin_name;
         tbl_line(tbl_line.count).con_code := rcd_olin.psa_con_code;
         tbl_line(tbl_line.count).con_name := rcd_olin.lco_con_name;
         tbl_line(tbl_line.count).fil_name := var_fil_name;
         tbl_line(tbl_line.count).ovr_flag := '1';
         tbl_line(tbl_line.count).shfary.delete;
      end loop;
      close csr_olin;

      /*-*/
      /* Retrieve the stocktakes
      /*-*/
      tbl_stck.delete;
      open csr_stck;
      loop
         fetch csr_stck into rcd_stck;
         if csr_stck%notfound then
            exit;
         end if;
         tbl_stck(tbl_stck.count+1).stk_name := '('||rcd_stck.sth_stk_time||') '||rcd_stck.sth_stk_name;
         tbl_stck(tbl_stck.count).stk_barn := trunc(((rcd_stck.sth_wrk_time - var_min_time) * 1440) / 15) + 1;
      end loop;
      close csr_stck;

      /*-*/
      /* Clear the row array
      /*-*/
      var_cmax := 2 + (tbl_line.count * 2);
      tbl_srow.delete;
      for idr in 1..con_max_bar loop
         tbl_srow(idr).rowcde := idr;
         tbl_srow(idr).colary.delete;
         for idc in 1..var_cmax loop
            tbl_srow(idr).colary(idc).haltxt := 'center';
            tbl_srow(idr).colary(idc).valtxt := 'center';
            if idc > 2 and mod(idc,2) = 0 then
               tbl_srow(idr).colary(idc).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border:#808080 .5pt solid;';
            else
               if idr = 1 then
                  tbl_srow(idr).colary(idc).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-left:#808080 .5pt solid;border-right:#808080 .5pt solid;';
               else
                  tbl_srow(idr).colary(idc).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-left:#808080 .5pt solid;border-right:#808080 .5pt solid;';
               end if;
            end if;
            tbl_srow(idr).colary(idc).rowspn := '1';
            tbl_srow(idr).colary(idc).colspn := '1';
            tbl_srow(idr).colary(idc).outtxt := null;
         end loop;
      end loop;

      /*-*/
      /* Retrieve and load the date data
      /*-*/
      var_ridx := 0;
      var_str_date := false;
      open csr_date;
      loop
         fetch csr_date into rcd_date;
         if csr_date%notfound then
            exit;
         end if;
         var_str_date := true;
         for idd in 1..24 loop
            var_str_time := to_char(idd-1,'fm00');
            var_ridx := var_ridx + 1;
            tbl_srow(var_ridx).colary(1).haltxt := 'center';
            tbl_srow(var_ridx).colary(1).valtxt := 'center';
            if var_str_date = true then
               tbl_srow(var_ridx).colary(1).stytxt := 'font-family:Arial;font-size:8pt;font-weight:bold;background-color:#8080ff;color:#000000;border:#808080 .5pt solid;';
            else
               tbl_srow(var_ridx).colary(1).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0ff;color:#000000;border:#808080 .5pt solid;';
            end if;
            var_str_date := false;
            tbl_srow(var_ridx).colary(1).rowspn := '4';
            tbl_srow(var_ridx).colary(1).colspn := '1';
            tbl_srow(var_ridx).colary(1).outtxt := rcd_date.psd_day_name||'<br>'||rcd_date.psd_day_date;
            var_stk_flag := '0';
            for ids in 1..tbl_stck.count loop
               if tbl_stck(ids).stk_barn = var_ridx then
                  var_stk_flag := '1';
                  exit;
               end if;
            end loop;
            tbl_srow(var_ridx).colary(2).haltxt := 'center';
            tbl_srow(var_ridx).colary(2).valtxt := 'top';
            if var_stk_flag = '0' then
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:bold;background-color:#c0c0ff;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            else
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:bold;background-color:#c0c000;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            end if;
            tbl_srow(var_ridx).colary(2).rowspn := '1';
            tbl_srow(var_ridx).colary(2).colspn := '1';
            tbl_srow(var_ridx).colary(2).outtxt := var_str_time||':00';
            var_ridx := var_ridx + 1;
            tbl_srow(var_ridx).colary(1).haltxt := '*NULL';
            var_stk_flag := '0';
            for ids in 1..tbl_stck.count loop
               if tbl_stck(ids).stk_barn = var_ridx then
                  var_stk_flag := '1';
                  exit;
               end if;
            end loop;
            tbl_srow(var_ridx).colary(2).haltxt := 'center';
            tbl_srow(var_ridx).colary(2).valtxt := 'top';
            if var_stk_flag = '0' then
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0ff;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            else
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c000;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            end if;
            tbl_srow(var_ridx).colary(2).rowspn := '1';
            tbl_srow(var_ridx).colary(2).colspn := '1';
            tbl_srow(var_ridx).colary(2).outtxt := var_str_time||':15';
            var_ridx := var_ridx + 1;
            tbl_srow(var_ridx).colary(1).haltxt := '*NULL';
            var_stk_flag := '0';
            for ids in 1..tbl_stck.count loop
               if tbl_stck(ids).stk_barn = var_ridx then
                  var_stk_flag := '1';
                  exit;
               end if;
            end loop;
            tbl_srow(var_ridx).colary(2).haltxt := 'center';
            tbl_srow(var_ridx).colary(2).valtxt := 'top';
            if var_stk_flag = '0' then
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0ff;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            else
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c000;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            end if;
            tbl_srow(var_ridx).colary(2).rowspn := '1';
            tbl_srow(var_ridx).colary(2).colspn := '1';
            tbl_srow(var_ridx).colary(2).outtxt := var_str_time||':30';
            var_ridx := var_ridx + 1;
            tbl_srow(var_ridx).colary(1).haltxt := '*NULL';
            var_stk_flag := '0';
            for ids in 1..tbl_stck.count loop
               if tbl_stck(ids).stk_barn = var_ridx then
                  var_stk_flag := '1';
                  exit;
               end if;
            end loop;
            tbl_srow(var_ridx).colary(2).haltxt := 'center';
            tbl_srow(var_ridx).colary(2).valtxt := 'top';
            if var_stk_flag = '0' then
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c0ff;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            else
               tbl_srow(var_ridx).colary(2).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0c000;color:#000000;border:#808080 .5pt solid;mso-number-format:\@;';
            end if;
            tbl_srow(var_ridx).colary(2).rowspn := '1';
            tbl_srow(var_ridx).colary(2).colspn := '1';
            tbl_srow(var_ridx).colary(2).outtxt := var_str_time||':45';
         end loop;
      end loop;
      close csr_date;

      /*-*/
      /* Retrieve and load the shift data
      /*-*/
      var_cidx := 1;
      for idl in 1..tbl_line.count loop
         var_cidx := var_cidx + 2;
         if tbl_line(idl).ovr_flag = '0' then
            for ids in 1..tbl_line(idl).shfary.count loop
               if tbl_line(idl).shfary(ids).cmo_code != '*NONE' then
                  var_work := tbl_line(idl).shfary(ids).shf_name;
                  var_cmo_code := tbl_line(idl).shfary(ids).cmo_code;
                  open csr_cmod;
                  loop
                     fetch csr_cmod into rcd_cmod;
                     if csr_cmod%notfound then
                        exit;
                     end if;
                     var_work := var_work||'<br>('||rcd_cmod.cmr_res_qnty||') - '||rcd_cmod.rde_res_name;
                  end loop;
                  close csr_cmod;
                  tbl_srow(tbl_line(idl).shfary(ids).str_barn).colary(var_cidx).haltxt := 'center';
                  tbl_srow(tbl_line(idl).shfary(ids).str_barn).colary(var_cidx).valtxt := 'top';
                  tbl_srow(tbl_line(idl).shfary(ids).str_barn).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#c0ffc0;color:#000000;border:#008000 1pt solid;';
                  tbl_srow(tbl_line(idl).shfary(ids).str_barn).colary(var_cidx).rowspn := to_char((tbl_line(idl).shfary(ids).end_barn - tbl_line(idl).shfary(ids).str_barn) + 1);
                  tbl_srow(tbl_line(idl).shfary(ids).str_barn).colary(var_cidx).colspn := '1';
                  tbl_srow(tbl_line(idl).shfary(ids).str_barn).colary(var_cidx).outtxt := var_work;
                  for idw in tbl_line(idl).shfary(ids).str_barn..tbl_line(idl).shfary(ids).end_barn loop
                     if idw != tbl_line(idl).shfary(ids).str_barn then
                        tbl_srow(idw).colary(var_cidx).haltxt := '*NULL';
                     end if;
                     tbl_srow(idw).colary(var_cidx+1).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
                  end loop;
               end if;
            end loop;
         end if;
      end loop;

      /*-*/
      /* Retrieve and load the schedule data
      /*-*/
      var_cidx := 2;
      for idl in 1..tbl_line.count loop
         var_cidx := var_cidx + 2;
         var_lin_code := tbl_line(idl).lin_code;
         var_con_code := tbl_line(idl).con_code;

         /*-*/
         /* Load the schedule data
         /*-*/
         open csr_sact;
         loop
            fetch csr_sact into rcd_sact;
            if csr_sact%notfound then
               exit;
            end if;
            var_wek_flow := '0';
            if rcd_sact.psa_psc_week != var_wek_code then
               var_wek_flow := '1';
            end if;
            var_str_barn := trunc(((rcd_sact.psa_act_str_time - var_min_time) * 1440) / 15) + 1;
            var_end_barn := trunc(((rcd_sact.psa_act_end_time - var_min_time) * 1440) / 15) + 1;
            if rcd_sact.psa_act_str_time < var_min_time then
               var_str_barn := 1;
            end if;
            if rcd_sact.psa_act_end_time >= var_max_time then
               var_end_barn := con_max_bar;
            end if;
            if rcd_sact.psa_act_type = 'P' then
               if rcd_sact.psa_act_chg_flag = '1' then
                  var_chg_barn := trunc(((rcd_sact.psa_act_chg_time - var_min_time) * 1440) / 15) + 1;
                  if rcd_sact.psa_act_chg_time < var_min_time or rcd_sact.psa_act_chg_time >= var_max_time then
                     var_chg_barn := 0;
                  end if;
               end if;
               if rcd_sact.psa_act_win_flow = '0' then
                  var_bcolor := '#000000';
                  if var_wek_flow = '1' then
                     var_bcolor := '#800000';
                  end if;
               else
                  var_bcolor := '#800080';
                  if var_wek_flow = '1' then
                     var_bcolor := '#800000';
                  end if;
               end if;
               var_work := tbl_srow(var_str_barn).colary(var_cidx).outtxt;
               if not(var_work is null) then
                  var_work := var_work||'<br>';
               end if;
               var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*PROD* - Material ('||rcd_sact.psa_mat_code||') '||rcd_sact.psa_mat_name||'</font>';
               var_work := var_work||'<br>'||'Start ('||to_char(rcd_sact.psa_act_str_time,'dd/mm/yyyy hh24:mi')||') End ('||to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi')||')';
               if rcd_sact.psa_sch_chg_flag = '0' then
                  var_work := var_work||'<br>'||'Scheduled Production ('||rcd_sact.psa_sch_dur_mins||')';
               else
                  var_work := var_work||'<br>'||'Scheduled Production ('||rcd_sact.psa_sch_dur_mins||') Change ('||rcd_sact.psa_sch_chg_mins||')';
               end if;
               if rcd_sact.psa_act_ent_flag = '1' then
                  if rcd_sact.psa_act_chg_flag = '0' then
                     var_work := var_work||'<br>'||'Actual Production ('||rcd_sact.psa_act_dur_mins||')';
                  else
                     var_work := var_work||'<br>'||'Actual Production ('||rcd_sact.psa_act_dur_mins||') Change ('||rcd_sact.psa_act_chg_mins||')';
                  end if;
               end if;
               if rcd_retrieve.psp_prd_type = '*FILL' then
                  var_work := var_work||'<br>'||'Scheduled Cases ('||rcd_sact.psa_mat_sch_cas_qty||') Pouches ('||rcd_sact.psa_mat_sch_pch_qty||') Mixes ('||rcd_sact.psa_mat_sch_mix_qty||')';
               elsif rcd_retrieve.psp_prd_type = '*PACK' then
                  var_work := var_work||'<br>'||'Scheduled Cases ('||rcd_sact.psa_mat_sch_cas_qty||') Pallets ('||rcd_sact.psa_mat_sch_plt_qty||')';
               elsif rcd_retrieve.psp_prd_type = '*FORM' then
                  var_work := var_work||'<br>'||'Scheduled Pouches ('||rcd_sact.psa_mat_sch_pch_qty||')';
               end if;
               if rcd_sact.psa_act_ent_flag = '1' then
                  if rcd_retrieve.psp_prd_type = '*FILL' then
                     var_work := var_work||'<br>'||'Actual Cases ('||rcd_sact.psa_mat_act_cas_qty||') Pouches ('||rcd_sact.psa_mat_act_pch_qty||') Mixes ('||rcd_sact.psa_mat_act_mix_qty||')';
                  elsif rcd_retrieve.psp_prd_type = '*PACK' then
                     var_work := var_work||'<br>'||'Actual Cases ('||rcd_sact.psa_mat_act_cas_qty||') Pallets ('||rcd_sact.psa_mat_act_plt_qty||')';
                  elsif rcd_retrieve.psp_prd_type = '*FORM' then
                     var_work := var_work||'<br>'||'Actual Pouches ('||rcd_sact.psa_mat_act_pch_qty||')';
                  end if;
               end if;
               open csr_sivt;
               loop
                  fetch csr_sivt into rcd_sivt;
                  if csr_sivt%notfound then
                     exit;
                  end if;
                  var_work := var_work||'<br>'||'Component ('||rcd_sivt.psi_mat_code||') '||rcd_sivt.mde_mat_name||' Required ('||rcd_sivt.psi_inv_qnty||') Available ('||rcd_sivt.psi_inv_aval||')';
               end loop;
               close csr_sivt;
               tbl_srow(var_str_barn).colary(var_cidx).haltxt := 'left';
               tbl_srow(var_str_barn).colary(var_cidx).valtxt := 'top';
               tbl_srow(var_str_barn).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
               tbl_srow(var_str_barn).colary(var_cidx).rowspn := '1';
               tbl_srow(var_str_barn).colary(var_cidx).colspn := '1';
               tbl_srow(var_str_barn).colary(var_cidx).outtxt := var_work;
               if rcd_sact.psa_act_chg_flag = '1' and var_chg_barn != 0 then
                  for idb in var_str_barn+1..var_chg_barn-1 loop
                     var_work := tbl_srow(idb).colary(var_cidx).outtxt;
                     if not(var_work is null) then
                        var_work := var_work||'<br>';
                     end if;
                     var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*PROD*</font>';
                     tbl_srow(idb).colary(var_cidx).haltxt := 'left';
                     tbl_srow(idb).colary(var_cidx).valtxt := 'top';
                     tbl_srow(idb).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
                     tbl_srow(idb).colary(var_cidx).rowspn := '1';
                     tbl_srow(idb).colary(var_cidx).colspn := '1';
                     tbl_srow(idb).colary(var_cidx).outtxt := var_work;
                  end loop;
                  var_work := tbl_srow(var_chg_barn).colary(var_cidx).outtxt;
                  if not(var_work is null) then
                     var_work := var_work||'<br>';
                  end if;
                  var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*PROD*</font> - Material change ('||to_char(rcd_sact.psa_act_chg_time,'dd/mm/yyyy hh24:mi')||')';
                  tbl_srow(var_chg_barn).colary(var_cidx).haltxt := 'left';
                  tbl_srow(var_chg_barn).colary(var_cidx).valtxt := 'top';
                  tbl_srow(var_chg_barn).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
                  tbl_srow(var_chg_barn).colary(var_cidx).rowspn := '1';
                  tbl_srow(var_chg_barn).colary(var_cidx).colspn := '1';
                  tbl_srow(var_chg_barn).colary(var_cidx).outtxt := var_work;
                  for idb in var_chg_barn+1..var_end_barn-1 loop
                     var_work := tbl_srow(idb).colary(var_cidx).outtxt;
                     if not(var_work is null) then
                        var_work := var_work||'<br>';
                     end if;
                     var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*PROD*</font>';
                     tbl_srow(idb).colary(var_cidx).haltxt := 'left';
                     tbl_srow(idb).colary(var_cidx).valtxt := 'top';
                     tbl_srow(idb).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
                     tbl_srow(idb).colary(var_cidx).rowspn := '1';
                     tbl_srow(idb).colary(var_cidx).colspn := '1';
                     tbl_srow(idb).colary(var_cidx).outtxt := var_work;
                 end loop;
               else
                  for idb in var_str_barn+1..var_end_barn-1 loop
                     var_work := tbl_srow(idb).colary(var_cidx).outtxt;
                     if not(var_work is null) then
                        var_work := var_work||'<br>';
                     end if;
                     var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*PROD*</font>';
                     tbl_srow(idb).colary(var_cidx).haltxt := 'left';
                     tbl_srow(idb).colary(var_cidx).valtxt := 'top';
                     tbl_srow(idb).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
                     tbl_srow(idb).colary(var_cidx).rowspn := '1';
                     tbl_srow(idb).colary(var_cidx).colspn := '1';
                     tbl_srow(idb).colary(var_cidx).outtxt := var_work;
                 end loop;
               end if;
               var_work := tbl_srow(var_end_barn).colary(var_cidx).outtxt;
               if not(var_work is null) then
                  var_work := var_work||'<br>';
               end if;
               var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*PROD*</font> - End ('||to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi')||')';
               tbl_srow(var_end_barn).colary(var_cidx).haltxt := 'left';
               tbl_srow(var_end_barn).colary(var_cidx).valtxt := 'top';
               tbl_srow(var_end_barn).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
               tbl_srow(var_end_barn).colary(var_cidx).rowspn := '1';
               tbl_srow(var_end_barn).colary(var_cidx).colspn := '1';
               tbl_srow(var_end_barn).colary(var_cidx).outtxt := var_work;
            elsif rcd_sact.psa_act_type = 'T' then
               if rcd_sact.psa_act_win_flow = '0' then
                  var_bcolor := '#000000';
                  if var_wek_flow = '1' then
                     var_bcolor := '#800000';
                  end if;
               else
                  var_bcolor := '#800080';
                  if var_wek_flow = '1' then
                     var_bcolor := '#800000';
                  end if;
               end if;
               var_work := tbl_srow(var_str_barn).colary(var_cidx).outtxt;
               if not(var_work is null) then
                  var_work := var_work||'<br>';
               end if;
               var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*TIME* - Activity ('||rcd_sact.psa_sac_code||') '||rcd_sact.psa_sac_name||'</font>';
               var_work := var_work||'<br>'||'Start ('||to_char(rcd_sact.psa_act_str_time,'dd/mm/yyyy hh24:mi')||') End ('||to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi')||')';
               var_work := var_work||'<br>'||'Scheduled Duration ('||rcd_sact.psa_sch_dur_mins||')';
               if rcd_sact.psa_act_ent_flag = '1' then
                  var_work := var_work||'<br>'||'Actual Duration ('||rcd_sact.psa_act_dur_mins||')';
               end if;
               tbl_srow(var_str_barn).colary(var_cidx).haltxt := 'left';
               tbl_srow(var_str_barn).colary(var_cidx).valtxt := 'top';
               tbl_srow(var_str_barn).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
               tbl_srow(var_str_barn).colary(var_cidx).rowspn := '1';
               tbl_srow(var_str_barn).colary(var_cidx).colspn := '1';
               tbl_srow(var_str_barn).colary(var_cidx).outtxt := var_work;
               for idb in var_str_barn+1..var_end_barn-1 loop
                  var_work := tbl_srow(idb).colary(var_cidx).outtxt;
                  if not(var_work is null) then
                     var_work := var_work||'<br>';
                  end if;
                  var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*TIME*</font>';
                  tbl_srow(idb).colary(var_cidx).haltxt := 'left';
                  tbl_srow(idb).colary(var_cidx).valtxt := 'top';
                  tbl_srow(idb).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
                  tbl_srow(idb).colary(var_cidx).rowspn := '1';
                  tbl_srow(idb).colary(var_cidx).colspn := '1';
                  tbl_srow(idb).colary(var_cidx).outtxt := var_work;
               end loop;
               var_work := tbl_srow(var_end_barn).colary(var_cidx).outtxt;
               if not(var_work is null) then
                  var_work := var_work||'<br>';
               end if;
               var_work := var_work||'<font style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#ffffff;color:'||var_bcolor||';">*TIME*</font> - End ('||to_char(rcd_sact.psa_act_end_time,'dd/mm/yyyy hh24:mi')||')';
               tbl_srow(var_end_barn).colary(var_cidx).haltxt := 'left';
               tbl_srow(var_end_barn).colary(var_cidx).valtxt := 'top';
               tbl_srow(var_end_barn).colary(var_cidx).stytxt := 'font-family:Arial;font-size:8pt;font-weight:normal;background-color:#ffffff;color:#000000;border-top:#808080 .5pt solid;border-bottom:#808080 .5pt solid;mso-number-format:\@;';
               tbl_srow(var_end_barn).colary(var_cidx).rowspn := '1';
               tbl_srow(var_end_barn).colary(var_cidx).colspn := '1';
               tbl_srow(var_end_barn).colary(var_cidx).outtxt := var_work;
            end if;
         end loop;
         close csr_sact;

      end loop;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<html');
      pipe row('<head>');
      pipe row('<style>br {mos-data_placement:same-cell;}</style>');
      pipe row('<!--[if gte mso 9]><xml>');
      pipe row(' <x:ExcelWorkbook>');
      pipe row('  <x:ExcelWorksheets>');
      pipe row('   <x:ExcelWorksheet>');
      pipe row('    <x:Name>'||var_psc_code||'</x:Name>');
      pipe row('    <x:WorksheetOptions>');
      pipe row('     <x:Selected/>');
      pipe row('     <x:DoNotDisplayGridlines/>');
      pipe row('     <x:FreezePanes/>');
      pipe row('     <x:FrozenNoSplit/>');
      pipe row('     <x:SplitHorizontal>2</x:SplitHorizontal>');
      pipe row('     <x:TopRowBottomPane>2</x:TopRowBottomPane>');
      pipe row('     <x:SplitVertical>2</x:SplitVertical>');
      pipe row('     <x:LeftColumnRightPane>2</x:LeftColumnRightPane>');
      pipe row('     <x:ActivePane>0</x:ActivePane>');
      pipe row('     <x:Panes>');
      pipe row('      <x:Pane>');
      pipe row('       <x:Number>3</x:Number>');
      pipe row('      </x:Pane>');
      pipe row('      <x:Pane>');
      pipe row('       <x:Number>1</x:Number>');
      pipe row('      </x:Pane>');
      pipe row('      <x:Pane>');
      pipe row('       <x:Number>2</x:Number>');
      pipe row('      </x:Pane>');
      pipe row('      <x:Pane>');
      pipe row('       <x:Number>0</x:Number>');
      pipe row('       <x:ActiveRow>2</x:ActiveRow>');
      pipe row('       <x:ActiveCol>2</x:ActiveCol>');
      pipe row('      </x:Pane>');
      pipe row('     </x:Panes>');
      pipe row('     <x:ProtectContents>False</x:ProtectContents>');
      pipe row('     <x:ProtectObjects>False</x:ProtectObjects>');
      pipe row('     <x:ProtectScenarios>False</x:ProtectScenarios>');
      pipe row('    </x:WorksheetOptions>');
      pipe row('   </x:ExcelWorksheet>');
      pipe row('  </x:ExcelWorksheets>');
      pipe row('  <x:ProtectStructure>False</x:ProtectStructure>');
      pipe row('  <x:ProtectWindows>False</x:ProtectWindows>');
      pipe row(' </x:ExcelWorkbook>');
      pipe row('</xml><![endif]-->');
      pipe row('</head>');
      pipe row('<body>');
      pipe row('<table style="border:#808080 .5pt solid;">');
      pipe row('<tr><td align=center colspan='||to_char(var_cmax)||' style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#008000;color:#ffffff;border:#c0ffc0 1pt solid;" nowrap>Production Schedule Report - '||var_psc_code||' - '||'Y'||substr(var_wek_code,1,4)||' P'||substr(var_wek_code,5,2)||' W'||substr(var_wek_code,7,1)||' - '||rcd_retrieve.pty_prd_name||'</td></tr>');
      pipe row('<tr>');
      pipe row('<td align=center colspan=1 style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#008000;color:#ffffff;border:#c0ffc0 1pt solid;" nowrap>Date</td>');
      pipe row('<td align=center colspan=1 style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#008000;color:#ffffff;border:#c0ffc0 1pt solid;" nowrap>Time</td>');
      for idl in 1..tbl_line.count loop
         if tbl_line(idl).ovr_flag = '0' then
            pipe row('<td align=center colspan=2 style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#008000;color:#ffffff;border:#c0ffc0 1pt solid;" nowrap>('||tbl_line(idl).lin_code||') '||tbl_line(idl).lin_name||' - ('||tbl_line(idl).con_code||') '||tbl_line(idl).con_name||' - '||tbl_line(idl).fil_name||'</td>');
         else
            pipe row('<td align=center colspan=2 style="font-family:Arial;font-size:8pt;font-weight:bold;background-color:#008000;color:#ffffff;border:#c0ffc0 1pt solid;" nowrap>('||tbl_line(idl).lin_code||') '||tbl_line(idl).lin_name||' - ('||tbl_line(idl).con_code||') '||tbl_line(idl).con_name||' - '||tbl_line(idl).fil_name||'</td>');
         end if;
      end loop;
      pipe row('</tr>');

      /*-*/
      /* Output the schedule
      /*-*/
      for idr in 1..tbl_srow.count loop
         pipe row('<tr>');
         for idc in 1..tbl_srow(idr).colary.count loop
            if tbl_srow(idr).colary(idc).haltxt != '*NULL' then
               pipe row('<td align='||tbl_srow(idr).colary(idc).haltxt||' valign='||tbl_srow(idr).colary(idc).valtxt||' rowspan='||tbl_srow(idr).colary(idc).rowspn||' colspan='||tbl_srow(idr).colary(idc).colspn||' style="'||tbl_srow(idr).colary(idc).stytxt||'" nowrap>'||tbl_srow(idr).colary(idc).outtxt||'</td>');
            end if;
         end loop;
         pipe row('</tr>');
      end loop;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');
      pipe row('</body>');
      pipe row('</html>');

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PSA_RPT_FUNCTION - REPORT_SCHEDULE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_schedule;

end psa_rpt_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_rpt_function for psa_app.psa_rpt_function;
grant execute on psa_app.psa_rpt_function to public;