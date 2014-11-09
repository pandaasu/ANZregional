/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : qv
  Package   : bth_ats_mat_inclusion
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  BTH Plant DB - ATS Material Inclusions  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-11-10  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table qv.bth_ats_mat_inclusion cascade constraints;
  
  -- Create Table
  create table qv.bth_ats_mat_inclusion (
    matl_code varchar2(30 char) not null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table qv.bth_ats_mat_inclusion add constraint bth_ats_mat_inclusion_pk primary key (matl_code)
    using index (create unique index qv.bth_ats_mat_inclusion_pk on qv.bth_ats_mat_inclusion (matl_code));


  -- Comments
  comment on table bth_ats_mat_inclusion is 'BTH Plant DB - ATS Material Inclusions';
  comment on column bth_ats_mat_inclusion.matl_code is 'Material Code';
  comment on column bth_ats_mat_inclusion.last_update_date is 'Last Update Date/Time';
  comment on column bth_ats_mat_inclusion.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on qv.bth_ats_mat_inclusion to qv_app, lics_app with grant option;
  grant select on qv.bth_ats_mat_inclusion to qv_user, qv_app, lics_app;

/*******************************************************************************
  END
*******************************************************************************/
