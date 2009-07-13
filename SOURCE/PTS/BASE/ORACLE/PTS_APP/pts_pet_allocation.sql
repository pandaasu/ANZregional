/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_pet_allocation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pet_allocation
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet allocation

    This package contain the pet allocation functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure perform_allocation(par_tes_code in number);
   function report_allocation(par_tes_code in number) return pts_xls_type pipelined;

end pts_pet_allocation;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_pet_allocation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure standard(par_tes_code in number, par_day_count in number);
   procedure difference(par_tes_code in number, par_day_count in number);

   /*-*/
   /* Private constants
   /*-*/
   con_key_map constant varchar2(36) := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';

   /**********************************************************/
   /* This procedure performs the perform allocation routine */
   /**********************************************************/
   procedure perform_allocation(par_tes_code in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                nvl(t02.tty_sam_count,1) as tty_sam_count,
                t02.tty_alc_proc
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = par_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------------------------------------------*/
      /* NOTE - This procedure is under autonomous transaction control */
      /*---------------------------------------------------------------*/

      /*-*/
      /* Retrieve the existing test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') does not exist');
      end if;
      if rcd_retrieve.tde_tes_status != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(par_tes_code) || ') must be status (Raised) - allocation not allowed');
      end if;

      /*-*/
      /* Execute the allocation procedure
      /*-*/
      execute immediate 'begin '||rcd_retrieve.tty_alc_proc||'(' ||to_char(rcd_retrieve.tde_tes_code)||','||to_char(rcd_retrieve.tde_tes_day_count)||'); end;';

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_ALLOCATION - PERFORM_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end perform_allocation;

   /***********************************************************/
   /* This procedure performs the standard allocation routine */
   /***********************************************************/
   procedure standard(par_tes_code in number, par_day_count in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_key_work varchar2(36);
      var_key_index number;
      var_sam_index number;
      type typ_scod is table of pts_tes_sample%rowtype index by binary_integer;
      tbl_scod typ_scod;
      type typ_akey is table of varchar2(36) index by binary_integer;
      tbl_akey typ_akey;
      rcd_pts_tes_allocation pts_tes_allocation%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = par_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_allocation is
         select t01.*
           from table(pts_gen_function.randomize_allocation((select count(*) from pts_tes_sample where tsa_tes_code = par_tes_code), (select count(*) from pts_tes_panel where tpa_tes_code = par_tes_code))) t01;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code
                   from pts_tes_classification t01
                  where t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t02
          where t01.tpa_pan_code = t02.tcl_pan_code(+)
            and t01.tpa_tes_code = par_tes_code
          order by nvl(t02.tcl_val_code,1),
                   t01.tpa_pan_code;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve and load the test sample array
      /*-*/
      tbl_scod.delete;
      open csr_sample;
      fetch csr_sample bulk collect into tbl_scod;
      close csr_sample;
      if par_day_count != tbl_scod.count then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') duration days and sample count must match');
      end if;

      /*-*/
      /* Retrieve and load the allocation key array
      /*-*/
      tbl_akey.delete;
      open csr_allocation;
      fetch csr_allocation bulk collect into tbl_akey;
      close csr_allocation;

      /*-*/
      /* Clear the existing allocation
      /*-*/
      delete from pts_tes_allocation where tal_tes_code = par_tes_code;

      /*-*/
      /* Retrieve the test panel
      /* **notes** 1. The sample retrieval has been randomized so panel
      /*              does not need to be randomized
      /*           2. The panel has been sort by pet size to introduce
      /*              the sample randomization into the pet type
      /*-*/
      var_key_index := tbl_akey.count;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Create the test panel allocation
         /*-*/
         var_key_index := var_key_index + 1;
         if var_key_index > tbl_akey.count then
            var_key_index := 1;
         end if;
         var_key_work := tbl_akey(var_key_index);
         for idx in 1..length(var_key_work) loop
            var_sam_index := instr(con_key_map,substr(var_key_work,idx));
            if var_sam_index != 0 then
               rcd_pts_tes_allocation.tal_tes_code := rcd_panel.tpa_tes_code;
               rcd_pts_tes_allocation.tal_pan_code := rcd_panel.tpa_pan_code;
               rcd_pts_tes_allocation.tal_day_code := idx;
               rcd_pts_tes_allocation.tal_sam_code := tbl_scod(var_sam_index).tsa_sam_code;
               rcd_pts_tes_allocation.tal_seq_numb := idx;
               insert into pts_tes_allocation values rcd_pts_tes_allocation;
            end if;
         end loop;

      end loop;
      close csr_panel;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end standard;

   /*************************************************************/
   /* This procedure performs the difference allocation routine */
   /*************************************************************/
   procedure difference(par_tes_code in number, par_day_count in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_key_work varchar2(36);
      var_key_index number;
      var_sam_index number;
      var_switch boolean;
      type typ_scod is table of pts_tes_sample%rowtype index by binary_integer;
      tbl_scod typ_scod;
      type typ_akey is table of varchar2(36) index by binary_integer;
      tbl_akey typ_akey;
      rcd_pts_tes_allocation pts_tes_allocation%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = par_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_allocation is
         select t01.*
           from table(pts_gen_function.randomize_allocation((select count(*) from pts_tes_sample where tsa_tes_code = par_tes_code), (select count(*) from pts_tes_panel where tpa_tes_code = par_tes_code))) t01;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code
                   from pts_tes_classification t01
                  where t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t02
          where t01.tpa_pan_code = t02.tcl_pan_code(+)
            and t01.tpa_tes_code = par_tes_code
          order by nvl(t02.tcl_val_code,1),
                   t01.tpa_pan_code;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------------------------------------------*/
      /* NOTE - This procedure is under autonomous transaction control */
      /*---------------------------------------------------------------*/

      /*-*/
      /* Test validation
      /*-*/
      if par_day_count != 2 then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') duration must be 2 days for a difference allocation');
      end if;

      /*-*/
      /* Retrieve and load the test sample array
      /*-*/
      tbl_scod.delete;
      open csr_sample;
      fetch csr_sample bulk collect into tbl_scod;
      close csr_sample;
      if par_day_count != tbl_scod.count then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') duration days and sample count must match');
      end if;

      /*-*/
      /* Retrieve and load the allocation key array
      /*-*/
      tbl_akey.delete;
      open csr_allocation;
      fetch csr_allocation bulk collect into tbl_akey;
      close csr_allocation;

      /*-*/
      /* Clear the existing allocation
      /*-*/
      delete from pts_tes_allocation where tal_tes_code = par_tes_code;

      /*-*/
      /* Retrieve the test panel
      /* **notes** 1. The sample retrieval has been randomized so panel
      /*              does not need to be randomized
      /*           2. The panel has been sort by pet size to introduce
      /*              the sample randomization into the pet type
      /*-*/
      var_switch := false;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Create the test panel allocation
         /*-*/
         if var_switch = false then
            var_key_index := tbl_akey.count;
         else
            var_key_index := 1;
         end if;
         for idx in 1..par_day_count loop
            if var_switch = false then
               var_key_index := var_key_index + 1;
               if var_key_index > tbl_akey.count then
                  var_key_index := 1;
               end if;
            else
               var_key_index := var_key_index - 1;
               if var_key_index < 1 then
                  var_key_index := tbl_akey.count;
               end if;
            end if;
            var_key_work := tbl_akey(var_key_index);
            for idy in 1..length(var_key_work) loop
               var_sam_index := instr(con_key_map,substr(var_key_work,idy));
               if var_sam_index != 0 then
                  rcd_pts_tes_allocation.tal_tes_code := rcd_panel.tpa_tes_code;
                  rcd_pts_tes_allocation.tal_pan_code := rcd_panel.tpa_pan_code;
                  rcd_pts_tes_allocation.tal_day_code := idx;
                  rcd_pts_tes_allocation.tal_sam_code := tbl_scod(var_sam_index).tsa_sam_code;
                  rcd_pts_tes_allocation.tal_seq_numb := idy;
                  insert into pts_tes_allocation values rcd_pts_tes_allocation;
               end if;
            end loop;
         end loop;
         if var_switch = false then
            var_switch := true;
         else
            var_switch := false;
         end if;

      end loop;
      close csr_panel;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end difference;

   /*********************************************************/
   /* This procedure performs the report allocation routine */
   /*********************************************************/
   function report_allocation(par_tes_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_panel boolean;
      var_first boolean;
      var_output varchar2(4000 char);
      var_work varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                nvl(t02.tty_sam_count,1) as tty_sam_count
           from pts_tes_definition t01,
                pts_tes_type t02
          where t01.tde_tes_type = t02.tty_tes_type(+)
            and t01.tde_tes_code = par_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_panel is
         select t01.*,
                decode(t02.tcl_val_code,null,'*UNKNOWN','('||t02.tcl_val_code||') '||t02.sva_val_text) as size_text
           from pts_tes_panel t01,
                (select t01.tcl_pan_code,
                        t01.tcl_val_code,
                        nvl(t02.sva_val_text,'*UNKNOWN') as sva_val_text
                   from pts_tes_classification t01,
                        (select t01.sva_val_code,
                                t01.sva_val_text
                           from pts_sys_value t01
                          where t01.sva_tab_code = '*PET_CLA'
                            and t01.sva_fld_code = 8) t02
                  where t01.tcl_val_code = t02.sva_val_code(+)
                    and t01.tcl_tab_code = '*PET_CLA'
                    and t01.tcl_fld_code = 8) t02
          where t01.tpa_pan_code = t02.tcl_pan_code(+)
            and t01.tpa_tes_code = rcd_retrieve.tde_tes_code
          order by t01.tpa_pan_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.tal_day_code,
                t01.tal_seq_numb,
                t02.tsa_rpt_code,
                t02.tsa_mkt_code,
                t02.tsa_mkt_acde,
                '('||t01.tal_sam_code||') '||nvl(t03.sde_sam_text,'*UNKNOWN') as sample_text
           from pts_tes_allocation t01,
                pts_tes_sample t02,
                pts_sam_definition t03
          where t01.tal_tes_code = t02.tsa_tes_code(+)
            and t01.tal_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_sam_code = t03.sde_sam_code(+)
            and t01.tal_tes_code = rcd_panel.tpa_tes_code
            and t01.tal_pan_code = rcd_panel.tpa_pan_code
          order by t01.tal_day_code asc,
                   t01.tal_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Test code ('||to_char(par_tes_code)||') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      if rcd_retrieve.tty_sam_count = 1 then
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=8 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Size</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Description</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Day</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Report Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Research Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Research Alias</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sample</td>');
         pipe row('</tr>');
         pipe row('<tr><td align=center colspan=8></td></tr>');
      else
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=9 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">('||rcd_retrieve.tde_tes_code||') '||rcd_retrieve.tde_tes_title||'</td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Size</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Panel</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Day</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sequence</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Report Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Research Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Research Alias</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sample</td>');
         pipe row('</tr>');
         pipe row('<tr><td align=center colspan=9></td></tr>');
      end if;

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := false;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Panel found
         /*-*/
         var_panel := true;

         /*-*/
         /* Set the panel data
         /*-*/
         var_work := 'Household ('||rcd_panel.tpa_hou_code||') '||rcd_panel.tpa_con_fullname||', '||rcd_panel.tpa_loc_street||', '||rcd_panel.tpa_loc_town;
         var_work := var_work||' - Pet ('||rcd_panel.tpa_pan_code||') '||rcd_panel.tpa_pet_name;

         /*-*/
         /* Retrieve the test panel allocation
         /*-*/
         var_first := true;
         open csr_allocation;
         loop
            fetch csr_allocation into rcd_allocation;
            if csr_allocation%notfound then
               exit;
            end if;
            var_output := '<tr>';
            if var_first = true then
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.tpa_pan_status||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.size_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
            else
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap></td>';
            end if;
            var_first := false;
            if rcd_retrieve.tty_sam_count = 1 then
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tal_day_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tsa_rpt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tsa_mkt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tsa_mkt_acde)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.sample_text)||'</td>';
               var_output := var_output||'</tr>';
            else
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tal_day_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tal_seq_numb)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tsa_rpt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tsa_mkt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tsa_mkt_acde)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.sample_text)||'</td>';
               var_output := var_output||'</tr>';
            end if;
            pipe row(var_output);
         end loop;
         close csr_allocation;

      end loop;
      close csr_panel;

      /*-*/
      /* No Panel selection
      /*-*/
      if var_panel = false then
         if rcd_retrieve.tty_sam_count = 1 then
            pipe row('<tr><td align=center colspan=8 style="FONT-WEIGHT:bold;">NO PANEL</td></tr>');
         else
            pipe row('<tr><td align=center colspan=9 style="FONT-WEIGHT:bold;">NO PANEL</td></tr>');
         end if;
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_PET_ALLOCATION - REPORT_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_allocation;

end pts_pet_allocation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pet_allocation for pts_app.pts_pet_allocation;
grant execute on pts_app.pts_pet_allocation to public;
