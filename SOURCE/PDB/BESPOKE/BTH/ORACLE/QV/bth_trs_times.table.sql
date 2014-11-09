/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : qv
  Package   : bth_trs_times
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  BTH Plant DB - TRS Times  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-06-20  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table qv.bth_trs_times cascade constraints;
  
  -- Create Table
  create table qv.bth_trs_times (
    mars_week number(7,0) not null,
    lights_on date not null,
    lights_off date not null,
    holiday_hours number(7,2) null,
    pm_hours number(7,2) null,
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table qv.bth_trs_times add constraint bth_trs_times_pk primary key (mars_week)
    using index (create unique index qv.bth_trs_times_pk on qv.bth_trs_times (mars_week));


  -- Comments
  comment on table bth_trs_times is 'BTH Plant DB - TRS Times';
  comment on column bth_trs_times.mars_week is 'Mars Week';
  comment on column bth_trs_times.lights_on is 'Lights On Time';
  comment on column bth_trs_times.lights_off is 'Lights Off Time';
  comment on column bth_trs_times.holiday_hours is 'Public Holiday Hours';
  comment on column bth_trs_times.pm_hours is 'Planned Maintenance Hours';
  comment on column bth_trs_times.last_update_date is 'Last Update Date/Time';
  comment on column bth_trs_times.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on qv.bth_trs_times to qv_app, lics_app with grant option;
  grant select on qv.bth_trs_times to qv_user;

/*******************************************************************************
  END
*******************************************************************************/
