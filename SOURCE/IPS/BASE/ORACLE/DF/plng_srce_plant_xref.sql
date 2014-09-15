-- This is the planning source to plant cross reference table required by the demand financials to apollo supply interface.
create table plng_srce_plant_xref (
  plng_srce_code varchar2(20) not null,
  plng_srce_desc varchar2(200),
  plant_code varchar2(20)
);

-- Create index on the table.
create unique index plng_srce_plant_xref_pk01 on plng_srce_plant_xref (plng_srce_code);

-- Create a primary key constraint.
alter table plng_srce_plant_xref add constraint plng_srce_plant_xref_pk01 primary key (plng_srce_code) using index plng_srce_plant_xref_pk01;

-- Add table comments.
comment on column plng_srce_plant_xref.plng_srce_code IS 'Planning Source Code';
comment on column plng_srce_plant_xref.plng_srce_code IS 'Planning Source Description for Reference.';
comment on column plng_srce_plant_xref.plng_srce_code IS 'Plant Code.';
comment on table plng_srce_plant_xref  IS 'Demand Financials to Apollo Supply Planning Source to Plant Code Cross Reference.';
   
-- Grants to various schemes
grant select, update, insert, delete on plng_srce_plant_xref to df_app;
grant select, update, insert, delete on plng_srce_plant_xref to pf_app;
grant select on plng_srce_plant_xref to pf_reader;
   
-- Setup a public synonym for the table.
create or replace public synonym plng_srce_plant_xref for df.plng_srce_plant_xref;   