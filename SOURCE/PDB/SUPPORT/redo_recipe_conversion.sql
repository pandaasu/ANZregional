/********************************************************************/
/* This script re-runs recipe conversion for a given control recipe */
/********************************************************************/


DECLARE
	var_cntl_rec_id NUMBER;
BEGIN
	var_cntl_rec_id := 100000000000453870;

	DELETE FROM recpe_dtl WHERE cntl_rec_id = var_cntl_rec_id;
	DELETE FROM recpe_val WHERE cntl_rec_id = var_cntl_rec_id;
	DELETE FROM recpe_resrce WHERE cntl_rec_id = var_cntl_rec_id;
	DELETE FROM recpe_hdr WHERE cntl_rec_id = var_cntl_rec_id;
	COMMIT;

	recipe_conversion.EXECUTE (var_cntl_rec_id);
	COMMIT;
END;