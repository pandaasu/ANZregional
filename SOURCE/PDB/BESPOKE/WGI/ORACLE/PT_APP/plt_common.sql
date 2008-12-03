DROP PACKAGE PT_APP.PLT_COMMON;

CREATE OR REPLACE PACKAGE PT_APP.Plt_Common IS


		-- System Constants
		SUBTYPE RESULT_TYPE IS INTEGER;
  		SUCCESS      CONSTANT  RESULT_TYPE := 0;  -- Worked Successfully.
  		FAILURE      CONSTANT  RESULT_TYPE := 1;  -- The request was failed to be carried out or the desired answer was false.  The reason for it being false will be containted in the error message.
  		ERROR        CONSTANT  RESULT_TYPE := 2;  -- Oracle Error Most likley or other serious problem.
  		TIMEOUT      CONSTANT  RESULT_TYPE := 3;  -- Unable to complete the operation as the system timed out, or in the case of security if
                                        -- there have been no access for a certain period of time and hence the function should no be executed at this point in time.
 
        -- Site specific for STO transactions
		SOURCE_PLANT CONSTANT  VARCHAR2(4)  :=    'NZ01';	
        DOC_TYPE     CONSTANT  VARCHAR2(4)  :=    ' ZUB';
        CMPNY_CODE   CONSTANT  VARCHAR2(4)  :=    '149 ';
		PURCH_ORG    CONSTANT  VARCHAR2(4)  :=    '0208';
        PURCH_GRP    CONSTANT  VARCHAR2(3)  :=    '670';
        STOR_LOCN    CONSTANT  VARCHAR2(4)  :=    '0001';
       	CURRENCY     CONSTANT  VARCHAR2(3)  :=    'NZD';
        VENDOR       CONSTANT  VARCHAR2(1)  :=    ' ';	
        													
                                                            
        /* Times to Disable the Idoc sending for Pallet Tagging during 
        || End of Period Financial processing in Atlas
        || During this time NO Goods Recipts or STO's should be sent to Atlas 
        ||
        || Note if this function needs to be disabled 
        || set the PERIOD_END_DATE to any number greater than 28  
        */
        PERIOD_END_DAY CONSTANT NUMBER := 28;
        -- based on 24hr clock in hours 
        DISABLE_START CONSTANT NUMBER := 23;
        -- duration in hours - minutes in decimal 
        DISABLE_DURATION CONSTANT NUMBER := 3;
	END;
/


