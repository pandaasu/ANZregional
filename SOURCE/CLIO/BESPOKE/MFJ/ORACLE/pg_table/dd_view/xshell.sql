/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : xxx
 Owner  : od

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.xxx
   (

/*-*/
/* Authority
/*-*/
grant select on od.xxx to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym xxx for od.xxx;


