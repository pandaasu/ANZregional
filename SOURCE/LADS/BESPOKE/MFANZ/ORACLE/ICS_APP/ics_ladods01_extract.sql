/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_ladods01_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ics_ladods01_extract
    Owner   : ics_app

    Description
    -----------
    Local Atlas Data Store - LADS to ODS - Factory BOM

    This package extracts the LADS factory BOM data and sends the extract file
    to the ODS environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ics_ladods01_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_ladods01_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select t01.bom_material_code,
                t01.bom_alternative,
                t01.bom_plant,
                t01.bom_number,
                t01.bom_usage,
                case
                   when count = 1 and t02.valid_from_date is not null then to_char(t02.valid_from_date,'yyyymmdd')
                   when count = 1 and t02.valid_from_date is null then to_char(t01.bom_eff_from_date,'yyyymmdd')
                   when count > 1 and t02.valid_from_date is null then null
                   when count > 1 and t02.valid_from_date is not null then to_char(t02.valid_from_date,'yyyymmdd')
                end as bom_eff_from_date,
                to_char(t01.bom_eff_to_date,'yyyymmdd') as bom_eff_to_date,
                to_char(t01.bom_base_qty) as bom_base_qty,
                t01.bom_base_uom,
                t01.bom_status,
                to_char(t01.item_sequence) as item_sequence,
                t01.item_number,
                t01.item_material_code,
                t01.item_category,
                to_char(t01.item_base_qty) as item_base_qty,
                t01.item_base_uom,
                to_char(t01.item_eff_from_date,'yyyymmdd') as item_eff_from_date,
                to_char(t01.item_eff_to_date,'yyyymmdd') as item_eff_to_date
           from bds_bom_det t01,
                bds_refrnc_bom_altrnt_t415a t02,
                (select bom_material_code,
                        bom_plant,
                        count(*) as count
                   from (select distinct bom_material_code,
                                bom_plant,
                                bom_alternative
                           from bds_bom_det)	
                  group by bom_material_code,
                           bom_plant) t03
          where t01.bom_material_code = ltrim(t02.sap_material_code(+),' 0')
            and t01.bom_alternative = ltrim(t02.altrntv_bom(+),' 0')
            and t01.bom_plant = t02.plant_code(+)
            and t01.bom_usage = t02.bom_usage(+)
            and t01.bom_material_code = t03.bom_material_code
            and t01.bom_plant = t03.bom_plant
            and t01.bds_lads_status = '1';
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_instance := -1;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_extract;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface when required
         /*-*/
         if var_instance = -1 then
            var_instance := lics_outbound_loader.create_interface('LADODS01',null,'LADODS01.DAT');
            lics_outbound_loader.append_data('CTL'||'LADODS01'||rpad(' ',32-length('LADODS01'),' ')||to_char(sysdate,'yyyymmddhh24miss'));
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('DET' ||
                                          nvl(rcd_extract.bom_material_code,' ')||rpad(' ',18-length(nvl(rcd_extract.bom_material_code,' ')),' ') ||
                                          nvl(rcd_extract.bom_alternative,' ')||rpad(' ',2-length(nvl(rcd_extract.bom_alternative,' ')),' ') ||
                                          nvl(rcd_extract.bom_plant,' ')||rpad(' ',4-length(nvl(rcd_extract.bom_plant,' ')),' ') ||
                                          nvl(rcd_extract.bom_number,' ')||rpad(' ',8-length(nvl(rcd_extract.bom_number,' ')),' ') ||
                                          nvl(rcd_extract.bom_usage,' ')||rpad(' ',1-length(nvl(rcd_extract.bom_usage,' ')),' ') ||
                                          nvl(rcd_extract.bom_eff_from_date,' ')||rpad(' ',8-length(nvl(rcd_extract.bom_eff_from_date,' ')),' ') ||
                                          nvl(rcd_extract.bom_eff_to_date,' ')||rpad(' ',8-length(nvl(rcd_extract.bom_eff_to_date,' ')),' ') ||
                                          nvl(rcd_extract.bom_base_qty,'0')||rpad(' ',15-length(nvl(rcd_extract.bom_base_qty,'0')),' ') ||
                                          nvl(rcd_extract.bom_base_uom,' ')||rpad(' ',3-length(nvl(rcd_extract.bom_base_uom,' ')),' ') ||
                                          nvl(rcd_extract.bom_status,' ')||rpad(' ',2-length(nvl(rcd_extract.bom_status,' ')),' ') ||
                                          nvl(rcd_extract.item_sequence,'0')||rpad(' ',15-length(nvl(rcd_extract.item_sequence,'0')),' ') ||
                                          nvl(rcd_extract.item_number,' ')||rpad(' ',4-length(nvl(rcd_extract.item_number,' ')),' ') ||
                                          nvl(rcd_extract.item_material_code,' ')||rpad(' ',18-length(nvl(rcd_extract.item_material_code,' ')),' ') ||
                                          nvl(rcd_extract.item_category,' ')||rpad(' ',1-length(nvl(rcd_extract.item_category,' ')),' ') ||
                                          nvl(rcd_extract.item_base_qty,'0')||rpad(' ',15-length(nvl(rcd_extract.item_base_qty,'0')),' ') ||
                                          nvl(rcd_extract.item_base_uom,' ')||rpad(' ',3-length(nvl(rcd_extract.item_base_uom,' ')),' ') ||
                                          nvl(rcd_extract.item_eff_from_date,' ')||rpad(' ',8-length(nvl(rcd_extract.item_eff_from_date,' ')),' ') ||
                                          nvl(rcd_extract.item_eff_to_date,' ')||rpad(' ',8-length(nvl(rcd_extract.item_eff_to_date,' ')),' '));

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
      /*-*/
      if var_instance != -1 then
         lics_outbound_loader.finalise_interface;
      end if;

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
         if var_instance != -1 then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - ICS_LADODS01_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ics_ladods01_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_ladods01_extract for ics_app.ics_ladods01_extract;
grant execute on ics_ladods01_extract to public;
