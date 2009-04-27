/*****************/
/* Package Types */
/*****************/
create or replace type pts_sam_cntl_object as object
   (lst_more number,
    end_code number);
/

create or replace type pts_sam_cntl_type as table of pts_sam_cntl_object;
/