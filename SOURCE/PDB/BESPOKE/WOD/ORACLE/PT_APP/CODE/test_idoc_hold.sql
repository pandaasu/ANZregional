DROP PROCEDURE PT_APP.TEST_IDOC_HOLD;

CREATE OR REPLACE PROCEDURE PT_APP."TEST_IDOC_HOLD" IS
BEGIN 

 IF Idoc_Hold THEN
  DBMS_OUTPUT.PUT_LINE('Statement was TRUE  ==> IDOCs are currently being held');
 ELSE
  DBMS_OUTPUT.PUT_LINE('Statement was FALSE  ==> IDOCs are currently processing into ATLAS');
 END IF;

END;
/


