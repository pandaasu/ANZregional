/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_purging as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_purging
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Purging

    This package contains the forecast purging logic.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end dw_fcst_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_load;
   procedure purge_extract;

   /*-*/
   /* Private constants
   /*-*/
   cnt_process_count constant number(5,0) := 10;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the forecast load data
      /*-*/
      purge_load;

      /*-*/
      /* Purge the forecast extract data
      /*-*/
      purge_extract;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, 'DW_FORECAST_PURGING - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***********************************************************/
   /* This procedure performs the purge forecast load routine */
   /***********************************************************/
   procedure purge_load is

      /*-*/
      /* Local definitions
      /*-*/
      var_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is
         select t01.*
           from fcst_load_header t01,
                fcst_load_type t02
          where t01.load_type = t02.load_type
            and ((t02.load_type_version = '*PERIOD' and 
                  t01.load_data_version < (select mars_period from mars_date where calendar_date = trunc(sysdate - 180))) or
                 (t02.load_type_version = '*YEAR' and 
                  t01.load_data_version < (select mars_year-2 from mars_date where calendar_date = trunc(sysdate))));
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the forecast load data
      /*-*/
      var_count := 0;
      open csr_fcst_load_header;
      loop
         if var_count >= cnt_process_count then
            if csr_fcst_load_header%isopen then
               close csr_fcst_load_header;
            end if;
            commit;
            open csr_fcst_load_header;
            var_count := 0;
         end if;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from fcst_load_detail where load_identifier = rcd_fcst_load_header.load_identifier;
         delete from fcst_load_header where load_identifier = rcd_fcst_load_header.load_identifier;

      end loop;
      close csr_fcst_load_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_load;

   /**************************************************************/
   /* This procedure performs the purge forecast extract routine */
   /**************************************************************/
   procedure purge_extract is

      /*-*/
      /* Local definitions
      /*-*/
      var_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_header is
         select t01.*
           from fcst_extract_header t01,
                fcst_extract_type t02
          where t01.extract_type = t02.extract_type
            and ((t02.extract_type_version = '*PERIOD' and 
                  t01.extract_version < (select mars_period from mars_date where calendar_date = trunc(sysdate - 180))) or
                 (t02.extract_type_version = '*YEAR' and 
                  t01.extract_version < (select mars_year-2 from mars_date where calendar_date = trunc(sysdate))));
      rcd_fcst_extract_header csr_fcst_extract_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the forecast extract data
      /*-*/
      var_count := 0;
      open csr_fcst_extract_header;
      loop
         if var_count >= cnt_process_count then
            if csr_fcst_extract_header%isopen then
               close csr_fcst_extract_header;
            end if;
            commit;
            open csr_fcst_extract_header;
            var_count := 0;
         end if;
         fetch csr_fcst_extract_header into rcd_fcst_extract_header;
         if csr_fcst_extract_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from fcst_extract_load where extract_identifier = rcd_fcst_extract_header.extract_identifier;
         delete from fcst_extract_header where extract_identifier = rcd_fcst_extract_header.extract_identifier;

      end loop;
      close csr_fcst_extract_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_extract;

end dw_fcst_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_purging for dw_app.dw_fcst_purging;
grant execute on dw_fcst_purging to public;