--
-- ICS_LADWMS05_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ics_ladwms05_extract as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : ics_ladwms05_extract
 Owner   : ICS_APP
 Author  : Steve Gregan

 Description
 -----------
    LADS -> Thailand Warehouse Material Master Extract (Polarstar)

    PARAMETERS:

      1. PAR_DAYS - number of days of changes to extract
            0 = full extract (extract all materials)
            n = number provided will extract changed materials for sysdate - n
            DEFAULT = no parameter specified, default is 0 (full extract)



 YYYY/MM   Author               Description
 -------   ------               -----------
 2007/08   Steve Gregan         Created
 2007/08   Steve Gregan         Added XML header (requested by Zou Kai)
 2009/01   Trevor Keon          Changed date filter from LAEDA to LADS_DATE
 2010/07   Ben Halicki          Created this package, based on Korea LADWMS02 implementation
                                Updated to use BDS tables instead of LADS
                                
 NOTES:
  * It is assumed that material codes for China will not exceed 8 character in length (Zou Kai)
  * The weight and volume provided to DHL should be the weight of the
    PC for all finished goods (material type = FERT), POS materials (material type = ZPRM)
    and packaging materials (material type = VERP)
  * The weight (field = MATL_GROSS_WGT) provided to DHL must be in KGs.  Currently,
    it seems we maintain weight in either grams or kilograms. So if weight is maintained
    in grams (GRM) = then weight/1000 And therefore, field = MATL_WGT_UOM can be hard-coded to KG
    If the weight is not maintained in either grams or kgs, then please leave the Weight
    as 0000000000.000 and Weight UOM fields as blank  This will prompt the warehouse to enter
    this in themselves instead.
  * The volume (field = MATL_VOL_PER_BASE) provided to DHL must be in cubic metres (M3).  Currently,
    it seems we maintain the volume in either cubic decimetres (DMQ) or cubic metres (M3).
    If volume is in cubic decimetres (DMQ), then volume/1000  (ie. 1000 cubic decimetres = 1 cubic metre)
    If volume is in cubic centimetres (CMQ), then volume/1000000 (ie. 1,000,000 cubic cm = 1 cubic metre)
    If volume is not maintained in either cubic metres, cubic decimetres or cubic centimetres, then leave
    the Volume as 000000000.000 and Volume UOM fields blank.  This will prompt the warehouse to enter this
    in themselves instead.

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_days in number default 0);

end ics_ladwms05_extract;
/


--
-- ICS_LADWMS05_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADWMS05_EXTRACT FOR ICS_APP.ICS_LADWMS05_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADWMS05_EXTRACT TO LICS_APP;


--
-- ICS_LADWMS05_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_ladwms05_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   function format_xml_str(par_string varchar2) return varchar2;

   /*-*/
   /* Constants
   /*-*/
   var_interface constant varchar2(8) := 'LADWMS05';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_days in number default 0) is

      /*-*/
      /* Local Variables
      /*-*/
      var_instance number(15,0);
      var_days number;

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_matl_master is
        select 
            decode
            (
                substr(t01.sap_material_code,1,1),
                '0', 
                lpad(ltrim(t01.sap_material_code,'0'),8,'0'), 
                trim(t01.sap_material_code)
            ) as sap_material_code,
            bds_material_desc_en,
            bds_material_desc_th, 
            to_char(sysdate,'YYYYMMDD') as hdr_snd_date,
            material_type,
            material_division,
            NULL as material_brand,
            '0000000000.000' as matl_gross_wgt,
            'KG' as matl_wgt_uom,
            batch_mngmnt_reqrmnt_indctr,
            to_char(total_shelf_life) as total_shelf_life,
            '0000000000.000' as matl_vol_per_base,
            'M3' as matl_vol_uom,
            decode(t03.matl_pce_value,null,null,'PC') as matl_a_uom,
            decode(t03.matl_pce_value,null,'0',t03.matl_pce_umrez) as matl_a_factor,
            decode(t03.matl_pce_value,null,null,t03.matl_pce_ean11) as matl_a_ean11,
            case
                when t03.matl_sb_value is not null then 'SB'
                when t03.matl_pac_value is not null then 'PK'
                else null
            end as matl_b_uom,
            case
                when t03.matl_sb_value is not null and t03.matl_pac_value is not null then
                case
                    when t03.matl_sb_umren = 0 or t03.matl_sb_umren is null then '0'
                    else nvl(to_char(((t03.matl_pce_umren*t03.matl_sb_umrez)/t03.matl_sb_umren)),'0')
                end
                when t03.matl_sb_value is not null then
                case
                    when t03.matl_sb_umren = 0 or t03.matl_sb_umren is null then '0'
                    else nvl(to_char(((t03.matl_pce_umren*t03.matl_sb_umrez)/t03.matl_sb_umren)),'0')
                end
                when t03.matl_pac_value is not null then
                case
                    when t03.matl_pac_umren = 0 or t03.matl_pac_umren is null then '0'
                    else nvl(to_char(((t03.matl_pce_umren*t03.matl_pac_umrez)/t03.matl_pac_umren)),'0')
                end
                else '0'
            end as matl_b_factor,
            case
                when t03.matl_sb_value is not null and t03.matl_pac_value is not null then t03.matl_sb_ean11
                when t03.matl_sb_value is not null then t03.matl_sb_ean11
                when t03.matl_pac_value is not null then t03.matl_pac_ean11
            end as matl_b_ean11,
            decode(t03.matl_cs_value,null,null,'CS') as matl_c_uom,
            decode(t03.matl_cs_value,null,'0',nvl(to_char((t03.matl_cs_umrez*t03.matl_pce_umren)),'0')) as matl_c_factor,
            decode(t03.matl_cs_value,null,null,t03.matl_cs_ean11) as matl_c_ean11,
            decode(t03.matl_ea_value,null,null,'EA') as matl_base_uom,
            decode(t03.matl_ea_value,null,'0',nvl(t03.matl_pce_umren,'0')) as matl_base_factor,
            decode(t03.matl_ea_value,null,null,t03.matl_ea_ean11) as matl_base_ean11
            from 
                bds_material_hdr t01,
                bds_material_plant_hdr t02,
                (
                    select 
                        sap_material_code,
                        max(case when uom_code = 'PCE' then 'x' end) as matl_pce_value,
                        max(case when uom_code = 'PCE' then interntl_article_no end) as matl_pce_ean11,
                        max(case when uom_code = 'PCE' then base_uom_denominator end) as matl_pce_umren,
                        max(case when uom_code = 'PCE' then base_uom_numerator end) as matl_pce_umrez,
                        max(case when uom_code = 'SB' then 'x' end) as matl_sb_value,
                        max(case when uom_code = 'SB' then interntl_article_no end) as matl_sb_ean11,
                        max(case when uom_code = 'SB' then base_uom_denominator end) as matl_sb_umren,
                        max(case when uom_code = 'SB' then base_uom_numerator end) as matl_sb_umrez,
                        max(case when uom_code = 'CS' then 'x' end) as matl_cs_value,
                        max(case when uom_code = 'CS' then interntl_article_no end) as matl_cs_ean11,
                        max(case when uom_code = 'CS' then base_uom_numerator end) as matl_cs_umrez,
                        max(case when uom_code = 'EA' then 'x' end) as matl_ea_value,
                        max(case when uom_code = 'EA' then interntl_article_no end) as matl_ea_ean11,
                        max(case when uom_code = 'PK' then 'x' end) as matl_pac_value,
                        max(case when uom_code = 'PK' then base_uom_denominator end) as matl_pac_umren,
                        max(case when uom_code = 'PK' then base_uom_numerator end) as matl_pac_umrez,
                        max(case when uom_code = 'PK' then interntl_article_no end) as matl_pac_ean11
                    from 
                        bds_material_uom
                    where 
                        uom_code in ('PCE','SB','CS','EA','PK')
                    group by 
                        sap_material_code
                ) t03  
            where 
                t01.sap_material_code = t03.sap_material_code(+)
                and t01.sap_material_code=t02.sap_material_code(+)
                and t01.bds_lads_date > (sysdate - var_days)
                and t01.material_type in ('FERT','ZPRM','VERP')
                and t02.plant_code in ('TH03')
                and t02.plant_specific_status in ('03','20');

   rec_matl_master csr_matl_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Define number of days to extract
      /*-*/
      if (par_days = 0) then
         var_days := 99999;
      else
         var_days := par_days;
      end if;

      /*-*/
      /* Create Outbound Interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface(var_interface);

      /*-*/
      /* Write XML Header
      /*-*/
      lics_outbound_loader.append_data('<?xml version="1.0" encoding="UTF-8"?>');
      lics_outbound_loader.append_data('<recordset>');

      /*-*/
      /* Write XML Control record
      /*-*/
      lics_outbound_loader.append_data('<CTL>');
      /*-*/
      lics_outbound_loader.append_data('<CTL_RECORD_ID>CTL</CTL_RECORD_ID>');
      lics_outbound_loader.append_data('<CTL_INTERFACE_NAME>' || var_interface || '</CTL_INTERFACE_NAME>');

--      /*-*/
--      /* TEST ENVIRONMENT (security defined against this tag on gateway)
--      /*-*/
--      -- lics_outbound_loader.append_data('<CTL_NAME>MCHNDHLB2BT2</CTL_NAME>');

--      /*-*/
--      /* PRODUCTION ENVIRONMENT (security defined against this tag on gateway)
--      /*-*/
--      lics_outbound_loader.append_data('<CTL_NAME>ACHNDHLP1</CTL_NAME>');

      lics_outbound_loader.append_data('</CTL>');

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_matl_master;
      loop
         fetch csr_matl_master into rec_matl_master;
         if (csr_matl_master%notfound) then
            exit;
         end if;

         /*-*/
         /* Only select naterials with an english or chinese description
         /*-*/
         if not(rec_matl_master.bds_material_desc_en is null) or not(rec_matl_master.bds_material_desc_th is null) then

            /*-*/
            /* Append Data Lines
            /*-*/
            lics_outbound_loader.append_data('<HDR>');
            /*-*/
            lics_outbound_loader.append_data('<HDR_RECORD_ID>HDR</HDR_RECORD_ID>');
            lics_outbound_loader.append_data('<HDR_MATERIAL>' || rec_matl_master.sap_material_code || '</HDR_MATERIAL>');
            if not(rec_matl_master.bds_material_desc_th is null) then
               lics_outbound_loader.append_data('<HDR_MATL_DESC>' || nvl(format_xml_str(rec_matl_master.bds_material_desc_th),' ') || '</HDR_MATL_DESC>');
            else
               lics_outbound_loader.append_data('<HDR_MATL_DESC>' || nvl(format_xml_str(rec_matl_master.bds_material_desc_en),' ') || '</HDR_MATL_DESC>');
            end if;
            lics_outbound_loader.append_data('<HDR_MATL_DESC_TH>' || nvl(format_xml_str(rec_matl_master.bds_material_desc_th),' ') || '</HDR_MATL_DESC_TH>');
            lics_outbound_loader.append_data('<HDR_RECORD_DATE>' || nvl(rec_matl_master.hdr_snd_date,' ') || '</HDR_RECORD_DATE>');
            lics_outbound_loader.append_data('<HDR_MATL_TYPE>' || nvl(rec_matl_master.material_type,' ') || '</HDR_MATL_TYPE>');
            lics_outbound_loader.append_data('<HDR_MATL_DIVISION>' || nvl(rec_matl_master.material_division,' ') || '</HDR_MATL_DIVISION>');
            lics_outbound_loader.append_data('<HDR_MATL_BRAND> </HDR_MATL_BRAND>');
            lics_outbound_loader.append_data('<HDR_GROSS_WEIGHT>' || nvl(rec_matl_master.matl_gross_wgt,' ') || '</HDR_GROSS_WEIGHT>');
            lics_outbound_loader.append_data('<HDR_WEIGHT_UOM>' || nvl(rec_matl_master.matl_wgt_uom,' ') || '</HDR_WEIGHT_UOM>');
            lics_outbound_loader.append_data('<HDR_BATCH_MNGD>' || nvl(rec_matl_master.BATCH_MNGMNT_REQRMNT_INDCTR,' ') || '</HDR_BATCH_MNGD>');
            lics_outbound_loader.append_data('<HDR_SHELF_LIFE>' || nvl(rec_matl_master.TOTAL_SHELF_LIFE,' ') || '</HDR_SHELF_LIFE>');
            lics_outbound_loader.append_data('<HDR_UNIT_VOLUME>' || nvl(rec_matl_master.matl_vol_per_base,' ') || '</HDR_UNIT_VOLUME>');
            lics_outbound_loader.append_data('<HDR_VOLUME_UOM>' || nvl(rec_matl_master.matl_vol_uom,' ') || '</HDR_VOLUME_UOM>');
            lics_outbound_loader.append_data('<HDR_UOM_A>' || nvl(rec_matl_master.matl_a_uom,' ') || '</HDR_UOM_A>');
            lics_outbound_loader.append_data('<HDR_UOM_A_FACTOR>' || nvl(rec_matl_master.matl_a_factor,' ') || '</HDR_UOM_A_FACTOR>');
            lics_outbound_loader.append_data('<HDR_UOM_A_EAN>' || nvl(rec_matl_master.matl_a_ean11,' ') || '</HDR_UOM_A_EAN>');
            lics_outbound_loader.append_data('<HDR_UOM_B>' || nvl(rec_matl_master.matl_b_uom,' ') || '</HDR_UOM_B>');
            lics_outbound_loader.append_data('<HDR_UOM_B_FACTOR>' || nvl(rec_matl_master.matl_b_factor,' ') || '</HDR_UOM_B_FACTOR>');
            lics_outbound_loader.append_data('<HDR_UOM_B_EAN>' || nvl(rec_matl_master.matl_b_ean11,' ') || '</HDR_UOM_B_EAN>');
            lics_outbound_loader.append_data('<HDR_UOM_C>' || nvl(rec_matl_master.matl_c_uom,' ') || '</HDR_UOM_C>');
            lics_outbound_loader.append_data('<HDR_UOM_C_FACTOR>' || nvl(rec_matl_master.matl_c_factor,' ') || '</HDR_UOM_C_FACTOR>');
            lics_outbound_loader.append_data('<HDR_UOM_C_EAN>' || nvl(rec_matl_master.matl_c_ean11,' ') || '</HDR_UOM_C_EAN>');
            lics_outbound_loader.append_data('<HDR_UOM_BASE>' || nvl(rec_matl_master.matl_base_uom,' ') || '</HDR_UOM_BASE>');
            lics_outbound_loader.append_data('<HDR_UOM_BASE_FACTOR>' || nvl(rec_matl_master.matl_base_factor,' ') || '</HDR_UOM_BASE_FACTOR>');
            lics_outbound_loader.append_data('<HDR_UOM_BASE_EAN>' || nvl(rec_matl_master.matl_base_ean11,' ') || '</HDR_UOM_BASE_EAN>');
            /*-*/
            lics_outbound_loader.append_data('</HDR>');

         end if;

      end loop;
      close csr_matl_master;

      /*-*/
      /* Write XML Footer details
      /*-*/
      lics_outbound_loader.append_data('</recordset>');

      /*-*/
      /* Finalise Interface
      /*-*/
      lics_outbound_loader.finalise_interface;

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
         /* Close Interface
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**************************************************/
   /* This function converts XML specific characters */
   /* to be XML compliant within a string            */
   /**************************************************/
   function format_xml_str(par_string varchar2) return varchar2 is

      /*-*/
      /* Local Variables
      /*-*/
      var_string varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      var_string := to_char(par_string);

      /*-*/
      /* Replace  ;
      /*-*/
      var_string := replace(var_string,'&',';');

      /*-*/
      /* Replace < with ;
      /*-*/
      var_string := replace(var_string,'<',';');

      /*-*/
      /* Replace > with ;
      /*-*/
      var_string := replace(var_string,'>',';');

      /*-*/
      /* Replace " with ;
      /*-*/
      var_string := replace(var_string,'"',';');

      /*-*/
      /* Replace ' with null;
      /*-*/
      var_string := replace(var_string,'''','');

      /*-*/
      /* Return formatted string
      /*-*/
      return var_string;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise
         /*-*/
         raise_application_error(-20000,'ICS_LADWMS05_EXTRACT - FORMAT_XML_STR - Error formatting string ['||par_string||'] - ['||SQLERRM||']');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_xml_str;

end ics_ladwms05_extract;
/


--
-- ICS_LADWMS05_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADWMS05_EXTRACT FOR ICS_APP.ICS_LADWMS05_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADWMS05_EXTRACT TO LICS_APP;
