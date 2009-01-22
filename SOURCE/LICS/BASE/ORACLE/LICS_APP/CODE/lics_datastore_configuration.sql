/******************/
/* Package Header */
/******************/
create or replace package lics_datastore_configuration as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_datastore_configuration
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Data Store Configuration

    The package implements the data store configuration functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/01   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_nodes(par_system in varchar2) return lics_store_table pipelined;
   procedure define_store(par_user in varchar2);
   procedure delete_store(par_system in varchar2);

end lics_datastore_configuration;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_datastore_configuration as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_das_system lics_das_system%rowtype;
   rcd_lics_das_group lics_das_group%rowtype;
   rcd_lics_das_code lics_das_code%rowtype;
   rcd_lics_das_value lics_das_value%rowtype;

   /*************************************************/
   /* This procedure performs the get nodes routine */
   /*************************************************/
   function get_nodes(par_system in varchar2) return lics_store_table pipelined is

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_group is
         select t01.*
           from lics_das_group t01
          where t01.dsg_system = upper(par_system)
          order by t01.dsg_group asc;
      rcd_group csr_group%rowtype;

      cursor csr_code is
         select t01.*
           from lics_das_code t01
          where t01.dsc_system = rcd_group.dsg_system
            and t01.dsc_group = rcd_group.dsg_group
          order by t01.dsc_code asc;
      rcd_code csr_code%rowtype;

      cursor csr_value is
         select t01.*
           from lics_das_value t01
          where t01.dsv_system = rcd_code.dsc_system
            and t01.dsv_group = rcd_code.dsc_group
            and t01.dsv_code = rcd_code.dsc_code
          order by t01.dsv_value asc,
                   t01.dsv_sequence asc;
      rcd_value csr_value%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Pipe the data store root node
      /*-*/
      pipe row(lics_store_object(0,
                                 'S',
                                 null,
                                 null,
                                 'Data Store Root',
                                 null,
                                 null,
                                 null));

      /*-*/
      /* Pipe the data store group nodes
      /*-*/
      open csr_group;
      loop
         fetch csr_group into rcd_group;
         if csr_group%notfound then
            exit;
         end if;
         pipe row(lics_store_object(1,
                                    'G',
                                    rcd_group.dsg_group,
                                    null,
                                    rcd_group.dsg_description,
                                    null,
                                    null,
                                    null));

         /*-*/
         /* Pipe the data store code nodes
         /*-*/
         open csr_code;
         loop
            fetch csr_code into rcd_code;
            if csr_code%notfound then
               exit;
            end if;
            pipe row(lics_store_object(2,
                                       'C',
                                       rcd_code.dsc_group,
                                       rcd_code.dsc_code,
                                       rcd_code.dsc_description,
                                       null,
                                       rcd_code.dsc_val_type,
                                       rcd_code.dsc_val_data));

            /*-*/
            /* Pipe the data store value nodes
            /*-*/
            open csr_value;
            loop
               fetch csr_value into rcd_value;
               if csr_value%notfound then
                  exit;
               end if;
               pipe row(lics_store_object(3,
                                          'V',
                                          rcd_value.dsv_group,
                                          rcd_value.dsv_code,
                                          null,
                                          rcd_value.dsv_value,
                                          null,
                                          null));
            end loop;
            close csr_value;

         end loop;
         close csr_code;

      end loop;
      close csr_group;

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
         raise_application_error(-20000, 'ICS_DATASTORE_CONFIGURATION - GET_NODES - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_nodes;

   /****************************************************/
   /* This procedure performs the define store routine */
   /****************************************************/
   procedure define_store(par_user in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      obj_xml_parser xmlParser.parser;
      obj_xml_document xmlDom.domDocument;
      obj_xml_store xmlDom.domNode;
      obj_xml_node_list xmlDom.domNodeList;
      obj_xml_node xmlDom.domNode;
      var_val_seqn number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check_store is 
         select t01.*
           from lics_das_system t01
          where t01.dss_system = rcd_lics_das_system.dss_system;
      rcd_check_store csr_check_store%rowtype;

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
      /* Retrieve and process the data store
      /*-*/
      obj_xml_store := xslProcessor.selectSingleNode(xmlDom.makeNode(obj_xml_document),'/ICS_STORE');
      rcd_lics_das_system.dss_system := upper(xslProcessor.valueOf(obj_xml_store,'@CODE'));
      rcd_lics_das_system.dss_description := xslProcessor.valueOf(obj_xml_store,'@TEXT');
      rcd_lics_das_system.dss_upd_user := par_user;
      rcd_lics_das_system.dss_upd_date := sysdate;
      open csr_check_store;
      fetch csr_check_store into rcd_check_store;
      if csr_check_store%found then
         update lics_das_system
            set dss_description = rcd_lics_das_system.dss_description,
                dss_upd_user = rcd_lics_das_system.dss_upd_user,
                dss_upd_date = rcd_lics_das_system.dss_upd_date
          where dss_system = rcd_lics_das_system.dss_system;
         delete from lics_das_value where dsv_system = rcd_lics_das_system.dss_system;
         delete from lics_das_code where dsc_system = rcd_lics_das_system.dss_system;
         delete from lics_das_group where dsg_system = rcd_lics_das_system.dss_system;
      else
         insert into lics_das_system values rcd_lics_das_system;
      end if;
      close csr_check_store;

      /*-*/
      /* Retrieve and process the data store nodes
      /*-*/
      obj_xml_node_list := xslProcessor.selectNodes(xmlDom.makeNode(obj_xml_document),'/ICS_STORE/NODES/NODE');
      for idx in 0..xmlDom.getLength(obj_xml_node_list)-1 loop
         obj_xml_node := xmlDom.item(obj_xml_node_list,idx);
         if upper(xslProcessor.valueOf(obj_xml_node,'@NODE')) = 'G' then
            rcd_lics_das_group.dsg_system := rcd_lics_das_system.dss_system;
            rcd_lics_das_group.dsg_group := upper(xslProcessor.valueOf(obj_xml_node,'@GROUP'));
            rcd_lics_das_group.dsg_description := xslProcessor.valueOf(obj_xml_node,'@TEXT');
            rcd_lics_das_group.dsg_upd_user := rcd_lics_das_system.dss_upd_user;
            rcd_lics_das_group.dsg_upd_date := rcd_lics_das_system.dss_upd_date;
            insert into lics_das_group values rcd_lics_das_group;
         end if;
         if upper(xslProcessor.valueOf(obj_xml_node,'@NODE')) = 'C' then
            rcd_lics_das_code.dsc_system := rcd_lics_das_system.dss_system;
            rcd_lics_das_code.dsc_group := upper(xslProcessor.valueOf(obj_xml_node,'@GROUP'));
            rcd_lics_das_code.dsc_code := upper(xslProcessor.valueOf(obj_xml_node,'@CODE'));
            rcd_lics_das_code.dsc_description := xslProcessor.valueOf(obj_xml_node,'@TEXT');
            rcd_lics_das_code.dsc_val_type := upper(xslProcessor.valueOf(obj_xml_node,'@TYPE'));
            rcd_lics_das_code.dsc_val_data := upper(xslProcessor.valueOf(obj_xml_node,'@DATA'));
            rcd_lics_das_code.dsc_upd_user := rcd_lics_das_system.dss_upd_user;
            rcd_lics_das_code.dsc_upd_date := rcd_lics_das_system.dss_upd_date;
            insert into lics_das_code values rcd_lics_das_code;
            var_val_seqn := 0;
         end if;
         if upper(xslProcessor.valueOf(obj_xml_node,'@NODE')) = 'V' then
            var_val_seqn := var_val_seqn + 1;
            rcd_lics_das_value.dsv_system := rcd_lics_das_system.dss_system;
            rcd_lics_das_value.dsv_group := upper(xslProcessor.valueOf(obj_xml_node,'@GROUP'));
            rcd_lics_das_value.dsv_code := upper(xslProcessor.valueOf(obj_xml_node,'@CODE'));
            rcd_lics_das_value.dsv_sequence := var_val_seqn;
            rcd_lics_das_value.dsv_value := xslProcessor.valueOf(obj_xml_node,'@VALUE');
            insert into lics_das_value values rcd_lics_das_value;
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
         raise_application_error(-20000, 'FATAL ERROR - ICS_DATASTORE_CONFIGURATION - DEFINE_STORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end define_store;

   /****************************************************/
   /* This procedure performs the delete store routine */
   /****************************************************/
   procedure delete_store(par_system in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the store data
      /*-*/
      delete from lics_das_value where dsv_system = upper(par_system);
      delete from lics_das_code where dsc_system = upper(par_system);
      delete from lics_das_group where dsg_system = upper(par_system);
      delete from lics_das_system where dss_system = upper(par_system);

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

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - ICS_DATASTORE_CONFIGURATION - DELETE_STORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_store;

end lics_datastore_configuration;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_datastore_configuration for lics_app.lics_datastore_configuration;
grant execute on lics_datastore_configuration to public;