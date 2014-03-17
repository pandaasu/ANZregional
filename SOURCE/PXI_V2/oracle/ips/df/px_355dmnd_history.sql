prompt :: Create Table [px_355dmnd_history] :::::::::::::::::::::::::::::::::::::::::::

/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : df
 Table  : px_355dmnd_history
 Owner  : df
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Repository of JDBC Connection Configuration

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-05   Mal Chambeyron         Created

*******************************************************************************/

-- Table

drop table df.px_355dmnd_history cascade constraints;

-- Atrocious column types .. but MUST MATCH Demand Financials .. 
create table df.px_355dmnd_history (
  fcst_id                         number(20,0)                    not null,
  moe_code                        varchar2(20 byte)               not null,
  sales_org                       varchar2(20 byte)               not null,
  bus_sgmnt_code                  varchar2(20 byte)               not null,
  dmnd_grp_code                   varchar2(20 byte)               not null,
  zrep_matl_code                  varchar2(20 byte)               not null,
  mars_week                       varchar2(20 byte)               not null,
  start_date                      date                            not null,
  end_date                        date                            not null,
  dmnd_plng_node                  varchar2(20 byte)               not null,
  px_dmnd_plng_node               varchar2(20 byte)               not null,
  split_qty                       number(30,10)                   not null,
  created_date                    date                            not null,  
  modified_date                   date                            not null,  
  has_px_account_sku              number(1,0)                     not null,
  has_px_account                  number(1,0)                     not null,
  has_px_sku                      number(1,0)                     not null
)
compress;

-- Keys

alter table df.px_355dmnd_history add constraint px_355dmnd_history_pk primary key (moe_code, sales_org, bus_sgmnt_code, dmnd_grp_code, px_dmnd_plng_node, zrep_matl_code, start_date)
  using index (create unique index df.px_355dmnd_history_pk on df.px_355dmnd_history(moe_code, sales_org, bus_sgmnt_code, dmnd_grp_code, px_dmnd_plng_node, zrep_matl_code, start_date) compress);

create index df.px_355dmnd_history_i01 on df.px_355dmnd_history (moe_code, end_date) compress;

-- Comments

comment on table px_355dmnd_history is 'Repository of 355DMND Interface History - Atrocious column types .. but MUST MATCH Demand Financials column types ..';
comment on column px_355dmnd_history.has_px_account_sku is '1 = True, 0 = False';
comment on column px_355dmnd_history.has_px_account is '1 = True, 0 = False';
comment on column px_355dmnd_history.has_px_sku is '1 = True, 0 = False';

-- Synonyms

create or replace public synonym px_355dmnd_history for df.px_355dmnd_history;

-- Grants

grant select, insert, update, delete on df.px_355dmnd_history to df_app;

--------------------------------------------------------------------------------
-- Create Working Tempory Table 

drop table df.px_355dmnd_history_temp cascade constraints; 

create global temporary table df.px_355dmnd_history_temp 
on commit delete rows 
as select * from df.px_355dmnd_history where 1=0
;

-- Comments

comment on table px_355dmnd_history is 'Repository of 355DMND Interface History - Temporary Table';

-- Synonyms

create or replace public synonym px_355dmnd_history_temp for df.px_355dmnd_history_temp;

-- Grants

grant select, insert, update, delete on df.px_355dmnd_history_temp to df_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

