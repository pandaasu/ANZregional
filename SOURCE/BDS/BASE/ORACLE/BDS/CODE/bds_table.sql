/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Object : bds_table
 Owner  : bds

 Description
 -----------
 Business Data Store - Table Utilities

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package bds_table as

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);

end bds_table;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_table as

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
      execute immediate 'truncate table bds.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

end bds_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_table for bds.bds_table;
grant execute on bds_table to bds_app;