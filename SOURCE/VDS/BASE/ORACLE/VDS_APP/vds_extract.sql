/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_extract as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_extract
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Extract Package

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_list(par_query in varchar2);
   procedure update_list(par_query in varchar2, par_list in varchar2);
   procedure start_meta(par_query in varchar2);
   procedure update_meta(par_query in varchar2, par_meta in varchar2);
   procedure final_meta(par_query in varchar2);
   procedure start_data(par_query in varchar2);
   procedure update_data(par_query in varchar2, par_data in varchar2);
   procedure final_data(par_query in varchar2);
   function create_buffer(par_sql in varchar2) return clob;

end vds_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   procedure generate_views(par_query in varchar2);
   rcd_vds_doc_query vds_doc_query%rowtype;
   rcd_vds_doc_meta vds_doc_meta%rowtype;
   rcd_vds_doc_data vds_doc_data%rowtype;

   /**************************************************/
   /* This procedure performs the clear list routine */
   /**************************************************/
   procedure clear_list(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_query is 
         select t01.*
           from vds_doc_query t01
          where t01.vdq_query = var_query;
      rcd_vds_query csr_vds_query%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      var_query := upper(par_query);
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
      /* Clear the table data
      /*-*/
      execute immediate 'begin ' || rcd_vds_query.vdq_load_proc || '.clear; end;';

      /*-*/
      /* Clear the query document list
      /*-*/
      delete from vds_doc_list where vdl_query = var_query;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Clear List - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_list;

   /***************************************************/
   /* This procedure performs the update list routine */
   /***************************************************/
   procedure update_list(par_query in varchar2, par_list in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_list varchar2(4000);
      var_number varchar2(30 char);
      var_date varchar2(20 char);
      var_char varchar2(1);
      var_flag varchar2(1);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*
           from vds_doc_list t01
          where t01.vdl_query = var_query
            and t01.vdl_number = var_number;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Extract the document list data and process
      /*-*/
      var_query := upper(par_query);
      var_list := par_list;
      var_number := null;
      var_date := null;
      var_flag := '1';
      for idx in 1..length(var_list) loop
         var_char := substr(var_list,idx,1);
         if var_char = ';' then
            if not(var_number is null) and not(var_date is null) then
               var_found := false;
               open csr_list;
               fetch csr_list into rcd_list;
               if csr_list%found then
                  var_found := true;
               end if;
               close csr_list;
               if var_found = true then
                  if rcd_list.vdl_date != var_date then
                     update vds_doc_list
                        set vdl_date = var_date,
                            vdl_status = '*CHANGED',
                            vdl_vds_date = sysdate
                      where vdl_query = var_query
                        and vdl_number = var_number;
                  end if;
               else
                  insert into vds_doc_list values(var_query, var_number, var_date, '*CHANGED', sysdate);
               end if;
            end if;
            var_number := null;
            var_date := null;
            var_flag := '1';
         elsif var_char = ',' then
            var_flag := '2';
         else
            if var_flag = '1' then
               var_number := var_number||var_char;
            else
               var_date := var_date||var_char;
            end if;
         end if;
      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update List - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_list;

   /****************************************************/
   /* This procedure performs the start meta routine */
   /****************************************************/
   procedure start_meta(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_query is 
         select t01.*
           from vds_doc_query t01
          where t01.vdq_query = var_query;
      rcd_vds_query csr_vds_query%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      var_query := upper(par_query);
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
      /* Clear the query document data
      /*-*/
      delete from vds_doc_meta where vdm_query = var_query;
      rcd_vds_doc_meta.vdm_row := 0;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Start Meta - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_meta;

   /***************************************************/
   /* This procedure performs the update meta routine */
   /***************************************************/
   procedure update_meta(par_query in varchar2, par_meta in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_meta varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the meta data
      /*-*/
      var_query := upper(par_query);
      var_meta := par_meta;
      rcd_vds_doc_meta.vdm_query := var_query;
      rcd_vds_doc_meta.vdm_row := rcd_vds_doc_meta.vdm_row + 1;
      rcd_vds_doc_meta.vdm_table := trim(substr(var_meta,1,30));
      rcd_vds_doc_meta.vdm_column := trim(substr(var_meta,31,30));
      rcd_vds_doc_meta.vdm_type := trim(substr(var_meta,61,10));
      rcd_vds_doc_meta.vdm_offset := to_number(trim(substr(var_meta,71,9)));
      rcd_vds_doc_meta.vdm_length := to_number(trim(substr(var_meta,80,9)));
      insert into vds_doc_meta
         (vdm_query,
          vdm_row,
          vdm_table,
          vdm_column,
          vdm_type,
          vdm_offset,
          vdm_length)
      values
         (rcd_vds_doc_meta.vdm_query,
          rcd_vds_doc_meta.vdm_row,
          rcd_vds_doc_meta.vdm_table,
          rcd_vds_doc_meta.vdm_column,
          rcd_vds_doc_meta.vdm_type,
          rcd_vds_doc_meta.vdm_offset,
          rcd_vds_doc_meta.vdm_length);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update Meta - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_meta;

   /**************************************************/
   /* This procedure performs the final meta routine */
   /**************************************************/
   procedure final_meta(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Finalise the query document data
      /*-*/
      var_query := upper(par_query);
      generate_views(var_query);
      vds.vds_builder.execute(var_query);

      /*-*/
      /* Update the query meta date
      /*-*/
      update vds_doc_query
         set vdq_meta_date = sysdate
       where vdq_query = var_query;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Final Meta - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end final_meta;

   /**************************************************/
   /* This procedure performs the start data routine */
   /**************************************************/
   procedure start_data(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_query is 
         select t01.*
           from vds_doc_query t01
          where t01.vdq_query = var_query;
      rcd_vds_query csr_vds_query%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      var_query := upper(par_query);
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
      /* Clear the query document data
      /*-*/
      delete from vds_doc_data where vdd_query = var_query;
      rcd_vds_doc_data.vdd_row := 0;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Start Data - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_data;

   /***************************************************/
   /* This procedure performs the update data routine */
   /***************************************************/
   procedure update_data(par_query in varchar2, par_data in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_data varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the data
      /*-*/
      var_query := upper(par_query);
      var_data := par_data;
      rcd_vds_doc_data.vdd_query := var_query;
      rcd_vds_doc_data.vdd_row := rcd_vds_doc_data.vdd_row + 1;
      rcd_vds_doc_data.vdd_table := trim(substr(var_data,1,30));
      rcd_vds_doc_data.vdd_data := trim(substr(var_data,31,4000));
      insert into vds_doc_data
         (vdd_query,
          vdd_row,
          vdd_table,
          vdd_data)
      values
         (rcd_vds_doc_data.vdd_query,
          rcd_vds_doc_data.vdd_row,
          rcd_vds_doc_data.vdd_table,
          rcd_vds_doc_data.vdd_data);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update Data - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /**************************************************/
   /* This procedure performs the final data routine */
   /**************************************************/
   procedure final_data(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_query is 
         select t01.*
           from vds_doc_query t01
          where t01.vdq_query = var_query;
      rcd_vds_query csr_vds_query%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      var_query := upper(par_query);
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
      /* Load the table data
      /*-*/
      execute immediate 'begin ' || rcd_vds_query.vdq_load_proc || '.load; end;';

      /*-*/
      /* Update the query document list
      /*-*/
      update vds_doc_list
         set vdl_status = '*ACTIVE'
       where vdl_query = var_query
         and vdl_status = '*CHANGED';

      /*-*/
      /* Update the query meta date
      /*-*/
      update vds_doc_query
         set vdq_data_date = sysdate
       where vdq_query = var_query;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Delete the query document data
      /*-*/
      delete from vds_doc_data where vdd_query = var_query;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Final Data - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end final_data;

   /********************************************/
   /* This procedure defines the create buffer */
   /********************************************/
   function create_buffer(par_sql in varchar2) return clob is

      /*-*/
      /* Local definitions
      /*-*/
      lobReference clob;
      type typ_list is ref cursor;
      csr_list typ_list;
      var_code varchar2(128 char);
      var_count number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the buffer
      /*-*/
      dbms_lob.createtemporary(lobReference,true);

      /*-*/
      /* Execute the list query to the buffer
      /*-*/
      var_count := 0;
      begin
         open csr_list for par_sql;
      exception
         when others then
            raise_application_error(-20000, 'List query failed - ' || substr(SQLERRM, 1, 1024));
      end;
      loop
         fetch csr_list into var_code;
         if csr_list%notfound then
            exit;
         end if;
         if var_count >= 200 then
            dbms_lob.writeappend(lobReference, 1, utl_tcp.CRLF);
            var_count := 0;
         end if;
         if var_count > 0 then
            dbms_lob.writeappend(lobReference, 1, ',');
         end if;
         dbms_lob.writeappend(lobReference, length(rtrim(var_code)), rtrim(var_code));
         var_count := var_count + 1;
      end loop;
      close csr_list;
      if var_count > 0 then
         dbms_lob.writeappend(lobReference, 1, utl_tcp.CRLF);
         var_count := 0;
      end if;

      /*-*/
      /* Return the data buffer
      /*-*/
      return lobReference;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_buffer;

   /******************************************************/
   /* This procedure performs the generate views routine */
   /******************************************************/
   procedure generate_views(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_sav_query varchar2(30);
      var_sav_table varchar2(30);
      var_view_name varchar2(30);
      var_columns boolean;
      var_view_source varchar2(32767);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_vds_meta is 
         select t01.*
           from vds_doc_meta t01
          where t01.vdm_query = upper(par_query)
          order by t01.vdm_table asc,
                   t01.vdm_offset asc;
      rcd_vds_meta csr_vds_meta%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the query meta data
      /*-*/
      var_sav_query := null;
      var_sav_table := null;
      open csr_vds_meta;
      loop
         fetch csr_vds_meta into rcd_vds_meta;
         if csr_vds_meta%notfound then
            exit;
         end if;

         /*-*/
         /* Change of table
         /*-*/
         if var_sav_table is null or var_sav_table != rcd_vds_meta.vdm_table then

            /*-*/
            /* Create the previous view when required
            /*-*/
            if not(var_sav_table is null) then

               /*-*/
               /* Finalise the view source
               /*-*/
               var_view_source := var_view_source || ' from vds_doc_data t01';
               var_view_source := var_view_source || ' where t01.vdd_query = ''' || var_sav_query || '''';
               var_view_source := var_view_source || ' and t01.vdd_table = ''' || var_sav_table || '''';

               /*-*/
               /* Creates the view
               /*-*/
               execute immediate var_view_source;
               execute immediate 'grant select on vds_app.' || lower(var_view_name) || ' to public with grant option';

            end if;

            /*-*/
            /* Reset the control data
            /*-*/
            var_sav_query := rcd_vds_meta.vdm_query;
            var_sav_table := rcd_vds_meta.vdm_table;
            var_view_name := 'view_'||var_sav_query || '_' || replace(var_sav_table,'/',null);
            var_columns := false;

            /*-*/
            /* Start the view source
            /*-*/
            var_view_source := 'create or replace force view vds_app.' || lower(var_view_name) || ' as select';

         end if;

         /*-*/
         /* Append the column to the view source
         /*-*/
         if var_columns = true then
            var_view_source := var_view_source || ',';
         end if;
         var_columns := true;
         if upper(rcd_vds_meta.vdm_type) = 'F' then
            var_view_source := var_view_source || ' to_number(replace(nvl(trim(substr(t01.vdd_data,' || to_char(rcd_vds_meta.vdm_offset+1,'fm99990') || ',' || to_char(rcd_vds_meta.vdm_length,'fm99990') || ')),''0''),'','',null)) as ' || rcd_vds_meta.vdm_column;
         elsif upper(rcd_vds_meta.vdm_type) = 'N' or upper(rcd_vds_meta.vdm_type) = 'P' then
            var_view_source := var_view_source || ' to_number(replace(nvl(trim(substr(t01.vdd_data,' || to_char(rcd_vds_meta.vdm_offset+1,'fm99990') || ',' || to_char(rcd_vds_meta.vdm_length,'fm99990') || ')),''0''),'','',null)) as ' || rcd_vds_meta.vdm_column;
         else
            var_view_source := var_view_source || ' rtrim(substr(t01.vdd_data,' || to_char(rcd_vds_meta.vdm_offset+1,'fm99990') || ',' || to_char(rcd_vds_meta.vdm_length,'fm99990') || ')) as ' || rcd_vds_meta.vdm_column;
         end if;

      end loop;
      close csr_vds_meta;

      /*-*/
      /* Create the last view when required
      /*-*/
      if not(var_sav_table is null) then

         /*-*/
         /* Finalise the view source
         /*-*/
         var_view_source := var_view_source || ' from vds_doc_data t01';
         var_view_source := var_view_source || ' where t01.vdd_query = ''' || var_sav_query || '''';
         var_view_source := var_view_source || ' and t01.vdd_table = ''' || var_sav_table || '''';

         /*-*/
         /* Creates the view
         /*-*/
         execute immediate var_view_source;
         execute immediate 'grant select on vds_app.' || lower(var_view_name) || ' to public with grant option';

      end if;

      /*-*/
      /* Update the query view date
      /*-*/
      update vds_doc_query
         set vdq_meta_date = sysdate
       where vdq_query = upper(par_query);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Generate Views - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate_views;

end vds_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_extract for vds_app.vds_extract;
grant execute on vds_extract to public;