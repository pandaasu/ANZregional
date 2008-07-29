CREATE OR REPLACE PACKAGE Ics_Ladmp201 AS

   /*-*/
   /* Public declarations
   /*-*/
   PROCEDURE EXECUTE;

END Ics_Ladmp201;
/


CREATE OR REPLACE PACKAGE BODY Ics_Ladmp201 AS

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   PROCEDURE EXECUTE IS

      /*-*/
      /* Local definitions
      /*-*/
      var_instance NUMBER(15,0);
      var_data VARCHAR2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_vendor IS
	SELECT *
	FROM mp2_vndr a
	ORDER BY a.vndr_nmbr;

	rec_vendor  csr_vendor%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADMP201');

      /*-*/
      /* Append File Header
      /*-*/
      OPEN csr_vendor;
      LOOP
         FETCH csr_vendor INTO rec_vendor;
         IF csr_vendor%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Append Detail Records
         /*-*/
         lics_outbound_loader.append_data(rec_vendor.vndr_nmbr||rec_vendor.vndr_name);

      END LOOP;
      CLOSE csr_vendor;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN
         ROLLBACK;
         IF lics_outbound_loader.is_created = TRUE THEN
            lics_outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END EXECUTE;

END Ics_Ladmp201;
/
