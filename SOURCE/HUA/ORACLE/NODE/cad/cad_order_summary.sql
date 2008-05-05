/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CAD
 Table   : CAD_ORDER_SUMMARY
 Owner   : CAD
 Author  : Linden Glen

 Description
 -----------
 China Application Data - Order Summary

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/02   Linden Glen    Added NIV values

*******************************************************************************/

drop table cad_order_summary;


/**/
/* Table creation
/**/
create table cad_order_summary
   (ord_doc_num                  varchar2(10 char)      not null,
    ord_doc_line_num             varchar2(6 char)       null,
    ord_lin_status               varchar2(4 char)       null,
    sap_order_type_code          varchar2(4 char)       null,
    sap_doc_currcy_code          varchar2(5 char)       null,
    sap_sold_to_cust_code        varchar2(10 char)      null,
    sap_bill_to_cust_code        varchar2(10 char)      null,
    sap_ship_to_cust_code        varchar2(10 char)      null,
    sap_plant_code               varchar2(4 char)       null,
    sap_material_code            varchar2(18 char)      null,
    sap_ord_qty_uom_code         varchar2(3 char)       null,
    ord_creation_date            varchar2(8 char)       null,
    agreed_del_date              varchar2(8 char)       null,
    scheduled_del_date           varchar2(8 char)       null,
    del_date                     varchar2(8 char)       null,
    pod_date                     varchar2(8 char)       null,
    ord_qty                      number                 null,
    del_qty                      number                 null,
    pod_qty                      number                 null,
    ord_niv                      number                 null,
    del_niv                      number                 null,
    pod_niv                      number                 null,
    cad_load_date                date                   not null);

/**/
/* Primary Key Constraint
/**/
alter table cad_order_summary
   add constraint cad_order_summary_pk primary key (ord_doc_num, ord_doc_line_num);

/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table cad_order_summary is 'China Application Data - Order Summary';

/**/
/* Synonym
/**/
create or replace public synonym cad_order_summary for cad.cad_order_summary;

/**/
/* Authority
/**/
grant select,update,delete,insert on cad_order_summary to lics_app;
grant select,update,delete,insert on cad_order_summary to cad_app;
grant select on cad_order_summary to public;
