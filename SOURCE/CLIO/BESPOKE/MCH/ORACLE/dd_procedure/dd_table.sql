/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Object : dd_table
 Owner  : dd

 Description
 -----------
 Dimensional Data Store - Table Utilities

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/10   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package dd_table as

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);

end dd_table;
/

/****************/
/* Package Body */
/****************/
create or replace package body dd_table as

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
      execute immediate 'truncate table dd.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

end dd_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dd_table for dd.dd_table;
grant execute on dd_table to dw_app;