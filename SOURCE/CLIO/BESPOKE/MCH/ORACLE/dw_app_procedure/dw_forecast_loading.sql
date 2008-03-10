/******************/
/* Package Header */
/******************/
create or replace package dw_forecast_loading as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_forecast_loading
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecasting

    This package contain the procedures for forecast load data. The package exposes the
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
   function report_extract(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

end dw_forecast_loading;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_forecast_loading as

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
         var_message := var_message || chr(13) || 'Forecast load (' || var_load_identifier || ') is currently attached to one or more forecast extracts';
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
      /* Delete the forecast extract detail
      /*-*/
      delete from fcst_extract_detail
       where extract_identifier = rcd_fcst_extract_header.extract_identifier;

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
                nvl(t02.mars_period,99999999) as mars_yyyypp,
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
      rcd_fcst_load_header.load_identifier := 'BR_APOLLO_'||par_cast_date;
      rcd_fcst_load_header.load_description := 'Apollo Domestic Forecasts';
      rcd_fcst_load_header.load_status := '*NONE';
      rcd_fcst_load_header.load_type := '*BR_DOMESTIC';
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
         select t01.*
           from fcst_data t01
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
      rcd_fcst_load_header.crt_user := user;
      rcd_fcst_load_header.crt_date := sysdate;
      rcd_fcst_load_header.upd_user := user;
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
         rcd_fcst_load_detail.cover_yyyymmdd := rcd_fcst_data.fcst_yyyymmdd;
         rcd_fcst_load_detail.cover_day := rcd_fcst_data.fcst_cover;
         rcd_fcst_load_detail.cover_qty := rcd_fcst_data.fcst_qty;
         rcd_fcst_load_detail.fcst_yyyyppw := rcd_fcst_data.fcst_yyyyppw;
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

      cursor csr_mars_date is
         select *
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_mars_date csr_mars_date%rowtype;

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
         if rcd_fcst_load_header.load_status != '*VALID' then
            var_message := var_message || chr(13) || 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') must be *VALID status';
         end if;

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
      for idx in 1..tbl_extract.count loop
         if tbl_extract(idx).select_count = 0 then
            var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has no forecast load selected';
         end if;
         if tbl_extract(idx).select_count > 1 then
            var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has more than one forecast load specified';
         end if;
      end loop;

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

   /******************************************************/
   /* This procedure performs the report extract routine */
   /******************************************************/
   procedure report_extract(par_extract_identifier in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_wrk_string varchar2(4000 char);
      var_row_count number;
      var_end_count number;
      var_fcst_time varchar2(1
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
          where t01.extract_type = var_extract_type(+);
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

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_identifier := upper(par_identifier);
      if var_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;

      /*-*/
      /* Forecast load header must exist
      /*-*/
      open csr_fcst_load_header;
      fetch csr_fcst_load_header into rcd_fcst_load_header;
      if csr_fcst_load_header%notfound then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Set the forecast literals
      /*-*/
      var_fcst_time := rcd_fcst_load_header.fcst_time;
      if rcd_fcst_load_header.fcst_time = '*MTH' then
         var_fcst_time := 'Month';
      end if;
      if rcd_fcst_load_header.fcst_time = '*PRD' then
         var_fcst_time := 'Period';
      end if;
      var_fcst_type := rcd_fcst_load_header.fcst_type;
      if rcd_fcst_load_header.fcst_type = '*BR' then
         var_fcst_type := 'Business Review';
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP1' then
         var_fcst_type := 'Operating Plan - This Year';
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP2' then
         var_fcst_type := 'Operating Plan - Next Year';
      end if;
      var_fcst_source := rcd_fcst_load_header.fcst_source;
      var_fcst_material_list := rcd_fcst_load_header.fcst_material_list;
      if rcd_fcst_load_header.fcst_source = '*PLN' then
         var_fcst_source := 'Planning System';
      end if;
      if rcd_fcst_load_header.fcst_source = '*TXQ' then
         var_fcst_source := 'Text File (Quantity Only)';
         var_fcst_material_list := '*FILE';
      end if;
      if rcd_fcst_load_header.fcst_source = '*TXV' then
         var_fcst_source := 'Text File (Quantity and Values)';
         var_fcst_material_list := '*FILE';
      end if;

      /*-*/
      /* Retrieve load detail material count
      /*-*/
      open csr_fcst_load_count;
      fetch csr_fcst_load_count into rcd_fcst_load_count;
      if csr_fcst_load_count%notfound then
         rcd_fcst_load_count.material_count := 0;
      end if;
      close csr_fcst_load_count;

      /*-*/
      /* Add the selection sheet
      /*-*/
      lics_spreadsheet.addSheet('Selection',false);

      /*-*/
      /* Set the selection data
      /*-*/
      lics_spreadsheet.setRange('A1:A1',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Selections');
      lics_spreadsheet.setHeadingBorder('A1:A1',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRange('A2:A2',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Identifier: '||rcd_fcst_load_header.load_identifier);
      lics_spreadsheet.setRange('A3:A3',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Description: '||rcd_fcst_load_header.load_description);
      lics_spreadsheet.setRange('A4:A4',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Status: '||rcd_fcst_load_header.load_status);
      lics_spreadsheet.setRange('A5:A5',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Replacement: '||rcd_fcst_load_header.load_replace);
      lics_spreadsheet.setRange('A6:A6',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Split: '||rcd_fcst_load_header.fcst_split_text);
      lics_spreadsheet.setRange('A7:A7',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Time: '||var_fcst_time);
      lics_spreadsheet.setRange('A8:A8',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Type: '||var_fcst_type);
      lics_spreadsheet.setRange('A9:A9',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Source: '||var_fcst_source);
      lics_spreadsheet.setRange('A10:A10',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Casting: '||to_char(rcd_fcst_load_header.fcst_cast_yyyynn,'fm000000'));
      lics_spreadsheet.setRange('A11:A11',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Forecast Materials: '||var_fcst_material_list);
      lics_spreadsheet.setRange('A12:A12',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Split Key Information');
      lics_spreadsheet.setRange('A13:A13',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Organisation: '||rcd_fcst_load_header.sap_sales_org_code||' '||rcd_fcst_load_header.sales_org_desc);
      lics_spreadsheet.setRange('A14:A14',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Distribution Channel: '||rcd_fcst_load_header.sap_distbn_chnl_code||' '||rcd_fcst_load_header.distbn_chnl_desc);
      lics_spreadsheet.setRange('A15:A15',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Division: '||rcd_fcst_load_header.sap_division_code||' '||rcd_fcst_load_header.division_desc);
      lics_spreadsheet.setRange('A16:A16',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Customer: '||nvl(rcd_fcst_load_header.sap_sales_div_cust_code,'N/A'));
      lics_spreadsheet.setRange('A17:A17',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Sales Organisation: '||nvl(rcd_fcst_load_header.sap_sales_div_sales_org_code,'N/A'));
      lics_spreadsheet.setRange('A18:A18',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Distribution Channel: '||nvl(rcd_fcst_load_header.sap_sales_div_distbn_chnl_code,'N/A'));
      lics_spreadsheet.setRange('A19:A19',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'Sales Division Division: '||nvl(rcd_fcst_load_header.sap_sales_div_division_code,'N/A'));
      lics_spreadsheet.setRangeBorder('A2:A19',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Set the legend data
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         lics_spreadsheet.setRange('A21:A21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Data Values');
         lics_spreadsheet.setRange('B21:B21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Legend');
         lics_spreadsheet.setRange('C21:C21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Type');
         lics_spreadsheet.setHeadingBorder('A21:C21',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRange('A22:A22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The forecast quantity');
         lics_spreadsheet.setRange('B22:B22',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
         lics_spreadsheet.setRange('C22:C22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A23:A23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The material list price');
         lics_spreadsheet.setRange('B23:B23',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'PRC');
         lics_spreadsheet.setRange('C23:C23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A24:A24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The base price value = QTY*PRC');
         lics_spreadsheet.setRange('B24:B24',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRange('C24:C24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Calculated');
         lics_spreadsheet.setRange('A25:A25',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The general discount price (negative number)');
         lics_spreadsheet.setRange('B25:B25',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'DIS');
         lics_spreadsheet.setRange('C25:C25',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A26:A26',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The average volume discount % (positive number) (eg. 20% = .20)');
         lics_spreadsheet.setRange('B26:B26',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'VOL');
         lics_spreadsheet.setRange('C26:C26',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A27:A27',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The gross sales value = QTY*round((PRC+DIS)-((PRC+DIS)*VOL),0)');
         lics_spreadsheet.setRange('B27:B27',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRange('C27:C27',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Calculated');
         lics_spreadsheet.setRangeBorder('A22:C27',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      else
         lics_spreadsheet.setRange('A21:A21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Data Values');
         lics_spreadsheet.setRange('B21:B21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Legend');
         lics_spreadsheet.setRange('C21:C21',null,lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Type');
         lics_spreadsheet.setHeadingBorder('A21:C21',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRange('A22:A22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The forecast quantity');
         lics_spreadsheet.setRange('B22:B22',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
         lics_spreadsheet.setRange('C22:C22',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A23:A23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The base price value');
         lics_spreadsheet.setRange('B23:B23',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRange('C23:C23',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRange('A24:A24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,'The gross sales value');
         lics_spreadsheet.setRange('B24:B24',null,lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRange('C24:C24',null,lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Data Entry');
         lics_spreadsheet.setRangeBorder('A22:C24',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      end if;

      /*-*/
      /* Add the forecast sheet
      /*-*/
      lics_spreadsheet.addSheet('Forecasting',false);

      /*-*/
      /* Set the sheet heading
      /*-*/
      lics_spreadsheet.setRange('A1:A1','A1:R1',lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast - '||var_fcst_time||' - '||var_fcst_type||' - Casting Period '||to_char(rcd_fcst_load_header.fcst_cast_yyyynn,'fm000000'));

      /*-*/
      /* Set the company heading
      /*-*/
      lics_spreadsheet.setRange('A2:A2','A2:R2', lics_spreadsheet.getHeadingType(2),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Company: '||rcd_fcst_load_header.company_desc);

      /*-*/
      /* Set the forecast heading
      /*-*/
      var_wrk_string := 'Material'||chr(9)||'Description'||chr(9)||'Data'||chr(9);
      var_cast_yyyynn := rcd_fcst_load_header.fcst_cast_yyyynn;
      for idx in 1..13 loop
         if substr(to_char(var_cast_yyyynn,'fm000000'),5,2) = '13' then
            var_cast_yyyynn := var_cast_yyyynn + 88;
         else
            var_cast_yyyynn := var_cast_yyyynn + 1;
         end if;
         var_wrk_string := var_wrk_string||to_char(var_cast_yyyynn,'FM000000')||chr(9);
      end loop;
      var_wrk_string := var_wrk_string||'Total'||chr(9)||'Error Message';
      lics_spreadsheet.setRangeArray('A3:A3','A3:R3',lics_spreadsheet.getHeadingType(7),lics_spreadsheet.FORMAT_CHAR_CENTRE,false,var_wrk_string);
      lics_spreadsheet.setHeadingBorder('A3:R3',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Initialise the row count
      /*-*/
      var_row_count := 3;

      /*-*/
      /* Exit when no detail lines
      /*-*/
      if rcd_fcst_load_count.material_count = 0 then
         lics_spreadsheet.setRange('A4:A4','A4:R4',lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'NO DETAILS EXIST');
         lics_spreadsheet.setRangeBorder('A4:R4',lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         return;
      end if;

      /*-*/
      /* Set the cell freeze
      /*-*/
      lics_spreadsheet.setFreezeCell('D4');

      /*-*/
      /* Set the data identifier start
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'<XLSHEET IDENTIFIER="'||rcd_fcst_load_header.load_identifier||'">');
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

      /*-*/
      /* Define the QTY row
      /*-*/
      var_row_count := var_row_count + 1;
      var_wrk_string := '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0';
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
      lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                     'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                     lics_spreadsheet.TYPE_DETAIL_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the PRC row when required
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'PRC');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,null);
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the BPS row
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=D'||to_char(var_row_count-2,'FM999999990')||'*D'||to_char(var_row_count-1,'FM999999990')||'');
         lics_spreadsheet.setRangeFill('D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.FILL_RIGHT);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      else
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the DIS row when required
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'DIS');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,null);
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the VOL row when required
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'VOL');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_2,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_DECIMAL_2,0,false,null);
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the GSV row
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=D'||to_char(var_row_count-5,'FM999999990')||'*round((D'||to_char(var_row_count-4,'FM999999990')||'+D'||to_char(var_row_count-2,'FM999999990')||')-((D'||to_char(var_row_count-4,'FM999999990')||'+D'||to_char(var_row_count-2,'FM999999990')||')*D'||to_char(var_row_count-1,'FM999999990')||'),0)');
         lics_spreadsheet.setRangeFill('D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.FILL_RIGHT);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      else
         var_row_count := var_row_count + 1;
         var_wrk_string := '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0'||chr(9)||
                           '0';
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
         lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
         lics_spreadsheet.setRangeArray('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),
                                        'D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),
                                        lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
         lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
         lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                   lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      end if;

      /*-*/
      /* Define the borders
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count-5,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('B'||to_char(var_row_count-5,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('C'||to_char(var_row_count-5,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('R'||to_char(var_row_count-5,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      else
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count-2,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('B'||to_char(var_row_count-2,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('C'||to_char(var_row_count-2,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('R'||to_char(var_row_count-2,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      end if;

      /*-*/
      /* Define the copy
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count-5,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),rcd_fcst_load_count.material_count-1,lics_spreadsheet.COPY_DOWN);
      else
         lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count-2,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),rcd_fcst_load_count.material_count-1,lics_spreadsheet.COPY_DOWN);
      end if;

      /*-*/
      /* Set the data identifier end 
      /*-*/
      if rcd_fcst_load_header.fcst_source != '*TXV' then
         var_row_count := var_row_count + ((rcd_fcst_load_count.material_count-1)*6) + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                   'A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),
                                   lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'</XLSHEET>');
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

      else
         var_row_count := var_row_count + ((rcd_fcst_load_count.material_count-1)*3) + 1;
         lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                   'A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),
                                   lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'</XLSHEET>');
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      end if;
      var_end_count := var_row_count;

      /*-*/
      /* Set the print settings
      /*-*/
      lics_spreadsheet.setPrintData('$1:$3','$A:$A',2,1,0);

      /*-*/
      /* Output the forecast values
      /*-*/
      var_row_count := 4;

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
         /* Output the QTY row
         /*-*/
         var_row_count := var_row_count + 1;
         var_wrk_string := rcd_fcst_load_detail.sap_material_code||chr(9)||
                           rcd_fcst_load_detail.material_desc_en||chr(9)||
                           'QTY'||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_01,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_02,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_03,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_04,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_05,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_06,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_07,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_08,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_09,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_10,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_11,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_12,'fm999999990')||chr(9)||
                           to_char(rcd_fcst_load_detail.fcst_qty_13,'fm999999990');
         lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                        null,null,null,false,var_wrk_string);
         if not(rcd_fcst_load_detail.err_message is null) then
            lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                      lics_spreadsheet.TYPE_NONE,lics_spreadsheet.FORMAT_NONE,0,false,rcd_fcst_load_detail.err_message);
         end if;

         /*-*/
         /* Output the PRC row when required
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'PRC'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_prc_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the BPS row
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
         else
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'BPS'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_bps_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the DIS row when required
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'DIS'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_dis_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the VOL row when required
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'VOL'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_01,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_02,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_03,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_04,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_05,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_06,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_07,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_08,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_09,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_10,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_11,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_12,'fm999999990.00')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_vol_13,'fm999999990.00');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

         /*-*/
         /* Output the GSV row
         /*-*/
         if rcd_fcst_load_header.fcst_source != '*TXV' then
            var_row_count := var_row_count + 1;
         else
            var_row_count := var_row_count + 1;
            var_wrk_string := chr(9)||
                              chr(9)||
                              'GSV'||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_01,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_02,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_03,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_04,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_05,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_06,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_07,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_08,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_09,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_10,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_11,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_12,'fm999999990')||chr(9)||
                              to_char(rcd_fcst_load_detail.fcst_gsv_13,'fm999999990');
            lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                           null,null,null,false,var_wrk_string);
         end if;

      end loop;
      close csr_fcst_load_detail;

      /*-*/
      /* Define the QTY total row
      /*-*/
      var_row_count := var_end_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_RIGHT,0,false,'Grand Totals:');
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'QTY');
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",D4:D'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",E4:E'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",F4:F'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",G4:G'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",H4:H'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",I4:I'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",J4:J'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",K4:K'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",L4:L'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",M4:M'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",N4:N'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",O4:O'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=QTY",P4:P'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the BPS total row
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'BPS');
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",D4:D'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",E4:E'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",F4:F'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",G4:G'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",H4:H'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",I4:I'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",J4:J'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",K4:K'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",L4:L'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",M4:M'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",N4:N'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",O4:O'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=BPS",P4:P'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the GSV total row
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'GSV');
      lics_spreadsheet.setRange('D'||to_char(var_row_count,'FM999999990')||':D'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",D4:D'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('E'||to_char(var_row_count,'FM999999990')||':E'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",E4:E'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('F'||to_char(var_row_count,'FM999999990')||':F'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",F4:F'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('G'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",G4:G'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",H4:H'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('I'||to_char(var_row_count,'FM999999990')||':I'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",I4:I'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('J'||to_char(var_row_count,'FM999999990')||':J'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",J4:J'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('K'||to_char(var_row_count,'FM999999990')||':K'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",K4:K'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('L'||to_char(var_row_count,'FM999999990')||':L'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",L4:L'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('M'||to_char(var_row_count,'FM999999990')||':M'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",M4:M'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('N'||to_char(var_row_count,'FM999999990')||':N'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",N4:N'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('O'||to_char(var_row_count,'FM999999990')||':O'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",O4:O'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('P'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sumif(C4:C'||to_char(var_end_count-1,'FM999999990')||',"=GSV",P4:P'||to_char(var_end_count-1,'FM999999990')||')');
      lics_spreadsheet.setRange('Q'||to_char(var_row_count,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT_BOLD,lics_spreadsheet.FORMAT_DECIMAL_0,0,false,'=sum(D'||to_char(var_row_count,'FM999999990')||':P'||to_char(var_row_count,'FM999999990')||')');
      lics_spreadsheet.setRange('R'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      /*-*/
      /* Define the total borders
      /*-*/
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count-2,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('C'||to_char(var_row_count-2,'FM999999990')||':Q'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('R'||to_char(var_row_count-2,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':R'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - REPORT_EXTRACT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_extract;

   /**********************************************/
   /* This procedure performs the export routine */
   /**********************************************/
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
         select t01.*
           from fcst_extract_header t01
          where t01.extract_identifier = var_extract_identifier;
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
      var_output := '<TABLE>';

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
      var_output := '</TABLE>';
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
      var_index number;

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

end dw_forecast_loading;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_loading for dw_app.dw_forecast_loading;
grant execute on dw_forecast_loading to public;
