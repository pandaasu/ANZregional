DROP PROCEDURE MANU_APP.GET_DUPLICATE_PHASE;

CREATE OR REPLACE PROCEDURE MANU_APP.Get_Duplicate_Phase(i_proc_order IN VARCHAR2) IS

/******************************************************************************
   NAME:       get_Duplicates
   PURPOSE:    This procedure will create a collection of recpe_dtl_id's that 
               will not be printed on the FRR 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        21/03/2007   Jeff Phillipson       1. Created this procedure.

   NOTES:

   

******************************************************************************/
    /*-*/
    /* constants
    /*-*/
    SRC_HIDE_DUPLICATES CONSTANT VARCHAR2(4) DEFAULT  '1999' ;
    
	/*-*/
	/* variables
	/*-*/
	o_result NUMBER;
	o_result_msg VARCHAR2(2000);
    v_proc_order cntl_rec_bom.proc_order%TYPE;
    v_count NUMBER;
    v_ids VARCHAR2(2000);
    
  
    /*-*/
	/* cursor to find any operations that may have a duplicate hide setting
    /* defined by an SRC
	/*-*/
    CURSOR csr_get_opertns
    IS
    SELECT opertn, phase 
      FROM cntl_rec_mpi_val
     WHERE LTRIM(proc_order,'0') =  v_proc_order
       AND mpi_tag =  SRC_HIDE_DUPLICATES
     GROUP BY opertn, phase
     UNION
    SELECT '0210', '0230' FROM dual;

    rcd_get_opertns csr_get_opertns%ROWTYPE; 
    
    
    /*-*/
    /* Cursor will check if multiple mades inside an operation  
    /*-*/
    CURSOR csr_made_per_operation
    IS
    SELECT COUNT(*) 
      FROM cntl_rec_bom
     WHERE LTRIM(proc_order,'0') =  v_proc_order
       AND opertn = rcd_get_opertns.opertn
       AND phantom = 'M'
       AND matl_code NOT IN (SELECT matl_code FROM recpe_phantom);

    CURSOR csr_get_ids
    IS
    SELECT cntl_rec_bom_id 
      FROM (SELECT t01.*, COUNT(*) 
                   OVER (PARTITION BY phase) AS phase_count
              FROM cntl_rec_bom t01
             WHERE LTRIM(t01.proc_order,'0') = v_proc_order
               AND t01.phase > rcd_get_opertns.phase
               AND matl_code  IN (SELECT matl_code
                                FROM cntl_rec_bom t02
                               WHERE t02.proc_order = t01.proc_order 
                                 AND t02.opertn = t01.opertn
                                 AND t02.phase = rcd_get_opertns.phase )
               AND pan_size  IN (SELECT pan_size
                               FROM cntl_rec_bom t03
                              WHERE t03.proc_order = t01.proc_order
                                AND t03.opertn = t01.opertn
                                AND t03.phase = rcd_get_opertns.phase ) )
             WHERE phase_count = (SELECT COUNT(*) 
                               FROM cntl_rec_bom 
                               WHERE LTRIM(proc_order,'0') = v_proc_order 
                                 AND phase = rcd_get_opertns.phase);
     rcd_get_ids csr_get_ids%ROWTYPE;
     
	/*-*/
	/* Private exceptions
	/*-*/
	application_exception EXCEPTION;
	PRAGMA EXCEPTION_INIT(application_exception, -20000);
  
     /*-*/
     /* Type declarations
     /* create a virtual table from the static object id_table (this is just a table ontype numbers 
     /*-*/
     v_vir_table id_table := id_table(); 
     
BEGIN
    o_result := 0;
	o_result_msg := '';
    v_proc_order := i_proc_order;
    v_proc_order := '1088141';
    /*-*/
    /* check to see if an SRC is set for duplicates in any operation
    /* if not return
    /*-*/
    OPEN csr_get_opertns;
    LOOP
        FETCH csr_get_opertns INTO rcd_get_opertns;
        EXIT WHEN csr_get_opertns%NOTFOUND;
       
        /*-*/
        /* for each src found test for duplicates 
        /* check if its an Operation duplicate or a phase duplicate within an operation
        /* this is tested by counting the number of made materials within the operation
        /*-*/ 
        OPEN csr_made_per_operation;
        FETCH csr_made_per_operation INTO v_count ;
        CLOSE csr_made_per_operation;
        
        IF v_count = 1 THEN
            /* check for another phase which is identical */
            v_count := 1;
        ELSE
            /* multiple phases within an operation to check */ 
            v_count := 0;
            OPEN csr_get_ids;
            LOOP
                FETCH csr_get_ids INTO rcd_get_ids;
                EXIT WHEN csr_get_ids%NOTFOUND;
                v_vir_table.EXTEND;
                v_vir_table(v_vir_table.LAST)  := rcd_get_ids.cntl_rec_bom_id;
            END LOOP;
            CLOSE csr_get_ids;
            
            DBMS_OUTPUT.PUT_LINE('First=' ||  v_vir_table(v_vir_table.FIRST));
	     
        END IF;
        /* check query works in a select statement */
        SELECT COUNT(*) INTO v_count 
          FROM TABLE(v_vir_table);
        DBMS_OUTPUT.PUT_LINE('Duplicate records for ' || v_proc_order || ' = ' || v_count);  
    END LOOP;
    CLOSE csr_get_opertns;
     

    
EXCEPTION
    WHEN OTHERS THEN
		o_result  := Constants.FAILURE;
		o_result_msg := 'get_Duplicates_Phase failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1900);	
END Get_Duplicate_Phase;
/


