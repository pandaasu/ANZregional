/******************/
/* Package Header */
/******************/
create or replace package dw_forecast_configuration as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : clio
 Package : dw_forecast_configuration
 Owner   : dw_app
 Author  : Steve Gregan - November 2006

 DESCRIPTION
 -----------
 Dimensional Data Store - Forecast Configuration

 The package implements the forecast configuration functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure select_data;
   procedure update_data;

end dw_forecast_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_forecast_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select data routine */
   /***************************************************/
   procedure select_data is

      /*-*/
      /* Local definitions
      /*-*/
      var_wrk_string varchar2(4000 char);
      var_row_count number;
      var_end_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_count is 
         select count(*) as material_count
           from fcst_material t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code;
      rcd_count csr_count%rowtype;

      cursor csr_fcst_material is 
         select t01.sap_material_code as sap_material_code,
                t02.material_desc_en as material_desc_en,
                nvl(t01.planning_status,0) as planning_status,
                nvl(t01.planning_type,0) as planning_type,
                nvl(t01.planning_cat_old,0) as planning_cat_old,
                nvl(t01.planning_cat_prv,0) as planning_cat_prv,
                nvl(t01.planning_category,0) as planning_category,
                t01.planning_src_unit as planning_src_unit
           from fcst_material t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code
          order by t01.sap_material_code;
      rcd_fcst_material csr_fcst_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve material count
      /*-*/
      open csr_count;
      fetch csr_count into rcd_count;
      if csr_count%notfound then
         rcd_count.material_count := 0;
      end if;
      close csr_count;

      /*-*/
      /* Add the maintenance sheet
      /*-*/
      lics_spreadsheet.addSheet('Material Maintenance',false);

      /*-*/
      /* Set the sheet heading
      /*-*/
      lics_spreadsheet.setRange('A1:A1','A1:H1',lics_spreadsheet.getHeadingType(1),lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'Forecast Material Maintenance');

      /*-*/
      /* Set the maintenance heading
      /*-*/
      var_wrk_string := 'SAP material code'||chr(9)||'Description'||chr(9)||'Planning status'||chr(9)||'Planning type'||chr(9)||'Planning category - Old'||chr(9)||'Planning category - Previous'||chr(9)||'Planning category - Current'||chr(9)||'Planning source unit';
      lics_spreadsheet.setRangeArray('A2:A2','A2:H2',lics_spreadsheet.getHeadingType(7),lics_spreadsheet.FORMAT_CHAR_CENTRE,false,var_wrk_string);
      lics_spreadsheet.setHeadingBorder('A2:H2',lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Initialise the row count
      /*-*/
      var_row_count := 2;

      /*-*/
      /* Exit when no detail lines
      /*-*/
      if rcd_count.material_count = 0 then
         lics_spreadsheet.setRange('A3:A3','A3:H3',lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'NO DETAILS EXIST');
         lics_spreadsheet.setRangeBorder('A3:H3',lics_spreadsheet.BORDER_BOTTOM_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
         return;
      end if;

      /*-*/
      /* Set the cell freeze
      /*-*/
      lics_spreadsheet.setFreezeCell('C3');

      /*-*/
      /* Set the data identifier start
      /*-*/
      var_row_count := var_row_count + 1;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'<XLSHEET IDENTIFIER="MAINTENANCE">');
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);

      /*-*/
      /* Define the data row
      /*-*/
      var_row_count := var_row_count + 1;
      var_wrk_string := '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0'||chr(9)||
                        '0';
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRange('B'||to_char(var_row_count,'FM999999990')||':B'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_PROTECT,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);
      lics_spreadsheet.setRangeArray('C'||to_char(var_row_count,'FM999999990')||':C'||to_char(var_row_count,'FM999999990'),
                                     'C'||to_char(var_row_count,'FM999999990')||':G'||to_char(var_row_count,'FM999999990'),
                                     lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_DECIMAL_0,true,var_wrk_string);
      lics_spreadsheet.setRange('H'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),null,
                                lics_spreadsheet.TYPE_DETAIL,lics_spreadsheet.FORMAT_CHAR_LEFT,0,false,null);

      /*-*/
      /* Define the borders
      /*-*/
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_ALL,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);

      /*-*/
      /* Define the copy
      /*-*/
      lics_spreadsheet.setRangeCopy('A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),rcd_count.material_count-1,lics_spreadsheet.COPY_DOWN);

      /*-*/
      /* Set the data identifier end 
      /*-*/
      var_row_count := var_row_count + rcd_count.material_count;
      lics_spreadsheet.setRange('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                'A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),
                                lics_spreadsheet.TYPE_MARKER,lics_spreadsheet.FORMAT_CHAR_CENTRE,0,false,'</XLSHEET>');
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_LEFT_RIGHT,lics_spreadsheet.BORDER_WEIGHT_DEFAULT);
      lics_spreadsheet.setRangeBorder('A'||to_char(var_row_count,'FM999999990')||':H'||to_char(var_row_count,'FM999999990'),lics_spreadsheet.BORDER_BOTTOM,lics_spreadsheet.BORDER_WEIGHT_MEDIUM);
      var_end_count := var_row_count;

      /*-*/
      /* Set the print settings
      /*-*/
      lics_spreadsheet.setPrintData('$1:$2','$A:$A',2,1,0);

      /*-*/
      /* Output the forecast material data
      /*-*/
      var_row_count := 3;

      /*-*/
      /* Retrieve the forecast material
      /*-*/
      /*-*/
      open csr_fcst_material;
      loop
         fetch csr_fcst_material into rcd_fcst_material;
         if csr_fcst_material%notfound then
            exit;
         end if;

         /*-*/
         /* Output the material row
         /*-*/
         var_row_count := var_row_count + 1;
         var_wrk_string := rcd_fcst_material.sap_material_code||chr(9)||
                           rcd_fcst_material.material_desc_en||chr(9)||
                           rcd_fcst_material.planning_status||chr(9)||
                           rcd_fcst_material.planning_type||chr(9)||
                           rcd_fcst_material.planning_cat_old||chr(9)||
                           rcd_fcst_material.planning_cat_prv||chr(9)||
                           rcd_fcst_material.planning_category||chr(9)||
                           rcd_fcst_material.planning_src_unit;
         lics_spreadsheet.setRangeArray('A'||to_char(var_row_count,'FM999999990')||':A'||to_char(var_row_count,'FM999999990'),
                                        null,null,null,false,var_wrk_string);

      end loop;
      close csr_fcst_material;

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
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_CONFIGURATION - SELECT_DATA - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_data;

   /***************************************************/
   /* This procedure performs the update data routine */
   /***************************************************/
   procedure update_data is

      /*-*/
      /* Local definitions
      /*-*/
      var_identifier varchar2(64 char);
      rcd_fcst_material fcst_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Spreadsheet validation
      /*-*/
      if lics_spreadsheet.read_sheet_count = 0 then
         raise_application_error(-20000, 'No spreadsheet data to update');
      end if;
      if lics_spreadsheet.read_sheet_count > 1 then
         raise_application_error(-20000, 'Only one spreadsheet can be updated at one time');
      end if;

      /*-*/
      /* Retrieve the sheet data
      /*-*/
      for sidx in 1..lics_spreadsheet.read_sheet_count loop

         /*-*/
         /* Retrieve the load identifier
         /*-*/
         var_identifier := lics_spreadsheet.read_sheet_identifier(sidx);

         /*-*/
         /* Retrieve the sheet rows
         /*-*/
         for ridx in 1..lics_spreadsheet.read_row_count(sidx) loop

            /*-*/
            /* Sheet row must have 8 columns
            /*-*/
            if lics_spreadsheet.read_cell_count(sidx,ridx) != 8 then
               raise_application_error(-20000, 'Spreadsheet (' || var_identifier || ') row (' || ridx || ') does not have 8 columns');
            end if;

            /*-*/
            /* Set the forecast material values
            /*-*/
            rcd_fcst_material.sap_material_code := lics_spreadsheet.read_cell_string(sidx,ridx,1);
            rcd_fcst_material.planning_status := lics_spreadsheet.read_cell_number(sidx,ridx,3);
            rcd_fcst_material.planning_type := lics_spreadsheet.read_cell_number(sidx,ridx,4);
            rcd_fcst_material.planning_cat_old := lics_spreadsheet.read_cell_number(sidx,ridx,5);
            rcd_fcst_material.planning_cat_prv := lics_spreadsheet.read_cell_number(sidx,ridx,6);
            rcd_fcst_material.planning_category := lics_spreadsheet.read_cell_number(sidx,ridx,7);
            rcd_fcst_material.planning_src_unit := lics_spreadsheet.read_cell_string(sidx,ridx,8);

            /*-*/
            /* Update/insert the forecast material
            /*-*/
            update fcst_material
               set planning_status = rcd_fcst_material.planning_status,
                   planning_type = rcd_fcst_material.planning_type,
                   planning_cat_old = rcd_fcst_material.planning_cat_old,
                   planning_cat_prv = rcd_fcst_material.planning_cat_prv,
                   planning_category = rcd_fcst_material.planning_category,
                   planning_src_unit = rcd_fcst_material.planning_src_unit
               where sap_material_code = rcd_fcst_material.sap_material_code;
            if sql%notfound then
               insert into fcst_material
                  (sap_material_code,
                   planning_status,
                   planning_type,
                   planning_cat_old,
                   planning_cat_prv,
                   planning_category,
                   planning_src_unit)
               values
                  (rcd_fcst_material.sap_material_code,
                   rcd_fcst_material.planning_status,
                   rcd_fcst_material.planning_type,
                   rcd_fcst_material.planning_cat_old,
                   rcd_fcst_material.planning_cat_prv,
                   rcd_fcst_material.planning_category,
                   rcd_fcst_material.planning_src_unit);
            end if;

         end loop;

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
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_CONFIGURATION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end dw_forecast_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_configuration for dw_app.dw_forecast_configuration;
grant execute on dw_forecast_configuration to public;