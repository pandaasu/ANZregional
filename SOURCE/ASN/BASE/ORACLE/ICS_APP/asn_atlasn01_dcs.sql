DROP PACKAGE ICS_APP.ASN_ATLASN01_DCS;

CREATE OR REPLACE PACKAGE ICS_APP.ASN_ATLASN01_DCS as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ASN
    Package : ASN_ATLASN01_DCS
    Owner   : ics_app
    Author  : Ben Halicki

    Description
    -----------
    Advanced Shipping Notice - Atlas to ASN Distribution Centre Shipment Interface

    YYYY/MM   Author          Description
    -------   ------          -----------
    2005/11   Ben Halicki     Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ASN_ATLASN01_DCS;
/


DROP PUBLIC SYNONYM ASN_ATLASN01_DCS;

CREATE OR REPLACE PUBLIC SYNONYM ASN_ATLASN01_DCS FOR ICS_APP.ASN_ATLASN01_DCS;


GRANT EXECUTE ON ICS_APP.ASN_ATLASN01_DCS TO LICS_APP;
DROP PACKAGE BODY ICS_APP.ASN_ATLASN01_DCS;

CREATE OR REPLACE PACKAGE BODY ICS_APP.ASN_ATLASN01_DCS as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_hph(par_record in varchar2);
   procedure process_record_hpd(par_record in varchar2);
   
   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_prv_record varchar2(32);

   var_interface varchar(32);
   var_file_name varchar(64);
   var_mars_cde asn_par_val.apv_value%type;

   rcd_asn_dcs_hdr asn_dcs_hdr%rowtype;
   rcd_asn_dcs_det asn_dcs_det%rowtype;

   type typ_asn_dcs_det is table of asn_dcs_det%rowtype index by binary_integer;
   tbl_asn_dcs_det typ_asn_dcs_det;
    
   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
     /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;
      var_prv_record := null;

      /*-*/
      /* Initialise the inbound definitions
     /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','HDR_RCDTYP',3);
      lics_inbound_utility.set_definition('HDR','HDR_DELIDE',10);
      lics_inbound_utility.set_definition('HDR','HDR_DELTYP',4);
      lics_inbound_utility.set_definition('HDR','HDR_SHPFRM',4);
      lics_inbound_utility.set_definition('HDR','HDR_SHPTAR',4);
      lics_inbound_utility.set_definition('HDR','HDR_SLOC',4);
      lics_inbound_utility.set_definition('HDR','HDR_CNN',12);
      lics_inbound_utility.set_definition('HDR','HDR_EXTID',35);
      lics_inbound_utility.set_definition('HDR','HDR_DLVDAT',8);
      lics_inbound_utility.set_definition('HDR','HDR_DLVTIM',6);
      lics_inbound_utility.set_definition('HDR','HDR_RTECDE',6);
      lics_inbound_utility.set_definition('HDR','HDR_RTEDSC',40);
      lics_inbound_utility.set_definition('HDR','HDR_VENDOR',8);
      lics_inbound_utility.set_definition('HDR','HDR_VNDDSC',40);
      lics_inbound_utility.set_definition('HDR','HDR_PONBR',10);
      lics_inbound_utility.set_definition('HDR','HDR_DSPDAT',8);
            
      lics_inbound_utility.set_definition('HPH','HPH_RCDTYP',3);
      lics_inbound_utility.set_definition('HPH','HPH_SSCNBR',20);
      lics_inbound_utility.set_definition('HPH','HPH_PAKMAT',18);
      lics_inbound_utility.set_definition('HPH','HPH_HUTYP',4);
      lics_inbound_utility.set_definition('HPH','HPH_HUSTS',1);
      
      lics_inbound_utility.set_definition('HPD','HPD_RCDTYP',3);
      lics_inbound_utility.set_definition('HPD','HPD_HUNID',1);
      lics_inbound_utility.set_definition('HPD','HPD_DLVNBR',10);
      lics_inbound_utility.set_definition('HPD','HPD_LINNBR',6);
      lics_inbound_utility.set_definition('HPD','HPD_BSEQTY',17);
      lics_inbound_utility.set_definition('HPD','HPD_BSEUOM',3);
      lics_inbound_utility.set_definition('HPD','HPD_MATCDE',18);
      lics_inbound_utility.set_definition('HPD','HPD_BATCDE',10);
      lics_inbound_utility.set_definition('HPD','HPD_DSTPLNT',4);
      lics_inbound_utility.set_definition('HPD','HPD_DSTSLOC',4);
      lics_inbound_utility.set_definition('HPD','HPD_BATEXP',8);
      
      /*-*/
      /* Retrieve the interface identifier from the inbound processor
     /* 1. Used to lookup Mars Unit in ASN parameters
     /*-*/
      var_interface := lics_inbound_processor.callback_interface;

      /*-*/
      /* Retrieve the associated file name from the inbound processor
     /* 1. Used to generate the acknowledgement file name
     /*-*/
      var_file_name := lics_inbound_processor.callback_file_name;

      /*-*/
      /* Retrieve the relevant ASN parameters
     /* 1. Interface indicates the Mars code
     /* 2. Interface indicates the acknowledgement interface
     /*-*/
      var_mars_cde := upper(asn_parameter.retrieve_value('IFACE_MARS_CODE', var_interface));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
     /* **notes** 1. Food uses HED which is converted to HDR to utilise same procedure
     /*-*/
      var_record_identifier := substr(par_record,1,3);

      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         when 'DET' then null;
         when 'HPH' then process_record_hph(par_record);
         when 'HPD' then process_record_hpd(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

      /*-*/
      /* Set the control values
     /*-*/
      var_trn_start := false;
      var_prv_record := var_record_identifier;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_ack_name varchar2(64);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data found
      /*-*/
      if var_trn_start = true then
         lics_inbound_utility.add_exception('Interface file contains no data');
         var_trn_error := true;
      end if;

      /*-*/
      /* Complete the transaction
     /*-*/
      complete_transaction;

      /*-*/
      /* Commit the database when required
     /*-*/
      if var_trn_error = false and
         var_trn_ignore = false then
         commit;
      else
         rollback;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists        boolean;
      var_splr_iid      asn_cfg_src.cfs_src_iden%type;
      var_splr_nam      asn_cfg_src.cfs_src_text%type;
      var_whs_desp_dte  asn_dcs_hdr.dch_whs_desp_dte%type;
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_sal_ord_hdr_01 is      
      select t01.*
        from lads_sal_ord_hdr t01,
             (select distinct t21.belnr as belnr
                from lads_del_irf t21
               where t21.vbeln = rcd_asn_dcs_hdr.dch_whs_pick_nbr
                 and t21.qualf = 'C'
                 and not(t21.datum is null)) t02
        where t01.belnr = t02.belnr
          and t01.lads_status = '1';
      rcd_lads_sal_ord_hdr_01 csr_lads_sal_ord_hdr_01%rowtype;
      
      cursor csr_asn_dcs_hdr_01 is
      select 'x' as fndind
        from asn_dcs_hdr t01
       where t01.dch_mars_cde = rcd_asn_dcs_hdr.dch_mars_cde
         and t01.dch_pick_nbr = rcd_asn_dcs_hdr.dch_pick_nbr;
      rcd_asn_dcs_hdr_01 csr_asn_dcs_hdr_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);

      /*-*/
      /* Clear the arrays
     /*-*/
      tbl_asn_dcs_det.delete;

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
      rcd_asn_dcs_hdr.dch_whs_file_ide := 'ATLRAN';
      rcd_asn_dcs_hdr.dch_whs_pick_nbr := lics_inbound_utility.get_variable('HDR_PCKNBR');
      rcd_asn_dcs_hdr.dch_whs_ship_frm := 'RAN';
      rcd_asn_dcs_hdr.dch_whs_pick_nbr := lics_inbound_utility.get_variable('HDR_DELIDE');
      rcd_asn_dcs_hdr.dch_whs_csgn_nbr := lics_inbound_utility.get_variable('HDR_DELIDE');
      rcd_asn_dcs_hdr.dch_trn_sord_nbr := lics_inbound_utility.get_variable('HDR_PONBR');
      rcd_asn_dcs_hdr.dch_whs_desp_dte := lics_inbound_utility.get_variable('HDR_DSPDAT') || '000000';
      
      /*-*/
      /* Retrieve target information from sales order
     /*-*/
      open csr_lads_sal_ord_hdr_01;
      fetch csr_lads_sal_ord_hdr_01 into rcd_lads_sal_ord_hdr_01;
      if csr_lads_sal_ord_hdr_01%notfound then
         rcd_asn_dcs_hdr.dch_whs_ship_tar := null;
      else
         rcd_asn_dcs_hdr.dch_whs_ship_tar := ltrim(rcd_lads_sal_ord_hdr_01.recipnt_no,'0');
      end if;
      close csr_lads_sal_ord_hdr_01;

      /*-*/
      /* Retrieve exceptions raised
     /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Check the record sequencing
     /*-*/
      if not(var_prv_record is null) then
         lics_inbound_utility.add_exception('First row in interface file must be record type HDR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the values
     /*-*/
      if var_mars_cde is null then
         lics_inbound_utility.add_exception('Missing Primary Key - Mars Code');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the values
     /*-*/
      if rcd_asn_dcs_hdr.dch_whs_pick_nbr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - Pick number');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the values
     /*-*/
      if rcd_asn_dcs_hdr.dch_whs_ship_frm is null then
         lics_inbound_utility.add_exception('Missing Field Value - Ship From');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the values
     /*-*/
      if rcd_asn_dcs_hdr.dch_whs_ship_tar is null then
         lics_inbound_utility.add_exception('Missing Field Value - Ship To Target');
         var_trn_error := true;
      end if;

      /*-*/
      /* Retrieve the relevant ASN configuration
     /* 1. Ship from indicates the supplier interchange id
     /* 2. Ship from indicates the supplier interchange name
     /*-*/
      var_splr_iid := asn_configuration.get_source_identifier(rcd_asn_dcs_hdr.dch_whs_ship_frm);
      var_splr_nam := asn_configuration.get_source_description(rcd_asn_dcs_hdr.dch_whs_ship_frm);
      if var_splr_iid is null then
         lics_inbound_utility.add_exception('Missing Configuration Value - Source = ' || rcd_asn_dcs_hdr.dch_whs_ship_frm);
         var_trn_error := true;
      end if;

      /*-*/
      /* Set the primary key and control data
     /*-*/
      rcd_asn_dcs_hdr.dch_mars_cde := var_mars_cde;
      rcd_asn_dcs_hdr.dch_pick_nbr := lpad(trim(rcd_asn_dcs_hdr.dch_whs_pick_nbr),10,'0');
      rcd_asn_dcs_hdr.dch_pick_typ := '*ATLDC';
      rcd_asn_dcs_hdr.dch_crtn_tim := sysdate;
      rcd_asn_dcs_hdr.dch_updt_tim := sysdate;
      rcd_asn_dcs_hdr.dch_stat_cde := '*WAIT_NORMAL';
      rcd_asn_dcs_hdr.dch_delv_ind := '0';
      rcd_asn_dcs_hdr.dch_sord_ind := '0';
      rcd_asn_dcs_hdr.dch_ship_ind := '0';
      rcd_asn_dcs_hdr.dch_invc_ind := '0';
      rcd_asn_dcs_hdr.dch_splr_iid := var_splr_iid;
      rcd_asn_dcs_hdr.dch_splr_nam := var_splr_nam;
      rcd_asn_dcs_hdr.dch_smsg_nbr := 0;
      rcd_asn_dcs_hdr.dch_smsg_cnt := 0;
      rcd_asn_dcs_hdr.dch_smsg_tim := null;
      rcd_asn_dcs_hdr.dch_smsg_ack := null;
      rcd_asn_dcs_hdr.dch_emsg_txt := null;

      /*-*/
      /* Initialise the transaction data
     /*-*/
      rcd_asn_dcs_hdr.dch_trn_pick_nbr := null;
      rcd_asn_dcs_hdr.dch_trn_ship_nbr := null;
      rcd_asn_dcs_hdr.dch_trn_invc_nbr := null;
      rcd_asn_dcs_hdr.dch_trn_mars_iid := null;
      rcd_asn_dcs_hdr.dch_trn_cust_iid := null;
      rcd_asn_dcs_hdr.dch_trn_cust_pon := null;
      rcd_asn_dcs_hdr.dch_trn_agrd_dte := null;
      rcd_asn_dcs_hdr.dch_trn_ordr_dte := null;
      rcd_asn_dcs_hdr.dch_trn_invc_dte := null;
      rcd_asn_dcs_hdr.dch_trn_splt_shp := null;
      rcd_asn_dcs_hdr.dch_trn_invc_val := null;
      rcd_asn_dcs_hdr.dch_trn_invc_gst := null;
      rcd_asn_dcs_hdr.dch_trn_crcy_cde := null;
      rcd_asn_dcs_hdr.dch_trn_ship_iid := null;
      rcd_asn_dcs_hdr.dch_trn_ship_nam := null;
      rcd_asn_dcs_hdr.dch_trn_dock_nbr := null;
      rcd_asn_dcs_hdr.dch_trn_byer_ide := null;

      /*-*/
      /* Reset child sequence
     /*-*/
      rcd_asn_dcs_det.dcd_seqn_nbr := 0;

      /*-*/
      /* Ignore when mars code and pick combination already exists
     /*-*/
      if var_trn_error = false then
         var_exists := true;
         open csr_asn_dcs_hdr_01;
         fetch csr_asn_dcs_hdr_01 into rcd_asn_dcs_hdr_01;
         if csr_asn_dcs_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_asn_dcs_hdr_01;
         if var_exists = true then
            var_trn_ignore := true;
         end if;
      end if;
      
   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_hph(par_record in varchar2) is
         
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HPH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
      rcd_asn_dcs_det.dcd_mars_cde := rcd_asn_dcs_hdr.dch_mars_cde;
      rcd_asn_dcs_det.dcd_pick_nbr := rcd_asn_dcs_hdr.dch_pick_nbr;
      rcd_asn_dcs_det.dcd_seqn_nbr := rcd_asn_dcs_det.dcd_seqn_nbr + 1;
      rcd_asn_dcs_det.dcd_whs_sscc_nbr := lics_inbound_utility.get_number('HPH_SSCNBR',null);
      rcd_asn_dcs_det.dcd_whs_iden_typ := '33E';
      rcd_asn_dcs_det.dcd_whs_pack_typ := 9;
      rcd_asn_dcs_det.dcd_whs_eqpt_typ := '*NONE';
      
      /*-*/
      /* Retrieve exceptions raised
     /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the values
     /*-*/
      if rcd_asn_dcs_det.dcd_whs_sscc_nbr is null then
         lics_inbound_utility.add_exception('Missing Field Value - SSCC number');
         var_trn_error := true;
      end if;
                       
   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hph;

   /**************************************************/
   /* This procedure performs the record HPD routine */
   /**************************************************/
   procedure process_record_hpd(par_record in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_01 is
      select t01.matnr,
             t01.kvewe,
             t01.kotabnr,
             t01.kschl,
             t01.kappl,
             t01.vkorg,
             t01.datab,
             t01.datbi,
             t01.rndqty,
             t01.trgqty,
             t01.detail_itemtype
        from(select t01.matnr,
                    nvl(t01.kvewe,'*NONE') as kvewe,
                    nvl(to_char(t01.kotabnr),'*NONE') as kotabnr,
                    nvl(t01.kschl,'*NONE') as kschl,
                    nvl(t01.kappl,'*NONE') as kappl,
                    nvl(t01.vkorg,'*NONE') as vkorg,
                    t02.datab as datab,
                    t02.datbi as datbi,
                    max(t04.rndqty) as rndqty,
                    max(t04.trgqty) as trgqty,
                    nvl(t04.detail_itemtype,'*NONE') as detail_itemtype,
                    rank() over (partition by t01.matnr order by datab desc) r
               from lads_mat_pch t01,
                    lads_mat_pcr t02,
                    lads_mat_pih t03,
                    lads_mat_pid t04
              where t01.matnr = t02.matnr(+)
                and t01.pchseq = t02.pchseq(+)
                and t02.matnr = t03.matnr(+)
                and t02.pchseq = t03.pchseq(+)
                and t02.pcrseq = t03.pcrseq(+)
                and t03.matnr = t04.matnr(+)
                and t03.pchseq = t04.pchseq(+)
                and t03.pcrseq = t04.pcrseq(+)
                and t04.detail_itemtype='I'
                and t01.kvewe='P'
                and t01.kappl='PO'
                and t01.kschl='Z001'
                and t01.kotabnr='505'
                and t01.vkorg in ('147')
                and t02.datab <= to_char(sysdate,'YYYYMMDD')
                and t02.datbi >= to_char(sysdate,'YYYYMMDD')
             group by t01.matnr,
                      nvl(t01.kvewe,'*NONE'),
                      nvl(to_char(t01.kotabnr),'*NONE'),
                      nvl(t01.kschl,'*NONE'),
                      nvl(t01.kappl,'*NONE'),
                      nvl(t01.vkorg,'*NONE'),
                      t02.datab,
                      t02.datbi,
                      nvl(t04.detail_itemtype,'*NONE')       
        ) t01 
        where t01.r=1
          and ltrim(t01.matnr,'0')=rcd_asn_dcs_det.dcd_whs_matl_code;
      rcd_lads_mat_01 csr_lads_mat_01%rowtype;
               
      cursor csr_lads_sal_ord_hdr_01 is       
      select t01.belnr,
             t01.genseq,
             t01.matl_code,
             t01.whs_gtin
        from (select t01.belnr,
                     t01.genseq,
                     max(case when t01.qualf = '002' then t01.idtnr end) as matl_code,
                     max(case when t01.qualf = '003' then t01.idtnr end) as whs_gtin
                from lads_sal_ord_iid t01
               where t01.qualf in ('002','003')
              group by t01.belnr, 
                       t01.genseq) t01
       where t01.belnr=rcd_asn_dcs_hdr.dch_trn_sord_nbr
         and t01.matl_code=rcd_asn_dcs_det.dcd_whs_matl_code;
      rcd_lads_sal_ord_hdr_01 csr_lads_sal_ord_hdr_01%rowtype;     
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HPD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
      rcd_asn_dcs_det.dcd_whs_bbdt := lics_inbound_utility.get_variable('HPD_BATEXP');
      rcd_asn_dcs_det.dcd_whs_btch := lics_inbound_utility.get_variable('HPD_BATCDE');
      rcd_asn_dcs_det.dcd_whs_matl_code := lics_inbound_utility.get_variable('HPD_MATCDE');
      rcd_asn_dcs_det.dcd_whs_palt_qty := lics_inbound_utility.get_variable('HPD_BSEQTY');
      rcd_asn_dcs_det.dcd_whs_matl_code := ltrim(rcd_asn_dcs_det.dcd_whs_matl_code,'0');

      /*-*/
      /* Retrieve pallet information from material master
     /*-*/
      open csr_lads_mat_01;
      fetch csr_lads_mat_01 into rcd_lads_mat_01;
      if csr_lads_mat_01%notfound then
         rcd_asn_dcs_det.dcd_whs_palt_lay := null;
         rcd_asn_dcs_det.dcd_whs_layr_unt := null;
      else
         rcd_asn_dcs_det.dcd_whs_palt_lay := rcd_lads_mat_01.rndqty;
         rcd_asn_dcs_det.dcd_whs_layr_unt := rcd_lads_mat_01.trgqty;
      end if;
      close csr_lads_mat_01;
      
      /*-*/
      /* Retrieve GTIN information from sales order
     /*-*/      
      open csr_lads_sal_ord_hdr_01;
      fetch csr_lads_sal_ord_hdr_01 into rcd_lads_sal_ord_hdr_01;
      if csr_lads_sal_ord_hdr_01%notfound then
         rcd_asn_dcs_det.dcd_whs_gtin := null;
         rcd_asn_dcs_det.dcd_whs_cust_gtin := null;
      else
         rcd_asn_dcs_det.dcd_whs_gtin := rcd_lads_sal_ord_hdr_01.whs_gtin;
         rcd_asn_dcs_det.dcd_whs_cust_gtin := rcd_lads_sal_ord_hdr_01.whs_gtin;
      end if;
      close csr_lads_sal_ord_hdr_01;
           
      /*-*/
      /* Retrieve exceptions raised
     /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Check the record sequencing
     /*-*/
      if not(var_prv_record = 'HPH') then
         lics_inbound_utility.add_exception('Previous row in interface file must be record type HPH - ' || var_prv_record);
         var_trn_error := true;
      end if;
     
      /*-*/
      /* Populate table array
     /*-*/        
      tbl_asn_dcs_det(tbl_asn_dcs_det.count+1) := rcd_asn_dcs_det;
     
   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hpd;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Finalise values
     /*-*/
      rcd_asn_dcs_hdr.dch_whs_palt_num := tbl_asn_dcs_det.count;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      /*-*/
      /* Perform the database update when required
     /*-*/
      if var_trn_error = false and
         var_trn_ignore = false then

         /*-*/
         /* Insert the new ASN DCS header row
        /*-*/
         insert into asn_dcs_hdr
            (dch_mars_cde,
             dch_pick_nbr,
             dch_pick_typ,
             dch_crtn_tim,
             dch_updt_tim,
             dch_stat_cde,
             dch_delv_ind,
             dch_sord_ind,
             dch_ship_ind,
             dch_invc_ind,
             dch_splr_iid,
             dch_splr_nam,
             dch_smsg_nbr,
             dch_smsg_cnt,
             dch_smsg_tim,
             dch_smsg_ack,
             dch_emsg_txt,
             dch_whs_file_ide,
             dch_whs_pick_nbr,
             dch_whs_ship_frm,
             dch_whs_send_dte,
             dch_whs_desp_dte,
             dch_whs_palt_num,
             dch_whs_palt_spc,
             dch_whs_csgn_nbr,
             dch_whs_ship_tar,
             dch_trn_pick_nbr,
             dch_trn_sord_nbr,
             dch_trn_ship_nbr,
             dch_trn_invc_nbr,
             dch_trn_mars_iid,
             dch_trn_cust_iid,
             dch_trn_cust_pon,
             dch_trn_agrd_dte,
             dch_trn_ordr_dte,
             dch_trn_invc_dte,
             dch_trn_splt_shp,
             dch_trn_invc_val,
             dch_trn_invc_gst,
             dch_trn_crcy_cde,
             dch_trn_ship_iid,
             dch_trn_ship_nam,
             dch_trn_dock_nbr,
             dch_trn_byer_ide)
         values
            (rcd_asn_dcs_hdr.dch_mars_cde,
             rcd_asn_dcs_hdr.dch_pick_nbr,
             rcd_asn_dcs_hdr.dch_pick_typ,
             rcd_asn_dcs_hdr.dch_crtn_tim,
             rcd_asn_dcs_hdr.dch_updt_tim,
             rcd_asn_dcs_hdr.dch_stat_cde,
             rcd_asn_dcs_hdr.dch_delv_ind,
             rcd_asn_dcs_hdr.dch_sord_ind,
             rcd_asn_dcs_hdr.dch_ship_ind,
             rcd_asn_dcs_hdr.dch_invc_ind,
             rcd_asn_dcs_hdr.dch_splr_iid,
             rcd_asn_dcs_hdr.dch_splr_nam,
             rcd_asn_dcs_hdr.dch_smsg_nbr,
             rcd_asn_dcs_hdr.dch_smsg_cnt,
             rcd_asn_dcs_hdr.dch_smsg_tim,
             rcd_asn_dcs_hdr.dch_smsg_ack,
             rcd_asn_dcs_hdr.dch_emsg_txt,
             rcd_asn_dcs_hdr.dch_whs_file_ide,
             rcd_asn_dcs_hdr.dch_whs_pick_nbr,
             rcd_asn_dcs_hdr.dch_whs_ship_frm,
             rcd_asn_dcs_hdr.dch_whs_send_dte,
             rcd_asn_dcs_hdr.dch_whs_desp_dte,
             rcd_asn_dcs_hdr.dch_whs_palt_num,
             rcd_asn_dcs_hdr.dch_whs_palt_spc,
             rcd_asn_dcs_hdr.dch_whs_csgn_nbr,
             rcd_asn_dcs_hdr.dch_whs_ship_tar,
             rcd_asn_dcs_hdr.dch_trn_pick_nbr,
             rcd_asn_dcs_hdr.dch_trn_sord_nbr,
             rcd_asn_dcs_hdr.dch_trn_ship_nbr,
             rcd_asn_dcs_hdr.dch_trn_invc_nbr,
             rcd_asn_dcs_hdr.dch_trn_mars_iid,
             rcd_asn_dcs_hdr.dch_trn_cust_iid,
             rcd_asn_dcs_hdr.dch_trn_cust_pon,
             rcd_asn_dcs_hdr.dch_trn_agrd_dte,
             rcd_asn_dcs_hdr.dch_trn_ordr_dte,
             rcd_asn_dcs_hdr.dch_trn_invc_dte,
             rcd_asn_dcs_hdr.dch_trn_splt_shp,
             rcd_asn_dcs_hdr.dch_trn_invc_val,
             rcd_asn_dcs_hdr.dch_trn_invc_gst,
             rcd_asn_dcs_hdr.dch_trn_crcy_cde,
             rcd_asn_dcs_hdr.dch_trn_ship_iid,
             rcd_asn_dcs_hdr.dch_trn_ship_nam,
             rcd_asn_dcs_hdr.dch_trn_dock_nbr,
             rcd_asn_dcs_hdr.dch_trn_byer_ide);

            /*-*/
            /* Append the interface data
           /*-*/
            for idx in 1..tbl_asn_dcs_det.count loop
            
               rcd_asn_dcs_det := tbl_asn_dcs_det(idx);
               
               insert into asn_dcs_det
                  (dcd_mars_cde,
                   dcd_pick_nbr,
                   dcd_seqn_nbr,
                   dcd_whs_sscc_nbr,
                   dcd_whs_iden_typ,
                   dcd_whs_pack_typ,
                   dcd_whs_eqpt_typ,
                   dcd_whs_gtin,
                   dcd_whs_btch,
                   dcd_whs_bbdt,
                   dcd_whs_palt_qty,
                   dcd_whs_palt_lay,
                   dcd_whs_layr_unt,
                   dcd_whs_cust_gtin,
                   dcd_whs_matl_code)
               values
                  (rcd_asn_dcs_det.dcd_mars_cde,
                   rcd_asn_dcs_det.dcd_pick_nbr,
                   rcd_asn_dcs_det.dcd_seqn_nbr,
                   rcd_asn_dcs_det.dcd_whs_sscc_nbr,
                   rcd_asn_dcs_det.dcd_whs_iden_typ,
                   rcd_asn_dcs_det.dcd_whs_pack_typ,
                   rcd_asn_dcs_det.dcd_whs_eqpt_typ,
                   rcd_asn_dcs_det.dcd_whs_gtin,
                   rcd_asn_dcs_det.dcd_whs_btch,
                   rcd_asn_dcs_det.dcd_whs_bbdt,
                   rcd_asn_dcs_det.dcd_whs_palt_qty,
                   rcd_asn_dcs_det.dcd_whs_palt_lay,
                   rcd_asn_dcs_det.dcd_whs_layr_unt,
                   rcd_asn_dcs_det.dcd_whs_cust_gtin,
                   rcd_asn_dcs_det.dcd_whs_matl_code);
                   
            end loop;
   
      end if;
      
   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;      

end ASN_ATLASN01_DCS;
/


DROP PUBLIC SYNONYM ASN_ATLASN01_DCS;

CREATE OR REPLACE PUBLIC SYNONYM ASN_ATLASN01_DCS FOR ICS_APP.ASN_ATLASN01_DCS;


GRANT EXECUTE ON ICS_APP.ASN_ATLASN01_DCS TO LICS_APP;

