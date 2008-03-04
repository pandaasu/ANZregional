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

    5. ACCEPT_PERIOD_LOAD

       This procedure is used to accept the forecast period load and update the operational data store.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created from Mars Japan version and modified for Mars China

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure delete_load(par_identifier in varchar2);
   procedure create_planning_load(par_cast_date in varchar2);

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
   /* This procedure performs the create planning load routine */
   /************************************************************/
   procedure create_planning_load(par_cast_date in varchar2) is

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
      var_cast_yyyypp rcd_fcst_load_header.cast_yyyypp%type;
      var_cast_yyyyppw rcd_fcst_load_header.cast_yyyyppw%type;

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

      /*-*/
      /* Initialise the forecast load header
      /*-*/
      rcd_fcst_load_header.load_identifier := 'BR_DOMESTIC_'||var_cast_yyyymmdd;
      rcd_fcst_load_header.load_description := 'Apollo Domestic Business Review Forecasts';
      rcd_fcst_load_header.load_status := '*CREATING';
      rcd_fcst_load_header.load_type := '*BR';
      rcd_fcst_load_header.load_data := '*DOMESTIC';
      rcd_fcst_load_header.cast_yyyymmdd := var_cast_yyyymmdd;
      rcd_fcst_load_header.cast_yyyyppw := var_cast_yyyyppw;
      rcd_fcst_load_header.cast_yyyypp := var_cast_yyyypp;
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
          load_data,
          cast_yyyymmdd,
          cast_yyyyppw,
          cast_yyyypp,
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
                rcd_fcst_load_header.load_data,
                rcd_fcst_load_header.cast_yyyymmdd,
                rcd_fcst_load_header.cast_yyyyppw,
                rcd_fcst_load_header.cast_yyyypp,
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
         raise_application_error(-20000, 'DW_FORECAST_LOADING - CREATE_PLANNING_LOAD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_planning_load;

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
