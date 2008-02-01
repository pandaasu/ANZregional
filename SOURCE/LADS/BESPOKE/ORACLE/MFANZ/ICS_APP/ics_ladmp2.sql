CREATE OR REPLACE PACKAGE ICS_LADMP2 AS

   /*-*/
   /* Public declarations
   /*-*/
   PROCEDURE EXECUTE;
   PROCEDURE WRITE_FILE (iv_intfc VARCHAR2);

END ICS_LADMP2;
/


CREATE OR REPLACE PACKAGE BODY ICS_LADMP2 AS

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   PROCEDURE EXECUTE IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN
      WRITE_FILE('LADMP201');
      WRITE_FILE('LADMP202');
      WRITE_FILE('LADMP203');
      WRITE_FILE('LADMP204');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN
         ROLLBACK;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END EXECUTE;


   PROCEDURE WRITE_FILE (iv_intfc VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_instance NUMBER(15,0);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_vendor IS
	SELECT *
	FROM vend.mp2_vndr;

	rec_vendor  csr_vendor%ROWTYPE;

   BEGIN
      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface(iv_intfc);

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
         lics_outbound_loader.append_data(rpad(rec_vendor.vndr_nmbr,8,' ')||rpad(rec_vendor.vndr_name,80,' '));

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
      WHEN OTHERS THEN
        IF lics_outbound_loader.is_created = TRUE THEN
           lics_outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
        END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END WRITE_FILE;

END ICS_LADMP2;
/

GRANT EXECUTE ON ICS_LADMP2 TO LICS_APP;

create public synonym ICS_LADMP2 for ics_app.ICS_LADMP2;
