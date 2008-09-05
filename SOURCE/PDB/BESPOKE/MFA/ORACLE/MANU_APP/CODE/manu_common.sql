DROP PACKAGE MANU_APP.MANU_COMMON;

CREATE OR REPLACE PACKAGE MANU_APP.Manu_Common IS


		-- System Constants
		SUBTYPE RESULT_TYPE IS INTEGER;
  		SUCCESS      CONSTANT  RESULT_TYPE := 0;  -- Worked Successfully.
  		FAILURE      CONSTANT  RESULT_TYPE := 1;  -- The request was failed to be carried out or the desired answer was false.  The reason for it being false will be containted in the error message.
  		ERROR        CONSTANT  RESULT_TYPE := 2;  -- Oracle Error Most likley or other serious problem.
  		TIMEOUT      CONSTANT  RESULT_TYPE := 3;  -- Unable to complete the operation as the system timed out, or in the case of security if
                                        -- there have been no access for a certain period of time and hence the function should no be executed at this point in time.
 
        -- Site specific for STO transactions
        
		MAX_REFRESH_TIMEOUT  CONSTANT NUMBER         := 15;     -- 15 minutes
        
        CONTACT              CONSTANT VARCHAR2(2000) := 'jeff.phillipson@ap.effem.com';
        DB_Name              CONSTANT VARCHAR2(20)   := 'MFA005_MANU_APP';
        LOCATION             CONSTANT VARCHAR2(20)   := 'MFANZ Food';
        ENVIRONMENT          CONSTANT VARCHAR2(20)   := 'MFA005 - Production';  
        MANAGERS_LOCAL_SUPPORT CONSTANT VARCHAR2(200)  :=  '"MFANZ Local Site Support ATLAS"@esosn1';
        EMAIL_SERVER         CONSTANT VARCHAR2(200)  := 'esosn1.ap.mars';     													

        
      
                             
	END;
/


DROP PUBLIC SYNONYM MANU_COMMON;

CREATE PUBLIC SYNONYM MANU_COMMON FOR MANU_APP.MANU_COMMON;


