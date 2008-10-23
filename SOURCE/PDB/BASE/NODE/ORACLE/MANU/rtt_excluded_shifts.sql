/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 Table   : rtt_excluded_shifts
 Owner   : manu 
 Author  : Daniel Owen

 Description 
 ----------- 
 Manufacturing - rtt_excluded_shifts

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/10   Daniel Owen    Created

*******************************************************************************/

/**/
/* Table creation 
/**/
create table manu.rtt_excluded_shifts
(
  shift_type_code  char(10 byte)                not null
);


grant delete, insert, select, update on manu.rtt_excluded_shifts to manu_app;