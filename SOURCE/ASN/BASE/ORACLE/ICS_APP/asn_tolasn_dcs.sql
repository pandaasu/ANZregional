/******************/
/* Package Header */
/******************/
create or replace package asn_tolasn_dcs as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_tolasn_dcs
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - Tolas to ASN Distribution Centre Shipment Interface

    YYYY/MM   Author          Description
    -------   ------          -----------
    2005/11   Steve Gregan    Created
    2006/03   Steve Gregan    Added dch_trn_byer_ide
                              Changed dch_smsg_ack to date
    2006/04   Steve Gregan    Modified for Atlas formats
    2006/11   Steve Gregan    Added configuration logic
                              Added ship to target field
                              Added send message original sent time
                              Changed outbound acknowledgement interface to unique file name
    2007/11   Steve Gregan    Added sales order creation date to the DCS header table
    2008/02   Steve Gregan    Added the customer GTIN to the DCS detail table
    2008/06   Steve Gregan    Added the material code to the DCS detail table

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end asn_tolasn_dcs;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_tolasn_dcs as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);

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
   var_ack_interface asn_par_val.apv_value%type;
   rcd_asn_dcs_hdr asn_dcs_hdr%rowtype;
   rcd_asn_dcs_det asn_dcs_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','HDR_FILIDE',6);
      lics_inbound_utility.set_definition('HDR','HDR_PCKNBR',10);
      lics_inbound_utility.set_definition('HDR','HDR_SHPFRM',3);
      lics_inbound_utility.set_definition('HDR','HDR_SNDTIM',14);
      lics_inbound_utility.set_definition('HDR','HDR_DSPTIM',14);
      lics_inbound_utility.set_definition('HDR','HDR_NUMPLT',3);
      lics_inbound_utility.set_definition('HDR','HDR_NUMPSP',5);
      lics_inbound_utility.set_definition('HDR','HDR_FILNAM',16);
      lics_inbound_utility.set_definition('HDR','HDR_SHPTAR',10);
      /*-*/
      lics_inbound_utility.set_definition('DET','DET_RCDTYP',3);
      lics_inbound_utility.set_definition('DET','DET_SSCCNB',18);
      lics_inbound_utility.set_definition('DET','DET_IDETYP',3);
      lics_inbound_utility.set_definition('DET','DET_PCKTYP',17);
      lics_inbound_utility.set_definition('DET','DET_EQPTYP',35);
      lics_inbound_utility.set_definition('DET','DET_GTIN',14);
      lics_inbound_utility.set_definition('DET','DET_BATCH',10);
      lics_inbound_utility.set_definition('DET','DET_BBD',8);
      lics_inbound_utility.set_definition('DET','DET_PLTCAS',4);
      lics_inbound_utility.set_definition('DET','DET_TIHILP',4);
      lics_inbound_utility.set_definition('DET','DET_TIHICL',4);
      lics_inbound_utility.set_definition('DET','DET_MATCDE',8);

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
      var_ack_interface := upper(asn_parameter.retrieve_value('IFACE_ACK_IFACE', var_interface));

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
      if var_record_identifier = 'HED' then
         var_record_identifier := 'HDR';
      end if;
      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         when 'DET' then process_record_det(par_record);
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
      /* Commit the database when required
      /*-*/
      if var_trn_error = false and
         var_trn_ignore = false then
         commit;
      else
         rollback;
      end if;

      /*-*/
      /* Bypass when acknowledgement not required
      /*-*/
      if var_ack_interface is null or upper(var_ack_interface) = '*NONE' then
         return;
      end if;

      /*-*/
      /* Generate the acknowledgement file name
      /*-*/
      var_ack_name := 'AACK' || substr(var_file_name,5,12);

      /*-*/
      /* Create an acknowledgement interface to the source system
      /*-*/
      var_instance := lics_outbound_loader.create_interface(var_ack_interface, null, var_ack_name || '.INT');

      /*-*/
      /* Append the interface data
      /*-*/
      if var_trn_error = true then
         lics_outbound_loader.append_data('HDR' || rpad(nvl(var_ack_name,' '),16,' ') || 'ER' || 'V01' || rpad(rcd_asn_dcs_hdr.dch_whs_pick_nbr,10,' '));
      else
         lics_outbound_loader.append_data('HDR' || rpad(nvl(var_ack_name,' '),16,' ') || 'VA' || rpad(' ',13,' '));
      end if;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

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
      var_exists boolean;
      var_splr_iid asn_cfg_src.cfs_src_iden%type;
      var_splr_nam asn_cfg_src.cfs_src_text%type;

      /*-*/
      /* Local cursors
      /*-*/
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

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_asn_dcs_hdr.dch_whs_file_ide := lics_inbound_utility.get_variable('HDR_FILIDE');
      rcd_asn_dcs_hdr.dch_whs_pick_nbr := lics_inbound_utility.get_variable('HDR_PCKNBR');
      rcd_asn_dcs_hdr.dch_whs_ship_frm := lics_inbound_utility.get_variable('HDR_SHPFRM');
      rcd_asn_dcs_hdr.dch_whs_send_dte := lics_inbound_utility.get_variable('HDR_SNDTIM');
      rcd_asn_dcs_hdr.dch_whs_desp_dte := lics_inbound_utility.get_variable('HDR_DSPTIM');
      rcd_asn_dcs_hdr.dch_whs_palt_num := lics_inbound_utility.get_number('HDR_NUMPLT',null);
      rcd_asn_dcs_hdr.dch_whs_palt_spc := lics_inbound_utility.get_number('HDR_NUMPSP',null);
      rcd_asn_dcs_hdr.dch_whs_csgn_nbr := lics_inbound_utility.get_variable('HDR_PCKNBR');
      rcd_asn_dcs_hdr.dch_whs_ship_tar := lics_inbound_utility.get_variable('HDR_SHPTAR');
      var_file_name := lics_inbound_utility.get_variable('HDR_FILNAM');

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
      rcd_asn_dcs_hdr.dch_trn_sord_nbr := null;
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

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_asn_dcs_det.dcd_mars_cde := rcd_asn_dcs_hdr.dch_mars_cde;
      rcd_asn_dcs_det.dcd_pick_nbr := rcd_asn_dcs_hdr.dch_pick_nbr;
      rcd_asn_dcs_det.dcd_seqn_nbr := rcd_asn_dcs_det.dcd_seqn_nbr + 1;
      rcd_asn_dcs_det.dcd_whs_sscc_nbr := lics_inbound_utility.get_variable('DET_SSCCNB');
      rcd_asn_dcs_det.dcd_whs_iden_typ := lics_inbound_utility.get_variable('DET_IDETYP');
      rcd_asn_dcs_det.dcd_whs_pack_typ := lics_inbound_utility.get_variable('DET_PCKTYP');
      rcd_asn_dcs_det.dcd_whs_eqpt_typ := lics_inbound_utility.get_variable('DET_EQPTYP');
      rcd_asn_dcs_det.dcd_whs_gtin := lics_inbound_utility.get_variable('DET_GTIN');
      rcd_asn_dcs_det.dcd_whs_btch := lics_inbound_utility.get_variable('DET_BATCH');
      rcd_asn_dcs_det.dcd_whs_bbdt := lics_inbound_utility.get_variable('DET_BBD');
      rcd_asn_dcs_det.dcd_whs_palt_qty := lics_inbound_utility.get_number('DET_PLTCAS',null);
      rcd_asn_dcs_det.dcd_whs_palt_lay := lics_inbound_utility.get_number('DET_TIHILP',null);
      rcd_asn_dcs_det.dcd_whs_layr_unt := lics_inbound_utility.get_number('DET_TIHICL',null);
      rcd_asn_dcs_det.dcd_whs_cust_gtin := lics_inbound_utility.get_variable('DET_GTIN');
      rcd_asn_dcs_det.dcd_whs_matl_code := lics_inbound_utility.get_variable('DET_MATCDE');

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
      if var_prv_record != 'HDR' and var_prv_record != 'DET' then
         lics_inbound_utility.add_exception('Record type DET must follow record type HDR or DET');
         var_trn_error := true;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      /*-*/
      /* Perform the database update when required
      /*-*/
      if var_trn_error = false then

         /*-*/
         /* Insert the new ASN DCS detail row
         /*-*/
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

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end asn_tolasn_dcs;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_tolasn_dcs for ics_app.asn_tolasn_dcs;
grant execute on asn_tolasn_dcs to public;