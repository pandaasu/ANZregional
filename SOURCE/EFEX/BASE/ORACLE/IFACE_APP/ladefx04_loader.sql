/******************/
/* Package Header */
/******************/
create or replace package ladefx04_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx04_loader
    Owner   : iface_app

    Description
    -----------
    Efex - LADEFX04 - China Sales Force Geographic Hierarchy Loader

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladefx04_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx04_loader as

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
   rcd_cad_sales_force_geo_hier cad_sales_force_geo_hier%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','SAP_HIER_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE',2);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_1',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_1',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_1',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_1',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_1',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_1',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_2',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_2',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_2',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_2',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_2',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_2',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_3',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_3',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_3',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_3',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_3',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_3',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_4',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_4',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_4',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_4',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_4',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_4',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_5',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_5',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_5',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_5',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_5',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_5',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_6',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_6',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_6',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_6',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_6',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_6',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_7',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_7',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_7',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_7',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_7',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_7',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_8',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_8',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_8',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_8',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_8',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_8',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_9',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_9',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_9',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_9',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_9',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_9',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUST_CODE_LEVEL_10',10);
      lics_inbound_utility.set_definition('HDR','CUST_NAME_EN_LEVEL_10',40);
      lics_inbound_utility.set_definition('HDR','SAP_SALES_ORG_CODE_LEVEL_10',4);
      lics_inbound_utility.set_definition('HDR','SAP_DISTBN_CHNL_CODE_LEVEL_10',2);
      lics_inbound_utility.set_definition('HDR','SAP_DIVISION_CODE_LEVEL_10',2);
      lics_inbound_utility.set_definition('HDR','CUST_HIER_SORT_LEVEL_10',10);


      /*-*/
      /* Delete Price master entries
      /*-*/
      delete cad_sales_force_geo_hier;

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
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/      
      rcd_cad_sales_force_geo_hier.sap_hier_cust_code := lics_inbound_utility.get_variable('SAP_HIER_CUST_CODE');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE');
      rcd_cad_sales_force_geo_hier.sap_division_code := lics_inbound_utility.get_variable('SAP_DIVISION_CODE');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_1 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_1');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_1 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_1');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_1 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_1');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_1 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_1');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_1 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_1');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_1 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_1');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_2 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_2');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_2 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_2');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_2 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_2');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_2 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_2');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_2 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_2');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_2 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_2');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_3 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_3');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_3 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_3');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_3 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_3');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_3 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_3');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_3 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_3');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_3 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_3');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_4 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_4');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_4 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_4');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_4 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_4');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_4 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_4');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_4 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_4');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_4 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_4');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_5 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_5');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_5 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_5');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_5 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_5');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_5 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_5');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_5 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_5');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_5 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_5');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_6 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_6');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_6 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_6');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_6 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_6');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_6 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_6');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_6 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_6');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_6 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_6');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_7 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_7');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_7 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_7');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_7 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_7');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_7 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_7');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_7 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_7');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_7 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_7');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_8 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_8');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_8 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_8');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_8 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_8');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_8 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_8');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_8 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_8');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_8 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_8');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_9 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_9');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_9 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_9');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_9 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_9');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_9 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_9');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_9 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_9');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_9 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_9');
      rcd_cad_sales_force_geo_hier.sap_cust_code_level_10 := lics_inbound_utility.get_variable('SAP_CUST_CODE_LEVEL_10');
      rcd_cad_sales_force_geo_hier.cust_name_en_level_10 := lics_inbound_utility.get_variable('CUST_NAME_EN_LEVEL_10');
      rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_10 := lics_inbound_utility.get_variable('SAP_SALES_ORG_CODE_LEVEL_10');
      rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_10 := lics_inbound_utility.get_variable('SAP_DISTBN_CHNL_CODE_LEVEL_10');
      rcd_cad_sales_force_geo_hier.sap_division_code_level_10 := lics_inbound_utility.get_variable('SAP_DIVISION_CODE_LEVEL_10');
      rcd_cad_sales_force_geo_hier.cust_hier_sort_level_10 := lics_inbound_utility.get_variable('CUST_HIER_SORT_LEVEL_10');
      rcd_cad_sales_force_geo_hier.cad_load_date := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      insert into cad_sales_force_geo_hier
         (sap_hier_cust_code,
          sap_sales_org_code,
          sap_distbn_chnl_code,
          sap_division_code,
          sap_cust_code_level_1,
          cust_name_en_level_1,
          sap_sales_org_code_level_1,
          sap_distbn_chnl_code_level_1,
          sap_division_code_level_1,
          cust_hier_sort_level_1,
          sap_cust_code_level_2,
          cust_name_en_level_2,
          sap_sales_org_code_level_2,
          sap_distbn_chnl_code_level_2,
          sap_division_code_level_2,
          cust_hier_sort_level_2,
          sap_cust_code_level_3,
          cust_name_en_level_3,
          sap_sales_org_code_level_3,
          sap_distbn_chnl_code_level_3,
          sap_division_code_level_3,
          cust_hier_sort_level_3,
          sap_cust_code_level_4,
          cust_name_en_level_4,
          sap_sales_org_code_level_4,
          sap_distbn_chnl_code_level_4,
          sap_division_code_level_4,
          cust_hier_sort_level_4,
          sap_cust_code_level_5,
          cust_name_en_level_5,
          sap_sales_org_code_level_5,
          sap_distbn_chnl_code_level_5,
          sap_division_code_level_5,
          cust_hier_sort_level_5,
          sap_cust_code_level_6,
          cust_name_en_level_6,
          sap_sales_org_code_level_6,
          sap_distbn_chnl_code_level_6,
          sap_division_code_level_6,
          cust_hier_sort_level_6,
          sap_cust_code_level_7,
          cust_name_en_level_7,
          sap_sales_org_code_level_7,
          sap_distbn_chnl_code_level_7,
          sap_division_code_level_7,
          cust_hier_sort_level_7,
          sap_cust_code_level_8,
          cust_name_en_level_8,
          sap_sales_org_code_level_8,
          sap_distbn_chnl_code_level_8,
          sap_division_code_level_8,
          cust_hier_sort_level_8,
          sap_cust_code_level_9,
          cust_name_en_level_9,
          sap_sales_org_code_level_9,
          sap_distbn_chnl_code_level_9,
          sap_division_code_level_9,
          cust_hier_sort_level_9,
          sap_cust_code_level_10,
          cust_name_en_level_10,
          sap_sales_org_code_level_10,
          sap_distbn_chnl_code_level_10,
          sap_division_code_level_10,
          cust_hier_sort_level_10,
          cad_load_date)
      values
         (rcd_cad_sales_force_geo_hier.sap_hier_cust_code,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code,
          rcd_cad_sales_force_geo_hier.sap_division_code,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_1,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_1,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_1,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_1,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_1,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_1,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_2,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_2,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_2,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_2,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_2,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_2,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_3,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_3,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_3,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_3,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_3,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_3,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_4,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_4,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_4,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_4,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_4,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_4,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_5,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_5,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_5,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_5,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_5,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_5,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_6,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_6,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_6,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_6,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_6,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_6,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_7,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_7,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_7,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_7,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_7,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_7,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_8,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_8,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_8,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_8,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_8,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_8,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_9,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_9,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_9,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_9,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_9,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_9,
          rcd_cad_sales_force_geo_hier.sap_cust_code_level_10,
          rcd_cad_sales_force_geo_hier.cust_name_en_level_10,
          rcd_cad_sales_force_geo_hier.sap_sales_org_code_level_10,
          rcd_cad_sales_force_geo_hier.sap_distbn_chnl_code_level_10,
          rcd_cad_sales_force_geo_hier.sap_division_code_level_10,
          rcd_cad_sales_force_geo_hier.cust_hier_sort_level_10,
          rcd_cad_sales_force_geo_hier.cad_load_date);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladefx04_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx04_loader for iface_app.ladefx04_loader;
grant execute on ladefx04_loader to lics_app;
