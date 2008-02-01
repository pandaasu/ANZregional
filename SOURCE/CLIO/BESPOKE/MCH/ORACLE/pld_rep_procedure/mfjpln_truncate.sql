/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_truncate                                    */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/
/**DESCRIPTION**
 Table Truncate
 This package is used to truncate the data in a table owned by pld_rep.

 **PARAMETERS**
 par_table = Table to truncate (mandatory)

**/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_truncate as

   /*-*/
   /* Public declarations */
   /*-*/
   procedure truncate_table(par_table in varchar2);

end mfjpln_truncate;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_truncate as

   /******************************************************/
   /* This procedure performs the truncate table routine */
   /******************************************************/
   procedure truncate_table(par_table in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Truncates the table data */
      /*-*/
      execute immediate 'truncate table pld_rep.' || par_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate_table;

end mfjpln_truncate;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace  public synonym mfjpln_truncate for pld_rep.mfjpln_truncate;
grant execute on mfjpln_truncate to public;