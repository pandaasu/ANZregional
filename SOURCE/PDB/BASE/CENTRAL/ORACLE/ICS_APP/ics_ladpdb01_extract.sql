--
-- ICS_LADPDB01_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ICS_LADPDB01_EXTRACT
as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : Site Application 
 Package : ICS_LADPDB01_EXTRACT 
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
 17-JUN-2010 Ben Halicki    Modified for Atlas Thailand implementation
 14-OCT-2010 Ben Halicki    Added code to retrieve interface extension from data store configuration,
                                based on plant code of process order
 27-Aug-2011 Steve Gregan   Add site_code
                                
*******************************************************************************/

   /*-*/
   /* Public declarations 
   /*-*/
   procedure execute (par_cntl_rec_id in number);
   
end ICS_LADPDB01_EXTRACT;
/


--
-- ICS_LADPDB01_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_ladpdb01_extract
AS
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception   EXCEPTION;
   PRAGMA EXCEPTION_INIT (application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   PROCEDURE process_zordine;

   PROCEDURE process_zatlas;

   PROCEDURE process_zatlasa;

   PROCEDURE process_zmessrc;

   PROCEDURE process_zphpan1;

   PROCEDURE process_zphbrq1;

   FUNCTION convert_to_number (par_value VARCHAR2)
      RETURN NUMBER;

   /*-*/  
   /* global constants
   /*-*/  
   con_intfc varchar2(20) := 'LADPDB01';

   /*-*/
   /* Private definitions
   /*-*/
   var_zordine             BOOLEAN;
   var_interface           VARCHAR2 (32 CHAR);
   rcd_lads_ctl_rec_hpi    lads_ctl_rec_hpi%ROWTYPE;
   rcd_lads_ctl_rec_tpi    lads_ctl_rec_tpi%ROWTYPE;

   TYPE rcd_recipe_header IS RECORD (
      proc_order           VARCHAR2 (12 CHAR),
      cntl_rec_id          NUMBER (18, 0),
      plant                VARCHAR2 (4 CHAR),
      cntl_rec_status      VARCHAR2 (5 CHAR),
      test_flag            VARCHAR2 (1 CHAR),
      recipe_text          VARCHAR2 (40 CHAR),
      material             VARCHAR2 (18 CHAR),
      material_text        VARCHAR2 (40 CHAR),
      quantity             NUMBER,
      insplot              VARCHAR2 (12 CHAR),
      uom                  VARCHAR2 (4 CHAR),
      batch                VARCHAR2 (10 CHAR),
      sched_start_datime   DATE,
      run_start_datime     DATE,
      run_end_datime       DATE,
      VERSION              NUMBER,
      upd_datime           DATE,
      cntl_rec_xfer        VARCHAR2 (1 CHAR),
      teco_status          VARCHAR2 (4 CHAR),
      storage_locn         VARCHAR2 (4 CHAR),
      idoc_timestamp       VARCHAR2 (16 CHAR)
   );

   TYPE rcd_recipe_bom IS RECORD (
      proc_order       VARCHAR2 (12 CHAR),
      operation        VARCHAR2 (4 CHAR),
      phase            VARCHAR2 (4 CHAR),
      seq              VARCHAR2 (4 CHAR),
      material_code    VARCHAR2 (18 CHAR),
      material_desc    VARCHAR2 (40 CHAR),
      material_qty     NUMBER,
      material_uom     VARCHAR2 (4 CHAR),
      material_prnt    VARCHAR2 (18 CHAR),
      bf_item          VARCHAR2 (1 CHAR),
      reservation      VARCHAR2 (40 CHAR),
      plant            VARCHAR2 (4 CHAR),
      pan_size         NUMBER,
      last_pan_size    NUMBER,
      pan_size_flag    VARCHAR2 (1 CHAR),
      pan_qty          NUMBER,
      phantom          VARCHAR2 (1 CHAR),
      operation_from   VARCHAR2 (4 CHAR)
   );

   TYPE rcd_recipe_resource IS RECORD (
      proc_order      VARCHAR2 (12 CHAR),
      operation       VARCHAR2 (4 CHAR),
      resource_code   VARCHAR2 (9 CHAR),
      batch_qty       NUMBER,
      batch_uom       VARCHAR2 (4 CHAR),
      phantom         VARCHAR2 (8 CHAR),
      phantom_desc    VARCHAR2 (40 CHAR),
      phantom_qty     VARCHAR2 (20 CHAR),
      phantom_uom     VARCHAR2 (10 CHAR),
      plant           VARCHAR2 (4 CHAR)
   );

   TYPE rcd_recipe_src_text IS RECORD (
      proc_order     VARCHAR2 (12 CHAR),
      operation      VARCHAR2 (4 CHAR),
      phase          VARCHAR2 (4 CHAR),
      seq            VARCHAR2 (4 CHAR),
      src_type       VARCHAR2 (1 CHAR),
      machine_code   VARCHAR2 (4 CHAR),
      plant          VARCHAR2 (4 CHAR),
      txt01_sidx     NUMBER,
      txt01_eidx     NUMBER,
      txt02_sidx     NUMBER,
      txt02_eidx     NUMBER
   );

   TYPE rcd_recipe_src_value IS RECORD (
      proc_order     VARCHAR2 (12 CHAR),
      operation      VARCHAR2 (4 CHAR),
      phase          VARCHAR2 (4 CHAR),
      seq            VARCHAR2 (4 CHAR),
      src_tag        VARCHAR2 (40 CHAR),
      src_val        VARCHAR2 (30 CHAR),
      src_uom        VARCHAR2 (20 CHAR),
      machine_code   VARCHAR2 (4 CHAR),
      plant          VARCHAR2 (4 CHAR),
      txt01_sidx     NUMBER,
      txt01_eidx     NUMBER,
      txt02_sidx     NUMBER,
      txt02_eidx     NUMBER
   );

   TYPE rcd_recipe_text IS RECORD (
      proc_order   VARCHAR2 (12 CHAR),
      operation    VARCHAR2 (4 CHAR),
      phase        VARCHAR2 (4 CHAR),
      seq          VARCHAR2 (4 CHAR),
      text_data    VARCHAR2 (500 CHAR)
   );

   row_recipe_header       rcd_recipe_header;
   row_recipe_bom          rcd_recipe_bom;
   row_recipe_resource     rcd_recipe_resource;
   row_recipe_src_text     rcd_recipe_src_text;
   row_recipe_src_value    rcd_recipe_src_value;
   row_recipe_text         rcd_recipe_text;

   TYPE typ_recipe_header IS TABLE OF rcd_recipe_header
      INDEX BY BINARY_INTEGER;

   TYPE typ_recipe_bom IS TABLE OF rcd_recipe_bom
      INDEX BY BINARY_INTEGER;

   TYPE typ_recipe_resource IS TABLE OF rcd_recipe_resource
      INDEX BY VARCHAR2 (32);

   TYPE typ_recipe_src_text IS TABLE OF rcd_recipe_src_text
      INDEX BY BINARY_INTEGER;

   TYPE typ_recipe_src_value IS TABLE OF rcd_recipe_src_value
      INDEX BY BINARY_INTEGER;

   TYPE typ_recipe_text IS TABLE OF rcd_recipe_text
      INDEX BY BINARY_INTEGER;

   tbl_recipe_header       typ_recipe_header;
   tbl_recipe_bom          typ_recipe_bom;
   tbl_recipe_resource     typ_recipe_resource;
   tbl_recipe_src_text     typ_recipe_src_text;
   tbl_recipe_src_value    typ_recipe_src_value;
   tbl_recipe_text01       typ_recipe_text;
   tbl_recipe_text02       typ_recipe_text;

/*****************************************************/
/* This procedure perfroms the BDS Interface routine */
/*****************************************************/
   PROCEDURE EXECUTE (par_cntl_rec_id IN NUMBER)
   IS
      /*-*/
      /* Local definitions
      /*-*/
      var_exception   VARCHAR2 (4000);
      var_lookup      VARCHAR2 (32);
      var_instance    NUMBER (15, 0);
      var_output      VARCHAR2 (4000);
      var_ignore      BOOLEAN;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_intfc is
         select 
            t01.dsv_group as site_code
         from
            table (lics_datastore.retrieve_group('PDB','VALID_PLANTS',rcd_lads_ctl_rec_hpi.plant)) t01;
      rcd_intfc csr_intfc%rowtype;

      cursor csr_extn is
         select 
            t01.dsv_value as intfc_extn
         from
            table (lics_datastore.retrieve_value('PDB',rcd_intfc.site_code,'INTFC_EXTN')) t01;
      rcd_extn csr_extn%rowtype;

      CURSOR csr_lads_ctl_rec_hpi_01
      IS
         SELECT t01.cntl_rec_id, t01.plant, t01.proc_order, t01.dest,
                t01.dest_address, t01.dest_type, t01.cntl_rec_status,
                t01.test_flag, t01.recipe_text, t01.material,
                t01.material_text, t01.insplot, t01.material_external,
                t01.material_guid, t01.material_version, t01.batch,
                t01.scheduled_start_date, t01.scheduled_start_time,
                t01.idoc_name, t01.idoc_number, t01.idoc_timestamp,
                t01.lads_date, t01.lads_status, t01.lads_flattened
           FROM lads_ctl_rec_hpi t01
          WHERE t01.cntl_rec_id = par_cntl_rec_id;

      CURSOR csr_lads_ctl_rec_tpi_01
      IS
         SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                  t01.proc_instr_type, t01.proc_instr_category,
                  t01.proc_instr_line_no, t01.phase_number
             FROM lads_ctl_rec_tpi t01
            WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id
         ORDER BY t01.proc_instr_number ASC;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_recipe_header.DELETE;
      tbl_recipe_bom.DELETE;
      tbl_recipe_resource.DELETE;
      tbl_recipe_src_text.DELETE;
      tbl_recipe_src_value.DELETE;
      tbl_recipe_text01.DELETE;
      tbl_recipe_text02.DELETE;
      var_ignore := FALSE;

      /*-*/
      /* Retrieve the control recipe HPI from the LADS schema
      /*-*/
      OPEN csr_lads_ctl_rec_hpi_01;

      FETCH csr_lads_ctl_rec_hpi_01
       INTO rcd_lads_ctl_rec_hpi;

      IF csr_lads_ctl_rec_hpi_01%NOTFOUND
      THEN
         raise_application_error (-20000,
                                     'Execute - Control recipe id ('
                                  || TO_CHAR (par_cntl_rec_id)
                                  || ') does not exist'
                                 );
      END IF;

      CLOSE csr_lads_ctl_rec_hpi_01;

      /*-*/
      /* Initialise the ZORDINE indicators
      /*-*/
      var_zordine := FALSE;

      /*-*/
      /* Retrieve the related control recipe TPI rows
      /*-*/
      OPEN csr_lads_ctl_rec_tpi_01;

      LOOP
         FETCH csr_lads_ctl_rec_tpi_01
          INTO rcd_lads_ctl_rec_tpi;

         IF csr_lads_ctl_rec_tpi_01%NOTFOUND
         THEN
            EXIT;
         END IF;

         /*-*/
         /* Process the related control recipe VPI rows based on intruction category
         /*-*/
         CASE rcd_lads_ctl_rec_tpi.proc_instr_category
            WHEN 'ZORDINE'
            THEN
               process_zordine;
            WHEN 'ZATLAS'
            THEN
               process_zatlas;
            WHEN 'ZBFBRQ1'
            THEN
               process_zatlas;
            WHEN 'ZATLASA'
            THEN
               process_zatlasa;
            WHEN 'ZACBRQ1'
            THEN
               process_zatlasa;
            WHEN 'ZMESSRC'
            THEN
               process_zmessrc;
            WHEN 'ZSRC'
            THEN
               process_zmessrc;
            WHEN 'ZPHPAN1'
            THEN
               process_zphpan1;
            WHEN 'ZPHBRQ1'
            THEN
               process_zphbrq1;
            WHEN 'ZATLAS2'
            THEN
               NULL;
            ELSE
               raise_application_error
                                 (-20000,
                                     'Execute - Control recipe id ('
                                  || TO_CHAR (rcd_lads_ctl_rec_hpi.cntl_rec_id)
                                  || ') process instruction category ('
                                  || rcd_lads_ctl_rec_tpi.proc_instr_category
                                  || ') not recognised on LADS_CTL_REC_TPI'
                                 );
         END CASE;
      END LOOP;

      CLOSE csr_lads_ctl_rec_tpi_01;

      /*-*/
      /* Control recipe must have one ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE
      THEN
         raise_application_error
            (-20000,
                'Execute - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_hpi.cntl_rec_id)
             || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI'
            );
      END IF;

      /*-*/
      /* Create the process order interface
      /*-*/
      var_ignore := FALSE;
    
      /* retrieve interface details from lics data store configuration */
      open csr_intfc;
      fetch csr_intfc into rcd_intfc;
        if csr_intfc%NOTFOUND then
            var_ignore:=TRUE;
        end if;
      close csr_intfc;

      IF NOT var_ignore then
         open csr_extn;
         fetch csr_extn into rcd_extn;
           if csr_extn%NOTFOUND then
               var_ignore:=TRUE;
           end if;
           var_interface := con_intfc || rcd_extn.intfc_extn;
         close csr_extn;
      end if;
        
      /*-*/
      IF NOT var_ignore
      THEN
         var_instance :=
            lics_outbound_loader.create_interface (var_interface,
                                                   NULL,
                                                   var_interface
                                                  );
            
         FOR idx IN 1 .. tbl_recipe_header.COUNT
         LOOP
            var_output := 'HDR';
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).proc_order, ' '), 12,
                        ' ');
            var_output :=
                  var_output
               || RPAD (TO_CHAR (tbl_recipe_header (idx).cntl_rec_id,
                                 'fm999999999999999990'
                                ),
                        18,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).plant, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).cntl_rec_status, ' '),
                        5,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).test_flag, ' '), 1, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).recipe_text, ' '),
                        40,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).material, ' '), 18, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).material_text, ' '),
                        40,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_header (idx).quantity), 0),
                        38,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).insplot, ' '), 12, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).uom, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).batch, ' '), 10, ' ');
            var_output :=
                  var_output
               || RPAD
                     (NVL
                         (TO_CHAR (tbl_recipe_header (idx).sched_start_datime,
                                   'yyyymmddhh24miss'
                                  ),
                          ' '
                         ),
                      14,
                      ' '
                     );
            var_output :=
                  var_output
               || RPAD
                     (NVL (TO_CHAR (tbl_recipe_header (idx).run_start_datime,
                                    'yyyymmddhh24miss'
                                   ),
                           ' '
                          ),
                      14,
                      ' '
                     );
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_header (idx).run_end_datime,
                                      'yyyymmddhh24miss'
                                     ),
                             ' '
                            ),
                        14,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_header (idx).VERSION), 0),
                        38,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_header (idx).upd_datime,
                                      'yyyymmddhh24miss'
                                     ),
                             ' '
                            ),
                        14,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).cntl_rec_xfer, ' '),
                        1,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).teco_status, ' '), 4,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).storage_locn, ' '),
                        4,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_header (idx).idoc_timestamp, ' '),
                        16,
                        ' '
                       );
            lics_outbound_loader.append_data (var_output);
         END LOOP;

         /*-*/
         FOR idx IN 1 .. tbl_recipe_bom.COUNT
         LOOP
            var_output := 'BOM';
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).proc_order, ' '), 12, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).operation, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).phase, ' '), 4, ' ');
            var_output :=
               var_output
               || RPAD (NVL (tbl_recipe_bom (idx).seq, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).material_code, ' '), 18,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).material_desc, ' '), 40,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_bom (idx).material_qty), -1),
                        38,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).material_uom, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).material_prnt, ' '), 18,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).bf_item, ' '), 1, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).reservation, ' '), 40, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).plant, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_bom (idx).pan_size), -1),
                        38,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_bom (idx).last_pan_size), -1),
                        38,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).pan_size_flag, ' '), 1, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (TO_CHAR (tbl_recipe_bom (idx).pan_qty), -1),
                        38,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).phantom, ' '), 1, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_bom (idx).operation_from, ' '), 4,
                        ' ');
            lics_outbound_loader.append_data (var_output);
         END LOOP;

         /*-*/
         var_lookup := tbl_recipe_resource.FIRST;

         WHILE NOT (var_lookup IS NULL)
         LOOP
            var_output := 'RES';
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).proc_order, ' '),
                        12,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).operation, ' '),
                        4,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).resource_code,
                             ' '
                            ),
                        9,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD
                     (NVL (TO_CHAR (tbl_recipe_resource (var_lookup).batch_qty),
                           -1
                          ),
                      38,
                      ' '
                     );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).batch_uom, ' '),
                        4,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).phantom, ' '),
                        8,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).phantom_desc,
                             ' '
                            ),
                        40,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).phantom_qty,
                             ' '),
                        20,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).phantom_uom,
                             ' '),
                        10,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_resource (var_lookup).plant, ' '),
                        4,
                        ' '
                       );
            lics_outbound_loader.append_data (var_output);
            var_lookup := tbl_recipe_resource.NEXT (var_lookup);
         END LOOP;

         /*-*/
         FOR idx IN 1 .. tbl_recipe_src_text.COUNT
         LOOP
            var_output := 'STX';
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).proc_order, ' '),
                        12,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).operation, ' '), 4,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).phase, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).seq, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).src_type, ' '), 1, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).machine_code, ' '),
                        4,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_text (idx).plant, ' '), 4, ' ');
            lics_outbound_loader.append_data (var_output);

            FOR tidx IN
               tbl_recipe_src_text (idx).txt01_sidx .. tbl_recipe_src_text
                                                                          (idx).txt01_eidx
            LOOP
               var_output := 'ST1';
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).proc_order, ' '),
                           12,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).operation, ' '),
                           4,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).phase, ' '), 4, ' ');
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).seq, ' '), 4, ' ');
               var_output :=
                   var_output || NVL (tbl_recipe_text01 (tidx).text_data, ' ');
               lics_outbound_loader.append_data (var_output);
            END LOOP;

            FOR tidx IN
               tbl_recipe_src_text (idx).txt02_sidx .. tbl_recipe_src_text
                                                                          (idx).txt02_eidx
            LOOP
               var_output := 'ST2';
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).proc_order, ' '),
                           12,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).operation, ' '),
                           4,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).phase, ' '), 4, ' ');
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).seq, ' '), 4, ' ');
               var_output :=
                   var_output || NVL (tbl_recipe_text02 (tidx).text_data, ' ');
               lics_outbound_loader.append_data (var_output);
            END LOOP;
         END LOOP;

         /*-*/
         FOR idx IN 1 .. tbl_recipe_src_value.COUNT
         LOOP
            var_output := 'SVL';
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).proc_order, ' '),
                        12,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).operation, ' '),
                        4,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).phase, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).seq, ' '), 4, ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).src_tag, ' '), 40,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).src_val, ' '), 30,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).src_uom, ' '), 20,
                        ' ');
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).machine_code, ' '),
                        4,
                        ' '
                       );
            var_output :=
                  var_output
               || RPAD (NVL (tbl_recipe_src_value (idx).plant, ' '), 4, ' ');
            lics_outbound_loader.append_data (var_output);

            FOR tidx IN
               tbl_recipe_src_value (idx).txt01_sidx .. tbl_recipe_src_value
                                                                          (idx).txt01_eidx
            LOOP
               var_output := 'SV1';
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).proc_order, ' '),
                           12,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).operation, ' '),
                           4,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).phase, ' '), 4, ' ');
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text01 (tidx).seq, ' '), 4, ' ');
               var_output :=
                   var_output || NVL (tbl_recipe_text01 (tidx).text_data, ' ');
               lics_outbound_loader.append_data (var_output);
            END LOOP;

            FOR tidx IN
               tbl_recipe_src_value (idx).txt02_sidx .. tbl_recipe_src_value
                                                                          (idx).txt02_eidx
            LOOP
               var_output := 'SV2';
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).proc_order, ' '),
                           12,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).operation, ' '),
                           4,
                           ' '
                          );
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).phase, ' '), 4, ' ');
               var_output :=
                     var_output
                  || RPAD (NVL (tbl_recipe_text02 (tidx).seq, ' '), 4, ' ');
               var_output :=
                   var_output || NVL (tbl_recipe_text02 (tidx).text_data, ' ');
               lics_outbound_loader.append_data (var_output);
            END LOOP;
         END LOOP;

         /*-*/
         lics_outbound_loader.finalise_interface;
      END IF;
/*-------------------*/
/* Exception handler */
/*-------------------*/
   EXCEPTION
      /**/
      /* Exception trap
      /**/
      WHEN OTHERS
      THEN
         /*-*/
         /* Rollback the database
         /*-*/
         ROLLBACK;
         /*-*/
         /* Save the exception
         /*-*/
         var_exception := SUBSTR (SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         IF lics_outbound_loader.is_created = TRUE
         THEN
            lics_outbound_loader.add_exception (var_exception);
            lics_outbound_loader.finalise_interface;
         END IF;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error (-20000,
                                     'ICS_LADPDB01_EXTRACT - '
                                  || 'CNTL_REC_ID: '
                                  || TO_CHAR (par_cntl_rec_id)
                                  || ' - '
                                  || var_exception
                                 );
/*-------------*/
/* End routine */
/*-------------*/
   END EXECUTE;

/*******************************************************/
/* This procedure performs the process ZORDINE routine */
/*******************************************************/
   PROCEDURE process_zordine
   IS
      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01
      IS
         SELECT t01.pppi_process_order, t01.pppi_order_quantity,
                t01.pppi_unit_of_measure, t01.pppi_storage_location,
                t01.zpppi_order_start_date, t01.zpppi_order_start_time,
                t01.zpppi_order_end_date, t01.zpppi_order_end_time,
                t01.z_teco_status
           FROM (SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PROCESS_ORDER'
                                    THEN t01.char_value
                              END
                             ) AS pppi_process_order,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_ORDER_QUANTITY'
                                    THEN t01.char_value
                              END
                             ) AS pppi_order_quantity,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_UNIT_OF_MEASURE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_unit_of_measure,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_STORAGE_LOCATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_storage_location,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'ZPPPI_ORDER_START_DATE'
                                    THEN t01.char_value
                              END
                             ) AS zpppi_order_start_date,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'ZPPPI_ORDER_START_TIME'
                                    THEN t01.char_value
                              END
                             ) AS zpppi_order_start_time,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'ZPPPI_ORDER_END_DATE'
                                    THEN t01.char_value
                              END
                             ) AS zpppi_order_end_date,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'ZPPPI_ORDER_END_TIME'
                                    THEN t01.char_value
                              END
                             ) AS zpppi_order_end_time,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_TECO_STATUS'
                                    THEN t01.char_value
                              END
                             ) AS z_teco_status
                     FROM lads_ctl_rec_vpi t01
                    WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                      AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
                 GROUP BY t01.cntl_rec_id, t01.proc_instr_number) t01;

      rcd_lads_ctl_rec_vpi   csr_lads_ctl_rec_vpi_01%ROWTYPE;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Control recipe can only have one ZORDINE process instruction
      /*-*/
      IF var_zordine = TRUE
      THEN
         raise_application_error
            (-20000,
                'Process ZORDINE - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
             || ') has multiple ZORDINE process instructions on LADS_CTL_REC_TPI'
            );
      END IF;

      var_zordine := TRUE;

      /*-*/
      /* Retrieve the ZORDINE data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;

      FETCH csr_lads_ctl_rec_vpi_01
       INTO rcd_lads_ctl_rec_vpi;

      IF csr_lads_ctl_rec_vpi_01%NOTFOUND
      THEN
         raise_application_error
                          (-20000,
                              'Process ZORDINE - Control recipe id ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
                           || ') process instruction number ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.proc_instr_number,
                                       'FM99999990'
                                      )
                           || ') has no associated rows on LADS_CTL_REC_VPI'
                          );
      END IF;

      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_header row data
      /*-*/
      row_recipe_header.proc_order := rcd_lads_ctl_rec_vpi.pppi_process_order;

      IF row_recipe_header.proc_order IS NULL
      THEN
         raise_application_error
                   (-20000,
                    'Process ZORDINE - Field - PROC_ORDER - Must not be null'
                   );
      END IF;

      row_recipe_header.cntl_rec_id := rcd_lads_ctl_rec_hpi.cntl_rec_id;
      row_recipe_header.plant := rcd_lads_ctl_rec_hpi.plant;

      IF row_recipe_header.plant IS NULL
      THEN
         raise_application_error
                        (-20000,
                         'Process ZORDINE - Field - PLANT - Must not be null'
                        );
      END IF;

      row_recipe_header.cntl_rec_status :=
                                          rcd_lads_ctl_rec_hpi.cntl_rec_status;
      row_recipe_header.test_flag := rcd_lads_ctl_rec_hpi.test_flag;
      row_recipe_header.recipe_text := rcd_lads_ctl_rec_hpi.recipe_text;
      row_recipe_header.material := rcd_lads_ctl_rec_hpi.material;

      IF row_recipe_header.material IS NULL
      THEN
         raise_application_error
                     (-20000,
                      'Process ZORDINE - Field - MATERIAL - Must not be null'
                     );
      END IF;

      row_recipe_header.material_text := rcd_lads_ctl_rec_hpi.material_text;
      row_recipe_header.quantity := NULL;

      BEGIN
         row_recipe_header.quantity :=
                         TO_NUMBER (rcd_lads_ctl_rec_vpi.pppi_order_quantity);
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZORDINE - Field - QUANTITY - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.pppi_order_quantity
                || ') to a number'
               );
      END;

      row_recipe_header.insplot := rcd_lads_ctl_rec_hpi.insplot;
      row_recipe_header.uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;
      row_recipe_header.batch := rcd_lads_ctl_rec_hpi.batch;
      row_recipe_header.sched_start_datime := NULL;

      BEGIN
         row_recipe_header.sched_start_datime :=
            TO_DATE (   rcd_lads_ctl_rec_hpi.scheduled_start_date
                     || rcd_lads_ctl_rec_hpi.scheduled_start_time,
                     'YYYYMMDDHH24MISS'
                    );
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZORDINE - Field - SCHED_START_DATIME - Unable to convert ('
                || rcd_lads_ctl_rec_hpi.scheduled_start_date
                || rcd_lads_ctl_rec_hpi.scheduled_start_time
                || ') to a date using format (YYYYMMDDHH24MISS)'
               );
      END;

      row_recipe_header.run_start_datime := NULL;

      BEGIN
         row_recipe_header.run_start_datime :=
            TO_DATE (   rcd_lads_ctl_rec_vpi.zpppi_order_start_date
                     || rcd_lads_ctl_rec_vpi.zpppi_order_start_time,
                     'YYYYMMDDHH24MISS'
                    );
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZORDINE - Field - RUN_START_DATIME - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.zpppi_order_start_date
                || rcd_lads_ctl_rec_vpi.zpppi_order_start_time
                || ') to a date using format (YYYYMMDDHH24MISS)'
               );
      END;

      IF row_recipe_header.run_start_datime IS NULL
      THEN
         raise_application_error
             (-20000,
              'Process ZORDINE - Field - RUN_START_DATIME - Must not be null'
             );
      END IF;

      row_recipe_header.run_end_datime := NULL;

      BEGIN
         row_recipe_header.run_end_datime :=
            TO_DATE (   rcd_lads_ctl_rec_vpi.zpppi_order_end_date
                     || rcd_lads_ctl_rec_vpi.zpppi_order_end_time,
                     'YYYYMMDDHH24MISS'
                    );
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZORDINE - Field - RUN_END_DATIME - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.zpppi_order_end_date
                || rcd_lads_ctl_rec_vpi.zpppi_order_end_time
                || ') to a date using format (YYYYMMDDHH24MISS)'
               );
      END;

      IF row_recipe_header.run_end_datime IS NULL
      THEN
         raise_application_error
              (-20000,
               ' Process ZORDINE - Field - RUN_END_DATIME - Must not be null'
              );
      END IF;

      row_recipe_header.VERSION := 1;
      row_recipe_header.upd_datime := SYSDATE;
      row_recipe_header.cntl_rec_xfer := 'N';
      row_recipe_header.teco_status := rcd_lads_ctl_rec_vpi.z_teco_status;
      row_recipe_header.storage_locn :=
                                    rcd_lads_ctl_rec_vpi.pppi_storage_location;
      row_recipe_header.idoc_timestamp := rcd_lads_ctl_rec_hpi.idoc_timestamp;
      /*-*/
      /* Create the process order header
      /*-*/
      tbl_recipe_header (tbl_recipe_header.COUNT + 1).proc_order :=
                                                  row_recipe_header.proc_order;
      tbl_recipe_header (tbl_recipe_header.COUNT).cntl_rec_id :=
                                                 row_recipe_header.cntl_rec_id;
      tbl_recipe_header (tbl_recipe_header.COUNT).plant :=
                                                       row_recipe_header.plant;
      tbl_recipe_header (tbl_recipe_header.COUNT).cntl_rec_status :=
                                             row_recipe_header.cntl_rec_status;
      tbl_recipe_header (tbl_recipe_header.COUNT).test_flag :=
                                                   row_recipe_header.test_flag;
      tbl_recipe_header (tbl_recipe_header.COUNT).recipe_text :=
                                                 row_recipe_header.recipe_text;
      tbl_recipe_header (tbl_recipe_header.COUNT).material :=
                                                    row_recipe_header.material;
      tbl_recipe_header (tbl_recipe_header.COUNT).material_text :=
                                               row_recipe_header.material_text;
      tbl_recipe_header (tbl_recipe_header.COUNT).quantity :=
                                                    row_recipe_header.quantity;
      tbl_recipe_header (tbl_recipe_header.COUNT).insplot :=
                                                     row_recipe_header.insplot;
      tbl_recipe_header (tbl_recipe_header.COUNT).uom := row_recipe_header.uom;
      tbl_recipe_header (tbl_recipe_header.COUNT).batch :=
                                                       row_recipe_header.batch;
      tbl_recipe_header (tbl_recipe_header.COUNT).sched_start_datime :=
                                          row_recipe_header.sched_start_datime;
      tbl_recipe_header (tbl_recipe_header.COUNT).run_start_datime :=
                                            row_recipe_header.run_start_datime;
      tbl_recipe_header (tbl_recipe_header.COUNT).run_end_datime :=
                                              row_recipe_header.run_end_datime;
      tbl_recipe_header (tbl_recipe_header.COUNT).VERSION :=
                                                     row_recipe_header.VERSION;
      tbl_recipe_header (tbl_recipe_header.COUNT).upd_datime :=
                                                  row_recipe_header.upd_datime;
      tbl_recipe_header (tbl_recipe_header.COUNT).cntl_rec_xfer :=
                                               row_recipe_header.cntl_rec_xfer;
      tbl_recipe_header (tbl_recipe_header.COUNT).teco_status :=
                                                 row_recipe_header.teco_status;
      tbl_recipe_header (tbl_recipe_header.COUNT).storage_locn :=
                                                row_recipe_header.storage_locn;
      tbl_recipe_header (tbl_recipe_header.COUNT).idoc_timestamp :=
                                              row_recipe_header.idoc_timestamp;
/*-------------*/
/* End routine */
/*-------------*/
   END process_zordine;

/******************************************************/
/* This procedure performs the process ZATLAS routine */
/******************************************************/
   PROCEDURE process_zatlas
   IS
      /*-*/
      /* Local definitions
      /*-*/
      var_work               VARCHAR2 (1);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01
      IS
         SELECT t01.pppi_material_item, t01.pppi_material,
                t01.pppi_material_quantity, t01.pppi_material_short_text,
                t01.pppi_operation, t01.pppi_phase, t01.pppi_unit_of_measure,
                t01.pppi_phase_resource, t01.z_ps_first_pan_in_num,
                t01.z_ps_last_pan_in_num, t01.z_ps_pan_size_yn,
                t01.z_ps_no_of_pans
           FROM (SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_MATERIAL_ITEM'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material_item,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_MATERIAL'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_MATERIAL_QUANTITY'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material_quantity,
                          MAX
                             (CASE
                                 WHEN t01.name_char =
                                                    'PPPI_MATERIAL_SHORT_TEXT'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material_short_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_OPERATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_operation,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_UNIT_OF_MEASURE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_unit_of_measure,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE_RESOURCE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase_resource,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_FIRST_PAN_IN_NUM'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_first_pan_in_num,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_LAST_PAN_IN_NUM'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_last_pan_in_num,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_PAN_SIZE_YN'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_pan_size_yn,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_NO_OF_PANS'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_no_of_pans
                     FROM lads_ctl_rec_vpi t01
                    WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                      AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
                 GROUP BY t01.cntl_rec_id, t01.proc_instr_number) t01;

      rcd_lads_ctl_rec_vpi   csr_lads_ctl_rec_vpi_01%ROWTYPE;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE
      THEN
         raise_application_error
            (-20000,
                'Process ZBFBRQ1 (ZATLAS) - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
             || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI'
            );
      END IF;

      /*-*/
      /* Retrieve the ZATLAS data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;

      FETCH csr_lads_ctl_rec_vpi_01
       INTO rcd_lads_ctl_rec_vpi;

      IF csr_lads_ctl_rec_vpi_01%NOTFOUND
      THEN
         raise_application_error
                         (-20000,
                             'Process ZBFBRQ1 (ZATLAS) - Control recipe id ('
                          || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
                          || ') process instruction number ('
                          || TO_CHAR (rcd_lads_ctl_rec_tpi.proc_instr_number,
                                      'FM99999990'
                                     )
                          || ') has no associated rows on LADS_CTL_REC_VPI'
                         );
      END IF;

      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;
      row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;
      row_recipe_bom.material_desc :=
                                 rcd_lads_ctl_rec_vpi.pppi_material_short_text;
      row_recipe_bom.material_qty := NULL;

      BEGIN
         row_recipe_bom.material_qty :=
                      TO_NUMBER (rcd_lads_ctl_rec_vpi.pppi_material_quantity);
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process  ZBFBRQ1 (ZATLAS) - Field - MATERIAL_QTY - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.pppi_material_quantity
                || ') to a number'
               );
      END;

      row_recipe_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;
      row_recipe_bom.material_prnt := NULL;
      row_recipe_bom.bf_item := NULL;
      row_recipe_bom.reservation := NULL;
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.phantom := NULL;
      row_recipe_bom.operation_from := NULL;
      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comands in idoc - Atlas 3.1
      /*-*/
      row_recipe_bom.pan_size := NULL;

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y'
      THEN
         BEGIN
            row_recipe_bom.pan_size :=
                       TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                   || ') to a number'
                  );
         END;
      END IF;

      row_recipe_bom.last_pan_size := NULL;

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y'
      THEN
         BEGIN
            row_recipe_bom.last_pan_size :=
                        TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZBFBRQ1 (ZATLAS) - Field - LAST_PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num
                   || ') to a number'
                  );
         END;
      END IF;

      row_recipe_bom.pan_size_flag := 'N';

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y'
      THEN
         row_recipe_bom.pan_size_flag := 'Y';
      END IF;

      row_recipe_bom.pan_qty := NULL;

      BEGIN
         row_recipe_bom.pan_qty :=
                             TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZBFBRQ1 (ZATLAS) - Field - PAN_QTY - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans
                || ') to a number'
               );
      END;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      IF row_recipe_bom.material_qty IS NULL
      THEN
         IF row_recipe_bom.pan_size_flag = 'N'
         THEN
            BEGIN
               row_recipe_bom.material_qty :=
                       TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error
                     (-20000,
                         'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert ('
                      || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                      || ') to a number'
                     );
            END;
         ELSE
            BEGIN
               row_recipe_bom.material_qty :=
                    TO_NUMBER (    rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                                 * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans
                               - 1
                              )
                  + TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error
                     (-20000,
                         'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE * PAN_QTY - Unable to convert ('
                      || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                      || 'or'
                      || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num
                      || ') to a number'
                     );
            END;
         END IF;
      END IF;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code :=
                                      rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := NULL;
      row_recipe_resource.batch_uom := NULL;
      row_recipe_resource.plant := row_recipe_header.plant;

      IF     NOT (row_recipe_resource.operation IS NULL)
         AND NOT (row_recipe_resource.resource_code IS NULL)
      THEN
         IF NOT (tbl_recipe_resource.EXISTS (row_recipe_resource.operation))
         THEN
            tbl_recipe_resource (row_recipe_resource.operation).proc_order :=
                                               row_recipe_resource.proc_order;
            tbl_recipe_resource (row_recipe_resource.operation).operation :=
                                                row_recipe_resource.operation;
            tbl_recipe_resource (row_recipe_resource.operation).resource_code :=
                                            row_recipe_resource.resource_code;
            tbl_recipe_resource (row_recipe_resource.operation).batch_qty :=
                                                row_recipe_resource.batch_qty;
            tbl_recipe_resource (row_recipe_resource.operation).batch_uom :=
                                                row_recipe_resource.batch_uom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom :=
                                                  row_recipe_resource.phantom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_desc :=
                                             row_recipe_resource.phantom_desc;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_qty :=
                                              row_recipe_resource.phantom_qty;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_uom :=
                                              row_recipe_resource.phantom_uom;
            tbl_recipe_resource (row_recipe_resource.operation).plant :=
                                                    row_recipe_resource.plant;
         END IF;
      END IF;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom (tbl_recipe_bom.COUNT + 1).proc_order :=
                                                     row_recipe_bom.proc_order;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation :=
                                                      row_recipe_bom.operation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phase := row_recipe_bom.phase;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).seq := row_recipe_bom.seq;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_code :=
                                                  row_recipe_bom.material_code;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_desc :=
                                                  row_recipe_bom.material_desc;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_qty :=
                                                   row_recipe_bom.material_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_uom :=
                                                   row_recipe_bom.material_uom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_prnt :=
                                                  row_recipe_bom.material_prnt;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).bf_item := row_recipe_bom.bf_item;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).reservation :=
                                                    row_recipe_bom.reservation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).plant := row_recipe_bom.plant;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size :=
                                                       row_recipe_bom.pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).last_pan_size :=
                                                  row_recipe_bom.last_pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size_flag :=
                                                  row_recipe_bom.pan_size_flag;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation_from :=
                                                 row_recipe_bom.operation_from;
/*-------------*/
/* End routine */
/*-------------*/
   END process_zatlas;

/*******************************************************/
/* This procedure performs the process ZATLASA routine */
/*******************************************************/
   PROCEDURE process_zatlasa
   IS
      /*-*/
      /* Local definitions
      /*-*/
      var_work               VARCHAR2 (1);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01
      IS
         SELECT t01.pppi_output_text, t01.pppi_material_item,
                t01.pppi_reservation, t01.pppi_material,
                t01.pppi_material_quantity, t01.pppi_material_short_text,
                t01.pppi_operation, t01.pppi_phase, t01.pppi_unit_of_measure,
                t01.pppi_phase_resource, t01.z_ps_first_pan_in_num,
                t01.z_ps_last_pan_in_num, t01.z_ps_pan_size_yn,
                t01.z_ps_no_of_pans
           FROM (SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_OUTPUT_TEXT'
                                    THEN t01.char_value
                              END
                             ) AS pppi_output_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_MATERIAL_ITEM'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material_item,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_RESERVATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_reservation,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_MATERIAL'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_MATERIAL_QUANTITY'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material_quantity,
                          MAX
                             (CASE
                                 WHEN t01.name_char =
                                                    'PPPI_MATERIAL_SHORT_TEXT'
                                    THEN t01.char_value
                              END
                             ) AS pppi_material_short_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_OPERATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_operation,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_UNIT_OF_MEASURE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_unit_of_measure,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE_RESOURCE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase_resource,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_FIRST_PAN_IN_NUM'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_first_pan_in_num,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_LAST_PAN_IN_NUM'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_last_pan_in_num,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_PAN_SIZE_YN'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_pan_size_yn,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_NO_OF_PANS'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_no_of_pans
                     FROM lads_ctl_rec_vpi t01
                    WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                      AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
                 GROUP BY t01.cntl_rec_id, t01.proc_instr_number) t01;

      rcd_lads_ctl_rec_vpi   csr_lads_ctl_rec_vpi_01%ROWTYPE;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE
      THEN
         raise_application_error
            (-20000,
                'Process ZACBRQ1 (ZATLASA) - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
             || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI'
            );
      END IF;

      /*-*/
      /* Retrieve the ZATLASA data from the LADS schema
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;

      FETCH csr_lads_ctl_rec_vpi_01
       INTO rcd_lads_ctl_rec_vpi;

      IF csr_lads_ctl_rec_vpi_01%NOTFOUND
      THEN
         raise_application_error
                        (-20000,
                            'Process ZACBRQ1 (ZATLASA) - Control recipe id ('
                         || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
                         || ') process instruction number ('
                         || TO_CHAR (rcd_lads_ctl_rec_tpi.proc_instr_number,
                                     'FM99999990'
                                    )
                         || ') has no associated rows on LADS_CTL_REC_VPI'
                        );
      END IF;

      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;
      row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;
      row_recipe_bom.material_desc :=
                                 rcd_lads_ctl_rec_vpi.pppi_material_short_text;
      row_recipe_bom.material_qty := NULL;

      BEGIN
         IF INSTR (rcd_lads_ctl_rec_vpi.pppi_material_quantity, 'E') > 0
         THEN
            row_recipe_bom.material_qty :=
                      TO_NUMBER (rcd_lads_ctl_rec_vpi.pppi_material_quantity);
         ELSE
            row_recipe_bom.material_qty :=
               convert_to_number (rcd_lads_ctl_rec_vpi.pppi_material_quantity);
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZACBRQ1 (ZATLASA) - Field - MATERIAL_QTY - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.pppi_material_quantity
                || ') to a number'
               );
      END;

      row_recipe_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;
      row_recipe_bom.material_prnt := NULL;
      row_recipe_bom.bf_item := 'Y';

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.pppi_output_text)) =
                                                       'NON BACKFLUSHED ITEMS'
      THEN
         row_recipe_bom.bf_item := 'N';
      END IF;

      row_recipe_bom.reservation := rcd_lads_ctl_rec_vpi.pppi_reservation;
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.phantom := NULL;
      row_recipe_bom.operation_from := NULL;
      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comds in idoc
      /*-*/
      row_recipe_bom.pan_size := NULL;

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y'
      THEN
         BEGIN
            row_recipe_bom.pan_size :=
                       TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                   || ') to a number'
                  );
         END;
      END IF;

      row_recipe_bom.last_pan_size := NULL;

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y'
      THEN
         BEGIN
            row_recipe_bom.last_pan_size :=
                        TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZACBRQ1 (ZATLASA) - Field - LAST_PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num
                   || ') to a number'
                  );
         END;
      END IF;

      row_recipe_bom.pan_size_flag := 'N';

      IF UPPER (TRIM (rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y'
      THEN
         row_recipe_bom.pan_size_flag := 'Y';
      END IF;

      row_recipe_bom.pan_qty := NULL;

      BEGIN
         row_recipe_bom.pan_qty :=
                             TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      EXCEPTION
         WHEN OTHERS
         THEN
            raise_application_error
               (-20000,
                   'Process ZACBRQ1 (ZATLASA) - Field - PAN_QTY - Unable to convert ('
                || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans
                || ') to a number'
               );
      END;

      /* update quantity if pan size is N or Y
      /*-*/
      IF row_recipe_bom.material_qty IS NULL
      THEN
         IF row_recipe_bom.pan_size_flag = 'N'
         THEN
            BEGIN
               row_recipe_bom.material_qty :=
                       TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error
                     (-20000,
                         'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert ('
                      || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                      || ') to a number'
                     );
            END;
         ELSE
            BEGIN
               row_recipe_bom.material_qty :=
                    TO_NUMBER (    rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                                 * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans
                               - 1
                              )
                  + TO_NUMBER (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            EXCEPTION
               WHEN OTHERS
               THEN
                  raise_application_error
                     (-20000,
                         'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE * PAN_QTY - Unable to convert ('
                      || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num
                      || 'or'
                      || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num
                      || ') to a number'
                     );
            END;
         END IF;
      END IF;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code :=
                                      rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := NULL;
      row_recipe_resource.batch_uom := NULL;
      row_recipe_resource.plant := row_recipe_header.plant;

      IF     NOT (row_recipe_resource.operation IS NULL)
         AND NOT (row_recipe_resource.resource_code IS NULL)
      THEN
         IF NOT (tbl_recipe_resource.EXISTS (row_recipe_resource.operation))
         THEN
            tbl_recipe_resource (row_recipe_resource.operation).proc_order :=
                                               row_recipe_resource.proc_order;
            tbl_recipe_resource (row_recipe_resource.operation).operation :=
                                                row_recipe_resource.operation;
            tbl_recipe_resource (row_recipe_resource.operation).resource_code :=
                                            row_recipe_resource.resource_code;
            tbl_recipe_resource (row_recipe_resource.operation).batch_qty :=
                                                row_recipe_resource.batch_qty;
            tbl_recipe_resource (row_recipe_resource.operation).batch_uom :=
                                                row_recipe_resource.batch_uom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom :=
                                                  row_recipe_resource.phantom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_desc :=
                                             row_recipe_resource.phantom_desc;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_qty :=
                                              row_recipe_resource.phantom_qty;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_uom :=
                                              row_recipe_resource.phantom_uom;
            tbl_recipe_resource (row_recipe_resource.operation).plant :=
                                                    row_recipe_resource.plant;
         END IF;
      END IF;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom (tbl_recipe_bom.COUNT + 1).proc_order :=
                                                     row_recipe_bom.proc_order;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation :=
                                                      row_recipe_bom.operation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phase := row_recipe_bom.phase;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).seq := row_recipe_bom.seq;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_code :=
                                                  row_recipe_bom.material_code;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_desc :=
                                                  row_recipe_bom.material_desc;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_qty :=
                                                   row_recipe_bom.material_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_uom :=
                                                   row_recipe_bom.material_uom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_prnt :=
                                                  row_recipe_bom.material_prnt;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).bf_item := row_recipe_bom.bf_item;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).reservation :=
                                                    row_recipe_bom.reservation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).plant := row_recipe_bom.plant;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size :=
                                                       row_recipe_bom.pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).last_pan_size :=
                                                  row_recipe_bom.last_pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size_flag :=
                                                  row_recipe_bom.pan_size_flag;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation_from :=
                                                 row_recipe_bom.operation_from;
/*-------------*/
/* End routine */
/*-------------*/
   END process_zatlasa;

/*******************************************************/
/* This procedure performs the process ZMESSRC routine */
/*******************************************************/
   PROCEDURE process_zmessrc
   IS
      /*-*/
      /* Local definitions
      /*-*/
      var_work                  VARCHAR2 (1 CHAR);
      var_char                  VARCHAR2 (1 CHAR);
      var_next                  VARCHAR2 (1 CHAR);
      var_tab                   BOOLEAN;
      var_wrk_text              VARCHAR2 (500 CHAR);
      var_text01                VARCHAR2 (32767 CHAR);
      var_text02                VARCHAR2 (32767 CHAR);
      var_work01                VARCHAR2 (32767 CHAR);
      var_work02                VARCHAR2 (32767 CHAR);
      var_index                 NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01
      IS
         SELECT t01.pppi_phase_resource, t01.pppi_operation, t01.pppi_phase,
                t01.pppi_export_data, t01.z_src_type, t01.z_src_id,
                t01.z_src_description, t01.x_src_description,
                t01.z_src_long_text, t01.x_src_long_text, t01.z_src_value,
                t01.z_src_uom, t01.z_src_machine_id
           FROM (SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE_RESOURCE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase_resource,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_OPERATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_operation,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_EXPORT_DATA'
                                    THEN t01.char_value
                              END
                             ) AS pppi_export_data,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_TYPE'
                                  OR t01.name_char = 'Z_TYPE_SRC'
                                    THEN t01.char_value
                              END
                             ) AS z_src_type,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_ID'
                                  OR t01.name_char = 'Z_ID_SRC'
                                    THEN t01.char_value
                              END
                             ) AS z_src_id,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_DESCRIPTION'
                                  OR t01.name_char = 'Z_DESCRIPTION_SRC'
                                    THEN t01.char_value
                              END
                             ) AS z_src_description,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_DESCRIPTION'
                                  OR t01.name_char = 'Z_DESCRIPTION_SRC'
                                    THEN t01.char_line_number
                              END
                             ) AS x_src_description,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_LONG_TEXT'
                                  OR t01.name_char = 'PPPI_NOTE'
                                    THEN t01.char_value
                              END
                             ) AS z_src_long_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_LONG_TEXT'
                                  OR t01.name_char = 'PPPI_NOTE'
                                    THEN t01.char_line_number
                              END
                             ) AS x_src_long_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_VALUE'
                                  OR t01.name_char = 'Z_VALUE_SRC'
                                    THEN t01.char_value
                              END
                             ) AS z_src_value,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_UOM'
                                  OR t01.name_char = 'Z_UOM_SRC'
                                    THEN t01.char_value
                              END
                             ) AS z_src_uom,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_SRC_MACHINE_ID'
                                  OR t01.name_char = 'Z_MACHINE_ID_SRC'
                                    THEN t01.char_value
                              END
                             ) AS z_src_machine_id
                     FROM lads_ctl_rec_vpi t01
                    WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                      AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
                 GROUP BY t01.cntl_rec_id, t01.proc_instr_number) t01;

      rcd_lads_ctl_rec_vpi      csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_lads_ctl_rec_txt_01
      IS
         SELECT   t01.tdformat, t01.tdline
             FROM lads_ctl_rec_txt t01
            WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
              AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
              AND t01.char_line_number =
                                        rcd_lads_ctl_rec_vpi.x_src_description
         ORDER BY t01.arrival_sequence;

      rcd_lads_ctl_rec_txt_01   csr_lads_ctl_rec_txt_01%ROWTYPE;

      CURSOR csr_lads_ctl_rec_txt_02
      IS
         SELECT   t01.tdformat, t01.tdline
             FROM lads_ctl_rec_txt t01
            WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
              AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
              AND t01.char_line_number = rcd_lads_ctl_rec_vpi.x_src_long_text
         ORDER BY t01.arrival_sequence;

      rcd_lads_ctl_rec_txt_02   csr_lads_ctl_rec_txt_02%ROWTYPE;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE
      THEN
         raise_application_error
            (-20000,
                'Process ZMESSRC - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
             || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI'
            );
      END IF;

      /*-*/
      /* Retrieve the ZMESSRC data from the LADS schema
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;

      FETCH csr_lads_ctl_rec_vpi_01
       INTO rcd_lads_ctl_rec_vpi;

      IF csr_lads_ctl_rec_vpi_01%NOTFOUND
      THEN
         raise_application_error
                          (-20000,
                              'Process ZMESSRC - Control recipe id ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
                           || ') process instruction number ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.proc_instr_number,
                                       'FM99999990'
                                      )
                           || ') has no associated rows on LADS_CTL_REC_VPI'
                          );
      END IF;

      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Retrieve and concatenate the related description text
      /*-*/
      var_text01 := NULL;

      OPEN csr_lads_ctl_rec_txt_01;

      LOOP
         FETCH csr_lads_ctl_rec_txt_01
          INTO rcd_lads_ctl_rec_txt_01;

         IF csr_lads_ctl_rec_txt_01%NOTFOUND
         THEN
            EXIT;
         END IF;

         IF NOT (var_text01 IS NULL)
         THEN
            IF rcd_lads_ctl_rec_txt_01.tdformat = '*'
            THEN
               var_text01 := var_text01 || '&.NEW_LINE';
            ELSIF    rcd_lads_ctl_rec_txt_01.tdformat IS NULL
                  OR rcd_lads_ctl_rec_txt_01.tdformat != '='
            THEN
               var_text01 := var_text01 || ' ';
            END IF;
         END IF;

         IF NOT (rcd_lads_ctl_rec_txt_01.tdline IS NULL)
         THEN
            var_wrk_text := NULL;
            var_tab := FALSE;

            FOR idx_chr IN 1 .. LENGTH (rcd_lads_ctl_rec_txt_01.tdline)
            LOOP
               IF var_tab = FALSE
               THEN
                  var_char :=
                          SUBSTR (rcd_lads_ctl_rec_txt_01.tdline, idx_chr, 1);
                  var_next :=
                      SUBSTR (rcd_lads_ctl_rec_txt_01.tdline, idx_chr + 1, 1);

                  IF var_char = ',' AND var_next = ','
                  THEN
                     var_wrk_text := var_wrk_text || '&.TAB';
                     var_tab := TRUE;
                  ELSE
                     var_wrk_text := var_wrk_text || var_char;
                  END IF;
               ELSE
                  var_tab := FALSE;
               END IF;
            END LOOP;

            var_text01 := var_text01 || var_wrk_text;
         END IF;
      END LOOP;

      CLOSE csr_lads_ctl_rec_txt_01;

      /*-*/
      /* Retrieve and concatenate the related long text
      /*-*/
      var_text02 := NULL;

      OPEN csr_lads_ctl_rec_txt_02;

      LOOP
         FETCH csr_lads_ctl_rec_txt_02
          INTO rcd_lads_ctl_rec_txt_02;

         IF csr_lads_ctl_rec_txt_02%NOTFOUND
         THEN
            EXIT;
         END IF;

         IF NOT (var_text02 IS NULL)
         THEN
            IF rcd_lads_ctl_rec_txt_02.tdformat = '*'
            THEN
               var_text02 := var_text02 || '&.NEW_LINE';
            ELSIF    rcd_lads_ctl_rec_txt_02.tdformat IS NULL
                  OR rcd_lads_ctl_rec_txt_02.tdformat != '='
            THEN
               var_text02 := var_text02 || ' ';
            END IF;
         END IF;

         IF NOT (rcd_lads_ctl_rec_txt_02.tdline IS NULL)
         THEN
            var_wrk_text := NULL;
            var_tab := FALSE;

            FOR idx_chr IN 1 .. LENGTH (rcd_lads_ctl_rec_txt_02.tdline)
            LOOP
               IF var_tab = FALSE
               THEN
                  var_char :=
                          SUBSTR (rcd_lads_ctl_rec_txt_02.tdline, idx_chr, 1);
                  var_next :=
                      SUBSTR (rcd_lads_ctl_rec_txt_02.tdline, idx_chr + 1, 1);

                  IF var_char = ',' AND var_next = ','
                  THEN
                     var_wrk_text := var_wrk_text || '&.TAB';
                     var_tab := TRUE;
                  ELSE
                     var_wrk_text := var_wrk_text || var_char;
                  END IF;
               ELSE
                  var_tab := FALSE;
               END IF;
            END LOOP;

            var_text02 := var_text02 || var_wrk_text;
         END IF;
      END LOOP;

      CLOSE csr_lads_ctl_rec_txt_02;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code :=
                                      rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := NULL;
      row_recipe_resource.batch_uom := NULL;
      row_recipe_resource.plant := row_recipe_header.plant;

      IF     NOT (row_recipe_resource.operation IS NULL)
         AND NOT (row_recipe_resource.resource_code IS NULL)
      THEN
         IF NOT (tbl_recipe_resource.EXISTS (row_recipe_resource.operation))
         THEN
            tbl_recipe_resource (row_recipe_resource.operation).proc_order :=
                                               row_recipe_resource.proc_order;
            tbl_recipe_resource (row_recipe_resource.operation).operation :=
                                                row_recipe_resource.operation;
            tbl_recipe_resource (row_recipe_resource.operation).resource_code :=
                                            row_recipe_resource.resource_code;
            tbl_recipe_resource (row_recipe_resource.operation).batch_qty :=
                                                row_recipe_resource.batch_qty;
            tbl_recipe_resource (row_recipe_resource.operation).batch_uom :=
                                                row_recipe_resource.batch_uom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom :=
                                                  row_recipe_resource.phantom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_desc :=
                                             row_recipe_resource.phantom_desc;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_qty :=
                                              row_recipe_resource.phantom_qty;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_uom :=
                                              row_recipe_resource.phantom_uom;
            tbl_recipe_resource (row_recipe_resource.operation).plant :=
                                                    row_recipe_resource.plant;
         END IF;
      END IF;

      /*-*/
      /* The bds_recipe_src_text row data
      /*-*/
      IF    rcd_lads_ctl_rec_vpi.z_src_type = 'H'
         OR rcd_lads_ctl_rec_vpi.z_src_type = 'I'
         OR rcd_lads_ctl_rec_vpi.z_src_type = 'N'
      THEN
         /*-*/
         /* Set and validate the bds_recipe_src_text row data
         /*-*/
         row_recipe_src_text.proc_order := row_recipe_header.proc_order;
         row_recipe_src_text.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
         row_recipe_src_text.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
/********************************/
/* Jeff Phillipson - 28/10/2004 */
         row_recipe_src_text.seq :=
                        SUBSTR (rcd_lads_ctl_rec_tpi.proc_instr_number, 1, 4);
/********************************/
         var_work01 := rcd_lads_ctl_rec_vpi.z_src_description;

         IF NOT (var_text01 IS NULL)
         THEN
            var_work01 := var_text01;
         END IF;

         row_recipe_src_text.src_type := rcd_lads_ctl_rec_vpi.z_src_type;
         row_recipe_src_text.machine_code :=
                                         rcd_lads_ctl_rec_vpi.z_src_machine_id;
         var_work02 := rcd_lads_ctl_rec_vpi.z_src_long_text;

         IF NOT (var_text02 IS NULL)
         THEN
            var_work02 := var_text02;
         END IF;

         row_recipe_src_text.plant := row_recipe_header.plant;
         /*-*/
         /* Create the process order source text
         /*-*/
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT + 1).proc_order :=
                                                row_recipe_src_text.proc_order;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).operation :=
                                                 row_recipe_src_text.operation;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).phase :=
                                                     row_recipe_src_text.phase;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).seq :=
                                                       row_recipe_src_text.seq;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).src_type :=
                                                  row_recipe_src_text.src_type;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).machine_code :=
                                              row_recipe_src_text.machine_code;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).plant :=
                                                     row_recipe_src_text.plant;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt01_sidx := 0;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt01_eidx := 0;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt02_sidx := 0;
         tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt02_eidx := 0;

         /*-*/
         /* Create the process order source text - src_text
         /*-*/
         IF NOT (var_work01 IS NULL)
         THEN
            tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt01_sidx :=
                                                  tbl_recipe_text01.COUNT + 1;
            var_index := 1;

            LOOP
               var_wrk_text := SUBSTR (var_work01, var_index, 500);

               IF var_wrk_text IS NULL
               THEN
                  EXIT;
               END IF;

               tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt01_eidx :=
                                                   tbl_recipe_text01.COUNT + 1;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT + 1).proc_order :=
                                                row_recipe_src_text.proc_order;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).operation :=
                                                 row_recipe_src_text.operation;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).phase :=
                                                     row_recipe_src_text.phase;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).seq :=
                                                       row_recipe_src_text.seq;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).text_data :=
                                                                  var_wrk_text;
               var_index := var_index + 500;
            END LOOP;
         END IF;

         /*-*/
         /* Create the process order source text - detail_desc
         /*-*/
         IF NOT (var_work02 IS NULL)
         THEN
            tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt02_sidx :=
                                                  tbl_recipe_text02.COUNT + 1;
            var_index := 1;

            LOOP
               var_wrk_text := SUBSTR (var_work02, var_index, 500);

               IF var_wrk_text IS NULL
               THEN
                  EXIT;
               END IF;

               tbl_recipe_src_text (tbl_recipe_src_text.COUNT).txt02_eidx :=
                                                   tbl_recipe_text02.COUNT + 1;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT + 1).proc_order :=
                                                row_recipe_src_text.proc_order;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).operation :=
                                                 row_recipe_src_text.operation;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).phase :=
                                                     row_recipe_src_text.phase;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).seq :=
                                                       row_recipe_src_text.seq;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).text_data :=
                                                                  var_wrk_text;
               var_index := var_index + 500;
            END LOOP;
         END IF;
      /*-*/
      /* The bds_recipe_resource row data
      /*-*/
      ELSIF rcd_lads_ctl_rec_vpi.z_src_type = 'B'
      THEN
         /*-*/
         /* Set and validate the bds_recipe_resource row data
         /*-*/
         IF     NOT (rcd_lads_ctl_rec_vpi.pppi_operation IS NULL)
            AND NOT (rcd_lads_ctl_rec_vpi.pppi_phase_resource IS NULL)
         THEN
            /*-*/
            /* Set the values
            /*-*/
            IF NOT (rcd_lads_ctl_rec_vpi.pppi_export_data IS NULL)
            THEN
               row_recipe_resource.batch_qty :=
                                        rcd_lads_ctl_rec_vpi.pppi_export_data;
            ELSE
               row_recipe_resource.batch_qty :=
                                             rcd_lads_ctl_rec_vpi.z_src_value;
            END IF;

            row_recipe_resource.batch_uom := rcd_lads_ctl_rec_vpi.z_src_uom;

            /*-*/
            /* Update the bds_recipe_resource row
            /*-*/
            IF tbl_recipe_resource.EXISTS (rcd_lads_ctl_rec_vpi.pppi_operation)
            THEN
               tbl_recipe_resource (rcd_lads_ctl_rec_vpi.pppi_operation).batch_qty :=
                                                row_recipe_resource.batch_qty;
               tbl_recipe_resource (rcd_lads_ctl_rec_vpi.pppi_operation).batch_uom :=
                                                row_recipe_resource.batch_uom;
            END IF;
         END IF;
      /*-*/
      /* The bds_recipe_src_value row data
      /*-*/
      ELSIF (   rcd_lads_ctl_rec_vpi.z_src_type = 'V'
             OR rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1'
            )
      THEN
         /*-*/
         /* Set and validate the bds_recipe_src_value row data
         /*-*/
         row_recipe_src_value.proc_order := row_recipe_header.proc_order;
         row_recipe_src_value.operation :=
                                          rcd_lads_ctl_rec_vpi.pppi_operation;
         row_recipe_src_value.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
/********************************/
/* Jeff Phillipson - 28/10/2004 */
         row_recipe_src_value.seq :=
                        SUBSTR (rcd_lads_ctl_rec_tpi.proc_instr_number, 1, 4);
/********************************/
         row_recipe_src_value.src_tag := rcd_lads_ctl_rec_vpi.z_src_id;
         var_work01 := rcd_lads_ctl_rec_vpi.z_src_description;

         IF NOT (var_text01 IS NULL)
         THEN
            var_work01 := var_text01;
         END IF;

         IF NOT (rcd_lads_ctl_rec_vpi.pppi_export_data IS NULL)
         THEN
            row_recipe_src_value.src_val :=
                                        rcd_lads_ctl_rec_vpi.pppi_export_data;
         ELSE
            row_recipe_src_value.src_val := rcd_lads_ctl_rec_vpi.z_src_value;
         END IF;

         row_recipe_src_value.src_uom := rcd_lads_ctl_rec_vpi.z_src_uom;
         row_recipe_src_value.machine_code :=
                                         rcd_lads_ctl_rec_vpi.z_src_machine_id;
         var_work02 := rcd_lads_ctl_rec_vpi.z_src_long_text;

         IF NOT (var_text02 IS NULL)
         THEN
            var_work02 := var_text02;
         END IF;

         row_recipe_src_value.plant := row_recipe_header.plant;

         /*-*/
         /* Modify values if src type TEXT1 is used
         /*-*/
         IF rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1'
         THEN
            var_work01 :=
                  var_work01
               || ' '
               || LOWER (row_recipe_src_value.src_val)
               || ' '
               || LOWER (row_recipe_src_value.src_uom);
            row_recipe_src_value.src_val := '';
            row_recipe_src_value.src_uom := '';
         END IF;

         /*-*/
         /* Create the process order source value
         /*-*/
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT + 1).proc_order :=
                                               row_recipe_src_value.proc_order;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).operation :=
                                                row_recipe_src_value.operation;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).phase :=
                                                    row_recipe_src_value.phase;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).seq :=
                                                      row_recipe_src_value.seq;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).src_tag :=
                                                  row_recipe_src_value.src_tag;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).src_val :=
                                                  row_recipe_src_value.src_val;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).src_uom :=
                                                  row_recipe_src_value.src_uom;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).machine_code :=
                                             row_recipe_src_value.machine_code;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).plant :=
                                                    row_recipe_src_value.plant;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt01_sidx := 0;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt01_eidx := 0;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt02_sidx := 0;
         tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt02_eidx := 0;

         /*-*/
         /* Create the process order source value - src_desc
         /*-*/
         IF NOT (var_work01 IS NULL)
         THEN
            tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt01_sidx :=
                                                  tbl_recipe_text01.COUNT + 1;
            var_index := 1;

            LOOP
               var_wrk_text := SUBSTR (var_work01, var_index, 500);

               IF var_wrk_text IS NULL
               THEN
                  EXIT;
               END IF;

               tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt01_eidx :=
                                                   tbl_recipe_text01.COUNT + 1;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT + 1).proc_order :=
                                               row_recipe_src_value.proc_order;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).operation :=
                                                row_recipe_src_value.operation;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).phase :=
                                                    row_recipe_src_value.phase;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).seq :=
                                                      row_recipe_src_value.seq;
               tbl_recipe_text01 (tbl_recipe_text01.COUNT).text_data :=
                                                                  var_wrk_text;
               var_index := var_index + 500;
            END LOOP;
         END IF;

         /*-*/
         /* Create the process order source value - detail_desc
         /*-*/
         IF NOT (var_work02 IS NULL)
         THEN
            tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt02_sidx :=
                                                  tbl_recipe_text02.COUNT + 1;
            var_index := 1;

            LOOP
               var_wrk_text := SUBSTR (var_work02, var_index, 500);

               IF var_wrk_text IS NULL
               THEN
                  EXIT;
               END IF;

               tbl_recipe_src_value (tbl_recipe_src_value.COUNT).txt02_eidx :=
                                                   tbl_recipe_text02.COUNT + 1;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT + 1).proc_order :=
                                               row_recipe_src_value.proc_order;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).operation :=
                                                row_recipe_src_value.operation;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).phase :=
                                                    row_recipe_src_value.phase;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).seq :=
                                                      row_recipe_src_value.seq;
               tbl_recipe_text02 (tbl_recipe_text02.COUNT).text_data :=
                                                                  var_wrk_text;
               var_index := var_index + 500;
            END LOOP;
         END IF;
      END IF;
/*-------------*/
/* End routine */
/*-------------*/
   END process_zmessrc;

/******************************************************/
/* This procedure performs the process ZPHPAN1 routine */
/******************************************************/
   PROCEDURE process_zphpan1
   IS
      /*-*/
      /* Local definitions
      /*-*/
      var_work               VARCHAR2 (1);
      var_space              NUMBER;
      var_space1             NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01
      IS
         SELECT t01.pppi_operation, t01.pppi_phase, t01.pppi_phase_resource,
                t01.z_ps_first_pan_out_char, t01.z_ps_material,
                t01.z_ps_material_short_text, t01.z_ps_material_qty_char,
                t01.z_ps_no_of_pans, t01.z_ps_last_pan_out_char
           FROM (SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_OPERATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_operation,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE_RESOURCE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase_resource,
                          MAX
                             (CASE
                                 WHEN t01.name_char =
                                                     'Z_PS_FIRST_PAN_OUT_CHAR'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_first_pan_out_char,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_MATERIAL'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_material,
                          MAX
                             (CASE
                                 WHEN t01.name_char =
                                                    'Z_PS_MATERIAL_SHORT_TEXT'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_material_short_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_MATERIAL_QTY_CHAR'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_material_qty_char,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_NO_OF_PANS'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_no_of_pans,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_LAST_PAN_OUT_CHAR'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_last_pan_out_char
                     FROM lads_ctl_rec_vpi t01
                    WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                      AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
                 GROUP BY t01.cntl_rec_id, t01.proc_instr_number) t01;

      rcd_lads_ctl_rec_vpi   csr_lads_ctl_rec_vpi_01%ROWTYPE;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE
      THEN
         raise_application_error
            (-20000,
                'Process ZBFBRQ1 (ZATLAS) - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
             || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI'
            );
      END IF;

      /*-*/
      /* Retrieve the ZATLAS data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;

      FETCH csr_lads_ctl_rec_vpi_01
       INTO rcd_lads_ctl_rec_vpi;

      IF csr_lads_ctl_rec_vpi_01%NOTFOUND
      THEN
         raise_application_error
                          (-20000,
                              'Process ZPHPAN1 - Control recipe id ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
                           || ') process instruction number ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.proc_instr_number,
                                       'FM99999990'
                                      )
                           || ') has no associated rows on LADS_CTL_REC_VPI'
                          );
      END IF;

      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;

      /*-*/
      /* copy phase into operation - its not sent in the latest Idoc
      /*-*/
      IF rcd_lads_ctl_rec_vpi.pppi_operation IS NULL
      THEN
         row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
      ELSE
         row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      END IF;

      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;
      row_recipe_bom.material_desc :=
                                 rcd_lads_ctl_rec_vpi.z_ps_material_short_text;
      row_recipe_bom.phantom := 'M';                  -- Phantom made location
      row_recipe_bom.operation_from := NULL;
      row_recipe_bom.pan_qty := rcd_lads_ctl_rec_vpi.z_ps_no_of_pans;
      row_recipe_bom.seq :=
                         SUBSTR (rcd_lads_ctl_rec_tpi.proc_instr_number, 1, 4);
      row_recipe_bom.material_uom :=
         TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,
                       var_space + 1
                      )
              );
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.bf_item := NULL;
      /*-*/
      /* seperate out qty and uom values
      /*-*/
      row_recipe_bom.material_qty := NULL;
      row_recipe_bom.pan_size := NULL;
      row_recipe_bom.last_pan_size := NULL;

      IF rcd_lads_ctl_rec_vpi.z_ps_no_of_pans = 0
      THEN
         row_recipe_bom.pan_size_flag := 'N';
         var_space :=
                     INSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char, ' ');

         BEGIN
            row_recipe_bom.material_qty :=
               convert_to_number
                  (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,
                                 1,
                                 var_space - 1
                                )
                        )
                  );
            row_recipe_bom.material_uom :=
               UPPER
                   (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,
                                  var_space + 1
                                 )
                         )
                   );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHPAN1 - Field - MATERIAL_QTY - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char
                   || ') to a number'
                  );
         END;
      ELSE
         var_space :=
                    INSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char, ' ');
         var_space1 :=
                     INSTR (rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char, ' ');

         BEGIN
            row_recipe_bom.pan_size :=
               convert_to_number
                  (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char,
                                 1,
                                 var_space - 1
                                )
                        )
                  );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      ' Process ZPHPAN1 - Field - FIRST_PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char
                   || ') to a number'
                  );
         END;

         BEGIN
            row_recipe_bom.last_pan_size :=
               convert_to_number
                  (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,
                                 1,
                                 var_space1 - 1
                                )
                        )
                  );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHPAN1 - Field - LAST_PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char
                   || ') to a number'
                  );
         END;

         var_space := INSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char, ' ');

         BEGIN
            row_recipe_bom.material_qty :=
               convert_to_number
                  (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,
                                 1,
                                 var_space - 1
                                )
                        )
                  );
            row_recipe_bom.material_uom :=
               UPPER
                   (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,
                                  var_space + 1
                                 )
                         )
                   );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHPAN1 - Field - MATERIAL_QTY WITH Pan Qty - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char
                   || ') to a number'
                  );
         END;

         row_recipe_bom.pan_size_flag := 'Y';
      END IF;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code :=
                                      rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := NULL;
      row_recipe_resource.batch_uom := NULL;
      row_recipe_resource.plant := row_recipe_header.plant;

      IF     NOT (row_recipe_resource.operation IS NULL)
         AND NOT (row_recipe_resource.resource_code IS NULL)
      THEN
         IF NOT (tbl_recipe_resource.EXISTS (row_recipe_resource.operation))
         THEN
            tbl_recipe_resource (row_recipe_resource.operation).proc_order :=
                                               row_recipe_resource.proc_order;
            tbl_recipe_resource (row_recipe_resource.operation).operation :=
                                                row_recipe_resource.operation;
            tbl_recipe_resource (row_recipe_resource.operation).resource_code :=
                                            row_recipe_resource.resource_code;
            tbl_recipe_resource (row_recipe_resource.operation).batch_qty :=
                                                row_recipe_resource.batch_qty;
            tbl_recipe_resource (row_recipe_resource.operation).batch_uom :=
                                                row_recipe_resource.batch_uom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom :=
                                                  row_recipe_resource.phantom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_desc :=
                                             row_recipe_resource.phantom_desc;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_qty :=
                                              row_recipe_resource.phantom_qty;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_uom :=
                                              row_recipe_resource.phantom_uom;
            tbl_recipe_resource (row_recipe_resource.operation).plant :=
                                                    row_recipe_resource.plant;
         END IF;
      END IF;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom (tbl_recipe_bom.COUNT + 1).proc_order :=
                                                     row_recipe_bom.proc_order;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation :=
                                                      row_recipe_bom.operation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phase := row_recipe_bom.phase;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).seq := row_recipe_bom.seq;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_code :=
                                                  row_recipe_bom.material_code;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_desc :=
                                                  row_recipe_bom.material_desc;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_qty :=
                                                   row_recipe_bom.material_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_uom :=
                                                   row_recipe_bom.material_uom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_prnt :=
                                                  row_recipe_bom.material_prnt;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).bf_item := NULL;
                                                     --row_recipe_bom.bf_item;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).reservation :=
                                                    row_recipe_bom.reservation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).plant := row_recipe_bom.plant;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size :=
                                                       row_recipe_bom.pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).last_pan_size :=
                                                  row_recipe_bom.last_pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size_flag :=
                                                  row_recipe_bom.pan_size_flag;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation_from :=
                                                 row_recipe_bom.operation_from;
/*-------------*/
/* End routine */
/*-------------*/
   END process_zphpan1;

/******************************************************/
/* This procedure performs the process ZPHBRQ1 routine */
/******************************************************/
   PROCEDURE process_zphbrq1
   IS
      /*-*/
      /* Local definitions
      /*-*/
      var_work               VARCHAR2 (1);
      var_space              NUMBER;
      var_space1             NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01
      IS
         SELECT t01.pppi_operation, t01.pppi_phase, t01.pppi_phase_resource,
                t01.z_ps_predecessor, t01.z_ps_first_pan_in_char,
                t01.z_ps_material, t01.z_ps_material_short_text,
                t01.z_ps_last_pan_in_char, t01.z_ps_pan_size_yn
           FROM (SELECT   t01.cntl_rec_id, t01.proc_instr_number,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_OPERATION'
                                    THEN t01.char_value
                              END
                             ) AS pppi_operation,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'PPPI_PHASE_RESOURCE'
                                    THEN t01.char_value
                              END
                             ) AS pppi_phase_resource,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_PREDECESSOR'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_predecessor,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_FIRST_PAN_IN_CHAR'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_first_pan_in_char,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_MATERIAL'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_material,
                          MAX
                             (CASE
                                 WHEN t01.name_char =
                                                    'Z_PS_MATERIAL_SHORT_TEXT'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_material_short_text,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_LAST_PAN_IN_CHAR'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_last_pan_in_char,
                          MAX
                             (CASE
                                 WHEN t01.name_char = 'Z_PS_PAN_SIZE_YN'
                                    THEN t01.char_value
                              END
                             ) AS z_ps_pan_size_yn
                     FROM lads_ctl_rec_vpi t01
                    WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                      AND t01.proc_instr_number =
                                        rcd_lads_ctl_rec_tpi.proc_instr_number
                 GROUP BY t01.cntl_rec_id, t01.proc_instr_number) t01;

      rcd_lads_ctl_rec_vpi   csr_lads_ctl_rec_vpi_01%ROWTYPE;
/*-------------*/
/* Begin block */
/*-------------*/
   BEGIN
      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE
      THEN
         raise_application_error
            (-20000,
                'Process ZPHBRQ1 - Control recipe id ('
             || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
             || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI'
            );
      END IF;

      /*-*/
      /* Retrieve the ZPHBRQ1 data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;

      FETCH csr_lads_ctl_rec_vpi_01
       INTO rcd_lads_ctl_rec_vpi;

      IF csr_lads_ctl_rec_vpi_01%NOTFOUND
      THEN
         raise_application_error
                          (-20000,
                              'Process ZPHBRQ1 - Control recipe id ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.cntl_rec_id)
                           || ') process instruction number ('
                           || TO_CHAR (rcd_lads_ctl_rec_tpi.proc_instr_number,
                                       'FM99999990'
                                      )
                           || ') has no associated rows on LADS_CTL_REC_VPI'
                          );
      END IF;

      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      row_recipe_bom.proc_order := row_recipe_header.proc_order;

      /*-*/
      /* Idoc doesn't send operation so make the operation and phase the same
      /*-*/
      IF rcd_lads_ctl_rec_vpi.pppi_operation IS NULL
      THEN
         row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
      ELSE
         row_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      END IF;

      row_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;
      row_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;
      row_recipe_bom.material_desc :=
                                 rcd_lads_ctl_rec_vpi.z_ps_material_short_text;
      row_recipe_bom.seq :=
                         SUBSTR (rcd_lads_ctl_rec_tpi.proc_instr_number, 1, 4);
      row_recipe_bom.plant := row_recipe_header.plant;
      row_recipe_bom.operation_from := rcd_lads_ctl_rec_vpi.z_ps_predecessor;
      row_recipe_bom.phantom := 'U';                  -- Phantom used location
      row_recipe_bom.pan_size_flag := rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn;
      row_recipe_bom.pan_qty := NULL;
      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      row_recipe_bom.material_qty := NULL;
      row_recipe_bom.pan_size := NULL;
      row_recipe_bom.last_pan_size := NULL;

      IF    row_recipe_bom.pan_size_flag = 'N'
         OR row_recipe_bom.pan_size_flag = 'E'
      THEN
         var_space :=
                     INSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char, ' ');

         BEGIN
            IF var_space = 0
            THEN
               row_recipe_bom.material_qty :=
                  convert_to_number
                           (TRIM (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char)
                           );
            ELSE
               row_recipe_bom.material_qty :=
                  convert_to_number
                     (TRIM
                         (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,
                                  1,
                                  var_space - 1
                                 )
                         )
                     );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHBRQ1 - Field - material qty - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char
                   || ') to a number'
                  );
         END;
      ELSE
         /*-*/
         /* get material qty using first and last pan qty
         /*-*/
         BEGIN
            /*-*/
            /* check on the type of number ie 1,0000 ot 1.098+E2 etc
            /*-*/
            IF INSTR (TRIM (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char),
                      'E') > 0
            THEN
               row_recipe_bom.material_qty :=
                  (  TO_NUMBER
                            (TRIM (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char)
                            )
                   + TO_NUMBER
                             (TRIM (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char)
                             )
                  );
            ELSE
               var_space :=
                     INSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char, ' ');
               var_space1 :=
                      INSTR (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char, ' ');
               row_recipe_bom.material_qty :=
                    (  convert_to_number
                          (TRIM
                              (SUBSTR
                                  (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,
                                   1,
                                   var_space - 1
                                  )
                              )
                          )
                     * 1
                    )
                  + convert_to_number
                       (TRIM
                           (SUBSTR
                                  (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,
                                   1,
                                   var_space1 - 1
                                  )
                           )
                       );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHBRQ1 - Field - PAN_SIZE * PAN_QTY - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char
                   || ' or '
                   || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char
                   || ') to a number'
                  );
         END;

         /*-*/
         /* get pan size
         /*-*/
         row_recipe_bom.pan_size := NULL;

         BEGIN
            row_recipe_bom.pan_size :=
               convert_to_number
                  (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,
                                 1,
                                 var_space - 1
                                )
                        )
                  );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHBRQ1  - Field - PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char
                   || ') to a number'
                  );
         END;

         /*-*/
         /* get last pan size
         /*-*/
         row_recipe_bom.last_pan_size := NULL;

         BEGIN
            /*-*/
            /* Changed the variable name from var_space to var_space1
            /* Added by JP 26 May 2006
            /* For the first time a Proc Order was sent with a smaller numerical value length for last_pan_size
            /*-*/
            row_recipe_bom.last_pan_size :=
               convert_to_number
                   (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,
                                  1,
                                  var_space1 - 1
                                 )
                         )
                   );
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error
                  (-20000,
                      'Process ZPHBRQ1 - Field - LAST_PAN_SIZE - Unable to convert ('
                   || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char
                   || ') to a number'
                  );
         END;
      END IF;

      IF var_space = 0
      THEN
         row_recipe_bom.material_uom := NULL;
      ELSE
         row_recipe_bom.material_uom :=
            UPPER (TRIM (SUBSTR (rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,
                                 var_space + 1
                                )
                        )
                  );
      END IF;

      /*-*/
      /* Create the process order resource when required
      /*-*/
      row_recipe_resource.proc_order := row_recipe_header.proc_order;
      row_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
      row_recipe_resource.resource_code :=
                                      rcd_lads_ctl_rec_vpi.pppi_phase_resource;
      row_recipe_resource.batch_qty := NULL;
      row_recipe_resource.batch_uom := NULL;
      row_recipe_resource.plant := row_recipe_header.plant;

      IF     NOT (row_recipe_resource.operation IS NULL)
         AND NOT (row_recipe_resource.resource_code IS NULL)
      THEN
         IF NOT (tbl_recipe_resource.EXISTS (row_recipe_resource.operation))
         THEN
            tbl_recipe_resource (row_recipe_resource.operation).proc_order :=
                                               row_recipe_resource.proc_order;
            tbl_recipe_resource (row_recipe_resource.operation).operation :=
                                                row_recipe_resource.operation;
            tbl_recipe_resource (row_recipe_resource.operation).resource_code :=
                                            row_recipe_resource.resource_code;
            tbl_recipe_resource (row_recipe_resource.operation).batch_qty :=
                                                row_recipe_resource.batch_qty;
            tbl_recipe_resource (row_recipe_resource.operation).batch_uom :=
                                                row_recipe_resource.batch_uom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom :=
                                                  row_recipe_resource.phantom;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_desc :=
                                             row_recipe_resource.phantom_desc;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_qty :=
                                              row_recipe_resource.phantom_qty;
            tbl_recipe_resource (row_recipe_resource.operation).phantom_uom :=
                                              row_recipe_resource.phantom_uom;
            tbl_recipe_resource (row_recipe_resource.operation).plant :=
                                                    row_recipe_resource.plant;
         END IF;
      END IF;

      /*-*/
      /* Create the process order BOM
      /*-*/
      tbl_recipe_bom (tbl_recipe_bom.COUNT + 1).proc_order :=
                                                     row_recipe_bom.proc_order;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation :=
                                                      row_recipe_bom.operation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phase := row_recipe_bom.phase;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).seq := row_recipe_bom.seq;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_code :=
                                                  row_recipe_bom.material_code;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_desc :=
                                                  row_recipe_bom.material_desc;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_qty :=
                                                   row_recipe_bom.material_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_uom :=
                                                   row_recipe_bom.material_uom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).material_prnt :=
                                                  row_recipe_bom.material_prnt;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).bf_item := row_recipe_bom.bf_item;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).reservation :=
                                                    row_recipe_bom.reservation;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).plant := row_recipe_bom.plant;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size :=
                                                       row_recipe_bom.pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).last_pan_size :=
                                                  row_recipe_bom.last_pan_size;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_size_flag :=
                                                  row_recipe_bom.pan_size_flag;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).pan_qty := row_recipe_bom.pan_qty;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).phantom := row_recipe_bom.phantom;
      tbl_recipe_bom (tbl_recipe_bom.COUNT).operation_from :=
                                                 row_recipe_bom.operation_from;
/*-------------*/
/* End routine */
/*-------------*/
   END process_zphbrq1;

   FUNCTION convert_to_number (par_value VARCHAR2)
      RETURN NUMBER
   IS
      var_result   NUMBER;
   BEGIN
      IF (INSTR (par_value, ',') = 0)
      THEN
         var_result := TO_NUMBER (par_value);
      ELSE
         var_result := TO_NUMBER (par_value, 'FM999G999G999D999');
      END IF;

      RETURN var_result;
   END convert_to_number;
END ics_ladpdb01_extract;
/


--
-- ICS_LADPDB01_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB01_EXTRACT FOR ICS_APP.ICS_LADPDB01_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB01_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB01_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB01_EXTRACT TO LICS_APP;

