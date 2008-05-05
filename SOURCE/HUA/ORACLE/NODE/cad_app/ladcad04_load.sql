create or replace package ladcad04_order_summary as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CAD
 Package : ladcad04_order_summary
 Owner   : CAD_APP
 Author  : Linden Glen

 Description
 -----------
 China Applications Data - CADLAD04 - Order Summary

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/02   Linden Glen    Added NIV values

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladcad04_order_summary;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad04_order_summary as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_cad_order_summary cad_order_summary%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_start := false;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','ORD_DOC_NUM',10);
      lics_inbound_utility.set_definition('HDR','ORD_DOC_LINE_NUM',6);
      lics_inbound_utility.set_definition('HDR','ORD_LIN_STATUS',4);
      lics_inbound_utility.set_definition('HDR','SAP_ORDER_TYPE_CODE',4);
      lics_inbound_utility.set_definition('HDR','SAP_DOC_CURRCY_CODE',5);
      lics_inbound_utility.set_definition('HDR','SAP_SOLD_TO_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','SAP_BILL_TO_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','SAP_SHIP_TO_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','SAP_PLANT_CODE',4);
      lics_inbound_utility.set_definition('HDR','SAP_MATERIAL_CODE',18);
      lics_inbound_utility.set_definition('HDR','SAP_ORD_QTY_UOM_CODE',3);
      lics_inbound_utility.set_definition('HDR','ORD_CREATION_DATE',8);
      lics_inbound_utility.set_definition('HDR','AGREED_DEL_DATE',8);
      lics_inbound_utility.set_definition('HDR','SCHEDULED_DEL_DATE',8);
      lics_inbound_utility.set_definition('HDR','DEL_DATE',8);
      lics_inbound_utility.set_definition('HDR','POD_DATE',8);
      lics_inbound_utility.set_definition('HDR','ORD_QTY',16);
      lics_inbound_utility.set_definition('HDR','DEL_QTY',16);
      lics_inbound_utility.set_definition('HDR','POD_QTY',16);
      lics_inbound_utility.set_definition('HDR','ORD_NIV',16);
      lics_inbound_utility.set_definition('HDR','DEL_NIV',16);
      lics_inbound_utility.set_definition('HDR','POD_NIV',16);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the transaction
      /*-*/
      complete_transaction;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

      /*-*/
      /* Local definitions
      /*-*/
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/


      /*-*/
      /* Local cursors
      /*-*/

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* Complete Previous Transaction */
      /*-------------------------------*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/      
      rcd_cad_order_summary.ord_doc_num := lics_inbound_utility.get_variable('ORD_DOC_NUM');
      rcd_cad_order_summary.ord_doc_line_num := lics_inbound_utility.get_variable('ORD_DOC_LINE_NUM');
      rcd_cad_order_summary.ord_lin_status := lics_inbound_utility.get_variable('ORD_LIN_STATUS');
      rcd_cad_order_summary.sap_order_type_code := lics_inbound_utility.get_variable('SAP_ORDER_TYPE_CODE');
      rcd_cad_order_summary.sap_doc_currcy_code := lics_inbound_utility.get_variable('SAP_DOC_CURRCY_CODE');
      rcd_cad_order_summary.sap_sold_to_cust_code := lics_inbound_utility.get_variable('SAP_SOLD_TO_CUST_CODE');
      rcd_cad_order_summary.sap_bill_to_cust_code := lics_inbound_utility.get_variable('SAP_BILL_TO_CUST_CODE');
      rcd_cad_order_summary.sap_ship_to_cust_code := lics_inbound_utility.get_variable('SAP_SHIP_TO_CUST_CODE');
      rcd_cad_order_summary.sap_plant_code := lics_inbound_utility.get_variable('SAP_PLANT_CODE');
      rcd_cad_order_summary.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
      rcd_cad_order_summary.sap_ord_qty_uom_code := lics_inbound_utility.get_variable('SAP_ORD_QTY_UOM_CODE');
      rcd_cad_order_summary.ord_creation_date := lics_inbound_utility.get_variable('ORD_CREATION_DATE');
      rcd_cad_order_summary.agreed_del_date := lics_inbound_utility.get_variable('AGREED_DEL_DATE');
      rcd_cad_order_summary.scheduled_del_date := lics_inbound_utility.get_variable('SCHEDULED_DEL_DATE');
      rcd_cad_order_summary.del_date := lics_inbound_utility.get_variable('DEL_DATE');
      rcd_cad_order_summary.pod_date := lics_inbound_utility.get_variable('POD_DATE');
      rcd_cad_order_summary.ord_qty := lics_inbound_utility.get_number('ORD_QTY',null);
      rcd_cad_order_summary.del_qty := lics_inbound_utility.get_number('DEL_QTY',null);
      rcd_cad_order_summary.pod_qty := lics_inbound_utility.get_number('POD_QTY',null);
      rcd_cad_order_summary.ord_niv := lics_inbound_utility.get_number('ORD_NIV',null);
      rcd_cad_order_summary.del_niv := lics_inbound_utility.get_number('DEL_NIV',null);
      rcd_cad_order_summary.pod_niv := lics_inbound_utility.get_number('POD_NIV',null);
      rcd_cad_order_summary.cad_load_date := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_cad_order_summary.ord_doc_num is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.ORD_DOC_NUM');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_cad_order_summary.ord_doc_line_num is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.ORD_DOC_LINE_NUM');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Delete Order Summary entry if it exists
      /*-*/
      delete cad_order_summary
       where ord_doc_num = rcd_cad_order_summary.ord_doc_num
         and ord_doc_line_num = rcd_cad_order_summary.ord_doc_line_num;

      insert into cad_order_summary
         (ord_doc_num,
          ord_doc_line_num,
          ord_lin_status,
          sap_order_type_code,
          sap_doc_currcy_code,
          sap_sold_to_cust_code,
          sap_bill_to_cust_code,
          sap_ship_to_cust_code,
          sap_plant_code,
          sap_material_code,
          sap_ord_qty_uom_code,
          ord_creation_date,
          agreed_del_date,
          scheduled_del_date,
          del_date,
          pod_date,
          ord_qty,
          del_qty,
          pod_qty,
          ord_niv,
          del_niv,
          pod_niv,
          cad_load_date)
      values
         (rcd_cad_order_summary.ord_doc_num,
          rcd_cad_order_summary.ord_doc_line_num,
          rcd_cad_order_summary.ord_lin_status,
          rcd_cad_order_summary.sap_order_type_code,
          rcd_cad_order_summary.sap_doc_currcy_code,
          rcd_cad_order_summary.sap_sold_to_cust_code,
          rcd_cad_order_summary.sap_bill_to_cust_code,
          rcd_cad_order_summary.sap_ship_to_cust_code,
          rcd_cad_order_summary.sap_plant_code,
          rcd_cad_order_summary.sap_material_code,
          rcd_cad_order_summary.sap_ord_qty_uom_code,
          rcd_cad_order_summary.ord_creation_date,
          rcd_cad_order_summary.agreed_del_date,
          rcd_cad_order_summary.scheduled_del_date,
          rcd_cad_order_summary.del_date,
          rcd_cad_order_summary.pod_date,
          rcd_cad_order_summary.ord_qty,
          rcd_cad_order_summary.del_qty,
          rcd_cad_order_summary.pod_qty,
          rcd_cad_order_summary.ord_niv,
          rcd_cad_order_summary.del_niv,
          rcd_cad_order_summary.pod_niv,
          rcd_cad_order_summary.cad_load_date);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladcad04_order_summary;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad04_order_summary for cad_app.ladcad04_order_summary;
grant execute on ladcad04_order_summary to lics_app;
