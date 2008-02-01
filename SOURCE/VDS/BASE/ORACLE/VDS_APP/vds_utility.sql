/******************/
/* Package Header */
/******************/
create or replace package vds_utility as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_utility
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Utility Package

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/02   Steve Gregan   Created

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure generate_views(par_query in varchar2);

end vds_utility;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_utility as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

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
         select *
           from vds_meta t01
          where t01.vme_query = upper(par_query)
          order by t01.vme_table asc,
                   t01.vme_offset asc;
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
         if var_sav_table is null or var_sav_table != rcd_vds_meta.vme_table then

            /*-*/
            /* Create the previous view when required
            /*-*/
            if not(var_sav_table is null) then

               /*-*/
               /* Finalise the view source
               /*-*/
               var_view_source := var_view_source || ' from vds_data t01';
               var_view_source := var_view_source || ' where t01.vda_query = ''' || var_sav_query || '''';
               var_view_source := var_view_source || ' and t01.vda_table = ''' || var_sav_table || '''';

               /*-*/
               /* Creates the view
               /*-*/
               execute immediate var_view_source;
               execute immediate 'grant select on vds_app.' || lower(var_view_name) || ' to public with grant option';

            end if;

            /*-*/
            /* Reset the control data
            /*-*/
            var_sav_query := rcd_vds_meta.vme_query;
            var_sav_table := rcd_vds_meta.vme_table;
            var_view_name := var_sav_query || '_' || var_sav_table;
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
         if upper(rcd_vds_meta.vme_type) = 'F' then
            var_view_source := var_view_source || ' to_number(replace(nvl(trim(substr(t01.vda_data,' || to_char(rcd_vds_meta.vme_offset+1,'fm99990') || ',' || to_char(rcd_vds_meta.vme_length,'fm99990') || ')),''0''),'','',''.'')) as ' || rcd_vds_meta.vme_column;
         elsif upper(rcd_vds_meta.vme_type) = 'N' or upper(rcd_vds_meta.vme_type) = 'P' then
            var_view_source := var_view_source || ' to_number(nvl(trim(substr(t01.vda_data,' || to_char(rcd_vds_meta.vme_offset+1,'fm99990') || ',' || to_char(rcd_vds_meta.vme_length,'fm99990') || ')),''0'')) as ' || rcd_vds_meta.vme_column;
         else
            var_view_source := var_view_source || ' rtrim(substr(t01.vda_data,' || to_char(rcd_vds_meta.vme_offset+1,'fm99990') || ',' || to_char(rcd_vds_meta.vme_length,'fm99990') || ')) as ' || rcd_vds_meta.vme_column;
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
         var_view_source := var_view_source || ' from vds_data t01';
         var_view_source := var_view_source || ' where t01.vda_query = ''' || var_sav_query || '''';
         var_view_source := var_view_source || ' and t01.vda_table = ''' || var_sav_table || '''';

         /*-*/
         /* Creates the view
         /*-*/
         execute immediate var_view_source;
         execute immediate 'grant select on vds_app.' || lower(var_view_name) || ' to public with grant option';

      end if;

      /*-*/
      /* Update the query view date
      /*-*/
      update vds_query
         set vqu_view_date = sysdate
       where vqu_query = upper(par_query);

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - Generate Views - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate_views;

end vds_utility;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_utility for vds_app.vds_utility;
grant execute on vds_utility to public;