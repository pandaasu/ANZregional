prompt :: Create Table [px_dmnd_lookup] :::::::::::::::::::::::::::::::::::::::::::::::

/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : df
 Table  : px_dmnd_lookup
 Owner  : df
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Created script from existing table ..

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-03-11   Mal Chambeyron         Created script from existing table .. 

*******************************************************************************/

-- Table

drop table df.px_dmnd_lookup cascade constraints;

create table df.px_dmnd_lookup (	
  dmnd_grp_code varchar2(20 byte) not null enable, 
  bus_sgmnt_code varchar2(20 byte) not null enable, 
  dmnd_plng_node varchar2(20 byte) not null enable, 
  dmnd_grp_desc varchar2(200 byte), 
  dmnd_plng_desc varchar2(200 byte), 
  split_percent number(30,10) 
);

-- Keys

alter table df.px_dmnd_lookup add constraint px_dmnd_lookup_pk primary key (dmnd_grp_code, bus_sgmnt_code, dmnd_plng_node)
  using index (create unique index df.px_dmnd_lookup_pk on df.px_dmnd_lookup(dmnd_grp_code, bus_sgmnt_code, dmnd_plng_node));

create index df.px_dmnd_lookup_i01 on df.px_dmnd_lookup(dmnd_plng_node, bus_sgmnt_code);
    
-- Comments

COMMENT ON TABLE DF.PX_DMND_LOOKUP  IS 'PMX Demand Group Lookup';
COMMENT ON COLUMN DF.PX_DMND_LOOKUP.DMND_GRP_CODE IS 'Demand Group Code - SAP';
COMMENT ON COLUMN DF.PX_DMND_LOOKUP.BUS_SGMNT_CODE IS 'Business Segment Code';
COMMENT ON COLUMN DF.PX_DMND_LOOKUP.DMND_PLNG_NODE IS 'Demand Planning Node - Apollo Code';
COMMENT ON COLUMN DF.PX_DMND_LOOKUP.DMND_GRP_DESC IS 'Demand Group Description';
COMMENT ON COLUMN DF.PX_DMND_LOOKUP.DMND_PLNG_DESC IS 'Demand Planning Node Description';
COMMENT ON COLUMN DF.PX_DMND_LOOKUP.SPLIT_PERCENT IS 'Percentage Split allocation for Apollo Base extracts to promax. NULL = 100%';

-- Synonyms

create or replace public synonym px_dmnd_lookup for df.px_dmnd_lookup;

-- grants

grant select, insert, update, delete on df.px_dmnd_lookup to df_app, pf_app;
grant select on df.px_dmnd_lookup to pf_reader;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

-- Initialise Table

-- Existing Production New Zealand
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSPS_NZ','01','0040007938','Fresh Choice Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007942','Gilmours Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007942','Gilmours Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007942','Gilmours Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007949','McDonalds Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007949','McDonalds Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007949','McDonalds Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007950','Moore Wilsons Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007950','Moore Wilsons Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007950','Moore Wilsons Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFA_NZ','02','0040007952','New World Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFA_NZ','05','0040007952','New World Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFA_NZ','01','0040007952','New World Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040007953','New World SI Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040007953','New World SI Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040007953','New World SI Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFW_NZ','02','0040007954','New World Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFW_NZ','05','0040007954','New World Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFW_NZ','01','0040007954','New World Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040007969','NZ Pet Trade Distributor Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040007969','NZ Pet Trade Distributor Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040007969','NZ Pet Trade Distributor Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFA_NZ','02','0040007972','Pak''N Save Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFA_NZ','05','0040007972','Pak''N Save Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFA_NZ','01','0040007972','Pak''N Save Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040007973','Pak''N Save Si Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040007973','Pak''N Save Si Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040007973','Pak''N Save Si Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFW_NZ','02','0040007974','Pak''N Save/Write Price Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFW_NZ','05','0040007974','Pak''N Save/Write Price Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFW_NZ','01','0040007974','Pak''N Save/Write Price Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040007977','Pet Practices Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040007977','Pet Practices Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040007977','Pet Practices Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040007978','Pet Vet Ltd Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040007978','Pet Vet Ltd Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040007978','Pet Vet Ltd Level 4','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFPS_NZ','02','0040007989','Supervalue NZ Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPPS_NZ','05','0040007989','Supervalue NZ Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSPS_NZ','01','0040007989','Supervalue NZ Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007994','Event Cinemas NZ Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007994','Event Cinemas NZ Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007994','Event Cinemas NZ Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008007','Toops NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008007','Toops NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008007','Toops NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFWS_NZ','02','0040008008','The Warehouse NZS Level 5','The Warehouse');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPWS_NZ','05','0040008008','The Warehouse NZS Level 5','The Warehouse');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSWS_NZ','01','0040008008','The Warehouse NZS Level 5','The Warehouse');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFWN_NZ','02','0040008009','The Warehouse NZN Level 5','The Warehouse');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPWN_NZ','05','0040008009','The Warehouse NZN Level 5','The Warehouse');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSWN_NZ','01','0040008009','The Warehouse NZN Level 5','The Warehouse');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008015','Z Energy Ltd NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008015','Z Energy Ltd NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008015','Z Energy Ltd NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAS_NZ','02','0040008016','RD1 NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAS_NZ','05','0040008016','RD1 NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAS_NZ','01','0040008016','RD1 NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAN_NZ','02','0040008017','RD1 NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAN_NZ','05','0040008017','RD1 NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAN_NZ','01','0040008017','RD1 NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAS_NZ','02','0040008020','PGG Wrightsons NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008042','NZ Independent Vets NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008043','NZ Independent Vets NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008043','NZ Independent Vets NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008043','NZ Independent Vets NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008044','NZ Ind Pet Outlets NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008044','NZ Ind Pet Outlets NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008044','NZ Ind Pet Outlets NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008045','NZ Ind Pet Outlets NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008045','NZ Ind Pet Outlets NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008045','NZ Ind Pet Outlets NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008047','L5 Impulse Dist Secondary NZS','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008047','L5 Impulse Dist Secondary NZS','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008047','L5 Impulse Dist Secondary NZS','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008049','NZ Breeder Suppliers NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008049','NZ Breeder Suppliers NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008049','NZ Breeder Suppliers NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008050','NZ Breeder Suppliers NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008050','NZ Breeder Suppliers NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008050','NZ Breeder Suppliers NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008062','Kongs NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008062','Kongs NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008062','Kongs NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008063','Kongs NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008063','Kongs NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008063','Kongs NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAS_NZ','02','0040008066','Independent Rurals NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040028272','L5 NZ Impulse Distributor Other','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040028272','L5 NZ Impulse Distributor Other','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040028272','L5 NZ Impulse Distributor Other','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040028643','L4 Australia Army','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040028643','L4 Australia Army','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040028643','L4 Australia Army','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAS_NZ','05','0040008020','PGG Wrightsons NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAS_NZ','01','0040008020','PGG Wrightsons NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008021','Provet NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008021','Provet NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008021','Provet NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008028','Pet Essentials NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008028','Pet Essentials NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008028','Pet Essentials NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008029','Pet Essentials NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008029','Pet Essentials NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008029','Pet Essentials NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008035','NZARFD N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008035','NZARFD N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008035','NZARFD N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008036','NZARFD N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008036','NZARFD N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008036','NZARFD N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008042','NZ Independent Vets NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008042','NZ Independent Vets NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAS_NZ','05','0040008066','Independent Rurals NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAS_NZ','01','0040008066','Independent Rurals NZS Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAN_NZ','02','0040008067','Independent Rurals NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAN_NZ','05','0040008067','Independent Rurals NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAN_NZ','01','0040008067','Independent Rurals NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008068','Event Cinemas NZ Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008068','Event Cinemas NZ Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008068','Event Cinemas NZ Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008070','Hoyts NZ (Akld) NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008070','Hoyts NZ (Akld) NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008070','Hoyts NZ (Akld) NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008072','Hoyts NZ (Akld) NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008072','Hoyts NZ (Akld) NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008072','Hoyts NZ (Akld) NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008087','Foodservice General NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008087','Foodservice General NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008087','Foodservice General NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008088','Foodservice General NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008088','Foodservice General NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008088','Foodservice General NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008094','Direct to Consumer N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008094','Direct to Consumer N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008094','Direct to Consumer N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008095','Direct to Consumer N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008095','Direct to Consumer N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008095','Direct to Consumer N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008099','Davis Trading NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008099','Davis Trading NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008099','Davis Trading NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008100','Davis Trading NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008100','Davis Trading NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008100','Davis Trading NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008101','Bidvest NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008101','Bidvest NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008101','Bidvest NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008102','Bidvest NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008102','Bidvest NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008102','Bidvest NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008103','Countrywide N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008103','Countrywide N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008103','Countrywide N/A NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008104','Countrywide N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008104','Countrywide N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008113','Caltex Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008115','BP Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008115','BP Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008115','BP Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008126','Animates NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008126','Animates NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008126','Animates NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008127','Animates NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008127','Animates NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008127','Animates NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAS_NZ','02','0040008139','Combined Rural Traders Level 3','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAS_NZ','05','0040008139','Combined Rural Traders Level 3','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAS_NZ','01','0040008139','Combined Rural Traders Level 3','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAN_NZ','02','0040008140','Farmlands Level 3','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAN_NZ','05','0040008140','Farmlands Level 3','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAN_NZ','01','0040008140','Farmlands Level 3','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040009701','Trents NZS Level 5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040009701','Trents NZS Level 5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040009701','Trents NZS Level 5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAN_NZ','02','0040009706','PGG Wrightsons NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAN_NZ','05','0040009706','PGG Wrightsons NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAN_NZ','01','0040009706','PGG Wrightsons NZN Level 5','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040009755','Mobil Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040009755','Mobil Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040009755','Mobil Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAN_NZ','02','0040010812','Elders  Level 5 - NZN','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAN_NZ','05','0040010812','Elders  Level 5 - NZN','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAN_NZ','01','0040010812','Elders  Level 5 - NZN','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFAS_NZ','02','0040010814','Elders Level 5 - NZS','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPAS_NZ','05','0040010814','Elders Level 5 - NZS','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSAS_NZ','01','0040010814','Elders Level 5 - NZS','AGRI');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040010916','Provet NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040010916','Provet NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040010916','Provet NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040011003','The Mad Butcher NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040011003','The Mad Butcher NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040011003','The Mad Butcher NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040011004','The Mad Butcher NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040011004','The Mad Butcher NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040011004','The Mad Butcher NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040011817','Four Square Direct  NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040011817','Four Square Direct  NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040011817','Four Square Direct  NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040011818','Four Square Direct NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040011818','Four Square Direct NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040011818','Four Square Direct NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040014051','Mitre 10 Mega NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040014051','Mitre 10 Mega NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040014051','Mitre 10 Mega NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040014052','Mitre 10 Mega NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040014052','Mitre 10 Mega NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008104','Countrywide N/A NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008109','Convenience Not Applic NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008112','Chrisco Hampers NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008112','Chrisco Hampers NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040008112','Chrisco Hampers NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008113','Caltex Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008113','Caltex Oil NZ NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040008108','Convenience Not Applic NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040008108','Convenience Not Applic NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040008108','Convenience Not Applic NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040008109','Convenience Not Applic NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040008109','Convenience Not Applic NZN Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040014916','Z Energy Ltd NZ NZS Level 5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040014052','Mitre 10 Mega NZS Level 5','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040014916','Z Energy Ltd NZ NZS Level 5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040014916','Z Energy Ltd NZ NZS Level 5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040015946','Caltex Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040015946','Caltex Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040015946','Caltex Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040015947','BP Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040015947','BP Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040015947','BP Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040015948','Mobil Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040015948','Mobil Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040015948','Mobil Oil NZ NZS L5','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040017474','L5 Mobility Dogs Nth','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040017474','L5 Mobility Dogs Nth','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040017474','L5 Mobility Dogs Nth','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040017475','L5 Mobility Dogs Sth','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040017475','L5 Mobility Dogs Sth','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040017475','L5 Mobility Dogs Sth','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040018000','L5 Impulse Dist Primary NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040018000','L5 Impulse Dist Primary NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040018000','L5 Impulse Dist Primary NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIS_NZ','02','0040018001','L5 Impulse Dist Prim NZS','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIS_NZ','05','0040018001','L5 Impulse Dist Prim NZS','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIS_NZ','01','0040018001','L5 Impulse Dist Prim NZS','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040018004','L5 Impulse Dist Secondary NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040018004','L5 Impulse Dist Secondary NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040018004','L5 Impulse Dist Secondary NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040019508','L5 Fix NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040019508','L5 Fix NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040019508','L5 Fix NZN','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040019509','L5 Fix NZS','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040019509','L5 Fix NZS','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040019509','L5 Fix NZS','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040021310','L4 Pet Centre','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040021310','L4 Pet Centre','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040021310','L4 Pet Centre','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFA_NZ','02','0040007932','Foodstuffs RDC AKL Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFA_NZ','05','0040007932','Foodstuffs RDC AKL Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFA_NZ','01','0040007932','Foodstuffs RDC AKL Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVN_NZ','01','0040008014','Southern Vet Suppliers NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVN_NZ','02','0040008014','Southern Vet Suppliers NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVN_NZ','05','0040008014','Southern Vet Suppliers NZN Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSVS_NZ','01','0040008013','Southern Vet Suppliers NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFVS_NZ','02','0040008013','Southern Vet Suppliers NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPVS_NZ','05','0040008013','Southern Vet Suppliers NZS Level 5','PET VET');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007910','Auckland Coin Machines Ltd Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007910','Auckland Coin Machines Ltd Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007910','Auckland Coin Machines Ltd Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007911','Austway Vending Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007911','Austway Vending Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007911','Austway Vending Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007917','Boyd & Major Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007917','Boyd & Major Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007917','Boyd & Major Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFIN_NZ','02','0040007919','Burger King Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPIN_NZ','05','0040007919','Burger King Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSIN_NZ','01','0040007919','Burger King Level 4','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFPN_NZ','02','0040007923','Countdown Nth Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPPN_NZ','05','0040007923','Countdown Nth Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSPN_NZ','01','0040007923','Countdown Nth Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSPS_NZ','01','0040007924','Countdown Sth Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040007933','Foodstuffs RDC SI','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040007933','Foodstuffs RDC SI','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040007933','Foodstuffs RDC SI','FOODPULSE');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFA_NZ','02','0040007935','Four Square Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFA_NZ','05','0040007935','Four Square Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFA_NZ','01','0040007935','Four Square Akl Level 4','Foodstuffs Auckland');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFC_NZ','02','0040007936','Four Square SI Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFC_NZ','05','0040007936','Four Square SI Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFPS_NZ','02','0040007924','Countdown Sth Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPPS_NZ','05','0040007924','Countdown Sth Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFC_NZ','01','0040007936','Four Square SI Level 4','Foodstuffs South Island');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFFW_NZ','02','0040007937','Four Square Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPFW_NZ','05','0040007937','Four Square Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NSFW_NZ','01','0040007937','Four Square Wgtn Level 4','Foodstuffs Wellington');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NFPS_NZ','02','0040007938','Fresh Choice Level 4','Progressive');
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC) values ('NPPS_NZ','05','0040007938','Fresh Choice Level 4','Progressive');
-- New Production Australia 
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APAG_AP','05','0040011053','L2 Agriculture POS Format','Agri',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APBW_AP','05','0040006340','L3 Big W Buying Group','Big W',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APCM_AP','05','0040006177','L3 GHPL Buying Group','Coles',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APCO_AP','05','0040015020','L3 Costco Customer Buying Group','Costco',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APEC_AP','05','0040006300','L3 AEC Buying Group','AEC',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APME_AP','05','0040006180','L3 Metcash Grocery Buying Group','Independents',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APME_AP','05','0040006693','L3 SPAR Buying Group','Independents',0);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APMS_AP','05','0040010855','Miscellaneous Dmd Grp - Pet','Miscellaneous',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APPT_AP','05','0040011054','L2 Pet Specialist No POS Format','Pet Specialist',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APVT_AP','05','0040011056','L2 Vet Clinic POS Format','Vet',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APWW_AP','05','0040006187','L3 Woolworths Buying Group','Woolworths',100);
Insert into df.px_dmnd_lookup (DMND_GRP_CODE,BUS_SGMNT_CODE,DMND_PLNG_NODE,DMND_GRP_DESC,DMND_PLNG_DESC,SPLIT_PERCENT) values ('APWW_AP','05','0040006324','L3 Statewide Buying Group','Statewide',0);

commit;
