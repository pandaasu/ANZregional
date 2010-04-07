/******************/
/* Package Header */
/******************/
create or replace package vds.vds_builder as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_builder
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Builder

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/

   /**/
   /* Public declarations
   /**/
   procedure execute(par_query in varchar2);

end vds_builder;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds.vds_builder as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_table varchar2(30);
      var_link varchar2(30);
      var_source varchar2(32767);
      var_columns boolean;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_query is 
         select t01.*
           from vds_doc_query t01
          where t01.vdq_query = var_query;
      rcd_vds_query csr_vds_query%rowtype;

      cursor csr_vds_tble is 
         select distinct(upper(t01.vdm_table)) as table_name
           from vds_doc_meta t01
          where t01.vdm_query = var_query
          order by table_name asc;
      rcd_vds_tble csr_vds_tble%rowtype;

      cursor csr_vds_meta is 
         select t01.vdm_column,
                decode(t01.vdm_type,'F','NUMBER','N','NUMBER','P','NUMBER','VARCHAR2') as vdm_type,
                t01.vdm_length
           from vds_doc_meta t01
          where t01.vdm_query = var_query
            and t01.vdm_table = var_link
          order by t01.vdm_table asc,
                   t01.vdm_offset asc;
      rcd_vds_meta csr_vds_meta%rowtype;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_tble is table of csr_vds_tble%rowtype index by binary_integer;
      type typ_meta is table of csr_vds_meta%rowtype index by binary_integer;
      tbl_tble typ_tble;
      tbl_meta typ_meta;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_query := upper(par_query);

      /*-*/
      /* Validate the parameters
      /*-*/
      var_found := false;
      open csr_vds_query;
      fetch csr_vds_query into rcd_vds_query;
      if csr_vds_query%found then
         var_found := true;
      end if;
      close csr_vds_query;
      if var_found = false then
         raise_application_error(-20000, 'VDS document query (' || var_query || ') does not exist in VDS_DOC_QUERY table');
      end if;

      /*-*/
      /* Retrieve the VDS query tables
      /*-*/
      tbl_tble.delete;
      open csr_vds_tble;
      fetch csr_vds_tble bulk collect into tbl_tble;
      close csr_vds_tble;

      /*-*/
      /* Remove the existing VDS query tables
      /*-*/
      for idx in 1..tbl_tble.count loop
         var_table := var_query||'_'||replace(tbl_tble(idx).table_name,'/',null);
         begin
            execute immediate 'drop table vds.' || lower(var_table) || ' purge';
         exception
            when others then
               null;
         end;
      end loop;

      /*-*/
      /* Build the VDS query tables
      /*-*/
      for idx in 1..tbl_tble.count loop

         /*-*/
         /* Start the table source
         /*-*/
         var_table := var_query||'_'||replace(tbl_tble(idx).table_name,'/',null);
         var_source := 'create table vds.' || lower(var_table);

         /*-*/
         /* Retrieve the VDS table meta columns
         /*-*/
         var_link := tbl_tble(idx).table_name;
         tbl_meta.delete;
         open csr_vds_meta;
         fetch csr_vds_meta bulk collect into tbl_meta;
         close csr_vds_meta;
         var_columns := false;
         for idy in 1..tbl_meta.count loop

            /*-*/
            /* Append the column to the table source
            /*-*/
            if var_columns = false then
               var_source := var_source || ' (';
            else
               var_source := var_source || ',';
            end if;
            var_columns := true;
            if upper(tbl_meta(idy).vdm_type) = 'F' or upper(tbl_meta(idy).vdm_type) = 'N' or upper(tbl_meta(idy).vdm_type) = 'P' then
               var_source := var_source || lower(tbl_meta(idy).vdm_column) || ' number null';
            else
               var_source := var_source || lower(tbl_meta(idy).vdm_column) || ' varchar2(' || to_char(tbl_meta(idy).vdm_length,'fm99990') || ' char) null';
            end if;

         end loop;

         /*-*/
         /* Finalise the table source
         /*-*/
         var_source := var_source || ')';

         /*-*/
         /* Create the table
         /*-*/
         execute immediate var_source;
         execute immediate 'grant select, insert, update, delete on vds.' || lower(var_table) || ' to vds_app';
         execute immediate 'grant select on vds.' || lower(var_table) || ' to public with grant option';

      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_BUILDER - Execute - ' || var_source || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end vds_builder;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_builder for vds.vds_builder;
grant execute on vds.vds_builder to vds_app;