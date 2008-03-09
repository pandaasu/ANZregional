/*****************/
/* Package Types */
/*****************/
create or replace type dw_fcst_table as table of varchar2(4000 char);
/

/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_extract01 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_extract01
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Extract - BW Forecast Extract

    This package contains the BW forecast extract procedure.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function export(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

end dw_fcst_extract01;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_extract01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**********************************************/
   /* This procedure performs the export routine */
   /**********************************************/
   function export(par_extract_identifier in varchar2) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_header is 
         select t01.*
           from fcst_extract_header t01
          where t01.extract_identifier = var_extract_identifier
            for update nowait;
      rcd_fcst_extract_header csr_fcst_extract_header%rowtype;

      cursor csr_fcst_extract_load is 
         select t01.*
           from fcst_extract_load t01
          where t01.extract_identifier = rcd_fcst_extract_header.extract_identifier;
      rcd_fcst_extract_load csr_fcst_extract_load%rowtype;

      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = rcd_fcst_extract_load.load_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is 
         select t01.*
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier
            and (rcd_fcst_extract_header.plan_group = '*NONE' or
                 t01.plan_group = rcd_fcst_extract_header.plan_group)
          order by material_code asc,
                   plant_code asc,
                   fcst_yyyypp asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_extract_identifier := upper(par_extract_identifier);
      if var_extract_identifier is null then
         raise_application_error(-20000, 'Forecast extract identifier must be specified');
      end if;

      /*-*/
      /* Attempt to lock the forecast extract header
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_fcst_extract_header;
         fetch csr_fcst_extract_header into rcd_fcst_extract_header;
         if csr_fcst_extract_header%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_fcst_extract_header%isopen then
         close csr_fcst_load_header;
      end if;

      /*-*/
      /* Release the header lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then
         raise_application_error(-20000, 'Forecast extract (' || var_extract_identifier || ') does not exist or is already locked');
      end if;

      /*-*/
      /* Retrieve the forecast extract loads
      /*-*/
      open csr_fcst_extract_load;
      loop
         fetch csr_fcst_extract_load into rcd_fcst_extract_load;
         if csr_fcst_extract_load%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the forecast load header
         /*-*/
         open csr_fcst_load_header;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            raise_application_error(-20000, 'Forecast load (' || rcd_fcst_extract_load.load_identifier || ') does not exist');
         end if;
         close csr_fcst_load_header;

         /*-*/
         /* Retrieve the forecast load detail
         /*-*/
         open csr_fcst_load_detail;
         loop
            fetch csr_fcst_load_detail into rcd_fcst_load_detail;
            if csr_fcst_load_detail%notfound then
               exit;
            end if;

            /*-*/
            /* Set the output string
            /*-*/
            var_output := xxxxxxxxxxxxxxxxxxxxxxxxx;
            var_output := var_output || xxxxxxxxxxxxxxxxxxxxxxxxx;

            /*-*/
            /* Pipe the output to the consumer
            /*-*/
            pipe row(var_output);

         end loop;
         close csr_fcst_load_detail;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* Return
      /*-*/  
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT01 - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end export;

end dw_fcst_extract01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_extract01 for dw_app.dw_fcst_extract01;
grant execute on dw_fcst_extract01 to public;
