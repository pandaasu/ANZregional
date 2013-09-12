
DROP TABLE "PXI"."PMX_MATL_DTRMNTN";

CREATE GLOBAL TEMPORARY TABLE "PXI"."PMX_MATL_DTRMNTN" (
  "ACCSS_SEQ" VARCHAR2(4 CHAR), 
  "ACCSS_LEVEL" NUMBER, 
  "SALES_ORG" VARCHAR2(4 CHAR), 
  "DISTBN_CHNL" VARCHAR2(2 CHAR), 
  "CUST_CODE" VARCHAR2(10 CHAR), 
  "MATL_CODE" VARCHAR2(18 CHAR), 
  "START_DATE" VARCHAR2(8 CHAR), 
  "END_DATE" VARCHAR2(8 CHAR), 
  "SUBST_MATL_CODE" VARCHAR2(18 CHAR)
  ) ON COMMIT PRESERVE ROWS ;

-- Table Comments
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."ACCSS_SEQ" IS 'The SAP Access Sequence for this material determination condition.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."ACCSS_LEVEL" IS 'The higer the number the more spefic the material determination rule is.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."SALES_ORG" IS 'The sales organisation code.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."DISTBN_CHNL" IS 'The sales distribution channel code.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."CUST_CODE" IS 'The Customer Code.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."MATL_CODE" IS 'The ZREP material code.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."START_DATE" IS 'The first day this condition becomes valid.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."END_DATE" IS 'The last day this condition is actually valid.';
COMMENT ON COLUMN "PXI"."PMX_MATL_DTRMNTN"."SUBST_MATL_CODE" IS 'The TDU material code to actually send.';
COMMENT ON TABLE "PXI"."PMX_MATL_DTRMNTN"  IS 'This table contains a temporary snapshot of material determination information from the MFANZ_MATL_DTRMNTN_PROMAX_VW view.  This is done for performance reasons.';

-- Index on the Material Determination Table.
CREATE INDEX "PXI"."PMX_MATL_DTRMNTN_NU01" ON "PXI"."PMX_MATL_DTRMNTN" ("MATL_CODE", "SALES_ORG") ;

-- Create a public synonym for this material determination table.
create or replace public synonym pmx_matl_dtrmntn for "PXI"."PMX_MATL_DTRMNTN";

-- Grant script for the temporary table.
grant select, update, insert, delete on PXI.PMX_MATL_DTRMNTN to PXI_APP;
