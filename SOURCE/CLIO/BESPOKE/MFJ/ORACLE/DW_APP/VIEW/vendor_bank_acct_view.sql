/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : vendor_bank_acct_view
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
create or replace force view dw_app.vendor_bank_acct_view
   (SAP_VENDOR_CODE,
    VENDOR_BANK_NAME,
    VENDOR_BANK_BRNCH_NAME,
    VENDOR_BANK_ACCT_TYPE_CODE,
    VENDOR_BANK_ACCT_NUM, 
    BANK_KEY,
    SAP_CNTRY_CODE,
    VENDOR_BANK_ACCT_LUPDT) AS 
   SELECT T2.SAP_VENDOR_CODE, 
          T2.VENDOR_BANK_NAME, 
          T2.VENDOR_BANK_BRNCH_NAME, 
          T2.VENDOR_BANK_ACCT_TYPE_CODE, 
          T2.VENDOR_BANK_ACCT_NUM, 
          T2.BANK_KEY, 
          T2.SAP_CNTRY_CODE,
          T1.VENDOR_LUPDT 
     FROM (SELECT SAP_VENDOR_CODE,
                  VENDOR_LUPDT
             FROM OD.VENDOR) T1,
          OD.VENDOR_BANK_ACCT T2
    WHERE T2.SAP_VENDOR_CODE = T1.SAP_VENDOR_CODE 
    GROUP BY T2.SAP_VENDOR_CODE, 
             T2.VENDOR_BANK_NAME, 
             T2.VENDOR_BANK_BRNCH_NAME, 
             T2.VENDOR_BANK_ACCT_TYPE_CODE, 
             T2.VENDOR_BANK_ACCT_NUM, 
             T2.BANK_KEY, 
             T2.SAP_CNTRY_CODE,
             T1.VENDOR_LUPDT;

/*-*/
/* Authority
/*-*/
grant select on dw_app.vendor_bank_acct_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym vendor_bank_acct_view for dw_app.vendor_bank_acct_view;



