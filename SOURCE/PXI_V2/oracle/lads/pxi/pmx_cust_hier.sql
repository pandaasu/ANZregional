/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pmx_cust_hier
 Owner  : pxi
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Promax Customer Hierarchy, Temporary Working Table (to Cache Query)

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-24   Mal Chambeyron         Created

*******************************************************************************/

drop table pxi.pmx_cust_hier_temp cascade constraints; 

create global temporary table pxi.pmx_cust_hier_temp (
  header_date                     varchar2(8 char)                not null, 
	header_seq                      number                          not null, 
	min_detail_seq                  number, 
	max_detail_seq                  number, 
	min_hier_level                  varchar2(2 char), 
	max_hier_level                  varchar2(2 char), 
	item_count                      number, 
	cust_code                       varchar2(10 char), 
	sales_org_code                  varchar2(4 char), 
	distbn_chnl_code                varchar2(2 char), 
	division_code                   varchar2(2 char), 
	sort_level                      varchar2(10 char), 
	hier_level                      varchar2(2 char), 
	start_date                      varchar2(8 char), 
	end_date                        varchar2(8 char), 
	cust_name                       varchar2(40 char), 
	priority                        number, 
	cust_code_01                    varchar2(10 char), 
	sales_org_code_01               varchar2(4 char), 
	distbn_chnl_code_01             varchar2(2 char), 
	division_code_01                varchar2(2 char), 
	sort_level_01                   varchar2(10 char), 
	hier_level_01                   varchar2(2 char), 
	start_date_01                   varchar2(8 char), 
	end_date_01                     varchar2(8 char), 
	cust_name_01                    varchar2(40 char), 
	cust_code_02 varchar2(10 char), 
	sales_org_code_02 varchar2(4 char), 
	distbn_chnl_code_02 varchar2(2 char), 
	division_code_02 varchar2(2 char), 
	sort_level_02 varchar2(10 char), 
	hier_level_02 varchar2(2 char), 
	start_date_02 varchar2(8 char), 
	end_date_02 varchar2(8 char), 
	cust_name_02 varchar2(40 char), 
	cust_code_03 varchar2(10 char), 
	sales_org_code_03 varchar2(4 char), 
	distbn_chnl_code_03 varchar2(2 char), 
	division_code_03 varchar2(2 char), 
	sort_level_03 varchar2(10 char), 
	hier_level_03 varchar2(2 char), 
	start_date_03 varchar2(8 char), 
	end_date_03 varchar2(8 char), 
	cust_name_03 varchar2(40 char), 
	cust_code_04 varchar2(10 char), 
	sales_org_code_04 varchar2(4 char), 
	distbn_chnl_code_04 varchar2(2 char), 
	division_code_04 varchar2(2 char), 
	sort_level_04 varchar2(10 char), 
	hier_level_04 varchar2(2 char), 
	start_date_04 varchar2(8 char), 
	end_date_04 varchar2(8 char), 
	cust_name_04 varchar2(40 char), 
	cust_code_05 varchar2(10 char), 
	sales_org_code_05 varchar2(4 char), 
	distbn_chnl_code_05 varchar2(2 char), 
	division_code_05 varchar2(2 char), 
	sort_level_05 varchar2(10 char), 
	hier_level_05 varchar2(2 char), 
	start_date_05 varchar2(8 char), 
	end_date_05 varchar2(8 char), 
	cust_name_05 varchar2(40 char), 
	cust_code_06 varchar2(10 char), 
	sales_org_code_06 varchar2(4 char), 
	distbn_chnl_code_06 varchar2(2 char), 
	division_code_06 varchar2(2 char), 
	sort_level_06 varchar2(10 char), 
	hier_level_06 varchar2(2 char), 
	start_date_06 varchar2(8 char), 
	end_date_06 varchar2(8 char), 
	cust_name_06 varchar2(40 char), 
	cust_header_order_block_flag varchar2(2 char), 
	cust_header_deletion_flag varchar2(1 char), 
	sales_area_order_block_flag varchar2(2 char), 
	sales_area_deletion_flag varchar2(1 char), 
	last_billing_yyyypp varchar2(6 char)
) 
on commit delete rows 
;

-- Comments
comment on table pxi.pmx_cust_hier_temp is 'Promax Customer Hierarhcy, Temporary Working Table';

-- Synonyms
-- create or replace public synonym pmx_cust_hier_temp for pxi.pmx_cust_hier_temp;
-- ORA-01031: insufficient privileges

-- Grants
grant select, insert, update, delete on pxi.pmx_cust_hier_temp to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

