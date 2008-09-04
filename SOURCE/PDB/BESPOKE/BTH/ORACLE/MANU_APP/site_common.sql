DROP PACKAGE MANU_APP.SITE_COMMON;

CREATE OR REPLACE PACKAGE MANU_APP.SITE_COMMON AS
/******************************************************************************
   NAME:       SITE_COMMON
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        28-Jun-06             1. Created this package.
******************************************************************************/

    /*-*/
	/* used as a string to lock the database
	/*-*/
	SUBTYPE PLANT IS VARCHAR2(10);
	PLANT_DB   CONSTANT PLANT := 'BTH001';
		

END SITE_COMMON;
/


DROP PUBLIC SYNONYM SITE_COMMON;

CREATE PUBLIC SYNONYM SITE_COMMON FOR MANU_APP.SITE_COMMON;


