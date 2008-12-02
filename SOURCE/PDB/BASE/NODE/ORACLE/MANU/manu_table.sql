/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Object : manu_table
 Owner  : manu

 Description
 -----------
 Manufacturing - Table Utilities
  Based off the BDS bds_table package.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/11   Trevor Keon    Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package manu_table as

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);

end manu_table;
/

/****************/
/* Package Body */
/****************/
create or replace package body manu_table as

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
      execute immediate 'truncate table manu.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

end manu_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym manu_table for manu.manu_table;
grant execute on manu_table to manu_app;