DROP PACKAGE MANU_APP.RECIPE_DIFFERENCE;

CREATE OR REPLACE PACKAGE MANU_APP.Recipe_Difference AS
/******************************************************************************
   NAME:       PO_BOM_DIFFERENCE
   PURPOSE:    This function will check if and BOM or SRC values have changed
               using the latest process order as a refrence compared with the last
               procedure order with the same material code.
               A check is also made on the material and src counts
               '
               If changes are found they will be recorded in a table PO_BOM_DIFFERENCES
               The requirement for this is for Snack - whoose PO BOM's do not change much
               so they need to know when a change occurs
               '
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        9/03/2007      Jeff Phillipson       1. Created this package.
******************************************************************************/

  PROCEDURE EXECUTE(i_proc_order IN VARCHAR2 DEFAULT '');

END Recipe_Difference;
/


DROP PACKAGE BODY MANU_APP.RECIPE_DIFFERENCE;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Recipe_Difference AS

	/*-*/
	/* variables
	/*-*/
    var_exit  BOOLEAN;
    var_count NUMBER;
    rcd_recpe_hdr recpe_hdr%ROWTYPE;
    var_current_proc_order recpe_hdr.proc_order%TYPE;
    var_last_proc_order recpe_hdr.proc_order%TYPE;
  
     
    /*-*/
	/* Type declarations
	/*-*/
    TYPE manu_proc_orders_object IS TABLE OF recpe_hdr.proc_order%TYPE INDEX BY BINARY_INTEGER;
    manu_proc_orders manu_proc_orders_object;
    
	/*-*/
	/* Private exceptions
	/*-*/
	application_exception EXCEPTION;
	PRAGMA EXCEPTION_INIT(application_exception, -20000);

    /*-*/
	/* Cursor definition
	/*-*/
    /* get all available process orders */
    CURSOR csr_po IS
    SELECT proc_order FROM recpe_hdr 
     WHERE TRUNC(run_start_datime) >= TRUNC(SYSDATE)
       AND TRUNC(run_start_datime) < TRUNC(SYSDATE)+ 40
       AND proc_order NOT IN (SELECT proc_order FROM recpe_diff)
       AND ASCII(SUBSTR(proc_order,1,1)) BETWEEN ASCII('0') AND ASCII('9');
    
    rcd_po csr_po%ROWTYPE;
    
    
    /* get the current proc order bom */
    CURSOR csr_get_recpe_dtl
    IS
    SELECT t01.proc_order, 
           t01.matl_code prnt_matl_code, 
           t02.opertn, 
           t02.phase, 
           t02.seq, 
           t02.matl_code, 
           TO_CHAR(ROUND(t02.bom_qty/t01.qty,6)) val, 
           t02.UOM, 
           t01.run_start_datime,
           TO_CHAR(t02.bom_qty) qty, 
           t01.qty po_qty,
           'MATL' TYPE
      FROM recpe_hdr t01, 
           recpe_dtl t02
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t01.proc_order = rcd_recpe_hdr.proc_order
     UNION
    SELECT t01.proc_order proc_order, 
           t01.matl_code prnt_matl_code, 
           t02.opertn opertn, 
           t02.phase phase, 
           t02.seq seq, 
           TO_CHAR(t02.mpi_tag) matl_code, 
           TO_CHAR(t02.mpi_val) val, 
           t02.mpi_UOM uom, 
           t01.run_start_datime run_start_datime,
           '0' qty, 
           t01.qty po_qty,
           'SRC' TYPE
      FROM recpe_hdr t01, 
           recpe_val t02
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t02.mpi_tag IS NOT NULL
       AND t01.proc_order = rcd_recpe_hdr.proc_order 
     ORDER BY 12,3,4,5;
    
    rcd_get_recpe_dtl csr_get_recpe_dtl%ROWTYPE;
    
    /* get the last proc order bom */
    CURSOR csr_get_last_recpe_dtl
    IS
    SELECT t01.proc_order, 
           t01.matl_code prnt_matl_code, 
           t02.opertn, 
           t02.phase, 
           t02.seq, 
           t02.matl_code, 
           TO_CHAR(ROUND(t02.bom_qty/t01.qty,6)) val, 
           t02.UOM, 
           t01.run_start_datime,
           t02.bom_qty qty, 
           t01.qty po_qty
      FROM recpe_hdr t01, 
           recpe_dtl t02
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t01.proc_order = var_last_proc_order
       AND t02.opertn = rcd_get_recpe_dtl.opertn
       AND t02.phase = rcd_get_recpe_dtl.phase
       AND t02.matl_code = rcd_get_recpe_dtl.matl_code;
       
    
    
    -- cursor will get all src's in the last proc order
    CURSOR csr_get_last_recpe_val
    IS
    SELECT t01.proc_order, 
           t01.matl_code prnt_matl_code, 
           t02.opertn, 
           t02.phase, 
           t02.seq, 
           TO_CHAR(t02.mpi_tag) matl_code, 
           TO_CHAR(mpi_val) val, 
           t02.mpi_UOM uom, 
           t01.run_start_datime,
           0 qty, 
           t01.qty po_qty
      FROM recpe_hdr t01, 
           recpe_val t02
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t02.mpi_tag IS NOT NULL
       AND t01.proc_order =  var_last_proc_order
       AND t02.opertn = rcd_get_recpe_dtl.opertn
       AND t02.phase = rcd_get_recpe_dtl.phase
       AND t02.mpi_tag = rcd_get_recpe_dtl.matl_code;
       
   rcd_get_last_recpe_dtl csr_get_last_recpe_val%ROWTYPE;
       
    /* get the last proc order code used */
    CURSOR csr_get_last_proc_order
    IS
    SELECT proc_order 
      FROM recpe_hdr
     WHERE run_start_datime IN (SELECT MAX(t02.run_start_datime) start_datime
                                  FROM recpe_hdr t01,
                                       recpe_hdr t02
                                 WHERE t01.matl_code = t02.matl_code
                                   AND t01.proc_order = rcd_recpe_hdr.proc_order
                                   AND t01.run_start_datime > t02.run_start_datime
                                   AND ASCII(SUBSTR(t02.proc_order,1,1)) BETWEEN ASCII('0') AND ASCII('9')); 

    rcd_get_last_proc_order csr_get_last_proc_order%ROWTYPE;
    
    rcd_recpe_diff recpe_diff%ROWTYPE;
          
    
    -- cursor will get all materials in the last proc order
    CURSOR csr_old_entries
    IS
    SELECT t01.proc_order last_proc_order, 
           t01.matl_code last_prnt_matl_code, 
           t02.opertn last_opertn, 
           t02.phase last_phase, 
           t02.seq last_seq, 
           t02.matl_code last_matl_code, 
           TO_CHAR(ROUND(t02.bom_qty/t01.qty,6)) last_val, 
           t02.UOM last_uom, 
           t01.run_start_datime last_run_start_datime,
           t02.bom_qty last_qty, 
           t01.qty last_po_qty
      FROM recpe_hdr t01, 
           recpe_dtl t02
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t01.proc_order = var_last_proc_order
       AND t02.matl_code NOT IN (SELECT t02.matl_code 
                                   FROM recpe_hdr t01,
                                        recpe_dtl t02
                                  WHERE t01.cntl_rec_id = t02.cntl_rec_id
                                    AND t01.proc_order = var_current_proc_order );
    
    rcd_old_entries csr_old_entries%ROWTYPE;
    
    -- cursor will get all srcs in the last proc order
    CURSOR csr_old_src_entries
    IS
    SELECT t01.proc_order last_proc_order, 
           t01.matl_code last_prnt_matl_code, 
           t02.opertn last_opertn, 
           t02.phase last_phase, 
           t02.seq last_seq, 
           t02.mpi_val last_matl_code, 
           TO_CHAR(mpi_val) last_val, 
           t02.mpi_UOM last_uom, 
           t01.run_start_datime last_run_start_datime,
           0 last_qty, 
           t01.qty last_po_qty
      FROM recpe_hdr t01, 
           recpe_val t02
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t01.proc_order = var_last_proc_order
       AND t02.mpi_val NOT IN (SELECT t02.mpi_val 
                                 FROM recpe_hdr t01,
                                      recpe_val t02
                                WHERE t01.cntl_rec_id = t02.cntl_rec_id
                                  AND t01.proc_order = var_current_proc_order);
  
    rcd_old_src_entries csr_old_src_entries%ROWTYPE;
          
             
  PROCEDURE EXECUTE(i_proc_order IN VARCHAR2 DEFAULT '') 
  AS
  
     v_seq NUMBER;
     var_save  BOOLEAN;
     
  BEGIN
 
      GOTO FINISH;
      
      DBMS_OUTPUT.ENABLE(Constants.DBMS_OUTPUT_BUF_SIZE);
 
      manu_proc_orders.DELETE;
      
      /*-*/
      /* the first section will examine the BOM data and identify any differences
      /*-*/
      IF i_proc_order IS NULL THEN
          /*-*/
          /* get all proc orders for this time frame into a table type
          /*-*/
          OPEN csr_po;
          FETCH csr_po BULK COLLECT INTO manu_proc_orders LIMIT 500;
          CLOSE csr_po;
       ELSE
          manu_proc_orders(manu_proc_orders.COUNT+1) := i_proc_order;
       END IF;  
      
      
       FOR i IN 1 .. manu_proc_orders.COUNT LOOP
            rcd_recpe_hdr.proc_order := manu_proc_orders(i);
            SELECT COUNT(*) INTO var_count FROM recpe_diff WHERE proc_order = manu_proc_orders(i);
            IF var_count = 0 THEN
                var_current_proc_order := rcd_recpe_hdr.proc_order;
                /*-*/
                /* get last proc order
                /*-*/
                OPEN csr_get_last_proc_order;
                   FETCH csr_get_last_proc_order INTO rcd_get_last_proc_order;
                   IF csr_get_last_proc_order%NOTFOUND THEN
                       var_exit := TRUE;
                   ELSE
                       var_last_proc_order := rcd_get_last_proc_order.proc_order;
                       var_exit := FALSE;
                   END IF;
                CLOSE csr_get_last_proc_order;
                
                IF NOT var_exit THEN
                    /*-*/
                    /* get current proc order data
                    /*-*/
                    OPEN csr_get_recpe_dtl;
                    LOOP
                        FETCH csr_get_recpe_dtl INTO rcd_get_recpe_dtl;
                        EXIT WHEN csr_get_recpe_dtl%NOTFOUND;
                            IF rcd_get_recpe_dtl.TYPE = 'MATL' THEN
	                            OPEN csr_get_last_recpe_dtl;
	                            FETCH csr_get_last_recpe_dtl INTO rcd_get_last_recpe_dtl;
	                            IF NOT csr_get_last_recpe_dtl%NOTFOUND THEN
	                                /*-*/
	                                /* compare qty
	                                /*-*/
	                                IF rcd_get_last_recpe_dtl.val <> rcd_get_recpe_dtl.val THEN
	                                    var_save := TRUE;
	                                ELSE
	                                    var_save := FALSE;
	                                END IF;
	                            ELSE
	                                /*-*/
	                                /* insert a record since the last po didn't have this material
	                                /*-*/
	                                rcd_get_last_recpe_dtl.proc_order := var_last_proc_order;
	                                rcd_get_last_recpe_dtl.opertn := NULL;
	                                rcd_get_last_recpe_dtl.phase := NULL;
	                                rcd_get_last_recpe_dtl.seq := NULL;
	                                rcd_get_last_recpe_dtl.matl_code := NULL;
	                                rcd_get_last_recpe_dtl.val := NULL;
	                                rcd_get_last_recpe_dtl.uom := NULL;
	                                rcd_get_last_recpe_dtl.run_start_datime := NULL;
	                                var_save := TRUE;
	                            END IF;
	                            CLOSE csr_get_last_recpe_dtl;
                            END IF; 
                            IF rcd_get_recpe_dtl.TYPE = 'SRC' THEN
                                OPEN csr_get_last_recpe_val;
	                            FETCH csr_get_last_recpe_val INTO rcd_get_last_recpe_dtl;
	                            IF NOT csr_get_last_recpe_val%NOTFOUND THEN
	                                /*-*/
	                                /* compare qty
	                                /*-*/
	                                IF rcd_get_last_recpe_dtl.val <> rcd_get_recpe_dtl.val THEN
	                                    var_save := TRUE;
	                                ELSE
	                                    var_save := FALSE;
	                                END IF;
	                            ELSE
	                                /*-*/
	                                /* insert a record since the last po didn't have this material
	                                /*-*/
	                                rcd_get_last_recpe_dtl.proc_order := var_last_proc_order;
	                                rcd_get_last_recpe_dtl.opertn := NULL;
	                                rcd_get_last_recpe_dtl.phase := NULL;
	                                rcd_get_last_recpe_dtl.seq := NULL;
	                                rcd_get_last_recpe_dtl.matl_code := NULL;
	                                rcd_get_last_recpe_dtl.val := NULL;
	                                rcd_get_last_recpe_dtl.uom := NULL;
	                                rcd_get_last_recpe_dtl.run_start_datime := NULL;
	                                var_save := TRUE;
	                            END IF;
	                            CLOSE csr_get_last_recpe_val;
                            END IF;                       
                            IF var_save THEN      
		                        /* the 2 values do not match */
			                    SELECT RECPE_DTL_id_seq.NEXTVAL INTO v_seq FROM dual;
			                    INSERT INTO recpe_diff
			                    VALUES (v_seq,
	                                    rcd_get_recpe_dtl.proc_order,
	                                    rcd_get_recpe_dtl.opertn,
	                                    rcd_get_recpe_dtl.phase,
	                                    rcd_get_recpe_dtl.seq,
	                                    SUBSTR(rcd_get_recpe_dtl.matl_code,1,32),
	                                    rcd_get_recpe_dtl.val,
	                                    rcd_get_recpe_dtl.uom,
	                                    rcd_get_recpe_dtl.run_start_datime,
	                                    rcd_get_last_recpe_dtl.proc_order,
	                                    rcd_get_last_recpe_dtl.opertn ,
	                                    rcd_get_last_recpe_dtl.phase ,
	                                    rcd_get_last_recpe_dtl.seq,
	                                    SUBSTR(rcd_get_last_recpe_dtl.matl_code,1,32),
	                                    rcd_get_last_recpe_dtl.val,
	                                    rcd_get_last_recpe_dtl.uom,
	                                    rcd_get_last_recpe_dtl.run_start_datime,
	                                    SYSDATE,
	                                    rcd_get_recpe_dtl.TYPE);
                            END IF;
                        --DBMS_OUTPUT.PUT_LINE('material' || rcd_bom.opertn);
                    END LOOP;
                    CLOSE csr_get_recpe_dtl;
                END IF;
                
                /*-*/
                /* get any entries that are in the old procedure order but not in the new
                /*-*/
                OPEN csr_old_entries;
                LOOP
                   FETCH csr_old_entries INTO rcd_old_entries;
                   EXIT WHEN csr_old_entries%NOTFOUND;
                       SELECT RECPE_DTL_id_seq.NEXTVAL INTO v_seq FROM dual;
		               INSERT INTO recpe_diff
		               VALUES (v_seq,
                               var_current_proc_order,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               rcd_old_entries.last_proc_order,
                               rcd_old_entries.last_opertn ,
                               rcd_old_entries.last_phase ,
                               rcd_old_entries.last_seq,
                               rcd_old_entries.last_matl_code,
                               rcd_old_entries.last_val,
                               rcd_old_entries.last_uom,
                               rcd_old_entries.last_run_start_datime,
                               SYSDATE,
                               rcd_get_recpe_dtl.TYPE);
                END LOOP;
                CLOSE csr_old_entries;
                
                /*-*/
                /* get any entries that are in the old procedure order but not in the new
                /*-*/
                OPEN csr_old_src_entries;
                LOOP
                   FETCH csr_old_src_entries INTO rcd_old_src_entries;
                   EXIT WHEN csr_old_src_entries%NOTFOUND;
                       SELECT RECPE_DTL_id_seq.NEXTVAL INTO v_seq FROM dual;
		               INSERT INTO recpe_diff
		               VALUES (v_seq,
                               var_current_proc_order,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               rcd_old_src_entries.last_proc_order,
                               rcd_old_src_entries.last_opertn ,
                               rcd_old_src_entries.last_phase ,
                               rcd_old_src_entries.last_seq,
                               rcd_old_src_entries.last_matl_code,
                               rcd_old_src_entries.last_val,
                               rcd_old_src_entries.last_uom,
                               rcd_old_src_entries.last_run_start_datime,
                               SYSDATE,
                               rcd_get_recpe_dtl.TYPE);
                END LOOP;
                CLOSE csr_old_src_entries;  
              
            END IF;
       
       END LOOP;
  <<FINISH>>
	   DBMS_OUTPUT.PUT_LINE('PO: ' || rcd_recpe_hdr.proc_order);
  EXCEPTION
      WHEN TOO_MANY_ROWS THEN
          RAISE_APPLICATION_ERROR(-20000,'PO_Bom_Difference.Execute : TOO_MANY_ROWS' || CHR(13) 
          ||  var_current_proc_order || ' - ' ||  var_last_proc_order);	
        
         
      
      WHEN OTHERS THEN
          IF csr_po%isopen THEN
              CLOSE csr_po;
          END IF;
          IF csr_get_recpe_dtl%isopen THEN
              CLOSE csr_get_recpe_dtl;
          END IF;
          IF csr_get_last_recpe_dtl%isopen THEN
              CLOSE csr_get_last_recpe_dtl;
          END IF;
          IF csr_get_last_recpe_val%isopen THEN
              CLOSE csr_get_last_recpe_val;
          END IF;
          IF csr_get_last_proc_order%isopen THEN
              CLOSE csr_get_last_proc_order;
          END IF;
          IF csr_old_entries%isopen THEN
              CLOSE csr_old_entries;
          END IF;
          IF csr_old_src_entries%isopen THEN
              CLOSE csr_old_src_entries;
          END IF;
	      RAISE_APPLICATION_ERROR(-20000,'PO_Bom_Difference.Execute : Others ' || CHR(13)
              || ' PO:' || var_current_proc_order||  CHR(13)
              || ' Last PO: ' || var_last_proc_order ||  CHR(13)
               || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1900));	
        
          
  END;

END Recipe_Difference;
/


DROP PUBLIC SYNONYM RECIPE_DIFFERENCE;

CREATE PUBLIC SYNONYM RECIPE_DIFFERENCE FOR MANU_APP.RECIPE_DIFFERENCE;


GRANT EXECUTE ON MANU_APP.RECIPE_DIFFERENCE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RECIPE_DIFFERENCE TO BDS_APP;

