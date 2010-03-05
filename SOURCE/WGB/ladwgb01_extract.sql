/******************/
/* Package Header */
/******************/
create or replace package site_app.ladwgb01_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladwgb01_extract
    Owner   : site_app

    Description
    -----------
    China Material Data - LADS to WGB



    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the LADS material that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface LADWGB01 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created
    2010/02   Steve Gregan   Added new interface fields
    2010/02   Steve Gregan   Changed list price calculation

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end ladwgb01_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body site_app.ladwgb01_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_history in varchar2 default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);

      var_history number;
      var_instance number(15,0);
      var_start boolean;

      /*-*/ 
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select decode(trim(t01.sap_material_code),null,';','"'||replace(trim(t01.sap_material_code),'"','""')||'";') as sap_material_code,
                decode(trim(t01.material_division),null,';','"'||replace(trim(t01.material_division),'"','""')||'";') as material_division,
                decode(trim(t02.sap_brand_flag_code),null,';','"'||replace(trim(t02.sap_brand_flag_code),'"','""')||'";') as sap_brand_flag_code,
                decode(trim(t02.sap_brand_flag_lng_dsc),null,';','"'||replace(trim(t02.sap_brand_flag_lng_dsc),'"','""')||'";') as sap_brand_flag_desc,
                decode(trim(t01.bds_material_desc_zh),null,';','"'||replace(trim(t01.bds_material_desc_zh),'"','""')||'";') as bds_material_desc_zh,
                decode(trim(t01.bds_material_desc_en),null,';','"'||replace(trim(t01.bds_material_desc_en),'"','""')||'";') as bds_material_desc_en,
                decode(trim(t03.dstrbtn_chain_status),null,';','"'||replace(trim(t03.dstrbtn_chain_status),'"','""')||'";') as dstrbtn_chain_status,
                decode(trim(t04.vakey),null,'','"'||to_char(t04.kbetr,'fm00000.00000')||'"') as list_price
           from bds_material_hdr t01,
                bds_material_classfctn_en t02,
                bds_material_dstrbtn_chain t03,
               (select t01.matnr as matnr,
                       t01.kbetr as kbetr
                  from lads_prc_lst_hdr t01,
                       lads_prc_lst_det t02
                 where t01.vakey = t02.vakey
                   and t01.kschl = t02.kschl
                   and t01.datab = t02.datab
                   and t01.knumh = t02.knumh
                   and t01.kschl = 'PR00'
                   and t01.vkorg = '135'
                   and decode(t01.datab,null,'19000101','00000000','19000101',t01.datab) <= to_char(sysdate,'yyyymmdd')
                   and decode(t01.datbi,null,'19000101','00000000','19000101',t01.datbi) >= to_char(sysdate,'yyyymmdd')) t04
          where t01.sap_material_code = t02.sap_material_code
            and t01.sap_material_code = t03.sap_material_code
            and t01.sap_material_code = t04.matnr(+)
            and t01.material_type in ('ZHIE','FERT')
            and t01.mars_traded_unit_flag = 'X'
            and t03.sales_organisation = '135'
            and t03.dstrbtn_channel = '10'
            and t03.dstrbtn_chain_delete_indctr is null
            and t03.dstrbtn_chain_status in ('20','99')
            and t03.bds_dstrbtn_chain_valid <= to_char(sysdate,'yyyymmdd')
            and trunc(t01.bds_lads_date) >= trunc(sysdate) - var_history;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;



      /*-*/
      /* Define number of days to extract
      /*-*/
      if (par_history = 0) then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

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
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADWGB01',null,'MARS_GB_02_MATL.txt');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_extract.sap_material_code ||
                                          rcd_extract.material_division ||
                                          rcd_extract.sap_brand_flag_code ||
                                          rcd_extract.sap_brand_flag_desc ||
                                          rcd_extract.bds_material_desc_zh ||
                                          rcd_extract.bds_material_desc_en ||
                                          rcd_extract.dstrbtn_chain_status ||
                                          rcd_extract.list_price);

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
      /*-*/
      if lics_outbound_loader.is_created = true then
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
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADWGB01 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladwgb01_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladwgb01_extract for site_app.ladwgb01_extract;
grant execute on ladwgb01_extract to public;
