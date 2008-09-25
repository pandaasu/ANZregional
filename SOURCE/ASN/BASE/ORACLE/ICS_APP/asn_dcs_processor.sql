/******************/
/* Package Header */
/******************/
create or replace package asn_dcs_processor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_dcs_processor
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - ASN Distribution Centre Shipment Processor

    This package contain the processing logic for distribution centre advanced shipping notices.
    The package exposes the following procedures:

    EXECUTE performs the data processing based on the following parameters:
    -------

    1. PAR_MARS_CDE (*ALL, 'mars code') (MANDATORY)

       *ALL processes available ASN DCS data for all Mars codes (ie. FOOD, PETCARE, SNACKFOOD). A
       single Mars code processes available ASN DCS data for only that Mars code.

       **notes**
       1. The procedure is executed on an polling thread and supports the use of multiple
          parallel polling threads. With this model it is possible to have any combination
          of single to multiple threads executing any combination of parameters. For example,
          multiple polling threads could all be executing *ALL, multiple polling threads could
          each be executing individual Mars codes, multiple polling threads could each be 
          executing multiple combinations of *ALL and Mars codes, or a single polling thread
          could be executing *ALL.

       2. The invocation interval is controlled by the polling thread.

       3. The polling threads provide load balancing and thread safety.

       4. The data isolation is provided by a locking mechanism within this package.

    SEND_MESSAGE performs the ASN DCS EDI message send based on the following parameters:
    ------------

    1. PAR_SMSG_NBR ('send number') (MANDATORY)

       Must be an existing completed ASN DCS shipment send number.

       **notes**
       1. This procedure is invoked from the EXECUTE procedure for completed ASN DCS shipments and
          from the ICS website for ASN DCS EDI message resend requests.

    CANCEL performs the ASN DCS shipment cancel based on the following parameters:
    ------

    1. PAR_MARS_CDE ('mars code') (MANDATORY)
    2. PAR_PICK_NBR ('pick number') (MANDATORY)

       Must be an existing uncompleted ASN DCS shipment.

       **notes**
       1. This procedure is invoked from the ICS website for ASN DCS shipment cancel requests.
    
    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/11   Steve Gregan   Created
    2006/03   Steve Gregan   Added dch_trn_byer_ide
                             Changed dch_smsg_ack to date
    2006/04   Steve Gregan   Removed shipment delivery
                             Changed function code on output message
                             AS400 code cross reference
    2006/10   Steve Gregan   Changed configuration access
                             Changed warning functionality
                             Added acknowledgement polling
                             Implemented EDI message creation
    2007/11   Steve Gregan   Removed AS400 code
                             Added sales order creation date
    2008/02   Steve Gregan   Added the customer GTIN to the DCS detail table
    2008/06   Steve Gregan   Added the material code to the DCS detail table
    2008/10   Steve Gregan   Removed LADS delivery status check from transaction lookup
                             (large order line splits have negated the existing delete logic)

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_mars_cde in varchar2);
   procedure send_message(par_smsg_nbr in varchar2);
   procedure cancel(par_mars_cde in varchar2, par_pick_nbr in varchar2);

end asn_dcs_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_dcs_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   snapshot_exception exception;
   pragma exception_init(application_exception, -20000);
   pragma exception_init(snapshot_exception, -1555);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_mars_cde in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_open boolean;
      var_exit boolean;
      var_available boolean;
      var_send boolean;
      var_mars_cde asn_par_val.apv_value%type;
      var_work asn_par_val.apv_value%type;
      var_envr_cde asn_par_val.apv_value%type;
      var_war_type asn_cfg_src.cfs_wrn_type%type;
      var_war_time asn_cfg_src.cfs_wrn_time%type;
      var_war_text asn_cfg_src.cfs_wrn_text%type;
      var_alt_type asn_cfg_src.cfs_alt_type%type;
      var_alt_time asn_cfg_src.cfs_alt_time%type;
      var_alt_text asn_cfg_src.cfs_alt_text%type;
      var_age_seconds number;
      var_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_dcs_hdr_01 is 
         select t01.dch_mars_cde,
                t01.dch_pick_nbr 
           from asn_dcs_hdr t01
          where (t01.dch_mars_cde = var_mars_cde or
                 var_mars_cde = '*ALL')
            and t01.dch_stat_cde != '*COMPLETE'
            and t01.dch_stat_cde != '*ERROR'
            and t01.dch_stat_cde != '*CANCELLED'
       order by t01.dch_crtn_tim asc,
                t01.dch_mars_cde asc,
                t01.dch_pick_nbr asc;
      rcd_asn_dcs_hdr_01 csr_asn_dcs_hdr_01%rowtype;

      cursor csr_asn_dcs_hdr is 
         select *
           from asn_dcs_hdr t01
          where t01.dch_mars_cde = rcd_asn_dcs_hdr_01.dch_mars_cde
            and t01.dch_pick_nbr = rcd_asn_dcs_hdr_01.dch_pick_nbr
                for update nowait;
      rcd_asn_dcs_hdr csr_asn_dcs_hdr%rowtype;

      cursor csr_asn_dcs_det is 
         select t01.dcd_mars_cde,
                t01.dcd_pick_nbr,
                t01.dcd_seqn_nbr,
                t02.ean11
           from asn_dcs_det t01,
                lads_mat_hdr t02
          where t01.dcd_mars_cde = rcd_asn_dcs_hdr.dch_mars_cde
            and t01.dcd_pick_nbr = rcd_asn_dcs_hdr.dch_pick_nbr
            and t01.dcd_whs_matl_code = lads_trim_code(t02.matnr);
      rcd_asn_dcs_det csr_asn_dcs_det%rowtype;

      cursor csr_lads_del_hdr is
         select *
           from lads_del_hdr t01
          where t01.vbeln = rcd_asn_dcs_hdr.dch_pick_nbr;
      --------      and t01.lads_status = '1';
      rcd_lads_del_hdr csr_lads_del_hdr%rowtype;

      cursor csr_lads_sal_ord_hdr is
         select t01.*
           from lads_sal_ord_hdr t01,
                (select distinct t21.belnr as belnr
                   from lads_del_irf t21
                  where t21.vbeln = rcd_asn_dcs_hdr.dch_trn_pick_nbr
                    and t21.qualf = 'C'
                    and not(t21.datum is null)) t02
          where t01.belnr = t02.belnr
            and t01.lads_status = '1';
      rcd_lads_sal_ord_hdr csr_lads_sal_ord_hdr%rowtype;

      cursor csr_lads_del_irf is
         select count(distinct t01.vbeln) as delcnt
           from lads_del_irf t01
          where t01.belnr = rcd_asn_dcs_hdr.dch_trn_sord_nbr
            and t01.qualf = 'C'
            and not(t01.datum is null);
      rcd_lads_del_irf csr_lads_del_irf%rowtype;

      cursor csr_lads_sal_ord_ref is
         select t01.refnr
           from lads_sal_ord_ref t01
          where t01.belnr = rcd_asn_dcs_hdr.dch_trn_sord_nbr
            and t01.qualf = '001';
      rcd_lads_sal_ord_ref csr_lads_sal_ord_ref%rowtype;

      cursor csr_lads_sal_ord_dat is
         select t01.iddat,
                datum || uzeit as datum
           from lads_sal_ord_dat t01
          where t01.belnr = rcd_asn_dcs_hdr.dch_trn_sord_nbr
            and t01.iddat in ('002','025');
      rcd_lads_sal_ord_dat csr_lads_sal_ord_dat%rowtype;

      cursor csr_lads_sal_ord_org is
         select orgid as orgid
           from lads_sal_ord_org t01
          where t01.belnr = rcd_asn_dcs_hdr.dch_trn_sord_nbr
            and t01.qualf = '016';
      rcd_lads_sal_ord_org csr_lads_sal_ord_org%rowtype;

      cursor csr_lads_sal_ord_txi is
         select t01.tdid,
                t02.tdline
           from lads_sal_ord_txi t01,
                lads_sal_ord_txt t02
          where t01.belnr = t02.belnr
            and t01.txiseq = t02.txiseq
            and t01.tdid in ('Z001','Z005','Z030','Z040')
            and t01.belnr = rcd_asn_dcs_hdr.dch_trn_sord_nbr;
      rcd_lads_sal_ord_txi csr_lads_sal_ord_txi%rowtype;

      cursor csr_lads_inv_hdr is
         select t01.belnr,
                t01.curcy
           from lads_inv_hdr t01,
                (select distinct(t21.belnr) as belnr
                   from lads_inv_irf t21
                  where t21.refnr = rcd_asn_dcs_hdr.dch_trn_pick_nbr
                    and t21.qualf = '016') t02
          where t01.belnr = t02.belnr
            and t01.lads_status = '1';
      rcd_lads_inv_hdr csr_lads_inv_hdr%rowtype;

      cursor csr_lads_inv_smy is
         select t01.sumid,
                to_number(decode(sign(instr(t01.summe,'-',1,1)),1,-1,1) * trim('-' from t01.summe)) as summe
           from lads_inv_smy t01
          where t01.belnr = rcd_asn_dcs_hdr.dch_trn_invc_nbr
            and t01.sumid in ('011','005');
      rcd_lads_inv_smy csr_lads_inv_smy%rowtype;

      cursor csr_lads_inv_dat is
         select t01.datum
           from lads_inv_dat t01
          where t01.belnr = rcd_asn_dcs_hdr.dch_trn_invc_nbr
            and t01.iddat = '015';
      rcd_lads_inv_dat csr_lads_inv_dat%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      var_mars_cde := upper(par_mars_cde);
      if var_mars_cde != '*ALL' then
         var_work := asn_parameter.retrieve_value('ASN_CONTROL', 'DCS_' || var_mars_cde);
         if var_work is null then
            raise_application_error(-20000, 'Mars code parameter (' || par_mars_cde || ') must be *ALL or a valid ASN_CONTROL in the ASN parameter table');
         end if;
      end if;

      /*-*/
      /* Retrieve the environment code
      /*-*/
      var_envr_cde := asn_parameter.retrieve_value('ASN_CONTROL', '*ENVIRONMENT');

      /*-*/
      /* Retrieve the ASN DCS headers
      /* notes - status not equal to *COMPLETE, *ERROR or *CANCELLED
      /*       - sorted by creation date ascending
      /*       - cursor is reopened when snapshot to old
      /*-*/
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next ASN header to process
         /*-*/
         loop
            if var_open = true then
               if csr_asn_dcs_hdr_01%isopen then
                  close csr_asn_dcs_hdr_01;
               end if;
               open csr_asn_dcs_hdr_01;
               var_open := false;
            end if;
            begin
               fetch csr_asn_dcs_hdr_01 into rcd_asn_dcs_hdr_01;
               if csr_asn_dcs_hdr_01%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Attempt to lock the header row
         /* notes - must still exist
         /*         must still be available status
         /*         must not be locked
         /*-*/
         var_available := true;
         begin
            open csr_asn_dcs_hdr;
            fetch csr_asn_dcs_hdr into rcd_asn_dcs_hdr;
            if csr_asn_dcs_hdr%notfound then
               var_available := false;
            end if;
            if rcd_asn_dcs_hdr.dch_stat_cde = '*COMPLETE' or
               rcd_asn_dcs_hdr.dch_stat_cde = '*ERROR' or
               rcd_asn_dcs_hdr.dch_stat_cde = '*CANCELLED' then
               var_available := false;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_asn_dcs_hdr%isopen then
            close csr_asn_dcs_hdr;
         end if;

         /*-*/
         /* Release the header lock when not available
         /* 1. Cursor row locks are not released until commit or rollback
         /* 2. Cursor close does not release row locks
         /*-*/
         if var_available = false then

            /*-*/
            /* Rollback to release row locks
            /*-*/
            rollback;

         /*-*/
         /* Process the header when available
         /*-*/
         else

            /*-*/
            /* Reset the send indicator
            /*-*/
            var_send := false;

            /*-*/
            /* Reset the message text
            /*-*/
            rcd_asn_dcs_hdr.dch_emsg_txt := null;

            /*-*/
            /* Process transaction waiting status
            /*-*/
            if rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_NORMAL' or
               rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_WARNING' or
               rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_ALERTED' then

               /*-*/
               /* Process the ASN header based on pick type
               /*-*/
               case rcd_asn_dcs_hdr.dch_pick_typ

                  /*-*/
                  /* Atlas system
                  /*-*/
                  when '*ATLDC' then

                     /*-*/
                     /* Retrieve the LADS delivery data when required
                     /*-*/
                     if rcd_asn_dcs_hdr.dch_delv_ind = '0' then
                        open csr_lads_del_hdr;
                        fetch csr_lads_del_hdr into rcd_lads_del_hdr;
                        if csr_lads_del_hdr%found then
                           rcd_asn_dcs_hdr.dch_delv_ind := '1';
                           rcd_asn_dcs_hdr.dch_trn_pick_nbr := rcd_lads_del_hdr.vbeln;
                        end if;
                        close csr_lads_del_hdr;
                     end if;

                     /*-*/
                     /* Retrieve the LADS sale order data when required and delivery found
                     /*-*/
                     if rcd_asn_dcs_hdr.dch_sord_ind = '0' and
                        rcd_asn_dcs_hdr.dch_delv_ind = '1' then

                        /*-*/
                        /* Retrieve the LADS sales order header
                        /* 1. Atlas supports multiple sales orders per delivery
                        /* 2. Distribution center business process only supports one sales order per delivery
                        /*-*/
                        open csr_lads_sal_ord_hdr;
                        loop
                           fetch csr_lads_sal_ord_hdr into rcd_lads_sal_ord_hdr;
                           if csr_lads_sal_ord_hdr%notfound then
                              exit;
                           end if;
                           if rcd_asn_dcs_hdr.dch_sord_ind = '1' then
                              rcd_asn_dcs_hdr.dch_sord_ind := '0';
                              rcd_asn_dcs_hdr.dch_stat_cde := '*ERROR';
                              rcd_asn_dcs_hdr.dch_emsg_txt := 'Atlas delivery covers multiple sales orders - unable to process';
                              exit;
                           else
                              rcd_asn_dcs_hdr.dch_sord_ind := '1';
                              rcd_asn_dcs_hdr.dch_trn_sord_nbr := rcd_lads_sal_ord_hdr.belnr;
                           end if;
                        end loop;
                        close csr_lads_sal_ord_hdr;

                        /*-*/
                        /* Retrieve the LADS sales order data when available
                        /* 1. Assumption that delivery covers one sales order
                        /*-*/
                        if rcd_asn_dcs_hdr.dch_sord_ind = '1' then

                           /*-*/
                           /* Retrieve the LADS sales order split shipment indicator
                           /* 1. Count the deliveries attached to the selected sales order
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_splt_shp := 'N';
                           open csr_lads_del_irf;
                           fetch csr_lads_del_irf into rcd_lads_del_irf;
                           if csr_lads_del_irf%found then
                              if rcd_lads_del_irf.delcnt > 1 then
                                 rcd_asn_dcs_hdr.dch_trn_splt_shp := 'Y';
                              end if;
                           end if;
                           close csr_lads_del_irf;

                           /*-*/
                           /* Retrieve the LADS sales order customer purchase order number
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_cust_pon := null;
                           open csr_lads_sal_ord_ref;
                           fetch csr_lads_sal_ord_ref into rcd_lads_sal_ord_ref;
                           if csr_lads_sal_ord_ref%found then
                              rcd_asn_dcs_hdr.dch_trn_cust_pon := substr(rcd_lads_sal_ord_ref.refnr,1,10);
                           end if;
                           close csr_lads_sal_ord_ref;

                           /*-*/
                           /* Retrieve the LADS sales order agreed delivery date and creation date
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_agrd_dte := null;
                           rcd_asn_dcs_hdr.dch_trn_ordr_dte := null;
                           open csr_lads_sal_ord_dat;
                           loop
                              fetch csr_lads_sal_ord_dat into rcd_lads_sal_ord_dat;
                              if csr_lads_sal_ord_dat%notfound then
                                 exit;
                              end if;
                              case rcd_lads_sal_ord_dat.iddat
                                 when '002' then rcd_asn_dcs_hdr.dch_trn_agrd_dte := rcd_lads_sal_ord_dat.datum;
                                 when '025' then rcd_asn_dcs_hdr.dch_trn_ordr_dte := rcd_lads_sal_ord_dat.datum;
                                 else null;
                              end case;
                           end loop;
                           close csr_lads_sal_ord_dat;

                           /*-*/
                           /* Retrieve the LADS sales order mars interchange identifier
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_mars_iid := null;
                           open csr_lads_sal_ord_org;
                           fetch csr_lads_sal_ord_org into rcd_lads_sal_ord_org;
                           if csr_lads_sal_ord_org%found then
                              rcd_asn_dcs_hdr.dch_trn_mars_iid := asn_parameter.retrieve_value('MARS_SALE_IID', rcd_lads_sal_ord_org.orgid);
                           end if;
                           close csr_lads_sal_ord_org;

                           /*-*/
                           /* Retrieve the LADS sales order text data
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_cust_iid := null;
                           rcd_asn_dcs_hdr.dch_trn_ship_iid := null;
                           rcd_asn_dcs_hdr.dch_trn_ship_nam := null;
                           rcd_asn_dcs_hdr.dch_trn_dock_nbr := null;
                           rcd_asn_dcs_hdr.dch_trn_byer_ide := null;
                           open csr_lads_sal_ord_txi;
                           loop
                              fetch csr_lads_sal_ord_txi into rcd_lads_sal_ord_txi;
                              if csr_lads_sal_ord_txi%notfound then
                                 exit;
                              end if;
                              case rcd_lads_sal_ord_txi.tdid
                                 when 'Z001' then rcd_asn_dcs_hdr.dch_trn_dock_nbr := substr(rcd_lads_sal_ord_txi.tdline,1,10);
                                 when 'Z005' then rcd_asn_dcs_hdr.dch_trn_byer_ide := substr(rcd_lads_sal_ord_txi.tdline,1,17);
                                 when 'Z030' then rcd_asn_dcs_hdr.dch_trn_ship_iid := substr(rcd_lads_sal_ord_txi.tdline,1,15);
                                 when 'Z040' then rcd_asn_dcs_hdr.dch_trn_cust_iid := substr(rcd_lads_sal_ord_txi.tdline,1,15);
                                 else null;
                              end case;
                           end loop;
                           close csr_lads_sal_ord_txi;

                        end if;

                     end if;

                     /*-*/
                     /* Set the LADS shipment data when required and delivery found
                     /*-*/
                     if rcd_asn_dcs_hdr.dch_ship_ind = '0' and
                        rcd_asn_dcs_hdr.dch_delv_ind = '1' then
                        rcd_asn_dcs_hdr.dch_ship_ind := '1';
                        rcd_asn_dcs_hdr.dch_trn_ship_nbr := null;
                     end if;

                     /*-*/
                     /* Retrieve the LADS invoice data when required and delivery found
                     /*-*/
                     if rcd_asn_dcs_hdr.dch_invc_ind = '0' and
                        rcd_asn_dcs_hdr.dch_delv_ind = '1' then

                        /*-*/
                        /* Retrieve the LADS invoice header
                        /*-*/
                        open csr_lads_inv_hdr;
                        fetch csr_lads_inv_hdr into rcd_lads_inv_hdr;
                        if csr_lads_inv_hdr%found then
                           rcd_asn_dcs_hdr.dch_invc_ind := '1';
                           rcd_asn_dcs_hdr.dch_trn_invc_nbr := rcd_lads_inv_hdr.belnr;
                           rcd_asn_dcs_hdr.dch_trn_crcy_cde := rcd_lads_inv_hdr.curcy;
                        end if;
                        close csr_lads_inv_hdr;

                        /*-*/
                        /* Retrieve the LADS invoice data when available
                        /*-*/
                        if rcd_asn_dcs_hdr.dch_invc_ind = '1' then

                           /*-*/
                           /* Retrieve the LADS invoice values when available
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_invc_val := 0;
                           rcd_asn_dcs_hdr.dch_trn_invc_gst := 0;
                           open csr_lads_inv_smy;
                           loop
                              fetch csr_lads_inv_smy into rcd_lads_inv_smy;
                              if csr_lads_inv_smy%notfound then
                                 exit;
                              end if;
                              case rcd_lads_inv_smy.sumid
                                 when '011' then rcd_asn_dcs_hdr.dch_trn_invc_val := rcd_lads_inv_smy.summe;
                                 when '005' then rcd_asn_dcs_hdr.dch_trn_invc_gst := rcd_lads_inv_smy.summe;
                                 else null;
                              end case;
                           end loop;
                           close csr_lads_inv_smy;

                           /*-*/
                           /* Retrieve the LADS invoice date when available
                           /*-*/
                           rcd_asn_dcs_hdr.dch_trn_invc_dte := null;
                           open csr_lads_inv_dat;
                           fetch csr_lads_inv_dat into rcd_lads_inv_dat;
                           if csr_lads_inv_dat%found then
                              rcd_asn_dcs_hdr.dch_trn_invc_dte := rcd_lads_inv_dat.datum;
                           end if;
                           close csr_lads_inv_dat;

                        end if;

                     end if;

                     /*-*/
                     /* Update the details when the delivery data received
                     /*-*/
                     if rcd_asn_dcs_hdr.dch_delv_ind = '1' then
                        open csr_asn_dcs_det;
                        loop
                        fetch csr_asn_dcs_det into rcd_asn_dcs_det;
                           if csr_asn_dcs_det%notfound then
                              exit;
                           end if;
                           update asn_dcs_det
                              set dcd_whs_cust_gtin = trim(rcd_asn_dcs_det.ean11)
                            where dcd_mars_cde = rcd_asn_dcs_det.dcd_mars_cde
                              and dcd_pick_nbr = rcd_asn_dcs_det.dcd_pick_nbr
                              and dcd_seqn_nbr = rcd_asn_dcs_det.dcd_seqn_nbr;
                        end loop;
                        close csr_asn_dcs_det;
                     end if;

                     /*-*/
                     /* Update the status to *COMPLETE/*ACK_NORMAL when all transaction data received
                     /*-*/
                     if rcd_asn_dcs_hdr.dch_delv_ind = '1' and
                        rcd_asn_dcs_hdr.dch_sord_ind = '1' and
                        rcd_asn_dcs_hdr.dch_ship_ind = '1' and
                        rcd_asn_dcs_hdr.dch_invc_ind = '1' then
                        select asn_dcs_msg_sequence.nextval into rcd_asn_dcs_hdr.dch_smsg_nbr from dual;
                        rcd_asn_dcs_hdr.dch_smsg_cnt := 0;
                        rcd_asn_dcs_hdr.dch_smsg_tim := null;
                        rcd_asn_dcs_hdr.dch_smsg_ack := null;
                        if asn_configuration.get_target_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_tar) is null or
                           asn_configuration.get_target_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_tar) = '0' then
                           rcd_asn_dcs_hdr.dch_stat_cde := '*COMPLETE';
                        else
                           rcd_asn_dcs_hdr.dch_stat_cde := '*ACK_NORMAL';
                        end if;
                        var_send := true;
                     end if;

                  /*-*/
                  /* Pick type not recognised
                  /*-*/
                  else 

                     rcd_asn_dcs_hdr.dch_stat_cde := '*ERROR';
                     rcd_asn_dcs_hdr.dch_emsg_txt := 'Invalid pick type (' || rcd_asn_dcs_hdr.dch_pick_typ || ')';

               end case;

               /*-*/
               /* Process waiting ASN headers
               /*-*/
               if rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_NORMAL' or
                  rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_WARNING' or
                  rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_ALERTED' then

                  /*-*/
                  /* Retrieve the relevant warning parameters for the transaction
                  /*-*/
                  var_war_type := '0';
                  var_war_time := 0;
                  var_war_text := null;
                  if not(asn_configuration.get_source_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_frm) is null) then
                     var_war_type := asn_configuration.get_source_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_frm);
                     var_war_time := asn_configuration.get_source_warn_time(rcd_asn_dcs_hdr.dch_whs_ship_frm);
                     var_war_text := asn_configuration.get_source_warn_text(rcd_asn_dcs_hdr.dch_whs_ship_frm);
                  end if;
                  if not(asn_configuration.get_route_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar) is null) then
                     var_war_type := asn_configuration.get_route_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
                     var_war_time := asn_configuration.get_route_warn_time(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
                     var_war_text := asn_configuration.get_route_warn_text(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
                  end if;

                  /*-*/
                  /* Retrieve the relevant alert parameters for the transaction
                  /*-*/
                  var_alt_type := '0';
                  var_alt_time := 0;
                  var_alt_text := null;
                  if not(asn_configuration.get_source_alrt_type(rcd_asn_dcs_hdr.dch_whs_ship_frm) is null) then
                     var_alt_type := asn_configuration.get_source_alrt_type(rcd_asn_dcs_hdr.dch_whs_ship_frm);
                     var_alt_time := asn_configuration.get_source_alrt_time(rcd_asn_dcs_hdr.dch_whs_ship_frm);
                     var_alt_text := asn_configuration.get_source_alrt_text(rcd_asn_dcs_hdr.dch_whs_ship_frm);
                  end if;
                  if not(asn_configuration.get_route_alrt_type(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar) is null) then
                     var_alt_type := asn_configuration.get_route_alrt_type(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
                     var_alt_time := asn_configuration.get_route_alrt_time(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
                     var_alt_text := asn_configuration.get_route_alrt_text(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
                  end if;

                  /*-*/
                  /* Calculate the ASN header age
                  /*-*/
                  var_age_seconds := (sysdate - rcd_asn_dcs_hdr.dch_crtn_tim) * 86400;

                  /*-*/
                  /* Set the new wait status
                  /*-*/
                  if var_war_type != '0' and rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_NORMAL' then
                     if var_age_seconds >= var_war_time then
                        rcd_asn_dcs_hdr.dch_stat_cde := '*WAIT_WARNING';
                        asn_notification.send_warning_email(var_envr_cde || '_DCS_' || rcd_asn_dcs_hdr.dch_mars_cde,
                                                            var_war_text,
                                                            'Pick (' || rcd_asn_dcs_hdr.dch_pick_nbr || ') transaction has exceeded warning timeout');
                     end if;
                  end if;
                  if var_alt_type != '0' and rcd_asn_dcs_hdr.dch_stat_cde = '*WAIT_WARNING' then
                     if var_age_seconds >= var_alt_time then
                        rcd_asn_dcs_hdr.dch_stat_cde := '*WAIT_ALERTED';
                        if var_alt_type = '1' then
                           asn_notification.send_alert_email(var_envr_cde || '_DCS_' || rcd_asn_dcs_hdr.dch_mars_cde,
                                                             var_alt_text,
                                                             'Pick (' || rcd_asn_dcs_hdr.dch_pick_nbr || ') transaction has exceeded alert timeout');
                        end if;
                        if var_alt_type = '2' then
                           var_alt_text := replace(var_alt_text,'<PICK>',rcd_asn_dcs_hdr.dch_pick_nbr);
                           asn_notification.send_alert_message(var_alt_text);
                        end if;
                     end if;
                  end if;

               end if;

            /*-*/
            /* Process acknowledgement waiting status
            /*-*/
            else

               /*-*/
               /* Update the status to *COMPLETE when acknowledgement data received or no longer required
               /*-*/
               if not(rcd_asn_dcs_hdr.dch_smsg_ack is null) or
                  asn_configuration.get_target_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_tar) is null or
                  asn_configuration.get_target_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_tar) = '0' then
                  rcd_asn_dcs_hdr.dch_stat_cde := '*COMPLETE';
               end if;

               /*-*/
               /* Process waiting ASN headers
               /*-*/
               if rcd_asn_dcs_hdr.dch_stat_cde = '*ACK_NORMAL' or
                  rcd_asn_dcs_hdr.dch_stat_cde = '*ACK_WARNING' then

                  /*-*/
                  /* Retrieve the relevant warning parameters for the transaction
                  /*-*/
                  var_war_type := '0';
                  var_war_time := 0;
                  var_war_text := null;
                  if not(asn_configuration.get_target_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_tar) is null) then
                     var_war_type := asn_configuration.get_target_warn_type(rcd_asn_dcs_hdr.dch_whs_ship_tar);
                     var_war_time := asn_configuration.get_target_warn_time(rcd_asn_dcs_hdr.dch_whs_ship_tar);
                     var_war_text := asn_configuration.get_target_warn_text(rcd_asn_dcs_hdr.dch_whs_ship_tar);
                  end if;

                  /*-*/
                  /* Calculate the ASN header acknowledgement age
                  /*-*/
                  var_age_seconds := (sysdate - rcd_asn_dcs_hdr.dch_smsg_tim) * 86400;

                  /*-*/
                  /* Set the new wait status
                  /*-*/
                  if var_war_type != '0' and rcd_asn_dcs_hdr.dch_stat_cde = '*ACK_NORMAL' then
                     if var_age_seconds >= var_war_time then
                        rcd_asn_dcs_hdr.dch_stat_cde := '*ACK_WARNING';
                        if var_war_type = '1' then
                           asn_notification.send_warning_email(var_envr_cde || '_DCS_' || rcd_asn_dcs_hdr.dch_mars_cde,
                                                               var_war_text,
                                                               'Pick (' || rcd_asn_dcs_hdr.dch_pick_nbr || ') customer acknowledgement has exceeded warning timeout');
                        end if;
                        if var_war_type = '2' then
                           var_war_text := replace(var_war_text,'<PICK>',rcd_asn_dcs_hdr.dch_pick_nbr);
                           asn_notification.send_alert_message(var_war_text);
                        end if;
                     end if;
                  end if;

               end if;

            end if;

            /*-*/
            /* Update the ASN header row
            /*-*/
            update asn_dcs_hdr
               set dch_updt_tim = sysdate,
                   dch_stat_cde = rcd_asn_dcs_hdr.dch_stat_cde,
                   dch_delv_ind = rcd_asn_dcs_hdr.dch_delv_ind,
                   dch_sord_ind = rcd_asn_dcs_hdr.dch_sord_ind,
                   dch_ship_ind = rcd_asn_dcs_hdr.dch_ship_ind,
                   dch_invc_ind = rcd_asn_dcs_hdr.dch_invc_ind,
                   dch_smsg_nbr = rcd_asn_dcs_hdr.dch_smsg_nbr,
                   dch_smsg_cnt = rcd_asn_dcs_hdr.dch_smsg_cnt,
                   dch_smsg_tim = rcd_asn_dcs_hdr.dch_smsg_tim,
                   dch_smsg_ack = rcd_asn_dcs_hdr.dch_smsg_ack,
                   dch_emsg_txt = rcd_asn_dcs_hdr.dch_emsg_txt,
                   dch_trn_pick_nbr = rcd_asn_dcs_hdr.dch_trn_pick_nbr,
                   dch_trn_sord_nbr = rcd_asn_dcs_hdr.dch_trn_sord_nbr,
                   dch_trn_ship_nbr = rcd_asn_dcs_hdr.dch_trn_ship_nbr,
                   dch_trn_invc_nbr = rcd_asn_dcs_hdr.dch_trn_invc_nbr,
                   dch_trn_mars_iid = rcd_asn_dcs_hdr.dch_trn_mars_iid,
                   dch_trn_cust_iid = rcd_asn_dcs_hdr.dch_trn_cust_iid,
                   dch_trn_cust_pon = rcd_asn_dcs_hdr.dch_trn_cust_pon,
                   dch_trn_agrd_dte = rcd_asn_dcs_hdr.dch_trn_agrd_dte,
                   dch_trn_ordr_dte = rcd_asn_dcs_hdr.dch_trn_ordr_dte,
                   dch_trn_invc_dte = rcd_asn_dcs_hdr.dch_trn_invc_dte,
                   dch_trn_splt_shp = rcd_asn_dcs_hdr.dch_trn_splt_shp,
                   dch_trn_invc_val = rcd_asn_dcs_hdr.dch_trn_invc_val,
                   dch_trn_invc_gst = rcd_asn_dcs_hdr.dch_trn_invc_gst,
                   dch_trn_crcy_cde = rcd_asn_dcs_hdr.dch_trn_crcy_cde,
                   dch_trn_ship_iid = rcd_asn_dcs_hdr.dch_trn_ship_iid,
                   dch_trn_ship_nam = rcd_asn_dcs_hdr.dch_trn_ship_nam,
                   dch_trn_dock_nbr = rcd_asn_dcs_hdr.dch_trn_dock_nbr,
                   dch_trn_byer_ide = rcd_asn_dcs_hdr.dch_trn_byer_ide
             where dch_mars_cde = rcd_asn_dcs_hdr.dch_mars_cde
               and dch_pick_nbr = rcd_asn_dcs_hdr.dch_pick_nbr;
            if sql%notfound then
               raise_application_error(-20000, 'ASN DCS Header (' || rcd_asn_dcs_hdr.dch_mars_cde || '/' || rcd_asn_dcs_hdr.dch_pick_nbr || ') does not exist');
            end if;

            /*-*/
            /* Commit the database
            /*-*/
            commit;

            /*-*/
            /* Send ASN DCS header when required
            /* 1. Separate commit boundary
            /*-*/
            if var_send = true then
               send_message(rcd_asn_dcs_hdr.dch_smsg_nbr);
            end if;

         end if;

      end loop;
      close csr_asn_dcs_hdr_01;

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
         raise_application_error(-20000, 'FATAL ERROR - ASN - ASN_DCS_PROCESSOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /****************************************************/
   /* This procedure performs the send message routine */
   /****************************************************/
   procedure send_message(par_smsg_nbr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_smsg_nbr number;
      var_available boolean;
      var_procedure varchar2(4000);
      var_msg_proc asn_cfg_src.cfs_msg_proc%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_dcs_hdr is 
         select * 
           from asn_dcs_hdr t01
          where t01.dch_smsg_nbr = var_smsg_nbr
                for update nowait;
      rcd_asn_dcs_hdr csr_asn_dcs_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to convert the parameter into a number
      /*-*/
      var_smsg_nbr := 0;
      begin
         var_smsg_nbr := to_number(par_smsg_nbr);
      exception
         when others then
            raise_application_error(-20000, 'Unable to convert (' || par_smsg_nbr || ') into a number');
      end;

      /*-*/
      /* Attempt to lock the header row
      /* notes - must exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_asn_dcs_hdr;
         fetch csr_asn_dcs_hdr into rcd_asn_dcs_hdr;
         if csr_asn_dcs_hdr%notfound then
            raise_application_error(-20000, 'ASN DCS Header (' || var_smsg_nbr || ') not found');
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_asn_dcs_hdr%isopen then
         close csr_asn_dcs_hdr;
      end if;

      /*-*/
      /* Release the header lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Execute the required DCS EDI message procedure
      /*-*/
      var_msg_proc := 'asn_dcs_edi_default';
      if not(asn_configuration.get_source_procedure(rcd_asn_dcs_hdr.dch_whs_ship_frm) is null) then
         var_msg_proc := asn_configuration.get_source_procedure(rcd_asn_dcs_hdr.dch_whs_ship_frm);
      end if;
      if not(asn_configuration.get_route_procedure(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar) is null) then
         var_msg_proc := asn_configuration.get_route_procedure(rcd_asn_dcs_hdr.dch_whs_ship_frm,rcd_asn_dcs_hdr.dch_whs_ship_tar);
      end if;
      var_procedure := 'begin '||var_msg_proc||'.send_message('||var_smsg_nbr||'); end;';
      begin
         execute immediate var_procedure;
      exception
         when others then
            raise_application_error(-20000, 'ASN DCS EDI Message procedure (' || var_procedure || ') failed - ' || substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Update the ASN DCS header row
      /*-*/
      rcd_asn_dcs_hdr.dch_smsg_cnt := rcd_asn_dcs_hdr.dch_smsg_cnt + 1;
      if rcd_asn_dcs_hdr.dch_smsg_cnt = 1 then
         rcd_asn_dcs_hdr.dch_smsg_tim := sysdate;
      end if;
      update asn_dcs_hdr
         set dch_updt_tim = sysdate,
             dch_smsg_cnt = rcd_asn_dcs_hdr.dch_smsg_cnt,
             dch_smsg_tim = rcd_asn_dcs_hdr.dch_smsg_tim
       where dch_smsg_nbr = rcd_asn_dcs_hdr.dch_smsg_nbr;
      if sql%notfound then
         raise_application_error(-20000, 'ASN DCS Header (' || rcd_asn_dcs_hdr.dch_smsg_nbr || ') does not exist');
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - ASN - ASN_DCS_PROCESSOR - SEND_MESSAGE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_message;

   /**********************************************/
   /* This procedure performs the cancel routine */
   /**********************************************/
   procedure cancel(par_mars_cde in varchar2, par_pick_nbr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_asn_dcs_hdr is 
         select * 
           from asn_dcs_hdr t01
          where t01.dch_mars_cde = par_mars_cde
            and t01.dch_pick_nbr = par_pick_nbr
                for update nowait;
      rcd_asn_dcs_hdr csr_asn_dcs_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the header row
      /* notes - must exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_asn_dcs_hdr;
         fetch csr_asn_dcs_hdr into rcd_asn_dcs_hdr;
         if csr_asn_dcs_hdr%notfound then
            raise_application_error(-20000, 'ASN DCS Header (' || par_mars_cde || '/' || par_pick_nbr || ') not found');
         end if;
         if rcd_asn_dcs_hdr.dch_stat_cde = '*COMPLETE' or
            rcd_asn_dcs_hdr.dch_stat_cde = '*CANCELLED' then
            raise_application_error(-20000, 'ASN DCS Header (' || par_mars_cde || '/' || par_pick_nbr || ') is already *COMPLETE or *CANCELLED');
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_asn_dcs_hdr%isopen then
         close csr_asn_dcs_hdr;
      end if;

      /*-*/
      /* Release the header lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Update the ASN DCS header row
      /*-*/
      rcd_asn_dcs_hdr.dch_stat_cde := '*CANCELLED';
      update asn_dcs_hdr
         set dch_updt_tim = sysdate,
             dch_stat_cde = rcd_asn_dcs_hdr.dch_stat_cde
       where dch_mars_cde = rcd_asn_dcs_hdr.dch_mars_cde
         and dch_pick_nbr = rcd_asn_dcs_hdr.dch_pick_nbr;
      if sql%notfound then
         raise_application_error(-20000, 'ASN DCS Header (' || rcd_asn_dcs_hdr.dch_mars_cde || '/' || rcd_asn_dcs_hdr.dch_pick_nbr || ') does not exist');
      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - ASN - ASN_DCS_PROCESSOR - CANCEL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end cancel;

end asn_dcs_processor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_dcs_processor for ics_app.asn_dcs_processor;
grant execute on asn_dcs_processor to public;
