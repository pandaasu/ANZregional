CREATE OR REPLACE PROCEDURE MANU_APP.Update_Automation_Kitchen


IS

 /*********************************************
  This procedure will run every 30minutes to convert Proc Order
  data into a horizontal structure and save in AUTOMATION_Kitchen table

  Input - Recipe_VW of each Proc_Order this is used to re-constitute the Phase
          numbering used in the old MPI system

  Output - records in Automation_Kitchen corresponding to the
         original Phase sections of the recipe.

  The Headers within the RECIPE_VW are used to define new CYCLES (PHASES)

  REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        23 Oct 2004 Jeff Phillipson 1. Created this procedure.
   1.1        21 Jul 2006  R.Carneiro     2. Added Brine as row
   1.2        07-May-2007  J Phillipson   Changed reference to cntl_rec to cntl_rec_vw - disables validation pos
   1.3       12 May 2008  R.Carneiro     updated to use cntl_rec_resource_vw

  *********************************************/

   DELETE_PERIOD     CONSTANT NUMBER := 1;
   CHECK_BACK        CONSTANT NUMBER := 1;
   CHECK_FORWARD     CONSTANT NUMBER := 3;
   NAME              CONSTANT VARCHAR2(100) := 'UPDATE_AUTOMATION_KITCHEN ';

   vsuccess          NUMBER;
   v_qty             VARCHAR2(12);
   vcount            NUMBER;
   vstart            NUMBER;
   vproc_order       VARCHAR2(12);
   vheaderfound      NUMBER;
   vcycle            NUMBER;
   vmanadd           NUMBER;
   vvalue            NUMBER;
   voutput           VARCHAR2(40);
   v_last_cycle_no   NUMBER;


   /* declare package cursor specification */
   CURSOR c1 IS
   SELECT LTRIM(c.proc_order,'0') FROM CNTL_REC_VW c, cntl_rec_resource_vw r
   --WHERE LTRIM(c.proc_order,'0') = '1006579'
   --  WHERE SCHED_START_DATIME > SYSDATE - CHECK_BACK
   --  AND SCHED_START_DATIME < SYSDATE + CHECK_FORWARD
   WHERE teco_status = 'NO'
     AND c.proc_order = r.proc_order
     AND r.resource_code IN ('MXSIM041','MXSIM042','MXSIM044');



   CURSOR c2 IS
    select t01.*, 
      t02.tag, 
      t03.resource_code, 
      t05.work_ctr_code, 
      ltrim(t04.material,'0') matl_code
    from recipe_vw t01,
      site_automation_kitchen t02, 
      (
        select proc_order,
          resource_code,
          operation
        from cntl_rec_resource_vw
        where substr(proc_order,1,1) between '0' and '9'
      ) t03,
      cntl_rec_vw t04, 
      work_ctr_vw t05
    where t01.code = t02.tag_or_num(+)
      and to_number(t01.proc_order) = to_number(t03.proc_order)
      and to_number(t04.proc_order) = to_number(t03.proc_order)
      and t03.resource_code = t05.resource_code
      and t01.operation = t03.operation
      and t01.proc_order = vproc_order
      and mpi_type in ('M','V','H')
      and upper(t01.description) not like 'INSTRUCTION%'
      and upper(t01.description) not like 'NOTE%'
      and upper(t01.description) not like 'SPECIAL%'
      and t03.resource_code in ('MXSIM041','MXSIM042','MXSIM044')
    order by 1,2,3,4; 


     /*****
     Row types
     ******/
     rcd_rec c2%ROWTYPE;
     rcd_aut AUTOMATION_KITCHEN%ROWTYPE;


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
         INSERT INTO AUTOMATION_KITCHEN
             VALUES (rcd_aut.proc_order,
             rcd_aut.work_ctr,
             rcd_aut.matl_code,
             rcd_aut.CYCLE_NO,
             rcd_aut.INNERAG,
             rcd_aut.INNERSPD,
             rcd_aut.OUTERAG,
             rcd_aut.OUTERSPD,
             rcd_aut.BOTTOMAG,
             rcd_aut.BOTTOMSPD,
             rcd_aut.cp_water,
             rcd_aut.liquids,
             rcd_aut.dtpaste,
             rcd_aut.conctp,
             rcd_aut.sugar,
             rcd_aut.powders,
             rcd_aut.cspry_wtr1,
             rcd_aut.hspry_wtr1,
             rcd_aut.key_stn,
             rcd_aut.glucose,
             rcd_aut.oil,
             rcd_aut.oil_spd,
             rcd_aut.acid,
             rcd_aut.acid_spd,
             rcd_aut.veges,
             rcd_aut.hp_water,
             rcd_aut.csball_wtr,
             rcd_aut.hsball_wtr,
             rcd_aut.cspry_wtr2,
             rcd_aut.hspry_wtr2,
             rcd_aut.mixtime,
             rcd_aut.manadd,
             rcd_aut.steam,
             rcd_aut.ramptemp,
             rcd_aut.ramptype,
             rcd_aut.veges_wtr,
             rcd_aut.v_blo_pres,
             rcd_aut.steam_wt,
             rcd_aut.instructn,
             rcd_aut.instrvalu,
             rcd_aut.soya_oil,
             rcd_aut.soya_o_spd,
             rcd_aut.user1,
             rcd_aut.user2,
             rcd_aut.user3,
             rcd_aut.user4,
             rcd_aut.brine
             );
             COMMIT;
             rcd_aut.CYCLE_NO := 0;

     EXCEPTION
         WHEN OTHERS THEN

         DBMS_OUTPUT.PUT_LINE('Automation_Kitchen InsertRecorde with Proc Order No. ' || vproc_order || ' Cycle ' || rcd_aut.CYCLE_NO || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));
   -- rollback the transaction
   ROLLBACK;

   --Raise an error
            raiseNotification(NAME || CHR(13) || VNAME || CHR(13) || ' with Proc Order No. ' || vproc_order || CHR(13)  || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));
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


    /*******************************************
    Clear the record to default values
    ********************************************/
    FUNCTION CLEAR_RCD RETURN NUMBER
    IS
       vsusccess NUMBER;
    BEGIN
        rcd_aut.CYCLE_NO := 0;
        rcd_aut.innerag := 0;
        rcd_aut.innerspd := '0';
        rcd_aut.outerag := 0;
        rcd_aut.outerspd := '0';
        rcd_aut.bottomag := 0;
        rcd_aut.bottomspd := '0';

        rcd_aut.cp_water := 0;
        rcd_aut.liquids := 0;
        rcd_aut.dtpaste := '0';
        rcd_aut.conctp := '0';
        rcd_aut.sugar := 0;
        rcd_aut.powders := 0;
        rcd_aut.cspry_wtr1 := 0;
        rcd_aut.hspry_wtr1 := 0;
        rcd_aut.key_stn := '0';
        rcd_aut.glucose := '0';
        rcd_aut.oil := '0';
        rcd_aut.oil_spd := '0';
        rcd_aut.acid := 0;
        rcd_aut.acid_spd := '0';
        rcd_aut.veges := 0;
        rcd_aut.hp_water := '0';
        rcd_aut.csball_wtr := 0;
        rcd_aut.hsball_wtr := '0';
        rcd_aut.cspry_wtr2 := 0;
        rcd_aut.hspry_wtr2 := 0;
        rcd_aut.mixtime := 0;
        rcd_aut.manadd := 0;
        rcd_aut.steam := 0;
        rcd_aut.ramptemp := '0';
        rcd_aut.ramptype := '0';
        rcd_aut.veges_wtr := '0';
        rcd_aut.v_blo_pres := '0';
        rcd_aut.steam_wt := '0';
        rcd_aut.instructn := 2;
        rcd_aut.instrvalu := 0;
        rcd_aut.soya_oil := '0';
        rcd_aut.soya_o_spd := '0';
        rcd_aut.user1 := '0';
        rcd_aut.user2 := '0';
        rcd_aut.user3 := '0';
        rcd_aut.user4 := '0';
        rcd_aut.brine := '0';

        vsusccess := 0;
       RETURN vsusccess;
    END;



    /**********************************************************
    Convert the tags or decriptions to table column values
    ************************************************************/

    FUNCTION GET_VALUE  (vtype VARCHAR2, vtag IN VARCHAR2, vvalue IN VARCHAR2, vdesc VARCHAR2, vcode VARCHAR2, vmatl VARCHAR2) RETURN NUMBER
    IS
      vval              VARCHAR2(40);
      vcount            NUMBER;
      v_mod_value       VARCHAR2(40);
      vNAME             CONSTANT VARCHAR2(20) := 'GET_VALUE ';
      v_num             VARCHAR2(200) DEFAULT 0;

    BEGIN

        vval := vvalue;

        IF vtag = 'INNERSPD' THEN
           IF isNumeric(vval) = 1 THEN
              IF TO_NUMBER(vval) > 0 THEN
                 rcd_aut.INNERAG := 1;
                 rcd_aut.INNERSPD := vval;
              ELSE
                 rcd_aut.INNERAG := 0;
                 rcd_aut.INNERSPD := 0;
              END IF;
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF vtag =  'OUTERSPD' THEN
           IF isNumeric(vval) = 1 THEN
              IF TO_NUMBER(vval) > 0 THEN
                 rcd_aut.OUTERAG := 1;
                 rcd_aut.OUTERSPD := vval;
                 ELSE
                 rcd_aut.OUTERAG := 0;
                 rcd_aut.OUTERSPD := 0;
                 END IF;
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF vtag =  'BOTTOMSPD' THEN
           IF isNumeric(vval) = 1 THEN
               IF TO_NUMBER(vval) > 0 THEN
                   rcd_aut.BOTTOMAG := 1;
                   rcd_aut.BOTTOMSPD := vval;
               ELSE
                   rcd_aut.BOTTOMAG := 0;
                   rcd_aut.BOTTOMSPD := 0;
               END IF;
           ELSE
               SELECT DECODE(SUBSTR(trim(vval),LENGTH(vval),1),'%',SUBSTR(vval,1,LENGTH(vval)-1), vval)
                 INTO v_num
                 FROM dual;
               IF isNumeric(v_num) = 1 THEN
                   IF TO_NUMBER(v_num) > 0 THEN
                       rcd_aut.BOTTOMAG := 1;
                       rcd_aut.BOTTOMSPD := v_num;
                   ELSE
                       rcd_aut.BOTTOMAG := 0;
                       rcd_aut.BOTTOMSPD := 0;
                   END IF;
                   DBMS_OUTPUT.PUT_LINE('Value modified');
               END IF;
               -- Send email message
               raiseNotification(NAME || VNAME || ' Problem with ' || vtag || ' Description ' || vdesc || CHR(13)
                                 || ' Proc Order ' || vproc_order
                                 || ' Tag is not Numeric - its value is - ' || vval || CHR(13)
                                 || ' Please inform R FOOD' || CHR(13)
                                 || ' Value should be ' || v_num);
           END IF;
           GOTO FINISH;
        END IF;

        IF vtag =  'CP_WATER' THEN
           IF isnumeric(vval) = 1 THEN
               rcd_aut.CP_WATER := rcd_aut.CP_WATER + TO_NUMBER(vval);
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF INSTR(UPPER(vdesc),'LIQ') > 0 AND vtype = 'M' THEN
           IF isnumeric(vval) = 1 THEN
              rcd_aut.LIQUIDS := rcd_aut.LIQUIDS + TO_NUMBER(vval);
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF vtag = 'TOMATO_PASTE' THEN
           rcd_aut.DTPASTE :=  vval;
           GOTO FINISH;
        END IF;

        IF vtag = 'TOMATO_PASTE_A' THEN
           rcd_aut.CONCTP :=  vval;
           GOTO FINISH;
        END IF;
       -- DBMS_OUTPUT.PUT_LINE('Is it Sugar -' || vtag || '-' || vdesc ||' - Count=' || INSTR(UPPER(vdesc),'SUGAR'));

        IF vtag = 'SUGAR' THEN
           IF isnumeric(vval) = 1 THEN
              rcd_aut.SUGAR := rcd_aut.SUGAR + TO_NUMBER(vval);
           ELSE
              -- Send email message
              raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF INSTR(UPPER(vdesc),'PWDR') > 0 AND vtype = 'M' THEN
           IF isnumeric(vval) = 1 THEN
               rcd_aut.POWDERS := rcd_aut.POWDERS + TO_NUMBER(vval);
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
            GOTO FINISH;
        END IF;

        IF INSTR(UPPER(vdesc),'KEY STATION') > 0  AND vtype = 'M' THEN
           rcd_aut.KEY_STN := vval;
           GOTO FINISH;
        END IF;

        IF vtag = 'GLUCOSE_76%_SO2_FREE' THEN
           rcd_aut.GLUCOSE := vval;
           GOTO FINISH;
        END IF;

  IF vtag = 'BRINE_26%NACL' THEN
           rcd_aut.BRINE := vval;
           GOTO FINISH;
        END IF;

        IF vtag = 'OIL_BULK' THEN
            IF isnumeric(vval) = 1 THEN
                rcd_aut.OIL :=  rcd_aut.OIL + TO_NUMBER(vval);
            ELSE
                -- Send email message
                raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
            END IF;
            GOTO FINISH;
        END IF;

        IF vtag = 'OIL_SPD' THEN
           rcd_aut.OIL_SPD := vval;
           GOTO FINISH;
        END IF;

        IF INSTR(UPPER(vdesc),'ACID ACETIC 75') > 0 AND vtype = 'M' THEN
            IF isnumeric(vval) = 1 THEN
                rcd_aut.ACID := rcd_aut.ACID + TO_NUMBER(vval);
            ELSE
                -- Send email message
                raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
            END IF;
            GOTO FINISH;
        END IF;

        IF vtag = 'ACID_SPD'  THEN
           rcd_aut.ACID_SPD := vval;
           GOTO FINISH;
        END IF;

        IF INSTR(UPPER(vdesc),'VEGE') > 0 AND vtype = 'M' THEN
           IF isnumeric(vval) = 1 THEN
               rcd_aut.VEGES := TO_NUMBER(vval);
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF vtag = 'HP_WATER' THEN
           rcd_aut.HP_WATER :=vval;
           GOTO FINISH;
        END IF;

        IF vtag =  'MIXTIME' THEN
           IF isnumeric(vval) = 1 THEN
               rcd_aut.MIXTIME := TO_NUMBER(vval) * 60;
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           GOTO FINISH;
        END IF;

        IF vtag =  'RAMPTEMP' THEN
           IF isnumeric(vval) = 1 THEN
               IF vval > 0 THEN
                   rcd_aut.STEAM := 1;
               ELSE
                   rcd_aut.STEAM := 0;
               END IF;
           ELSE
               -- Send email message
               raiseNotification(NAME || VNAME || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
           rcd_aut.RAMPTEMP := vval;
           GOTO FINISH;
        END IF;

        IF vtag =  'RAMPTYPE' THEN

            IF UPPER(vval) = 'VISCOUS 1' OR vval = '4' THEN
                rcd_aut.RAMPTYPE := 4;
            END IF;
            IF UPPER(vval) = 'VISCOUS 3'OR vval = '3' THEN
                rcd_aut.RAMPTYPE := 2;
            END IF;
            IF UPPER(vval) = 'VISCOUS 2' OR vval = '2' THEN
                rcd_aut.RAMPTYPE := 5;
            END IF;
            IF UPPER(vval) = 'STARCH'  THEN
                rcd_aut.RAMPTYPE := 3;
            END IF;
            IF UPPER(vval) = 'NORMAL' OR vval = '1' THEN
                rcd_aut.RAMPTYPE := 1;
            END IF;

            GOTO FINISH;
        END IF;

        IF vtag =  'VEGEWATER' THEN
           rcd_aut.VEGES_WTR := vval;
           GOTO FINISH;
        END IF;


        IF vtag =  'STEAM_CONDENSATE' THEN
           rcd_aut.STEAM_WT := vval;
           GOTO FINISH;
        END IF;


        IF UPPER(vtag) =  'QC_CHECK'THEN
           rcd_aut.INSTRUCTN := 4;
           GOTO FINISH;
        ELSE
           rcd_aut.INSTRUCTN :=2;
        END IF;

        IF UPPER(vtag) =  'BATCH_END'  THEN
            rcd_aut.INSTRUCTN :=3;
            GOTO FINISH;
        END IF;

        IF UPPER(vtag) =  'INSTRVALU' THEN
           rcd_aut.INSTRVALU := 0; -- not used
           GOTO FINISH;
        END IF;

        IF vtag =  'SOYA_OIL_BULK' THEN
           rcd_aut.SOYA_OIL := vval;
           GOTO FINISH;
        END IF;

        IF UPPER(vdesc) =  'SOYA OIL ADD SPEED' THEN
           rcd_aut.SOYA_O_spd := vval;
           GOTO FINISH;
        END IF;

        IF UPPER(vtag) =  'V_BLO_PRES' THEN
           rcd_aut.V_BLO_PRES := vval;
           GOTO FINISH;
        END IF;


        <<FINISH>>
        -- get manadd value
        IF vtype = 'M' AND INSTR(UPPER(vdesc),'LIQ') = 0 AND INSTR(UPPER(vdesc),'VEGE') = 0  AND INSTR(UPPER(vdesc),'PWD') = 0  THEN
           IF isnumeric(vval) = 1 THEN
               SELECT COUNT(*) INTO vcount FROM SITE_AUTOMATION_KITCHEN WHERE tag = trim(vtag);
               IF vcount = 0 THEN
                   rcd_aut.manadd := rcd_aut.manadd + TO_NUMBER(vval);
               END IF ;
            ELSE
               -- Send email message
               raiseNotification(NAME || CHR(13) || VNAME || CHR(13) || ' problem with ' || vtag || ' Description ' || vdesc);
           END IF;
        END IF;
        RETURN 0;
    END;
    /***************************************************************/



BEGIN
    vcount := 1;
    vsuccess := CLEAR_RCD;
    OPEN c1;
    LOOP
       FETCH c1 INTO vproc_order;
       EXIT WHEN c1%NOTFOUND;
            -- if record exists delete first
            DELETE FROM AUTOMATION_KITCHEN
            WHERE proc_order = vproc_order;

           vcycle := 5;
           OPEN c2;
           LOOP
                FETCH c2 INTO rcd_rec;
                EXIT WHEN c2%NOTFOUND;
              --  DBMS_OUTPUT.PUT_LINE('Record -' || rcd_rec.mpi_type || '-' || rcd_rec.description || '-' || rcd_rec.tag || ' headerfound=' || vheaderfound);

                IF (rcd_rec.mpi_type = 'V' OR  rcd_rec.mpi_type = 'M') AND vheaderfound = 1 THEN
                    -- get BOM qty
                    IF  rcd_rec.mpi_type = 'M' THEN
                        vvalue := Get_Bom_Qty(rcd_rec.matl_code, rcd_rec.code,rcd_rec.seq);
                        voutput := TO_CHAR(vvalue);
                        --DBMS_OUTPUT.PUT_LINE('test' || rcd_rec.matl_code || '-' || rcd_rec.code || '-' || rcd_rec.seq || ' new qty=' || TO_CHAR(vvalue) || ' old qty=' || rcd_rec.value);
                    ELSE
                        voutput := rcd_rec.value;
                    END IF;
                    vsuccess := get_value(rcd_rec.mpi_type, rcd_rec.tag, voutput, rcd_rec.description, rcd_rec.code, rcd_rec.matl_code);
                END IF;

                IF rcd_rec.mpi_type = 'H' AND rcd_rec.description NOT LIKE 'Instr%' THEN
                    IF vheaderfound = 1 THEN
                       IF rcd_aut.CYCLE_NO <> 0 THEN
                          InsertRecord;
                       END IF;
                       vsuccess:=CLEAR_RCD;
                       vheaderfound := 0;
                       vmanadd := 0;
                    END IF;
                    IF rcd_rec.mpi_type = 'H' THEN
                       IF SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description),1) = '0' THEN
                          --DBMS_OUTPUT.PUT_LINE( rcd_rec.description || '-' || TO_NUMBER(SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description)-2,3)));
                          rcd_aut.CYCLE_NO := TO_NUMBER(SUBSTR(rcd_rec.description,LENGTH(rcd_rec.description)-2,3));

                          /***************************************************
                          -- this shouldnt happen
                          -- if it does add 1 to the counter so that there is no unique key problem
                          -- in the table - raise an alert saying it should be fixed
                          JP 16 Feb 2005 */
                          IF v_last_cycle_no = rcd_aut.CYCLE_NO THEN
                              SELECT COUNT(*) INTO vcount
                              FROM ERR_PROCESS
                              WHERE proc_order = vproc_order;
                              IF vcount = 0 THEN
                                  raisenotification('The MPI data is INCORRECT. Please advise R There should only be 1 Step '
                                                || rcd_aut.CYCLE_NO
                                                || CHR(13)
                                                || ' THIS IS NOT A APPLICATION ERROR'
                                                || CHR(13)
                                                || ' Proc Order ' || vproc_order
                                                || CHR(13));
                                  INSERT INTO ERR_PROCESS VALUES (vproc_order,'The MPI data is INCORRECT. Please advise R There should only be 1 Step ',SYSDATE);
                              END IF;
                              rcd_aut.CYCLE_NO := rcd_aut.CYCLE_NO + 1;
                          END IF;
                          v_last_cycle_no := rcd_aut.CYCLE_NO;
                          /*****************************************************/

                       ELSE
                           rcd_aut.CYCLE_NO := vcycle;
                           vcycle := vcycle + 1;
                       END IF;
                       vheaderfound := 1;
                    END IF;
                    rcd_aut.proc_order := rcd_rec.proc_order;
                    rcd_aut.matl_code := rcd_rec.matl_code;
                    rcd_aut.work_ctr := rcd_rec.work_ctr_code;
                END IF;
                vcount := vcount + 1;
           END LOOP;

           -- DBMS_OUTPUT.PUT_LINE('XXXXXXXXXXXXXX' || vproc_order);
           IF LENGTH(vproc_order) > 4 AND rcd_aut.CYCLE_NO <> 0 THEN
              InsertRecord;
           END IF;
           CLOSE c2;
    END LOOP;
    CLOSE c1;
    vsuccess := vcount;

    /******************************************
    Delete old recoirds anything with teco status set to yes
    and at least 14 days old.
    *******************************************/
    DELETE FROM automation_kitchen
    WHERE proc_order IN (SELECT DISTINCT A.proc_order
                    FROM AUTOMATION_KITCHEN A, CNTL_REC C
                    WHERE A.PROC_ORDER = LTRIM(C.PROC_ORDER,'0')
                    AND C.TECO_STATUS = 'YES' );
                    --AND c.run_end_datime < SYSDATE - DELETE_PERIOD);


   DBMS_OUTPUT.PUT_LINE('Automation_Kitchen; Completed Successfully with - ' || vcount || ' records' );


EXCEPTION

    WHEN OTHERS THEN

         DBMS_OUTPUT.PUT_LINE('Automation_Kitchen  with Proc Order No. ' || vproc_order || ' Sql Error ' || DBMS_UTILITY.format_error_backtrace);

   -- rollback the transaction
   ROLLBACK;

   --Raise an error
          raiseNotification(NAME || CHR(13) || 'Main Procedure with Proc Order No. ' || vproc_order || CHR(13) || ' Sql Error ' || DBMS_UTILITY.format_error_backtrace);

END;
/

