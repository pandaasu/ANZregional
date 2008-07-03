CREATE OR REPLACE PACKAGE MANU_APP.eRECIPE AS
/******************************************************************************
   NAME:       eRECIPE
   PURPOSE:    This package will contain all the queries of data
               that is required to display the FRR (factory recipe report)
               in a web page.  Ensure any changes are applied to 
               Ballarat/Scoresby/Wyong/Wodonga/Bathurst/Wanganui.
               http://erecipe.mca.ap.mars/   http://dev.erecipe.mca.ap.mars/
               http://erecipe.sco.ap.mars/   http://dev.erecipe.sco.ap.mars/
               http://erecipe.wod.ap.mars/   http://dev.erecipe.wod.ap.mars/
               http://erecipe.bth.ap.mars/   http://dev.erecipe.bth.ap.mars/
               http://erecipe.wgi.ap.mars/   http://dev.erecipe.wgi.ap.mars/
               http://erecipe.mfa.ap.mars/   http://dev.erecipe.mfa.ap.mars/
               

   REVISIONS:
   Ver        Date          Author              Description
   ---------  ------------  ------------------  ------------------------------------
   1.0        18-Jun-2007   Scott R. Harding   Created this package body.
   1.1        03-Oct-2007   Scott R. Harding   Added user_role function
   1.2        15-Oct-2007   Scott R. Harding   Added regional_code (old material code)
   1.3        27-May-2008   Scott R. Harding   Added get_plants to support multi-plant sites. eg. WOD.
   1.4        27-May-2008   Scott R. Harding   Added material and run datime info to get_process_order
******************************************************************************/


  /***************************************************************************/
  /* PROCEDURE:    USER_ROLE
  /* PURPOSE:      User_Role will determine if the current user, for the 
  /*               eRecipe application has access
  /*              
  /* INPUTS:       i_userid       string      8   5+3- 'HARDISCO'
  /* RETURN:
  /*               NO acess to this application - returns 0 
  /*               general user access - PR_USER - return 1 - read only access
  /*               full access - PR_MAINT - return 2 
  /***********************************************************/
  FUNCTION USER_ROLE(i_userid IN VARCHAR2)  RETURN NUMBER;   
  
  /***************************************************************************/
  /* PROCEDURE:   GET_PLANT
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           512          oracle error ORA-20000 ....                                                 
  /*              cur_OUT           dataset returned
  /*     NOTE: OUTPUT Cursor MUST be called cur_OUT for use in .NET Enterprise library.          
  /* DATASET:
  /*         PLANT_CODE           string            4         AU10
  /*        PLANT_NAME            string            37        AU10 : MFANZ Wyong  
  /**************************************************************************/
      PROCEDURE GET_PLANT(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR);
                      
  /***************************************************************************/
  /* PROCEDURE:   GET_PROCESS_ORDER
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           512          oracle error ORA-20000 ....                                                 
  /*              cur_OUT           dataset returned
  /*              i_plant_code      string           4            eg AU40
  /*              i_sort_order      string                       eg process_order
  /*     NOTE: OUTPUT Cursor MUST be called cur_OUT for use in .NET Enterprise library.          
  /* DATASET:
  /*         PROCESS_ORDER           string            12         1085960
  /*        DESCRIPTION               string             40         Raws MALT Fs HagBag
  /*        RUN_START_DATIME          string             40         Tue, 02:35:17PM 27 May 2008
  /*        MATERIAL_CODE          string             18         10016633
  /*        MATERIAL_DESC          string             40         Mars bar 60g  
  /**************************************************************************/
      PROCEDURE GET_PROCESS_ORDER(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_plant_code IN VARCHAR2 DEFAULT 'BLANK',
                       i_sort_order IN VARCHAR2 DEFAULT 'process_order',
                       cur_OUT IN OUT Re_Timing_Common.RETURN_REF_CURSOR);
                       

/***************************************************************************/
  /* PROCEDURE:   GET_RESOURCE
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           512          oracle error ORA-20000 ....                                                 
  /*              cur_OUT           dataset returned
  /*              i_plant_code      string           4            eg AU40  '
  /*     NOTE: OUTPUT Cursor MUST be called cur_OUT for use in .NET Enterprise library.          
  /* DATASET:
  /*         PROCESS_ORDER           string            12         1085960
  /*        DESCRIPTION               string             40         Raws MALT Fs HagBag  
  /**************************************************************************/
      PROCEDURE GET_RESOURCE(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      i_plant_code IN VARCHAR2 DEFAULT 'BLANK',
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR);
                      
                                             
  /***************************************************************************/
  /* PROCEDURE:   GET_HEADER
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           512          oracle error ORA-20000 ....                                                 
  /*              cur_OUT           dataset returned
  /*              i_proc_order     string           8            eg 1086100
  /*     NOTE: OUTPUT Cursor MUST be called cur_OUT for use in .NET Enterprise library.          
  /* DATASET:
  /*         COLUMN1           string            12         eg Proc Order
  /*         COLUMN2           string            12         eg Material
  /*         COLUMN3           string            12         eg Description
  /*         COLUMN4           string            12         eg Blank
  /**************************************************************************/
      PROCEDURE GET_HEADER(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      i_proc_order IN VARCHAR2 DEFAULT 'BLANK',
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR);
                      

/***************************************************************************/
  /* PROCEDURE:   GET_BODY
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           512          oracle error ORA-20000 ....                                                 
  /*              cur_OUT           dataset returned
  /*              i_proc_order     string           8            eg 1086100
  /*     NOTE: OUTPUT Cursor MUST be called cur_OUT for use in .NET Enterprise library.          
  /* DATASET:
  /*         description          string            n        eg Proc Order
  /*         qty                  string            n         eg Material
  /*         uom                  string            n         eg Description
  /*         detailtype           string            n         eg H, HH, I, M, B or S
  /*         resource_code        string            n         eg BRINE001
  /*         regional_code        string            n         eg 13301
  /**************************************************************************/
      PROCEDURE GET_BODY(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      i_proc_order IN VARCHAR2 DEFAULT 'BLANK',
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR);
                                             

/***************************************************************************/
  /* PROCEDURE:   GET_FOOTER
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           512          oracle error ORA-20000 ....                                                 
  /*              cur_OUT           dataset returned
  /*     NOTE: OUTPUT Cursor MUST be called cur_OUT for use in .NET Enterprise library.          
  /* DATASET:
  /*         FOOTER           string                     eg Printed on: Sat, 04 Aug 2007 00:08:AM
  /**************************************************************************/
      PROCEDURE GET_FOOTER(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR);                     
 
END eRECIPE;
/


CREATE OR REPLACE PACKAGE BODY MANU_APP.eRECIPE AS

  /*-*/
  /* variables
  /*-*/
  o_result NUMBER;
  o_result_msg VARCHAR2(2000);
  
  
    FUNCTION USER_ROLE(i_userid IN VARCHAR2)  RETURN NUMBER IS
  
      v_return NUMBER;
      v_work VARCHAR2(20);
		
	  CURSOR cur_role IS
      SELECT granted_role FROM DBA_ROLE_PRIVS
	   WHERE grantee = UPPER(i_userid)
         AND granted_role IN ('PR_USER','PR_MAINT')
	   ORDER BY 1 ASC;
		
  BEGIN
  
  	  v_return := 0;  -- default 
		
      OPEN cur_role;
      LOOP
          FETCH cur_role INTO v_work;
          EXIT WHEN cur_role%NOTFOUND;
			 v_work := trim(UPPER(v_work));
			 IF v_work = 'PR_MAINT' THEN
			     v_return := 2;
				 EXIT;
			 END IF;
		     IF v_work = 'PR_USER' THEN
			      v_return := 1;
				  EXIT;
			 END IF;
			 v_return := 0;				
      END LOOP;
      CLOSE cur_role;
      RETURN v_return;
		
  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN 0;
  
  END USER_ROLE;
  
  PROCEDURE GET_PLANT(o_result OUT NUMBER, 
					  o_result_msg OUT VARCHAR2,
					  cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
								  
   BEGIN
     o_result  := Constants.SUCCESS;
     o_result_msg := 'Success';
	  
	    OPEN cur_OUT FOR 
		 SELECT TRIM(c.PLANT) plant_code,
		        TRIM(c.plant) || ' : ' || TRIM(c.PLANT_NAME) AS plant_name
         FROM REF_PLANT c
        WHERE c.plant IN (SELECT plant FROM CNTL_REC WHERE teco_stat = 'NO')
		  ORDER BY 1;
										
  EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'ERECIPE - GET_PLANT procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;	
  END GET_PLANT;

  PROCEDURE GET_PROCESS_ORDER(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_plant_code IN VARCHAR2 DEFAULT 'BLANK',
                       i_sort_order IN VARCHAR2 DEFAULT 'process_order',
                       cur_OUT IN OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
                       
  BEGIN
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
      
          OPEN cur_OUT FOR 
            SELECT   DISTINCT LTRIM(t01.proc_order,'0') AS process_order, 
                     RPAD(LTRIM(t01.proc_order,'0'),8,' ') || '[' || LPAD(LTRIM(t01.material,'0'),8,' ') || '] ' || RPAD(t01.material_text,40,' ') || ' ' || LPAD(t01.quantity,6,' ') || ' ' || RPAD(t01.uom,4,' ') || ' ' || TO_CHAR(t01.run_start_datime,'hh12:miAM dd-Mon-yyyy') AS description,
                     TO_CHAR(t01.run_start_datime,'yyyymmddhh24miss') AS run_start_datime,
                     t01.material AS material_code,
                     t01.material_text as material_desc
            FROM     bds_recipe_header t01
            WHERE    t01.teco_status = 'NO'
                     AND t01.plant_code = i_plant_code
                     AND t01.run_start_datime BETWEEN TRUNC(SYSDATE) - 5 AND TRUNC(SYSDATE) + 20
                     AND SUBSTR(t01.proc_order,1,1) BETWEEN '0' AND '9'
            ORDER BY 
                DECODE(i_sort_order, 'process_order',     process_order,
                                     'material_code',     material_code,
                                     'material_desc',     material_desc,
                                     'run_start_datime',  run_start_datime,
                                                          process_order);

  EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'ERECIPE - GET_PROCESS_ORDER procedure with plant code ' || i_plant_code || ' and sort order ' || i_sort_order || ' failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;
  END;
  


PROCEDURE GET_RESOURCE(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      i_plant_code IN VARCHAR2 DEFAULT 'BLANK',
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
  BEGIN
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
      
      OPEN cur_OUT FOR 
             SELECT   resrc_code, ('[' || resrc_code || '] ' || resrc_text) AS resrc_text
             FROM     bds_prodctn_resrc_en
             WHERE    resrc_plant_code = i_plant_code
             AND      resrc_code <> 'DURATION'
             /* -- to limit resources to only those used in an active recipe
             AND resrc_code IN (SELECT DISTINCT resource_code
                              FROM bds_recipe_header t01,
                                   bds_recipe_resource t02
                             WHERE t01.proc_order = t02.proc_order
                               AND t01.teco_status = 'NO'
                               AND t01.plant_code = i_plant_code
                               --AND t01.run_start_datime BETWEEN SYSDATE - 3 AND SYSDATE + 4
                               AND t01.run_start_datime BETWEEN SYSDATE - 6 AND SYSDATE + 7
                               AND SUBSTR(t01.proc_order,1,1) BETWEEN '0' AND '9') 
             */
             ORDER BY resrc_code ASC;
       
  EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'ERECIPE - GET_RESOURCE procedure with process order ' || trim(i_plant_code) || ' failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;
  END;


    
  /***************************************************************************/
  /* this procedure will return a recordset of all recipe rows for a define 
  /* process order.
  /***************************************************************************/
    PROCEDURE GET_HEADER(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      i_proc_order IN VARCHAR2 DEFAULT 'BLANK',
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
                      
BEGIN
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
      
         IF (i_proc_order <> 'BLANK' AND i_proc_order IS NOT NULL) THEN
         OPEN cur_OUT FOR
         
             SELECT 'Proc Order' AS column1, 'Material' AS Column2, 'Description' AS column3, 'Old Material' AS column4
             FROM dual
             UNION ALL
             SELECT t01.proc_order, t01.matl_code, t01.matl_desc, t01.old_matl_code
             FROM recpe_hdr t01
             WHERE t01.proc_order = LTRIM(i_proc_order,'0')
             UNION ALL
             SELECT 'Start time: ', TO_CHAR(run_start_datime,'Dy, DD Mon YYYY HH24:MM:PM'), 'Quantity: ', TO_CHAR(Qty) || ' ' || uom
             FROM recpe_hdr t01
             WHERE t01.proc_order = LTRIM(i_proc_order,'0')
             UNION ALL
             SELECT DECODE(t02.units_per_case, NULL,NULL,'Units/case: '), TO_CHAR(t02.units_per_case), DECODE(t02.units_per_case, NULL,NULL,'Cartons/Pallet: '), TO_CHAR(t02.crtns_per_pllt)
             FROM recpe_hdr t01, MATL_PLT_VW t02
             WHERE t01.MATL_CODE = t02.MATL_CODE(+)
             AND t01.proc_order = LTRIM(i_proc_order,'0')
             UNION ALL
             SELECT 'Ctrl Recipe Id: ', TO_CHAR(t02.cntl_rec_id), 'Plant: ', plant_code
             FROM recpe_hdr t01, bds_recipe_header t02
             WHERE t01.proc_order = LTRIM(t02.proc_order,'0')
             AND t01.proc_order = LTRIM(i_proc_order,'0')
             UNION ALL
             SELECT DECODE(tun_code,NULL,NULL,'TUN Code: '), tun_code, DECODE(t03.shelf_life, NULL, NULL,'Shelf Life: '), TO_CHAR(t03.shelf_life)
             FROM recpe_hdr t01, MATL_PLT_VW t02, matl_vw t03
             WHERE t01.MATL_CODE = t02.MATL_CODE(+)
             AND t01.MATL_CODE = t03.MATL_CODE(+)
             AND t01.proc_order = LTRIM(i_proc_order,'0');
        END IF; 
       
  EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'ERECIPE - GET_HEADER procedure with process order ' || trim(i_proc_order) || ' failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;
  END;                      
                      
                      
                             
  /***************************************************************************/
  /* this procedure will return a recordset of all recipe rows for a define 
  /* process order.
  /* detailtype = H      -      Operation header
  /*              HH     -      Phase header
  /*              M      -      Material line
  /*              S      -      SRC code line
  /*              I      -      Instruction line
  /*              B      -      Bold
  /***************************************************************************/
  PROCEDURE GET_BODY(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      i_proc_order IN VARCHAR2 DEFAULT 'BLANK',
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
                      
BEGIN
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
      
          OPEN cur_OUT FOR 
             SELECT   t01.description, qty, DECODE(uom,'?','',uom) uom, detailtype, resource_code, t01.old_matl_code as regional_code
             FROM     recpe_vw t01, bds_recipe_resource t02
             WHERE    t01.proc_order = LTRIM(t02.proc_order,'0')
                      AND t01.opertn = t02.operation
                      AND t01.proc_order = i_proc_order
             ORDER BY opertn ASC, phase ASC, seq ASC, dummy ASC;
       
  EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'ERECIPE - GET_BODY procedure with process order ' || trim(i_proc_order) || ' failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;
  END;                      
                      
  

  PROCEDURE GET_FOOTER(o_result OUT NUMBER, 
                      o_result_msg OUT VARCHAR2,
                      cur_OUT OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
  BEGIN
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
      
          OPEN cur_OUT FOR 
             SELECT 'Printed on: ' || TO_CHAR(SYSDATE,'Dy, DD Mon YYYY HH24:Mi:PM') AS footer FROM dual
             UNION ALL
             SELECT 'This document and the information contained in it are confidential and are the property of Mars Australia and Mars New Zealand.  Contents may not '
             || 'in any way be disclosed, copied or used by anyone unless expressly authorised by Mars Australia and Mars New Zealand.  The document should always '
             || 'be kept in a secure place, and should be destroyed or returned to Mars Australia or Mars New Zealand when it is no longer needed.' AS footer FROM dual
             ;
       
  EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'ERECIPE - GET_FOOTER procedure with process order failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;
  END;                         
                                                                                                                                     
END eRECIPE;
/

CREATE OR REPLACE PUBLIC SYNONYM ERECIPE FOR MANU_APP.ERECIPE;


GRANT EXECUTE ON MANU_APP.ERECIPE TO ERECIPE_WEB;

