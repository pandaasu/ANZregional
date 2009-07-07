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
   pvar_dat_seqn number;
   pvar_dim_indx number;
   pvar_value boolean;
   rcd_sms_rpt_header sms_rpt_header%rowtype;
   rcd_sms_rpt_data sms_rpt_data%rowtype;

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
   procedure read_xml_stream(par_stream in clob) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;
      obj_map_node_list xmlDom.domNamedNodeMap;
      obj_map_node xmlDom.domNode;
      var_found boolean;
      var_date date;
      var_rpt_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_query is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = rcd_sms_rpt_header.rhe_qry_code;
      rcd_query csr_query%rowtype;

      cursor csr_date is
         select t01.mars_period,
                t01.mars_week,
                t01.mars_yyyyppdd
           from mars_date t01
          where trunc(t01.calendar_date) = var_date;
      rcd_date csr_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period information based on today
      /*-*/
      var_date := trunc(sysdate);
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%notfound then
         raise_application_error(-20000, 'No mars date found for ' || to_char(var_date,'yyyy/mm/dd'));
      end if;
      close csr_date;

      /*-*/
      /* Initialise the report
      /*-*/
      pvar_report := false;
      rcd_sms_rpt_header.rhe_qry_code := null;
      rcd_sms_rpt_header.rhe_rpt_date := null;
      rcd_sms_rpt_header.rhe_rpt_yyyypp := null;
      rcd_sms_rpt_header.rhe_rpt_yyyyppw := null;
      rcd_sms_rpt_header.rhe_rpt_yyyyppdd := null;
      rcd_sms_rpt_header.rhe_crt_user := user;
      rcd_sms_rpt_header.rhe_crt_date := sysdate;
      rcd_sms_rpt_header.rhe_crt_yyyypp := rcd_date.mars_period;
      rcd_sms_rpt_header.rhe_crt_yyyyppw := rcd_date.mars_week;
      rcd_sms_rpt_header.rhe_crt_yyyyppdd := rcd_date.mars_yyyyppdd;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,par_stream);
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);

      /*-*/
      /* Retrieve the document nodes
      /*-*/
      obj_xml_node_list := xmlDom.getElementsByTagName(obj_xml_document,'*');

      /*-*/
      /* Retrieve the processing date
      /*-*/
      var_rpt_date := null;
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         if upper(xmlDom.getNodeName(obj_xml_node)) = 'PROCESSINGDATE' then
            var_rpt_date := sms_to_date(trim(xmlDom.getNodeValue(obj_xml_node)),'yyyy-mm-dd');
            exit;
         end if;
      end loop;
      if var_rpt_date is null then
         raise_application_error(-20000, 'ProcessingDate tag does exist or does not contain a date in the format YYYY-MM-DD');
      end if;
      rcd_sms_rpt_header.rhe_rpt_date := to_char(var_rpt_date,'yyyymmdd');

      /*-*/
      /* Retrieve the current period information based on report date
      /*-*/
      var_date := trunc(var_rpt_date);
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%notfound then
         raise_application_error(-20000, 'No mars date found for ' || to_char(var_rpt_date,'yyyy/mm/dd'));
      end if;
      close csr_date;
      rcd_sms_rpt_header.rhe_rpt_yyyypp := rcd_date.mars_period;
      rcd_sms_rpt_header.rhe_rpt_yyyyppw := rcd_date.mars_week;
      rcd_sms_rpt_header.rhe_rpt_yyyyppdd := rcd_date.mars_yyyyppdd;

      /*-*/
      /* Retrieve the query name
      /*-*/
      var_found := false; 
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         if upper(xmlDom.getNodeName(obj_xml_node)) = 'QUERY' then
            var_found := true;
            exit;
         end if;
      end loop;
      if var_found = false then
         raise_application_error(-20000, 'Query tag does exist');
      end if;
      obj_map_node_list := xmlDom.getAttributes(obj_xml_node);
      if not(xmlDom.isNull(obj_map_node_list)) then
         for idx in 0..xmlDom.getLength(obj_map_node_list)-1 loop
            obj_map_node := xmlDom.item(obj_map_node_list,idx);
            if upper(xmlDom.getNodeName(obj_map_node)) = 'NAME' then
               rcd_sms_rpt_header.rhe_qry_code := sms_from_xml(xmlDom.getNodeValue(obj_map_node));
               exit;
            end if;
         end loop;
      end if;
      if rcd_sms_rpt_header.rhe_qry_code is null then
         raise_application_error(-20000, 'Query tag does not contain a name attribute');
      else
         var_found := false;
         open csr_query;
         fetch csr_query into rcd_query;
         if csr_query%found then
            var_found := true;
         end if;
         close csr_query;
         if var_found = false then
            raise_application_error(-20000, 'Query code ('||rcd_sms_rpt_header.rhe_qry_code||') is not defined');
         end if;
         if rcd_query.que_qry_status != '1' then
            raise_application_error(-20000, 'Query code ('||rcd_sms_rpt_header.rhe_qry_code||') is not active');
         end if;
      end if;

      /*-*/
      /* Delete the existing report information
      /*-*/
      delete from sms_rpt_data
       where rda_qry_code = rcd_sms_rpt_header.rhe_qry_code
         and rda_rpt_date =  rcd_sms_rpt_header.rhe_rpt_date;
      delete from sms_rpt_header
       where rhe_qry_code = rcd_sms_rpt_header.rhe_qry_code
         and rhe_rpt_date =  rcd_sms_rpt_header.rhe_rpt_date;

      /*-*/
      /* Create the report header
      /*-*/
      insert into sms_rpt_header values rcd_sms_rpt_header;

      /*-*/
      /* Retrieve the report data
      /*-*/
      pvar_dat_seqn := 0;
      pvar_dim_indx := 0;
      pvar_value := false;
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         read_xml_child(obj_xml_node);
      end loop;

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
   procedure read_xml_child(par_xml_node in xmlDom.domNode) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_map_node_list xmlDom.domNamedNodeMap;
      obj_map_node xmlDom.domNode;
      var_dim_code varchar2(256 char);
      var_dim_valu varchar2(256 char);
      var_val_code varchar2(256 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the current XML node
      /*-*/
      case upper(xmlDom.getNodeName(par_xml_node))

         when 'DATACELL' then

            pvar_dat_seqn := pvar_dat_seqn + 1;
            pvar_dim_indx := 0;
            pvar_value := false;
            rcd_sms_rpt_data.rda_qry_code := rcd_sms_rpt_header.rhe_qry_name;
            rcd_sms_rpt_data.rda_rpt_date := rcd_sms_rpt_header.rhe_rpt_date;
            rcd_sms_rpt_data.rda_dat_seqn := pvar_dat_seqn;
            rcd_sms_rpt_data.rda_dim_seqn := null;
            rcd_sms_rpt_data.rda_dim_cod01 := null;
            rcd_sms_rpt_data.rda_dim_cod02 := null;
            rcd_sms_rpt_data.rda_dim_cod03 := null;
            rcd_sms_rpt_data.rda_dim_cod04 := null;
            rcd_sms_rpt_data.rda_dim_cod05 := null;
            rcd_sms_rpt_data.rda_dim_cod06 := null;
            rcd_sms_rpt_data.rda_dim_cod07 := null;
            rcd_sms_rpt_data.rda_dim_cod08 := null;
            rcd_sms_rpt_data.rda_dim_cod09 := null;
            rcd_sms_rpt_data.rda_dim_val01 := null;
            rcd_sms_rpt_data.rda_dim_val02 := null;
            rcd_sms_rpt_data.rda_dim_val03 := null;
            rcd_sms_rpt_data.rda_dim_val04 := null;
            rcd_sms_rpt_data.rda_dim_val05 := null;
            rcd_sms_rpt_data.rda_dim_val06 := null;
            rcd_sms_rpt_data.rda_dim_val07 := null;
            rcd_sms_rpt_data.rda_dim_val08 := null;
            rcd_sms_rpt_data.rda_dim_val09 := null;
            rcd_sms_rpt_data.rda_val_code := null;
            rcd_sms_rpt_data.rda_val_data := null;

         when 'CHARACTERISTICDIMENSION' then

            pvar_dim_indx := pvar_dim_indx + 1;

         when 'CHARACTERISTIC' then

            var_dim_code := null;
            obj_map_node_list := xmlDom.getAttributes(par_xml_node);
            if not(xmlDom.isNull(obj_map_node_list)) then
               for idx in 0..xmlDom.getLength(obj_map_node_list)-1 loop
                  obj_map_node := xmlDom.item(obj_map_node_list,idx);
                  if upper(xmlDom.getNodeName(obj_map_node)) = 'TEXT' then
                     var_dim_code := sms_from_xml(xmlDom.getNodeValue(obj_map_node));
                     exit;
                  end if;
               end loop;
            end if;
            if pvar_dim_indx = 1 then
               rcd_sms_rpt_data.rda_dim_cod01 := var_dim_code;
            elsif pvar_dim_indx = 2 then
               rcd_sms_rpt_data.rda_dim_cod02 := var_dim_code;
            elsif pvar_dim_indx = 3 then
               rcd_sms_rpt_data.rda_dim_cod03 := var_dim_code;
            elsif pvar_dim_indx = 4 then
               rcd_sms_rpt_data.rda_dim_cod04 := var_dim_code;
            elsif pvar_dim_indx = 5 then
               rcd_sms_rpt_data.rda_dim_cod05 := var_dim_code;
            elsif pvar_dim_indx = 6 then
               rcd_sms_rpt_data.rda_dim_cod06 := var_dim_code;
            elsif pvar_dim_indx = 7 then
               rcd_sms_rpt_data.rda_dim_cod07 := var_dim_code;
            elsif pvar_dim_indx = 8 then
               rcd_sms_rpt_data.rda_dim_cod08 := var_dim_code;
            elsif pvar_dim_indx = 9 then
               rcd_sms_rpt_data.rda_dim_cod09 := var_dim_code;
            end if;

         when 'CHARACTERISTICMEMBER' then

            var_dim_valu := null;
            obj_map_node_list := xmlDom.getAttributes(par_xml_node);
            if not(xmlDom.isNull(obj_map_node_list)) then
               for idx in 0..xmlDom.getLength(obj_map_node_list)-1 loop
                  obj_map_node := xmlDom.item(obj_map_node_list,idx);
                  if upper(xmlDom.getNodeName(obj_map_node)) = 'TEXT' then
                     var_dim_valu := sms_from_xml(xmlDom.getNodeValue(obj_map_node));
                     exit;
                  end if;
               end loop;
            end if;
            if pvar_dim_indx = 1 then
               rcd_sms_rpt_data.rda_dim_val01 := var_dim_valu;
            elsif pvar_dim_indx = 2 then
               rcd_sms_rpt_data.rda_dim_val02 := var_dim_valu;
            elsif pvar_dim_indx = 3 then
               rcd_sms_rpt_data.rda_dim_val03 := var_dim_valu;
            elsif pvar_dim_indx = 4 then
               rcd_sms_rpt_data.rda_dim_val04 := var_dim_valu;
            elsif pvar_dim_indx = 5 then
               rcd_sms_rpt_data.rda_dim_val05 := var_dim_valu;
            elsif pvar_dim_indx = 6 then
               rcd_sms_rpt_data.rda_dim_val06 := var_dim_valu;
            elsif pvar_dim_indx = 7 then
               rcd_sms_rpt_data.rda_dim_val07 := var_dim_valu;
            elsif pvar_dim_indx = 8 then
               rcd_sms_rpt_data.rda_dim_val08 := var_dim_valu;
            elsif pvar_dim_indx = 9 then
               rcd_sms_rpt_data.rda_dim_val09 := var_dim_valu;
            end if;

         when 'KEYFIGURE' then

            var_val_code := null;
            obj_map_node_list := xmlDom.getAttributes(par_xml_node);
            if not(xmlDom.isNull(obj_map_node_list)) then
               for idx in 0..xmlDom.getLength(obj_map_node_list)-1 loop
                  obj_map_node := xmlDom.item(obj_map_node_list,idx);
                  if upper(xmlDom.getNodeName(obj_map_node)) = 'TEXT' then
                     var_val_code := sms_from_xml(xmlDom.getNodeValue(obj_map_node));
                     exit;
                  end if;
               end loop;
            end if;
            rcd_sms_rpt_data.rda_val_code := var_val_code;

         when 'DISPLAYDATACELL' then

            pvar_value := true;

         when 'VALUE' then

            if pvar_value = true then
               rcd_sms_rpt_data.rda_val_data := sms_from_xml(trim(xmlDom.getNodeValue(par_xml_node)));
               insert into sms_rpt_data values rcd_sms_rpt_data;
            end if;

         else

            null;

      end case;

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
