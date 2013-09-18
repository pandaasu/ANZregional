-- Create a local synonyms as public ones are not always allowed.
create or replace synonym pmx_matl_dtrmntn for "PXI"."PMX_MATL_DTRMNTN";
create or replace synonym pmx_359_promotions_seq for pxi.pmx_359_promotions_seq;
create or replace synonym pmx_359_promotions for pxi.pmx_359_promotions;
create or replace synonym "PMX_ZREP_MATERIALS" for "PXI"."PMX_ZREP_MATERIALS";
create or replace synonym pmx_prom_config for pxi.pmx_prom_config;
create or replace synonym "PMX_MATL_TDU_TO_RSU" for "PXI"."PMX_MATL_TDU_TO_RSU";
create or replace synonym PMX_MATL_HIST for pxi.PMX_MATL_HIST;
