DROP PROCEDURE MANU_APP.RAWS_HOLD_UPDATE_PROC;

CREATE OR REPLACE PROCEDURE MANU_APP.RAWS_HOLD_UPDATE_PROC IS

/*********************************************************************************
 Created by Ricardo Carneiro  16/11/05 
 This procedure populates the RAW_HOLD table. 
  
 //This procedure updates the raw_hold table with the updated data from table
 //raw_hold_tmp, which itself is populated by SQL loader with data passed
 //from Tolas.

*******************************************************************************
*  REVISIONS:
*  Ver   DATE        Author            Description
*  ----  ----------  ----------------  -----------------------------------------
*  1.0   16/11/2005  Ricardo Carneiro  Created Procedure.
*  
**********************************************************************************/

v_dspstn_code   raw_hold.dspstn_code%TYPE;

CURSOR csr_get_load_records IS
SELECT 
 pallet_no,
 material_code,
 qty,
 uom,
 dspstn_code,
 manufacture_date,
 use_by_date,
 tolas_matl_desc,
 receipt_date
FROM 
 raw_hold_tmp;
      
      
CURSOR csr_check_raw (p_pallet_no IN VARCHAR2, p_material_code IN VARCHAR2) IS
SELECT
 dspstn_code
FROM 
 raw_hold
WHERE
 pallet_no = p_pallet_no
 AND material_code = p_material_code;

BEGIN
 FOR recs in csr_get_load_records LOOP
     OPEN csr_check_raw (recs.pallet_no, recs.material_code);
        FETCH csr_check_raw INTO v_dspstn_code;
       IF csr_check_raw%NOTFOUND THEN
    INSERT INTO raw_hold
     (pallet_no, 
     material_code,
     qty,
     uom,
     dspstn_code,
     manufacture_date,
     use_by_date,
     tolas_matl_desc,
     receipt_date,
     status)
       VALUES 
     (recs.pallet_no,
     recs.material_code,
     recs.qty,
     recs.uom,
     recs.dspstn_code,
     recs.manufacture_date,
     recs.use_by_date,
     recs.tolas_matl_desc,
     recs.receipt_date,
     'NEW');
        ELSE
         IF not(recs.dspstn_code = v_dspstn_code) THEN
     UPDATE raw_hold
     set dspstn_code = recs.dspstn_code
     where pallet_no = recs.pallet_no
     and material_code = recs.material_code;
    END IF;   
   END IF;    
  CLOSE csr_check_raw;
 END LOOP;
 
 COMMIT;
 
 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     RAISE_APPLICATION_ERROR(-20100, 'ERROR Occured while '||SQLERRM(SQLCODE));
END RAWS_HOLD_UPDATE_PROC;
/


