create or replace function manu_app.get_bom_batch_qty(par_matl in  varchar2) return number is
/*******************************************************************************
    NAME:      Get_Bom_Batch_Qty
    PURPOSE:   Gets tha Batch quantity of the Bom for a given material code 

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   7/7/2004  Jeff Phillipson          Created this procedure.
    1.2   7/1/2009  Trevor Keon              Changed query to use BDS tables

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 Load Material                           material code
   \
    

    RETURN VALUE:			 Batch qty based on BOM value for material code entered
    ASSUMPTIONS:
    NOTES:		 			 
  ********************************************************************************/
   
  var_matl    varchar2(8);
  var_qty     number;
       
begin
     
  var_matl := ltrim(par_matl,'0');
  
  select t01.bom_base_qty
  into var_qty
  from bds_bom_all t01
  where t01.bom_plant = 'AU30'
    and t01.item_number is not null
    and t01.bom_material_code = par_matl
    and t01.bom_alternative = get_alternate(t01.bom_material_code) 
    and decode(t01.bom_eff_from_date, null, t01.item_eff_from_date, t01.bom_eff_from_date) = get_alternate_date(t01.bom_material_code)
  group by t01.bom_base_qty;
     
  return var_qty;
   
exception
  when others then
    raise_application_error(-20000, 'MANU. Get_BOM_BATCH_QTY function - ' || substr(sqlerrm, 1, 512));
end;
/

grant execute on manu_app.get_bom_batch_qty to appsupport;
grant execute on manu_app.get_bom_batch_qty to bthsupport;

create or replace public synonym get_bom_batch_qty for manu_app.get_bom_batch_qty;