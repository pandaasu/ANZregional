/*******************************************************************************
** Table Definition
********************************************************************************

 System : quo
 Table  : quo_interface_list
 Owner  : quo
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Quofore Interface Control : Interface / Entity / Table List 

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2013-02-19   Mal Chambeyron         Created

*******************************************************************************/

-- Table DDL
drop table ods.quo_interface_list cascade constraints;

create table ods.quo_interface_list (
  q4x_interface_name              varchar2(32 char)               not null, -- LICS Limit
  q4x_entity_name                 varchar2(32 char)               not null,
  q4x_table_name                  varchar2(30 char)               not null -- Oracle Limit
);

-- Constraints and Checks
alter table ods.quo_interface_list add constraint quo_interface_list_pk primary key (q4x_interface_name) 
  using index (create unique index quo_interface_list_pk on ods.quo_interface_list(q4x_interface_name));

alter table ods.quo_interface_list add constraint quo_interface_list_entity_uk unique (q4x_entity_name)
  using index (create unique index quo_interface_list_entity_uk on ods.quo_interface_list(q4x_entity_name));

alter table ods.quo_interface_list add constraint quo_interface_list_table_uk unique (q4x_table_name)
  using index (create unique index quo_interface_list_table_uk on ods.quo_interface_list(q4x_table_name));
  
alter table ods.quo_interface_list add constraint quo_interface_list_int_ck check (q4x_interface_name = upper(q4x_interface_name));  
  
alter table ods.quo_interface_list add constraint quo_interface_list_entity_ck check (q4x_entity_name = upper(q4x_entity_name));  

alter table ods.quo_interface_list add constraint quo_interface_list_table_ck check (q4x_table_name = upper(q4x_table_name));  
  
-- Comments
comment on table ods.quo_interface_list is 'Quofore Interface Control : Interface / Entity / Table List';
comment on column ods.quo_interface_list.q4x_interface_name is 'Primary Key - Interface Name - MUST BE UPPERCASE';
comment on column ods.quo_interface_list.q4x_entity_name is 'Unique Key - Entity Name - MUST BE UPPERCASE';
comment on column ods.quo_interface_list.q4x_table_name is 'Unique Key - Table Name - MUST BE UPPERCASE';

-- Synonyms
create or replace public synonym quo_interface_list for ods.quo_interface_list;

-- Grants
grant select,update,delete,insert on ods.quo_interface_list to ods_app;
grant select on ods.quo_interface_list to dds_app, qv_user, bo_user;

-- Populate Table .. 
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW00', 'DIGEST', 'QUO_DIGEST');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW01', 'HIERARCHY', 'QUO_HIER');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW02', 'GENERALLIST', 'QUO_GENERAL_LIST');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW03', 'POSITION', 'QUO_POS');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW04', 'REP', 'QUO_REP');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW05', 'REPADDRESS', 'QUO_REP_ADDRS');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW06', 'PRODUCT', 'QUO_PROD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW07', 'PRODUCTBARCODE', 'QUO_PROD_BARCODE');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW08', 'CUSTOMER', 'QUO_CUST');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW09', 'CUSTOMERADDRESS', 'QUO_CUST_ADDRS');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW10', 'CUSTOMERNOTE', 'QUO_CUST_NOTE');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW11', 'CUSTOMERCONTACT', 'QUO_CUST_CONTACT');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW12', 'CUSTOMERVISITORDAY', 'QUO_CUST_VISIT_DAY');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW13', 'ASSORTMENTDETAIL', 'QUO_ASSORT_DTL');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW14', 'CUSTOMERASSORTMENTDETAIL', 'QUO_CUST_ASSORT_DTL');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW15', 'PRODUCTASSORTMENTDETAIL', 'QUO_PROD_ASSORT_DTL');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW16', 'AUTHORISEDLISTPRODUCT', 'QUO_AUTH_LIST_PROD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW17', 'APPOINTMENT', 'QUO_APPOINT');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW18', 'CALLCARD', 'QUO_CALLCARD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW19', 'CALLCARDNOTE', 'QUO_CALLCARD_NOTE');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW20', 'ORDERHEADER', 'QUO_ORD_HDR');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW21', 'ORDERDETAIL', 'QUO_ORD_DTL');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW22', 'TERRITORY', 'QUO_TERR');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW23', 'CUSTOMERTERRITORY', 'QUO_CUST_TERR');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW24', 'POSITIONTERRITORY', 'QUO_POS_TERR');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW25', 'SURVEY', 'QUO_SURVEY');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW26', 'SURVEYQUESTION', 'QUO_SURVEY_QUESTION');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW27', 'RESPONSEOPTION', 'QUO_RESPONSE_OPT');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW28', 'TASK', 'QUO_TASK');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW29', 'TASKASSIGNMENT', 'QUO_TASK_ASSIGN');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW30', 'TASKCUSTOMER', 'QUO_TASK_CUST');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW31', 'TASKPRODUCT', 'QUO_TASK_PROD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW32', 'TASKSURVEY', 'QUO_TASK_SURVEY');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW33', 'ACTIVITYHEADER', 'QUO_ACT_HDR');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW34', 'ACTIVITYDETAILDISTCHECK', 'QUO_ACT_DTL_DIST_CHECK');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW35', 'ACTIVITYDETAILOOS', 'QUO_ACT_DTL_OOS');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW36', 'ACTIVITYDETAILSOSPSD', 'QUO_ACT_DTL_SOS_PSD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW37', 'ACTIVITYDETAILSOSSPC', 'QUO_ACT_DTL_SOS_SPC');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW38', 'ACTIVITYDETAILSOCPSD', 'QUO_ACT_DTL_SOC_PSD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW39', 'ACTIVITYDETAILSOCSPC', 'QUO_ACT_DTL_SOC_SPC');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW40', 'ACTIVITYDETAILTRAINING', 'QUO_ACT_DTL_TRAINING');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW41', 'SURVEYANSWER', 'QUO_SURVEY_ANSWER');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW42', 'GRAVEYARD', 'QUO_GRAVEYARD');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW43', 'ACTIVITYDETAILOFF', 'QUO_ACT_DTL_OFF');
insert into quo_interface_list (q4x_interface_name, q4x_entity_name, q4x_table_name) values ('QUOCDW99', '*ALL', 'QUO_INTERFACE_LIST');
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
