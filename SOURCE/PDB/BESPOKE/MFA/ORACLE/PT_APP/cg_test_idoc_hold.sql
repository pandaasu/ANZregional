DROP PROCEDURE PT_APP.CG_TEST_IDOC_HOLD;

CREATE OR REPLACE PROCEDURE PT_APP.cg_test_idoc_hold is
begin

 if IDOC_HOLD then
  dbms_output.put_line('Statement was TRUE  ==> IDOCs are currently being held');
 else
  dbms_output.put_line('Statement was FALSE  ==> IDOCs are currently processing into ATLAS');
 end if;

end;
/


