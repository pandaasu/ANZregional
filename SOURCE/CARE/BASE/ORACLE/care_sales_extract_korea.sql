/******************/
/* Package Header */
/******************/
create or replace package care_sales_extract_korea as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : care_sales_extract_korea
 Owner   : dw_app

 Description
 -----------
 Care - Sales Extract - Korea Version

 This package contains the sales extract procedure for the Care system. The package exposes
 one procedure EXTRACT_SALES that performs the extract based on the following parameters:

 1. PAR_FILE_PATH (Interface file path) (MANDATORY, MAXIMUM LENGTH 128)

 2. PAR_FILE_NAME Interface file name) (MANDATORY, MAXIMUM LENGTH 64)

 3. PAR_SOURCE (Source unit code) (MANDATORY, MAXIMUM LENGTH 4)

 4. PAR_PERIOD (Mars period to extract) (MANDATORY, MAXIMUM LENGTH 6)

    YYYYPP - Period number
    *LAST - Last completed period

 5. PAR_DATA (GRD data flag) (MANDATORY, MAXIMUM LENGTH 1)

    Y - GRD data codes used.
    N - Legacy data codes used.

 **notes**
 1. All errors will raise an exception to the calling application so that an alert can
    be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created
 2007/01   Steve Gregan   Included POS material exclusions

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure extract_sales(par_file_path in varchar2,
                           par_file_name in varchar2,
                           par_source in varchar2,
                           par_period in varchar2,
                           par_data in varchar2);

end care_sales_extract_korea;
/

/****************/
/* Package Body */
/****************/
create or replace package body care_sales_extract_korea as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the extract sales routine */
   /*****************************************************/
   procedure extract_sales(par_file_path in varchar2,
                           par_file_name in varchar2,
                           par_source in varchar2,
                           par_period in varchar2,
                           par_data in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_output varchar2(4000);
      var_period number(6,0);
      type typ_output is table of varchar2(4000) index by binary_integer;
      tbl_output typ_output;
      var_opened boolean;
      var_fil_handle utl_file.file_type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_this_period is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_this_period csr_this_period%rowtype;

      cursor csr_sales is
         select t02.source_logx_code,
                t01.sales_cases,
                t02.trad_unit_outer_per_case,
                t02.trad_unit_units_per_outer
           from (select t01.trad_unit_code as trad_unit_code,
                        sum(t01.qty_invcd) as sales_cases
                   from sales_act_mfgcust_tu_dly t01,
                        bus_sgmnt_and_brand_view t02,
                        cust_dlvry_point t03,
                        whse t04,
                        sales_regn t05,
                        sub_chnl t06
                  where t01.trad_unit_code = t02.trad_unit_code
                    and t01.cust_dlvry_point_code = t03.cust_dlvry_point_code
                    and t03.whse_code = t04.whse_code
                    and t04.sales_regn_code = t05.sales_regn_code
                    and t03.sub_chnl_code = t06.sub_chnl_code
                    and t01.order_type in ('A', 'J', 'R', 'S', 'U')
                    and t01.yyyypp = var_period
                    and t06.sub_chnl_code <> 8720
                  group by t01.trad_unit_code) t01,
                trad_unit t02
          where t01.trad_unit_code = t02.trad_unit_code
            and t01.sales_cases != 0
            and substr(t02.source_logx_code,1,1) != 'P'
            and substr(t02.source_logx_code,1,2) != 'LX'
            and substr(t02.source_logx_code,1,2) != 'CM';
      rcd_sales csr_sales%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the procedure
      /*-*/
      var_opened := false;

      /*-*/
      /* Validate the file path
      /*-*/
      if par_file_path is null then
         raise_application_error(-20000, 'File path parameter must be specified');
      end if;
      if length(par_file_path) > 128 then
         raise_application_error(-20000, 'File path parameter exceeds maximum length 128');
      end if;

      /*-*/
      /* Validate the file name
      /*-*/
      if par_file_name is null then
         raise_application_error(-20000, 'File name parameter must be specified');
      end if;
      if length(par_file_name) > 64 then
         raise_application_error(-20000, 'File name parameter exceeds maximum length 64');
      end if;

      /*-*/
      /* Validate the source parameter
      /*-*/
      if par_source is null then
         raise_application_error(-20000, 'Source parameter must be specified');
      end if;
      if length(par_source) > 4 then
         raise_application_error(-20000, 'Source parameter exceeds maximum length 4');
      end if;

      /*-*/
      /* Validate the period parameter
      /*-*/
      if par_period is null then
         raise_application_error(-20000, 'Period parameter must be specified');
      end if;

      /*-*/
      /* Validate the data parameter
      /*-*/
      if upper(par_data) != 'Y' and upper(par_data) != 'N' then
         raise_application_error(-20000, 'Data parameter (' || par_data || ') must be Y(GRD) or N(Legacy)');
      end if;

      /*-*/
      /* Retrieve the last period or accept the parameter period
      /*-*/
      if trim(upper(par_period)) = '*LAST' then
         open csr_this_period;
         fetch csr_this_period into rcd_this_period;
         if csr_this_period%notfound then
            raise_application_error(-20000, 'Period parameter - current period not found in MARS_DATE');
         end if;
         close csr_this_period;
         var_period := rcd_this_period.mars_period - 1;
         if to_number(substr(to_char(var_period,'fm000000'),5,2)) = 0 then
            var_period := var_period - 87;
         end if;
      else
         begin
            var_period := to_number(par_period);
         exception
            when others then
               raise_application_error(-20000, 'Period parameter (' || par_period || ') - unable to convert to number');
         end;
      end if;

      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_output.delete;

      /*-*/
      /* Retrieve the sales data
      /*-*/
      open csr_sales;
      loop
         fetch csr_sales into rcd_sales;
         if csr_sales%notfound then
            exit;
         end if;

         /*-*/
         /* Output the sales details
         /*-*/
         var_output := 'DET';
         var_output := var_output || rpad(rcd_sales.source_logx_code,18,' ');
         var_output := var_output || lpad(to_char(rcd_sales.sales_cases,'9999999999999.00000'),20,' ');
         var_output := var_output || lpad(to_char(rcd_sales.trad_unit_outer_per_case*rcd_sales.trad_unit_units_per_outer,'fm9990'),4,' ');
         var_output := var_output || lpad(to_char(rcd_sales.trad_unit_outer_per_case,'fm9990'),4,' ');
         tbl_output(tbl_output.count + 1) := var_output;

      end loop;
      close csr_sales;

      /**/
      /* Open the interface file 
      /**/
      begin
         var_fil_handle := utl_file.fopen(par_file_path, par_file_name, 'w');
      exception
         when others then
            raise_application_error(-20000, 'Could not open interface file - Path (' || par_file_path || ') File (' || par_file_name || ') - ' || substr(SQLERRM, 1, 1024));
      end;
      var_opened := true;

      /*-*/
      /* Append the header record
      /*-*/
      var_output := 'HDR';
      var_output := var_output || to_char(sysdate,'yyyymmddhh24miss');
      var_output := var_output || rpad(par_source,20,' ');
      var_output := var_output || to_char(var_period,'fm000000');
      var_output := var_output || lpad(to_char(tbl_output.count,'fm9999999990'),10,' ');
      if upper(par_data) = 'Y' then 
         var_output := var_output || 'GRD';
      else
         var_output := var_output || rpad(' ',3,' ');
      end if;
      utl_file.put_line(var_fil_handle,var_output);

      /*-*/
      /* Append the detail records
      /*-*/
      for idx in 1..tbl_output.count loop
         utl_file.put_line(var_fil_handle,tbl_output(idx));
      end loop;

      /*-*/
      /* Close the interface file
      /*-*/
      begin
         utl_file.fclose(var_fil_handle);
      exception
         when others then
            raise_application_error(-20000, 'Could not close interface file - Path (' || par_file_path || ') File (' || par_file_name || ') - ' || substr(SQLERRM, 1, 1024));
      end;
      var_opened := false;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Close the file handle whn required
         /*-*/
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CARE SALES - EXTRACT_SALES - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_sales;

end care_sales_extract_korea;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym care_sales_extract_korea for dw_app.care_sales_extract_korea;
grant execute on care_sales_extract_korea to public;
