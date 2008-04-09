/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_datastore
 Owner   : lics_app
 Author  : Steve Gregan - June 2006

 DESCRIPTION
 -----------
 Local Interface Control System - Datastore

 The package implements the datastore functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created 
 2008/04   Trevor Keon    Added retrieve_group function

*******************************************************************************/

/*****************/
/* Package Types */
/*****************/
--drop type lics_datastore_table;
--drop type lics_datastore_object;

create or replace type lics_datastore_object as object
   (dsv_system varchar2(32 char),
    dsv_group varchar2(32 char),
    dsv_code varchar2(32 char),
    dsv_value varchar2(256 char));
/
create or replace type lics_datastore_table as table of lics_datastore_object;
/

/******************/
/* Package Header */
/******************/
create or replace package lics_datastore as

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_value(par_system in varchar2,
                           par_group in varchar2,
                           par_code in varchar2) return lics_datastore_table;
   function retrieve_group(par_system in varchar2,
                           par_code in varchar2,
                           par_value in varchar2) return lics_datastore_table;

end lics_datastore;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_datastore as

   /******************************************************/
   /* This procedure performs the retrieve value routine */
   /******************************************************/
   function retrieve_value(par_system in varchar2,
                           par_group in varchar2,
                           par_code in varchar2) return lics_datastore_table is

      /*-*/
      /* Local definitions
      /*-*/
      var_vir_table lics_datastore_table := lics_datastore_table();

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_das_value is 
         select *
           from lics_das_value t01
          where (par_system is null or t01.dsv_system = upper(par_system))
            and (par_group is null or t01.dsv_group = upper(par_group))
            and (par_code is null or t01.dsv_code = upper(par_code))
          order by t01.dsv_sequence asc;
      rcd_lics_das_value csr_lics_das_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the datastore values
      /*-*/
      open csr_lics_das_value;
      loop
         fetch csr_lics_das_value into rcd_lics_das_value;
         if csr_lics_das_value%notfound then
            exit;
         end if;
         var_vir_table.extend;
         var_vir_table(var_vir_table.last) := lics_datastore_object(rcd_lics_das_value.dsv_system,
                                                                    rcd_lics_das_value.dsv_group,
                                                                    rcd_lics_das_value.dsv_code,
                                                                    rcd_lics_das_value.dsv_value);
      end loop;
      close csr_lics_das_value;

      /*-*/
      /* Return the virtual table
      /*-*/
      return var_vir_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_value;

   /******************************************************/
   /* This procedure performs the retrieve code routine */
   /******************************************************/
   function retrieve_group(par_system in varchar2,
                           par_code in varchar2,
                           par_value in varchar2) return lics_datastore_table is

      /*-*/
      /* Local definitions
      /*-*/
      var_vir_table lics_datastore_table := lics_datastore_table();

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_das_value is 
         select *
           from lics_das_value t01
          where (par_system is null or t01.dsv_system = upper(par_system))
            and (par_code is null or t01.dsv_code = upper(par_code))
            and (par_value is null or t01.dsv_value = upper(par_value))
          order by t01.dsv_sequence asc;
      rcd_lics_das_value csr_lics_das_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the datastore values
      /*-*/
      open csr_lics_das_value;
      loop
         fetch csr_lics_das_value into rcd_lics_das_value;
         if csr_lics_das_value%notfound then
            exit;
         end if;
         var_vir_table.extend;
         var_vir_table(var_vir_table.last) := lics_datastore_object(rcd_lics_das_value.dsv_system,
                                                                    rcd_lics_das_value.dsv_group,
                                                                    rcd_lics_das_value.dsv_code,
                                                                    rcd_lics_das_value.dsv_value);
      end loop;
      close csr_lics_das_value;

      /*-*/
      /* Return the virtual table
      /*-*/
      return var_vir_table;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_group;
   
end lics_datastore;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_datastore for lics_app.lics_datastore;
grant execute on lics_datastore to public with grant option;