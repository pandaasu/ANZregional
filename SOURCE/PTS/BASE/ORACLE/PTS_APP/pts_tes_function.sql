/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_test_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_app.pts_test_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Test Maintenance

    This package contain the procedures and functions for product test.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure select_pet_panel(par_tes_code in number);
   procedure select_household_panel(par_tes_code in number);

end pts_test_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_test_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************/
   /* This procedure performs the select pet panel routine */
   /********************************************************/
   procedure select_pet_panel(par_tes_code in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_tes_code number;
      var_tot_mem_count integer;
      var_tot_res_count integer;
      var_set_tot_count integer;
      var_set_sel_count integer;
      var_pan_selected boolean;
      var_pan_exit boolean;

      type rcd_group is record(sel_group varchar2(32 char),
                               str_rule number,
                               end_rule number,
                               req_mem_count number,
                               req_res_count number,
                               sel_mem_count number,
                               sel_res_count number);
      type typ_group is table of rcd_group index by binary_integer;
      tbl_group typ_group;

      type rcd_rule is record(sel_group varchar2(32 char),
                              tab_code varchar2(32 char),
                              fld_code number,
                              sel_code varchar2(32 char),
                              str_rule number,
                              end_rule number,
                              req_mem_count number,
                              req_res_count number,
                              sel_mem_count number,
                              sel_res_count number,
                              sel_count number);
      type typ_rule is table of rcd_rule index by binary_integer;
      tbl_rule typ_rule;

      type rcd_value is record(sel_group varchar2(32 char),
                               tab_code varchar2(32 char),
                               fld_code number,
                               val_code number,
                               fld_text varchar2(256 char),
                               fld_percent number,
                               req_mem_count number,
                               req_res_count number,
                               sel_mem_count number,
                               sel_res_count number,
                               sel_count number,
                               fld_count number);
      type typ_value is table of rcd_value index by binary_integer;
      tbl_value typ_value;

      type rcd_class is record(tab_code varchar2(32 char),
                               fld_code number,
                               val_code number,
                               fld_text varchar2(4000 char));
      type typ_class is table of rcd_class index by binary_integer;
      tbl_class typ_class;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_test is 
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code;
      rcd_test csr_test%rowtype;

      cursor csr_group is 
         select t01.*
           from pts_tes_sel_group t01
          where t01.tsg_tes_code = rcd_test.tde_tes_code
          order by t01.tsg_sel_group;
      rcd_group csr_group%rowtype;

      cursor csr_rule is 
         select t01.*
           from pts_tes_sel_rule t01
          where t01.tsr_tes_code = rcd_test.tde_tes_code
            and t01.tsr_sel_group = rcd_group.tsg_tes_group
          order by t01.tsr_dsp_seqn;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is 
         select t01.*
           from pts_tes_sel_value t01
          where t01.tsv_tes_code = rcd_test.tde_tes_code
            and t01.tsv_sel_group = rcd_rule.tsr_sel_group
            and t01.tsv_tab_code = rcd_rule.tsv_tab_value
            and t01.tsv_fld_code = rcd_rule.tsv_fld_value
          order by t01.tsv_dsp_seqn;
      rcd_value csr_value%rowtype;


Test Status                   	1	Raised                        
Test Status                   	2	Questionnaires Printed        
Test Status                   	3	Results Entered               
Test Status                   	4	Closed                        
Test Status                   	9	Cancelled                     



      cursor csr_member is 
         select t01.*
           from pts_pet_definition t01,
                table(pts_app.pts_gen_function.pet_selection('select p1.pde_pet_code from pts_pet_definition p1, pts_hou_definition h1 where p1.pde_hou_code = h1.hde_hou_code(+)')) t02
          where t01.pde_pet_code = t02.pan_code
            and t01.pde_pet_status = '*ACTIVE'
            and t01.pde_tes_dates = ****DONT CLASH
          order by dbms_random.value;
      rcd_member csr_member%rowtype;

      cursor csr_reserve is 
         select t01.*
           from pts_pet_definition t01,
                table(pts_app.pts_gen_function.pet_selection('select p1.pde_pet_code from pts_pet_definition p1, pts_hou_definition h1 where p1.pde_hou_code = h1.hde_hou_code(+)')) t02
          where t01.pde_pet_code = t02.pan_code
            and t01.pde_pet_status = '*ACTIVE'
            and t01.pde_tes_dates = ****DONT CLASH
            and t01.pde_pet_code not in (select nvl(tsp_pet_code,-1)
                                           from pts_tes_sel_panel
                                          where tsp_tes_code = rcd_test.tde_tes_code)
          order by dbms_random.value;
      rcd_reserve csr_reserve%rowtype;

      cursor csr_hou_classificaton is 
         select t01.*
           from pts_hou_classification t01
          where t01.hcl_hou_code = var_hou_code
          order by t01.hcl_cla_code;
      rcd_hou_classificaton csr_hou_classificaton%rowtype;

      cursor csr_pet_classificaton is 
         select t01.*
           from pts_pet_classification t01
          where t01.pcl_pet_code = var_pet_code
          order by t01.pcl_cla_code;
      rcd_pet_classificaton csr_pet_classificaton%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Validate the parameter values
      /*-*/
      if par_tes_code is null then
         raise_application_error(-20000, 'Test identifier must be specified');
      end if;
      var_tes_code := par_tes_code;

      /*-*/
      /* Retrieve the test definition
      /*-*/
      open csr_test;
      fetch csr_test into rcd_test;
      if csr_test%notfound then
         raise_application_error(-20000, 'Test code (' || to_char(var_test_code) || ') does not exist');
      end if;
      close csr_test;
      if rcd_test.tes_status != 222 then
         raise_application_error(-20000, 'Test code (' || to_char(var_test_code) || ') is *ACTIVE or *COMPLETE - panel selection not allowed');
      end if;

      /*-*/
      /* Process the selection groups
      /*-*/
      tbl_group.delete;
      tbl_rule.delete;
      tbl_value.delete;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Clear the work selection temporary tables
         /*-*/
         delete from pts_wor_sel_rule;
         delete from pts_wor_sel_value;

         /*-*/
         /* Reset the test group selection member and reserve counts
         /*-*/
         update pts_tes_sel_group
            set tsg_sel_mem_count = 0,
                tsg_sel_res_count = 0
          where tsg_tes_code = rcd_group.tsg_tes_code
            and tsg_sel_group = rcd_group.tsg_sel_group;

         /*-*/
         /* Load the group array
         /*-*/
         tbl_group(tbl_group.count+1).sel_group := rcd_group.tsg_sel_group;
         tbl_group(tbl_group.count).str_rule := 0;
         tbl_group(tbl_group.count).end_rule := 0;
         tbl_group(tbl_group.count).req_mem_count := rcd_group.tsg_req_mem_count;
         tbl_group(tbl_group.count).req_res_count := rcd_group.tsg_req_res_count;
         tbl_group(tbl_group.count).sel_mem_count := 0;
         tbl_group(tbl_group.count).sel_res_count := 0;

         /*-*/
         /* Process the selection group rules
         /*-*/
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            insert into pts_wor_sel_rule
               values(rcd_rule.tsr_sel_group,
                      rcd_rule.tsr_rul_seqn,
                      rcd_rule.tsr_tab_code,
                      rcd_rule.tsr_fld_code,
                      rcd_rule.tsr_rul_test,
                      rcd_rule.tsr_rul_type);

            /*-*/
            /* Reset the test group rule panel member and reserve counts
            /*-*/
            update pts_tes_sel_rule
               set tsr_req_mem_count = tbl_group(tbl_group.count).req_mem_count,
                   tsr_req_res_count = tbl_group(tbl_group.count).req_res_count,
                   tsr_sel_mem_count = 0,
                   tsr_sel_res_count = 0
             where tsr_tes_code = rcd_rule.tsr_tes_code
               and tsr_sel_group = rcd_rule.tsr_sel_group
               and tsr_tab_code = rcd_rule.tsr_tab_code
               and tsr_fld_code = rcd_rule.tsr_fld_code;

            /*-*/
            /* Load the rule array
            /*-*/
            tbl_rule(tbl_rule.count+1).sel_group := rcd_rule.tsr_sel_group;
            tbl_rule(tbl_rule.count).tab_code := rcd_rule.tsr_tab_code;
            tbl_rule(tbl_rule.count).fld_code := rcd_rule.tsr_fld_code;
            tbl_rule(tbl_rule.count).sel_code := rcd_rule.tsr_sel_code;
            tbl_rule(tbl_rule.count).str_value := 0;
            tbl_rule(tbl_rule.count).end_value := 0;
            tbl_rule(tbl_rule.count).req_mem_count := tbl_group(tbl_group.count).req_mem_count;
            tbl_rule(tbl_rule.count).req_res_count := tbl_group(tbl_group.count).req_res_count;
            tbl_rule(tbl_rule.count).sel_mem_count := 0;
            tbl_rule(tbl_rule.count).sel_res_count := 0;
            tbl_rule(tbl_rule.count).sel_count := 0;
            if tbl_group(tbl_group.count).str_rule = 0 then
               tbl_group(tbl_group.count).str_rule := tbl_rule.count;
            end if;
            tbl_group(tbl_group.count).end_rule := tbl_rule.count;

            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_tot_mem_count := 0;
            var_tot_res_count := 0;
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;

               insert into pts_wor_sel_value
                  values(rcd_value.tsv_sel_group,
                         rcd_value.tsv_rul_seqn,
                         rcd_value.tsv_val_seqn,
                         rcd_value.tsv_val_value);

               tbl_value(tbl_value.count+1).sel_group := rcd_value.tsv_sel_group;
               tbl_value(tbl_value.count).tab_code := rcd_value.tsv_cla_code;
               tbl_value(tbl_value.count).fld_code := rcd_value.tsv_fld_code;
               tbl_value(tbl_value.count).val_code := rcd_value.tsv_val_code;
               tbl_value(tbl_value.count).fld_text := rcd_value.tsv_fld_text;
               tbl_value(tbl_value.count).fld_pcnt := rcd_value.tsv_fld_pcnt;
               tbl_value(tbl_value.count).req_mem_count := 0;
               tbl_value(tbl_value.count).req_res_count := 0;
               tbl_value(tbl_value.count).sel_mem_count := 0;
               tbl_value(tbl_value.count).sel_res_count := 0;
               tbl_value(tbl_value.count).sel_count := 0;
               tbl_value(tbl_value.count).fld_count := 0;
               if tbl_rule(tbl_rule.count).sel_code = '*SELECT_WHEN_EQ_MIX' then
                  tbl_value(tbl_value.count).req_mem_count := round(tbl_rule(tbl_rule.count).req_mem_count * nvl(rcd_value.tsv_fld_pcnt,0), 0);
                  tbl_value(tbl_value.count).req_res_count := round(tbl_rule(tbl_rule.count).req_res_count * nvl(rcd_value.tsv_fld_pcnt,0), 0);
                  var_tot_mem_count := var_tot_mem_count + tbl_value(tbl_value.count).req_mem_count;
                  var_tot_res_count := var_tot_res_count + tbl_value(tbl_value.count).req_res_count;
               else
                  tbl_value(tbl_value.count).req_mem_count := tbl_rule(tbl_rule.count).req_mem_count;
                  tbl_value(tbl_value.count).req_res_count := tbl_rule(tbl_rule.count).req_res_count;
               end if;
               if tbl_rule(tbl_rule.count).str_value = 0 then
                  tbl_rule(tbl_rule.count).str_value := tbl_value.count;
               end if;
               tbl_rule(tbl_rule.count).end_value := tbl_value.count;
            end loop;
            close csr_value;
            if tbl_rule(tbl_rule.count).sel_code = '*SELECT_WHEN_EQ_MIX' then
               if tbl_value.count != 0 then
                  if var_tot_mem_count != tbl_rule(tbl_rule.count).req_mem_count then
                     tbl_value(tbl_value.count).req_mem_count := tbl_value(tbl_value.count).req_mem_count + (tbl_rule(tbl_rule.count).req_mem_count - var_tot_mem_count);
                  end if;
                  if var_tot_res_count != tbl_rule(tbl_rule.count).req_res_count then
                     tbl_value(tbl_value.count).req_res_count := tbl_value(tbl_value.count).req_res_count + (tbl_rule(tbl_rule.count).req_res_count - var_tot_res_count);
                  end if;
               end if;
            end if;

            /*-*/
            /* Reset the test group rule value panel member and reserve counts when required
            /*-*/
            if tbl_rule(tbl_rule.count).str_value != 0 then
               for idx in tbl_rule(tbl_rule.count).str_value..tbl_rule(tbl_rule.count).end_value loop
                  update pts_tes_sel_value
                     set tsv_req_mem_count = tbl_value(idx).req_mem_count,
                         tsv_req_res_count = tbl_value(idx).req_res_count,
                         tsv_sel_mem_count = 0,
                         tsv_sel_res_count = 0
                   where tsv_tes_code = rcd_test.tde_tes_code
                     and tsv_sel_group = tbl_value(idx).sel_group
                     and tsv_tab_code = tbl_value(idx).tab_code
                     and tsv_fld_code = tbl_value(idx).fld_code
                     and tsv_val_code = tbl_value(idx).val_code;
               end loop;
            end if;

         end loop;
         close csr_rule;

      end loop;
      close csr_group;

      /*-*/
      /* Reset the test panel member and reserve counts
      /*-*/
      var_tot_mem_count := 0;
      var_tot_res_count := 0;
      for idx in 1..tbl_group.count loop
         var_tot_mem_count := var_tot_mem_count + tbl_group(idx).req_mem_count;
         var_tot_res_count := var_tot_res_count + tbl_group(idx).req_res_count;
      end loop;
      update pts_tes_definition
         set tde_req_mem_count = var_tot_mem_count,
             tde_req_res_count = var_tot_res_count,
             tde_sel_mem_count = 0,
             tde_sel_res_count = 0
       where tde_tes_code = rcd_test.tde_tes_code;

      /*-*/
      /* Delete the existing test panel data
      /*-*/
IF DELETE REQUESTED -- WHAT ABOUT COUNTS???
      delete from pts_tes_sel_panel
       where tsp_tes_code = rcd_test.tde_tes_code;
END IF

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Process the panel for potential members
      /*-*/
      open csr_member;
      loop
         fetch csr_member into rcd_member;
         if csr_member%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the household and pet classifications
         /*-*/
         var_hou_code := rcd_member.pde_hou_code;
         var_pet_code := rcd_member.pde_pet_code;
         tbl_class.delete;
         open csr_hou_classificaton;
         loop
            fetch csr_hou_classificaton into rcd_hou_classificaton;
            if csr_hou_classificaton%notfound then
               exit;
            end if;
            tbl_class(tbl_class.count+1).tab_code := rcd_hou_classificaton.tab_code;
            tbl_class(tbl_class.count).fld_code := rcd_hou_classificaton.fld_code;
            tbl_class(tbl_class.count).val_code := rcd_hou_classificaton.val_code;
            tbl_class(tbl_class.count).fld_text := rcd_hou_classificaton.fld_text;
         end loop;
         close csr_hou_classificaton;
         open csr_pet_classificaton;
         loop
            fetch csr_pet_classificaton into rcd_pet_classificaton;
            if csr_pet_classificaton%notfound then
               exit;
            end if;
            tbl_class(tbl_class.count+1).tab_code := rcd_pet_classificaton.tab_code;
            tbl_class(tbl_class.count).fld_code := rcd_pet_classificaton.fld_code;
            tbl_class(tbl_class.count).val_code := rcd_pet_classificaton.val_code;
            tbl_class(tbl_class.count).fld_text := rcd_pet_classificaton.fld_text;
         end loop;
         close csr_pet_classificaton;

         /*-*/
         /* Process the selection groups
         /* **note** 1. Groups are logically ORed and mutually exclusive
         /*          2. The first group to satisfy all group rules will be selected
         /*-*/
         var_pan_selected := false;
         for idx in 1..tbl_group.count loop

            /*-*/
            /* Only process groups with remaining quotas
            /*-*/
            if tbl_group(idx).req_mem_count > tbl_group(idx).sel_mem_count then

               /*-*/
               /* Process the selection group rules
               /* **note** 1. Rules are logically ANDed
               /*-*/
               for idy in tbl_group(idx).str_value..tbl_group(idx).end_value loop

                  /*-*/
                  /* Record the rule value classification hits
                  /* **note** 1. Lookup the related classification value
                  /*-*/
                  for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                     tbl_value(idz).sel_count := 0;
                     tbl_value(idz).fld_count := 0;
                     for idc in 1..tbl_class.count loop
                        if (tbl_class(idc).tab_code = tbl_value(idz).tab_code and
                            tbl_class(idc).fld_code = tbl_value(idz).fld_code and
                            tbl_class(idc).val_code = tbl_value(idz).val_code) then
                           tbl_value(idz).fld_count := 1;
                           exit;
                        end if;
                     end loop;
                  end loop;

                  /*-*/
                  /* Evaluate the rule results
                  /* **note** 1. Compare the requested and selected counts
                  /*-*/
                  var_set_tot_count := 0;
                  var_set_sel_count := 0;
                  for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                     var_set_tot_count := var_set_tot_count + 1;
                     if tbl_value(idz).fld_count = 1 then
                        var_set_sel_count := var_set_sel_count + 1;
                     end if;
                  end loop;
                  tbl_rule(idy).sel_count := 0;
                  if tbl_rule(idy).rul_test = '*INCLUDE' then
                     if tbl_rule(idy).rul_cond = '*WHEN_ANY' then
                        if var_set_sel_count != 0 then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           if tbl_value(idz).fld_count = 1 then
                              tbl_value(idz).sel_count := 1;
                              exit;
                           end if;
                        end loop;
                     elsif tbl_rule(idy).rul_cond = '*WHEN_ALL' then
                        if var_set_sel_count = var_set_tot_count then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           tbl_value(idz).sel_count := 1;
                        end loop;
                     end if;
                  elsif tbl_rule(idy).rul_test = '*EXCLUDE' then
                     if tbl_rule(idy).rul_cond = '*WHEN_ANY' then
                        if var_set_sel_count = 0 then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                     elsif tbl_rule(idy).rul_cond = '*WHEN_ALL' then
                        if var_set_sel_count != var_set_tot_count then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           if tbl_value(idz).fld_count = 1 then
                              tbl_value(idz).sel_count := 1;
                           end if;
                        end loop;
                     end if;
                  elsif tbl_rule(idy).rul_test = '*MIX' then
                     if var_set_sel_count != 0 then
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           if tbl_value(idz).req_mem_count > tbl_value(idz).sel_mem_count then
                              if tbl_value(idz).fld_count = 1 then
                                 tbl_value(idz).sel_count := 1;
                                 tbl_rule(idy).sel_count := 1;
                                 exit;
                              end if;
                           end if;
                        end loop;
                     end if;
                  end if;

               end loop;

               /*-*/
               /* Evaluate the group selection
               /* **note** 1. Compare the rule total count to the rule selected count
               /*          2. All rules must be satisfied (logically ANDed)
               /*-*/
               var_set_tot_count := 0;
               var_set_sel_count := 0;
               for idy in tbl_group(idx).str_value..tbl_group(idx).end_value loop
                  var_set_tot_count := var_set_tot_count + 1;
                  if tbl_rule(idy).sel_count = 1 then
                     var_set_sel_count := var_set_sel_count + 1;
                  end if;
               end loop;
               if var_set_sel_count = var_set_tot_count then
                  var_pan_selected := true;
                  tbl_group(idx).sel_mem_count := tbl_group(idx).sel_mem_count + 1;
                  for idy in tbl_group(idx).str_value..tbl_group(idx).end_value loop
                     tbl_rule(idy).sel_mem_count := tbl_rule(idy).sel_mem_count + 1;
                     for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                        if tbl_value(idz).sel_count = 1 then
                           tbl_value(idz).sel_mem_count := tbl_value(idz).sel_mem_count + 1;
                        end if;
                     end loop;
                  end loop;
               end if;

               /*-*/
               /* Insert the new panel member when required
               /*-*/
               if var_pan_selected = true then
                  rcd_tes_sel_panel.tsp_tes_code := rcd_test.tde_tes_code;
                  rcd_tes_sel_panel.tsp_sel_group := tbl_group(idx).sel_group;
                  rcd_tes_sel_panel.tsp_hou_code := rcd_member.pde_hou_code;
                  rcd_tes_sel_panel.tsp_pet_code := rcd_member.pde_pet_code;
                  rcd_tes_sel_panel.tsp_status := '*MEMBER';
                  insert into pts_tes_sel_panel using rcd_tes_sel_panel;
               end if;

            end if;

            /*-*/
            /* Exit group loop when panel member selected
            /*-*/
            if var_pan_selected = true then
               exit;
            end if;

         end loop;

         /*-*/
         /* Exit the panel loop when all group panel requirements satisfied
         /*-*/
         var_pan_exit := true;
         for idx in 1..tbl_group.count loop
            if tbl_group(idx).req_mem_count > tbl_group(idx).sel_mem_count then
               var_pan_exit := false;
            end if;
         end loop;
         if var_pan_exit = true then
            exit;
         end if;

      end loop;
      close csr_member;

      /*-*/
      /* Process the panel for potential reserves
      /*-*/
      open csr_reserve;
      loop
         fetch csr_reserve into rcd_reserve;
         if csr_reserve%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the household and pet classifications
         /*-*/
         var_hou_code := rcd_reserve.pde_hou_code;
         var_pet_code := rcd_reserve.pde_pet_code;
         tbl_class.delete;
         open csr_hou_classificaton;
         loop
            fetch csr_hou_classificaton into rcd_hou_classificaton;
            if csr_hou_classificaton%notfound then
               exit;
            end if;
            tbl_class(tbl_class.count+1).cla_code := rcd_hou_classificaton.cla_code;
            tbl_class(tbl_class.count).cla_value := rcd_hou_classificaton.cla_value;
            tbl_class(tbl_class.count).cla_text := rcd_hou_classificaton.cla_text;
         end loop;
         close csr_hou_classificaton;
         open csr_pet_classificaton;
         loop
            fetch csr_pet_classificaton into rcd_pet_classificaton;
            if csr_pet_classificaton%notfound then
               exit;
            end if;
            tbl_class(tbl_class.count+1).cla_code := rcd_pet_classificaton.cla_code;
            tbl_class(tbl_class.count).cla_value := rcd_pet_classificaton.cla_value;
            tbl_class(tbl_class.count).cla_text := rcd_pet_classificaton.cla_text;
         end loop;
         close csr_pet_classificaton;

         /*-*/
         /* Process the selection groups
         /* **note** 1. Groups are logically ORed and mutually exclusive
         /*          2. The first group to satisfy all group rules will be selected
         /*-*/
         var_pan_selected := false;
         for idx in 1..tbl_group.count loop

            /*-*/
            /* Only process groups with remaining quotas
            /*-*/
            if tbl_group(idx).req_res_count > tbl_group(idx).sel_res_count then

               /*-*/
               /* Process the selection group rules
               /* **note** 1. Rules are logically ANDed
               /*-*/
               for idy in tbl_group(idx).str_value..tbl_group(idx).end_value loop

                  /*-*/
                  /* Record the rule value classification hits
                  /* **note** 1. Lookup the related classification value
                  /*-*/
                  for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                     tbl_value(idz).sel_count := 0;
                     tbl_value(idz).fld_count := 0;
                     for idc in 1..tbl_class.count loop
                        if (tbl_class(idc).cla_code = tbl_value(idz).cla_code and
                            tbl_class(idc).cla_value = tbl_value(idz).cla_value) then
                           tbl_value(idz).fld_count := 1;
                           exit;
                        end if;
                     end loop;
                  end loop;

                  /*-*/
                  /* Evaluate the rule results
                  /* **note** 1. Compare the requested and selected counts
                  /*-*/
                  var_set_tot_count := 0;
                  var_set_sel_count := 0;
                  for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                     var_set_tot_count := var_set_tot_count + 1;
                     if tbl_value(idz).fld_count = 1 then
                        var_set_sel_count := var_set_sel_count + 1;
                     end if;
                  end loop;
                  tbl_rule(idy).sel_count := 0;
                  if tbl_rule(idy).rul_test = '*INCLUDE' then
                     if tbl_rule(idy).rul_cond = '*WHEN_ANY' then
                        if var_set_sel_count != 0 then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           if tbl_value(idz).fld_count = 1 then
                              tbl_value(idz).sel_count := 1;
                              exit;
                           end if;
                        end loop;
                     elsif tbl_rule(idy).rul_cond = '*WHEN_ALL' then
                        if var_set_sel_count = var_set_tot_count then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           tbl_value(idz).sel_count := 1;
                        end loop;
                     end if;
                  elsif tbl_rule(idy).rul_test = '*EXCLUDE' then
                     if tbl_rule(idy).rul_cond = '*WHEN_ANY' then
                        if var_set_sel_count = 0 then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                     elsif tbl_rule(idy).rul_cond = '*WHEN_ALL' then
                        if var_set_sel_count != var_set_tot_count then
                           tbl_rule(idy).sel_count := 1;
                        end if;
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           if tbl_value(idz).fld_count = 1 then
                              tbl_value(idz).sel_count := 1;
                           end if;
                        end loop;
                     end if;
                  elsif tbl_rule(idy).rul_test = '*MIX' then
                     if var_set_sel_count != 0 then
                        for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                           if tbl_value(idz).req_res_count > tbl_value(idz).sel_res_count then
                              if tbl_value(idz).fld_count = 1 then
                                 tbl_value(idz).sel_count := 1;
                                 tbl_rule(idy).sel_count := 1;
                                 exit;
                              end if;
                           end if;
                        end loop;
                     end if;
                  end if;

               end loop;

               /*-*/
               /* Evaluate the group selection
               /* **note** 1. Compare the rule total count to the rule selected count
               /*          2. All rules must be satisfied (logically ANDed)
               /*-*/
               var_set_tot_count := 0;
               var_set_sel_count := 0;
               for idy in tbl_group(idx).str_value..tbl_group(idx).end_value loop
                  var_set_tot_count := var_set_tot_count + 1;
                  if tbl_rule(idy).sel_count = 1 then
                     var_set_sel_count := var_set_sel_count + 1;
                  end if;
               end loop;
               if var_set_sel_count = var_set_tot_count then
                  var_pan_selected := true;
                  tbl_group(idx).sel_res_count := tbl_group(idx).sel_res_count + 1;
                  for idy in tbl_group(idx).str_value..tbl_group(idx).end_value loop
                     tbl_rule(idy).sel_res_count := tbl_rule(idy).sel_res_count + 1;
                     for idz in tbl_rule(idy).str_value..tbl_rule(idy).end_value loop
                        if tbl_value(idz).sel_count = 1 then
                           tbl_value(idz).sel_res_count := tbl_value(idz).sel_res_count + 1;
                        end if;
                     end loop;
                  end loop;
               end if;

               /*-*/
               /* Insert the new panel reserve when required
               /*-*/
               if var_pan_selected = true then
                  rcd_tes_sel_panel.tsp_site := rcd_test.tde_sit_code;
                  rcd_tes_sel_panel.tsp_test := rcd_test.tde_tes_code;
                  rcd_tes_sel_panel.tsp_sel_group := tbl_group(idx).sel_group;
                  rcd_tes_sel_panel.tsp_hou_code := rcd_reserve.pde_hou_code;
                  rcd_tes_sel_panel.tsp_pet_code := rcd_reserve.pde_pet_code;
                  rcd_tes_sel_panel.tsp_status := '*RESERVE';
                  insert into pts_tes_sel_panel using rcd_tes_sel_panel;
               end if;

            end if;

            /*-*/
            /* Exit group loop when panel reserve selected
            /*-*/
            if var_pan_selected = true then
               exit;
            end if;

         end loop;

         /*-*/
         /* Exit the panel loop when all group panel requirements satisfied
         /*-*/
         var_pan_exit := true;
         for idx in 1..tbl_group.count loop
            if tbl_group(idx).req_res_count > tbl_group(idx).sel_res_count then
               var_pan_exit := false;
            end if;
         end loop;
         if var_pan_exit = true then
            exit;
         end if;

      end loop;
      close csr_reserve;

      /*-*/
      /* Update the test panel member and reserve counts
      /*-*/
      var_tot_mem_count := 0;
      var_tot_res_count := 0;
      for idx in 1..tbl_group.count loop
         var_tot_mem_count := var_tot_mem_count + tbl_group(idx).sel_mem_count;
         var_tot_res_count := var_tot_res_count + tbl_group(idx).sel_res_count;
      end loop;
      update pts_tes_definition
         set tde_sel_mem_count = var_tot_mem_count,
             tde_sel_res_count = var_tot_res_count
       where tde_tes_code = rcd_test.tde_tes_code;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'PTS_TEST_FUNCTION - PANEL_SELECTION - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end panel_selection;

end pts_test_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_test_function for pts_app.pts_test_function;
grant execute on pts_app.pts_test_function to public;
