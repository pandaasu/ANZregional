DROP VIEW MANU.CUST_VW;

/* Formatted on 2008/12/22 11:06 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cust_vw (NAME,
                                           addr1,
                                           addr2,
                                           city,
                                           region,
                                           postcode,
                                           cust_code
                                          )
AS
  SELECT "NAME", "ADDR1", "ADDR2", "CITY", "REGION", "POSTCODE", "CUST_CODE"
    FROM cust;


DROP PUBLIC SYNONYM CUST_VW;

CREATE PUBLIC SYNONYM CUST_VW FOR MANU.CUST_VW;


GRANT SELECT ON MANU.CUST_VW TO MANU_APP;

