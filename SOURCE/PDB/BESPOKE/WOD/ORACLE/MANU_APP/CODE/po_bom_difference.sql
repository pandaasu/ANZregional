DROP PACKAGE MANU_APP.PO_BOM_DIFFERENCE;

CREATE OR REPLACE PACKAGE MANU_APP.Po_Bom_Difference AS
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

END Po_Bom_Difference;
/


DROP PACKAGE BODY MANU_APP.PO_BOM_DIFFERENCE;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Po_Bom_Difference AS
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

	/*-*/
	/* variables
	/*-*/
    v_count NUMBER;
    rcd_recpe_hdr recpe_hdr%ROWTYPE;
    v_current_proc_order recpe_hdr.proc_order%TYPE;
    v_last_proc_order recpe_hdr.proc_order%TYPE;
   -- v_proc_order recpe_hdr.proc_order%TYPE;
     
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
    /* compare the bom records */
    CURSOR csr_bom IS
    SELECT t03.*, t09.*
      FROM (/* get the current proc order bom */
           SELECT t01.proc_order, t01.matl_code prnt_matl_code, t02.opertn, t02.phase, t02.seq, t02.matl_code, TO_CHAR(ROUND(t02.bom_qty/t01.qty,6)) val 
             FROM recpe_hdr t01, recpe_dtl t02
            WHERE t01.cntl_rec_id = t02.cntl_rec_id)  t03,
           (/* get the last proc order using the same material as the current one - if it exists 
           and then get the last bom details */
           SELECT t04.proc_order last_proc_order, t05.opertn last_opertn, t05.phase last_phase, t05.seq last_seq, t05.matl_code last_matl_code, TO_CHAR(ROUND(t05.bom_qty/t04.qty,6)) last_bom_qty 
             FROM recpe_hdr t04, recpe_dtl t05
            WHERE t04.cntl_rec_id = t05.cntl_rec_id
              AND t04.proc_order IN (SELECT proc_order 
                                   FROM (SELECT t06.proc_order,
                                                rank() OVER (PARTITION BY t06.proc_order,
                                                                          t06.matl_code
                                                                 ORDER BY t06.run_start_datime DESC) AS rnkseq  
                                           FROM recpe_hdr t06
                                          WHERE t06.proc_order <> rcd_recpe_hdr.proc_order
                                            AND matl_code = (SELECT matl_code 
                                                               FROM recpe_hdr t07
                                                              WHERE t07.proc_order = rcd_recpe_hdr.proc_order)
                                            AND run_start_datime < SYSDATE) t08
                                  /* this will get the last proc order only */
                                  WHERE rnkseq = 1)) t09 
     WHERE t03.matl_code = t09.last_matl_code(+)
       AND t03.opertn = t09.last_opertn(+)
       AND t03.phase = t09.last_phase(+)
       AND t03.val <> t09.last_bom_qty(+) -- this will filter only mismatch recordsets
       AND t03.proc_order = rcd_recpe_hdr.proc_order
       ORDER BY 3,4,5;
       
    rcd_bom csr_bom%ROWTYPE;
    
    /* compare the src records */
    CURSOR csr_src IS
    SELECT t03.*, t09.*
      FROM (/* get the current proc order bom */
           SELECT t01.proc_order, t01.matl_code prnt_matl_code, t02.opertn, t02.phase, t02.seq, t02.mpi_tag, t02.mpi_val 
             FROM recpe_hdr t01, recpe_val t02
            WHERE t01.cntl_rec_id = t02.cntl_rec_id)  t03,
           (/* get the last proc order using the same material as the current one - if it exists 
           and then get the last bom details */
           SELECT t04.proc_order last_proc_order, t05.opertn last_opertn, t05.phase last_phase, t05.seq last_seq, t05.mpi_tag last_mpi_tag, t05.mpi_val last_mpi_val 
             FROM recpe_hdr t04, recpe_val t05
            WHERE t04.cntl_rec_id = t05.cntl_rec_id
              AND t04.proc_order IN (SELECT proc_order 
                                   FROM (SELECT t06.proc_order,
                                                rank() OVER (PARTITION BY t06.proc_order,
                                                                          t06.matl_code
                                                                 ORDER BY t06.run_start_datime DESC) AS rnkseq  
                                           FROM recpe_hdr t06
                                          WHERE t06.proc_order <> rcd_recpe_hdr.proc_order
                                            AND matl_code = (SELECT matl_code 
                                                               FROM recpe_hdr t07
                                                              WHERE t07.proc_order = rcd_recpe_hdr.proc_order)
                                            AND run_start_datime < SYSDATE) t08
                                  /* this will get the last proc order only */
                                  WHERE rnkseq = 1)) t09 
     WHERE t03.mpi_tag = t09.last_mpi_tag(+)
       AND t03.opertn = t09.last_opertn(+)
       AND t03.phase = t09.last_phase(+)
       AND t03.seq = t09.last_seq(+)
       AND t03.mpi_val <> t09.last_mpi_val(+) -- this will filter only mismatch recordsets
       AND t03.proc_order = rcd_recpe_hdr.proc_order
       AND t03.mpi_tag IS NOT NULL
       ORDER BY 3,4,5;
       
    rcd_src csr_src%ROWTYPE;
    
    
    /* get all available process orders */
    CURSOR csr_po IS
    SELECT proc_order FROM recpe_hdr 
     WHERE TRUNC(run_start_datime) >= TRUNC(SYSDATE)
       AND TRUNC(run_start_datime) < TRUNC(SYSDATE)+ 4;
    
    rcd_po csr_po%ROWTYPE;
    
    /*-*/
    /* this cursor will provide a value of the BOM count between
    /* the current and last procedure order - a value of zero makes them equal
    /*-*/
    CURSOR csr_count IS
    SELECT ABS(t01.current_val - t02.last_val) 
    FROM (SELECT COUNT(proc_order) current_val
           FROM recpe_hdr t01, recpe_dtl t02
          WHERE t01.cntl_rec_id = t02.cntl_rec_id
            AND (t01.proc_order = v_current_proc_order)
          GROUP BY proc_order) t01,
         (SELECT COUNT(proc_order) last_val
           FROM recpe_hdr t01, recpe_dtl t02
          WHERE t01.cntl_rec_id = t02.cntl_rec_id
            AND (t01.proc_order = v_last_proc_order)
          GROUP BY proc_order) t02;
       
    /*-*/
    /* this cursor will provide a value of the SRC count between
    /* the current and last procedure order - a value of zero makes them equal
    /*-*/
    CURSOR csr_count01 IS
    SELECT ABS(t01.current_val - t02.last_val) 
    FROM (SELECT COUNT(proc_order) current_val
           FROM recpe_hdr t01, recpe_val t02
          WHERE t01.cntl_rec_id = t02.cntl_rec_id
            AND (t01.proc_order = v_current_proc_order)
          GROUP BY proc_order) t01,
         (SELECT COUNT(proc_order) last_val
           FROM recpe_hdr t01, recpe_val t02
          WHERE t01.cntl_rec_id = t02.cntl_rec_id
            AND (t01.proc_order = v_last_proc_order)
          GROUP BY proc_order) t02;
          
             
  PROCEDURE EXECUTE(i_proc_order IN VARCHAR2 DEFAULT '') 
  AS
  
     v_seq NUMBER;
     
  BEGIN
 
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
            OPEN csr_bom;
            LOOP
               FETCH csr_bom INTO rcd_bom;
               EXIT WHEN csr_bom%NOTFOUND;
               
               v_current_proc_order := rcd_bom.proc_order;
               v_last_proc_order := rcd_bom.last_proc_order;
                              
               IF rcd_bom.val <> TO_CHAR(rcd_bom.last_bom_qty) AND rcd_bom.last_proc_order IS NOT NULL THEN
                   /* the 2 values do not match */
                   SELECT RECPE_DTL_id_seq.NEXTVAL INTO v_seq FROM dual;
                   INSERT INTO recpe_diff
                   VALUES (v_seq,
                          rcd_bom.proc_order,
                          rcd_bom.opertn,
                          rcd_bom.phase,
                          rcd_bom.seq,
                          rcd_bom.matl_code,
                          rcd_bom.val,
                          rcd_bom.last_proc_order,
                          rcd_bom.last_opertn ,
                          rcd_bom.last_phase ,
                          rcd_bom.last_seq,
                          rcd_bom.last_matl_code,
                          rcd_bom.last_bom_qty,
                          SYSDATE);
               END IF;
            END LOOP;
            CLOSE csr_bom;
            
            /* now check src's within the process order */
            OPEN csr_src;
            LOOP
               FETCH csr_src INTO rcd_src;
               EXIT WHEN csr_src%NOTFOUND;
               
               v_current_proc_order := rcd_src.proc_order;
               v_last_proc_order := rcd_src.last_proc_order;
                              
               IF rcd_src.mpi_val <> TO_CHAR(rcd_src.last_mpi_val) AND rcd_src.last_proc_order IS NOT NULL THEN
                   /* the 2 values do not match */
                   SELECT RECPE_DTL_id_seq.NEXTVAL INTO v_seq FROM dual;
                   INSERT INTO recpe_diff
                   VALUES (v_seq,
                          rcd_bom.proc_order,
                          rcd_bom.opertn,
                          rcd_bom.phase,
                          rcd_bom.seq,
                          rcd_bom.matl_code,
                          rcd_bom.val,
                          rcd_bom.last_proc_order,
                          rcd_bom.last_opertn ,
                          rcd_bom.last_phase ,
                          rcd_bom.last_seq,
                          rcd_bom.last_matl_code,
                          rcd_bom.last_bom_qty,
                          SYSDATE);
               END IF;
            END LOOP;
            CLOSE csr_src;
            /*-*/
            /* get the record count for each proc order - if non zero then they are not equal
            /*-*/
            OPEN csr_count;
            FETCH csr_count INTO v_count;
            CLOSE csr_count;
            IF v_count <> 0 THEN
                DBMS_OUTPUT.PUT_LINE('BOM count is not equal');
            END IF;
            OPEN csr_count01;
            FETCH csr_count01 INTO v_count;
            CLOSE csr_count01;
            IF v_count <> 0 THEN
                DBMS_OUTPUT.PUT_LINE('SRC count is not equal');
            END IF;
            
       
       END LOOP;
	
  EXCEPTION
      WHEN TOO_MANY_ROWS THEN
          RAISE_APPLICATION_ERROR(-20000,'PO_Bom_Difference.Execute : TOO_MANY_ROWS' || CHR(13) 
          ||  v_current_proc_order || ' - ' ||  v_last_proc_order);	
        
         
      
      WHEN OTHERS THEN
	      RAISE_APPLICATION_ERROR(-20000,'PO_Bom_Difference.Execute : Others' || CHR(13) || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1900));	
        
          
  END;

END Po_Bom_Difference;
/


