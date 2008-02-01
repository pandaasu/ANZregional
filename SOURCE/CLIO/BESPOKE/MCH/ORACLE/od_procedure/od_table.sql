/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Object : od_table
 Owner  : od

 Description
 -----------
 Operational Data Store - Table Utilities

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/10   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package od_table as

   /*-*/
   /* Public declarations
   /*-*/
   procedure truncate(par_table in varchar2);

end od_table;
/

/****************/
/* Package Body */
/****************/
create or replace package body od_table as

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
      execute immediate 'truncate table od.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

end od_table;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create public synonym od_table for od.od_table;
grant execute on od_table to dw_app;