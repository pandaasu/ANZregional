/*******************************************************************************
** Sequence Definition
********************************************************************************

 System : quo
 Sequence : quo_load_seq
 Owner  : quo
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Quofore Interface Control : Load Sequence 

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2012-10-26   Mal Chambeyron         Created

*******************************************************************************/

-- Sequence DDL
drop sequence ods.quo_load_seq;

create sequence ods.quo_load_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

-- Synonyms
create or replace public synonym quo_load_seq for ods.quo_load_seq;

-- Grants
grant select on ods.quo_load_seq to ods_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
