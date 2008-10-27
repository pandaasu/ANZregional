CREATE OR REPLACE PACKAGE PT_APP.eTrace AS
/******************************************************************************
   NAME:       eTrace
   PURPOSE:    This package will handle oracle access from the eTrace web
               application.

   REVISIONS:
   Ver        Date        Author            Description
   ---------  -------------  -------------------  ------------------------------------
   1.0        22-Oct-2007     Scott R. Harding     Created this package.
   1.1        06-Nov-2007     Liam Watson          Added reclaim, scrap, rework & consumption.
   1.2        20-Dec-2007     Scott R. Harding     Added process order status check.
   
 
******************************************************************************/
 
  /***************************************************************************/
  /* PROCEDURE:   GET_PLT_LABL_HIST 
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*        *PRT_DATETIME     DATE,
  /*        TKT_TYPE         VARCHAR2(15 BYTE) 
  /*        SSCC             VARCHAR2(20 BYTE)
  /*        MATL_CODE        VARCHAR2(18 BYTE)
  /*        MATL_DESC        VARCHAR2(40 BYTE)
  /*        VNDR_BATCH       VARCHAR2(20 BYTE)
  /*        PRODN_DATE       DATE
  /*        PRODN_TIME       VARCHAR2(6 BYTE)
  /*        BBD              DATE
  /*        QTY              NUMBER(12,3)
  /*        UOM              VARCHAR2(6 BYTE)
  /*        QTY_PER_PLT      NUMBER(12,3)
  /*        NUM_TKT_PRTD     NUMBER(6)
  /*        SNDR_PLANT       VARCHAR2(6 BYTE)
  /*        CUST_PURCH_ORD   VARCHAR2(20 BYTE)
  /*        SPLR_NAME        VARCHAR2(50 BYTE)
  /*        GTIN             VARCHAR2(20 BYTE)
  /*        XFER_IND         CHAR(1 BYTE)
  /*        STRGE_LOCN       VARCHAR2(30 BYTE)
  /*        VNDR             VARCHAR2(20 BYTE)
  /*        LAST_UPD_DATIME  DATE
  /*        OLD_MATL_CODE    VARCHAR2(18 BYTE)
  /**************************************************************************/
--  PROCEDURE GET_PLT_LABL_HIST(o_result OUT NUMBER, 
--                       o_result_msg OUT VARCHAR2,
--                       i_prt_datetime IN VARCHAR2,
--                       i_tkt_type IN VARCHAR2,
--                       i_sscc IN VARCHAR2,
--                       i_matl_code IN VARCHAR2,
--                       i_vndr_batch IN VARCHAR2,
--                       o_retrieve OUT Common.RETURN_REF_CURSOR);

  /***************************************************************************/
  /* PROCEDURE:   GET_PLT_INFO 
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*        CREATE_DATTIME   DATE,
  /*        SSCC             VARCHAR2(20 BYTE)
  /*        MATL_CODE        VARCHAR2(18 BYTE)
  /*        MATL_DESC        VARCHAR2(40 BYTE)
  /*        BATCH_CODE       VARCHAR2(20 BYTE)
  /*        PLANT_code       VARCHAR2(6 BYTE)
  /*        last_gr_flag     varchar2(1 byte)
  /*        PRODN_TIME       VARCHAR2(6 BYTE)
  /*        QTY              NUMBER(12,3)
  /*        UOM              VARCHAR2(6 BYTE)
  /*        XACTN_TYPE       varchar2(10 byte)
  /*        STRGE_LOCN       VARCHAR2(30 BYTE)
  /*        OLD_MATL_CODE    VARCHAR2(18 BYTE)
  /*        CREATE_DATIME          varchar2
  /**************************************************************************/
  PROCEDURE GET_PLT_INFO(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR);
                       

 /***************************************************************************/
  /* PROCEDURE:   GET_CNSMPTN
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
  PROCEDURE GET_CNSMPTN(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_plt_cnsmptn_id IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR);                     
                       

 /***************************************************************************/
  /* PROCEDURE:   GET_REWORK
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
PROCEDURE GET_REWORK(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR);                    
                       
                       
                       

 /***************************************************************************/
  /* PROCEDURE:   GET_SCRAP
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
  PROCEDURE GET_SCRAP(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR);                     
                       
                    
                     
  
 /***************************************************************************/
  /* PROCEDURE:   GET_RECLAIM
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
PROCEDURE GET_RECLAIM(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR);  
                       
  /***************************************************************************/
  /* PROCEDURE:   GET_RECIPE_HEADER 
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*        proc_order
  /*        teco_status
  /*        plant_code
  /*        material
  /*        material_text
  /*        quantity
  /*        uom
  /*        run_start_datime
  /*        run_end_datime
  /**************************************************************************/
  PROCEDURE GET_RECIPE_HEADER(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR);                        
                       
                         
                                                 
END eTrace;
/

CREATE OR REPLACE PACKAGE BODY PT_APP.Etrace AS

     /*-*/
    /* Private exceptions
    /*-*/
    application_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(application_exception, -20000);



--  PROCEDURE GET_PLT_LABL_HIST(o_result OUT NUMBER, 
--                       o_result_msg OUT VARCHAR2,
--                       i_prt_datetime IN VARCHAR2,
--                       i_tkt_type IN VARCHAR2,
--                       i_sscc IN VARCHAR2,
--                       i_matl_code IN VARCHAR2,
--                       i_vndr_batch IN VARCHAR2,
--                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS
--  BEGIN
--  
--      o_result  := Constants.SUCCESS;
--      o_result_msg := 'Success';
--  
--      OPEN o_retrieve FOR
--          
--    SELECT t01.tkt_type, 
--           t01.sscc, 
--           t01.matl_code, 
--           t01.matl_desc,
--           t01.vndr_batch, 
--           t01.prodn_date,
--           t01.prodn_time,
--           t01.bbd, 
--           t01.qty,
--           t01.uom,
--           t03.proc_order,  
--           t01.qty_per_plt, 
--           t01.num_tkt_prtd,
--           t01.sndr_plant, 
--           t01.cust_purch_ord, 
--           t01.splr_name, 
--           t01.gtin, 
--           t01.xfer_ind,
--           t01.strge_locn, 
--           t01.vndr,  
--           t01.last_upd_datime,
--           t03.status, 
--           t03.batch_code,
--           t01.old_matl_code
--      FROM plt_labl_hist t01,
--           (SELECT t02.* 
--              FROM (SELECT t01.plt_code,
--                          proc_order,
--                          zpppi_batch AS batch_code,
--                          last_gr_flag,
--                          status,
--                          t01.plt_create_datime,
--                          rank() OVER (PARTITION BY t01.plt_code, matl_code
--                                      ORDER BY xactn_type ASC) AS rnk
--                     FROM plt_hdr t01,
--                          plt_det t02
--                    WHERE t01.plt_code = t02.plt_code) t02
--             WHERE rnk = 1) t03
--     WHERE t01.sscc = t03.plt_code(+)
--       AND (TO_CHAR(prt_datetime,'yyyymmdd') LIKE '%' || i_prt_datetime || '%' OR i_prt_datetime IS NULL)
--       AND (sscc LIKE '%' || TRIM(i_sscc) || '%' OR i_sscc IS NULL)
--       AND (UPPER(tkt_type) LIKE '%' || UPPER(TRIM(i_tkt_type)) || '%' OR i_tkt_type IS NULL)
--       AND (matl_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
--       AND (UPPER(vndr_batch) LIKE '%' || UPPER(TRIM(i_vndr_batch)) || '%' OR i_vndr_batch IS NULL)
-- ORDER BY prt_datetime DESC;
--    
--  EXCEPTION
--      WHEN OTHERS THEN
--        o_result  := Constants.FAILURE;
--        o_result_msg := 'eTrace.GET_PLT_LABL_HIST procedure failed' || CHR(13)
--                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
--        /*-*/
--        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
--        /* to sending the result variables back to the calling application
--        /*-*/
--        OPEN o_retrieve FOR 
--        SELECT * FROM dual WHERE 1=0;
--  END GET_PLT_LABL_HIST;
 
 
  PROCEDURE GET_PLT_INFO(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS
   BEGIN
  
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
  
      OPEN o_retrieve FOR
      SELECT t01.plt_code AS sscc,
             t01.proc_order,
             t01.matl_code,
             t03.bds_material_desc_en AS matl_desc,
             t01.zpppi_batch AS batch_code,
             decode(upper(t01.dispn_code),'S','Blocked','X','Quality Inspect',' ','Unrestricted','Undefined') as disposition,
             t01.plant_code,
             t01.last_gr_flag,
             t01.qty,
             t01.uom,
             t02.xactn_type,
             t01.plt_create_datime,
             TO_CHAR(t02.xactn_date,'dd/mm/yyyy') || ' ' || SUBSTR(LPAD(t02.xactn_time,6,'0'),1,2) || ':' || SUBSTR(LPAD(t02.xactn_time,6,'0'),3,2) || ':' || SUBSTR(LPAD(t02.xactn_time,6,'0'),5,2) AS Xactn_Date,
             LPAD(t01.stor_locn_code,4,'0') AS strge_locn,
             LTRIM(t03.regional_code_19, '0') AS old_matl_code,
             LPAD(t04.tolas_seq,8,'0') AS tolas_seq
        FROM plt_hdr t01,
             plt_det t02,
             bds_material_plant_mfanz t03,
             plt_tolas t04
       WHERE t01.plt_code = t02.plt_code
         AND t01.matl_code = LTRIM(t03.sap_material_code,'0')
         AND t01.plant_code = t03.plant_code
         AND t01.plt_code = t04.plt_code (+)
         AND (t01.plt_code LIKE '%' || TRIM(i_sscc) || '%' OR i_sscc IS NULL)
         AND (matl_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
         AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
         AND (t01.zpppi_batch LIKE '%' || TRIM(i_batch_code) || '%' OR i_batch_code IS NULL)
         AND (TO_CHAR(plt_create_datime,'yyyymmdd') LIKE '%' || i_create_datime || '%' OR i_create_datime IS NULL)
       ORDER BY plt_create_datime DESC;
      
                       
 EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'eTrace.GET_PLT_INFO procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
        /* to sending the result variables back to the calling application
        /*-*/
        OPEN o_retrieve FOR 
        SELECT * FROM dual WHERE 1=0;
  END GET_PLT_INFO;
  
                               
  PROCEDURE GET_CNSMPTN(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_plt_cnsmptn_id IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS
   BEGIN
  
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
  
      OPEN o_retrieve FOR
  
        SELECT t01.plt_cnsmptn_id,
               t01.proc_order,
               t01.matl_code,
               t02.bds_material_desc_en AS matl_desc,
               t01.qty,
               t01.uom,
               t01.plant_code,
               t01.sent_flag,
               t01.store_locn,
               t01.upd_datime,
               t01.trans_id,
               t01.trans_type
        FROM plt_cnsmptn t01, bds_material_plant_mfanz t02
        WHERE t01.matl_code = LTRIM(t02.sap_material_code, '0')
            AND t01.plant_code = t02.plant_code
            AND (t01.plt_cnsmptn_id LIKE '%' || TRIM(i_plt_cnsmptn_id) || '%' OR i_plt_cnsmptn_id IS NULL)
            AND (matl_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
            AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
            AND (TO_CHAR(upd_datime,'yyyymmdd') LIKE '%' || i_create_datime || '%' OR i_create_datime IS NULL)
        ORDER BY upd_datime DESC;
      /*
      SELECT t01.plt_code AS sscc,
             t01.proc_order,
             t01.matl_code,
             t03.bds_material_desc_en AS matl_desc,
             t01.zpppi_batch AS batch_code,
             t01.plant_code,
             t01.last_gr_flag,
             t01.qty,
             t01.uom,
             t02.xactn_type,
             t01.plt_create_datime,
             t01.stor_locn_code AS strge_locn,
             t03.regional_code_19 AS old_matl_code
        FROM plt_hdr t01,
             plt_det t02,
             bds_material_plant_mfanz t03
       WHERE t01.plt_code = t02.plt_code
         AND t01.matl_code = LTRIM(t03.sap_material_code,'0')
         AND t01.plant_code = t03.plant_code
         AND (t01.plt_code LIKE '%' || TRIM(i_sscc) || '%' OR i_sscc IS NULL)
         AND (matl_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
         AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
         AND (TO_CHAR(plt_create_datime,'yyyymmdd') LIKE '%' || i_create_datime || '%' OR i_create_datime IS NULL);
       */
                       
 EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
        /* to sending the result variables back to the calling application
        /*-*/
        OPEN o_retrieve FOR 
        SELECT * FROM dual WHERE 1=0;
  END GET_CNSMPTN;  
  
  
  
  
   
  

    PROCEDURE GET_REWORK(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS
   BEGIN
  
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
  
      OPEN o_retrieve FOR
  
      SELECT scrap_rework_id,
             sent_flag, 
             proc_order,
             matl_code,
             t02.bds_material_desc_en AS matl_desc,
             plt_code,
             qty,
             uom,
             storage_locn,
             batch_code,
             event_datime,
             t01.plant_code,
             reason_code,
             rework_code,
             rework_batch_code,
             rework_exp_date,
             rework_sloc,
             cost_centre,
             bin_code,
             area_in_code,
             area_out_code,
             status_code
      FROM scrap_rework t01, bds_material_plant_mfanz t02
      WHERE t01.matl_code = LTRIM(t02.sap_material_code, '0')
          AND t01.plant_code = t02.plant_code
          AND scrap_rework_code='R'
          AND (t01.plt_code LIKE '%' || TRIM(i_sscc) || '%' OR i_sscc IS NULL)
          AND (batch_code LIKE '%' || TRIM(i_batch_code) || '%' OR i_batch_code IS NULL)
          AND (matl_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
          AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
          AND (TO_CHAR(event_datime,'yyyymmdd') LIKE '%' || i_create_datime || '%' OR i_create_datime IS NULL)
      ORDER BY event_datime DESC;

                       
 EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
        /* to sending the result variables back to the calling application
        /*-*/
        OPEN o_retrieve FOR 
        SELECT * FROM dual WHERE 1=0;
  END GET_REWORK;  
 
 
 
     PROCEDURE GET_SCRAP(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS
   BEGIN
  
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
  
      OPEN o_retrieve FOR
  
      SELECT scrap_rework_id,
             sent_flag, 
             proc_order,
             matl_code,
             t02.bds_material_desc_en AS matl_desc,
             plt_code,
             qty,
             uom,
             storage_locn,
             batch_code,
             event_datime,
             t01.plant_code,
             reason_code,
             cost_centre,
             bin_code,
             area_in_code,
             area_out_code,
             status_code
      FROM scrap_rework t01, bds_material_plant_mfanz t02
      WHERE t01.matl_code = LTRIM(t02.sap_material_code, '0')
          AND t01.plant_code = t02.plant_code
          AND scrap_rework_code='S'
          AND (t01.plt_code LIKE '%' || TRIM(i_sscc) || '%' OR i_sscc IS NULL)
          AND (matl_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
          AND (batch_code LIKE '%' || TRIM(i_batch_code) || '%' OR i_batch_code IS NULL)      
          AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
          AND (TO_CHAR(event_datime,'yyyymmdd') LIKE '%' || i_create_datime || '%' OR i_create_datime IS NULL)
      ORDER BY event_datime DESC;

                       
 EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
        /* to sending the result variables back to the calling application
        /*-*/
        OPEN o_retrieve FOR 
        SELECT * FROM dual WHERE 1=0;
  END GET_SCRAP;    
                    
  
  
  
  
PROCEDURE GET_RECLAIM(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_create_datime IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_batch_code IN VARCHAR2,
                       i_sscc IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS
  
    BEGIN
  
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
  
      OPEN o_retrieve FOR
  
      SELECT reclaim_ltds_id,
             plt_code,
             material_code,
             t02.bds_material_desc_en AS matl_desc,
             qty,
             t01.plant_code,
             proc_order,
             dispn_code,
             batch_code,
             use_by_date,
             transaction_type,
             last_upd_by,
             last_upd_datime
      FROM plt_reclaim t01, bds_material_plant_mfanz t02
      WHERE t01.material_code = LTRIM(t02.sap_material_code, '0')
          AND t01.plant_code = t02.plant_code
          AND (t01.plt_code LIKE '%' || TRIM(i_sscc) || '%' OR i_sscc IS NULL)
          AND (material_code LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
          AND (batch_code LIKE '%' || TRIM(i_batch_code) || '%' OR i_batch_code IS NULL)      
          AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
          AND (TO_CHAR(use_by_date,'yyyymmdd') LIKE '%' || i_create_datime || '%' OR i_create_datime IS NULL)
      ORDER BY use_by_date DESC;

                       
 EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
        /* to sending the result variables back to the calling application
        /*-*/
        OPEN o_retrieve FOR 
        SELECT * FROM dual WHERE 1=0;
  END GET_RECLAIM;  
                        

  PROCEDURE GET_RECIPE_HEADER(o_result OUT NUMBER, 
                       o_result_msg OUT VARCHAR2,
                       i_matl_code IN VARCHAR2,
                       i_proc_order IN VARCHAR2,
                       o_retrieve OUT Common.RETURN_REF_CURSOR) IS  

   BEGIN
  
      o_result  := Constants.SUCCESS;
      o_result_msg := 'Success';
  
      OPEN o_retrieve FOR
      
         SELECT   proc_order, 
                  teco_status, 
                  plant_code, 
                  material, 
                  material_text,
                  quantity, 
                  uom, 
                  run_start_datime, 
                  run_end_datime
           FROM   bds_recipe_header
           WHERE (material LIKE '%' || TRIM(i_matl_code) || '%' OR i_matl_code IS NULL)
                 AND (proc_order LIKE '%' || TRIM(i_proc_order) || '%' OR i_proc_order IS NULL)
        ORDER BY run_start_datime ASC;
       
      
                       
 EXCEPTION
      WHEN OTHERS THEN
        o_result  := Constants.FAILURE;
        o_result_msg := 'eTrace.GET_RECIPE_HEADER procedure failed' || CHR(13)
                        || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);    
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
        /* to sending the result variables back to the calling application
        /*-*/
        OPEN o_retrieve FOR 
        SELECT * FROM dual WHERE 1=0;
  END GET_RECIPE_HEADER;
                                               
                                                                                        
END Etrace;
/

GRANT EXECUTE ON PT_APP.ETRACE TO APPSUPPORT;
GRANT EXECUTE ON PT_APP.ETRACE TO ETRACE_WEB;

CREATE OR REPLACE PUBLIC SYNONYM ETRACE FOR PT_APP.ETRACE;