/*****************/
/* Package Types */
/*****************/

create or replace type vds_validation_object as object
   (wrk_lng_code varchar2(30 char),
    wrk_trm_code varchar2(30 char),
    wrk_search01 varchar2(256 char),
    wrk_search02 varchar2(256 char),
    wrk_search03 varchar2(256 char),
    wrk_search04 varchar2(256 char),
    wrk_search05 varchar2(256 char),
    wrk_search06 varchar2(256 char),
    wrk_search07 varchar2(256 char),
    wrk_search08 varchar2(256 char),
    wrk_search09 varchar2(256 char));
/
create or replace type vds_validation_table as table of vds_validation_object;
/
