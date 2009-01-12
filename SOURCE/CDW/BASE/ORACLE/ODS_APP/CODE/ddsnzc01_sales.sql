create or replace package ddsnzf01_sales as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ddsnzf01_sales
 Owner   : ods_app

 Description
 -----------
 Sales Data with COndition Type for NZ (149)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/10   Linden Glen    Created
                           
*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_start_yyyypp in varchar2, par_end_yyyypp in varchar2);

end ddsnzf01_sales;
/

/****************/
/* Package Body */
/****************/
create or replace package body ddsnzf01_sales as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_start_yyyypp in varchar2, par_end_yyyypp in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select a.billing_doc_num || ',' ||
                a.billing_doc_line_num || ',' ||
                a.billing_trace_seqn || ',' ||
                a.creatn_date || ',' ||
                a.creatn_yyyyppdd || ',' ||
                a.creatn_yyyyppw || ',' ||
                a.creatn_yyyypp || ',' ||
                a.creatn_yyyymm || ',' ||
                a.billing_eff_date || ',' ||
                a.billing_eff_yyyyppdd || ',' ||
                a.billing_eff_yyyyppw || ',' ||
                a.billing_eff_yyyypp || ',' ||
                a.billing_eff_yyyymm || ',' ||
                a.order_doc_num || ',' ||
                a.order_doc_line_num || ',' ||
                a.purch_order_doc_num || ',' ||
                a.purch_order_doc_line_num || ',' ||
                a.dlvry_doc_num || ',' ||
                a.dlvry_doc_line_num || ',' ||
                a.company_code || ',' ||
                a.hdr_sales_org_code || ',' ||
                a.hdr_distbn_chnl_code || ',' ||
                a.hdr_division_code || ',' ||
                a.gen_sales_org_code || ',' ||
                a.gen_distbn_chnl_code || ',' ||
                a.gen_division_code || ',' ||
                a.doc_currcy_code || ',' ||
                a.company_currcy_code || ',' ||
                a.exch_rate || ',' ||
                a.invc_type_code || ',' ||
                a.order_type_code || ',' ||
                a.order_reasn_code || ',' ||
                a.order_usage_code || ',' ||
                a.sold_to_cust_code || ',' ||
                a.bill_to_cust_code || ',' ||
                a.payer_cust_code || ',' ||
                a.ship_to_cust_code || ',' ||
                a.matl_code || ',' ||
                a.ods_matl_code || ',' ||
                a.matl_entd || ',' ||
                a.plant_code || ',' ||
                a.storage_locn_code || ',' ||
                a.order_qty || ',' ||
                a.billed_weight_unit || ',' ||
                a.billed_gross_weight || ',' ||
                a.billed_net_weight || ',' ||
                a.billed_uom_code || ',' ||
                a.billed_base_uom_code || ',' ||
                a.billed_qty || ',' ||
                a.billed_qty_base_uom || ',' ||
                a.billed_qty_gross_tonnes || ',' ||
                a.billed_qty_net_tonnes || ',' ||
                a.billed_gsv || ',' ||
                a.billed_gsv_xactn || ',' ||
                a.billed_gsv_aud || ',' ||
                a.billed_gsv_usd || ',' ||
                a.billed_gsv_eur || ',' ||
                a.mfanz_icb_flag || ',' ||
                a.demand_plng_grp_division_code || ',' ||
                b.zn00_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn01_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn02_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn07_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn08_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn03_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn04_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn05_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn06_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn09_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn10_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zn11_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zk33_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) || ',' ||
                b.zk35_condition*decode(nvl(c.invc_type_sign,'x'),'-',-1,1) as extract_data
         from dw_sales_base a,
              (select t01.belnr, 
                      t01.posex, 
                      max(case when t02.kschl = 'ZN00' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN00_condition,    
                      max(case when t02.kschl = 'ZN01' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN01_condition,   
                      max(case when t02.kschl = 'ZN02' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN02_condition,   
                      max(case when t02.kschl = 'ZN07' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN07_condition,
                      max(case when t02.kschl = 'ZN08' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN08_condition,   
                      max(case when t02.kschl = 'ZN03' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN03_condition,  
                      max(case when t02.kschl = 'ZN04' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN04_condition,   
                      max(case when t02.kschl = 'ZN05' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN05_condition, 
                      max(case when t02.kschl = 'ZN06' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN06_condition,   
                      max(case when t02.kschl = 'ZN09' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN09_condition,    
                      max(case when t02.kschl = 'ZN10' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN10_condition,     
                      max(case when t02.kschl = 'ZN11' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZN11_condition,   
                      max(case when t02.kschl = 'ZK33' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZK33_condition,    
                      max(case when t02.kschl = 'ZK35' then decode(t02.alckz,'-',-1,1)*nvl(dw_to_number(t02.betrg),0) end) as ZK35_condition
               from sap_inv_gen t01,
                    sap_inv_icn t02
               where t01.belnr = t02.belnr
                 and t01.genseq = t02.genseq
                 and t02.kschl in ('ZN00','ZN01','ZN02','ZN07','ZN08','ZN03','ZN04','ZN05','ZN06','ZN09','ZN10','ZN11','ZK33','ZK35')
               group by t01.belnr, t01.posex) b,
              invc_type c
         where a.billing_doc_num = b.belnr(+)
           and a.billing_doc_line_num = b.posex(+)
           and a.invc_type_code = c.invc_type_code(+)
           and a.company_code = '149'
           and a.billing_eff_yyyypp between par_start_yyyypp and par_end_yyyypp;
      rec_extract  csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      var_instance := lics_outbound_loader.create_interface('DDSNZF01',null);


      lics_outbound_loader.append_data('"BILLING_DOC_NUM","BILLING_DOC_LINE_NUM","BILLING_TRACE_SEQN","CREATN_DATE",' ||
                                       '"CREATN_YYYYPPDD","CREATN_YYYYPPW","CREATN_YYYYPP","CREATN_YYYYMM","BILLING_EFF_DATE",' ||
                                       '"BILLING_EFF_YYYYPPDD","BILLING_EFF_YYYYPPW","BILLING_EFF_YYYYPP","BILLING_EFF_YYYYMM",' ||
                                       '"ORDER_DOC_NUM","ORDER_DOC_LINE_NUM","PURCH_ORDER_DOC_NUM","PURCH_ORDER_DOC_LINE_NUM",' ||
                                       '"DLVRY_DOC_NUM","DLVRY_DOC_LINE_NUM","COMPANY_CODE","HDR_SALES_ORG_CODE","HDR_DISTBN_CHNL_CODE",' ||
                                       '"HDR_DIVISION_CODE","GEN_SALES_ORG_CODE","GEN_DISTBN_CHNL_CODE","GEN_DIVISION_CODE","DOC_CURRCY_CODE",' ||
                                       '"COMPANY_CURRCY_CODE","EXCH_RATE","INVC_TYPE_CODE","ORDER_TYPE_CODE","ORDER_REASN_CODE","ORDER_USAGE_CODE",' ||
                                       '"SOLD_TO_CUST_CODE","BILL_TO_CUST_CODE","PAYER_CUST_CODE","SHIP_TO_CUST_CODE","MATL_CODE","ODS_MATL_CODE",' ||
                                       '"MATL_ENTD","PLANT_CODE","STORAGE_LOCN_CODE","ORDER_QTY","BILLED_WEIGHT_UNIT","BILLED_GROSS_WEIGHT",' ||
                                       '"BILLED_NET_WEIGHT","BILLED_UOM_CODE","BILLED_BASE_UOM_CODE","BILLED_QTY","BILLED_QTY_BASE_UOM",' ||
                                       '"BILLED_QTY_GROSS_TONNES","BILLED_QTY_NET_TONNES","BILLED_GSV","BILLED_GSV_XACTN","BILLED_GSV_AUD",' ||
                                       '"BILLED_GSV_USD","BILLED_GSV_EUR","MFANZ_ICB_FLAG","DEMAND_PLNG_GRP_DIVISION_CODE","ZN00_CONDITION",' ||
                                       '"ZN01_CONDITION","ZN02_CONDITION","ZN07_CONDITION","ZN08_CONDITION","ZN03_CONDITION","ZN04_CONDITION",' ||
                                       '"ZN05_CONDITION","ZN06_CONDITION","ZN09_CONDITION","ZN10_CONDITION","ZN11_CONDITION","ZK33_CONDITION",' ||
                                       '"ZK35_CONDITION"');

      /*-*/
      /* Open Cursor for output
      /*-*/
      open csr_extract;
      loop
         fetch csr_extract into rec_extract;
         if (csr_extract%notfound) then
            exit;
         end if;


         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data(rec_extract.extract_data);

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
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

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DDSNZF01 SALES - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ddsnzf01_sales;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ddsnzf01_sales for ods_app.ddsnzf01_sales;
grant execute on ddsnzf01_sales to public;
