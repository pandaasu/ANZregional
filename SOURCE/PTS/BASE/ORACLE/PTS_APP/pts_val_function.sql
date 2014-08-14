/******************/
/* Package Header */
/******************/
create or replace
package         pts_val_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_val_function
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Pet Validation Function

    This package contain the procedures and functions for product test.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/11   Peter Tylee    Created. Based upon PTS_TES_FUNCTION

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function retrieve_list return pts_xml_type pipelined;
   function retrieve_data return pts_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   function retrieve_preview return pts_xml_type pipelined;
   function retrieve_test return pts_xml_type pipelined;
   function select_test return pts_xml_type pipelined;
   procedure update_test(par_user in varchar2);
   function retrieve_pet return pts_xml_type pipelined;
   function select_pet return pts_xml_type pipelined;
   procedure update_pet(par_user in varchar2);
   function retrieve_allocation return pts_xml_type pipelined;
   procedure update_allocation(par_user in varchar2);
   function report_allocation(par_val_code in number, par_val_type in number, par_val_date in varchar2) return pts_xls_type pipelined;
   function report_questionnaire(par_val_code in number, par_val_type in number, par_val_date in varchar2) return pts_xls_type pipelined;
   function report_selection(par_val_code in number, par_val_type in number, par_val_date in varchar2) return pts_xls_type pipelined;
   function report_results(par_val_code in number) return pts_xls_type pipelined;
   function report_candidates(par_val_date in varchar2) return pts_xls_type pipelined;
   function response_load return pts_xml_type pipelined;
   function response_list return pts_xml_type pipelined;
   function response_retrieve return pts_xml_type pipelined;
   procedure update_response;

end pts_val_function;
/

/****************/
/* Package Body */
/****************/
create or replace
package body         pts_val_function as

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
      /* Local definitions
      /*-*/
      var_pag_size number;
      var_row_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.vde_val_code,
                t01.vde_val_title,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*VAL_DEF' and sva_fld_code = 3 and sva_val_code = t01.vde_val_status),'*UNKNOWN') as vde_val_status
           from pts_val_definition t01
          where t01.vde_val_code in (select sel_code from table(pts_app.pts_gen_function.get_list_data('*VALIDATION',null)))
            and t01.vde_val_code > (select sel_code from table(pts_app.pts_gen_function.get_list_from))
          order by t01.vde_val_code asc;
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
      pipe row(pts_xml_object('<LSTCTL COLCNT="2" HED1="'||pts_to_xml('Validation')||'" HED2="'||pts_to_xml('Status')||'" />'));

      /*-*/
      /* Retrieve the pet list and pipe the results
      /*-*/
      var_pag_size := 20;
      var_row_count := 0;
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_row_count := var_row_count + 1;
         if var_row_count <= var_pag_size then
            pipe row(pts_xml_object('<LSTROW SELCDE="'||to_char(rcd_list.vde_val_code)||'" SELTXT="'||pts_to_xml('('||to_char(rcd_list.vde_val_code)||') '||rcd_list.vde_val_title)||'" COL1="'||pts_to_xml('('||to_char(rcd_list.vde_val_code)||') '||rcd_list.vde_val_title)||'" COL2="'||pts_to_xml(rcd_list.vde_val_status)||'"/>'));
         else
            exit;
         end if;
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RETRIEVE_LIST - ' || substr(SQLERRM, 1, 1536));

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
      var_val_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = var_val_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*VAL_DEF',3)) t01;
      rcd_sta_code csr_sta_code%rowtype;
      
      cursor csr_pet_type is
         select t01.*
           from table(pts_app.pts_gen_function.list_pet_type) t01
          where t01.pty_status = 1;
      rcd_pet_type csr_pet_type%rowtype;

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
      if var_action != '*UPDVAL' and var_action != '*CRTVAL' and var_action != '*CPYVAL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the existing test when required
      /*-*/
      if var_action = '*UPDVAL' or var_action = '*CPYVAL' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
         end if;
         if pts_gen_function.get_mesg_count != 0 then
            return;
         end if;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the status XML
      /*-*/
      open csr_sta_code;
      loop
         fetch csr_sta_code into rcd_sta_code;
         if csr_sta_code%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<STA_LIST VALCDE="'||rcd_sta_code.val_code||'" VALTXT="'||pts_to_xml(rcd_sta_code.val_text)||'"/>'));
      end loop;
      close csr_sta_code;
      
      /*-*/
      /* Pipe the pet type XML
      /*-*/
      pipe row(pts_xml_object('<PET_TYPE VALCDE="" VALTXT="** Select **"/>'));
      open csr_pet_type;
      loop
         fetch csr_pet_type into rcd_pet_type;
         if csr_pet_type%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PET_TYPE VALCDE="'||rcd_pet_type.pty_code||'" VALTXT="'||pts_to_xml(rcd_pet_type.pty_text)||'"/>'));
      end loop;
      close csr_pet_type;

      /*-*/
      /* Pipe the test XML
      /*-*/
      if var_action = '*UPDVAL' then
         pipe row(pts_xml_object('<VAL VALCDE="'||to_char(rcd_retrieve.vde_val_code)||'"'));
         pipe row(pts_xml_object(' VALTIT="'||pts_to_xml(rcd_retrieve.vde_val_title)||'"'));
         pipe row(pts_xml_object(' VALSTA="'||to_char(rcd_retrieve.vde_val_status)||'"'));
         pipe row(pts_xml_object(' COMTXT="'||pts_to_xml(rcd_retrieve.vde_val_comment)||'"'));
         pipe row(pts_xml_object(' STRDAT="'||to_char(rcd_retrieve.vde_val_str_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' FLDWEK="'||to_char(rcd_retrieve.vde_val_fld_week)||'"'));
         pipe row(pts_xml_object(' PETTYP="'||to_char(rcd_retrieve.vde_pet_type)||'"/>'));
      elsif var_action = '*CPYVAL' then
         pipe row(pts_xml_object('<VAL VALCDE="*NEW"'));
         pipe row(pts_xml_object(' VALTIT="'||pts_to_xml(rcd_retrieve.vde_val_title)||'"'));
         pipe row(pts_xml_object(' VALSTA="1"'));
         pipe row(pts_xml_object(' COMTXT="'||pts_to_xml(rcd_retrieve.vde_val_comment)||'"'));
         pipe row(pts_xml_object(' STRDAT="'||to_char(rcd_retrieve.vde_val_str_date,'dd/mm/yyyy')||'"'));
         pipe row(pts_xml_object(' FLDWEK="'||to_char(rcd_retrieve.vde_val_fld_week)||'"'));
         pipe row(pts_xml_object(' PETTYP="'||to_char(rcd_retrieve.vde_pet_type)||'"/>'));
      elsif var_action = '*CRTVAL' then
         pipe row(pts_xml_object('<VAL VALCDE="*NEW"'));
         pipe row(pts_xml_object(' VALTIT=""'));
         pipe row(pts_xml_object(' VALSTA="1"'));
         pipe row(pts_xml_object(' COMTXT=""'));
         pipe row(pts_xml_object(' STRDAT=""'));
         pipe row(pts_xml_object(' FLDWEK=""'));
         pipe row(pts_xml_object(' PETTYP=""/>'));
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      var_locked boolean;
      var_test boolean;
      var_allocation boolean;
      var_cpy_code number;
      rcd_pts_val_definition pts_val_definition%rowtype;
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = rcd_pts_val_definition.vde_val_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_copy is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = var_cpy_code;
      rcd_copy csr_copy%rowtype;

      cursor csr_sta_code is
         select t01.*
           from table(pts_app.pts_gen_function.list_class('*VAL_DEF',3)) t01
          where t01.val_code = rcd_pts_val_definition.vde_val_status;
      rcd_sta_code csr_sta_code%rowtype;
      
      cursor csr_pet_type is
         select t01.*
           from pts_pet_type t01
          where t01.pty_pet_type = rcd_pts_val_definition.vde_pet_type
                and t01.pty_typ_status = 1;
      rcd_pet_type csr_pet_type%rowtype;
      
      cursor csr_test is
         select t01.*
           from pts_val_test t01
          where t01.vte_val_code = rcd_pts_val_definition.vde_val_code;
      rcd_test csr_test%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_val_allocation t01
          where t01.val_val_code = rcd_pts_val_definition.vde_val_code;
      rcd_allocation csr_allocation%rowtype;

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
      if var_action != '*DEFVAL' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_cpy_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@CPYCDE'));
      rcd_pts_val_definition.vde_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      rcd_pts_val_definition.vde_val_title := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@VALTIT')));
      rcd_pts_val_definition.vde_val_status := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALSTA'));
      rcd_pts_val_definition.vde_val_comment := upper(pts_from_xml(xslProcessor.valueOf(obj_pts_request,'@COMTXT')));
      rcd_pts_val_definition.vde_val_str_date := pts_to_date(xslProcessor.valueOf(obj_pts_request,'@STRDAT'),'dd/mm/yyyy');
      rcd_pts_val_definition.vde_val_fld_week := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@FLDWEK'));
      rcd_pts_val_definition.vde_pet_type := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETTYP'));
      if rcd_pts_val_definition.vde_val_code is null and not(xslProcessor.valueOf(obj_pts_request,'@VALCDE') = '*NEW') then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if rcd_pts_val_definition.vde_val_status is null and not(xslProcessor.valueOf(obj_pts_request,'@VALSTA') is null) then
         pts_gen_function.add_mesg_data('Validation status ('||xslProcessor.valueOf(obj_pts_request,'@VALSTA')||') must be a number');
      end if;
      if rcd_pts_val_definition.vde_val_str_date is null and not(xslProcessor.valueOf(obj_pts_request,'@STRDAT') is null) then
         pts_gen_function.add_mesg_data('Validation start date ('||xslProcessor.valueOf(obj_pts_request,'@STRDAT')||') must be a date in format DD/MM/YYYY');
      end if;
      if rcd_pts_val_definition.vde_val_fld_week is null and not(xslProcessor.valueOf(obj_pts_request,'@FLDWEK') is null) then
         pts_gen_function.add_mesg_data('Validation field week ('||xslProcessor.valueOf(obj_pts_request,'@FLDWEK')||') must be a number in format YYYYWW');
      end if;
      if rcd_pts_val_definition.vde_pet_type is null and not(xslProcessor.valueOf(obj_pts_request,'@PETTYP') is null) then
         pts_gen_function.add_mesg_data('Validation pet type week ('||xslProcessor.valueOf(obj_pts_request,'@PETTYP')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing test when required
      /*-*/
      var_locked := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_locked := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') is currently locked');
      end;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve the validation test
      /*-*/
      var_test := false;
      open csr_test;
      fetch csr_test into rcd_test;
      if csr_test%found then
         var_test := true;
      end if;
      close csr_test;

      /*-*/
      /* Retrieve the validation allocation
      /*-*/
      var_allocation := false;
      open csr_allocation;
      fetch csr_allocation into rcd_allocation;
      if csr_allocation%found then
         var_allocation := true;
      end if;
      close csr_allocation;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_pts_val_definition.vde_val_title is null then
         pts_gen_function.add_mesg_data('Validation title must be supplied');
      end if;
      if rcd_pts_val_definition.vde_val_status is null then
         pts_gen_function.add_mesg_data('Validation status must be supplied');
      end if;
      open csr_sta_code;
      fetch csr_sta_code into rcd_sta_code;
      if csr_sta_code%notfound then
         pts_gen_function.add_mesg_data('Validation status ('||to_char(rcd_pts_val_definition.vde_val_status)||') does not exist');
      end if;
      close csr_sta_code;
      open csr_pet_type;
      fetch csr_pet_type into rcd_pet_type;
      if csr_pet_type%notfound then
         pts_gen_function.add_mesg_data('Validation pet type ('||to_char(rcd_pts_val_definition.vde_pet_type)||') does not exist or is inactive');
      end if;
      close csr_pet_type;
      if var_locked = true then
         if rcd_retrieve.vde_val_status = 1 and (rcd_pts_val_definition.vde_val_status != 1 and rcd_pts_val_definition.vde_val_status != 2 and rcd_pts_val_definition.vde_val_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Raised - new status must be Raised, Allocation Completed or Cancelled');
         end if;
         if rcd_retrieve.vde_val_status = 2 and (rcd_pts_val_definition.vde_val_status != 1 and rcd_pts_val_definition.vde_val_status != 2 and rcd_pts_val_definition.vde_val_status != 4 and rcd_pts_val_definition.vde_val_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Allocation Completed - new status must be Raised, Allocation Completed, Closed or Cancelled');
         end if;
         if rcd_retrieve.vde_val_status = 3 and (rcd_pts_val_definition.vde_val_status != 1 and rcd_pts_val_definition.vde_val_status != 3 and rcd_pts_val_definition.vde_val_status != 4 and rcd_pts_val_definition.vde_val_status != 9) then
            pts_gen_function.add_mesg_data('Current status is Results Entered - new status must be Raised, Results Entered, Closed or Cancelled');
         end if;
         if rcd_retrieve.vde_val_status = 4 and (rcd_pts_val_definition.vde_val_status != 2 and rcd_pts_val_definition.vde_val_status != 4) then
            pts_gen_function.add_mesg_data('Current status is Closed - new status must be Allocation Completed or Closed');
         end if;
         if rcd_retrieve.vde_val_status = 9 then
            pts_gen_function.add_mesg_data('Current status is Cancelled - update not allowed');
         end if;
         if rcd_pts_val_definition.vde_val_status = 2 or rcd_pts_val_definition.vde_val_status = 3 or rcd_pts_val_definition.vde_val_status = 4 then
            if var_test = false then
                pts_gen_function.add_mesg_data('Validation status is Allocation Completed, Results Entered or Closed and no tests defined - update not allowed');
            end if;
            if var_allocation = false then
                pts_gen_function.add_mesg_data('Validation status is Allocation Completed, Results Entered or Closed and no allocation - update not allowed');
            end if;
         end if;
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Process the test definition
      /*-*/
      if var_locked = true then

         /*-*/
         /* Update the test
         /*-*/
         var_confirm := 'updated';
         update pts_val_definition
            set vde_val_title = rcd_pts_val_definition.vde_val_title,
                vde_val_status = rcd_pts_val_definition.vde_val_status,
                vde_val_comment = rcd_pts_val_definition.vde_val_comment,
                vde_val_str_date = rcd_pts_val_definition.vde_val_str_date,
                vde_val_fld_week = rcd_pts_val_definition.vde_val_fld_week,
                vde_pet_type = rcd_pts_val_definition.vde_pet_type
          where vde_val_code = rcd_pts_val_definition.vde_val_code;

         /*-*/
         /* Remove response data when required
         /*-*/
         if rcd_pts_val_definition.vde_val_status = 1 then
            delete
            from    pts_tes_response 
            where   tre_tes_code in (
                      select  vte_tes_code
                      from    pts_val_test
                      where   vte_val_code = rcd_pts_val_definition.vde_val_code
                    );
         end if;
         
         /*-*/
         /* Release any panel members when required
         /*-*/
         if rcd_pts_val_definition.vde_val_status = 4 or rcd_pts_val_definition.vde_val_status = 9 then
            update pts_pet_definition
               set pde_pet_status = decode(pde_pet_status,2,1,5,3,1),
                   pde_val_code = null
             where pde_val_code = rcd_pts_val_definition.vde_val_code;
            update pts_hou_definition
               set hde_hou_status = decode(hde_hou_status,2,1,5,3,1),
                   hde_val_code = null
             where hde_val_code = rcd_pts_val_definition.vde_val_code;
         end if;

      else

         /*-*/
         /* Create the test
         /*-*/
         var_confirm := 'created';
         select pts_val_sequence.nextval into rcd_pts_val_definition.vde_val_code from dual;
         insert into pts_val_definition values rcd_pts_val_definition;

      end if;

      /*-*/
      /* Copy the validation data when required
      /*-*/
      if not(var_cpy_code is null) and var_confirm = 'created' then
         insert into pts_val_test
            select rcd_pts_val_definition.vde_val_code,
                   vte_tes_code,
                   vte_tes_seqn
              from pts_val_test
             where vte_val_code = var_cpy_code;
      end if;

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
      pts_gen_function.set_cfrm_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') successfully '||var_confirm);

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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /********************************************************/
   /* This procedure performs the retrieve preview routine */
   /********************************************************/
   function retrieve_preview return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_found boolean;
      var_status varchar2(128);
      var_test varchar2(1);
      var_allocation varchar2(1);
      var_response varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = var_val_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_test is
         select t01.*
           from pts_val_test t01
          where t01.vte_val_code = rcd_retrieve.vde_val_code;
      rcd_test csr_test%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_val_allocation t01
          where t01.val_val_code = rcd_retrieve.vde_val_code;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_response is
         select t02.*
           from pts_val_test t01
                inner join pts_tes_response t02 on t01.vte_tes_code = t02.tre_tes_code
          where t01.vte_val_code = rcd_retrieve.vde_val_code;
      rcd_response csr_response%rowtype;

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
      if var_action != '*RTVPVW' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the test
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.vde_val_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.vde_val_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.vde_val_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.vde_val_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.vde_val_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Retrieve the validation test
      /*-*/
      var_test := '0';
      open csr_test;
      fetch csr_test into rcd_test;
      if csr_test%found then
         var_test := '1';
      end if;
      close csr_test;

      /*-*/
      /* Retrieve the validation allocation
      /*-*/
      var_allocation := '0';
      open csr_allocation;
      fetch csr_allocation into rcd_allocation;
      if csr_allocation%found then
         var_allocation := '1';
      end if;
      close csr_allocation;

      /*-*/
      /* Retrieve the validation response
      /*-*/
      var_response := '0';
      open csr_response;
      fetch csr_response into rcd_response;
      if csr_response%found then
         var_response := '1';
      end if;
      close csr_response;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<VAL VALTXT="('||to_char(rcd_retrieve.vde_val_code)||') '||pts_to_xml(rcd_retrieve.vde_val_title)||pts_to_xml(var_status)||'" TESDTA="'||var_test||'" ALCDTA="'||var_allocation||'" RESDTA="'||var_response||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RETRIEVE_PREVIEW - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_preview;

   /*********************************************************/
   /* This procedure performs the retrieve test routine     */
   /*********************************************************/
   function retrieve_test return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_found boolean;
      var_status varchar2(128);
      var_response varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = var_val_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_test is
         select t02.*,
                t03.vty_typ_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*TES_DEF' and sva_fld_code = 9 and sva_val_code = t02.tde_tes_status),'*UNKNOWN') as status_text
           from pts_val_test t01
                inner join pts_tes_definition t02 on t01.vte_tes_code = t02.tde_tes_code
                inner join pts_val_type t03 on t02.tde_val_type = t03.vty_val_type
          where t01.vte_val_code = var_val_code
          order by t01.vte_tes_seqn asc;
      rcd_test csr_test%rowtype;

      cursor csr_response is
         select t02.*
           from pts_val_test t01
                inner join pts_tes_response t02 on t01.vte_tes_code = t02.tre_tes_code
          where t01.vte_val_code = rcd_retrieve.vde_val_code;
      rcd_response csr_response%rowtype;

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
      if var_action != '*RTVTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.vde_val_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.vde_val_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.vde_val_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.vde_val_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.vde_val_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Retrieve the test response
      /*-*/
      var_response := '0';
      open csr_response;
      fetch csr_response into rcd_response;
      if csr_response%found then
         var_response := '1';
      end if;
      close csr_response;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the validation xml
      /*-*/
      pipe row(pts_xml_object('<VAL VALTXT="('||to_char(rcd_retrieve.vde_val_code)||') '||pts_to_xml(rcd_retrieve.vde_val_title)||pts_to_xml(var_status)||'" VALSTA="'||to_char(rcd_retrieve.vde_val_status)||'" RESDTA="'||var_response||'"/>'));

      /*-*/
      /* Pipe the validation test xml
      /*-*/
      open csr_test;
      loop
         fetch csr_test into rcd_test;
         if csr_test%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TEST TESCDE="'||to_char(rcd_test.tde_tes_code)||'" VALTYP="'||pts_to_xml(rcd_test.vty_typ_text)||'" TESTIT="('||to_char(rcd_test.tde_tes_code)||') '||pts_to_xml(rcd_test.tde_tes_title)||'" TESSTA="'||pts_to_xml(rcd_test.status_text)||'"/>'));
      end loop;
      close csr_test;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RETRIEVE_TEST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_test;

   /*******************************************************/
   /* This procedure performs the select test routine     */
   /*******************************************************/
   function select_test return pts_xml_type pipelined is

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
      cursor csr_test is
         select t01.*,
                t02.vty_typ_text,
                nvl((select sva_val_text from pts_sys_value where sva_tab_code = '*TES_DEF' and sva_fld_code = 9 and sva_val_code = t01.tde_tes_status),'*UNKNOWN') as status_text
           from pts_tes_definition t01
                inner join pts_val_type t02 on t01.tde_val_type = t02.vty_val_type
          where t01.tde_tes_code = var_tes_code;
      rcd_test csr_test%rowtype;

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
      if var_action != '*SELTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_tes_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@TESCDE'));
      if var_tes_code is null then
         pts_gen_function.add_mesg_data('Test code ('||xslProcessor.valueOf(obj_pts_request,'@TESCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the question
      /*-*/
      var_found := false;
      open csr_test;
      fetch csr_test into rcd_test;
      if csr_test%found then
         var_found := true;
      end if;
      close csr_test;
      if var_found = false then
         pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist, or is not a validation test');
      end if;
      if rcd_test.tde_tes_status not in (1,2,3) then
         pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must be active');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<TEST TESCDE="'||to_char(rcd_test.tde_tes_code)||'" VALTYP="'||pts_to_xml(rcd_test.vty_typ_text)||'" TESTXT="('||to_char(rcd_test.tde_tes_code)||') '||pts_to_xml(rcd_test.tde_tes_title)||'" TESSTA="'||pts_to_xml(rcd_test.status_text)||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - SELECT_TEST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_test;

   /*******************************************************/
   /* This procedure performs the update test routine     */
   /*******************************************************/
   procedure update_test(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_tes_list xmlDom.domNodeList;
      obj_tes_node xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_tes_code number;
      rcd_pts_val_definition pts_val_definition%rowtype;
      rcd_pts_val_test pts_val_test%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = rcd_pts_val_definition.vde_val_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_test is
         select t01.*
           from pts_tes_definition t01
                inner join pts_val_type t02 on t01.tde_val_type = t02.vty_val_type
          where t01.tde_tes_code = var_tes_code
                and t01.tde_val_type is not null;
      rcd_test csr_test%rowtype;

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
      if var_action != '*UPDTES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_val_definition.vde_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if rcd_pts_val_definition.vde_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing validation
      /*-*/
      var_found := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') does not exist');
      end if;
      if rcd_retrieve.vde_val_status != 1 
         and rcd_retrieve.vde_val_status != 2
         and rcd_retrieve.vde_val_status != 3 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(rcd_pts_val_definition.vde_val_code) || ') must be status Raised, Allocation Complete or Results Entered - test update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Retrieve and validate the test data
      /*-*/
      obj_tes_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/TEST');
      for idy in 0..xmlDom.getLength(obj_tes_list)-1 loop
         obj_tes_node := xmlDom.item(obj_tes_list,idy);
         var_tes_code := pts_to_number(xslProcessor.valueOf(obj_tes_node,'@TESCDE'));
         open csr_test;
         fetch csr_test into rcd_test;
         if csr_test%notfound then
            pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist, or is not a validation test');
         else
            if rcd_test.tde_tes_status != 1 
               and rcd_test.tde_tes_status != 2 
               and rcd_test.tde_tes_status != 3 then
               pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') is not active');
            end if;
         end if;
         close csr_test;
      end loop;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Delete the existing test data from missing tests
      /*-*/
      delete from pts_tes_response where tre_tes_code in (
        select  vte_tes_code
        from    pts_val_test
        where   vte_val_code = rcd_pts_val_definition.vde_val_code
      );
      delete from pts_val_test where vte_val_code = rcd_pts_val_definition.vde_val_code;

      /*-*/
      /* Retrieve and insert the test data
      /*-*/
      obj_tes_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/TEST');
      rcd_pts_val_test.vte_tes_seqn := 0;
      for idy in 0..xmlDom.getLength(obj_tes_list)-1 loop
         obj_tes_node := xmlDom.item(obj_tes_list,idy);
         rcd_pts_val_test.vte_val_code := rcd_pts_val_definition.vde_val_code;
         rcd_pts_val_test.vte_tes_code := pts_to_number(xslProcessor.valueOf(obj_tes_node,'@TESCDE'));
         rcd_pts_val_test.vte_tes_seqn := rcd_pts_val_test.vte_tes_seqn + 1;
         insert into pts_val_test values rcd_pts_val_test;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - UPDATE_QUESTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_test;


   /*********************************************************/
   /* This procedure performs the retrieve pet routine     */
   /*********************************************************/
   function retrieve_pet return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_found boolean;
      var_status varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = var_val_code;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_pet is
         select distinct
                t02.*
           from pts_val_allocation t01
                inner join pts_pet_definition t02 on t01.val_pet_code = t02.pde_pet_code
          where t01.val_val_code = var_val_code
          order by t02.pde_pet_code asc;
      rcd_pet csr_pet%rowtype;

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
      if var_action != '*RTVPET' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.vde_val_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.vde_val_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.vde_val_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.vde_val_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.vde_val_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the validation xml
      /*-*/
      pipe row(pts_xml_object('<VAL VALTXT="('||to_char(rcd_retrieve.vde_val_code)||') '||pts_to_xml(rcd_retrieve.vde_val_title)||pts_to_xml(var_status)||'" VALSTA="'||to_char(rcd_retrieve.vde_val_status)||'"/>'));

      /*-*/
      /* Pipe the validation pet xml
      /*-*/
      open csr_pet;
      loop
         fetch csr_pet into rcd_pet;
         if csr_pet%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PET PETCDE="'||to_char(rcd_pet.pde_pet_code)||'" PETNAM="('||to_char(rcd_pet.pde_pet_code)||') '||pts_to_xml(rcd_pet.pde_pet_name)||'"/>'));
      end loop;
      close csr_pet;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RETRIEVE_PET - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_pet;
   
   /*******************************************************/
   /* This procedure performs the select pet routine      */
   /*******************************************************/
   function select_pet return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_pet_code number;
      var_val_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pet is
         select t01.*,
                case
                  when exists (
                    select  1
                    from    pts_val_pet p
                            inner join pts_val_status s on p.vpe_sta_code = s.vst_sta_code
                    where   p.vpe_pet_code = var_pet_code
                            and s.vst_val_flg = 1
                  ) then 1
                  else 0
                end as req_val,
                t02.*
           from pts_pet_definition t01
                inner join pts_hou_definition t02 on t01.pde_hou_code = t02.hde_hou_code
          where t01.pde_pet_code = var_pet_code;
      rcd_pet csr_pet%rowtype;
      
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      

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
      if var_action != '*SELPET' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      var_pet_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if var_pet_code is null then
         pts_gen_function.add_mesg_data('Pet code ('||xslProcessor.valueOf(obj_pts_request,'@PETCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the question
      /*-*/
      var_found := false;
      open csr_pet;
      fetch csr_pet into rcd_pet;
      if csr_pet%found then
         var_found := true;
      end if;
      close csr_pet;
      if var_found = false then
         pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') does not exist');
      end if;
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if rcd_pet.pde_pet_status != 1 then
         pts_gen_function.add_mesg_data('Pet code (' || to_char(var_pet_code) || ') must be active');
      end if;
      if rcd_pet.hde_hou_status != 1 then
         pts_gen_function.add_mesg_data('Pet code (' || to_char(var_pet_code) || ') must have active household');
      end if;
      if rcd_pet.req_val != 1 then
         pts_gen_function.add_mesg_data('Pet code (' || to_char(var_pet_code) || ') does not require validation');
      end if;
      if rcd_pet.pde_pet_type != rcd_validation.vde_pet_type then
         pts_gen_function.add_mesg_data('Pet code (' || to_char(var_pet_code) || ') is not the required type');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test xml
      /*-*/
      pipe row(pts_xml_object('<PET PETCDE="'||to_char(rcd_pet.pde_pet_code)||'" PETNAM="('||to_char(rcd_pet.pde_pet_code)||') '||pts_to_xml(rcd_pet.pde_pet_name)||'"/>'));

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - SELECT_PET - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_pet;
   
   /*******************************************************/
   /* This procedure performs the update pet routine      */
   /*******************************************************/
   procedure update_pet(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      obj_pet_list xmlDom.domNodeList;
      obj_pet_node xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_val_code number;
      var_pet_code number;
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = var_val_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_pet is
         select t01.*,
                case
                  when exists (
                    select  1
                    from    pts_val_allocation p
                    where   p.val_pet_code = var_pet_code
                            and p.val_val_code = var_val_code
                  ) then 1
                  else 0
                end as on_validation
           from pts_pet_definition t01
          where t01.pde_pet_code = var_pet_code;
      rcd_pet csr_pet%rowtype;
      
      cursor csr_pet_val is
        select  pde_val_code
        from    pts_pet_definition
        where   pde_pet_code = var_pet_code;
      rcd_pet_val csr_pet_val%rowtype;
      
      cursor csr_val_test is
        select  t01.*
        from    pts_tes_definition t01
                inner join pts_val_test t02 on t01.tde_tes_code = t02.vte_tes_code
        where   t02.vte_val_code = var_val_code
                and t01.tde_tes_status in (1,2,3); --Raised, Allocation Complete, Results Entered
      rcd_val_test csr_val_test%rowtype;
      
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
      if var_action != '*UPDPET' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing validation
      /*-*/
      var_found := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if rcd_retrieve.vde_val_status != 1 and rcd_retrieve.vde_val_status != 2 and rcd_retrieve.vde_val_status != 3 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(var_val_code) || ') must be status Raised, Allocation Complete or Results Entered - pet update not allowed');
      end if;
      open csr_val_test;
      fetch csr_val_test into rcd_val_test;
      if csr_val_test%notfound then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(var_val_code) || ') must have at least one test in status Raised, Allocation Complete or Results Entered - allocation not allowed');
      end if;
      close csr_val_test;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;
      
      /*-*/
      /* Retrieve and validate the pet data
      /*-*/
      obj_pet_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/PET');
      for idy in 0..xmlDom.getLength(obj_pet_list)-1 loop
         obj_pet_node := xmlDom.item(obj_pet_list,idy);
         var_pet_code := pts_to_number(xslProcessor.valueOf(obj_pet_node,'@PETCDE'));
         open csr_pet;
         fetch csr_pet into rcd_pet;
         if csr_pet%notfound then
            pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') does not exist');
         else
            if rcd_pet.on_validation = 0 then
              if rcd_pet.pde_pet_status != 1 then
                 pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') is not active');
              else
                 --insert into tab_pets values rcd_pet;
                 /*-*/
                 /* Perform the pet allocation routine
                 /*-*/
                 begin
                    pts_pet_allocation.perform_allocation_validation(var_val_code, var_pet_code);
                 exception
                    when others then
                    pts_gen_function.add_mesg_data(substr(SQLERRM, 1, 2000));
                    rollback;
                    return;
                 end;
                 
                 --Confirm the pet is now on validation
                 open csr_pet_val;
                 fetch csr_pet_val into rcd_pet_val;
                 close csr_pet_val;
                 
                 if nvl(rcd_pet_val.pde_val_code,0) <> var_val_code then
                    pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') not available for validation, or no suitable tests in validation for this pet');
                 end if;
              end if;
            end if;
         end if;
         close csr_pet;
      end loop;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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

         /* Raise an exception to the calling application
         /*-*/
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - UPDATE_PET - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_pet;
   
   /***********************************************************/
   /* This procedure performs the retrieve allocation routine */
   /***********************************************************/
   function retrieve_allocation return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_found boolean;
      var_status varchar2(128);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*,
                decode(nvl(t02.allocation_count,0),0,'0','1') as allocation_done
           from pts_val_definition t01,
                (select val_val_code, count(*) as allocation_count from pts_val_allocation where val_val_code = var_val_code group by val_val_code) t02
          where t01.vde_val_code = t02.val_val_code(+)
            and t01.vde_val_code = var_val_code;
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
      if var_action != '*RTVALC' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_retrieve;
      fetch csr_retrieve into rcd_retrieve;
      if csr_retrieve%found then
         var_found := true;
      end if;
      close csr_retrieve;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_status := ' - (*UNKNOWN)';
      if rcd_retrieve.vde_val_status = 1 then
         var_status := ' - (Raised)';
      elsif rcd_retrieve.vde_val_status = 2 then
         var_status := ' - (Allocation Completed)';
      elsif rcd_retrieve.vde_val_status = 3 then
         var_status := ' - (Results Entered)';
      elsif rcd_retrieve.vde_val_status = 4 then
         var_status := ' - (Closed)';
      elsif rcd_retrieve.vde_val_status = 9 then
         var_status := ' - (Cancelled)';
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the validation xml
      /*-*/
      pipe row(pts_xml_object('<VAL VALTXT="('||to_char(rcd_retrieve.vde_val_code)||') '||pts_to_xml(rcd_retrieve.vde_val_title)||pts_to_xml(var_status)||'" VALSTA="'||to_char(rcd_retrieve.vde_val_status)||'" ALCDON="'||pts_to_xml(rcd_retrieve.allocation_done)||'"/>'));

      /*-*/
      /* Pipe the validation type data
      /*-*/
      for val_type in (
          select    vty_val_type,
                    vty_typ_text
          from      pts_val_type
          order by  vty_typ_seq asc
      ) loop
        pipe row(pts_xml_object('<VAL_TYPE VALCDE="'||pts_to_xml(val_type.vty_val_type)||'" VALTXT="'||pts_to_xml(val_type.vty_typ_text)||'"/>'));
      end loop;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RETRIEVE_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve_allocation;

   /*********************************************************/
   /* This procedure performs the update allocation routine */
   /*********************************************************/
   procedure update_allocation(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_update_count number;
      var_begin_date date;
      var_action varchar2(32);
      var_found boolean;
      rcd_pts_val_definition pts_val_definition%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from pts_val_definition t01
          where t01.vde_val_code = rcd_pts_val_definition.vde_val_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;
      
      cursor csr_val_test is
        select  t01.*
        from    pts_tes_definition t01
                inner join pts_val_test t02 on t01.tde_tes_code = t02.vte_tes_code
        where   t02.vte_val_code = rcd_pts_val_definition.vde_val_code
                and t01.tde_tes_status in (1,2,3); --Raised, Allocation Complete, Results Entered
      rcd_val_test csr_val_test%rowtype;

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
      if var_action != '*UPDALC' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      rcd_pts_val_definition.vde_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if rcd_pts_val_definition.vde_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      open csr_val_test;
      fetch csr_val_test into rcd_val_test;
      if csr_val_test%notfound then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(rcd_pts_val_definition.vde_val_code) || ') must have at least one test in status Raised, Allocation Complete or Results Entered - allocation not allowed');
      end if;
      close csr_val_test;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve and lock the existing validation
      /*-*/
      var_found := false;
      begin
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
      exception
         when others then
            pts_gen_function.add_mesg_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') does not exist');
      end if;
      if rcd_retrieve.vde_val_status != 1 and rcd_retrieve.vde_val_status != 2 and rcd_retrieve.vde_val_status != 3 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(rcd_pts_val_definition.vde_val_code) || ') must be status Raised, Allocation Complete, or Results Entered - allocation update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;

      /*-*/
      /* Perform the pet allocation routine
      /*-*/
      var_begin_date := sysdate; --Log the time
      begin
         pts_pet_allocation.perform_allocation_validation(rcd_pts_val_definition.vde_val_code, null);
      exception
         when others then
         pts_gen_function.add_mesg_data(substr(SQLERRM, 1, 2000));
         rollback;
         return;
      end;

      /*-*/
      /* Commit the database
      /*-*/
      commit;
      
      /*-*/
      /* Check that pets were added for the validation
      /*-*/
      select  count(distinct val_pet_code)
      into    var_update_count
      from    pts_val_allocation
      where   val_val_code = rcd_pts_val_definition.vde_val_code
              and val_all_date >= var_begin_date;

      /*-*/
      /* Send the confirm message
      /*-*/
      if var_update_count = 0 then
        pts_gen_function.set_cfrm_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') allocation had no pets to add.');
      else
        pts_gen_function.set_cfrm_data('Validation ('||to_char(rcd_pts_val_definition.vde_val_code)||') allocation completed successfully, '||to_char(var_update_count)||' pets added.');
      end if;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - UPDATE_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_allocation;
   
   /*********************************************************/
   /* This procedure performs the report allocation routine */
   /*********************************************************/
   function report_allocation(par_val_code in number, par_val_type in number, par_val_date in varchar2) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_val_date date;
      var_val_code number;
      var_val_type number;
      var_found boolean;
      var_panel boolean;
      var_first boolean;
      var_day number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_type is
        select  t01.*
        from    pts_val_type t01
        where   t01.vty_val_type = var_val_type;
      rcd_type csr_type%rowtype;
      
      cursor csr_panel is
        select    distinct
                  t01.val_tes_code,
                  t07.*,
                  t02.*,
                  t03.*,
                  decode(t04.pty_pet_type,null,'*UNKNOWN','('||t04.pty_pet_type||') '||t04.pty_typ_text) as type_text,
                  decode(t06.sva_val_code,null,'*UNKNOWN','('||t06.sva_val_code||') '||t06.sva_val_text) as size_text,
                  decode(t05.gzo_geo_zone,null,'*UNKNOWN','('||t05.gzo_geo_zone||') '||t05.gzo_zon_text) as zone_text
        from      pts_val_allocation t01
                  inner join pts_tes_definition t07 on t01.val_tes_code = t07.tde_tes_code
                  inner join pts_pet_definition t02 on t01.val_pet_code = t02.pde_pet_code
                  left outer join pts_hou_definition t03 on t02.pde_hou_code = t03.hde_hou_code
                  left outer join pts_pet_type t04 on t02.pde_pet_type = t04.pty_pet_type
                  left outer join pts_geo_zone t05 on (
                    t03.hde_geo_zone = t05.gzo_geo_zone
                    and t05.gzo_geo_type = 40
                  )
                  left outer join (
                    select  t01.pcl_pet_code,
                            t02.sva_val_text,
                            t02.sva_val_code
                    from    pts_pet_classification t01
                            inner join pts_sys_value t02 on (
                              t01.pcl_fld_code = t02.sva_fld_code 
                              and t01.pcl_tab_code = t02.sva_tab_code
                              and t01.pcl_val_code = t02.sva_val_code
                            )
                    where   t01.pcl_tab_code = '*PET_CLA'
                            and t01.pcl_fld_code = 8
                  ) t06 on t02.pde_pet_code = t06.pcl_pet_code
        where     t01.val_val_code = var_val_code
                  and t07.tde_val_type = var_val_type
                  and t01.val_all_date >= var_val_date
        order by  t03.hde_geo_zone asc,
                  t02.pde_pet_code asc,
                  t07.tde_val_type asc,
                  t07.tde_tes_code asc;
      rcd_panel csr_panel%rowtype;
          
      cursor csr_allocation is
         select t01.val_day_code,
                t01.val_seq_numb,
                t01.val_mkt_code,
                t02.tsa_rpt_code,
                t02.tsa_mkt_code,
                t02.tsa_mkt_acde,
                '('||t01.val_sam_code||') '||nvl(t03.sde_sam_text,'*UNKNOWN') as sample_text
           from pts_val_allocation t01,
                pts_tes_sample t02,
                pts_sam_definition t03
          where t01.val_tes_code = t02.tsa_tes_code(+)
            and t01.val_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_sam_code = t03.sde_sam_code(+)
            and t01.val_tes_code = rcd_panel.val_tes_code
            and t01.val_pet_code = rcd_panel.pde_pet_code
          order by t01.val_day_code asc,
                   t01.val_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_val_code := par_val_code;
      var_val_type := par_val_type;
      
      begin
         var_val_date := nvl(to_date(par_val_date, 'DD/MM/YYYY'),to_date('01/01/2000', 'DD/MM/YYYY'));
      exception
         when others then
         var_val_date := to_date('01/01/2000', 'DD/MM/YYYY');
      end;
      
      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         raise_application_error(-20000, 'Validation code ('||to_char(var_val_code)||') does not exist');
      end if;
      
      var_found := false;
      open csr_type;
      fetch csr_type into rcd_type;
      if csr_type%found then
         var_found := true;
      end if;
      close csr_type;
      if var_found = false then
         raise_application_error(-20000, 'Validation type code ('||to_char(var_val_type)||') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      if rcd_type.vty_tes_type = 1 then
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=11 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Validation Test Allocation - ('||rcd_validation.vde_val_code||') '||rcd_validation.vde_val_title||'</td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Test</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Size</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Household</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Day</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Report Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Alias</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sample</td>');
         pipe row('</tr>');
         pipe row('<tr><td align=center colspan=11></td></tr>');
      else
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=12 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Validation Test Allocation - ('||rcd_validation.vde_val_code||') '||rcd_validation.vde_val_title||'</td></tr>');
         pipe row('<tr>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Test</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Type</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Size</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Household</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Day</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Seq</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Report Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Code</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Market Alias</td>');
         pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Sample</td>');
         pipe row('</tr>');
         pipe row('<tr><td align=center colspan=12></td></tr>');
      end if;

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := false;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Panel found
         /*-*/
         var_panel := true;

         /*-*/
         /* Retrieve the test panel allocation
         /*-*/
         var_first := true;
         var_day := 0;
         open csr_allocation;
         loop
            fetch csr_allocation into rcd_allocation;
            if csr_allocation%notfound then
               exit;
            end if;
            var_output := '<tr>';
            if var_first = true then
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">('||rcd_panel.val_tes_code||') '||rcd_panel.tde_tes_title||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.zone_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.type_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||rcd_panel.size_text||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>('||rcd_panel.pde_pet_code||') '||rcd_panel.pde_pet_name||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>('||rcd_panel.hde_hou_code||') '||rcd_panel.hde_con_fullname||', '||rcd_panel.hde_loc_street||', '||rcd_panel.hde_loc_town||'</td>';
            else
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
            end if;
            var_first := false;
            if rcd_type.vty_tes_type = 1 then
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.val_day_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_rpt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_acde)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.sample_text)||'</td>';
               var_output := var_output||'</tr>';
            else
               if rcd_allocation.val_day_code != var_day then
                  var_day := rcd_allocation.val_day_code;
                  var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.val_day_code)||'</td>';
               else
                  var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>';
               end if;
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.val_seq_numb)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_rpt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_code)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.tsa_mkt_acde)||'</td>';
               var_output := var_output||'<td align=left style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;" nowrap>'||to_char(rcd_allocation.sample_text)||'</td>';
               var_output := var_output||'</tr>';
            end if;
            pipe row(var_output);
         end loop;
         close csr_allocation;

      end loop;
      close csr_panel;

      /*-*/
      /* No Panel selection
      /*-*/
      if var_panel = false then
         if rcd_type.vty_tes_type = 1 then
            pipe row('<tr><td align=center colspan=11 style="FONT-WEIGHT:bold;">NO PANEL</td></tr>');
         else
            pipe row('<tr><td align=center colspan=12 style="FONT-WEIGHT:bold;">NO PANEL</td></tr>');
         end if;
      end if;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_VAL_ALLOCATION - REPORT_ALLOCATION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_allocation;

   /************************************************************/
   /* This procedure performs the report questionnaire routine */
   /************************************************************/
   function report_questionnaire(par_val_code in number, par_val_type in number, par_val_date in varchar2) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_val_code number;
      var_val_type number;
      var_day_code number;
      var_val_date date;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*,
                (
                  select  max(tde_tes_day_count)
                  from    pts_val_test vte
                          inner join pts_tes_definition tde on vte.vte_tes_code = tde.tde_tes_code
                  where   vte.vte_val_code = var_val_code
                          and tde.tde_val_type = var_val_type
                ) as day_count,
                (
                  select  max(tde_tes_sam_count)
                  from    pts_val_test vte
                          inner join pts_tes_definition tde on vte.vte_tes_code = tde.tde_tes_code
                  where   vte.vte_val_code = var_val_code
                          and tde.tde_val_type = var_val_type
                ) as sam_count
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_type is
        select  t01.*
        from    pts_val_type t01
        where   t01.vty_val_type = var_val_type;
      rcd_type csr_type%rowtype;
      
      cursor csr_panel is
        select    distinct
                  t01.val_tes_code,
                  t07.*,
                  t02.*,
                  t03.*,
                  decode(t04.pty_pet_type,null,'*UNKNOWN','('||t04.pty_pet_type||') '||t04.pty_typ_text) as type_text,
                  decode(t06.sva_val_code,null,'*UNKNOWN','('||t06.sva_val_code||') '||t06.sva_val_text) as size_text,
                  decode(t05.gzo_geo_zone,null,'*UNKNOWN','('||t05.gzo_geo_zone||') '||t05.gzo_zon_text) as zone_text,
                  t06.sva_val_code as size_code
        from      pts_val_allocation t01
                  inner join pts_tes_definition t07 on t01.val_tes_code = t07.tde_tes_code
                  inner join pts_pet_definition t02 on t01.val_pet_code = t02.pde_pet_code
                  left outer join pts_hou_definition t03 on t02.pde_hou_code = t03.hde_hou_code
                  left outer join pts_pet_type t04 on t02.pde_pet_type = t04.pty_pet_type
                  left outer join pts_geo_zone t05 on (
                    t03.hde_geo_zone = t05.gzo_geo_zone
                    and t05.gzo_geo_type = 40
                  )
                  left outer join (
                    select  t01.pcl_pet_code,
                            t02.sva_val_text,
                            t02.sva_val_code
                    from    pts_pet_classification t01
                            inner join pts_sys_value t02 on (
                              t01.pcl_fld_code = t02.sva_fld_code 
                              and t01.pcl_tab_code = t02.sva_tab_code
                              and t01.pcl_val_code = t02.sva_val_code
                            )
                    where   t01.pcl_tab_code = '*PET_CLA'
                            and t01.pcl_fld_code = 8
                  ) t06 on t02.pde_pet_code = t06.pcl_pet_code
        where     t01.val_val_code = var_val_code
                  and t07.tde_val_type = var_val_type
                  and t01.val_all_date >= var_val_date
        order by  t03.hde_geo_zone asc,
                  t02.pde_pet_code asc,
                  t07.tde_val_type asc,
                  t07.tde_tes_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.*,
                nvl(t02.tsa_mkt_code,'*') as tsa_mkt_code,
                nvl(t02.tsa_mkt_acde,'*') as tsa_mkt_acde,
                to_char(nvl(t03.tfe_fed_qnty,0)) as tfe_fed_qnty,
                t03.tfe_fed_text,
                to_char(nvl(t04.sde_uom_size,0))||' '||nvl(t05.sva_val_text,'*UNKNOWN') as size_text
           from pts_val_allocation t01,
                pts_tes_sample t02,
                (select t01.*
                   from pts_tes_feeding t01
                  where t01.tfe_tes_code = rcd_panel.tde_tes_code
                    and t01.tfe_pet_size = rcd_panel.size_code) t03,
                pts_sam_definition t04,
                (select t01.sva_val_code,
                        t01.sva_val_text
                   from pts_sys_value t01
                  where t01.sva_tab_code = '*SAM_DEF'
                    and t01.sva_fld_code = 4) t05
          where t01.val_tes_code = t02.tsa_tes_code(+)
            and t01.val_sam_code = t02.tsa_sam_code(+)
            and t02.tsa_tes_code = t03.tfe_tes_code(+)
            and t02.tsa_sam_code = t03.tfe_sam_code(+)
            and t02.tsa_sam_code = t04.sde_sam_code(+)
            and t04.sde_uom_code = t05.sva_val_code(+)
            and t01.val_tes_code = rcd_panel.tde_tes_code
            and t01.val_pet_code = rcd_panel.pde_pet_code
            and t01.val_day_code = var_day_code
          order by t01.val_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_val_code := par_val_code;
      var_val_type := par_val_type;
      
      begin
         var_val_date := nvl(to_date(par_val_date, 'DD/MM/YYYY'),to_date('01/01/2000', 'DD/MM/YYYY'));
      exception
         when others then
         var_val_date := to_date('01/01/2000', 'DD/MM/YYYY');
      end;

      /*-*/
      /* Retrieve the existing validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         raise_application_error(-20000, 'Validation code (' || to_char(var_val_code) || ') does not exist');
      end if;
      
      var_found := false;
      open csr_type;
      fetch csr_type into rcd_type;
      if csr_type%found then
         var_found := true;
      end if;
      close csr_type;
      if var_found = false then
         raise_application_error(-20000, 'Validation type code ('||to_char(var_val_type)||') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '"'||'TESTCODE'||'"';
      var_output := var_output||',"'||'TESTTITLE'||'"';
      var_output := var_output||',"'||'AREA'||'"';
      var_output := var_output||',"'||'PETCODE'||'"';
      var_output := var_output||',"'||'PETNAME'||'"';
      var_output := var_output||',"'||'PARTICIPANTNAME'||'"';
      var_output := var_output||',"'||'STREET'||'"';
      var_output := var_output||',"'||'CITYPOSTCODE'||'"';
      var_output := var_output||',"'||'COUNTRY'||'"';
      for idx in 1..rcd_validation.day_count loop
         var_output := var_output||',"'||'DAY'||to_char(idx)||'"';
         for idy in 1..rcd_validation.sam_count loop
            var_output := var_output||',"'||'D'||to_char(idx)||'MR'||to_char(idy)||'"';
            var_output := var_output||',"'||'D'||to_char(idx)||'QTY'||to_char(idy)||'"';
            var_output := var_output||',"'||'D'||to_char(idx)||'OFF'||to_char(idy)||'"';
            var_output := var_output||',"'||'D'||to_char(idx)||'SIZE'||to_char(idy)||'"';
         end loop;
      end loop;
      pipe row(var_output);

      /*-*/
      /* Retrieve the panel
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Output the panel data
         /*-*/
         var_output := '"'||to_char(rcd_panel.tde_tes_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.tde_tes_title,'"','""')||'"';
         var_output := var_output||',"'||to_char(rcd_panel.hde_geo_zone)||'"';
         var_output := var_output||',"'||to_char(rcd_panel.pde_pet_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.pde_pet_name,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.hde_con_fullname,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.hde_loc_street,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.hde_loc_town||' '||rcd_panel.hde_loc_postcode,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.hde_loc_country,'"','""')||'"';
         for idx in 1..rcd_validation.day_count loop
            var_day_code := idx;
            var_output := var_output||',"'||'Day'||to_char(var_day_code)||'"';
            open csr_allocation;
            loop
               fetch csr_allocation into rcd_allocation;
               if csr_allocation%notfound then
                  exit;
               end if;
               var_output := var_output||',"'||replace(rcd_allocation.val_mkt_code,'"','""')||'"';
               var_output := var_output||',"'||to_char(rcd_allocation.tfe_fed_qnty)||'"';
               var_output := var_output||',"'||replace(rcd_allocation.tfe_fed_text,'"','""')||'"';
               var_output := var_output||',"'||replace(rcd_allocation.size_text,'"','""')||'"';
            end loop;
            close csr_allocation;
         end loop;
         pipe row(var_output);

      end loop;
      close csr_panel;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_VAL_FUNCTION - REPORT_QUESTIONNAIRE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_questionnaire;

   /********************************************************/
   /* This procedure performs the report selection routine */
   /********************************************************/
   function report_selection(par_val_code in number, par_val_type in number, par_val_date in varchar2) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_val_code number;
      var_val_type number;
      var_tes_code number;
      var_pet_code number;
      var_val_date date;
      var_found boolean;
      var_panel boolean;
      var_geo_zone number;
      var_index number;
      var_sam_count number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*,
                (
                  select  sum(tde_tes_day_count)
                  from    pts_val_test vte
                          inner join pts_tes_definition tde on vte.vte_tes_code = tde.tde_tes_code
                  where   vte.vte_val_code = var_val_code
                          and tde.tde_val_type = var_val_type
                ) as day_count_total,
                (
                  select  sum(tde_tes_sam_count)
                  from    pts_val_test vte
                          inner join pts_tes_definition tde on vte.vte_tes_code = tde.tde_tes_code
                  where   vte.vte_val_code = var_val_code
                          and tde.tde_val_type = var_val_type
                ) as sam_count_total
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_type is
        select  t01.*
        from    pts_val_type t01
        where   t01.vty_val_type = var_val_type;
      rcd_type csr_type%rowtype;

      cursor csr_check_allocation is
         select t01.*
           from pts_val_allocation t01
                inner join pts_tes_definition t02 on t01.val_tes_code = t02.tde_tes_code
          where t01.val_val_code = var_val_code
                and t02.tde_val_type = var_val_type
                and t01.val_all_date >= var_val_date;
      rcd_check_allocation csr_check_allocation%rowtype;
      
      cursor csr_panel is
        select    distinct
                  t07.tde_val_type,
                  t02.*,
                  t03.*,
                  decode(t04.pty_pet_type,null,'*UNKNOWN','('||t04.pty_pet_type||') '||t04.pty_typ_text) as type_text,
                  decode(t06.sva_val_code,null,'*UNKNOWN','('||t06.sva_val_code||') '||t06.sva_val_text) as size_text,
                  decode(t05.gzo_geo_zone,null,'*UNKNOWN','('||t05.gzo_geo_zone||') '||t05.gzo_zon_text) as zone_text,
                  t06.sva_val_code as size_code
        from      pts_val_allocation t01
                  inner join pts_tes_definition t07 on t01.val_tes_code = t07.tde_tes_code
                  inner join pts_pet_definition t02 on t01.val_pet_code = t02.pde_pet_code
                  left outer join pts_hou_definition t03 on t02.pde_hou_code = t03.hde_hou_code
                  left outer join pts_pet_type t04 on t02.pde_pet_type = t04.pty_pet_type
                  left outer join pts_geo_zone t05 on (
                    t03.hde_geo_zone = t05.gzo_geo_zone
                    and t05.gzo_geo_type = 40
                  )
                  left outer join (
                    select  t01.pcl_pet_code,
                            t02.sva_val_text,
                            t02.sva_val_code
                    from    pts_pet_classification t01
                            inner join pts_sys_value t02 on (
                              t01.pcl_fld_code = t02.sva_fld_code 
                              and t01.pcl_tab_code = t02.sva_tab_code
                              and t01.pcl_val_code = t02.sva_val_code
                            )
                    where   t01.pcl_tab_code = '*PET_CLA'
                            and t01.pcl_fld_code = 8
                  ) t06 on t02.pde_pet_code = t06.pcl_pet_code
        where     t01.val_val_code = var_val_code
                  and t07.tde_val_type = var_val_type
                  and t01.val_all_date >= var_val_date
        order by  t03.hde_geo_zone asc,
                  t03.hde_hou_code asc,
                  t02.pde_pet_code asc,
                  t07.tde_val_type asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.val_day_code,
                t01.val_mkt_code,
                sum(t03.tfe_fed_qnty) as tfe_fed_qnty
           from pts_val_allocation t01
                inner join pts_tes_definition t02 on t01.val_tes_code = t02.tde_tes_code
                inner join pts_tes_feeding t03 on (
                  t03.tfe_tes_code = t01.val_tes_code
                  and t03.tfe_pet_size = rcd_panel.size_code
                  and t03.tfe_sam_code = t01.val_sam_code
                )
          where t01.val_val_code = var_val_code
                and t01.val_pet_code = rcd_panel.pde_pet_code
                and t02.tde_val_type = var_val_type
          group by t01.val_day_code,
                   t01.val_mkt_code
          order by t01.val_day_code asc,
                   t01.val_mkt_code asc;
      rcd_allocation csr_allocation%rowtype;
      
      cursor csr_area_total is
        select  t01.val_mkt_code,
                sum(t03.tfe_fed_qnty) as total
        from    pts_val_allocation t01
                inner join (
                  select  t01.pcl_pet_code,
                          t02.sva_val_code
                  from    pts_pet_classification t01
                          inner join pts_sys_value t02 on (
                            t01.pcl_fld_code = t02.sva_fld_code 
                            and t01.pcl_tab_code = t02.sva_tab_code
                            and t01.pcl_val_code = t02.sva_val_code
                          )
                  where   t01.pcl_tab_code = '*PET_CLA'
                          and t01.pcl_fld_code = 8
                ) t02 on t01.val_pet_code = t02.pcl_pet_code
                inner join pts_tes_feeding t03 on (
                  t03.tfe_tes_code = t01.val_tes_code
                  and t03.tfe_pet_size = t02.sva_val_code
                  and t03.tfe_sam_code = t01.val_sam_code
                )
                inner join pts_val_test t04 on t01.val_tes_code = t04.vte_tes_code
                inner join pts_tes_definition t05 on t04.vte_tes_code = t05.tde_tes_code
        where   t01.val_val_code = var_val_code
                and t05.tde_val_type = var_val_type
                and t01.val_pet_code in (
                  select  pde.pde_pet_code
                  from    pts_val_allocation val
                          inner join pts_pet_definition pde on val.val_pet_code = pde.pde_pet_code
                          inner join pts_hou_definition hde on pde.pde_hou_code = hde.hde_hou_code
                  where   hde.hde_geo_zone = var_geo_zone
                )
        group by t01.val_mkt_code
        order by t01.val_mkt_code asc;
      rcd_area_total csr_area_total%rowtype;
      
      cursor csr_validation_total is
        select  t01.val_mkt_code,
                sum(t03.tfe_fed_qnty) as total
        from    pts_val_allocation t01
                inner join (
                  select  t01.pcl_pet_code,
                          t02.sva_val_code
                  from    pts_pet_classification t01
                          inner join pts_sys_value t02 on (
                            t01.pcl_fld_code = t02.sva_fld_code 
                            and t01.pcl_tab_code = t02.sva_tab_code
                            and t01.pcl_val_code = t02.sva_val_code
                          )
                  where   t01.pcl_tab_code = '*PET_CLA'
                          and t01.pcl_fld_code = 8
                ) t02 on t01.val_pet_code = t02.pcl_pet_code
                inner join pts_tes_feeding t03 on (
                  t03.tfe_tes_code = t01.val_tes_code
                  and t03.tfe_pet_size = t02.sva_val_code
                  and t03.tfe_sam_code = t01.val_sam_code
                )
                inner join pts_val_test t04 on t01.val_tes_code = t04.vte_tes_code
                inner join pts_tes_definition t05 on t04.vte_tes_code = t05.tde_tes_code
        where   t01.val_val_code = var_val_code
                and t05.tde_val_type = var_val_type
        group by t01.val_mkt_code
        order by t01.val_mkt_code asc;
      rcd_validation_total csr_validation_total%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_val_code := par_val_code;
      var_val_type := par_val_type;
      
      begin
         var_val_date := nvl(to_date(par_val_date, 'DD/MM/YYYY'),to_date('01/01/2000', 'DD/MM/YYYY'));
      exception
         when others then
         var_val_date := to_date('01/01/2000', 'DD/MM/YYYY');
      end;

      /*-*/
      /* Retrieve the existing validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         raise_application_error(-20000, 'Validation code (' || to_char(var_val_code) || ') does not exist');
      end if;
      
      var_found := false;
      open csr_type;
      fetch csr_type into rcd_type;
      if csr_type%found then
         var_found := true;
      end if;
      close csr_type;
      if var_found = false then
         raise_application_error(-20000, 'Validation type code ('||to_char(var_val_type)||') does not exist');
      end if;

      /*-*/
      /* Check for allocation
      /*-*/
      var_found := false;
      open csr_check_allocation;
      fetch csr_check_allocation into rcd_check_allocation;
      if csr_check_allocation%found then
         var_found := true;
      end if;
      close csr_check_allocation;
      if var_found = false then
         pipe row('<table border=1>');
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Validation Selection - ('||rcd_validation.vde_val_code||') '||rcd_validation.vde_val_title||'</td></tr>');
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-WEIGHT:bold;">NO ALLOCATION FOR THOSE PARAMETERS</td></tr>');
         pipe row('</table>');
         return;
      end if;

      /*-*/
      /* Start the report
      /*-*/
      pipe row('<table border=1>');

      /*-*/
      /* Retrieve the test panel
      /*-*/
      var_panel := false;
      var_geo_zone := -1;
      var_pet_code := -1;
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         /*-*/
         /* Panel found
         /*-*/
         var_panel := true;

         /*-*/
         /* Area change
         /*-*/
         if rcd_panel.hde_geo_zone != var_geo_zone then

            /*-*/
            /* Process area total when required
            /*-*/
            if var_geo_zone != -1 then
               pipe row('<tr><td align=center colspan=6></td></tr>');
               pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area - ('||var_geo_zone||') Sample Totals</td></tr>');
               var_tes_code := -1;
               open csr_area_total;
               loop
                  fetch csr_area_total into rcd_area_total;
                  if csr_area_total%notfound then
                     exit;
                  end if;
                  pipe row('<tr>');
                  pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
                  pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_area_total.val_mkt_code||'</td>');
                  pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_area_total.total||'</td>');
                  pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
                  pipe row('</tr>');
               end loop;
               close csr_area_total;
               pipe row('<tr><td align=center colspan=6></td></tr>');
            end if;
            var_geo_zone := rcd_panel.hde_geo_zone;

            /*-*/
            /* Output the new area heading
            /*-*/
            pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Validation Selection - ('||rcd_validation.vde_val_code||') '||rcd_validation.vde_val_title||'</td></tr>');
            pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area - ('||rcd_panel.hde_geo_zone||')</td></tr>');
            pipe row('<tr>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Name</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">MR/Qty</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Household</td>');
            pipe row('</tr>');

         end if;
        
         /*-*/
         /* Spacer between pets
         /*-*/
         if var_pet_code <> rcd_panel.pde_pet_code then
           pipe row('<tr><td align=center colspan=6></td></tr>');
         end if;
            
         /*-*/
         /* Retrieve the panel allocation
         /*-*/
         var_index := 0;
         var_tes_code := -1;
         open csr_allocation;
         loop
            fetch csr_allocation into rcd_allocation;
            if csr_allocation%notfound then
               exit;
            end if;
            
            /*-*/
            /* Output the next line
            /*-*/
            pipe row('<tr>');
            
            if var_index = 0 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_panel.pde_pet_code)||'</td>');
            else
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            end if;
            
            if var_index = 0 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.pde_pet_name||'</td>');
            elsif var_index = 1 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.size_text||'</td>');
            else
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            end if;
            
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_allocation.val_mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_allocation.tfe_fed_qnty)||'</td>');
            
            if var_index = 0 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||to_char(rcd_panel.hde_hou_code)||'</td>');
            else
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            end if;
            
            if var_index = 0 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.hde_con_fullname||'</td>');
            elsif var_index = 1 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.hde_loc_street||'</td>');
            elsif var_index = 2 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.hde_loc_town||' '||rcd_panel.hde_loc_postcode||'</td>');  
            elsif var_index = 3 and var_pet_code <> rcd_panel.pde_pet_code then
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_panel.hde_tel_number||'</td>');
            else
              pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            end if;
            pipe row('</tr>');
            
            var_index := var_index + 1;
         end loop;
         close csr_allocation;

         var_pet_code := rcd_panel.pde_pet_code;

      end loop;
      close csr_panel;

      /*-*/
      /* Panel selection
      /*-*/
      if var_panel = true then

         /*-*/
         /* Process area total when required
         /*-*/
         var_tes_code := -1;
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Area - ('||var_geo_zone||') Sample Totals</td></tr>');
         open csr_area_total;
         loop
            fetch csr_area_total into rcd_area_total;
            if csr_area_total%notfound then
               exit;
            end if;
            pipe row('<tr>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_area_total.val_mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_area_total.total||'</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('</tr>');
         end loop;
         close csr_area_total;
         pipe row('<tr><td align=center colspan=6></td></tr>');

         /*-*/
         /* Process grand total
         /*-*/
         var_tes_code := -1;
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Grand Totals</td></tr>');
         open csr_validation_total;
         loop
            fetch csr_validation_total into rcd_validation_total;
            if csr_validation_total%notfound then
               exit;
            end if;
            pipe row('<tr>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_validation_total.val_mkt_code||'</td>');
            pipe row('<td align=left colspan=1 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;">'||rcd_validation_total.total||'</td>');
            pipe row('<td align=left colspan=2 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;BACKGROUND-COLOR:#FFFFFF;COLOR:#000000;"></td>');
            pipe row('</tr>');
         end loop;
         close csr_validation_total;
      end if;

      /*-*/
      /* No Panel selection
      /*-*/
      if var_panel = false then
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-FAMILY:Arial;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#CCFFCC;COLOR:#000000;">Pet Test Selection - ('||rcd_validation.vde_val_code||') '||rcd_validation.vde_val_title||'</td></tr>');
         pipe row('<tr><td align=center colspan=6></td></tr>');
         pipe row('<tr><td align=center colspan=6 style="FONT-WEIGHT:bold;">NO PETS ON VALIDATION PANEL</td></tr>');
      end if;

      /*-*/
      /* End the report
      /*-*/
      pipe row('</table>');

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_VAL_ALLOCATION - REPORT_SELECTION - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_selection;

   /******************************************************/
   /* This procedure performs the report results routine */
   /******************************************************/
   function report_results(par_val_code in number) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_val_code number;
      var_found boolean;
      var_day_code number;
      var_wgt_bowl number;
      var_wgt_offer number;
      var_wgt_remain number;
      var_wgt_eaten number;
      var_per_eaten number;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;

      cursor csr_panel is
        select    distinct
                  t01.val_tes_code,
                  t01.val_sam_code,
                  t01.val_day_code,
                  t01.val_pet_code,
                  t08.tsa_rpt_code,
                  t03.hde_hou_code,
                  t03.hde_geo_zone,
                  t09.vty_val_type,
                  t09.vty_typ_text,
                  t11.tre_res_value as wgt_bowl,
                  t12.tre_res_value as wgt_offer,
                  t13.tre_res_value as wgt_remain,
                  decode(t04.pty_pet_type,null,'*UNKNOWN','('||t04.pty_pet_type||') '||t04.pty_typ_text) as type_text,
                  decode(t06.sva_val_code,null,'*UNKNOWN','('||t06.sva_val_code||') '||t06.sva_val_text) as size_text,
                  decode(t05.gzo_geo_zone,null,'*UNKNOWN','('||t05.gzo_geo_zone||') '||t05.gzo_zon_text) as zone_text
        from      pts_val_allocation t01
                  inner join pts_tes_definition t07 on t01.val_tes_code = t07.tde_tes_code
                  inner join pts_val_type t09 on t07.tde_val_type = t09.vty_val_type
                  inner join pts_val_pet t10 on (
                    t10.vpe_pet_code = t01.val_pet_code
                    and t10.vpe_val_type = t09.vty_val_type
                  )
                  inner join pts_val_status t11 on t10.vpe_sta_code = t11.vst_sta_code
                  inner join pts_pet_definition t02 on t01.val_pet_code = t02.pde_pet_code
                  inner join pts_tes_sample t08 on (
                    t01.val_tes_code = t08.tsa_tes_code
                    and t01.val_sam_code = t08.tsa_sam_code
                  )
                  inner join pts_tes_response t11 on (
                    t11.tre_tes_code = t01.val_tes_code
                    and t11.tre_pan_code = t01.val_pet_code
                    and t11.tre_day_code = t01.val_day_code
                    and t11.tre_sam_code = t01.val_sam_code
                    and t11.tre_que_code = t07.tde_wgt_que_bowl
                  )
                  inner join pts_tes_response t12 on (
                    t12.tre_tes_code = t01.val_tes_code
                    and t12.tre_pan_code = t01.val_pet_code
                    and t12.tre_day_code = t01.val_day_code
                    and t12.tre_sam_code = t01.val_sam_code
                    and t12.tre_que_code = t07.tde_wgt_que_offer
                  )
                  inner join pts_tes_response t13 on (
                    t13.tre_tes_code = t01.val_tes_code
                    and t13.tre_pan_code = t01.val_pet_code
                    and t13.tre_day_code = t01.val_day_code
                    and t13.tre_sam_code = t01.val_sam_code
                    and t13.tre_que_code = t07.tde_wgt_que_remain
                  )
                  left outer join pts_hou_definition t03 on t02.pde_hou_code = t03.hde_hou_code
                  left outer join pts_pet_type t04 on t02.pde_pet_type = t04.pty_pet_type
                  left outer join pts_geo_zone t05 on (
                    t03.hde_geo_zone = t05.gzo_geo_zone
                    and t05.gzo_geo_type = 40
                  )
                  left outer join (
                    select  t01.pcl_pet_code,
                            t02.sva_val_text,
                            t02.sva_val_code
                    from    pts_pet_classification t01
                            inner join pts_sys_value t02 on (
                              t01.pcl_fld_code = t02.sva_fld_code 
                              and t01.pcl_tab_code = t02.sva_tab_code
                              and t01.pcl_val_code = t02.sva_val_code
                            )
                    where   t01.pcl_tab_code = '*PET_CLA'
                            and t01.pcl_fld_code = 8
                  ) t06 on t02.pde_pet_code = t06.pcl_pet_code
        where     t01.val_val_code = var_val_code
                  and exists ( --Pet has a response for this test and day
                    select  1
                    from    pts_tes_response tre
                    where   tre.tre_tes_code = t01.val_tes_code
                            and tre.tre_pan_code = t01.val_pet_code
                            and tre.tre_day_code = t01.val_day_code
                  )
                  and t11.vst_val_flg = 1 --Pet still requires validation for this validation type
        order by  t03.hde_geo_zone asc,
                  t03.hde_hou_code asc,
                  t01.val_pet_code asc,
                  t09.vty_val_type asc,
                  t01.val_tes_code asc,
                  t01.val_day_code asc;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_val_code := par_val_code;

      /*-*/
      /* Retrieve the existing validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         raise_application_error(-20000, 'Validation code (' || to_char(var_val_code) || ') does not exist');
      end if;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '"'||'Test'||'"';
      var_output := var_output||',"'||'Pet'||'"';
      var_output := var_output||',"'||'Sample'||'"';
      var_output := var_output||',"'||'Day'||'"';
      var_output := var_output||',"'||'Weight Eaten'||'"';
      var_output := var_output||',"'||'% Eaten'||'"';
      var_output := var_output||',"'||'Test Type'||'"';
      var_output := var_output||',"'||'Household'||'"';
      var_output := var_output||',"'||'Area'||'"';
      var_output := var_output||',"'||'Pet Type'||'"';
      var_output := var_output||',"'||'Pet Size'||'"';
      pipe row(var_output);

      /*-*/
      /* Retrieve the panel
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         var_output := '"'||to_char(rcd_panel.val_tes_code)||'"';
         var_output := var_output||',"'||to_char(rcd_panel.val_pet_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.tsa_rpt_code,'"','""')||'"';
         var_output := var_output||',"'||to_char(rcd_panel.val_day_code)||'"';
         var_wgt_bowl := nvl(rcd_panel.wgt_bowl,0);
         var_wgt_offer := nvl(rcd_panel.wgt_offer,0);
         var_wgt_remain := nvl(rcd_panel.wgt_remain,0);
         var_wgt_eaten := (var_wgt_bowl + var_wgt_offer) - var_wgt_remain;
         var_per_eaten := 0;
         if var_wgt_offer != 0 then
            var_per_eaten := round((var_wgt_eaten / var_wgt_offer) * 100,0);
         end if;
         var_output := var_output||',"'||to_char(var_wgt_eaten)||'"';
         var_output := var_output||',"'||to_char(var_per_eaten)||'"';
         var_output := var_output||',"'||'('||to_char(rcd_panel.vty_val_type)||') '||replace(rcd_panel.vty_typ_text,'"','""')||'"';
         var_output := var_output||',"'||to_char(rcd_panel.hde_hou_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.zone_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.type_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.size_text,'"','""')||'"';
         
         pipe row(var_output);
      end loop;
      close csr_panel;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_VAL_FUNCTION - REPORT_RESULTS - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_results;
   
   /*********************************************************/
   /* This procedure performs the report candidates routine */
   /*********************************************************/
   function report_candidates(par_val_date in varchar2) return pts_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;
      var_day_code number;
      var_wgt_bowl number;
      var_wgt_offer number;
      var_wgt_remain number;
      var_wgt_eaten number;
      var_per_eaten number;
      var_val_date date;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_panel is
        select    distinct
                  t10.tal_tes_code,
                  t10.tal_pan_code,
                  t10.tal_day_code,
                  t10.tal_sam_code,
                  t08.tsa_rpt_code,
                  t11.tre_res_value as wgt_bowl,
                  t12.tre_res_value as wgt_offer,
                  t13.tre_res_value as wgt_remain,
                  t11.tty_tes_type,
                  t11.tty_typ_text,
                  t03.hde_hou_code,
                  t03.hde_geo_zone,
                  decode(t04.pty_pet_type,null,'*UNKNOWN','('||t04.pty_pet_type||') '||t04.pty_typ_text) as type_text,
                  decode(t06.sva_val_code,null,'*UNKNOWN','('||t06.sva_val_code||') '||t06.sva_val_text) as size_text,
                  decode(t05.gzo_geo_zone,null,'*UNKNOWN','('||t05.gzo_geo_zone||') '||t05.gzo_zon_text) as zone_text
        from      pts_tes_allocation t10
                  inner join pts_tes_definition t07 on t10.tal_tes_code = t07.tde_tes_code
                  inner join pts_tes_type t11 on t07.tde_tes_type = t11.tty_tes_type
                  inner join pts_pet_definition t02 on t10.tal_pan_code = t02.pde_pet_code
                  inner join pts_tes_sample t08 on (
                    t07.tde_tes_code = t08.tsa_tes_code
                    and t10.tal_sam_code = t08.tsa_sam_code
                  )
                  inner join pts_tes_response t11 on (
                    t11.tre_tes_code = t10.tal_tes_code
                    and t11.tre_pan_code = t10.tal_pan_code
                    and t11.tre_day_code = t10.tal_day_code
                    and t11.tre_sam_code = t10.tal_sam_code
                    and t11.tre_que_code = t07.tde_wgt_que_bowl
                  )
                  inner join pts_tes_response t12 on (
                    t12.tre_tes_code = t10.tal_tes_code
                    and t12.tre_pan_code = t10.tal_pan_code
                    and t12.tre_day_code = t10.tal_day_code
                    and t12.tre_sam_code = t10.tal_sam_code
                    and t12.tre_que_code = t07.tde_wgt_que_offer
                  )
                  inner join pts_tes_response t13 on (
                    t13.tre_tes_code = t10.tal_tes_code
                    and t13.tre_pan_code = t10.tal_pan_code
                    and t13.tre_day_code = t10.tal_day_code
                    and t13.tre_sam_code = t10.tal_sam_code
                    and t13.tre_que_code = t07.tde_wgt_que_remain
                  )
                  left outer join pts_hou_definition t03 on t02.pde_hou_code = t03.hde_hou_code
                  left outer join pts_pet_type t04 on t02.pde_pet_type = t04.pty_pet_type
                  left outer join pts_geo_zone t05 on (
                    t03.hde_geo_zone = t05.gzo_geo_zone
                    and t05.gzo_geo_type = 40
                  )
                  left outer join (
                    select  t01.pcl_pet_code,
                            t02.sva_val_text,
                            t02.sva_val_code
                    from    pts_pet_classification t01
                            inner join pts_sys_value t02 on (
                              t01.pcl_fld_code = t02.sva_fld_code 
                              and t01.pcl_tab_code = t02.sva_tab_code
                              and t01.pcl_val_code = t02.sva_val_code
                            )
                    where   t01.pcl_tab_code = '*PET_CLA'
                            and t01.pcl_fld_code = 8
                  ) t06 on t02.pde_pet_code = t06.pcl_pet_code
        where     exists ( --Pet has a response for this test and day
                    select  1
                    from    pts_tes_response tre
                    where   tre.tre_tes_code = t07.tde_tes_code
                            and tre.tre_pan_code = t02.pde_pet_code
                            and tre.tre_day_code = t10.tal_day_code
                  )
                  and t07.tde_tes_status in (3,4)
                  and t11.tty_typ_target = 1
                  and t07.tde_val_type is null --Non-validation tests
                  and t07.tde_upd_date >= var_val_date
        order by  t03.hde_geo_zone asc,
                  t03.hde_hou_code asc,
                  t10.tal_pan_code asc,
                  t11.tty_tes_type asc,
                  t10.tal_tes_code asc,
                  t10.tal_day_code asc;
      rcd_panel csr_panel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      begin
         var_val_date := nvl(to_date(par_val_date, 'DD/MM/YYYY'),sysdate-365);
      exception
         when others then
         var_val_date := sysdate-365;
      end;

      /*-*/
      /* Start the report
      /*-*/
      var_output := '"'||'Test'||'"';
      var_output := var_output||',"'||'Pet'||'"';
      var_output := var_output||',"'||'Sample'||'"';
      var_output := var_output||',"'||'Day'||'"';
      var_output := var_output||',"'||'Weight Eaten'||'"';
      var_output := var_output||',"'||'% Eaten'||'"';
      var_output := var_output||',"'||'Test Type'||'"';
      var_output := var_output||',"'||'Household'||'"';
      var_output := var_output||',"'||'Area'||'"';
      var_output := var_output||',"'||'Pet Type'||'"';
      var_output := var_output||',"'||'Pet Size'||'"';
      pipe row(var_output);

      /*-*/
      /* Retrieve the panel
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;

         var_output := '"'||to_char(rcd_panel.tal_tes_code)||'"';
         var_output := var_output||',"'||to_char(rcd_panel.tal_pan_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.tsa_rpt_code,'"','""')||'"';
         var_output := var_output||',"'||to_char(rcd_panel.tal_day_code)||'"';
         var_wgt_bowl := nvl(rcd_panel.wgt_bowl,0);
         var_wgt_offer := nvl(rcd_panel.wgt_offer,0);
         var_wgt_remain := nvl(rcd_panel.wgt_remain,0);
         var_wgt_eaten := (var_wgt_bowl + var_wgt_offer) - var_wgt_remain;
         var_per_eaten := 0;
         if var_wgt_offer != 0 then
            var_per_eaten := round((var_wgt_eaten / var_wgt_offer) * 100,0);
         end if;
         var_output := var_output||',"'||to_char(var_wgt_eaten)||'"';
         var_output := var_output||',"'||to_char(var_per_eaten)||'"';
         var_output := var_output||',"'||'('||to_char(rcd_panel.tty_tes_type)||') '||replace(rcd_panel.tty_typ_text,'"','""')||'"';
         var_output := var_output||',"'||to_char(rcd_panel.hde_hou_code)||'"';
         var_output := var_output||',"'||replace(rcd_panel.zone_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.type_text,'"','""')||'"';
         var_output := var_output||',"'||replace(rcd_panel.size_text,'"','""')||'"';
         
         pipe row(var_output);
      end loop;
      close csr_panel;

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
         raise_application_error(-20000, 'FATAL ERROR - PTS_VAL_FUNCTION - REPORT_RESULTS - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end report_candidates;

   /*****************************************************/
   /* This procedure performs the response load routine */
   /*****************************************************/
   function response_load return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_day_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_test is
          select    t02.*,
                    t03.tty_typ_target
          from      pts_val_test t01
                    inner join pts_tes_definition t02 on t01.vte_tes_code = t02.tde_tes_code
                    left outer join pts_tes_type t03 on t02.tde_tes_type = t03.tty_tes_type
          where     t01.vte_val_code = var_val_code
          order by  t01.vte_tes_seqn asc;
      rcd_test csr_test%rowtype;

      cursor csr_question is
         select t01.*,
                t02.qde_que_text
           from pts_tes_question t01,
                pts_que_definition t02
          where t01.tqu_que_code = t02.qde_que_code(+)
            and t01.tqu_tes_code = rcd_test.tde_tes_code
            and t01.tqu_day_code = var_day_code
          order by t01.tqu_dsp_seqn asc;
      rcd_question csr_question%rowtype;

      cursor csr_panel is
        select  t01.*,
                t02.*,
                case
                  when exists (
                    select  1
                    from    pts_tes_response tre
                            inner join pts_val_test vte on tre.tre_tes_code = vte.vte_tes_code
                    where   vte_val_code = var_val_code
                            and tre.tre_pan_code = t01.pde_pet_code
                  ) then '1'
                  else '0'
                end as res_status
        from    pts_pet_definition t01
                inner join pts_hou_definition t02 on t01.pde_hou_code = t02.hde_hou_code
        where   exists (
                  select  1
                  from    pts_val_allocation val
                  where   val.val_val_code = var_val_code
                          and val.val_pet_code = t01.pde_pet_code
                )
        order by t02.hde_geo_zone asc,
                t01.pde_pet_code asc;
      rcd_panel csr_panel%rowtype;

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
      if var_action != '*LODRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if rcd_validation.vde_val_status != 2 and
         rcd_validation.vde_val_status != 3 and
         rcd_validation.vde_val_status != 4 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(var_val_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the validation xml
      /*-*/
      pipe row(pts_xml_object('<VAL VALTXT="('||to_char(rcd_validation.vde_val_code)||') '||pts_to_xml(rcd_validation.vde_val_title)||'"/>'));

      /*-*/
      /* Pipe the test response meta xml
      /*-*/
      open csr_test;
      loop
         fetch csr_test into rcd_test;
         if csr_test%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_test.tde_tes_code)||') '||pts_to_xml(rcd_test.tde_tes_title)||'" TESSAM="'||to_char(rcd_test.tde_tes_sam_count)||'" TESCDE="'||to_char(rcd_test.tde_tes_code)||'"/>'));

         if rcd_test.tty_typ_target != 1 then
            pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_test.tde_tes_code) || ') target must be *PET - response update not allowed');
            exit;
         end if;
  
         for idx in 1..rcd_test.tde_tes_day_count loop
            var_day_code := idx;
            pipe row(pts_xml_object('<METD DAYCDE="'||to_char(var_day_code)||'" DAYTXT="Day '||to_char(var_day_code)||'"/>'));
            open csr_question;
            loop
               fetch csr_question into rcd_question;
               if csr_question%notfound then
                  exit;
               end if;
               pipe row(pts_xml_object('<METQ DAYCDE="'||to_char(var_day_code)||'" QUECDE="'||to_char(rcd_question.tqu_que_code)||'" QUETXT="Que '||to_char(rcd_question.tqu_dsp_seqn)||'" QUETYP="'||pts_to_xml(rcd_question.tqu_que_type)||'" QUENAM="'||pts_to_xml(rcd_question.qde_que_text)||'"/>'));
            end loop;
            close csr_question;
         end loop;
      end loop;
      close csr_test;
      
      /*-*/
      /* Pipe the validation panel data xml
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PET PETCDE="'||to_char(rcd_panel.pde_pet_code)||'" PETTXT="'||pts_to_xml('('||to_char(rcd_panel.pde_pet_code)||') '||rcd_panel.pde_pet_name||' - Household ('||rcd_panel.hde_hou_code||') '||rcd_panel.hde_con_fullname||', '||rcd_panel.hde_loc_street||', '||rcd_panel.hde_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel.res_status)||'"/>'));
      end loop;
      close csr_panel;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RESPONSE_LOAD - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end response_load;

   /*****************************************************/
   /* This procedure performs the response list routine */
   /*****************************************************/
   function response_list return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_panel is
        select  t01.*,
                t02.*,
                case
                  when exists (
                    select  1
                    from    pts_tes_response tre
                            inner join pts_val_test vte on tre.tre_tes_code = vte.vte_tes_code
                    where   vte_val_code = var_val_code
                            and tre.tre_pan_code = t01.pde_pet_code
                  ) then '1'
                  else '0'
                end as res_status
        from    pts_pet_definition t01
                inner join pts_hou_definition t02 on t01.pde_hou_code = t02.hde_hou_code
        where   exists (
                  select  1
                  from    pts_val_allocation val
                  where   val.val_val_code = var_val_code
                          and val.val_pet_code = t01.pde_pet_code
                )
        order by t02.hde_geo_zone asc,
                t01.pde_pet_code asc;
      rcd_panel csr_panel%rowtype;

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
      if var_action != '*LSTRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;
      xmlDom.freeDocument(obj_xml_document);

      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if rcd_validation.vde_val_status != 2 and
         rcd_validation.vde_val_status != 3 and
         rcd_validation.vde_val_status != 4 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(var_val_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));

      /*-*/
      /* Pipe the test panel data xml
      /*-*/
      open csr_panel;
      loop
         fetch csr_panel into rcd_panel;
         if csr_panel%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<PET PETCDE="'||to_char(rcd_panel.pde_pet_code)||'" PETTXT="'||pts_to_xml('('||to_char(rcd_panel.pde_pet_code)||') '||rcd_panel.pde_pet_name||' - Household ('||rcd_panel.hde_hou_code||') '||rcd_panel.hde_con_fullname||', '||rcd_panel.hde_loc_street||', '||rcd_panel.hde_loc_town)||'" RESSTS="'||pts_to_xml(rcd_panel.res_status)||'"/>'));
      end loop;
      close csr_panel;

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RESPONSE_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end response_list;

   /*********************************************************/
   /* This procedure performs the response retrieve routine */
   /*********************************************************/
   function response_retrieve return pts_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_pts_request xmlDom.domNode;
      var_action varchar2(32);
      var_val_code number;
      var_pet_code number;
      var_tes_code number;
      var_que_code number;
      var_seq_numb number;
      var_day_code number;
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_test is
        select    t02.*,
                  t03.tty_typ_target
        from      pts_val_test t01
                  inner join pts_tes_definition t02 on t01.vte_tes_code = t02.tde_tes_code
                  left outer join pts_tes_type t03 on t02.tde_tes_type = t03.tty_tes_type
        where     t01.vte_val_code = var_val_code
                  and exists (
                    select  1
                    from    pts_val_allocation val
                    where   val.val_val_code = var_val_code
                            and val.val_tes_code = t02.tde_tes_code
                            and val.val_pet_code = var_pet_code
                  )
        order by  t01.vte_tes_seqn asc;
      rcd_test csr_test%rowtype;

      cursor csr_question is
         select t01.*,
                t02.qde_que_text
           from pts_tes_question t01,
                pts_que_definition t02
          where t01.tqu_que_code = t02.qde_que_code(+)
            and t01.tqu_tes_code = rcd_test.tde_tes_code
            and t01.tqu_day_code = var_day_code
          order by t01.tqu_dsp_seqn asc;
      rcd_question csr_question%rowtype;

      cursor csr_panel is
        select  t01.*,
                t02.*,
                case
                  when exists (
                    select  1
                    from    pts_tes_response tre
                            inner join pts_val_test vte on tre.tre_tes_code = vte.vte_tes_code
                    where   vte_val_code = var_val_code
                            and tre.tre_pan_code = t01.pde_pet_code
                  ) then '1'
                  else '0'
                end as res_status
        from    pts_pet_definition t01
                inner join pts_hou_definition t02 on t01.pde_hou_code = t02.hde_hou_code
        where   exists (
                  select  1
                  from    pts_val_allocation val
                  where   val.val_val_code = var_val_code
                          and val.val_pet_code = t01.pde_pet_code
                )
        order by t02.hde_geo_zone asc,
                t01.pde_pet_code asc;
      rcd_panel csr_panel%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_val_allocation t01
          where t01.val_tes_code = var_tes_code
            and t01.val_pet_code = var_pet_code
            and t01.val_day_code = var_day_code
            and t01.val_val_code = var_val_code
          order by t01.val_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_response is
         select t01.*,
                nvl(t02.val_seq_numb,0) as val_seq_numb
           from pts_tes_response t01
                left outer join pts_val_allocation t02 on (
                  t01.tre_tes_code = t02.val_tes_code
                  and t01.tre_pan_code = t02.val_pet_code
                  and t01.tre_day_code = t02.val_day_code
                  and t01.tre_sam_code = t02.val_sam_code
                  and t02.val_val_code = var_val_code
                )
          where t01.tre_tes_code = var_tes_code
            and t01.tre_pan_code = var_pet_code
            and t01.tre_day_code = var_day_code
          order by t01.tre_que_code asc,
                   val_seq_numb asc;
      rcd_response csr_response%rowtype;
       
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
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      var_pet_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETCDE'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELRES' then
         pts_gen_function.add_mesg_data('Invalid request action');
         return;
      end if;

      /*-*/
      /* Retrieve the validation
      /*-*/
      var_found := false;
      open csr_validation;
      fetch csr_validation into rcd_validation;
      if csr_validation%found then
         var_found := true;
      end if;
      close csr_validation;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if rcd_validation.vde_val_status != 2 and
         rcd_validation.vde_val_status != 3 and
         rcd_validation.vde_val_status != 4 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(var_val_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(pts_xml_object('<?xml version="1.0" encoding="UTF-8"?><PTS_RESPONSE>'));
      
      /*-*/
      /* Pipe the test response meta xml
      /*-*/
      open csr_test;
      loop
         fetch csr_test into rcd_test;
         if csr_test%notfound then
            exit;
         end if;
         pipe row(pts_xml_object('<TEST TESTXT="('||to_char(rcd_test.tde_tes_code)||') '||pts_to_xml(rcd_test.tde_tes_title)||'" TESSAM="'||to_char(rcd_test.tde_tes_sam_count)||'" TESCDE="'||to_char(rcd_test.tde_tes_code)||'"/>'));

         if rcd_test.tty_typ_target != 1 then
            pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_test.tde_tes_code) || ') target must be *PET - response update not allowed');
            exit;
         end if;
         var_tes_code := rcd_test.tde_tes_code;
  
         for idx in 1..rcd_test.tde_tes_day_count loop
            var_day_code := idx;
            pipe row(pts_xml_object('<METD DAYCDE="'||to_char(var_day_code)||'" DAYTXT="Day '||to_char(var_day_code)||'"/>'));
            open csr_question;
            loop
               fetch csr_question into rcd_question;
               if csr_question%notfound then
                  exit;
               end if;
               pipe row(pts_xml_object('<METQ DAYCDE="'||to_char(var_day_code)||'" QUECDE="'||to_char(rcd_question.tqu_que_code)||'" QUETXT="Que '||to_char(rcd_question.tqu_dsp_seqn)||'" QUETYP="'||pts_to_xml(rcd_question.tqu_que_type)||'" QUENAM="'||pts_to_xml(rcd_question.qde_que_text)||'"/>'));
            end loop;
            close csr_question;
            
            var_seq_numb := 0;
            open csr_allocation;
            loop
               fetch csr_allocation into rcd_allocation;
               if csr_allocation%notfound then
                  exit;
               end if;
               var_seq_numb := var_seq_numb + 1;
               pipe row(pts_xml_object('<RESD DAYCDE="'||to_char(var_day_code)||'" RESSEQ="'||to_char(var_seq_numb)||'" MKTCDE="'||pts_to_xml(rcd_allocation.val_mkt_code)||'"/>'));
            end loop;
            close csr_allocation;
            var_que_code := 0;
            var_seq_numb := 0;
            open csr_response;
            loop
               fetch csr_response into rcd_response;
               if csr_response%notfound then
                  exit;
               end if;
               if var_que_code != rcd_response.tre_que_code then
                  var_que_code := rcd_response.tre_que_code;
                  var_seq_numb := 0;
               end if;
               var_seq_numb := var_seq_numb + 1;
               pipe row(pts_xml_object('<RESQ DAYCDE="'||to_char(var_day_code)||'" QUECDE="'||to_char(rcd_response.tre_que_code)||'" RESSEQ="'||to_char(var_seq_numb)||'" RESVAL="'||to_char(rcd_response.tre_res_value)||'"/>'));
            end loop;
            close csr_response;
         end loop;
      end loop;
      close csr_test;
      
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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - RESPONSE_RETRIEVE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end response_retrieve;

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
      obj_tes_list xmlDom.domNodeList;
      obj_tes_node xmlDom.domNode;
      obj_res_list xmlDom.domNodeList;
      obj_res_node xmlDom.domNode;
      var_action varchar2(32);
      var_sam_count number;
      var_wrk_count number;
      var_val_code number;
      var_tes_code number;
      var_pet_code number;
      var_day_code number;
      var_mkt_code varchar2(10);
      var_sam_cod1 number;
      var_sam_cod2 number;
      var_seq_numb number;
      var_que_code number;
      var_res_value number;
      var_wgt_bowl1 number;
      var_wgt_offer1 number;
      var_wgt_remain1 number;
      var_wgt_bowl2 number;
      var_wgt_offer2 number;
      var_wgt_remain2 number;
      var_typ_code varchar2(10 char);
      var_all_date date;
      var_found boolean;
      var_message boolean;
      var_exists boolean;
      var_member boolean;
      type typ_mktcde is table of varchar2(10) index by binary_integer;
      tbl_mktcde typ_mktcde;
      type rcd_alcdat is record(day_code number,
                                seq_numb number,
                                sam_code number,
                                mkt_code varchar2(10));
      type typ_alcdat is table of rcd_alcdat index by binary_integer;
      tbl_alcdat typ_alcdat;
      rcd_pts_tes_statistic pts_tes_statistic%rowtype;
      rcd_pts_val_allocation pts_val_allocation%rowtype;
      rcd_pts_tes_response pts_tes_response%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validation is
        select  t01.*
        from    pts_val_definition t01
        where   t01.vde_val_code = var_val_code
        for     update nowait;
      rcd_validation csr_validation%rowtype;
      
      cursor csr_retrieve is
         select t01.*
           from pts_tes_definition t01
          where t01.tde_tes_code = var_tes_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

      cursor csr_target is
         select t01.*
           from pts_tes_type t01
          where t01.tty_tes_type = rcd_retrieve.tde_tes_type;
      rcd_target csr_target%rowtype;

      cursor csr_count is
         select count(*) as sam_count
           from pts_tes_sample t01
          where t01.tsa_tes_code = var_tes_code;
      rcd_count csr_count%rowtype;

      cursor csr_panel is
         select t01.*
           from pts_val_allocation t01
          where t01.val_tes_code = var_tes_code
            and t01.val_pet_code = var_pet_code
            and t01.val_val_code = var_val_code;
      rcd_panel csr_panel%rowtype;

      cursor csr_pet is
         select t01.*,
                t02.*
           from pts_pet_definition t01,
                pts_hou_definition t02
          where t01.pde_hou_code = t02.hde_hou_code
            and t01.pde_pet_code = var_pet_code;
      rcd_pet csr_pet%rowtype;

      cursor csr_pet_stat is
         select t01.pde_pet_type,
                count(*) as typ_count
           from pts_pet_definition t01
          where t01.pde_hou_code = rcd_pet.pde_hou_code
            and not(t01.pde_pet_status in (4,9))
          group by t01.pde_pet_type;
      rcd_pet_stat csr_pet_stat%rowtype;

      cursor csr_allocation is
         select t01.*
           from pts_val_allocation t01
          where t01.val_tes_code = var_tes_code
            and t01.val_pet_code = var_pet_code
            and t01.val_val_code = var_val_code
          order by t01.val_day_code asc,
                   t01.val_seq_numb asc;
      rcd_allocation csr_allocation%rowtype;

      cursor csr_sample is
         select t01.*
           from pts_tes_sample t01
          where t01.tsa_tes_code = var_tes_code
            and (t01.tsa_mkt_code = var_mkt_code or t01.tsa_mkt_acde = var_mkt_code);
      rcd_sample csr_sample%rowtype;

      cursor csr_question is
         select t01.*
           from pts_que_definition t01
          where t01.qde_que_code  = var_que_code;
      rcd_question csr_question%rowtype;

      cursor csr_response is
         select t01.*
           from pts_que_response t01
          where t01.qre_que_code = var_que_code
            and t01.qre_res_code = var_res_value;
      rcd_response csr_response%rowtype;

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
      var_val_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@VALCDE'));
      var_pet_code := pts_to_number(xslProcessor.valueOf(obj_pts_request,'@PETCDE'));
      if var_val_code is null then
         pts_gen_function.add_mesg_data('Validation code ('||xslProcessor.valueOf(obj_pts_request,'@VALCDE')||') must be a number');
      end if;
      if var_pet_code is null then
         pts_gen_function.add_mesg_data('Pet code ('||xslProcessor.valueOf(obj_pts_request,'@PETCDE')||') must be a number');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve and lock the existing validation
      /*-*/
      var_found := false;
      begin
         open csr_validation;
         fetch csr_validation into rcd_validation;
         if csr_validation%found then
            var_found := true;
         end if;
         close csr_validation;
      exception
         when others then
            pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') is currently locked');
            return;
      end;
      if var_found = false then
         pts_gen_function.add_mesg_data('Validation ('||to_char(var_val_code)||') does not exist');
      end if;
      if rcd_validation.vde_val_status != 2 and
         rcd_validation.vde_val_status != 3 and
         rcd_validation.vde_val_status != 4 then
         pts_gen_function.add_mesg_data('Validation code (' || to_char(var_val_code) || ') must be status Allocation Completed, Results Entered or Closed - response update not allowed');
      end if;
      if pts_gen_function.get_mesg_count != 0 then
         rollback;
         return;
      end if;
      
      /*-*/
      /* Update the validation definition
      /*-*/
      update pts_val_definition
         set vde_val_status = 3
       where vde_val_code = rcd_validation.vde_val_code;

      obj_tes_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/TEST');
      for idt in 0..xmlDom.getLength(obj_tes_list)-1 loop
        obj_tes_node := xmlDom.item(obj_tes_list,idt);
        var_tes_code := upper(xslProcessor.valueOf(obj_tes_node,'@TESCDE'));
        var_all_date := sysdate;
        var_found := false;
        begin
           open csr_retrieve;
           fetch csr_retrieve into rcd_retrieve;
           if csr_retrieve%found then
              var_found := true;
           end if;
           close csr_retrieve;
        exception
           when others then
              pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') is currently locked');
              return;
        end;
        if var_found = false then
           pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||') does not exist');
        end if;
        if rcd_retrieve.tde_tes_status = 9 then
           pts_gen_function.add_mesg_data('Test code (' || to_char(var_tes_code) || ') must not be Cancelled - response update not allowed');
        end if;
        if pts_gen_function.get_mesg_count != 0 then
           rollback;
           return;
        end if;
  
        /*-*/
        /* Retrieve the test target
        /*-*/
        var_found := false;
        open csr_target;
        fetch csr_target into rcd_target;
        if csr_target%found then
           var_found := true;
        end if;
        close csr_target;
        if var_found = false then
           pts_gen_function.add_mesg_data('Test type ('||to_char(rcd_retrieve.tde_tes_type)||') does not exist');
        end if;
        if rcd_target.tty_typ_target != 1 then
           pts_gen_function.add_mesg_data('Test code (' || to_char(rcd_retrieve.tde_tes_code) || ') target must be *PET - response update not allowed');
        end if;
        if pts_gen_function.get_mesg_count != 0 then
           rollback;
           return;
        end if;
  
        /*-*/
        /* Retrieve the test sample count
        /*-*/
        var_sam_count := 0;
        open csr_count;
        fetch csr_count into rcd_count;
        if csr_count%found then
           var_sam_count := rcd_count.sam_count;
        end if;
        close csr_count;
  
        /*-*/
        /* Update the test definition
        /*-*/
        update pts_tes_definition
           set tde_tes_status = 3
         where tde_tes_code = rcd_retrieve.tde_tes_code;
  
        /*-*/
        /* Retrieve the existing panel member
        /* **notes** 1. Create a recruited panel when not found regardless of status
        /*-*/
        var_found := false;
        var_member := false;
        open csr_panel;
        fetch csr_panel into rcd_panel;
        if csr_panel%found then
           var_found := true;
           var_member := true;
        end if;
        close csr_panel;
        if var_found = false then
           open csr_pet;
           fetch csr_pet into rcd_pet;
           if csr_pet%notfound then
              pts_gen_function.add_mesg_data('Pet ('||to_char(var_pet_code)||') does not exist');
           else
              open csr_pet_stat;
              loop
                 fetch csr_pet_stat into rcd_pet_stat;
                 if csr_pet_stat%notfound then
                    exit;
                 end if;
                 rcd_pts_tes_statistic.tst_tes_code := var_tes_code;
                 rcd_pts_tes_statistic.tst_pan_code := var_pet_code;
                 rcd_pts_tes_statistic.tst_pet_type := rcd_pet_stat.pde_pet_type;
                 rcd_pts_tes_statistic.tst_pet_count := rcd_pet_stat.typ_count;
                 insert into pts_tes_statistic values rcd_pts_tes_statistic;
              end loop;
              close csr_pet_stat;
           end if;
           close csr_pet;
        end if;
        if pts_gen_function.get_mesg_count != 0 then
           rollback;
           return;
        end if;
  
        /*-*/
        /* Save the existing allocation data
        /*-*/
        tbl_alcdat.delete;
        if var_member = true then
           open csr_allocation;
           loop
              fetch csr_allocation into rcd_allocation;
              if csr_allocation%notfound then
                 exit;
              end if;
              tbl_alcdat(tbl_alcdat.count+1).day_code := rcd_allocation.val_day_code;
              tbl_alcdat(tbl_alcdat.count).seq_numb := rcd_allocation.val_seq_numb;
              tbl_alcdat(tbl_alcdat.count).sam_code := rcd_allocation.val_sam_code;
              tbl_alcdat(tbl_alcdat.count).mkt_code := rcd_allocation.val_mkt_code;
              var_all_date := rcd_allocation.val_all_date;
            end loop;
            close csr_allocation;
        end if;
  
        /*-*/
        /* Clear the existing response data
        /*-*/
        delete from pts_val_allocation
         where val_tes_code = var_tes_code
           and val_pet_code = var_pet_code
           and val_val_code = var_val_code;
        delete from pts_tes_response
         where tre_tes_code = var_tes_code
           and tre_pan_code = var_pet_code;
  
        /*-*/
        /* Retrieve and insert the response data
        /* **notes** 1. Update the allocation when supplied
        /*           2. Use current allocation when not supplied
        /*           3. Perform the weight validation when required
        /*-*/
        tbl_mktcde.delete;
        var_day_code := null;
        var_sam_cod1 := null;
        var_sam_cod2 := null;
        var_wrk_count := 0;
        obj_res_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/PTS_REQUEST/TEST[@TESCDE="'||to_char(var_tes_code)||'"]/RESP');
        for idx in 0..xmlDom.getLength(obj_res_list)-1 loop
           obj_res_node := xmlDom.item(obj_res_list,idx);
           var_typ_code := upper(xslProcessor.valueOf(obj_res_node,'@TYPCDE'));
           if var_typ_code = 'D' then
              if rcd_retrieve.tde_wgt_que_calc = '1' then
                 if not(var_day_code is null) then
                    if ((var_wgt_bowl1 + var_wgt_offer1) - var_wgt_remain1) > var_wgt_offer1 then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code one weight eaten is greater than offered');
                    end if;
                    if var_wgt_remain1 > (var_wgt_bowl1 + var_wgt_offer1) then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code one weight remaining is greater than offered');
                    end if;
                    if ((var_wgt_bowl2 + var_wgt_offer2) - var_wgt_remain2) > var_wgt_offer2 then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code two weight eaten is greater than offered');
                    end if;
                    if var_wgt_remain2 > (var_wgt_bowl2 + var_wgt_offer2) then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code two weight remaining is greater than offered');
                    end if;
                 end if;
                 var_wgt_bowl1 := 0;
                 var_wgt_offer1 := 0;
                 var_wgt_remain1 := 0;
                 var_wgt_bowl2 := 0;
                 var_wgt_offer2 := 0;
                 var_wgt_remain2 := 0;
              end if;
              var_message := false;
              var_day_code := pts_to_number(xslProcessor.valueOf(obj_res_node,'@DAYCDE'));
              var_sam_cod1 := null;
              var_sam_cod2 := null;
              if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                 tbl_mktcde.delete;
              end if;
              var_mkt_code := upper(trim(xslProcessor.valueOf(obj_res_node,'@MKTCD1')));
              if var_mkt_code is null then
                 var_seq_numb := var_day_code;
                 if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                    var_seq_numb := 1;
                 end if;
                 var_exists := false;
                 for idx in 1..tbl_alcdat.count loop
                    if tbl_alcdat(idx).day_code = var_day_code and
                       tbl_alcdat(idx).seq_numb = var_seq_numb then
                       var_sam_cod1 := tbl_alcdat(idx).sam_code;
                       var_mkt_code := tbl_alcdat(idx).mkt_code;
                       var_exists := true;
                       exit;
                    end if;
                 end loop;
                 if var_exists = false then
                    pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') sample allocation does not exist for this test member - market research code one must be specified');
                    var_message := true;
                 else
                    var_exists := false;
                    for idx in 1..tbl_mktcde.count loop
                       if tbl_mktcde(idx) = var_mkt_code then
                          var_exists := true;
                          exit;
                       end if;
                    end loop;
                    if var_exists = true then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                       var_message := true;
                    else
                       tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                    end if;
                 end if;
              else
                 var_exists := false;
                 for idx in 1..tbl_mktcde.count loop
                    if tbl_mktcde(idx) = var_mkt_code then
                       var_exists := true;
                       exit;
                    end if;
                 end loop;
                  if var_exists = true then
                     pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                     var_message := true;
                  else
                     tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                     open csr_sample;
                     fetch csr_sample into rcd_sample;
                     if csr_sample%notfound then
                        pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                        var_message := true;
                     else
                        var_sam_cod1 := rcd_sample.tsa_sam_code;
                        var_seq_numb := var_day_code;
                        if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                           var_seq_numb := 1;
                        end if;
                        if var_member = true then
                           var_exists := false;
                           for idx in 1..tbl_alcdat.count loop
                              if tbl_alcdat(idx).sam_code = var_sam_cod1 then
                                 var_exists := true;
                                 exit;
                              end if;
                           end loop;
                           if var_exists = false then
                              pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') is not allocated for this test member');
                              var_message := true;
                           end if;
                        end if;
                     end if;
                     close csr_sample;
                  end if;
              end if;
              if var_message = false then
                 rcd_pts_val_allocation.val_val_code := var_val_code;
                 rcd_pts_val_allocation.val_tes_code := var_tes_code;
                 rcd_pts_val_allocation.val_pet_code := var_pet_code;
                 rcd_pts_val_allocation.val_day_code := var_day_code;
                 rcd_pts_val_allocation.val_sam_code := var_sam_cod1;
                 rcd_pts_val_allocation.val_seq_numb := var_seq_numb;
                 rcd_pts_val_allocation.val_mkt_code := var_mkt_code;
                 rcd_pts_val_allocation.val_all_date := var_all_date;
                 insert into pts_val_allocation values rcd_pts_val_allocation;
              end if;
              if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                 var_mkt_code := upper(trim(xslProcessor.valueOf(obj_res_node,'@MKTCD2')));
                 if var_mkt_code is null then
                    var_seq_numb := var_day_code;
                    if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                       var_seq_numb := 2;
                    end if;
                    var_exists := false;
                    for idx in 1..tbl_alcdat.count loop
                       if tbl_alcdat(idx).day_code = var_day_code and
                          tbl_alcdat(idx).seq_numb = var_seq_numb then
                          var_sam_cod2 := tbl_alcdat(idx).sam_code;
                          var_mkt_code := tbl_alcdat(idx).mkt_code;
                          var_exists := true;
                          exit;
                       end if;
                    end loop;
                    if var_exists = false then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') sample allocation does not exist for this test member - market research code two must be specified');
                       var_message := true;
                    else
                       var_exists := false;
                       for idx in 1..tbl_mktcde.count loop
                          if tbl_mktcde(idx) = var_mkt_code then
                             var_exists := true;
                             exit;
                          end if;
                       end loop;
                       if var_exists = true then
                          pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                          var_message := true;
                       else
                          tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                       end if;
                    end if;
                 else
                    var_exists := false;
                    for idx in 1..tbl_mktcde.count loop
                       if tbl_mktcde(idx) = var_mkt_code then
                          var_exists := true;
                          exit;
                       end if;
                    end loop;
                    if var_exists = true then
                       pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') already used');
                       var_message := true;
                    else
                       tbl_mktcde(tbl_mktcde.count+1) := var_mkt_code;
                       open csr_sample;
                       fetch csr_sample into rcd_sample;
                       if csr_sample%notfound then
                          pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') does not exist for this test');
                          var_message := true;
                       else
                          var_sam_cod2 := rcd_sample.tsa_sam_code;
                          var_seq_numb := var_day_code;
                          if upper(rcd_target.tty_alc_proc) = 'DIFFERENCE' then
                             var_seq_numb := 2;
                          end if;
                          if var_member = true then
                             var_exists := false;
                             for idx in 1..tbl_alcdat.count loop
                                if tbl_alcdat(idx).sam_code = var_sam_cod1 then
                                   var_exists := true;
                                   exit;
                                end if;
                             end loop;
                             if var_exists = false then
                                pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code ('||var_mkt_code||') is not allocated for this test member');
                                var_message := true;
                             end if;
                          end if;
                       end if;
                       close csr_sample;
                    end if;
                 end if;
                 if var_message = false then
                    rcd_pts_val_allocation.val_val_code := var_val_code;
                    rcd_pts_val_allocation.val_tes_code := var_tes_code;
                    rcd_pts_val_allocation.val_pet_code := var_pet_code;
                    rcd_pts_val_allocation.val_day_code := var_day_code;
                    rcd_pts_val_allocation.val_sam_code := var_sam_cod2;
                    rcd_pts_val_allocation.val_seq_numb := var_seq_numb;
                    rcd_pts_val_allocation.val_mkt_code := var_mkt_code;
                    rcd_pts_val_allocation.val_all_date := var_all_date;
                    insert into pts_val_allocation values rcd_pts_val_allocation;
                 end if;
              end if;
           end if;
           if var_typ_code = 'Q' then
              if not(xslProcessor.valueOf(obj_res_node,'@RESVAL') is null) then
                 var_que_code := pts_to_number(xslProcessor.valueOf(obj_res_node,'@QUECDE'));
                 var_res_value := pts_to_number(xslProcessor.valueOf(obj_res_node,'@RESVAL'));
                 open csr_question;
                 fetch csr_question into rcd_question;
                 if csr_question%notfound then
                    pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') question ('||to_char(var_que_code)||') does not exist for this test');
                    var_message := true;
                 else
                    if rcd_retrieve.tde_wgt_que_calc = '1' then
                       if xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '1' then
                          if var_que_code = rcd_retrieve.tde_wgt_que_bowl then
                             var_wgt_bowl1 := nvl(var_res_value,0);
                          elsif var_que_code = rcd_retrieve.tde_wgt_que_offer then
                             var_wgt_offer1 := nvl(var_res_value,0);
                          elsif var_que_code = rcd_retrieve.tde_wgt_que_remain then
                             var_wgt_remain1 := nvl(var_res_value,0);
                          end if;
                       elsif xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '2' then
                          if var_que_code = rcd_retrieve.tde_wgt_que_bowl then
                             var_wgt_bowl2 := nvl(var_res_value,0);
                          elsif var_que_code = rcd_retrieve.tde_wgt_que_offer then
                             var_wgt_offer2 := nvl(var_res_value,0);
                          elsif var_que_code = rcd_retrieve.tde_wgt_que_remain then
                             var_wgt_remain2 := nvl(var_res_value,0);
                          end if;
                       end if;
                    end if;
                    if rcd_question.qde_rsp_type = 1 then
                       open csr_response;
                       fetch csr_response into rcd_response;
                       if csr_response%notfound then
                          pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') question ('||to_char(var_que_code)||') response value ('||to_char(var_res_value)||') does not exist for question');
                          var_message := true;
                       end if;
                       close csr_response;
                    elsif rcd_question.qde_rsp_type = 2 then
                       if var_res_value < rcd_question.qde_rsp_str_range or var_res_value > rcd_question.qde_rsp_end_range then
                          pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') question ('||to_char(var_que_code)||') response value ('||to_char(var_res_value)||') is not within the defined range ('||to_char(rcd_question.qde_rsp_str_range)||' to '||to_char(rcd_question.qde_rsp_end_range)||')');
                          var_message := true;
                       end if;
                    else
                       pts_gen_function.add_mesg_data('Question has invalid response type');
                       var_message := true;
                    end if;
                 end if;
                 close csr_question;
                 if var_message = false then
                    rcd_pts_tes_response.tre_tes_code := var_tes_code;
                    rcd_pts_tes_response.tre_pan_code := var_pet_code;
                    rcd_pts_tes_response.tre_day_code := var_day_code;
                    rcd_pts_tes_response.tre_que_code := var_que_code;
                    rcd_pts_tes_response.tre_sam_code := 0;
                    if xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '1' then
                       rcd_pts_tes_response.tre_sam_code := var_sam_cod1;
                    elsif xslProcessor.valueOf(obj_res_node,'@RESSEQ') = '2' then
                       rcd_pts_tes_response.tre_sam_code := var_sam_cod2;
                    end if;
                    rcd_pts_tes_response.tre_res_value := var_res_value;
                    insert into pts_tes_response values rcd_pts_tes_response;
                 end if;
              end if;
           end if;
        end loop;
        if rcd_retrieve.tde_wgt_que_calc = '1' then
           if not(var_day_code is null) then
              if ((var_wgt_bowl1 + var_wgt_offer1) - var_wgt_remain1) > var_wgt_offer1 then
                 pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code one weight eaten is greater than offered');
              end if;
              if var_wgt_remain1 > (var_wgt_bowl1 + var_wgt_offer1) then
                 pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code one weight remaining is greater than offered');
              end if;
              if ((var_wgt_bowl2 + var_wgt_offer2) - var_wgt_remain2) > var_wgt_offer2 then
                 pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code two weight eaten is greater than offered');
              end if;
              if var_wgt_remain2 > (var_wgt_bowl2 + var_wgt_offer2) then
                 pts_gen_function.add_mesg_data('Test ('||to_char(var_tes_code)||'), Day ('||to_char(var_day_code)||') market research code two weight remaining is greater than offered');
              end if;
           end if;
        end if;
        if pts_gen_function.get_mesg_count != 0 then
           rollback;
           return;
        end if;
      end loop;

      /*-*/
      /* Free the XML document
      /*-*/
      xmlDom.freeDocument(obj_xml_document);

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
         pts_gen_function.add_mesg_data('FATAL ERROR - PTS_VAL_FUNCTION - UPDATE_RESPONSE - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_response;

end pts_val_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_val_function for pts_app.pts_val_function;
grant execute on pts_app.pts_val_function to public;
