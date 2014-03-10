/*******************************************************************************
** TABLE DEFINITION
********************************************************************************

  Schema    : bi
  Package   : mqm_audit_result
  Author    : Trevor Keon         

  Description
  ------------------------------------------------------------------------------
  MQM Scorecard - Food - Audit Results  
  
  Date        Author                Description
  ----------  -------------------  --------------------------------------------
  2014-02-05  Trevor Keon           [Auto Generated]

*******************************************************************************/

  -- Drop Table
  drop table bi.mqm_audit_result cascade constraints;
  
  -- Create Table
  create table bi.mqm_audit_result (
    supplier varchar2(500 char) not null,
    audit_score varchar2(10 char),
    audit_date date not null,
    activity_status varchar2(100 char),
    status varchar2(4 char),
    last_status_change date,
    auditor varchar2(50 char),
    critical number(16,0),
    major number(16,0),
    minor number(16,0),
    last_update_date date not null,
    last_update_user varchar2(30 char) not null
  );
  
  -- Indexes
  alter table bi.mqm_audit_result add constraint mqm_audit_result_pk primary key (supplier,audit_date)
    using index (create unique index bi.mqm_audit_result_pk on bi.mqm_audit_result (supplier,audit_date));


  -- Comments
  comment on table mqm_audit_result is 'MQM Scorecard - Food - Audit Results';
  comment on column mqm_audit_result.supplier is 'Supplier Code';
  comment on column mqm_audit_result.audit_score is 'Audit Score';
  comment on column mqm_audit_result.audit_date is 'Audit Date';
  comment on column mqm_audit_result.activity_status is 'Activity Status';
  comment on column mqm_audit_result.status is 'Overwrite status';
  comment on column mqm_audit_result.last_status_change is 'Date of last status change';
  comment on column mqm_audit_result.auditor is 'Auditor initials';  
  comment on column mqm_audit_result.critical is '# of critical non-conformance';
  comment on column mqm_audit_result.major is '# of major non-conformance';
  comment on column mqm_audit_result.minor is '# of minor non-conformance';
  comment on column mqm_audit_result.last_update_date is 'Last Update Date/Time';
  comment on column mqm_audit_result.last_update_user is 'Last Update User';
   
  -- Grants
  grant select, insert, update, delete on bi.mqm_audit_result to bi_app, lics_app with grant option;
  grant select on bi.mqm_audit_result to qv_user, bo_user, dds_app, bi_app;

  -- Synonyms 
  create or replace public synonym mqm_audit_result for bi.mqm_audit_result;

/*******************************************************************************
  END
*******************************************************************************/
