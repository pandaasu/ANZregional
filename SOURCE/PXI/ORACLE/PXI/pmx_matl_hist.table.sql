-- Promax Pricing Conditions Configuration Table.

  CREATE TABLE PMX_MATL_HIST (	
     CMPNY_CODE VARCHAR2(3 BYTE) NOT NULL , 
     DIV_CODE VARCHAR2(3 BYTE) NOT NULL , 
	   ZREP_MATL_CODE VARCHAR2(18 BYTE) NOT NULL ,
     dstrbtn_chain_status varchar2(2 Byte) not null,
     change_date date,
    CONSTRAINT "PMX_MATL_HIST_PK" PRIMARY KEY (CMPNY_CODE, DIV_CODE, ZREP_MATL_CODE));

   COMMENT ON COLUMN PMX_MATL_HIST.CMPNY_CODE IS 'Promax Company Code';
   COMMENT ON COLUMN PMX_MATL_HIST.DIV_CODE IS 'Promax Division Code';
   COMMENT ON COLUMN PMX_MATL_HIST.ZREP_MATL_CODE IS 'ZREP Material Code';
   COMMENT ON COLUMN PMX_MATL_HIST.dstrbtn_chain_status IS 'Material Distribution Status.';
   COMMENT ON COLUMN PMX_MATL_HIST.change_date IS 'Last time the status was seen to have changed.';
   comment on table PMX_MATL_HIST  is 'Promax PX Material Send History.';
   
   grant select, update, insert, delete on PMX_MATL_HIST to pxi_app;
   
   create  or replace public synonym PMX_MATL_HIST for pxi.PMX_MATL_HIST;
   
