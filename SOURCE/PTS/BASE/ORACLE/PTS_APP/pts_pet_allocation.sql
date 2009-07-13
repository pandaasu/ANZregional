/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_alc_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_alc_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Allocation functions

    This package contain the allocation functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure normal(par_tes_code in number);
   procedure difference(par_tes_code in number);
   function report_allocation(par_tes_code in number) return pts_xls_type pipelined;

end pts_alc_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_alc_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_key_map constant varchar2(36) := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';

   /*-*/
   /* Private definitions
   /*-*/
   type ptyp_skey is table of varchar2(32) index by binary_integer;
   ptbl_skey ptyp_skey;

   /*********************************************************/
   /* This procedure performs the normal allocation routine */
   /*********************************************************/
   procedure normal is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_key_work varchar2(36);
      var_key_index number;
      var_sam_index number;
      type typ_scod is table of pts_tes_sample%rowtype index by binary_integer;
      tbl_scod typ_scod;
      type typ_akey is table of varchar2(32) index by binary_integer;
      tbl_akey typ_akey;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tpa_tes_code = var_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_gen_function.randomize_allocation(tbl_scod.count, (select count(*) from pts_tes_panel where tpa_tes_code = rcd_retrieve.tde_tes_code)) t01;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01,
                (select t01.pcl_pet_code,
                        t01.pcl_val_code
                   from pts_pet_classification t01
                  where t01.pcl_tab_code = '*PET_CLA'
                    and t01.pcl_fld_code = 8) t02
          where t01.tpa_pan_code = t01.pcl_pet_code(+)
            and t01.tpa_tes_code = var_tes_code
          order by nvl(t02.pcl_val_code,1),
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
      /* Retrieve and lock the existing selection template
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      end if;

      --if day_count != sam_count then
      --   pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      --end if;

      /*-*/
      /* Clear the existing allocation
      /*-*/
      delete from pts_tes_allocation where tal_tes_code = var_tes_Code;

      /*-*/
      /* Retrieve and load the test sample array
      /*-*/
      tbl_scod.delete;
      open csr_sample;
      fetch csr_sample bulk collect into tbl_scod;
      close csr_sample;

      /*-*/
      /* Retrieve and load the allocation key array
      /*-*/
      tbl_akey.delete;
      open csr_allocation;
      fetch csr_allocation bulk collect into tbl_akey;
      close csr_allocation;

      /*-*/
      /* Retrieve the test panel
      /* **notes** 1. The sample retrieval has been randomized
      /*-*/
      var_key_index := tbl_skey.count;
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
         if var_key_index > tbl_skey.count then
            var_key_index := 1;
         end if;
         var_key_work := tbl_skey(var_key_index);
         for idx 1..length(var_key_work) loop
            var_sam_index := instr(con_key_map,substr(var_key_work,idx));
            if var_sam_index != 0 then
               rcd_pts_tes_allocation.tal_tes_code := rcd_panel.tpa_tes_code;
               rcd_pts_tes_allocation.tal_pan_code := rcd_panel.tpa_pan_code;
               rcd_pts_tes_allocation.tal_day_code := idx;
               rcd_pts_tes_allocation.tal_sam_code := tbl_sam(var_sam_index).tsa_sam_code;
               rcd_pts_tes_allocation.tal_seq_numb := idx;
               insert into pts_tes_allocation values rcd_pts_tes_allocation;
            end if;
         end loop;

      end loop;
      close csr_panel;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_ALC_FUNCTION - UPDATE_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end normal;

   /*************************************************************/
   /* This procedure performs the difference allocation routine */
   /*************************************************************/
   procedure difference is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;

      var_key_code varchar2(36);
      var_key_work varchar2(36);
      var_key_index number;
      var_sam_index number;
      type typ_scod is table of pts_tes_sample%rowtype index by binary_integer;
      tbl_scod typ_scod;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tpa_tes_code = var_tes_code;
      rcd_sample csr_sample%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_tes_panel t01,
                (select t01.pcl_pet_code,
                        t01.pcl_val_code
                   from pts_pet_classification t01
                  where t01.pcl_tab_code = '*PET_CLA'
                    and t01.pcl_fld_code = 8) t02
          where t01.tpa_pan_code = t01.pcl_pet_code(+)
            and t01.tpa_tes_code = var_tes_code
          order by nvl(t02.pcl_val_code,1),
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
         pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      end if;

      --if day_count != 2 then
      --   pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      --end if;
      --if day_count != sam_count then
      --   pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
      --end if;

      /*-*/
      /* Clear the existing allocation
      /*-*/
      delete from pts_tes_allocation where tal_tes_code = var_tes_Code;

      /*-*/
      /* Retrieve and load the test sample array
      /*-*/
      tbl_scod.delete;
      open csr_sample;
      fetch csr_sample bulk collect into tbl_scod;
      close csr_sample;
      var_key_code := null;
      for idx 1..tbl_scod loop
         var_key_code := var_key_code||substr(con_key_map,idx,1);
      end loop;

      /*-*/
      /* Retrieve and load the sample key array
      /*-*/
      pts_gen_function.randomize_allocation(sam_count,pan_count);

      /*-*/
      /* Retrieve the test panel
      /* **notes** 1. The sample retrieval has been randomized
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Create the test panel allocation
         /*-*/
         var_key_index := tbl_skey.count;
         for idd 1..rcd_retrieve.tde_day_count loop
            var_key_index := var_key_index + 1;
            if var_key_index > tbl_skey.count then
               var_key_index := 1;
            end if;
            var_key_work := tbl_skey(var_key_index);
            for idx 1..length(var_key_work) loop
               var_sam_index := instr(con_key_map,substr(var_key_work,idx));
               if var_sam_index != 0 then
                  rcd_pts_tes_allocation.tal_tes_code := rcd_panel.tpa_tes_code;
                  rcd_pts_tes_allocation.tal_pan_code := rcd_panel.tpa_pan_code;
                  rcd_pts_tes_allocation.tal_day_code := idd;
                  rcd_pts_tes_allocation.tal_sam_code := tbl_sam(var_sam_index).tsa_sam_code;
                  rcd_pts_tes_allocation.tal_seq_numb := idx;
                  insert into pts_tes_allocation values rcd_pts_tes_allocation;
               end if;
            end loop;
         end loop;

      end loop;
      close csr_panel;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_ALC_FUNCTION - DIFFERENCE - ' || substr(SQLERRM, 1, 1536));

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
      var_stm_code number;
      var_found boolean;
      var_group boolean;
      var_output varchar2(4000 char);
      var_work varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_code = var_stm_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_group is
         select t01.*
           from pts_stm_group t01
          where t01.stg_stm_code = var_stm_code
          order by t01.stg_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is
         select t01.*,
                t02.sfi_fld_text,
                t02.sfi_fld_rul_type
           from pts_stm_rule t01,
                pts_sys_field t02
          where t01.str_tab_code = t02.sfi_tab_code
            and t01.str_fld_code = t02.sfi_fld_code
            and t01.str_stm_code = var_stm_code
            and t01.str_sel_group = rcd_group.stg_sel_group
          order by t01.str_tab_code asc,
                   t01.str_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is
         select t01.*
           from pts_stm_value t01
          where t01.stv_stm_code = var_stm_code
            and t01.stv_sel_group = rcd_group.stg_sel_group
            and t01.stv_tab_code = rcd_rule.str_tab_code
            and t01.stv_fld_code = rcd_rule.str_fld_code
          order by t01.stv_val_code asc;
      rcd_value csr_value%rowtype;

      cursor csr_panel_pet is
         select t01.*,
                t02.*,
                t03.*
           from pts_stm_panel t01,
                pts_hou_definition t02,
                pts_pet_definition t03
          where t01.stp_hou_code = t02.hde_hou_code(+)
            and t01.stp_pan_code = t03.pde_pet_code(+)
            and t01.stp_stm_code = var_stm_code
            and t01.stp_sel_group = rcd_group.stg_sel_group
          order by t01.stp_pan_status asc,
                   t01.stp_pan_code asc;
      rcd_panel_pet csr_panel_pet%rowtype;

      cursor csr_panel_hou is
         select t01.*,
                t02.*
           from pts_stm_panel t01,
                pts_hou_definition t02
          where t01.stp_pan_code = t02.hde_hou_code(+)
            and t01.stp_stm_code = var_stm_code
            and t01.stp_sel_group = rcd_group.stg_sel_group
          order by t01.stp_pan_status asc,
                   t01.stp_pan_code asc;
      rcd_panel_hou csr_panel_hou%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_stm_code := par_stm_code;

      /*-*/
      /* Retrieve the existing selection template
      /*-*/
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         raise_application_error(-20000, 'Selection template code (' || to_char(var_stm_code) || ') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1>');
      pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">('||rcd_retrieve.std_stm_code||') '||rcd_retrieve.std_stm_text||'</td></tr>');
      pipe row('<tr>');
      pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
      pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Description</td>');
      pipe row('</tr>');
      pipe row('<tr><td align=center colspan=2></td></tr>');

      /*-*/
      /* Retrieve the report data
      /*-*/
      var_group := false;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Output the group separator
         /*-*/
         if var_group = true then
            pipe row('<tr><td align=center colspan=2></td></tr>');
         end if;
         var_group := true;

         /*-*/
         /* Output the group data
         /*-*/
         var_work := rcd_group.stg_sel_text||' ('||to_char(rcd_group.stg_sel_pcnt)||'%)';
         var_work := var_work||' - Requested/Selected Members ('||to_char(rcd_group.stg_req_mem_count)||'/'||to_char(rcd_group.stg_sel_mem_count)||')';
         var_work := var_work||' - Requested/Selected Reserves ('||to_char(rcd_group.stg_req_res_count)||'/'||to_char(rcd_group.stg_sel_res_count)||')';
         var_output := '<tr>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Group</td>';
         var_output := var_output||'<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;" nowrap>'||var_work||'</td>';
         var_output := var_output||'</tr>';
         pipe row(var_output);
         pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rules</td></tr>');

         /*-*/
         /* Retrieve the rule data
         /*-*/
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Output the rule data
            /*-*/
            var_work := rcd_rule.sfi_fld_text||' ('||rcd_rule.str_rul_code||')';
            var_output := '<tr>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Rule</td>';
            var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
            var_output := var_output||'</tr>';
            pipe row(var_output);

            /*-*/
            /* Retrieve the value data
            /*-*/
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               if rcd_rule.sfi_fld_rul_type = '*TEXT' or rcd_rule.sfi_fld_rul_type = '*NUMBER' then
                  var_work := rcd_value.stv_val_text;
               else
                  var_work := rcd_value.stv_val_text;
                  if rcd_rule.str_rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                     var_work := rcd_value.stv_val_text||' ('||rcd_value.stv_val_pcnt||'%)';
                     var_work := var_work||' - Requested/Selected Members ('||to_char(rcd_value.stv_req_mem_count)||'/'||to_char(rcd_value.stv_sel_mem_count)||')';
                     var_work := var_work||' - Requested/Selected Reserves ('||to_char(rcd_value.stv_req_res_count)||'/'||to_char(rcd_value.stv_sel_res_count)||')';
                  end if;
               end if;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_value;

         end loop;
         close csr_rule;

         /*-*/
         /* Retrieve the panel data
         /*-*/
         if rcd_retrieve.std_stm_target = 1 then
            pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Panel</td></tr>');
            open csr_panel_pet;
            loop
               fetch csr_panel_pet into rcd_panel_pet;
               if csr_panel_pet%notfound then
                  exit;
               end if;
               var_work := 'Household ('||rcd_panel_pet.stp_hou_code||') '||rcd_panel_pet.hde_con_fullname||', '||rcd_panel_pet.hde_loc_street||', '||rcd_panel_pet.hde_loc_town;
               var_work := var_work||' - Pet ('||rcd_panel_pet.stp_pan_code||') '||rcd_panel_pet.pde_pet_name;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel_pet.stp_pan_status||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_panel_pet;
         else
            pipe row('<tr><td align=center colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">Panel</td></tr>');
            open csr_panel_hou;
            loop
               fetch csr_panel_hou into rcd_panel_hou;
               if csr_panel_hou%notfound then
                  exit;
               end if;
               var_work := 'Household ('||rcd_panel_hou.stp_pan_code||') '||rcd_panel_hou.hde_con_fullname||', '||rcd_panel_hou.hde_loc_street||', '||rcd_panel_hou.hde_loc_town;
               var_output := '<tr>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel_hou.stp_pan_status||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:9pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||var_work||'</td>';
               var_output := var_output||'</tr>';
               pipe row(var_output);
            end loop;
            close csr_panel_hou;
         end if;

      end loop;
      close csr_group;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_ALC_FUNCTION - REPORT_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_allocation;

end pts_alc_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_alc_function for pts_app.pts_alc_function;
grant execute on pts_app.pts_alc_function to public;
