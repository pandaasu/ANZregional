--------------------------------------------------------------------------------
-- Sequence 
drop sequence pxi.pmx_359_promotions_seq;

create sequence pxi.pmx_359_promotions_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

-- Synonym
create or replace public synonym pmx_359_promotions_seq for pxi.pmx_359_promotions_seq;

-- Grants
grant select on pxi.pmx_359_promotions_seq to pxi_app;

