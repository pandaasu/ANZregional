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
    Dimensional Data Store - Forecast Loading

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
    2008/02   Steve Gregan   Created from Mars Japan version and modified for Mars China

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure delete_load(par_load_identifier in varchar2);
   procedure delete_extract(par_extract_identifier in varchar2);
   procedure create_domestic_load(par_cast_date in varchar2);
   procedure extract_load(par_extract_type in varchar2,
                          par_extract_identifier in varchar2,
                          par_extract_description in varchar2,
                          par_load_identifier in varchar2,
                          par_user in varchar2);

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
   procedure validate_load(par_identifier in varchar2);

   /***************************************************/
   /* This procedure performs the delete load routine */
   /***************************************************/
   procedure delete_load(par_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_identifier fcst_load_header.load_identifier%type;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = var_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

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
      /* Attempt to lock the forecast header row
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
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist or is already locked');
      end if;

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

   /************************************************************/
   /* This procedure performs the create domestic load routine */
   /************************************************************/
   procedure create_domestic_load(par_cast_date in varchar2) is

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
      var_cast_yyyymmdd rcd_fcst_load_header.cast_yyyymmdd%type;
      var_cast_yyyyppw rcd_fcst_load_header.cast_yyyyppw%type;
      var_cast_yyyypp rcd_fcst_load_header.cast_yyyypp%type;
      var_fcst_version rcd_fcst_load_header.fcst_version%type;

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
                nvl(t02.mars_period,99999999) as fcst_yyyypp,
                nvl(t02.mars_week,9999999) as fcst_yyyyppw
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
      var_cast_yyyymmdd := to_char(var_cast_date,'yyyymmdd');
      var_cast_yyyyppw := rcd_mars_date.mars_week;
      var_cast_yyyypp := rcd_mars_date.mars_period;
      var_fcst_version := rcd_mars_date.mars_period;
      if substr(to_char(var_fcst_version,'fm000000'),5,2) = '13' then
         var_fcst_version := var_fcst_version + 88;
      else
         var_fcst_version := var_fcst_version + 1;
      end if;

      /*-*/
      /* Initialise the forecast load header
      /*-*/
      rcd_fcst_load_header.load_identifier := 'BR_DOMESTIC_'||var_cast_yyyymmdd;
      rcd_fcst_load_header.load_description := 'Business Review Domestic Forecasts';
      rcd_fcst_load_header.load_status := '*CREATING';
      rcd_fcst_load_header.load_type := '*BR_DOMESTIC';
      rcd_fcst_load_header.cast_yyyymmdd := var_cast_yyyymmdd;
      rcd_fcst_load_header.cast_yyyyppw := var_cast_yyyyppw;
      rcd_fcst_load_header.cast_yyyypp := var_cast_yyyypp;
      rcd_fcst_load_header.fcst_version := var_fcst_version;
      rcd_fcst_load_header.fcst_str_yyyyppw := 9999999;
      rcd_fcst_load_header.fcst_str_yyyypp := 999999;
      rcd_fcst_load_header.fcst_end_yyyyppw := 0;
      rcd_fcst_load_header.fcst_end_yyyypp := 0;
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
          cast_yyyymmdd,
          cast_yyyyppw,
          cast_yyyypp,
          fcst_version,
          fcst_str_yyyyppw,
          fcst_str_yyyypp,
          fcst_end_yyyyppw,
          fcst_end_yyyypp,
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
                rcd_fcst_load_header.cast_yyyymmdd,
                rcd_fcst_load_header.cast_yyyyppw,
                rcd_fcst_load_header.cast_yyyypp,
                rcd_fcst_load_header.fcst_version,
                rcd_fcst_load_header.fcst_str_yyyyppw,
                rcd_fcst_load_header.fcst_str_yyyypp,
                rcd_fcst_load_header.fcst_end_yyyyppw,
                rcd_fcst_load_header.fcst_end_yyyypp,
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
         var_work_yyyyppw := rcd_fcst_data.fcst_yyyyppw;
         var_work_yyyypp := rcd_fcst_data.fcst_yyyypp;
         var_work_count := round(rcd_fcst_load_detail.cover_day/7,0);
         var_work_qty := rcd_fcst_load_detail.cover_qty / var_work_count;
         for idx in 1..var_work_count loop

            /*-*/
            /* Update the header forecast range
            /*-*/
            if var_work_yyyyppw < rcd_fcst_load_header.fcst_str_yyyyppw then
               rcd_fcst_load_header.fcst_str_yyyyppw := var_work_yyyyppw;
            end if;
            if var_work_yyyypp < rcd_fcst_load_header.fcst_str_yyyypp then
               rcd_fcst_load_header.fcst_str_yyyypp := var_work_yyyypp;
            end if;
            if var_work_yyyyppw > rcd_fcst_load_header.fcst_end_yyyyppw then
               rcd_fcst_load_header.fcst_end_yyyyppw := var_work_yyyyppw;
            end if;
            if var_work_yyyypp > rcd_fcst_load_header.fcst_end_yyyypp then
               rcd_fcst_load_header.fcst_end_yyyypp := var_work_yyyypp;
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
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set fcst_str_yyyyppw = rcd_fcst_load_header.fcst_str_yyyyppw,
             fcst_str_yyyypp = rcd_fcst_load_header.fcst_str_yyyypp,
             fcst_end_yyyyppw = rcd_fcst_load_header.fcst_end_yyyyppw,
             fcst_end_yyyypp = rcd_fcst_load_header.fcst_end_yyyypp
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
         raise_application_error(-20000, 'DW_FORECAST_LOADING - CREATE_DOMESTIC_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_domestic_load;

   /****************************************************/
   /* This procedure performs the extract load routine */
   /****************************************************/
   procedure extract_load(par_extract_type in varchar2,
                          par_extract_identifier in varchar2,
                          par_extract_description in varchar2,
                          par_load_identifier in varchar2,
                          par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_extract_header fcst_extract_header%rowtype;
      rcd_fcst_extract_load fcst_extract_load%rowtype;
      var_extract_type fcst_extract_header.extract_type%type;
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_extract_description fcst_extract_header.extract_description%type;
      var_load_identifier fcst_load_header.load_identifier%type;
      var_user fcst_load_header.crt_user%type;
      var_value varchar2(256);
      type typ_value is table of varchar2(256) index by binary_integer;
      tbl_value typ_value;

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

      cursor csr_fcst_extract_header is 
         select t01.*
           from fcst_extract_header t01
          where t01.extract_identifier = var_extract_identifier;
      rcd_fcst_extract_header csr_fcst_extract_header%rowtype;

      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = tbl_value(idx);
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
      /* Validate the parameter values
      /*-*/
      var_extract_type := upper(par_extract_type);
      var_extract_identifier := upper(par_extract_identifier);
      var_extract_description := par_extract_description;
      var_load_identifier := upper(par_load_identifier);
      var_user := upper(par_user);
      if var_extract_type is null then
         raise_application_error(-20000, 'Forecast extract type must be specified');
      end if;
      if var_extract_identifier is null then
         raise_application_error(-20000, 'Forecast extract identifier must be specified');
      end if;
      if var_extract_description is null then
         raise_application_error(-20000, 'Forecast extract description must be specified');
      end if;
      if var_load_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier(s) must be specified');
      end if;
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Extract the load identifiers
      /*-*/
      tbl_value.delete;
      var_value := null;
      for idx in 1..length(var_load_identifier) loop
         if substr(var_load_identifier,idx,1) = ',' then
            if not(var_value is null) then
               tbl_value(tbl_value.count+1) := var_value;
            end if;
            var_value := null;
         else
            var_value := var_value||substr(var_load_identifier,idx,1);
         end if;
      end loop;
      if not(var_value is null) then
         tbl_value(tbl_value.count+1) := var_value;
      end if;

      /*-*/
      /* Validate the extract type
      /*-*/
      open csr_fcst_extract_type;
      fetch csr_fcst_extract_type into rcd_fcst_extract_type;
      if csr_fcst_extract_type%notfound then
         raise_application_error(-20000, 'Forecast extract type (' || var_extract_type || ') does not exist');
      end if;
      close csr_fcst_extract_type;

      /*-*/
      /* Validate the extract type load types
      /*-*/
      open csr_fcst_extract_type_load;
      loop
         fetch csr_fcst_extract_type_load into rcd_fcst_extract_type_load;
         if csr_fcst_extract_type_load%notfound then
            exit;
         end if;

      end loop;

      /*-*/
      /* Validate the extract header
      /*-*/
      open csr_fcst_extract_header;
      fetch csr_fcst_extract_header into rcd_fcst_extract_header;
      if csr_fcst_extract_header%found then
         raise_application_error(-20000, 'Forecast extract (' || var_extract_identifier || ') already exists');
      end if;
      close csr_fcst_extract_header;

      /*-*/
      /* Validate the load identifiers
      /*-*/
      for idx in 1..tbl_value.count loop

         /*-*/
         /* Forecast load must exist
         /*-*/
         open csr_fcst_load_header;
         fetch csr_fcst_load_header into rcd_fcst_load_header;
         if csr_fcst_load_header%notfound then
            raise_application_error(-20000, 'Forecast load (' || tbl_value(idx) || ') does not exist');
         end if;
         close csr_fcst_load_header;

         /*-*/
         /* Forecast load type must match the extract load type
         /*-*/
--must match extract type load list and extract type load list must be fullfilled
      ---   if rcd_fcst_load_header.load_type != rcd_fcst_extract_type.load_type then
      ---      raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') type ( || rcd_fcst_load_header.load_type ||') does not match the extract load type( || rcd_fcst_extract_type.load_type ||')');
      ---   end if;

         /*-*/
         /* Forecast load must be *VALID
         /*-*/
         if rcd_fcst_load_header.load_status != '*VALID' then
            raise_application_error(-20000, 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') must be *VALID status');
         end if;

         /*-*/
         /* Forecast load casting period must match CLIO
         /*-*/
         open csr_mars_date;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%notfound then
            raise_application_error(-20000, 'Mars date (' || to_char(sysdate,'yyyy/mm/dd') || ') does not exist');
         end if;
         close csr_mars_date;
         if rcd_fcst_load_header.fcst_type = '*BR' then
            if rcd_fcst_load_header.fcst_cast_yyyypp < (rcd_mars_date.mars_period - 1) then
               raise_application_error(-20000, ' Business review casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyypp)||') must not be less than previous period ('||to_char(rcd_mars_date.mars_period-1)||')');
            end if;
         end if;

      end loop;

      /*-*/
      /* Initialise the forecast extract header
      /*-*/
      rcd_fcst_extract_header.extract_identifier := var_extract_identifier;
      rcd_fcst_extract_header.extract_description := var_extract_description;
      rcd_fcst_extract_header.extract_type := var_extract_type;
      rcd_fcst_extract_header.plan_group := rcd_fcst_extract_header.plan_group;
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
          plan_group,
          crt_user,
          crt_date)
         values(rcd_fcst_extract_header.extract_identifier,
                rcd_fcst_extract_header.extract_description,
                rcd_fcst_extract_header.extract_type,
                rcd_fcst_extract_header.plan_group,
                rcd_fcst_extract_header.crt_user,
                rcd_fcst_extract_header.crt_date);
      exception
         when dup_val_on_index then
            raise_application_error(-20000, 'Forecast extract identifier (' || var_extract_identifier || ') already exists');
      end;

      /*-*/
      /* Insert the forecast extract loads
      /*-*/
      rcd_fcst_extract_load.extract_identifier := rcd_fcst_extract_header.extract_identifier;
      for idx in 1..tbl_value.count loop
         rcd_fcst_extract_load.load_identifier := tbl_value(idx);
         insert into fcst_extract_load
            (extract_identifier,
             load_identifier)
         values(rcd_fcst_extract_load.extract_identifier,
                rcd_fcst_extract_load.load_identifier);
      end loop;

      /*-*/
      /* Execute the required extract procedure
      /*-*/
      begin
         execute immediate 'begin '||rcd_fcst_extract_type.extract_procedure||'.execute('||rcd_fcst_extract_header.extract_identifier||'); end;';
      exception
         when others then
            raise_application_error(-20000, 'Forecast extract procedure (' || rcd_fcst_extract_type.extract_procedure || ') failed - ' || substr(sqlerrm, 1, 1024));
      end;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - EXTRACT_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_load;

   /*************************************************************/
   /* This procedure performs the report planning load routine */
   /*************************************************************/
   procedure report_planning_load(par_cast_period in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;
      var_wrk_count number;
      var_wrk_yyyypp number;
      var_query varchar2(32767 char);
      type typ_cursor is ref cursor;
      csr_extract typ_cursor;

      type typ_record is record(qry_ord_number varchar2(256 char),
                                qry_ord_line varchar2(256 char),
                                qry_gi_date date,
                                qry_sup_plant varchar2(256 char),
                                qry_sup_locn varchar2(256 char),
                                qry_rcv_plant varchar2(256 char),
                                qry_matl_code varchar2(256 char),
                                qry_matl_desc varchar2(256 char),
                                qry_ord_qty number,
                                qry_ord_uom varchar2(256 char),
                                qry_dsp_price number,
                                qry_dsp_value number,
                                qry_tax_rate number,
                                qry_tax_value number,
                                qry_tot_value number,
                                qry_tax_eye varchar2(256 char),
                                qry_pack_frmt varchar2(256 char),
                                qry_cust_name varchar2(256 char),
                                qry_cust_addr varchar2(256 char),
                                qry_cust_bank varchar2(256 char),
                                qry_tax_code varchar2(256 char));



      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select *
           from mars_date t01
          where to_char(t01.calendar_date,'yyyymmdd') = to_char(sysdate,'yyyymmdd');
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_fcst_load_header is 
         select *
           from fcst_load_header t01
          where t01.load_identifier = var_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

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
      var_user := upper(par_user);
      if var_user is null then
         var_user := user;
      end if;

      /*-*/
      /* Attempt to lock the forecast header row
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
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') does not exist or is already locked');
      end if;

      /*-*/
      /* Forecast load must be *VALID
      /*-*/
      if rcd_fcst_load_header.load_status != '*VALID' then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') must be *VALID status');
      end if;

      /*-*/
      /* Forecast load must be a period load
      /*-*/
      if rcd_fcst_load_header.fcst_time != '*PRD' then
         raise_application_error(-20000, 'Forecast load (' || var_identifier || ') must be period load');
      end if;

      /*-*/
      /* Forecast load casting period must match CLIO
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Mars date (' || to_char(sysdate,'yyyy/mm/dd') || ') does not exist');
      end if;
      close csr_mars_date;
      if rcd_fcst_load_header.fcst_type = '*BR' then
         if rcd_fcst_load_header.fcst_cast_yyyynn < (rcd_mars_date.mars_period - 1) then
            raise_application_error(-20000, ' Business review casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyynn)||') must not be less than CLIO previous period ('||to_char(rcd_mars_date.mars_period-1)||')');
         end if;
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP1' then
         if rcd_fcst_load_header.fcst_cast_yyyynn != rcd_mars_date.mars_year*100 then
            raise_application_error(-20000, 'Operating plan (this year) casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyynn)||') does not match CLIO casting period ('||to_char(rcd_mars_date.mars_year*100)||'00)');
         end if;
      end if;
      if rcd_fcst_load_header.fcst_type = '*OP2' then
         if rcd_fcst_load_header.fcst_cast_yyyynn != (rcd_mars_date.mars_year+1)*100 then
            raise_application_error(-20000, 'Operating plan (next year) casting period ('||to_char(rcd_fcst_load_header.fcst_cast_yyyynn)||') does not match CLIO casting period ('||to_char((rcd_mars_date.mars_year+1)*100)||'00)');
         end if;
      end if;

      /*-*/
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set load_status = '*LOADED',
             upd_user = var_user,
             upd_date = sysdate
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Set the forecast type variable
      /*-*/
      if rcd_fcst_load_header.fcst_time = '*PRD' then
         if rcd_fcst_load_header.fcst_type = '*BR' then
            var_fcst_type_code := 3;
         end if;
         if rcd_fcst_load_header.fcst_type = '*OP1' then
            var_fcst_type_code := 4;
         end if;
         if rcd_fcst_load_header.fcst_type = '*OP2' then
            var_fcst_type_code := 4;
         end if;
      end if;

      /*-*/
      /* Load the query statement
      /*-*/
      var_query := 'select t01.material_code material_code,
                           nvl(sum(case when t01.fcst_yyyypp = <P01> then fcst_qty end),0) q01_qty,
                           nvl(sum(case when t01.fcst_yyyypp = <P02> then fcst_qty end),0) q02_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P03> then fcst_qty end),0) q03_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P04> then fcst_qty end),0) q04_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P05> then fcst_qty end),0) q05_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P06> then fcst_qty end),0) q06_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P07> then fcst_qty end),0) q07_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P08> then fcst_qty end),0) q08_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P09> then fcst_qty end),0) q09_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P10> then fcst_qty end),0) q10_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P11> then fcst_qty end),0) q11_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P12> then fcst_qty end),0) q12_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P13> then fcst_qty end),0) q13_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P14> then fcst_qty end),0) q14_qty,
                           nvl(sum(case when t01.fcst_yyyypp = <P15> then fcst_qty end),0) q15_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P16> then fcst_qty end),0) q16_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P17> then fcst_qty end),0) q17_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P18> then fcst_qty end),0) q18_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P19> then fcst_qty end),0) q19_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P20> then fcst_qty end),0) q20_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P21> then fcst_qty end),0) q21_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P22> then fcst_qty end),0) q22_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P23> then fcst_qty end),0) q23_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P24> then fcst_qty end),0) q24_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P25> then fcst_qty end),0) q25_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P26> then fcst_qty end),0) q26_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P27> then fcst_qty end),0) q27_qty,
                           nvl(sum(case when t01.fcst_yyyypp = <P28> then fcst_qty end),0) q28_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P29> then fcst_qty end),0) q29_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P30> then fcst_qty end),0) q30_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P31> then fcst_qty end),0) q31_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P32> then fcst_qty end),0) q32_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P33> then fcst_qty end),0) q33_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P34> then fcst_qty end),0) q34_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P35> then fcst_qty end),0) q35_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P36> then fcst_qty end),0) q36_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P37> then fcst_qty end),0) q37_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P38> then fcst_qty end),0) q38_val,
                           nvl(sum(case when t01.fcst_yyyypp = <P39> then fcst_qty end),0) q39_val
                      from fcst_load_detail t01
                     where t01.load_identifier = '<LOADID>'
                     group by t01.material_code
                     order by material_code';
      var_query := replace(var_query,'<LOADID>',var_tax_01);

      /*-*/
      /* Set the forecast periods
      /*-*/
      var_wrk_count := 1;
      var_wrk_yyyypp := rcd_fcst_load_header.fcst_str_yyyypp;
      loop
         if var_wrk_yyyypp > rcd_fcst_load_header.fcst_end_yyyypp then
            exit;
         end if;
         var_query := replace(var_query,'<P'||to_char(var_wrk_count,'fm00')||'>',to_char(var_wrk_yyyypp,'fm000000'));
         var_wrk_count := var_wrk_count + 1;
         if substr(to_char(var_wrk_yyyypp,'fm000000'),5,2) = '13' then
            var_wrk_yyyypp := var_wrk_yyyypp + 88;
         else
            var_wrk_yyyypp := var_wrk_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Retrieve the extract data
      /*-*/
      /*-*/
      tbl_report.delete;
      open csr_extract for var_query;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;
      end loop;
      close csr_extract;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_LOADING - REPORT_PLANNING_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_planning_load;

   /*****************************************************/
   /* This procedure performs the validate load routine */
   /*****************************************************/
   procedure validate_load(par_identifier in varchar2) is

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
          where t01.load_identifier = par_identifier;
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
            and (t04.mars_period <= rcd_fcst_load_header.fcst_str_yyyypp or
                 (t05.mars_period is null or t05.mars_period >= rcd_fcst_load_header.fcst_end_yyyypp));
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
         raise_application_error(-20000, 'Forecast load (' || par_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Load the forecast period array
      /*-*/
      tbl_wrkn.delete;
      var_wrk_yyyypp := rcd_fcst_load_header.fcst_str_yyyypp;
      loop
         if var_wrk_yyyypp > rcd_fcst_load_header.fcst_end_yyyypp then
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
         /* Retrieve the material price data for new material
         /*-*/
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

         /*-*/
         /* Retrieve the detail price and calculate the gsv
         /*-*/
         rcd_fcst_load_detail.fcst_prc := 0;
         for idx in 1..tbl_wrkn.count loop
            if tbl_wrkn(idx).yyyypp = rcd_fcst_load_detail.fcst_yyyypp then
               rcd_fcst_load_detail.fcst_prc := tbl_wrkn(idx).price;
               exit;
            end if;
	 end loop;
         rcd_fcst_load_detail.fcst_gsv := rcd_fcst_load_detail.fcst_qty * rcd_fcst_load_detail.fcst_prc;

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

end dw_forecast_loading;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_loading for dw_app.dw_forecast_loading;
grant execute on dw_forecast_loading to public;
