  -- Run the following script as DF.  

  -- Promax Demand Lookup Table
  CREATE TABLE "DF"."PX_DMND_LOOKUP" (
    "DMND_GRP_CODE" NVARCHAR2(20) NOT NULL ENABLE, 
  	"BUS_SGMNT_CODE" NVARCHAR2(20) NOT NULL ENABLE, 
	  "DMND_PLNG_NODE" NVARCHAR2(20) NOT NULL ENABLE, 
	  "DMND_GRP_DESC" NVARCHAR2(200),
	  "DMND_PLNG_DESC" NVARCHAR2(200), 
    CONSTRAINT "PX_DMND_LOOKUP_PK" PRIMARY KEY ("DMND_GRP_CODE", "BUS_SGMNT_CODE", "DMND_PLNG_NODE")
   );

   -- Promax Demand Lookup Table Comments  
   COMMENT ON COLUMN "DF"."PX_DMND_LOOKUP"."DMND_GRP_CODE" IS 'Demand Group Code - SAP';
   COMMENT ON COLUMN "DF"."PX_DMND_LOOKUP"."BUS_SGMNT_CODE" IS 'Business Segment Code';
   COMMENT ON COLUMN "DF"."PX_DMND_LOOKUP"."DMND_PLNG_NODE" IS 'Demand Planning Node - Apollo Code';
   COMMENT ON COLUMN "DF"."PX_DMND_LOOKUP"."DMND_GRP_DESC" IS 'Demand Group Description';
   COMMENT ON COLUMN "DF"."PX_DMND_LOOKUP"."DMND_PLNG_DESC" IS 'Demand Planning Node Description';
   COMMENT ON TABLE "DF"."PX_DMND_LOOKUP"  IS 'PMX Demand Group Lookup';
   
   -- Promax Demand Lookup Table Comments
   grant select, update, insert, delete on px_dmnd_lookup to df_app;
   grant select, update, insert, delete on px_dmnd_lookup to pf_app;
   grant select on px_dmnd_lookup to pf_reader;
   
   -- Setup a public synonym for the table.
   create or replace public synonym px_dmnd_lookup for df.px_dmnd_lookup;
   