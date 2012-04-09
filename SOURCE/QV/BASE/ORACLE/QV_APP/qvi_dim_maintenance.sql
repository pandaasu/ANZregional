/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_dim_maintenance as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_dim_maintenance
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Dimension Maintenance

    This package contain the dimension maintenance functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_list return qvi_xml_type pipelined;
   function retrieve_data return qvi_xml_type pipelined;
   procedure update_data(par_user in varchar2);
   procedure delete_data;

end qvi_dim_maintenance;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_dim_maintenance as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select list routine */
   /***************************************************/
   function select_list return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_str_code varchar2(32);
      var_end_code varchar2(32);
      var_output varchar2(2000 char);
      var_pag_size number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_slct is
         select t01.*
           from (select t01.qdd_dim_code,
                        t01.qdd_dim_name,
                        decode(t01.qdd_dim_status,'0','Inactive','1','Active','*UNKNOWN') as qdd_dim_status,
                        decode(t01.qdd_lod_status,'0','Empty','1','Loading','2','Loaded','*UNKNOWN') as qdd_lod_status,
                        decode(t01.qdd_lod_status,'0','Empty',to_char(t01.qdd_str_date, 'yyyy/mm/dd hh24:mi:ss')) as qdd_str_date,
                        decode(t01.qdd_lod_status,'0','Empty','1','In Progress',to_char(t01.qdd_end_date, 'yyyy/mm/dd hh24:mi:ss')) as qdd_end_date
                   from qvi_dim_defn t01
                  where (var_str_code is null or t01.qdd_dim_code >= var_str_code)
                  order by t01.qdd_dim_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_next is
         select t01.*
           from (select t01.qdd_dim_code,
                        t01.qdd_dim_name,
                        decode(t01.qdd_dim_status,'0','Inactive','1','Active','*UNKNOWN') as qdd_dim_status,
                        decode(t01.qdd_lod_status,'0','Empty','1','Loading','2','Loaded','*UNKNOWN') as qdd_lod_status,
                        decode(t01.qdd_lod_status,'0','Empty',to_char(t01.qdd_str_date, 'yyyy/mm/dd hh24:mi:ss')) as qdd_str_date,
                        decode(t01.qdd_lod_status,'0','Empty','1','In Progress',to_char(t01.qdd_end_date, 'yyyy/mm/dd hh24:mi:ss')) as qdd_end_date
                   from qvi_dim_defn t01
                  where (var_action = '*NXTDEF' and (var_end_code is null or t01.qdd_dim_code > var_end_code)) or
                        (var_action = '*PRVDEF')
                  order by t01.qdd_dim_code asc) t01
          where rownum <= var_pag_size;

      cursor csr_prev is
         select t01.*
           from (select t01.qdd_dim_code,
                        t01.qdd_dim_name,
                        decode(t01.qdd_dim_status,'0','Inactive','1','Active','*UNKNOWN') as qdd_dim_status,
                        decode(t01.qdd_lod_status,'0','Empty','1','Loading','2','Loaded','*UNKNOWN') as qdd_lod_status,
                        decode(t01.qdd_lod_status,'0','Empty',to_char(t01.qdd_str_date, 'yyyy/mm/dd hh24:mi:ss')) as qdd_str_date,
                        decode(t01.qdd_lod_status,'0','Empty','1','In Progress',to_char(t01.qdd_end_date, 'yyyy/mm/dd hh24:mi:ss')) as qdd_end_date
                   from qvi_dim_defn t01
                  where (var_action = '*PRVDEF' and (var_str_code is null or t01.qdd_dim_code < var_str_code)) or
                        (var_action = '*NXTDEF')
                  order by t01.qdd_dim_code desc) t01
          where rownum <= var_pag_size;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_list is table of csr_slct%rowtype index by binary_integer;
      tbl_list typ_list;

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
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      var_str_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@STRCDE')));
      var_end_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@ENDCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SELDEF' and var_action != '*PRVDEF' and var_action != '*NXTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Retrieve the dimension list and pipe the results
      /*-*/
      var_pag_size := 20;
      if var_action = '*SELDEF' then
         tbl_list.delete;
         open csr_slct;
         fetch csr_slct bulk collect into tbl_list;
         close csr_slct;
         for idx in 1..tbl_list.count loop
            pipe row(qvi_xml_object('<LSTROW DIMCDE="'||qvi_to_xml(tbl_list(idx).qdd_dim_code)||'" DIMNAM="'||qvi_to_xml(tbl_list(idx).qdd_dim_name)||'" DIMSTS="'||qvi_to_xml(tbl_list(idx).qdd_dim_status)||'" LODSTS="'||qvi_to_xml(tbl_list(idx).qdd_lod_status)||'" LODSTR="'||qvi_to_xml(tbl_list(idx).qdd_str_date)||'" LODEND="'||qvi_to_xml(tbl_list(idx).qdd_end_date)||'"/>'));
         end loop;
      elsif var_action = '*NXTDEF' then
         tbl_list.delete;
         open csr_next;
         fetch csr_next bulk collect into tbl_list;
         close csr_next;
         if tbl_list.count = var_pag_size then
            for idx in 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DIMCDE="'||qvi_to_xml(tbl_list(idx).qdd_dim_code)||'" DIMNAM="'||qvi_to_xml(tbl_list(idx).qdd_dim_name)||'" DIMSTS="'||qvi_to_xml(tbl_list(idx).qdd_dim_status)||'" LODSTS="'||qvi_to_xml(tbl_list(idx).qdd_lod_status)||'" LODSTR="'||qvi_to_xml(tbl_list(idx).qdd_str_date)||'" LODEND="'||qvi_to_xml(tbl_list(idx).qdd_end_date)||'"/>'));
            end loop;
         else
            open csr_prev;
            fetch csr_prev bulk collect into tbl_list;
            close csr_prev;
            for idx in reverse 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DIMCDE="'||qvi_to_xml(tbl_list(idx).qdd_dim_code)||'" DIMNAM="'||qvi_to_xml(tbl_list(idx).qdd_dim_name)||'" DIMSTS="'||qvi_to_xml(tbl_list(idx).qdd_dim_status)||'" LODSTS="'||qvi_to_xml(tbl_list(idx).qdd_lod_status)||'" LODSTR="'||qvi_to_xml(tbl_list(idx).qdd_str_date)||'" LODEND="'||qvi_to_xml(tbl_list(idx).qdd_end_date)||'"/>'));
            end loop;
         end if;
      elsif var_action = '*PRVDEF' then
         tbl_list.delete;
         open csr_prev;
         fetch csr_prev bulk collect into tbl_list;
         close csr_prev;
         if tbl_list.count = var_pag_size then
            for idx in reverse 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DIMCDE="'||qvi_to_xml(tbl_list(idx).qdd_dim_code)||'" DIMNAM="'||qvi_to_xml(tbl_list(idx).qdd_dim_name)||'" DIMSTS="'||qvi_to_xml(tbl_list(idx).qdd_dim_status)||'" LODSTS="'||qvi_to_xml(tbl_list(idx).qdd_lod_status)||'" LODSTR="'||qvi_to_xml(tbl_list(idx).qdd_str_date)||'" LODEND="'||qvi_to_xml(tbl_list(idx).qdd_end_date)||'"/>'));
            end loop;
         else
            open csr_next;
            fetch csr_next bulk collect into tbl_list;
            close csr_next;
            for idx in 1..tbl_list.count loop
               pipe row(qvi_xml_object('<LSTROW DIMCDE="'||qvi_to_xml(tbl_list(idx).qdd_dim_code)||'" DIMNAM="'||qvi_to_xml(tbl_list(idx).qdd_dim_name)||'" DIMSTS="'||qvi_to_xml(tbl_list(idx).qdd_dim_status)||'" LODSTS="'||qvi_to_xml(tbl_list(idx).qdd_lod_status)||'" LODSTR="'||qvi_to_xml(tbl_list(idx).qdd_str_date)||'" LODEND="'||qvi_to_xml(tbl_list(idx).qdd_end_date)||'"/>'));
            end loop;
         end if;
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(qvi_xml_object('</QVI_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DIM_MAINTENANCE - SELECT_LIST - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_list;

   /*****************************************************/
   /* This procedure performs the retrieve data routine */
   /*****************************************************/
   function retrieve_data return qvi_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_dim_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_dim_defn t01
          where t01.qdd_dim_code = var_dim_code;
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
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      var_dim_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMCDE')));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' and var_action != '*CPYDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Retrieve the existing dimension when required
      /*-*/
      if var_action = '*UPDDEF' or var_action = '*CPYDEF' then
         var_found := false;
         open csr_retrieve;
         fetch csr_retrieve into rcd_retrieve;
         if csr_retrieve%found then
            var_found := true;
         end if;
         close csr_retrieve;
         if var_found = false then
            qvi_gen_function.add_mesg_data('Dimension ('||var_dim_code||') does not exist');
         end if;
         if qvi_gen_function.get_mesg_count != 0 then
            return;
         end if;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(qvi_xml_object('<?xml version="1.0" encoding="UTF-8"?><QVI_RESPONSE>'));

      /*-*/
      /* Pipe the dimension XML
      /*-*/
      if var_action = '*UPDDEF' then
         var_output := '<DIMDFN DIMCDE="'||qvi_to_xml(rcd_retrieve.qdd_dim_code||' - (Last updated by '||rcd_retrieve.qdd_upd_user||' on '||to_char(rcd_retrieve.qdd_upd_date,'yyyy/mm/dd')||')')||'"';
         var_output := var_output||' DIMNAM="'||qvi_to_xml(rcd_retrieve.qdd_dim_name)||'"';
         var_output := var_output||' DIMSTS="'||qvi_to_xml(rcd_retrieve.qdd_dim_status)||'"';
         var_output := var_output||' DIMTAB="'||qvi_to_xml(rcd_retrieve.qdd_dim_table)||'"';
         var_output := var_output||' DIMTYP="'||qvi_to_xml(rcd_retrieve.qdd_dim_type)||'"';
         var_output := var_output||' POLFLG="'||qvi_to_xml(rcd_retrieve.qdd_pol_flag)||'"';
         var_output := var_output||' FLGINT="'||qvi_to_xml(rcd_retrieve.qdd_flg_iface)||'"';
         var_output := var_output||' FLGMSG="'||qvi_to_xml(rcd_retrieve.qdd_flg_mname)||'"/>';
         pipe row(qvi_xml_object(var_output));
      elsif var_action = '*CPYDEF' then
         var_output := '<DIMDFN DIMCDE=""';
         var_output := var_output||' DIMNAM="'||qvi_to_xml(rcd_retrieve.qdd_dim_name)||'"';
         var_output := var_output||' DIMSTS="1"';
         var_output := var_output||' DIMTAB="'||qvi_to_xml(rcd_retrieve.qdd_dim_table)||'"';
         var_output := var_output||' DIMTYP="'||qvi_to_xml(rcd_retrieve.qdd_dim_type)||'"';
         var_output := var_output||' POLFLG="'||qvi_to_xml(rcd_retrieve.qdd_pol_flag)||'"';
         var_output := var_output||' FLGINT="'||qvi_to_xml(rcd_retrieve.qdd_flg_iface)||'"';
         var_output := var_output||' FLGMSG="'||qvi_to_xml(rcd_retrieve.qdd_flg_mname)||'"/>';
         pipe row(qvi_xml_object(var_output));
      elsif var_action = '*CRTDEF' then
         var_output := '<DIMDFN DIMCDE=""';
         var_output := var_output||' DIMNAM=""';
         var_output := var_output||' DIMSTS="1"';
         var_output := var_output||' DIMTAB=""';
         var_output := var_output||' DIMTYP=""';
         var_output := var_output||' POLFLG="0"';
         var_output := var_output||' FLGINT=""';
         var_output := var_output||' FLGMSG=""/>';
         pipe row(qvi_xml_object(var_output));
      end if;

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(qvi_xml_object('</QVI_RESPONSE>'));

      /*-*/
      /* Return
      /*-*/
      return;

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DIM_MAINTENANCE - RETRIEVE_DATA - ' || substr(SQLERRM, 1, 1536));

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
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      rcd_qvi_dim_defn qvi_dim_defn%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_dim_defn t01
          where t01.qdd_dim_code = rcd_qvi_dim_defn.qdd_dim_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      if var_action != '*UPDDEF' and var_action != '*CRTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;
      rcd_qvi_dim_defn.qdd_dim_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMCDE')));
      rcd_qvi_dim_defn.qdd_dim_name := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMNAM'));
      rcd_qvi_dim_defn.qdd_dim_status := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMSTS'));
      rcd_qvi_dim_defn.qdd_dim_table := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMTAB'));
      rcd_qvi_dim_defn.qdd_dim_type := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMTYP'));
      rcd_qvi_dim_defn.qdd_lod_status := '0';
      rcd_qvi_dim_defn.qdd_pol_flag := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@POLFLG'));
      rcd_qvi_dim_defn.qdd_flg_iface := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FLGINT'));
      rcd_qvi_dim_defn.qdd_flg_mname := qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@FLGMSG'));
      rcd_qvi_dim_defn.qdd_upd_seqn := 0;
      rcd_qvi_dim_defn.qdd_str_date := sysdate;
      rcd_qvi_dim_defn.qdd_end_date := sysdate;
      rcd_qvi_dim_defn.qdd_upd_user := upper(par_user);
      rcd_qvi_dim_defn.qdd_upd_date := sysdate;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Validate the input
      /*-*/
      if rcd_qvi_dim_defn.qdd_dim_code is null then
         qvi_gen_function.add_mesg_data('Dimension code must be supplied');
      end if;
      if rcd_qvi_dim_defn.qdd_dim_name is null then
         qvi_gen_function.add_mesg_data('Dimension name must be supplied');
      end if;
      if rcd_qvi_dim_defn.qdd_dim_status is null or (rcd_qvi_dim_defn.qdd_dim_status != '0' and rcd_qvi_dim_defn.qdd_dim_status != '1') then
         qvi_gen_function.add_mesg_data('Dimension status must be (0)inactive or (1)active');
      end if;
      if rcd_qvi_dim_defn.qdd_dim_table is null then
         qvi_gen_function.add_mesg_data('Dimension retrieve table function must be supplied');
      end if;
      if rcd_qvi_dim_defn.qdd_dim_type is null then
         qvi_gen_function.add_mesg_data('Dimension storage type must be supplied');
      end if;
      if rcd_qvi_dim_defn.qdd_pol_flag is null or (rcd_qvi_dim_defn.qdd_pol_flag != '0' and rcd_qvi_dim_defn.qdd_pol_flag != '1') then
         qvi_gen_function.add_mesg_data('Dimension polling flag must be (0)flag or (1)batch');
      else
         if rcd_qvi_dim_defn.qdd_pol_flag = '0' then
            if rcd_qvi_dim_defn.qdd_flg_iface is null then
               qvi_gen_function.add_mesg_data('Dimension flag file interface must be supplied for polling flag (0)flag');
            end if;
            if rcd_qvi_dim_defn.qdd_flg_mname is null then
               qvi_gen_function.add_mesg_data('Dimension flag file message name must be supplied for polling flag (0)flag');
            end if;
         else
            if not(rcd_qvi_dim_defn.qdd_flg_iface) is null then
               qvi_gen_function.add_mesg_data('Dimension flag file interface must be null for polling flag (1)batch');
            end if;
            if not(rcd_qvi_dim_defn.qdd_flg_mname) is null then
               qvi_gen_function.add_mesg_data('Dimension flag file message name must be null for polling flag (1)batch');
            end if;
         end if;
      end if;
      if rcd_qvi_dim_defn.qdd_upd_user is null then
         qvi_gen_function.add_mesg_data('Update user must be supplied');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the dimension definition
      /*-*/
      if var_action = '*UPDDEF' then
         var_confirm := 'updated';
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
               var_found := true;
               qvi_gen_function.add_mesg_data('Dimension code ('||rcd_qvi_dim_defn.qdd_dim_code||') is currently locked');
         end;
         if var_found = false then
            qvi_gen_function.add_mesg_data('Dimension code ('||rcd_qvi_dim_defn.qdd_dim_code||') does not exist');
         else
            if rcd_retrieve.qdd_lod_status = '1' then
               qvi_gen_function.add_mesg_data('Dimension code ('||rcd_qvi_dim_defn.qdd_dim_code||') is currently loading - unable to update');
            end if;
         end if;
         if qvi_gen_function.get_mesg_count = 0 then
            update qvi_dim_defn
               set qdd_dim_name = rcd_qvi_dim_defn.qdd_dim_name,
                   qdd_dim_status = rcd_qvi_dim_defn.qdd_dim_status,
                   qdd_dim_table = rcd_qvi_dim_defn.qdd_dim_table,
                   qdd_dim_type = rcd_qvi_dim_defn.qdd_dim_type,
                   qdd_pol_flag = rcd_qvi_dim_defn.qdd_pol_flag,
                   qdd_flg_iface = rcd_qvi_dim_defn.qdd_flg_iface,
                   qdd_flg_mname = rcd_qvi_dim_defn.qdd_flg_mname,
                   qdd_upd_user = rcd_qvi_dim_defn.qdd_upd_user,
                   qdd_upd_date = rcd_qvi_dim_defn.qdd_upd_date
             where qdd_dim_code = rcd_qvi_dim_defn.qdd_dim_code;
         end if;
      elsif var_action = '*CRTDEF' then
         var_confirm := 'created';
         begin
            insert into qvi_dim_defn values rcd_qvi_dim_defn;
         exception
            when dup_val_on_index then
               qvi_gen_function.add_mesg_data('Dimension code ('||rcd_qvi_dim_defn.qdd_dim_code||') already exists - unable to create');
         end;
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
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

      /*-*/
      /* Send the confirm message
      /*-*/
      qvi_gen_function.set_cfrm_data('Dimension ('||to_char(rcd_qvi_dim_defn.qdd_dim_code)||') successfully '||var_confirm);

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DIM_MAINTENANCE - UPDATE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_data;

   /***************************************************/
   /* This procedure performs the delete data routine */
   /***************************************************/
   procedure delete_data is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_qvi_request xmlDom.domNode;
      var_action varchar2(32);
      var_confirm varchar2(32);
      var_found boolean;
      var_dim_code varchar2(32);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from qvi_dim_defn t01
          where t01.qdd_dim_code = var_dim_code
            for update nowait;
      rcd_retrieve csr_retrieve%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the message data
      /*-*/
      qvi_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('QVI_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_qvi_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/QVI_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_qvi_request,'@ACTION'));
      if var_action != '*DLTDEF' then
         qvi_gen_function.add_mesg_data('Invalid request action');
      end if;
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;
      var_dim_code := upper(qvi_from_xml(xslProcessor.valueOf(obj_qvi_request,'@DIMCDE')));
      if qvi_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Process the dimension definition
      /*-*/
      var_confirm := 'deleted';
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
            var_found := true;
            qvi_gen_function.add_mesg_data('Dimension code ('||var_dim_code||') is currently locked');
      end;
      if var_found = false then
         qvi_gen_function.add_mesg_data('Dimension code ('||var_dim_code||') does not exist');
      else
         if rcd_retrieve.qdd_lod_status = '1' then
            qvi_gen_function.add_mesg_data('Dimension code ('||var_dim_code||') is currently loading - unable to delete');
         end if;
      end if;
      if qvi_gen_function.get_mesg_count = 0 then
         delete from qvi_dim_data where qdd_dim_code = var_dim_code;
         delete from qvi_dim_defn where qdd_dim_code = var_dim_code;
      else
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

      /*-*/
      /* Send the confirm message
      /*-*/
      qvi_gen_function.set_cfrm_data('Dimension ('||var_dim_code||') successfully '||var_confirm);

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
         qvi_gen_function.add_mesg_data('FATAL ERROR - QVI_DIM_MAINTENANCE - DELETE_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_data;

end qvi_dim_maintenance;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_dim_maintenance for qv_app.qvi_dim_maintenance;
grant execute on qv_app.qvi_dim_maintenance to public;
