/******************/
/* Package Header */
/******************/
create or replace package site_app.efxwgb01_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxwgb01_extract
    Owner   : site_app

    Description
    -----------
    China Customer Data - EFEX to WGB

    This package extracts the EFEX customer that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface EFXWGB01 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end efxwgb01_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body site_app.efxwgb01_extract as

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
      cursor csr_customer is
         select decode(trim(t01.customer_code),null,';','"'||replace(trim(t01.customer_code),'"','""')||'";') as customer_code,
                decode(trim(t01.customer_name),null,';','"'||replace(trim(t01.customer_name),'"','""')||'";') as customer_name,
                decode(trim(t01.cust_type_name),null,';','"'||replace(trim(t01.cust_type_name),'"','""')||'";') as cust_type_name,
                decode(trim(t01.geo_level5_name),null,';','"'||replace(trim(t01.geo_level5_name),'"','""')||'";') as geo_level5_name,
                decode(trim(t01.distributor_id_distcust_code),null,';','"'||replace(trim(t01.distributor_id_distcust_code),'"','""')||'";') as distributor_id_distcust_code,
                decode(trim(t01.segment_name),null,';','"'||replace(trim(t01.segment_name),'"','""')||'";') as segment_name,
                decode(trim(t01.active_flag),null,';','"'||replace(trim(t01.active_flag),'"','""')||'"') as active_flag,
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
      rcd_customer csr_customer%rowtype;

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
      open csr_customer;
      loop
         fetch csr_customer into rcd_customer;
         if csr_customer%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('EFXWGB01',null,'MARS_GB_06_OTLS'||to_char(sysdate,'yyyymmddhh24miss')||'.txt');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_customer.customer_code ||
                                          rcd_customer.customer_name ||
                                          rcd_customer.cust_type_name ||
                                          rcd_customer.geo_level5_name ||
                                          rcd_customer.distributor_id_distcust_code ||
                                          rcd_customer.segment_name ||
                                          rcd_customer.active_flag);

      end loop;
      close csr_customer;

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
         raise_application_error(-20000, 'FATAL ERROR - EFXWGB02 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxwgb01_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxwgb01_extract for site_app.efxwgb01_extract;
grant execute on efxwgb01_extract to public;
