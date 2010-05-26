/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_mix_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_mix_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Mix Function

    This package contain the mix functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function select_data return psa_xml_type pipelined;
   function extract_data(par_str_date in varchar2, par_end_date in varchar2) return psa_xls_type pipelined;

end psa_mix_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_mix_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***************************************************/
   /* This procedure performs the select data routine */
   /***************************************************/
   function select_data return psa_xml_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_psa_request xmlDom.domNode;
      var_action varchar2(32);
      var_found boolean;
      var_fil_code varchar2(32);
      var_output varchar2(2000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_retrieve is
         select t01.*
           from psa_fil_defn t01
          where t01.fde_fil_code = var_fil_code;
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
      psa_gen_function.clear_mesg_data;

      /*-*/
      /* Parse the XML input
      /*-*/
      obj_xml_parser := xmlParser.newParser();
      xmlParser.parseClob(obj_xml_parser,lics_form.get_clob('PSA_STREAM'));
      obj_xml_document := xmlParser.getDocument(obj_xml_parser);
      xmlParser.freeParser(obj_xml_parser);
      obj_psa_request := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/PSA_REQUEST');
      var_action := upper(xslProcessor.valueOf(obj_psa_request,'@ACTION'));
      xmlDom.freeDocument(obj_xml_document);
      if var_action != '*SLTEXT' then
         psa_gen_function.add_mesg_data('Invalid request action');
      end if;
      if psa_gen_function.get_mesg_count != 0 then
         return;
      end if;

      /*-*/
      /* Pipe the XML start
      /*-*/
      pipe row(psa_xml_object('<?xml version="1.0" encoding="UTF-8"?><PSA_RESPONSE>'));

      /*-*/
      /* Pipe the select XML
      /*-*/
      var_output := '<EXTDFN STRDTE="'||psa_to_xml(to_char(sysdate,'dd/mm/yyyy'))||'" ENDDTE="'||psa_to_xml(to_char(sysdate,'dd/mm/yyyy'))||'"/>';
      pipe row(psa_xml_object(var_output));

      /*-*/
      /* Pipe the XML end
      /*-*/
      pipe row(psa_xml_object('</PSA_RESPONSE>'));

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
         psa_gen_function.add_mesg_data('FATAL ERROR - PSA_MIX_FUNCTION - SELECT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_data;

   /****************************************************/
   /* This procedure performs the extract date routine */
   /****************************************************/
   function extract_data(par_str_date in varchar2, par_end_date in varchar2) return psa_xls_type pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_str_date date;
      var_end_date date;
      var_found boolean;
      var_output varchar2(4000 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(trunc(t01.psa_act_str_time),'dd/mm/yyyy') as mix_date,
                t01.psa_mat_code,
                max(t01.psa_mat_name) as psa_mat_name,
                to_char(sum(t01.psa_mat_act_mix_qty)) as mix_qty
           from psa_psc_actv t01
          where t01.psa_psc_code = '*MASTER'
            and t01.psa_prd_type = '*FILL'
            and t01.psa_act_type = 'P'
            and (t01.psa_act_str_time >= var_str_date and t01.psa_act_str_time < var_end_date)
          group by trunc(t01.psa_act_str_time),
                   t01.psa_mat_code
          order by trunc(t01.psa_act_str_time) asc,
                   t01.psa_mat_code asc;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_str_date := psa_to_date(par_str_date,'dd/mm/yyyy');
      var_end_date := psa_to_date(par_end_date,'dd/mm/yyyy')+1;

      /*-*/
      /* Retrieve the extract data
      /*-*/
      open csr_extract;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;
         var_output := '"'||rcd_extract.mix_date||'"';
         var_output := var_output||',"'||rcd_extract.psa_mat_code||'"';
         var_output := var_output||',"'||replace(rcd_extract.psa_mat_name,'"','""')||'"';
         var_output := var_output||',"'||rcd_extract.mix_qty||'"';
         pipe row(var_output);
      end loop;
      close csr_extract;

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
         raise_application_error(-20000, 'FATAL ERROR - PSA_MIX_FUNCTION - EXTRACT_DATA - ' || substr(SQLERRM, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_data;

end psa_mix_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_mix_function for psa_app.psa_mix_function;
grant execute on psa_app.psa_mix_function to public;
