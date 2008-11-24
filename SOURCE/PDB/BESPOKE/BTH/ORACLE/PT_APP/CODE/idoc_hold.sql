DROP FUNCTION PT_APP.IDOC_HOLD;

CREATE OR REPLACE FUNCTION PT_APP.Idoc_Hold RETURN BOOLEAN IS

  v_max_prd_day		NUMBER(2);
  v_prd_day		    NUMBER(2);
  v_disable_start	NUMBER := 23.75;	-- FOOD ==> 23.75(11.45pm)	
  v_disable_end		NUMBER := 01;		-- Petcare ==> 01.00(1am)	
  v_disable		    BOOLEAN;
  
 
  
	/******************************************************************************
	Created By:	Craig George (Based upon function written by Jeff Phillipson for NZ)
	Created Date:	16 Jun 2005
	Purpose:	Prevent IDOCS from transmission to Atlas
			To enable window for processing of end of period financial data

	Called from:	PRODUCTION_INTFC (4 calls)
			REPROCESS_MESSAGES (1 calls)
            
    Added a second instance of disabling Pallets Idocs - Jeff Phillipson
    A problem occurs with AUK001 on Saturday between 10 and 10:30 - this has been difficult to fix 
    Oracle fault - Distributed transaction time out between AP0065P and AP0064P 
    in Shiftlog so Idocs will be disbled for this time operiod 
	******************************************************************************/
    
BEGIN
	v_disable:= FALSE;

	-- Get the maximum, or last day for the current period
	SELECT MAX(PERIOD_DAY_NUM) INTO v_max_prd_day
	FROM mars_date
	WHERE mars_period = (SELECT MARS_PERIOD FROM mars_date WHERE calendar_date = TRUNC(SYSDATE))
	;

	-- Get the period day for today
	SELECT PERIOD_DAY_NUM INTO v_prd_day
	FROM mars_date
	WHERE calendar_date = TRUNC(SYSDATE);

	-- Testing overide
    --	v_prd_day := 28;	-- 1 or 28 or 7

	-- Check the following, hold IDOCS if criteria is met
	-- The day is the LAST day of the period
	-- The time is GREATER than or EQUAL to the disable start time
	IF v_prd_day = v_max_prd_day THEN
		IF SYSDATE >= (TRUNC(SYSDATE) + v_disable_start / 24) THEN
			v_disable:= TRUE;
		END IF;
	END IF;

	-- Check the following, hold IDOCS if criteria is met
	-- The day is the FIRST day of the period
	-- The time is LESS than or EQUAL to the disable end time
	IF v_prd_day = 1 THEN
		IF SYSDATE <= (TRUNC(SYSDATE) + v_disable_end / 24) THEN
			v_disable:= TRUE;
		END IF;
	END IF;

  
    
RETURN v_disable;

EXCEPTION
WHEN OTHERS THEN
	-- Consider logging the error and then re-raise
       v_disable:= FALSE;
       RETURN v_disable;
END Idoc_Hold;
/


DROP PUBLIC SYNONYM IDOC_HOLD;

CREATE PUBLIC SYNONYM IDOC_HOLD FOR PT_APP.IDOC_HOLD;


GRANT EXECUTE ON PT_APP.IDOC_HOLD TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.IDOC_HOLD TO BTHSUPPORT;

