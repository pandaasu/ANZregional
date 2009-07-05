/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_gen_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_gen_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - General functions

    This package contain the general functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear_mesg_data;
   function get_mesg_count return number;
   procedure add_mesg_data(par_message in varchar2);
   function get_mesg_data return sms_xml_type pipelined;
   function retrieve_meta_data return sms_xml_type pipelined;
   procedure update_meta_data(par_user in varchar2);
   function retrieve_query_data return sms_xml_type pipelined;
   procedure update_query_data(par_user in varchar2);

end sms_gen_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_gen_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;
   pvar_cfrm varchar2(2000 char);
   type ptyp_mesg is table of varchar2(2000 char) index by binary_integer;
   ptbl_mesg ptyp_mesg;

   /**********************************************************/
   /* This procedure performs the clear message data routine */
   /**********************************************************/
   procedure clear_mesg_data is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Clear the message data
      /*-*/
      ptbl_mesg.delete;
      pvar_cfrm := null;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - CLEAR_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_mesg_data;

   /*********************************************************/
   /* This procedure performs the get message count routine */
   /*********************************************************/
   function get_mesg_count return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Return the message data count
      /*-*/
      return ptbl_mesg.count;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - GET_MESG_COUNT - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_count;

   /********************************************************/
   /* This procedure performs the add message data routine */
   /********************************************************/
   procedure add_mesg_data(par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Add the message data
      /*-*/
      ptbl_mesg(ptbl_mesg.count+1) := par_message;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - ADD_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_mesg_data;

   /********************************************************/
   /* This procedure performs the get message data routine */
   /********************************************************/
   function get_mesg_data return sms_xml_type pipelined is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Pipe the message data when required
      /*-*/
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(sms_xml_object('<?xml version="1.0" encoding="UTF-8"?><SMS_RESPONSE>'));
      end if;
      for idx in 1..ptbl_mesg.count loop
         pipe row(sms_xml_object('<ERROR ERRTXT="'||sms_to_xml(ptbl_mesg(idx))||'"/>'));
      end loop;
      if not(pvar_cfrm is null) then
         pipe row(sms_xml_object('<CONFIRM CONTXT="'||sms_to_xml(pvar_cfrm)||'"/>'));
      end if;
      if ptbl_mesg.count != 0 or not(pvar_cfrm is null) then
         pipe row(sms_xml_object('</SMS_RESPONSE>'));
      end if;

      /*-*/
      /* Return
      /*-*/
      return;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_GEN_FUNCTION - GET_MESG_DATA - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mesg_data;

   /*******************************************************/
   /* This procedure performs the read xml stream routine */
   /*******************************************************/
   procedure read_xml_stream(par_source in varchar2, par_stream in clob) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the forecast data
      /*-*/
      delete from fcst_data;
      commit;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,par_stream);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the primary node
      /*-*/
      var_wrkr := 0;
      obj_xml_element := xmlDom.getDocumentElement(obj_xml_document);
      obj_xml_node := xmlDom.makeNode(obj_xml_element);
      read_xml_child(par_source, obj_xml_node);

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_stream;

   /******************************************************/
   /* This procedure performs the read xml child routine */
   /******************************************************/
   procedure read_xml_child(par_source in varchar2, par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      rcd_fcst_data fcst_data%rowtype;
      var_string varchar2(32767);
      var_char varchar2(1);
      var_value varchar2(4000);
      var_index number;
      type typ_wrkw is table of number index by binary_integer;
      tbl_wrkw typ_wrkw;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'DATACELL' then

            --start the new measure;
            --clear keys

         when 'CharacteristicDimension' then

            --start the new dimension;
            --probably can ignore

         when 'CHARACTERISTIC' then

            --when loading meta data find unique instances of these and load known values from CHARACTERISTICMEMBER
            --sms requests can then be built from this meta data

            name attribute = dimension type name
            text attribute = dimension type description
            Name="0MATERIAL__ZCLF01" Text="Business Segment"

         when 'CHARACTERISTICMEMBER' then

            name attribute = dimension member name
            text attribute = dimension member description
            Name="05" Text="Petcare"

            if name attribute = 'SUMME' then ignore
            else store

         when 'KEYFIGURE' then

            name attribute = measure name
            text attribute = measue description
            Name="4ABL45NH9FJTW2S0AHCVK6GJB" Text="ACT+UNPOST%Target"

         when 'VALUE' then

            name text = measure value
            17.81281095961305

         when '#CDATA-SECTION' then
            rcd_fcst_data.sap_material_code := '*ROW';
            for idx in 1..39 loop
               tbl_wrkw(idx) := 0;
	    end loop;
            var_string := rtrim(ltrim(xmlDom.getNodeValue(par_xml_node),'['),']');
            if not(var_string is null) then
               var_value := null;
               var_index := 0;
               for idx in 1..length(var_string) loop
                  var_char := substr(var_string,idx,1);
                  if var_char = chr(9) then
                     if rcd_fcst_data.sap_material_code = '*ROW' then
                        if length(var_value) > 18 then
                           raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Material code ('||var_value||') exceeds maximum length 18');
                        end if;
                        rcd_fcst_data.sap_material_code := var_value;
                     else
                        var_index := var_index + 1;
                        begin
                           if substr(var_value,length(var_value),1) = '-' then
                              tbl_wrkw(var_index) := to_number('-' || substr(var_value,1,length(var_value) - 1));
                           else
                              tbl_wrkw(var_index) := to_number(var_value);
                           end if;
                        exception
                           when others then
                              raise_application_error(-20000, 'Text file data row '||var_wrkr||' column '||var_index||' - Invalid number ('||var_value||')');
                        end;
                     end if;
                     var_value := null;
                  else
                     var_value := var_value||var_char;
                  end if;
               end loop;
               if rcd_fcst_data.sap_material_code = '*ROW' then
                  if length(var_value) > 18 then
                     raise_application_error(-20000, 'Text file data row '||var_wrkr||' - Material code ('||var_value||') exceeds maximum length 18');
                  end if;
                  rcd_fcst_data.sap_material_code := var_value;
               else
                  var_index := var_index + 1;
                  begin
                     if substr(var_value,length(var_value),1) = '-' then
                        tbl_wrkw(var_index) := to_number('-' || substr(var_value,1,length(var_value) - 1));
                     else
                        tbl_wrkw(var_index) := to_number(var_value);
                     end if;
                  exception
                     when others then
                        raise_application_error(-20000, 'Text file data row '||var_wrkr||' column '||var_index||' - Invalid number ('||var_value||')');
                  end;
               end if;
            end if;
            if par_source = '*TXQ' then
               if var_index != 13 then
                  raise_application_error(-20000, 'Text file data (quantity only) row '||var_wrkr||' - Column count must be equal to 14');
               end if;
            end if;
            if par_source = '*TXV' then
               if var_index != 39 then
                  raise_application_error(-20000, 'Text file data (quantity/value) row '||var_wrkr||' - Column count must be equal to 40');
               end if;
            end if;

      end case;

      /*-*/
      /* Process the child nodes
      /*-*/
      obj_xml_node_list := xmlDom.getChildNodes(par_xml_node);
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(par_source, obj_xml_node);
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_child;


   /********************************************************/
   /* This procedure performs the read spreadsheet routine */
   /********************************************************/
   procedure read_spreadsheet(par_procedure in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the status
      /*-*/
      if var_wrks_status != '*LOADED' then
         raise_application_error(-20000, 'Read Spreadsheet - Spreadsheet data has not been loaded');
      end if;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_procedure is null then
         raise_application_error(-20000, 'Read Spreadsheet - Spreadsheet read procedure must be supplied');
      end if;

      /*-*/
      /* Clear the value arrays
      /*-*/
      tbl_wrks_dtas.delete;
      tbl_wrks_dtar.delete;
      tbl_wrks_dtac.delete;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lobReference);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and process the primary node
      /*-*/
      obj_xml_element := xmlDom.getDocumentElement(obj_xml_document);
      obj_xml_node := xmlDom.makeNode(obj_xml_element);
      read_xml_child(obj_xml_node);

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Execute the spreadsheet read procedure
      /*-*/
      begin
         execute immediate 'begin ' || par_procedure || '; end;';
      exception
         when others then
            raise_application_error(-20000, 'Read Spreadsheet - Procedure (' || par_procedure || ') failed - ' || substr(SQLERRM, 1, 3000));
      end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_spreadsheet;

   /******************************************************/
   /* This procedure performs the read xml child routine */
   /******************************************************/
   procedure read_xml_child(par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_element xmlDom.domElement;
      obj_xml_node xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      var_string varchar2(32767);
      var_char varchar2(1 char);
      var_value varchar2(2000 char);
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'XLSTREAM' then
            null;
         when 'XLSHEET' then
            obj_xml_element := xmlDom.makeElement(par_xml_node);
            var_index := tbl_wrks_dtas.count + 1;
            tbl_wrks_dtas(var_index).she_iden := xmlDom.getAttribute(obj_xml_element,'IDENTIFIER');
            tbl_wrks_dtas(var_index).she_rsix := 0;
            tbl_wrks_dtas(var_index).she_reix := 0;
         when 'XR' then
            var_index := tbl_wrks_dtar.count + 1;
            tbl_wrks_dtar(var_index).row_csix := 0;
            tbl_wrks_dtar(var_index).row_ceix := 0;
            if tbl_wrks_dtas(tbl_wrks_dtas.count).she_rsix = 0 then
               tbl_wrks_dtas(tbl_wrks_dtas.count).she_rsix := var_index;
            end if;
            tbl_wrks_dtas(tbl_wrks_dtas.count).she_reix := var_index;
         when '#CDATA-SECTION' then
            begin
               var_string := xmlDom.getNodeValue(par_xml_node);
               var_value := null;
               for idx in 1..length(var_string) loop
                  var_char := substr(var_string,idx,1);
                  if var_char = chr(9) then
                     var_index := tbl_wrks_dtac.count + 1;
                     tbl_wrks_dtac(var_index) := var_value;
                     if tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix = 0 then
                        tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix := var_index;
                     end if;
                     tbl_wrks_dtar(tbl_wrks_dtar.count).row_ceix := var_index;
                     var_value := null;
                  else
                     var_value := var_value||var_char;
                  end if;
               end loop;
               var_index := tbl_wrks_dtac.count + 1;
               tbl_wrks_dtac(var_index) := var_value;
               if tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix = 0 then
                  tbl_wrks_dtar(tbl_wrks_dtar.count).row_csix := var_index;
               end if;
               tbl_wrks_dtar(tbl_wrks_dtar.count).row_ceix := var_index;
            exception
               when others then
                  raise_application_error(-20000, 'Read Spreadsheet - Row (' || tbl_wrks_dtar.count || ' Cell (' || var_index || ') read failed - ' || substr(SQLERRM, 1, 1024));
            end;
            else raise_application_error(-20000, 'Read Spreadsheet - Type (' || xmlDom.getNodeName(par_xml_node) || ') not recognised');
         end case;

      /*-*/
      /* Process the child nodes
      /*-*/
      obj_xml_node_list := xmlDom.getChildNodes(par_xml_node);
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(obj_xml_node);
      end loop;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end read_xml_child;


/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   ptbl_mesg.delete;
   pvar_end_code := 0;

end sms_gen_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_gen_function for sms_app.sms_gen_function;
grant execute on sms_app.sms_gen_function to public;
