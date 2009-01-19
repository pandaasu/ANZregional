create or replace function manu_app.get_alternate(matl in varchar2, xdate in date default sysdate) return varchar2 is
/****************************************************

Function to get the alternate version number for the material entered 

This is used to provide BOM data in VIEW BOM_NOW_VW which only 
provides valid data based on SYSDATE ie the time it is viewed - now

The output is the correct Alternate number to use 

Note this is used in conjunction with GET_ALTERNATE_DATE to get the 
     correct date.
     
     
Author:  Jeff Phillipson  7/7/2004 

****************************************************/
  
  v_alt    varchar2(4);
     
begin

  select r.alternate 
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
        return 1;
end;
/

grant execute on manu_app.get_alternate to manu;
grant execute on manu_app.get_alternate to appsupport;

create or replace public synonym get_alternate for manu_app.get_alternate;