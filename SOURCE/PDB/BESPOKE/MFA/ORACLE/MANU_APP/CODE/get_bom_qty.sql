create or replace function manu_app.get_bom_qty(matl in  varchar2, sub in varchar2, seq in varchar2) return number is
/****************************************************

Function to get the alternate version number for the material entered 

This is used to provide BOM quantity data in VIEW RECIPE_FCS_VW 
rather than the process order quantity

The output is the correct qty based on BOM value number to use 
   
     
Author:  Jeff Phillipson  7/7/2004 

****************************************************/
   
  v_matl    varchar2(8);
  v_sub     varchar2(8);
  v_seq     varchar2(4);
  v_qty     number;
     
  cursor c1 is
    select max(qty) qty 
    from 
    (
      select level as lvl, 
        ltrim (t01.bom_material_code, '0') as material, 
        ltrim (t01.item_material_code, '0') as sub_matl,
        t01.item_base_qty as qty, 
        ltrim (t01.item_number, '0') as seq 
      from bds_bom_all t01
      where level < 2
      start with ltrim (t01.bom_material_code, '0') = v_matl
        and t01.bom_alternative = get_alternate(bom_material_code) 
        and nvl (t01.bom_eff_from_date, to_date ('20000101', 'yyyymmdd')) = get_alternate_date(bom_material_code)
      connect by prior t01.item_material_code = t01.bom_material_code
    ) r
    where sub_matl = v_sub
      and ltrim(seq,'0') = v_seq;
   
begin
     
  v_matl := ltrim(matl,'0');
  v_sub :=  ltrim(sub,'0');
  v_seq :=  ltrim(seq,'0');
     
  if length(v_seq) = 0 then
    v_seq := '0';
  end if;
     
  open c1;
    fetch c1 into v_qty;
  close c1;
     
  return v_qty;
   
exception 
  when others then
    raise_application_error(-20000, 'MANU. Get_BOM_QTY function - ' || substr(sqlerrm, 1, 512));
end;
/

grant execute on manu_app.get_bom_qty to appsupport;

create or replace public synonym get_bom_qty for manu_app.get_bom_qty;