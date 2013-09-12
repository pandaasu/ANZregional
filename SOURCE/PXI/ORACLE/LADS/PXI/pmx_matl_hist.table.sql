-- Promax Material Extract History Tracking Table.
-- Drop the table.
drop table pmx_matl_hist;


-- Create the table.
CREATE TABLE PMX_MATL_HIST (	
    CMPNY_CODE VARCHAR2(3 BYTE) NOT NULL , 
    DIV_CODE VARCHAR2(3 BYTE) NOT NULL , 
    ZREP_MATL_CODE VARCHAR2(18 BYTE) NOT NULL ,
    xdstrbtn_chain_status varchar2(2 byte) not null,
    dstrbtn_chain_status varchar2(2 Byte) not null,
    change_date date,
    last_extracted date,
    CONSTRAINT "PMX_MATL_HIST_PK" PRIMARY KEY (CMPNY_CODE, DIV_CODE, ZREP_MATL_CODE));

-- Table comments.
COMMENT ON COLUMN PMX_MATL_HIST.CMPNY_CODE IS 'Promax Company Code';
COMMENT ON COLUMN PMX_MATL_HIST.DIV_CODE IS 'Promax Division Code';
COMMENT ON COLUMN PMX_MATL_HIST.ZREP_MATL_CODE IS 'ZREP Material Code';
comment on column pmx_matl_hist.xdstrbtn_chain_status is 'Cross Distribution Status.';
COMMENT ON COLUMN PMX_MATL_HIST.dstrbtn_chain_status IS 'Material Distribution Status.';
COMMENT ON COLUMN PMX_MATL_HIST.change_date IS 'Last time the status was seen to have changed.';
COMMENT ON COLUMN PMX_MATL_HIST.last_extracted IS 'Last time this record was extracted.';
comment on table PMX_MATL_HIST  is 'Promax PX Material Send History.';
   
-- Table grants.
grant select, update, insert, delete on PMX_MATL_HIST to pxi_app;

-- Public Synonyms 
create  or replace public synonym PMX_MATL_HIST for pxi.PMX_MATL_HIST;
