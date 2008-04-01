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

    This package contain the procedures for forecast maintenance.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function delete_load(par_load_identifier in varchar2) return varchar2;
   function delete_extract(par_extract_identifier in varchar2) return varchar2;
   function validate_load(par_load_identifier in varchar2, par_user in varchar2) return varchar2;
   procedure create_apollo_load(par_cast_date in varchar2);
   function create_stream_load(par_load_type in varchar2,
                               par_load_identifier in varchar2,
                               par_load_description in varchar2,
                               par_load_data_type in varchar2,
                               par_load_data_version in number,
                               par_load_data_range in number,
                               par_load_plan_group in varchar2,
                               par_user in varchar2) return varchar2;
   function update_stream_load(par_load_identifier in varchar2,
                               par_user in varchar2) return varchar2;
   function create_extract(par_extract_type in varchar2,
                           par_extract_identifier in varchar2,
                           par_extract_description in varchar2,
                           par_extract_version in number,
                           par_load_identifier in varchar2,
                           par_user in varchar2) return varchar2;
   function retrieve_loads(par_extract_type in varchar2, par_extract_version in number) return dw_fcst_table pipelined;
   function export_load(par_load_identifier in varchar2) return dw_fcst_table pipelined;
   function report_load(par_load_identifier in varchar2) return dw_fcst_table pipelined;
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
   function delete_load(par_load_identifier in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_load_identifier fcst_load_header.load_identifier%type;
      var_available boolean;
      var_title varchar2(128);
      var_message varchar2(4000);

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
      /* Initialise the message
      /*-*/
      var_title := 'Forecast Maintenance - Delete Forecast Load';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_load_identifier := upper(par_load_identifier);
      if var_load_identifier is null then
         var_message := var_message || chr(13) || 'Forecast load identifier must be specified';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
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
         var_message := var_message || chr(13) || 'Forecast load (' || var_load_identifier || ') does not exist or is already locked';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
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
   end delete_load;

   /******************************************************/
   /* This procedure performs the delete extract routine */
   /******************************************************/
   function delete_extract(par_extract_identifier in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_available boolean;
      var_title varchar2(128);
      var_message varchar2(4000);

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
      /* Initialise the message
      /*-*/
      var_title := 'Forecast Maintenance - Delete Forecast Extract';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_extract_identifier := upper(par_extract_identifier);
      if var_extract_identifier is null then
         var_message := var_message || chr(13) || 'Forecast extract identifier must be specified';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
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
         var_message := var_message || chr(13) || 'Forecast extract (' || var_extract_identifier || ') does not exist or is already locked';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
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
   end delete_extract;

   /*****************************************************/
   /* This procedure performs the validate load routine */
   /*****************************************************/
   function validate_load(par_load_identifier in varchar2, par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_load_identifier fcst_load_header.load_identifier%type;
      var_user fcst_load_header.crt_user%type;
      var_available boolean;
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = var_load_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Forecast Maintenance - Validate Forecast Load';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_load_identifier := upper(par_load_identifier);
      var_user := upper(par_user);
      if var_load_identifier is null then
         var_message := var_message || chr(13) || 'Forecast load identifier must be specified';
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
         var_message := var_message || chr(13) || 'Forecast load (' || var_load_identifier || ') does not exist or is already locked';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set upd_user = var_user,
             upd_date = sysdate
       where load_identifier = rcd_fcst_load_header.load_identifier;

      /*-*/
      /* Validate the forecast load
      /*-*/
      validate_load(rcd_fcst_load_header.load_identifier);

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
   end validate_load;

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
      var_sales_org_code fcst_load_header.sales_org_code%type;
      var_distbn_chnl_code fcst_load_header.distbn_chnl_code%type;
      var_division_code fcst_load_header.division_code%type;
      var_load_data_version fcst_load_header.load_data_version%type;
      var_load_data_range fcst_load_header.load_data_range%type;

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
      /* Retrieve the channel data
      /*-*/
      select dsv_value into var_sales_org_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_SALES_ORG_CODE'));
      select dsv_value into var_distbn_chnl_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_DISTBN_CHNL_CODE'));
      select dsv_value into var_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_DIVISION_CODE'));
      if var_sales_org_code is null then
         raise_application_error(-20000, 'Forecast domestic sales organisation code not set in the LICS data store');
      end if;
      if var_distbn_chnl_code is null then
         raise_application_error(-20000, 'Forecast domestic distribution channel code not set in the LICS data store');
      end if;
      if var_division_code is null then
         raise_application_error(-20000, 'Forecast domestic division code not set in the LICS data store');
      end if;

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
      rcd_fcst_load_header.load_plan_group := '*ALL';
      rcd_fcst_load_header.sales_org_code := var_sales_org_code;
      rcd_fcst_load_header.distbn_chnl_code := var_distbn_chnl_code;
      rcd_fcst_load_header.division_code := var_division_code;
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
          load_plan_group,
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
                rcd_fcst_load_header.load_plan_group,
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
                               par_load_plan_group in varchar2,
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
      var_load_plan_group fcst_load_header.load_plan_group%type;
      var_user fcst_load_header.crt_user%type;
      var_sales_org_code fcst_load_header.sales_org_code%type;
      var_distbn_chnl_code fcst_load_header.distbn_chnl_code%type;
      var_division_code fcst_load_header.division_code%type;
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

      cursor csr_fcst_plan_group is 
         select t01.*
           from fcst_plan_group t01
          where t01.plan_group = var_load_plan_group;
      rcd_fcst_plan_group csr_fcst_plan_group%rowtype;

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
      var_title := 'Forecast Maintenance - Create Forecast Load';
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
      var_load_plan_group := par_load_plan_group;
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
      if var_load_plan_group is null then
         var_message := var_message || chr(13) || 'Forecast load planning group must be specified';
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
      else
         if rcd_fcst_load_type.load_type_updatable != '1' then
            var_message := var_message || chr(13) || 'Forecast load type (' || rcd_fcst_load_header.load_type || ') is not updatable';
         end if;
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
      /* Validate the load plan group when required
      /*-*/
      if var_load_plan_group != '*ALL' then
         open csr_fcst_plan_group;
         fetch csr_fcst_plan_group into rcd_fcst_plan_group;
         if csr_fcst_plan_group%notfound then
            var_message := var_message || chr(13) || 'Forecast load plan group (' || var_load_plan_group || ') does not exist';
         end if;
         close csr_fcst_plan_group;
      end if;

      /*-*/
      /* Retrieve the channel data
      /*-*/
      if rcd_fcst_load_type.load_type_channel = '*DOMESTIC' then
         select dsv_value into var_sales_org_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_SALES_ORG_CODE'));
         select dsv_value into var_distbn_chnl_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_DISTBN_CHNL_CODE'));
         select dsv_value into var_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_DIVISION_CODE'));
         if var_sales_org_code is null then
            var_message := var_message || chr(13) || 'Forecast domestic sales organisation code not set in the LICS data store';
         end if;
         if var_distbn_chnl_code is null then
            var_message := var_message || chr(13) || 'Forecast domestic distribution channel code not set in the LICS data store';
         end if;
         if var_division_code is null then
            var_message := var_message || chr(13) || 'Forecast domestic division code not set in the LICS data store';
         end if;
      end if;
      if rcd_fcst_load_type.load_type_channel = '*AFFILIATE' then
         select dsv_value into var_sales_org_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_SALES_ORG_CODE'));
         select dsv_value into var_distbn_chnl_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_DISTBN_CHNL_CODE'));
         select dsv_value into var_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_DIVISION_CODE'));
         if var_sales_org_code is null then
            var_message := var_message || chr(13) || 'Forecast affiliate sales organisation code not set in the LICS data store';
         end if;
         if var_distbn_chnl_code is null then
            var_message := var_message || chr(13) || 'Forecast affiliate distribution channel code not set in the LICS data store';
         end if;
         if var_division_code is null then
            var_message := var_message || chr(13) || 'Forecast affiliate division code not set in the LICS data store';
         end if;
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
      rcd_fcst_load_header.load_plan_group := var_load_plan_group;
      rcd_fcst_load_header.sales_org_code := var_sales_org_code;
      rcd_fcst_load_header.distbn_chnl_code := var_distbn_chnl_code;
      rcd_fcst_load_header.division_code := var_division_code;
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
             load_plan_group,
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
                   rcd_fcst_load_header.load_plan_group,
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

   /**********************************************************/
   /* This procedure performs the update stream load routine */
   /**********************************************************/
   function update_stream_load(par_load_identifier in varchar2,
                               par_user in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      rcd_fcst_load_detail fcst_load_detail%rowtype;
      var_load_identifier fcst_load_header.load_identifier%type;
      var_user fcst_load_header.crt_user%type;
      var_available boolean;
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = var_load_identifier
            for update nowait;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_type is 
         select t01.*
           from fcst_load_type t01
          where t01.load_type = rcd_fcst_load_header.load_type;
      rcd_fcst_load_type csr_fcst_load_type%rowtype;

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
      var_title := 'Forecast Maintenance - Update Forecast Load';
      var_message := null;

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_load_identifier := upper(par_load_identifier);
      var_user := upper(par_user);
      if var_load_identifier is null then
         var_message := var_message || chr(13) || 'Forecast load identifier must be specified';
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
         var_message := var_message || chr(13) || 'Forecast load (' || var_load_identifier || ') does not exist or is already locked';
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
         var_message := var_message || chr(13) || 'Forecast load type (' || rcd_fcst_load_header.load_type || ') does not exist';
      else
         if rcd_fcst_load_type.load_type_updatable != '1' then
            var_message := var_message || chr(13) || 'Forecast load type (' || rcd_fcst_load_header.load_type || ') is not updatable';
         end if;
      end if;
      close csr_fcst_load_type;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Retrieve the stream data
      /*-*/
      read_xml_stream(rcd_fcst_load_type.load_type_version,rcd_fcst_load_header.load_data_type,rcd_fcst_load_header.load_data_version,rcd_fcst_load_header.load_data_range,lics_form.get_clob('LOAD_STREAM'));

      /*-*/
      /* Delete the existing forecast load detail
      /*-*/
      delete from fcst_load_detail where load_identifier = rcd_fcst_load_header.load_identifier;

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

      end loop;
      close csr_fcst_data;

      /*-*/
      /* Update the forecast load header
      /*-*/
      update fcst_load_header
         set upd_user = var_user,
             upd_date = sysdate
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
   end update_stream_load;

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
      var_load_identifier varchar2(4000);
      var_work_identifier fcst_load_header.load_identifier%type;
      var_user fcst_load_header.crt_user%type;
      var_title varchar2(128);
      var_message varchar2(4000);
      var_found boolean;
      var_value varchar2(256);
      var_count number;
      type rcd_load is record(load_identifier varchar2(256));
      type typ_load is table of rcd_load index by binary_integer;
      tbl_load typ_load;
      type rcd_extract is record(load_type varchar2(32), select_count number, all_count number);
      type typ_extract is table of rcd_extract index by binary_integer;
      tbl_extract typ_extract;
      type rcd_group is record(load_type varchar2(32), plan_group varchar2(32), select_count number);
      type typ_group is table of rcd_group index by binary_integer;
      tbl_group typ_group;

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

      cursor csr_fcst_plan_group is 
         select t01.*
           from fcst_plan_group t01;
      rcd_fcst_plan_group csr_fcst_plan_group%rowtype;

      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = var_work_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_mars_period is
         select t01.*
           from mars_date t01
          where mars_period = var_extract_version;
      rcd_mars_period csr_mars_period%rowtype;

      cursor csr_mars_year is
         select t01.*
           from mars_date t01
          where mars_year = var_extract_version;
      rcd_mars_year csr_mars_year%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Forecast Maintenance - Create Forecast Extract';
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
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Retrieve the extract type data version
      /*-*/
      if rcd_fcst_extract_type.extract_type_version = '*PERIOD' then
         open csr_mars_period;
         fetch csr_mars_period into rcd_mars_period;
         if csr_mars_period%notfound then
            var_message := var_message || chr(13) || 'Forecast extract version (' || to_char(var_extract_version) || ') does not exist as a Mars period in Mars Date Table';
         end if;
         close csr_mars_period;
      elsif rcd_fcst_extract_type.extract_type_version = '*YEAR' then
         open csr_mars_year;
         fetch csr_mars_year into rcd_mars_year;
         if csr_mars_year%notfound then
            var_message := var_message || chr(13) || 'Forecast extract version (' || to_char(var_extract_version) || ') does not exist as a Mars year in Mars Date Table';
         end if;
         close csr_mars_year;
      else
         var_message := var_message || chr(13) || 'Forecast extract version (' || rcd_fcst_extract_type.extract_type_version || ') is not recognised';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

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
         tbl_extract(tbl_extract.count).all_count := 0;
      end loop;
      close csr_fcst_extract_type_load;

      /*-*/
      /* Extract the planning groups
      /*-*/
      tbl_group.delete;
      for idx in 1..tbl_extract.count loop
         open csr_fcst_plan_group;
         loop
            fetch csr_fcst_plan_group into rcd_fcst_plan_group;
            if csr_fcst_plan_group%notfound then
               exit;
            end if;
            tbl_group(tbl_group.count+1).load_type := tbl_extract(idx).load_type;
            tbl_group(tbl_group.count).plan_group := rcd_fcst_plan_group.plan_group;
            tbl_group(tbl_group.count).select_count := 0;
         end loop;
         close csr_fcst_plan_group;
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
               if rcd_fcst_load_header.load_plan_group = '*ALL' then
                  tbl_extract(idy).all_count := tbl_extract(idy).all_count + 1;
               end if;
               var_found := true;
            end if;
         end loop;
         if var_found = false then
            var_message := var_message || chr(13) || 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') type (' || rcd_fcst_load_header.load_type || ') does not exist in extract load types';
         end if;

         /*-*/
         /* Update the forecast load planning group count when required
         /*-*/
         if rcd_fcst_load_header.load_plan_group != '*ALL' then
            for idy in 1..tbl_group.count loop
               if tbl_group(idy).load_type = rcd_fcst_load_header.load_type then
                  if tbl_group(idy).plan_group = rcd_fcst_load_header.load_plan_group then
                     tbl_group(idy).select_count := tbl_group(idy).select_count + 1;
                  end if;
               end if;
            end loop;
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

         /*-*/
         /* Forecast load planning group must match the extract planning group when required
         /*-*/
         if rcd_fcst_extract_type.extract_plan_group != '*ALL' then
            if rcd_fcst_load_header.load_plan_group != '*ALL' then
               if rcd_fcst_load_header.load_plan_group != rcd_fcst_extract_type.extract_plan_group then
                  var_message := var_message || chr(13) || 'Forecast load (' || rcd_fcst_load_header.load_identifier || ') planning group (' || to_char(rcd_fcst_load_header.load_plan_group) || ') does not match the extract planning group';
               end if;
            end if;
         end if;

      end loop;

      /*-*/
      /* Forecast extract load types must be selected
      /*-*/
      for idx in 1..tbl_extract.count loop
         if tbl_extract(idx).select_count = 0 then
            var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has no forecast load selected';
         end if;
      end loop;
      if rcd_fcst_extract_type.extract_plan_group != '*ALL' then
         for idx in 1..tbl_extract.count loop
            if tbl_extract(idx).select_count > 1 then
               var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has more than one forecast load specified';
            end if;
         end loop;
      else
         for idx in 1..tbl_extract.count loop
            var_count := 0;
            for idy in 1..tbl_group.count loop
               if tbl_extract(idx).load_type = tbl_group(idy).load_type then
                  var_count := var_count + tbl_group(idy).select_count;
               end if;
            end loop;
            if tbl_extract(idx).all_count != 0 then
               if var_count != 0 then
                  var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has both *ALL and other planning group forecast loads specified';
               else
                  if tbl_extract(idx).all_count > 1 then
                     var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has more than one *ALL planning group forecast load specified';
                  end if;
               end if;
            else
               for idy in 1..tbl_group.count loop
                  if tbl_extract(idx).load_type = tbl_group(idy).load_type then
                     if tbl_group(idy).select_count = 0 then
                        var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has no ' || tbl_group(idy).plan_group || ' planning group forecast load specified';
                     end if;
                     if tbl_group(idy).select_count > 1 then
                        var_message := var_message || chr(13) || 'Forecast extract load type (' || tbl_extract(idx).load_type || ') has more than one ' || tbl_group(idy).plan_group || ' planning group forecast load specified';
                     end if;
                  end if;
               end loop;
            end if;
         end loop;
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

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

   /******************************************************/
   /* This procedure performs the retrieve loads routine */
   /******************************************************/
   function retrieve_loads(par_extract_type in varchar2, par_extract_version in number) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_output varchar2(4000 char);
      var_extract_type fcst_extract_type.extract_type%type;
      var_extract_version fcst_extract_header.extract_version%type;

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
          where t01.load_type = rcd_fcst_extract_type_load.load_type
            and t01.load_data_version = var_extract_version
            and (rcd_fcst_extract_type.extract_plan_group = '*ALL' or
                 (rcd_fcst_extract_type.extract_plan_group != '*ALL' and (t01.load_plan_group = rcd_fcst_extract_type.extract_plan_group or t01.load_plan_group = '*ALL')))
            ; ------------------------------------------------------------------------------and t01.load_status = '*VALID';
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

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
      var_extract_type := upper(par_extract_type);
      var_extract_version := par_extract_version;
      if var_extract_type is null then
         raise_application_error(-20000, 'Forecast extract type must be specified');
      end if;
      if var_extract_version is null then
         raise_application_error(-20000, 'Forecast extract version must be specified');
      end if;

      /*-*/
      /* Retrieve the extract type
      /*-*/
      open csr_fcst_extract_type;
      fetch csr_fcst_extract_type into rcd_fcst_extract_type;
      if csr_fcst_extract_type%notfound then
         raise_application_error(-20000, 'Forecast extract type (' || var_extract_type || ') does not exist');
      end if;
      close csr_fcst_extract_type;

      /*-*/
      /* Retrieve the forecast extract type load typess
      /*-*/
      open csr_fcst_extract_type_load;
      loop
         fetch csr_fcst_extract_type_load into rcd_fcst_extract_type_load;
         if csr_fcst_extract_type_load%notfound then
            exit;
         end if;

         /*-*/
         /* Pipe the row
         /*-*/
         pipe row('*LOADTYPE'||chr(9)||rcd_fcst_extract_type_load.load_type);

         /*-*/
         /* Retrieve the forecast load headers
         /*-*/
         open csr_fcst_load_header;
         loop
            fetch csr_fcst_load_header into rcd_fcst_load_header;
            if csr_fcst_load_header%notfound then
               exit;
            end if;

            /*-*/
            /* Pipe the row
            /*-*/
            pipe row(rcd_fcst_extract_type_load.load_type||'@'||rcd_fcst_load_header.load_identifier||chr(9)||rcd_fcst_load_header.load_description||' ['||rcd_fcst_load_header.load_plan_group||']');

         end loop;
         close csr_fcst_load_header;

      end loop;
      close csr_fcst_extract_type_load;

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
         raise_application_error(-20000, 'DW_FCST_MAINTENANCE - RETRIEVE_LOADS - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_loads;

   /***************************************************/
   /* This procedure performs the export load routine */
   /***************************************************/
   function export_load(par_load_identifier in varchar2) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_load_identifier fcst_load_header.load_identifier%type;
      var_dmnd_group fcst_load_detail.dmnd_group%type;
      var_material_code fcst_load_detail.material_code%type;
      var_plant_code fcst_load_detail.plant_code%type;
      var_output varchar2(4000 char);
      var_work_yyyypp number;
      type rcd_datv is record(fcst_yyyypp number,
                              fcst_qty number,
                              fcst_gsv number);
      type typ_datv is table of rcd_datv index by binary_integer;
      tbl_datv typ_datv;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*
           from fcst_load_header t01
          where t01.load_identifier = var_load_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_row is
         select t01.dmnd_group,
                t01.material_code,
                t01.plant_code,
                t01.fcst_yyyypp,
                sum(t01.fcst_qty) as fcst_qty,
                sum(t01.fcst_gsv) as fcst_gsv
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_load_header.load_identifier
          group by t01.dmnd_group,
                   t01.material_code,
                   t01.plant_code,
                   t01.fcst_yyyypp
          order by t01.dmnd_group asc,
                   t01.material_code asc,
                   t01.plant_code asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_load_row csr_fcst_load_row%rowtype;

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
      var_load_identifier := upper(par_load_identifier);
      if var_load_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;

      /*-*/
      /* Retrieve the load header
      /*-*/
      open csr_fcst_load_header;
      fetch csr_fcst_load_header into rcd_fcst_load_header;
      if csr_fcst_load_header%notfound then
         raise_application_error(-20000, 'Forecast load (' || var_load_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Initialise the period range
      /*-*/
      tbl_datv.delete;
      var_work_yyyypp := rcd_fcst_load_header.load_str_yyyypp;
      for idx in 1..rcd_fcst_load_header.load_data_range loop
         tbl_datv(tbl_datv.count+1).fcst_yyyypp := var_work_yyyypp;
         tbl_datv(tbl_datv.count).fcst_qty := 0;
         tbl_datv(tbl_datv.count).fcst_gsv := 0;
         if substr(to_char(var_work_yyyypp,'fm000000'),5,2) = '13' then
            var_work_yyyypp := var_work_yyyypp + 88;
         else
            var_work_yyyypp := var_work_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Retrieve the forecast load rows
      /*-*/
      var_dmnd_group := null;
      var_material_code := null;
      var_plant_code := null;
      open csr_fcst_load_row;
      loop
         fetch csr_fcst_load_row into rcd_fcst_load_row;
         if csr_fcst_load_row%notfound then
            exit;
         end if;

         /*-*/
         /* Change in row
         /*-*/
         if var_dmnd_group is null or
            var_dmnd_group != rcd_fcst_load_row.dmnd_group or
            var_material_code != rcd_fcst_load_row.material_code or
            var_plant_code != rcd_fcst_load_row.plant_code then

            /*-*/
            /* Output the row when required
            /*-*/
            if not(var_dmnd_group is null) then

               /*-*/
               /* Output the row
               /*-*/
               var_output := var_dmnd_group;
               var_output := var_output||chr(9)||var_material_code;
               var_output := var_output||chr(9)||var_plant_code;
               for idx in 1..tbl_datv.count loop
                  var_output := var_output||chr(9)||to_char(tbl_datv(idx).fcst_qty);
               end loop;
               if rcd_fcst_load_header.load_data_type = '*QTY_GSV' then
                  for idx in 1..tbl_datv.count loop
                     var_output := var_output||chr(9)||to_char(tbl_datv(idx).fcst_gsv);
                  end loop;
               end if;
               pipe row(var_output);

            end if;

            /*-*/
            /* Initialise the row
            /*-*/
            var_dmnd_group := rcd_fcst_load_row.dmnd_group;
            var_material_code := rcd_fcst_load_row.material_code;
            var_plant_code := rcd_fcst_load_row.plant_code;
            for idx in 1..tbl_datv.count loop
               tbl_datv(idx).fcst_qty := 0;
               tbl_datv(idx).fcst_gsv := 0;
            end loop;

         end if;

         /*-*/
         /* Set the values
         /*-*/
         for idx in 1..tbl_datv.count loop
            if tbl_datv(idx).fcst_yyyypp = rcd_fcst_load_row.fcst_yyyypp then
               tbl_datv(idx).fcst_qty := rcd_fcst_load_row.fcst_qty;
               tbl_datv(idx).fcst_gsv := rcd_fcst_load_row.fcst_gsv;
               exit;
            end if;
         end loop;

      end loop;
      close csr_fcst_load_row;

      /*-*/
      /* Output the last row when required
      /*-*/
      if not(var_dmnd_group is null) then

         /*-*/
         /* Output the row
         /*-*/
         var_output := var_dmnd_group;
         var_output := var_output||chr(9)||var_material_code;
         var_output := var_output||chr(9)||var_plant_code;
         for idx in 1..tbl_datv.count loop
            var_output := var_output||chr(9)||to_char(tbl_datv(idx).fcst_qty);
         end loop;
         if rcd_fcst_load_header.load_data_type = '*QTY_GSV' then
            for idx in 1..tbl_datv.count loop
               var_output := var_output||chr(9)||to_char(tbl_datv(idx).fcst_gsv);
            end loop;
         end if;
         pipe row(var_output);

      end if;

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
         raise_application_error(-20000, 'DW_FCST_MAINTENANCE - EXPORT_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end export_load;

   /***************************************************/
   /* This procedure performs the report load routine */
   /***************************************************/
   function report_load(par_load_identifier in varchar2) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_load_identifier fcst_load_header.load_identifier%type;
      var_dmnd_group fcst_load_detail.dmnd_group%type;
      var_material_code fcst_load_detail.material_code%type;
      var_plant_code fcst_load_detail.plant_code%type;
      var_dmnd_group_desc varchar(256 char);
      var_material_desc varchar(256 char);
      var_output varchar2(4000 char);
      var_found boolean;
      var_work_yyyypp number;
      type rcd_datv is record(fcst_yyyypp number,
                              fcst_qty number,
                              fcst_prc number,
                              fcst_gsv number);
      type typ_datv is table of rcd_datv index by binary_integer;
      tbl_datv typ_datv;
      type typ_datm is table of varchar2(4000) index by binary_integer;
      tbl_datm typ_datm;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*,
                t02.load_type_channel
           from fcst_load_header t01,
                fcst_load_type t02
          where t01.load_type = t02.load_type(+)
            and t01.load_identifier = var_load_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_row is
         select t01.*
           from (select t01.dmnd_group,
                        t01.material_code,
                        t01.plant_code,
                        t01.fcst_yyyypp,
                        sum(t01.fcst_qty) as fcst_qty,
                        max(t01.fcst_prc) as fcst_prc,
                        sum(t01.fcst_gsv) as fcst_gsv,
                        max(t02.material_desc_zh) as material_desc_zh,
                        max(t02.material_desc_en) as material_desc_en,
                        max(t03.customer_desc) as customer_desc,
                        null as mesg_text
                   from fcst_load_detail t01,
                        (select lads_trim_code(t01.sap_material_code) as material_code,
                                max(case when t01.desc_language = 'ZH' then t01.material_desc end) material_desc_zh,
                                max(case when t01.desc_language = 'EN' then t01.material_desc end) material_desc_en
                           from bds_material_desc t01
                          where (t01.desc_language = 'ZH' or t01.desc_language = 'EN')
                          group by lads_trim_code(t01.sap_material_code)) t02,
                        (select lads_trim_code(t01.customer_code) as customer_code,
                                t01.name as customer_desc
                           from bds_addr_customer t01
                          where t01.address_version = '*NONE') t03
                  where t01.load_identifier = rcd_fcst_load_header.load_identifier
                    and t01.material_code = t02.material_code(+)
                    and t01.dmnd_group = t03.customer_code(+)
                  group by t01.dmnd_group,
                           t01.material_code,
                           t01.plant_code,
                           t01.fcst_yyyypp
                  union all
                 select t01.dmnd_group,
                        t01.material_code,
                        t01.plant_code,
                        999999 as fcst_yyyypp,
                        0 as fcst_qty,
                        0 as fcst_prc,
                        0 as fcst_gsv,
                        null as material_desc_zh,
                        null as material_desc_en,
                        null as customer_desc,
                        t01.mesg_text
                   from fcst_load_detail t01
                  where t01.load_identifier = rcd_fcst_load_header.load_identifier
                    and not(t01.mesg_text is null)
                  group by t01.dmnd_group,
                           t01.material_code,
                           t01.plant_code,
                           t01.mesg_text) t01
          order by t01.dmnd_group asc,
                   t01.material_code asc,
                   t01.plant_code asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_load_row csr_fcst_load_row%rowtype;

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
      var_load_identifier := upper(par_load_identifier);
      if var_load_identifier is null then
         raise_application_error(-20000, 'Forecast load identifier must be specified');
      end if;

      /*-*/
      /* Retrieve the load header
      /*-*/
      open csr_fcst_load_header;
      fetch csr_fcst_load_header into rcd_fcst_load_header;
      if csr_fcst_load_header%notfound then
         raise_application_error(-20000, 'Forecast load (' || var_load_identifier || ') does not exist');
      end if;
      close csr_fcst_load_header;

      /*-*/
      /* Initialise the period range
      /*-*/
      tbl_datv.delete;
      var_work_yyyypp := rcd_fcst_load_header.load_str_yyyypp;
      for idx in 1..rcd_fcst_load_header.load_data_range loop
         tbl_datv(tbl_datv.count+1).fcst_yyyypp := var_work_yyyypp;
         tbl_datv(tbl_datv.count).fcst_qty := 0;
         tbl_datv(tbl_datv.count).fcst_prc := 0;
         tbl_datv(tbl_datv.count).fcst_gsv := 0;
         if substr(to_char(var_work_yyyypp,'fm000000'),5,2) = '13' then
            var_work_yyyypp := var_work_yyyypp + 88;
         else
            var_work_yyyypp := var_work_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1 cellpadding="0" cellspacing="0">');
      pipe row('<tr>');
      pipe row('<td align=center colspan='||to_char(rcd_fcst_load_header.load_data_range+5)||' style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Load Report - ('||rcd_fcst_load_header.load_identifier||') '||rcd_fcst_load_header.load_description||'</td>');
      pipe row('</tr>');
      pipe row('<tr>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Demand Group/Customer</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Plant</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Data</td>');
      for idx in 1..tbl_datv.count loop
         pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(tbl_datv(idx).fcst_yyyypp)||'</td>');
      end loop;
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Messages</td>');
      pipe row('</tr>');

      /*-*/
      /* Retrieve the forecast load rows
      /*-*/
      var_dmnd_group := null;
      var_material_code := null;
      var_plant_code := null;
      open csr_fcst_load_row;
      loop
         fetch csr_fcst_load_row into rcd_fcst_load_row;
         if csr_fcst_load_row%notfound then
            exit;
         end if;

         /*-*/
         /* Change in row
         /*-*/
         if var_dmnd_group is null or
            var_dmnd_group != rcd_fcst_load_row.dmnd_group or
            var_material_code != rcd_fcst_load_row.material_code or
            var_plant_code != rcd_fcst_load_row.plant_code then

            /*-*/
            /* Output the row when required
            /*-*/
            if not(var_dmnd_group is null) then

               /*-*/
               /* Quantity row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td rowspan=3 valign=top align=left>'||var_dmnd_group_desc||'</td>';
               var_output := var_output||'<td rowspan=3 valign=top align=left>'||var_material_desc||'</td>';
               var_output := var_output||'<td rowspan=3 valign=top align=left>'||var_plant_code||'</td>';
               var_output := var_output||'<td align=center>QTY</td>';
               for idx in 1..tbl_datv.count loop
                  var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_qty,2))||'</td>';
               end loop;
               pipe row(var_output);

               /*-*/
               /* Messages
               /*-*/
               var_found := false;
               for idx in 1..tbl_datm.count loop
                  if var_found = false then
                     pipe row('<td rowspan=3 valign=top align=left>'||tbl_datm(idx));
                     var_found := true;
                  else
                     pipe row(chr(10)||tbl_datm(idx));
                  end if;
               end loop;
               if var_found = true then
                  pipe row('</td>');
               else
                  pipe row('<td rowspan=3 valign=top align=left></td>');
               end if;

               /*-*/
               /* Quantity row
               /*-*/
               pipe row('</tr>');

               /*-*/
               /* Price row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td align=center>PRICE</td>';
               for idx in 1..tbl_datv.count loop
                  var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_prc,2))||'</td>';
               end loop;
               var_output := var_output||'</tr>';
               pipe row(var_output);

               /*-*/
               /* GSV row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td align=center>GSV</td>';
               for idx in 1..tbl_datv.count loop
                  var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_gsv,2))||'</td>';
               end loop;
               var_output := var_output||'</tr>';
               pipe row(var_output);

            end if;

            /*-*/
            /* Initialise the row
            /*-*/
            var_dmnd_group := rcd_fcst_load_row.dmnd_group;
            var_material_code := rcd_fcst_load_row.material_code;
            var_plant_code := rcd_fcst_load_row.plant_code;
            if rcd_fcst_load_header.load_type_channel != '*AFFILIATE' then
               var_dmnd_group_desc := rcd_fcst_load_row.dmnd_group;
            else
               var_dmnd_group_desc := '('||rcd_fcst_load_row.dmnd_group||')';
               if not(rcd_fcst_load_row.customer_desc is null) then
                  var_dmnd_group_desc := var_dmnd_group_desc||' '||rcd_fcst_load_row.customer_desc;
               else
                  var_dmnd_group_desc := var_dmnd_group_desc||' UNKNOWN';
               end if;
            end if;
            var_material_desc := '('||rcd_fcst_load_row.material_code||')';
            if not(rcd_fcst_load_row.material_desc_zh is null) then
               var_material_desc := var_material_desc||' '||rcd_fcst_load_row.material_desc_zh;
            elsif not(rcd_fcst_load_row.material_desc_en is null) then
               var_material_desc := var_material_desc||' '||rcd_fcst_load_row.material_desc_en;
            else
               var_material_desc := var_material_desc||' UNKNOWN';
            end if;
            for idx in 1..tbl_datv.count loop
               tbl_datv(idx).fcst_qty := 0;
               tbl_datv(idx).fcst_prc := 0;
               tbl_datv(idx).fcst_gsv := 0;
            end loop;
            tbl_datm.delete;

         end if;

         /*-*/
         /* Set the values
         /*-*/
         if rcd_fcst_load_row.fcst_yyyypp != 999999 then
            for idx in 1..tbl_datv.count loop
               if tbl_datv(idx).fcst_yyyypp = rcd_fcst_load_row.fcst_yyyypp then
                  tbl_datv(idx).fcst_qty := rcd_fcst_load_row.fcst_qty;
                  tbl_datv(idx).fcst_prc := rcd_fcst_load_row.fcst_prc;
                  tbl_datv(idx).fcst_gsv := rcd_fcst_load_row.fcst_gsv;
                  exit;
               end if;
            end loop;
         else
            tbl_datm(tbl_datm.count+1) := rcd_fcst_load_row.mesg_text;
         end if;

      end loop;
      close csr_fcst_load_row;

      /*-*/
      /* Output the last row when required
      /*-*/
      if not(var_dmnd_group is null) then

         /*-*/
         /* Quantity row
         /*-*/
         var_output := '<tr>';
         var_output := var_output||'<td rowspan=3 valign=top align=left>'||var_dmnd_group_desc||'</td>';
         var_output := var_output||'<td rowspan=3 valign=top align=left>'||var_material_desc||'</td>';
         var_output := var_output||'<td rowspan=3 valign=top align=left>'||var_plant_code||'</td>';
         var_output := var_output||'<td align=center>QTY</td>';
         for idx in 1..tbl_datv.count loop
            var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_qty,2))||'</td>';
         end loop;
         pipe row(var_output);

         /*-*/
         /* Messages
         /*-*/
         var_found := false;
         for idx in 1..tbl_datm.count loop
            if var_found = false then
               pipe row('<td rowspan=3 valign=top align=left>'||tbl_datm(idx));
               var_found := true;
            else
               pipe row(chr(10)||tbl_datm(idx));
            end if;
         end loop;
         if var_found = true then
            pipe row('</td>');
         else
            pipe row('<td rowspan=3 valign=top align=left></td>');
         end if;

         /*-*/
         /* Quantity row
         /*-*/
         pipe row('</tr>');

         /*-*/
         /* Price row
         /*-*/
         var_output := '<tr>';
         var_output := var_output||'<td align=center>PRICE</td>';
         for idx in 1..tbl_datv.count loop
            var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_prc,2))||'</td>';
         end loop;
         var_output := var_output||'</tr>';
         pipe row(var_output);

         /*-*/
         /* GSV row
         /*-*/
         var_output := '<tr>';
         var_output := var_output||'<td align=center>GSV</td>';
         for idx in 1..tbl_datv.count loop
            var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_gsv,2))||'</td>';
         end loop;
         var_output := var_output||'</tr>';
         pipe row(var_output);

      end if;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');

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
         raise_application_error(-20000, 'DW_FCST_MAINTENANCE - REPORT_LOAD - ' || substr(SQLERRM, 1, 1024));

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
      var_load_str_yyyypp fcst_load_header.load_str_yyyypp%type;
      var_load_end_yyyypp fcst_load_header.load_end_yyyypp%type;
      var_material_code fcst_load_detail.material_code%type;
      var_plant_code fcst_load_detail.plant_code%type;
      var_output varchar2(4000 char);
      var_found boolean;
      var_work_yyyypp number;
      type rcd_datv is record(fcst_yyyypp number,
                              fcst_qty number,
                              fcst_gsv number);
      type typ_datv is table of rcd_datv index by binary_integer;
      tbl_datv typ_datv;

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
         select t02.*
           from fcst_extract_load t01,
                fcst_load_header t02
          where t01.load_identifier = t02.load_identifier(+)
            and t01.extract_identifier = rcd_fcst_extract_header.extract_identifier;
      rcd_fcst_extract_load csr_fcst_extract_load%rowtype;

      cursor csr_fcst_load_row is
         select t01.material_code,
                t01.plant_code,
                t01.fcst_yyyypp,
                sum(t01.fcst_qty) as fcst_qty,
                sum(t01.fcst_gsv) as fcst_gsv
           from fcst_load_detail t01
          where t01.load_identifier in (select load_identifier
                                          from fcst_extract_load
                                         where extract_identifier = rcd_fcst_extract_header.extract_identifier)
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
          group by t01.material_code,
                   t01.plant_code,
                   t01.fcst_yyyypp
          order by t01.material_code asc,
                   t01.plant_code asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_load_row csr_fcst_load_row%rowtype;

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
      /* Retrieve the forecast extract loads
      /*-*/
      var_load_str_yyyypp := 999999;
      var_load_end_yyyypp := 0;
      open csr_fcst_extract_load;
      loop
         fetch csr_fcst_extract_load into rcd_fcst_extract_load;
         if csr_fcst_extract_load%notfound then
            exit;
         end if;
         if rcd_fcst_extract_load.load_str_yyyypp < var_load_str_yyyypp then
            var_load_str_yyyypp := rcd_fcst_extract_load.load_str_yyyypp;
         end if;
         if rcd_fcst_extract_load.load_end_yyyypp > var_load_end_yyyypp then
            var_load_end_yyyypp := rcd_fcst_extract_load.load_end_yyyypp;
         end if;
      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* Initialise the period range
      /*-*/
      tbl_datv.delete;
      var_work_yyyypp := var_load_str_yyyypp;
      loop
         if var_work_yyyypp > var_load_end_yyyypp then
            exit;
         end if;
         tbl_datv(tbl_datv.count+1).fcst_yyyypp := var_work_yyyypp;
         tbl_datv(tbl_datv.count).fcst_qty := 0;
         tbl_datv(tbl_datv.count).fcst_gsv := 0;
         if substr(to_char(var_work_yyyypp,'fm000000'),5,2) = '13' then
            var_work_yyyypp := var_work_yyyypp + 88;
         else
            var_work_yyyypp := var_work_yyyypp + 1;
         end if;
      end loop;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1 cellpadding="0" cellspacing="0">');
      pipe row('<tr>');
      pipe row('<td align=center colspan='||to_char(tbl_datv.count+3)||' style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Extract Report - ('||rcd_fcst_extract_header.extract_identifier||') '||rcd_fcst_extract_header.extract_description||'</td>');
      pipe row('</tr>');
      pipe row('<tr>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Code</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Plant</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Data</td>');
      for idx in 1..tbl_datv.count loop
         pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(tbl_datv(idx).fcst_yyyypp)||'</td>');
      end loop;
      pipe row('</tr>');

      /*-*/
      /* Retrieve the forecast load rows
      /*-*/
      var_material_code := null;
      var_plant_code := null;
      open csr_fcst_load_row;
      loop
         fetch csr_fcst_load_row into rcd_fcst_load_row;
         if csr_fcst_load_row%notfound then
            exit;
         end if;

         /*-*/
         /* Change in row
         /*-*/
         if var_material_code is null or
            var_material_code != rcd_fcst_load_row.material_code or
            var_plant_code != rcd_fcst_load_row.plant_code then

            /*-*/
            /* Output the row when required
            /*-*/
            if not(var_material_code is null) then

               /*-*/
               /* Quantity row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_code||'</td>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_plant_code||'</td>';
               var_output := var_output||'<td align=center>QTY</td>';
               for idx in 1..tbl_datv.count loop
                  var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_qty,2))||'</td>';
               end loop;
               var_output := var_output||'</tr>';
               pipe row(var_output);

               /*-*/
               /* GSV row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td align=center>GSV</td>';
               for idx in 1..tbl_datv.count loop
                  var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_gsv,2))||'</td>';
               end loop;
               var_output := var_output||'</tr>';
               pipe row(var_output);

            end if;

            /*-*/
            /* Initialise the row
            /*-*/
            var_material_code := rcd_fcst_load_row.material_code;
            var_plant_code := rcd_fcst_load_row.plant_code;
            for idx in 1..tbl_datv.count loop
               tbl_datv(idx).fcst_qty := 0;
               tbl_datv(idx).fcst_gsv := 0;
            end loop;

         end if;

         /*-*/
         /* Set the values
         /*-*/
         for idx in 1..tbl_datv.count loop
            if tbl_datv(idx).fcst_yyyypp = rcd_fcst_load_row.fcst_yyyypp then
               tbl_datv(idx).fcst_qty := rcd_fcst_load_row.fcst_qty;
               tbl_datv(idx).fcst_gsv := rcd_fcst_load_row.fcst_gsv;
               exit;
            end if;
         end loop;

      end loop;
      close csr_fcst_load_row;

      /*-*/
      /* Output the last row when required
      /*-*/
      if not(var_material_code is null) then

         /*-*/
         /* Quantity row
         /*-*/
         var_output := '<tr>';
         var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_code||'</td>';
         var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_plant_code||'</td>';
         var_output := var_output||'<td align=center>QTY</td>';
         for idx in 1..tbl_datv.count loop
            var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_qty,2))||'</td>';
         end loop;
         var_output := var_output||'</tr>';
         pipe row(var_output);

         /*-*/
         /* GSV row
         /*-*/
         var_output := '<tr>';
         var_output := var_output||'<td align=center>GSV</td>';
         for idx in 1..tbl_datv.count loop
            var_output := var_output||'<td align=right>'||to_char(round(tbl_datv(idx).fcst_gsv,2))||'</td>';
         end loop;
         var_output := var_output||'</tr>';
         pipe row(var_output);

      end if;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');

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
         raise_application_error(-20000, 'DW_FCST_MAINTENANCE - REPORT_EXTRACT - ' || substr(SQLERRM, 1, 1024));

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
      var_material_save varchar2(128 char);
      var_customer_save varchar2(128 char);
      var_price_vakey varchar2(128 char);
      var_price_kschl varchar2(128 char);
      var_vakey varchar2(128 char);
      var_kschl varchar2(128 char);
      var_wrk_yyyypp number;
      type rcd_wrkv is record(yyyypp number, price number);
      type tab_wrkv is table of rcd_wrkv index by binary_integer;
      tbl_wrkn tab_wrkv;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_load_header is 
         select t01.*,
                t02.load_type_channel
           from fcst_load_header t01,
                fcst_load_type t02
          where t01.load_type = t02.load_type(+)
            and t01.load_identifier = par_load_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is
         select t01.*,
                nvl(t02.sap_material_code,'*NULL') as sap_material_code,
                t02.matl_code,
                t02.matl_status,
                decode(t02.bus_sgmnt_code,'01','*SNACK','05','*PET','*NONE') as new_plan_group,
                nvl(t03.sap_customer_code,'*NULL') as sap_customer_code,
                t03.cust_code,
                t03.cust_status
           from fcst_load_detail t01,
                (select t01.sap_material_code as sap_material_code,
                        lads_trim_code(t01.sap_material_code) as matl_code,
                        decode(t01.deletion_flag,'X','INACTIVE','ACTIVE') as matl_status,
                        t02.sap_bus_sgmnt_code as bus_sgmnt_code
                   from bds_material_hdr t01,
                        bds_material_classfctn t02
                  where t01.sap_material_code = t02.sap_material_code(+)) t02,
                (select t01.customer_code as sap_customer_code,
                        lads_trim_code(t01.customer_code) as cust_code,
                        decode(t01.deletion_flag,'X','INACTIVE','ACTIVE') as cust_status
                   from bds_cust_header t01) t03
          where t01.material_code = t02.matl_code(+)
            and t01.dmnd_group = t03.cust_code(+)
            and t01.load_identifier = rcd_fcst_load_header.load_identifier
          order by t02.sap_material_code asc,
                   t03.sap_customer_code asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

      cursor csr_material_price is
         select t03.mars_period as str_yyyypp,
                nvl(t04.mars_period,999999) as end_yyyypp,
                ((t01.kbetr/t01.kpein)*nvl(t02.umren,1))/nvl(t02.umrez,1) as material_price 
           from (select t01.matnr,
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
                    and t01.vakey = var_vakey
                    and t01.kschl = var_kschl) t01,
                lads_mat_uom t02,
                mars_date t03,
                mars_date t04
          where t01.matnr = t02.matnr(+)
            and t01.kmein = t02.meinh(+)
            and t01.datab = t03.calendar_date
            and t01.datbi = t04.calendar_date(+)
            and (t03.mars_period <= rcd_fcst_load_header.load_str_yyyypp or
                 (t04.mars_period is null or t04.mars_period >= rcd_fcst_load_header.load_end_yyyypp));
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
      /* Retrieve the price settings
      /*-*/
      if upper(rcd_fcst_load_header.load_type_channel) != '*AFFILIATE' then
         select dsv_value into var_price_vakey from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_PRICE_VAKEY'));
         select dsv_value into var_price_kschl from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_PRICE_KSCHL'));
      else
         select dsv_value into var_price_vakey from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_PRICE_VAKEY'));
         select dsv_value into var_price_kschl from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_PRICE_KSCHL'));
      end if;

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
      var_customer_save := '*NONE';
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
            if upper(rcd_fcst_load_header.load_type_channel) != '*AFFILIATE' then
               if rcd_fcst_load_detail.sap_material_code != var_material_save then
                  for idx in 1..tbl_wrkn.count loop
                     tbl_wrkn(idx).price := 0;
	          end loop;
                  if rcd_fcst_load_detail.sap_material_code != '*NULL' then
                     var_vakey := var_price_vakey||' '||rcd_fcst_load_detail.sap_material_code;
                     var_kschl := var_price_kschl;
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
                  end if;
                  var_material_save := rcd_fcst_load_detail.sap_material_code;
               end if;
            else
               if rcd_fcst_load_detail.sap_material_code != var_material_save or
                  rcd_fcst_load_detail.sap_customer_code != var_customer_save then
                  for idx in 1..tbl_wrkn.count loop
                     tbl_wrkn(idx).price := 0;
	          end loop;
                  if rcd_fcst_load_detail.sap_material_code != '*NULL' and
                     rcd_fcst_load_detail.sap_customer_code != '*NULL' then
                     var_vakey := var_price_vakey||rcd_fcst_load_detail.sap_customer_code||rcd_fcst_load_detail.sap_material_code;
                     var_kschl := var_price_kschl;
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
                  end if;
                  var_material_save := rcd_fcst_load_detail.sap_material_code;
                  var_customer_save := rcd_fcst_load_detail.sap_customer_code;
               end if;
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
         else
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
               rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - is not a valid planning group material';
               var_errors := true;
            else
               if rcd_fcst_load_header.load_plan_group != '*ALL' and rcd_fcst_load_detail.new_plan_group != rcd_fcst_load_header.load_plan_group then
                  if rcd_fcst_load_detail.mesg_text is null then
                     rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
                  end if;
                  rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - does not match the loader header planning group ('||rcd_fcst_load_header.load_plan_group||')';
                  var_errors := true;
               end if;
            end if;
         end if;

         /*-*/
         /* Validate the forecast customer when required
         /*-*/
         if upper(rcd_fcst_load_header.load_type_channel) = '*AFFILIATE' then
            if rcd_fcst_load_detail.cust_code is null then
               if rcd_fcst_load_detail.mesg_text is null then
                  rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
               end if;
               rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - Customer ('||rcd_fcst_load_detail.dmnd_group||') does not exist in LADS';
               var_errors := true;
            else
               if rcd_fcst_load_detail.cust_status != 'ACTIVE' then
                  if rcd_fcst_load_detail.mesg_text is null then
                     rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
                  end if;
                  rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - Customer ('||rcd_fcst_load_detail.dmnd_group||') is not active in LADS';
                  var_errors := true;
               end if;
            end if;
         end if;

         /*-*/
         /* Validate the forecast data
         /*-*/
         if upper(rcd_fcst_load_header.load_type_channel) != '*AFFILIATE' then
            if rcd_fcst_load_detail.fcst_qty = 0 then
               if rcd_fcst_load_detail.mesg_text is null then
                  rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
               end if;
               rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - does not have a forecast quantity for period '||to_Char(rcd_fcst_load_detail.fcst_yyyypp);
               var_errors := true;
            end if;
            if not(rcd_fcst_load_detail.matl_code is null) then
               if rcd_fcst_load_detail.fcst_prc = 0 then
                  if rcd_fcst_load_detail.mesg_text is null then
                     rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
                  end if;
                  rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - does not have pricing data for period '||to_Char(rcd_fcst_load_detail.fcst_yyyypp);
                  var_errors := true;
               end if;
            end if;
         else
            if rcd_fcst_load_detail.fcst_qty = 0 then
               if rcd_fcst_load_detail.mesg_text is null then
                  rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
               end if;
               rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - Customer ('||rcd_fcst_load_detail.dmnd_group||') does not have a forecast quantity for period '||to_Char(rcd_fcst_load_detail.fcst_yyyypp);
               var_errors := true;
            end if;
            if not(rcd_fcst_load_detail.matl_code is null) and not(rcd_fcst_load_detail.cust_code is null) then
               if rcd_fcst_load_detail.fcst_prc = 0 then
                  if rcd_fcst_load_detail.mesg_text is null then
                     rcd_fcst_load_detail.mesg_text := 'Material ('||rcd_fcst_load_detail.material_code||')';
                  end if;
                  rcd_fcst_load_detail.mesg_text := rcd_fcst_load_detail.mesg_text||' - Customer ('||rcd_fcst_load_detail.dmnd_group||') does not have pricing data for period '||to_Char(rcd_fcst_load_detail.fcst_yyyypp);
                  var_errors := true;
               end if;
            end if;
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
            rcd_fcst_data.plant_code := '*ROW';
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
                     elsif rcd_fcst_data.plant_code = '*ROW' then
                        if length(var_value) > 4 then
                           raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Plant code ('||var_value||') exceeds maximum length 4');
                        end if;
                        rcd_fcst_data.plant_code := upper(var_value);
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
                     raise_application_error(-20000, 'Text file data (quantity only) row '||var_wrkr||' - Column count must be equal to ' || to_char(par_data_range + 3));
                  end if;
               end if;
               if par_data_type = '*QTY_GSV' then
                  if var_index != par_data_range + par_data_range then
                     raise_application_error(-20000, 'Text file data (quantity/gsv) row '||var_wrkr||' - Column count must be equal to ' || to_char(par_data_range + par_data_range + 3));
                  end if;
               end if;
               for idx in 1..par_data_range loop
                  rcd_fcst_data.fcst_qty := tbl_wrkw(idx);
                  rcd_fcst_data.fcst_prc := 0;
                  rcd_fcst_data.fcst_gsv := 0;
                  if par_data_type = '*QTY_GSV' then
                     rcd_fcst_data.fcst_gsv := tbl_wrkw(idx+par_data_range);
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
