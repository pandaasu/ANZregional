/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_wmsics01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ics_wmsics01_loader
    Owner   : ics_app

    Description
    -----------
    WMS to ICS - WMSICS01 - Stock On Hand Interface Loader (Korea)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/02   Steve Gregan   Created
    2009/06   Trevor Keon    Altered storage loc logic when creating ICSAPL01

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_wmsics01_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_wmsics01_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   type typ_inbound is table of varchar2(2000 char) index by binary_integer;
   tbl_inbound typ_inbound;
   type typ_outbound is table of varchar2(2000 char) index by binary_integer;
   tbl_outbound typ_outbound;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the transaction variables
      /*-*/
      tbl_inbound.delete;
      tbl_outbound.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Build the inbound data array
      /*-*/
      tbl_inbound(tbl_inbound.count + 1) := par_record;

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
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_clob clob;
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_stream xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;
      var_output varchar2(2000 char);
      var_in_item varchar2(256 char);
      var_sap_plant varchar2(256 char);
      var_avail_date varchar2(256 char);
      var_qty varchar2(256 char);
      var_stor_loc varchar2(256 char);
      var_stock_status varchar2(256 char);
      var_acbbd2 varchar2(256 char);
      var_stock_type varchar2(256 char);
      var_timestamp varchar2(256 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select t01.matnr,
                t01.mtart
           from lads_mat_hdr t01
          where ltrim(t01.matnr,' 0') = var_in_item;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore when no data
      /*-*/
      if tbl_inbound.count = 0 then
         return;
      end if;

      /*-*/
      /* Load the temporary clob
      /*-*/
      dbms_lob.createtemporary(var_clob,true);
      for idx in 1..tbl_inbound.count loop
         dbms_lob.writeappend(var_clob, length(tbl_inbound(idx)), tbl_inbound(idx));
      end loop;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,var_clob);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve parent node
      /*-*/
      obj_xml_stream := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/FRESHNESS_REPORT');

      /*-*/
      /* Retrieve and process the HDR nodes
      /* **notes** 1. Only FG materials are forwarded to Apollo
      /*              (Materials with 8 digits or materials starting with English letter(s) are to be regarded as FGs)
      /*-*/
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/FRESHNESS_REPORT/HDR');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop

         /*-*/
         /* Retrieve the HDR node values
         /*-*/
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         var_in_item := xslProcessor.valueOf(obj_xml_node,'IN_ITEM');
         var_sap_plant := xslProcessor.valueOf(obj_xml_node,'SAP_PLANT');
         var_avail_date := xslProcessor.valueOf(obj_xml_node,'AVAIL_DATE');
         var_qty := xslProcessor.valueOf(obj_xml_node,'QTY');
         var_stor_loc := xslProcessor.valueOf(obj_xml_node,'STOR_SLOC');
         var_stock_status := xslProcessor.valueOf(obj_xml_node,'STOCK_STATUS');
         var_acbbd2 := xslProcessor.valueOf(obj_xml_node,'ACBBD2');

         /*-*/
         /* Retrieve the material code
         /*-*/
         open csr_material;
         fetch csr_material into rcd_material;
         if csr_material%notfound then
            rcd_material.mtart := 'XXXX';
         end if;
         close csr_material;

         /*-*/
         /* Output finished good materials only
         /*-*/
         if rcd_material.mtart = 'FERT' then
            var_output := var_in_item||',';
            var_output := var_output||var_sap_plant||',';
            var_output := var_output||var_avail_date||',';
            var_output := var_output||var_qty||',';
            if trim(var_stor_loc) = '0001' and (var_stock_status is null or trim(var_stock_status) = '' or trim(var_stock_status) = 'X') then
               var_output := var_output||'F,';
            elsif trim(var_stor_loc) = '0009' and (var_stock_status is null or trim(var_stock_status) = '') then
               var_output := var_output||'F,';
            else
               var_output := var_output||'X,';
            end if;
            var_output := var_output||var_acbbd2||',';
            var_output := var_output||to_char(tbl_outbound.count+1)||',';
            tbl_outbound(tbl_outbound.count+1) := var_output;
         end if;

      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Create the outbound interface when required
      /*-*/
      if tbl_outbound.count != 0 then
         var_timestamp := to_char(sysdate,'yyyymmddhh24miss');
         var_instance := lics_outbound_loader.create_interface('ICSAPL01', null, 'IN_ONHAND_SUP_STG_LADASU02.3.dat');
         for idx in 1..tbl_outbound.count loop
            lics_outbound_loader.append_data(tbl_outbound(idx)||to_char(tbl_outbound.count)||','||var_timestamp);
         end loop;
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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Add the exception to the interface
         /*-*/
         lics_inbound_utility.add_exception(var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end ics_wmsics01_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_wmsics01_loader for ics_app.ics_wmsics01_loader;
grant execute on ics_app.ics_wmsics01_loader to lics_app;
