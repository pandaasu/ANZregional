CREATE OR REPLACE PACKAGE Ics_LADOTO01 AS

   /*-*/
   /* Public declarations
   /*-*/
   PROCEDURE EXECUTE;

END Ics_LADOTO01;
/


CREATE OR REPLACE PACKAGE BODY Ics_LADOTO01 AS

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
      CURSOR csr_matl IS
	SELECT
	RPAD(trim(a.matl_code),8,' ')||
	RPAD(trim(''),8,' ')||
	RPAD(trim(a.matl_sales_text),135,' ')||
	RPAD(trim(a.min_ord_qty),17,' ')||
	RPAD(trim(a.delivery_unit),17,' ')||
	RPAD(trim(''),18,' ')||
	trim('Y') matl_line
	FROM matl.telesales_mat_v01 a
	ORDER BY a.matl_code;

	rec_matl  csr_matl%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('LADOTO01','PRDCTMASTER.XML');

      OPEN csr_matl;
      LOOP
         FETCH csr_matl INTO rec_matl;
         IF csr_matl%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Append Detail Records
         /*-*/
         lics_outbound_loader.append_data(rec_matl.matl_line);

      END LOOP;
      CLOSE csr_matl;

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

END Ics_LADOTO01;
/

create public synonym ICS_LADOTO01 for ics_app.ICS_LADOTO01;
GRANT EXECUTE ON ICS_LADOTO01 TO LICS_APP;
