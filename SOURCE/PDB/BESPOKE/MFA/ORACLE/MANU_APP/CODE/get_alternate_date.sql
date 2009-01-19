create or replace function manu_app.get_alternate_date(matl in  varchar2, xdate in date default sysdate) return date is
/****************************************************

Function to get the alternate no for the material entered 

This is used to provide BOM data in VIEW BOM_NOW_VW which only
provides valid data based on SYSDATE ie the time it is viewed.

Note this is used in conjunction with GET_ALTERNATE to get the 
     correctalternate value 
     

Author:  Jeff Phillipson  7/7/2004 

****************************************************/
   
  v_alt    date;
 
begin

  select r.eff_start_date
  into v_alt
  from 
  (
    select decode(t01.bom_alternative,null,'1', t01.bom_alternative) as alternate, 
      nvl(t01.bom_eff_from_date, to_date('20000101','yyyymmdd')) as eff_start_date
    from bds_bom_all t01
    where t01.bom_material_code = matl
      and nvl(t01.bom_eff_from_date, to_date('20000101','yyyymmdd')) <= xdate
    order by 2 desc
  ) r
  where rownum = 1;
   
  return v_alt;
   
exception
  when others then
    raise_application_error(-20000, 'MANU.Get_Alternate function - ' || substr(sqlerrm, 1, 512));
end;
/

grant execute on manu_app.get_alternate_date to cl_app;
grant execute on manu_app.get_alternate_date to manu;

create or replace public synonym get_alternate_date for manu_app.get_alternate_date;