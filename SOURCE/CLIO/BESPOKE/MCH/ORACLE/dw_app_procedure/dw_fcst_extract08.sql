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
   procedure export(par_extract_identifier in varchar2);

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
   procedure export(par_extract_identifier in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_extract_identifier fcst_extract_header.extract_identifier%type;
      var_aff_cust_code varchar2(256);
      var_aff_gsv_code varchar2(256);
      var_aff_vol_code varchar2(256);
      var_output varchar2(4000);
      type typ_outbound is table of varchar2(4000) index by binary_integer;
      tbl_outbound typ_outbound;

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
         select t01.*,
                t02.srce_code
                t03.dest_code
           from fcst_load_detail t01,
                (select lads_trim_code(t01.matnr) as material_code,
                        t01.werks as plant_code
                        max(t02.zzfppsmoe) as srce_code
                   from lads_mat_mrc t01,
                        lads_mat_zmc t02
                  where t01.matnr = t02.matnr
                    and t01.mrcseq = t02.mrcseq
                  group by t01.matnr,
                           t01.werks) t02,
                (select lads_trim_code(t01.customer_code) as cust_code,
                        t01.location as dest_code
                   from bds_cust_header t01) t03
          where t01.material_code = t02.material_code(+)
            and t01.plant_code = t02.plant_code(+)
            and t01.dmnd_group = t03.cust_code(+)
            and t01.load_identifier = rcd_fcst_extract_load.load_identifier
            and (rcd_fcst_extract_header.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_header.extract_plan_group)
          order by t01.material_code asc,
                   t01.dmnd_group asc,
                   t01.fcst_yyyypp asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

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
      /* Clear the outbound array
      /*-*/
      tbl_outbound.delete;

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

5103034        393            BJ             GC                                      15498                                2007            -181.955              65.858         1358797.696          463339.896          445882.242          463008.469         

material = 15
source = 15
destination = 15
customer = 40
line item = 40

P01 - p13 = 20

            /*-*/
            /* Output the interface data
            /*-*/
            if rcd_fcst_load_detail.fcst_yyyypp >= rcd_fcst_extract_header.extract_version then
               var_output := '"' || rcd_fcst_load_detail.material_code || '"';
               var_output := var_output || ',"' || rcd_fcst_load_detail.plant_code || '"';
               var_output := var_output || ',"' || rcd_fcst_load_detail.cover_yyyymmdd || '"';
               var_output := var_output || ',"' || to_char(rcd_fcst_load_detail.cover_day) || 'D' || '"';
               var_output := var_output || ',"' || to_char(tbl_outbound.count+1,'fm000000000') || '"';
               var_output := var_output || ',"' || to_char(var_tot_count,'fm000000000') || '"';
               var_output := var_output || ',"' || to_char(sysdate,'yyyymmddhh24miss') || '"';
               tbl_outbound(tbl_outbound.count+1) := var_output;
            end if;

         end loop;
         close csr_fcst_load_detail;

      end loop;
      close csr_fcst_extract_load;

      /*-*/
      /* Create the outbound interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('ODSAPL01',null,'ODSAPL.DAT');

      /*-*/
      /* Append the interface data
      /*-*/
      for idx in 1..tbl_outbound.count loop
         lics_outbound_loader.append_data(tbl_outbound(idx));
      end loop;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

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
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 1024));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT07 - EXPORT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end export;

end dw_fcst_extract08;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_extract08 for dw_app.dw_fcst_extract08;
grant execute on dw_fcst_extract08 to public;
