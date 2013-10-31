/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : japan_target_days_cover
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  Japan Inventory - Target Days Cover  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2013-10-31  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table bi.japan_target_days_cover cascade constraints;
  
  -- Create Table
  create table bi.japan_target_days_cover (
    matl_code varchar2(18 char) not null,
    plant_code varchar2(4 char) not null,
    target_days_cover number(8,0) not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table bi.japan_target_days_cover add constraint japan_target_days_cover_pk primary key (matl_code,plant_code)
    using index (create unique index bi.japan_target_days_cover_pk on bi.japan_target_days_cover (matl_code,plant_code));


  -- Comments
  comment on table japan_target_days_cover is 'Japan Inventory - Target Days Cover';
  comment on column japan_target_days_cover.matl_code is 'Material Code';
  comment on column japan_target_days_cover.plant_code is 'Plant Code';
  comment on column japan_target_days_cover.target_days_cover is 'Target Days Cover';
  comment on column japan_target_days_cover.last_update_date is 'Last Update Date/Time';
  comment on column japan_target_days_cover.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.japan_target_days_cover to bi_app, lics_app with grant option;
  grant select on bi.japan_target_days_cover to qv_user, qv_app, bi_app;

  -- Synonyms
  create or replace public synonym japan_target_days_cover for bi.japan_target_days_cover;

/*******************************************************************************
  END
*******************************************************************************/
