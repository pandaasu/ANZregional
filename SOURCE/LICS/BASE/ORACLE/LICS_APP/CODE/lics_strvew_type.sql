/*****************/
/* Package Types */
/*****************/
drop type lics_strvew_table;

create or replace type lics_strvew_object as object
   (str_depth                    number,
    str_type                     varchar2(1 char),
    str_dt001                    varchar2(512 char),
    str_dt002                    varchar2(512 char),
    str_dt003                    varchar2(512 char),
    str_dt004                    varchar2(512 char),
    str_dt005                    varchar2(512 char),
    str_dt006                    varchar2(512 char),
    str_dt007                    varchar2(512 char),
    str_dt008                    varchar2(512 char),
    str_dt009                    varchar2(512 char),
    str_dt010                    varchar2(512 char),
    str_dt011                    varchar2(512 char),
    str_dt012                    varchar2(512 char),
    str_dt013                    varchar2(512 char));
/

create or replace type lics_strvew_table as table of lics_strvew_object;
/