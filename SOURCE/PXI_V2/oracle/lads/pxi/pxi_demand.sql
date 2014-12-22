/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_demand
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 This table contains all the demand file information from Apollo Demand.
 
 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-16   Chris Horn             Created script.

*******************************************************************************/

-- Drop the sequence
drop sequence pxi_demand_seq;

-- Drop the Table
drop table pxi_demand_detail cascade constraints;
drop table pxi_demand_header cascade constraints;


-- Create the sequence
create sequence pxi_demand_seq minvalue 0 maxvalue 999999999999999 increment by 1 start with 1 nocache nocycle;

-- Table
create table pxi_demand_header (	
  demand_seq      number(15,0) not null enable, 
  moe_code        varchar2(10 byte) not null enable, 
  location_code   varchar2(10 byte),
  load_date       date,
  min_mars_week   number(7,0),
  max_mars_week   number(7,0),
  modify_date     date, 
  modify_user     varchar2(30 byte)
);

create table pxi_demand_detail (
  demand_seq      number(15,0) not null enable,
  row_seq         number(10,0) not null enable,
  demand_unit     varchar2(50 byte),
  demand_group    varchar2(50 byte),
  start_date      date,
  duration_mins   number(5,0),
  type_code       number(1,0),
  qty             number(20,4),
  demand_text     varchar2(50 byte), 
  promo_type      varchar2(255 byte),
  zrep_code       varchar2(20 byte), 
  mars_week       number(7,0)
);

-- Primary Key
alter table pxi_demand_header add constraint pxi_demand_header_pk primary key (demand_seq)
  using index (create unique index pxi_demand_header_pk on pxi_demand_header(demand_seq));
  
-- Indexes
create index pxi_demand_header_i2 on pxi_demand_header (moe_code);
create index pxi_demand_detail_i1 on pxi_demand_detail (demand_seq,demand_group,zrep_code,mars_week);

-- Foreign key constraint.
alter table pxi_demand_detail add constraint pxi_demand_detail_fk foreign key (demand_seq) referencing pxi_demand_header(demand_seq);

-- Comments
COMMENT ON TABLE pxi_demand_header  IS 'Apollo Demand Data Header.';
COMMENT ON COLUMN pxi_demand_header.demand_seq IS 'Demand Sequence Code';
COMMENT ON COLUMN pxi_demand_header.moe_code IS 'Mars Organisational Entity Code';
COMMENT ON COLUMN pxi_demand_header.location_code IS 'Location';
COMMENT ON COLUMN pxi_demand_header.load_date IS 'Date the file was loaded.';
COMMENT ON COLUMN pxi_demand_header.min_mars_week IS 'Minimum mars week within file.';
COMMENT ON COLUMN pxi_demand_header.max_mars_week IS 'Maximum mars week within file.';
COMMENT ON COLUMN pxi_demand_header.modify_date IS 'Date this file was modified.';
COMMENT ON COLUMN pxi_demand_header.modify_user IS 'User that modified this file.';

COMMENT ON TABLE pxi_demand_detail  IS 'Apollo Demand Data Detail.';
COMMENT ON COLUMN pxi_demand_detail.demand_seq IS 'Demand Sequence Code';
COMMENT ON COLUMN pxi_demand_detail.row_seq IS 'File Row Number';
COMMENT ON COLUMN pxi_demand_detail.demand_unit IS 'Demand Unit Code';
COMMENT ON COLUMN pxi_demand_detail.demand_group IS 'Demand Group';
COMMENT ON COLUMN pxi_demand_detail.start_date IS 'Start Date';
COMMENT ON COLUMN pxi_demand_detail.duration_mins IS 'Duration Mininutes';
COMMENT ON COLUMN pxi_demand_detail.type_code IS 'Type code';
COMMENT ON COLUMN pxi_demand_detail.qty IS 'Quantity';
COMMENT ON COLUMN pxi_demand_detail.demand_text IS 'Demand Type';
COMMENT ON COLUMN pxi_demand_detail.promo_type IS 'Promotion Type';
COMMENT ON COLUMN pxi_demand_detail.zrep_code IS 'Zrep Code';
COMMENT ON COLUMN pxi_demand_detail.mars_week IS 'Mars week for the given start date.';

-- Grants
grant select, insert, update, delete on pxi_demand_header to pxi_app;
grant select, insert, update, delete on pxi_demand_detail to pxi_app;
grant select on pxi_demand_seq to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


