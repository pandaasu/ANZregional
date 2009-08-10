/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : reason_codes
 Owner   : pt
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - reason_codes

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt.reason_codes
(
  reason_code       varchar2(4 byte),
  reason_code_desc  varchar2(32 byte),
  cost_centre       varchar2(32 byte)
);

/**/
/* authority 
/**/
grant select on pt.reason_codes to appsupport;
grant select on pt.reason_codes to pt_app with grant option;
grant delete, insert, update on pt.reason_codes to pt_app;

/**/
/* synonym 
/**/
create or replace public synonym reason_codes for pt.reason_codes;