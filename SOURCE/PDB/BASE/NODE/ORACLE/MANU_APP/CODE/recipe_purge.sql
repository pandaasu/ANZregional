create or replace procedure manu_app.recipe_purge is
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

create or replace public synonym recipe_purge for manu_app.recipe_purge;

grant execute on manu_app.recipe_purge to appsupport;
grant execute on manu_app.recipe_purge to bds_app;
grant execute on manu_app.recipe_purge to lics_app;