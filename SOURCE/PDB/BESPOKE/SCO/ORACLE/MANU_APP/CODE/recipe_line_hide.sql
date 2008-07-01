DROP FUNCTION MANU_APP.RECIPE_LINE_HIDE;

CREATE OR REPLACE FUNCTION MANU_APP.Recipe_Line_Hide(i_proc_order IN VARCHAR2, i_opertn IN VARCHAR2, i_phase IN VARCHAR2) RETURN VARCHAR2 IS

/******************************************************************************
   NAME:       RECIPE_LINE_HIDE
   PURPOSE:    To define if the header line hav lower level data
               if not the line should be hidden

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/06/2007   Jeff Phillipson 1. Created this function.

   NOTES:     Return 'H' to hide the line
                     'D' to display the line

   Automatically available Auto Replace Keywords:
      Object Name:     RECIPE_LINE_HIDE
      Sysdate:         14/06/2007

******************************************************************************/

    CURSOR csr_hide_op
    IS
    SELECT DECODE(COUNT(*),0,'H','D') 
      FROM (SELECT COUNT(VALUE), 
                  opertn,
                  proc_order
             FROM (SELECT opertn, t01.proc_order, t02.matl_code VALUE
                     FROM recpe_hdr t01,
                          recpe_dtl t02
                    WHERE t01.cntl_rec_id = t02.cntl_rec_id
                   UNION ALL
                   SELECT opertn, t01.proc_order, mpi_val
                     FROM recpe_hdr t01,
                          recpe_val t02
                    WHERE t01.cntl_rec_id = t02.cntl_rec_id
                      AND SUBSTR(trim(mpi_val),0,1) <> '?' 
                      AND recpe_val_type <> 'VH'
                   UNION ALL
                   SELECT opertn,  t01.proc_order, mpi_text
                     FROM cntl_rec_mpi_txt t01)
            WHERE proc_order = i_proc_order
              AND opertn = i_opertn OR i_opertn IS NULL
            GROUP BY opertn, proc_order);
    
    CURSOR csr_hide_ph
    IS
    SELECT DECODE(COUNT(*),0,'H','D') 
      FROM (SELECT COUNT(VALUE), 
                  opertn,
                  proc_order
             FROM (SELECT opertn, phase, t01.proc_order, t02.matl_code VALUE
                     FROM recpe_hdr t01,
                          recpe_dtl t02
                    WHERE t01.cntl_rec_id = t02.cntl_rec_id
                   UNION ALL
                   SELECT opertn, phase, t01.proc_order, mpi_val
                     FROM recpe_hdr t01,
                          recpe_val t02
                    WHERE t01.cntl_rec_id = t02.cntl_rec_id
                      AND SUBSTR(trim(mpi_val),0,1) <> '?' 
                      AND recpe_val_type <> 'VH'
                   UNION ALL
                   SELECT opertn, phase,  t01.proc_order, mpi_text
                     FROM cntl_rec_mpi_txt t01)
            WHERE proc_order = i_proc_order
              AND opertn = i_opertn OR i_opertn IS NULL
              AND phase = i_phase OR i_phase IS NULL
            GROUP BY opertn, phase, proc_order);
            
    var_work VARCHAR2(100);
    
BEGIN
    IF i_phase IS NULL THEN
        OPEN csr_hide_op;
            FETCH csr_hide_op INTO var_work;
            IF csr_hide_op%NOTFOUND THEN
                 var_work := 'H';
            END IF;
        CLOSE csr_hide_op;
    ELSE
        OPEN csr_hide_ph;
            FETCH csr_hide_ph INTO var_work;
            IF csr_hide_ph%NOTFOUND THEN
                 var_work := 'H';
            END IF;
        CLOSE csr_hide_ph;
    END IF;
   RETURN var_work;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 'D';
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RETURN 'D';
END Recipe_Line_Hide;
/


DROP PUBLIC SYNONYM RECIPE_LINE_HIDE;

CREATE PUBLIC SYNONYM RECIPE_LINE_HIDE FOR MANU_APP.RECIPE_LINE_HIDE;


