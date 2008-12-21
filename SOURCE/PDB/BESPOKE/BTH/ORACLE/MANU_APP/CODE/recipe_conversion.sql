DROP PACKAGE MANU_APP.RECIPE_CONVERSION;

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
   2.0        10/05/2007   Jeff Phillipson    Added scale to Bom,
                                              Hide duplicates
   2.1        29-Oct-2007  Jeff Phillipson    Scale to Bom material calc changed
   2.2        28-Apr-2008  Jeff Phillipson    Added a method to ratio scale to Bom and Parent 
                                              by a scale to of the parent if it exits 
   2.3        14-May-2008  Jeff Phillipson    Added date of PO into getScaleToBom function 
   
   NOTE: THIS IS A COPY OF THE PACKAGE USED IN SNACK
   HOWEVER THERE ARE CHANGES SINCE TABLE COLUMN NAMES 
   ARE DIFFERENT IN MFA PLANT DB 
******************************************************************************/
/* Recipe_Conversion DATA flow
/*
/*
/*     1            Get DEFAULT DATA FROM RECPE_SPCL_CNDTN tabe AND DATABASE NAME
/*     2            RECOVER THE general HEADER detail FROM cntl_rec etc
/*     3            DELETE THE OLD recipe IF already IN THE DATABASE
/*     4            INSERT THE HEADER RECORD - used FOR THE FRR printout HEADER details
/*     5            Check if Resource record has to be created - if new Operation code found
/*                     this changes depending upon how many phantoms and hide duplicate conditions
/*     6            Detail material records are then added to the recpe_dtl table
/*     7            All Phantoms based on HIDE_DUPLICATE are the inserted into the detail table
/*     8            Any resources used within the SRC tables (CNTL_REC_MPI_VAL and _TXT are inserted into the resource table
/*     9            Finally the SRC_CONVERSION package is called to insert all SRC records
/*
*/
  
  /************************************************************************************/
   /* this function will calculate the correct pan size and summ all pans
   /* INPUT         proc_order
   /*               operation
   /* OUTPUT        pan_size  based on the largets pan_size within the operation
   /*               no_of_pans      calculation of the total number of pans required
   /* RETURN value  0 no duplicates
   /*               1 valid pan size and number of pans
   /************************************************************************************/
   FUNCTION getPanValues (i_proc_order IN VARCHAR2, i_opertn IN VARCHAR2, i_dedup IN NUMBER, o_pan_size OUT NUMBER, o_no_of_pans OUT NUMBER) RETURN NUMBER;
   
                   
   PROCEDURE EXECUTE(par_cntl_Rec_Id IN NUMBER);
  
   FUNCTION  get_Next_Level(i_proc_order IN VARCHAR2, 
                      i_parent_phase IN VARCHAR2, 
                      i_parent_matl_code IN VARCHAR2, 
                      o_display_rule OUT VARCHAR2, 
                      o_parent_matl_code OUT VARCHAR2, 
                      o_parent_opertn OUT VARCHAR2,
                      o_parent_phase OUT VARCHAR2) RETURN NUMBER; 
         
END Recipe_Conversion;
/


DROP PACKAGE BODY MANU_APP.RECIPE_CONVERSION;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Recipe_Conversion AS
/******************************************************************************
   NAME:       Recipe_Conversion
   PURPOSE:    To convert the proc Order data sent by Atlas through
               Proc_Orders into a set of records that can be easily used
               by a fron end to print FDR's
               The data will be expanded based on RESRCE and Opcode settings

   
    /*-*/
    /*   RULES:
	/* 	 1	 Scale to Parent - Material Quantities are adjusted as per the USE quantity rather than the made quantity.
	/*	 If an SRC with the MPI_TAG set to 'SCALE_TO_PARENT' mpi tag (defined in table RECPE_SPCL_CNDTN)
    /*   within an Operation/Phase is found, then material quantities within the phase
	/*	 are modified by the ratio of phantom USED qty/ phantom MADE quantity  
    /*
    /*   2.  Scale to Bom if this SRC is found within a phase then all materials
    /*   are scaled to the parents BOM quantity.
    /*
    /*   3.  Hide duplicates if a phase has an SRC code thar defines hide duplicates
    /*   then all duplicate phases are removed and if only 1 visible phase is left
    /*   the Resource header line contains the pan size and number of total batches  
    /*-*/

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*-*/
   /* cursor to get special coinditions
   /*-*/
   CURSOR csr_spcl_condition 
   IS
   SELECT MAX(CASE WHEN spcl_cndtn_name = 'SCALE_TO_PARENT' THEN mpi_tag END) AS SCALE_TO_PARENT,
          MAX(CASE WHEN spcl_cndtn_name = 'SCALE_TO_BOM' THEN mpi_tag END) AS SCALE_TO_BOM,
          MAX(CASE WHEN spcl_cndtn_name = 'HIDE_DUPLICATES' THEN mpi_tag END) AS HIDE_DUPLICATES,
          MAX(CASE WHEN spcl_cndtn_name = 'START_SPCL' THEN mpi_tag END) AS START_SPCL,
          MAX(CASE WHEN spcl_cndtn_name = 'END_SPCL' THEN mpi_tag END) AS END_SPCL
     FROM recpe_spcl_cndtn;
     
   /*-*/
   /* variables - special condition codes sent as an MPI_TAG within the same phase as the material
   /*-*/
   rcd_spcl_cndtn csr_spcl_condition%ROWTYPE;
   
    
   /************************************************************************************/
   /* local functions for calculating the scale to parent or scale to bom
   /************************************************************************************/
   /*-*/
   /* this will provide a ratio to use for each material entry
   /* scalled to the Parent material quantity (where used)
   /* This function will return the ratio of either the first pan if the pan flag is set to Y
   /* or ratio the quantities if the pan fag is not Y
   /*-*/
   FUNCTION  getScaleToParent(i_proc_order IN VARCHAR2, i_opertn IN VARCHAR2, i_phase IN VARCHAR2,  pan_count OUT NUMBER) RETURN NUMBER
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
               AND t01.phase = t02.opertn_from -- new line
			   AND t01.proc_order = t03.proc_order
			   AND t02.opertn = t03.opertn
    	 	   AND t01.opertn =  i_opertn
			   AND t01.phase =  i_phase
   		 	   AND t01.phantom = 'M'
   		 	   AND t02.phantom = 'U'
   		 	   AND LTRIM(t01.proc_order,'0') = i_proc_order;
		 
   BEGIN
		pan_count := 1;
		/* scale to parent is present so get the scale factor */
        OPEN csr_ratio;
        FETCH csr_ratio INTO  var_ratio, var_pan_count;
            IF csr_ratio%NOTFOUND THEN
			    var_ratio := 1;  
			    var_pan_count := 1;
            END IF;
        CLOSE csr_ratio;
		/* if the ratio has become zero make it equal 1 */
		IF var_ratio = 0 THEN
		    var_ratio := 1;
		END IF;
		pan_count := var_pan_count;
		RETURN var_ratio;
   EXCEPTION
       WHEN OTHERS THEN
       	   pan_count := 1;
           RETURN 1;
   END;
   /*******************************************/
   
   FUNCTION  getScaleToBOM(i_proc_order IN VARCHAR2, i_opertn IN VARCHAR2, i_phase IN VARCHAR2, i_matl_code IN VARCHAR2, i_date IN DATE, pan_count OUT NUMBER, bom_qty OUT NUMBER) RETURN NUMBER
   IS
       var_ratio NUMBER;
	   var_bom_qty NUMBER;
	   var_pan_count NUMBER;
       
	   CURSOR csr_get_parent IS
	   SELECT matl_code,
              CASE
              WHEN pan_size_flag = 'Y' AND pan_qty IS NOT NULL AND pan_qty = 1 THEN pan_size
              WHEN pan_size_flag = 'N' THEN qty
              WHEN pan_size_flag = 'Y' AND pan_qty IS NOT NULL AND pan_qty > 1 THEN pan_size 
              ELSE pan_size * pan_qty END po_qty,
              pan_qty,
              plant plant_code
         FROM cntl_rec_bom
        WHERE LTRIM(proc_order,'0') = i_proc_order
          AND matl_code NOT IN (SELECT matl_code FROM recpe_phantom)
          AND opertn =  i_opertn
          --AND phase = i_phase
          AND phantom = 'M';
       rcd_get_parent csr_get_parent%ROWTYPE;
          
       CURSOR csr_get_bom IS
       SELECT t01.bom_base_qty AS bom_qty,
              t01.item_base_qty qty
         FROM (SELECT DISTINCT item_material_code, 
                      bom_base_qty,
                      item_base_qty
                 FROM TABLE (bds_bom.get_dataset(i_date, rcd_get_parent.matl_code, rcd_get_parent.plant_code))) t01
        WHERE t01.item_material_code = i_matl_code;
       rcd_get_bom csr_get_bom%ROWTYPE;  
		 
   BEGIN
      var_ratio := 1; -- default
      var_bom_qty := 0; --default
      
	  /* firstly get the parent material code and the parent quantity from the procedure order */
      OPEN csr_get_parent;
         FETCH csr_get_parent INTO  rcd_get_parent;
         IF NOT csr_get_parent%NOTFOUND THEN
            /* if a record found go and get the bom quantity of the bom parent used */
            OPEN csr_get_bom;
                FETCH csr_get_bom INTO rcd_get_bom;
                IF NOT csr_get_bom%NOTFOUND THEN
                    var_ratio := NVL(rcd_get_bom.bom_qty/rcd_get_parent.po_qty,1); 
                    --DBMS_OUTPUT.PUT_LINE('op' || i_opertn || ' ratio:' || TO_CHAR(rcd_get_bom.bom_qty,'999999D999') ||' - ' || TO_CHAR(rcd_get_parent.po_qty,'999999D999')); 
                    var_bom_qty := rcd_get_bom.qty;
                    var_pan_count := (rcd_get_parent.po_qty*rcd_get_parent.pan_qty) /rcd_get_bom.bom_qty;
                END IF;
            CLOSE csr_get_bom;
         END IF;
      CLOSE csr_get_parent;
      pan_count := var_pan_count;
      bom_qty := var_bom_qty;        
      
	  RETURN var_ratio;
      
   EXCEPTION
       WHEN OTHERS THEN
           pan_count := 1;
           DBMS_OUTPUT.PUT_LINE ('ERROR!');
           RETURN 1;
   END;
   /************************************************************************************/
   
   /************************************************************************************/
   /* this function will calculate the correct pan size and summ all pans
   /* INPUT         proc_order
   /*               operation
   /* OUTPUT        pan_size  based on the largets pan_size within the operation
   /*               no_of_pans      calculation of the total number of pans required
   /* RETURN value  0 no duplicates
   /*               1 valid pan size and number of pans
   /************************************************************************************/
   FUNCTION getPanValues (i_proc_order IN VARCHAR2, i_opertn IN VARCHAR2, i_dedup IN NUMBER, o_pan_size OUT NUMBER, o_no_of_pans OUT NUMBER) RETURN NUMBER
   IS
   
       CURSOR csr_pan
       IS
       SELECT pan_size, 
           CASE 
               WHEN pan_qty = 1 THEN pan_size
               WHEN pan_qty > 1 THEN (pan_size * (pan_qty - 1)) + last_pan_size
               ELSE pan_size 
           END AS qty_total 
        FROM cntl_rec_bom
       WHERE LTRIM(proc_order,'0') = i_proc_order
         AND opertn = i_opertn
         AND phantom = 'M'
         AND LTRIM(MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
         AND EXISTS (SELECT 'x' 
                       FROM cntl_rec_mpi_val 
                      WHERE LTRIM(proc_order,'0') = i_proc_order
                        AND opertn = i_opertn
                        AND mpi_tag = i_dedup)
       ORDER BY phase;
       rcd_pan csr_pan%ROWTYPE;
       
       
       CURSOR csr_get_all_other_pans
       IS
       SELECT SUM(pan_qty) 
         FROM cntl_rec_bom
        WHERE LTRIM(proc_order,'0') = i_proc_order
          AND opertn > i_opertn
          AND phantom = 'M'
          AND LTRIM(MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
          AND matl_code IN (SELECT matl_code 
                              FROM cntl_rec_bom
                             WHERE LTRIM(proc_order,'0') = i_proc_order
                               AND opertn = i_opertn
                               AND phantom = 'M'
                               AND LTRIM(MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM));
         
       
       var_count NUMBER DEFAULT 0;
       var_work NUMBER DEFAULT 0;
         
   BEGIN
       o_pan_size := 0;
       o_no_of_pans := 0;
       
       var_count := 0;
       OPEN csr_pan;
       LOOP
           FETCH csr_pan INTO rcd_pan;
           EXIT WHEN csr_pan%NOTFOUND;
           IF var_count = 0 THEN
               /*-*/
               /* get the best pan size by using the largest value
               /*-*/
               o_pan_size := rcd_pan.pan_size;
               var_count := var_count + 1;
           END IF;
           var_work := var_work + rcd_pan.qty_total;
       END LOOP;
       CLOSE csr_pan;
       o_no_of_pans := ROUND(var_work / o_pan_size,3);
       
       /*-*/
       /* check if this in an op with 1 phantom and a hide dups
       /*-*/
       SELECT COUNT(*) INTO var_count
       FROM cntl_rec_bom
       WHERE LTRIM(proc_order,'0') = i_proc_order
         AND opertn = i_opertn
         AND phantom = 'M'
         AND LTRIM(MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
         AND EXISTS (SELECT 'x' 
                       FROM cntl_rec_mpi_val 
                      WHERE LTRIM(proc_order,'0') = i_proc_order
                        AND opertn = i_opertn
                        AND mpi_tag = i_dedup);
       
       
                        
       IF var_count > 1 THEN 
           RETURN 1;
       ELSE
           OPEN csr_get_all_other_pans;
           FETCH csr_get_all_other_pans INTO var_count;
           IF csr_get_all_other_pans%NOTFOUND THEN
               var_count := 0;
           END IF;
           CLOSE csr_get_all_other_pans;
           IF var_count IS NOT NULL THEN
               o_no_of_pans := o_no_of_pans + var_count;
           END IF;
           
           RETURN 1;
       END IF;
       
   EXCEPTION
       WHEN OTHERS THEN
           RETURN 0;
   END;
   /************************************************************************************/
   

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
    var_ratio_scale   NUMBER; -- used for getting scale to bom or parent of the parent 
	var_no_of_pans    NUMBER;
    var_name          VARCHAR2(200);
    var_bom_qty       NUMBER;
    var_hide_phantom_matl VARCHAR2(18);
    var_success       NUMBER;
    var_dup_pan_size  NUMBER;
    var_dup_no_of_pans NUMBER;
   
    var_new_op bds_recipe_bom.operation%TYPE;
    var_new_ph bds_recipe_bom.phase%TYPE;
    var_new_display_rule VARCHAR2(2);
    var_new_matl_code VARCHAR2(18);
	var_result NUMBER;
        
    var_in_phase bds_recipe_bom.phase%TYPE;
    var_in_material_code bds_recipe_bom.material_code%TYPE;
	
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
    /* Cursor gets the header information using the cntl_rec_id code
    /* This detail is used for the header data of the FRR printout
    /*-*/
    CURSOR csr_cntl_rec IS
       SELECT c.* , ean_code tun, rgnl_code_nmbr
         FROM CNTL_REC c, MATL_vw M
        WHERE cntl_rec_id = par_cntl_rec_id
		  AND LTRIM(c.MATL_code,'0') = M.matl_code(+);
		  --AND c.plant = M.plant_code(+);
    rcd_cntl_rec csr_cntl_rec%ROWTYPE; 
    
    /*-*/
    /* Cursor retrieves all material entries to be used for printing the report.
    /* this cursor will remove dupolicate entries if the HIDE_DUPLICATES 
    /* flag is set against a Phase
    /* table t07 has been added to also allow phases that do not have a phantom ('M')
    /* within the phase to be printed. This allows complex duplicates to work
    /*-*/
    CURSOR csr_recpe IS
    /* NEW VERSION OF QUERY */
    SELECT t01.*, 
           t02.parent_material_code,
           t02.parent_operation,
           t02.parent_phase,
           t02.parent_opertn_from,
           t02.parent_display_rule_x, t02.rnk
      FROM (SELECT LTRIM (t01.proc_order, '0') proc_order,
                   t01.cntl_rec_id,
                   t02.resrce_code,
                   DECODE (t04.resrc_text, NULL, 'No REF_RESOURCE table entry', t04.resrc_text) resrce_desc,
                   t03.opertn opertn,
                   t03.phase,
                   t03.seq,
                   t03.phantom,
                   LTRIM (t03.matl_code, '0') matl_code,
                   t03.matl_desc,
                   TO_CHAR (TO_NUMBER (DECODE (t03.pan_size_flag, 'Y', t03.pan_size, t03.qty)),'999999999990.999990') bom_qty,
                   t03.uom,
                   t03.opertn_from,
                   Recipe_Disp_Hide (t01.proc_order, t03.opertn, t03.phase, t03.matl_code) display,
                   CASE
                       WHEN spcl_cndtn_name = 'SCALE_TO_BOM' THEN 'SB'
                       WHEN spcl_cndtn_name = 'SCALE_TO_PARENT' THEN 'SP'
                       ELSE NULL
                   END display_rule_x --,
                   --Recipe_Scale_To(t01.proc_order, t03.opertn, t03.matl_code) display_rule
              FROM cntl_rec t01, 
                   cntl_rec_resrce t02, 
                   cntl_rec_bom t03, 
                   bds_prodctn_resrc_en t04, --ref_resource t04,
                   (SELECT DISTINCT proc_order,
                           opertn AS opertn,
                           t01.mpi_tag,
                           spcl_cndtn_name
                      FROM cntl_rec_mpi_val t01, recpe_spcl_cndtn t02
                     WHERE t01.mpi_tag = t02.mpi_tag
                       AND (spcl_cndtn_name = 'SCALE_TO_BOM' OR spcl_cndtn_name = 'SCALE_TO_PARENT' )) t08
             WHERE t01.proc_order = t02.proc_order
               AND t01.proc_order = t03.proc_order
               AND t02.opertn = t03.opertn
               AND t02.resrce_code = t04.resrc_code(+)
               AND t02.plant = t04.resrc_plant_code(+)
               AND t03.proc_order = t08.proc_order(+)
               AND t03.opertn = t08.opertn(+)
               AND LTRIM(t03.MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
               AND (t03.phantom = 'U' OR t03.phantom IS NULL)   -- U = Used (from atlas)
             ) t01,
             (-- this query is used to find if a SB or SP exists for the parent
             SELECT DISTINCT t01.proc_order, 
                    t01.matl_code parent_material_code,
                    t01.opertn parent_operation, 
                    t01.phase parent_phase, 
                    t01.opertn_from parent_opertn_from,
                    CASE 
                        WHEN spcl_cndtn_name = 'SCALE_TO_BOM' THEN 'SB'
                        WHEN spcl_cndtn_name = 'SCALE_TO_PARENT' THEN 'SP'
                        ELSE ''
                    END AS parent_display_rule_x,
                    rank() OVER (PARTITION BY t01.proc_order,t01.matl_code
                                      ORDER BY spcl_cndtn_name ASC) rnk
               FROM cntl_rec_bom t01,
                    cntl_rec_mpi_val t02, 
                    recpe_spcl_cndtn t03
              WHERE t01.proc_order = t02.proc_order
                AND t01.opertn = t02.opertn
                AND t02.mpi_tag = t03.mpi_tag
                AND (spcl_cndtn_name = 'SCALE_TO_BOM' OR spcl_cndtn_name = 'SCALE_TO_PARENT') 
                AND opertn_from IS NOT NULL   
                ) t02
       WHERE t01.proc_order = ltrim(t02.proc_order(+),'0')
         AND t01.phase = t02.parent_opertn_from(+)
         AND t01.proc_order = LTRIM (rcd_cntl_rec.proc_order, '0') 
         AND display = 'D'
         --AND (rnk = 1 OR rnk IS NULL)
       ORDER BY 5, 6, 7;
 
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
			AND (opertn IN (SELECT  DISTINCT opertn FROM cntl_rec_mpi_val	WHERE proc_order = t01.proc_order
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
        /* this is assuming the MPI_TAG value is set to SCALE_TO_MADE (1999)
		/*-*/
		CURSOR csr_pan_qty IS
		    SELECT SUM(DECODE(pan_qty,0,1,NULL,1,1,pan_qty, (pan_qty - 1)  + (TO_CHAR(TO_NUMBER(last_pan_size)/pan_size,'999D9')))) pan_qty,  
			       matl_code AS matl_code, 
				   matl_desc AS matl_desc,  
			       DECODE(pan_size,NULL,qty,pan_size) qty,
				   uom AS uom,
				   DECODE(mpi_tag, NULL, 'N', 'Y') rescale
			  FROM CNTL_REC_BOM t01,
                   (SELECT * 
                      FROM cntl_rec_mpi_val 
                     WHERE mpi_tag IN (rcd_spcl_cndtn.scale_to_parent,rcd_spcl_cndtn.scale_to_bom)) t02
			 WHERE t01.opertn = rcd_recpe.opertn
			   AND LTRIM(t01.proc_order,'0')  = LTRIM(rcd_cntl_rec.proc_order,'0')
			   AND phantom = 'M'
			   AND t01.PROC_ORDER = t02.PROC_ORDER(+)
			   AND t01.OPERTN = t02.OPERTN(+)
			   AND LTRIM(matl_code,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
             GROUP BY matl_code, 
                   matl_desc, 
                   DECODE(pan_size, NULL, qty, pan_size),
                   uom, 
                   DECODE(mpi_tag, NULL, 'N', 'Y');				
					
		rcd_pan_qty csr_pan_qty%ROWTYPE;	
		
		/*-*/
		/* this cursor will get all MADE material Phantoms for any operation 
		/* where there is more than 1 made phantom 
		/* All the records will then be saved in the RECPE_DTL table 
        /* and these lines will be printed in Bold on the  
		/* recipe report 
		/*-*/
		CURSOR csr_phantoms
        IS
		SELECT proc_order,
		       opertn,
		       phase,
		       matl_code,
		       matl_desc,
		       seq,
		       rnk,
		       mpi_tag,
		       phase_header
          FROM (SELECT t01.*,
                       t02.mpi_tag,
                       SUM(rnk) OVER (PARTITION BY t01.proc_order, t01.opertn) phase_header
                  FROM (SELECT t01.*,
                               rank() OVER (PARTITION BY proc_order, opertn, matl_code
                                      ORDER BY phase ASC) rnk
                          FROM (SELECT LTRIM(t01.proc_order,'0') AS proc_order, 
	                                   t01.opertn AS opertn, 
                                       LPAD(TO_CHAR(TO_NUMBER(t01.phase) - 1),4,'0') phase, 
	                                   t01.matl_code AS matl_code, 
	                                   matl_desc AS matl_desc, 
	                                   '0001' seq,
                                       t03.cntl_rec_id
		                          FROM cntl_rec_bom t01,
                                       cntl_rec t03
		                         WHERE phantom = 'M'
		                           AND LTRIM(t01.MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
		                           AND t03.proc_order = t01.proc_order) t01) t01,
               (SELECT DISTINCT mpi_tag, proc_order, opertn AS opertn 
                  FROM cntl_rec_mpi_val 
                 WHERE mpi_tag = (SELECT mpi_tag FROM recpe_spcl_cndtn WHERE spcl_cndtn_name = 'HIDE_DUPLICATES')) t02
         WHERE t01.proc_order = t02.proc_order(+)
           AND t01.opertn = t02.opertn(+)
           AND t01.cntl_rec_id = par_cntl_Rec_Id)
  WHERE phase_header > 1 
    AND (rnk = 1 OR (rnk > 1 AND mpi_tag IS NULL))
  ORDER BY 2,3,4,5;
       
		 rcd_phantoms csr_phantoms%ROWTYPE;
		
        /*-*/
        /* cursor to get the number of phantoms within a operation and look for hide duplicates MPI tag
        /*-*/
        CURSOR csr_get_phantoms_per_op
        IS
        SELECT matl_code AS matl_code, 
               mpi_tag 
          FROM cntl_rec_bom t01,
               cntl_rec_mpi_val t02
         WHERE t01.proc_order = t02.proc_order(+)
           AND t01.opertn = t02.opertn(+) 
           AND t01.phase = t02.phase(+)
           AND t01.opertn = rcd_recpe.opertn
           AND LTRIM(t01.MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
           AND LTRIM(t01.proc_order,'0')  = LTRIM(rcd_recpe.proc_order,'0')
           AND t01.phantom = 'M'
         ORDER BY 1,2;
        rcd_get_phantoms_per_op csr_get_phantoms_per_op%ROWTYPE;
        rcd_get_last_phantoms_per_op csr_get_phantoms_per_op%ROWTYPE;
        
        
        
  BEGIN

     /*****  1  *****/
    
     /*-*/
     /* get the database, oracle database name - used for error messages
     /*-*/
	 SELECT UPPER(sys_context('USERENV','DB_NAME'))
       INTO var_name 
       FROM dual;
     
     /*-*/
     /* get special condition flags - scale to parent or bom and hide duplicates
     /*-*/
     BEGIN
          OPEN csr_spcl_condition;
          FETCH csr_spcl_condition INTO rcd_spcl_cndtn;
              IF csr_spcl_condition%NOTFOUND THEN
                  rcd_spcl_cndtn.scale_to_parent := 0;   
                  rcd_spcl_cndtn.scale_to_bom := 0;
                  rcd_spcl_cndtn.hide_duplicates := 0;
              END IF;
          --CLOSE csr_spcl_condition;
     EXCEPTION
         WHEN OTHERS THEN
             rcd_spcl_cndtn.scale_to_parent := 0;   
             rcd_spcl_cndtn.scale_to_bom := 0;
             rcd_spcl_cndtn.hide_duplicates := 0;
     END; 
     
     /*****  2  *****/
     /*-*/
     /* Retrieve the procedure Order using the cntl_rec id 
     /*-*/
     OPEN csr_cntl_rec;
    
	 FETCH csr_cntl_rec INTO rcd_cntl_rec;
     IF NOT csr_cntl_rec%NOTFOUND THEN
	 
	     /*****  3  *****/
         /*-*/
         /* delete the existing recipe if exists based on the old cntl_rec_Id
         /*-*/
         DELETE FROM RECPE_DTL WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
	     DELETE FROM RECPE_VAL WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
		 DELETE FROM RECPE_RESRCE WHERE cntl_rec_id = (SELECT cntl_rec_id FROM RECPE_HDR WHERE LTRIM(proc_order,'0') = (SELECT LTRIM(proc_order,'0') FROM CNTL_REC WHERE cntl_rec_id = par_cntl_Rec_Id));
	     DELETE FROM RECPE_HDR WHERE proc_order = LTRIM(rcd_cntl_rec.proc_order,'0');
	 
	     /*****  4  *****/
         /*-*/
         /* Insert HEADER record 
         /*-*/
     	 INSERT INTO RECPE_HDR
	     VALUES (rcd_cntl_rec.cntl_rec_id,
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
        
        /*****  5  *****/ 
        /*-*/
        /* Retrieve the BOM and RESRCE data using the cntl_rec id 
        /*-*/
        OPEN csr_recpe;
        LOOP
           FETCH csr_recpe INTO rcd_recpe;
           EXIT WHEN csr_recpe%NOTFOUND; 
 		   
		   /*-*/
		   /* check if a ratio adjustment is needed ie scale to parent or scale to bom
		   /*-*/
           var_ratio_scale := 1;  -- set default value to 1 incase there is no scale too .. of the parent 
           IF rcd_recpe.display_rule_x = 'SP' THEN
              
              /*-*/
              /*  28 Apr 2008 - JP added the next 2 if statements and the var_no_of_pans modification
              /* for calculating the scale to BOM/Parent of the parent material 
		      /* check if a ratio adjustment is needed on the parent - it could be a scale to parent or scale to bom
		      /*-*/
              var_ratio_scale := 1;
               IF rcd_recpe.parent_display_rule_x = 'SP' THEN
                   var_in_phase := rcd_recpe.parent_phase;
                   var_in_material_code := rcd_recpe.parent_material_code;
                   LOOP
                       var_result := get_next_level(LTRIM(rcd_cntl_rec.proc_order,'0'), var_in_phase, var_in_material_code, var_new_display_rule, var_new_matl_code, var_new_op, var_new_ph);
                       exit WHEN var_result = 0;
                       IF var_new_display_rule = 'SB' THEN
                           var_ratio_scale := var_ratio_scale * getScaleToBOM(LTRIM(rcd_cntl_rec.proc_order,'0'), var_new_op, var_new_ph, var_new_matl_code, rcd_cntl_rec.run_start_datime, var_no_of_pans, var_bom_qty);
                       ELSE -- must be SP
                           var_ratio_scale := var_ratio_scale * getScaleToParent(LTRIM(rcd_cntl_rec.proc_order,'0'), var_new_op, var_new_ph, var_no_of_pans);
                       END IF;
                       exit;
                       var_in_phase := var_new_ph;
                       var_in_material_code := var_new_matl_code;
                   END LOOP;
                   
                   var_ratio_scale := var_ratio_scale * getScaleToParent(LTRIM(rcd_cntl_rec.proc_order,'0'), rcd_recpe.parent_operation, rcd_recpe.parent_phase, var_no_of_pans);
               
               END IF;
               IF rcd_recpe.parent_display_rule_x = 'SB' THEN
                   var_ratio_scale := getScaleToBOM(LTRIM(rcd_cntl_rec.proc_order,'0'), rcd_recpe.parent_operation, rcd_recpe.parent_phase, rcd_recpe.parent_material_code, rcd_cntl_rec.run_start_datime, var_no_of_pans, var_bom_qty);
               END IF;
		       var_ratio := var_ratio_scale * getScaleToParent(LTRIM(rcd_cntl_rec.proc_order,'0'), rcd_recpe.opertn, rcd_recpe.phase, var_no_of_pans);
		       /*-*/
               /* to modify the pan count dive the parents ratio by the materials number of pans 
               /*-*/
               var_no_of_pans := var_no_of_pans / var_ratio_scale;
               --dbms_output.put_line('Ratio1=' || var_ratio || ' no of pans=' ||  var_no_of_pans || ' bom_qty=' || var_bom_qty);
           
           ELSIF rcd_recpe.display_rule_x = 'SB' THEN
               var_ratio := getScaleToBOM(LTRIM(rcd_cntl_rec.proc_order,'0'), rcd_recpe.opertn, rcd_recpe.phase, rcd_recpe.matl_code, rcd_cntl_rec.run_start_datime, var_no_of_pans, var_bom_qty);
           ELSE
               var_ratio := 1;
               var_no_of_pans := 1;  -- used in calculation of number of Pans against the resource header line
           END IF;
          
        
        
        
           /*-*/
           /**********************************************************************************/
           /*****  6  *****/
           /**********************************************************************************/
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
               /* this section will determine if there are more than 1 phantom (M)
               /* made within the current Operation
			   /* var_count will contain the number
               /* however this will be modified if there is an SRC within a phase
               /* defining hide duplicates
               /* this variable is then used when inserting the Resource header record
               /* if v_count is 1 then the Phantom plus pan qty will be adfded to the resource 
               /* header record 
			   /*-*/ 
               /* get the number of Phantoms in the operation */ 
				SELECT COUNT(*) INTO var_count
				  FROM CNTL_REC_BOM
			     WHERE opertn = rcd_recpe.opertn
				   AND LTRIM(proc_order,'0') = LTRIM(rcd_cntl_rec.proc_order,'0')
				   AND phantom = 'M'
				   AND LTRIM(matl_code,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
                   ORDER BY 1;	
				
                IF var_count > 1 THEN
                   /* if the result is more than 1 then
                   /* check if there is a hide duplicates src set */
                   var_hide_phantom_matl := '';
                   OPEN csr_get_phantoms_per_op;
                   LOOP
                  
                      FETCH csr_get_phantoms_per_op INTO rcd_get_phantoms_per_op;
                      EXIT WHEN csr_get_phantoms_per_op%NOTFOUND;
                      IF rcd_get_phantoms_per_op.mpi_tag = rcd_spcl_cndtn.hide_duplicates THEN
                          var_hide_phantom_matl := rcd_get_phantoms_per_op.matl_code;
                      ELSE
                          IF LENGTH(var_hide_phantom_matl) > 1 AND  var_hide_phantom_matl = rcd_get_phantoms_per_op.matl_code THEN
                              var_count := var_count - 1;
                          END IF;
                      END IF;
  
                   END LOOP;
                   CLOSE csr_get_phantoms_per_op;   
                END IF;	   
                /* the if statement above will adjust the var_count variable depending upon hide_duplicates mpi_tag
                 
                /*-*/
			    /* if var_count is greater than 1 it means that there are several made 
			    /* phantoms in this operation and so the pan qty should be 0 
			    /*-*/
			    rcd_pan_qty.pan_qty := 0;
			    rcd_pan_qty.matl_code := '';
			    rcd_pan_qty.matl_desc := '';
			    rcd_pan_qty.qty := 0;
				
                /*-*/
                /* Get the pan quantity and number of pans 
                /* checking if there is a HIDE_DUPLICATES flag 
                /* if there is the result gets the sum of Pans
                /*-*/  
				OPEN csr_pan_qty;
				FETCH csr_pan_qty INTO rcd_pan_qty;		
				    IF csr_pan_qty%NOTFOUND THEN
				        var_pan := 0;
				  	END IF;
				    
                    /*-*/
                    /* this function will return the pan siz and number of pans
                    /*-*/
                    var_success := getPanValues( rcd_recpe.proc_order,  rcd_recpe.opertn, rcd_spcl_cndtn.hide_duplicates, var_dup_pan_size, var_dup_no_of_pans);
                    IF var_success = 1 THEN
                        rcd_pan_qty.qty := var_dup_pan_size;
                        rcd_pan_qty.pan_qty := var_dup_no_of_pans;
                    END IF;
                
                    /*-*/
                    /* just make sure a resource record exists for this operatuion
                    /*-*/
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
								ROUND(DECODE(var_count, 1, DECODE(rcd_pan_qty.rescale, 'Y', var_no_of_pans, rcd_pan_qty.pan_qty),0),1),
								DECODE(var_count, 1, rcd_pan_qty.matl_code, ''),
								DECODE(var_count, 1, rcd_pan_qty.matl_desc, ''),
								DECODE(var_count, 1, DECODE(rcd_pan_qty.qty, NULL, 0,'', 0, rcd_pan_qty.qty), 0) * var_ratio);
                        
                        
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
           /**********************************************************************************/
           /**********************************************************************************/
           
		      
		   /*****  7  *****/
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
           IF (rcd_recpe.rnk > 1 AND rcd_recpe.rnk IS NOT NULL) THEN 
               rcd_recpe_dtl.matl_desc :=  ' Error: Multiple Parents!';
           END IF;
		   
           IF rcd_recpe.display_rule_x = 'SB' AND var_bom_qty <> 0 THEN
               --rcd_recpe_dtl.bom_qty := var_bom_qty;
               rcd_recpe_dtl.bom_qty := rcd_recpe.bom_qty * var_ratio;
           ELSIF rcd_recpe.display_rule_x = 'SP' THEN
               rcd_recpe_dtl.bom_qty := rcd_recpe.bom_qty * var_ratio;
           ELSE
		       rcd_recpe_dtl.bom_qty := rcd_recpe.bom_qty;
		   END IF;
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
                        NVL(rcd_recpe_dtl.uom,' '),
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
		     	
		/*****  8  *****/
        /*-*/
		/* Insert ALL records to be printed in BOLD for any MULTIPLE PHANTOMs
		/* within any 1 operation
        /* If HIDE_DUPLICATES are found then only 1 Phantom is printed		
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
                        phantom)
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
             
		/*****  9  *****/
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
		CLOSE csr_spcl_condition;
          
		/*****  10  *****/
        /*-*/
		/* update the recpe_val table with SRC codes 
		/*-*/
		Recipe_Conversion_Src.EXECUTE(LTRIM(rcd_cntl_rec.proc_order,'0'));
		/*-*/
        /* update the po difference table
        /*-*/ 
	    --Recipe_Difference.EXECUTE(LTRIM(rcd_cntl_rec.proc_order,'0'));
        
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
       
   /*-------------*/
   /* End routine */
   /*-------------*/
   END EXECUTE;
   
   
 
FUNCTION  get_Next_Level(i_proc_order IN VARCHAR2, 
                      i_parent_phase IN VARCHAR2, 
                      i_parent_matl_code IN VARCHAR2, 
                      o_display_rule OUT VARCHAR2, 
                      o_parent_matl_code OUT VARCHAR2, 
                      o_parent_opertn OUT VARCHAR2,
                      o_parent_phase OUT VARCHAR2) RETURN NUMBER
   IS
   
   /*-*/
   /* cursor definition
   /*-*/
   CURSOR csr_get_next_level
   IS
   SELECT --t01.*, 
           t02.parent_material_code,
           t02.parent_operation,
           t02.parent_phase,
           t02.parent_opertn_from,
           t02.parent_display_rule_x, t02.rnk
      FROM (SELECT LTRIM (t01.proc_order, '0') proc_order,
                   t01.cntl_rec_id,
                   t02.resrce_code,
                   DECODE (t04.resrc_text, NULL, 'No REF_RESOURCE table entry', t04.resrc_text) resrce_desc,
                   t03.opertn opertn,
                   t03.phase,
                   t03.seq,
                   t03.phantom,
                   LTRIM (t03.matl_code, '0') matl_code,
                   t03.matl_desc,
                   TO_CHAR (TO_NUMBER (DECODE (t03.pan_size_flag, 'Y', t03.pan_size, t03.qty)),'999999999990.999990') bom_qty,
                   t03.uom uom,
                   t03.opertn_from,
                   Recipe_Disp_Hide (t01.proc_order, t03.opertn, t03.phase, t03.matl_code) display,
                   CASE
                       WHEN spcl_cndtn_name = 'SCALE_TO_BOM' THEN 'SB'
                       WHEN spcl_cndtn_name = 'SCALE_TO_PARENT' THEN 'SP'
                       ELSE NULL
                   END display_rule_x --,
              FROM cntl_rec t01, 
                   cntl_rec_resrce t02, 
                   cntl_rec_bom t03, 
                   bds_prodctn_resrc_en t04, --ref_resource t04,
                   (SELECT DISTINCT proc_order,
                           opertn AS opertn,
                           t01.mpi_tag,
                           spcl_cndtn_name
                      FROM cntl_rec_mpi_val t01, recpe_spcl_cndtn t02
                     WHERE t01.mpi_tag = t02.mpi_tag
                       AND (spcl_cndtn_name = 'SCALE_TO_BOM' OR spcl_cndtn_name = 'SCALE_TO_PARENT' )) t08
             WHERE t01.proc_order = t02.proc_order
               AND t01.proc_order = t03.proc_order
               AND t02.opertn = t03.opertn
               AND t02.resrce_code = t04.resrc_code(+)
               AND t02.plant = t04.resrc_plant_code(+)
               AND t03.proc_order = t08.proc_order(+)
               AND t03.opertn = t08.opertn(+)
               AND LTRIM(t03.MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
               AND (t03.phantom = 'U' OR t03.phantom IS NULL)   -- U = Used (from atlas)
             ) t01,
             (-- this query is used to find if a SB or SP exists for the parent
             SELECT DISTINCT t01.proc_order, 
                    t01.matl_code parent_material_code,
                    t01.opertn parent_operation, 
                    t01.phase parent_phase, 
                    t01.opertn_from parent_opertn_from,
                    CASE 
                        WHEN spcl_cndtn_name = 'SCALE_TO_BOM' THEN 'SB'
                        WHEN spcl_cndtn_name = 'SCALE_TO_PARENT' THEN 'SP'
                        ELSE ''
                    END AS parent_display_rule_x,
                    rank() OVER (PARTITION BY t01.proc_order,t01.matl_code
                                      ORDER BY spcl_cndtn_name ASC) rnk
               FROM cntl_rec_bom t01,
                    cntl_rec_mpi_val t02, 
                    recpe_spcl_cndtn t03
              WHERE t01.proc_order = t02.proc_order
                AND t01.opertn = t02.opertn
                AND t02.mpi_tag = t03.mpi_tag
                AND (spcl_cndtn_name = 'SCALE_TO_BOM' OR spcl_cndtn_name = 'SCALE_TO_PARENT') 
                AND opertn_from IS NOT NULL  
                ) t02
       WHERE t01.proc_order = ltrim(t02.proc_order(+),'0')
         AND t01.phase = t02.parent_opertn_from(+)
         AND display = 'D'
         AND phantom IN ('M','U')
         AND rnk = 1 
         AND t01.proc_order = LTRIM (i_proc_order, '0') 
         AND t01.phase = i_parent_phase 
         AND matl_code = i_parent_matl_code;
       
       
       rcd_get_next_level csr_get_next_level%ROWTYPE;
    
       var_return NUMBER;
   
   BEGIN
       var_return := 0;
       o_display_rule := '';
       o_parent_matl_code := '';
       o_parent_phase := '';
       o_parent_opertn := '';
       OPEN csr_get_next_level;
	   LOOP
		    FETCH csr_get_next_level INTO rcd_get_next_level;
		    IF NOT csr_get_next_level%NOTFOUND THEN
                var_return := 1;
                o_display_rule := rcd_get_next_level.parent_display_rule_x;
                o_parent_matl_code := rcd_get_next_level.parent_material_code;
                o_parent_phase := rcd_get_next_level.parent_phase;
                o_parent_opertn := rcd_get_next_level.parent_operation;
            END IF; 
            exit;
       END LOOP;
	   CLOSE csr_get_next_level;  
       
       RETURN var_return;
       
   END;
        
   
   
END Recipe_Conversion;
/


DROP PUBLIC SYNONYM RECIPE_CONVERSION;

CREATE PUBLIC SYNONYM RECIPE_CONVERSION FOR MANU_APP.RECIPE_CONVERSION;


GRANT EXECUTE ON MANU_APP.RECIPE_CONVERSION TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RECIPE_CONVERSION TO BDS_APP;

GRANT EXECUTE ON MANU_APP.RECIPE_CONVERSION TO BTHSUPPORT;

