/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : pts_doco
 Owner   : pts_app
 Author  : Steve Gregan

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package pts_doco as

   /*-*/
   /* Public declarations
   /*-*/
   function execute return pts_xls_type pipelined;

end pts_doco;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_doco as

   /*-*/
   /* Private declarations
   /*-*/
   procedure print_data(par_table in varchar2);
   type typ_data is table of varchar2(4000) index by binary_integer;
   tbl_data typ_data;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function execute return pts_xls_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Print the data 
      /**/
      pipe row('System' || chr(9) || 'System Tables');
      print_data('PTS_SYS_RULE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_SYS_ENTITY');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_SYS_LINK');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_SYS_TABLE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_SYS_FIELD');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_SYS_VALUE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_SYS_SELECT');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Company' || chr(9) || 'Company Tables');
      print_data('PTS_COM_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Geographic' || chr(9) || 'Geographic Tables');
      print_data('PTS_GEO_TYPE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_GEO_ZONE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Interviewer' || chr(9) || 'Interviewer Tables');
      print_data('PTS_INT_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Household' || chr(9) || 'Household Tables');
      print_data('PTS_HOU_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_HOU_CLASSIFICATION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Pet Type' || chr(9) || 'Pet Type Tables');
      print_data('PTS_PET_TYPE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_PTY_SYS_FIELD');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_PTY_SYS_VALUE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Pet' || chr(9) || 'Pet Tables');
      print_data('PTS_PET_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_PET_CLASSIFICATION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Question' || chr(9) || 'Question');
      print_data('PTS_QUE_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_QUE_RESPONSE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Sample' || chr(9) || 'Sample');
      print_data('PTS_SAM_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Selection Template' || chr(9) || 'Selection Template Tables');
      print_data('PTS_STM_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_STM_GROUP');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_STM_RULE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_STM_VALUE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_STM_PANEL');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Product Test' || chr(9) || 'Product Test Tables');
      print_data('PTS_TES_TYPE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_DEFINITION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_KEYWORD');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_QUESTION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_SAMPLE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_FEEDING');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_GROUP');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_RULE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_VALUE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_PANEL');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_STATISTIC');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_CLASSIFICATION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_ALLOCATION');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_TES_RESPONSE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Work' || chr(9) || 'Work Temporary Tables');
      print_data('PTS_WOR_SEL_GROUP');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_WOR_SEL_RULE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_WOR_SEL_VALUE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTS_WOR_TAB_FIELD');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**************************************************/
   /* This procedure performs the print data routine */
   /**************************************************/
    procedure print_data(par_table in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_data varchar2(4000);
      var_work varchar2(1000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pts_table_01 is 
         select chr(9) || upper(t01.table_name) || chr(9) || t02.comments || chr(9)
           from all_tables t01, all_tab_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.table_name = par_table;

      cursor csr_pts_constraint_01 is 
         select lower(t01.column_name)
           from all_cons_columns t01
          where t01.table_name = par_table
            and t01.constraint_name = par_table || '_PK'
       order by t01.position asc;

      cursor csr_pts_column_01 is 
         select case when lower(t01.data_type) = 'varchar2' then chr(9) || lower(t01.column_name) || chr(9) || t02.comments || chr(9) || lower(t01.data_type) || '(' || to_char(t01.data_length) || ')' else chr(9) || lower(t01.column_name) || chr(9) || t02.comments || chr(9) || lower(t01.data_type) end
           from all_tab_columns t01, all_col_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.column_name = t02.column_name(+)
            and t01.table_name = par_table
       order by t01.column_id asc;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the data array
      /*-*/
      tbl_data.delete;

      /*-*/
      /* Retrieve the tables
      /*-*/
      open csr_pts_table_01;
      loop
         fetch csr_pts_table_01 into var_data;
         if csr_pts_table_01%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the constraints related to the table
         /*-*/
         open csr_pts_constraint_01;
         loop
            fetch csr_pts_constraint_01 into var_work;
            if csr_pts_constraint_01%notfound then
               exit;
            end if;
            var_data := var_data || chr(9) || var_work; 
         end loop;
         close csr_pts_constraint_01;

         /*-*/
         /* Write the print data
         /*-*/
         tbl_data(tbl_data.count+1) := var_data;

         /*-*/
         /* Retrieve the columns related to the table
         /*-*/
         open csr_pts_column_01;
         loop
            fetch csr_pts_column_01 into var_data;
            if csr_pts_column_01%notfound then
               exit;
            end if;

            /*-*/
            /* Write the print data
            /*-*/
            tbl_data(tbl_data.count+1) := var_data;

         end loop;
         close csr_pts_column_01;

      end loop;
      close csr_pts_table_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end print_data;

end pts_doco;
/  
