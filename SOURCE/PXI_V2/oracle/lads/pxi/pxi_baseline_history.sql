/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_history
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 This table contains all the baseline history information that has been 
 sent to Promax PX.
 
 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-16   Chris Horn             Created script.

*******************************************************************************/

-- Drop the Table
drop table pxi_baseline_history cascade constraints;


-- Table
create table pxi_baseline_history (
  moe_code          varchar2(3 byte) not null enable,
  px_company_code   varchar2(3 byte),
  px_division_code  varchar2(3 byte), 
  account_code      varchar2(20 byte) not null enable,
  zrep_code         varchar2(20 byte) not null enable,
  start_date        date,
  stop_date         date,
  volume            number(20,0),
  has_account_sku   varchar2(1),
  has_account       varchar2(1),
  has_sku           varchar2(1),
  demand_group      varchar2(50),
  mars_week         number(7,0) not null,
  demand_seq        number(15,0),
  created_date      date,
  modified_date     date
);

-- Primary Key
alter table pxi_baseline_history add constraint pxi_baseline_history_pk primary key (moe_code,account_code,zrep_code,mars_week)
  using index (create unique index pxi_baseline_history_pk on pxi_baseline_history(moe_code,account_code,zrep_code,mars_week));  

-- Comments
COMMENT ON TABLE pxi_baseline_history  IS 'Promax PX External Baseline History.';
COMMENT ON COLUMN pxi_baseline_history.moe_code IS 'Mars Organisational Entity';
COMMENT ON COLUMN pxi_baseline_history.px_company_code IS 'Promax Company Code';
COMMENT ON COLUMN pxi_baseline_history.px_division_code IS 'Promax Division Code';
COMMENT ON COLUMN pxi_baseline_history.account_code IS 'Account Code';
COMMENT ON COLUMN pxi_baseline_history.zrep_code IS 'Zrep Code';
COMMENT ON COLUMN pxi_baseline_history.start_date IS 'Start Date';
COMMENT ON COLUMN pxi_baseline_history.stop_date IS 'Stop Date';
COMMENT ON COLUMN pxi_baseline_history.volume IS 'Volume';
COMMENT ON COLUMN pxi_baseline_history.has_account_sku IS 'Has Account SKU';
COMMENT ON COLUMN pxi_baseline_history.has_account IS 'Has Account';
COMMENT ON COLUMN pxi_baseline_history.has_sku IS 'Has SKU';
COMMENT ON COLUMN pxi_baseline_history.demand_group IS 'Demand Group Code';
COMMENT ON COLUMN pxi_baseline_history.mars_week IS 'Mars Week';
COMMENT ON COLUMN pxi_baseline_history.demand_seq IS 'Link to Demand Sequence';
COMMENT ON COLUMN pxi_baseline_history.created_date IS 'Date this entry was created.';
COMMENT ON COLUMN pxi_baseline_history.modified_date IS 'Date this record was last modified.';

-- Grants
grant select, insert, update, delete on pxi_baseline_history to pxi_app;
grant select, insert, update, delete on pxi_baseline_history to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


