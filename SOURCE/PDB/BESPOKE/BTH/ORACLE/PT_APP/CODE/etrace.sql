create or replace package pt_app.etrace as
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
  procedure get_plt_labl_hist(o_result out number, 
                              o_result_msg out varchar2,
                              i_prt_datetime in varchar2,
                              i_tkt_type in varchar2,
                              i_sscc in varchar2,
                              i_matl_code in varchar2,
                              i_vndr_batch in varchar2,
                              o_retrieve out plt_common.return_ref_cursor);

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
  procedure get_plt_info(o_result out number, 
                         o_result_msg out varchar2,
                         i_create_datime in varchar2,
                         i_sscc in varchar2,
                         i_matl_code in varchar2,
                         i_proc_order in varchar2,
                         i_batch_code in varchar2,
                         o_retrieve out plt_common.return_ref_cursor);                       

 /***************************************************************************/
  /* PROCEDURE:   GET_CNSMPTN
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
  procedure get_cnsmptn(o_result out number, 
                        o_result_msg out varchar2,
                        i_create_datime in varchar2,
                        i_plt_cnsmptn_id in varchar2,
                        i_proc_order in varchar2,
                        i_matl_code in varchar2,
                        o_retrieve out plt_common.return_ref_cursor);

 /***************************************************************************/
  /* PROCEDURE:   GET_REWORK
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
  procedure get_rework(o_result out number, 
                       o_result_msg out varchar2,
                       i_create_datime in varchar2,
                       i_proc_order in varchar2,
                       i_matl_code in varchar2,
                       i_batch_code in varchar2,
                       i_sscc in varchar2,
                       o_retrieve out plt_common.return_ref_cursor);               

 /***************************************************************************/
  /* PROCEDURE:   GET_SCRAP
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
  procedure get_scrap(o_result out number, 
                      o_result_msg out varchar2,
                      i_create_datime in varchar2,
                      i_proc_order in varchar2,
                      i_matl_code in varchar2,
                      i_batch_code in varchar2,
                      i_sscc in varchar2,
                      o_retrieve out plt_common.return_ref_cursor);
  
 /***************************************************************************/
  /* PROCEDURE:   GET_RECLAIM
  /* PARAMETERS:  variable         type           length         example
  /*              o_result         number           1            0,1 0r 2 
  /*              o_result_msg     string           2000         oracle error ORA-20000 ....                                                 
  /*              o_retrieve       dataset returned                                                 
  /* DATASET
  /*
  /**************************************************************************/
procedure get_reclaim(o_result out number, 
                      o_result_msg out varchar2,
                      i_create_datime in varchar2,
                      i_proc_order in varchar2,
                      i_matl_code in varchar2,
                      i_batch_code in varchar2,
                      i_sscc in varchar2,
                      o_retrieve out plt_common.return_ref_cursor);  
                       
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
  procedure get_recipe_header(o_result out number, 
                              o_result_msg out varchar2,
                              i_matl_code in varchar2,
                              i_proc_order in varchar2,
                              o_retrieve out plt_common.return_ref_cursor);                        
                                              
end etrace;
/

create or replace package body pt_app.etrace as

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  procedure get_plt_labl_hist(o_result out number, 
                              o_result_msg out varchar2,
                              i_prt_datetime in varchar2,
                              i_tkt_type in varchar2,
                              i_sscc in varchar2,
                              i_matl_code in varchar2,
                              i_vndr_batch in varchar2,
                              o_retrieve out plt_common.return_ref_cursor) is
  begin
    
    o_result  := constants.success;
    o_result_msg := 'Success';
    
    open o_retrieve for            
      select --t01.prt_datetime, 
        t01.tkt_type, 
        t01.sscc, 
        --item_code, 
        t01.matl_code, 
        t01.matl_desc,
        t01.vndr_batch, 
        t01.prodn_date,
        t01.prodn_time,
        t01.bbd, 
        t01.qty,
        t01.uom,
        t03.proc_order,  
        t01.qty_per_plt, 
        t01.num_tkt_prtd,
        t01.sndr_plant, 
        t01.cust_purch_ord, 
        t01.splr_name, 
        t01.gtin, 
        t01.xfer_ind,
        t01.strge_locn, 
        t01.vndr,  
        --user_id, 
        t01.last_upd_datime,
        t03.status, 
        t03.batch_code,
        t01.old_matl_code
      from plt_labl_hist t01,
        (
          select t02.* 
          from 
            (
              select t01.plt_code,
                proc_order,
                zpppi_batch as batch_code,
                last_gr_flag,
                status,
                t01.plt_create_datime,
                rank() over (partition by t01.plt_code, matl_code order by xactn_type asc) as rnk
              from plt_hdr t01,
                plt_det t02
              where t01.plt_code = t02.plt_code
            ) t02
            where rnk = 1
        ) t03
      where t01.sscc = t03.plt_code(+)
        and (to_char(prt_datetime,'yyyymmdd') like '%' || i_prt_datetime || '%' or i_prt_datetime is null)
        and (sscc like '%' || trim(i_sscc) || '%' or i_sscc is null)
        and (upper(tkt_type) like '%' || upper(trim(i_tkt_type)) || '%' or i_tkt_type is null)
        and (matl_code like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (upper(vndr_batch) like '%' || upper(trim(i_vndr_batch)) || '%' or i_vndr_batch is null)
      order by prt_datetime desc;
      
  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_PLT_LABL_HIST procedure failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring prior to sending the
      /* result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual 
        where 1=0;
  end get_plt_labl_hist; 
 
  procedure get_plt_info(o_result out number, 
                         o_result_msg out varchar2,
                         i_create_datime in varchar2,
                         i_sscc in varchar2,
                         i_matl_code in varchar2,
                         i_proc_order in varchar2,
                         i_batch_code in varchar2,
                         o_retrieve out plt_common.return_ref_cursor) is
  begin
    
    o_result  := constants.success;
    o_result_msg := 'Success';
      
    open o_retrieve for
      select t01.plt_code as sscc,
        t01.proc_order,
        t01.matl_code,
        t03.bds_material_desc_en as matl_desc,
        t01.zpppi_batch as batch_code,
        decode(upper(t01.dispn_code),'S','Blocked','X','Quality Inspect',' ','Unrestricted','Undefined') as disposition,
        t01.plant_code,
        t01.last_gr_flag,
        t01.qty,
        t01.uom,
        t02.xactn_type,
        t01.plt_create_datime,
        to_char(t02.xactn_date,'dd/mm/yyyy') || ' ' || substr(lpad(t02.xactn_time,6,'0'),1,2) || ':' || substr(lpad(t02.xactn_time,6,'0'),3,2) || ':' || substr(lpad(t02.xactn_time,6,'0'),5,2) as xactn_date,
        lpad(t01.stor_locn_code,4,'0') as strge_locn,
        ltrim(t03.regional_code_19, '0') as old_matl_code,
        lpad(t04.tolas_seq,8,'0') as tolas_seq
      from plt_hdr t01,
        plt_det t02,
        bds_material_plant_mfanz t03,
        plt_tolas t04
      where t01.plt_code = t02.plt_code
        and t01.matl_code = ltrim(t03.sap_material_code,'0')
        and t01.plant_code = t03.plant_code
        and t01.plt_code = t04.plt_code (+)
        and (t01.plt_code like '%' || trim(i_sscc) || '%' or i_sscc is null)
        and (matl_code like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (proc_order like '%' || trim(i_proc_order) || '%' or i_proc_order is null)
        and (t01.zpppi_batch like '%' || trim(i_batch_code) || '%' or i_batch_code is null)
        and (to_char(plt_create_datime,'yyyymmdd') like '%' || i_create_datime || '%' or i_create_datime is null)
      order by plt_create_datime desc;

  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_PLT_INFO procedure failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
      /* to sending the result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual 
        where 1=0;
  end get_plt_info;  
                               
  procedure get_cnsmptn(o_result out number, 
                        o_result_msg out varchar2,
                        i_create_datime in varchar2,
                        i_plt_cnsmptn_id in varchar2,
                        i_proc_order in varchar2,
                        i_matl_code in varchar2,
                        o_retrieve out plt_common.return_ref_cursor) is
  begin
    
    o_result  := constants.success;
    o_result_msg := 'Success';
      
    open o_retrieve for      
      select t01.plt_cnsmptn_id,
        t01.proc_order,
        t01.matl_code,
        t02.bds_material_desc_en as matl_desc,
        t01.qty,
        t01.uom,
        t01.plant_code,
        t01.sent_flag,
        t01.store_locn,
        t01.upd_datime,
        t01.trans_id,
        t01.trans_type
      from plt_cnsmptn t01, bds_material_plant_mfanz t02
      where t01.matl_code = ltrim(t02.sap_material_code, '0')
        and t01.plant_code = t02.plant_code
        and (t01.plt_cnsmptn_id like '%' || trim(i_plt_cnsmptn_id) || '%' or i_plt_cnsmptn_id is null)
        and (matl_code like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (proc_order like '%' || trim(i_proc_order) || '%' or i_proc_order is null)
        and (to_char(upd_datime,'yyyymmdd') like '%' || i_create_datime || '%' or i_create_datime is null)
      order by upd_datime desc;
                           
  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
      /* to sending the result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual 
        where 1=0;
  end get_cnsmptn;  

  procedure get_rework(o_result out number, 
                       o_result_msg out varchar2,
                       i_create_datime in varchar2,
                       i_proc_order in varchar2,
                       i_matl_code in varchar2,
                       i_batch_code in varchar2,
                       i_sscc in varchar2,
                       o_retrieve out plt_common.return_ref_cursor) is
  begin
    
    o_result  := constants.success;
    o_result_msg := 'Success';
      
    open o_retrieve for      
      select scrap_rework_id,
        sent_flag, 
        proc_order,
        matl_code,
        t02.bds_material_desc_en as matl_desc,
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
      from scrap_rework t01, 
        bds_material_plant_mfanz t02
      where t01.matl_code = ltrim(t02.sap_material_code, '0')
        and t01.plant_code = t02.plant_code
        and scrap_rework_code='R'
        and (t01.plt_code like '%' || trim(i_sscc) || '%' or i_sscc is null)
        and (batch_code like '%' || trim(i_batch_code) || '%' or i_batch_code is null)
        and (matl_code like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (proc_order like '%' || trim(i_proc_order) || '%' or i_proc_order is null)
        and (to_char(event_datime,'yyyymmdd') like '%' || i_create_datime || '%' or i_create_datime is null)
      order by event_datime desc;
                         
  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || chr(13)
      || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
      /* to sending the result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual 
        where 1=0;
  end get_rework; 
 
  procedure get_scrap(o_result out number, 
                      o_result_msg out varchar2,
                      i_create_datime in varchar2,
                      i_proc_order in varchar2,
                      i_matl_code in varchar2,
                      i_batch_code in varchar2,
                      i_sscc in varchar2,
                      o_retrieve out plt_common.return_ref_cursor) is
  begin
    
    o_result  := constants.success;
    o_result_msg := 'Success';
      
    open o_retrieve for      
      select scrap_rework_id,
        sent_flag, 
        proc_order,
        matl_code,
        t02.bds_material_desc_en as matl_desc,
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
      from scrap_rework t01, 
        bds_material_plant_mfanz t02
      where t01.matl_code = ltrim(t02.sap_material_code, '0')
        and t01.plant_code = t02.plant_code
        and scrap_rework_code='S'
        and (t01.plt_code like '%' || trim(i_sscc) || '%' or i_sscc is null)
        and (matl_code like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (batch_code like '%' || trim(i_batch_code) || '%' or i_batch_code is null)      
        and (proc_order like '%' || trim(i_proc_order) || '%' or i_proc_order is null)
        and (to_char(event_datime,'yyyymmdd') like '%' || i_create_datime || '%' or i_create_datime is null)
      order by event_datime desc;
                      
  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
      /* to sending the result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual 
        where 1=0;
  end get_scrap;  
  
  procedure get_reclaim(o_result out number, 
                        o_result_msg out varchar2,
                        i_create_datime in varchar2,
                        i_proc_order in varchar2,
                        i_matl_code in varchar2,
                        i_batch_code in varchar2,
                        i_sscc in varchar2,
                        o_retrieve out plt_common.return_ref_cursor) is
                          
  begin
    
    o_result  := constants.success;
    o_result_msg := 'Success';
      
    open o_retrieve for      
      select reclaim_ltds_id,
        plt_code,
        material_code,
        t02.bds_material_desc_en as matl_desc,
        qty,
        t01.plant_code,
        proc_order,
        dispn_code,
        batch_code,
        use_by_date,
        transaction_type,
        last_upd_by,
        last_upd_datime
      from plt_reclaim t01, 
        bds_material_plant_mfanz t02
      where t01.material_code = ltrim(t02.sap_material_code, '0')
        and t01.plant_code = t02.plant_code
        and (t01.plt_code like '%' || trim(i_sscc) || '%' or i_sscc is null)
        and (material_code like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (batch_code like '%' || trim(i_batch_code) || '%' or i_batch_code is null)      
        and (proc_order like '%' || trim(i_proc_order) || '%' or i_proc_order is null)
        and (to_char(use_by_date,'yyyymmdd') like '%' || i_create_datime || '%' or i_create_datime is null)
      order by use_by_date desc;
                           
  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_CNSMPTN procedure failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
      /* to sending the result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual 
        where 1=0;
  end get_reclaim;  
                        

  procedure get_recipe_header(o_result out number, 
                              o_result_msg out varchar2,
                              i_matl_code in varchar2,
                              i_proc_order in varchar2,
                              o_retrieve out plt_common.return_ref_cursor) is  

  begin
      
    o_result  := constants.success;
    o_result_msg := 'Success';
      
    open o_retrieve for          
      select proc_order, 
        teco_status, 
        plant_code, 
        material, 
        material_text,
        quantity, 
        uom, 
        run_start_datime, 
        run_end_datime
      from bds_recipe_header
      where (material like '%' || trim(i_matl_code) || '%' or i_matl_code is null)
        and (proc_order like '%' || trim(i_proc_order) || '%' or i_proc_order is null)
      order by run_start_datime asc;    
                         
  exception
    when others then
      o_result  := constants.failure;
      o_result_msg := 'eTrace.GET_RECIPE_HEADER procedure failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 512);    
      /*-*/
      /* this creates a dummy cursor to prevent an oracle error occuring priorto sending the
      /* to sending the result variables back to the calling application
      /*-*/
      open o_retrieve for 
        select * 
        from dual
        where 1=0;
  end get_recipe_header;
                                                 
                                                                                          
end etrace;
/

grant execute on pt_app.etrace to appsupport;
grant execute on pt_app.etrace to etrace_app;
grant execute on pt_app.etrace to etrace_web;

create or replace public synonym etrace for pt_app.etrace;