/*****************/
/* Package Types */
/*****************/
create or replace type pts_sam_list_object as object
   (sam_code number,
    sam_text varchar2(120 char),
    sam_status varchar2(20 char));
/

create or replace type pts_sam_list_type as table of pts_sam_list_object;
/