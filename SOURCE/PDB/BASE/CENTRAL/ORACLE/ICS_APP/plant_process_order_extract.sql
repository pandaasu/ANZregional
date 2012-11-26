CREATE OR REPLACE PACKAGE ICS_APP.plant_process_order_extract
as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : Site Application 
 Package : plant_process_order_extract 
 Owner   : ics_app 
 Author  : Steve Gregan 

 Description
 -----------
 Site Application - ATLLAD01 - Plant Database Interface 
 Sends the converted procedure order data as a file to the specified plant database 

 YYYY/MM     Author         Description 
 -------     ------         ----------- 
 01_Jun-2007 Steve Gregan   Created 
 12-Oct-2007 JP             Added filtering to not send to petcare, Food and WGI 
 26-Oct-2007 JP             Remove plant specific filtering 
 28-Feb-2008 Trevor Keon    Changed schema to ICS_APP from SITE_APP
 10-Dec-2008 Trevor Keon    Added check for missing ',' when doing to_number with FM999G999G999D999 
                                format using convert_to_number. 
 2011/12    B. Halicki      Added trigger option for sending to systems without V2
 2012/11    B. Halicki      Removed Scoresby (SCO)
  
*******************************************************************************/

   /*-*/
   /* Public declarations 
   /*-*/
   procedure execute (par_cntl_rec_id in number);
end plant_process_order_extract;
/

CREATE OR REPLACE PUBLIC SYNONYM PLANT_PROCESS_ORDER_EXTRACT FOR ICS_APP.PLANT_PROCESS_ORDER_EXTRACT;
CREATE OR REPLACE PACKAGE BODY ICS_APP.plant_process_order_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_zordine;
   procedure process_zatlas;
   procedure process_zatlasa;
   procedure process_zmessrc;
   procedure process_zphpan1;
   procedure process_zphbrq1;
   function convert_to_number(par_value varchar2) return number;

   /*-*/
   /* Private definitions
   /*-*/
   var_zordine      boolean;
   var_interface    varchar2(32 char);
   var_trigger      varchar2(32 char);
   rcd_lads_ctl_rec_hpi lads_ctl_rec_hpi%rowtype;
   rcd_lads_ctl_rec_tpi lads_ctl_rec_tpi%rowtype;
   type rcd_recipe_header is record(proc_order varchar2(12 char),
                                    cntl_rec_id number(18,0),
                                    plant varchar2(4 char),
                                    cntl_rec_status varchar2(5 char),
                                    test_flag varchar2(1 char),
                                    recipe_text varchar2(40 char),
                                    material varchar2(18 char),
                                    material_text varchar2(40 char),
                                    quantity number,
                                    insplot varchar2(12 char),
                                    uom varchar2(4 char),
                                    batch varchar2(10 char),
                                    sched_start_datime date,
                                    run_start_datime date,
                                    run_end_datime date,
                                    version number,
                                    upd_datime date,
                                    cntl_rec_xfer varchar2(1 char),
                                    teco_status varchar2(4 char),
                                    storage_locn varchar2(4 char),
                                    idoc_timestamp varchar2(16 char));
   type rcd_recipe_bom is record(proc_order varchar2(12 char),
                                 operation varchar2(4 char),
                                 phase varchar2(4 char),
                                 seq varchar2(4 char),
                                 material_code varchar2(18 char),
                                 material_desc varchar2(40 char),
                                 material_qty number,
                                 material_uom varchar2(4 char),
                                 material_prnt varchar2(18 char),
                                 bf_item varchar2(1 char),
                                 reservation varchar2(40 char),
                                 plant varchar2(4 char),
                                 pan_size number,
                                 last_pan_size number,
                                 pan_size_flag varchar2(1 char),
                                 pan_qty number,
                                 phantom varchar2(1 char),
                                 operation_from varchar2(4 char));
   type rcd_recipe_resource is record(proc_order varchar2(12 char),
                                      operation varchar2(4 char),
                                      resource_code varchar2(9 char),
                                      batch_qty number,
                                      batch_uom varchar2(4 char),
                                      phantom varchar2(8 char),
                                      phantom_desc varchar2(40 char),
                                      phantom_qty varchar2(20 char),
                                      phantom_uom varchar2(10 char),
                                      plant varchar2(4 char));
   type rcd_recipe_src_text is record(proc_order varchar2(12 char),
                                      operation varchar2(4 char),
                                      phase varchar2(4 char),
                                      seq varchar2(4 char),
                                      src_type varchar2(1 char),
                                      machine_code varchar2(4 char),
                                      plant varchar2(4 char),
                                      txt01_sidx number,
                                      txt01_eidx number,
                                      txt02_sidx number,
                                      txt02_eidx number);
   type rcd_recipe_src_value is record(proc_order varchar2(12 char),
                                       operation varchar2(4 char),
                                       phase varchar2(4 char),
                                       seq varchar2(4 char),
                                       src_tag varchar2(40 char),
                                       src_val varchar2(30 char),
                                       src_uom varchar2(20 char),
                                       machine_code varchar2(4 char),
                                       plant varchar2(4 char),
                                       txt01_sidx number,
                                       txt01_eidx number,
                                       txt02_sidx number,
                                       txt02_eidx number);
   type rcd_recipe_text is record(proc_order varchar2(12 char),
                                  operation varchar2(4 char),
                                  phase varchar2(4 char),
                                  seq varchar2(4 char),
                                  text_data varchar2(500 char));
   row_recipe_header rcd_recipe_header;
   row_recipe_bom rcd_recipe_bom;
   row_recipe_resource rcd_recipe_resource;
   row_recipe_src_text rcd_recipe_src_text;
   row_recipe_src_value rcd_recipe_src_value;
   row_recipe_text rcd_recipe_text;
   type typ_recipe_header is table of rcd_recipe_header index by binary_integer;
   type typ_recipe_bom is table of rcd_recipe_bom index by binary_integer;
   type typ_recipe_resource is table of rcd_recipe_resource index by varchar2(32);
   type typ_recipe_src_text is table of rcd_recipe_src_text index by binary_integer;
   type typ_recipe_src_value is table of rcd_recipe_src_value index by binary_integer;
   type typ_recipe_text is table of rcd_recipe_text index by binary_integer;
   tbl_recipe_header typ_recipe_header;
   tbl_recipe_bom typ_recipe_bom;
   tbl_recipe_resource typ_recipe_resource;
   tbl_recipe_src_text typ_recipe_src_text;
   tbl_recipe_src_value typ_recipe_src_value;
   tbl_recipe_text01 typ_recipe_text;
   tbl_recipe_text02 typ_recipe_text;

   /*****************************************************/
   /* This procedure perfroms the BDS Interface routine */
   /*****************************************************/
   procedure execute(par_cntl_rec_id IN number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_lookup varchar2(32);
      var_instance number(15,0);
      var_output varchar2(4000);
      var_ignore boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_hpi_01 is
         select t01.cntl_rec_id,
                t01.plant,
                t01.proc_order,
                t01.dest,
                t01.dest_address,
                t01.dest_type,
                t01.cntl_rec_status,
                t01.test_flag,
                t01.recipe_text,
                t01.material,
                t01.material_text,
                t01.insplot,
                t01.material_external,
                t01.material_guid,
                t01.material_version,
                t01.batch,
                t01.scheduled_start_date,
                t01.scheduled_start_time,
                t01.idoc_name,
                t01.idoc_number,
                t01.idoc_timestamp,
                t01.lads_date,
                t01.lads_status,
                t01.lads_flattened
           from lads_ctl_rec_hpi t01
          where t01.cntl_rec_id = par_cntl_rec_id;

      cursor csr_lads_ctl_rec_tpi_01 is
         select t01.cntl_rec_id,
                t01.proc_instr_number,
                t01.proc_instr_type,
                t01.proc_instr_category,
                t01.proc_instr_line_no,
                t01.phase_number
           from lads_ctl_rec_tpi t01
          where t01.cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id
       order by t01.proc_instr_number asc;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_recipe_header.delete;
      tbl_recipe_bom.delete;
      tbl_recipe_resource.delete;
      tbl_recipe_src_text.delete;
      tbl_recipe_src_value.delete;
      tbl_recipe_text01.delete;
      tbl_recipe_text02.delete;

      var_ignore := false;
      
      /*-*/
      /* Retrieve the control recipe HPI from the LADS schema
      /*-*/
      open csr_lads_ctl_rec_hpi_01;
      fetch csr_lads_ctl_rec_hpi_01 into rcd_lads_ctl_rec_hpi;
      if csr_lads_ctl_rec_hpi_01%notfound then
         raise_application_error(-20000, 'Execute - Control recipe id (' || to_char(par_cntl_rec_id) || ') does not exist');
      end if;
      close csr_lads_ctl_rec_hpi_01;

      /*-*/
      /* Initialise the ZORDINE indicators
      /*-*/
      var_zordine := false;

      /*-*/
      /* Retrieve the related control recipe TPI rows
      /*-*/
      open csr_lads_ctl_rec_tpi_01;
      loop
         fetch csr_lads_ctl_rec_tpi_01 into rcd_lads_ctl_rec_tpi;
         if csr_lads_ctl_rec_tpi_01%notfound then
            exit;
         end if;

         /*-*/
         /* Process the related control recipe VPI rows based on intruction category
         /*-*/
         case rcd_lads_ctl_rec_tpi.proc_instr_category
            when 'ZORDINE' then process_zordine;
            when 'ZATLAS'  then process_zatlas;
            when 'ZBFBRQ1' then process_zatlas;
            when 'ZATLASA' then process_zatlasa;
            when 'ZACBRQ1' then process_zatlasa;
            when 'ZMESSRC' then process_zmessrc;
            when 'ZSRC'    then process_zmessrc;
            when 'ZPHPAN1' then process_zphpan1;
            when 'ZPHBRQ1' then process_zphbrq1;
            when 'ZATLAS2' then null;
            else raise_application_error(-20000, 'Execute - Control recipe id (' || to_char(rcd_lads_ctl_rec_hpi.cntl_rec_id) || ') process instruction category (' || rcd_lads_ctl_rec_tpi.proc_instr_category || ') not recognised on LADS_CTL_REC_TPI');
         end case;

      end loop;
      close csr_lads_ctl_rec_tpi_01;

      /*-*/
      /* Control recipe must have one ZORDINE process instruction
      /*-*/
      if var_zordine = false then
         raise_application_error(-20000, 'Execute - Control recipe id (' || to_char(rcd_lads_ctl_rec_hpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      end if;

      /*-*/
      /* Create the process order interface
      /*-*/
      var_ignore := false;
      if rcd_lads_ctl_rec_hpi.plant = 'AU10' then
         var_interface := 'LADPDB01.1';
         var_trigger := 'Y';
      elsif rcd_lads_ctl_rec_hpi.plant = 'NZ01' then
         var_interface := 'LADPDB01.2';
         var_trigger := 'Y';         
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU20' then
         var_interface := 'LADPDB01.3';
         var_trigger := 'N';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU21' then
         var_interface := 'LADPDB01.3';
         var_trigger := 'N';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU22' then
         var_interface := 'LADPDB01.3';
         var_trigger := 'N';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU23' then
         var_interface := 'LADPDB01.3';
         var_trigger := 'N';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU24' then
         var_interface := 'LADPDB01.3';
         var_trigger := 'N';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU25' then
         var_interface := 'LADPDB01.3';
         var_trigger := 'N';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU30' then
         var_interface := 'LADPDB01.4';
         var_trigger := 'Y';
      elsif rcd_lads_ctl_rec_hpi.plant = 'AU40' then
         var_interface := 'LADPDB01.5';
         var_trigger := 'Y';
      else
         raise_application_error(-20000, 'Execute - Control recipe id (' || to_char(rcd_lads_ctl_rec_hpi.cntl_rec_id) || ') plant (' || rcd_lads_ctl_rec_hpi.plant || ') not defined for plant database interface');
      end if;
      
      /*-*/
      if not var_ignore then
          
          if upper(var_trigger) = 'Y' then
             var_instance := lics_outbound_loader.create_interface(var_interface, null, var_interface);
          else
             var_instance := lics_outbound_loader.create_interface(var_interface);
          end if;
  
          for idx in 1..tbl_recipe_header.count loop
             var_output := 'HDR';
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).proc_order,' '),12,' ');
             var_output := var_output || rpad(to_char(tbl_recipe_header(idx).cntl_rec_id,'fm999999999999999990'),18,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).plant,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).cntl_rec_status,' '),5,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).test_flag,' '),1,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).recipe_text,' '),40,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).material,' '),18,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).material_text,' '),40,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_header(idx).quantity),0),38,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).insplot,' '),12,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).uom,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).batch,' '),10,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_header(idx).sched_start_datime,'yyyymmddhh24miss'),' '),14,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_header(idx).run_start_datime,'yyyymmddhh24miss'),' '),14,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_header(idx).run_end_datime,'yyyymmddhh24miss'),' '),14,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_header(idx).version),0),38,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_header(idx).upd_datime,'yyyymmddhh24miss'),' '),14,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).cntl_rec_xfer,' '),1,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).teco_status,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).storage_locn,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_header(idx).idoc_timestamp,' '),16,' ');
             lics_outbound_loader.append_data(var_output);
          end loop;
    
          /*-*/
    
          for idx in 1..tbl_recipe_bom.count loop
             var_output := 'BOM';
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).proc_order,' '),12,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).operation,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).phase,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).seq,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).material_code,' '),18,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).material_desc,' '),40,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_bom(idx).material_qty),-1),38,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).material_uom,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).material_prnt,' '),18,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).bf_item,' '),1,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).reservation,' '),40,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).plant,' '),4,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_bom(idx).pan_size),-1),38,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_bom(idx).last_pan_size),-1),38,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).pan_size_flag,' '),1,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_bom(idx).pan_qty),-1),38,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).phantom,' '),1,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_bom(idx).operation_from,' '),4,' ');
             lics_outbound_loader.append_data(var_output);
          end loop;
    
          /*-*/
    
          var_lookup := tbl_recipe_resource.first;
          while not(var_lookup is null) loop
             var_output := 'RES';
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).proc_order,' '),12,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).operation,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).resource_code,' '),9,' ');
             var_output := var_output || rpad(nvl(to_char(tbl_recipe_resource(var_lookup).batch_qty),-1),38,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).batch_uom,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).phantom,' '),8,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).phantom_desc,' '),40,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).phantom_qty,' '),20,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).phantom_uom,' '),10,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_resource(var_lookup).plant,' '),4,' ');
             lics_outbound_loader.append_data(var_output);
             var_lookup := tbl_recipe_resource.next(var_lookup);
          end loop;

          /*-*/
    
          for idx in 1..tbl_recipe_src_text.count loop
             var_output := 'STX';
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).proc_order,' '),12,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).operation,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).phase,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).seq,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).src_type,' '),1,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).machine_code,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_text(idx).plant,' '),4,' ');
             lics_outbound_loader.append_data(var_output);
             for tidx in tbl_recipe_src_text(idx).txt01_sidx..tbl_recipe_src_text(idx).txt01_eidx loop
                var_output := 'ST1';
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).proc_order,' '),12,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).operation,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).phase,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).seq,' '),4,' ');
                var_output := var_output || nvl(tbl_recipe_text01(tidx).text_data,' ');
                lics_outbound_loader.append_data(var_output);
             end loop;
             for tidx in tbl_recipe_src_text(idx).txt02_sidx..tbl_recipe_src_text(idx).txt02_eidx loop
                var_output := 'ST2';
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).proc_order,' '),12,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).operation,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).phase,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).seq,' '),4,' ');
                var_output := var_output || nvl(tbl_recipe_text02(tidx).text_data,' ');
                lics_outbound_loader.append_data(var_output);
             end loop;
          end loop;

          /*-*/
    
          for idx in 1..tbl_recipe_src_value.count loop
             var_output := 'SVL';
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).proc_order,' '),12,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).operation,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).phase,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).seq,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).src_tag,' '),40,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).SRC_VAL,' '),30,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).src_uom,' '),20,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).machine_code,' '),4,' ');
             var_output := var_output || rpad(nvl(tbl_recipe_src_value(idx).plant,' '),4,' ');
             lics_outbound_loader.append_data(var_output);
             for tidx in tbl_recipe_src_value(idx).txt01_sidx..tbl_recipe_src_value(idx).txt01_eidx loop
                var_output := 'SV1';
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).proc_order,' '),12,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).operation,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).phase,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text01(tidx).seq,' '),4,' ');
                var_output := var_output || nvl(tbl_recipe_text01(tidx).text_data,' ');
                lics_outbound_loader.append_data(var_output);
             end loop;
             for tidx in tbl_recipe_src_value(idx).txt02_sidx..tbl_recipe_src_value(idx).txt02_eidx loop
                var_output := 'SV2';
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).proc_order,' '),12,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).operation,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).phase,' '),4,' ');
                var_output := var_output || rpad(nvl(tbl_recipe_text02(tidx).seq,' '),4,' ');
                var_output := var_output || nvl(tbl_recipe_text02(tidx).text_data,' ');
                lics_outbound_loader.append_data(var_output);
             end loop;
          end loop;

          /*-*/
    
          lics_outbound_loader.finalise_interface;
      end if;
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
         /* Save the exception
         /*-*/
         var_exception := substr(sqlerrm, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'PLANT_PROCESS_ORDER_EXTRACT - ' || 'CNTL_REC_ID: ' || to_char(par_cntl_rec_id) || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*******************************************************/
   /* This procedure performs the process ZORDINE routine */
   /*******************************************************/
   procedure process_zordine is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_vpi_01 is
         select t01.pppi_process_order,
                t01.pppi_order_quantity,
                t01.pppi_unit_of_measure,
                t01.pppi_storage_location,
                t01.zpppi_order_start_date,
                t01.zpppi_order_start_time,
                t01.zpppi_order_end_date,
                t01.zpppi_order_end_time,
                t01.z_teco_status
           from (select t01.cntl_rec_id,
                        t01.proc_instr_number,
                        max(case when t01.name_char = 'PPPI_PROCESS_ORDER' then t01.char_value end) as pppi_process_order,
                        max(case when t01.name_char = 'PPPI_ORDER_QUANTITY' then t01.char_value end) as pppi_order_quantity,
                        max(case when t01.name_char = 'PPPI_UNIT_OF_MEASURE' then t01.char_value end) as pppi_unit_of_measure,
                        max(case when t01.name_char = 'PPPI_STORAGE_LOCATION' then t01.char_value end) as pppi_storage_location,
                        max(case when t01.name_char = 'ZPPPI_ORDER_START_DATE' then t01.char_value end) as zpppi_order_start_date,
                        max(case when t01.name_char = 'ZPPPI_ORDER_START_TIME' then t01.char_value end) as zpppi_order_start_time,
                        max(case when t01.name_char = 'ZPPPI_ORDER_END_DATE' then t01.char_value end) as zpppi_order_end_date,
                        max(case when t01.name_char = 'ZPPPI_ORDER_END_TIME' then t01.char_value end) as zpppi_order_end_time,
                        max(case when t01.name_char = 'Z_TECO_STATUS' then t01.char_value end) as z_teco_status
                   from lads_ctl_rec_vpi t01
                  where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    and t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               group by t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Control recipe can only have one ZORDINE process instruction
      /*-*/
      if var_zordine = true then
         raise_application_error(-20000, 'Process ZORDINE - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') has multiple ZORDINE process instructions on LADS_CTL_REC_TPI');
      end if;
      var_zordine := true;

      /*-*/
      /* Retrieve the ZORDINE data (LADS schema)
      /*-*/
      open csr_lads_ctl_rec_vpi_01;
      fetch csr_lads_ctl_rec_vpi_01 into rcd_lads_ctl_rec_vpi;
      if csr_lads_ctl_rec_vpi_01%notfound then
         raise_application_error(-20000, 'Process ZORDINE - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || to_char(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      end if;
      close csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_header row data
      /*-*/
      row_recipe_header.proc_order := rcd_lads_ctl_rec_vpi.pppi_process_order;
      if row_recipe_header.proc_order is null then
         raise_application_error(-20000, 'Process ZORDINE - Field - PROC_ORDER - Must not be null');
      end if;

      row_recipe_header.cntl_rec_id := rcd_lads_ctl_rec_hpi.cntl_rec_id;

      row_recipe_header.plant := rcd_lads_ctl_rec_hpi.plant;
      if row_recipe_header.plant is null then
         raise_application_error(-20000, 'Process ZORDINE - Field - PLANT - Must not be null');
      end if;

      row_recipe_header.cntl_rec_status := rcd_lads_ctl_rec_hpi.cntl_rec_status;

      row_recipe_header.test_flag := rcd_lads_ctl_rec_hpi.test_flag;

      row_recipe_header.recipe_text := rcd_lads_ctl_rec_hpi.recipe_text;

      row_recipe_header.material := rcd_lads_ctl_rec_hpi.material;
      if row_recipe_header.material is null then
         raise_application_error(-20000, 'Process ZORDINE - Field - MATERIAL - Must not be null');
      end if;

      row_recipe_header.material_text := rcd_lads_ctl_rec_hpi.material_text;

      row_recipe_header.quantity := null;
      begin
         row_recipe_header.quantity := to_number(rcd_lads_ctl_rec_vpi.pppi_order_quantity);
      exception
         when others then
            raise_application_error(-20000, 'Process ZORDINE - Field - QUANTITY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_order_quantity || ') to a number');
      end;

      row_recipe_header.insplot := rcd_lads_ctl_rec_hpi.insplot;
      row_recipe_header.uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;
      row_recipe_header.batch := rcd_lads_ctl_rec_hpi.batch;
      row_recipe_header.sched_start_datime := null;
      
      begin
         row_recipe_header.sched_start_datime := to_date(rcd_lads_ctl_rec_hpi.scheduled_start_date || rcd_lads_ctl_rec_hpi.scheduled_start_time,'YYYYMMDDHH24MISS');
      exception
         when others then
            raise_application_error(-20000, 'Process ZORDINE - Field - SCHED_START_DATIME - Unable to convert (' || rcd_lads_ctl_rec_hpi.scheduled_start_date || rcd_lads_ctl_rec_hpi.scheduled_start_time || ') to a date using format (YYYYMMDDHH24MISS)');
      end;

      row_recipe_header.run_start_datime := null;
      begin
         row_recipe_header.run_start_datime := to_date(rcd_lads_ctl_rec_vpi.zpppi_order_start_date || rcd_lads_ctl_rec_vpi.zpppi_order_start_time,'YYYYMMDDHH24MISS');
      exception
         when others then
            raise_application_error(-20000, 'Process ZORDINE - Field - RUN_START_DATIME - Unable to convert (' || rcd_lads_ctl_rec_vpi.zpppi_order_start_date || rcd_lads_ctl_rec_vpi.zpppi_order_start_time || ') to a date using format (YYYYMMDDHH24MISS)');
      end;
      if row_recipe_header.run_start_datime is null then
         raise_application_error(-20000, 'Process ZORDINE - Field - RUN_START_DATIME - Must not be null');
      end if;

      row_recipe_header.run_end_datime := null;
      begin
         row_recipe_header.run_end_datime := to_date(rcd_lads_ctl_rec_vpi.zpppi_order_end_date || rcd_lads_ctl_rec_vpi.zpppi_order_end_time,'YYYYMMDDHH24MISS');
      exception
         when others then
            raise_application_error(-20000, 'Process ZORDINE - Field - RUN_END_DATIME - Unable to convert (' || rcd_lads_ctl_rec_vpi.zpppi_order_end_date || rcd_lads_ctl_rec_vpi.zpppi_order_end_time || ') to a date using format (YYYYMMDDHH24MISS)');
      end;
      if row_recipe_header.run_end_datime is null then
         raise_application_error(-20000,' Process ZORDINE - Field - RUN_END_DATIME - Must not be null');
      end if;

      row_recipe_header.version := 1;
      row_recipe_header.upd_datime := sysdate;
      row_recipe_header.cntl_rec_xfer := 'N';
      row_recipe_header.teco_status := rcd_lads_ctl_rec_vpi.z_teco_status;
      row_recipe_header.storage_locn := rcd_lads_ctl_rec_vpi.pppi_storage_location;
      row_recipe_header.idoc_timestamp := rcd_lads_ctl_rec_hpi.idoc_timestamp;

      /*-*/
      /* Create the process order header
      /*-*/
      tbl_recipe_header(tbl_recipe_header.count + 1).proc_order := row_recipe_header.proc_order;
      tbl_recipe_header(tbl_recipe_header.count).cntl_rec_id := row_recipe_header.cntl_rec_id;
      tbl_recipe_header(tbl_recipe_header.count).plant := row_recipe_header.plant;
      tbl_recipe_header(tbl_recipe_header.count).cntl_rec_status := row_recipe_header.cntl_rec_status;
      tbl_recipe_header(tbl_recipe_header.count).test_flag := row_recipe_header.test_flag;
      tbl_recipe_header(tbl_recipe_header.count).recipe_text := row_recipe_header.recipe_text;
      tbl_recipe_header(tbl_recipe_header.count).material := row_recipe_header.material;
      tbl_recipe_header(tbl_recipe_header.count).material_text := row_recipe_header.material_text;
      tbl_recipe_header(tbl_recipe_header.count).quantity := row_recipe_header.quantity;
      tbl_recipe_header(tbl_recipe_header.count).insplot := row_recipe_header.insplot;
      tbl_recipe_header(tbl_recipe_header.count).uom := row_recipe_header.uom;
      tbl_recipe_header(tbl_recipe_header.count).batch := row_recipe_header.batch;
      tbl_recipe_header(tbl_recipe_header.count).sched_start_datime := row_recipe_header.sched_start_datime;
      tbl_recipe_header(tbl_recipe_header.count).run_start_datime := row_recipe_header.run_start_datime;
      tbl_recipe_header(tbl_recipe_header.count).run_end_datime := row_recipe_header.run_end_datime;
      tbl_recipe_header(tbl_recipe_header.count).version := row_recipe_header.version;
      tbl_recipe_header(tbl_recipe_header.count).upd_datime := row_recipe_header.upd_datime;
      tbl_recipe_header(tbl_recipe_header.count).cntl_rec_xfer := row_recipe_header.cntl_rec_xfer;
      tbl_recipe_header(tbl_recipe_header.count).teco_status := row_recipe_header.teco_status;
      tbl_recipe_header(tbl_recipe_header.count).storage_locn := row_recipe_header.storage_locn;
      tbl_recipe_header(tbl_recipe_header.count).idoc_timestamp := row_recipe_header.idoc_timestamp;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zordine;

   /******************************************************/
   /* This procedure performs the process ZATLAS routine */
   /******************************************************/
   procedure process_zatlas is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_vpi_01 is
         select t01.pppi_material_item,
                t01.pppi_material,
                t01.pppi_material_quantity,
                t01.pppi_material_short_text,
                t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_unit_of_measure,
                t01.pppi_phase_resource,
                t01.z_ps_first_pan_in_num,
                t01.z_ps_last_pan_in_num,
                t01.z_ps_pan_size_yn,
                t01.z_ps_no_of_pans
           from (select t01.cntl_rec_id,
                        t01.proc_instr_number,
                        max(case when t01.name_char = 'PPPI_MATERIAL_ITEM' then t01.char_value end) as pppi_material_item,
                        max(case when t01.name_char = 'PPPI_MATERIAL' then t01.char_value end) as pppi_material,
                        max(case when t01.name_char = 'PPPI_MATERIAL_QUANTITY' then t01.char_value end) as pppi_material_quantity,
                        max(case when t01.name_char = 'PPPI_MATERIAL_SHORT_TEXT' then t01.char_value end) as pppi_material_short_text,
                        max(case when t01.name_char = 'PPPI_OPERATION' then t01.char_value end) as pppi_operation,
                        max(case when t01.name_char = 'PPPI_PHASE' then t01.char_value end) as pppi_phase,
                        max(case when t01.name_char = 'PPPI_UNIT_OF_MEASURE' then t01.char_value end) as pppi_unit_of_measure,
                        max(case when t01.name_char = 'PPPI_PHASE_RESOURCE' then t01.char_value end) as pppi_phase_resource,
                        max(case when t01.name_char = 'Z_PS_FIRST_PAN_IN_NUM' then t01.char_value end) as z_ps_first_pan_in_num,
                        max(case when t01.name_char = 'Z_PS_LAST_PAN_IN_NUM' then t01.char_value end) as z_ps_last_pan_in_num,
                        max(case when t01.name_char = 'Z_PS_PAN_SIZE_YN' then t01.char_value end) as z_ps_pan_size_yn,
                        max(case when t01.name_char = 'Z_PS_NO_OF_PANS' then t01.char_value end) as z_ps_no_of_pans
                   from lads_ctl_rec_vpi t01
                  where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    and t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               group by t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      if var_zordine = false then
         raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      end if;

      /*-*/
      /* Retrieve the ZATLAS data (LADS schema)
      /*-*/
      open csr_lads_ctl_rec_vpi_01;
      fetch csr_lads_ctl_rec_vpi_01 into rcd_lads_ctl_rec_vpi;
      if csr_lads_ctl_rec_vpi_01%notfound then
         raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || to_char(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      end if;
      close csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;
      row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;
      row_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.pppi_material_short_text;
      row_recipe_bom.material_qty := null;
      
      begin
         row_recipe_bom.material_qty := to_number(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
      exception
         when others then
            raise_application_error(-20000, 'Process  ZBFBRQ1 (ZATLAS) - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_material_quantity || ') to a number');
      end;

      row_recipe_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;
      row_recipe_bom.material_prnt := null;
      row_recipe_bom.bf_item := null;
      row_recipe_bom.reservation := null;
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.phantom := null;
      row_recipe_bom.operation_from := null;

      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comands in idoc - Atlas 3.1
      /*-*/
      row_recipe_bom.pan_size := null;
      
      if upper(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' then
         begin
            row_recipe_bom.pan_size := to_number(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         exception
            when others then
               raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
         end;
      end if;

      row_recipe_bom.last_pan_size := null;
      if upper(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' then
         begin
            row_recipe_bom.last_pan_size := to_number(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         exception
            when others then
               raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num || ') to a number');
         end;
      end if;

      row_recipe_bom.pan_size_flag := 'N';
      if upper(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' then
         row_recipe_bom.pan_size_flag := 'Y';
      end if;

      row_recipe_bom.pan_qty := null;
      begin
         row_recipe_bom.pan_qty := to_number(rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      exception
         when others then
            raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans || ') to a number');
      end;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      if row_recipe_bom.material_qty is null then
         if row_recipe_bom.pan_size_flag = 'N' then
            begin
               row_recipe_bom.material_qty := to_number(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            exception
               when others then
                  raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
            end;
         else
            begin
               row_recipe_bom.material_qty := to_number(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans -1) + to_number(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            exception
               when others then
                  raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || 'or' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num ||') to a number');
            end;
         end if;
      end if;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := null;
      row_recipe_resource.batch_uom := null;
      row_recipe_resource.plant := row_recipe_header.plant;
      
      if not(row_recipe_resource.operation is null) and
         not(row_recipe_resource.resource_code is null) then
         if not(tbl_recipe_resource.exists(row_recipe_resource.operation)) then
            tbl_recipe_resource(row_recipe_resource.operation).proc_order := row_recipe_resource.proc_order;
            tbl_recipe_resource(row_recipe_resource.operation).operation := row_recipe_resource.operation;
            tbl_recipe_resource(row_recipe_resource.operation).resource_code := row_recipe_resource.resource_code;
            tbl_recipe_resource(row_recipe_resource.operation).batch_qty := row_recipe_resource.batch_qty;
            tbl_recipe_resource(row_recipe_resource.operation).batch_uom := row_recipe_resource.batch_uom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom := row_recipe_resource.phantom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_desc := row_recipe_resource.phantom_desc;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_qty := row_recipe_resource.phantom_qty;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_uom := row_recipe_resource.phantom_uom;
            tbl_recipe_resource(row_recipe_resource.operation).plant := row_recipe_resource.plant;
         end if;
      end if;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom(tbl_recipe_bom.count + 1).proc_order := row_recipe_bom.proc_order;
      tbl_recipe_bom(tbl_recipe_bom.count).operation := row_recipe_bom.operation;
      tbl_recipe_bom(tbl_recipe_bom.count).phase := row_recipe_bom.phase;
      tbl_recipe_bom(tbl_recipe_bom.count).seq := row_recipe_bom.seq;
      tbl_recipe_bom(tbl_recipe_bom.count).material_code := row_recipe_bom.material_code;
      tbl_recipe_bom(tbl_recipe_bom.count).material_desc := row_recipe_bom.material_desc;
      tbl_recipe_bom(tbl_recipe_bom.count).material_qty := row_recipe_bom.material_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).material_uom := row_recipe_bom.material_uom;
      tbl_recipe_bom(tbl_recipe_bom.count).material_prnt := row_recipe_bom.material_prnt;
      tbl_recipe_bom(tbl_recipe_bom.count).bf_item := row_recipe_bom.bf_item;
      tbl_recipe_bom(tbl_recipe_bom.count).reservation := row_recipe_bom.reservation;
      tbl_recipe_bom(tbl_recipe_bom.count).plant := row_recipe_bom.plant;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size := row_recipe_bom.pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).last_pan_size := row_recipe_bom.last_pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size_flag := row_recipe_bom.pan_size_flag;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom(tbl_recipe_bom.count).operation_from := row_recipe_bom.operation_from;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zatlas;

   /*******************************************************/
   /* This procedure performs the process ZATLASA routine */
   /*******************************************************/
   procedure process_zatlasa is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_vpi_01 is
         select t01.pppi_output_text,
                t01.pppi_material_item,
                t01.pppi_reservation,
                t01.pppi_material,
                t01.pppi_material_quantity,
                t01.pppi_material_short_text,
                t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_unit_of_measure,
                t01.pppi_phase_resource,
                t01.z_ps_first_pan_in_num,
                t01.z_ps_last_pan_in_num,
                t01.z_ps_pan_size_yn,
                t01.z_ps_no_of_pans
           from (select t01.cntl_rec_id,
                        t01.proc_instr_number,
                        max(case when t01.name_char = 'PPPI_OUTPUT_TEXT' then t01.char_value end) as pppi_output_text,
                        max(case when t01.name_char = 'PPPI_MATERIAL_ITEM' then t01.char_value end) as pppi_material_item,
                        max(case when t01.name_char = 'PPPI_RESERVATION' then t01.char_value end) as pppi_reservation,
                        max(case when t01.name_char = 'PPPI_MATERIAL' then t01.char_value end) as pppi_material,
                        max(case when t01.name_char = 'PPPI_MATERIAL_QUANTITY' then t01.char_value end) as pppi_material_quantity,
                        max(case when t01.name_char = 'PPPI_MATERIAL_SHORT_TEXT' then t01.char_value end) as pppi_material_short_text,
                        max(case when t01.name_char = 'PPPI_OPERATION' then t01.char_value end) as pppi_operation,
                        max(case when t01.name_char = 'PPPI_PHASE' then t01.char_value end) as pppi_phase,
                        max(case when t01.name_char = 'PPPI_UNIT_OF_MEASURE' then t01.char_value end) as pppi_unit_of_measure,
                        max(case when t01.name_char = 'PPPI_PHASE_RESOURCE' then t01.char_value end) as pppi_phase_resource,
                        max(case when t01.name_char = 'Z_PS_FIRST_PAN_IN_NUM' then t01.char_value end) as z_ps_first_pan_in_num,
                        max(case when t01.name_char = 'Z_PS_LAST_PAN_IN_NUM' then t01.char_value end) as z_ps_last_pan_in_num,
                        max(case when t01.name_char = 'Z_PS_PAN_SIZE_YN' then t01.char_value end) as z_ps_pan_size_yn,
                        max(case when t01.name_char = 'Z_PS_NO_OF_PANS' then t01.char_value end) as z_ps_no_of_pans
                   from lads_ctl_rec_vpi t01
                  where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    and t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               group by t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      if var_zordine = false then
         raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      end if;

      /*-*/
      /* Retrieve the ZATLASA data from the LADS schema
      /*-*/
      open csr_lads_ctl_rec_vpi_01;
      fetch csr_lads_ctl_rec_vpi_01 into rcd_lads_ctl_rec_vpi;
      if csr_lads_ctl_rec_vpi_01%notfound then
         raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || to_char(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      end if;
      close csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;
      row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;
      row_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.pppi_material_short_text;
      row_recipe_bom.material_qty := null;
      
      begin
           if instr(rcd_lads_ctl_rec_vpi.pppi_material_quantity,'E') > 0 then
                row_recipe_bom.material_qty := to_number(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
            else
             row_recipe_bom.material_qty := convert_to_number(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
         end if;

          exception
         when others then
            raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_material_quantity || ') to a number');
      end;


      row_recipe_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;
      row_recipe_bom.material_prnt := null;
      row_recipe_bom.bf_item := 'Y';      
      if upper(trim(rcd_lads_ctl_rec_vpi.pppi_output_text)) = 'NON BACKFLUSHED ITEMS' then
         row_recipe_bom.bf_item := 'N';
      end if;

      row_recipe_bom.reservation := rcd_lads_ctl_rec_vpi.pppi_reservation;
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.phantom := null;
      row_recipe_bom.operation_from := null;

      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comds in idoc
      /*-*/
      row_recipe_bom.pan_size := null;      
      if upper(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' then
         begin
            row_recipe_bom.pan_size := to_number(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         exception
            when others then
               raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
         end;
      end if;

      row_recipe_bom.last_pan_size := null;
      if upper(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' then
         begin
            row_recipe_bom.last_pan_size := to_number(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         exception
            when others then
               raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num || ') to a number');
         end;
      end if;

      row_recipe_bom.pan_size_flag := 'N';
      if upper(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' then
         row_recipe_bom.pan_size_flag := 'Y';
      end if;

      row_recipe_bom.pan_qty := null;
      begin
         row_recipe_bom.pan_qty := to_number(rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      exception
         when others then
            raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans || ') to a number');
      end;

      /* update quantity if pan size is N or Y
      /*-*/
      if row_recipe_bom.material_qty is null then
         if row_recipe_bom.pan_size_flag = 'N' then
            begin
               row_recipe_bom.material_qty := to_number(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            exception
               when others then
                  raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
            end;
         else
            begin
               row_recipe_bom.material_qty := to_number(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans -1) + to_number(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            exception
               when others then
                  raise_application_error(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || 'or' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num ||') to a number');
            end;
         end if;
      end if;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := null;
      row_recipe_resource.batch_uom := null;
      row_recipe_resource.plant := row_recipe_header.plant;
      if not(row_recipe_resource.operation is null) and
         not(row_recipe_resource.resource_code is null) then
         if not(tbl_recipe_resource.exists(row_recipe_resource.operation)) then
            tbl_recipe_resource(row_recipe_resource.operation).proc_order := row_recipe_resource.proc_order;
            tbl_recipe_resource(row_recipe_resource.operation).operation := row_recipe_resource.operation;
            tbl_recipe_resource(row_recipe_resource.operation).resource_code := row_recipe_resource.resource_code;
            tbl_recipe_resource(row_recipe_resource.operation).batch_qty := row_recipe_resource.batch_qty;
            tbl_recipe_resource(row_recipe_resource.operation).batch_uom := row_recipe_resource.batch_uom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom := row_recipe_resource.phantom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_desc := row_recipe_resource.phantom_desc;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_qty := row_recipe_resource.phantom_qty;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_uom := row_recipe_resource.phantom_uom;
            tbl_recipe_resource(row_recipe_resource.operation).plant := row_recipe_resource.plant;
         end if;
      end if;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom(tbl_recipe_bom.count + 1).proc_order := row_recipe_bom.proc_order;
      tbl_recipe_bom(tbl_recipe_bom.count).operation := row_recipe_bom.operation;
      tbl_recipe_bom(tbl_recipe_bom.count).phase := row_recipe_bom.phase;
      tbl_recipe_bom(tbl_recipe_bom.count).seq := row_recipe_bom.seq;
      tbl_recipe_bom(tbl_recipe_bom.count).material_code := row_recipe_bom.material_code;
      tbl_recipe_bom(tbl_recipe_bom.count).material_desc := row_recipe_bom.material_desc;
      tbl_recipe_bom(tbl_recipe_bom.count).material_qty := row_recipe_bom.material_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).material_uom := row_recipe_bom.material_uom;
      tbl_recipe_bom(tbl_recipe_bom.count).material_prnt := row_recipe_bom.material_prnt;
      tbl_recipe_bom(tbl_recipe_bom.count).bf_item := row_recipe_bom.bf_item;
      tbl_recipe_bom(tbl_recipe_bom.count).reservation := row_recipe_bom.reservation;
      tbl_recipe_bom(tbl_recipe_bom.count).plant := row_recipe_bom.plant;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size := row_recipe_bom.pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).last_pan_size := row_recipe_bom.last_pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size_flag := row_recipe_bom.pan_size_flag;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom(tbl_recipe_bom.count).operation_from := row_recipe_bom.operation_from;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zatlasa;

   /*******************************************************/
   /* This procedure performs the process ZMESSRC routine */
   /*******************************************************/
   procedure process_zmessrc is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1 char);
      var_char varchar2(1 char);
      var_next varchar2(1 char);
      var_tab boolean;
      var_wrk_text varchar2(500 char);
      var_text01 varchar2(32767 char);
      var_text02 varchar2(32767 char);
      var_work01 varchar2(32767 char);
      var_work02 varchar2(32767 char);
      var_index number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_vpi_01 is
         select t01.pppi_phase_resource,
                t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_export_data,
                t01.z_src_type,
                t01.z_src_id,
                t01.z_src_description,
                t01.x_src_description,
                t01.z_src_long_text,
                t01.x_src_long_text,
                t01.z_src_value,
                t01.z_src_uom,
                t01.z_src_machine_id
           from (select t01.cntl_rec_id,
                        t01.proc_instr_number,
                        max(case when t01.name_char = 'PPPI_PHASE_RESOURCE' then t01.char_value end) as pppi_phase_resource,
                        max(case when t01.name_char = 'PPPI_OPERATION' then t01.char_value end) as pppi_operation,
                        max(case when t01.name_char = 'PPPI_PHASE' then t01.char_value end) as pppi_phase,
                        max(case when t01.name_char = 'PPPI_EXPORT_DATA' then t01.char_value end) as pppi_export_data,
                        max(case when t01.name_char = 'Z_SRC_TYPE' or t01.name_char = 'Z_TYPE_SRC' then t01.char_value end) as z_src_type,
                        max(case when t01.name_char = 'Z_SRC_ID' or t01.name_char = 'Z_ID_SRC'then t01.char_value end) as z_src_id,
                        max(case when t01.name_char = 'Z_SRC_DESCRIPTION' or t01.name_char = 'Z_DESCRIPTION_SRC'then t01.char_value end) as z_src_description,
                        max(case when t01.name_char = 'Z_SRC_DESCRIPTION' or t01.name_char = 'Z_DESCRIPTION_SRC' then t01.char_line_number end) as x_src_description,
                        max(case when t01.name_char = 'Z_SRC_LONG_TEXT' or t01.name_char = 'PPPI_NOTE' then t01.char_value end) as z_src_long_text,
                        max(case when t01.name_char = 'Z_SRC_LONG_TEXT' or t01.name_char = 'PPPI_NOTE' then t01.char_line_number end) as x_src_long_text,
                        max(case when t01.name_char = 'Z_SRC_VALUE' or t01.name_char = 'Z_VALUE_SRC' then t01.char_value end) as z_src_value,
                        max(case when t01.name_char = 'Z_SRC_UOM' or t01.name_char = 'Z_UOM_SRC' then t01.char_value end) as z_src_uom,
                        max(case when t01.name_char = 'Z_SRC_MACHINE_ID' or t01.name_char = 'Z_MACHINE_ID_SRC' then t01.char_value end) as z_src_machine_id
                   from lads_ctl_rec_vpi t01
                  where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    and t01.proc_instr_number = rcd_lads_ctl_rec_tpi.proc_instr_number
               group by t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%rowtype;

      cursor csr_lads_ctl_rec_txt_01 is
         select t01.tdformat,
                t01.tdline
           from lads_ctl_rec_txt t01
          where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
            and t01.proc_instr_number = rcd_lads_ctl_rec_tpi.proc_instr_number
            and t01.char_line_number = rcd_lads_ctl_rec_vpi.x_src_description
       order by t01.arrival_sequence;
      rcd_lads_ctl_rec_txt_01 csr_lads_ctl_rec_txt_01%rowtype;

      cursor csr_lads_ctl_rec_txt_02 is
         select t01.tdformat,
                t01.tdline
           from lads_ctl_rec_txt t01
          where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
            and t01.proc_instr_number = rcd_lads_ctl_rec_tpi.proc_instr_number
            and t01.char_line_number = rcd_lads_ctl_rec_vpi.x_src_long_text
       order by t01.arrival_sequence;
      rcd_lads_ctl_rec_txt_02 csr_lads_ctl_rec_txt_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      if var_zordine = false then
         raise_application_error(-20000, 'Process ZMESSRC - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      end if;

      /*-*/
      /* Retrieve the ZMESSRC data from the LADS schema
      /*-*/
      open csr_lads_ctl_rec_vpi_01;
      fetch csr_lads_ctl_rec_vpi_01 into rcd_lads_ctl_rec_vpi;
      if csr_lads_ctl_rec_vpi_01%notfound then
         raise_application_error(-20000, 'Process ZMESSRC - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || to_char(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      end if;
      close csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Retrieve and concatenate the related description text
      /*-*/
      var_text01 := null;
      open csr_lads_ctl_rec_txt_01;
      loop
         fetch csr_lads_ctl_rec_txt_01 into rcd_lads_ctl_rec_txt_01;
         if csr_lads_ctl_rec_txt_01%notfound then
            exit;
         end if;
         if not(var_text01 is null) then
            if rcd_lads_ctl_rec_txt_01.tdformat = '*' then
               var_text01 := var_text01 || '&.NEW_LINE';
            elsif rcd_lads_ctl_rec_txt_01.tdformat is null or rcd_lads_ctl_rec_txt_01.tdformat != '=' then
               var_text01 := var_text01 || ' ';
            end if;
         end if;
         if not(rcd_lads_ctl_rec_txt_01.tdline is null) then
            var_wrk_text := null;
            var_tab := false;
            For idx_chr IN 1..length(rcd_lads_ctl_rec_txt_01.tdline) loop
               if var_tab = false then
                  var_char := substr(rcd_lads_ctl_rec_txt_01.tdline, idx_chr, 1);
                  var_next := substr(rcd_lads_ctl_rec_txt_01.tdline, idx_chr + 1, 1);
                  if var_char = ',' and var_next = ',' then
                     var_wrk_text := var_wrk_text || '&.TAB';
                     var_tab := true;
                  else
                     var_wrk_text := var_wrk_text || var_char;
                  end if;
               else
                  var_tab := false;
               end if;
            end loop;
            var_text01 := var_text01 || var_wrk_text;
         end if;
      end loop;
      close csr_lads_ctl_rec_txt_01;

      /*-*/
      /* Retrieve and concatenate the related long text
      /*-*/
      var_text02 := null;
      open csr_lads_ctl_rec_txt_02;
      loop
         fetch csr_lads_ctl_rec_txt_02 into rcd_lads_ctl_rec_txt_02;
         if csr_lads_ctl_rec_txt_02%notfound then
            exit;
         end if;
         if not(var_text02 is null) then
            if rcd_lads_ctl_rec_txt_02.tdformat = '*' then
               var_text02 := var_text02 || '&.NEW_LINE';
            elsif rcd_lads_ctl_rec_txt_02.tdformat is null or rcd_lads_ctl_rec_txt_02.tdformat != '=' then
               var_text02 := var_text02 || ' ';
            end if;
         end if;
         if not(rcd_lads_ctl_rec_txt_02.tdline is null) then
            var_wrk_text := null;
            var_tab := false;
            For idx_chr IN 1..length(rcd_lads_ctl_rec_txt_02.tdline) loop
               if var_tab = false then
                  var_char := substr(rcd_lads_ctl_rec_txt_02.tdline, idx_chr, 1);
                  var_next := substr(rcd_lads_ctl_rec_txt_02.tdline, idx_chr + 1, 1);
                  if var_char = ',' and var_next = ',' then
                     var_wrk_text := var_wrk_text || '&.TAB';
                     var_tab := true;
                  else
                     var_wrk_text := var_wrk_text || var_char;
                  end if;
               else
                  var_tab := false;
               end if;
            end loop;
            var_text02 := var_text02 || var_wrk_text;
         end if;
      end loop;
      close csr_lads_ctl_rec_txt_02;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := null;
      row_recipe_resource.batch_uom := null;
      row_recipe_resource.plant := row_recipe_header.plant;
      
      if not(row_recipe_resource.operation is null) and
         not(row_recipe_resource.resource_code is null) then
         if not(tbl_recipe_resource.exists(row_recipe_resource.operation)) then
            tbl_recipe_resource(row_recipe_resource.operation).proc_order := row_recipe_resource.proc_order;
            tbl_recipe_resource(row_recipe_resource.operation).operation := row_recipe_resource.operation;
            tbl_recipe_resource(row_recipe_resource.operation).resource_code := row_recipe_resource.resource_code;
            tbl_recipe_resource(row_recipe_resource.operation).batch_qty := row_recipe_resource.batch_qty;
            tbl_recipe_resource(row_recipe_resource.operation).batch_uom := row_recipe_resource.batch_uom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom := row_recipe_resource.phantom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_desc := row_recipe_resource.phantom_desc;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_qty := row_recipe_resource.phantom_qty;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_uom := row_recipe_resource.phantom_uom;
            tbl_recipe_resource(row_recipe_resource.operation).plant := row_recipe_resource.plant;
         end if;
      end if;

      /*-*/
      /* The bds_recipe_src_text row data
      /*-*/
      if rcd_lads_ctl_rec_vpi.z_src_type = 'H' or
         rcd_lads_ctl_rec_vpi.z_src_type = 'I' or
         rcd_lads_ctl_rec_vpi.z_src_type = 'N' then

         /*-*/
         /* Set and validate the bds_recipe_src_text row data
         /*-*/
         row_recipe_src_text.proc_order := row_recipe_header.proc_order;
         row_recipe_src_text.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
         row_recipe_src_text.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

         /********************************/
         /* Jeff Phillipson - 28/10/2004 */

         row_recipe_src_text.seq := substr(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

         /********************************/

         var_work01 := rcd_lads_ctl_rec_vpi.z_src_description;
         if not(var_text01 is null) then
            var_work01 := var_text01;
         end if;

         row_recipe_src_text.src_type := rcd_lads_ctl_rec_vpi.z_src_type;
         row_recipe_src_text.machine_code := rcd_lads_ctl_rec_vpi.z_src_machine_id;

         var_work02 := rcd_lads_ctl_rec_vpi.z_src_long_text;
         if not(var_text02 is null) then
            var_work02 := var_text02;
         end if;

         row_recipe_src_text.plant := row_recipe_header.plant;

         /*-*/
         /* Create the process order source text
         /*-*/
         tbl_recipe_src_text(tbl_recipe_src_text.count + 1).proc_order := row_recipe_src_text.proc_order;
         tbl_recipe_src_text(tbl_recipe_src_text.count).operation := row_recipe_src_text.operation;
         tbl_recipe_src_text(tbl_recipe_src_text.count).phase := row_recipe_src_text.phase;
         tbl_recipe_src_text(tbl_recipe_src_text.count).seq := row_recipe_src_text.seq;
         tbl_recipe_src_text(tbl_recipe_src_text.count).src_type := row_recipe_src_text.src_type;
         tbl_recipe_src_text(tbl_recipe_src_text.count).machine_code := row_recipe_src_text.machine_code;
         tbl_recipe_src_text(tbl_recipe_src_text.count).plant := row_recipe_src_text.plant;
         tbl_recipe_src_text(tbl_recipe_src_text.count).txt01_sidx := 0;
         tbl_recipe_src_text(tbl_recipe_src_text.count).txt01_eidx := 0;
         tbl_recipe_src_text(tbl_recipe_src_text.count).txt02_sidx := 0;
         tbl_recipe_src_text(tbl_recipe_src_text.count).txt02_eidx := 0;

         /*-*/
         /* Create the process order source text - src_text
         /*-*/
         if not(var_work01 is null) then
            tbl_recipe_src_text(tbl_recipe_src_text.count).txt01_sidx := tbl_recipe_text01.count + 1;
            var_index := 1;
            loop
               var_wrk_text := substr(var_work01,var_index,500);
               if var_wrk_text is null then
                  exit;
               end if;
               tbl_recipe_src_text(tbl_recipe_src_text.count).txt01_eidx := tbl_recipe_text01.count + 1;
               tbl_recipe_text01(tbl_recipe_text01.count + 1).proc_order := row_recipe_src_text.proc_order;
               tbl_recipe_text01(tbl_recipe_text01.count).operation := row_recipe_src_text.operation;
               tbl_recipe_text01(tbl_recipe_text01.count).phase := row_recipe_src_text.phase;
               tbl_recipe_text01(tbl_recipe_text01.count).seq := row_recipe_src_text.seq;
               tbl_recipe_text01(tbl_recipe_text01.count).text_data := var_wrk_text;
               var_index := var_index + 500;
            end loop;
         end if;

         /*-*/
         /* Create the process order source text - detail_desc
         /*-*/
         if not(var_work02 is null) then
            tbl_recipe_src_text(tbl_recipe_src_text.count).txt02_sidx := tbl_recipe_text02.count + 1;
            var_index := 1;
            loop
               var_wrk_text := substr(var_work02,var_index,500);
               if var_wrk_text is null then
                  exit;
               end if;
               tbl_recipe_src_text(tbl_recipe_src_text.count).txt02_eidx := tbl_recipe_text02.count + 1;
               tbl_recipe_text02(tbl_recipe_text02.count + 1).proc_order := row_recipe_src_text.proc_order;
               tbl_recipe_text02(tbl_recipe_text02.count).operation := row_recipe_src_text.operation;
               tbl_recipe_text02(tbl_recipe_text02.count).phase := row_recipe_src_text.phase;
               tbl_recipe_text02(tbl_recipe_text02.count).seq := row_recipe_src_text.seq;
               tbl_recipe_text02(tbl_recipe_text02.count).text_data := var_wrk_text;
               var_index := var_index + 500;
            end loop;
         end if;

      /*-*/
      /* The bds_recipe_resource row data
      /*-*/
      elsif rcd_lads_ctl_rec_vpi.z_src_type = 'B' then

         /*-*/
         /* Set and validate the bds_recipe_resource row data
         /*-*/
         if not(rcd_lads_ctl_rec_vpi.pppi_operation is null) and
            not(rcd_lads_ctl_rec_vpi.pppi_phase_resource is null) then

            /*-*/
            /* Set the values
            /*-*/
            if not(rcd_lads_ctl_rec_vpi.pppi_export_data is null) then
               row_recipe_resource.batch_qty := rcd_lads_ctl_rec_vpi.pppi_export_data;
            else
               row_recipe_resource.batch_qty := rcd_lads_ctl_rec_vpi.z_src_value;
            end if;
            row_recipe_resource.batch_uom := rcd_lads_ctl_rec_vpi.z_src_uom;

            /*-*/
            /* Update the bds_recipe_resource row
            /*-*/
            if tbl_recipe_resource.exists(rcd_lads_ctl_rec_vpi.pppi_operation) then
               tbl_recipe_resource(rcd_lads_ctl_rec_vpi.pppi_operation).batch_qty := row_recipe_resource.batch_qty;
               tbl_recipe_resource(rcd_lads_ctl_rec_vpi.pppi_operation).batch_uom := row_recipe_resource.batch_uom;
            end if;

         end if;

      /*-*/
      /* The bds_recipe_src_value row data
      /*-*/
      elsif (rcd_lads_ctl_rec_vpi.z_src_type = 'V' or rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1') then

         /*-*/
         /* Set and validate the bds_recipe_src_value row data
         /*-*/
         row_recipe_src_value.proc_order := row_recipe_header.proc_order;
         row_recipe_src_value.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
         row_recipe_src_value.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

        /********************************/
        /* Jeff Phillipson - 28/10/2004 */

         row_recipe_src_value.seq := substr(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

        /********************************/

         row_recipe_src_value.src_tag := rcd_lads_ctl_rec_vpi.z_src_id;
         var_work01 := rcd_lads_ctl_rec_vpi.z_src_description;
         
         if not(var_text01 is null) then
            var_work01 := var_text01;
         end if;

         if not(rcd_lads_ctl_rec_vpi.pppi_export_data is null) then
            row_recipe_src_value.src_val := rcd_lads_ctl_rec_vpi.pppi_export_data;
         else
            row_recipe_src_value.src_val := rcd_lads_ctl_rec_vpi.z_src_value;
         end if;

         row_recipe_src_value.src_uom := rcd_lads_ctl_rec_vpi.z_src_uom;
         row_recipe_src_value.machine_code := rcd_lads_ctl_rec_vpi.z_src_machine_id;
         var_work02 := rcd_lads_ctl_rec_vpi.z_src_long_text;
         
         if not(var_text02 is null) then
            var_work02 := var_text02;
         end if;

         row_recipe_src_value.plant := row_recipe_header.plant;

         /*-*/
         /* Modify values if src type TEXT1 is used
         /*-*/
         if rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1' then
            var_work01 := var_work01 || ' ' || lower(row_recipe_src_value.src_val) || ' ' || lower(row_recipe_src_value.src_uom);
            row_recipe_src_value.src_val := '';
            row_recipe_src_value.src_uom := '';
         end if;

         /*-*/
         /* Create the process order source value
         /*-*/
         tbl_recipe_src_value(tbl_recipe_src_value.count + 1).proc_order := row_recipe_src_value.proc_order;
         tbl_recipe_src_value(tbl_recipe_src_value.count).operation := row_recipe_src_value.operation;
         tbl_recipe_src_value(tbl_recipe_src_value.count).phase := row_recipe_src_value.phase;
         tbl_recipe_src_value(tbl_recipe_src_value.count).seq := row_recipe_src_value.seq;
         tbl_recipe_src_value(tbl_recipe_src_value.count).src_tag := row_recipe_src_value.src_tag;
         tbl_recipe_src_value(tbl_recipe_src_value.count).src_val := row_recipe_src_value.src_val;
         tbl_recipe_src_value(tbl_recipe_src_value.count).src_uom := row_recipe_src_value.src_uom;
         tbl_recipe_src_value(tbl_recipe_src_value.count).machine_code := row_recipe_src_value.machine_code;
         tbl_recipe_src_value(tbl_recipe_src_value.count).plant := row_recipe_src_value.plant;
         tbl_recipe_src_value(tbl_recipe_src_value.count).txt01_sidx := 0;
         tbl_recipe_src_value(tbl_recipe_src_value.count).txt01_eidx := 0;
         tbl_recipe_src_value(tbl_recipe_src_value.count).txt02_sidx := 0;
         tbl_recipe_src_value(tbl_recipe_src_value.count).txt02_eidx := 0;

         /*-*/
         /* Create the process order source value - src_desc
         /*-*/
         if not(var_work01 is null) then
            tbl_recipe_src_value(tbl_recipe_src_value.count).txt01_sidx := tbl_recipe_text01.count + 1;
            var_index := 1;
            loop
               var_wrk_text := substr(var_work01,var_index,500);
               if var_wrk_text is null then
                  exit;
               end if;
               tbl_recipe_src_value(tbl_recipe_src_value.count).txt01_eidx := tbl_recipe_text01.count + 1;
               tbl_recipe_text01(tbl_recipe_text01.count + 1).proc_order := row_recipe_src_value.proc_order;
               tbl_recipe_text01(tbl_recipe_text01.count).operation := row_recipe_src_value.operation;
               tbl_recipe_text01(tbl_recipe_text01.count).phase := row_recipe_src_value.phase;
               tbl_recipe_text01(tbl_recipe_text01.count).seq := row_recipe_src_value.seq;
               tbl_recipe_text01(tbl_recipe_text01.count).text_data := var_wrk_text;
               var_index := var_index + 500;
            end loop;
         end if;

         /*-*/
         /* Create the process order source value - detail_desc
         /*-*/
         if not(var_work02 is null) then
            tbl_recipe_src_value(tbl_recipe_src_value.count).txt02_sidx := tbl_recipe_text02.count + 1;
            var_index := 1;
            loop
               var_wrk_text := substr(var_work02,var_index,500);
               if var_wrk_text is null then
                  exit;
               end if;
               tbl_recipe_src_value(tbl_recipe_src_value.count).txt02_eidx := tbl_recipe_text02.count + 1;
               tbl_recipe_text02(tbl_recipe_text02.count + 1).proc_order := row_recipe_src_value.proc_order;
               tbl_recipe_text02(tbl_recipe_text02.count).operation := row_recipe_src_value.operation;
               tbl_recipe_text02(tbl_recipe_text02.count).phase := row_recipe_src_value.phase;
               tbl_recipe_text02(tbl_recipe_text02.count).seq := row_recipe_src_value.seq;
               tbl_recipe_text02(tbl_recipe_text02.count).text_data := var_wrk_text;
               var_index := var_index + 500;
            end loop;
         end if;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zmessrc;

   /******************************************************/
   /* This procedure performs the process ZPHPAN1 routine */
   /******************************************************/
   procedure process_zphpan1 is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);
      var_space number;
      var_space1 number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_vpi_01 is
         select t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_phase_resource,
                t01.z_ps_first_pan_out_char,
                t01.z_ps_material,
                t01.z_ps_material_short_text,
                t01.z_ps_material_qty_char,
                t01.z_ps_no_of_pans,
                t01.z_ps_last_pan_out_char
           from (select t01.cntl_rec_id,
                        t01.proc_instr_number,
                        max(case when t01.name_char = 'PPPI_OPERATION' then t01.char_value end) as pppi_operation,
                        max(case when t01.name_char = 'PPPI_PHASE' then t01.char_value end) as pppi_phase,
                        max(case when t01.name_char = 'PPPI_PHASE_RESOURCE' then t01.char_value end) as pppi_phase_resource,
                        max(case when t01.name_char = 'Z_PS_FIRST_PAN_OUT_CHAR' then t01.char_value end) as z_ps_first_pan_out_char,
                        max(case when t01.name_char = 'Z_PS_MATERIAL' then t01.char_value end) as z_ps_material,
                        max(case when t01.name_char = 'Z_PS_MATERIAL_SHORT_TEXT' then t01.char_value end) as z_ps_material_short_text,
                        max(case when t01.name_char = 'Z_PS_MATERIAL_QTY_CHAR' then t01.char_value end) as z_ps_material_qty_char,
                        max(case when t01.name_char = 'Z_PS_NO_OF_PANS' then t01.char_value end) as z_ps_no_of_pans,
                        max(case when t01.name_char = 'Z_PS_LAST_PAN_OUT_CHAR' then t01.char_value end) as z_ps_last_pan_out_char
                   from lads_ctl_rec_vpi t01
                  where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    and t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               group by t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      if var_zordine = false then
         raise_application_error(-20000, 'Process ZBFBRQ1 (ZATLAS) - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      end if;

      /*-*/
      /* Retrieve the ZATLAS data (LADS schema)
      /*-*/
      open csr_lads_ctl_rec_vpi_01;
      fetch csr_lads_ctl_rec_vpi_01 into rcd_lads_ctl_rec_vpi;
      if csr_lads_ctl_rec_vpi_01%notfound then
         raise_application_error(-20000, 'Process ZPHPAN1 - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || to_char(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      end if;
      close csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;

      /*-*/
      /* copy phase into operation - its not sent in the latest Idoc
      /*-*/
      if rcd_lads_ctl_rec_vpi.pppi_operation is null then
        row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
      else
           row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      end if;
      
      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;
      row_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.z_ps_material_short_text;
      row_recipe_bom.phantom := 'M';  -- Phantom made location
      row_recipe_bom.operation_from := null;
      row_recipe_bom.pan_qty :=  rcd_lads_ctl_rec_vpi.z_ps_no_of_pans;
      row_recipe_bom.seq := substr(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);
      row_recipe_bom.material_uom := trim(substr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1));
      row_recipe_bom.plant := row_recipe_header.plant;
        row_recipe_bom.bf_item := null;

      /*-*/
      /* seperate out qty and uom values
      /*-*/
      row_recipe_bom.material_qty := null;
      row_recipe_bom.pan_size := null;
      row_recipe_bom.last_pan_size := null;
      
      if rcd_lads_ctl_rec_vpi.z_ps_no_of_pans = 0 then
            row_recipe_bom.pan_size_flag := 'N';
        var_space := instr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,' ');
        
        begin
           row_recipe_bom.material_qty := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,1,var_space - 1)));
           row_recipe_bom.material_uom := upper(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1)));
        exception
           when others then
              raise_application_error(-20000, 'Process ZPHPAN1 - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char || ') to a number');
        end;

      else
         var_space := instr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char,' ');
         var_space1 := instr(rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,' ');
         
         begin
            row_recipe_bom.pan_size := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char, 1, var_space - 1)));
         exception
            when others then
               raise_application_error(-20000, ' Process ZPHPAN1 - Field - FIRST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char || ') to a number');
         end;

         begin
            row_recipe_bom.last_pan_size := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,1,var_space1 - 1)));
         exception
            when others then
               raise_application_error(-20000, 'Process ZPHPAN1 - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char || ') to a number');
         end;

         var_space := instr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,' ');
         begin
            row_recipe_bom.material_qty := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,1,var_space - 1)));
            row_recipe_bom.material_uom := upper(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1)));
         exception
            when others then
               raise_application_error(-20000, 'Process ZPHPAN1 - Field - MATERIAL_QTY WITH Pan Qty - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char || ') to a number');
         end;

         row_recipe_bom.pan_size_flag := 'Y';

      end if;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := null;
      row_recipe_resource.batch_uom := null;
      row_recipe_resource.plant := row_recipe_header.plant;
      
      if not(row_recipe_resource.operation is null) and
         not(row_recipe_resource.resource_code is null) then
         if not(tbl_recipe_resource.exists(row_recipe_resource.operation)) then
            tbl_recipe_resource(row_recipe_resource.operation).proc_order := row_recipe_resource.proc_order;
            tbl_recipe_resource(row_recipe_resource.operation).operation := row_recipe_resource.operation;
            tbl_recipe_resource(row_recipe_resource.operation).resource_code := row_recipe_resource.resource_code;
            tbl_recipe_resource(row_recipe_resource.operation).batch_qty := row_recipe_resource.batch_qty;
            tbl_recipe_resource(row_recipe_resource.operation).batch_uom := row_recipe_resource.batch_uom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom := row_recipe_resource.phantom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_desc := row_recipe_resource.phantom_desc;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_qty := row_recipe_resource.phantom_qty;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_uom := row_recipe_resource.phantom_uom;
            tbl_recipe_resource(row_recipe_resource.operation).plant := row_recipe_resource.plant;
         end if;
      end if;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom(tbl_recipe_bom.count + 1).proc_order := row_recipe_bom.proc_order;
      tbl_recipe_bom(tbl_recipe_bom.count).operation := row_recipe_bom.operation;
      tbl_recipe_bom(tbl_recipe_bom.count).phase := row_recipe_bom.phase;
      tbl_recipe_bom(tbl_recipe_bom.count).seq := row_recipe_bom.seq;
      tbl_recipe_bom(tbl_recipe_bom.count).material_code := row_recipe_bom.material_code;
      tbl_recipe_bom(tbl_recipe_bom.count).material_desc := row_recipe_bom.material_desc;
      tbl_recipe_bom(tbl_recipe_bom.count).material_qty := row_recipe_bom.material_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).material_uom := row_recipe_bom.material_uom;
      tbl_recipe_bom(tbl_recipe_bom.count).material_prnt := row_recipe_bom.material_prnt;
      tbl_recipe_bom(tbl_recipe_bom.count).bf_item := null; --row_recipe_bom.bf_item;
      tbl_recipe_bom(tbl_recipe_bom.count).reservation := row_recipe_bom.reservation;
      tbl_recipe_bom(tbl_recipe_bom.count).plant := row_recipe_bom.plant;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size := row_recipe_bom.pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).last_pan_size := row_recipe_bom.last_pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size_flag := row_recipe_bom.pan_size_flag;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom(tbl_recipe_bom.count).operation_from := row_recipe_bom.operation_from;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zphpan1;

   /******************************************************/
   /* This procedure performs the process ZPHBRQ1 routine */
   /******************************************************/
   procedure process_zphbrq1 is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);
      var_space number;
      var_space1 number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_vpi_01 is
         select t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_phase_resource,
                t01.z_ps_predecessor,
                t01.z_ps_first_pan_in_char,
                t01.z_ps_material,
                t01.z_ps_material_short_text,
                t01.z_ps_last_pan_in_char,
                t01.z_ps_pan_size_yn
           from (select t01.cntl_rec_id,
                        t01.proc_instr_number,
                        max(case when t01.name_char = 'PPPI_OPERATION' then t01.char_value end) as pppi_operation,
                        max(case when t01.name_char = 'PPPI_PHASE' then t01.char_value end) as pppi_phase,
                        max(case when t01.name_char = 'PPPI_PHASE_RESOURCE' then t01.char_value end) as pppi_phase_resource,
                        max(case when t01.name_char = 'Z_PS_PREDECESSOR' then t01.char_value end) as z_ps_predecessor,
                        max(case when t01.name_char = 'Z_PS_FIRST_PAN_IN_CHAR' then t01.char_value end) as z_ps_first_pan_in_char,
                        max(case when t01.name_char = 'Z_PS_MATERIAL' then t01.char_value end) as z_ps_material,
                        max(case when t01.name_char = 'Z_PS_MATERIAL_SHORT_TEXT' then t01.char_value end) as z_ps_material_short_text,
                        max(case when t01.name_char = 'Z_PS_LAST_PAN_IN_CHAR' then t01.char_value end) as z_ps_last_pan_in_char,
                        max(case when t01.name_char = 'Z_PS_PAN_SIZE_YN' then t01.char_value end) as z_ps_pan_size_yn
                   from lads_ctl_rec_vpi t01
                  where t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    and t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               group by t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      if var_zordine = false then
         raise_application_error(-20000, 'Process ZPHBRQ1 - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      end if;

      /*-*/
      /* Retrieve the ZPHBRQ1 data (LADS schema)
      /*-*/
      open csr_lads_ctl_rec_vpi_01;
      fetch csr_lads_ctl_rec_vpi_01 into rcd_lads_ctl_rec_vpi;
      if csr_lads_ctl_rec_vpi_01%notfound then
         raise_application_error(-20000, 'Process ZPHBRQ1 - Control recipe id (' || to_char(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || to_char(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      end if;
      close csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;

      /*-*/
      /* Idoc doesn't send operation so make the operation and phase the same
      /*-*/
      if rcd_lads_ctl_rec_vpi.pppi_operation is null then
          row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
      else
            row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      end if;
      
      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;
      row_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.z_ps_material_short_text;
      row_recipe_bom.seq := substr(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.operation_from := rcd_lads_ctl_rec_vpi.z_ps_predecessor;
      row_recipe_bom.phantom := 'U';  -- Phantom used location
      row_recipe_bom.pan_size_flag := rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn;
      row_recipe_bom.pan_qty := null;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      row_recipe_bom.material_qty := null;
      row_recipe_bom.pan_size := null;
      row_recipe_bom.last_pan_size := null;

      if row_recipe_bom.pan_size_flag = 'N' or row_recipe_bom.pan_size_flag = 'E' then

        var_space := instr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,' ');

        begin
          if var_space = 0 then
            row_recipe_bom.material_qty := convert_to_number(trim(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char));
          else
                  row_recipe_bom.material_qty := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1, var_space - 1)));
          end if;
        exception
              when others then
                 raise_application_error(-20000, 'Process ZPHBRQ1 - Field - material qty - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ') to a number');
        end;

      else
         /*-*/
         /* get material qty using first and last pan qty
         /*-*/
        begin
                /*-*/
                /* check on the type of number ie 1,0000 ot 1.098+E2 etc
                /*-*/
                if instr(trim(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char),'E') > 0 then
                    row_recipe_bom.material_qty := (to_number(trim(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char)) + to_number(trim(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char)));
                  else
               var_space := instr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,' ');
               var_space1 := instr(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,' ');
               row_recipe_bom.material_qty := (convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1,var_space -1))) * 1) + convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,1,var_space1 -1)));
          end if;
              exception
            when others then
               raise_application_error(-20000, 'Process ZPHBRQ1 - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ' or ' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char ||') to a number');
        end;

         /*-*/
         /* get pan size
         /*-*/
         row_recipe_bom.pan_size := null;
         begin
            row_recipe_bom.pan_size := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1,var_space - 1)));
         exception
            when others then
               raise_application_error(-20000, 'Process ZPHBRQ1  - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ') to a number');
         end;

         /*-*/
         /* get last pan size
         /*-*/
         row_recipe_bom.last_pan_size := null;
         begin
            /*-*/
            /* Changed the variable name from var_space to var_space1
            /* Added by JP 26 May 2006
            /* For the first time a Proc Order was sent with a smaller numerical value length for last_pan_size
            /*-*/
            row_recipe_bom.last_pan_size := convert_to_number(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,1,var_space1 - 1)));
         exception
            when others then
               raise_application_error(-20000, 'Process ZPHBRQ1 - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char || ') to a number');
         end;
      end if;

      if var_space  = 0 then
          row_recipe_bom.material_uom := null;
      else
          row_recipe_bom.material_uom := upper(trim(substr(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char, var_space + 1)));
      end if;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := null;
      row_recipe_resource.batch_uom := null;
      row_recipe_resource.plant := row_recipe_header.plant;
      
      if not(row_recipe_resource.operation is null) and
         not(row_recipe_resource.resource_code is null) then
         if not(tbl_recipe_resource.exists(row_recipe_resource.operation)) then
            tbl_recipe_resource(row_recipe_resource.operation).proc_order := row_recipe_resource.proc_order;
            tbl_recipe_resource(row_recipe_resource.operation).operation := row_recipe_resource.operation;
            tbl_recipe_resource(row_recipe_resource.operation).resource_code := row_recipe_resource.resource_code;
            tbl_recipe_resource(row_recipe_resource.operation).batch_qty := row_recipe_resource.batch_qty;
            tbl_recipe_resource(row_recipe_resource.operation).batch_uom := row_recipe_resource.batch_uom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom := row_recipe_resource.phantom;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_desc := row_recipe_resource.phantom_desc;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_qty := row_recipe_resource.phantom_qty;
            tbl_recipe_resource(row_recipe_resource.operation).phantom_uom := row_recipe_resource.phantom_uom;
            tbl_recipe_resource(row_recipe_resource.operation).plant := row_recipe_resource.plant;
         end if;
      end if;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom(tbl_recipe_bom.count + 1).proc_order := row_recipe_bom.proc_order;
      tbl_recipe_bom(tbl_recipe_bom.count).operation := row_recipe_bom.operation;
      tbl_recipe_bom(tbl_recipe_bom.count).phase := row_recipe_bom.phase;
      tbl_recipe_bom(tbl_recipe_bom.count).seq := row_recipe_bom.seq;
      tbl_recipe_bom(tbl_recipe_bom.count).material_code := row_recipe_bom.material_code;
      tbl_recipe_bom(tbl_recipe_bom.count).material_desc := row_recipe_bom.material_desc;
      tbl_recipe_bom(tbl_recipe_bom.count).material_qty := row_recipe_bom.material_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).material_uom := row_recipe_bom.material_uom;
      tbl_recipe_bom(tbl_recipe_bom.count).material_prnt := row_recipe_bom.material_prnt;
      tbl_recipe_bom(tbl_recipe_bom.count).bf_item := row_recipe_bom.bf_item;
      tbl_recipe_bom(tbl_recipe_bom.count).reservation := row_recipe_bom.reservation;
      tbl_recipe_bom(tbl_recipe_bom.count).plant := row_recipe_bom.plant;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size := row_recipe_bom.pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).last_pan_size := row_recipe_bom.last_pan_size;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_size_flag := row_recipe_bom.pan_size_flag;
      tbl_recipe_bom(tbl_recipe_bom.count).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom(tbl_recipe_bom.count).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom(tbl_recipe_bom.count).operation_from := row_recipe_bom.operation_from;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zphbrq1;
   
  function convert_to_number(par_value varchar2) return number is

    var_result number;

  begin
  
    if ( instr(par_value, ',') = 0 ) then    
      var_result := to_number(par_value);    
    else
      var_result := to_number(par_value, 'FM999G999G999D999');    
    end if;
  
    return var_result;

  end convert_to_number;   

end plant_process_order_extract;
/

CREATE OR REPLACE PUBLIC SYNONYM PLANT_PROCESS_ORDER_EXTRACT FOR ICS_APP.PLANT_PROCESS_ORDER_EXTRACT;
