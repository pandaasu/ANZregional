/********************************************************************/
/* This script updates the teco status for a given process order    */
/********************************************************************/
declare
  var_proc_order bds_recipe_header.proc_order%type;
  var_plant_code bds_recipe_header.plant_code%type;
begin
  var_proc_order := '000001101188';
  var_plant_code := 'AU40';
  
  update_teco_status(var_proc_order, var_plant_code, 'YES');
end;