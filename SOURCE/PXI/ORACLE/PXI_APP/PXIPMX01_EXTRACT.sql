create or replace 
PACKAGE          PXIPMX01_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX01_EXTRACT
 Owner   : SITE_APP
 Author  : Chris Horn

 Description
 -----------
    LADS -> Promax PX - Customer Data - PX Interface 300

 This interface selects customer data and sends to promax PI.  

 Date          Author                Description
 ------------  --------------------  -----------
 23/07/2013    Chris Horn            Created.
 
*******************************************************************************/
 
   procedure execute;

end PXIPMX01_EXTRACT;