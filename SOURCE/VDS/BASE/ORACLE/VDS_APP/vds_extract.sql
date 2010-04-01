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

   /**/
   /* Public declarations
   /**/
   procedure update_list(par_query in varchar2, par_list in varchar2);
   procedure update_query(par_query in varchar2);
   procedure update_meta(par_query in varchar2, par_meta in varchar2);
   procedure update_data(par_query in varchar2, par_data in varchar2);
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
 --  rcd_vds_doc_query vds_doc_query%rowtype;
   rcd_vds_doc_meta vds_doc_meta%rowtype;
   rcd_vds_doc_data vds_doc_data%rowtype;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update List - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_list;

   /****************************************************/
   /* This procedure performs the update query routine */
   /****************************************************/
   procedure update_query(par_query in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the query document data
      /*-*/
      var_query := upper(par_query);
      delete from vds_doc_meta where vdm_query = var_query;
      delete from vds_doc_data where vdd_query = var_query;
      rcd_vds_doc_meta.vdm_row := 0;
      rcd_vds_doc_data.vdd_row := 0;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update Query - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_query;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update Meta - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_meta;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT - Update Data - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

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

end vds_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_extract for vds_app.vds_extract;
grant execute on vds_extract to public;