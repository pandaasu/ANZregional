CREATE OR REPLACE PACKAGE Ics_Ladhht01 AS

   /*-*/
   /* Public declarations
   /*-*/
   PROCEDURE EXECUTE;

END Ics_Ladhht01;
/


CREATE OR REPLACE PACKAGE BODY Ics_Ladhht01 AS

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
      var_count NUMBER(6,0);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_hht_mat_v01 IS
        SELECT
	  RPAD(NVL(trim(t01.tdu_matl_code),' '),8,' ') ||
	  RPAD(NVL(trim(t01.tdu_ean),' '),18,' ') ||
	  RPAD(NVL(trim(t01.rsu_ean),' '),18,' ') ||
	  RPAD(NVL(trim(t01.matl_desc),' '),20,' ')
	FROM hht_mat_v01 t01
	WHERE t01.tdu_ean is not null
	AND   t01.rsu_ean is not null
	ORDER BY t01.tdu_ean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise the count
      /*-*/
      var_count := 0;

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADHHT01','hhtprdct');

      /*-*/
      /* Retrieve the material rows
      /*-*/
      OPEN csr_hht_mat_v01;
      LOOP
         FETCH csr_hht_mat_v01 INTO var_data;
         IF csr_hht_mat_v01%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

      END LOOP;
      CLOSE csr_hht_mat_v01;

      /*-*/
      /* Append the interface EOF data
      /*-*/
      lics_outbound_loader.append_data(RPAD('EOF' || LPAD(var_count,6,0), 64, ' '));

      /*-*/
      /* Write blank line at EOF (required by HHT Load)
      /*-*/
      lics_outbound_loader.append_data('');

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

END ics_ladhht01;
/

create public synonym ics_ladhht01 for ics_app.ics_ladhht01;
grant execute on ics_ladhht01 to public;
