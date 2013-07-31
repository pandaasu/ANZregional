create or replace 
package body pxipmx04_extract as
   -- Private exceptions
   pc_application_exception pls_integer := -20000;
   application_exception exception;
   pragma exception_init(application_exception, -20000);

/*******************************************************************************
  NAME:      GET_CUSTOMER_HIERARCHY                                        PUBLIC
*******************************************************************************/
  function get_customer_hierarchy return tt_hierachy pipelined is
    -- This cursor generates the product level data in a flatterned table structure.
    cursor csr_cust_level_data is
      select 
        t1.customer_code, 
        t3.sales_org_code,
        t3.distbn_chnl_code,
        t3.division_code,
        t2.name as customer_name,
        t4.level_01_cust_code, 
        t4.level_01_cust_name_en, 
        t4.level_02_cust_code,
        t4.level_02_cust_name_en,
        t4.level_03_cust_code,
        t4.level_03_cust_name_en,
        t4.level_04_cust_code,
        t4.level_04_cust_name_en,
        t4.level_05_cust_code,
        t4.level_05_cust_name_en,
        t4.level_06_cust_code,
        t4.level_06_cust_name_en
      from 
        bds_cust_header t1,  
        bds_addr_customer t2,
        bds_cust_sales_area t3, 
        (
          -- Venus Customer Hiearchy Query 
          SELECT
            DECODE(L.LEVEL_02_CUST_CODE, NULL, L.LEVEL_01_CUST_CODE,
              DECODE(L.LEVEL_03_CUST_CODE, NULL, L.LEVEL_02_CUST_CODE,
                DECODE(L.LEVEL_04_CUST_CODE, NULL, L.LEVEL_03_CUST_CODE,
                  DECODE(L.LEVEL_05_CUST_CODE, NULL, L.LEVEL_04_CUST_CODE,
                    DECODE(L.LEVEL_06_CUST_CODE, NULL, L.LEVEL_05_CUST_CODE,
                      DECODE(L.LEVEL_07_CUST_CODE, NULL, L.LEVEL_06_CUST_CODE,
                        DECODE(L.LEVEL_08_CUST_CODE, NULL, L.LEVEL_07_CUST_CODE,
                          DECODE(L.LEVEL_09_CUST_CODE, NULL, L.LEVEL_08_CUST_CODE,
                            DECODE(L.LEVEL_10_CUST_CODE, NULL, L.LEVEL_09_CUST_CODE,
                            L.LEVEL_10_CUST_CODE))))))))) AS CUST_CODE,
            DECODE(L.LEVEL_02_CUST_CODE, NULL, L.LEVEL_01_SALES_ORG_CODE,
              DECODE(L.LEVEL_03_CUST_CODE, NULL, L.LEVEL_02_SALES_ORG_CODE,
                DECODE(L.LEVEL_04_CUST_CODE, NULL, L.LEVEL_03_SALES_ORG_CODE,
                  DECODE(L.LEVEL_05_CUST_CODE, NULL, L.LEVEL_04_SALES_ORG_CODE,
                    DECODE(L.LEVEL_06_CUST_CODE, NULL, L.LEVEL_05_SALES_ORG_CODE,
                      DECODE(L.LEVEL_07_CUST_CODE, NULL, L.LEVEL_06_SALES_ORG_CODE,
                        DECODE(L.LEVEL_08_CUST_CODE, NULL, L.LEVEL_07_SALES_ORG_CODE,
                          DECODE(L.LEVEL_09_CUST_CODE, NULL, L.LEVEL_08_SALES_ORG_CODE,
                            DECODE(L.LEVEL_10_CUST_CODE, NULL, L.LEVEL_09_SALES_ORG_CODE,
                            L.LEVEL_10_SALES_ORG_CODE))))))))) AS SALES_ORG_CODE,
            DECODE(L.LEVEL_02_CUST_CODE, NULL, L.LEVEL_01_DISTBN_CHNL_CODE,
              DECODE(L.LEVEL_03_CUST_CODE, NULL, L.LEVEL_02_DISTBN_CHNL_CODE,
                DECODE(L.LEVEL_04_CUST_CODE, NULL, L.LEVEL_03_DISTBN_CHNL_CODE,
                  DECODE(L.LEVEL_05_CUST_CODE, NULL, L.LEVEL_04_DISTBN_CHNL_CODE,
                    DECODE(L.LEVEL_06_CUST_CODE, NULL, L.LEVEL_05_DISTBN_CHNL_CODE,
                      DECODE(L.LEVEL_07_CUST_CODE, NULL, L.LEVEL_06_DISTBN_CHNL_CODE,
                        DECODE(L.LEVEL_08_CUST_CODE, NULL, L.LEVEL_07_DISTBN_CHNL_CODE,
                          DECODE(L.LEVEL_09_CUST_CODE, NULL, L.LEVEL_08_DISTBN_CHNL_CODE,
                            DECODE(L.LEVEL_10_CUST_CODE, NULL, L.LEVEL_09_DISTBN_CHNL_CODE,
                            L.LEVEL_10_DISTBN_CHNL_CODE))))))))) AS DISTBN_CHNL_CODE,
            DECODE(L.LEVEL_02_CUST_CODE, NULL, L.LEVEL_01_DIVISION_CODE,
              DECODE(L.LEVEL_03_CUST_CODE, NULL, L.LEVEL_02_DIVISION_CODE,
                DECODE(L.LEVEL_04_CUST_CODE, NULL, L.LEVEL_03_DIVISION_CODE,
                  DECODE(L.LEVEL_05_CUST_CODE, NULL, L.LEVEL_04_DIVISION_CODE,
                    DECODE(L.LEVEL_06_CUST_CODE, NULL, L.LEVEL_05_DIVISION_CODE,
                      DECODE(L.LEVEL_07_CUST_CODE, NULL, L.LEVEL_06_DIVISION_CODE,
                        DECODE(L.LEVEL_08_CUST_CODE, NULL, L.LEVEL_07_DIVISION_CODE,
                          DECODE(L.LEVEL_09_CUST_CODE, NULL, L.LEVEL_08_DIVISION_CODE,
                            DECODE(L.LEVEL_10_CUST_CODE, NULL, L.LEVEL_09_DIVISION_CODE,
                            L.LEVEL_10_DIVISION_CODE))))))))) AS DIVISION_CODE,
            L.LEVEL_01_CUST_CODE,
            M.name AS LEVEL_01_CUST_NAME_EN,
            L.LEVEL_01_SALES_ORG_CODE,
            L.LEVEL_01_DISTBN_CHNL_CODE,
            L.LEVEL_01_DIVISION_CODE,
            L.LEVEL_01_SORT_LEVEL,
            L.LEVEL_01_START_DATE,
            L.LEVEL_01_END_DATE,
            L.LEVEL_02_CUST_CODE,
            N.name AS LEVEL_02_CUST_NAME_EN,
            L.LEVEL_02_SALES_ORG_CODE,
            L.LEVEL_02_DISTBN_CHNL_CODE,
            L.LEVEL_02_DIVISION_CODE,
            L.LEVEL_02_SORT_LEVEL,
            L.LEVEL_02_START_DATE,
            L.LEVEL_02_END_DATE,
            L.LEVEL_03_CUST_CODE,
            O.name AS LEVEL_03_CUST_NAME_EN,
            L.LEVEL_03_SALES_ORG_CODE,
            L.LEVEL_03_DISTBN_CHNL_CODE,
            L.LEVEL_03_DIVISION_CODE,
            L.LEVEL_03_SORT_LEVEL,
            L.LEVEL_03_START_DATE,
            L.LEVEL_03_END_DATE,
            L.LEVEL_04_CUST_CODE,
            P.name AS LEVEL_04_CUST_NAME_EN,
            L.LEVEL_04_SALES_ORG_CODE,
            L.LEVEL_04_DISTBN_CHNL_CODE,
            L.LEVEL_04_DIVISION_CODE,
            L.LEVEL_04_SORT_LEVEL,
            L.LEVEL_04_START_DATE,
            L.LEVEL_04_END_DATE,
            L.LEVEL_05_CUST_CODE,
            Q.name AS LEVEL_05_CUST_NAME_EN,
            L.LEVEL_05_SALES_ORG_CODE,
            L.LEVEL_05_DISTBN_CHNL_CODE,
            L.LEVEL_05_DIVISION_CODE,
            L.LEVEL_05_SORT_LEVEL,
            L.LEVEL_05_START_DATE,
            L.LEVEL_05_END_DATE,
            L.LEVEL_06_CUST_CODE,
            R.name AS LEVEL_06_CUST_NAME_EN,
            L.LEVEL_06_SALES_ORG_CODE,
            L.LEVEL_06_DISTBN_CHNL_CODE,
            L.LEVEL_06_DIVISION_CODE,
            L.LEVEL_06_SORT_LEVEL,
            L.LEVEL_06_START_DATE,
            L.LEVEL_06_END_DATE,
            L.LEVEL_07_CUST_CODE,
            S.name AS LEVEL_07_CUST_NAME_EN,
            L.LEVEL_07_SALES_ORG_CODE,
            L.LEVEL_07_DISTBN_CHNL_CODE,
            L.LEVEL_07_DIVISION_CODE,
            L.LEVEL_07_SORT_LEVEL,
            L.LEVEL_07_START_DATE,
            L.LEVEL_07_END_DATE,
            L.LEVEL_08_CUST_CODE,
            T.name AS LEVEL_08_CUST_NAME_EN,
            L.LEVEL_08_SALES_ORG_CODE,
            L.LEVEL_08_DISTBN_CHNL_CODE,
            L.LEVEL_08_DIVISION_CODE,
            L.LEVEL_08_SORT_LEVEL,
            L.LEVEL_08_START_DATE,
            L.LEVEL_08_END_DATE,
            L.LEVEL_09_CUST_CODE,
            U.name AS LEVEL_09_CUST_NAME_EN,
            L.LEVEL_09_SALES_ORG_CODE,
            L.LEVEL_09_DISTBN_CHNL_CODE,
            L.LEVEL_09_DIVISION_CODE,
            L.LEVEL_09_SORT_LEVEL,
            L.LEVEL_09_START_DATE,
            L.LEVEL_09_END_DATE,
            L.LEVEL_10_CUST_CODE,
            V.name AS LEVEL_10_CUST_NAME_EN,
            L.LEVEL_10_SALES_ORG_CODE,
            L.LEVEL_10_DISTBN_CHNL_CODE,
            L.LEVEL_10_DIVISION_CODE,
            L.LEVEL_10_SORT_LEVEL,
            L.LEVEL_10_START_DATE,
            L.LEVEL_10_END_DATE
          FROM
            (
            SELECT
              B.kunnr  AS LEVEL_01_CUST_CODE,
              B.vkorg  AS LEVEL_01_SALES_ORG_CODE,
              B.vtweg  AS LEVEL_01_DISTBN_CHNL_CODE,
              B.spart  AS LEVEL_01_DIVISION_CODE,
              B.sortl  AS LEVEL_01_SORT_LEVEL,
              B.datab  AS LEVEL_01_START_DATE,
              B.datbi  AS LEVEL_01_END_DATE,
              C.kunnr  AS LEVEL_02_CUST_CODE,
              C.vkorg  AS LEVEL_02_SALES_ORG_CODE,
              C.vtweg  AS LEVEL_02_DISTBN_CHNL_CODE,
              C.spart  AS LEVEL_02_DIVISION_CODE,
              C.sortl  AS LEVEL_02_SORT_LEVEL,
              C.datab  AS LEVEL_02_START_DATE,
              C.datbi  AS LEVEL_02_END_DATE,
              D.kunnr  AS LEVEL_03_CUST_CODE,
              D.vkorg  AS LEVEL_03_SALES_ORG_CODE,
              D.vtweg  AS LEVEL_03_DISTBN_CHNL_CODE,
              D.spart  AS LEVEL_03_DIVISION_CODE,
              D.sortl  AS LEVEL_03_SORT_LEVEL,
              D.datab  AS LEVEL_03_START_DATE,
              D.datbi  AS LEVEL_03_END_DATE,
              E.kunnr  AS LEVEL_04_CUST_CODE,
              E.vkorg  AS LEVEL_04_SALES_ORG_CODE,
              E.vtweg  AS LEVEL_04_DISTBN_CHNL_CODE,
              E.spart  AS LEVEL_04_DIVISION_CODE,
              E.sortl  AS LEVEL_04_SORT_LEVEL,
              E.datab  AS LEVEL_04_START_DATE,
              E.datbi  AS LEVEL_04_END_DATE,
              F.kunnr  AS LEVEL_05_CUST_CODE,
              F.vkorg  AS LEVEL_05_SALES_ORG_CODE,
              F.vtweg  AS LEVEL_05_DISTBN_CHNL_CODE,
              F.spart  AS LEVEL_05_DIVISION_CODE,
              F.sortl  AS LEVEL_05_SORT_LEVEL,
              F.datab  AS LEVEL_05_START_DATE,
              F.datbi  AS LEVEL_05_END_DATE,
              G.kunnr  AS LEVEL_06_CUST_CODE,
              G.vkorg  AS LEVEL_06_SALES_ORG_CODE,
              G.vtweg  AS LEVEL_06_DISTBN_CHNL_CODE,
              G.spart  AS LEVEL_06_DIVISION_CODE,
              G.sortl  AS LEVEL_06_SORT_LEVEL,
              G.datab  AS LEVEL_06_START_DATE,
              G.datbi  AS LEVEL_06_END_DATE,
              H.kunnr  AS LEVEL_07_CUST_CODE,
              H.vkorg  AS LEVEL_07_SALES_ORG_CODE,
              H.vtweg  AS LEVEL_07_DISTBN_CHNL_CODE,
              H.spart  AS LEVEL_07_DIVISION_CODE,
              H.sortl  AS LEVEL_07_SORT_LEVEL,
              H.datab  AS LEVEL_07_START_DATE,
              H.datbi  AS LEVEL_07_END_DATE,
              I.kunnr  AS LEVEL_08_CUST_CODE,
              I.vkorg  AS LEVEL_08_SALES_ORG_CODE,
              I.vtweg  AS LEVEL_08_DISTBN_CHNL_CODE,
              I.spart  AS LEVEL_08_DIVISION_CODE,
              I.sortl  AS LEVEL_08_SORT_LEVEL,
              I.datab  AS LEVEL_08_START_DATE,
              I.datbi  AS LEVEL_08_END_DATE,
              J.kunnr  AS LEVEL_09_CUST_CODE,
              J.vkorg  AS LEVEL_09_SALES_ORG_CODE,
              J.vtweg  AS LEVEL_09_DISTBN_CHNL_CODE,
              J.spart  AS LEVEL_09_DIVISION_CODE,
              J.sortl  AS LEVEL_09_SORT_LEVEL,
              J.datab  AS LEVEL_09_START_DATE,
              J.datbi  AS LEVEL_09_END_DATE,
              K.kunnr  AS LEVEL_10_CUST_CODE,
              K.vkorg  AS LEVEL_10_SALES_ORG_CODE,
              K.vtweg  AS LEVEL_10_DISTBN_CHNL_CODE,
              K.spart  AS LEVEL_10_DIVISION_CODE,
              K.sortl  AS LEVEL_10_SORT_LEVEL,
              K.datab  AS LEVEL_10_START_DATE,
              K.datbi  AS LEVEL_10_END_DATE
            FROM
              lads_hie_cus_hdr A, -- Header Information
              lads_hie_cus_det B, -- Level 1
              lads_hie_cus_det C, -- Level 2
              lads_hie_cus_det D, -- Level 3
              lads_hie_cus_det E, -- Level 4
              lads_hie_cus_det F, -- Level 5
              lads_hie_cus_det G, -- Level 6
              lads_hie_cus_det H, -- Level 7
              lads_hie_cus_det I, -- Level 8
              lads_hie_cus_det J, -- Level 9
              lads_hie_cus_det K  -- Level 10
            WHERE
              A.lads_status = '1'
              AND A.hdrdat = (SELECT
                                MAX(G.hdrdat)
                              FROM
                                lads_hie_cus_hdr G)
              AND A.hityp = 'A'
              AND A.datab <= TO_CHAR(sysdate, 'YYYYMMDD')
              AND A.datbi >= TO_CHAR(sysdate, 'YYYYMMDD')
              AND A.hdrdat = B.hdrdat
              AND A.hdrseq = B.hdrseq
              AND B.hielv = '01'
              AND B.datab <= TO_CHAR(sysdate, 'YYYYMMDD')
              AND B.datbi >= TO_CHAR(sysdate, 'YYYYMMDD')
              AND A.hdrdat = C.hdrdat (+)
              AND A.hdrseq = C.hdrseq (+)
              AND C.hielv (+) = '02'
              AND A.hdrdat = D.hdrdat (+)
              AND A.hdrseq = D.hdrseq (+)
              AND D.hielv (+) = '03'
              AND A.hdrdat = E.hdrdat (+)
              AND A.hdrseq = E.hdrseq (+)
              AND E.hielv (+) = '04'
              AND A.hdrdat = F.hdrdat (+)
              AND A.hdrseq = F.hdrseq (+)
              AND F.hielv (+) = '05'
              AND A.hdrdat = G.hdrdat (+)
              AND A.hdrseq = G.hdrseq (+)
              AND G.hielv (+) = '06'
              AND A.hdrdat = H.hdrdat (+)
              AND A.hdrseq = H.hdrseq (+)
              AND H.hielv (+) = '07'
              AND A.hdrdat = I.hdrdat (+)
              AND A.hdrseq = I.hdrseq (+)
              AND I.hielv (+) = '08'
              AND A.hdrdat = J.hdrdat (+)
              AND A.hdrseq = J.hdrseq (+)
              AND J.hielv (+) = '09'
              AND A.hdrdat = K.hdrdat (+)
              AND A.hdrseq = K.hdrseq (+)
              AND K.hielv (+) = '10'
              AND DECODE(B.vkorg, '149', 1,
                    DECODE(C.vkorg, '149', 1,
                      DECODE(D.vkorg, '149', 1,
                        DECODE(E.vkorg, '149', 1,
                          DECODE(F.vkorg, '149', 1,
                            DECODE(G.vkorg, '149', 1,
                              DECODE(H.vkorg, '149', 1,
                                DECODE(I.vkorg, '149', 1,
                                  DECODE(J.vkorg, '149', 1,
                                    DECODE(K.vkorg, '149', 1, 0)))))))))) = 1
            ) L,
            lads_adr_det M,
            lads_adr_det N,
            lads_adr_det O,
            lads_adr_det P,
            lads_adr_det Q,
            lads_adr_det R,
            lads_adr_det S,
            lads_adr_det T,
            lads_adr_det U,
            lads_adr_det V
          WHERE
            DECODE(L.LEVEL_02_START_DATE, NULL, '00000000', L.LEVEL_02_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_02_END_DATE, NULL, '99999999', L.LEVEL_02_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_03_START_DATE, NULL, '00000000', L.LEVEL_03_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_03_END_DATE, NULL, '99999999', L.LEVEL_03_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_04_START_DATE, NULL, '00000000', L.LEVEL_04_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_04_END_DATE, NULL, '99999999', L.LEVEL_04_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_05_START_DATE, NULL, '00000000', L.LEVEL_05_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_05_END_DATE, NULL, '99999999', L.LEVEL_05_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_06_START_DATE, NULL, '00000000', L.LEVEL_06_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_06_END_DATE, NULL, '99999999', L.LEVEL_06_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_07_START_DATE, NULL, '00000000', L.LEVEL_07_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_07_END_DATE, NULL, '99999999', L.LEVEL_07_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_08_START_DATE, NULL, '00000000', L.LEVEL_08_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_08_END_DATE, NULL, '99999999', L.LEVEL_08_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_09_START_DATE, NULL, '00000000', L.LEVEL_09_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_09_END_DATE, NULL, '99999999', L.LEVEL_09_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_10_START_DATE, NULL, '00000000', L.LEVEL_10_START_DATE) <= TO_CHAR(sysdate, 'YYYYMMDD')
            AND DECODE(L.LEVEL_10_END_DATE, NULL, '99999999', L.LEVEL_10_END_DATE) >= TO_CHAR(sysdate, 'YYYYMMDD')
            AND L.LEVEL_01_CUST_CODE = M.obj_id (+)
            AND L.LEVEL_02_CUST_CODE = N.obj_id (+)
            AND L.LEVEL_03_CUST_CODE = O.obj_id (+)
            AND L.LEVEL_04_CUST_CODE = P.obj_id (+)
            AND L.LEVEL_05_CUST_CODE = Q.obj_id (+)
            AND L.LEVEL_06_CUST_CODE = R.obj_id (+)
            AND L.LEVEL_07_CUST_CODE = S.obj_id (+)
            AND L.LEVEL_08_CUST_CODE = T.obj_id (+)
            AND L.LEVEL_09_CUST_CODE = U.obj_id (+)
            AND L.LEVEL_10_CUST_CODE = V.obj_id (+)
          ORDER BY
            CUST_CODE,
            SALES_ORG_CODE,
            DISTBN_CHNL_CODE,
            DIVISION_CODE,
            LEVEL_01_CUST_CODE,
            LEVEL_01_CUST_NAME_EN,
            LEVEL_01_SALES_ORG_CODE,
            LEVEL_01_DISTBN_CHNL_CODE,
            LEVEL_01_DIVISION_CODE,
            LEVEL_01_SORT_LEVEL,
            LEVEL_01_START_DATE DESC,
            LEVEL_01_END_DATE DESC,
            LEVEL_02_CUST_CODE,
            LEVEL_02_CUST_NAME_EN,
            LEVEL_02_SALES_ORG_CODE,
            LEVEL_02_DISTBN_CHNL_CODE,
            LEVEL_02_DIVISION_CODE,
            LEVEL_02_SORT_LEVEL,
            LEVEL_02_START_DATE DESC,
            LEVEL_02_END_DATE DESC,
            LEVEL_03_CUST_CODE,
            LEVEL_03_CUST_NAME_EN,
            LEVEL_03_SALES_ORG_CODE,
            LEVEL_03_DISTBN_CHNL_CODE,
            LEVEL_03_DIVISION_CODE,
            LEVEL_03_SORT_LEVEL,
            LEVEL_03_START_DATE DESC,
            LEVEL_03_END_DATE DESC,
            LEVEL_04_CUST_CODE,
            LEVEL_04_CUST_NAME_EN,
            level_04_sales_org_code,
            LEVEL_04_DISTBN_CHNL_CODE,
            LEVEL_04_DIVISION_CODE,
            LEVEL_04_SORT_LEVEL,
            LEVEL_04_START_DATE DESC,
            LEVEL_04_END_DATE DESC,
            LEVEL_05_CUST_CODE,
            LEVEL_05_CUST_NAME_EN,
            LEVEL_05_SALES_ORG_CODE,
            LEVEL_05_DISTBN_CHNL_CODE,
            LEVEL_05_DIVISION_CODE,
            LEVEL_05_SORT_LEVEL,
            LEVEL_05_START_DATE DESC,
            LEVEL_05_END_DATE DESC,
            LEVEL_06_CUST_CODE,
            LEVEL_06_CUST_NAME_EN,
            LEVEL_06_SALES_ORG_CODE,
            LEVEL_06_DISTBN_CHNL_CODE,
            LEVEL_06_DIVISION_CODE,
            LEVEL_06_SORT_LEVEL,
            LEVEL_06_START_DATE DESC,
            LEVEL_06_END_DATE DESC,
            LEVEL_07_CUST_CODE,
            LEVEL_07_CUST_NAME_EN,
            LEVEL_07_SALES_ORG_CODE,
            LEVEL_07_DISTBN_CHNL_CODE,
            LEVEL_07_DIVISION_CODE,
            LEVEL_07_SORT_LEVEL,
            LEVEL_07_START_DATE DESC,
            LEVEL_07_END_DATE DESC,
            LEVEL_08_CUST_CODE,
            LEVEL_08_CUST_NAME_EN,
            LEVEL_08_SALES_ORG_CODE,
            LEVEL_08_DISTBN_CHNL_CODE,
            LEVEL_08_DIVISION_CODE,
            LEVEL_08_SORT_LEVEL,
            LEVEL_08_START_DATE DESC,
            LEVEL_08_END_DATE DESC,
            LEVEL_09_CUST_CODE,
            LEVEL_09_CUST_NAME_EN,
            LEVEL_09_SALES_ORG_CODE,
            LEVEL_09_DISTBN_CHNL_CODE,
            LEVEL_09_DIVISION_CODE,
            LEVEL_09_SORT_LEVEL,
            LEVEL_09_START_DATE DESC,
            LEVEL_09_END_DATE DESC,
            LEVEL_10_CUST_CODE,
            LEVEL_10_CUST_NAME_EN,
            LEVEL_10_SALES_ORG_CODE,
            LEVEL_10_DISTBN_CHNL_CODE,
            LEVEL_10_DIVISION_CODE,
            LEVEL_10_SORT_LEVEL,
            level_10_start_date desc,
            level_10_end_date desc
        ) t4
      where 
        -- Table Joins
        t1.customer_code = t2.customer_code and 
        t1.customer_code = t3.customer_code and 
        t4.cust_code (+) = t3.customer_code and 
        t4.sales_org_code (+) = t3.sales_org_code and 
        t4.distbn_chnl_code (+) = t3.distbn_chnl_code and
        t4.division_code (+) = t3.division_code and    
        -- Only Customers extended into sales organisation for New Zealand.
        t3.sales_org_code = '149' and 
        -- Only show the main english customer name.
        t2.address_version = '*NONE' and
        -- Still include customer in the extract even if order block is in place if they have had sales in the last 12 weeks.
        (t3.order_block_flag is null or (t3.order_block_flag is not null and exists (select * from sale_cdw_gsv t0 where t0.sold_to_cust_code = t1.customer_code))) and 
        -- Only include customers that are not deleted.
        t3.deletion_flag is null and
        -- Only include not rasw and packs or affiliate customers
        t3.distbn_chnl_code not in ('98','99') and 
        -- Do not include demand planning nodes.
        t1.demand_plan_group_code is null;
    rv_cust_level csr_cust_level_data%rowtype; 
    -- Define the table structure for the product hierarchy.
    type tt_hierachy_collection is table of rt_hierarchy_node index by pls_integer;
    tv_hierarchy tt_hierachy_collection;
    v_counter pls_integer;
     
    -- This procedure looks through the existing node paths and checks if one already exists.  
    procedure add_path(i_cust_code in varchar2, i_cust_name in varchar2,i_parent_cust_code in varchar2,i_level in number,i_sales_org_code in varchar2) is
      rv_node rt_hierarchy_node;
      v_counter pls_integer;
      v_mover pls_integer;
      v_found boolean;
      v_stop boolean;
    begin
      -- Only add the path if the customer code supplied is not null. 
      if i_cust_code is not null then 
        v_counter := 0;
        v_found := false;
        v_stop := false;
        loop 
          v_counter := v_counter + 1;
          exit when v_counter > tv_hierarchy.count;
          -- Check if we reached the end of the nodes at this level that we need and the record hadn't been found.
          if tv_hierarchy(v_counter).node_level = i_level then
            if i_cust_code = tv_hierarchy(v_counter).cust_code then 
              v_found := true;
              -- Check that the parent node and name are the same.
              if i_cust_name <> tv_hierarchy(v_counter).cust_name or i_parent_cust_code <> tv_hierarchy(v_counter).parent_cust_code then 
                raise_application_error(pc_application_exception,'Cust Node : ' || i_cust_code || ' Cust Name or Parent Cust Code did not match a previous instance.');
              end if;
            elsif i_cust_code < tv_hierarchy(v_counter).cust_code then 
              v_stop := true;  
            end if;
          elsif i_level < tv_hierarchy(v_counter).node_level then
            v_stop := true;
          end if;
          -- If a flag has been set then exit.  
          exit when v_stop = true or v_found = true;
        end loop;
        -- If stop was executed then insert a blank space here in the hierarchy.
        if v_stop = true then 
          v_mover := tv_hierarchy.count;
          loop
            tv_hierarchy(v_mover+1) := tv_hierarchy(v_mover);
            exit when v_mover = v_counter;
            v_mover := v_mover - 1;
          end loop;
          tv_hierarchy(v_counter) := null;
        end if;
        -- If the node was not found then assign this node to the current position of the counter.
        if v_found = false then 
          rv_node.cust_code := i_cust_code;
          rv_node.cust_name := i_cust_name;
          rv_node.parent_cust_code := i_parent_cust_code;
          rv_node.node_level := i_level;
          rv_node.sales_org_code := i_sales_org_code;
          tv_hierarchy(v_counter) := rv_node;
        end if;
      end if;
    end;
    
   begin
     -- Now process each of the rows of product data and build the hierarchy data in memory.
     open csr_cust_level_data;
     loop 
       fetch csr_cust_level_data into rv_cust_level;
       exit when csr_cust_level_data%notfound;
       -- Now process the material. 
       add_path(rv_cust_level.level_01_cust_code,rv_cust_level.level_01_cust_name_en,null,1,rv_cust_level.sales_org_code);
       add_path(rv_cust_level.level_02_cust_code,rv_cust_level.level_02_cust_name_en,rv_cust_level.level_01_cust_code,2,rv_cust_level.sales_org_code);
       add_path(rv_cust_level.level_03_cust_code,rv_cust_level.level_03_cust_name_en,rv_cust_level.level_02_cust_code,3,rv_cust_level.sales_org_code);
       add_path(rv_cust_level.level_04_cust_code,rv_cust_level.level_04_cust_name_en,rv_cust_level.level_03_cust_code,4,rv_cust_level.sales_org_code);
       add_path(rv_cust_level.level_05_cust_code,rv_cust_level.level_05_cust_name_en,rv_cust_level.level_04_cust_code,5,rv_cust_level.sales_org_code);
       add_path(rv_cust_level.level_06_cust_code,rv_cust_level.level_06_cust_name_en,rv_cust_level.level_05_cust_code,6,rv_cust_level.sales_org_code);
     end loop;
     close csr_cust_level_data;
     -- Now output the actual hierarchy rows. 
     v_counter := 0;
     loop 
       v_counter := v_counter + 1;
       exit when v_counter > tv_hierarchy.count;
       pipe row(tv_hierarchy(v_counter));
     end loop;
   end get_customer_hierarchy;  

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute is
      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('301001', 6, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '301001' -> ICRecordType
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXDivisionCode
          pxi_common.char_format(cust_code, 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- cust_code -> CustomerNumber
          pxi_common.char_format(cust_name, 40, pxi_common.format_type_none, pxi_common.is_nullable) || -- cust_name -> CustomerDescription
          pxi_common.char_format(sales_org_code, 3, pxi_common.format_type_none, pxi_common.is_nullable) || -- sales_org_code -> CustomerSalesOrg
          pxi_common.char_format(parent_cust_code, 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_nullable) -- parent_cust_code -> ParentCustomerNumber
        ------------------------------------------------------------------------
        from 
          table(get_customer_hierarchy);
        --======================================================================

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Retrieve the rows
      /*-*/
      open csr_input;
      loop
         fetch csr_input into var_data;
         if csr_input%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new interface when required
         /*-*/
         if lics_outbound_loader.is_created = false then
            var_instance := lics_outbound_loader.create_interface('PXIPMX04');
         end if;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

      end loop;
      close csr_input;

      /*-*/
      /* Finalise the interface when required
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX04_EXTRACT;
/
