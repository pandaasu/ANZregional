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
   function report_schedule return psa_xls_type pipelined;
   function report_shift return psa_xls_type pipelined;
   function report_resource return psa_xls_type pipelined;
   function report_production return psa_xls_type pipelined;

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
   type ptyp_data is table of varchar2(2000 char) index by binary_integer;
   ptbl_data ptyp_data;
   type prcd_invm is record (plt_qty number,cas_qty number,pch_qty number,ton_qty number);
   type ptyp_invm is table of number index by varchar2(32);
   type prcd_invd is record (invdat date,matary ptyp_invm);
   type ptyp_invd is table of prcd_invd index by binary_integer;
   ptbl_sinv ptyp_invd;
   ptbl_ainv ptyp_invd;

   /*******************************************************/
   /* This procedure performs the report schedule routine */
   /*******************************************************/
   function report_schedule return psa_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_output varchar2(2000);
      var_work varchar2(2000);
      var_lin_flag boolean;
      var_com_flag boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_defn is
         select t01.mde_mat_code,
                t01.mde_mat_name,
                t01.mde_mat_type,
                t01.mde_mat_usage,
                t01.mde_mat_status,
                t01.mde_mat_uom,
                to_char(t01.mde_gro_weight,'fm999999990.000') as mde_gro_weight,
                to_char(t01.mde_net_weight,'fm999999990.000') as mde_net_weight,
                to_char(t01.mde_unt_case) as mde_unt_case,
                t01.mde_sap_code,
                nvl(t01.mde_sap_line,'*NONE') as mde_sap_line,
                nvl(t01.mde_psa_line,'*NONE') as mde_psa_line,
                t01.mde_sys_user||' on '||to_char(t01.mde_sys_date,'yyyy/mm/dd hh24:mi:ss') as mde_sys_user,
                decode(t01.mde_upd_user,null,'ADDED',t01.mde_upd_user||' on '||to_char(t01.mde_upd_date,'yyyy/mm/dd hh24:mi:ss')) as mde_upd_user
           from psa_mat_defn t01
          where t01.mde_mat_status in ('*ACTIVE','*CHG','*DEL')
          order by t01.mde_mat_type asc,
                   decode(t01.mde_mat_usage,'TDU','1','MPO','2','PCH','3','RLS','4','GUSSET','5',t01.mde_mat_usage) asc,
                   t01.mde_mat_code asc;
      rcd_defn csr_defn%rowtype;

      cursor csr_prod is
         select t01.mpr_prd_type,
                nvl(upper(t02.pty_prd_name),'*UNKNOWN') as pty_prd_name,
                to_char(nvl(t01.mpr_sch_priority,1)) as mpr_sch_priority,
                decode(t01.mpr_req_flag,'1','Yes','No') as mpr_req_flag,
                nvl(t01.mpr_dft_line,'*NONE') as mpr_dft_line,
                to_char(nvl(t01.mpr_cas_pallet,0)) as mpr_cas_pallet,
                to_char(nvl(t01.mpr_bch_quantity,0)) as mpr_bch_quantity,
                to_char(nvl(t01.mpr_yld_percent,100),'fm990.00') as mpr_yld_percent,
                to_char(nvl(t01.mpr_yld_value,0)) as mpr_yld_value,
                to_char(nvl(t01.mpr_pck_percent,100),'fm990.00') as mpr_pck_percent,
                to_char(nvl(t01.mpr_pck_weight,0),'fm999999990.000') as mpr_pck_weight,
                to_char(nvl(t01.mpr_bch_weight,0),'fm999999990.000') as mpr_bch_weight
           from psa_mat_prod t01,
                psa_prd_type t02
          where t01.mpr_prd_type = t02.pty_prd_type(+)
            and t01.mpr_mat_code = rcd_defn.mde_mat_code
          order by t01.mpr_prd_type asc;
      rcd_prod csr_prod%rowtype;

      cursor csr_line is
         select '('||t01.mli_lin_code||') '||nvl(t03.lde_lin_name,'*UNKNOWN') as mli_lin_code,
                '('||t01.mli_con_code||') '||nvl(t02.lco_con_name,'*UNKNOWN') as mli_con_code,
                decode(t01.mli_dft_flag,'1','Yes','No') as mli_dft_flag,
                '('||t01.mli_rra_code||') '||nvl(t04.rrd_rra_name,'*UNKNOWN') as mli_rra_code,
                to_char(nvl(t04.rrd_rra_efficiency,0),'fm990.00') as rrd_rra_efficiency,
                to_char(nvl(t04.rrd_rra_wastage,0),'fm990.00') as rrd_rra_wastage,
                to_char(t01.mli_rra_efficiency,'fm990.00') as mli_rra_efficiency,
                to_char(t01.mli_rra_wastage,'fm990.00') as mli_rra_wastage
           from psa_mat_line t01,
                psa_lin_config t02,
                psa_lin_defn t03,
                psa_rra_defn t04
          where t01.mli_lin_code = t02.lco_lin_code(+)
            and t01.mli_con_code = t02.lco_con_code(+)
            and t02.lco_lin_code = t03.lde_lin_code(+)
            and t01.mli_rra_code = t04.rrd_rra_code(+)
            and t01.mli_mat_code = rcd_defn.mde_mat_code
            and t01.mli_prd_type = rcd_prod.mpr_prd_type
          order by t01.mli_lin_code asc,
                   t01.mli_con_code asc;
      rcd_line csr_line%rowtype;

      cursor csr_comp is
         select '('||t01.mco_com_code||') '||nvl(t02.mde_mat_name,'*UNKNOWN') as mco_com_code,
                to_char(t01.mco_com_quantity) as mco_com_quantity
           from psa_mat_comp t01,
                psa_mat_defn t02
          where t01.mco_com_code = t02.mde_mat_code(+)
            and t01.mco_mat_code = rcd_defn.mde_mat_code
            and t01.mco_prd_type = rcd_prod.mpr_prd_type
          order by t02.mde_mat_code asc;
      rcd_comp csr_comp%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1>');
      pipe row('<tr><td align=center colspan=14 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Master Report</td></tr>');
      pipe row('<tr>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Description</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Usage</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Status</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">UOM</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Gross Weight</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Net Weight</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Units/Case</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">SAP Code</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">SAP Line</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">PSA Line</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">SAP Updated</td>');
      pipe row('<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">PSA Updated</td>');
      pipe row('</tr>');

      /*-*/
      /* Retrieve the materials
      /*-*/
      open csr_defn;
      loop
         fetch csr_defn into rcd_defn;
         if csr_defn%notfound then
            exit;
         end if;

         /*-*/
         /* Output the definition data
         /*-*/
         pipe row('<tr><td align=center colspan=14></td></tr>');
         var_output := '<tr>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFC0;COLOR:#000000;" nowrap>'||rcd_defn.mde_mat_code||'</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_mat_name||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_mat_type||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_mat_usage||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_mat_status||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_mat_uom||'</td>';
         var_output := var_output||'<td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_gro_weight||'</td>';
         var_output := var_output||'<td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_net_weight||'</td>';
         var_output := var_output||'<td align=right colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_unt_case||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;mso-number-format:\@;" nowrap>'||rcd_defn.mde_sap_code||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_sap_line||'</td>';
         var_output := var_output||'<td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_psa_line||'</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_sys_user||'</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_defn.mde_upd_user||'</td>';
         var_output := var_output||'</tr>';
         pipe row(var_output);

         /*-*/
         /* Retrieve the production type data
         /*-*/
         open csr_prod;
         loop
            fetch csr_prod into rcd_prod;
            if csr_prod%notfound then
               exit;
            end if;

            if rcd_prod.mpr_prd_type = '*FILL' then
               pipe row('<tr><td align=center colspan=14></td></tr>');
               var_work := '<font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Default Line:</font> '||rcd_prod.mpr_dft_line;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Requirements:</font> '||rcd_prod.mpr_req_flag;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Scheduling Priority:</font> '||rcd_prod.mpr_sch_priority;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Batch Case Quantity:</font> '||rcd_prod.mpr_bch_quantity;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Yield %:</font> '||rcd_prod. mpr_yld_percent;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Yield:</font> '||rcd_prod.mpr_yld_value;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Pack Weight %:</font> '||rcd_prod.mpr_pck_percent;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Pack Weight:</font> '||rcd_prod.mpr_pck_weight;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Batch Weight:</font> '||rcd_prod.mpr_bch_weight;
               pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_prod.pty_prd_name||'</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
            elsif rcd_prod.mpr_prd_type = '*PACK' then
               pipe row('<tr><td align=center colspan=14></td></tr>');
               var_work := '<font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Default Line:</font> '||rcd_prod.mpr_dft_line;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Scheduling Priority:</font> '||rcd_prod.mpr_sch_priority;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Cases/Pallet:</font> '||rcd_prod.mpr_cas_pallet;
               pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_prod.pty_prd_name||'</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
            elsif rcd_prod.mpr_prd_type = '*FORM' then
               pipe row('<tr><td align=center colspan=14></td></tr>');
               var_work := '<font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Default Line:</font> '||rcd_prod.mpr_dft_line;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Scheduling Priority:</font> '||rcd_prod.mpr_sch_priority;
               var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Batch Lot Quantity:</font> '||rcd_prod.mpr_bch_quantity;
               pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_prod.pty_prd_name||'</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
            end if;

            /*-*/
            /* Retrieve the line data
            /*-*/
            var_lin_flag := false;
            open csr_line;
            loop
               fetch csr_line into rcd_line;
               if csr_line%notfound then
                  exit;
               end if;

               if rcd_prod.mpr_prd_type = '*FILL' then
                  var_work := rcd_line.mli_lin_code||' / '||rcd_line.mli_con_code;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Default:</font> '||rcd_line.mli_dft_flag;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate:</font> '||rcd_line.mli_rra_code;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate Efficiency %:</font> '||rcd_line.rrd_rra_efficiency;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate Wastage %:</font> '||rcd_line.rrd_rra_wastage;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Override Efficiency %:</font> '||rcd_line.mli_rra_efficiency;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Override Wastage %:</font> '||rcd_line.mli_rra_wastage;
                  if var_lin_flag = false then
                     pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>Lines</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
                  else
                     pipe row('<tr><td align=center colspan=1></td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
                  end if;
               elsif rcd_prod.mpr_prd_type = '*PACK' then
                  var_work := rcd_line.mli_lin_code||' / '||rcd_line.mli_con_code;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Default:</font> '||rcd_line.mli_dft_flag;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate:</font> '||rcd_line.mli_rra_code;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate Efficiency %:</font> '||rcd_line.rrd_rra_efficiency;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate Wastage %:</font> '||rcd_line.rrd_rra_wastage;
                  if var_lin_flag = false then
                     pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>Lines</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
                  else
                     pipe row('<tr><td align=center colspan=1></td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
                  end if;
               elsif rcd_prod.mpr_prd_type = '*FORM' then
                  var_work := rcd_line.mli_lin_code||' / '||rcd_line.mli_con_code;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Default:</font> '||rcd_line.mli_dft_flag;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate:</font> '||rcd_line.mli_rra_code;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate Efficiency %:</font> '||rcd_line.rrd_rra_efficiency;
                  var_work := var_work||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Run Rate Wastage %:</font> '||rcd_line.rrd_rra_wastage;
                  if var_lin_flag = false then
                     pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>Lines</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
                  else
                     pipe row('<tr><td align=center colspan=1></td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
                  end if;
               end if;
               var_lin_flag := true;

            end loop;
            close csr_line;

            /*-*/
            /* Retrieve the component data
            /*-*/
            var_com_flag := false;
            open csr_comp;
            loop
               fetch csr_comp into rcd_comp;
               if csr_comp%notfound then
                  exit;
               end if;

               var_work := rcd_comp.mco_com_code||' <font style="BACKGROUND-COLOR:#FFFFFF;COLOR:#4040FF;">Quantity:</font> '||rcd_comp.mco_com_quantity;
               if var_com_flag = false then
                  pipe row('<tr><td align=center colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>Components</td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
               else
                  pipe row('<tr><td align=center colspan=1></td><td align=left colspan=13 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td></tr>');
               end if;
               var_com_flag := true;

            end loop;
            close csr_comp;

         end loop;
         close csr_prod;

      end loop;
      close csr_defn;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');

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