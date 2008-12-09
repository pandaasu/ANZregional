/******************/
/* Package Header */
/******************/
create or replace package pricelist_execution as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pricelist_execution
    Owner   : pr_app

    Description
    -----------
    Price List Generator - Reporting

    This package contain the procedures for the price list generator execution.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute_report(par_report_id in number, par_report_date in varchar2) return pricelist_data pipelined;

end pricelist_execution;
/

/****************/
/* Package Body */
/****************/
create or replace package body pricelist_execution as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************/
   /* This procedure performs the report execution routine */
   /********************************************************/
   function execute_report(par_report_id in number, par_report_date in varchar2) return pricelist_data pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_report_id number;
      var_report_date date;
      var_report_item_type report_item.report_item_type%type;
      var_output varchar2(4000);
      var_query varchar2(32767);
      var_select_found boolean;
      var_order_found boolean;
      var_break_count integer;
      var_data_count integer;
      var_break_level integer;
      var_cursor integer;
      var_status integer;
      var_column_count integer;
      var_row_count integer;
      var_rcd_table dbms_sql.desc_tab;
      type rcd_data is record(save_value varchar2(4000),
                              this_value varchar2(4000),
                              item_type varchar2(1),
                              data_frmt varchar2(4000),
                              name_frmt varchar2(4000),
                              name_ovrd varchar2(200));
      type typ_data is table of rcd_data index by binary_integer;
      tbl_data typ_data;
 
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report is 
         select t01.*
           from report t01
          where t01.report_id = var_report_id;
      rcd_report csr_report%rowtype;

      cursor csr_price_mdl is 
         select t01.sql_from_tables,
                t01.sql_where_joins
           from price_mdl t01
          where t01.price_mdl_id = rcd_report.price_mdl_id;
      rcd_price_mdl csr_price_mdl%rowtype;

      cursor csr_report_item is 
         select t01.report_item_id,
                t01.report_item_type,
                nvl(t01.name_ovrd,t02.price_item_name) as name_ovrd,
                t01.name_frmt,
                t01.data_frmt,
                t02.sql_select
           from report_item t01,
                price_item t02
          where t01.report_id = var_report_id
            and t01.price_item_id = t02.price_item_id
            and t01.report_item_type = var_report_item_type
          order by t01.sort_order asc;
      rcd_report_item csr_report_item%rowtype;

      cursor csr_report_term is 
         select t01.value,
                t01.data_frmt
           from report_term t01
          where t01.report_id = var_report_id
          order by t01.sort_order asc;
      rcd_report_term csr_report_term%rowtype;

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
      if par_report_id is null then
         raise_application_error(-20000, 'Report identifier must be specified');
      end if;
      var_report_id := par_report_id;
      if par_report_date is null then
         var_report_date := trunc(sysdate);
      else
         begin
            var_report_date := to_date(par_report_date,'YYYYMMDD');
         exception
            when others then
               raise_application_error(-20000, 'Unable to convert (' || var_report_date || ') to a date using format YYYYMMDD');
         end;
      end if;

      /*-*/
      /* Retrieve the report
      /*-*/
      open csr_report;
      fetch csr_report into rcd_report;
      if csr_report%notfound then
         raise_application_error(-20000, 'Report (' || to_char(var_report_id) || ') does not exist');
      end if;
      close csr_report;

      /*-*/
      /* Retrieve the price model
      /*-*/
      open csr_price_mdl;
      fetch csr_price_mdl into rcd_price_mdl;
      if csr_price_mdl%notfound then
         raise_application_error(-20000, 'Report (' || to_char(var_report_id) || ') pricing model not found');
      end if;
      close csr_price_mdl;

      /*-*/
      /* Initialise the report
      /*-*/
      tbl_data.delete;
      var_select_found := false;
      var_order_found := false;
      var_break_count := 0;
      var_data_count := 0;
      var_query := 'select';

      /*-*/
      /* Retrieve the report items (BREAK)
      /*-*/
      var_report_item_type := 'B';
      open csr_report_item;
      loop
         fetch csr_report_item into rcd_report_item;
         if csr_report_item%notfound then
            exit;
         end if;
         if var_select_found = true then
            var_query := var_query || ',';
         end if;
         var_query := var_query || ' ' || trim(rcd_report_item.sql_select) || ' as b' || to_char(var_break_count+1,'fm00');
         var_select_found := true;
         var_break_count := var_break_count + 1;
         tbl_data(tbl_data.count+1).save_value := '*NULL*';
         tbl_data(tbl_data.count).this_value := '*NULL*';
         tbl_data(tbl_data.count).item_type := rcd_report_item.report_item_type;
         tbl_data(tbl_data.count).data_frmt := rcd_report_item.data_frmt;
         tbl_data(tbl_data.count).name_frmt := rcd_report_item.name_frmt;
         tbl_data(tbl_data.count).name_ovrd := rcd_report_item.name_ovrd;
      end loop;
      close csr_report_item;

      /*-*/
      /* Retrieve the report items (DATA)
      /*-*/
      var_report_item_type := 'D';
      open csr_report_item;
      loop
         fetch csr_report_item into rcd_report_item;
         if csr_report_item%notfound then
            exit;
         end if;
         if var_select_found = true then
            var_query := var_query || ',';
         end if;
         var_query := var_query || ' ' || trim(rcd_report_item.sql_select) || ' as d' || to_char(var_data_count+1,'fm00');
         var_select_found := true;
         var_data_count := var_data_count + 1;
         tbl_data(tbl_data.count+1).save_value := '*NULL*';
         tbl_data(tbl_data.count).this_value := '*NULL*';
         tbl_data(tbl_data.count).item_type := rcd_report_item.report_item_type;
         tbl_data(tbl_data.count).data_frmt := rcd_report_item.data_frmt;
         tbl_data(tbl_data.count).name_frmt := rcd_report_item.name_frmt;
         tbl_data(tbl_data.count).name_ovrd := rcd_report_item.name_ovrd;
      end loop;
      close csr_report_item;

      /*-*/
      /* Validate the report structure
      /*-*/
      if var_data_count = 0 then
         raise_application_error(-20000, 'Report (' || to_char(var_report_id) || ') must have at least one report item to bring back for display');
      end if;

      /*-*/
      /* Set the table information
      /*-*/
      var_query := var_query || ' from report t1a, report_matl t1b, price_sales_org t1c, price_distbn_chnl t1d, matl t1, matl_by_sales_area t2';
      if not(rcd_price_mdl.sql_from_tables is null) and not(rcd_price_mdl.sql_where_joins is null) then
         var_query := var_query || ', ' || trim(rcd_price_mdl.sql_from_tables);
      end if;
      var_query := var_query || ' where t1a.report_id = ' || to_char(var_report_id);
      var_query := var_query || ' and t1a.report_id = t1b.report_id';
      var_query := var_query || ' and t1b.matl_code = t1.matl_code';
      var_query := var_query || ' and t1b.matl_code = t2.matl_code';
      var_query := var_query || ' and t1a.price_sales_org_id = t1c.price_sales_org_id';
      var_query := var_query || ' and t1c.price_sales_org_code = t2.sales_org';
      var_query := var_query || ' and t1a.price_distbn_chnl_id = t1d.price_distbn_chnl_id';
      var_query := var_query || ' and t1d.price_distbn_chnl_code = t2.dstrbtn_chnl';
      if not(rcd_price_mdl.sql_from_tables is null) and not(rcd_price_mdl.sql_where_joins is null) then
         var_query := var_query || trim(rcd_price_mdl.sql_where_joins);
      end if;

      /*-*/
      /* Retrieve the order by clause (BREAK)
      /*-*/
      var_report_item_type := 'B';
      open csr_report_item;
      loop
         fetch csr_report_item into rcd_report_item;
         if csr_report_item%notfound then
            exit;
         end if;
         if var_order_found = false then
            var_query := var_query || ' order by';
         else
            var_query := var_query || ',';
         end if;
         var_query := var_query || ' ' || rcd_report_item.sql_select;
         var_order_found := true;
      end loop;
      close csr_report_item;

      /*-*/
      /* Retrieve the order by clause (ORDER)
      /*-*/
      var_report_item_type := 'O';
      open csr_report_item;
      loop
         fetch csr_report_item into rcd_report_item;
         if csr_report_item%notfound then
            exit;
         end if;
         if var_order_found = false then
            var_query := var_query || ' order by';
         else
            var_query := var_query || ',';
         end if;
         var_query := var_query || ' ' || rcd_report_item.sql_select;
         var_order_found := true;
      end loop;
      close csr_report_item;

      /*-*/
      /* Initialise the price list functions used by the report query
      /*-*/
      pricelist_functions.set_pricelist_date(var_report_date);

      /*-*/
      /* Parse and execute the report query
      /*-*/
      var_cursor := dbms_sql.open_cursor;
      begin
         dbms_sql.parse(var_cursor, var_query, dbms_sql.native);
         dbms_sql.describe_columns(var_cursor, var_column_count, var_rcd_table);
         for idx in 1..var_column_count loop
            dbms_sql.define_column(var_cursor,idx,tbl_data(idx).this_value,4000);
         end loop;
         var_status := dbms_sql.execute(var_cursor);
      exception
         when others then
            raise_application_error(-20000, 'Report (' || to_char(var_report_id) || ') query error - ' || substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=0 cellpadding="0" cellspacing="0">');
      if rcd_report.report_name_frmt is null then
         pipe row('<tr><td colspan='||var_data_count||'>'||rcd_report.report_name||'</td></tr>');
      else
         pipe row('<tr><td colspan='||var_data_count||' style="'||rcd_report.report_name_frmt||'>'||rcd_report.report_name||'"</td></tr>');
      end if;
      var_output := '<tr>';
      for idx in var_break_count+1..var_column_count loop
         if tbl_data(idx).item_type = 'D' then
            if tbl_data(idx).name_frmt is null then
               var_output := var_output || '<td>'||tbl_data(idx).name_ovrd||'</td>';
            else
               var_output := var_output || '<td style="'||tbl_data(idx).name_frmt||'">'||tbl_data(idx).name_ovrd||'</td>';
            end if;
         end if;
      end loop;
      var_output := var_output || '</tr>';
      pipe row(var_output);

      /*-*/
      /* Retrieve the report data
      /*-*/
      var_row_count := 0;
      loop
         if dbms_sql.fetch_rows(var_cursor) = 0 then
            exit;
         end if;

         /*-*/
         /* Load the row data array
         /*-*/
         var_row_count := var_row_count + 1;
         for idx in 1..var_column_count loop
            dbms_sql.column_value(var_cursor,idx,tbl_data(idx).this_value);
         end loop;

         /*-*/
         /* Check for report break changes and output when required
         /*-*/
         if var_break_count != 0 then
            var_break_level := 0;
            for idx in reverse 1..var_break_count loop
               if tbl_data(idx).item_type = 'B' then
                  if tbl_data(idx).this_value != tbl_data(idx).save_value then
                     var_break_level := idx;
                  end if;
               end if;
            end loop;
            if var_break_level != 0 then
               for idx in var_break_level..var_break_count loop
                  if tbl_data(idx).item_type = 'B' then
                     tbl_data(idx).save_value := tbl_data(idx).this_value;
                     if tbl_data(idx).data_frmt is null then
                        var_output := '<tr><td colspan='||to_char(var_data_count)||'>'||tbl_data(idx).this_value||'</td></tr>';
                     else
                        var_output := '<tr><td colspan='||to_char(var_data_count)||' style="'||tbl_data(idx).data_frmt||'">'||tbl_data(idx).this_value||'</td></tr>';
                     end if;
                     pipe row(var_output);
                  end if;
               end loop;
            end if;
         end if;

         /*-*/
         /* Output the report data
         /*-*/
         var_output := '<tr>';
         for idx in var_break_count+1..var_column_count loop
            if tbl_data(idx).item_type = 'D' then
               if tbl_data(idx).data_frmt is null then
                  var_output := var_output||'<td>'||tbl_data(idx).this_value||'</td>';
               else
                  var_output := var_output||'<td style="'||tbl_data(idx).data_frmt||'">'||tbl_data(idx).this_value||'</td>';
               end if;
            end if;
         end loop;
         var_output := var_output||'</tr>';
         pipe row(var_output);

      end loop;
      dbms_sql.close_cursor(var_cursor);

      /*-*/
      /* Empty report
      /*-*/
      if var_row_count = 0 then
         pipe row('<tr><td colspan='||var_data_count||'>NO DETAILS</td></tr>');
      end if;

      /*-*/
      /* Retrieve the terms and conditions
      /*-*/
      open csr_report_term;
      loop
         fetch csr_report_term into rcd_report_term;
         if csr_report_term%notfound then
            exit;
         end if;
         if rcd_report_term.data_frmt is null then
            var_output := var_output||'<tr><td colspan='||to_char(var_data_count)||'>'||rcd_report_term.value||'</td></tr>';
         else
            var_output := var_output||'<tr><td colspan='||to_char(var_data_count)||' style="'||rcd_report_term.data_frmt||'">'||rcd_report_term.value||'</td></tr>';
         end if;
      end loop;
      close csr_report_term;

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
         raise_application_error(-20000, 'PRICELIST_REPORTING - EXECUTE_REPORT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_report;

end pricelist_execution;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pricelist_execution for dw_app.pricelist_execution;
grant execute on pricelist_execution to public;
