CREATE OR REPLACE PROCEDURE MANU_APP.Update_Automation_Tower 



IS

  /*********************************************
  This procedure will run every 30minutes to convert Proc Order 
  data into a horizontal structure and save in AUTOMATION_TOWER table
 
  Input - Recipe_VW of each Proc_Order this is used to re-constitute the Phase
          numbering used in the old MPI system
  
  Output - records in Automation_Tower corresponding to the
         original Phase sections of the recipe.
  
  The Headers within the RECIPE_VW are used to define new CYCLES (PHASES)

  
  J.Phillipson 23 Oct 2004 
  J Phillipson 07-May-2007  Changed reference to cntl_rec to cntl_rec_vw - disables validation pos
  R Carneiro 12-May-2008   Changed reference to cntl_rec_resource to cntl_resource_vw
  *********************************************/
   
   DELETE_PERIOD     CONSTANT NUMBER := 1;
   CHECK_BACK        CONSTANT NUMBER := 1;
   CHECK_FORWARD     CONSTANT NUMBER := 3;
  
   NAME              CONSTANT VARCHAR2(100) := 'UPDATE_AUTOMATION_TOWER ';
  
  
   vmessage     VARCHAR2(2000);
   vsuccess     NUMBER;
   vcount       NUMBER;
   vproc_order  VARCHAR2(12);
   vheaderfound NUMBER; 
   vcycle       NUMBER;
   CYCLE_NO     NUMBER;
   vvalue       NUMBER;
   voutput      VARCHAR2(40);
   
   
   -- added JP 13 Apr 2005
   vSluryWater BOOLEAN    DEFAULT  FALSE;
   
   /* declare package cursor specification 
   This will identify all Proc_Orders that 
   need to be converted to a AUTOMATION_TOWER record*/
   CURSOR c1 IS 
   SELECT LTRIM(c.proc_order,'0') FROM CNTL_REC_VW c, CNTL_REC_RESOURCE_vw r
       WHERE SCHED_START_DATIME > SYSDATE - CHECK_BACK
       AND SCHED_START_DATIME < SYSDATE + CHECK_FORWARD
       AND teco_status = 'NO'
       AND c.proc_order = r.proc_order
       AND r.resource_code = 'MXSIM037'
       --AND LTRIM(c.proc_order,'0') IN ('1009861')  -- test only 
       AND LTRIM(c.proc_order,'0') NOT IN (   
       SELECT DISTINCT A.proc_order FROM AUTOMATION_KITCHEN A, CNTL_REC c
       WHERE LTRIM(c.PROC_ORDER,'0') = A.PROC_ORDER AND c.VERSION > 1 AND teco_status = 'NO'
       );
     
         
  
   CURSOR c2 IS
   SELECT v.*,K.*, r.resource_code, wc.work_ctr_code, LTRIM(c.MATERIAL,'0') matl_code
      FROM recipe_vw v, CNTL_REC_RESOURCE_VW r, work_ctr_vw wc, CNTL_REC_VW c, SITE_AUTOMATION_TOWER K
      WHERE TO_NUMBER(v.proc_order) = TO_NUMBER(r.proc_order)
      AND v.code = K.tag_or_num(+)
      AND TO_NUMBER(c.proc_order) = TO_NUMBER(r.proc_order)
      AND r.RESOURCE_CODE = wc.RESOURCE_CODE
      AND UPPER(v.description) NOT LIKE 'INSTRUCTION%'
      AND UPPER(v.description) NOT LIKE 'NOTE%'
      AND  v.proc_order = vproc_order
      AND mpi_type IN ('M','V','H') 
      AND r.resource_code = 'MXSIM037'
      ORDER BY 1,2,3,4;
          
     rcd_rec c2%ROWTYPE;
     rcd_aut AUTOMATION_TOWER%ROWTYPE;
     
     
    
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
     
     
     PROCEDURE InsertRecord
     IS
     vNAME             CONSTANT VARCHAR2(20) := 'InsertRecord ';
     BEGIN
         -- insert record before going to next 
         INSERT INTO AUTOMATION_TOWER
             VALUES (rcd_aut.proc_order,
             rcd_aut.BATCH,
             rcd_aut.matl_code,
             rcd_aut.mixtime,
             rcd_aut.ramptype,
             rcd_aut.buf_dischs,
             rcd_aut.liquids,
             rcd_aut.sugar,
             rcd_aut.powders,
             rcd_aut.tomato,
             rcd_aut.veges,
             rcd_aut.water,
             rcd_aut.vegwater,
             rcd_aut.onion_dehy,
             rcd_aut.r_capsicum,
             rcd_aut.g_capsicum,
             rcd_aut.jalapeno,
             rcd_aut.dryherb,
             rcd_aut.temp_sp1,
             rcd_aut.temp_sp2,
             rcd_aut.whitebase,
             rcd_aut.pallecon,
             rcd_aut.acid,
             rcd_aut.whitebase2,
             rcd_aut.pallecon2,
             rcd_aut.acid2,
             rcd_aut.speed1,
             rcd_aut.speed2,
             rcd_aut.speed3,
             rcd_aut.speed4,
             rcd_aut.spd_chng1,
             rcd_aut.spd_chng2,
             rcd_aut.fill_sp,
             rcd_aut.buff_ag,
             rcd_aut.buff_agspd,
             rcd_aut.use_slry,
             rcd_aut.slry_watr,
             rcd_aut.slry_agspd,
             rcd_aut.slry_spray,
             rcd_aut.trans_watr,
             rcd_aut.user1,
             rcd_aut.user2,
             rcd_aut.user3,
             rcd_aut.user4
             );
           
             --DBMS_OUTPUT.PUT_LINE('save cycle ' || rcd_aut.proc_order);
             COMMIT;
             
     EXCEPTION
         WHEN OTHERS THEN
			-- rollback the transaction
			ROLLBACK;
			--Raise an error
            raiseNotification(NAME || VNAME || ' with Proc Order No. ' || vproc_order || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512)); 
     END;
     
     
     
    /****************************************
     Check if a value is a number
     *****************************************/
     FUNCTION isNumeric(text IN VARCHAR2)
             RETURN NUMBER
     IS
         v_val NUMBER;
     BEGIN
         v_val := TO_NUMBER(text);
         RETURN 1;
     EXCEPTION
        WHEN OTHERS THEN
        RETURN 0;
     END;
      
     
    FUNCTION CLEAR_RCD RETURN NUMBER
    IS
       vsusccess NUMBER;
       /* reset all vriables */
    BEGIN
        rcd_aut.BATCH := '';
        rcd_aut.BATCH := 10;
        rcd_aut.matl_code := '';
        rcd_aut.mixtime := 0;
        rcd_aut.ramptype := '';
        rcd_aut.buf_dischs := '';
        rcd_aut.liquids := '';
        rcd_aut.sugar := 0;
        rcd_aut.powders := '';
        rcd_aut.tomato := 0;
        rcd_aut.veges := 0;
        rcd_aut.water := 0;
        rcd_aut.vegwater := '';
        rcd_aut.onion_dehy := '';
        rcd_aut.r_capsicum := '';
        rcd_aut.g_capsicum := '';
        rcd_aut.jalapeno := '';
        rcd_aut.dryherb := '';
        rcd_aut.temp_sp1 := '';
        rcd_aut.temp_sp2 := '';
        rcd_aut.whitebase := '';
        rcd_aut.pallecon := '';
        rcd_aut.whitebase2 := '';
        rcd_aut.pallecon2 := '';
        rcd_aut.acid2 := '';
        rcd_aut.speed1 := '';
        rcd_aut.speed2 := '';
        rcd_aut.speed3 := '';
        rcd_aut.speed4 := '';
        rcd_aut.spd_chng1 := '';
        rcd_aut.spd_chng2 := '';
        rcd_aut.fill_sp := '';
        rcd_aut.buff_ag := 0;
        rcd_aut.buff_agspd := '';
        rcd_aut.use_slry := 0;
        rcd_aut.slry_watr := '';
        rcd_aut.slry_agspd := '';
        rcd_aut.slry_spray := '';
        rcd_aut.trans_watr := '';
        rcd_aut.user1 := '';
        rcd_aut.user2 := '';
        rcd_aut.user3 := '';
        rcd_aut.user4 := '';
        
        vsusccess := 0;
       RETURN vsusccess;
    END;
    
    /**********************************************************
    Convert the tags or decriptions to table column values
    ************************************************************/
    FUNCTION GET_VALUE  (vtype VARCHAR2, vtag IN VARCHAR2, vvalue IN VARCHAR2, vdesc VARCHAR2, vcode VARCHAR2, vmatl VARCHAR2) RETURN NUMBER
    IS
       vval             VARCHAR2(40);
       vcount           NUMBER;
       v_mod_value      VARCHAR2(40);
       vNAME            CONSTANT VARCHAR2(20) := 'GET_VALUE ';
       
    BEGIN
  
        vval := vvalue;
       
        IF vtag =  'MIXTIME' THEN
            IF isNumeric(vval) = 1 THEN
                rcd_aut.MIXTIME := TO_NUMBER(vval) * 60;
            ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'RAMPTYPE' THEN
           rcd_aut.RAMPTYPE := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'BUF_DISCHS' THEN
           rcd_aut.BUF_DISCHS := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SUGAR' THEN
           IF isNumeric(vval) = 1 THEN
               rcd_aut.SUGAR := vval;
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'TOMATO' THEN
            IF isNumeric(vval) = 1 THEN
                rcd_aut.TOMATO := TO_NUMBER(vval);
            ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
            END IF;
            GOTO FINISH;
        END IF;
        
        IF vtag =  'WATER' THEN
           IF isNumeric(vval) = 1 THEN
              
              rcd_aut.WATER := rcd_aut.WATER + TO_NUMBER(vval);
              --dbms_output.put_line('WATER value ' || rcd_aut.WATER);
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
            END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'VEGEWATER' THEN
           rcd_aut.VEGWATER := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'TEMP_SP1' THEN
           rcd_aut.TEMP_SP1 := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'TEMP_SP2' THEN
           rcd_aut.TEMP_SP2 := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'WHITEBASE' THEN
           rcd_aut.WHITEBASE := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'PALLECON' THEN
           rcd_aut.PALLECON := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'ACID' THEN
           rcd_aut.ACID := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'WHITEBASE2' THEN
           rcd_aut.WHITEBASE2 := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'PALLECON2' THEN
           rcd_aut.PALLECON2 := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'ACID2' THEN
           rcd_aut.ACID2 := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SPEED1' THEN
           rcd_aut.SPEED1 := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SPEED2' THEN
           IF vvalue IS NOT NULL THEN
              rcd_aut.SPEED2 := vval;
           ELSE
               rcd_aut.SPEED2 := 50;
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SPEED3' THEN
           IF vvalue IS NOT NULL THEN
              rcd_aut.SPEED3 := vval;
           ELSE
               rcd_aut.SPEED3 := 50;
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SPEED4' THEN
           IF vvalue IS NOT NULL THEN
              rcd_aut.SPEED4 := vval;
           ELSE
               rcd_aut.SPEED4 := 50;
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SPD_CHNG1' THEN
           IF vvalue IS NOT NULL THEN
              rcd_aut.SPD_CHNG1 := vval;
           ELSE
               rcd_aut.SPD_CHNG1 := 50;
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SPD_CHNG2' THEN
           IF vvalue IS NOT NULL THEN
              rcd_aut.SPD_CHNG2 := vval;
           ELSE
               rcd_aut.SPD_CHNG2 := 98;
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'FILL_SP' THEN
           rcd_aut.FILL_SP := vval;
           GOTO FINISH;
        END IF;
      
        IF vtag =  'BUFF_AG' THEN
           IF UPPER(vvalue) = 'ON' THEN
              rcd_aut.BUFF_AG := 1;
           ELSE
               rcd_aut.BUFF_AG := '';
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'BUFF_AGSPD' THEN
           IF vvalue IS NOT NULL THEN
              rcd_aut.BUFF_AGSPD := vval;
           ELSE
               rcd_aut.BUFF_AGSPD := 50;
           END IF;
           GOTO FINISH;
        END IF;
        
        
        
        IF vtag =  'USE_SLRY' THEN
        
           IF UPPER(vvalue) ='YES' THEN
              rcd_aut.USE_SLRY := 1;
           ELSE
               rcd_aut.USE_SLRY := 0;
           END IF;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SLRY_WATR' THEN
           rcd_aut.SLRY_WATR := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SLRY_AGSPD' THEN
           rcd_aut.SLRY_AGSPD := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'SLRY_SPRAY' THEN
           vSluryWater := TRUE;
           rcd_aut.SLRY_SPRAY := vval;
           GOTO FINISH;
        END IF;
        
        IF vtag =  'TRANS_WATR' THEN
           vSluryWater := TRUE;
           rcd_aut.TRANS_WATR := vval;
           GOTO FINISH;
        END IF;
        
        IF vtype = 'M' AND INSTR(UPPER(vdesc),'LIQ') > 0  THEN
           rcd_aut.LIQUIDS :=  vval;
           GOTO FINISH;
        END IF;

        IF vtype = 'M' AND INSTR(UPPER(vdesc),'PWDR') > 0  THEN
           rcd_aut.POWDERS := vval;
           GOTO FINISH;
        END IF;
        
        IF vtype = 'M' AND INSTR(UPPER(vdesc),'VEG') > 0  THEN
            IF isNumeric(vval) = 1 THEN
                IF isNumeric(rcd_aut.VEGWATER)=1 THEN
                   rcd_aut.VEGES := vval - rcd_aut.VEGWATER;
                ELSE
                    rcd_aut.VEGES := vval;
                END IF;
            ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
            END IF;
            GOTO FINISH;
        END IF;
        
        <<FINISH>>
        
        vval:= 0;
       RETURN vval;
    END;
    
   
BEGIN
    vcount := 1;
    vsuccess := CLEAR_RCD;
    OPEN c1;
    LOOP
       FETCH c1 INTO vproc_order;
       EXIT WHEN c1%NOTFOUND;
           -- if record exists delete first 
           DELETE FROM AUTOMATION_TOWER
           WHERE proc_order = vproc_order;
           vsuccess := CLEAR_RCD;
          -- DBMS_OUTPUT.PUT_LINE('proc Order No ' || vproc_order);
           CYCLE_NO := 0;
           vcycle := 5;
           OPEN c2;
           LOOP
                FETCH c2 INTO rcd_rec;
                EXIT WHEN c2%NOTFOUND;
                --DBMS_OUTPUT.PUT_LINE('Record -' || rcd_rec.mpi_type || '-' || rcd_rec.description || '-' || rcd_rec.tag || ' headerfound=' || vheaderfound);
                
                IF (rcd_rec.mpi_type = 'V' OR  rcd_rec.mpi_type = 'M') AND vheaderfound = 1 THEN
                   
                     
                    IF CYCLE_NO =  rcd_rec.box_num OR rcd_rec.box_num IS NULL OR (CYCLE_NO < 10 AND rcd_rec.box_num = 9) THEN 
                       -- get BOM qty 
                       IF  rcd_rec.mpi_type = 'M' THEN
                           vvalue := Get_Bom_Qty(rcd_rec.matl_code, rcd_rec.code,rcd_rec.seq);
                           voutput := TO_CHAR(vvalue);
                           ELSE
                           voutput := rcd_rec.value;
                       END IF; 
                       --DBMS_OUTPUT.PUT_LINE('typ' || rcd_rec.mpi_type ||' tg' || rcd_rec.tag || ' v' || voutput || ' desc' || rcd_rec.description || '-' || rcd_rec.code || '-' || rcd_rec.matl_code);
                                
                       vsuccess := get_value(rcd_rec.mpi_type, rcd_rec.tag, voutput, rcd_rec.description, rcd_rec.code, rcd_rec.matl_code ); 
                    END IF;
                      
                END IF;
                
                IF rcd_rec.mpi_type = 'H'  THEN
                   -- added JP 13 Apr 2005
                   vSluryWater := FALSE;
                   IF SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description),1) = '0' THEN
                       --DBMS_OUTPUT.PUT_LINE( rcd_rec.description || '-' || TO_NUMBER(SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description)-2,3)));
                       CYCLE_NO := TO_NUMBER(SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description)-2,3));
                   ELSE
                       CYCLE_NO := vcycle;
                       vcycle := vcycle + 1;
                   END IF;
                   vheaderfound := 1; 
                   rcd_aut.proc_order := rcd_rec.proc_order;
                   rcd_aut.matl_code := rcd_rec.matl_code;
                        
                END IF;
                vcount := vcount + 1;
           END LOOP;  
           CLOSE c2;
           IF LENGTH(vproc_order) > 4 AND CYCLE_NO <> 0 THEN
              InsertRecord;
           END IF;
           
                  
    END LOOP;
    CLOSE c1;
    vsuccess := vcount;
    
    /******************************************
    Delete old records anything with teco status set to yes
    and at least 14 days old.
    *******************************************/
    DELETE FROM AUTOMATION_KITCHEN 
    WHERE proc_order IN (SELECT DISTINCT A.proc_order 
                    FROM AUTOMATION_TOWER A, CNTL_REC C
                    WHERE A.PROC_ORDER = LTRIM(C.PROC_ORDER,'0')
                    AND C.TECO_STATUS = 'YES' 
                    AND c.run_end_datime < SYSDATE - DELETE_PERIOD);
   
   DBMS_OUTPUT.PUT_LINE('Automation_Tower; Completed Successfully with - ' || vcount || ' records' );
   
   
EXCEPTION

    WHEN OTHERS THEN
	   
            vmessage := 'Automation_Tower  with Proc Order No. ' || vproc_order || CHR(13) || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512);
            
            
       		DBMS_OUTPUT.PUT_LINE(vmessage);
			
			-- rollback the transaction
			ROLLBACK;
            
          
			
			--Raise an error 
         	raiseNotification(NAME || 'Main Procedure with Proc Order No. ' || vproc_order || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));

            
END;
/

