DROP FUNCTION MANU_APP.DATEDIFF;

CREATE OR REPLACE FUNCTION MANU_APP.Datediff( p_what IN VARCHAR2, 
                                         p_d1   IN DATE, 
                                         p_d2   IN DATE ) RETURN NUMBER 
    AS 
        l_result    NUMBER; 
    BEGIN 
        SELECT (p_d2-p_d1) * 
               DECODE( UPPER(p_what), 
                       'SS', 24*60*60, 'MI', 24*60, 'HH', 24, NULL ) 
        INTO l_result FROM dual; 
  
       RETURN l_result; 
   END;
/


DROP PUBLIC SYNONYM DATEDIFF;

CREATE PUBLIC SYNONYM DATEDIFF FOR MANU_APP.DATEDIFF;


