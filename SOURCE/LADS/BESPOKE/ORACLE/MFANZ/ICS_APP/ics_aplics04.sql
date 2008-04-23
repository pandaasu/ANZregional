create or replace package ics_app.ics_aplics04 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_aplics04;

create or replace package body ics_app.ics_aplics04 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   type rcd_definition is record(value varchar2(4000 char),
                                 plant varchar2(4 char),
                                 bus_seg varchar2(2 char));
   type typ_definition is table of rcd_definition index by binary_integer;
   tbl_definition typ_definition;


   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_index number(5,0);

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
      tbl_definition.delete;
      var_index := 0;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('PLANT',2);
      lics_inbound_utility.set_csv_definition('MATL_CODE',3);
      lics_inbound_utility.set_csv_definition('STRT_TIME',4);
      lics_inbound_utility.set_csv_definition('QUANTITY',6);
      lics_inbound_utility.set_csv_definition('PURCHASE_ORDER',7);
      lics_inbound_utility.set_csv_definition('VENDOR_ID',8);
      lics_inbound_utility.set_csv_definition('UOM',9);
      lics_inbound_utility.set_csv_definition('CO_CODE',11);
      lics_inbound_utility.set_csv_definition('BUS_SEG',16);
      lics_inbound_utility.set_csv_definition('SOURCE_PLANT',26);

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
      con_delimiter CONSTANT varchar2(32)  := ',';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate data record
      /*-*/
      if (par_record) is null then
         raise_application_error(-20000, 'NULL line identified');
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

      var_index := tbl_definition.count + 1;

      /*-*/
      /* Retrieve field values
      /*-*/
      tbl_definition(var_index).value := rpad(substr(nvl(lics_inbound_utility.get_variable('PLANT'),' '),1,4),4)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('MATL_CODE'),' '),1,18),18)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('STRT_TIME'),' '),1,14),14)
                                         || lpad(substr(to_char(lics_inbound_utility.get_number('QUANTITY',null),'FM99999990.000'),1,13),13)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('VENDOR_ID'),' '),1,10),10)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('UOM'),' '),1,3),3)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('CO_CODE'),' '),1,4),4)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('BUS_SEG'),' '),1,2),2)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('SOURCE_PLANT'),' '),1,4),4)
                                         || rpad(substr(nvl(lics_inbound_utility.get_variable('PURCHASE_ORDER'),' '),1,10),10);

      tbl_definition(var_index).plant := substr(lics_inbound_utility.get_variable('PLANT'),1,4);
      tbl_definition(var_index).bus_seg := substr(lics_inbound_utility.get_variable('BUS_SEG'),1,2);

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR - Bypass further processing      */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;


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


      /*-*/
      /* Local definitions
      /*-*/
      var_interface number(15,0);
      var_file_name varchar2(64 char);
      var_message_name varchar2(64 char);
      var_count number;
      con_ob_interface_pet CONSTANT lics.lics_interface.int_interface%type  := 'ICSPPL04'; -- Petcare
      con_ob_interface_snkmca CONSTANT lics.lics_interface.int_interface%type  := 'ICSPDB04.5'; -- Snack - MCA
      con_ob_interface_snksco CONSTANT lics.lics_interface.int_interface%type  := 'ICSPDB04.6'; -- Snack - SCO

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------*/
      /* ERROR - Bypass output further processing */
      /*------------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Return when no outbound data exist
      /*-*/
      if tbl_definition.count = 0 then
         return;
      end if;

      /*------------------------*/
      /* Check Data - Snack Pet
      /*------------------------*/
      var_file_name := null;
      var_count := 0;

      for idx in 1..tbl_definition.count loop
	       if (tbl_definition(idx).bus_seg in ('05','00') and
             (upper(substr(tbl_definition(idx).plant,1,2)) = 'AU' or
              upper(substr(tbl_definition(idx).plant,1,4)) = 'NZ01' or
              upper(substr(tbl_definition(idx).plant,1,4)) = 'NZ12' or
              upper(substr(tbl_definition(idx).plant,1,4)) = 'NZ11')) then
            var_count := var_count + 1;
         end if;
      end loop;

      if  var_count != 0 then
         /*-*/
         /* Determine File Name
         /*   note : Monday - Saturday, remain constant so overwritten at destination
         /*          Sunday - unique so it can be archived and re-used at destination
         /*-*/
         if (trim(to_char(sysdate,'DAY')) = 'SUNDAY') then
            var_message_name := 'PUR_VIA_ATLAPL60_PET_' || to_char(sysdate,'YYYYMMDD') || '.dat';
         else
            var_message_name := 'PUR_VIA_ATLAPL60_PET.dat';
         end if;

         /*-*/
         /* Create Outbound Interface - Pet
         /*-*/
         var_interface := lics_outbound_loader.create_interface(con_ob_interface_pet, var_file_name, var_message_name);

         /*-*/
         /* Process data array
         /*-*/
         for idx in 1..tbl_definition.count loop

            /*-*/
            /* Write Outbound data based on filter logic
            /*-*/
            if (tbl_definition(idx).bus_seg in ('05','00') and
                 (upper(substr(tbl_definition(idx).plant,1,2)) = 'AU' or
                  upper(substr(tbl_definition(idx).plant,1,4)) = 'NZ01' or
                  upper(substr(tbl_definition(idx).plant,1,4)) = 'NZ12' or
                  upper(substr(tbl_definition(idx).plant,1,4)) = 'NZ11')) then
               lics_outbound_loader.append_data(tbl_definition(idx).value);
            end if;

         end loop;

         /*-*/
         /* Finalise Outbound Interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      end if;

      /*------------------------*/
      /* Check Data - Snack MCA
      /*------------------------*/
      var_file_name := null;
      var_count := 0;

      for idx in 1..tbl_definition.count loop
         if (tbl_definition(idx).bus_seg in ('01','00') and
             (upper(substr(tbl_definition(idx).plant,1,2)) = 'AU')) then
            var_count := var_count + 1;
         end if;
      end loop;

      if  var_count != 0 then

         /*-*/
         /* Create Outbound Interface - Snack - Ballarat
         /*-*/
         var_message_name := 'PUR_VIA_ATLAPL60_MCA.dat';
         var_interface := lics_outbound_loader.create_interface(con_ob_interface_snkmca, var_file_name, var_message_name);

         /*-*/
         /* Process data array
         /*-*/
         for idx in 1..tbl_definition.count loop

            /*-*/
            /* Write Outbound data based on filter logic
            /*-*/
            if (tbl_definition(idx).bus_seg in ('01','00') and
                 (upper(substr(tbl_definition(idx).plant,1,2)) = 'AU')) then
               lics_outbound_loader.append_data(tbl_definition(idx).value);
            end if;

         end loop;

         /*-*/
         /* Finalise Outbound Interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      end if;

      /*------------------------*/
      /* Check Data - Snack SCO
      /*------------------------*/
      var_file_name := null;
      var_count := 0;

      for idx in 1..tbl_definition.count loop
         if (tbl_definition(idx).bus_seg in ('01','00') and
             (upper(substr(tbl_definition(idx).plant,1,2)) = 'AU')) then
            var_count := var_count + 1;
         end if;
      end loop;

      if  var_count != 0 then

         /*-*/
         /* Create Outbound Interface - Snack - Scoreby
         /*-*/
         var_message_name := 'PUR_VIA_ATLAPL60_SCO.dat';
         var_interface := lics_outbound_loader.create_interface(con_ob_interface_snksco, var_file_name, var_message_name);

         /*-*/
         /* Process data array
         /*-*/
         for idx in 1..tbl_definition.count loop

            /*-*/
            /* Write Outbound data based on filter logic
            /*-*/
            if (tbl_definition(idx).bus_seg in ('01','00') and
                 (upper(substr(tbl_definition(idx).plant,1,2)) = 'AU')) then
               lics_outbound_loader.append_data(tbl_definition(idx).value);
            end if;

         end loop;

         /*-*/
         /* Finalise Outbound Interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end ics_aplics04;

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.ics_aplics04 to ics_executor;
grant execute on ics_app.ics_aplics04 to lics_app;
grant execute on ics_app.ics_aplics04 to public;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ics_aplics04 for ics_app.ics_aplics04; 
