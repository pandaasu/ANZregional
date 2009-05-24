/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_pty_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_pty_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet Type Function

    This package contain the pet type functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);

end pts_pty_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body pts_app.pts_pty_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************/
   /* This procedure performs the retrieve list routine */
   /*****************************************************/
   function retrieve_list return pts_xml_type pipelined is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.pty_pet_type,
                t01.pty_typ_text,
                decode(t01.pty_typ_status,1,'Active',2,'Inactive','*UNKNOWN') as pty_typ_status
           from pts_pet_type t01
          order by t01.pty_pet_type asc;
      rcd_list csr_list%rowtype;

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
      /* Retrieve the pet type list and pipe the results
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.pty_pet_type)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.pty_pet_type)||') '||rcd_list.pty_typ_text)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.pty_pet_type)||') '||rcd_list.pty_typ_text)||'" COL2="'||pts_to_xml(rcd_list.pty_typ_status)||'"/>'));
      end loop;
      close csr_list;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PTY_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_pty_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_pet_type t01
          where t01.pty_pet_type = pts_to_number(var_pty_code);
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
      var_pty_code := xslProcessor.valueOf(obj_pts_request,'@PTYCODE');
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDPTY' and var_action != '*CRTPTY' and var_action != '*CPYPTY' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the existing pet type when required
      /*-*/
      if var_action = '*UPDPTY' or var_action = '*CPYPTY' then
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%notfound then
            pts_gen_function.add_mesg_data('Pet type ('||var_pty_code||') does not exist');
            return;
         end if;
         close csr_retrieve;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the status XML
      /*-*/
      pipe row(pts_xml_object('<STA_LIST VALCDE="1" VALTXT="Active"/>'));
      pipe row(pts_xml_object('<STA_LIST VALCDE="2" VALTXT="Inactive"/>'));

      /*-*/
      /* Pipe the pet type XML
      /*-*/
      if var_action = '*UPDPTY' then
         var_output := '<PET_TYPE PTYCODE="'||to_char(rcd_retrieve.pty_pet_type)||'"';
         var_output := var_output||' PTYTEXT="'||pts_to_xml(rcd_retrieve.pty_typ_text)||'"';
         var_output := var_output||' PTYSTAT="'||to_char(rcd_retrieve.pty_typ_status)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CPYPTY' then
         var_output := '<PET_TYPE PTYCODE="*NEW"';
         var_output := var_output||' PTYTEXT="'||pts_to_xml(rcd_retrieve.pty_typ_text)||'"';
         var_output := var_output||' PTYSTAT="'||to_char(rcd_retrieve.pty_typ_status)||'"/>';
         pipe row(pts_xml_object(var_output));
      elsif var_action = '*CRTPTY' then
         var_output := '<PET_TYPE PTYCODE="*NEW"';
         var_output := var_output||' PTYTEXT=""';
         var_output := var_output||' PTYSTAT="1"/>';
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PTY_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_data;

   /***************************************************/
   /* This procedure performs the update data routine */
   /***************************************************/
   procedure update_data(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      rcd_pts_pet_type pts_pet_type%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from pts_pet_type t01
          where t01.pty_pet_type = rcd_pts_pet_type.pty_pet_type;
      rcd_check csr_check%rowtype;

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
      if var_action != '*DEFPTY' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_pet_type.pty_pet_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PTYCODE'));
      rcd_pts_pet_type.pty_typ_text := pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@PTYTEXT'));
      rcd_pts_pet_type.pty_typ_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PTYSTAT'));
      rcd_pts_pet_type.pty_upd_user := upper(par_user);
      rcd_pts_pet_type.pty_upd_date := sysdate;
      if rcd_pts_pet_type.pty_pet_type is null and not(xslProcessor.valueOf(obj_pts_request,'@PTYCODE') = '*NEW') then
         pts_gen_function.add_mesg_data('Pet type code ('||xslProcessor.valueOf(obj_pts_request,'@PTYCODE')||') must be a number');
      end if;
      if rcd_pts_pet_type.pty_typ_status is null and not(xslProcessor.valueOf(obj_pts_request,'@PTYSTAT') is null) then
         pts_gen_function.add_mesg_data('Pet type status ('||xslProcessor.valueOf(obj_pts_request,'@PTYSTAT')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_pet_type.pty_typ_text is null then
         pts_gen_function.add_mesg_data('Pet type description must be supplied');
      end if;
      if rcd_pts_pet_type.pty_typ_status is null then
         pts_gen_function.add_mesg_data('Pet type status must be supplied');
      else
         if (rcd_pts_pet_type.pty_typ_status != 1 and rcd_pts_pet_type.pty_typ_status != 2) then
            pts_gen_function.add_mesg_data('Pet type status must be 1(Active) or 2(Inactive)');
        end if;
      end if;
      if rcd_pts_pet_type.pty_upd_user is null then
         pts_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
     
      /*-*/
      /* Retrieve and process the pet type definition
      /*-*/
      open csr_check;
      fetch csr_check into rcd_check;
      if csr_check%found then
         var_confirm := 'updated';
         update pts_pet_type
            set pty_typ_text = rcd_pts_pet_type.pty_typ_text,
                pty_typ_status = rcd_pts_pet_type.pty_typ_status
          where pty_pet_type = rcd_pts_pet_type.pty_pet_type;
      else
         var_confirm := 'created';
         select pts_pty_sequence.nextval into rcd_pts_pet_type.pty_pet_type from dual;
         insert into pts_pet_type values rcd_pts_pet_type;
      end if;
      close csr_check;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Send the confirm message
      /*-*/
      pts_gen_function.set_cfrm_data('Pet type ('||to_char(rcd_pts_pet_type.pty_pet_type)||') successfully '||var_confirm);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_PTY_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

end pts_pty_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_pty_function for pts_app.pts_pty_function;
grant execute on pts_app.pts_pty_function to public;
