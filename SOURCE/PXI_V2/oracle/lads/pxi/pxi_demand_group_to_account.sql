/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_demand_group_to_account
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 Cross Reference Table for Demand Group to Account Mapping Information

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-11   Chris Horn             Created script.

*******************************************************************************/

-- Drop the Table
drop table pxi_demand_group_to_account cascade constraints;

-- Table
create table pxi_demand_group_to_account (	
  demand_group varchar2(50 byte) not null enable, 
  account_code varchar2(20 byte) not null enable, 
  primary_account varchar2(1 byte) not null enable, 
  moe_code varchar2(10 byte) not null enable
);

-- Primary Key
alter table pxi_demand_group_to_account add constraint pxi_demand_group_to_account_pk primary key (demand_group,account_code)
  using index (create unique index pxi_demand_group_to_account_pk on pxi_demand_group_to_account(demand_group,account_code));
  
-- Indexes
create index pxi_demand_group_to_account_i2 on pxi_demand_group_to_account (account_code);

-- Comments
COMMENT ON TABLE pxi_demand_group_to_account  IS 'Apollo Demand Group to SAP Account Code Mapping Table';
COMMENT ON COLUMN pxi_demand_group_to_account.demand_group IS 'Demand Group';
COMMENT ON COLUMN pxi_demand_group_to_account.account_code IS 'Account Code';
COMMENT ON COLUMN pxi_demand_group_to_account.primary_account IS 'Primary Account - Yes(Y) | No(N)';
COMMENT ON COLUMN pxi_demand_group_to_account.moe_code IS 'Mars Organsiational Entity';

-- Grants
grant select, insert, update, delete on pxi_demand_group_to_account to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/