/* Formatted on 2008/06/20 10:36 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW cr_app.care_hierachy_vw AS
  SELECT   keyw_keyword, 'PROD' AS keyw_type, 'N' AS keyw_ask_for_input,
           'Y' AS keyw_replace_key, 'N' AS keyw_inactive, 'N' AS keyw_at_end,
           CHR (32) AS keyw_apn, CHR (32) AS keyw_keyword_01,
           CHR (32) AS keyw_keyword_02, CHR (32) AS keyw_keyword_03,
           CHR (32) AS keyw_keyword_04, CHR (32) AS keyw_keyword_05,
           CHR (32) AS keyw_keyword_06, CHR (32) AS keyw_keyword_07,
           CHR (32) AS keyw_keyword_08, CHR (32) AS keyw_keyword_09,
           CHR (32) AS keyw_keyword_10, CHR (32) AS keyw_keyword_11,
           CHR (32) AS keyw_keyword_12, CHR (32) AS keyw_misc1_x,
           CHR (32) AS keyw_misc2, CHR (32) AS keyw_misc3,
           MAX (descl) AS keyw_description_40,
           MAX (descl) AS keyw_description_74
      FROM (SELECT   keyw_keyword_01 AS keyw_keyword,
                     MAX (keyw_keyword_01_desc) AS descs,
                     MAX (keyw_keyword_01_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_01
            UNION ALL
            SELECT   keyw_keyword_02 AS keyw_keyword,
                     MAX (keyw_keyword_02_desc) AS descs,
                     MAX (keyw_keyword_02_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_02
            UNION ALL
            SELECT   keyw_keyword_03 AS keyw_keyword,
                     MAX (keyw_keyword_03_desc) AS descs,
                     MAX (keyw_keyword_03_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_03
            UNION ALL
            SELECT   keyw_keyword_04 AS keyw_keyword,
                     MAX (keyw_keyword_04_desc) AS descs,
                     MAX (keyw_keyword_04_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_04
            UNION ALL
            SELECT   keyw_keyword_05 AS keyw_keyword,
                     MAX (keyw_keyword_05_desc) AS descs,
                     MAX (keyw_keyword_05_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_05
            UNION ALL
            SELECT   keyw_keyword_06 AS keyw_keyword,
                     MAX (keyw_keyword_06_desc) AS descs,
                     MAX (keyw_keyword_06_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_06
            UNION ALL
            SELECT   keyw_keyword_07 AS keyw_keyword,
                     MAX (keyw_keyword_07_desc) AS descs,
                     MAX (keyw_keyword_07_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_07
            UNION ALL
            SELECT   keyw_keyword_08 AS keyw_keyword,
                     MAX (keyw_keyword_08_desc) AS descs,
                     MAX (keyw_keyword_08_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_08
            UNION ALL
            SELECT   keyw_keyword_09 AS keyw_keyword,
                     MAX (keyw_keyword_09_desc) AS descs,
                     MAX (keyw_keyword_09_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_09
            UNION ALL
            SELECT   keyw_keyword_10 AS keyw_keyword,
                     MAX (keyw_keyword_10_desc) AS descs,
                     MAX (keyw_keyword_10_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_10
            UNION ALL
            SELECT   keyw_keyword_11 AS keyw_keyword,
                     MAX (keyw_keyword_11_desc) AS descs,
                     MAX (keyw_keyword_11_descl) AS descl
                FROM care_tdu_tmp
            GROUP BY keyw_keyword_11)
  GROUP BY keyw_keyword;


GRANT SELECT ON CR_APP.CARE_HIERACHY_VW TO PUBLIC;

