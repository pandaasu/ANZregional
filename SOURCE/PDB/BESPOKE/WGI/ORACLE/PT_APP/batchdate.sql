DROP FUNCTION PT_APP.BATCHDATE;

CREATE OR REPLACE FUNCTION PT_APP.Batchdate(i_batch  IN VARCHAR2) RETURN VARCHAR2 IS

/******************************************************************************
   NAME:       BatchDate
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/01/2005   Jeff Phillipson 1. Created this function.

   
******************************************************************************/
    Batchdate VARCHAR2(20);
    test VARCHAR2(20);-- DEFAULT  '522C1WGI01';
    Byear VARCHAR2(45); 
    Bmonth VARCHAR2(2);
    Bday VARCHAR2(1); 
    v_count NUMBER; 
    offset VARCHAR2(20) ;                                                                       
    voffset NUMBER;
                                                                              
BEGIN

   test := i_batch;
   -- get year 
   Byear := '01/01/' || SUBSTR(TO_CHAR(SYSDATE,'yyyymmdd'),1,3) || SUBSTR(test,1,1) ;
   offset := TO_CHAR(TO_DATE(Byear,'dd/mm/yyyy'),'day');
   IF RTRIM(LTRIM(offset)) = 'monday' THEN
      voffset := 1;
   END IF;
   IF RTRIM(LTRIM(offset)) = 'tuesday' THEN
      voffset := 2;
   END IF;
   IF RTRIM(LTRIM(offset)) = 'wednesday' THEN
      voffset := 3;
   END IF;
   IF RTRIM(LTRIM(offset)) = 'thursday' THEN
      voffset := 4;
   END IF;
   IF RTRIM(LTRIM(offset)) = 'friday' THEN
      voffset := 5;
   END IF;
   IF RTRIM(LTRIM(offset)) = 'saturday' THEN
      voffset := 6;
   END IF;
   IF RTRIM(LTRIM(offset)) = 'sunday' THEN
      voffset := 7;
   END IF;
   
   
   --dbms_output.put (offset || TO_CHAR(voffset));
   -- get month
   Bmonth := SUBSTR(test,2,2);
   -- save as number
   v_count := (TO_NUMBER(Bmonth)-1)* 7;
   -- get day of week
   Bday := UPPER(SUBSTR(test,4,1));
   IF bday = 'A' THEN
       v_count := v_count + 1-voffset;
   END IF;
   IF bday = 'B' THEN
       v_count := v_count + 2-voffset;
   END IF;
   IF bday = 'C' THEN
       v_count := v_count + 3-voffset;
   END IF;
   IF bday = 'D' THEN
       v_count := v_count + 4-voffset;
   END IF;
   IF bday = 'E' THEN
       v_count := v_count + 5-voffset;
   END IF;
   IF bday = 'F' THEN
       v_count := v_count + 6-voffset;
   END IF;
   IF bday = 'G' THEN
       v_count := v_count + 7-voffset;
   END IF;
   IF bday NOT IN ('A','B','C','D','E','F','G') THEN
       Batchdate  := 'Wrong day of week';
   ELSE
       Batchdate :=   TO_DATE(Byear,'dd/mm/yyyy') + v_count;
   END IF;
   
   
   RETURN Batchdate;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Batchdate;
/


