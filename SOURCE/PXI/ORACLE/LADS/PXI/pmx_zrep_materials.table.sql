-- This temporary table is to speed up the processing of product extract.
drop table "PXI"."PMX_ZREP_MATERIALS";

CREATE GLOBAL TEMPORARY TABLE "PMX_ZREP_MATERIALS" (
  "PROMAX_COMPANY" VARCHAR2(3 char), 
	"PROMAX_DIVISION" VARCHAR2(3 char), 
	"SALES_ORG" VARCHAR2(4 char), 
	"DSTRBTN_CHANNEL" VARCHAR2(2 char), 
	"XDSTRBTN_CHAIN_STATUS" VARCHAR2(2 char), 
	"DSTRBTN_CHAIN_STATUS" VARCHAR2(2 char), 
	"ZREP_MATL_CODE" VARCHAR2(18 char), 
	"ZREP_MATL_DESC" VARCHAR2(40 char)
   ) ON COMMIT PRESERVE ROWS;

-- Table Comments
--COMMENT ON COLUMN "PXI"."PMX_ZREP_MATERIALS"."SUBST_MATL_CODE" IS 'The TDU material code to actually send.';
COMMENT ON TABLE "PXI"."PMX_ZREP_MATERIALS"  IS 'This is a temporary table used to create the matl tdu to rsu lookup information.';

-- Index on the Material Determination Table.
CREATE UNIQUE INDEX "PXI"."PMX_ZREP_MATERIALS_01" ON "PXI"."PMX_ZREP_MATERIALS" (PROMAX_COMPANY, PROMAX_DIVISION, ZREP_MATL_CODE) ;

-- Create a public synonym for this material determination table.
create or replace public synonym "PMX_ZREP_MATERIALS" for "PXI"."PMX_ZREP_MATERIALS";


-- Perform the necessary grants.
grant select, update, insert, delete on "PXI"."PMX_ZREP_MATERIALS" to pxi_app;