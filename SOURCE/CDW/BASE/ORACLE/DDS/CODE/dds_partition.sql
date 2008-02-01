/******************/
/* Package Header */
/******************/
create or replace package dds_partition as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Object : dds_partition
    Owner  : dds

    Description
    -----------
    Dimensional Data Store - Partition
 
    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure check_create(par_table varchar2, par_partition number, par_subpartition varchar2, par_prefix varchar2);
   procedure truncate(par_table varchar2, par_partition number, par_subpartition varchar2, par_prefix varchar2);

end dds_partition;
/

/****************/
/* Package Body */
/****************/
create or replace package body dds_partition as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************************/
   /* This procedure performs the check/create table partition routine */
   /********************************************************************/
   procedure check_create(par_table varchar2, par_partition number, par_subpartition varchar2, par_prefix varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(6);
      var_table varchar2(60);
      var_year varchar2(4);
      var_period varchar2(2);
      var_prefix varchar2(1);
      var_partition varchar2(60);
      var_subpartition varchar2(60);
      var_sql varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_partition is
         select partition_name
           from user_tab_partitions
          where table_name = var_table
            and partition_name >= var_partition
          order by partition_name asc;
      rcd_partition csr_partition%rowtype;

      cursor csr_subpartition is
         select subpartition_name
           from user_tab_subpartitions
          where table_name = var_table
            and partition_name = var_partition
            and subpartition_name = var_subpartition;
      rcd_subpartition csr_subpartition%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the local variables
      /*-*/
      var_work := to_char(par_partition,'fm000000');
      var_table := upper(par_table);
      var_year := substr(var_work,1,4);
      var_period := substr(var_work,5,2);
      var_prefix := upper(par_prefix);
      var_partition := 'Y' || var_year || '_' || var_prefix || var_period;
      var_subpartition := 'Y' || var_year || '_' || var_prefix || var_period || '_C' || par_subpartition;

      /*-*/
      /* Initialise the partition less than variables
      /*-*/
      if (var_prefix = 'P' and var_period = '13') then
         var_year := to_char(to_number(var_year)+1,'fm0000');
         var_period := '01';
      elsif (var_prefix = 'M' and var_period = '12') then
         var_year := to_char(to_number(var_year)+1,'fm0000');
         var_period := '01';
      elsif (var_prefix = 'P' and var_period < '13') then
         var_period := to_char(to_number(var_period)+1,'fm00');
      elsif (var_prefix = 'M' and var_period < '12') then
         var_period := to_char(to_number(var_period)+1,'fm00');
      else
         raise_application_error(-20000, 'DDS_PARTITION - invalid table partition date range');
      end if;

      /*-*/
      /* Create the new partition when not found
      /* Split the higher partition when required
      /*-*/
      open csr_partition;
      fetch csr_partition into rcd_partition;
      if csr_partition%notfound then
         var_sql := 'alter table ' || var_table || ' split partition the_rest at ';
         var_sql := var_sql || '(' || var_year || var_period || ')';
         var_sql := var_sql || ' into (partition ' || var_partition;
         var_sql := var_sql || ', partition the_rest)';
         execute immediate var_sql;
      elsif rcd_partition.partition_name > var_partition then
         var_sql := 'alter table ' || var_table || ' split partition ' || rcd_partition.partition_name || ' at ';
         var_sql := var_sql || '(' || var_year || var_period || ')';
         var_sql := var_sql || ' into (partition ' || var_partition;
         var_sql := var_sql || ', partition ' || rcd_partition.partition_name || ')';
         execute immediate var_sql;
      end if;
      close csr_partition;

      /*-*/
      /* Create the new subpartition when not found
      /*-*/
      open csr_subpartition;
      fetch csr_subpartition into rcd_subpartition;
      if csr_subpartition%notfound then
         var_sql := 'alter table ' || var_table || ' split subpartition ' || var_partition || '_the_rest';
         var_sql := var_sql || ' values (''' || par_subpartition || ''') into';
         var_sql := var_sql || ' (subpartition ' || var_subpartition || ',';
         var_sql := var_sql || ' subpartition ' || var_partition || '_the_rest)';
         execute immediate var_sql;
      end if;
      close csr_subpartition;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_create;

   /****************************************************************/
   /* This procedure performs the truncate table partition routine */
   /****************************************************************/
   procedure truncate(par_table varchar2, par_partition number, par_subpartition varchar2, par_prefix varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(6);
      var_table varchar2(60);
      var_year varchar2(4);
      var_period varchar2(2);
      var_prefix varchar2(1);
      var_partition varchar2(60);
      var_subpartition varchar2(60);
      var_partpartition varchar2(60);
      var_sql varchar2(2000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_subpartition is
         select subpartition_name
           from user_tab_subpartitions
          where table_name = var_table
            and ((partition_name = var_partition and
                  subpartition_name = var_subpartition) or
                 (par_partition = 999999 and
                  subpartition_name like var_partpartition)) 
          order by partition_name asc,
                   subpartition_name asc;
      rcd_subpartition csr_subpartition%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the local variables
      /*-*/
      var_work := to_char(par_partition,'fm000000');
      var_table := upper(par_table);
      var_year := substr(var_work,1,4);
      var_period := substr(var_work,5,2);
      var_prefix := upper(par_prefix);
      var_partition := 'Y' || var_year || '_' || var_prefix || var_period;
      var_subpartition := 'Y' || var_year || '_' || var_prefix || var_period || '_C' || par_subpartition;
      var_partpartition := '%_C' || par_subpartition;

      /*-*/
      /* Truncate the requested subpartitions
      /*-*/
      open csr_subpartition;
      loop
         fetch csr_subpartition into rcd_subpartition;
         if csr_subpartition%notfound then
            exit;
         end if;
         var_sql := 'alter table ' || var_table || ' truncate subpartition ' || rcd_subpartition.subpartition_name;
         execute immediate var_sql;
      end loop;
      close csr_subpartition;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end truncate;

end dds_partition;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dds_partition for dds.dds_partition;
grant execute on dds_partition to dw_app;