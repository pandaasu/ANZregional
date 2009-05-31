/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_tes_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_tes_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Test Function

    This package contain the procedures and functions for product test.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   function load_response return pts_xml_type pipelined;
   function select_response return pts_xml_type pipelined;
   procedure update_response;
   procedure load_pet_panel(par_tes_code in number);
   procedure load_hou_panel(par_tes_code in number);

end pts_tes_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_tes_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure clear_panel(par_tes_code in number, par_req_mem_count in number, par_req_res_count in number);
   procedure select_pet_panel(par_tes_code in number, par_pan_type in varchar2, par_pet_multiple in varchar2);
   procedure select_hou_panel(par_tes_code in number, par_pan_type in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   type rcd_sel_group is record(sel_group varchar2(32 char),
                                str_rule number,
                                end_rule number,
                                req_mem_count number,
                                req_res_count number,
                                sel_mem_count number,
                                sel_res_count number);
   type typ_sel_group is table of rcd_sel_group index by binary_integer;
   tbl_sel_group typ_sel_group;
   type rcd_sel_rule is record(sel_group varchar2(32 char),
                               tab_code varchar2(32 char),
                               fld_code number,
                               rul_code varchar2(32 char),
                               str_value number,
                               end_value number,
                               sel_count number);
   type typ_sel_rule is table of rcd_sel_rule index by binary_integer;
   tbl_sel_rule typ_sel_rule;
   type rcd_sel_value is record(sel_group varchar2(32 char),
                                tab_code varchar2(32 char),
                                fld_code number,
                                val_code number,
                                val_text varchar2(256 char),
                                val_pcnt number,
                                req_mem_count number,
                                req_res_count number,
                                sel_mem_count number,
                                sel_res_count number,
                                sel_count number,
                                fld_count number);
   type typ_sel_value is table of rcd_sel_value index by binary_integer;
   tbl_sel_value typ_sel_value;

   /*****************************************************/
   /* This procedure performs the retrieve list routine */
   /*****************************************************/
   function retrieve_list return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_pag_size number;
      var_row_count number;

      /*-*/
      /* Local cursors
      /*-*/


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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      pipe row(pts_xml_object('<LSTCTL COLCNT="2"/>'));

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code varchar2(32);
      var_tab_flag boolean;
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_stm_definition t01
          where t01.std_stm_code = pts_to_number(var_tes_code);
      rcd_retrieve csr_retrieve%rowtype;

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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tes_code := xslProcessor.valueOf(obj_pts_request,'@TESCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDTES' and var_action != '*CRTTES' and var_action != '*CPYTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing test when required
      /*-*/
      if var_action = '*UPDTES' or var_action = '*CPYTES' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Selection template ('||var_tes_code||') does not exist');
            return;
         end if;
         close csr_retrieve;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test XML
      /*-*/
      if var_action = '*UPDTES' then
         var_output := '<TES TESCODE="'||to_char(rcd_retrieve.std_stm_code)||'"';
         var_output := var_output||' TESTEXT="'||pts_to_xml(rcd_retrieve.std_stm_text)||'"';
         var_output := var_output||' TESSTAT="'||to_char(rcd_retrieve.std_stm_status)||'"';
         var_output := var_output||' TESTARG="'||to_char(rcd_retrieve.std_stm_target)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYTES' then
         var_output := '<TEST TESCODE="'||to_char(rcd_retrieve.std_stm_code)||'"';
         var_output := var_output||' TESTEXT="'||pts_to_xml(rcd_retrieve.std_stm_text)||'"';
         var_output := var_output||' TESSTAT="'||to_char(rcd_retrieve.std_stm_status)||'"';
         var_output := var_output||' TESTARG="'||to_char(rcd_retrieve.std_stm_target)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTTES' then
         var_output := '<TEST TESCODE="*NEW"';
         var_output := var_output||' TESTEXT=""';
         var_output := var_output||' TESSTAT="1"';
         var_output := var_output||' TESTARG="1"/>';
         pipe row(pts_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /*****************************************************/
   /* This procedure performs the load response routine */
   /*****************************************************/
   function load_response return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/


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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tes_code := xslProcessor.valueOf(obj_pts_request,'@TESCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*LODRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the test
      /*-*/


      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESTEXT="'||pts_to_xml('Dummy product test')||'"/>'));

      /*-*/
      /* Retrieve the response meta data information
      /*-*/
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(1)||'" DAYTXT="'||pts_to_xml('Day 1')||'" DAYBGN="'||pts_to_xml('1')||'" QUECDE="'||to_char(1)||'" QUETXT="'||pts_to_xml('Question #01')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(1)||'" DAYTXT="'||pts_to_xml('Day 1')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(2)||'" QUETXT="'||pts_to_xml('Question #02')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(1)||'" DAYTXT="'||pts_to_xml('Day 1')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(3)||'" QUETXT="'||pts_to_xml('Question #03')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(1)||'" DAYTXT="'||pts_to_xml('Day 1')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(4)||'" QUETXT="'||pts_to_xml('Question #04')||'"/>'));

      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(2)||'" DAYTXT="'||pts_to_xml('Day 2')||'" DAYBGN="'||pts_to_xml('1')||'" QUECDE="'||to_char(5)||'" QUETXT="'||pts_to_xml('Question #05')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(2)||'" DAYTXT="'||pts_to_xml('Day 2')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(6)||'" QUETXT="'||pts_to_xml('Question #06')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(2)||'" DAYTXT="'||pts_to_xml('Day 2')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(7)||'" QUETXT="'||pts_to_xml('Question #07')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(2)||'" DAYTXT="'||pts_to_xml('Day 2')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(8)||'" QUETXT="'||pts_to_xml('Question #08')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(2)||'" DAYTXT="'||pts_to_xml('Day 2')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(9)||'" QUETXT="'||pts_to_xml('Question #09')||'"/>'));

      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(3)||'" DAYTXT="'||pts_to_xml('Day 3')||'" DAYBGN="'||pts_to_xml('1')||'" QUECDE="'||to_char(1)||'" QUETXT="'||pts_to_xml('Question #01')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(3)||'" DAYTXT="'||pts_to_xml('Day 3')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(2)||'" QUETXT="'||pts_to_xml('Question #02')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(3)||'" DAYTXT="'||pts_to_xml('Day 3')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(3)||'" QUETXT="'||pts_to_xml('Question #03')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(3)||'" DAYTXT="'||pts_to_xml('Day 3')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(4)||'" QUETXT="'||pts_to_xml('Question #04')||'"/>'));

      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(4)||'" DAYTXT="'||pts_to_xml('Day 4')||'" DAYBGN="'||pts_to_xml('1')||'" QUECDE="'||to_char(5)||'" QUETXT="'||pts_to_xml('Question #05')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(4)||'" DAYTXT="'||pts_to_xml('Day 4')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(6)||'" QUETXT="'||pts_to_xml('Question #06')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(4)||'" DAYTXT="'||pts_to_xml('Day 4')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(7)||'" QUETXT="'||pts_to_xml('Question #07')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(4)||'" DAYTXT="'||pts_to_xml('Day 4')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(8)||'" QUETXT="'||pts_to_xml('Question #08')||'"/>'));
      pipe row(pts_xml_object('<QUESTION DAYCDE="'||to_char(4)||'" DAYTXT="'||pts_to_xml('Day 4')||'" DAYBGN="'||pts_to_xml('0')||'" QUECDE="'||to_char(9)||'" QUETXT="'||pts_to_xml('Question #09')||'"/>'));

      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2221)||'" RESTXT="'||pts_to_xml('(2221) Pet name 2221')||'" RESSTS="'||pts_to_xml('1')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2222)||'" RESTXT="'||pts_to_xml('(2222) Pet name 2222')||'" RESSTS="'||pts_to_xml('1')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2223)||'" RESTXT="'||pts_to_xml('(2223) Pet name 2223')||'" RESSTS="'||pts_to_xml('0')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2224)||'" RESTXT="'||pts_to_xml('(2224) Pet name 2224')||'" RESSTS="'||pts_to_xml('0')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2225)||'" RESTXT="'||pts_to_xml('(2225) Pet name 2225')||'" RESSTS="'||pts_to_xml('0')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2226)||'" RESTXT="'||pts_to_xml('(2226) Pet name 2226')||'" RESSTS="'||pts_to_xml('1')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2227)||'" RESTXT="'||pts_to_xml('(2227) Pet name 2227')||'" RESSTS="'||pts_to_xml('0')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2228)||'" RESTXT="'||pts_to_xml('(2228) Pet name 2228')||'" RESSTS="'||pts_to_xml('1')||'"/>'));
      pipe row(pts_xml_object('<RESPONSE RESCDE="'||to_char(2229)||'" RESTXT="'||pts_to_xml('(2229) Pet name 2229')||'" RESSTS="'||pts_to_xml('0')||'"/>'));


      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - LOAD_RESPONSE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_response;

   /*******************************************************/
   /* This procedure performs the select response routine */
   /*******************************************************/
   function select_response return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code varchar2(32);
      var_res_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/


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
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      var_tes_code := xslProcessor.valueOf(obj_pts_request,'@TESCDE');
      var_res_code := xslProcessor.valueOf(obj_pts_request,'@RESCDE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the test
      /*-*/


      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test response xml
      /*-*/
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(1)||'" QUECDE="'||to_char(1)||'" RESVAL="'||to_char(1)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(1)||'" QUECDE="'||to_char(2)||'" RESVAL="'||to_char(2)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(1)||'" QUECDE="'||to_char(3)||'" RESVAL="'||to_char(2)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(1)||'" QUECDE="'||to_char(4)||'" RESVAL="'||to_char(1)||'"/>'));

      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(2)||'" QUECDE="'||to_char(5)||'" RESVAL="'||to_char(5)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(2)||'" QUECDE="'||to_char(6)||'" RESVAL="'||to_char(4)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(2)||'" QUECDE="'||to_char(7)||'" RESVAL="'||to_char(3)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(2)||'" QUECDE="'||to_char(8)||'" RESVAL="'||to_char(4)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(2)||'" QUECDE="'||to_char(9)||'" RESVAL="'||to_char(5)||'"/>'));

      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(3)||'" QUECDE="'||to_char(1)||'" RESVAL="'||to_char(6)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(3)||'" QUECDE="'||to_char(2)||'" RESVAL="'||to_char(7)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(3)||'" QUECDE="'||to_char(3)||'" RESVAL="'||to_char(8)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(3)||'" QUECDE="'||to_char(4)||'" RESVAL="'||to_char(9)||'"/>'));

      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(4)||'" QUECDE="'||to_char(5)||'" RESVAL="'||to_char(8)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(4)||'" QUECDE="'||to_char(6)||'" RESVAL="'||to_char(7)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(4)||'" QUECDE="'||to_char(7)||'" RESVAL="'||to_char(6)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(4)||'" QUECDE="'||to_char(8)||'" RESVAL="'||to_char(7)||'"/>'));
      pipe row(pts_xml_object('<RESPONSE DAYCDE="'||to_char(4)||'" QUECDE="'||to_char(9)||'" RESVAL="'||to_char(8)||'"/>'));


      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(pts_xml_object('</PTS_RESPONSE>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - SELECT_RESPONSE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_response;

   /*******************************************************/
   /* This procedure performs the update response routine */
   /*******************************************************/
   procedure update_response is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_tes_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      pts_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PTS_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_pts_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_pts_request,'@ACTION'));
      if var_action != '*UPDRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      if var_tes_code is null then
         pts_gen_function.add_mesg_data('Product test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve and lock the existing selection template
      /*-*/
   --   var_found := false;
   --   begin
   --      open csr_retrieve;
   --      fetch csr_retrieve into rcd_retrieve;
   --      if csr_retrieve%found then
   --         var_found := true;
   --      end if;
   --      close csr_retrieve;
   --   exception
   --      when others then
   --         pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') is currently locked');
   --         return;
   --   end;
   --   if var_found = false then
   --      pts_gen_function.add_mesg_data('Selection template ('||to_char(var_stm_code)||') does not exist');
   --   end if;


      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_TES_FUNCTION - UPDATE_RESPONSE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_response;

   /******************************************************/
   /* This procedure performs the load pet panel routine */
   /******************************************************/
   procedure load_pet_panel(par_tes_code in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_tes_code number;
      var_tes_status number;
      var_tes_error varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_test is 
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code
            for update nowait;
      rcd_test csr_test%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      if par_tes_code is null then
         raise_application_error(-20000, 'Test code must be specified');
      end if;
      var_tes_code := par_tes_code;

      /*-*/
      /* Attempt to retrieve and lock the test definition
      /* **notes** - 1. Must exist
      /*             2. Must not be locked
      /*             3. Must be target (1) pet test
      /*             4. Must be status (1) raised or (5) Errored
      /*-*/
      var_found := false;
      begin
         open csr_test;
         fetch csr_test into rcd_test;
         if csr_test%found then
            var_found := true;
         end if;
         close csr_test;
      exception
         when others then
            raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') is locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') does not exist');
      end if;
      if rcd_test.tde_tes_target != 1 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') must be target (Pet Test) - panel selection not allowed');
      end if;
      if rcd_test.tde_tes_status != 1 and
         rcd_test.tde_tes_status != 5 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') must be status (Raised or Errored) - panel selection not allowed');
      end if;

      /*-*/
      /* Clear and select the test panel
      /* **note** 1. Autonomous transactions that not impact the test lock
      /*-*/
      var_tes_status := 1;
      var_tes_error := null;
      begin
         clear_panel(rcd_test.tde_tes_code, rcd_test.tde_req_mem_count, rcd_test.tde_req_res_count);
         select_pet_panel(rcd_test.tde_tes_code, '*MEMBER', nvl(rcd_test.tde_hou_pet_multiple,'0'));
         select_pet_panel(rcd_test.tde_tes_code, '*RESERVE', nvl(rcd_test.tde_hou_pet_multiple,'0'));
      exception
         when others then
            var_tes_status := 5;
            var_tes_error := substr(sqlerrm, 1, 4000);
      end;

      /*-*/
      /* Update the test definition
      /* **note** 1. Releases the test lock
      /*-*/
      update pts_tes_definition
         set tde_tes_status = var_tes_status,
             tde_tes_error = var_tes_error
       where tde_tes_code = rcd_test.tde_tes_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'PTS_TES_FUNCTION - LOAD_PET_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_pet_panel;

   /************************************************************/
   /* This procedure performs the load household panel routine */
   /************************************************************/
   procedure load_hou_panel(par_tes_code in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_tes_code number;
      var_tes_status number;
      var_tes_error varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_test is 
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code
            for update nowait;
      rcd_test csr_test%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameter values
      /*-*/
      if par_tes_code is null then
         raise_application_error(-20000, 'Test code must be specified');
      end if;
      var_tes_code := par_tes_code;

      /*-*/
      /* Attempt to retrieve and lock the test definition
      /* **notes** - 1. Must exist
      /*             2. Must not be locked
      /*             3. Must be target (2) household test
      /*             4. Must be status (1) raised or (5) Errored
      /*-*/
      var_found := false;
      begin
         open csr_test;
         fetch csr_test into rcd_test;
         if csr_test%found then
            var_found := true;
         end if;
         close csr_test;
      exception
         when others then
            raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') is locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') does not exist');
      end if;
      if rcd_test.tde_tes_target != 2 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') must be target (Household Test) - panel selection not allowed');
      end if;
      if rcd_test.tde_tes_status != 1 and
         rcd_test.tde_tes_status != 5 then
         raise_application_error(-20000, 'Test code (' || to_char(var_tes_code) || ') must be status (Raised or Errored) - panel selection not allowed');
      end if;

      /*-*/
      /* Clear and select the test panel
      /* **note** 1. Autonomous transactions that not impact the test lock
      /*-*/
      var_tes_status := 1;
      var_tes_error := null;
      begin
         clear_panel(rcd_test.tde_tes_code, rcd_test.tde_req_mem_count, rcd_test.tde_req_res_count);
         select_hou_panel(rcd_test.tde_tes_code, '*MEMBER');
         select_hou_panel(rcd_test.tde_tes_code, '*RESERVE');
      exception
         when others then
            var_tes_status := 5;
            var_tes_error := substr(sqlerrm, 1, 4000);
      end;

      /*-*/
      /* Update the test definition
      /* **note** 1. Releases the test lock
      /*-*/
      update pts_tes_definition
         set tde_tes_status = var_tes_status,
             tde_tes_error = var_tes_error
       where tde_tes_code = rcd_test.tde_tes_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'PTS_TES_FUNCTION - LOAD_HOU_PANEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_hou_panel;

   /***************************************************/
   /* This procedure performs the clear panel routine */
   /***************************************************/
   procedure clear_panel(par_tes_code in number, par_req_mem_count in number, par_req_res_count in number) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_sel_group varchar2(32);
      var_tsg_mem_count number;
      var_tsg_res_count number;
      var_tsv_mem_count number;
      var_tsv_res_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_group is 
         select t01.*
           from pts_tes_sel_group t01
          where t01.tsg_tes_code = par_tes_code
          order by t01.tsg_sel_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_rule is 
         select t01.*
           from pts_tes_sel_rule t01
          where t01.tsr_tes_code = par_tes_code
            and t01.tsr_sel_group = var_sel_group
          order by t01.tsr_tab_code asc,
                   t01.tsr_fld_code asc;
      rcd_rule csr_rule%rowtype;

      cursor csr_value is 
         select t01.*
           from pts_tes_sel_value t01
          where t01.tsv_tes_code = par_tes_code
            and t01.tsv_sel_group = rcd_rule.tsr_sel_group
            and t01.tsv_tab_code = rcd_rule.tsr_tab_code
            and t01.tsv_fld_code = rcd_rule.tsr_fld_code
          order by t01.tsv_val_code asc;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the work selection temporary tables
      /*-*/
      delete from pts_wor_sel_group;
      delete from pts_wor_sel_rule;
      delete from pts_wor_sel_value;
      tbl_sel_group.delete;
      tbl_sel_rule.delete;
      tbl_sel_value.delete;

      /*-*/
      /* Process the selection groups
      /*-*/
      var_tsg_mem_count := 0;
      var_tsg_res_count := 0;
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;

         /*-*/
         /* Create the work selection group
         /*-*/
         insert into pts_wor_sel_group
            values(rcd_group.tsg_sel_group);

         /*-*/
         /* Load the group array
         /*-*/
         tbl_sel_group(tbl_sel_group.count+1).sel_group := rcd_group.tsg_sel_group;
         tbl_sel_group(tbl_sel_group.count).str_rule := 0;
         tbl_sel_group(tbl_sel_group.count).end_rule := 0;
         tbl_sel_group(tbl_sel_group.count).req_mem_count := round(par_req_mem_count * nvl(rcd_group.tsg_sel_pcnt,0), 0);
         tbl_sel_group(tbl_sel_group.count).req_res_count := round(par_req_res_count * nvl(rcd_group.tsg_sel_pcnt,0), 0);
         tbl_sel_group(tbl_sel_group.count).sel_mem_count := 0;
         tbl_sel_group(tbl_sel_group.count).sel_res_count := 0;
         var_tsg_mem_count := var_tsg_mem_count + tbl_sel_group(tbl_sel_group.count).req_mem_count;
         var_tsg_res_count := var_tsg_res_count + tbl_sel_group(tbl_sel_group.count).req_res_count;

      end loop;
      close csr_group;

      /*-*/
      /* Complete the group processing when required
      /*-*/
      if tbl_sel_group.count != 0 then

         /*-*/
         /* Adjust the group counts when required
         /* **note** 1. the last group contains any rounding
         /*-*/
         if var_tsg_mem_count != par_req_mem_count then
            tbl_sel_group(tbl_sel_group.count).req_mem_count := tbl_sel_group(tbl_sel_group.count).req_mem_count + (par_req_mem_count - var_tsg_mem_count);
         end if;
         if var_tsg_res_count != par_req_res_count then
            tbl_sel_group(tbl_sel_group.count).req_res_count := tbl_sel_group(tbl_sel_group.count).req_res_count + (par_req_res_count - var_tsg_res_count);
         end if;

         /*-*/
         /* Reset the test group panel member and reserve counts
         /*-*/
         for idg in 1..tbl_sel_group.count loop
            update pts_tes_sel_group
               set tsg_req_mem_count = tbl_sel_group(idg).req_mem_count,
                   tsg_req_res_count = tbl_sel_group(idg).req_res_count,
                   tsg_sel_mem_count = 0,
                   tsg_sel_res_count = 0
             where tsg_tes_code = par_tes_code
               and tsg_sel_group = tbl_sel_group(idg).sel_group;
         end loop;

      end if;

      /*-*/
      /* Process the selection group rules
      /*-*/
      for idg in 1..tbl_sel_group.count loop

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_sel_group := tbl_sel_group(idg).sel_group;
         open csr_rule;
         loop
            fetch csr_rule into rcd_rule;
            if csr_rule%notfound then
               exit;
            end if;

            /*-*/
            /* Create the work selection rule
            /*-*/
            insert into pts_wor_sel_rule
               values(rcd_rule.tsr_sel_group,
                      rcd_rule.tsr_tab_code,
                      rcd_rule.tsr_fld_code,
                      rcd_rule.tsr_rul_code);

            /*-*/
            /* Load the rule array
            /*-*/
            tbl_sel_rule(tbl_sel_rule.count+1).sel_group := rcd_rule.tsr_sel_group;
            tbl_sel_rule(tbl_sel_rule.count).tab_code := rcd_rule.tsr_tab_code;
            tbl_sel_rule(tbl_sel_rule.count).fld_code := rcd_rule.tsr_fld_code;
            tbl_sel_rule(tbl_sel_rule.count).rul_code := rcd_rule.tsr_rul_code;
            tbl_sel_rule(tbl_sel_rule.count).str_value := 0;
            tbl_sel_rule(tbl_sel_rule.count).end_value := 0;
            tbl_sel_rule(tbl_sel_rule.count).sel_count := 0;
            if tbl_sel_group(idg).str_rule = 0 then
               tbl_sel_group(idg).str_rule := tbl_sel_rule.count;
            end if;
            tbl_sel_group(idg).end_rule := tbl_sel_rule.count;

            /*-*/
            /* Process the selection group rule values
            /*-*/
            var_tsv_mem_count := 0;
            var_tsv_res_count := 0;
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;

               /*-*/
               /* Create the work selection value
               /*-*/
               insert into pts_wor_sel_value
                  values(rcd_value.tsv_sel_group,
                         rcd_value.tsv_tab_code,
                         rcd_value.tsv_fld_code,
                         rcd_value.tsv_val_code,
                         rcd_value.tsv_val_text);

               /*-*/
               /* Load the value array
               /*-*/
               tbl_sel_value(tbl_sel_value.count+1).sel_group := rcd_value.tsv_sel_group;
               tbl_sel_value(tbl_sel_value.count).tab_code := rcd_value.tsv_tab_code;
               tbl_sel_value(tbl_sel_value.count).fld_code := rcd_value.tsv_fld_code;
               tbl_sel_value(tbl_sel_value.count).val_code := rcd_value.tsv_val_code;
               tbl_sel_value(tbl_sel_value.count).val_text := rcd_value.tsv_val_text;
               tbl_sel_value(tbl_sel_value.count).val_pcnt := rcd_value.tsv_val_pcnt;
               tbl_sel_value(tbl_sel_value.count).req_mem_count := 0;
               tbl_sel_value(tbl_sel_value.count).req_res_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_mem_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_res_count := 0;
               tbl_sel_value(tbl_sel_value.count).sel_count := 0;
               tbl_sel_value(tbl_sel_value.count).fld_count := 0;
               if tbl_sel_rule(tbl_sel_rule.count).rul_code = '*SELECT_WHEN_EQ_MIX' then
                  tbl_sel_value(tbl_sel_value.count).req_mem_count := round(tbl_sel_group(idg).req_mem_count * nvl(rcd_value.tsv_val_pcnt,0), 0);
                  tbl_sel_value(tbl_sel_value.count).req_res_count := round(tbl_sel_group(idg).req_res_count * nvl(rcd_value.tsv_val_pcnt,0), 0);
                  var_tsv_mem_count := var_tsv_mem_count + tbl_sel_value(tbl_sel_value.count).req_mem_count;
                  var_tsv_res_count := var_tsv_res_count + tbl_sel_value(tbl_sel_value.count).req_res_count;
               end if;
               if tbl_sel_rule(tbl_sel_rule.count).str_value = 0 then
                  tbl_sel_rule(tbl_sel_rule.count).str_value := tbl_sel_value.count;
               end if;
               tbl_sel_rule(tbl_sel_rule.count).end_value := tbl_sel_value.count;

            end loop;
            close csr_value;

            /*-*/
            /* Complete the test group rule processing when required
            /*-*/
            if tbl_sel_rule(tbl_sel_rule.count).str_value != 0 then

               /*-*/
               /* Adjust the value counts when required
               /* **note** 1. the last value contains any rounding
               /*-*/
               if tbl_sel_rule(tbl_sel_rule.count).rul_code = '*SELECT_WHEN_EQ_MIX' then
                  if var_tsv_mem_count != tbl_sel_group(idg).req_mem_count then
                     tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_mem_count := tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_mem_count + (tbl_sel_group(idg).req_mem_count - var_tsv_mem_count);
                  end if;
                  if var_tsv_res_count != tbl_sel_group(idg).req_res_count then
                     tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_res_count := tbl_sel_value(tbl_sel_rule(tbl_sel_rule.count).end_value).req_res_count + (tbl_sel_group(idg).req_res_count - var_tsv_res_count);
                  end if;
               end if;

               /*-*/
               /* Reset the test group rule value panel member and reserve counts
               /*-*/
               for idv in tbl_sel_rule(tbl_sel_rule.count).str_value..tbl_sel_rule(tbl_sel_rule.count).end_value loop
                  update pts_tes_sel_value
                     set tsv_req_mem_count = tbl_sel_value(idv).req_mem_count,
                         tsv_req_res_count = tbl_sel_value(idv).req_res_count,
                         tsv_sel_mem_count = 0,
                         tsv_sel_res_count = 0
                   where tsv_tes_code = par_tes_code
                     and tsv_sel_group = tbl_sel_value(idv).sel_group
                     and tsv_tab_code = tbl_sel_value(idv).tab_code
                     and tsv_fld_code = tbl_sel_value(idv).fld_code
                     and tsv_val_code = tbl_sel_value(idv).val_code;
               end loop;

            end if;

         end loop;
         close csr_rule;

      end loop;

      /*-*/
      /* Delete the existing test panel data
      /*-*/
      delete from pts_tes_sel_panel
       where tsp_tes_code = par_tes_code;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'CLEAR_PANEL - ' || substr(SQLERRM, 1, 3048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_panel;

   /********************************************************/
   /* This procedure performs the select pet panel routine */
   /********************************************************/
   procedure select_pet_panel(par_tes_code in number, par_pan_type in varchar2, par_pet_multiple in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_tes_sel_panel pts_tes_sel_panel%rowtype;
      var_sel_group varchar2(32);
      var_set_tot_count number;
      var_set_sel_count number;
      var_pan_selected boolean;
      var_available boolean;
      type rcd_sel_data is record(tab_code varchar2(32 char),
                                  fld_code number,
                                  val_code number);
      type typ_sel_data is table of rcd_sel_data index by binary_integer;
      tbl_sel_data typ_sel_data;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_panel is 
         select t01.pde_pet_code,
                t01.pde_hou_code,
                t01.pde_pet_type,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_hou_pet_type where hpt_hou_code=t01.pde_hou_code) as pde_hou_status,
                (select case when count(*)=0 then 0 when count(*)=1 then 1 else 2 end from pts_hou_pet_type where hpt_hou_code=t01.pde_hou_code and hpt_pet_type=t01.pde_pet_type) as pde_hou_count,
                t02.hde_geo_zone
           from pts_pet_definition t01,
                pts_hou_definition t02,
                table(pts_app.pts_gen_function.get_list_data('*PET',var_sel_group)) t03
          where t01.pde_hou_code = t02.hde_hou_code
            and t01.pde_pet_code = t03.sel_code
            and t01.pde_pet_status = 1
            and t01.pde_pet_code not in (select nvl(tsp_pet_code,-1)
                                           from pts_tes_sel_panel
                                          where tsp_tes_code = par_tes_code)
          order by dbms_random.value;
      rcd_panel csr_panel%rowtype;

      cursor csr_classification is
         select t01.*
           from (select t01.hcl_tab_code as tab_code,
                        t01.hcl_fld_code as fld_code,
                        t01.hcl_val_code as val_code
                   from pts_hou_classification t01,
                        pts_sys_field t02
                  where t01.hcl_tab_code = t02.sfi_tab_code
                    and t01.hcl_fld_code = t02.sfi_fld_code
                    and t01.hcl_hou_code = rcd_panel.pde_hou_code
                    and t02.sfi_fld_rul_type = '*LIST'
                 union all
                 select t01.pcl_tab_code as tab_code,
                        t01.pcl_fld_code as fld_code,
                        t01.pcl_val_code as val_code
                   from pts_pet_classification t01,
                        pts_sys_field t02
                  where t01.pcl_tab_code = t02.sfi_tab_code
                    and t01.pcl_fld_code = t02.sfi_fld_code
                    and t01.pcl_pet_code = rcd_panel.pde_pet_code
                    and t02.sfi_fld_rul_type = '*LIST') t01
          order by t01.tab_code asc,
                   t01.fld_code asc,
                   t01.val_code asc;
      rcd_classification csr_classification%rowtype;

      cursor csr_pet_update is 
         select t01.*
           from pts_pet_definition t01
          where t01.pde_pet_code = rcd_panel.pde_pet_code
                for update wait 10;
      rcd_pet_update csr_pet_update%rowtype;

      cursor csr_panel_check is 
         select tsp_pet_code
           from pts_tes_sel_panel t01
          where t01.tsp_tes_code = par_tes_code
            and t01.tsp_hou_code = rcd_panel.pde_hou_code;
      rcd_panel_check csr_panel_check%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the test selection groups for panel inclusion
      /* **note** 1. Groups are logically ORed and mutually exclusive
      /*          2. The first group to satisfy all group rules will be selected
      /*          3. Percentage mix rules are satisfied matched selected counts
      /*-*/
      for idg in 1..tbl_sel_group.count loop

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_sel_group := tbl_sel_group(idg).sel_group;

         /*-*/
         /* Retrieve the panel for potential candidates
         /*-*/
         open csr_panel;
         loop
            fetch csr_panel into rcd_panel;
            if csr_panel%notfound then
               exit;
            end if;

            /*-*/
            /* Clear the selection data
            /*-*/
            tbl_sel_data.delete;

            /*-*/
            /* Load the definition data
            /*-*/
            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEFINITION';
            tbl_sel_data(tbl_sel_data.count).fld_code := 2;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_pet_type;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEFINITION';
            tbl_sel_data(tbl_sel_data.count).fld_code := 9;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_hou_status;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*PET_DEFINITION';
            tbl_sel_data(tbl_sel_data.count).fld_code := 10;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.pde_hou_count;

            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*HOU_DEFINITION';
            tbl_sel_data(tbl_sel_data.count).fld_code := 2;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.hde_geo_zone;

            /*-*/
            /* Retrieve and load the classification data (*LIST only)
            /*-*/
            open csr_classification;
            loop
               fetch csr_classification into rcd_classification;
               if csr_classification%notfound then
                  exit;
               end if;
               tbl_sel_data(tbl_sel_data.count+1).tab_code := rcd_classification.tab_code;
               tbl_sel_data(tbl_sel_data.count).fld_code := rcd_classification.fld_code;
               tbl_sel_data(tbl_sel_data.count).val_code := rcd_classification.val_code;
            end loop;
            close csr_classification;

            /*-*/
            /* Process the selection group rules
            /* **note** 1. Rules are logically ANDed
            /*          2. Non percentage mix rules are satisfied in the SQL
            /*          3. Percentage mix rules are satisfied by matched selected counts
            /*-*/
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               tbl_sel_rule(idr).sel_count := 0;
               if tbl_sel_rule(idr).rul_code != '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_rule(idr).sel_count := 1;
               else
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     tbl_sel_value(idv).sel_count := 0;
                     tbl_sel_value(idv).fld_count := 0;
                     for idc in 1..tbl_sel_data.count loop
                        if (tbl_sel_data(idc).tab_code = tbl_sel_value(idv).tab_code and
                            tbl_sel_data(idc).fld_code = tbl_sel_value(idv).fld_code and
                            tbl_sel_data(idc).val_code = tbl_sel_value(idv).val_code) then
                           tbl_sel_value(idv).fld_count := 1;
                           exit;
                        end if;
                     end loop;
                  end loop;
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     if upper(par_pan_type) = '*MEMBER' then
                        if tbl_sel_value(idv).req_mem_count > tbl_sel_value(idv).sel_mem_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     else
                        if tbl_sel_value(idv).req_res_count > tbl_sel_value(idv).sel_res_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     end if;
                  end loop;
               end if;
            end loop;

            /*-*/
            /* Reset the panel selection indicator
            /*-*/
            var_pan_selected := false;

            /*-*/
            /* Evaluate the group selection
            /* **note** 1. Compare the rule total count to the rule selected count
            /*          2. All rules must be satisfied (logically ANDed)
            /*-*/
            var_set_tot_count := 0;
            var_set_sel_count := 0;
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               var_set_tot_count := var_set_tot_count + 1;
               if tbl_sel_rule(idr).sel_count = 1 then
                  var_set_sel_count := var_set_sel_count + 1;
               end if;
            end loop;

            /*-*/
            /* Panel satisfies the group selection
            /*-*/
            if var_set_sel_count = var_set_tot_count then

               /*-*/
               /* Set the panel to selected
               /*-*/
               var_pan_selected := true;

               /*-*/
               /* Check for multiple panel pets when required 
               /*-*/
               if par_pet_multiple = '0' then
                  open csr_panel_check;
                  fetch csr_panel_check into rcd_panel_check;
                  if csr_panel_check%found then
                     var_pan_selected := false;
                  end if;
                  close csr_panel_check;
               end if;

               /*-*/
               /* Attempt to lock the pet definition for update
               /* **notes** 1. Must exist
               /*           2. Must be status available
               /*           3. must not be locked
               /*-*/
               if var_pan_selected = true then
                  var_available := true;
                  begin
                     open csr_pet_update;
                     fetch csr_pet_update into rcd_pet_update;
                     if csr_pet_update%notfound then
                        var_available := false;
                     else
                        if rcd_pet_update.pde_pet_status != 1 then
                           var_available := false;
                        end if;
                     end if;
                  exception
                     when others then
                        var_available := false;
                  end;
                  if csr_pet_update%isopen then
                     close csr_pet_update;
                  end if;
                  if var_available = false then
                     var_pan_selected := false;
                  end if;
               end if;

            end if;

            /*-*/
            /* Process selected panel
            /*-*/
            if var_pan_selected = true then

               /*-*/
               /* Update the internal selection counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  tbl_sel_group(idg).sel_mem_count := tbl_sel_group(idg).sel_mem_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_mem_count := tbl_sel_value(idv).sel_mem_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  tbl_sel_group(idg).sel_res_count := tbl_sel_group(idg).sel_res_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_res_count := tbl_sel_value(idv).sel_res_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Insert the new panel member
               /*-*/
               rcd_pts_tes_sel_panel.tsp_tes_code := par_tes_code;
               rcd_pts_tes_sel_panel.tsp_sel_group := tbl_sel_group(idg).sel_group;
               rcd_pts_tes_sel_panel.tsp_hou_code := rcd_panel.pde_hou_code;
               rcd_pts_tes_sel_panel.tsp_pet_code := rcd_panel.pde_pet_code;
               rcd_pts_tes_sel_panel.tsp_status := upper(par_pan_type);
               insert into pts_tes_sel_panel values rcd_pts_tes_sel_panel;

               /*-*/
               /* Update the pet status
               /*-*/
               update pts_pet_definition
                  set pde_pet_status = 2
                where pde_pet_code = rcd_panel.pde_pet_code;

               /*-*/
               /* Update the test counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  update pts_tes_sel_group
                     set tsg_sel_mem_count = tsg_sel_mem_count + 1
                   where tsg_tes_code = par_tes_code
                     and tsg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_sel_value
                                 set tsv_sel_mem_count = tsv_sel_mem_count + 1
                               where tsv_tes_code = par_tes_code
                                 and tsv_sel_group = tbl_sel_value(idv).sel_group
                                 and tsv_tab_code = tbl_sel_value(idv).tab_code
                                 and tsv_fld_code = tbl_sel_value(idv).fld_code
                                 and tsv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  update pts_tes_sel_group
                     set tsg_sel_res_count = tsg_sel_res_count + 1
                   where tsg_tes_code = par_tes_code
                     and tsg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_sel_value
                                 set tsv_sel_res_count = tsv_sel_res_count + 1
                               where tsv_tes_code = par_tes_code
                                 and tsv_sel_group = tbl_sel_value(idv).sel_group
                                 and tsv_tab_code = tbl_sel_value(idv).tab_code
                                 and tsv_fld_code = tbl_sel_value(idv).fld_code
                                 and tsv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Commit the database
               /*-*/
               commit;

            else

               /*-*/
               /* Rollback the database to release update lock
               /*-*/
               rollback;

            end if;

            /*-*/
            /* Exit the panel loop when group panel requirements satisfied
            /*-*/
            if upper(par_pan_type) = '*MEMBER' then
               if tbl_sel_group(idg).sel_mem_count >= tbl_sel_group(idg).req_mem_count then
                  exit;
               end if;
            else
               if tbl_sel_group(idg).sel_res_count >= tbl_sel_group(idg).req_res_count then
                  exit;
               end if;
            end if;

         end loop;
         close csr_panel;

      end loop;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'SELECT_PET_PANEL - ' || substr(SQLERRM, 1, 3048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_pet_panel;

   /**************************************************************/
   /* This procedure performs the select household panel routine */
   /**************************************************************/
   procedure select_hou_panel(par_tes_code in number, par_pan_type in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      rcd_pts_tes_sel_panel pts_tes_sel_panel%rowtype;
      var_sel_group varchar2(32);
      var_set_tot_count number;
      var_set_sel_count number;
      var_pan_selected boolean;
      var_available boolean;
      type rcd_sel_data is record(tab_code varchar2(32 char),
                                  fld_code number,
                                  val_code number);
      type typ_sel_data is table of rcd_sel_data index by binary_integer;
      tbl_sel_data typ_sel_data;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_panel is 
         select t01.hde_hou_code,
                t01.hde_geo_zone
           from pts_hou_definition t01,
                table(pts_app.pts_gen_function.get_list_data('*HOUSEHOLD',var_sel_group)) t02
          where t01.hde_hou_code = t02.sel_code
            and t01.hde_hou_status = 1
            and t01.hde_hou_code not in (select nvl(tsp_hou_code,-1)
                                           from pts_tes_sel_panel
                                          where tsp_tes_code = par_tes_code)
          order by dbms_random.value;
      rcd_panel csr_panel%rowtype;

      cursor csr_classification is
         select t01.*
           from (select t01.hcl_tab_code as tab_code,
                        t01.hcl_fld_code as fld_code,
                        t01.hcl_val_code as val_code
                   from pts_hou_classification t01,
                        pts_sys_field t02
                  where t01.hcl_tab_code = t02.sfi_tab_code
                    and t01.hcl_fld_code = t02.sfi_fld_code
                    and t01.hcl_hou_code = rcd_panel.hde_hou_code
                    and t02.sfi_fld_rul_type = '*LIST') t01
          order by t01.tab_code asc,
                   t01.fld_code asc,
                   t01.val_code asc;
      rcd_classification csr_classification%rowtype;

      cursor csr_hou_update is 
         select t01.*
           from pts_hou_definition t01
          where t01.hde_hou_code = rcd_panel.hde_hou_code
                for update wait 10;
      rcd_hou_update csr_hou_update%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the test selection groups for panel inclusion
      /* **note** 1. Groups are logically ORed and mutually exclusive
      /*          2. The first group to satisfy all group rules will be selected
      /*          3. Percentage mix rules are satisfied matched selected counts
      /*-*/
      for idg in 1..tbl_sel_group.count loop

         /*-*/
         /* Process the selection group rules
         /*-*/
         var_sel_group := tbl_sel_group(idg).sel_group;

         /*-*/
         /* Retrieve the panel for potential candidates
         /*-*/
         open csr_panel;
         loop
            fetch csr_panel into rcd_panel;
            if csr_panel%notfound then
               exit;
            end if;

            /*-*/
            /* Clear the selection data
            /*-*/
            tbl_sel_data.delete;

            /*-*/
            /* Load the definition data
            /*-*/
            tbl_sel_data(tbl_sel_data.count+1).tab_code := '*HOU_DEFINITION';
            tbl_sel_data(tbl_sel_data.count).fld_code := 2;
            tbl_sel_data(tbl_sel_data.count).val_code := rcd_panel.hde_geo_zone;

            /*-*/
            /* Retrieve and load the classification data (*LIST only)
            /*-*/
            open csr_classification;
            loop
               fetch csr_classification into rcd_classification;
               if csr_classification%notfound then
                  exit;
               end if;
               tbl_sel_data(tbl_sel_data.count+1).tab_code := rcd_classification.tab_code;
               tbl_sel_data(tbl_sel_data.count).fld_code := rcd_classification.fld_code;
               tbl_sel_data(tbl_sel_data.count).val_code := rcd_classification.val_code;
            end loop;
            close csr_classification;

            /*-*/
            /* Process the selection group rules
            /* **note** 1. Rules are logically ANDed
            /*          2. Non percentage mix rules are satisfied in the SQL
            /*          3. Percentage mix rules are satisfied by matched selected counts
            /*-*/
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               tbl_sel_rule(idr).sel_count := 0;
               if tbl_sel_rule(idr).rul_code != '*SELECT_WHEN_EQUAL_MIX' then
                  tbl_sel_rule(idr).sel_count := 1;
               else
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     tbl_sel_value(idv).sel_count := 0;
                     tbl_sel_value(idv).fld_count := 0;
                     for idc in 1..tbl_sel_data.count loop
                        if (tbl_sel_data(idc).tab_code = tbl_sel_value(idv).tab_code and
                            tbl_sel_data(idc).fld_code = tbl_sel_value(idv).fld_code and
                            tbl_sel_data(idc).val_code = tbl_sel_value(idv).val_code) then
                           tbl_sel_value(idv).fld_count := 1;
                           exit;
                        end if;
                     end loop;
                  end loop;
                  for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                     if upper(par_pan_type) = '*MEMBER' then
                        if tbl_sel_value(idv).req_mem_count > tbl_sel_value(idv).sel_mem_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     else
                        if tbl_sel_value(idv).req_res_count > tbl_sel_value(idv).sel_res_count then
                           if tbl_sel_value(idv).fld_count = 1 then
                              tbl_sel_value(idv).sel_count := 1;
                              tbl_sel_rule(idr).sel_count := 1;
                              exit;
                           end if;
                        end if;
                     end if;
                  end loop;
               end if;
            end loop;

            /*-*/
            /* Reset the panel selection indicator
            /*-*/
            var_pan_selected := false;

            /*-*/
            /* Evaluate the group selection
            /* **note** 1. Compare the rule total count to the rule selected count
            /*          2. All rules must be satisfied (logically ANDed)
            /*-*/
            var_set_tot_count := 0;
            var_set_sel_count := 0;
            for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
               var_set_tot_count := var_set_tot_count + 1;
               if tbl_sel_rule(idr).sel_count = 1 then
                  var_set_sel_count := var_set_sel_count + 1;
               end if;
            end loop;

            /*-*/
            /* Panel satisfies the group selection
            /*-*/
            if var_set_sel_count = var_set_tot_count then

               /*-*/
               /* Set the panel to selected
               /*-*/
               var_pan_selected := true;

               /*-*/
               /* Attempt to lock the household definition for update
               /* **notes** 1. Must exist
               /*           2. Must be status available
               /*           3. must not be locked
               /*-*/
               if var_pan_selected = true then
                  var_available := true;
                  begin
                     open csr_hou_update;
                     fetch csr_hou_update into rcd_hou_update;
                     if csr_hou_update%notfound then
                        var_available := false;
                     else
                        if rcd_hou_update.hde_hou_status != 1 then
                           var_available := false;
                        end if;
                     end if;
                  exception
                     when others then
                        var_available := false;
                  end;
                  if csr_hou_update%isopen then
                     close csr_hou_update;
                  end if;
                  if var_available = false then
                     var_pan_selected := false;
                  end if;
               end if;

            end if;

            /*-*/
            /* Process selected panel
            /*-*/
            if var_pan_selected = true then

               /*-*/
               /* Update the internal selection counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  tbl_sel_group(idg).sel_mem_count := tbl_sel_group(idg).sel_mem_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_mem_count := tbl_sel_value(idv).sel_mem_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  tbl_sel_group(idg).sel_res_count := tbl_sel_group(idg).sel_res_count + 1;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              tbl_sel_value(idv).sel_res_count := tbl_sel_value(idv).sel_res_count + 1;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Insert the new panel member
               /*-*/
               rcd_pts_tes_sel_panel.tsp_tes_code := par_tes_code;
               rcd_pts_tes_sel_panel.tsp_sel_group := tbl_sel_group(idg).sel_group;
               rcd_pts_tes_sel_panel.tsp_hou_code := rcd_panel.hde_hou_code;
               rcd_pts_tes_sel_panel.tsp_pet_code := null;
               rcd_pts_tes_sel_panel.tsp_status := upper(par_pan_type);
               insert into pts_tes_sel_panel values rcd_pts_tes_sel_panel;

               /*-*/
               /* Update the household status
               /*-*/
               update pts_hou_definition
                  set hde_hou_status = 2
                where hde_hou_code = rcd_panel.hde_hou_code;

               /*-*/
               /* Update the test counts
               /*-*/
               if upper(par_pan_type) = '*MEMBER' then
                  update pts_tes_sel_group
                     set tsg_sel_mem_count = tsg_sel_mem_count + 1
                   where tsg_tes_code = par_tes_code
                     and tsg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_sel_value
                                 set tsv_sel_mem_count = tsv_sel_mem_count + 1
                               where tsv_tes_code = par_tes_code
                                 and tsv_sel_group = tbl_sel_value(idv).sel_group
                                 and tsv_tab_code = tbl_sel_value(idv).tab_code
                                 and tsv_fld_code = tbl_sel_value(idv).fld_code
                                 and tsv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               else
                  update pts_tes_sel_group
                     set tsg_sel_res_count = tsg_sel_res_count + 1
                   where tsg_tes_code = par_tes_code
                     and tsg_sel_group = tbl_sel_group(idg).sel_group;
                  for idr in tbl_sel_group(idg).str_rule..tbl_sel_group(idg).end_rule loop
                     if tbl_sel_rule(idr).rul_code = '*SELECT_WHEN_EQUAL_MIX' then
                        for idv in tbl_sel_rule(idr).str_value..tbl_sel_rule(idr).end_value loop
                           if tbl_sel_value(idv).sel_count = 1 then
                              update pts_tes_sel_value
                                 set tsv_sel_res_count = tsv_sel_res_count + 1
                               where tsv_tes_code = par_tes_code
                                 and tsv_sel_group = tbl_sel_value(idv).sel_group
                                 and tsv_tab_code = tbl_sel_value(idv).tab_code
                                 and tsv_fld_code = tbl_sel_value(idv).fld_code
                                 and tsv_val_code = tbl_sel_value(idv).val_code;
                           end if;
                        end loop;
                     end if;
                  end loop;
               end if;

               /*-*/
               /* Commit the database
               /*-*/
               commit;

            else

               /*-*/
               /* Rollback the database to release update lock
               /*-*/
               rollback;

            end if;

            /*-*/
            /* Exit the panel loop when group panel requirements satisfied
            /*-*/
            if upper(par_pan_type) = '*MEMBER' then
               if tbl_sel_group(idg).sel_mem_count >= tbl_sel_group(idg).req_mem_count then
                  exit;
               end if;
            else
               if tbl_sel_group(idg).sel_res_count >= tbl_sel_group(idg).req_res_count then
                  exit;
               end if;
            end if;

         end loop;
         close csr_panel;

      end loop;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'SELECT_HOU_PANEL - ' || substr(SQLERRM, 1, 3048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_hou_panel;

end pts_tes_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_tes_function for pts_app.pts_tes_function;
grant execute on pts_app.pts_tes_function to public;
