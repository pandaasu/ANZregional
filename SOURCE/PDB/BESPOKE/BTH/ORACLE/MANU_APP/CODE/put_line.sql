DROP PROCEDURE MANU_APP.PUT_LINE;

CREATE OR REPLACE PROCEDURE MANU_APP.Put_Line(
    v_string     IN VARCHAR2,
    v_len        IN INTEGER)
AS
    v_curr_pos   INTEGER;
    v_length     INTEGER;
    v_printed_to INTEGER;
    v_last_ws    INTEGER;
    skipping_ws  BOOLEAN;

BEGIN

  IF (v_string IS NULL) THEN
    RETURN;
  END IF;

  v_length := LENGTH(v_string);

  v_curr_pos    :=  0;
  v_printed_to  := -1;
  v_last_ws     := -1;
  skipping_ws   := TRUE;

  WHILE v_curr_pos < v_length LOOP

    IF SUBSTR(v_string,v_curr_pos+1,1) = ' ' THEN
      v_last_ws := v_curr_pos;
      IF skipping_ws THEN
        v_printed_to := v_curr_pos;
      END IF;
    ELSE
      skipping_ws := FALSE;
    END IF;

    IF v_curr_pos >= v_printed_to + v_len THEN
      IF v_last_ws <= v_printed_to THEN
        DBMS_OUTPUT.PUT_LINE(SUBSTR(v_string,v_printed_to+2,v_curr_pos-v_printed_to));
        v_printed_to:=v_curr_pos;
        skipping_ws := TRUE;
      ELSE
        DBMS_OUTPUT.PUT_LINE(SUBSTR(v_string,v_printed_to+2,v_last_ws-v_printed_to));
        v_printed_to := v_last_ws;
        skipping_ws := TRUE;
      END IF;
    END IF;

    v_curr_pos := v_curr_pos + 1; 

  END LOOP;

  DBMS_OUTPUT.PUT_LINE (SUBSTR(v_string,v_printed_to+1));

END Put_Line;
/


GRANT EXECUTE ON MANU_APP.PUT_LINE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.PUT_LINE TO BTHSUPPORT;

