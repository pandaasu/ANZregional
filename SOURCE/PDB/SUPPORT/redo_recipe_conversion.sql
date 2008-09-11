/********************************************************************/
/* This script re-runs recipe conversion for a given control recipe */
/********************************************************************/
declare
	var_cntl_rec_id number;
begin
	var_cntl_rec_id := 100000000000453870;

	delete from recpe_dtl where cntl_rec_id = var_cntl_rec_id;
	delete from recpe_val where cntl_rec_id = var_cntl_rec_id;
	delete from recpe_resrce where cntl_rec_id = var_cntl_rec_id;
	delete from recpe_hdr where cntl_rec_id = var_cntl_rec_id;
	commit;

	recipe_conversion.execute (var_cntl_rec_id);
	commit;
end;