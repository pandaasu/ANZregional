create or replace function manu_app.get_bom_batch_qty(matl in  varchar2) return number is
/****************************************************

Function to get the alternate version number for the material entered 

This is used to provide BOM quantity data in VIEW RECIPE_FCS_VW 
rather than the process order quantity

The output is the correct qty based on BOM value number to use 
   
     
Author:  Jeff Phillipson  7/10/2004 

****************************************************/

   
  v_matl    varchar2(8);
  v_qty     number;
     
  cursor c1 is
    select distinct decode (t01.bom_base_qty, '0', null, t01.bom_base_qty)
    from bds_bom_all t01
    where ltrim(t01.bom_material_code, '0') = v_matl
      and t01.bom_alternative = get_alternate(bom_material_code) 
      and nvl(t01.bom_eff_from_date, to_date ('20000101', 'yyyymmdd')) = get_alternate_date(bom_material_code);      
   
begin
     
  v_matl := ltrim(matl,'0');
  
  open c1;
    fetch c1 into v_qty;
  close c1;
   
return v_qty;
   
exception   
  when others then
    raise_application_error(-20000, 'MANU. Get_BOM_BATCH_QTY function - ' || substr(sqlerrm, 1, 512));
end;
/

grant execute on manu_app.get_bom_batch_qty to appsupport;

create or replace public synonym get_bom_batch_qty for manu_app.get_bom_batch_qty;