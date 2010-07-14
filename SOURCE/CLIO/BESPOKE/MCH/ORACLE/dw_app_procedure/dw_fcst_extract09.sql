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
    2008/05   Steve Gregan   Changed customer description logic
    2009/08   Steve Gregan   Changed division code based on planning group

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function export(par_extract_identifier in varchar2) return dw_fcst_table pipelined;
   function report(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

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
      var_type varchar2(32 char);
      var_version varchar2(32 char);
      var_planner varchar2(32 char);
      var_dom_division_code varchar2(32 char);
      var_aff_division_code varchar2(32 char);

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

      cursor csr_fcst_load_detail_01 is 
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
      rcd_fcst_load_detail_01 csr_fcst_load_detail_01%rowtype;

      cursor csr_fcst_load_detail_02 is 
         select t01.fcst_yyyypp,
                t01.plant_code,
                t01.dmnd_group,
                t01.material_code,
                sum(t01.fcst_qty) as fcst_qty,
                sum(t01.fcst_gsv) as fcst_gsv
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_extract_load.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
          group by t01.fcst_yyyypp,
                   t01.plant_code,
                   t01.dmnd_group,
                   t01.material_code
          order by t01.fcst_yyyypp asc,
                   t01.plant_code asc,
                   t01.dmnd_group asc,
                   t01.material_code asc;
      rcd_fcst_load_detail_02 csr_fcst_load_detail_02%rowtype;

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
      /* Retrieve the plan group division data
      /*-*/
      if upper(rcd_fcst_extract_header.extract_plan_group) = '*SNACK' then
         select dsv_value into var_dom_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_SNK_DIVISION_CODE'));
         select dsv_value into var_aff_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_SNK_DIVISION_CODE'));
         if var_dom_division_code is null then
            raise_application_error(-20000, 'Forecast domestic SNACK division code not set in the LICS data store');
         end if;
         if var_aff_division_code is null then
            raise_application_error(-20000, 'Forecast affiliate SNACK division code not set in the LICS data store');
         end if;
      end if;
      if upper(rcd_fcst_extract_header.extract_plan_group) = '*PET' then
         select dsv_value into var_dom_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','DOM_PET_DIVISION_CODE'));
         select dsv_value into var_aff_division_code from table(lics_datastore.retrieve_value('CHINA','CHINA_FCST','AFF_PET_DIVISION_CODE'));
         if var_dom_division_code is null then
            raise_application_error(-20000, 'Forecast domestic PET division code not set in the LICS data store');
         end if;
         if var_aff_division_code is null then
            raise_application_error(-20000, 'Forecast affiliate PET division code not set in the LICS data store');
         end if;
      end if;

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
      /* Retrieve the forecast extract loads (CN_FCS_OFL output)
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
         /* Domestic load
         /*-*/
         if upper(rcd_fcst_load_header.load_type_channel) != '*AFFILIATE' then

            /*-*/
            /* Retrieve the forecast load detail
            /*-*/
            open csr_fcst_load_detail_01;
            loop
               fetch csr_fcst_load_detail_01 into rcd_fcst_load_detail_01;
               if csr_fcst_load_detail_01%notfound then
                  exit;
               end if;

               /*-*/
               /* Set the control data
               /*-*/
               var_type := 'CN_FCS_OFL';
               var_version := substr(to_char(rcd_fcst_load_detail_01.fcst_yyyypp,'fm000000'),1,4)||'P';
               if substr(to_char(rcd_fcst_load_detail_01.fcst_yyyypp,'fm000000'),5,1) = '0' then
                  var_version := var_version||substr(to_char(rcd_fcst_load_detail_01.fcst_yyyypp,'fm000000'),6,1);
               else
                  var_version := var_version||substr(to_char(rcd_fcst_load_detail_01.fcst_yyyypp,'fm000000'),5,2);
               end if;
               var_planner := rcd_fcst_extract_header.extract_planner;

               /*-*/
               /* Pipe the detail row when required
               /*-*/
               if rcd_fcst_load_detail_01.fcst_yyyypp >= rcd_fcst_extract_header.extract_version then
                  var_output := var_type;
                  var_output := var_output || chr(9) || var_version;
                  var_output := var_output || chr(9) || var_planner;
                  var_output := var_output || chr(9) || to_char(rcd_fcst_load_detail_01.fcst_yyyypp,'fm000000');
                  var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_header.distbn_chnl_code;
                  var_output := var_output || chr(9) || var_dom_division_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_01.plant_code;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_01.material_code;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || 'EA';
                  var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_01.fcst_qty,2));
                  var_output := var_output || chr(9) || 'CNY';
                  var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_01.fcst_gsv,2));
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  pipe row(var_output);
               end if;

            end loop;
            close csr_fcst_load_detail_01;

         /*-*/
         /* Affiliate load
         /*-*/
         else

            /*-*/
            /* Retrieve the forecast load detail
            /*-*/
            open csr_fcst_load_detail_02;
            loop
               fetch csr_fcst_load_detail_02 into rcd_fcst_load_detail_02;
               if csr_fcst_load_detail_02%notfound then
                  exit;
               end if;

               /*-*/
               /* Set the control data
               /*-*/
               var_type := 'CN_FCS_OFL';
               var_version := substr(to_char(rcd_fcst_load_detail_02.fcst_yyyypp,'fm000000'),1,4)||'P';
               if substr(to_char(rcd_fcst_load_detail_02.fcst_yyyypp,'fm000000'),5,1) = '0' then
                  var_version := var_version||substr(to_char(rcd_fcst_load_detail_02.fcst_yyyypp,'fm000000'),6,1);
               else
                  var_version := var_version||substr(to_char(rcd_fcst_load_detail_02.fcst_yyyypp,'fm000000'),5,2);
               end if;
               var_planner := rcd_fcst_extract_header.extract_planner;

               /*-*/
               /* Pipe the detail row when required
               /*-*/
               if rcd_fcst_load_detail_02.fcst_yyyypp >= rcd_fcst_extract_header.extract_version then
                  var_output := var_type;
                  var_output := var_output || chr(9) || var_version;
                  var_output := var_output || chr(9) || var_planner;
                  var_output := var_output || chr(9) || to_char(rcd_fcst_load_detail_02.fcst_yyyypp,'fm000000');
                  var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_header.distbn_chnl_code;
                  var_output := var_output || chr(9) || var_aff_division_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_02.plant_code;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_02.dmnd_group;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_02.dmnd_group;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_02.dmnd_group;
                  var_output := var_output || chr(9) || rcd_fcst_load_detail_02.material_code;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || 'EA';
                  var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_02.fcst_qty,2));
                  var_output := var_output || chr(9) || 'CNY';
                  var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_02.fcst_gsv,2));
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  var_output := var_output || chr(9) || null;
                  pipe row(var_output);
               end if;

            end loop;
            close csr_fcst_load_detail_02;

         end if;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* Retrieve the forecast extract loads (CN_FCS_HST output)
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
         /* Domestic load
         /*-*/
         if upper(rcd_fcst_load_header.load_type_channel) != '*AFFILIATE' then

            /*-*/
            /* Retrieve the forecast load detail
            /*-*/
            open csr_fcst_load_detail_01;
            loop
               fetch csr_fcst_load_detail_01 into rcd_fcst_load_detail_01;
               if csr_fcst_load_detail_01%notfound then
                  exit;
               end if;

               /*-*/
               /* Set the control data
               /*-*/
               var_type := 'CN_FCS_HST';
               var_version := substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),1,4)||'P';
               if substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),5,1) = '0' then
                  var_version := var_version||substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),6,1);
               else
                  var_version := var_version||substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),5,2);
               end if;
               var_planner := rcd_fcst_extract_header.extract_planner;

               /*-*/
               /* Pipe the detail row
               /*-*/
               var_output := var_type;
               var_output := var_output || chr(9) || var_version;
               var_output := var_output || chr(9) || var_planner;
               var_output := var_output || chr(9) || to_char(rcd_fcst_load_detail_01.fcst_yyyypp,'fm000000');
               var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.distbn_chnl_code;
               var_output := var_output || chr(9) || var_dom_division_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_01.plant_code;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_01.material_code;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || 'EA';
               var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_01.fcst_qty,2));
               var_output := var_output || chr(9) || 'CNY';
               var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_01.fcst_gsv,2));
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               pipe row(var_output);

            end loop;
            close csr_fcst_load_detail_01;

         /*-*/
         /* Affiliate load
         /*-*/
         else

            /*-*/
            /* Retrieve the forecast load detail
            /*-*/
            open csr_fcst_load_detail_02;
            loop
               fetch csr_fcst_load_detail_02 into rcd_fcst_load_detail_02;
               if csr_fcst_load_detail_02%notfound then
                  exit;
               end if;

               /*-*/
               /* Set the control data
               /*-*/
               var_type := 'CN_FCS_HST';
               var_version := substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),1,4)||'P';
               if substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),5,1) = '0' then
                  var_version := var_version||substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),6,1);
               else
                  var_version := var_version||substr(to_char(rcd_fcst_extract_header.extract_version,'fm000000'),5,2);
               end if;
               var_planner := rcd_fcst_extract_header.extract_planner;

               /*-*/
               /* Pipe the detail row
               /*-*/
               var_output := var_type;
               var_output := var_output || chr(9) || var_version;
               var_output := var_output || chr(9) || var_planner;
               var_output := var_output || chr(9) || to_char(rcd_fcst_load_detail_02.fcst_yyyypp,'fm000000');
               var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.distbn_chnl_code;
               var_output := var_output || chr(9) || var_aff_division_code;
               var_output := var_output || chr(9) || rcd_fcst_load_header.sales_org_code;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_02.plant_code;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_02.dmnd_group;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_02.dmnd_group;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_02.dmnd_group;
               var_output := var_output || chr(9) || rcd_fcst_load_detail_02.material_code;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || 'EA';
               var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_02.fcst_qty,2));
               var_output := var_output || chr(9) || 'CNY';
               var_output := var_output || chr(9) || to_char(round(rcd_fcst_load_detail_02.fcst_gsv,2));
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               var_output := var_output || chr(9) || null;
               pipe row(var_output);

            end loop;
            close csr_fcst_load_detail_02;

         end if;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT01 - EXPORT - ' || substr(SQLERRM, 1, 1024));

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
      var_load_str_yyyypp fcst_load_header.load_str_yyyypp%type;
      var_load_end_yyyypp fcst_load_header.load_end_yyyypp%type;
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

      cursor csr_fcst_load_01 is
         select t01.material_code,
                t01.plant_code,
                t01.fcst_yyyypp,
                t01.fcst_qty as fcst_qty,
                t01.fcst_gsv as fcst_gsv,
                t02.material_desc_zh,
                t02.material_desc_en
           from fcst_load_detail t01,
                (select lads_trim_code(t01.sap_material_code) as material_code,
                        max(case when t01.desc_language = 'ZH' then t01.material_desc end) material_desc_zh,
                        max(case when t01.desc_language = 'EN' then t01.material_desc end) material_desc_en
                   from bds_material_desc t01
                  where (t01.desc_language = 'ZH' or t01.desc_language = 'EN')
                  group by lads_trim_code(t01.sap_material_code)) t02
          where t01.material_code = t02.material_code(+)
            and t01.load_identifier = rcd_fcst_extract_load.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
          order by t01.material_code asc,
                   t01.plant_code asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_load_01 csr_fcst_load_01%rowtype;

      cursor csr_fcst_load_02 is
         select t01.dmnd_group,
                t01.material_code,
                t01.plant_code,
                t01.fcst_yyyypp,
                t01.fcst_qty as fcst_qty,
                t01.fcst_gsv as fcst_gsv,
                t02.material_desc_zh,
                t02.material_desc_en,
                t03.customer_desc_zh,
                t03.customer_desc_en
           from fcst_load_detail t01,
                (select lads_trim_code(t01.sap_material_code) as material_code,
                        max(case when t01.desc_language = 'ZH' then t01.material_desc end) material_desc_zh,
                        max(case when t01.desc_language = 'EN' then t01.material_desc end) material_desc_en
                   from bds_material_desc t01
                  where (t01.desc_language = 'ZH' or t01.desc_language = 'EN')
                  group by lads_trim_code(t01.sap_material_code)) t02,
                (select lads_trim_code(t01.customer_code) as customer_code,
                        max(case when t01.address_version = 'I' then t01.name end) customer_desc_zh,
                        max(case when t01.address_version = '*NONE' then t01.name end) customer_desc_en
                   from bds_addr_customer t01
                  where (t01.address_version = 'I' or t01.address_version = '*NONE')
                  group by lads_trim_code(t01.customer_code)) t03
          where t01.material_code = t02.material_code(+)
            and t01.dmnd_group = t03.customer_code(+)
            and t01.load_identifier = rcd_fcst_extract_load.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
          order by t01.dmnd_group asc,
                   t01.material_code asc,
                   t01.plant_code asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_load_02 csr_fcst_load_02%rowtype;

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
      pipe row('<td align=center colspan='||to_char(tbl_datv.count+5)||' style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Extract Report - ('||rcd_fcst_extract_header.extract_identifier||') '||rcd_fcst_extract_header.extract_description||'</td>');
      pipe row('</tr>');
      pipe row('<tr>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Load</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Customer Code</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Code</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Plant</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Data</td>');
      for idx in 1..tbl_datv.count loop
         pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">'||to_char(tbl_datv(idx).fcst_yyyypp)||'</td>');
      end loop;
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
         /* Domestic load
         /*-*/
         if upper(rcd_fcst_extract_load.load_type_channel) != '*AFFILIATE' then

            /*-*/
            /* Retrieve the forecast load rows
            /*-*/
            var_material_code := null;
            var_plant_code := null;
            open csr_fcst_load_01;
            loop
               fetch csr_fcst_load_01 into rcd_fcst_load_01;
               if csr_fcst_load_01%notfound then
                  exit;
               end if;

               /*-*/
               /* Change in row
               /*-*/
               if var_material_code is null or
                  var_material_code != rcd_fcst_load_01.material_code or
                  var_plant_code != rcd_fcst_load_01.plant_code then

                  /*-*/
                  /* Output the row when required
                  /*-*/
                  if not(var_material_code is null) then

                     /*-*/
                     /* Quantity row
                     /*-*/
                     var_output := '<tr>';
                     var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
                     var_output := var_output||'<td rowspan=2 valign=top align=left></td>';
                     var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_desc||'</td>';
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
                  var_material_code := rcd_fcst_load_01.material_code;
                  var_plant_code := rcd_fcst_load_01.plant_code;
                  var_material_desc := '('||rcd_fcst_load_01.material_code||')';
                  if not(rcd_fcst_load_01.material_desc_zh is null) then
                     var_material_desc := var_material_desc||' '||rcd_fcst_load_01.material_desc_zh;
                  elsif not(rcd_fcst_load_01.material_desc_en is null) then
                     var_material_desc := var_material_desc||' '||rcd_fcst_load_01.material_desc_en;
                  else
                     var_material_desc := var_material_desc||' NO DESCRIPTION';
                  end if;
                  for idx in 1..tbl_datv.count loop
                     tbl_datv(idx).fcst_qty := 0;
                     tbl_datv(idx).fcst_gsv := 0;
                  end loop;

               end if;

               /*-*/
               /* Set the values
               /*-*/
               for idx in 1..tbl_datv.count loop
                  if tbl_datv(idx).fcst_yyyypp = rcd_fcst_load_01.fcst_yyyypp then
                     tbl_datv(idx).fcst_qty := tbl_datv(idx).fcst_qty + rcd_fcst_load_01.fcst_qty;
                     tbl_datv(idx).fcst_gsv := tbl_datv(idx).fcst_gsv + rcd_fcst_load_01.fcst_gsv;
                     exit;
                  end if;
               end loop;

            end loop;
            close csr_fcst_load_01;

            /*-*/
            /* Output the last row when required
            /*-*/
            if not(var_dmnd_group is null) then

               /*-*/
               /* Quantity row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_dmnd_group_desc||'</td>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_desc||'</td>';
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
         /* Affiliate load
         /*-*/
         else

            /*-*/
            /* Retrieve the forecast load rows
            /*-*/
            var_dmnd_group := null;
            var_material_code := null;
            var_plant_code := null;
            open csr_fcst_load_02;
            loop
               fetch csr_fcst_load_02 into rcd_fcst_load_02;
               if csr_fcst_load_02%notfound then
                  exit;
               end if;

               /*-*/
               /* Change in row
               /*-*/
               if var_dmnd_group is null or
                  var_dmnd_group != rcd_fcst_load_02.dmnd_group or
                  var_material_code != rcd_fcst_load_02.material_code or
                  var_plant_code != rcd_fcst_load_02.plant_code then

                  /*-*/
                  /* Output the row when required
                  /*-*/
                  if not(var_dmnd_group is null) then

                     /*-*/
                     /* Quantity row
                     /*-*/
                     var_output := '<tr>';
                     var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
                     var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_dmnd_group_desc||'</td>';
                     var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_desc||'</td>';
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
                  var_dmnd_group := rcd_fcst_load_02.dmnd_group;
                  var_material_code := rcd_fcst_load_02.material_code;
                  var_plant_code := rcd_fcst_load_02.plant_code;
                  var_dmnd_group_desc := '('||rcd_fcst_load_02.dmnd_group||')';
                  if not(rcd_fcst_load_02.customer_desc_zh is null) then
                     var_dmnd_group_desc := var_dmnd_group_desc||' '||rcd_fcst_load_02.customer_desc_zh;
                  elsif not(rcd_fcst_load_02.customer_desc_en is null) then
                     var_dmnd_group_desc := var_dmnd_group_desc||' '||rcd_fcst_load_02.customer_desc_en;
                  else
                     var_dmnd_group_desc := var_dmnd_group_desc||' NO DESCRIPTION';
                  end if;
                  var_material_desc := '('||rcd_fcst_load_02.material_code||')';
                  if not(rcd_fcst_load_02.material_desc_zh is null) then
                     var_material_desc := var_material_desc||' '||rcd_fcst_load_02.material_desc_zh;
                  elsif not(rcd_fcst_load_02.material_desc_en is null) then
                     var_material_desc := var_material_desc||' '||rcd_fcst_load_02.material_desc_en;
                  else
                     var_material_desc := var_material_desc||' NO DESCRIPTION';
                  end if;
                  for idx in 1..tbl_datv.count loop
                     tbl_datv(idx).fcst_qty := 0;
                     tbl_datv(idx).fcst_gsv := 0;
                  end loop;

               end if;

               /*-*/
               /* Set the values
               /*-*/
               for idx in 1..tbl_datv.count loop
                  if tbl_datv(idx).fcst_yyyypp = rcd_fcst_load_02.fcst_yyyypp then
                     tbl_datv(idx).fcst_qty := tbl_datv(idx).fcst_qty + rcd_fcst_load_02.fcst_qty;
                     tbl_datv(idx).fcst_gsv := tbl_datv(idx).fcst_gsv + rcd_fcst_load_02.fcst_gsv;
                     exit;
                  end if;
               end loop;

            end loop;
            close csr_fcst_load_02;

            /*-*/
            /* Output the last row when required
            /*-*/
            if not(var_dmnd_group is null) then

               /*-*/
               /* Quantity row
               /*-*/
               var_output := '<tr>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_dmnd_group_desc||'</td>';
               var_output := var_output||'<td rowspan=2 valign=top align=left>'||var_material_desc||'</td>';
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

         end if;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT01 - REPORT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report;

end dw_fcst_extract01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_extract01 for dw_app.dw_fcst_extract01;
grant execute on dw_fcst_extract01 to public;
