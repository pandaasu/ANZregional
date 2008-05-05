/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CAD
 Table   : CAD_LIST_PRICE
 Owner   : CAD
 Author  : Linden Glen

 Description
 -----------
 China Application Data - List Price

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/

drop table cad_list_price;


/**/
/* Table creation
/**/
create table cad_list_price
   (price_list_type                varchar2(4 char)     not null,
    sap_company_code               varchar2(4 char)     not null,
    sap_material_code              varchar2(18 char)    not null,
    price_list_currcy              varchar2(5 char)     null,
    uom                            varchar2(3 char)     null,
    eff_start_date                 varchar2(8 char)     null,
    eff_end_date                   varchar2(8 char)     null,
    list_price                     number               null,
    cad_load_date                  date                 not null);


/**/
/* Primary Key Constraint
/**/

/**/
/* Indexes
/**/
create index cad_list_price_idx01 on cad_list_price (price_list_type, sap_company_code);

/**/
/* Comments
/**/
comment on table cad_list_price is 'China Application Data - Price List';

/**/
/* Synonym
/**/
create or replace public synonym cad_list_price for cad.cad_list_price;

/**/
/* Authority
/**/
grant select,update,delete,insert on cad_list_price to lics_app;
grant select,update,delete,insert on cad_list_price to cad_app;
grant select on cad_list_price to public;
