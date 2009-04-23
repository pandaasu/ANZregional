/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_gen_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_gen_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - General functions

    This package contain the general functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list(par_ent_code in varchar2, par_sel_group in varchar2) return pts_sel_list_type pipelined;
   function to_number(par_number in varchar2) return number;
   function to_date(par_date in varchar2, par_format in varchar2) return date;

end pts_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_gen_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the pet_selection routine */
   /*****************************************************/
   function select_list(par_ent_code in varchar2, par_sel_group in varchar2) return pts_sel_list_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_sel_code number;
      var_query varchar2(32767);
      type typ_dynamic_cursor is ref cursor;
      var_dynamic_cursor typ_dynamic_cursor;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_entity is 
         select t01.sen_ent_sel_sql
           from pts_sys_entity t01
          where t01.sen_ent_code = upper(par_ent_code);
      rcd_entity csr_entity%rowtype;

      cursor csr_group is 
         select t01.wsg_sel_group
           from pts_wor_sel_group t01
          where (par_sel_group is null or t01.wsg_sel_group = upper(par_sel_group))
          order by t01.wsg_sel_group;
      rcd_group csr_group%rowtype;

      cursor csr_rule is 
         select t02.sfi_fld_rul_type,
                t02.sfi_fld_rul_tes_sql,
                t03.sru_rul_cond,
                t03.sru_rul_test,
                t03.sru_rul_lnot
           from pts_wor_sel_rule t01,
                pts_sys_field t02,
                pts_sys_rule t03
          where t01.wsr_tab_code = t02.sfi_tab_code
            and t01.wsr_fld_code = t02.sfi_fld_code
            and t01.wsr_rul_code = t03.sru_rul_code
            and t01.wsr_sel_group = rcd_group.wsg_sel_group
          order by t01.wsr_tab_code asc,
                   t01.wsr_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is 
         select t01.wsv_val_code,
                t01.wsv_val_text
           from pts_wor_sel_value t01
          where t01.wsv_sel_group = rcd_rule.wsr_sel_group
            and t01.wsv_tab_code = rcd_rule.wsr_tab_code
            and t01.wsv_fld_code = rcd_rule.wsr_fld_code
          order by t01.wsv_val_code;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Initialise the select query
      /*-*/
      var_query := null;
      open csr_entity;
      fetch csr_entity into rcd_entity;
      if csr_entity%found then
         var_query := rcd_entity.sen_ent_sel_sql;
      end if;
      close csr_entity;

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
            /* Start the rule
            /*-*/
            if var_rule_found = false then
               var_query := var_query||'(';
            else
               var_query := var_query||' and (';
            end if;
            var_rule_found := true;

            /*-*/
            /* Build the rule logical not test
            /*-*/
            if rcd_rule.sru_rul_lnot = '1' then
               var_query := var_query||'not(';
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
                  var_query := var_query||rcd_rule.sru_rul_cond;
               end if;
               var_value_found := true;
               if upper(rcd_rule.sfi_fld_rul_type) = '*LIST' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_code);
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*TEXT' then
                  if upper(trim(rcd_rule.sru_rul_test)) = 'LIKE' then
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>','upper(''%'||rcd_value.wsv_val_text||'%'')');
                  else
                     var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',''''||rcd_value.wsv_val_text||'''');
                  end if;
               elsif upper(rcd_rule.sfi_fld_rul_type) = '*NUMBER' then
                  var_query := var_query||replace(replace(rcd_rule.sfi_fld_rul_tes_sql,'<%RULE_TEST%>',rcd_rule.sru_rul_test),'<%RULE_VALUE%>',rcd_value.wsv_val_text);
               end if;
            end loop;
            close csr_value;

            /*-*/
            /* End the rule
            /*-*/
            if rcd_rule.sru_rul_lnot = '1' then
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
      close csr_group;

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
         fetch var_dynamic_cursor into var_sel_code;
         if var_dynamic_cursor%notfound then
            exit;
         end if;
         pipe row(pts_sel_list_object(var_sel_code));
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
         raise_application_error(-20000, 'PTS_GEN_FUNCTION - SELECT_LIST - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /**************************************************/
   /* This procedure performs the to number function */
   /**************************************************/
   function to_number(par_number in varchar2) return number is

      /*-*/
      /* Local definitions
      /*-*/
      var_return number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the number value
      /*-*/
      var_return := null;
      begin
         if substr(par_number,length(par_number),1) = '-' then
            var_return := to_number('-' || substr(par_number,1,length(par_number) - 1));
         else
            var_return := to_number(par_number);
         end if;
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end to_number;

   /************************************************/
   /* This procedure performs the to date function */
   /************************************************/
   function to_date(par_date in varchar2, par_format in varchar2) return date is

      /*-*/
      /* Local definitions
      /*-*/
      var_return date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the date value
      /*-*/
      var_return := null;
      begin
         var_return := to_date(par_date,par_format);
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end to_date;

end pts_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_gen_function for pts_app.pts_gen_function;
grant execute on pts_app.pts_gen_function to public;
