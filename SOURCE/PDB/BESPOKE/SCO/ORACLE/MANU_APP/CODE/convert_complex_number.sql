DROP FUNCTION MANU_APP.CONVERT_COMPLEX_NUMBER;

CREATE OR REPLACE FUNCTION MANU_APP.Convert_Complex_Number(par_value IN VARCHAR2) RETURN NUMBER IS
/******************************************************************************
   NAME:       convert_complex_number
   PURPOSE:    this function is used to calulate the target weight values for
               RECPE_FCS_VW

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/10/2007   Jeff Phillipson       1. Created this function.

   NOTES:     par_value eg '61.9/4+3.4'

******************************************************************************/
    var_value NUMBER;
BEGIN
   EXECUTE IMMEDIATE 'select TO_NUMBER(' || par_value  || ') FROM dual' INTO var_value;
   RETURN var_value;
EXCEPTION
     WHEN OTHERS THEN
       RETURN 0;
END Convert_Complex_Number;
/


DROP PUBLIC SYNONYM CONVERT_COMPLEX_NUMBER;

CREATE PUBLIC SYNONYM CONVERT_COMPLEX_NUMBER FOR MANU_APP.CONVERT_COMPLEX_NUMBER;


GRANT EXECUTE ON MANU_APP.CONVERT_COMPLEX_NUMBER TO APPSUPPORT;

