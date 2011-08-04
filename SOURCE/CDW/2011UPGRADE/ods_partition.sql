/******************/
/* Package Header */
/******************/
create or replace package ods.ods_partition as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Object : ods_partition
    Owner  : ods

    Description
    -----------
    Operational Data Store - ODS Partition
 
    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure check_create_list(par_table varchar2, par_partition varchar2, par_value varchar2);
   procedure truncate_list(par_table varchar2, par_partition varchar2);
   procedure drop_list(par_table varchar2, par_partition varchar2);

end ods_partition;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods.ods_partition as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*************************************************************************/
   /* This procedure performs the check/create table list partition routine */
   /*************************************************************************/
   procedure check_create_list(par_table varchar2, par_partition varchar2, par_value varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_table varchar2(60);
      var_partition varchar2(60);
      var_sql varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_partition is
         select partition_name
           from user_tab_partitions
          where table_name = var_table
            and partition_name = var_partition;
      rcd_partition csr_partition%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the local variables
      /*-*/
      var_table := upper(par_table);
      var_partition := upper(par_partition);

      /*-*/
      /* Create the new partition when not found
      /*-*/
      open csr_partition;
      fetch csr_partition into rcd_partition;
      if csr_partition%notfound then
         var_sql := 'alter table '||var_table||' split partition the_rest values('''||par_value||''') into (partition '||var_partition||', partition the_rest)';
         execute immediate var_sql;
      end if;
      close csr_partition;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_create_list;

   /*********************************************************************/
   /* This procedure performs the truncate table list partition routine */
   /*********************************************************************/
   procedure truncate_list(par_table varchar2, par_partition varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_table varchar2(60);
      var_partition varchar2(60);
      var_sql varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_partition is
         select partition_name
           from user_tab_partitions
          where table_name = var_table
            and partition_name = var_partition;
      rcd_partition csr_partition%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the local variables
      /*-*/
      var_table := upper(par_table);
      var_partition := upper(par_partition);

      /*-*/
      /* Truncate the requested partition when found
      /*-*/
      open csr_partition;
      fetch csr_partition into rcd_partition;
      if csr_partition%found then
         var_sql := 'alter table ' || var_table || ' truncate partition ' || rcd_partition.partition_name;
         execute immediate var_sql;
      end if;
      close csr_partition;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate_list;

   /*****************************************************************/
   /* This procedure performs the drop table list partition routine */
   /*****************************************************************/
   procedure drop_list(par_table varchar2, par_partition varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_table varchar2(60);
      var_partition varchar2(60);
      var_sql varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_partition is
         select partition_name
           from user_tab_partitions
          where table_name = var_table
            and partition_name = var_partition;
      rcd_partition csr_partition%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the local variables
      /*-*/
      var_table := upper(par_table);
      var_partition := upper(par_partition);

      /*-*/
      /* Truncate the requested partition when found
      /*-*/
      open csr_partition;
      fetch csr_partition into rcd_partition;
      if csr_partition%found then
         var_sql := 'alter table ' || var_table || ' drop partition ' || rcd_partition.partition_name;
         execute immediate var_sql;
      end if;
      close csr_partition;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end drop_list;

end ods_partition;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_partition for ods.ods_partition;
grant execute on ods.ods_partition to ods_app;