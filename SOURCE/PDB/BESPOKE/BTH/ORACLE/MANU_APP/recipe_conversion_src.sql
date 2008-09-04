DROP PACKAGE MANU_APP.RECIPE_CONVERSION_SRC;

CREATE OR REPLACE PACKAGE MANU_APP.Recipe_Conversion_Src AS
/******************************************************************************
   NAME:       SRC_CONVERT 
   PURPOSE:		This procedure will convert any multiple SRCs
					into a single row with header line 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        18-Jan-06   JP          1. Created this package.
   2.0        17-May-07   JP          Added recpe_spcl_cndtn table filter in cursor
   3.0        09-Oct_2007 JP          changed Multiple cursor for Target weight settings
   4.0        09-Oct-2007 JP          added DIV0 feature to Target weight section
******************************************************************************/


  PROCEDURE EXECUTE(par_proc_order IN VARCHAR2);

END Recipe_Conversion_Src;
/


DROP PACKAGE BODY MANU_APP.RECIPE_CONVERSION_SRC;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Recipe_Conversion_Src AS

   /*-*/
   /* constants
   /*-*/
   /* defines the number of characters that can be user for SRC's that 
   /* have a multiple grouping accros the page  
   /*-*/
   MAX_SRC_VALUE_LENGTH CONSTANT NUMBER  := 4;
   /*-*/
   /* this is the character used to seperate the description from the header text on multiple SRC's
   /*-*/
   HEADER_SEPERATOR CONSTANT VARCHAR2(1) := '|';
   /*-*/
   /* the SRC value sent from Atlas to indicate a target weight calculation has to be made
   /*-*/
   TARGET_WEIGHT_SRC_VALUE CONSTANT VARCHAR2(32) := '=TW';
   
   /*-*/
   /* Type declarations
   /* create a virtual table from the static object cntl_rec_mpi_val_table 
   /* (this is just a table of cntl_rec_mpi_val columns
   /*-*/
   v_vir_table cntl_rec_mpi_val_table := cntl_rec_mpi_val_table(); 
     
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);
       

       
   FUNCTION Recipe_Src_Convert(par_proc_order IN VARCHAR2) RETURN NUMBER; 
   FUNCTION get_Value(par_function IN VARCHAR2, par_sign IN VARCHAR2) RETURN NUMBER; 

   
  /*-*/
  /* Main procedure
  /*-*/ 
  PROCEDURE EXECUTE(par_proc_order IN VARCHAR2) IS
    
	 /*-*/
	 /* local variables 
	 /*-*/
	 var_sub_header             VARCHAR2(2000);
	 var_last_sub_header        VARCHAR2(2000) DEFAULT '0';
     var_opertn                 VARCHAR2(4);
     var_last_opertn            VARCHAR2(4) DEFAULT '0';
	 var_mpi_val  				VARCHAR2(2000);
	 var_count 	  				NUMBER DEFAULT 0;
	 var_cntl_rec_id 			NUMBER;
	 var_last_seq				NUMBER DEFAULT 0;
	 var_seq					NUMBER;
	 var_row_count				NUMBER;
	 var_row_seq				NUMBER;
	 var_success               NUMBER;
     var_temp                 VARCHAR2(500);
	 
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
		  		t02.plant, 
		  		t02.cntl_rec_id,
				DECODE(INSTR(mpi_desc,'|'),0,'',trim(SUBSTR(mpi_desc, INSTR(mpi_desc,'|') + 1, LENGTH(mpi_desc)))) sub_header
   	       FROM TABLE(v_vir_table) t01, 
			    CNTL_REC t02
          WHERE LTRIM(t01.proc_order,'0') = LTRIM(t02.proc_order,'0')
	        AND LTRIM(t01.proc_order,'0') = LTRIM(par_proc_order,'0')
			/* dont get any entries with mpi tag of 1999 */
			AND mpi_tag NOT IN (SELECT mpi_tag 
                                  FROM recpe_spcl_cndtn
                                 WHERE INSTR(spcl_cndtn_name,'START') = 0 
                                   AND INSTR(spcl_cndtn_name,'END') = 0)
			/* any mpi values using '*NP*' should not be displayed */
			AND mpi_val <> '*NP*'
			AND mc_code IS NULL
          ORDER BY 2,3,TO_NUMBER(seq);
	 
	 rcd_src csr_src%ROWTYPE;
	 rcd_recpe_val recpe_val%ROWTYPE;
	 
	 /*-*/
	 /* this cursor will get the number of expected entries for each multiple line SRC set
	 /* it checks on the number of material descriptionsd with '|' character in then groups
	 /* all lines with the same description upto the pipe char within a PHASE
	 /*-*/
	 CURSOR csr_multiplexx IS
	     SELECT COUNT(*) COUNT,
		        trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1)) VALUE, 
		        opertn, 
				phase
		   FROM TABLE(v_vir_table) t01, --CNTL_REC_MPI_VAL t01, 
			    CNTL_REC t02
          WHERE LTRIM(t01.proc_order,'0') = LTRIM(t02.proc_order,'0')
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
									    AND TO_NUMBER(t05.seq) < TO_NUMBER(rcd_src.seq)) 		
            /********************************************************/
            /* added JP 2 Oct 2007 to count upto the min seq number in the phase list */
            /*AND TO_NUMBER(t01.seq) < (SELECT MIN(seq)
                                       FROM (SELECT seq, SUBSTR(mpi_desc,1,INSTR(mpi_desc,'|')) mpi_desc
                                               FROM TABLE(v_vir_table) 
                                              WHERE LTRIM(proc_order,'0') = LTRIM('1087070','0')
                                                AND opertn = rcd_src.opertn
                                                AND phase = rcd_src.phase
                                                AND TO_NUMBER(seq) >= TO_NUMBER(rcd_src.seq)
                                              ORDER BY seq) t01
                                      WHERE t01.mpi_desc IS NULL) */
            /********************************************************/
			AND trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1)) = trim(rcd_src.mpi_desc)
			AND INSTR(mpi_desc,'|') > 0
			AND mc_code IS NULL
            AND TO_NUMBER(seq) >= TO_NUMBER(rcd_src.seq) 
		  GROUP BY trim(SUBSTR(mpi_desc,0 ,INSTR(mpi_desc,'|') - 1)),
			    opertn, 
				phase
		  ORDER BY 3,4;
          
		CURSOR csr_multiple
        IS
              SELECT seq, 
                      SUBSTR(mpi_desc,1,INSTR(mpi_desc,'|')) AS Description
                 FROM TABLE(v_vir_table) t01
                WHERE LTRIM(t01.proc_order,'0') = LTRIM(par_proc_order,'0')
                  AND t01.opertn = rcd_src.opertn
                  AND t01.phase = rcd_src.phase
                  AND t01.mc_code IS NULL
                  AND TO_NUMBER(t01.seq) >= TO_NUMBER(rcd_src.seq)
                  /*-*/
			      /* added to seperate like SRC codes with header values from cntl_rec_mpi_txt
			      /*-*/
				  /* this gets the highest number of any header that may exist in this operation/phase
				  /* closest to the current sequence
				  /* if no value found 9999 returned
				  /*-*/
			      AND TO_NUMBER(t01.seq) < (SELECT DECODE(MIN(TO_NUMBER(seq)),NULL,9999,MIN(TO_NUMBER(seq))) header_seq
		    	   					   FROM cntl_rec_mpi_txt t05 
		   		  					  WHERE LTRIM(t05.proc_order,'0') = LTRIM(par_proc_order,'0')
									    AND mpi_type = 'H'
									    AND TO_NUMBER(t05.seq) > TO_NUMBER(rcd_src.seq)) 
                  /*-*/
			      /* this gets the lower number of any header that may exist in this operation/phase
			      /* closest to the current sequence
			      /* if no value found 0 is returned
			      /*-*/
			      AND TO_NUMBER(t01.seq) > (SELECT DECODE(MAX(TO_NUMBER(seq)),NULL,0, MAX(TO_NUMBER(seq))) header_seq
		    	   					   FROM cntl_rec_mpi_txt t05 
		   		  					  WHERE LTRIM(t05.proc_order,'0') = LTRIM(par_proc_order,'0')
									    AND mpi_type = 'H'
									    AND TO_NUMBER(t05.seq) < TO_NUMBER(rcd_src.seq)) 		
                   /********************************************************/
                 ORDER BY TO_NUMBER(seq);
       
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
    
      v_vir_table.DELETE; -- clear virtual table
      
	  /*-*/
	  /* get the control recipe id from cntl_rec table
	  /*-*/
	  OPEN csr_cntl_rec_id;
	  FETCH csr_cntl_rec_id INTO var_cntl_rec_id;
	  IF NOT csr_cntl_rec_id%NOTFOUND THEN
		  
		  /*-*/
		  /* get the data into the virtual table
          /* and do any target weight calculations
          /* then use virtual table as source of mpi data
		  /*-*/
	      var_success := Recipe_Src_Convert(LTRIM(par_proc_order,'0'));
	   
    	  /********************************************************************/
    	  /*-*/
    	  /*  now get all SRC records with either no pipe or PIPE but NO MC_CODES 
          /* ie this cursor will get all records that have no PIPE plus
          /* all records that have a PIPE in order  
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
				  /* start to build the multiple value line 
				  /*-*/
				  var_mpi_val := var_mpi_val || RPAD(LPAD(rcd_recpe_val.mpi_val,4,' '),5,' ');
				  var_sub_header := var_sub_header || RPAD(LPAD(SUBSTR(rcd_src.sub_header,0,4),4,' '),5,' ');
				  
                  /*-*/
				  /* if the count is 0 - we can get the next multiple entry and process
                  /* first time round this value var_count is 0
				  /*-*/
				/*  IF var_count = 0 THEN
					  OPEN csr_multiple;
                      FETCH csr_multiple INTO rcd_multiple;
                      IF NOT csr_multiple%NOTFOUND THEN 
						  var_count := rcd_multiple.COUNT;
                          --DBMS_OUTPUT.PUT_LINE('desc' || rcd_multiple.description ||' seq;' ||  rcd_multiple.seq || ' ph ' || rcd_src.phase || ' count ' || rcd_multiple.COUNT);
                          /*-*/
                          /* if there is only 1 value and it is bigger then 4 characters exppand 
                           /*-*/
                /*          IF var_count = 1 THEN
                              var_mpi_val := trim(rcd_recpe_val.mpi_val);
                          END IF; 
					  ELSE
						  var_count := 0;
					  END IF;
                      CLOSE csr_multiple;
				  END IF; 
                  */
				  IF var_count = 0 THEN                  
					  OPEN csr_multiple;
                      LOOP
                      FETCH csr_multiple INTO rcd_multiple;
                      EXIT WHEN csr_multiple%NOTFOUND;
                          IF rcd_multiple.description IS NULL THEN
                              EXIT;
                          ELSIF var_count = 0 THEN
                              var_temp := rcd_multiple.description;
                          ELSE
                              IF var_temp <> rcd_multiple.description THEN
                                  EXIT;
                              END IF;
                          END IF;
                          var_count := var_count + 1;
                      END LOOP;
                      CLOSE csr_multiple;
                      IF var_count = 1 THEN
                          var_mpi_val := trim(rcd_recpe_val.mpi_val);
                      END IF;
                  END IF;
                   
                  /*---------------------------*/
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
                          IF var_last_sub_header <> var_sub_header OR (var_last_opertn <> rcd_src.opertn AND LENGTH(var_sub_header) > 1) THEN
						       -- only insert header if it is a new header 
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
                            var_last_opertn := rcd_src.opertn;	
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

  
   /*-*/
   /* put the SRC Value entries into a virtual table and modify any =TW (target weight)
   /-*/
   FUNCTION Recipe_Src_Convert(par_proc_order IN VARCHAR2) RETURN NUMBER IS
       
           /*-*/
           /* cursor definitions
           /*-*/
           CURSOR csr_target_weight
           IS
           SELECT LTRIM(t01.matl_code,'0') matl_code, 
                  t02.nake_target_wght AS target_weight,
                  t02.nake_uom uom
             FROM cntl_rec t01,
                  material_target_weight t02
            WHERE LTRIM(t01.matl_code,'0') = t02.matl_code
              AND LTRIM(t01.proc_order,'0') = par_proc_order;
              
           rcd_target_weight csr_target_weight%ROWTYPE;
           
           CURSOR csr_cntl_rec_mpi_val
           IS
           SELECT t01.*, 
                  LTRIM(t02.matl_code,'0') matl_code
             FROM cntl_rec_mpi_val t01,
                  cntl_rec t02
            WHERE t01.proc_order = t02.proc_order
              AND LTRIM(t01.proc_order,'0') = par_proc_order 
            ORDER BY t01.opertn, t01.phase, TO_NUMBER(t01.seq);
           rcd_cntl_rec_mpi_val csr_cntl_rec_mpi_val%ROWTYPE;
     
           var_target_weight NUMBER DEFAULT 0;
           var_count         NUMBER;
           var_work          VARCHAR2(2000);
           var_scalefactor   NUMBER DEFAULT 1;
           var_offset        NUMBER DEFAULT 0;
           var_length        NUMBER;
           var_uom_scale     NUMBER DEFAULT 1;
           
       BEGIN
           
           /*-*/
           /* open the target weight cursor
           /*-*/
           OPEN csr_target_weight; 
           FETCH csr_target_weight INTO rcd_target_weight;
           IF csr_target_weight%NOTFOUND THEN
               var_target_weight := 0;
           ELSE
               var_target_weight := rcd_target_weight.target_weight;
           END IF;
           CLOSE csr_target_weight;
                   
           /*-*/
           /* open the mpi val cursor
           /*-*/
           OPEN csr_cntl_rec_mpi_val;
           LOOP
               FETCH csr_cntl_rec_mpi_val INTO rcd_cntl_rec_mpi_val;
               IF csr_cntl_rec_mpi_val%NOTFOUND THEN
                   EXIT;
               END IF;
               v_vir_table.EXTEND;
            
               /*-*/
               /* copy the data to the virtual table
               /*-*/  
               v_vir_table(v_vir_table.LAST):= cntl_rec_mpi_val_object(rcd_cntl_rec_mpi_val.cntl_rec_mpi_val_id,
                                                                       LTRIM(rcd_cntl_rec_mpi_val.PROC_ORDER,'0'),
                                                                       rcd_cntl_rec_mpi_val.opertn,
                                                                       rcd_cntl_rec_mpi_val.phase,
                                                                       LPAD(rcd_cntl_rec_mpi_val.seq,4,'0'),
                                                                       rcd_cntl_rec_mpi_val.mpi_tag,
                                                                       rcd_cntl_rec_mpi_val.mpi_desc,
                                                                       LTRIM(rcd_cntl_rec_mpi_val.mpi_val),
                                                                       rcd_cntl_rec_mpi_val.mpi_uom,
                                                                       rcd_cntl_rec_mpi_val.mc_code,
                                                                       rcd_cntl_rec_mpi_val.dtl_desc,
                                                                       rcd_cntl_rec_mpi_val.plant);
            
           END LOOP;
           CLOSE csr_cntl_rec_mpi_val;
           
           IF v_vir_table.COUNT > 0 THEN        
               
               /*-*/
               /* loop through to convert any target weight calcs
               /*-*/
               FOR i IN v_vir_table.FIRST .. v_vir_table.LAST
                   LOOP
                 
                   IF SUBSTR(v_vir_table(i).mpi_val, 0, LENGTH(TARGET_WEIGHT_SRC_VALUE)) = TARGET_WEIGHT_SRC_VALUE THEN
                       /*-*/
                       /* found one
                       /*-*/
                       IF var_target_weight = 0 THEN
                           v_vir_table(i).mpi_val := 'Err'; -- set the value to an error
                       ELSE
                           /*-*/
                           /* define the uom scaling factor
                           /*-*/
                           IF UPPER(SUBSTR(rcd_target_weight.uom,0,1)) = 'K' AND UPPER(SUBSTR(v_vir_table(i).mpi_uom,0,1)) = 'K' THEN 
                               var_uom_scale := 1;
                           ELSIF UPPER(SUBSTR(rcd_target_weight.uom,0,1)) = 'G' AND UPPER(SUBSTR(v_vir_table(i).mpi_uom,0,2)) = 'G' THEN 
                               var_uom_scale := 1;
                           ELSIF UPPER(SUBSTR(rcd_target_weight.uom,0,1)) = 'K' AND SUBSTR(UPPER(trim(v_vir_table(i).mpi_uom)),1,1) = 'G' THEN 
                               var_uom_scale := 1000;
                           ELSIF UPPER(SUBSTR(rcd_target_weight.uom,0,1)) = 'G' AND UPPER(SUBSTR(v_vir_table(i).mpi_uom,0,1)) = 'K' THEN 
                               var_uom_scale := 1/1000;
                           ELSE var_uom_scale := 1; 
                           END IF;
                          
                           /*-*/
                           /* this is a taget weight SRC - remove any spaces
                           /*-*/
                           v_vir_table(i).mpi_val := trim(REPLACE(v_vir_table(i).mpi_val,' ',''));  -- remove any spaces
                           /*-*/
                           /* get the remainder of the src value into a variable
                           /*-*/
                           var_work := SUBSTR(v_vir_table(i).mpi_val, LENGTH(TARGET_WEIGHT_SRC_VALUE) + 1, LENGTH(v_vir_table(i).mpi_val));
                           /*-*/
                           /*set default value
                           /*-*/
                           var_scalefactor := 1;
                           var_offset := 0;
                           IF var_work IS NULL THEN
                               /*-*/
                               /* just the taget weight value required
                               /*-*/
                               v_vir_table(i).mpi_val := TO_CHAR(var_target_weight * var_uom_scale);
                           ELSE
                               /*-*/
                               /* now convert scale and offset commands
                               /*-*/
                               IF INSTR(var_work,'/') > 0 THEN
                                   var_scalefactor := get_Value(SUBSTR(var_work, INSTR(var_work,'/')+1,LENGTH(var_work)), '/');
                               END IF;   
                               IF INSTR(var_work,'*') > 0 THEN
                                   var_scalefactor := get_Value(SUBSTR(var_work, INSTR(var_work,'*')+1,LENGTH(var_work)), '*');
                               END IF;  
                               IF INSTR(var_work,'+') > 0 THEN
                                   var_offset := get_Value(SUBSTR(var_work, INSTR(var_work,'+')+1,LENGTH(var_work)), '+');
                               END IF;  
                               IF INSTR(var_work,'-') > 0 THEN
                                   var_offset := get_Value(SUBSTR(var_work, INSTR(var_work,'-')+1,LENGTH(var_work)), '-');
                               END IF;  
                               IF var_offset = 999 OR var_scalefactor = 999 THEN
                                   v_vir_table(i).mpi_val := 'Err'; -- set the value to an error
                               ELSIF var_scalefactor = 0 AND INSTR(var_work,'/') > 0 THEN
                                   v_vir_table(i).mpi_val := 'DIV0';
                               ELSE
                                   v_vir_table(i).mpi_val := ((var_target_weight * var_scalefactor) * var_uom_scale) + var_offset;
                                   DBMS_OUTPUT.PUT_LINE('tgt' || v_vir_table(i).mpi_val);                              
                                  -- v_vir_table(i).mpi_val := v_vir_table(i).mpi_val * var_uom_scale;
                                  -- DBMS_OUTPUT.PUT_LINE('tgt01' || v_vir_table(i).mpi_val);   
                               END IF;
                           END IF; 
                       END IF;
                   
                   END IF;
               END LOOP;
               
               /*-*/
               /* now check if any value columns that should be jioned by the '|' character 
               /* has more than the standard number of characters
               /*-*/
               FOR i IN v_vir_table.FIRST .. v_vir_table.LAST
                   LOOP
                     IF LENGTH(v_vir_table(i).mpi_val) > MAX_SRC_VALUE_LENGTH AND INSTR(v_vir_table(i).mpi_desc,HEADER_SEPERATOR) > 0 THEN
                         --v_vir_table(i).mpi_desc := SUBSTR(v_vir_table(i).mpi_desc,0,INSTR(v_vir_table(i).mpi_desc,'|')-1);
                         v_vir_table(i).mpi_desc := REPLACE(v_vir_table(i).mpi_desc,HEADER_SEPERATOR, ': ');
                     END IF;
                    
                     /*IF v_vir_table(i).opertn = '0030' THEN
                      DBMS_OUTPUT.PUT_LINE('op=' ||v_vir_table(i).opertn || '-' || v_vir_table(i).phase || '-' || v_vir_table(i).seq|| ' mpi_desc=' ||v_vir_table(i).mpi_desc || ' mpi_val=' ||v_vir_table(i).mpi_val);
                     END IF;
                    */
               END LOOP; 
               
           END IF; 
           
           
              
           RETURN 0;
           
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               RETURN 1;
           WHEN OTHERS THEN
               -- Consider logging the error and then re-raise
               RETURN 1;
       END;
       
       
       /*-*/
       /* convert the string into a number
       /-*/
       FUNCTION get_Value(par_function IN VARCHAR2, par_sign IN VARCHAR2) RETURN NUMBER IS
       
           var_work VARCHAR2(2000) DEFAULT ''; 
           var_work01 VARCHAR2(2000) DEFAULT '';
           var_result NUMBER;
           
       BEGIN
       
           --DBMS_OUTPUT.PUT_LINE(par_function ||' by ' || par_sign);
           var_work := par_function;
           IF LENGTH(var_work) = 0 THEN
               RETURN 999;
           ELSE
              IF INSTR(var_work, '+') > 0 THEN
                 var_work01 := SUBSTR(var_work,0, INSTR(var_work, '+') - 1);
              ELSIF INSTR(var_work, '-') > 0 THEN
                  var_work01 := SUBSTR(var_work,0, INSTR(var_work, '-') - 1);
              ELSE
                 var_work01 := var_work;
              END IF;
           END IF;
           
           /*-*/
           /* convert to a number
           /*-*/
           BEGIN
               IF par_sign = '-' THEN 
                    var_result := -TO_NUMBER(var_work01);
               ELSIF par_sign = '/' THEN 
                   var_result := 1/TO_NUMBER(var_work01);
               ELSE
                   var_result := TO_NUMBER(var_work01);
               END IF;
              
           EXCEPTION
               WHEN OTHERS THEN
                   RETURN 999;
           END;
           
           RETURN var_result;
       END;
       
       
       
END Recipe_Conversion_Src;
/


