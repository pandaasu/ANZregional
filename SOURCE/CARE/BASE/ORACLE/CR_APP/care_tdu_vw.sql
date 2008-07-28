/* Formatted on 2008/06/20 10:36 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW cr_app.care_tdu_vw AS
  SELECT b.orgentity AS sell_moe, LTRIM (a.matnr, '0') AS grd_tdu,
         CASE
/************/
/* XRF_KEY LOGIC
/************/
/* SNACKFOOD LOGIC
/* notes - if brand is 'ECLAIRS' then key on ingredient variety
/*       - else key on brand, sub brand, consumer pack format,
/*         product category, pack type, product type, size, ingredient
/************/
         WHEN a.busseg = '01'
             THEN CASE
                   WHEN a.brnd = '000'
                     THEN a.ingvrty
                   ELSE    a.brnd
                        || a.brndsub
                        || a.cnspckfrt
                        || a.prdcat
                        || a.cnspcktype
                        || a.prdtype
                        || a.mat_size
                        || a.ingvrty
                 END
/************/
/* FOOD LOGIC
/* notes - if busseg = 02 then key on brand, sub brand, consumer pack format,
/*         product category, pack type, product type, size, ingredient
/************/
         WHEN a.busseg = '02'
             THEN LTRIM (a.matnr, 0)
/************/
/* PETCARE LOGIC
/* notes - if busseg = 05 then key on brand, sub brand, consumer pack format, product category, pack type, product type
/*         size, ingredient variety and functional variety
/************/
         WHEN a.busseg = '05'
             THEN    a.brnd
                  || a.brndsub
                  || a.cnspckfrt
                  || a.prdcat
                  || a.cnspcktype
                  || a.prdtype
                  || a.mat_size
                  || a.ingvrty
                  || a.funcvrty
/************/
/* ELSE
/************/
         ELSE 'UNKNOWN'
         END AS xrf_key,
         'PROD' AS keyw_type,
         CASE
/************/
/* KEYW_DESCRIPTION_40 LOGIC
/************/
/* SNACKFOOD LOGIC
/* notes - if GRD description is NOT null then use it
/*         else use BRAND DESCL(long) + SUB BRAND DESCL (long) + INGREDIENT DESCL(long) + SIZE DESCL(long) + CONS PACK TYPE DESCL (long)
/*         if any are N/A then exclude
/************/
         WHEN a.busseg = '01'
             THEN CASE
                   WHEN TRIM (a.maktx) IS NOT NULL
                     THEN SUBSTR (a.maktx, 1, 40)
                   ELSE SUBSTR
                         (   (SELECT brnddescl || ' '
                                FROM grd_mat_hdr
                               WHERE matnr = a.matnr AND brnd != '000')
                          || (SELECT brndsubdescl || ' '
                                FROM grd_mat_hdr
                               WHERE matnr = a.matnr AND brndsub != '000')
                          || (SELECT ingvrtydescl || ' '
                                FROM grd_mat_hdr
                               WHERE matnr = a.matnr AND ingvrty != '0000')
                          || (SELECT sizedescl || ' '
                                FROM grd_mat_hdr
                               WHERE matnr = a.matnr AND mat_size != '000')
                          || (SELECT cnspcktypedescl
                                FROM grd_mat_hdr
                               WHERE matnr = a.matnr AND cnspcktype != '00'),
                          1,
                          40
                         )
                 END
/************/
/* FOOD LOGIC
/* notes - if GRD description is NOT null then use it
/*         else use BRAND DESCL(long) + PROD TYPE (short) + INGREDIENT DESCL(long) + SIZE DESCL(long)
/*         if any are N/A then exclude
/************/
         WHEN a.busseg = '02'
             THEN CASE
                   WHEN TRIM (a.maktx) IS NOT NULL
                     THEN SUBSTR (a.maktx, 1, 40)
                   ELSE SUBSTR (   (SELECT brnddescl || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr AND brnd != '000')
                                || (SELECT prdtypedescl || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                           AND prdtype != '000')
                                || (SELECT ingvrtydescl || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                       AND ingvrty != '0000')
                                || (SELECT sizedescl || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                       AND mat_size != '000'),
                                1,
                                40
                               )
                 END
/************/
/* PETCARE LOGIC
/* notes - if size is MIXED or SUBBRAND and INGREDIENT and SIZE are N/A then GRD TDU description
/*       - else use BRAND(short) + SUB BRAND(short) + PROD TYPE (short) + FUNCTIONAL VARIETY(short) + INGREDIENT(long) + SIZE(long)
/*         if any are N/A then exclude
/************/
         WHEN a.busseg = '05'
             THEN CASE
                   WHEN a.mat_size = '999'
                    OR (    a.brndsub = '000'
                        AND a.ingvrty = '0000'
                        AND a.mat_size = '000'
                       )
                     THEN SUBSTR (a.maktx, 1, 40)
                   ELSE SUBSTR (   (SELECT brnddesc || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr AND brnd != '000')
                                || (SELECT brndsubdesc || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                           AND brndsub != '000')
                                || (SELECT prdtypedesc || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                           AND prdtype != '000')
                                || (SELECT funcvrtydesc || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                       AND funcvrty != '000')
                                || (SELECT ingvrtydescl || ' '
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                       AND ingvrty != '0000')
                                || (SELECT sizedescl
                                      FROM grd_mat_hdr
                                     WHERE matnr = a.matnr
                                       AND mat_size != '000'),
                                1,
                                40
                               )
                 END
/************/
/* ELSE
/************/
         ELSE 'UNKNOWN'
         END AS keyw_description_40,
         NULL AS keyw_description_74, 'N' AS keyw_ask_for_input,
         DECODE (a.ean11, NULL, ' ', SUBSTR (a.ean11, 1, 20)) AS keyw_apn,
         'Y' AS keyw_replace_key, 'N' AS keyw_inactive,
                                                      --- derived from a.mstae
                                                       'Y' AS keyw_at_end,
         'BSG' || a.busseg AS keyw_keyword_01,
         a.bussegdesc AS keyw_keyword_01_desc,
         a.bussegdesc AS keyw_keyword_01_descl,
         'BRF' || a.brnd AS keyw_keyword_02,
         a.brnddesc AS keyw_keyword_02_desc,
         a.brnddescl AS keyw_keyword_02_descl,
         'BSF' || a.brndsub AS keyw_keyword_03,
         a.brndsubdesc AS keyw_keyword_03_desc,
         a.brndsubdescl AS keyw_keyword_03_descl,
         'CPF' || a.cnspckfrt AS keyw_keyword_04,
         a.cnspckfrtdesc AS keyw_keyword_04_desc,
         a.cnspckfrtdescl AS keyw_keyword_04_descl,
         'PCT' || a.prdcat AS keyw_keyword_05,
         a.prdcatdesc AS keyw_keyword_05_desc,
         a.prdcatdescl AS keyw_keyword_05_descl,
         'CPT' || a.cnspcktype AS keyw_keyword_06,
         a.cnspcktypedesc AS keyw_keyword_06_desc,
         a.cnspcktypedescl AS keyw_keyword_06_descl,
         'PTY' || a.prdtype AS keyw_keyword_07,
         a.prdtypedesc AS keyw_keyword_07_desc,
         a.prdtypedescl AS keyw_keyword_07_descl,
         'IGV' || a.ingvrty AS keyw_keyword_08,
         a.ingvrtydesc AS keyw_keyword_08_desc,
         a.ingvrtydescl AS keyw_keyword_08_descl,
         'SZE' || a.mat_size AS keyw_keyword_09,
         a.sizedesc AS keyw_keyword_09_desc,
         a.sizedescl AS keyw_keyword_09_descl, 
         'SSG' || a.spplysgmnt AS keyw_keyword_10,
         a.spplysgmntdesc AS keyw_keyword_10_desc,
         a.spplysgmntdescl AS keyw_keyword_10_descl, 
         'MSG' || a.mktsgmnt AS keyw_keyword_11,
         a.mktsgmntdesc AS keyw_keyword_11_desc,
         a.mktsgmntdescl AS keyw_keyword_11_descl, 
         NULL AS keyw_keyword_12,
         RPAD (CHR (32), 10, CHR (32)) AS keyw_misc1_x, CHR (32)
                                                                AS keyw_misc2,
         CHR (32) AS keyw_misc3
    FROM grd_mat_hdr a, grd_mat_det b
   WHERE a.matnr = b.matnr
     AND b.orgentity IN
     (
       '0009', '0021', '0042', '0083', '0085', '0086', '0168', '0177', 
       '0196', '0199', '0200', '0201', '0222', '0246', '0370'
     )
     AND b.usagecode = 'SEL'
     AND a.brnd IS NOT NULL
     AND a.brndsub IS NOT NULL
     AND a.cnspckfrt IS NOT NULL
     AND a.prdcat IS NOT NULL
     AND a.cnspcktype IS NOT NULL
     AND a.prdtype IS NOT NULL
     AND a.ingvrty IS NOT NULL
     AND a.mat_size IS NOT NULL
     AND a.mtart = 'FERT'
     AND a.zzistdu = 'X'
     AND a.busseg IN ('01', '02', '05');


GRANT SELECT ON CR_APP.CARE_TDU_VW TO PUBLIC;

