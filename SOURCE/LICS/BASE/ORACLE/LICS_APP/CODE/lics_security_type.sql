/*****************/
/* Package Types */
/*****************/
create or replace type lics_security_object as object
   (sec_level                    number,
    sec_obj_type                 varchar2(4 char),
    sec_obj_code                 varchar2(32 char),
    sec_obj_description          varchar2(128 char),
    sec_obj_status               varchar2(1 char),
    sec_lnk_sequence             number,
    sec_lnk_type                 varchar2(4 char),
    sec_lnk_code                 varchar2(32 char),
    sec_lnk_description          varchar2(128 char),
    sec_lnk_script               varchar2(256 char),
    sec_lnk_status               varchar2(1 char));
/

create or replace type lics_security_table as table of lics_security_object;
/
