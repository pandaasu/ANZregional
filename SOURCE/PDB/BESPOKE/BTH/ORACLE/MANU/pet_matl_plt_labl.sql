/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 Table   : pet_matl_plt_labl
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - pet_matl_plt_labl

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2009/01   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table manu.pet_matl_plt_labl
( 
  matl_code	        varchar2(18 char),
  matl_desc         varchar2(40 char),
  plant	            varchar2(4 char),	
  matl_type         varchar2(4 char),	
  rgnl_code_nmbr    varchar2(18 char),	
  base_uom          varchar2(3 char),	
  altrntv_uom       varchar2(3 char),	
  net_wght          number,	
  ean_code          varchar2(19 char),	
  shelf_life        number,	
  trdd_unit         varchar2(1 char),	
  semi_fnshd_prdct  varchar2(1 char),	
  vndr_code         varchar2(10 char),	
  vndr_name         varchar2(35 char),	
  crtns_per_pllt    number	  
);

/**/
/* Indexes  
/**/
create index manu.pet_matl_plt_labl_idx01 on manu.pet_matl_plt_labl(matl_type, trdd_unit);
create index manu.pet_matl_plt_labl_idx02 on manu.pet_matl_plt_labl(matl_code, plant);
create index manu.pet_matl_plt_labl_idx03 on manu.pet_matl_plt_labl(semi_fnshd_prdct);

/**/
/* Authority 
/**/
grant select, update, delete, insert on manu.pet_matl_plt_labl to manu_app with grant option;
grant select on manu.pet_matl_plt_labl to bds_app with grant option;
grant select on manu.pet_matl_plt_labl to pt_app with grant option;
grant select on manu.pet_matl_plt_labl to manu_user;

/**/
/* Synonym 
/**/
create or replace public synonym pet_matl_plt_labl for manu.pet_matl_plt_labl;