/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_extract08 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_extract08
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Extract - FPPS Affiliate Extract

    This package contains the FPPS procedure.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function export(par_extract_identifier in varchar2) return dw_fcst_table pipelined;
   function report(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

end dw_fcst_extract08;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_extract08 as

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
      var_aff_cust_code varchar2(256);
      var_aff_gsv_code varchar2(256);
      var_aff_vol_code varchar2(256);
      var_output varchar2(4000);

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
         select t01.*,
                t02.load_type_channel
           from fcst_load_header t01,
                fcst_load_type t02
          where t01.load_type = t02.load_type(+)
            and t01.load_identifier = rcd_fcst_extract_load.load_identifier;
      rcd_fcst_load_header csr_fcst_load_header%rowtype;

      cursor csr_fcst_load_detail is
         select t01.material_code,
                t02.srce_code,
                t03.dest_code,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '01' then t01.fcst_gsv end) w01_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '02' then t01.fcst_gsv end) w02_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '03' then t01.fcst_gsv end) w03_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '04' then t01.fcst_gsv end) w04_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '05' then t01.fcst_gsv end) w05_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '06' then t01.fcst_gsv end) w06_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '07' then t01.fcst_gsv end) w07_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '08' then t01.fcst_gsv end) w08_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '09' then t01.fcst_gsv end) w09_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '10' then t01.fcst_gsv end) w10_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '11' then t01.fcst_gsv end) w11_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '12' then t01.fcst_gsv end) w12_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '13' then t01.fcst_gsv end) w13_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '01' then t01.fcst_qty end) w01_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '02' then t01.fcst_qty end) w02_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '03' then t01.fcst_qty end) w03_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '04' then t01.fcst_qty end) w04_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '05' then t01.fcst_qty end) w05_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '06' then t01.fcst_qty end) w06_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '07' then t01.fcst_qty end) w07_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '08' then t01.fcst_qty end) w08_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '09' then t01.fcst_qty end) w09_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '10' then t01.fcst_qty end) w10_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '11' then t01.fcst_qty end) w11_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '12' then t01.fcst_qty end) w12_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '13' then t01.fcst_qty end) w13_qty
           from (select t01.material_code,
                        t01.plant_code,
                        t01.dmnd_group,
                        t01.fcst_yyyypp,
                        t01.fcst_gsv,
                        t01.fcst_qty
                   from fcst_load_detail t01
                  where t01.load_identifier = rcd_fcst_extract_load.load_identifier
                    and to_number(substr(to_char(t01.fcst_yyyypp,'fm000000'),1,4)) = rcd_fcst_load_header.load_data_version
                    and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                         t01.plan_group = rcd_fcst_extract_header.extract_plan_group)) t01,
                (select lads_trim_code(t01.matnr) as material_code,
                        t01.werks as plant_code,
                        max(t02.zzfppsmoe) as srce_code
                   from lads_mat_mrc t01,
                        lads_mat_zmc t02
                  where t01.matnr = t02.matnr
                    and t01.mrcseq = t02.mrcseq
                  group by t01.matnr,
                           t01.werks) t02,
                (select lads_trim_code(t01.customer_code) as cust_code,
                        t01.location_code as dest_code
                   from bds_cust_header t01) t03
          where t01.material_code = t02.material_code(+)
            and t01.plant_code = t02.plant_code(+)
            and t01.dmnd_group = t03.cust_code(+)
          group by t01.material_code,
                   t02.srce_code,
                   t03.dest_code
          order by t01.material_code asc,
                   t02.srce_code asc,
                   t03.dest_code asc;
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
      /* Retrieve the FPPS settings
      /*-*/
      select dsv_value into var_aff_cust_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','FPPS_AFF_CUST_CODE'));
      select dsv_value into var_aff_gsv_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','FPPS_AFF_GSV_CODE'));
      select dsv_value into var_aff_vol_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','FPPS_AFF_VOL_CODE'));

      /*-*/
      /* Pipe the header row
      /*-*/
      var_output := 'item,source,destination,customer,line item,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13';
      pipe row(var_output);

      /*-*/
      /* Retrieve the forecast extract loads (GSV)
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
            /* Pipe the detail row
            /*-*/
            var_output := rcd_fcst_load_detail.material_code;
            var_output := var_output || ',' || nvl(rcd_fcst_load_detail.srce_code,'000');
            var_output := var_output || ',' || nvl(rcd_fcst_load_detail.dest_code,'000');
            var_output := var_output || ',' || var_aff_cust_code;
            var_output := var_output || ',' || var_aff_gsv_code;
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w01_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w02_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w03_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w04_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w05_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w06_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w07_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w08_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w09_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w10_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w11_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w12_gsv,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w13_gsv,2));
            pipe row(var_output);

         end loop;
         close csr_fcst_load_detail;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* Retrieve the forecast extract loads (VOL)
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
            /* Pipe the detail row when required
            /*-*/
            var_output := rcd_fcst_load_detail.material_code;
            var_output := var_output || ',' || rcd_fcst_load_detail.srce_code;
            var_output := var_output || ',' || nvl(rcd_fcst_load_detail.dest_code,'000');
            var_output := var_output || ',' || var_aff_cust_code;
            var_output := var_output || ',' || var_aff_vol_code;
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w01_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w02_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w03_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w04_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w05_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w06_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w07_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w08_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w09_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w10_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w11_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w12_qty,2));
            var_output := var_output || ',' || to_char(round(rcd_fcst_load_detail.w13_qty,2));
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
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT07 - EXPORT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end export;

   /******************************************************/
   /* This procedure performs the extract report routine */
   /******************************************************/
   function report(par_extract_identifier in varchar2) return dw_fcst_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_aff_cust_code varchar2(256);
      var_aff_gsv_code varchar2(256);
      var_aff_vol_code varchar2(256);
      var_material_desc varchar(256 char);
      var_output varchar2(4000 char);

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
         select t02.*,
                t03.load_type_channel
           from fcst_extract_load t01,
                fcst_load_header t02,
                fcst_load_type t03
          where t01.load_identifier = t02.load_identifier(+)
            and t02.load_type = t03.load_type(+)
            and t01.extract_identifier = rcd_fcst_extract_header.extract_identifier
          order by t02.load_identifier;
      rcd_fcst_extract_load csr_fcst_extract_load%rowtype;

      cursor csr_fcst_load is
         select t01.material_code,
                t02.srce_code,
                t03.dest_code,
                max(t04.material_desc_zh) as material_desc_zh,
                max(t04.material_desc_en) as material_desc_en,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '01' then t01.fcst_gsv end) w01_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '02' then t01.fcst_gsv end) w02_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '03' then t01.fcst_gsv end) w03_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '04' then t01.fcst_gsv end) w04_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '05' then t01.fcst_gsv end) w05_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '06' then t01.fcst_gsv end) w06_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '07' then t01.fcst_gsv end) w07_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '08' then t01.fcst_gsv end) w08_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '09' then t01.fcst_gsv end) w09_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '10' then t01.fcst_gsv end) w10_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '11' then t01.fcst_gsv end) w11_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '12' then t01.fcst_gsv end) w12_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '13' then t01.fcst_gsv end) w13_gsv,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '01' then t01.fcst_qty end) w01_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '02' then t01.fcst_qty end) w02_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '03' then t01.fcst_qty end) w03_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '04' then t01.fcst_qty end) w04_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '05' then t01.fcst_qty end) w05_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '06' then t01.fcst_qty end) w06_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '07' then t01.fcst_qty end) w07_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '08' then t01.fcst_qty end) w08_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '09' then t01.fcst_qty end) w09_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '10' then t01.fcst_qty end) w10_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '11' then t01.fcst_qty end) w11_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '12' then t01.fcst_qty end) w12_qty,
                sum(case when substr(to_char(t01.fcst_yyyypp,'fm000000'),5,2) = '13' then t01.fcst_qty end) w13_qty
           from (select t01.material_code,
                        t01.plant_code,
                        t01.dmnd_group,
                        t01.fcst_yyyypp,
                        t01.fcst_gsv,
                        t01.fcst_qty
                   from fcst_load_detail t01
                  where t01.load_identifier = rcd_fcst_extract_load.load_identifier
                    and to_number(substr(to_char(t01.fcst_yyyypp,'fm000000'),1,4)) = rcd_fcst_extract_load.load_data_version
                    and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                         t01.plan_group = rcd_fcst_extract_header.extract_plan_group)) t01,
                (select lads_trim_code(t01.matnr) as material_code,
                        t01.werks as plant_code,
                        max(t02.zzfppsmoe) as srce_code
                   from lads_mat_mrc t01,
                        lads_mat_zmc t02
                  where t01.matnr = t02.matnr
                    and t01.mrcseq = t02.mrcseq
                  group by t01.matnr,
                           t01.werks) t02,
                (select lads_trim_code(t01.customer_code) as cust_code,
                        t01.location_code as dest_code
                   from bds_cust_header t01) t03,
                (select lads_trim_code(t01.sap_material_code) as material_code,
                        max(case when t01.desc_language = 'ZH' then t01.material_desc end) material_desc_zh,
                        max(case when t01.desc_language = 'EN' then t01.material_desc end) material_desc_en
                   from bds_material_desc t01
                  where (t01.desc_language = 'ZH' or t01.desc_language = 'EN')
                  group by lads_trim_code(t01.sap_material_code)) t04
          where t01.material_code = t02.material_code(+)
            and t01.plant_code = t02.plant_code(+)
            and t01.dmnd_group = t03.cust_code(+)
            and t01.material_code = t04.material_code(+)
          group by t01.material_code,
                   t02.srce_code,
                   t03.dest_code
          order by t01.material_code asc,
                   t02.srce_code asc,
                   t03.dest_code asc;
      rcd_fcst_load csr_fcst_load%rowtype;

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
      /* Retrieve the FPPS domestic settings
      /*-*/
      select dsv_value into var_aff_cust_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','FPPS_AFF_CUST_CODE'));
      select dsv_value into var_aff_gsv_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','FPPS_AFF_GSV_CODE'));
      select dsv_value into var_aff_vol_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','FPPS_AFF_VOL_CODE'));

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1 cellpadding="0" cellspacing="0">');
      pipe row('<tr>');
      pipe row('<td align=center colspan=19 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Extract Report - ('||rcd_fcst_extract_header.extract_identifier||') '||rcd_fcst_extract_header.extract_description||'</td>');
      pipe row('</tr>');
      pipe row('<tr>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Load</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Code</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">FPPS Source</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">FPPS Destination</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">FPPS Customer</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">FPPS Line Item</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'01</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'02</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'03</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'04</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'05</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'06</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'07</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'08</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'09</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'10</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'11</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'12</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(rcd_fcst_extract_header.extract_version)||'13</td>');
      pipe row('</tr>');

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
         /* Retrieve the forecast load rows
         /*-*/
         open csr_fcst_load;
         loop
            fetch csr_fcst_load into rcd_fcst_load;
            if csr_fcst_load%notfound then
               exit;
            end if;

            /*-*/
            /* Material description
            /*-*/
            var_material_desc := '('||rcd_fcst_load.material_code||')';
            if not(rcd_fcst_load.material_desc_zh is null) then
               var_material_desc := var_material_desc||' '||rcd_fcst_load.material_desc_zh;
            elsif not(rcd_fcst_load.material_desc_en is null) then
               var_material_desc := var_material_desc||' '||rcd_fcst_load.material_desc_en;
            else
               var_material_desc := var_material_desc||' UNKNOWN';
            end if;

            /*-*/
            /* Quantity row
            /*-*/
            var_output := '<tr>';
            var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
            var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_desc||'</td>';
            var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_load.srce_code||'</td>';
            var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_load.dest_code||'</td>';
            var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_aff_cust_code||'</td>';
            var_output := var_output||'<td align=center>QTY ('||var_aff_vol_code||')</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w01_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w02_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w03_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w04_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w05_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w06_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w07_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w08_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w09_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w10_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w11_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w12_qty,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w13_qty,2))||'</td>';
            var_output := var_output||'</tr>';
            pipe row(var_output);

            /*-*/
            /* GSV row
            /*-*/
            var_output := '<tr>';
            var_output := var_output||'<td align=center>GSV ('||var_aff_gsv_code||')</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w01_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w02_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w03_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w04_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w05_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w06_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w07_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w08_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w09_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w10_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w11_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w12_gsv,2))||'</td>';
            var_output := var_output||'<td align=right>'||to_char(round(rcd_fcst_load.w13_gsv,2))||'</td>';
            var_output := var_output||'</tr>';
            pipe row(var_output);

         end loop;
         close csr_fcst_load;

      end loop;
      close csr_fcst_extract_load;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT08 - REPORT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report;

end dw_fcst_extract08;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_extract08 for dw_app.dw_fcst_extract08;
grant execute on dw_fcst_extract08 to public;
