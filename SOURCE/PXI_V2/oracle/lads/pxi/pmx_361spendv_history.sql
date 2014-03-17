/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : pxi
 Table  : pxi_361_spendv_history
 Owner  : pxi
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Spendvision Transaction Histroy, to Allow Determination of Duplicates on [claim_code]

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-19   Mal Chambeyron         Created

*******************************************************************************/

-- Table 
drop table pxi.pxi_361_spendv_history cascade constraints;

create table pxi.pxi_361_spendv_history (
  company_code                    varchar2(3 char)                not null,
  division_code                   varchar2(3 char)                not null,
  cust_code                       varchar2(10 char)               not null,
  promotion_code                  varchar2(20 char),
  claim_amount_ex_gst             number(13,2)                    not null,
  tax_amount                      number(13,2)                    not null,
  doc_type                        varchar2(1 char),
  claim_code                      varchar2(20 char)               not null,
  invoice_date                    date,
  claim_comment                   varchar2(32 char)               not null,
  promax_company_code             varchar2(3 char)                not null,
  promax_division_code            varchar2(3 char)                not null,
  promax_invoice_date             date                            not null,
  promax_amount                   number(13,2)                    not null,
  created_by                      varchar2(32 char)               not null,
  created_date                    date                            not null
)
compress;

-- Keys
alter table pxi.pxi_361_spendv_history add constraint pxi_361_spendv_history_pk primary key (claim_code)
  using index (create unique index pxi.pxi_361_spendv_history_pk on pxi.pxi_361_spendv_history(claim_code));

-- Comments
comment on table pxi_361_spendv_history is 'Spendvision Transaction Histroy, for 361SPENDV, to Allow Determination of Duplicates on [claim_code]';

-- Synonyms
-- create or replace public synonym pxi_361_spendv_history for pxi.pxi_361_spendv_history;
-- ORA-01031: insufficient privileges

-- Grants
grant select, insert, update, delete on pxi.pxi_361_spendv_history to pxi_app;

--------------------------------------------------------------------------------
-- Create Working Tempory Table 

drop table pxi.pxi_361_spendv_history_temp cascade constraints; 

create global temporary table pxi.pxi_361_spendv_history_temp 
on commit delete rows 
as select * from pxi.pxi_361_spendv_history where 1=0
;

-- Comments
comment on table pxi_361_spendv_history is 'Spendvision Transaction Histroy, for 361SPENDV, Temporary Working Table';

-- Synonyms
-- create or replace public synonym pxi_361_spendv_history_temp for pxi.pxi_361_spendv_history_temp;
-- ORA-01031: insufficient privileges

-- Grants
grant select, insert, update, delete on pxi.pxi_361_spendv_history_temp to pxi_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

