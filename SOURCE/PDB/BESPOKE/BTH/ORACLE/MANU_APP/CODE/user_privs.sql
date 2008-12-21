DROP FUNCTION MANU_APP.USER_PRIVS;

CREATE OR REPLACE FUNCTION MANU_APP.USER_PRIVS(i_userid IN VARCHAR2) RETURN NUMBER IS
  
  var_work VARCHAR2(32);
  var_return NUMBER;
  var_userid VARCHAR2(20) DEFAULT '';
  
  CURSOR cur_role IS
      SELECT trim(UPPER(granted_role)) FROM DBA_ROLE_PRIVS
		 WHERE grantee = UPPER(i_userid)
         AND granted_role IN ('PR_ADMIN','PR_USER')
		ORDER BY 1;
  
  BEGIN
      var_return := Re_Timing_Common.NOACCESS;
		OPEN cur_role;
      LOOP
         FETCH cur_role INTO var_work;
         EXIT WHEN cur_role%NOTFOUND;
			   var_work := trim(UPPER(var_work));
				IF var_work = 'PR_USER' THEN
			      var_return := Re_Timing_Common.READONLY;
					EXIT;
			   END IF;
				
		      IF var_work = 'PR_ADMIN' THEN
			      var_return := Re_Timing_Common.EDIT;
					
					IF Get_Edit_Status = FALSE THEN
					    var_return := Re_Timing_Common.READONLY;
					END IF;
					
			  	   EXIT;
			   END IF;
			   
      END LOOP;
      CLOSE cur_role;
		
		RETURN TO_CHAR(var_return);
		
  EXCEPTION
      WHEN OTHERS THEN
  			   RETURN 'Oracle error ' || SQLCODE || ' -ERROR- '|| SUBSTR(SQLERRM,0,2000);	
  END USER_PRIVS;
/


