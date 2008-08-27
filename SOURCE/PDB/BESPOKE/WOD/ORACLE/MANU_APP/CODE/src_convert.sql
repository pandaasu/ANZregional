DROP PACKAGE MANU_APP.SRC_CONVERT;

CREATE OR REPLACE PACKAGE MANU_APP.Src_Convert AS
/******************************************************************************
   NAME:       SRC_CONVERT 
   PURPOSE:		This procedure will convert any multiple SRCs
					into a single row with header line 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        18-Jan-06             1. Created this package.
******************************************************************************/


  PROCEDURE EXECUTE(par_proc_order IN VARCHAR2);

END Src_Convert;
/


DROP PACKAGE BODY MANU_APP.SRC_CONVERT;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Src_Convert AS
/******************************************************************************
   NAME:       SRC_CONVERT
   PURPOSE:		This procedure will convert any multiple SRCs
					into a single row with header line 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        18-Jan-06             1. Created this package body.
******************************************************************************/

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);
  

  PROCEDURE EXECUTE(par_proc_order IN VARCHAR2) IS
    
	 /*-*/
	 /* local variables 
	 /*-*/
	 var_sub_header              VARCHAR2(2000);
	 var_last_sub_header         VARCHAR2(2000) DEFAULT '0';
	 var_mpi_val  					  VARCHAR2(2000);
	 var_count 	  					  NUMBER DEFAULT 0;
	 var_cntl_rec_id 				  NUMBER;
	 var_last_seq					  NUMBER DEFAULT 0;
	 var_seq							  NUMBER;
	 var_row_count					  NUMBER;
	 var_row_seq					  NUMBER;
	 
	 
	 /*-*/
	 /* cursors 
	 /*-*/
	 /*-*/
	 /* this cursor get the SRC data ready for processing  
	 /* this handles individual records with NO Pipe and NO MC_Code
	 /* plus records with PIPE but NO MC_Codes 
	 /*-*/		
	 CURSOR csr_src IS
	     SELECT t01.proc_order, 
                t01.opertn, 
		  		t01.phase, 
		  		LPAD(t01.seq,4,'0') seq,
		  		mpi_tag,
		  		DECODE(INSTR(mpi_desc,'|'),0,mpi_desc,trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1))) mpi_desc, 
		  		mpi_val, 
		  		mpi_uom,
		  		mc_code,
		  		t01.plant, 
		  		t02.cntl_rec_id,
				DECODE(INSTR(mpi_desc,'|'),0,'',trim(SUBSTR(mpi_desc, INSTR(mpi_desc,'|') + 1, LENGTH(mpi_desc)))) sub_header
   	       FROM CNTL_REC_MPI_VAL t01, 
			    CNTL_REC t02
          WHERE t01.proc_order = t02.proc_order
	        AND LTRIM(t01.proc_order,'0') = LTRIM(par_proc_order,'0')
			/* dont get any entries with mpi tag of 1999 */
			AND mpi_tag <> 1999
			/* any mpi values using '*NP*' should not be displayed */
			AND mpi_val <> '*NP*'
			AND mc_code IS NULL
          ORDER BY 2,3,4;
	 
	 rcd_src csr_src%ROWTYPE;
	 rcd_recpe_val recpe_val%ROWTYPE;
	 
	 /*-*/
	 /* this cursor will get the number of expected entries for each multiple line SRC set
	 /* it checks on the number of material descriptionsd with '|' character in then groups
	 /* all lines with the same description upto the pipe char within a PHASE
	 /*-*/
	 CURSOR csr_multiple IS
	     SELECT COUNT(*) COUNT,
		        trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1)) VALUE, 
		        opertn, 
				phase
		   FROM CNTL_REC_MPI_VAL t01, 
			    CNTL_REC t02
          WHERE t01.proc_order = t02.proc_order
	        AND LTRIM(t02.proc_order,'0') = LTRIM(par_proc_order,'0')
			AND opertn = rcd_src.opertn 
			AND phase = rcd_src.phase
			/*-*/
			/* added to seperate like SRC codes with header values from cntl_rec_mpi_txt
			/*-*/
			/*-*/
			/* this gets the highest number of any header that may exist in this operation/phase
			/* closest to the current sequence
			/* if no value found 9999 returned
			/*-*/
			AND TO_NUMBER(t01.seq) < (	
								   	 SELECT DECODE(MIN(TO_NUMBER(seq)),NULL,9999,MIN(TO_NUMBER(seq))) header_seq
		    	   					   FROM cntl_rec_mpi_txt t05 
		   		  					  WHERE LTRIM(t05.proc_order,'0') = LTRIM(par_proc_order,'0')
									    AND mpi_type = 'H'
									    AND TO_NUMBER(t05.seq) > TO_NUMBER(rcd_src.seq)
									) 
			/*-*/
			/* this gets the lower number of any header that may exist in this operation/phase
			/* closest to the current sequence
			/* if no value found 0 is returned
			/*-*/
			AND TO_NUMBER(t01.seq) > (	
								   	 SELECT DECODE(MAX(TO_NUMBER(seq)),NULL,0, MAX(TO_NUMBER(seq))) header_seq
		    	   					   FROM cntl_rec_mpi_txt t05 
		   		  					  WHERE LTRIM(t05.proc_order,'0') = LTRIM(par_proc_order,'0')
									    AND mpi_type = 'H'
									    AND TO_NUMBER(t05.seq) < TO_NUMBER(rcd_src.seq)
									) 
			/********************************************************/
			AND trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1)) = trim(rcd_src.mpi_desc)
			AND INSTR(mpi_desc,'|') > 0
			AND mc_code IS NULL
		  GROUP BY trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1)),
			    opertn, 
				phase
		  ORDER BY 3,4;
			
	rcd_multiple csr_multiple%ROWTYPE;		
	 
	/*-*/
	/* this cursor will get all records with MC codes  and No Pipe character 
	/* the multiple values will be grouped by reference to the count value 
	/*-*/ 
	CURSOR csr_mc IS
	    SELECT t01.proc_order, 
               t01.opertn, 
		 	   t01.phase, 
		 	   LPAD(t01.seq,4,'0') seq, 
       	 	   t01.mpi_tag, 
		 	   t01.mpi_desc,
		 	   t02.COUNT,
		 	   t02.seq_start,
			   t01.MPI_VAL,
		       t01.MPI_UOM,
		       t01.MC_CODE
          FROM CNTL_REC_MPI_VAL t01,
               (SELECT proc_order, 
	                   opertn, 
	               	   phase, 
				       mpi_tag, 
				       COUNT(mpi_tag) COUNT, 
				       MIN(LPAD(seq,4,'0')) seq_start
                  FROM CNTL_REC_MPI_VAL t01
                 WHERE mc_code IS NOT NULL
                 GROUP BY proc_order,opertn, phase, mpi_tag
                 ORDER BY  proc_order, opertn, phase, MIN(LPAD(seq,4,'0'))
               ) t02
         WHERE t01.proc_order = t02.proc_order
           AND t01.opertn = t02.opertn
      	   AND t01.phase = t02.phase
      	   AND t01.mpi_tag = t02.mpi_tag
      	   AND LTRIM(t01.proc_order,'0') = LTRIM(par_proc_order,'0')
      	   AND mc_code IS NOT NULL  -- only entries with a MC code
		   AND INSTR(mpi_desc,'|') = 0 -- and no entries with a pipe 
   		 ORDER BY 1,2,3, 8, 5, 11;
	 
	 rcd_mc csr_mc%ROWTYPE;
	 rcd_last_mc csr_mc%ROWTYPE;
	 
	 
	 /*-*/
	 /* this cursor will get all records with MC codes  and with Pipe character 
	 /* the multiple values will be grouped by reference to the count value 
	 /*-*/ 
	 CURSOR csr_both IS
	     SELECT t01.proc_order, 
                t01.opertn, 
		 	 	t01.phase, 
		 	 	LPAD(t01.seq,4,'0') seq, 
       	 		t01.mpi_tag, 
		 	 	DECODE(INSTR(mpi_desc,'|'),0,mpi_desc,trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1))) mpi_desc,
		 	 	t02.COUNT,
		 	 	t02.seq_start,
			 	t01.MPI_VAL,
		    	t01.MPI_UOM,
		    	t01.MC_CODE,
			 	DECODE(INSTR(mpi_desc,'|'),0,'',trim(SUBSTR(mpi_desc, INSTR(mpi_desc,'|') + 1, LENGTH(mpi_desc)))) sub_header
     	   FROM CNTL_REC_MPI_VAL t01,
                (SELECT proc_order, 
	            		opertn, 
	               		phase, 
				        COUNT(SUBSTR(mpi_desc,0, INSTR(mpi_desc,'|') -1)) COUNT, 
				      	MIN(LPAD(seq,4,'0')) seq_start,
						mc_code,
						SUBSTR(mpi_desc,0, INSTR(mpi_desc,'|') -1) description
                   FROM CNTL_REC_MPI_VAL t01
                  WHERE mc_code IS NOT NULL 
                  GROUP BY proc_order,opertn, phase, SUBSTR(mpi_desc,0, INSTR(mpi_desc,'|') -1), mc_code
                  ORDER BY  proc_order, opertn, phase, MIN(LPAD(seq,4,'0'))
			    ) t02
    	  WHERE t01.proc_order = t02.proc_order
            AND t01.opertn = t02.opertn
      		AND t01.phase = t02.phase
      		AND t01.mc_code = t02.mc_code
			AND SUBSTR(t01.mpi_desc,0, INSTR(t01.mpi_desc,'|') -1) = t02.description
      		AND LTRIM(t01.proc_order,'0') = LTRIM(par_proc_order,'0')
      		AND t01.mc_code IS NOT NULL
			AND INSTR(t01.mpi_desc,'|') > 0
          ORDER BY 1,2,3, 6, 4,11;
	 
	 rcd_both csr_both%ROWTYPE;
	 rcd_last_both csr_both%ROWTYPE;
	 
	 /*-*/
	 /* get the control recid code
	 /*-*/
	 CURSOR csr_cntl_rec_id IS
	     SELECT cntl_rec_id 
	       FROM cntl_rec 
	      WHERE LTRIM(proc_order,'0') = LTRIM(par_proc_order,'0');
	 
  BEGIN
     
	  /*-*/
	  /* get the control recipe id from cntl_rec table
	  /*-*/
	  OPEN csr_cntl_rec_id;
	      FETCH csr_cntl_rec_id INTO var_cntl_rec_id;
		  IF NOT csr_cntl_rec_id%NOTFOUND THEN
		  
		  /*-*/
		  /* OK to continue
		  /*-*/
		  
	
	   
	  /********************************************************************/
	  /*-*/
	  /*  now get all SRC records with either no pipe or PIPE but NO MC_CODES 
	  /*-*/
	  /********************************************************************/
	  BEGIN
	 
	  OPEN csr_src;
      LOOP
        FETCH csr_src INTO rcd_src;
        EXIT WHEN csr_src%NOTFOUND;
		 
		    rcd_recpe_val.cntl_rec_id := rcd_src.cntl_rec_id;
			rcd_recpe_val.opertn      := rcd_src.opertn;
			rcd_recpe_val.phase       := rcd_src.phase;
			rcd_recpe_val.seq 		  := rcd_src.seq;
			rcd_recpe_val.mpi_tag 	  := rcd_src.mpi_tag;
			rcd_recpe_val.mpi_desc 	  := rcd_src.mpi_desc;
			rcd_recpe_val.mpi_val 	  := rcd_src.mpi_val;
			rcd_recpe_val.mpi_uom 	  := rcd_src.mpi_uom;
			rcd_recpe_val.recpe_val_type := 'V';
				

			/*-*/
			/* check if multiple pipe entries exist by the value of the sub header
			/* if not then the entry is a normal SRC value
			/*-*/
		    IF rcd_src.sub_header IS NOT NULL THEN
			
				    /*-*/
					/* multiple value line 
					/*-*/
					var_mpi_val := var_mpi_val || RPAD(LPAD(rcd_recpe_val.mpi_val,4,' '),5,' ');
					var_sub_header := var_sub_header || RPAD(LPAD(SUBSTR(rcd_src.sub_header,0,4),4,' '),5,' ');
					
					/*-*/
					/* if the count is 0 - we can get the next multiple entry and process
					/*-*/
					IF var_count = 0 THEN
					    OPEN csr_multiple;
                       
                           FETCH csr_multiple INTO rcd_multiple;
                           IF NOT csr_multiple%NOTFOUND THEN
							   var_count := rcd_multiple.COUNT;
						   ELSE
						       var_count := 0;
						   END IF;
                      
                        CLOSE csr_multiple;
				    END IF;
					
					/*-*/
					/* do nothing until the count gets down to zero again
					/*-*/
					IF var_count > 0 THEN
						 var_count := var_count - 1;
						 /*-*/
						 /* when it has reached zero insert sub header record
						 /*-*/
						 IF var_count = 0 THEN
						      /*-*/
							  /* insert records 
							  /*-*/
							  IF var_last_sub_header <> var_sub_header THEN
							      -- only inser header if it is a new header 
									SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
									INSERT INTO RECPE_VAL
					                VALUES (var_seq,
									       rcd_recpe_val.cntl_rec_id,
					                   	   rcd_recpe_val.opertn,
							               rcd_recpe_val.phase,
							               LPAD(rcd_recpe_val.seq,4,'0'),
							               '',
							               '',
							               var_sub_header,
							               '',
							               'VH',
										   '');
							  END IF;
							/*-*/
							/* add a multiple line record
							/*-*/		
							SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
						    INSERT INTO RECPE_VAL
					        VALUES (var_seq,
									rcd_recpe_val.cntl_rec_id,
									rcd_recpe_val.opertn,
							 	  	rcd_recpe_val.phase,
							 		LPAD(TO_CHAR(TO_NUMBER(rcd_recpe_val.seq) + 1),4,'0'),
							 		rcd_recpe_val.mpi_tag,
							 		SUBSTR(rcd_recpe_val.mpi_desc,0,100),
							 		SUBSTR(var_mpi_val,0,50),
							 		rcd_recpe_val.mpi_uom,
							 		'VL',
									trim(var_sub_header));
							  
							  var_last_sub_header := var_sub_header;
							  var_sub_header := '';
							  var_mpi_val := '';
					     END IF;
							
					END IF;
				
			ELSE
					 /*-*/
					 /* normal single line SRC 
					 /*-*/
					 SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
				     INSERT INTO RECPE_VAL
					 VALUES (var_seq,
					        rcd_recpe_val.cntl_rec_id,
					        rcd_recpe_val.opertn,
						    rcd_recpe_val.phase,
						    LPAD(rcd_recpe_val.seq,4,'0'),
							rcd_recpe_val.mpi_tag,
							rcd_recpe_val.mpi_desc,
							rcd_recpe_val.mpi_val,
							rcd_recpe_val.mpi_uom,
							rcd_recpe_val.recpe_val_type,
							'');
							 
				    var_sub_header := '';
					var_last_sub_header := '0';
			END IF;
				
				
     END LOOP;
	  
	  
     CLOSE csr_src;
	  
	  EXCEPTION
	     WHEN OTHERS THEN
		      RAISE_APPLICATION_ERROR(-20000, 'SRC_CONVERT failed to insert SRCs into RECPE_VAL table cntl_rec_id=' ||  var_cntl_rec_id
			                         || CHR(13) || SUBSTR(SQLERRM, 1, 512));  
	  
	  END;
	  
	  
	  /********************************************************************/
	  /*-*/
	  /*  now get all SRC records with MC_id's - machine codes 
	  /* these will be grouped just like the multiple entries from above  
	  /*-*/
	  /********************************************************************/
     BEGIN
	 
	    rcd_last_mc.mpi_tag := '';
		var_count := 0;
		var_mpi_val := '';
		var_sub_header := '';
			
		OPEN csr_mc;
        LOOP
             FETCH csr_mc INTO rcd_mc;
             EXIT WHEN csr_mc%NOTFOUND;
			         
				     /*-*/
					  /* get the number of entries for this src code 
					  /*-*/
					  IF var_count = 0 THEN
					      var_count := rcd_mc.COUNT;
					  END IF;
					  
					  var_mpi_val := var_mpi_val || RPAD(LPAD(rcd_mc.mpi_val,4,' '),5,' ');
					  var_sub_header := var_sub_header || RPAD(LPAD(SUBSTR(rcd_mc.mc_code,0,4),4,' '),5,' ');
					
				 	  IF var_count = 1 THEN
					       IF var_last_sub_header <> var_sub_header  THEN
				              /*-*/
					          /* insert a header record 
					          /*-*/
							  SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
					          INSERT INTO RECPE_VAL
					          VALUES (var_seq,
								     var_cntl_rec_id,
					                 rcd_mc.opertn,
						             rcd_mc.phase,
						             LPAD(rcd_mc.seq_start,4,'0'),
						             '',
						             '',
						             var_sub_header,
						             '',
						             'VH',
									 '');
							 END IF;
							
				  
				         /*-*/
				         /* insert a standard record 
				         /*-*/
						 SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
				         INSERT INTO RECPE_VAL
					     VALUES (var_seq,
							    var_cntl_rec_id,
					            rcd_mc.opertn,
							    rcd_mc.phase,
							    LPAD(TO_CHAR(TO_NUMBER(rcd_mc.seq_start) + 1),4,'0'),
							    rcd_mc.mpi_tag,
							    SUBSTR(rcd_mc.mpi_desc,0,100),
							    SUBSTR(var_mpi_val,0,50),
							    rcd_mc.mpi_uom,
							    'VL',
								trim(var_sub_header));
									 
					      var_last_sub_header := var_sub_header;
						  var_sub_header := '';
						  var_mpi_val := '';
						  var_last_seq := TO_NUMBER(rcd_mc.seq);
							 
				     END IF;
					 
					 var_count := var_count - 1;
					 
							 
			    /*-*/
				/* save this recordset 
				/*-*/
				rcd_last_mc := rcd_mc;
				
         END LOOP;
			
         CLOSE csr_mc;
      
	  EXCEPTION
	  	WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'SRC_CONVERT failed to insert  MC_Code value SRCs into RECPE_VAL table cntl_rec_id=' ||  var_cntl_rec_id 
			                       || CHR(13) || SUBSTR(SQLERRM, 1, 512)); 		  
	  END;
	
	
	
	  /********************************************************************/
	  /*-*/
	  /*  SRC records WITH PIPE and MC_CODES 
	  /*  now get all SRC records with MC_id's - machine codes 
	  /*  and all multiple pipe entries
	  /*-*/
	  /********************************************************************/
     BEGIN
	 
	      rcd_last_both.mpi_tag := '';
			var_count := 0;
			var_mpi_val := '';
			var_sub_header := '';
			var_row_count := 0;
			
		 OPEN csr_both;
         LOOP
             FETCH csr_both INTO rcd_both;
             EXIT WHEN csr_both%NOTFOUND;
				     /*-*/
					  /* multiple value line 
					  /*-*/
					  var_mpi_val := var_mpi_val || RPAD(LPAD(rcd_both.mpi_val,4,' '),5,' ');
					  var_sub_header := var_sub_header || RPAD(LPAD(SUBSTR(rcd_both.sub_header,0,4),4,' '),5,' ');
					  
					  
					  /*-*/
					  /* get the number of entries for this src code 
					  /*-*/
					  IF var_count = 0 THEN
					      var_count := rcd_both.COUNT;
					  END IF;
					
					  IF var_count > 0 THEN
						   var_count := var_count - 1;
							
						   IF var_count = 0 THEN
							
							    /*-*/
					  			 /* if row count is the first entry save the start seq code 
					  			 /* and increment by 1 each loop 
					  			 /*-*/
					  			 IF var_row_count = 0 THEN
					  	           var_row_seq := TO_NUMBER(rcd_both.seq_start);
					  	   	 ELSE
					  	           var_row_seq := var_row_seq + var_row_count;
					  	       END IF;
					  
					  			 
								 
						       /*-*/
							    /* insert records 
							    /*-*/
							    IF var_last_sub_header <> var_sub_header THEN
							        -- only inser header if it is a new header 
									  SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
									  INSERT INTO RECPE_VAL
					                  VALUES (var_seq,
									         var_cntl_rec_id,
					                         rcd_both.opertn,
							                 rcd_both.phase,
							                 --LPAD(rcd_both.seq_start,4,'0'),
											 LPAD(TO_CHAR(var_row_seq),4,'0'),
							                 '',
							                 '',
							                 var_sub_header,
							                 '',
							                 'VH',
											 '');
							    END IF;
									
								 var_row_count := var_row_count + 1;
								 
							    SELECT RECPE_VAL_id_seq.NEXTVAL INTO var_seq FROM dual;
						       INSERT INTO RECPE_VAL
					          VALUES (var_seq,
									     var_cntl_rec_id,
									     rcd_both.opertn,
							 	  	     rcd_both.phase,
							 		     --LPAD(TO_CHAR(TO_NUMBER(rcd_both.seq_start) + 1),4,'0'),
										  LPAD(TO_CHAR(var_row_seq + 1),4,'0'),
							 		     rcd_both.mpi_tag,
							 		     rcd_both.mc_code || ': ' || SUBSTR(rcd_both.mpi_desc,0,96),
							 		     SUBSTR(var_mpi_val,0,50),
							 		     rcd_both.mpi_uom,
							 		     'VL',
									     trim(var_sub_header));
							  
							    var_last_sub_header := var_sub_header;
							    var_sub_header := '';
							    var_mpi_val := '';
					      END IF;
							
					  END IF;
			       /*-*/
				    /* save this recordset 
				    /*-*/
				    rcd_last_both := rcd_both;
				
            END LOOP;
			
            CLOSE csr_both;
      
	  EXCEPTION
	  	 WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'SRC_CONVERT failed to insert MC_Codes with Pipe SRCs into RECPE_VAL table cntl_rec_id=' ||  var_cntl_rec_id
			                      || CHR(13) || SUBSTR(SQLERRM, 1, 512)); 		  
	  END;
	  
	  END IF;
	  CLOSE csr_cntl_rec_id;
	  
	  
	  
  EXCEPTION
      WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, 'SRC_CONVERT failed' || CHR(13) || SUBSTR(SQLERRM, 1, 512));  
	  
  END;

END Src_Convert;
/


DROP PUBLIC SYNONYM SRC_CONVERT;

CREATE PUBLIC SYNONYM SRC_CONVERT FOR MANU_APP.SRC_CONVERT;


GRANT EXECUTE ON MANU_APP.SRC_CONVERT TO APPSUPPORT;

