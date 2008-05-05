/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : CDW
 Table   : ods_dbp_company
 Owner   : ODS
 Author  : Linden Glen

 Description
 -----------
 Regional Sales Position - Company Control Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/02   Linden Glen    Created

*******************************************************************************/


drop table ods_dbp_company;

/**/
/* Table creation
/**/
create table ods_dbp_company
   (com_code          varchar2(6 char)    not null,
    com_desc          varchar2(64 char)   not null,
    com_email         varchar2(256 char)  not null,
    com_currency      varchar2(3 char)    not null,
    com_source        varchar2(8 char)    not null,
    com_distributor   varchar2(1 char)    null,
    com_rprt_factor   number              null,
    com_rprt_uom      varchar2(3 char)    null);

/**/
/* Constraints
/**/
 ALTER TABLE ods_dbp_company
  ADD CONSTRAINT ods_dbp_company_pk PRIMARY KEY (com_code);


/**/
/* Comments
/**/
comment on table ods_dbp_company is 'Regional Business Sales Position - Company Control Table';

/**/
/* Authority
/**/
grant select, insert, update, delete on ods_dbp_company to ods_app;
grant select, insert, update, delete on ods_dbp_company to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym ods_dbp_company for ods.ods_dbp_company;


/**/
/* inserts
/**/
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('131', 'Japan', 'linden.glen@ap.effem.com', 'JPY', '*REGL', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_DISTRIBUTOR)
 Values
   ('901', 'Singapore', 'linden.glen', 'USD', '*REGL', 'x');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_DISTRIBUTOR)
 Values
   ('902', 'Brunei', 'linden.glen', 'USD', '*REGL', 'x');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_DISTRIBUTOR)
 Values
   ('903', 'Vietnam', 'linden.glen', 'USD', '*REGL', 'x');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_DISTRIBUTOR)
 Values
   ('904', 'Indochina', 'linden.glen', 'USD', '*REGL', 'x');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_DISTRIBUTOR, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('905', 'Malaysia', 'linden.glen', 'USD', '*REGL', 'x', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('906', 'Korea', 'linden.glen', 'KRW', '*REGL', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_DISTRIBUTOR, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('907', 'Philippines', 'linden.glen', 'PHP', '*REGL', 'x', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('908', 'China', 'linden.glen', 'CNY', '*REGL', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('909', 'Hong Kong', 'linden.glen', 'HKD', '*REGL', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('912', 'Taiwan', 'linden.glen', 'TWD', '*REGL', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE, COM_RPRT_FACTOR, COM_RPRT_UOM)
 Values
   ('900', 'Thailand', 'linden.glen', 'THB', '*REGL', 1000000, 'm');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE)
 Values
   ('147', 'Australia', 'linden.glen', 'AUD', '*CDW');
Insert into ODS.ODS_DBP_COMPANY
   (COM_CODE, COM_DESC, COM_EMAIL, COM_CURRENCY, COM_SOURCE)
 Values
   ('149', 'New Zealand', 'linden.glen', 'AUD', '*CDW');
COMMIT;

