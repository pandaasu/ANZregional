-- Code to re-create the pmx_cust_hier_view containing the new columns added in LADS
  CREATE OR REPLACE FORCE VIEW "PDS_APP"."PMX_CUST_HIER_VIEW" ("HDRSEQ", "COCODE", "REGION", "CHNCODE", "DIVCODE", "CUSTLEVEL", "CUSTNO", "POSFORMAT", "CHAIN", "EFF_FROM", "HDRDAT") AS 
  select "HDRSEQ","COCODE","REGION","CHNCODE","DIVCODE","CUSTLEVEL","CUSTNO","POSFORMAT","CHAIN","EFF_FROM","HDRDAT" from lads.promax_cust_hier_view@ap0064p.world;
 