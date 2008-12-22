DROP PROCEDURE MANU_APP.RECIPE_PURGE;

CREATE OR REPLACE PROCEDURE MANU_APP.recipe_purge is
/******************************************************************************
   NAME:       recipe_purge
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07-Sep-05          1. Created this procedure.
   NOTES:
   This procedure will delete all records from the RECPE_.. tables
   where they don't exist in the main proc_order table
******************************************************************************/
begin
  /*-*/
  /* delete recipe records 
  /*-*/
  delete 
  from recpe_dtl
  where cntl_rec_id not in (select cntl_rec_id from cntl_rec);

  delete 
  from recpe_resrce
  where cntl_rec_id not in (select cntl_rec_id from cntl_rec);

  delete 
  from recpe_val
  where cntl_rec_id not in (select cntl_rec_id from cntl_rec);
  	 
  delete 
  from recpe_hdr
  where cntl_rec_id not in (select cntl_rec_id from cntl_rec);	 
	 
  commit;
	
exception
  when others then
    rollback;
    raise_application_error(-20000, 'Recipe_Purge failed ' || 'Oracle error ' || substr(sqlerrm, 1, 1000));
       
end recipe_purge;
/


DROP PUBLIC SYNONYM RECIPE_PURGE;

CREATE PUBLIC SYNONYM RECIPE_PURGE FOR MANU_APP.RECIPE_PURGE;


GRANT EXECUTE ON MANU_APP.RECIPE_PURGE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RECIPE_PURGE TO BDS_APP;

GRANT EXECUTE ON MANU_APP.RECIPE_PURGE TO LICS_APP;

