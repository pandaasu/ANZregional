SELECT
          j.sales_org AS cocode,
          a.dvsn AS divcode,
          RTRIM (LTRIM (t.matl_code, 0)) AS matnr,
          SUBSTR (a.matl_desc, 1, 30) AS tdu_desc,
          CASE
             WHEN j.sales_org = '147' AND a.dvsn = '01'
                THEN DECODE (x.mkt_sub_cat_code,
                             '00', NULL,
                             RTRIM(x.mkt_sub_cat_desc))
             WHEN j.sales_org = '147' AND a.dvsn = '02'
                THEN DECODE (d.trade_sctr_code,
                             '00', NULL,
                             RTRIM (d.trade_sctr_short_desc))
                     || DECODE (x.mkt_sub_cat_code,
                                '00', NULL,
                                ' ' || RTRIM(x.mkt_sub_cat_desc))
                     || DECODE (y.mkt_sub_cat_grp_code,
                                '00', NULL,
                                ' ' || RTRIM(y.mkt_sub_cat_grp_desc))
                     || ' ' || RTRIM(i.size_short_desc)
             WHEN j.sales_org = '147' AND a.dvsn = '05'
                THEN DECODE (y.mkt_sub_cat_grp_code,
                             '00', NULL,
                             RTRIM(y.mkt_sub_cat_grp_desc))
             WHEN j.sales_org = '149'
                THEN DECODE (z.nz_promotional_grp_code,
                             '000', NULL,
                             RTRIM(nz_promotional_grp_desc))
          END AS new_packsize,
          CASE
             WHEN j.sales_org = '147' AND a.dvsn = '01'
                THEN DECODE (x.mkt_sub_cat_code,
                             '00', NULL,
                             RTRIM (x.mkt_sub_cat_desc)
                            )
             ELSE DECODE
                    (a.dvsn,
                     '01', DECODE
                                 (v.local_pack_type_code,
                                  'G00', NULL,
                                  RTRIM (SUBSTR (v.local_pack_type_short_desc,
                                                 1,
                                                 13
                                                )
                                        )
                                 )
                      || DECODE (m.size_group_code,
                                 '00', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (m.size_group_short_desc,
                                                   1,
                                                   4
                                                  )
                                          )
                                )
                      || DECODE
                             (u.local_cnsmr_pack_frmt_code,
                              'G00', NULL,
                                 ' '
                              || RTRIM
                                    (SUBSTR (u.lcl_cnsmr_pack_frmt_short_desc,
                                             1,
                                             13
                                            )
                                    )
                             ),
                     '02', DECODE (d.trade_sctr_code,
                                   '00', NULL,
                                   RTRIM (d.trade_sctr_short_desc)
                                  )
                      || DECODE (e.brand_flag_code,
                                 '000', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (e.brand_flag_short_desc,
                                                   1,
                                                   3
                                                  )
                                          )
                                )
                      || DECODE
                               (g.local_prdct_ctgry_code,
                                'G00', NULL,
                                   ' '
                                || RTRIM
                                      (SUBSTR (g.local_prdct_ctgry_short_desc,
                                               1,
                                               13
                                              )
                                      )
                               )
                      || ' '
                      || RTRIM (i.size_short_desc),
                     '05', DECODE (p.mkt_sgmnt_code,
                                   '00', NULL,
                                   RTRIM (SUBSTR (p.mkt_sgmnt_short_desc, 1,
                                                  3)
                                         )
                                  )
                      || DECODE (q.dsply_strg_cndtn_code,
                                 '00', NULL,
                                 '03', NULL,
                                    ' '
                                 || RTRIM
                                       (SUBSTR (q.dsply_strg_cndtn_short_desc,
                                                1,
                                                3
                                               )
                                       )
                                )
                      || DECODE
                             (q.dsply_strg_cndtn_code,
                              '01', NULL,
                              '02', NULL,
                              DECODE (r.spply_sgmnt_code,
                                      '000', NULL,
                                         ' '
                                      || RTRIM
                                            (SUBSTR (r.spply_sgmnt_short_desc,
                                                     1,
                                                     3
                                                    )
                                            )
                                     )
                             )
                      || DECODE (e.brand_flag_code,
                                 '000', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (e.brand_flag_short_desc,
                                                   1,
                                                   3
                                                  )
                                          )
                                )
                      || DECODE (s.brand_sub_flag_code,
                                 '000', NULL,
                                    ' '
                                 || RTRIM
                                         (SUBSTR (s.brand_sub_flag_short_desc,
                                                  1,
                                                  4
                                                 )
                                         )
                                )
                      || DECODE (i.size_code,
                                 '000', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (i.size_short_desc, 1, 9))
                                )
                      || DECODE (w.mltpck_qty_code,
                                 '00', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (w.mltpck_qty_short_desc,
                                                   1,
                                                   4
                                                  )
                                          )
                                )
                    )
          END AS packsize,
          RTRIM (g.local_prdct_ctgry_code) AS CATEGORY,
          CASE
             WHEN j.sales_org = '147' AND a.dvsn = '01'
                THEN DECODE (e.brand_flag_code,
                             '000', NULL,
                             RTRIM (e.brand_flag_long_desc)
                            )
             ELSE DECODE
                    (a.dvsn,
                     '01', DECODE (e.brand_flag_code,
                                   '000', NULL,
                                   RTRIM (SUBSTR (e.brand_flag_short_desc,
                                                  1,
                                                  7
                                                 )
                                         )
                                  )
                      || DECODE (v.local_pack_type_code,
                                 'G00', NULL,
                                    ' '
                                 || RTRIM
                                        (SUBSTR (v.local_pack_type_short_desc,
                                                 1,
                                                 13
                                                )
                                        )
                                )
                      || DECODE (m.size_group_code,
                                 '00', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (m.size_group_short_desc,
                                                   1,
                                                   4
                                                  )
                                          )
                                ),
                     '02', DECODE (d.trade_sctr_code,
                                   '00', NULL,
                                   RTRIM (d.trade_sctr_short_desc)
                                  )
                      || DECODE (e.brand_flag_code,
                                 '000', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (e.brand_flag_short_desc,
                                                   1,
                                                   3
                                                  )
                                          )
                                )
                      || DECODE
                               (g.local_prdct_ctgry_code,
                                'G00', NULL,
                                   ' '
                                || RTRIM
                                      (SUBSTR (g.local_prdct_ctgry_short_desc,
                                               1,
                                               13
                                              )
                                      )
                               )
                      || DECODE (h.local_prdct_type_code,
                                 'G000', NULL,
                                    ' '
                                 || RTRIM
                                       (SUBSTR (h.local_prdct_type_short_desc,
                                                1,
                                                7
                                               )
                                       )
                                ),
                     '05', DECODE (p.mkt_sgmnt_code,
                                   '00', NULL,
                                   RTRIM (SUBSTR (p.mkt_sgmnt_short_desc, 1,
                                                  4)
                                         )
                                  )
                      || DECODE (e.brand_flag_code,
                                 '000', NULL,
                                    ' '
                                 || RTRIM (SUBSTR (e.brand_flag_short_desc,
                                                   1,
                                                   3
                                                  )
                                          )
                                )
                      || DECODE (q.dsply_strg_cndtn_code,
                                 '00', NULL,
                                 '03', NULL,
                                 ' ' || RTRIM (q.dsply_strg_cndtn_short_desc)
                                )
                      || DECODE (q.dsply_strg_cndtn_code,
                                 '00', NULL,
                                 DECODE (r.spply_sgmnt_code,
                                         '000', NULL,
                                            ' '
                                         || RTRIM (r.spply_sgmnt_short_desc)
                                        )
                                )
                      || DECODE (u.local_cnsmr_pack_frmt_code,
                                 'G00', NULL,
                                    ' '
                                 || RTRIM (u.lcl_cnsmr_pack_frmt_short_desc)
                                )
                    )
          END AS brand_flag,
          c.cnvrsn_fctr_from_base_uom AS rsu_per_case,
          c.cnvrsn_fctr_from_base_uom AS rsu_per_case_11,
          LTRIM (e.brand_flag_code, 0) AS product_class, ' ' AS prod_grp_code,
          DECODE (a.ean_code, NULL, ' ', a.ean_code) AS tdu_ean_code,
          DECODE (c.ean_code_altrntv_matl,
                  NULL, ' ',
                  c.ean_code_altrntv_matl
                 ) AS rsu_ean_code,
          DECODE (b.dsply_strg_cndtn_code,
                  NULL, '0',
                  '00', '0',
                  LTRIM (b.dsply_strg_cndtn_code, 0)
                 ) vartcode,
          'Default' AS shortdesc,
          DECODE (j.sales_org, '149', 12.5, '147', 10) AS prodtax,
          999 AS bmgrcode, 9 AS not_active, ' ' AS scanprod,
          LTRIM (a.dvsn, 0) AS strcode,
          DECODE (j.sales_org,
                  '147', DECODE (a.dvsn, '01', 'S', '02', 'S', '05', 'P'),
                  '149', DECODE (a.dvsn, '01', 'S', '02', 'P', '05', 'P')
                 ) AS promuom
     FROM mfanz_matl a,
          mfanz_fg_matl_clssfctn b,
          mfanz_matl_altrntv_uom c,
          trade_sctr d,
          brand_flag e,
          local_prdct_ctgry_vw g,
          local_prdct_type_vw h,
          size_dscrptv i,
          mfanz_matl_by_sales_area j,
          local_matl_classn_vw k,
          size_group m,
          (SELECT DISTINCT matl_code
                      FROM mfanz_matl_moe
                     WHERE item_usage_code = 'SEL'
                       AND moe_code IN ('0009', '0021', '0086', '0196')) o,
          mkt_sgmnt p,
          dsply_strg_cndtn q,
          spply_sgmnt r,
          brand_sub_flag s,
          (SELECT DISTINCT SALES_ORG,
                           MATL_CODE,
                           START_DATE
                      FROM mfanz_matl_dtrmntn) t,
          local_cnsmr_pack_frmt_vw u,
          local_pack_type_vw v,
          mltpck_qty w,
          mkt_sub_cat x,
          mkt_sub_cat_grp y,
          (select sap_charistic_value_code nz_promotional_grp_code, sap_charistic_value_desc nz_promotional_grp_desc
             FROM bds_charistic_value_en
            WHERE sap_charistic_code = 'Z_APCHAR11') z
    WHERE t.matl_code = a.matl_code
      AND a.matl_type = 'ZREP'
      AND a.trdd_unit = 'X'
      AND c.altrntv_uom = 'PCE'
      AND j.sales_org IN ('147', '149')
      AND j.dstrbtn_chnl = '99'
      AND t.matl_code = b.matl_code(+)
      AND t.matl_code = c.matl_code
      AND t.matl_code = j.matl_code
      AND t.matl_code = k.matl_code
      AND t.sales_org = j.sales_org
      AND t.matl_code = o.matl_code
      AND t.start_date =
             (SELECT MAX (aa.start_date)
                FROM mfanz_matl_dtrmntn aa
               WHERE aa.matl_code = a.matl_code
                 AND aa.matl_code = c.matl_code
                 AND aa.matl_code = j.matl_code
                 AND aa.matl_code = k.matl_code
                 AND aa.sales_org = j.sales_org
                 AND aa.matl_code = o.matl_code
                 AND aa.start_date <= TO_CHAR (SYSDATE+101, 'YYYYMMDD'))
      AND b.trade_sctr_code = d.trade_sctr_code(+)
      AND b.brand_flag_code = e.brand_flag_code(+)
      AND b.size_code = i.size_code(+)
      AND b.size_group_code = m.size_group_code(+)
      AND b.spply_sgmnt_code = r.spply_sgmnt_code(+)
      AND b.brand_sub_flag_code = s.brand_sub_flag_code(+)
      AND b.dsply_strg_cndtn_code = q.dsply_strg_cndtn_code(+)
      AND b.mkt_sgmnt_code = p.mkt_sgmnt_code(+)
      AND b.mltpck_qty_code = w.mltpck_qty_code(+)
      AND g.local_prdct_ctgry_code(+) = k.local_prdct_ctgry_code
      AND h.local_prdct_type_code(+) = k.local_prdct_type_code
      AND u.local_cnsmr_pack_frmt_code(+) = k.local_cnsmr_pack_frmt_code
      AND v.local_pack_type_code(+) = k.local_pack_type_code
      AND b.mkt_sub_cat_code = x.mkt_sub_cat_code(+)
      AND b.mkt_sub_cat_grp_code = y.mkt_sub_cat_grp_code(+)
      and b.nz_promotional_grp_code = z.nz_promotional_grp_code(+)
    ORDER BY cocode, divcode, matnr;

