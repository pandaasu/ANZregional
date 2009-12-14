/******************/
/* Package Header */
/******************/
create or replace package site_app.ladwgb03_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladwgb03_extract
    Owner   : site_app

    Description
    -----------
    China Customer Hierarchy - Standard Data - LADS to WGB

    This package extracts the LADS customer hierarchy - standard that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface LADWGB03 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladwgb03_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body site_app.ladwgb03_extract as

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
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_customer_hierarchy_standard is
         select decode(trim(t01.sap_hier_cust_code),null,';','"'||replace(trim(t01.sap_hier_cust_code),'"','""')||'";') as sap_hier_cust_code,
                decode(trim(t01.sap_sales_org_code),null,';','"'||replace(trim(t01.sap_sales_org_code),'"','""')||'";') as sap_sales_org_code,
                decode(trim(t01.sap_distbn_chnl_code),null,';','"'||replace(trim(t01.sap_distbn_chnl_code),'"','""')||'";') as sap_distbn_chnl_code,
                decode(trim(t01.sap_division_code),null,';','"'||replace(trim(t01.sap_division_code),'"','""')||'";') as sap_division_code,
                decode(trim(t01.sap_cust_code_level_1),null,';','"'||replace(trim(t01.sap_cust_code_level_1),'"','""')||'";') as sap_cust_code_level_1,
                decode(trim(t01.cust_name_en_level_1),null,';','"'||replace(trim(t01.cust_name_en_level_1),'"','""')||'";') as cust_name_en_level_1,
                decode(trim(t01.sap_sales_org_code_level_1),null,';','"'||replace(trim(t01.sap_sales_org_code_level_1),'"','""')||'";') as sap_sales_org_code_level_1,
                decode(trim(t01.sap_distbn_chnl_code_level_1),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_1),'"','""')||'";') as sap_distbn_chnl_code_level_1,
                decode(trim(t01.sap_division_code_level_1),null,';','"'||replace(trim(t01.sap_division_code_level_1),'"','""')||'";') as sap_division_code_level_1,
                decode(trim(t01.cust_hier_sort_level_1),null,';','"'||replace(trim(t01.cust_hier_sort_level_1),'"','""')||'";') as cust_hier_sort_level_1,
                decode(trim(t01.sap_cust_code_level_2),null,';','"'||replace(trim(t01.sap_cust_code_level_2),'"','""')||'";') as sap_cust_code_level_2,
                decode(trim(t01.cust_name_en_level_2),null,';','"'||replace(trim(t01.cust_name_en_level_2),'"','""')||'";') as cust_name_en_level_2,
                decode(trim(t01.sap_sales_org_code_level_2),null,';','"'||replace(trim(t01.sap_sales_org_code_level_2),'"','""')||'";') as sap_sales_org_code_level_2,
                decode(trim(t01.sap_distbn_chnl_code_level_2),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_2),'"','""')||'";') as sap_distbn_chnl_code_level_2,
                decode(trim(t01.sap_division_code_level_2),null,';','"'||replace(trim(t01.sap_division_code_level_2),'"','""')||'";') as sap_division_code_level_2,
                decode(trim(t01.cust_hier_sort_level_2),null,';','"'||replace(trim(t01.cust_hier_sort_level_2),'"','""')||'";') as cust_hier_sort_level_2,
                decode(trim(t01.sap_cust_code_level_3),null,';','"'||replace(trim(t01.sap_cust_code_level_3),'"','""')||'";') as sap_cust_code_level_3,
                decode(trim(t01.cust_name_en_level_3),null,';','"'||replace(trim(t01.cust_name_en_level_3),'"','""')||'";') as cust_name_en_level_3,
                decode(trim(t01.sap_sales_org_code_level_3),null,';','"'||replace(trim(t01.sap_sales_org_code_level_3),'"','""')||'";') as sap_sales_org_code_level_3,
                decode(trim(t01.sap_distbn_chnl_code_level_3),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_3),'"','""')||'";') as sap_distbn_chnl_code_level_3,
                decode(trim(t01.sap_division_code_level_3),null,';','"'||replace(trim(t01.sap_division_code_level_3),'"','""')||'";') as sap_division_code_level_3,
                decode(trim(t01.cust_hier_sort_level_3),null,';','"'||replace(trim(t01.cust_hier_sort_level_3),'"','""')||'";') as cust_hier_sort_level_3,
                decode(trim(t01.sap_cust_code_level_4),null,';','"'||replace(trim(t01.sap_cust_code_level_4),'"','""')||'";') as sap_cust_code_level_4,
                decode(trim(t01.cust_name_en_level_4),null,';','"'||replace(trim(t01.cust_name_en_level_4),'"','""')||'";') as cust_name_en_level_4,
                decode(trim(t01.sap_sales_org_code_level_4),null,';','"'||replace(trim(t01.sap_sales_org_code_level_4),'"','""')||'";') as sap_sales_org_code_level_4,
                decode(trim(t01.sap_distbn_chnl_code_level_4),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_4),'"','""')||'";') as sap_distbn_chnl_code_level_4,
                decode(trim(t01.sap_division_code_level_4),null,';','"'||replace(trim(t01.sap_division_code_level_4),'"','""')||'";') as sap_division_code_level_4,
                decode(trim(t01.cust_hier_sort_level_4),null,';','"'||replace(trim(t01.cust_hier_sort_level_4),'"','""')||'";') as cust_hier_sort_level_4,
                decode(trim(t01.sap_cust_code_level_5),null,';','"'||replace(trim(t01.sap_cust_code_level_5),'"','""')||'";') as sap_cust_code_level_5,
                decode(trim(t01.cust_name_en_level_5),null,';','"'||replace(trim(t01.cust_name_en_level_5),'"','""')||'";') as cust_name_en_level_5,
                decode(trim(t01.sap_sales_org_code_level_5),null,';','"'||replace(trim(t01.sap_sales_org_code_level_5),'"','""')||'";') as sap_sales_org_code_level_5,
                decode(trim(t01.sap_distbn_chnl_code_level_5),null,';','"'||replace(trim(t01.sap_distbn_chnl_code_level_5),'"','""')||'";') as sap_distbn_chnl_code_level_5,
                decode(trim(t01.sap_division_code_level_5),null,';','"'||replace(trim(t01.sap_division_code_level_5),'"','""')||'";') as sap_division_code_level_5,
                decode(trim(t01.cust_hier_sort_level_5),null,';','"'||replace(trim(t01.cust_hier_sort_level_5),'"','""')||'"') as cust_hier_sort_level_5,
           from bds_material_hdr t01,
                bds_material_classfctn t02,
                bds_material_dstrbtn_chain t03
               (select t01.matnr as matnr,
                       t01.kbetr as kbetr
                  from (select t01.*
                          from (select t01.vakey,
                                       t01.kotabnr,
                                       t01.kschl,
                                       t01.vkorg,
                                       t01.vtweg,
                                       t01.spart,
                                       t01.datab,
                                       t01.datbi,
                                       t01.matnr,
                                       t02.kbetr,
                                       t02.konwa,
                                       t02.kpein,
                                       t02.kmein,
                                       rank() over (partition by t01.matnr order by t01.datab desc, t01.datbi asc) as rnkseq
                                  from lads_prc_lst_hdr t01,
                                       lads_prc_lst_det t02
                                 where t01.vakey = t02.vakey
                                   and t01.kschl = t02.kschl
                                   and t01.datab = t02.datab
                                   and t01.knumh = t02.knumh
                                   and t01.kschl = 'PR00'
                                   and t01.vkorg = '135'
                                   and (t01.vtweg is null or t01.vtweg = '10')
                                   and decode(t01.datab,null,'19000101','00000000','19000101',t01.datab) <= to_char(sysdate,'yyyymmdd')
                                   and decode(t01.datbi,null,'19000101','00000000','19000101',t01.datbi) >= to_char(sysdate,'yyyymmdd')
                                   and t02.kmein = 'CS') t01
                         where t01.rnkseq = 1) t01) t04
          where t01.matnr = t02.matnr
            and t01.matnr = t03.matnr
            and t01.matnr = t04.matnr(+);
      rcd_customer_hierarchy_standard csr_customer_hierarchy_standard%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_customer_hierarchy_standard;
      loop
         fetch csr_customer_hierarchy_standard into rcd_customer_hierarchy_standard;
         if csr_customer)hierarchy_standard%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADWGB03',null,'MARS_GB_03_CSTD'||to_char(sysdate,'yyyymmddhh24miss')||'.txt');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_customer_hierarchy_standard.sap_hier_cust_code ||
                                          rcd_customer_hierarchy_standard.sap_sales_org_code ||
                                          rcd_customer_hierarchy_standard.sap_distbn_chnl_code ||
                                          rcd_customer_hierarchy_standard.sap_division_code ||
                                          rcd_customer_hierarchy_standard.sap_cust_code_level_1 ||
                                          rcd_customer_hierarchy_standard.cust_name_en_level_1 ||
                                          rcd_customer_hierarchy_standard.sap_sales_org_code_level_1 ||
                                          rcd_customer_hierarchy_standard.sap_distbn_chnl_code_level_1 ||
                                          rcd_customer_hierarchy_standard.sap_division_code_level_1 ||
                                          rcd_customer_hierarchy_standard.cust_hier_sort_level_1 ||
                                          rcd_customer_hierarchy_standard.sap_cust_code_level_2 ||
                                          rcd_customer_hierarchy_standard.cust_name_en_level_2 ||
                                          rcd_customer_hierarchy_standard.sap_sales_org_code_level_2 ||
                                          rcd_customer_hierarchy_standard.sap_distbn_chnl_code_level_2 ||
                                          rcd_customer_hierarchy_standard.sap_division_code_level_2 ||
                                          rcd_customer_hierarchy_standard.cust_hier_sort_level_2 ||
                                          rcd_customer_hierarchy_standard.sap_cust_code_level_3 ||
                                          rcd_customer_hierarchy_standard.cust_name_en_level_3 ||
                                          rcd_customer_hierarchy_standard.sap_sales_org_code_level_3 ||
                                          rcd_customer_hierarchy_standard.sap_distbn_chnl_code_level_3 ||
                                          rcd_customer_hierarchy_standard.sap_division_code_level_3 ||
                                          rcd_customer_hierarchy_standard.cust_hier_sort_level_3 ||
                                          rcd_customer_hierarchy_standard.sap_cust_code_level_4 ||
                                          rcd_customer_hierarchy_standard.cust_name_en_level_4 ||
                                          rcd_customer_hierarchy_standard.sap_sales_org_code_level_4 ||
                                          rcd_customer_hierarchy_standard.sap_distbn_chnl_code_level_4 ||
                                          rcd_customer_hierarchy_standard.sap_division_code_level_4 ||
                                          rcd_customer_hierarchy_standard.cust_hier_sort_level_4 ||
                                          rcd_customer_hierarchy_standard.sap_cust_code_level_5 ||
                                          rcd_customer_hierarchy_standard.cust_name_en_level_5 ||
                                          rcd_customer_hierarchy_standard.sap_sales_org_code_level_5 ||
                                          rcd_customer_hierarchy_standard.sap_distbn_chnl_code_level_5 ||
                                          rcd_customer_hierarchy_standard.sap_division_code_level_5 ||
                                          rcd_customer_hierarchy_standard.cust_hier_sort_level_5);

      end loop;
      close csr_customer_hierarchy_standard;

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
         raise_application_error(-20000, 'FATAL ERROR - LADWGB03 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladwgb03_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladwgb03_extract for site_app.ladwgb03_extract;
grant execute on ladwgb03_extract to public;
