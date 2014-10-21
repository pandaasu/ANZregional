/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : sop_step_v_scorecard 
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  S&OP+ Scorecard - Step 5   
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-10-16  Trevor Keon           Created 

*******************************************************************************/

  -- Drop Table
  drop table bi.sop_step_v_scorecard cascade constraints;
  
  -- Create Table
  create table bi.sop_step_v_scorecard (
    data_last_update varchar2(10 char) not null,
    level_1 varchar2(500 char) null,
    level_2 varchar2(500 char) null,
    level_3 varchar2(500 char) null,
    data_format varchar2(50 char) null,
    data_year number null,
    field_name varchar2(500 char) null,
    field_value varchar2(500 char) null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  -- no indexes defined

  -- Comments
  comment on table sop_step_v_scorecard is 'SnOP+ Step 5 Scorecard';
  comment on column sop_step_v_scorecard.data_last_update is 'Data Last Updateded';
  comment on column sop_step_v_scorecard.level_1 is 'Level 1 Name';
  comment on column sop_step_v_scorecard.level_2 is 'Level 2 Name';
  comment on column sop_step_v_scorecard.level_3 is 'Level 3 Name';
  comment on column sop_step_v_scorecard.data_format is 'Data Format';
  comment on column sop_step_v_scorecard.data_year is 'Data Year';
  comment on column sop_step_v_scorecard.field_name is 'Field Name';
  comment on column sop_step_v_scorecard.field_value is 'Field Value';
  comment on column sop_step_v_scorecard.last_update_date is 'Last Update Date/Time';
  comment on column sop_step_v_scorecard.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.sop_step_v_scorecard to bi_app, lics_app with grant option;
  grant select on bi.sop_step_v_scorecard to qv_user, bo_user, dds_app, bi_app;

  -- Synonyms 
  create or replace public synonym sop_step_v_scorecard for bi.sop_step_v_scorecard;
  
/*******************************************************************************
  END 
*******************************************************************************/
