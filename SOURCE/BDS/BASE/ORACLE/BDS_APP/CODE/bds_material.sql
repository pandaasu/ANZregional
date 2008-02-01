create or replace package bds_material as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_material
 Owner   : BDS_APP
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Functions


 FUNCTION : JOIN_TEXT_LINES (PAR_MATNR [MANDATORY], PAR_TEXT_HDR_SEQ [MANDATORY])
            PAR_MATNR - Material code of text lines to be joined
            PAR_TEXT_HDR_SEQ - LADS_MAT_TXH.TXHSEQ of text lines to be joined

 FUNCTION : GET_MATERIAL_BOM This function retrieves the material BOM for the requested parameters.
                             Any null parameters values (with the exception of material code) are
                             defaulted to predefined values. This function should be used in
                             conjunction with the bds_material_bom_anydate view.

 FUNCTION : GET_UOM_CODE_CONV This function retrieves the correct UOM Code based on the parameter supplied.
                              SAP stores (for example) Kilogram as KG, but builds the IDOC using KGM. The 
                              function will return the correct SAP UOM code. Where no conversion is found,
                              the passed in code will be returned.

                              Available conversions are as follows:
                              KGM -> KG
                              MTR -> M
                              GRM or GM -> G
                              LTR -> L


 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created
 2007/01   Linden Glen    Added GET_UOM_CODE_CONV function

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function join_text_lines(par_matnr in varchar2, par_text_hdr_seq in number ) return varchar2;
   function get_uom_code_conv(par_uom_code in varchar2) return varchar2;
   function get_material_bom(par_parent_material_code in varchar2,
                             par_bom_plant in varchar2,
                             par_bom_usage in varchar2,
                             par_bom_status in number,
                             par_bom_alternative in varchar2,
                             par_bom_eff_date in date) return varchar2;

end bds_material;
/


/****************/
/* Package Body */
/****************/
create or replace package body bds_material as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the convert uom routine */
   /***************************************************/
   function join_text_lines(par_matnr in varchar2, par_text_hdr_seq in number) return varchar2 is

      /*-*/
      /* Declare Variables
      /*-*/
      var_text_line_sep varchar2(1);
      var_text varchar2(2000);


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise Variables
      /*-*/
      var_text_line_sep := ' ';
      var_text := null;

      /*-*/
      /* Concatenate text lines
      /*  notes : maximum length 2000 characters (will allow for double byte characters)
      /*-*/
      for x in (select tdline 
                from lads_mat_txl 
                where matnr = par_matnr
                  and txhseq = par_text_hdr_seq
                order by txlseq) loop
         exit when (length(var_text) + length(x.tdline)) > 2000;
            var_text := trim(var_text||var_text_line_sep||x.tdline);
      end loop;


      /*-*/
      /* Return Text line
      /*-*/  
      return var_text;


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
         raise_application_error(-20000, 'BDS_MATERIAL - JOIN_TEXT_LINES(' || par_matnr || ',' || par_text_hdr_seq || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end join_text_lines;


   /***************************************************/
   /* This procedure performs the convert uom routine */
   /***************************************************/
   function get_uom_code_conv(par_uom_code in varchar2) return varchar2 is

      /*-*/
      /* Declare Variables
      /*-*/
      var_uom_code_conv varchar2(32);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform conversion
      /*-*/
      case upper(trim(par_uom_code))
         when 'KGM' then var_uom_code_conv := 'KG';
         when 'MTR' then var_uom_code_conv := 'M';
         when 'GRM' then var_uom_code_conv := 'G';
         when 'GM' then var_uom_code_conv := 'G';
         when 'LTR' then var_uom_code_conv := 'L';
         else var_uom_code_conv := upper(trim(par_uom_code));
      end case;


      /*-*/
      /* Return Text line
      /*-*/  
      return var_uom_code_conv;


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
         raise_application_error(-20000, 'BDS_MATERIAL - GET_UOM_CODE_CONV(' || par_uom_code || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_uom_code_conv;


   /********************************************************/
   /* This procedure performs the get material BOM routine */
   /********************************************************/
   function get_material_bom(par_parent_material_code in varchar2,
                             par_bom_plant in varchar2,
                             par_bom_usage in varchar2,
                             par_bom_status in number,
                             par_bom_alternative in varchar2,
                             par_bom_eff_date in date) return varchar2 is

      /*-*/
      /* Declare Variables
      /*-*/
      var_return bds_material_bom_hdr.sap_bom%type;
      var_bom_plant bds_material_bom_hdr.bom_plant%type;
      var_bom_usage bds_material_bom_hdr.bom_usage%type;
      var_bom_status bds_material_bom_hdr.bom_status%type;
      var_bom_alternative bds_material_bom_hdr.sap_bom_alternative%type;
      var_bom_eff_date bds_material_bom_hdr.bom_eff_date%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_bds_material_bom is
         select t01.sap_bom
           from (select t01.sap_bom,
                        rank() over (partition by t01.parent_material_code,
                                                  t01.bom_plant,
                                                  t01.bom_usage,
                                                  t01.sap_bom_alternative
                                         order by t01.bom_eff_date desc) as rnkseq
                   from bds_material_bom_hdr t01
                  where t01.bds_lads_status = '1'
                    and t01.parent_material_code = par_parent_material_code
                    and t01.bom_plant = var_bom_plant
                    and t01.bom_usage = var_bom_usage
                    and t01.bom_status = var_bom_status
                    and t01.sap_bom_alternative = var_bom_alternative
                    and trunc(t01.bom_eff_date) <= trunc(var_bom_eff_date)) t01
          where rnkseq = 1;
      rcd_bds_material_bom csr_bds_material_bom%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*
      /* defaults - plant - *NONE = sales BOM
      /*            usage - 1 = units per FG (mcu or rsu)
      /*            status - 1 = active
      /*            alternative - 01 = first BOM
      /*            date - sysdate
      /*-*/
      var_return := null;
      var_bom_plant := par_bom_plant;
      var_bom_usage := par_bom_usage;
      var_bom_status := par_bom_status;
      var_bom_alternative := par_bom_alternative;
      var_bom_eff_date := par_bom_eff_date;
      if par_bom_plant is null then
         var_bom_plant := '*NONE';
      end if;
      if par_bom_usage is null then
         var_bom_usage := '1';
      end if;
      if par_bom_status is null then
         var_bom_status := 1;
      end if;
      if par_bom_alternative is null then
         var_bom_alternative := '01';
      end if;
      if par_bom_eff_date is null then
         var_bom_eff_date := sysdate;
      end if;

      /*-*/
      /* Retrieve the material information
      /*-*/
      open csr_bds_material_bom;
      fetch csr_bds_material_bom into rcd_bds_material_bom;
      if csr_bds_material_bom%found then
         var_return := rcd_bds_material_bom.sap_bom;
      end if;
      close csr_bds_material_bom;

      /*-*/
      /* Return the BOM identifier
      /*-*/  
      return var_return;

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
         raise_application_error(-20000, 'BDS_MATERIAL - GET_MATERIAL_BOM (' || par_parent_material_code || ',' || par_bom_plant || ',' || par_bom_usage || ',' || par_bom_status || ',' || par_bom_alternative || ',' || par_bom_eff_date || ') - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_material_bom;

end bds_material;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_material for bds_app.bds_material;
grant execute on bds_material to public;
