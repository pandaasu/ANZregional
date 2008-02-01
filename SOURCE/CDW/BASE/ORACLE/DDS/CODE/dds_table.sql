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

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);

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

end dds_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dds_table for dds.dds_table;
grant execute on dds_table to dw_app;