/*****************/
/* Package Types */
/*****************/
create or replace type pts_geo_hier_object as object (hie_level number, geo_type number, geo_zone number, geo_text varchar2(120 char));
/

create or replace type pts_geo_hier_type as table of pts_geo_hier_object;
/