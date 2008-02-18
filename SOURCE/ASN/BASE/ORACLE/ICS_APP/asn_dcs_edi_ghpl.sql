/******************/
/* Package Header */
/******************/
create or replace package asn_dcs_edi_ghpl as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_dcs_edi_ghpl
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advance Shipping Notice - ASN Distribution Centre Shipment EDI Message - GHPL

    This package contain the processing logic for distribution centre advance shipping notices
    GHPL EDI message. The package exposes the following procedure:

    SEND_MESSAGE performs the ASN DCS EDI message send based on the following parameters:
    ------------

    1. PAR_SMSG_NBR ('send number') (MANDATORY)

       Must be an existing completed ASN DCS shipment send number.

       **notes**
       1. This procedure is invoked from the EXECUTE procedure for completed ASN DCS shipments and
          from the ICS website for ASN DCS EDI message resend requests.

       2. This procedure must be implemented by all ASN DCS EDI message creation packages.
    
    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/11   Steve Gregan   Created
    2008/02   Steve Gregan   Changed the interface file name

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure send_message(par_smsg_nbr in number);

end asn_dcs_edi_ghpl;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_dcs_edi_ghpl as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /****************************************************/
   /* This procedure performs the send message routine */
   /****************************************************/
   procedure send_message(par_smsg_nbr in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_020ind boolean;
      var_020idx number;
      var_020qty number;
      var_030ind boolean;
      var_030idx number;
      var_030qty number;
      var_040qty number;
      var_040plt number;
      var_sav_sscc asn_dcs_det.dcd_whs_sscc_nbr%type;
      var_sav_gtin asn_dcs_det.dcd_whs_gtin%type;
      var_sav_btch asn_dcs_det.dcd_whs_btch%type;
      var_sav_bbdt asn_dcs_det.dcd_whs_bbdt%type;
      type typ_outbound is table of varchar2(4000) index by binary_integer;
      tbl_outbound typ_outbound;
      var_index number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_dcs_hdr is 
         select * 
           from asn_dcs_hdr t01
          where t01.dch_smsg_nbr = par_smsg_nbr;
      rcd_asn_dcs_hdr csr_asn_dcs_hdr%rowtype;

      cursor csr_asn_dcs_det is 
         select * 
           from asn_dcs_det t01
          where t01.dcd_mars_cde = rcd_asn_dcs_hdr.dch_mars_cde
            and t01.dcd_pick_nbr = rcd_asn_dcs_hdr.dch_pick_nbr
          order by t01.dcd_whs_sscc_nbr asc,
                   t01.dcd_whs_gtin asc,
                   t01.dcd_whs_btch asc,
                   t01.dcd_whs_bbdt asc;
      rcd_asn_dcs_det csr_asn_dcs_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to find the header row
      /* notes - must exist
      /*-*/
      open csr_asn_dcs_hdr;
      fetch csr_asn_dcs_hdr into rcd_asn_dcs_hdr;
      if csr_asn_dcs_hdr%notfound then
         raise_application_error(-20000, 'ASN DCS Header (' || par_smsg_nbr || ') not found');
      end if;
      close csr_asn_dcs_hdr;

      /*-*/
      /* Clear the outbound array
      /*-*/
      tbl_outbound.delete;

      /*-*/
      /* Append the XML start
      /*-*/
      tbl_outbound(tbl_outbound.count+1) := '<?xml version="1.0" encoding="UTF-8"?>';
      tbl_outbound(tbl_outbound.count+1) := '<XML_ATLAS_ASN_GHPL>';

      /*-*/
      /* Append the "000" record
      /*-*/
      tbl_outbound(tbl_outbound.count+1) := '   <REC000>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTFID>ASPEDI10</INTFID>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTCVRSN/>';
      tbl_outbound(tbl_outbound.count+1) := '      <EDIDOCNUM/>';
      tbl_outbound(tbl_outbound.count+1) := '      <RECID>000</RECID>';
      tbl_outbound(tbl_outbound.count+1) := '      <SENDERID>' || rcd_asn_dcs_hdr.dch_trn_mars_iid || '</SENDERID>';
      tbl_outbound(tbl_outbound.count+1) := '      <RECEIVERID>' || rcd_asn_dcs_hdr.dch_trn_cust_iid || '</RECEIVERID>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTNUM>' || to_char(rcd_asn_dcs_hdr.dch_smsg_nbr,'fm99999999999999999990') || '</INTNUM>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTDATE>' || to_char(sysdate,'yyyymmdd') || '</INTDATE>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTTIME>' || to_char(sysdate,'hh24mi') || '</INTTIME>';
      tbl_outbound(tbl_outbound.count+1) := '      <ACKREQ>1</ACKREQ>';
      tbl_outbound(tbl_outbound.count+1) := '      <TESTIND>1</TESTIND>';
      tbl_outbound(tbl_outbound.count+1) := '   </REC000>';

      /*-*/
      /* Append the "010" record
      /*-*/
      tbl_outbound(tbl_outbound.count+1) := '   <REC010>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTID>ASPEDI10</INTID>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTCVRSN/>';
      tbl_outbound(tbl_outbound.count+1) := '      <EDIDOCNUM/>';
      tbl_outbound(tbl_outbound.count+1) := '      <RECID>010</RECID>';
      tbl_outbound(tbl_outbound.count+1) := '      <DOCTYP>ASN</DOCTYP>';
      tbl_outbound(tbl_outbound.count+1) := '      <VERSION>2</VERSION>';
      if rcd_asn_dcs_hdr.dch_smsg_cnt = 0 then
         tbl_outbound(tbl_outbound.count+1) := '      <FUNCCODE>9</FUNCCODE>';
      else
         tbl_outbound(tbl_outbound.count+1) := '      <FUNCCODE>7</FUNCCODE>';
      end if;
      tbl_outbound(tbl_outbound.count+1) := '      <DESADVNUM>' || rcd_asn_dcs_hdr.dch_whs_pick_nbr || '</DESADVNUM>';
      tbl_outbound(tbl_outbound.count+1) := '      <CUSTORD>' || rcd_asn_dcs_hdr.dch_trn_cust_pon || '</CUSTORD>';
      tbl_outbound(tbl_outbound.count+1) := '      <INVCNUM>' || rcd_asn_dcs_hdr.dch_trn_invc_nbr || '</INVCNUM>';
      tbl_outbound(tbl_outbound.count+1) := '      <CONNUM>' || rcd_asn_dcs_hdr.dch_whs_csgn_nbr || '</CONNUM>';
      tbl_outbound(tbl_outbound.count+1) := '      <ORDDATE>' || substr(rcd_asn_dcs_hdr.dch_trn_ordr_dte,1,8) || '</ORDDATE>';
      tbl_outbound(tbl_outbound.count+1) := '      <DESPDATE>' || substr(rcd_asn_dcs_hdr.dch_whs_desp_dte,1,8) || '</DESPDATE>';
      tbl_outbound(tbl_outbound.count+1) := '      <DESPTIME>' || substr(rcd_asn_dcs_hdr.dch_whs_desp_dte,9,4) || '</DESPTIME>';
      tbl_outbound(tbl_outbound.count+1) := '      <DELDATE>' || substr(rcd_asn_dcs_hdr.dch_trn_agrd_dte,1,8) || '</DELDATE>';
      tbl_outbound(tbl_outbound.count+1) := '      <DELTIME>' || substr(rcd_asn_dcs_hdr.dch_trn_agrd_dte,9,4) || '</DELTIME>';
      if rcd_asn_dcs_hdr.dch_trn_splt_shp = 'N' then
         tbl_outbound(tbl_outbound.count+1) := '      <SPLITSHIP></SPLITSHIP>';
      else
         tbl_outbound(tbl_outbound.count+1) := '      <SPLITSHIP>165</SPLITSHIP>';
      end if;
      tbl_outbound(tbl_outbound.count+1) := '      <INVOICAMT>' || to_char(nvl(rcd_asn_dcs_hdr.dch_trn_invc_val,0),'fm99999999999999990.00') || '</INVOICAMT>';
      tbl_outbound(tbl_outbound.count+1) := '      <INVOICGST>' || to_char(nvl(rcd_asn_dcs_hdr.dch_trn_invc_gst,0),'fm99999999999999990.00') || '</INVOICGST>';
      tbl_outbound(tbl_outbound.count+1) := '      <SUPPLIERID>' || rcd_asn_dcs_hdr.dch_splr_iid || '</SUPPLIERID>';
      tbl_outbound(tbl_outbound.count+1) := '      <SUPPLIERNAM>' || rcd_asn_dcs_hdr.dch_splr_nam || '</SUPPLIERNAM>';
      tbl_outbound(tbl_outbound.count+1) := '      <BILLTOID>' || rcd_asn_dcs_hdr.dch_trn_ship_iid || '</BILLTOID>';
      tbl_outbound(tbl_outbound.count+1) := '      <BILLTONAM>' || rcd_asn_dcs_hdr.dch_trn_ship_nam || '</BILLTONAM>';
      tbl_outbound(tbl_outbound.count+1) := '      <SHIPTOID>' || rcd_asn_dcs_hdr.dch_trn_ship_iid || '</SHIPTOID>';
      tbl_outbound(tbl_outbound.count+1) := '      <SHIPTONAM>' || rcd_asn_dcs_hdr.dch_trn_ship_nam || '</SHIPTONAM>';
      tbl_outbound(tbl_outbound.count+1) := '      <DELIVLOC>' || rcd_asn_dcs_hdr.dch_trn_dock_nbr || '</DELIVLOC>';
      tbl_outbound(tbl_outbound.count+1) := '      <PALLETFOOT>' || to_char(nvl(rcd_asn_dcs_hdr.dch_whs_palt_spc,0),'fm000.0') || '</PALLETFOOT>';
      tbl_outbound(tbl_outbound.count+1) := '      <VENDORID>' || rcd_asn_dcs_hdr.dch_trn_byer_ide || '</VENDORID>';
      tbl_outbound(tbl_outbound.count+1) := '   </REC010>';

      /*-*/
      /* Reset the detail variables
      /*-*/
      var_sav_sscc := null;
      var_sav_gtin := null;
      var_sav_btch := null;
      var_sav_bbdt := null;
      var_020ind := false;
      var_020qty := 0;
      var_030ind := false;
      var_030qty := 0;
      var_040qty := 0;
      var_040plt := 0;

      /*-*/
      /* Retrieve the ASN DC detail
      /*-*/
      open csr_asn_dcs_det;
      loop
         fetch csr_asn_dcs_det into rcd_asn_dcs_det;
         if csr_asn_dcs_det%notfound then
            exit;
         end if;

         /*-*/
         /* Test "020" record
         /*-*/
         if var_020ind = false or
            rcd_asn_dcs_det.dcd_whs_sscc_nbr != var_sav_sscc then

            /*-*/
            /* Append the "030" record closure
            /*-*/
            if var_030ind = true then
               tbl_outbound(var_030idx) := '         <QTYONPAL>' || to_char(var_030qty,'fm9999990') || '</QTYONPAL>';
               tbl_outbound(tbl_outbound.count+1) := '      </REC030>';
            end if;

            /*-*/
            /* Append the "020" record closure
            /*-*/
            if var_020ind = true then
               tbl_outbound(var_020idx) := '      <TOTQTYONPAL>' || to_char(var_020qty,'fm9999990') || '</TOTQTYONPAL>';
               tbl_outbound(tbl_outbound.count+1) := '   </REC020>';
            end if;

            /*-*/
            /* Append the "020" record
            /*-*/
            tbl_outbound(tbl_outbound.count+1) := '   <REC020>';
            tbl_outbound(tbl_outbound.count+1) := '      <INTID>ASPEDI10</INTID>';
            tbl_outbound(tbl_outbound.count+1) := '      <INTCVRSN/>';
            tbl_outbound(tbl_outbound.count+1) := '      <EDIDOCNUM/>';
            tbl_outbound(tbl_outbound.count+1) := '      <RECID>020</RECID>';
            tbl_outbound(tbl_outbound.count+1) := '      <PACKTYPE>' || trim(rcd_asn_dcs_det.dcd_whs_pack_typ) || '</PACKTYPE>';
            tbl_outbound(tbl_outbound.count+1) := '      <EQUIPTYP>' || rcd_asn_dcs_det.dcd_whs_eqpt_typ || '</EQUIPTYP>';
            tbl_outbound(tbl_outbound.count+1) := '      <SSCCNUM>' || rcd_asn_dcs_det.dcd_whs_sscc_nbr || '</SSCCNUM>';
            tbl_outbound(tbl_outbound.count+1) := '      <TOTQTYONPAL></TOTQTYONPAL>';
            var_020idx := tbl_outbound.count;
            tbl_outbound(tbl_outbound.count+1) := '      <MARKING>' || rcd_asn_dcs_det.dcd_whs_iden_typ || '</MARKING>';

            /*-*/
            /* Set the "020" level variables
            /*-*/
            var_020ind := true;
            var_020qty := 0;
            var_030ind := false;
            var_030qty := 0;
            var_sav_sscc := rcd_asn_dcs_det.dcd_whs_sscc_nbr;
            var_sav_gtin := null;
            var_sav_btch := null;
            var_sav_bbdt := null;

         end if;

         /*-*/
         /* Test "030" record
         /*-*/
         if var_030ind = false or
            rcd_asn_dcs_det.dcd_whs_gtin != var_sav_gtin or
            rcd_asn_dcs_det.dcd_whs_btch != var_sav_btch or
            rcd_asn_dcs_det.dcd_whs_bbdt != var_sav_bbdt then

            /*-*/
            /* Append the "030" record closure
            /*-*/
            if var_030ind = true then
               tbl_outbound(var_030idx) := '         <QTYONPAL>' || to_char(var_030qty,'fm9999990') || '</QTYONPAL>';
               tbl_outbound(tbl_outbound.count+1) := '      </REC030>';
            end if;

            /*-*/
            /* Append the "030" record
            /*-*/
            tbl_outbound(tbl_outbound.count+1) := '      <REC030>';
            tbl_outbound(tbl_outbound.count+1) := '         <INTID>ASPEDI10</INTID>';
            tbl_outbound(tbl_outbound.count+1) := '         <INTCVRSN/>';
            tbl_outbound(tbl_outbound.count+1) := '         <EDIDOCNUM/>';
            tbl_outbound(tbl_outbound.count+1) := '         <RECID>030</RECID>';
            tbl_outbound(tbl_outbound.count+1) := '         <GTIN>' || rcd_asn_dcs_det.dcd_whs_gtin || '</GTIN>';
            tbl_outbound(tbl_outbound.count+1) := '         <BBDATE>' || rcd_asn_dcs_det.dcd_whs_btch || '</BBDATE>';
            tbl_outbound(tbl_outbound.count+1) := '         <BATCHCODE>' || rcd_asn_dcs_det.dcd_whs_bbdt || '</BATCHCODE>';
            tbl_outbound(tbl_outbound.count+1) := '         <QTYONPAL>' || to_char(nvl(rcd_asn_dcs_det.dcd_whs_palt_qty,0),'fm99990') || '</QTYONPAL>';
            var_030idx := tbl_outbound.count;
            tbl_outbound(tbl_outbound.count+1) := '      </REC030>';

            /*-*/
            /* Set the "030" level variables
            /*-*/
            var_030ind := true;
            var_sav_gtin := rcd_asn_dcs_det.dcd_whs_gtin;
            var_sav_btch := rcd_asn_dcs_det.dcd_whs_btch;
            var_sav_bbdt := rcd_asn_dcs_det.dcd_whs_bbdt;

            /*-*/
            /* Accrue the "030" record totals
            /*-*/
            var_030qty := var_030qty + nvl(rcd_asn_dcs_det.dcd_whs_palt_qty,0);

            /*-*/
            /* Accrue the "020" record totals
            /*-*/
            var_020qty := var_020qty + nvl(rcd_asn_dcs_det.dcd_whs_palt_qty,0);

            /*-*/
            /* Accrue the "040" record totals
            /*-*/
            var_040qty := var_040qty + nvl(rcd_asn_dcs_det.dcd_whs_palt_qty,0);
            var_040plt := var_040plt + 1;

         end if;

      end loop;
      close csr_asn_dcs_det;

      /*-*/
      /* Append the "030" record closure when required
      /*-*/
      if var_030ind = true then
         tbl_outbound(var_030idx) := '         <QTYONPAL>' || to_char(var_030qty,'fm9999990') || '</QTYONPAL>';
         tbl_outbound(tbl_outbound.count+1) := '      </REC030>';
      end if;

      /*-*/
      /* Append the "020" record closure when required
      /*-*/
      if var_020ind = true then
         tbl_outbound(var_020idx) := '      <TOTQTYONPAL>' || to_char(var_020qty,'fm9999990') || '</TOTQTYONPAL>';
         tbl_outbound(tbl_outbound.count+1) := '   </REC020>';
      end if;

      /*-*/
      /* Append the "040" record
      /*-*/
      tbl_outbound(tbl_outbound.count+1) := '   <REC040>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTID>ASPEDI10</INTID>';
      tbl_outbound(tbl_outbound.count+1) := '      <INTCVRSN/>';
      tbl_outbound(tbl_outbound.count+1) := '      <EDIDOCNUM/>';
      tbl_outbound(tbl_outbound.count+1) := '      <RECID>040</RECID>';
      tbl_outbound(tbl_outbound.count+1) := '      <TOTCART>' || to_char(var_040qty,'fm9999990') || '</TOTCART>';
      tbl_outbound(tbl_outbound.count+1) := '      <TOTPAL>' || to_char(var_040plt,'fm9999990') || '</TOTPAL>';
      tbl_outbound(tbl_outbound.count+1) := '   </REC040>';

      /*-*/
      /* Append the XML start
      /*-*/
      tbl_outbound(tbl_outbound.count+1) := '</XML_ATLAS_ASN_GHPL>';

      /*-*/
      /* Create the outbound interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('ASNEDI02',null,'ASNGHPL'||to_char(sysdate,'yyyymmddhh24miss')||'.xml');

      /*-*/
      /* Append the interface data
      /*-*/
      for idx in 1..tbl_outbound.count loop
         lics_outbound_loader.append_data(tbl_outbound(idx));
      end loop;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

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
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 1024));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - ASN - ASN_DCS_EDI_DEFAULT - SEND_MESSAGE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_message;

end asn_dcs_edi_ghpl;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_dcs_edi_ghpl for ics_app.asn_dcs_edi_ghpl;
grant execute on asn_dcs_edi_ghpl to public;
