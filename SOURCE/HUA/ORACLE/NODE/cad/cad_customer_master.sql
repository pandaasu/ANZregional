/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CAD
 Table   : CAD_CUSTOMER_MASTER
 Owner   : CAD
 Author  : Linden Glen

 Description
 -----------
 China Application Data - Customer master

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created
 2008/02   Linden Glen    Added LAST_UPDATE_DATE
 2008/05   Linden Glen    Added account_group_code and search_term_02

*******************************************************************************/

drop table cad_customer_master;

/**/
/* Table creation
/**/
create table cad_customer_master
   (sap_customer_code                varchar2(10 char)     not null,
    sap_customer_name                varchar2(160 char)    null,
    ship_to_cust_code                varchar2(10 char)     null,
    ship_to_cust_name                varchar2(40 char)     null,
    bill_to_cust_code                varchar2(10 char)     null,
    bill_to_cust_name                varchar2(40 char)     null,
    salesman_code                    varchar2(10 char)     null,
    salesman_name                    varchar2(40 char)     null,
    city_code                        varchar2(10 char)     null,
    city_name                        varchar2(40 char)     null,
    hub_city_code                    varchar2(10 char)     null,
    hub_city_name                    varchar2(40 char)     null,
    address_street_en                varchar2(60 char)     null,
    address_sort_en                  varchar2(20 char)     null,
    region_code                      varchar2(3 char)      null,
    plant_code                       varchar2(4 char)      null,
    vat_registration_number          varchar2(20 char)     null,
    customer_status                  varchar2(1 char)      null,
    insurance_number                 varchar2(10 char)     null,
    buying_grp_code                  varchar2(10 char)     null,
    buying_grp_name                  varchar2(120 char)    null,
    key_account_code                 varchar2(10 char)     null,
    key_account_name                 varchar2(120 char)    null,
    channel_code                     varchar2(10 char)     null,
    channel_name                     varchar2(120 char)    null,
    channel_grp_code                 varchar2(10 char)     null,
    channel_grp_name                 varchar2(120 char)    null,
    last_update_date                 varchar2(14 char)     null,
    account_group_code               varchar2(4 char)      null,
    search_term_02                   varchar2(20 char)     null,
    cad_load_date                    date                  not null);


/**/
/* Primary Key Constraint
/**/
alter table cad_customer_master
   add constraint cad_customer_master_pk primary key (sap_customer_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table cad_customer_master is 'China Application Data - Customer Master';


/**/
/* Synonym
/**/
create or replace public synonym cad_customer_master for cad.cad_customer_master;


/**/
/* Authority
/**/
grant select,update,delete,insert on cad_customer_master to lics_app;
grant select,update,delete,insert on cad_customer_master to cad_app;
grant select on cad_customer_master to public;