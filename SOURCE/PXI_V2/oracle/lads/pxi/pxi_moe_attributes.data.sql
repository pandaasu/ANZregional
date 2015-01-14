/*******************************************************************************
/* Table Data
/*******************************************************************************
 System : pxi
 Table  : pxi_moe_attributes
*******************************************************************************/

-- Clear Table
delete from pxi_moe_attributes;

-- Populate Table
insert into pxi_moe_attributes (moe_code,interface_suffix,px_company_code,px_division_code,location_code,system_code) 
values ('009','1','147','01','AU','PX_AU_SNACK');
insert into pxi_moe_attributes (moe_code,interface_suffix,px_company_code,px_division_code,location_code,system_code) 
values ('0021','2','147','02','AU','PX_AU_FOOD');
insert into pxi_moe_attributes (moe_code,interface_suffix,px_company_code,px_division_code,location_code,system_code) 
values ('0196','3','147','05','AU','PX_AU_PETCARE');
insert into pxi_moe_attributes (moe_code,interface_suffix,px_company_code,px_division_code,location_code,system_code) 
values ('0086','4','149','149','NZ','PX_NZ');

-- Commit Data
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

