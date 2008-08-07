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
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_iface_geo_hierarchy iface_geo_hierarchy%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IFACE_CTL',3);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IFACE_HDR',3);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL1_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL2_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL3_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL4_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL5_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL1_NAME',50);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL2_NAME',50);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL3_NAME',50);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL4_NAME',50);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL5_NAME',50);

      /*-*/
      /* Clear the IFACE sales force hierarchy table
      /*-*/
      delete iface_geo_hierarchy;
      commit;

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
         when 'CTL' then process_record_ctl(par_record);
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
         rollback;
      elsif var_trn_error = true then
         rollback;
      else
         commit;
         efex_refresh.refresh_geo_hierarchy;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

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
      rcd_iface_geo_hierarchy.geo_level1_code := lics_inbound_utility.get_variable('GEO_LEVEL1_CODE');
      rcd_iface_geo_hierarchy.geo_level2_code := lics_inbound_utility.get_variable('GEO_LEVEL2_CODE');
      rcd_iface_geo_hierarchy.geo_level3_code := lics_inbound_utility.get_variable('GEO_LEVEL3_CODE');
      rcd_iface_geo_hierarchy.geo_level4_code := lics_inbound_utility.get_variable('GEO_LEVEL4_CODE');
      rcd_iface_geo_hierarchy.geo_level5_code := lics_inbound_utility.get_variable('GEO_LEVEL5_CODE');
      rcd_iface_geo_hierarchy.geo_level1_name := lics_inbound_utility.get_variable('GEO_LEVEL1_NAME');
      rcd_iface_geo_hierarchy.geo_level2_name := lics_inbound_utility.get_variable('GEO_LEVEL2_NAME');
      rcd_iface_geo_hierarchy.geo_level3_name := lics_inbound_utility.get_variable('GEO_LEVEL3_NAME');
      rcd_iface_geo_hierarchy.geo_level4_name := lics_inbound_utility.get_variable('GEO_LEVEL4_NAME');
      rcd_iface_geo_hierarchy.geo_level5_name := lics_inbound_utility.get_variable('GEO_LEVEL5_NAME');

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

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into iface_geo_hierarchy
         (geo_level1_code,
          geo_level2_code,
          geo_level3_code,
          geo_level4_code,
          geo_level5_code,
          geo_level1_name,
          geo_level2_name,
          geo_level3_name,
          geo_level4_name,
          geo_level5_name)
      values
         (rcd_iface_geo_hierarchy.geo_level1_code,
          rcd_iface_geo_hierarchy.geo_level2_code,
          rcd_iface_geo_hierarchy.geo_level3_code,
          rcd_iface_geo_hierarchy.geo_level4_code,
          rcd_iface_geo_hierarchy.geo_level5_code,
          rcd_iface_geo_hierarchy.geo_level1_name,
          rcd_iface_geo_hierarchy.geo_level2_name,
          rcd_iface_geo_hierarchy.geo_level3_name,
          rcd_iface_geo_hierarchy.geo_level4_name,
          rcd_iface_geo_hierarchy.geo_level5_name);

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
