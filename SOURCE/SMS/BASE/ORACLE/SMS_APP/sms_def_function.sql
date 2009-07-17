/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_qry_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_gen_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Query functions

    This package contain the query functions and procedures.

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
create or replace package body sms_app.sms_qry_function as

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


<ExceptionReport Size="50">

  <ProcessingDate>2009-06-22</ProcessingDate>

  <Query Name="Y135_DAILY_SMS_FCST_CP_LP" Text="(/LCL/CN-AT) Daily SMS - Total China - Fcast CP LP"


      /*-*/
      /* Process the attribute node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))
         when 'QUERY' then

            --start the new measure;
            --clear keys

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

            var_string := trim(xmlDom.getNodeValue(par_xml_node));

         else
            null;
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
create or replace public synonym sms_qry_function for sms_app.sms_gen_function;
grant execute on sms_app.sms_qry_function to public;
