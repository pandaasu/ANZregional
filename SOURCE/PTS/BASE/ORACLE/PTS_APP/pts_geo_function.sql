/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_geo_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_app.pts_geo_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Geographic Zone Function

    This package contain the geographic zone functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function list_zones(par_tab_code in varchar2, par_fld_code in varchar2) return pts_cla_lst_type pipelined;

end pts_app.pts_geo_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_geo_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_classification(par_tab_code in varchar2, par_fld_code in varchar2) return pts_cla_lst_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = upper(par_fld_code)
            and t01.sva_val_status = '1'
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet system values
      /*-*/
      open csr_system_all;
      loop
         fetch csr_system_all into rcd_system_all;
         if csr_system_all%notfound then
            exit;
         end if;
         pipe row(pts_cla_lst_object(rcd_system_all.sva_val_code,rcd_system_all.sva_val_text));
      end loop;
      close csr_system_all;

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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - LIST_CLASSIFICATION - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_classification;

   /***********************************************************/
   /* This procedure performs the list classification routine */
   /***********************************************************/
   function list_classification(par_pet_type in number, par_tab_code in varchar2, par_fld_code in varchar2) return pts_cla_lst_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_system_field is
         select t01.*
           from pts_pty_sys_field t01
          where t01.psf_pet_type = par_pet_type
            and t01.psf_tab_code = upper(par_tab_code)
            and t01.psf_fld_code = upper(par_fld_code)
      rcd_system_field csr_system_field%rowtype;

      cursor csr_system_all is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = upper(par_fld_code)
            and t01.sva_val_status = '1'
          order by t01.sva_val_code asc;
      rcd_system_all csr_system_all%rowtype;

      cursor csr_system_select is
         select t01.sva_val_code,
                t01.sva_val_text
           from pts_sys_value t01
          where t01.sva_tab_code = upper(par_tab_code)
            and t01.sva_fld_code = upper(par_fld_code)
            and t01.sva_val_status = '1'
            and t01.sva_val_code in (select psv_val_code 
                                       from pts_pty_sys_value
                                      where t01.psv_pet_type = par_pet_type
                                        and t01.psv_tab_code = upper(par_tab_code)
                                        and t01.psv_fld_code = upper(par_fld_code))
          order by t01.sva_val_code asc;
      rcd_system_select csr_system_select%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the pet type system field
      /*-*/
      open csr_system_field;
      fetch csr_system_field into rcd_system_field;
      if csr_system_field%notfound then
         return;
      end if;
      close csr_system_field;

      /*-*/
      /* Retrieve the pet type system values
      /*-*/
      if upper(rcd_system_field.psf_val_type) = '*ALL' then
         open csr_system_all;
         loop
            fetch csr_system_all into rcd_system_all;
            if csr_system_all%notfound then
               exit;
            end if;
            pipe row(pts_cla_lst_object(rcd_system_all.sva_val_code,rcd_system_all.sva_val_text));
         end loop;
         close csr_system_all;
      elsif upper(rcd_system_field.psf_val_type) = '*SELECT' then
         open csr_system_select;
         loop
            fetch csr_system_select into rcd_system_select;
            if csr_system_select%notfound then
               exit;
            end if;
            pipe row(pts_cla_lst_object(rcd_system_select.sva_val_code,rcd_system_select.sva_val_text));
         end loop;
         close csr_system_select;
      else
         return;
      end if;

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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - LIST_CLASSIFICATION - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end list_classification;

   /********************************************************/
   /* This procedure performs the report execution routine */
   /********************************************************/
   function retrieve_pet_list(par_sit_code in varchar2) return pts_panel_list_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_sit_code varchar2(32);
      var_output varchar2(4000);
      var_query varchar2(32767);

      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;
 
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_group is 
         select t01.*
           from pts_wor_sel_group t01
          order by t01.wsg_sel_group;
      rcd_group csr_group%rowtype;

      cursor csr_rule is 
         select t01.*
           from pts_wor_sel_rule t01
          where t01.wsr_sel_group = rcd_group.wsg_sel_group
          order by t01.wsr_dsp_seqn;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is 
         select t01.*
           from pts_wor_sel_value t01
          where t01.wsv_sel_group = rcd_rule.wsr_sel_group
            and t01.wsv_cla_code = rcd_rule.wsv_cla_value
          order by t01.wsv_dsp_seqn;
      rcd_value csr_value%rowtype;

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
      if par_sit_code is null then
         raise_application_error(-20000, 'Site code must be specified');
      end if;
      var_sit_code := upper(par_sit_code);

      /*-*/
      /* Initialise the list query
      /*-*/
      var_query := 'select t01.pde_pet_code from pts_pet_definition t01, pts_hou_definition t02 where t01.pde_hou_code = t02.hde_hou_code(+)';

      /*-*/
      /* Process the selection groups
      /*-*/
      var_group_found := false;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Start the group
         /*-*/
         if var_group_found = false then
            var_query := var_query||' and ((';
         else
            var_query := var_query||' or (';
         end if;
         var_group_found := true;

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_rule_found := false;
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Validate the rule
            /*-*/
            if (upper(rcd_rule.wsr_rul_entity) != '*PET_HDR' and
                upper(rcd_rule.wsr_rul_entity) != '*PET_CLASS' and
                upper(rcd_rule.wsr_rul_entity) != '*HHOLD_HDR' and
                upper(rcd_rule.wsr_rul_entity) != '*HHOLD_CLASS') then
               raise_application_error(-20000, 'Rule entity ('||upper(rcd_rule.wsr_rul_entity)||') not recognised');
            end if;
            if (upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_EQUAL' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_NOT_EQUAL' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_LIKE' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_NOT_LIKE' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_LT' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_GT' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_LE' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_GE' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_EQUAL_ALL' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_NOT_EQUAL_ALL' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_LIKE_ALL' and
                upper(rcd_rule.wsr_rul_test) != '*SELECT_WHEN_NOT_LIKE_ALL') then
               raise_application_error(-20000, 'Rule test ('||upper(rcd_rule.wsr_rul_test)||') not recognised');
            end if;
            if (upper(rcd_rule.wsr_val_type) != '*SINGLE_LIST' and
                upper(rcd_rule.wsr_val_type) != '*MULTIPLE_LIST' and
                upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' and
                upper(rcd_rule.wsr_val_type) != '*SINGLE_NUMBER' and
                upper(rcd_rule.wsr_val_type) != '*SINGLE_PERCENT') then
               raise_application_error(-20000, 'Rule value type ('||upper(rcd_rule.wsr_val_type)||') not recognised');
            end if;
            if (upper(rcd_rule.wsr_rul_test) = '*SELECT_WHEN_LIKE' or
                upper(rcd_rule.wsr_rul_test) = '*SELECT_WHEN_NOT_LIKE' or
                upper(rcd_rule.wsr_rul_test) = '*SELECT_WHEN_LIKE_ALL' or
                upper(rcd_rule.wsr_rul_test) = '*SELECT_WHEN_NOT_LIKE_ALL') then
               if rcd_rule.wsr_val_type != '*SINGLE_TEXT' then
                  raise_application_error(-20000, 'Rule value type ('||upper(rcd_rule.wsr_val_type)||') must be *TEXT for *LIKE tests');
               end if;
            end if;

            /*-*/
            /* Start the rule
            /*-*/
            if var_rule_found = false then
               var_query := var_query||'(';
            else
               var_query := var_query||' and (';
            end if;
            var_rule_found := true;

            /*-*/
            /* Build the rule not test
            /*-*/
            if (upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_EQUAL' or
                upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_EQUAL_ALL' or
                upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_LIKE' or
                upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_LIKE_ALL') then
               var_query := var_query||'not(';
            end if;

            /*-*/
            /* Build the rule start end end
            /*-*/
            if upper(rcd_rule.wsr_rul_entity) = '*PET_HDR' then
               var_rul_str := 't01.'||rcd_rule.wsr_rul_field;
               var_rul_end := '';
            elsif upper(rcd_rule.wsr_rul_entity) = '*PET_CLASS' then
               var_rul_str := 'exists (select 1 from pts_pet_classification where pcl_pet_code = t01.pde_pet_code and pcl_sit_code = '''||var_sit_code||''' and pcl_cla_code = '''||upper(rcd_rule.wsr_rul_field)||''' and pcl_cla_value';
               var_rul_end := ')';
            elsif upper(rcd_rule.wsr_rul_entity) = '*HHOLD_HDR' then
               var_rul_str := 't02.'||rcd_rule.wsr_rul_field;
               var_rul_end := '';
            elsif upper(rcd_rule.wsr_rul_entity) = '*HHOLD_CLASS' then
               var_rul_str := 'exists (select 1 from pts_hou_classification where hcl_hou_code = t01.pde_hou_code and hcl_sit_code = '''||var_sit_code||''' and hcl_cla_code = '''||upper(rcd_rule.wsr_rul_field)||''' and hcl_cla_value';
               var_rul_end := ')';
            end if;

            /*-*/
            /* Build the value start end end
            /*-*/
            if upper( rcd_rule.tsr_rul_test) = '*SELECT_WHEN_EQUAL' then
               var_val_cond := ' or ';
               var_val_str := '=';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_EQUAL' then
               var_val_cond := ' or ';
               var_val_str := '=';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_LIKE' then
               var_val_cond := ' or ';
               var_val_str := ' like ''%';
               var_val_end := '%''';
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_LIKE' then
               var_val_cond := ' or ';
               var_val_str := ' like ''%';
               var_val_end := '%''';
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_LT' then
               var_val_cond := ' or ';
               var_val_str := '<';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_GT' then
               var_val_cond := ' or ';
               var_val_str := '>';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_LE' then
               var_val_cond := ' or ';
               var_val_str := '<=';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_GE' then
               var_val_cond := ' or ';
               var_val_str := '>=';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_EQUAL_ALL' then
               var_val_cond := ' and ';
               var_val_str := '=';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_EQUAL_ALL' then
               var_val_cond := ' and ';
               var_val_str := '=';
               var_val_end := '';
               if upper(rcd_rule.wsr_val_type) != '*SINGLE_TEXT' then
                  var_val_str := '=''';
                  var_val_end := '''';
               end if;
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_LIKE_ALL' then
               var_val_cond := ' and ';
               var_val_str := ' like ''%';
               var_val_end := '%''';
            elsif upper(rcd_rule.tsr_rul_test) = '*SELECT_WHEN_NOT_LIKE_ALL' then
               var_val_cond := ' and ';
               var_val_str := ' like ''%';
               var_val_end := '%''';
            end if;
             
            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_value_found := false;
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               if var_value_found = true then
                  var_query := var_query||var_val_cond;
               end if;
               var_value_found := true;
               var_query := var_query||var_rul_str||var_val_str||rcd_value.wsv_fld_value||var_val_end||var_rul_end;
            end loop;
            close csr_value;

            /*-*/
            /* End the rule
            /*-*/
            if (rcd_rule.tsr_rul_cond = '*SELECT_WHEN_NOT_EQUAL' or
                rcd_rule.tsr_rul_cond = '*SELECT_WHEN_NOT_EQUAL_ALL' or
                rcd_rule.tsr_rul_cond = '*SELECT_WHEN_NOT_LIKE' or
                rcd_rule.tsr_rul_cond = '*SELECT_WHEN_NOT_LIKE_ALL') then
               var_query := var_query||')';
            end if;
            var_query := var_query||')';

         end loop;
         close csr_rule;

         /*-*/
         /* End the group
         /*-*/
         var_query := var_query||')';

      end loop;
      close csr_group

      /*-*/
      /* End the list query when required
      /*-*/
      if var_group_found = true then
         var_query := var_query||')';
      end if;

      /*-*/
      /* Open the query and pipe the results
      /*-*/
      open var_dynamic_cursor for var_query;
      loop
         fetch var_dynamic_cursor into var_pan_code;
         if var_dynamic_cursor%notfound then
            exit;
         end if;
         pipe row(pts_panel_list_object(var_pan_code));
      end loop;
      close var_dynamic_cursor;

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
         raise_application_error(-20000, 'PTS_PET_FUNCTION - RETRIEVE_PET_LIST - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_pet_list;

end pts_app.pts_geo_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_geo_function for pts_app.pts_geo_function;
grant execute on pts_geo_function to public;
