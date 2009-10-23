/******************/
/* Package Header */
/******************/
create or replace package dds_table as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Object : dds_table
    Owner  : dds

    Description
    -----------
    Dimensional Data Store - Table Utilities

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created
    2009/10   Steve Gregan   Added analyse table and index routines

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);
   procedure analyze_table(par_table in varchar2);

end dds_table;
/

/****************/
/* Package Body */
/****************/
create or replace package body dds_table as

   /************************************************/
   /* This procedure performs the truncate routine */
   /************************************************/
   procedure truncate(par_table in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Truncates the table data
      /*-*/
      execute immediate 'truncate table dds.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

   /*****************************************************/
   /* This procedure performs the analyze table routine */
   /*****************************************************/
   procedure analyze_table(par_table in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Analyse table statistics
      /*-*/
      dbms_stats.gather_table_stats(tabname => par_table,
                                    ownname => 'DDS',
                                    estimate_percent => dbms_stats.auto_sample_size,
                                    method_opt => 'FOR ALL COLUMNS SIZE AUTO',
                                    cascade => true);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end analyze_table;

end dds_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dds_table for dds.dds_table;
grant execute on dds_table to dw_app;