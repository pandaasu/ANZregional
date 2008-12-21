DROP FUNCTION MANU_APP.USER_ROLE;

CREATE OR REPLACE FUNCTION MANU_APP.User_Role(i_userid IN VARCHAR2)  RETURN VARCHAR2 IS
  
      var_return VARCHAR2(4000);
	  var_work VARCHAR2(20);
		
		CURSOR cur_role IS
      SELECT granted_role FROM DBA_ROLE_PRIVS
		 WHERE grantee = UPPER(i_userid)
         AND granted_role IN ('PR_USER','PR_FDR_ISSR')
		 ORDER BY 1 ASC;
		
  BEGIN
  
  		var_return := 'OK';  -- default 
		
      OPEN cur_role;
      LOOP
         FETCH cur_role INTO var_work;
         EXIT WHEN cur_role%NOTFOUND;
		
			   var_work := trim(UPPER(var_work));
			   IF var_work = 'PR_ADMIN' THEN
			       var_return := '3 OK';
				   EXIT;
			   END IF;
		       IF var_work = 'PR_FDR_ISSR' THEN
			      var_return := '2 OK';
				  EXIT;
			   END IF;
			   IF var_work = 'PR_USER' THEN
			      var_return := '1 OK';
					EXIT;
			   END IF;
      END LOOP;
      CLOSE cur_role;
  RETURN var_return;
		
  EXCEPTION
      WHEN OTHERS THEN
  		  RETURN 'Oracle error ' || SQLCODE || ' -ERROR- '|| SUBSTR(SQLERRM,0,2000);	
  
  END;
/


DROP PUBLIC SYNONYM USER_ROLE;

CREATE PUBLIC SYNONYM USER_ROLE FOR MANU_APP.USER_ROLE;


GRANT EXECUTE ON MANU_APP.USER_ROLE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.USER_ROLE TO PUBLIC;

