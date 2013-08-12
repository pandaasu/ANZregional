-- Laws of Growth - Table Creation Script for Wodonga - Petcare Tables 
--------------------------------------------------------------------------------

-- SALES SCAN TABLE.
drop table logr_wod_sales_scan;

create table logr_wod_sales_scan (
  period varchar2(100),
  mars_period number(6,0),
  data_animal_type varchar2(20),
  measure varchar2(100),
  product varchar2(100),
  market varchar2(100),
  data_value number(30,10),
  manufacturer varchar2(100),
  brand varchar2(100),
  catgry varchar2(100),
  sgmnt varchar2(100),
  packtype varchar2(100),
  packsize varchar2(100),
  sze_grams number(8,0),
  ean varchar2(100),
  sub_brand varchar2(100),
  multiple varchar2(100),
  multi_pack varchar2(100),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index log_wod_sales_scan_nu01 on logr_wod_sales_scan (mars_period,data_animal_type);

create or replace public synonym logr_wod_sales_scan for ods.logr_wod_sales_scan;

grant select, insert, update, delete on logr_wod_sales_scan to ods_app;

-- DISTINCTIVE ASSET

drop table logr_wod_dstnctv_asset;

create table logr_wod_dstnctv_asset (
  mars_period number(6,0),
  catgry varchar2(100),
  brand varchar2(100),
  dstnctv_asset_target number(8,0),
  dstnctv_asset_count number(8,0),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_dstnctv_asset_nu01 on logr_wod_dstnctv_asset (mars_period);

create or replace public synonym logr_wod_dstnctv_asset for ods.logr_wod_dstnctv_asset;

grant select, insert, update, delete on logr_wod_dstnctv_asset to ods_app;

-- SHARE_OF_SHELF
drop table logr_wod_share_of_shelf;

create table logr_wod_share_of_shelf (
  mars_period number(6,0),
  account varchar2(100),
  clster varchar2(100),
  ean varchar2(100),
  ean_name varchar2(100),
  linear_space number(30,10),
  catgry varchar2(100),
  brand varchar2(100),
  sub_brand varchar2(100),
  sgmnt varchar2(100),
  manufacturer varchar2(100),
  single_multi varchar2(100),
  packsize varchar2(100),
  packtype varchar2(100),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_share_of_shelf_nu01 on logr_wod_share_of_shelf (mars_period,account);

create or replace public synonym logr_wod_share_of_shelf for ods.logr_wod_share_of_shelf;

grant select, insert, update, delete on logr_wod_share_of_shelf to ods_app;

-- PACKAGING EFFECTIVENESS
drop table logr_wod_pack_effctvnss;

create table logr_wod_pack_effctvnss (
  mars_period number(6,0),
  catgry varchar2(100),
  brand varchar2(100),
  sgmnt varchar2(100),
  packtype varchar2(100),
  specific_sku varchar2(200),
  time_to_find_mars number(30,10),
  percent_wrong_mars number(30,10),
  spi_mars number(30,10),
  time_to_find_cmpttr number(30,10), 
  percent_wrong_cmpttr number(30,10),
  spi_cmpttr number(30,10),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_pack_effctvnss_nu01 on logr_wod_pack_effctvnss (mars_period);

create or replace public synonym logr_wod_pack_effctvnss for ods.logr_wod_pack_effctvnss;

grant select, insert, update, delete on logr_wod_pack_effctvnss to ods_app;


-- ADVERTISING EFFECTIVENESS
drop table logr_wod_advert_effctvnss;

create table logr_wod_advert_effctvnss (
  mars_period number(6,0),
  catgry varchar2(100),
  brand varchar2(100),
  sgmnt varchar2(100),
  packtype varchar2(100),
  copy varchar2(200),
  avi_score number(30,10),
  performance_vs_market varchar2(100),
  ipsos_score number(30,10),
  on_air_currently varchar2(100),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_advert_effctvnss_nu01 on logr_wod_advert_effctvnss (mars_period);

create or replace public synonym logr_wod_advert_effctvnss for ods.logr_wod_advert_effctvnss;

grant select, insert, update, delete on logr_wod_advert_effctvnss to ods_app;

-- TV ADVERTISING ACTIVITY
drop table logr_wod_tv_activity;

create table logr_wod_tv_activity (
  version number(6,0),
  brand varchar2(100),
  sgmnt varchar2(100),
  period number(2,0),
  year number(4,0),
  weeks_on_air number(30,10),
  four_weekly_reach number(30,10),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_tv_activity_nu01 on logr_wod_tv_activity (version);

create or replace public synonym logr_wod_tv_activity for ods.logr_wod_tv_activity;

grant select, insert, update, delete on logr_wod_tv_activity to ods_app;


-- HOUSEHOLD PENETRATION
drop table logr_wod_house_pntrtn;

create table logr_wod_house_pntrtn (
  market varchar2(100),
  shopper_level varchar2(100),
  product varchar2(100),
  brand varchar2(100),
  catgry varchar2(100),
  sub_catgry varchar2(100),
  quarter varchar2(100),
  quarter_period number(6,0),
  rltv_pntrtn number(30,10),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create or replace public synonym logr_wod_house_pntrtn for ods.logr_wod_house_pntrtn;

grant select, insert, update, delete on logr_wod_house_pntrtn to ods_app;

-- PRODUCT PERFORMANCE
drop table logr_wod_prdct_prfrmnc;

create table logr_wod_prdct_prfrmnc (
  something varchar2(100),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create or replace public synonym logr_wod_prdct_prfrmnc for ods.logr_wod_prdct_prfrmnc;

grant select, insert, update, delete on logr_wod_prdct_prfrmnc to ods_app;

-- TABLE COMMENTS
COMMENT ON TABLE LOGR_WOD_ADVERT_EFFCTVNSS IS 'Data for advertising effectiveness of the Australian Petcare business.';
COMMENT ON TABLE LOGR_WOD_DSTNCTV_ASSET IS 'Data for distinctive asset information of the Australian Petcare business.';
COMMENT ON TABLE LOGR_WOD_PACK_EFFCTVNSS IS 'Data for packaging effectiveness of the Australian Petcare business.';
COMMENT ON TABLE LOGR_WOD_SALES_SCAN IS 'Data for sales scan information of the Australian Petcare business.';
COMMENT ON TABLE LOGR_WOD_SHARE_OF_SHELF IS 'Data for share of shelf information of the Australian Petcare business.';
COMMENT ON TABLE logr_wod_tv_activity IS 'Data for tv advertisitment actuals and plans of the Australian Petcare business.';
COMMENT ON TABLE LOGR_WOD_HOUSE_PNTRTN IS 'Data for house hold penetration information of the Australia Petcare business.';
COMMENT ON TABLE LOGR_WOD_PRDCT_PRFRMNC IS 'Data for product performance information of the Australia Petcare business.';

-- TABLE COLUMN COMMENTS
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.ACCOUNT IS 'Customer Account.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.ANIMAL_TYPE IS 'Product Animal Type.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.AVI_SCORE IS 'Advertising Effectiveness AVI Score.';
COMMENT ON COLUMN logr_wod_tv_activity.BRAND IS 'Brand.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.BRAND IS 'Brand.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.BRAND IS 'Brand.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.BRAND IS 'Brand.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.BRAND IS 'Brand.';
COMMENT ON COLUMN LOGR_WOD_DSTNCTV_ASSET.BRAND IS 'Brand.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.CATGRY IS 'Product Category.';
COMMENT ON COLUMN LOGR_WOD_DSTNCTV_ASSET.CATGRY IS 'Product Category.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.CATGRY IS 'Product Category.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.CATGRY IS 'Product Category.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.CATGRY IS 'Product Category.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.CLSTER IS 'Geographic Cluster of the Customer Account.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.COPY IS 'The advertising campaign - copy.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.DATA_VALUE IS 'The value associated with this scan data mesaure.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.DEPARTMENT IS 'Department.';
COMMENT ON COLUMN LOGR_WOD_DSTNCTV_ASSET.DSTNCTV_ASSET_COUNT IS 'Distinctive Asset Count in Top Right Quadrant.';
COMMENT ON COLUMN LOGR_WOD_DSTNCTV_ASSET.DSTNCTV_ASSET_TARGET IS 'Distinctive Asset Target.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.EAN IS 'Product EAN Code - Barcode.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.EAN IS 'Product EAN Code - Barcode.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.EAN_NAME IS 'Product Name.';
COMMENT ON COLUMN logr_wod_tv_activity.FOUR_WEEKLY_REACH IS 'TV Four Weekly Reach Measure.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.IPSOS_SCORE IS 'Advertising Effectiveness IPSOS Score.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.LINEAR_SPACE IS 'This is the linear shelf space that this product occupies.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.MANUFACTURER IS 'The product''s Manufacturer.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.MANUFACTURER IS 'The product''s Manufacturer.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.MARKET IS 'Product Market';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.MARS_PERIOD IS 'The Mars Period.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.MARS_PERIOD IS 'The Mars Period.';
COMMENT ON COLUMN LOGR_WOD_DSTNCTV_ASSET.MARS_PERIOD IS 'The Mars Period.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.MARS_PERIOD IS 'The Mars Period.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.MARS_PERIOD IS 'The Mars Period.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.MEASURE IS 'The type of data being collected, measured.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.ON_AIR_CURRENTLY IS 'If the advert is currently on the air.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.PACKSIZE IS 'Product Pack Size';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.PACKSIZE IS 'Product Pack Size';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.PACKTYPE IS 'Product Pack Type';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.PACKTYPE IS 'Product Pack Type';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.PACKTYPE IS 'Product Pack Type';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.PACKTYPE IS 'Product Pack Type';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.PERCENT_WRONG_CMPTTR IS 'Percentage person picked wrong product when looking for specific Competitor product.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.PERCENT_WRONG_MARS IS 'Percentage person picked wrong product when looking for specific Mars product.';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.PERFORMANCE_VS_MARKET IS 'Description about advert''s performance verses the market.  ie.  Average.';
COMMENT ON COLUMN logr_wod_tv_activity.PERIOD IS 'Mars Period.  Period number only, no year.';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.PRODUCT IS 'Product';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.SGMNT IS 'Product Segement';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.SGMNT IS 'Product Segment';
COMMENT ON COLUMN LOGR_WOD_ADVERT_EFFCTVNSS.SGMNT IS 'Product Segment';
COMMENT ON COLUMN logr_wod_tv_activity.SGMNT IS 'Product Segment';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.SGMNT IS 'Product Segment';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.SINGLE_MULTI IS 'If this product is a single or multi pack product.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.SPECIFIC_SKU IS 'Description of Product.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.SPI_CMPTTR IS 'SPI for Competitor Product.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.SPI_MARS IS 'SPI For Mars Product.';
COMMENT ON COLUMN LOGR_WOD_SHARE_OF_SHELF.SUB_BRAND IS 'Sub Brand';
COMMENT ON COLUMN LOGR_WOD_SALES_SCAN.SZE_GRAMS IS 'Size of the product in grams.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.TIME_TO_FIND_CMPTTR IS 'Time it took the person to find the specific competitor product.';
COMMENT ON COLUMN LOGR_WOD_PACK_EFFCTVNSS.TIME_TO_FIND_MARS IS 'Time it took the person to find the specific mars product.';
COMMENT ON COLUMN logr_wod_tv_activity.VERSION IS 'The advertising plan version, similar to a casting period.';
COMMENT ON COLUMN logr_wod_tv_activity.WEEKS_ON_AIR IS 'Number of weeks this advert has been on air.';
COMMENT ON COLUMN logr_wod_tv_activity.YEAR IS 'The year.';
comment on column logr_wod_house_pntrtn.market is 'The market associated with this data.';
comment on column logr_wod_house_pntrtn.shopper_level is 'The relative grouping of the shoper.';
comment on column logr_wod_house_pntrtn.product is 'The type of product that the penetration data is for.';
comment on column logr_wod_house_pntrtn.brand is 'The product brand.';
comment on column logr_wod_house_pntrtn.catgry is 'The product category.';
comment on column logr_wod_house_pntrtn.sub_catgry is 'The product sub category.';
comment on column logr_wod_house_pntrtn.quarter is 'The end date of the quarter, converted to mars YYYYPP.';
comment on column logr_wod_house_pntrtn.rltv_pntrtn is 'The relative percentage of the house hold penetration.';
comment on column logr_wod_advert_effctvnss.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_dstnctv_asset.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_pack_effctvnss.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_sales_scan.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_share_of_shelf.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
COMMENT ON column logr_wod_tv_activity.last_updtd_user IS 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_house_pntrtn.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_prdct_prfrmnc.last_updtd_user is 'The user that uploaded or reprocessed the interface that supplied this data.';
comment on column logr_wod_advert_effctvnss.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
comment on column logr_wod_dstnctv_asset.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
comment on column logr_wod_pack_effctvnss.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
comment on column logr_wod_sales_scan.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
comment on column logr_wod_share_of_shelf.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
COMMENT ON column logr_wod_tv_activity.last_updtd_time IS 'The time that this supplied data was loaded or reprocessed.';
comment on column logr_wod_house_pntrtn.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
comment on column logr_wod_prdct_prfrmnc.last_updtd_time is 'The time that this supplied data was loaded or reprocessed.';
