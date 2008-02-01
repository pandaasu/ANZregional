/******************/
/* Package Header */
/******************/
create or replace package ods_table as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Object : ods_table
    Owner  : ods

    Description
    -----------
    Operational Data Store - Table Utilities

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);

end ods_table;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_table as

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
      execute immediate 'truncate table ods.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

end ods_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create public synonym ods_table for ods.ods_table;
grant execute on ods_table to ods_app;
grant execute on ods_table to dds_app;