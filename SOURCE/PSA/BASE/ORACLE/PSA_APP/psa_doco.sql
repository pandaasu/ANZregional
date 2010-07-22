/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : psa_doco
 Owner   : psa_app
 Author  : Steve Gregan

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package psa_doco as

   /*-*/
   /* Public declarations
   /*-*/
   function execute return psa_xls_type pipelined;

end psa_doco;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_doco as

   /*-*/
   /* Private declarations
   /*-*/
   procedure print_data(par_table in varchar2);
   type typ_data is table of varchar2(4000) index by binary_integer;
   tbl_data typ_data;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   function execute return psa_xls_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Print the data 
      /**/
      pipe row('System' || chr(9) || 'System Tables');
      print_data('PSA_SYSTEM');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PRD_TYPE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Shift' || chr(9) || 'Shift Tables');
      print_data('PSA_SHF_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Shift Model' || chr(9) || 'Shift Model Tables');
      print_data('PSA_SMO_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_SMO_SHIFT');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Resource' || chr(9) || 'Resource Tables');
      print_data('PSA_RES_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Crew Model' || chr(9) || 'Crew Model Tables');
      print_data('PSA_CMO_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_CMO_RESOURCE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Run Rate' || chr(9) || 'Run Rate Tables');
      print_data('PSA_RRA_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Filler' || chr(9) || 'Filler Tables');
      print_data('PSA_FIL_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Line' || chr(9) || 'Line Tables');
      print_data('PSA_LIN_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_LIN_CONFIG');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_LIN_RATE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_LIN_FILLER');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_LIN_LINK');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_SAP_LINE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Material' || chr(9) || 'Material Tables');
      print_data('PSA_MAT_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_MAT_PROD');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_MAT_LINE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_MAT_COMP');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Schedule Activity' || chr(9) || 'Schedule Activity Tables');
      print_data('PSA_SAC_DEFN');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Requirement' || chr(9) || 'Requirement Tables');
      print_data('PSA_REQ_HEADER');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTA_REQ_DETAIL');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Stocktake' || chr(9) || 'Stocktake Tables');
      print_data('PSA_STK_HEADER');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PTA_STK_DETAIL');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      pipe row('Production Schedule' || chr(9) || 'Production Schedule Tables');
      print_data('PSA_PSC_HEDR');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_WEEK');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_DATE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_PROD');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_LINE');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_SHFT');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_RESO');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_ACTV');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_INVT');
      for idx in 1..tbl_data.count loop
         pipe row(tbl_data(idx));
      end loop;
      print_data('PSA_PSC_ENTY');
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
      cursor csr_psa_table_01 is 
         select chr(9) || upper(t01.table_name) || chr(9) || t02.comments || chr(9)
           from all_tables t01, all_tab_comments t02
          where t01.table_name = t02.table_name(+)
            and t01.table_name = par_table;

      cursor csr_psa_constraint_01 is 
         select lower(t01.column_name)
           from all_cons_columns t01
          where t01.table_name = par_table
            and t01.constraint_name = par_table || '_PK'
       order by t01.position asc;

      cursor csr_psa_column_01 is 
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
      open csr_psa_table_01;
      loop
         fetch csr_psa_table_01 into var_data;
         if csr_psa_table_01%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the constraints related to the table
         /*-*/
         open csr_psa_constraint_01;
         loop
            fetch csr_psa_constraint_01 into var_work;
            if csr_psa_constraint_01%notfound then
               exit;
            end if;
            var_data := var_data || chr(9) || var_work; 
         end loop;
         close csr_psa_constraint_01;

         /*-*/
         /* Write the print data
         /*-*/
         tbl_data(tbl_data.count+1) := var_data;

         /*-*/
         /* Retrieve the columns related to the table
         /*-*/
         open csr_psa_column_01;
         loop
            fetch csr_psa_column_01 into var_data;
            if csr_psa_column_01%notfound then
               exit;
            end if;

            /*-*/
            /* Write the print data
            /*-*/
            tbl_data(tbl_data.count+1) := var_data;

         end loop;
         close csr_psa_column_01;

      end loop;
      close csr_psa_table_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end print_data;

end psa_doco;
/  
