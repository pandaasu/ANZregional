/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_extract05 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_extract05
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Extract - BW ROB Extract

    This package contains the BW ROB extract procedure.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function export(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

end dw_fcst_extract05;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_extract05 as

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
      var_type varchar2(32 char);
      var_version varchar2(32 char);
      var_planner varchar2(32 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_header is 
         select t01.*,
                t02.extract_plan_group,
                t02.extract_planner
           from fcst_extract_header t01,
                fcst_extract_type t02
          where t01.extract_type = t02.extract_type(+)
            and t01.extract_identifier = var_extract_identifier;
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
         select t01.fcst_yyyypp,
                t01.plant_code,
                t01.material_code,
                sum(t01.fcst_qty) as fcst_qty,
                sum(t01.fcst_gsv) as fcst_gsv
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_extract_load.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
          group by t01.fcst_yyyypp,
                   t01.plant_code,
                   t01.material_code
          order by t01.fcst_yyyypp asc,
                   t01.plant_code asc,
                   t01.material_code asc;
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
      /* Retrieve the extract header
      /*-*/
      open csr_fcst_extract_header;
      fetch csr_fcst_extract_header into rcd_fcst_extract_header;
      if csr_fcst_extract_header%notfound then
         raise_application_error(-20000, 'Forecast extract (' || var_extract_identifier || ') does not exist');
      end if;
      close csr_fcst_extract_header;

      /*-*/
      /* Pipe the header row
      /*-*/
      var_output := 'Plan Type';
      var_output := var_output || chr(9) || 'Plan Version';
      var_output := var_output || chr(9) || 'Plan Id';
      var_output := var_output || chr(9) || 'Mars Period';
      var_output := var_output || chr(9) || 'Company Code';
      var_output := var_output || chr(9) || 'Distribution Channel';
      var_output := var_output || chr(9) || 'Division';
      var_output := var_output || chr(9) || 'Sales Organisation';
      var_output := var_output || chr(9) || 'Plant';
      var_output := var_output || chr(9) || 'Ship-to Party';
      var_output := var_output || chr(9) || 'Sold-to Party';
      var_output := var_output || chr(9) || 'Bill-to Party';
      var_output := var_output || chr(9) || 'Material';
      var_output := var_output || chr(9) || 'Business Segmnent';
      var_output := var_output || chr(9) || 'Pack Sub Family';
      var_output := var_output || chr(9) || 'Market Segment';
      var_output := var_output || chr(9) || 'Product Category';
      var_output := var_output || chr(9) || 'Product Type';
      var_output := var_output || chr(9) || 'Brand Flag';
      var_output := var_output || chr(9) || 'Representative Item';
      var_output := var_output || chr(9) || 'Plan Item';
      var_output := var_output || chr(9) || 'Unit for Quantity';
      var_output := var_output || chr(9) || 'Planned Quantity';
      var_output := var_output || chr(9) || 'Currency';
      var_output := var_output || chr(9) || 'Planned GSV';
      var_output := var_output || chr(9) || 'Planned NIV';
      var_output := var_output || chr(9) || 'Planned COPA1';
      var_output := var_output || chr(9) || 'Planned COPA2';
      var_output := var_output || chr(9) || 'Planned COPA3';
      pipe row(var_output);

      /*-*/
      /* Retrieve the forecast extract loads (CN_YEE_OFL output)
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
            /* Set the control data
            /*-*/
            var_type := 'CN_YEE_OFL';
            var_version := substr(to_char(rcd_fcst_load_detail.fcst_yyyypp,'fm000000'),1,4)||'P';
            if substr(to_char(rcd_fcst_load_detail.fcst_yyyypp,'fm000000'),5,1) = '0' then
               var_version := var_version||substr(to_char(rcd_fcst_load_detail.fcst_yyyypp,'fm000000'),6,1);
            else
               var_version := var_version||substr(to_char(rcd_fcst_load_detail.fcst_yyyypp,'fm000000'),5,2);
            end if;
            var_planner := rcd_fcst_extract_header.extract_planner;

            /*-*/
            /* Pipe the detail row when required
            /*-*/
            if rcd_fcst_load_detail.fcst_yyyypp >= rcd_fcst_extract_header.extract_version then
               var_output := var_type;
               var_output := var_output || chr(9) || var_version;
               var_output := var_output || chr(9) || var_planner;
               var_output := var_output || chr(9) || to_char(rcd_fcst_load_detail.fcst_yyyypp,'fm000000');
               var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.distbn_chnl_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.division_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
               var_output := var_output || chr(9) || rcd_fcst_load_detail.plant_code;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || rcd_fcst_load_detail.material_code;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || 'EA';
               var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail.fcst_qty,2));
               var_output := var_output || chr(9) || 'RMB';
               var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail.fcst_gsv,2));
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               pipe row(var_output);
            end if;

         end loop;
         close csr_fcst_load_detail;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* Retrieve the forecast extract loads (CN_YEE_HST output)
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
            /* Set the control data
            /*-*/
            var_type := 'CN_YEE_HST';
            var_version := 'ROB_'||substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),1,6);
            var_planner := rcd_fcst_extract_header.extract_planner;

            /*-*/
            /* Pipe the detail row
            /*-*/
            var_output := var_type;
            var_output := var_output || chr(9) || var_version;
            var_output := var_output || chr(9) || var_planner;
            var_output := var_output || chr(9) || to_char(rcd_fcst_load_detail.fcst_yyyypp,'fm000000');
            var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
            var_output := var_output || chr(9) || rcd_fcst_load_header.distbn_chnl_code;
            var_output := var_output || chr(9) || rcd_fcst_load_header.division_code;
            var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
            var_output := var_output || chr(9) || rcd_fcst_load_detail.plant_code;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || rcd_fcst_load_detail.material_code;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || 'EA';
            var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail.fcst_qty,2));
            var_output := var_output || chr(9) || 'RMB';
            var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail.fcst_gsv,2));
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
            var_output := var_output || chr(9) || null;
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
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT05 - EXPORT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end export;

end dw_fcst_extract05;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_extract05 for dw_app.dw_fcst_extract05;
grant execute on dw_fcst_extract05 to public;
