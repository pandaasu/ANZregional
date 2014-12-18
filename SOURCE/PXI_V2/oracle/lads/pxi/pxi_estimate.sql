/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_estimate
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 This table contains all the Promax PX Estimate information. 
 
 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-16   Chris Horn             Created script.

*******************************************************************************/

-- Drop the sequence
drop sequence pxi_estimate_seq;

-- Drop the Table
drop table pxi_estimate_detail cascade constraints;
drop table pxi_estimate_header cascade constraints;


-- Create the sequence
create sequence pxi_estimate_seq minvalue 0 maxvalue 999999999999999 increment by 1 start with 1 nocache nocycle;

-- Table
create table pxi_estimate_header (	
  estimate_seq    number(15,0) not null enable, 
  moe_code        varchar2(10 byte) not null enable, 
  modify_date     date, 
  modify_user     varchar2(30 byte)
);

create table pxi_estimate_detail (
  estimate_seq    number(15,0) not null enable,
  row_seq         number(10,0) not null enable,
  week_date       date,
  account_code    varchar2(20 byte),
  stock_code      varchar2(20 byte),
  est_estimated_volume      number(10,0),
  est_normal_volume         number(10,0),
  est_incremental_volume    number(10,0),
  est_marketing_adj_volume  number(10,0),
  est_state_phasing_volume  number(10,0),
  mars_week       number(7,0)
);

-- Primary Key
alter table pxi_estimate_header add constraint pxi_estimate_header_pk primary key (estimate_seq)
  using index (create unique index pxi_estimate_header_pk on pxi_estimate_header(estimate_seq));
alter table pxi_estimate_detail add constraint pxi_estimate_detail_pk primary key (estimate_seq,account_code,stock_code,mars_week)
  using index (create unique index pxi_estimate_detail_pk on pxi_estimate_detail(estimate_seq,account_code,stock_code,mars_week));
  
-- Indexes
create index pxi_estimate_header_i2 on pxi_estimate_header (moe_code);

-- Foreign key constraint.
alter table pxi_estimate_detail add constraint pxi_estimate_detail_fk foreign key (estimate_seq) referencing pxi_estimate_header(estimate_seq);

-- Comments
COMMENT ON TABLE pxi_estimate_header  IS 'Promax PX Estimate Data Header.';
COMMENT ON COLUMN pxi_estimate_header.estimate_seq IS 'Estimate Sequence Code';
COMMENT ON COLUMN pxi_estimate_header.moe_code IS 'Mars Organisational Entity Code';
COMMENT ON COLUMN pxi_estimate_header.modify_date IS 'Date this file was modified.';
COMMENT ON COLUMN pxi_estimate_header.modify_user IS 'User that modified this file.';

COMMENT ON TABLE pxi_estimate_detail  IS 'Promax PX Estimate Data Detail.';
COMMENT ON COLUMN pxi_estimate_detail.estimate_seq IS 'Estimate Sequence Code';
COMMENT ON COLUMN pxi_estimate_detail.row_seq IS 'File Row Number';
COMMENT ON COLUMN pxi_estimate_detail.week_date IS 'Monday of given week.';
COMMENT ON COLUMN pxi_estimate_detail.account_code IS 'Account Code';
COMMENT ON COLUMN pxi_estimate_detail.stock_code IS 'Stock Code / ZREP';
COMMENT ON COLUMN pxi_estimate_detail.est_estimated_volume IS 'Estimated Volume';
COMMENT ON COLUMN pxi_estimate_detail.est_normal_volume IS 'Normal Volume';
COMMENT ON COLUMN pxi_estimate_detail.est_incremental_volume IS 'Incremental Volume';
COMMENT ON COLUMN pxi_estimate_detail.est_marketing_adj_volume IS 'Marketing Volume';
COMMENT ON COLUMN pxi_estimate_detail.est_state_phasing_volume IS 'State Phasing Volume';
COMMENT ON COLUMN pxi_estimate_detail.mars_week IS 'Mars week for the given start date.';

-- Grants
grant select, insert, update, delete on pxi_estimate_header to pxi_app;
grant select, insert, update, delete on pxi_estimate_detail to pxi_app;
grant select on pxi_estimate_seq to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


