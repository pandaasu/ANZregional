DROP PACKAGE SITE_APP.SITE_LADNWH01;

CREATE OR REPLACE PACKAGE SITE_APP.site_ladnwh01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : SITE_LADNWH01
 Owner   : SITE_APP
 Author  : Scott R. Harding

 Description
 -----------
    LADS -> NEW ZEALAND WAREHOUSE MATERIAL MASTER EXTRACT
      * Outbound query based on site_ladex101 example
      
      File naming convention: MMSTNZ16<8-char sequential number>.int

 Parameters :

   1. PAR_ACTION [MANDATORY] - warehouse(s) to extract material master for
      <plant_code> - extract for a single warehouse code, e.g. 'AU34'
      '*ALL'       - extract for all warehouses, Inbound and Outbound
      '*ALL_OB'    - extract for all Outbound warehouses
      '*ALL_IB'    - extract for all Inbound warehouses

   2. PAR_DAYS [OPTIONAL] - number of days of changes to extract
      n = number provided will extract changed materials for sysdate - n
      DEFAULT = no parameter specified, default is 7



 DD-MON-YYYY    Author               Description
 ------------   ------               -----------
 07-Jul-2008    Scott R. Harding     Created from site_app.ladswh01 example.
 09-Jul-2008    Scott R. Harding     Added 45 blank spaces to end of row for future use.
 04-Aug-2008    Scott R. Harding     Changed '02' = 'HS' to 'FD"
 08-Sep-2010    Ben Halicki          Updated to include NZ17 (Cardinal Palmerston North Warehouse)
 07/Oct-2010    Ben Halicki          Modified logic to create interface only if materials have been 
                                        selected for sending
 
 *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_days in number default 7);

end site_ladnwh01;
/


DROP PUBLIC SYNONYM SITE_LADNWH01;

CREATE PUBLIC SYNONYM SITE_LADNWH01 FOR SITE_APP.SITE_LADNWH01;


GRANT EXECUTE ON SITE_APP.SITE_LADNWH01 TO ICS_APP;

GRANT EXECUTE ON SITE_APP.SITE_LADNWH01 TO ICS_EXECUTOR;

GRANT EXECUTE ON SITE_APP.SITE_LADNWH01 TO LICS_APP;


DROP PACKAGE BODY SITE_APP.SITE_LADNWH01;

CREATE OR REPLACE PACKAGE BODY SITE_APP.SITE_LADNWH01 AS

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   PROCEDURE execute_tolas_ob(par_plant IN VARCHAR2, par_interface IN VARCHAR2, par_days IN NUMBER);
   PROCEDURE execute_tolas_ib(par_plant IN VARCHAR2, par_interface IN VARCHAR2, par_days IN NUMBER);

   /***************************************************/
   /* This procedure performs the execute routine     */
   /***************************************************/
   PROCEDURE EXECUTE(par_action IN VARCHAR2, par_days IN NUMBER DEFAULT 7) IS

       var_days NUMBER;
   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      IF (par_days IS NULL OR par_days = '') THEN
          var_days := 7;
      ELSE
          var_days := par_days;
      END IF;
          
      IF (UPPER(par_action) != 'NZ16' AND
          UPPER(par_action) != 'NZ17' and 
          UPPER(par_action) != '*ALL_OB' AND
          UPPER(par_action) != '*ALL_IB' AND
          UPPER(par_action) != '*ALL') THEN
            RAISE_APPLICATION_ERROR(-20000, 'Invalid action code - must be either NZ16, NZ17, *ALL_OB, *ALL_IB or *ALL');
         END IF;


      /* Cardinal - outbound */
      if (upper(par_action) in ('NZ16', '*ALL','*ALL_OB')) then
         execute_tolas_ob('NZ16','LADCFD01',var_days);
      end if;

      if (upper(par_action) in ('NZ17', '*ALL','*ALL_OB')) then
         execute_tolas_ob('NZ17','LADCPN01',var_days);
      end if;
            
      
--      /* Linfox Ballarat - inbound */
--      IF (UPPER(par_action) IN ('CCpp','*ALL','*ALL_IB')) THEN
--         execute_tolas_ib('CCpp','LADxxxnn', var_days);
--      END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END EXECUTE;


   /**************************************************************************/
   /* This procedure performs the execute outbound warehouse extract routine */
   /**************************************************************************/
   PROCEDURE execute_tolas_ob(par_plant IN VARCHAR2, par_interface IN VARCHAR2, par_days IN NUMBER) IS

      /*-*/
      /* Local Variables */
      /*-*/
      var_instance NUMBER(15,0);
      var_days NUMBER;


      /*-*/
      /* Local Cursors */
      /*-*/
      CURSOR csr_matl_master IS

        SELECT
          'HDR' ||
          RPAD(LTRIM(NVL(a.matl_code,' '), 0),8,' ') ||
          RPAD(NVL(a.matl_desc,' '),40,' ') ||
          RPAD(TO_NUMBER(a.crtn_date),8,' ') ||
          RPAD(UPPER(NVL(b.plant,' ')),4,' ') ||
          RPAD(UPPER(NVL(a.matl_type,' ')),4,' ') ||
          CASE
              WHEN h.bus_sgmnt_code = '05' then 'PC'
              WHEN h.bus_sgmnt_code = '02' then 'FD'
              WHEN h.bus_sgmnt_code = '01' then 'SN'
              ELSE '  '
          END || -- Required for KPI reporting ie. # pallets of petfood
          CASE
              WHEN a.gross_wght > 0 and a.dclrd_uom = 'KGM' THEN TO_CHAR(a.gross_wght,'FM0000000000.000')
              WHEN a.gross_wght > 0 and a.dclrd_uom = 'GRM' THEN TO_CHAR(a.gross_wght/1000,'FM0000000000.000')
              WHEN a.gross_wght > 0 and a.dclrd_uom = 'TNE' THEN TO_CHAR(a.gross_wght*1000,'FM0000000000.000')
              WHEN a.gross_wght is not null and a.dclrd_uom = 'KGM' THEN TO_CHAR(a.gross_wght,'FM0000000000.000')
              WHEN a.gross_wght is not null and a.dclrd_uom = 'GRM' THEN TO_CHAR(a.gross_wght/1000,'FM0000000000.000')
              WHEN a.gross_wght is not null and a.dclrd_uom = 'TNE' THEN TO_CHAR(a.gross_wght*1000,'FM0000000000.000')
              ELSE TO_CHAR(0,'FM0000000000.000')
          END || -- All weights to be in KGs
          CASE
              WHEN a.net_wght > 0 and a.dclrd_uom = 'KGM' THEN TO_CHAR(a.net_wght,'FM0000000000.000')
              WHEN a.net_wght > 0 and a.dclrd_uom = 'GRM' THEN TO_CHAR( a.net_wght/1000,'FM0000000000.000')
              WHEN a.net_wght > 0 and a.dclrd_uom = 'TNE' THEN TO_CHAR( a.net_wght*1000,'FM0000000000.000')
              WHEN a.net_wght is not null and a.dclrd_uom = 'KGM' THEN TO_CHAR( a.net_wght,'FM0000000000.000')
              WHEN a.net_wght is not null and a.dclrd_uom = 'GRM' THEN TO_CHAR( a.net_wght/1000,'FM0000000000.000')
              WHEN a.net_wght is not null and a.dclrd_uom = 'TNE' THEN TO_CHAR( a.net_wght*1000,'FM0000000000.000')
              ELSE TO_CHAR(0,'FM0000000000.000')
          END || -- All weights to be in KGs. Note: Net weight is the same as Gross Weight.
          DECODE(a.dclrd_uom, 'KGM', 'KG ', 'GRM', 'KG ', 'TNE', 'KG ', 'ERR') || --gross_wght_uom: Weight UOM should be in KGs. If not converted from KGram, Gram or Tonne, then error is used.
          NVL(a.batch_mngmnt_rqrmnt_indctr,' ') ||
          RPAD(DECODE(i.sales_unit,'0',' ',NVL(i.sales_unit,' ')),3,' ') || --order_uom,
          RPAD(NVL(a.base_uom,' '),3,' ') ||
          RPAD(DECODE(NVL(a.shelf_life,'9999'),'0','9999',a.shelf_life),4,' ') ||
          '  ' || -- spcl_prcrmnt_type
          ' ' || -- dltn_indctr
          TO_CHAR(1,'FM00000V0000') || -- sales_unit_to_base_uom
          RPAD(NVL(e.ean_code_altrntv_matl,' '),18,' ') || -- rsu_ean
          RPAD(NVL(a.ean_code,' '),18,' ') ||
          TO_CHAR(NVL(g.crtns_per_pllt,0),'FM00000V0000') ||
          TO_CHAR(DECODE(NVL(g.crtns_per_layer,0),0,0,g.crtns_per_pllt/g.crtns_per_layer),'FM00000V0000') || -- lyrs_per_pllt,
          CASE
              WHEN a.hght > 0 AND a.uom_for_lwh = 'CMT' THEN TO_CHAR(a.hght,'FM00000000V0')
              WHEN a.hght > 0 AND a.uom_for_lwh = 'MMT' THEN TO_CHAR(a.hght/10,'FM00000000V0')
              WHEN a.hght > 0 AND a.uom_for_lwh = 'MTR' THEN TO_CHAR(a.hght*100,'FM00000000V0')
              WHEN a.hght IS NOT NULL AND a.uom_for_lwh = 'CMT' THEN TO_CHAR(a.hght,'FM00000000V0')
              WHEN a.hght IS NOT NULL AND a.uom_for_lwh = 'MMT' THEN TO_CHAR(a.hght/10,'FM00000000V0')
              WHEN a.hght IS NOT NULL AND a.uom_for_lwh = 'MTR' THEN TO_CHAR(a.hght*100,'FM00000000V0')
              ELSE TO_CHAR(0,'FM00000000V0')
              END || -- hght
          CASE
              WHEN a.lngth > 0 AND a.uom_for_lwh = 'CMT' THEN TO_CHAR(a.lngth,'FM00000000V0')
              WHEN a.lngth > 0 AND a.uom_for_lwh = 'MMT' THEN TO_CHAR(a.lngth/10,'FM00000000V0')
              WHEN a.lngth > 0 AND a.uom_for_lwh = 'MTR' THEN TO_CHAR(a.lngth*100,'FM00000000V0')
              WHEN a.lngth IS NOT NULL AND a.uom_for_lwh = 'CMT' THEN TO_CHAR(a.lngth,'FM00000000V0')
              WHEN a.lngth IS NOT NULL AND a.uom_for_lwh = 'MMT' THEN TO_CHAR(a.lngth/10,'FM00000000V0')
              WHEN a.lngth IS NOT NULL AND a.uom_for_lwh = 'MTR' THEN TO_CHAR(a.lngth*100,'FM00000000V0')
              ELSE TO_CHAR(0,'FM00000000V0')
              END || -- length
          CASE
              WHEN a.width > 0 AND a.uom_for_lwh = 'CMT' THEN TO_CHAR(a.width,'FM00000000V0')
              WHEN a.width > 0 AND a.uom_for_lwh = 'MMT' THEN TO_CHAR(a.width/10,'FM00000000V0')
              WHEN a.width > 0 AND a.uom_for_lwh = 'MTR' THEN TO_CHAR(a.width*100,'FM00000000V0')
              WHEN a.width IS NOT NULL AND a.uom_for_lwh = 'CMT' THEN TO_CHAR(a.width,'FM00000000V0')
              WHEN a.width IS NOT NULL AND a.uom_for_lwh = 'MMT' THEN TO_CHAR(a.width/10,'FM00000000V0')
              WHEN a.width IS NOT NULL AND a.uom_for_lwh = 'MTR' THEN TO_CHAR(a.width*100,'FM00000000V0')
              ELSE TO_CHAR(0,'FM00000000V0')
              END || -- width
          CASE
              WHEN k.item_usage_code = 'MKE' AND k.moe_code = '0089' THEN ' '
              ELSE 'Y'
          END || -- batch_visible_flag. note: this indicates whether the generic batch is visible in Cardinal.
                 -- If 'Y', then the real batch is not visible on the product --> ASN will be overwritten with the generic batch in Cardinal.
          RPAD(' ',45,' ') -- spare spaces for future use.
          AS matl_master
        FROM
          mfanz_matl a,
          mfanz_matl_by_plant b,
          mfanz_matl_altrntv_uom c,
          mfanz_matl_altrntv_uom d,
          mfanz_matl_altrntv_uom e,
        (SELECT f.matl_code as matl_code, f.item_usage_code as item_usage_code, f.moe_code as moe_code
           FROM mfanz_matl_moe f
          WHERE f.item_usage_code = 'MKE' AND f.moe_code = '0089') k,
         (SELECT matl_code, crtns_per_pllt, crtns_per_layer, start_date, end_date
           FROM  mfanz_pckgng_instrctn z
           WHERE SUBSTR(vrbl_key,1,3) = '149') g,
          mfanz_fg_matl_clssfctn h,
         (SELECT   j.matl_code as matl_code,NVL(MIN(j.sales_unit),0) AS sales_unit
            FROM   mfanz_matl_by_sales_area j
           WHERE   j.sales_org = '149' AND j.dstrbtn_chnl = '10'
          GROUP BY j.matl_code) i
        WHERE
          a.trdd_unit = 'X'
          AND a.matl_code = b.matl_code
          AND b.plant = par_plant --eg. NZ16 Cardinal
          AND a.matl_code = h.matl_code(+)
          AND a.matl_code = i.matl_code(+)
          AND i.sales_unit = d.matl_code(+)
          AND a.matl_code = c.matl_code(+)
          AND c.altrntv_uom(+) = 'CS'
          AND a.matl_code = e.matl_code(+)
          AND e.altrntv_uom(+) = 'PCE'
          AND a.matl_code = k.matl_code(+)
          AND a.matl_code = g.matl_code(+)
          AND (g.start_date <= TO_CHAR(SYSDATE, 'YYYYMMDD') OR g.start_date IS NULL)
          AND (g.end_date >= TO_CHAR(SYSDATE, 'YYYYMMDD') OR g.end_date IS NULL)
          AND b.plant_sts = '20'
          AND a.x_plant_matl_sts = '10'
          AND TO_DATE(a.chng_date,'YYYYMMDD') > (SYSDATE-var_days); 
           
      rec_matl_master csr_matl_master%ROWTYPE;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Define number of days to extract */
      /*-*/
      IF par_days = 0 THEN
         var_days := 99999; -- all available data
      ELSE
         var_days := par_days;
      END IF;
      
      /*-*/
      /* Open Cursor for output */
      /*-*/
      OPEN csr_matl_master;
      LOOP
         FETCH csr_matl_master INTO rec_matl_master;
         IF (csr_matl_master%NOTFOUND) THEN
            EXIT;
         END IF;
         
         if (csr_matl_master%rowcount=1) then
            /*-*/
            /* Create Outbound Interface */
            /*-*/
            var_instance := lics_outbound_loader.create_interface(par_interface);
         end if;
         
         /*-*/
         /* Append Data Lines */
         /*-*/
         lics_outbound_loader.append_data(rec_matl_master.matl_master);

      END LOOP;
      CLOSE csr_matl_master;
 
      if lics_outbound_loader.is_created = TRUE then
        /*-*/
        /* Append Control Record */
        /*-*/
        lics_outbound_loader.append_data('CTL' || TO_CHAR(var_instance,'FM000000000000000'));
      
        /*-*/
        /* Finalise Interface */
        /*-*/
        lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /*-*/
      /* Exception trap */
      /*-*/
      WHEN OTHERS THEN

         /*-*/
         /* Rollback the database */
         /*-*/
         ROLLBACK;

         /*-*/
         /* Close Interface */
         /*-*/
         IF lics_outbound_loader.is_created = TRUE THEN
            lics_outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         END IF;
         
         RAISE_APPLICATION_ERROR(-20001, 'SITE_APP.SITE_LADNWH01 procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END execute_tolas_ob;


   /**************************************************************************/
   /* This procedure performs the execute inbound warehouse extract routine  */
   /**************************************************************************/
   PROCEDURE execute_tolas_ib(par_plant IN VARCHAR2, par_interface IN VARCHAR2, par_days IN NUMBER) IS

      /*-*/
      /* Local Variables */
      /*-*/
      var_instance NUMBER(15,0);
      var_days NUMBER;


      /*-*/
      /* Local Cursors */
      /*-*/
      CURSOR csr_matl_master IS
      
         SELECT 'NOT YET IMPLEMENTED' AS matl_master
         FROM dual;
         
      rec_matl_master csr_matl_master%ROWTYPE;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Define number of days to extract */
      /*-*/
      IF par_days = 0 THEN
         var_days := 99999; -- all available data
      ELSE
         var_days := par_days;
      END IF;


      /*-*/
      /* Create Outbound Interface */
      /*-*/
      var_instance := lics_outbound_loader.create_interface(par_interface);


      /*-*/
      /* Open Cursor for output */
      /*-*/
      OPEN csr_matl_master;
      LOOP
         FETCH csr_matl_master INTO rec_matl_master;
         IF (csr_matl_master%NOTFOUND) THEN
            EXIT;
         END IF;
         /*-*/
         /* Append Data Lines */
         /*-*/
         lics_outbound_loader.append_data(rec_matl_master.matl_master);

      END LOOP;
      CLOSE csr_matl_master;

      /*-*/
      /* Append Control Record */
      /*-*/
      lics_outbound_loader.append_data('CTL' || TO_CHAR(var_instance,'FM000000000000000'));


      /*-*/
      /* Finalise Interface */
      /*-*/
      lics_outbound_loader.finalise_interface;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /*-*/
      /* Exception trap */
      /*-*/
      WHEN OTHERS THEN

         /*-*/
         /* Rollback the database */
         /*-*/
         ROLLBACK;

         /*-*/
         /* Close Interface */
         /*-*/
         IF lics_outbound_loader.is_created = TRUE THEN
            lics_outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         END IF;
         
         RAISE_APPLICATION_ERROR(-20001, 'SITE_APP.SITE_LADNWH01 procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END execute_tolas_ib;

END SITE_LADNWH01;
/


DROP PUBLIC SYNONYM SITE_LADNWH01;

CREATE PUBLIC SYNONYM SITE_LADNWH01 FOR SITE_APP.SITE_LADNWH01;


GRANT EXECUTE ON SITE_APP.SITE_LADNWH01 TO ICS_APP;

GRANT EXECUTE ON SITE_APP.SITE_LADNWH01 TO ICS_EXECUTOR;

GRANT EXECUTE ON SITE_APP.SITE_LADNWH01 TO LICS_APP;
