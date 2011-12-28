/******************/
/* Package Header */
/******************/
create or replace package lics_stream_execution as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_stream_execution
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Stream Execution

    The package implements the stream execution functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure submit_stream;

end lics_stream_execution;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_stream_execution as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the submit stream routine */
   /*****************************************************/
   procedure submit_stream is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_stream xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('TRANSACTION_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve and load the stream
      /*-*/
      obj_xml_stream := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/ICS_STREAM');
      lics_stream_loader.load(upper(xslProcessor.valueOf(obj_xml_stream,'@CODE')),xslProcessor.valueOf(obj_xml_stream,'@TEXT'),xslProcessor.valueOf(obj_xml_stream,'@PROCEDURE'));

      /*-*/
      /* Retrieve and set the stream parameters
      /*-*/
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/ICS_STREAM/PARAM');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         lics_stream_loader.set_parameter(upper(xslProcessor.valueOf(obj_xml_node,'@CODE')),xslProcessor.valueOf(obj_xml_node,'@VALUE'));
      end loop;

      /*-*/
      /* Execute the stream
      /*-*/
      lics_stream_loader.execute;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - ICS_STREAM_EXECUTION - SUBMIT_STREAM - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end submit_stream;

end lics_stream_execution;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_execution for lics_app.lics_stream_execution;
grant execute on lics_stream_execution to public;