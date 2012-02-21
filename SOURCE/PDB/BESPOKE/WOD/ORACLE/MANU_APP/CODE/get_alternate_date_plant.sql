create or replace function manu_app.get_alternate_date_plant(par_matl in  varchar2, par_plant in varchar2, par_xdate in date default sysdate) return date is

/*******************************************************************************
    NAME:      Get_Alternate_Date_Plant
    PURPOSE:   Function to get the alternate version date for the material entered 
               his is used to provide BOM data in VIEW BOM_NOW_VW which only 
					provides valid data based on SYSDATE ie the time it is viewed - now

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   7/7/2004  Jeff Phillipson          Created this procedure.
    1.1   11/1/2008 Daniel Owen           Added plant filter
    1.2   15/4/2009 Trevor Keon              Changed query to use BDS tables

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 Load Material                           material code
    2    IN     VARCHAR2 Plant                                AU20
    3    IN     DATE     Input date - default is sysdate      date of interest
    

    RETURN VALUE:			 correct Alternate date to use 
    ASSUMPTIONS:
    NOTES:		 			 This is used in conjunction with GET_ALTERNATE_DATE to get the 
     							 correct date.
  ********************************************************************************/
  
  var_alt date;
  
begin
   
  select r.eff_start_date 
  into var_alt
  from 
    (
      select decode(t01.bom_alternative, null, '1', t01.bom_alternative) as alt,
        decode(t01.bom_eff_from_date, null, t01.item_eff_from_date, t01.bom_eff_from_date) as eff_start_date
      from bds_bom_all t01
      where t01.item_number is not null
        and t01.bom_plant = par_plant
        and t01.bom_material_code = par_matl
        and decode(t01.bom_eff_from_date, null, t01.item_eff_from_date, t01.bom_eff_from_date) <= par_xdate
      order by 2 desc
    ) r 
  where rownum = 1;
     
  return var_alt;
   
exception
  when others then
    raise_application_error(-20000, 'MANU.Get_Alternate_Date_Plant function - ' || substr(sqlerrm, 1, 512));
end;
/


