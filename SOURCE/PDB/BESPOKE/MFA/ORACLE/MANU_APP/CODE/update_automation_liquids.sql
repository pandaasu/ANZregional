DROP PROCEDURE MANU_APP.UPDATE_AUTOMATION_LIQUIDS;

CREATE OR REPLACE PROCEDURE MANU_APP.Update_Automation_Liquids 


IS

 /*********************************************
  This procedure will run every 30minutes to convert Proc Order 
  data into a horizontal structure and save in AUTOMATION_Kitchen table
 
  Input - Recipe_VW of each Proc_Order this is used to re-constitute the Phase
          numbering used in the old MPI system
  
  Output - records in Automation_Kitchen corresponding to the
         original Phase sections of the recipe.
  
  The Headers within the RECIPE_VW are used to define new CYCLES (PHASES)

  
  J.Phillipson 23 Oct 2004 
  J Phillipson 07-May-2007  Changed reference to cntl_rec to cntl_rec_vw - disables validation pos
  R Carneiro 12-May-2008   Changed reference to cntl_rec_resource to cntl_resource_vw
  *********************************************/
  
   DELETE_PERIOD     CONSTANT NUMBER := 1;
   CHECK_BACK        CONSTANT NUMBER := 1;
   CHECK_FORWARD     CONSTANT NUMBER := 3;
   NAME              CONSTANT VARCHAR2(100) := 'UPDATE_AUTOMATION_LIQUIDS ';
  
   vsuccess          NUMBER;
   vcount            NUMBER;
   vproc_order       VARCHAR2(12);
   vcycle            NUMBER;
   vzero             NUMBER;
 
   
   /* declare package cursor specification */
   CURSOR c1 IS 
   SELECT LTRIM(c.proc_order,'0') FROM CNTL_REC_VW c, cntl_rec_resource_vw r
   --WHERE LTRIM(c.proc_order,'0') = '1001005' 
     WHERE SCHED_START_DATIME > SYSDATE - CHECK_BACK
      AND SCHED_START_DATIME < SYSDATE + CHECK_FORWARD
      AND teco_status = 'NO'
      AND c.proc_order = r.proc_order
      AND r.resource_code IN ('MICRO052','LIQDS051')
      AND ltrim(c.proc_order,'0') NOT IN (SELECT proc_order FROM automation_liquid);
      
         
  
   CURSOR c2 IS
   SELECT v.*,   LTRIM(c.MATERIAL,'0') matl_code
   FROM recipe_vw v,CNTL_REC_VW c
          WHERE TO_NUMBER(v.proc_order) = TO_NUMBER(c.proc_order)
          AND v.proc_order = vproc_order
          AND mpi_type IN ('M','V','H') 
          AND UPPER(v.description) NOT LIKE 'INSTRUCTION%'
          AND UPPER(v.description) NOT LIKE 'NOTE%'
          AND UPPER(v.description) NOT LIKE 'SPECIAL%'
          ORDER BY 1,2,3,4;
          
   
     /*****
     Row types 
     ******/    
     rcd_rec c2%ROWTYPE;
     rcd_aut AUTOMATION_LIQUID%ROWTYPE;
   
   
     /*********************************************
     RAISE email notification OF error
     **********************************************/
     PROCEDURE raiseNotification(message IN VARCHAR2)
     IS
     
         vmessage VARCHAR2(4000);
         
     BEGIN
          vmessage := message;
          Mailout(vmessage);
     EXCEPTION
         WHEN OTHERS THEN
         vmessage := message;
     END;
     
     
     -- Insert record into Automation_Kitchen 
     PROCEDURE InsertRecord
     IS
     vNAME             CONSTANT VARCHAR2(20) := 'InsertRecord ';
     BEGIN
         
         
         -- insert record before going to next 
         INSERT INTO AUTOMATION_LIQUID
             VALUES (rcd_aut.proc_order,
             rcd_aut.OPERATION,
             rcd_aut.PHASE,
             rcd_aut.SEQ,
             trim(rcd_aut.BOX_NO)
             );
             COMMIT;
         --DBMS_OUTPUT.PUT_LINE('A=' || rcd_aut.proc_order || '-' ||  rcd_aut.OPERATION ||'-'|| rcd_aut.PHASE ||'-' || rcd_aut.SEQ);
             
     EXCEPTION
         WHEN OTHERS THEN
	   
       		--DBMS_OUTPUT.PUT_LINE('Automation_Liquid InsertRecord with Proc Order No. ' || vproc_order || ' op=' || rcd_aut.operation || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));
			-- rollback the transaction
			ROLLBACK;
			
			--Raise an error
            raiseNotification(NAME || CHR(13) || VNAME || CHR(13) || ' with Proc Order No. ' || vproc_order || CHR(13) || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512)); 
     END;
     
     
    
    
    
   
BEGIN
    vcount := 1;
    vzero := 0;
    OPEN c1;
    LOOP
       FETCH c1 INTO vproc_order;
       EXIT WHEN c1%NOTFOUND;
           -- if record exists delete first 
           DELETE FROM AUTOMATION_LIQUID
           WHERE proc_order = vproc_order;
            
           rcd_aut.proc_order := vproc_order;
           
           vcycle := 5;
           OPEN c2;
           LOOP 
                FETCH c2 INTO rcd_rec;
                EXIT WHEN c2%NOTFOUND;
                --  DBMS_OUTPUT.PUT_LINE('Record -' || rcd_rec.mpi_type || '-' || rcd_rec.description || '-' || rcd_rec.tag || ' headerfound=' || vheaderfound);
                rcd_aut.operation := rcd_rec.operation;
                rcd_aut.phase := rcd_rec.phase;
                rcd_aut.seq := rcd_rec.seq;
                IF rcd_rec.seq = 0 THEN
                   rcd_aut.seq := vzero;
                   vzero := vzero + 1;
                ELSE
                    vzero := 0;
                END IF;
                IF rcd_rec.mpi_type = 'H' AND rcd_rec.description NOT LIKE 'Instr%' THEN
                    
                    IF SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description),1) = '0' THEN
                        rcd_aut.BOX_NO := SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description)-2,3);
                    ELSE
                        rcd_aut.BOX_NO := TO_CHAR(vcycle);
                        vcycle := vcycle + 1;
                    END IF;
                END IF;
                vcount := vcount + 1;
                 IF LENGTH(rcd_aut.operation) > 0 AND rcd_aut.BOX_NO <> '0' THEN
                    InsertRecord;
                END IF;
           END LOOP;  
           
           
           CLOSE c2;      
    END LOOP;
    CLOSE c1;
    vsuccess := vcount;
    DBMS_OUTPUT.PUT_LINE('Automation_liquid; Completed Successfully with - ' || vcount || ' records' );
   
    
    /******************************************
    Delete old recoirds anything with teco status set to yes
   
    *******************************************/
    DELETE FROM AUTOMATION_LIQUID 
    WHERE proc_order IN (SELECT DISTINCT A.proc_order 
                    FROM AUTOMATION_LIQUID A, CNTL_REC C
                    WHERE A.PROC_ORDER = LTRIM(C.PROC_ORDER,'0')
                    AND C.TECO_STATUS = 'YES'); 
                    --AND c.run_end_datime < SYSDATE - DELETE_PERIOD);
   dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from AUTOMATION_LIQUID');
   
   
   
EXCEPTION

    WHEN OTHERS THEN
	   
       		DBMS_OUTPUT.PUT_LINE('Automation_Liquid  with Proc Order No. ' || vproc_order || ' op=' || rcd_aut.operation || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));
			
			-- rollback the transaction
			ROLLBACK;
			
			--Raise an error 
         	raiseNotification(NAME || CHR(13) || 'Main Procedure with Proc Order No. ' || vproc_order || CHR(13) || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));
            
END;
/


DROP PUBLIC SYNONYM UPDATE_AUTOMATION_LIQUIDS;

CREATE PUBLIC SYNONYM UPDATE_AUTOMATION_LIQUIDS FOR MANU_APP.UPDATE_AUTOMATION_LIQUIDS;


