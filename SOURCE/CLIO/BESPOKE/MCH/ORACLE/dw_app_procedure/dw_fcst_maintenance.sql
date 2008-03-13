/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_maintenance as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_maintenance
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Maintenance

    This package contain the procedures for forecast maintenance. The package exposes the
    following procedures.

    1. SELECT_LOAD

       This procedure is used to retrieve the forecast load into an excel spreadsheet.

    2. DELETE_LOAD

       This procedure is used to delete the forecast load.

    3. CREATE_PERIOD_LOAD

       This procedure is used to create a forecast period load data set.

    4. UPDATE_PERIOD_LOAD

       This procedure is used to update the forecast period load from an excel spreadsheet.

    5. EXTRACT_LOAD

       This procedure is used to accept the forecast period load and update the operational data store.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure delete_load(par_load_identifier in varchar2);
   procedure delete_extract(par_extract_identifier in varchar2);
   procedure create_apollo_load(par_cast_date in varchar2);
   function create_stream_load(par_load_type in varchar2,
                               par_load_identifier in varchar2,
                               par_load_description in varchar2,
                               par_load_data_type in varchar2,
                               par_load_data_version in number,
                               par_load_data_range in number,
                               par_user in varchar2) return varchar2;
   function create_extract(par_extract_type in varchar2,
                           par_extract_identifier in varchar2,
                           par_extract_description in varchar2,
                           par_extract_version in number,
                           par_load_identifier in varchar2,
                           par_user in varchar2) return varchar2;
   function report_load(par_extract_identifier in varchar2) return dw_fcst_table pipelined;
   function report_extract(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

end dw_fcst_maintenance;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_maintenance as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_wrkr number;

   /*-*/
   /* Private declarations
   /*-*/
   procedure validate_load(par_load_identifier in varchar2);
   procedure read_xml_stream(par_type_version in varchar2,
                             par_data_type in varchar2,
                             par_data_version in number,
                             par_data_range in number,
                             par_stream in clob);
   procedure read_xml_child(par_type_version in varchar2,
                            par_data_type in varchar2,
                            par_data_version in number,
                            par_data_range in number,
                            par_xml_node in xmlDom.domNode);

   /***************************************************/
   /* This procedure performs the delete load routine */
   /***************************************************/
   procedure delete_load(par_load_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_load_identifier fcst_load_header.load_identifier%type;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = var_load_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_extract_load is 
         select t01.*
           from fcst_extract_load t01
          where t01.load_identifier = var_load_identifier;
      rcd_fcst_extract_load csr_fcst_extract_load%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_load_identifier := upper(par_load_identifier);
      if var_load_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;

      /*-*/
      /* Attempt to lock the forecast load header row
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_fcst_load_header;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_fcst_load_header%isopen then
         close csr_fcst_load_header;
      end if;

      /*-*/
      /* Release the header lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then
         raise_application_error(-20000, 'Forecast load (' || var_load_identifier || ') does not exist or is already locked');
      end if;

      /*-*/
      /* Check the load usage
      /*-*/
      open csr_fcst_extract_load;
      fetch csr_fcst_extract_load into rcd_fcst_extract_load;
      if csr_fcst_extract_load%found then
         raise_application_error(-20000, 'Forecast load (' || var_load_identifier || ') is currently attached to one or more forecast extracts');
      end if;
      close csr_fcst_extract_load;

      /*-*/
      /* Delete the forecast load detail
      /*-*/
      delete from fcst_load_detail
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Delete the forecast load header
      /*-*/
      delete from fcst_load_header
       where load_identifier = rcd_fcst_load_header.load_identifier;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - DELETE_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_load;

   /******************************************************/
   /* This procedure performs the delete extract routine */
   /******************************************************/
   procedure delete_extract(par_extract_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_header is 
         select t01.*
           from fcst_extract_header t01
          where t01.extract_identifier = var_extract_identifier
            for update nowait;
      rcd_fcst_extract_header csr_fcst_extract_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_extract_identifier := upper(par_extract_identifier);
      if var_extract_identifier is null then
         raise_application_error(-20000, 'Forecast extract identifier must be specified');
      end if;

      /*-*/
      /* Attempt to lock the forecast extract header row
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
         close csr_fcst_extract_header;
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
      /* Delete the forecast extract load
      /*-*/
      delete from fcst_extract_load
       where extract_identifier = rcd_fcst_extract_header.extract_identifier;

      /*-*/
      /* Delete the forecast extract header
      /*-*/
      delete from fcst_extract_header
       where extract_identifier = rcd_fcst_extract_header.extract_identifier;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - DELETE_EXTRACT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_extract;

   /**********************************************************/
   /* This procedure performs the create apollo load routine */
   /**********************************************************/
   procedure create_apollo_load(par_cast_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_load_header fcst_load_header%rowtype;
      rcd_fcst_load_detail fcst_load_detail%rowtype;
      var_work_yyyyppw number;
      var_work_yyyypp number;
      var_work_count number;
      var_work_qty number;
      var_work_date date;
      var_cast_date date;
      var_load_data_version rcd_fcst_load_header.load_data_version%type;
      var_load_data_range rcd_fcst_load_header.load_data_range%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t01.mars_period,
                t01.mars_week
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(var_work_date);
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_fcst_data is
         select t01.*,
                nvl(t02.mars_period,999999) as mars_yyyypp,
                nvl(t02.mars_week,9999999) as mars_yyyyppw
           from fcst_data t01,
                mars_date t02
          where to_date(t01.fcst_yyyymmdd,'yyyymmdd') = t02.calendar_date(+)
          order by t01.material_code asc,
                   t01.dmnd_group asc,
                   t01.plant_code asc,
                   t01.fcst_yyyymmdd asc;
      rcd_fcst_data csr_fcst_data%rowtype;

      cursor csr_mars_week is
         select t01.mars_period,
                t01.mars_week
           from mars_date t01
          where mars_week > var_work_yyyyppw
          order by mars_week asc;
      rcd_mars_week csr_mars_week%rowtype;

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
      if par_cast_date is null then
         raise_application_error(-20000, 'Casting date parameter must be supplied');
      end if;
      /*-*/
      begin
         var_cast_date := to_date(par_cast_date,'yyyymmdd');
      exception
         when others then
            raise_application_error(-20000, 'Casting date parameter (' || par_cast_date || ') - unable to convert to date format YYYYMMDD');
      end;

      /*-*/
      /* Retrieve the period and week information
      /*-*/
      var_work_date := var_cast_date;
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Casting date (' || to_char(var_cast_date,'yyyy/mm/dd') || ') does not exist in Mars Date Table');
      end if;
      close csr_mars_date;
      var_load_data_version := rcd_mars_date.mars_period;
      if substr(to_char(var_load_data_version,'fm000000'),5,2) = '13' then
         var_load_data_version := var_load_data_version + 88;
      else
         var_load_data_version := var_load_data_version + 1;
      end if;

      /*-*/
      /* Initialise the forecast load header
      /*-*/
      rcd_fcst_load_header.load_identifier := 'FCST_APOLLO_DOMESTIC_'||par_cast_date;
      rcd_fcst_load_header.load_description := 'Apollo Domestic Forecasts';
      rcd_fcst_load_header.load_status := '*NONE';
      rcd_fcst_load_header.load_type := '*FCST_DOMESTIC';
      rcd_fcst_load_header.load_data_type := '*QTY_ONLY';
      rcd_fcst_load_header.load_data_version := var_load_data_version;
      rcd_fcst_load_header.load_data_range := 0;
      rcd_fcst_load_header.load_str_yyyypp := 999999;
      rcd_fcst_load_header.load_end_yyyypp := 0;
      rcd_fcst_load_header.sales_org_code := '135';
      rcd_fcst_load_header.distbn_chnl_code := '10';
      rcd_fcst_load_header.division_code := '51';
      rcd_fcst_load_header.crt_user := user;
      rcd_fcst_load_header.crt_date := sysdate;
      rcd_fcst_load_header.upd_user := user;
      rcd_fcst_load_header.upd_date := sysdate;

      /*-*/
      /* Delete the existing forecast load
      /*-*/
      delete from fcst_load_detail where load_identifier = rcd_fcst_load_header.load_identifier;
      delete from fcst_load_header where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Insert the forecast load header
      /*-*/
      insert into fcst_load_header
         (load_identifier,
          load_description,
          load_status,
          load_type,
          load_data_type,
          load_data_version,
          load_data_range,
          load_str_yyyypp,
          load_end_yyyypp,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          crt_user,
          crt_date,
          upd_user,
          upd_date)
         values(rcd_fcst_load_header.load_identifier,
                rcd_fcst_load_header.load_description,
                rcd_fcst_load_header.load_status,
                rcd_fcst_load_header.load_type,
                rcd_fcst_load_header.load_data_type,
                rcd_fcst_load_header.load_data_version,
                rcd_fcst_load_header.load_data_range,
                rcd_fcst_load_header.load_str_yyyypp,
                rcd_fcst_load_header.load_end_yyyypp,
                rcd_fcst_load_header.sales_org_code,
                rcd_fcst_load_header.distbn_chnl_code,
                rcd_fcst_load_header.division_code,
                rcd_fcst_load_header.crt_user,
                rcd_fcst_load_header.crt_date,
                rcd_fcst_load_header.upd_user,
                rcd_fcst_load_header.upd_date);

      /*-*/
      /* Retrieve the forecast data
      /*-*/
      rcd_fcst_load_detail.load_identifier := rcd_fcst_load_header.load_identifier;
      rcd_fcst_load_detail.load_sequence := 0;
      open csr_fcst_data;
      loop
         fetch csr_fcst_data into rcd_fcst_data;
         if csr_fcst_data%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the forecast load detail
         /*-*/
         rcd_fcst_load_detail.material_code := rcd_fcst_data.material_code;
         rcd_fcst_load_detail.dmnd_group := rcd_fcst_data.dmnd_group;
         rcd_fcst_load_detail.plant_code := rcd_fcst_data.plant_code;
         rcd_fcst_load_detail.cover_yyyymmdd := rcd_fcst_data.fcst_yyyymmdd;
         rcd_fcst_load_detail.cover_day := rcd_fcst_data.fcst_cover;
         rcd_fcst_load_detail.cover_qty := rcd_fcst_data.fcst_qty;
         rcd_fcst_load_detail.fcst_yyyyppw := 0;
         rcd_fcst_load_detail.fcst_yyyypp := 0;
         rcd_fcst_load_detail.fcst_qty := 0;
         rcd_fcst_load_detail.fcst_prc := 0;
         rcd_fcst_load_detail.fcst_gsv := 0;
         rcd_fcst_load_detail.plan_group := '*NONE';
         rcd_fcst_load_detail.mesg_text := null;

         /*-*/
         /* Process the weeks covered by the forecast
         /*-*/
         var_work_yyyyppw := rcd_fcst_data.mars_yyyyppw;
         var_work_yyyypp := rcd_fcst_data.mars_yyyypp;
         var_work_count := round(rcd_fcst_load_detail.cover_day/7,0);
         var_work_qty := rcd_fcst_load_detail.cover_qty / var_work_count;
         for idx in 1..var_work_count loop

            /*-*/
            /* Update the header forecast range
            /*-*/
            if var_work_yyyypp < rcd_fcst_load_header.load_str_yyyypp then
               rcd_fcst_load_header.load_str_yyyypp := var_work_yyyypp;
            end if;
            if var_work_yyyypp > rcd_fcst_load_header.load_end_yyyypp then
               rcd_fcst_load_header.load_end_yyyypp := var_work_yyyypp;
            end if;

            /*-*/
            /* Insert the forecast load detail
            /*-*/
            rcd_fcst_load_detail.load_sequence := rcd_fcst_load_detail.load_sequence + 1;
            rcd_fcst_load_detail.fcst_yyyyppw := var_work_yyyyppw;
            rcd_fcst_load_detail.fcst_yyyypp := var_work_yyyypp;
            rcd_fcst_load_detail.fcst_qty := var_work_qty;
            insert into fcst_load_detail
               (load_identifier,
                load_sequence,
                material_code,
                dmnd_group,
                plant_code,
                cover_yyyymmdd,
                cover_day,
                cover_qty,
                fcst_yyyyppw,
                fcst_yyyypp,
                fcst_qty,
                fcst_prc,
                fcst_gsv,
                plan_group,
                mesg_text)
               values (rcd_fcst_load_detail.load_identifier,
                       rcd_fcst_load_detail.load_sequence,
                       rcd_fcst_load_detail.material_code,
                       rcd_fcst_load_detail.dmnd_group,
                       rcd_fcst_load_detail.plant_code,
                       rcd_fcst_load_detail.cover_yyyymmdd,
                       rcd_fcst_load_detail.cover_day,
                       rcd_fcst_load_detail.cover_qty,
                       rcd_fcst_load_detail.fcst_yyyyppw,
                       rcd_fcst_load_detail.fcst_yyyypp,
                       rcd_fcst_load_detail.fcst_qty,
                       rcd_fcst_load_detail.fcst_prc,
                       rcd_fcst_load_detail.fcst_gsv,
                       rcd_fcst_load_detail.plan_group,
                       rcd_fcst_load_detail.mesg_text);

            /*-*/
            /* Retrieve the next mars week/period when required
            /*-*/
            if idx < var_work_count then
               open csr_mars_week;
               fetch csr_mars_week into rcd_mars_week;
               if csr_mars_week%notfound then
                  raise_application_error(-20000, 'Next week (' || to_char(var_work_yyyyppw,'fm0000000') || ') does not exist in Mars Date Table');
               end if;
               close csr_mars_week;
               var_work_yyyyppw := rcd_mars_week.mars_week;
               var_work_yyyypp := rcd_mars_week.mars_period;
            end if;

         end loop;

      end loop;
      close csr_fcst_data;

      /*-*/
      /* Calculate the load data range
      /*-*/
      var_work_yyyypp := rcd_fcst_load_header.load_str_yyyypp;
      loop
         if var_work_yyyypp > rcd_fcst_load_header.load_end_yyyypp then
            exit;
         end if;
         rcd_fcst_load_header.load_data_range := rcd_fcst_load_header.load_data_range + 1;
         if substr(to_char(var_work_yyyypp,'fm000000'),5,2) = '13' then
            var_work_yyyypp := var_work_yyyypp + 88;
         else
            var_work_yyyypp := var_work_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set load_data_range = rcd_fcst_load_header.load_data_range,
             load_str_yyyypp = rcd_fcst_load_header.load_str_yyyypp,
             load_end_yyyypp = rcd_fcst_load_header.load_end_yyyypp
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Validate the forecast load
      /*-*/
      validate_load(rcd_fcst_load_header.load_identifier);

      /*-*/
      /* Delete the temporary forecast data
      /*-*/
      delete from fcst_data;

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
         raise_application_error(-20000, 'DW_FORECAST_LOADING - CREATE_APOLLO_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_apollo_load;

   /**********************************************************/
   /* This procedure performs the create stream load routine */
   /**********************************************************/
   function create_stream_load(par_load_type in varchar2,
                               par_load_identifier in varchar2,
                               par_load_description in varchar2,
                               par_load_data_type in varchar2,
                               par_load_data_version in number,
                               par_load_data_range in number,
                               par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_load_header fcst_load_header%rowtype;
      rcd_fcst_load_detail fcst_load_detail%rowtype;
      var_load_type fcst_load_header.load_type%type;
      var_load_identifier fcst_load_header.load_identifier%type;
      var_load_description fcst_load_header.load_description%type;
      var_load_data_type fcst_load_header.load_data_type%type;
      var_load_data_version fcst_load_header.load_data_version%type;
      var_load_data_range fcst_load_header.load_data_range%type;
      var_user fcst_load_header.crt_user%type;
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_type is 
         select t01.*
           from fcst_load_type t01
          where t01.load_type = var_load_type;
      rcd_fcst_load_type csr_fcst_load_type%rowtype;

      cursor csr_mars_period is
         select t01.*
           from mars_date t01
          where mars_period = var_load_data_version;
      rcd_mars_period csr_mars_period%rowtype;

      cursor csr_mars_year is
         select t01.*
           from mars_date t01
          where mars_year = var_load_data_version;
      rcd_mars_year csr_mars_year%rowtype;

      cursor csr_fcst_data is
         select t01.*,
                nvl(t02.mars_yyyymmdd,'99999999') as mars_yyyymmdd,
                nvl(t02.mars_yyyyppw,9999999) as mars_yyyyppw,
                nvl(t02.mars_cover,0) as mars_cover
           from fcst_data t01,
                (select t01.mars_period,
                        min(to_char(t01.calendar_date,'yyyymmdd')) as mars_yyyymmdd,
                        min(t01.mars_week) as mars_yyyyppw,
                        max(period_day_num) as mars_cover
                   from mars_date t01
                  group by t01.mars_period) t02
          where t01.fcst_yyyypp = t02.mars_period(+)
          order by t01.material_code asc,
                   t01.dmnd_group asc,
                   t01.plant_code asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_data csr_fcst_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Forecast Loading - Create Forecast Load';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_load_type := upper(par_load_type);
      var_load_identifier := upper(par_load_identifier);
      var_load_description := par_load_description;
      var_load_data_type := par_load_data_type;
      var_load_data_version := par_load_data_version;
      var_load_data_range := par_load_data_range;
      var_user := upper(par_user);
      if var_load_type is null then
         var_message := var_message || chr(13) || 'Forecast load type must be specified';
      end if;
      if var_load_identifier is null then
         var_message := var_message || chr(13) || 'Forecast load identifier must be specified';
      end if;
      if var_load_description is null then
         var_message := var_message || chr(13) || 'Forecast load description must be specified';
      end if;
      if var_load_data_type is null then
         var_message := var_message || chr(13) || 'Forecast load data type must be specified';
      end if;
      if var_load_data_version is null then
         var_message := var_message || chr(13) || 'Forecast load data version must be specified';
      end if;
      if var_load_data_range is null then
         var_message := var_message || chr(13) || 'Forecast load data range must be specified';
      end if;
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Validate the load type
      /*-*/
      open csr_fcst_load_type;
      fetch csr_fcst_load_type into rcd_fcst_load_type;
      if csr_fcst_load_type%notfound then
         var_message := var_message || chr(13) || 'Forecast load type (' || var_load_type || ') does not exist';
      end if;
      close csr_fcst_load_type;

      /*-*/
      /* Retrieve the load data version
      /*-*/
      if rcd_fcst_load_type.load_type_version = '*PERIOD' then
         open csr_mars_period;
         fetch csr_mars_period into rcd_mars_period;
         if csr_mars_period%notfound then
            var_message := var_message || chr(13) || 'Forecast load data version (' || to_char(var_load_data_version) || ') does not exist as a Mars period in Mars Date Table';
         end if;
         close csr_mars_period;
      elsif rcd_fcst_load_type.load_type_version = '*YEAR' then
         open csr_mars_year;
         fetch csr_mars_year into rcd_mars_year;
         if csr_mars_year%notfound then
            var_message := var_message || chr(13) || 'Forecast load data version (' || to_char(var_load_data_version) || ') does not exist as a Mars year in Mars Date Table';
         end if;
         close csr_mars_year;
      else
         var_message := var_message || chr(13) || 'Forecast load type version (' || rcd_fcst_load_type.load_type_version || ') is not recognised';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Retrieve the stream data
      /*-*/
      read_xml_stream(rcd_fcst_load_type.load_type_version,var_load_data_type,var_load_data_version,var_load_data_range,lics_form.get_clob('LOAD_STREAM'));

      /*-*/
      /* Initialise the forecast load header
      /*-*/
      rcd_fcst_load_header.load_identifier := var_load_identifier;
      rcd_fcst_load_header.load_description := var_load_description;
      rcd_fcst_load_header.load_status := '*NONE';
      rcd_fcst_load_header.load_type := var_load_type;
      rcd_fcst_load_header.load_data_type := var_load_data_type;
      rcd_fcst_load_header.load_data_version := var_load_data_version;
      rcd_fcst_load_header.load_data_range := var_load_data_range;
      rcd_fcst_load_header.load_str_yyyypp := 999999;
      rcd_fcst_load_header.load_end_yyyypp := 0;
      rcd_fcst_load_header.sales_org_code := '135';
      rcd_fcst_load_header.distbn_chnl_code := '10';
      rcd_fcst_load_header.division_code := '51';
      rcd_fcst_load_header.crt_user := var_user;
      rcd_fcst_load_header.crt_date := sysdate;
      rcd_fcst_load_header.upd_user := var_user;
      rcd_fcst_load_header.upd_date := sysdate;

      /*-*/
      /* Insert the forecast load header
      /*-*/
      begin
         insert into fcst_load_header
            (load_identifier,
             load_description,
             load_status,
             load_type,
             load_data_type,
             load_data_version,
             load_data_range,
             load_str_yyyypp,
             load_end_yyyypp,
             sales_org_code,
             distbn_chnl_code,
             division_code,
             crt_user,
             crt_date,
             upd_user,
             upd_date)
            values(rcd_fcst_load_header.load_identifier,
                   rcd_fcst_load_header.load_description,
                   rcd_fcst_load_header.load_status,
                   rcd_fcst_load_header.load_type,
                   rcd_fcst_load_header.load_data_type,
                   rcd_fcst_load_header.load_data_version,
                   rcd_fcst_load_header.load_data_range,
                   rcd_fcst_load_header.load_str_yyyypp,
                   rcd_fcst_load_header.load_end_yyyypp,
                   rcd_fcst_load_header.sales_org_code,
                   rcd_fcst_load_header.distbn_chnl_code,
                   rcd_fcst_load_header.division_code,
                   rcd_fcst_load_header.crt_user,
                   rcd_fcst_load_header.crt_date,
                   rcd_fcst_load_header.upd_user,
                   rcd_fcst_load_header.upd_date);
      exception
         when dup_val_on_index then
            var_message := var_message || chr(13) || 'Forecast load identifier (' || var_load_identifier || ') already exists';
      end;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Retrieve the forecast data
      /*-*/
      rcd_fcst_load_detail.load_identifier := rcd_fcst_load_header.load_identifier;
      rcd_fcst_load_detail.load_sequence := 0;
      open csr_fcst_data;
      loop
         fetch csr_fcst_data into rcd_fcst_data;
         if csr_fcst_data%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the forecast load detail
         /*-*/
         rcd_fcst_load_detail.load_sequence := rcd_fcst_load_detail.load_sequence + 1;
         rcd_fcst_load_detail.material_code := rcd_fcst_data.material_code;
         rcd_fcst_load_detail.dmnd_group := rcd_fcst_data.dmnd_group;
         rcd_fcst_load_detail.plant_code := rcd_fcst_data.plant_code;
         rcd_fcst_load_detail.cover_yyyymmdd := rcd_fcst_data.mars_yyyymmdd;
         rcd_fcst_load_detail.cover_day := rcd_fcst_data.mars_cover;
         rcd_fcst_load_detail.cover_qty := rcd_fcst_data.fcst_qty;
         rcd_fcst_load_detail.fcst_yyyyppw := rcd_fcst_data.mars_yyyyppw;
         rcd_fcst_load_detail.fcst_yyyypp := rcd_fcst_data.fcst_yyyypp;
         rcd_fcst_load_detail.fcst_qty := rcd_fcst_data.fcst_qty;
         rcd_fcst_load_detail.fcst_prc := rcd_fcst_data.fcst_prc;
         rcd_fcst_load_detail.fcst_gsv := rcd_fcst_data.fcst_gsv;
         rcd_fcst_load_detail.plan_group := '*NONE';
         rcd_fcst_load_detail.mesg_text := null;

         /*-*/
         /* Insert the forecast load detail
         /*-*/
         insert into fcst_load_detail
            (load_identifier,
             load_sequence,
             material_code,
             dmnd_group,
             plant_code,
             cover_yyyymmdd,
             cover_day,
             cover_qty,
             fcst_yyyyppw,
             fcst_yyyypp,
             fcst_qty,
             fcst_prc,
             fcst_gsv,
             plan_group,
             mesg_text)
            values (rcd_fcst_load_detail.load_identifier,
                    rcd_fcst_load_detail.load_sequence,
                    rcd_fcst_load_detail.material_code,
                    rcd_fcst_load_detail.dmnd_group,
                    rcd_fcst_load_detail.plant_code,
                    rcd_fcst_load_detail.cover_yyyymmdd,
                    rcd_fcst_load_detail.cover_day,
                    rcd_fcst_load_detail.cover_qty,
                    rcd_fcst_load_detail.fcst_yyyyppw,
                    rcd_fcst_load_detail.fcst_yyyypp,
                    rcd_fcst_load_detail.fcst_qty,
                    rcd_fcst_load_detail.fcst_prc,
                    rcd_fcst_load_detail.fcst_gsv,
                    rcd_fcst_load_detail.plan_group,
                    rcd_fcst_load_detail.mesg_text);

         /*-*/
         /* Update the header forecast range
         /*-*/
         if rcd_fcst_load_detail.fcst_yyyypp < rcd_fcst_load_header.load_str_yyyypp then
            rcd_fcst_load_header.load_str_yyyypp := rcd_fcst_load_detail.fcst_yyyypp;
         end if;
         if rcd_fcst_load_detail.fcst_yyyypp > rcd_fcst_load_header.load_end_yyyypp then
            rcd_fcst_load_header.load_end_yyyypp := rcd_fcst_load_detail.fcst_yyyypp;
         end if;

      end loop;
      close csr_fcst_data;

      /*-*/
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set load_str_yyyypp = rcd_fcst_load_header.load_str_yyyypp,
             load_end_yyyypp = rcd_fcst_load_header.load_end_yyyypp
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Validate the forecast load
      /*-*/
      validate_load(rcd_fcst_load_header.load_identifier);

      /*-*/
      /* Delete the temporary forecast data
      /*-*/
      delete from fcst_data;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_stream_load;

   /******************************************************/
   /* This procedure performs the create extract routine */
   /******************************************************/
   function create_extract(par_extract_type in varchar2,
                           par_extract_identifier in varchar2,
                           par_extract_description in varchar2,
                           par_extract_version in number,
                           par_load_identifier in varchar2,
                           par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_extract_header fcst_extract_header%rowtype;
      rcd_fcst_extract_load fcst_extract_load%rowtype;
      var_extract_type fcst_extract_header.extract_type%type;
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_extract_description fcst_extract_header.extract_description%type;
      var_extract_version fcst_extract_header.extract_version%type;
      var_load_identifier fcst_load_header.load_identifier%type;
      var_work_identifier fcst_load_header.load_identifier%type;
      var_user fcst_load_header.crt_user%type;
      var_title varchar2(128);
      var_message varchar2(4000);
      var_found boolean;
      var_value varchar2(256);
      type rcd_load is record(load_identifier varchar2(256));
      type typ_load is table of rcd_load index by binary_integer;
      tbl_load typ_load;
      type rcd_extract is record(load_type varchar2(32), select_count number);
      type typ_extract is table of rcd_extract index by binary_integer;
      tbl_extract typ_extract;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_type is 
         select t01.*
           from fcst_extract_type t01
          where t01.extract_type = var_extract_type;
      rcd_fcst_extract_type csr_fcst_extract_type%rowtype;

      cursor csr_fcst_extract_type_load is 
         select t01.*
           from fcst_extract_type_load t01
          where t01.extract_type = rcd_fcst_extract_type.extract_type;
      rcd_fcst_extract_type_load csr_fcst_extract_type_load%rowtype;

      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = var_work_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Forecast Loading - Create Forecast Extract';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_extract_type := upper(par_extract_type);
      var_extract_identifier := upper(par_extract_identifier);
      var_extract_description := par_extract_description;
      var_extract_version := par_extract_version;
      var_load_identifier := upper(par_load_identifier);
      var_user := upper(par_user);
      if var_extract_type is null then
         var_message := var_message || chr(13) || 'Forecast extract type must be specified';
      end if;
      if var_extract_identifier is null then
         var_message := var_message || chr(13) || 'Forecast extract identifier must be specified';
      end if;
      if var_extract_description is null then
         var_message := var_message || chr(13) || 'Forecast extract description must be specified';
      end if;
      if var_extract_version is null then
         var_message := var_message || chr(13) || 'Forecast extract version must be specified';
      end if;
      if var_load_identifier is null then
         var_message := var_message || chr(13) || 'Forecast load identifier(s) must be specified';
      end if;
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Extract the load identifiers
      /*-*/
      tbl_load.delete;
      var_value := null;
      for idx in 1..length(var_load_identifier) loop
         if substr(var_load_identifier,idx,1) = ',' then
            if not(var_value is null) then
               tbl_load(tbl_load.count+1).load_identifier := var_value;
            end if;
            var_value := null;
         else
            var_value := var_value||substr(var_load_identifier,idx,1);
         end if;
      end loop;
      if not(var_value is null) then
         tbl_load(tbl_load.count+1).load_identifier := var_value;
      end if;

      /*-*/
      /* Validate the extract type
      /*-*/
      open csr_fcst_extract_type;
      fetch csr_fcst_extract_type into rcd_fcst_extract_type;
      if csr_fcst_extract_type%notfound then
         var_message := var_message || chr(13) || 'Forecast extract type (' || var_extract_type || ') does not exist';
      end if;
      close csr_fcst_extract_type;

      /*-*/
      /* Extract the extract type load types
      /*-*/
      tbl_extract.delete;
      open csr_fcst_extract_type_load;
      loop
         fetch csr_fcst_extract_type_load into rcd_fcst_extract_type_load;
         if csr_fcst_extract_type_load%notfound then
            exit;
         end if;
         tbl_extract(tbl_extract.count+1).load_type := rcd_fcst_extract_type_load.load_type;
         tbl_extract(tbl_extract.count).select_count := 0;
      end loop;

      /*-*/
      /* Validate the load identifiers
      /*-*/
      for idx in 1..tbl_load.count loop

         /*-*/
         /* Forecast load must exist
         /*-*/
         var_work_identifier := tbl_load(idx).load_identifier;
         open csr_fcst_load_header;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            var_message := var_message || chr(13) || 'Forecast load (' || var_work_identifier || ') does not exist';
         end if;
         close csr_fcst_load_header;

         /*-*/
         /* Forecast load type must match the extract load types
         /*-*/
         var_found := false;
         for idy in 1..tbl_extract.count loop
            if tbl_extract(idy).load_type = rcd_fcst_load_header.load_type then
               tbl_extract(idy).select_count := tbl_extract(idy).select_count + 1;
               var_found := true;
            end if;
         end loop;
         if var_found = false then
            var_message := var_message || chr(13) || 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') type (' || rcd_fcst_load_header.load_type || ') does not exist in extract load types';
         end if;

         /*-*/
         /* Forecast load must be *VALID
         /*-*/
     --    if rcd_fcst_load_header.load_status != '*VALID' then
     --       var_message := var_message || chr(13) || 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') must be *VALID status';
     --    end if;

         /*-*/
         /* Forecast load version must match the extract version
         /*-*/
         if rcd_fcst_load_header.load_data_version != var_extract_version then
            var_message := var_message || chr(13) || 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') version (' || to_char(rcd_fcst_load_header.load_data_version) || ') does not match the extract version';
         end if;

      end loop;

      /*-*/
      /* Forecast extract load types must be selected
      /*-*/
   --   for idx in 1..tbl_extract.count loop
   --      if tbl_extract(idx).select_count = 0 then
   --         var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has no forecast load selected';
   --      end if;
   --      if tbl_extract(idx).select_count > 1 then
   --         var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has more than one forecast load specified';
   --      end if;
   --   end loop;

      /*-*/
      /* Initialise the forecast extract header
      /*-*/
      rcd_fcst_extract_header.extract_identifier := var_extract_identifier;
      rcd_fcst_extract_header.extract_description := var_extract_description;
      rcd_fcst_extract_header.extract_type := var_extract_type;
      rcd_fcst_extract_header.extract_version := var_extract_version;
      rcd_fcst_extract_header.crt_user := var_user;
      rcd_fcst_extract_header.crt_date := sysdate;

      /*-*/
      /* Insert the forecast extract header
      /*-*/
      begin
         insert into fcst_extract_header
            (extract_identifier,
             extract_description,
             extract_type,
             extract_version,
             crt_user,
             crt_date)
            values(rcd_fcst_extract_header.extract_identifier,
                   rcd_fcst_extract_header.extract_description,
                   rcd_fcst_extract_header.extract_type,
                   rcd_fcst_extract_header.extract_version,
                   rcd_fcst_extract_header.crt_user,
                   rcd_fcst_extract_header.crt_date);
      exception
         when dup_val_on_index then
            var_message := var_message || chr(13) || 'Forecast extract identifier (' || var_extract_identifier || ') already exists';
      end;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Insert the forecast extract loads
      /*-*/
      rcd_fcst_extract_load.extract_identifier := rcd_fcst_extract_header.extract_identifier;
      for idx in 1..tbl_load.count loop
         rcd_fcst_extract_load.load_identifier := tbl_load(idx).load_identifier;
         insert into fcst_extract_load
            (extract_identifier,
             load_identifier)
         values(rcd_fcst_extract_load.extract_identifier,
                rcd_fcst_extract_load.load_identifier);
      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_extract;

   /***************************************************/
   /* This procedure performs the report load routine */
   /***************************************************/
   function report_load(par_extract_identifier in varchar2) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_output varchar2(4000 char);
      type typ_select is table of varchar2(32) index by binary_integer;
      tbl_select typ_select;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_header is 
         select t01.*,
                t02.extract_plan_group
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
         select t01.*
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
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
      /* Retrieve the extract header
      /*-*/
      open csr_fcst_extract_header;
      fetch csr_fcst_extract_header into rcd_fcst_extract_header;
      if csr_fcst_extract_header%notfound then
         raise_application_error(-20000, 'Forecast extract (' || var_extract_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '<table border=1 cellpadding="0" cellspacing="0">';
      var_output := var_output || '<tr>';
    --  var_output := var_output || '<td align=center colspan=9 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Monthly Invoice Data / '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_str_date,'yyyymmdd'),'yyyy.mm.dd')||' - '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_end_date,'yyyymmdd'),'yyyy.mm.dd')||' / xxxxxxxxxxxxxxxxxx</td>'
      pipe row(var_output);

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
            var_output := var_output || 'xxxxxxxxxxxxxxxxxxxxxxxxx';
            pipe row(var_output);

         end loop;
         close csr_fcst_load_detail;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* End the report
      /*-*/
      var_output := '</table>';
      pipe row(var_output);

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
         raise_application_error(-20000, 'DW_FORECAST_LOADING - REPORT_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_load;

   /******************************************************/
   /* This procedure performs the report extract routine */
   /******************************************************/
   function report_extract(par_extract_identifier in varchar2) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_output varchar2(4000 char);
      type typ_select is table of varchar2(32) index by binary_integer;
      tbl_select typ_select;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_header is 
         select t01.*,
                t02.extract_plan_group
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
         select t01.*
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
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
      /* Retrieve the extract header
      /*-*/
      open csr_fcst_extract_header;
      fetch csr_fcst_extract_header into rcd_fcst_extract_header;
      if csr_fcst_extract_header%notfound then
         raise_application_error(-20000, 'Forecast extract (' || var_extract_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '<table border=1 cellpadding="0" cellspacing="0">';
      var_output := var_output || '<tr>';
    --  var_output := var_output || '<td align=center colspan=9 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Monthly Invoice Data / '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_str_date,'yyyymmdd'),'yyyy.mm.dd')||' - '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_end_date,'yyyymmdd'),'yyyy.mm.dd')||' / xxxxxxxxxxxxxxxxxx</td>'
      pipe row(var_output);

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
            var_output := var_output || 'xxxxxxxxxxxxxxxxxxxxxxxxx';
            pipe row(var_output);

         end loop;
         close csr_fcst_load_detail;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* End the report
      /*-*/
      var_output := '</table>';
      pipe row(var_output);

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
         raise_application_error(-20000, 'DW_FORECAST_LOADING - REPORT_EXTRACT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_extract;

   /*****************************************************/
   /* This procedure performs the validate load routine */
   /*****************************************************/
   procedure validate_load(par_load_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_errors boolean;
      var_material_save varchar2(18 char);
      var_wrk_yyyypp number;
      type rcd_wrkv is record(yyyypp number, price number);
      type tab_wrkv is table of rcd_wrkv index by binary_integer;
      tbl_wrkn tab_wrkv;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = par_load_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is
         select t01.*,
                t02.matl_code,
                t02.matl_status,
                decode(t02.bus_sgmnt_code,'01','*SNACK','05','*PET','*NONE') as new_plan_group
           from fcst_load_detail t01,
                (select lads_trim_code(t01.matnr) as matl_code,
                        decode(t01.lvorm,'X','INACTIVE','ACTIVE') as matl_status,
                        t02.atwrt as bus_sgmnt_code
                   from lads_mat_hdr t01,
                        lads_cla_chr t02
                  where t01.matnr = t02.objek(+)
                    and t02.obtab(+) = 'MARA'
                    and t02.klart(+) = '001'
                    and t02.atnam(+) = 'CLFFERT01') t02
          where t01.material_code = t02.matl_code(+)
            and t01.load_identifier = rcd_fcst_load_header.load_identifier
          order by t01.material_code asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

      cursor csr_material_price is
         select t04.mars_period as str_yyyypp,
                nvl(t05.mars_period,999999) as end_yyyypp,
                ((t02.kbetr/t02.kpein)*nvl(t03.umren,1))/nvl(t03.umrez,1) as material_price 
           from lads_mat_hdr t01,
                (select t01.matnr,
                        lads_to_date(t01.datab,'yyyymmdd') datab,
                        lads_to_date(t01.datbi,'yyyymmdd') datbi,
                        t02.kmein,
                        nvl(t02.kbetr,0) kbetr,
                        nvl(t02.kpein,1) kpein
                   from lads_prc_lst_hdr t01,
                        lads_prc_lst_det t02
                  where t01.vakey = t02.vakey
                    and t01.kschl = t02.kschl
                    and t01.datab = t02.datab
                    and t01.knumh = t02.knumh
                    and t01.vkorg = rcd_fcst_load_header.sales_org_code
                    and t01.vtweg is null
                    and t01.kschl = 'PR00') t02,
                lads_mat_uom t03,
                mars_date t04,
                mars_date t05
          where t01.matnr = t02.matnr
            and t02.matnr = t03.matnr(+)
            and t02.kmein = t03.meinh(+)
            and t02.datab = t04.calendar_date
            and t02.datbi = t05.calendar_date(+)
            and lads_trim_code(t01.matnr) = rcd_fcst_load_detail.material_code
            and (t04.mars_period <= rcd_fcst_load_header.load_str_yyyypp or
                 (t05.mars_period is null or t05.mars_period >= rcd_fcst_load_header.load_end_yyyypp));
      rcd_material_price csr_material_price%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the forecast header row
      /*-*/
      open csr_fcst_load_header;
      fetch csr_fcst_load_header into rcd_fcst_load_header;
      if csr_fcst_load_header%notfound then
         raise_application_error(-20000, 'Forecast load (' || par_load_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Load the forecast period array
      /*-*/
      tbl_wrkn.delete;
      var_wrk_yyyypp := rcd_fcst_load_header.load_str_yyyypp;
      loop
         if var_wrk_yyyypp > rcd_fcst_load_header.load_end_yyyypp then
            exit;
         end if;
         tbl_wrkn(tbl_wrkn.count+1).yyyypp := var_wrk_yyyypp;
         tbl_wrkn(tbl_wrkn.count).price := 0;
         if substr(to_char(var_wrk_yyyypp,'fm000000'),5,2) = '13' then
            var_wrk_yyyypp := var_wrk_yyyypp + 88;
         else
            var_wrk_yyyypp := var_wrk_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Reset the error indicator
      /*-*/
      var_errors := false;

      /*-*/
      /* Retrieve the forecast load details
      /*-*/
      var_material_save := '*NONE';
      open csr_fcst_load_detail;
      loop
         fetch csr_fcst_load_detail into rcd_fcst_load_detail;
         if csr_fcst_load_detail%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the material price data when required
         /*-*/
         if rcd_fcst_load_header.load_data_type = '*QTY_ONLY' then
            if rcd_fcst_load_detail.material_code != var_material_save then
               for idx in 1..tbl_wrkn.count loop
                  tbl_wrkn(idx).price := 0;
	       end loop;
               open csr_material_price;
               loop
                  fetch csr_material_price into rcd_material_price;
                  if csr_material_price%notfound then
                     exit;
                  end if;
                  for idx in 1..tbl_wrkn.count loop
                     if rcd_material_price.str_yyyypp <= tbl_wrkn(idx).yyyypp and
                        rcd_material_price.end_yyyypp >= tbl_wrkn(idx).yyyypp then
                        tbl_wrkn(idx).price := rcd_material_price.material_price;
                     end if;
                  end loop;
               end loop;
               close csr_material_price;
               var_material_save := rcd_fcst_load_detail.material_code;
            end if;
         end if;

         /*-*/
         /* Retrieve the detail price and calculate the gsv for *QTY_ONLY
         /*-*/
         if rcd_fcst_load_header.load_data_type = '*QTY_ONLY' then
            rcd_fcst_load_detail.fcst_prc := 0;
            for idx in 1..tbl_wrkn.count loop
               if tbl_wrkn(idx).yyyypp = rcd_fcst_load_detail.fcst_yyyypp then
                  rcd_fcst_load_detail.fcst_prc := tbl_wrkn(idx).price;
                  exit;
               end if;
	    end loop;
            rcd_fcst_load_detail.fcst_gsv := rcd_fcst_load_detail.fcst_qty * rcd_fcst_load_detail.fcst_prc;
         end if;

         /*-*/
         /* Set the forecast load detail
         /*-*/
         rcd_fcst_load_detail.mesg_text := null;

         /*-*/
         /* Validate the forecast material
         /*-*/
         if rcd_fcst_load_detail.matl_code is null then
            if rcd_fcst_load_detail.mesg_text is null then
               rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - does not exist in LADS';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.matl_status != 'ACTIVE' then
            if rcd_fcst_load_detail.mesg_text is null then
               rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - is not active in LADS';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.new_plan_group = '*NONE' then
            if rcd_fcst_load_detail.mesg_text is null then
               rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - is not a *SNACK or *PET material';
            var_errors := true;
         end if;

         /*-*/
         /* Validate the forecast data
         /*-*/
         if rcd_fcst_load_detail.fcst_qty = 0 then
            if rcd_fcst_load_detail.mesg_text is null then
               rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - does not have a forecast quantity';
            var_errors := true;
         end if;
         if rcd_fcst_load_detail.fcst_prc = 0 then
            if rcd_fcst_load_detail.mesg_text is null then
               rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
            end if;
            rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - does not have pricing data for this period';
            var_errors := true;
         end if;

         /*-*/
         /* Update the forecast load detail row
         /*-*/
         update fcst_load_detail
            set fcst_prc = rcd_fcst_load_detail.fcst_prc,
                fcst_gsv = rcd_fcst_load_detail.fcst_gsv,
                plan_group = rcd_fcst_load_detail.new_plan_group,
                mesg_text = rcd_fcst_load_detail.mesg_text
          where load_identifier = rcd_fcst_load_detail.load_identifier
            and load_sequence = rcd_fcst_load_detail.load_sequence;

      end loop;
      close csr_fcst_load_detail;

      /*-*/
      /* Set the forecast load header status
      /*-*/
      if var_errors = false then
         rcd_fcst_load_header.load_status := '*VALID';
      else
         rcd_fcst_load_header.load_status := '*ERROR';
      end if;

      /*-*/
      /* Update the forecast load header status
      /*-*/
      update fcst_load_header
         set load_status = rcd_fcst_load_header.load_status
       where load_identifier = rcd_fcst_load_header.load_identifier;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_load;

   /*******************************************************/
   /* This procedure performs the read xml stream routine */
   /*******************************************************/
   procedure read_xml_stream(par_type_version in varchar2,
                             par_data_type in varchar2,
                             par_data_version in number,
                             par_data_range in number,
                             par_stream in clob) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the forecast data
      /*-*/
      delete from fcst_data;
      commit;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,par_stream);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the primary node
      /*-*/
      var_wrkr := 0;
      obj_xml_element := xmlDom.getDocumentElement(obj_xml_document);
      obj_xml_node := xmlDom.makeNode(obj_xml_element);
      read_xml_child(par_type_version,par_data_type,par_data_version,par_data_range,obj_xml_node);

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_stream;

   /******************************************************/
   /* This procedure performs the read xml child routine */
   /******************************************************/
   procedure read_xml_child(par_type_version in varchar2,
                            par_data_type in varchar2,
                            par_data_version in number,
                            par_data_range in number,
                            par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      rcd_fcst_data fcst_data%rowtype;
      var_string varchar2(32767);
      var_char varchar2(1);
      var_value varchar2(4000);
      var_index number;
      type typ_wrkw is table of number index by binary_integer;
      tbl_wrkw typ_wrkw;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'TXTSTREAM' then
            null;
         when 'XR' then
            var_wrkr := var_wrkr + 1;
         when '#CDATA-SECTION' then
            rcd_fcst_data.material_code := '*ROW';
            rcd_fcst_data.dmnd_group := '*ROW';
            rcd_fcst_data.plant_code := '*NONE';
            rcd_fcst_data.fcst_yyyymmdd := '00000000';
            rcd_fcst_data.fcst_yyyyppw := 0;
            rcd_fcst_data.fcst_yyyypp := par_data_version;
            if par_type_version = '*YEAR' then
               rcd_fcst_data.fcst_yyyypp := (par_data_version * 100) + 1;
            end if;
            rcd_fcst_data.fcst_cover := 0;
            rcd_fcst_data.fcst_qty := 0;
            rcd_fcst_data.fcst_prc := 0;
            rcd_fcst_data.fcst_gsv := 0;
            for idx in 1..par_data_range loop
               tbl_wrkw(idx) := 0;
	    end loop;
            if par_data_type = '*QTY_GSV' then
               for idx in 1..par_data_range loop
                  tbl_wrkw(idx+par_data_range) := 0;
	       end loop;
            end if;
            var_string := xmlDom.getNodeValue(par_xml_node);
            if not(var_string is null) then
               var_value := null;
               var_index := 0;
               for idx in 1..length(var_string) loop
                  var_char := substr(var_string,idx,1);
                  if var_char = chr(9) then
                     if rcd_fcst_data.dmnd_group = '*ROW' then
                        if length(var_value) > 32 then
                           raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Demand group ('||var_value||') exceeds maximum length 32');
                        end if;
                        rcd_fcst_data.dmnd_group := nvl(var_value,'*NONE');
                     elsif rcd_fcst_data.material_code = '*ROW' then
                        if length(var_value) > 18 then
                           raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Material code ('||var_value||') exceeds maximum length 18');
                        end if;
                        rcd_fcst_data.material_code := var_value;
                     else
                        var_index := var_index + 1;
                        begin
                           if substr(var_value,length(var_value),1) = '-' then
                              tbl_wrkw(var_index) := to_number('-' || substr(var_value,1,length(var_value) - 1));
                           else
                              tbl_wrkw(var_index) := to_number(var_value);
                           end if;
                        exception
                           when others then
                              raise_application_error(-20000, 'Text file data row '||var_wrkr||' column '||var_index||' - Invalid number ('||var_value||')');
                        end;
                     end if;
                     var_value := null;
                  else
                     var_value := var_value||var_char;
                  end if;
               end loop;
               if rcd_fcst_data.dmnd_group = '*ROW' then
                  if length(var_value) > 32 then
                     raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Demand group ('||var_value||') exceeds maximum length 32');
                  end if;
                  rcd_fcst_data.dmnd_group := nvl(var_value,'*NONE');
               elsif rcd_fcst_data.material_code = '*ROW' then
                  if length(var_value) > 18 then
                     raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Material code ('||var_value||') exceeds maximum length 18');
                  end if;
                  rcd_fcst_data.material_code := var_value;
               else
                  var_index := var_index + 1;
                  begin
                     if substr(var_value,length(var_value),1) = '-' then
                        tbl_wrkw(var_index) := to_number('-' || substr(var_value,1,length(var_value) - 1));
                     else
                        tbl_wrkw(var_index) := to_number(var_value);
                     end if;
                  exception
                     when others then
                        raise_application_error(-20000, 'Text file data row '||var_wrkr||' column '||var_index||' - Invalid number ('||var_value||')');
                  end;
               end if;
               if par_data_type = '*QTY_ONLY' then
                  if var_index != par_data_range then
                     raise_application_error(-20000, 'Text file data (quantity only) row '||var_wrkr||' - Column count must be equal to ' || to_char(par_data_range + 2));
                  end if;
               end if;
               if par_data_type = '*QTY_GSV' then
                  if var_index != par_data_range + par_data_range then
                     raise_application_error(-20000, 'Text file data (quantity/gsv) row '||var_wrkr||' - Column count must be equal to ' || to_char(par_data_range + par_data_range + 2));
                  end if;
               end if;
               for idx in 1..par_data_range loop
                  rcd_fcst_data.fcst_qty := tbl_wrkw(idx);
                  rcd_fcst_data.fcst_gsv := tbl_wrkw(idx+par_data_range);
                  if par_data_type = '*QTY_GSV' then
                     rcd_fcst_data.fcst_prc := rcd_fcst_data.fcst_gsv / rcd_fcst_data.fcst_qty;
                  end if;
                  if rcd_fcst_data.fcst_qty != 0 then
                     insert into fcst_data
                        (material_code,
                         dmnd_group,
                         plant_code,
                         fcst_yyyymmdd,
                         fcst_yyyyppw,
                         fcst_yyyypp,
                         fcst_cover,
                         fcst_qty,
                         fcst_prc,
                         fcst_gsv)
                        values(rcd_fcst_data.material_code,
                               rcd_fcst_data.dmnd_group,
                               rcd_fcst_data.plant_code,
                               rcd_fcst_data.fcst_yyyymmdd,
                               rcd_fcst_data.fcst_yyyyppw,
                               rcd_fcst_data.fcst_yyyypp,
                               rcd_fcst_data.fcst_cover,
                               rcd_fcst_data.fcst_qty,
                               rcd_fcst_data.fcst_prc,
                               rcd_fcst_data.fcst_gsv);
                  end if;
                  if substr(to_char(rcd_fcst_data.fcst_yyyypp,'fm000000'),5,2) = '13' then
                     rcd_fcst_data.fcst_yyyypp := rcd_fcst_data.fcst_yyyypp + 88;
                  else
                     rcd_fcst_data.fcst_yyyypp := rcd_fcst_data.fcst_yyyypp + 1;
                  end if;
               end loop;
            end if;
         else raise_application_error(-20000, 'read_xml_stream - Type (' || xmlDom.getNodeName(par_xml_node) || ') not recognised');
      end case;

      /*-*/
      /* Process the child nodes
      /*-*/
      obj_xml_node_list := xmlDom.getChildNodes(par_xml_node);
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(par_type_version,par_data_type,par_data_version,par_data_range,obj_xml_node);
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_child;

end dw_fcst_maintenance;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_maintenance for dw_app.dw_fcst_maintenance;
grant execute on dw_fcst_maintenance to public;
