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

create or replace public synonym logr_wod_sales_scan for logr.logr_wod_sales_scan;

grant select, insert, update, delete on logr_wod_sales_scan to logr_app;

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

create or replace public synonym logr_wod_dstnctv_asset for logr.logr_wod_dstnctv_asset;

grant select, insert, update, delete on logr_wod_dstnctv_asset to logr_app;

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

create or replace public synonym logr_wod_share_of_shelf for logr.logr_wod_share_of_shelf;

grant select, insert, update, delete on logr_wod_share_of_shelf to logr_app;

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
  performance number(30,10),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_pack_effctvnss_nu01 on logr_wod_pack_effctvnss (mars_period);

create or replace public synonym logr_wod_pack_effctvnss for logr.logr_wod_pack_effctvnss;

grant select, insert, update, delete on logr_wod_pack_effctvnss to logr_app;


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
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_advert_effctvnss_nu01 on logr_wod_advert_effctvnss (mars_period);

create or replace public synonym logr_wod_advert_effctvnss for logr.logr_wod_advert_effctvnss;

grant select, insert, update, delete on logr_wod_advert_effctvnss to logr_app;

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

create or replace public synonym logr_wod_tv_activity for logr.logr_wod_tv_activity;

grant select, insert, update, delete on logr_wod_tv_activity to logr_app;


-- HOUSEHOLD PENETRATION
drop table logr_wod_house_pntrtn;

create table logr_wod_house_pntrtn (
  market varchar2(100),
  shopper_level varchar2(100),
  quarter varchar2(100),
  quarter_period number(6,0),
  data_animal_type varchar2(20),
  product varchar2(100),
  sub_catgry varchar2(100),
  brand varchar2(100),
  sub_brand varchar2(100),
  packtype varchar2(100),
  serving_size varchar2(100),
  rltv_pntrtn number(30,10),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create index logr_wod_house_pntrtn_nu01 on logr_wod_house_pntrtn (data_animal_type);

create or replace public synonym logr_wod_house_pntrtn for logr.logr_wod_house_pntrtn;

grant select, insert, update, delete on logr_wod_house_pntrtn to logr_app;

-- PRODUCT PERFORMANCE
drop table logr_wod_prdct_prfrmnc;

create table logr_wod_prdct_prfrmnc (
  mars_period number(6,0),
  animal varchar2(100),
  catgry varchar2(100),
  brand varchar2(100), 
  product_family varchar2(100),
  palatability_result varchar2(100),
  digestibility_result varchar2(100),
  faeces_qlty_result varchar2(100),
  last_updtd_user varchar2(30),
  last_updtd_time date
);

create or replace public synonym logr_wod_prdct_prfrmnc for logr.logr_wod_prdct_prfrmnc;

grant select, insert, update, delete on logr_wod_prdct_prfrmnc to logr_app;

-- Table Grants for the QV User
grant select on LOGR_WOD_ADVERT_EFFCTVNSS to qv_user;
grant select on LOGR_WOD_DSTNCTV_ASSET to qv_user;
grant select on LOGR_WOD_PACK_EFFCTVNSS to qv_user;
grant select on LOGR_WOD_SALES_SCAN to qv_user;
grant select on LOGR_WOD_SHARE_OF_SHELF to qv_user;
grant select on logr_wod_tv_activity to qv_user;
grant select on logr_wod_house_pntrtn to qv_user;
grant select on LOGR_WOD_ADVERT_EFFCTVNSS to qv_user;
grant select on logr_wod_advert_effctvnss to qv_user;
grant select on logr_wod_prdct_prfrmnc to qv_user;
-- Table Grants for the APPSUPPORT User
grant select on LOGR_WOD_ADVERT_EFFCTVNSS to appsupport;
grant select on LOGR_WOD_DSTNCTV_ASSET to appsupport;
grant select on LOGR_WOD_PACK_EFFCTVNSS to appsupport;
grant select on LOGR_WOD_SALES_SCAN to appsupport;
grant select on LOGR_WOD_SHARE_OF_SHELF to appsupport;
grant select on logr_wod_tv_activity to appsupport;
grant select on logr_wod_house_pntrtn to appsupport;
grant select on LOGR_WOD_ADVERT_EFFCTVNSS to appsupport;
grant select on logr_wod_advert_effctvnss to appsupport;
grant select on logr_wod_prdct_prfrmnc to appsupport;


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
comment on column logr_wod_sales_scan.data_animal_type is 'Animal Type based on interface load.';
COMMENT ON COLUMN LOGR_WOD_house_pntrtn.DATA_ANIMAL_TYPE IS 'Animal Type based on interface load.';
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
comment on column logr_wod_house_pntrtn.sub_brand is 'The product sub brand.';
comment on column logr_wod_house_pntrtn.sub_catgry is 'The product sub category.';
comment on column logr_wod_house_pntrtn.serving_size is 'The serving size information.';
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
comment on column logr_wod_prdct_prfrmnc.mars_period is 'The Mars Period.';
comment on column logr_wod_prdct_prfrmnc.animal is 'The animal type this data is associated with.';
comment on column logr_wod_prdct_prfrmnc.catgry is 'The product category.';
comment on column logr_wod_prdct_prfrmnc.brand is 'The product brand.';
comment on column logr_wod_prdct_prfrmnc.product_family is 'The product family.';
comment on column logr_wod_prdct_prfrmnc.palatability_result is 'Palatability Result.';
comment on column logr_wod_prdct_prfrmnc.digestibility_result is 'Digestibility Result.';
comment on column logr_wod_prdct_prfrmnc.faeces_qlty_result is 'Faeces Quality Result';
comment on column logr_wod_house_pntrtn.quarter_period is 'The mars period at the end of the quater.';
comment on column logr_wod_house_pntrtn.packtype is 'The product packaging type.';
comment on column logr_wod_pack_effctvnss.performance is 'A calculation of the difference between mars and competitor SPI scores.';
comment on column logr_wod_sales_scan.period is 'The supplied text and date representing the current period.';
comment on column logr_wod_sales_scan.multi_pack is 'If this product is sold as a multi pack.';
comment on column logr_wod_sales_scan.multiple is 'Supporting information if this product is sold as a multi pack.';
comment on column logr_wod_sales_scan.sub_brand is 'The products sub brand.';

