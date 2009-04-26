/*****************/
/* Package Types */
/*****************/
create or replace type pts_geo_list_object as object (geo_zone number, geo_text varchar2(120 char));
/

create or replace type pts_geo_list_type as table of pts_geo_list_object;
/