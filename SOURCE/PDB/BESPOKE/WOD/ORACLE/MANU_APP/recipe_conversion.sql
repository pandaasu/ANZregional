CREATE OR REPLACE PACKAGE MANU_APP.Recipe_Conversion AS
/******************************************************************************
   NAME:       Recipe_Conversion
   PURPOSE:    To convert the process Order data sent by Atlas through 
               Proc_Orders into a set of records that can be easily used 
               by a ffont end to print FDR's
               The data will be expanded based on Resource and Opcode settings 
					
					The retrieve recordsets for the FRR front end 
					are also provided within this package 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/08/2005   Jeff Phillipson    1. Created this package.
******************************************************************************/

  PROCEDURE EXECUTE(par_cntl_Rec_Id IN NUMBER);
									
END Recipe_Conversion;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Recipe_Conversion AS
/******************************************************************************
   NAME:       Recipe_Conversion
   PURPOSE:    To convert the proc Order data sent by Atlas through
               Proc_Orders into a set of records that can be easily used
               by a fron end to print FDR's
               The data will be expanded based on RESRCE and Opcode settings

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/08/2005  Jeff Phillipson  1. Created this package body.
   2.0        19/05/2006  Jeff Phillipson Added Scale for where used function
******************************************************************************/

    /*-*/
    /*   RULES:
	/* 	 1	   Material Quantities are adjusted as per the USE quantity rather than the made quantity.
	/*	 If an SRC with the MPI_TAG set to '1999' within an Operation is found, then material quantities within the phase
	/*	 are modified by the ratio of phantom USED qty/ phantom MADE quantity  
    /*-*/

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

 
   /*-*/
   /* This function will return the ratio of either the first pan if the pan flag is set to Y
   /* or ratio the quantities if the pan fag is not Y
   /*-*/
   FUNCTION  getScaleForWhereUsed(i_proc_order IN VARCHAR2, i_opertn IN VARCHAR2, i_phase IN VARCHAR2, material IN VARCHAR2, pan_count OUT NUMBER) RETURN NUMBER
   IS
       var_ratio NUMBER;
	   var_work VARCHAR2(1);
	   var_pan_count NUMBER;
	   
	   CURSOR csr_ratio IS
	        SELECT CASE t02.pan_size_flag 
                   WHEN 'Y' THEN t02.pan_size
                   WHEN 'N' THEN t02.qty
                   ELSE t02.qty
                   END /
				   /* decode added to prevent divide by zero error if no of pans = 0 */
			       DECODE(CASE t01.pan_size_flag 
                          WHEN 'Y' THEN t01.pan_size
                          WHEN 'N' THEN t01.qty
				          WHEN 'E' THEN t01.qty
                          ELSE t01.qty
                          END,0,1, CASE t01.pan_size_flag 
                                   WHEN 'Y' THEN t01.pan_size
                                   WHEN 'N' THEN t01.qty
				                   WHEN 'E' THEN t01.qty
                                   ELSE t01.qty
                                   END ) qty_ratio,
				   t03.pans
              FROM cntl_rec_bom t01,
                   cntl_rec_bom t02,
				   (SELECT proc_order, opertn,DECODE(pan_size_flag,'N', 1, 'E', 1, ROUND(pan_qty - 1 + last_pan_size/pan_size,1)) pans
			   	   FROM cntl_rec_bom 
			       WHERE  phantom = 'M') t03
             WHERE t01.proc_order = t02.proc_order
               AND t01.matl_code = t02.matl_code
			   AND t01.proc_order = t03.proc_order
			   AND t02.opertn = t03.opertn
    	 	   AND t01.opertn =  i_opertn
			   AND t01.phase =  i_phase
   		 	   AND t01.phantom = 'M'
   		 	   AND t02.phantom = 'U'
   		 	   AND LTRIM(t01.proc_order,'0') = i_proc_order;
		 
		CURSOR csr_tag IS
		    SELECT 'x' FROM cntl_rec_mpi_val t01
            WHERE LTRIM(t01.proc_order,'0') = i_proc_order
			  AND t01.opertn =  i_opertn
			  AND t01.phase =  i_phase
              AND mpi_tag = 1999;
	   
   BEGIN
        
		  pan_count := 1;
		  OPEN csr_tag;
		      FETCH csr_tag INTO  var_work;
		      IF csr_tag%NOTFOUND THEN
			       RETURN 1;
			  END IF;
		  CLOSE csr_tag;
		 
          OPEN csr_ratio;
             FETCH csr_ratio INTO  var_ratio, var_pan_count;
             IF csr_ratio%NOTFOUND THEN
				var_ratio := 1;  
				var_pan_count := 1;
             END IF;
          CLOSE csr_ratio;
		  
		  IF var_ratio = 0 THEN
		      var_ratio := 1;
		  END IF;
		  pan_count := var_pan_count;
		  RETURN var_ratio;
		 
   END;
   /*******************************************/
   
   

  PROCEDURE EXECUTE(par_cntl_Rec_Id IN NUMBER) IS
    
    /*-*/
    /* Private definitions
    /*-*/
    var_work          VARCHAR2(1);
	var_number 		  NUMBER;
    var_runing_total  NUMBER DEFAULT 0;
	var_pan			  NUMBER;
	var_seq			  NUMBER;
	var_count		  NUMBER;
	var_ratio		  NUMBER; -- used for getting the ratio of made / used phantoms
	var_no_of_pans    NUMBER;
	
    rcd_recpe_resrce RECPE_RESRCE%ROWTYPE;
    rcd_recpe_dtl RECPE_DTL%ROWTYPE;
    
    /*-*/
    /* Constant definitions 
    /*-*/
    cst_Blank_RESRCE CONSTANT CHAR(1) := '0';
    cst_KG CONSTANT CHAR(2) := 'KG';
	cst_G  CONSTANT CHAR(1) := 'G';
    
    /*-*/
    /* Define cursors
    /*-*/
    
    /*-*/
    /* get detail to be used for the header table entry  of proc Order of interest
    /*-*/
    CURSOR csr_cntl_rec IS
       SELECT c.* , ean_code tun, rgnl_code_nmbr
         FROM CNTL_REC c, MATL m
        WHERE cntl_rec_id = par_cntl_rec_id
		  AND LTRIM(c.MATL_code,'0') = m.matl_code(+)
		  AND c.plant = m.plant;
		  
    
    rcd_cntl_rec csr_cntl_rec%ROWTYPE; 
    
    /*-*/
    /* get all the Bom and RESRCE data 
    /*-*/
    CURSOR csr_recpe IS
       SELECT LTRIM(c.PROC_ORDER,'0') proc_order, 
              c.CNTL_REC_ID, 
              r.RESRCE_CODE, 
				  DECODE(rr.RESRCE_DESC,NULL,'No REF_RESOURCE table entry',rr.RESRCE_DESC) resrce_desc,
              b.opertn, 
              b.phase, 
              b.seq,
              b.phantom, 
              LTRIM(b.MATL_CODE,'0') matl_code, 
              b.matl_desc, 
              TO_CHAR(TO_NUMBER(DECODE(pan_size_flag,'Y',pan_size,b.QTY)),'9999990.999990') bom_qty,
              b.UOM uom,
			     b.OPERTN_FROM
         FROM CNTL_REC c,
              CNTL_REC_RESRCE r,
              CNTL_REC_BOM b,
              REF_RESRCE rr
        WHERE c.PROC_ORDER = r.PROC_ORDER
          AND c.PROC_ORDER = b.PROC_ORDER
          AND r.OPERTN = b.opertn
          AND r.RESRCE_CODE = rr.RESRCE_CODE(+)
		  AND (b.phantom = 'U' OR b.phantom IS NULL)
          AND c.cntl_rec_id = par_cntl_Rec_Id
		  AND r.plant = rr.PLANT(+)  
		  AND LTRIM(b.MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
        ORDER BY 1,2,b.opertn, b.phase, b.seq;
      
      rcd_recpe csr_recpe%ROWTYPE;
      
      rcd_last_recpe csr_recpe%ROWTYPE;
		
		/*-*/
		/* add any resources that are not associated with materials but only SRC's 
		/*-*/
		CURSOR csr_resrce IS
		SELECT opertn, 
		       t01.resrce_code, 
				 resrce_desc
		  FROM CNTL_REC_RESRCE t01, 
		       REF_RESRCE t02
		  WHERE trim(t01.resrce_code) = trim(t02.resrce_code(+))
		    AND t02.plant(+) =  rcd_cntl_rec.plant
		    AND LTRIM(t01.proc_order,'0') = LTRIM(rcd_cntl_rec.proc_order,'0')
			/*-*/
			/* only get operations that are not already defined with resources in the BOM table 
			/*-*/
		    AND opertn NOT IN (SELECT opertn 
		                       FROM CNTL_REC_BOM 
							  WHERE proc_order = t01.proc_order 
								AND (phantom = 'N' OR phantom IS NULL  OR phantom = 'U')
								AND LTRIM(matl_code,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM))						  
		    /*-*/
			/* and add operation and resources which are in either MPI_VAL or MPI_TXT tables
			/*-*/
			AND (opertn IN (SELECT DISTINCT opertn FROM cntl_rec_mpi_val	WHERE proc_order = t01.proc_order
	                       UNION
				           SELECT DISTINCT opertn FROM cntl_rec_mpi_txt	WHERE proc_order = t01.proc_order)
				);
									 
		rcd_resrce csr_resrce%ROWTYPE;							 
      
      /*-*/
      /* record checking cursors 
      /*-*/
      CURSOR csr_recpe_resrce IS
         SELECT 'x'
           FROM RECPE_RESRCE 
          WHERE cntl_rec_id = par_cntl_rec_id
            AND resrce_code = rcd_recpe.resrce_code
            AND opertn = rcd_recpe.opertn;
      
			  
		/*-*/
		/* this cursor is used to get the pan quantity from the manufactured - M 
		/* entry in the bom table of the proc order 
		/*-*/
		CURSOR csr_pans IS
		    SELECT DECODE(pan_qty,NULL,0,pan_qty) 
				FROM CNTL_REC_BOM
			  WHERE phase = rcd_recpe.opertn_from
				 AND proc_order = rcd_cntl_rec.proc_order
				 AND phantom = 'M';
					
		/*-*/
		/* this cursor is used to get the pan quantity from the manufactured - M 
		/* entry in the bom table of the proc order using just the operation 
		/*-*/
		CURSOR csr_pan_qty IS
		    SELECT DECODE(pan_qty,0,1,NULL,1,1,pan_qty, (pan_qty - 1)  + (TO_CHAR(TO_NUMBER(last_pan_size)/pan_size,'999D9'))) pan_qty,  
			       matl_code, 
				   matl_desc,  
			       DECODE(pan_size,NULL,qty,pan_size) qty,
				   uom,
				   DECODE(mpi_tag, NULL, 'N', 'Y') rescale
			  FROM CNTL_REC_BOM t01, cntl_rec_mpi_val t02
			 WHERE t01.opertn = rcd_recpe.opertn
			   AND LTRIM(t01.proc_order,'0')  = LTRIM(rcd_cntl_rec.proc_order,'0')
			   AND phantom = 'M'
			   AND t01.PROC_ORDER = t02.PROC_ORDER(+)
			   AND t01.OPERTN = t02.OPERTN(+)
			   AND mpi_tag(+) = 1999
			   AND LTRIM(matl_code,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM recpe_phantom);				
					
		rcd_pan_qty csr_pan_qty%ROWTYPE;	
		
		/*-*/
		/* this curspor will get all MADE material Phantoms for any operation 
		/* where there is more than 1 made phantom 
		/* the record will then be saved and these lines will be printed in Bold on the  
		/* recipe report 
		/*-*/
		CURSOR csr_phantoms IS
		     SELECT t03.proc_order, 
		            t01.opertn, LPAD(TO_CHAR(TO_NUMBER(t01.phase) - 1),4,'0') phase, 
		            t01.matl_code, 
					matl_desc, 
					'0001' seq
		  FROM cntl_rec_bom t01,
		       (		 
				 SELECT opertn, COUNT(Seq) seq, proc_order
		          FROM cntl_rec_bom
		         WHERE phantom = 'M'
		           AND LTRIM(MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
				 GROUP BY opertn, proc_order
				 ) t02,
		       cntl_rec t03
		  WHERE phantom = 'M'
		    AND t03.cntl_rec_id = par_cntl_Rec_Id 
		    AND LTRIM(t01.MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
		    AND t01.opertn = t02.opertn
		    AND t02.seq > 1
		    AND t03.PROC_ORDER = t01.PROC_ORDER
		    AND t03.PROC_ORDER = t02.PROC_ORDER
		  ORDER BY 2,3,4,5;
			  
		 rcd_phantoms csr_phantoms%ROWTYPE;
		

  BEGIN

     /*-*/
     /* Retrieve the procedure Order using the cntl_rec id 
     /*-*/
     OPEN csr_cntl_rec;
    
	 FETCH csr_cntl_rec INTO rcd_cntl_rec;
     IF NOT csr_cntl_rec%NOTFOUND THEN
	 
	     BEGIN
		   DELETE FROM RECPE_DTL WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
	       DELETE FROM RECPE_VAL WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
		   DELETE FROM RECPE_RESRCE WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
	       DELETE FROM RECPE_HDR WHERE proc_order = LTRIM(rcd_cntl_rec.proc_order,'0');
	 	   COMMIT;
		 EXCEPTION
		     WHEN OTHERS THEN
			     --ORA-060 error deadlock
				 ROLLBACK;
				 dbms_lock.sleep(3);
				 DELETE FROM RECPE_DTL WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
	       		 DELETE FROM RECPE_VAL WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
		   		 DELETE FROM RECPE_RESRCE WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
	       		 DELETE FROM RECPE_HDR WHERE proc_order = LTRIM(rcd_cntl_rec.proc_order,'0');
				 COMMIT;
		 END;
	 
	    /*-*/
        /* Insert HEADER record 
        /*-*/
     	INSERT INTO RECPE_HDR
	    VALUES ( rcd_cntl_rec.cntl_rec_id,
			     LTRIM(rcd_cntl_rec.proc_order,'0'),
			     LTRIM(rcd_cntl_rec.matl_code,'0'),
			     rcd_cntl_rec.matl_text,
			     rcd_cntl_rec.run_start_datime,
			     rcd_cntl_rec.run_end_datime,
			     rcd_cntl_rec.tun,
			     rcd_cntl_rec.rgnl_code_nmbr,
		         rcd_cntl_rec.qty,
				 rcd_cntl_rec.uom);
			
        /*-*/
        /* at the start of a new recipe set the RESRCE code to a blank value
        /*-*/
        rcd_last_recpe.RESRCE_code := cst_Blank_Resrce;
          
        /*-*/
        /* Retrieve the BOM and RESRCE data using the cntl_rec id 
        /*-*/
		
        OPEN csr_recpe;
        LOOP
           FETCH csr_recpe INTO rcd_recpe;
           EXIT WHEN csr_recpe%NOTFOUND; 
 		   
		   
		   /*-*/
		   /* check if a ratio adjustment is needed 
		   /*-*/
		   var_ratio := getScaleForWhereUsed( LTRIM(rcd_cntl_rec.proc_order,'0'), rcd_recpe.opertn, rcd_recpe.phase, rcd_recpe.matl_code, var_no_of_pans);

			    
		   
           /*-*/
           /* check for a Phase header change 
		   /* this area is for a PHASE dependant change to occur  
           /*-*/ 
		   IF (rcd_recpe.opertn <> rcd_last_recpe.opertn OR rcd_recpe.RESRCE_code <> rcd_last_recpe.RESRCE_code) THEN      
			     /*-*/
               /* insert a phase header record 
               /*-*/
               rcd_recpe_RESRCE.cntl_rec_id := rcd_recpe.cntl_rec_id;
            
               rcd_recpe_RESRCE.RESRCE_code := rcd_recpe.RESRCE_code;
           
               rcd_recpe_RESRCE.opertn :=  rcd_recpe.opertn;
           
               rcd_recpe_RESRCE.RESRCE_desc := rcd_recpe.RESRCE_desc;
          
			   /*-*/
				/* get pan qty for this operation and add to the resource record 
				/*-*/
				  
				  SELECT COUNT(*) INTO var_count
				    FROM CNTL_REC_BOM
			      WHERE opertn = rcd_recpe.opertn
				     AND LTRIM(proc_order,'0')  = LTRIM(rcd_cntl_rec.proc_order,'0')
				     AND phantom = 'M'
					 AND LTRIM(matl_code,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM recpe_phantom);	
					  
				  /*-*/
				  /* if var_count is greater than 1 it means that there are several made 
				  /* phantoms in this operation and so the pan qty should be 0 
				  /*-*/
				  
				  rcd_pan_qty.pan_qty := 0;
				  rcd_pan_qty.matl_code := '';
				  rcd_pan_qty.matl_desc := '';
				  rcd_pan_qty.qty := 0;
				  
				  OPEN csr_pan_qty;
				  FETCH csr_pan_qty INTO rcd_pan_qty;		
				      IF csr_pan_qty%NOTFOUND THEN
				          var_pan := 0;
				  	   END IF;
				  
				  
                      OPEN csr_recpe_RESRCE;
                      FETCH csr_recpe_RESRCE INTO var_work;
                      IF csr_recpe_RESRCE%NOTFOUND THEN
                          INSERT INTO RECPE_RESRCE 
                                (cntl_rec_id,
                           		RESRCE_code,
                          		opertn,
                           		RESRCE_desc,
								pan_qty,
								matl_made,
								matl_made_desc,
								matl_made_qty)
                          VALUES (rcd_recpe_RESRCE.cntl_rec_id,
                                rcd_recpe_RESRCE.RESRCE_code,
                           		rcd_recpe_RESRCE.opertn,
                           		rcd_recpe_RESRCE.RESRCE_desc,
								-- var_count will be 1 if a phantom is made within this operation
								ROUND(DECODE(var_count,1,DECODE(rcd_pan_qty.rescale,'Y',var_no_of_pans,rcd_pan_qty.pan_qty),0),1),
								--ROUND(DECODE(var_count,1,rcd_pan_qty.pan_qty,0) / var_ratio,1),
								DECODE(var_count,1,rcd_pan_qty.matl_code,''),
								DECODE(var_count,1,rcd_pan_qty.matl_desc,''),
								DECODE(var_count,1,DECODE(rcd_pan_qty.qty,NULL,0,'',0,rcd_pan_qty.qty),0) * var_ratio
											);
									
                      END IF;
                      CLOSE csr_recpe_RESRCE;
				  CLOSE csr_pan_qty;
              
              /*-*/
              /* get latest RESRCE code  
              /*-*/
              rcd_last_recpe.RESRCE_code := rcd_recpe.RESRCE_code;
              
              /*-*/
              /* reset running total 
              /*-*/
              var_runing_total := 0;
              
           END IF;
           /*-*/
           /* End of PHASE Change section 
           /*-*/
		      
		  
           /*-*/
           /* insert a detail record  
           /*-*/
           rcd_recpe_dtl.cntl_rec_id := rcd_recpe.cntl_rec_id;
           
           rcd_recpe_dtl.opertn := rcd_recpe.opertn;
           
           rcd_recpe_dtl.phase := rcd_recpe.phase;
           
		   IF  rcd_recpe.seq IS NULL THEN
		       rcd_recpe_dtl.seq :=  LPAD(TO_CHAR(TO_NUMBER(rcd_last_recpe.seq) + 1),4,'0');
		   ELSE
               rcd_recpe_dtl.seq := rcd_recpe.seq;
           END IF;
		   
           rcd_recpe_dtl.matl_code := rcd_recpe.matl_code;
           
           rcd_recpe_dtl.matl_desc := rcd_recpe.matl_desc;
		  
		  /*-*/
		  /* check if a ratio adjustment is needed 
		  /*-*/
		  --var_ratio := getScaleForWhereUsed( LTRIM(rcd_cntl_rec.proc_order,'0'), rcd_recpe.opertn, rcd_recpe.matl_code, var_no_of_pans);
		
		   rcd_recpe_dtl.bom_qty := rcd_recpe.bom_qty * var_ratio;
			
		   rcd_recpe_dtl.opertn_from := rcd_recpe.opertn_from;
			  
           rcd_recpe_dtl.uom := UPPER(rcd_recpe.uom);
           IF (rcd_recpe_dtl.uom IS NULL) THEN
		   	  rcd_recpe_dtl.uom := ' ';
		   END IF;
		   
           rcd_recpe_dtl.phantom := rcd_recpe.phantom;
			  
			  rcd_recpe_dtl.pans := '';
			  IF rcd_recpe.phantom = 'U' THEN
			      /*-*/
					/* get the number of pans for this material 
					/*-*/
					OPEN csr_pans;
					FETCH csr_pans INTO var_number;
					    IF NOT csr_pans%NOTFOUND THEN
						 	  rcd_recpe_dtl.pans := var_number;
					    END IF;
					CLOSE csr_pans;
			  END IF;
           
           /*-*/
           /* progressive total 
           /*-*/
           IF rcd_recpe_dtl.uom = cst_KG THEN
              var_runing_total :=  var_runing_total + rcd_recpe.bom_qty;
           END IF;
           
           /*-*/
           /* add materials to the detail record 
           /*-*/
				 SELECT RECPE_DTL_id_seq.NEXTVAL INTO var_seq FROM dual;
                 INSERT INTO RECPE_DTL
                        (recpe_dtl_id,
						cntl_rec_id,
                        opertn,
                        phase,
                        seq,
                        matl_code,
                        matl_desc,
                        uom,
						bom_qty,
						total,
                        phantom,
						pans,
						opertn_from
                        )
                 VALUES (var_seq,
					    rcd_recpe_dtl.cntl_rec_id,
                        rcd_recpe_dtl.opertn,
                        rcd_recpe_dtl.phase,
                        rcd_recpe_dtl.seq,
                        rcd_recpe_dtl.matl_code,
                        rcd_recpe_dtl.matl_desc,
                        rcd_recpe_dtl.uom,
                        rcd_recpe_dtl.bom_qty,
                        var_runing_total,
                        rcd_recpe_dtl.phantom,
						rcd_recpe_dtl.pans,
						rcd_recpe_dtl.opertn_from);
     
              
           /*-*/
           /* save a copy of the last record - will be required for the phase footer record 
           /*-*/
           rcd_last_recpe := rcd_recpe;
           
        END LOOP;
        CLOSE csr_recpe;
		     	
		  /*-*/
		  /* Insert records to be printed in BOLD for any MULTIPLE PHANTOM
		  /* within any 1 operation
		  /*-*/
		   OPEN csr_phantoms;
         LOOP
            FETCH csr_phantoms INTO rcd_phantoms;
            EXIT WHEN csr_phantoms%NOTFOUND;
				    SELECT RECPE_DTL_id_seq.NEXTVAL INTO var_seq FROM dual;
                 INSERT INTO RECPE_DTL
                        (recpe_dtl_id,
						cntl_rec_id,
                        opertn,
                        phase,
                        seq,
                        matl_code,
                        matl_desc,
                        phantom
                        )
                 VALUES (var_seq,
					    par_cntl_Rec_Id,
                        rcd_phantoms.opertn,
                        rcd_phantoms.phase,
                        rcd_phantoms.seq,
                        rcd_phantoms.matl_code,
                        rcd_phantoms.matl_desc,
                        'B');
				
         END LOOP;
         CLOSE csr_phantoms;
         
 	
		 
        
		  /*-*/
		  /* check if there are any Resources used that dont have material assignments 
		  /*-*/
		  
		  OPEN csr_resrce;
		  LOOP
		      FETCH csr_resrce INTO rcd_resrce;
		      EXIT WHEN csr_resrce%NOTFOUND; 
				    INSERT INTO RECPE_RESRCE
                       (cntl_rec_id,
                       RESRCE_code,
                       opertn,
                       RESRCE_desc,
					   pan_qty,
					   matl_made_qty)
                VALUES (par_cntl_Rec_Id,
                       rcd_RESRCE.RESRCE_code,
                       rcd_RESRCE.opertn,
                       rcd_RESRCE.RESRCE_desc,
					   0,
					   0);
		  END LOOP;
		  CLOSE csr_resrce;  
		 
		  /*-*/
		  /* update the recpe_val table with SRC codes 
		  /*-*/
		  Src_Convert.EXECUTE(rcd_cntl_rec.proc_order);
		  
	  --ELSE
        
        /*-*/
        /* cntl rec not found 
        /*-*/
        --RAISE_APPLICATION_ERROR(-20000, 'Recipe_Conversion.Execute - Control recipe id (' || TO_CHAR(par_cntl_rec_id) || ') does not exist');
     
     END IF;
	 
          
	  CLOSE csr_cntl_rec;
     
     COMMIT;
     
     
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Rollback the database
         /*-*/
         ROLLBACK;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'Recipe_Conversion - Control Rec Id = ' || par_cntl_Rec_Id || CHR(13)
             || 'Proc Order = ' || rcd_cntl_rec.proc_order || CHR(13)
				 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));
             
         Mailout('Recipe_Conversion - ContRecId= '  || par_cntl_Rec_Id || ' Proc Order= ' || rcd_cntl_rec.proc_order,
                 '"2005 Site Team"@smtp.ap.mars',
                  Site_Common.PLANT_DB,
                 'Oracle error ' || SUBSTR(SQLERRM, 1, 1000));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END EXECUTE;         

END Recipe_Conversion;

GRANT EXECUTE ON MANU_APP.RECIPE_CONVERSION TO APPSUPPORT;
GRANT EXECUTE ON MANU_APP.RECIPE_CONVERSION TO BDS_APP;

CREATE OR REPLACE PUBLIC SYNONYM RECIPE_CONVERSION FOR MANU_APP.RECIPE_CONVERSION;