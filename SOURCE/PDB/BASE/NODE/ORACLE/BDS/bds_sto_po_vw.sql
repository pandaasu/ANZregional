grant select on bds_sto_po_header to manu_app;

/* Formatted on 14/02/2013 1:31:37 PM (QP5 v5.215.12089.38647) */
CREATE OR REPLACE FORCE VIEW BDS.BDS_STO_PO_VW
(
   STO_PO_DOC_NUM,
   DOCUMENT_TYPE,
   CURRENCY_CODE,
   STO_PO_TYPE,
   VENDOR_CODE,
   DOCUMENT_DATE,
   PURCH_COMPANY_CODE,
   PURCH_ORG_CODE,
   PURCH_GRP_CODE,
   CUSTOMER_CODE,
   DOC_LINE_NUM,
   MATERIAL_CODE,
   MATERIAL_DESCRIPTION,
   DELIVERY_DATE,
   QTY,
   UOM_CODE,
   ITEM_VALUE_NET,
   PLANT_CODE,
   STORAGE_LOCN_CODE,
   ACTION_CODE,
   DEL_COMPLETE,
   OVER_DEL_TOLRNCE,
   STOCK_TYPE,
   UPD_DATIME
)
AS
   (SELECT t01.purch_order_doc_num,
           t01.document_type,
           t01.currency_code,
           t01.purch_order_type,
           t01.vendor_code,
           t01.document_date,
           t01.company_code,
           t01.purch_order_org_code,
           t01.purch_order_grp_code,
           t01.customer_code,
           t02.purch_order_doc_line_num,
           t02.sap_material_code,
           t03.bds_material_desc_en AS material_description,
           t02.delivery_date,
           t02.qty,
           t02.uom_code,
           t02.item_value_net,
           t02.plant_code,
           t02.storage_locn_code,
           t02.action_code,
           t02.dlvry_comp AS dlvry_comp,
           t02.over_del_tolrnce AS over_del_tolrnce,
           t02.stock_type AS stock_type,
           t01.upd_datime AS upd_dattime
      FROM bds_sto_po_header t01,
           bds_sto_po_detail t02,
           bds_material_plant_local t03
     WHERE     t01.purch_order_doc_num = t02.purch_order_doc_num
           AND t02.sap_material_code = t03.sap_material_code(+)
           AND t02.plant_code = t03.plant_code(+));
/


CREATE OR REPLACE PUBLIC SYNONYM BDS_STO_PO_VW FOR BDS.BDS_STO_PO_VW;
/


GRANT SELECT ON BDS.BDS_STO_PO_VW TO BDS_APP WITH GRANT OPTION;
/

grant select on bds.bds_sto_po_vw to appsupport;
/