/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_extract06 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_extract06
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Extract - Apollo Affiliate Extract

    This package contains the Apollo Affiliate procedure.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure export(par_batch_code in varchar2);
   function report(par_extract_identifier in varchar2) return dw_fcst_table pipelined;

end dw_fcst_extract06;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_extract06 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**********************************************/
   /* This procedure performs the export routine */
   /**********************************************/
   procedure export(par_batch_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_batch_code fcst_extract_type.extract_format%type;
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_instance number(15,0);
      var_output varchar2(4000);
      type typ_outbound is table of varchar2(4000) index by binary_integer;
      tbl_outbound typ_outbound;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_extract_type is 
         select t01.*
           from fcst_extract_type t01
          where upper(t01.extract_format) = var_batch_code;
      rcd_fcst_extract_type csr_fcst_extract_type%rowtype;

      cursor csr_fcst_extract_header is 
         select t01.*
           from fcst_extract_header t01
          where t01.extract_type = rcd_fcst_extract_type.extract_type
          order by t01.crt_date desc;
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
         select t01.*
           from fcst_load_detail t01
          where t01.load_identifier = rcd_fcst_extract_load.load_identifier
            and (rcd_fcst_extract_type.extract_plan_group = '*ALL' or
                 t01.plan_group = rcd_fcst_extract_type.extract_plan_group)
          order by t01.material_code asc,
                   t01.plant_code asc,
                   t01.cover_yyyymmdd asc;
      rcd_fcst_load_detail csr_fcst_load_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      var_batch_code := upper(par_batch_code);
      if var_batch_code is null then
         raise_application_error(-20000, 'Forecast extract batch code must be specified');
      end if;

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'DW - FCST_APOLLO_EXTRACT';
      var_log_search := 'FCST_APOLLO_EXTRACT';

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Apollo Forecast Extract - Parameters(' || var_batch_code || ')');

      /*-*/
      /* Clear the outbound array
      /*-*/
      tbl_outbound.delete;

      /*-*/
      /* Retrieve the extract types for the batch code
      /*-*/
      open csr_fcst_extract_type;
      loop
         fetch csr_fcst_extract_type into rcd_fcst_extract_type;
         if csr_fcst_extract_type%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the latest forecast extract header for the extract type
         /*-*/
         open csr_fcst_extract_header;
         fetch csr_fcst_extract_header into rcd_fcst_extract_header;
         if csr_fcst_extract_header%found then

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
               /* Interface sent
               /*-*/
               lics_logging.write_log('Extracting load ('||rcd_fcst_extract_load.load_identifier||')');

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
                  /* Output the interface data
                  /*-*/
                  if rcd_fcst_load_detail.fcst_yyyypp >= rcd_fcst_extract_header.extract_version then
                     var_output := '"' || rcd_fcst_load_detail.material_code || '"';
                     var_output := var_output || ',"' || rcd_fcst_load_detail.plant_code || '"';
                     var_output := var_output || ',"' || rcd_fcst_load_detail.cover_yyyymmdd || '"';
                     var_output := var_output || ',"' || to_char(rcd_fcst_load_detail.cover_day) || 'D' || '"';
                     var_output := var_output || ',"' || to_char(rcd_fcst_load_detail.fcst_qty) || '"';
                     var_output := var_output || ',"' || to_char(tbl_outbound.count+1,'fm000000000') || '"';
                     var_output := var_output || ',"<TOTCOUNT>"';
                     var_output := var_output || ',"' || to_char(sysdate,'yyyymmddhh24miss') || '"';
                     tbl_outbound(tbl_outbound.count+1) := var_output;
                  end if;

               end loop;
               close csr_fcst_load_detail;

            end loop;
            close csr_fcst_extract_load;

         end if;
         close csr_fcst_extract_header;

      end loop;
      close csr_fcst_extract_type;

      /*-*/
      /* Process the data when required
      /*-*/
      if tbl_outbound.count != 0 then

         /*-*/
         /* Create the outbound interface
         /*-*/
         var_instance := lics_outbound_loader.create_interface('ODSAPL01',null,'IN_AP_CDW_DEMAND_SUP_STG_DWHAPL06.1.dat');

         /*-*/
         /* Append the interface data
         /*-*/
         for idx in 1..tbl_outbound.count loop
            lics_outbound_loader.append_data(replace(tbl_outbound(idx),'<TOTCOUNT>',to_char(tbl_outbound.count,'fm000000000')));
         end loop;

         /*-*/
         /* Finalise the interface
         /*-*/
         lics_outbound_loader.finalise_interface;

         /*-*/
         /* Interface sent
         /*-*/
         lics_logging.write_log('Interface Sent - Record Count ('||to_char(tbl_outbound.count,'fm000000000')||')');

      else

         /*-*/
         /* Interface sent
         /*-*/
         lics_logging.write_log('Interface NOT sent - no data');

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Apollo Forecast Extract');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT06 - EXPORT - ' || var_exception);

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
      var_material_code fcst_load_detail.material_code%type;
      var_plant_code fcst_load_detail.plant_code%type;
      var_cover_yyyymmdd fcst_load_detail.cover_yyyymmdd%type;
      var_cover_day fcst_load_detail.cover_day%type;
      var_cover_qty fcst_load_detail.fcst_qty%type;
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
                t01.plant_code,
                t01.cover_yyyymmdd,
                t01.cover_day,
                t01.fcst_qty as fcst_qty,
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
                   t01.cover_yyyymmdd asc,
                   t01.cover_day asc;
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
      /* Start the report
      /*-*/
      pipe row('<table border=1 cellpadding="0" cellspacing="0">');
      pipe row('<tr>');
      pipe row('<td align=center colspan=6 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:10pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Extract Report - ('||rcd_fcst_extract_header.extract_identifier||') '||rcd_fcst_extract_header.extract_description||'</td>');
      pipe row('</tr>');
      pipe row('<tr>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Forecast Load</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Material Code</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Plant</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Date</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Cover</td>');
      pipe row('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Quantity</td>');
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
         var_material_code := null;
         var_plant_code := null;
         var_cover_yyyymmdd := null;
         var_cover_day := null;
         open csr_fcst_load;
         loop
            fetch csr_fcst_load into rcd_fcst_load;
            if csr_fcst_load%notfound then
               exit;
            end if;

            /*-*/
            /* Change in row
            /*-*/
            if var_material_code is null or
               var_material_code != rcd_fcst_load.material_code or
               var_plant_code != rcd_fcst_load.plant_code or
               var_cover_yyyymmdd != rcd_fcst_load.cover_yyyymmdd or
               var_cover_day != rcd_fcst_load.cover_day then

               /*-*/
               /* Output the row when required
               /*-*/
               if not(var_material_code is null) then

                  /*-*/
                  /* Quantity row
                  /*-*/
                  var_output := '<tr>';
                  var_output := var_output||'<td valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
                  var_output := var_output||'<td valign=top align=left>'||var_material_desc||'</td>';
                  var_output := var_output||'<td valign=top align=left>'||var_plant_code||'</td>';
                  var_output := var_output||'<td valign=top align=left>'||var_cover_yyyymmdd||'</td>';
                  var_output := var_output||'<td valign=top align=left>'||to_char(var_cover_day)||'D</td>';
                  var_output := var_output||'<td align=right>'||to_char(round(var_cover_qty,2))||'</td>';
                  var_output := var_output||'</tr>';
                  pipe row(var_output);

               end if;

               /*-*/
               /* Initialise the row
               /*-*/
               var_material_code := rcd_fcst_load.material_code;
               var_plant_code := rcd_fcst_load.plant_code;
               var_cover_yyyymmdd := rcd_fcst_load.cover_yyyymmdd;
               var_cover_day := rcd_fcst_load.cover_day;
               var_material_desc := '('||rcd_fcst_load.material_code||')';
               if not(rcd_fcst_load.material_desc_zh is null) then
                  var_material_desc := var_material_desc||' '||rcd_fcst_load.material_desc_zh;
               elsif not(rcd_fcst_load.material_desc_en is null) then
                  var_material_desc := var_material_desc||' '||rcd_fcst_load.material_desc_en;
               else
                  var_material_desc := var_material_desc||' UNKNOWN';
               end if;
               var_cover_qty := 0;

            end if;

            /*-*/
            /* Set the values
            /*-*/
            var_cover_qty := var_cover_qty + rcd_fcst_load.fcst_qty;

         end loop;
         close csr_fcst_load;

         /*-*/
         /* Output the last row when required
         /*-*/
         if not(var_material_code is null) then

            /*-*/
            /* Quantity row
            /*-*/
            var_output := '<tr>';
            var_output := var_output||'<td valign=top align=left>'||rcd_fcst_extract_load.load_identifier||'</td>';
            var_output := var_output||'<td valign=top align=left>'||var_material_desc||'</td>';
            var_output := var_output||'<td valign=top align=left>'||var_plant_code||'</td>';
            var_output := var_output||'<td valign=top align=left>'||var_cover_yyyymmdd||'</td>';
            var_output := var_output||'<td valign=top align=left>'||to_char(var_cover_day)||'D</td>';
            var_output := var_output||'<td align=right>'||to_char(round(var_cover_qty,2))||'</td>';
            var_output := var_output||'</tr>';
            pipe row(var_output);

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FCST_EXTRACT06 - REPORT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report;

end dw_fcst_extract06;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_extract06 for dw_app.dw_fcst_extract06;
grant execute on dw_fcst_extract06 to public;
