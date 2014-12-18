/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_moe_attributes
 Owner  : pxi
 Author : Chris Horn

 Description
 -------------------------------------------------------------------------------
 This table is used to manage all the moe attribute information.  It is a 
 static reference table that will only be maintained by the support team.

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-12-11   Chris Horn             Created script.

*******************************************************************************/

-- Drop the Table
drop table pxi_moe_attributes cascade constraints;

-- Table
create table pxi_moe_attributes (	
  moe_code varchar2(10 byte) not null enable, 
  interface_suffix varchar2(3 byte) not null enable, 
  px_company_code varchar2(3 byte) not null enable, 
  px_division_code varchar2(3 byte) not null enable,
  location_code varchar2(50 byte) not null enable,
  system_code varchar2(20 byte) not null enable
);

-- Primary Key
alter table pxi_moe_attributes add constraint pxi_moe_attributes_pk primary key (moe_code)
  using index (create unique index pxi_moe_attributes_pk on pxi_moe_attributes(moe_code));
  
-- Indexes
create index pxi_moe_attributes_i2 on pxi_moe_attributes (interface_suffix);

-- Comments
COMMENT ON TABLE pxi_moe_attributes  IS 'MOE Code System Attribute and Configuration Information.';
COMMENT ON COLUMN pxi_moe_attributes.moe_code IS 'Mars Organisational Entity Code';
COMMENT ON COLUMN pxi_moe_attributes.interface_suffix IS 'Interface Suffix Code';
COMMENT ON COLUMN pxi_moe_attributes.px_company_code IS 'Promax Company Code';
COMMENT ON COLUMN pxi_moe_attributes.px_division_code IS 'Promax Division Code';
COMMENT ON COLUMN pxi_moe_attributes.location_code IS 'Country Location Code';
COMMENT ON COLUMN pxi_moe_attributes.system_code IS 'Promax System Code';

-- Grants
grant select, insert, update, delete on pxi_moe_attributes to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/


