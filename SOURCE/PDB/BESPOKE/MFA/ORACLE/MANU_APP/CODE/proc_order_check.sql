DROP PROCEDURE MANU_APP.PROC_ORDER_CHECK;

CREATE OR REPLACE PROCEDURE MANU_APP.Proc_Order_Check IS


/******************************************************************************
   NAME:       Proc_Order_Check
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        31/01/2005   Jeff Phillipson 1. Created this procedure.

   NOTES:     This procedure will run at 12am every day and provide exceptions 
              for to few procedure Orders 2 days away
              and on a Friday emial to a Shift Managers group how many 
              procedure Orders are available for the following Monday 

  
******************************************************************************/

    NAME              CONSTANT VARCHAR2(100) := 'Proc_Order_Check ';
    CHECK_FORWARD     CONSTANT NUMBER := 1;
    CHECK_FRIDAY      CONSTANT NUMBER := 3;  -- should be 3 
    FRIDAY            CONSTANT VARCHAR2(10) := 'friday';
    MIN_PROC_ORDERS   CONSTANT NUMBER := 10;
    
    v_recs            NUMBER;
    v_day             VARCHAR2(20);
    v_count           NUMBER;
    v_result          VARCHAR2(3700) DEFAULT CHR(13) || 'WARNING! There is less than ' || MIN_PROC_ORDERS || ' Proc Orders in the Plant Database.'
					  				 		 || CHR(13)
											 -- || 'The following Proc Orders are available in the Plant Database ' 
                                             -- || CHR(13) 
                                             || 'for the Factory Control Systems on - ' 
                                             ;
                                             
    v_result1         VARCHAR2(2000)  DEFAULT CHR(13) 
                                             || '*************************************************************' 
                                             || CHR(13) 
                                             || 'Proc Order   Material ' 
                                             || CHR(13);
    v_offset          NUMBER;
    
    
     CURSOR c_procs IS
     SELECT material, material_text, quantity, c.uom, proc_order
         FROM cntl_rec c, material m
         WHERE TO_CHAR(SCHED_START_DATIME,'dd-mon-yyyy') = TO_CHAR(SYSDATE + v_offset,'dd-mon-yyyy') 
         AND LTRIM(c.material,0) = m.material_code
         AND PLANT_ORNTD_MATL_TYPE IN ('7','3','4')
         ORDER BY PLANT_ORNTD_MATL_TYPE, recipe_text;
      
     rcd c_procs%ROWTYPE;
     
     
    /*********************************************
     RAISE email notification OF error
     **********************************************/
     PROCEDURE raiseNotification(message IN VARCHAR2, shift_managers IN NUMBER)
     IS
     
         vmessage VARCHAR2(4000);
         
     BEGIN
          vmessage := message;
          IF shift_managers <>  1 THEN
              Mailout(vmessage,'ricardo.carneiro@ap.effem.com', 'Plant_Database','Factory Proc Orders from Atlas');
          ELSE
              Mailout(vmessage,'"MFA Process Orders Alert"@esosn1', 'Plant_Database','Factory Proc Orders from Atlas');
          END IF;
     EXCEPTION
         WHEN OTHERS THEN
         vmessage := message;
     END;
    
    
    
    
     
     
     
BEGIN

  -- check date 
  v_day := RTRIM(LTRIM(TO_CHAR(SYSDATE,'day'))); 
    
  -- only do this test if in working week 
  IF  v_day <> 'saturday' AND v_day <> 'sunday' THEN
  
    IF v_day = FRIDAY THEN
        v_offset := CHECK_FRIDAY;
    ELSE
        v_offset := CHECK_FORWARD;
    END IF;
    v_result := v_result || NLS_INITCAP(TO_CHAR(SYSDATE + v_offset,'day')) || ' ' || TO_CHAR(SYSDATE + v_offset); -- || v_result1;
 
    v_recs := 0;
    OPEN c_procs;
    LOOP
        FETCH c_procs INTO rcd;
        EXIT WHEN c_procs%NOTFOUND;
        --IF LENGTH(v_result) < 3600 THEN 
        --    v_result := v_result || CHR(13) ||LTRIM(rcd.proc_order,'0') || '      ' || LTRIM(rcd.material,'0') || ' - ' || SUBSTR(RPAD(rcd.material_text,30,' '),1,30) || ' - ' || TO_CHAR(rcd.quantity,'999999.999') || rcd.uom;
        --ELSE
        --    v_result := v_result || CHR(13) || ' and more ....';
        --    EXIT;        
        --END IF;
        v_recs := v_recs + 1;
    END LOOP;
    CLOSE c_procs;
 
  
   
    
    IF v_recs > 0 THEN
        v_result := v_result || CHR(13);
        -- if Friday send email 
        -- if not friday - send email on exception ie if no of orders less than a preset amount
        IF v_recs <  MIN_PROC_ORDERS   THEN
            dbms_output.put('Day' || v_day || v_recs);
            raiseNotification(v_result || CHR(13) || '(' || v_recs || ' records )',1);
        END IF;
        
    ELSE
        IF v_Offset = CHECK_FORWARD THEN
            raiseNotification('WARNING! PROC ORDERS for FACTORY (Plant Database) ' || CHR(13) || 'No Process Orders are available for ' || CHECK_FORWARD || ' days ahead.', 1);
        ELSE
            raiseNotification('WARNING! No Process Orders are available for next MONDAY!', 1);
        END IF;
    END IF;
   
   
    COMMIT;
  END IF;
   
  EXCEPTION

    WHEN OTHERS THEN
	   
       		DBMS_OUTPUT.PUT_LINE('Proc_Order_Check procedure failed to run ' || SUBSTR(SQLERRM, 1, 512));
			
			-- rollback the transaction
			ROLLBACK;
			
			--Raise an error 
         	raiseNotification(NAME || CHR(13) || 'Proc_Order_Check procedure failed to run. ' || CHR(13) || 'Sql Error ' || SUBSTR(SQLERRM, 1, 512), 0);
           
END Proc_Order_Check;
/


