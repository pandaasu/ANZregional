/******************/
/* Package Header */
/******************/
create or replace package cts_tolcts01 as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : cts
 Package : cts_tolcts01
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Cost To Server - Tolas to CTS Delivery Interface

 YYYY/MM   Author          Description
 -------   ------          -----------
 2006/06   Steve Gregan    Created
 2006/08   Steve Gregan    Added Tolas shipment load number

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end cts_tolcts01;
/

/****************/
/* Package Body */
/****************/
create or replace package body cts_tolcts01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_cts_del_hdr cts_del_hdr%rowtype;

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
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','HDR_RCDTYP',3);
      lics_inbound_utility.set_definition('HDR','HDR_DELNUM',12);
      lics_inbound_utility.set_definition('HDR','HDR_SHPNUM',18);
      lics_inbound_utility.set_definition('HDR','HDR_SHPDAT',10);
      lics_inbound_utility.set_definition('HDR','HDR_DELRTE',30);
      lics_inbound_utility.set_definition('HDR','HDR_SHPCAR',30);
      lics_inbound_utility.set_definition('HDR','HDR_SHPVEH',30);
      lics_inbound_utility.set_definition('HDR','HDR_SHPFUP',8);
      lics_inbound_utility.set_definition('HDR','HDR_SHPPAL',8);
      lics_inbound_utility.set_definition('HDR','HDR_SHPCAS',8);
      lics_inbound_utility.set_definition('HDR','HDR_DELPAL',8);
      lics_inbound_utility.set_definition('HDR','HDR_DELFUP',8);
      lics_inbound_utility.set_definition('HDR','HDR_DELEPS',13);
      lics_inbound_utility.set_definition('HDR','HDR_DELCAS',8);
      lics_inbound_utility.set_definition('HDR','HDR_DELVOL',13);
      lics_inbound_utility.set_definition('HDR','HDR_DELWGT',13);
      lics_inbound_utility.set_definition('HDR','HDR_SHPLOD',15);

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

      /*-*/
      /* Set the control values
      /*-*/
      var_trn_start := false;

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
      /* No data found
      /*-*/
      if var_trn_start = true then
         lics_inbound_utility.add_exception('Interface file contains no data');
         var_trn_error := true;
      end if;

      /*-*/
      /* Commit the database when required
      /*-*/
      if var_trn_error = false and
         var_trn_ignore = false then
         commit;
      else
         rollback;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

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

      rcd_cts_del_hdr.cdh_delv_nbr := lics_inbound_utility.get_variable('HDR_DELNUM');
      rcd_cts_del_hdr.cdh_ship_nbr := lics_inbound_utility.get_variable('HDR_SHPNUM');
      rcd_cts_del_hdr.cdh_ship_dte := lics_inbound_utility.get_variable('HDR_SHPDAT');
      rcd_cts_del_hdr.cdh_delv_rte := lics_inbound_utility.get_variable('HDR_DELRTE');
      rcd_cts_del_hdr.cdh_ship_lod := lics_inbound_utility.get_variable('HDR_SHPLOD');
      rcd_cts_del_hdr.cdh_ship_car := lics_inbound_utility.get_variable('HDR_SHPCAR');
      rcd_cts_del_hdr.cdh_ship_veh := lics_inbound_utility.get_variable('HDR_SHPVEH');
      rcd_cts_del_hdr.cdh_ship_fup := lics_inbound_utility.get_number('HDR_SHPFUP',null);
      rcd_cts_del_hdr.cdh_ship_pal := lics_inbound_utility.get_number('HDR_SHPPAL',null);
      rcd_cts_del_hdr.cdh_ship_cas := lics_inbound_utility.get_number('HDR_SHPCAS',null);
      rcd_cts_del_hdr.cdh_delv_pal := lics_inbound_utility.get_number('HDR_DELPAL',null);
      rcd_cts_del_hdr.cdh_delv_fup := lics_inbound_utility.get_number('HDR_DELFUP',null);
      rcd_cts_del_hdr.cdh_delv_eps := lics_inbound_utility.get_number('HDR_DELEPS',null);
      rcd_cts_del_hdr.cdh_delv_cas := lics_inbound_utility.get_number('HDR_DELCAS',null);
      rcd_cts_del_hdr.cdh_delv_vol := lics_inbound_utility.get_number('HDR_DELVOL',null);
      rcd_cts_del_hdr.cdh_delv_wgt := lics_inbound_utility.get_number('HDR_DELWGT',null);

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
      /* Validate the values
      /*-*/
      if rcd_cts_del_hdr.cdh_delv_nbr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - Delivery number');
         var_trn_error := true;
      end if;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
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

      update cts_del_hdr set
         cdh_ship_nbr = rcd_cts_del_hdr.cdh_ship_nbr,
         cdh_ship_dte = rcd_cts_del_hdr.cdh_ship_dte,
         cdh_delv_rte = rcd_cts_del_hdr.cdh_delv_rte,
         cdh_ship_lod = rcd_cts_del_hdr.cdh_ship_lod,
         cdh_ship_car = rcd_cts_del_hdr.cdh_ship_car,
         cdh_ship_veh = rcd_cts_del_hdr.cdh_ship_veh,
         cdh_ship_fup = rcd_cts_del_hdr.cdh_ship_fup,
         cdh_ship_pal = rcd_cts_del_hdr.cdh_ship_pal,
         cdh_ship_cas = rcd_cts_del_hdr.cdh_ship_cas,
         cdh_delv_pal = rcd_cts_del_hdr.cdh_delv_pal,
         cdh_delv_fup = rcd_cts_del_hdr.cdh_delv_fup,
         cdh_delv_eps = rcd_cts_del_hdr.cdh_delv_eps,
         cdh_delv_cas = rcd_cts_del_hdr.cdh_delv_cas,
         cdh_delv_vol = rcd_cts_del_hdr.cdh_delv_vol,
         cdh_delv_wgt = rcd_cts_del_hdr.cdh_delv_wgt
      where cdh_delv_nbr = rcd_cts_del_hdr.cdh_delv_nbr;
      if sql%notfound then
         insert into cts_del_hdr
            (cdh_delv_nbr,
             cdh_ship_nbr,
             cdh_ship_dte,
             cdh_delv_rte,
             cdh_ship_lod,
             cdh_ship_car,
             cdh_ship_veh,
             cdh_ship_fup,
             cdh_ship_pal,
             cdh_ship_cas,
             cdh_delv_pal,
             cdh_delv_fup,
             cdh_delv_eps,
             cdh_delv_cas,
             cdh_delv_vol,
             cdh_delv_wgt)
         values
            (rcd_cts_del_hdr.cdh_delv_nbr,
             rcd_cts_del_hdr.cdh_ship_nbr,
             rcd_cts_del_hdr.cdh_ship_dte,
             rcd_cts_del_hdr.cdh_delv_rte,
             rcd_cts_del_hdr.cdh_ship_lod,
             rcd_cts_del_hdr.cdh_ship_car,
             rcd_cts_del_hdr.cdh_ship_veh,
             rcd_cts_del_hdr.cdh_ship_fup,
             rcd_cts_del_hdr.cdh_ship_pal,
             rcd_cts_del_hdr.cdh_ship_cas,
             rcd_cts_del_hdr.cdh_delv_pal,
             rcd_cts_del_hdr.cdh_delv_fup,
             rcd_cts_del_hdr.cdh_delv_eps,
             rcd_cts_del_hdr.cdh_delv_cas,
             rcd_cts_del_hdr.cdh_delv_vol,
             rcd_cts_del_hdr.cdh_delv_wgt);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end cts_tolcts01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym cts_tolcts01 for ics_app.cts_tolcts01;
grant execute on cts_tolcts01 to public;