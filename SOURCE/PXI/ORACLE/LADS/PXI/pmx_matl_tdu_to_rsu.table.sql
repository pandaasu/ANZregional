drop table "PXI"."PMX_MATL_TDU_TO_RSU";

CREATE GLOBAL TEMPORARY TABLE "PMX_MATL_TDU_TO_RSU" (
    "TDU_MATL_CODE" VARCHAR2(18 CHAR), 
    "RSU_MATL_CODE" VARCHAR2(18 CHAR), 
    "RSU_MATL_DESC" VARCHAR2(40 CHAR), 
    "RSU_EAN" VARCHAR2(18 CHAR), 
    "RSU_UOM" VARCHAR2(9 CHAR), 
    "RSUS_PER_TDU" NUMBER, 
    "RSU_LENGTH" NUMBER, 
    "RSU_WIDTH" NUMBER, 
    "RSU_HEIGHT" NUMBER
     ) ON COMMIT PRESERVE ROWS;

-- Table Comments
--COMMENT ON COLUMN "PXI"."PMX_MATL_TDU_TO_RSU"."SUBST_MATL_CODE" IS 'The TDU material code to actually send.';
COMMENT ON TABLE "PXI"."PMX_MATL_TDU_TO_RSU"  IS 'This is a temporary table used to create the matl tdu to rsu lookup information.';

-- Index on the Material Determination Table.
CREATE INDEX "PXI"."PMX_MATL_TDU_TO_RSU_N01" ON "PXI"."PMX_MATL_TDU_TO_RSU" ("TDU_MATL_CODE") ;

-- Create a public synonym for this material determination table.
create or replace public synonym "PMX_MATL_TDU_TO_RSU" for "PXI"."PMX_MATL_TDU_TO_RSU";


-- Perform the necessary grants.
grant select, update, insert, delete on "PXI"."PMX_MATL_TDU_TO_RSU" to pxi_app;