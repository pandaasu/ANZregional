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
   procedure execute;

end pts_doco;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_doco as

   /*-*/
   /* Private definitions
   /*-*/
   var_fil_handle utl_file.file_type;

   /*-*/
   /* Private declarations
   /*-*/
   procedure print_data(par_table in varchar2);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Open the print file 
      /**/
      var_fil_handle := utl_file.fopen('/tmp', 'pts_doco.txt', 'w', 32767);

      /**/
      /* Print the data 
      /**/
      utl_file.put_line(var_fil_handle, 'System' || chr(9) || 'System Tables');
      print_data('PTS_SYS_RULE');
      print_data('PTS_SYS_ENTITY');
      print_data('PTS_SYS_LINK');
      print_data('PTS_SYS_TABLE');
      print_data('PTS_SYS_FIELD');
      print_data('PTS_SYS_VALUE');
      print_data('PTS_SYS_SELECT');
      utl_file.put_line(var_fil_handle, 'Company' || chr(9) || 'Company Tables');
      print_data('PTS_COM_DEFINITION');
      utl_file.put_line(var_fil_handle, 'Geographic' || chr(9) || 'Geographic Tables');
      print_data('PTS_GEO_TYP');
      print_data('PTS_GEO_ZONE');
      utl_file.put_line(var_fil_handle, 'Interviewer' || chr(9) || 'Interviewer Tables');
      print_data('PTS_INT_DEFINITION');
      utl_file.put_line(var_fil_handle, 'Household' || chr(9) || 'Household Tables');
      print_data('PTS_HOU_DEFINITION');
      print_data('PTS_HOU_CLASSIFICATION');
      utl_file.put_line(var_fil_handle, 'Pet Type' || chr(9) || 'Pet Type Tables');
      print_data('PTS_PET_TYPE');
      print_data('PTS_PTY_SYS_FIELD');
      print_data('PTS_PTY_SYS_VALUE');
      utl_file.put_line(var_fil_handle, 'Pet' || chr(9) || 'Pet Tables');
      print_data('PTS_PET_DEFINITION');
      print_data('PTS_PET_CLASSIFICATION');
      utl_file.put_line(var_fil_handle, 'Question' || chr(9) || 'Question');
      print_data('PTS_QUE_DEFINITION');
      print_data('PTS_QUE_RESPONSE');
      utl_file.put_line(var_fil_handle, 'Sample' || chr(9) || 'Sample');
      print_data('PTS_SAM_DEFINITION');
      utl_file.put_line(var_fil_handle, 'Selection Template' || chr(9) || 'Selection Template Tables');
      print_data('PTS_STM_DEFINITION');
      print_data('PTS_STM_GROUP');
      print_data('PTS_STM_RULE');
      print_data('PTS_STM_VALUE');
      print_data('PTS_STM_PANEL');
      utl_file.put_line(var_fil_handle, 'Product Test' || chr(9) || 'Product Test Tables');
      print_data('PTS_TES_TYPE');
      print_data('PTS_TES_DEFINITION');
      print_data('PTS_TES_KEYWORD');
      print_data('PTS_TES_QUESTION');
      print_data('PTS_TES_SAMPLE');
      print_data('PTS_TES_FEEDING');
      print_data('PTS_TES_GROUP');
      print_data('PTS_TES_RULE');
      print_data('PTS_TES_VALUE');
      print_data('PTS_TES_PANEL');
      print_data('PTS_TES_STATISTIC');
      print_data('PTS_TES_CLASSIFICATION');
      print_data('PTS_TES_ALLOCATION');
      print_data('PTS_TES_RESPONSE');
      utl_file.put_line(var_fil_handle, 'Work' || chr(9) || 'Work Temporary Tables');
      print_data('PTS_WOR_SEL_GROUP');
      print_data('PTS_WOR_SEL_RULE');
      print_data('PTS_WOR_SEL_VALUE');
      print_data('PTS_WOR_TAB_FIELD');

      /**/
      /* Close the print file 
      /**/
      utl_file.fclose(var_fil_handle);

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
      /* Retrieve the tables
      /*-*/
      open csr_pts_table_01;
      loop
         fetch csr__pts_table_01 into var_data;
         if csr__pts_table_01%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the constraints related to the table
         /*-*/
         open csr__pts_constraint_01;
         loop
            fetch csr__pts_constraint_01 into var_work;
            if csr__pts_constraint_01%notfound then
               exit;
            end if;
            var_data := var_data || chr(9) || var_work; 
         end loop;
         close csr__pts_constraint_01;

         /*-*/
         /* Write the print data
         /*-*/
         utl_file.put_line(var_fil_handle, var_data);

         /*-*/
         /* Retrieve the columns related to the table
         /*-*/
         open csr__pts_column_01;
         loop
            fetch csr__pts_column_01 into var_data;
            if csr__pts_column_01%notfound then
               exit;
            end if;

            /*-*/
            /* Write the print data
            /*-*/
            utl_file.put_line(var_fil_handle, var_data); 

         end loop;
         close csr__pts_column_01;

      end loop;
      close csr__pts_table_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end print_data;

end pts_doco;
/  
