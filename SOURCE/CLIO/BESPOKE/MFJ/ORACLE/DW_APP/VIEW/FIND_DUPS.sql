/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : find_dups
 Owner  : dw_app

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
create or replace force view find_dups
   (SHIP_TO_CUST_CODE, SOLD_TO_CUST_CODE, DISTBN_CHNL_CODE, DIVISION_CODE, SALES_ORG_CODE, 
 SALES_FORCE_GEO_HIER_CUST_CODE)
AS 
(SELECT /*+ FULL(A) */ 
     A.SHIP_TO_CUST_CODE          AS SHIP_TO_CUST_CODE, 
     A.SOLD_TO_CUST_CODE          AS SOLD_TO_CUST_CODE, 
     A.SALES_DTL_DISTBN_CHNL_CODE AS DISTBN_CHNL_CODE, 
     A.SALES_DTL_DIVISION_CODE    AS DIVISION_CODE, 
     A.SALES_DTL_SALES_ORG_CODE   AS SALES_ORG_CODE, 
     DECODE(B.CUST_PARTNER_CODE, NULL, DECODE(C.CUST_PARTNER_CODE, NULL, NULL, C.CUST_PARTNER_CODE), B.CUST_PARTNER_CODE)  AS SALES_FORCE_GEO_HIER_CUST_CODE 
   FROM 
     SALES_FACT         A, 
     CUST_PARTNER_FUNCN B, 
     CUST_PARTNER_FUNCN C 
   WHERE 
         A.SHIP_TO_CUST_CODE          = B.CUST_CODE (+) 
     AND A.SALES_DTL_SALES_ORG_CODE   = B.SALES_ORG_CODE (+) 
     AND A.SALES_DTL_DISTBN_CHNL_CODE = B.DISTBN_CHNL_CODE (+) 
     AND A.SALES_DTL_DIVISION_CODE    = B.DIVISION_CODE (+) 
     AND B.PARTNER_FUNCN_CODE (+)     = 19 
     AND A.SOLD_TO_CUST_CODE          = C.CUST_CODE (+) 
     AND A.SALES_DTL_SALES_ORG_CODE   = C.SALES_ORG_CODE (+) 
     AND A.SALES_DTL_DISTBN_CHNL_CODE = C.DISTBN_CHNL_CODE (+) 
     AND A.SALES_DTL_DIVISION_CODE    = C.DIVISION_CODE (+) 
     AND C.PARTNER_FUNCN_CODE (+)     = 19 
     AND DECODE(B.CUST_PARTNER_CODE, NULL, DECODE(C.CUST_PARTNER_CODE, NULL, 0, 1), 1) = 1 
   GROUP BY 
     A.SHIP_TO_CUST_CODE, 
     A.SOLD_TO_CUST_CODE, 
     A.SALES_DTL_DISTBN_CHNL_CODE, 
     A.SALES_DTL_DIVISION_CODE, 
     A.SALES_DTL_SALES_ORG_CODE, 
     DECODE(B.CUST_PARTNER_CODE, NULL, DECODE(C.CUST_PARTNER_CODE, NULL, NULL, C.CUST_PARTNER_CODE), B.CUST_PARTNER_CODE) 
   );

/*-*/
/* Authority
/*-*/
grant select on dw_app.find_dups to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym find_dups for dw_app.find_dups;