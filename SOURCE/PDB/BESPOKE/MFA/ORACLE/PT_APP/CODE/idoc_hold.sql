DROP FUNCTION PT_APP.IDOC_HOLD;

CREATE OR REPLACE FUNCTION PT_APP.IDOC_HOLD RETURN BOOLEAN IS
  v_max_prd_day		number(2);
  v_prd_day		number(2);
  v_disable_start	number := 23.75;		-- 23.45
  v_disable_end		number := 01;			-- 00.45
  v_disable		BOOLEAN;
	/******************************************************************************
	Created By:	Craig George (Based upon function written by Jeff Phillipson for NZ)
	Created Date:	16 Jun 2005
	Purpose:	Prevent IDOCS from transmission to Atlas
			To enable window for processing of end of period financial data

	Called from:	PRODUCTION_INTFC (4 calls)
			REPROCESS_MESSAGES (1 calls)
	******************************************************************************/
BEGIN
	v_disable:= FALSE;

	-- Get the maximum, or last day for the current period
	SELECT max(PERIOD_DAY_NUM) into v_max_prd_day
	FROM mars_date
	WHERE mars_period = (select MARS_PERIOD from mars_date where calendar_date = trunc(sysdate))
	;

	-- Get the period day for today
	SELECT PERIOD_DAY_NUM into v_prd_day
	FROM mars_date
	WHERE calendar_date = TRUNC(SYSDATE);

	-- Testing overide
--	v_prd_day := 28;	-- 1 or 28

	-- Check the following, hold IDOCS if criteria is met
	-- The day is the LAST day of the period
	-- The time is GREATER than or EQUAL to the disable start time
	if v_prd_day = v_max_prd_day then
		if sysdate >= (TRUNC(SYSDATE) + v_disable_start / 24) then
			v_disable:= TRUE;
		end if;
	End if;

	-- Check the following, hold IDOCS if criteria is met
	-- The day is the FIRST day of the period
	-- The time is LESS than or EQUAL to the disable end time
	if v_prd_day = 1 then
		if sysdate <= (TRUNC(SYSDATE) + v_disable_end / 24) then
			v_disable:= TRUE;
		end if;
	end if;


RETURN v_disable;

EXCEPTION
WHEN OTHERS THEN
	-- Consider logging the error and then re-raise
       v_disable:= FALSE;
       RETURN v_disable;
END IDOC_HOLD;
/


