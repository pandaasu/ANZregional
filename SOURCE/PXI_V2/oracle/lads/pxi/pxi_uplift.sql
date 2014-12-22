/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_uplift
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 This table contains a copy of all the uplift data that is sent back to 
 Apollo Demand.
 
 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-16   Chris Horn             Created script.

*******************************************************************************/

-- Drop the sequence
drop sequence pxi_uplift_seq;

-- Drop the Table
drop table pxi_uplift_detail cascade constraints;
drop table pxi_uplift_header cascade constraints;


-- Create the sequence
create sequence pxi_uplift_seq minvalue 0 maxvalue 999999999999999 increment by 1 start with 1 nocache nocycle;

-- Table
create table pxi_uplift_header (	
  uplift_seq      number(15,0) not null enable, 
  moe_code        varchar2(10 byte) not null enable, 
  location_code   varchar2(50 byte),
  demand_seq      number(15,0),
  estimate_seq    number(15,0), 
  modify_date     date, 
  modify_user     varchar2(30 byte)
);

create table pxi_uplift_detail (
  uplift_seq      number(15,0) not null enable,
  row_seq         number(10,0) not null enable,
  demand_unit     varchar2(50 byte),
  demand_group     varchar2(50 byte),
  start_date      date,
  duration        number(10,0),
  type_code       number(1,0),
  forecast_id     varchar2(255 byte),
  qty             number(20,4),
  mars_week       number(7,0)
);

-- Primary Key
alter table pxi_uplift_header add constraint pxi_uplift_header_pk primary key (uplift_seq)
  using index (create unique index pxi_uplift_header_pk on pxi_uplift_header(uplift_seq));
alter table pxi_uplift_detail add constraint pxi_uplift_detail_pk primary key (uplift_seq,demand_unit,demand_group,mars_week)
  using index (create unique index pxi_uplift_detail_pk on pxi_uplift_detail(uplift_seq,demand_unit,demand_group,mars_week));
  
-- Indexes
create index pxi_uplift_header_i2 on pxi_uplift_header (moe_code);

-- Foreign key constraint.
alter table pxi_uplift_detail add constraint pxi_uplift_detail_fk foreign key (uplift_seq) referencing pxi_uplift_header(uplift_seq);

-- Comments
COMMENT ON TABLE pxi_uplift_header  IS 'Apollo Uplift Extract Data';
COMMENT ON COLUMN pxi_uplift_header.uplift_seq IS 'Uplift Sequence Code';
COMMENT ON COLUMN pxi_uplift_header.moe_code IS 'Mars Organisational Entity Code';
COMMENT ON COLUMN pxi_uplift_header.location_code IS 'Location Code';
COMMENT ON COLUMN pxi_uplift_header.demand_seq IS 'Link to the Demand File.';
COMMENT ON COLUMN pxi_uplift_header.estimate_seq IS 'Link to the Estimate File.';
COMMENT ON COLUMN pxi_uplift_header.modify_date IS 'Date this file was modified.';
COMMENT ON COLUMN pxi_uplift_header.modify_user IS 'User that modified this file.';

COMMENT ON TABLE pxi_uplift_detail  IS 'Apollo Uplift Extract Detail.';
COMMENT ON COLUMN pxi_uplift_detail.uplift_seq IS 'Uplift Sequence Code';
COMMENT ON COLUMN pxi_uplift_detail.row_seq IS 'File Row Number';
COMMENT ON COLUMN pxi_uplift_detail.demand_unit IS 'Demand Unit';
COMMENT ON COLUMN pxi_uplift_detail.demand_group IS 'Demand Group';
COMMENT ON COLUMN pxi_uplift_detail.start_date IS 'Start Date';
COMMENT ON COLUMN pxi_uplift_detail.duration IS 'Duration';
COMMENT ON COLUMN pxi_uplift_detail.type_code IS 'Type Code';
COMMENT ON COLUMN pxi_uplift_detail.forecast_id IS 'Apollo Forecast ID';
COMMENT ON COLUMN pxi_uplift_detail.qty IS 'Quanityt';
COMMENT ON COLUMN pxi_uplift_detail.mars_week IS 'Mars week for the given start date.';

-- Grants
grant select, insert, update, delete on pxi_uplift_header to pxi_app;
grant select, insert, update, delete on pxi_uplift_detail to pxi_app;
grant select on pxi_uplift_seq to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


