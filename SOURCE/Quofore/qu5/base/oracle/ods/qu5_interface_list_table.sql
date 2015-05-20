
set define off;

  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_interface_list
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    Interface / Entity / Table List

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-07-10  Mal Chambeyron        Increase Entity Name from 32 > 64 char
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- Table DDL
drop table ods.qu5_interface_list cascade constraints;

create table ods.qu5_interface_list (
  q4x_interface_name              varchar2(32 char)               not null, -- LICS Limit
  q4x_entity_name                 varchar2(64 char)               not null,
  q4x_table_name                  varchar2(30 char)               not null -- Oracle Limit
);

-- Constraints and Checks
alter table ods.qu5_interface_list add constraint qu5_interface_list_pk primary key (q4x_interface_name)
  using index (create unique index qu5_interface_list_pk on ods.qu5_interface_list(q4x_interface_name));

alter table ods.qu5_interface_list add constraint qu5_interface_list_entity_uk unique (q4x_entity_name)
  using index (create unique index qu5_interface_list_entity_uk on ods.qu5_interface_list(q4x_entity_name));

alter table ods.qu5_interface_list add constraint qu5_interface_list_table_uk unique (q4x_table_name)
  using index (create unique index qu5_interface_list_table_uk on ods.qu5_interface_list(q4x_table_name));

alter table ods.qu5_interface_list add constraint qu5_interface_list_int_ck check (q4x_interface_name = upper(q4x_interface_name));

alter table ods.qu5_interface_list add constraint qu5_interface_list_entity_ck check (q4x_entity_name = upper(q4x_entity_name));

alter table ods.qu5_interface_list add constraint qu5_interface_list_table_ck check (q4x_table_name = upper(q4x_table_name));

-- Comments
comment on table ods.qu5_interface_list is'Quofore Interface Control : Interface / Entity / Table List';
comment on column ods.qu5_interface_list.q4x_interface_name is'Primary Key - Interface Name - MUST BE UPPERCASE';
comment on column ods.qu5_interface_list.q4x_entity_name is'Unique Key - Entity Name - MUST BE UPPERCASE';
comment on column ods.qu5_interface_list.q4x_table_name is'Unique Key - Table Name - MUST BE UPPERCASE';

-- Synonyms
create or replace public synonym qu5_interface_list for ods.qu5_interface_list;

-- Grants
grant select,insert,update,delete on ods.qu5_interface_list to ods_app;
grant select on ods.qu5_interface_list to dds_app, qv_user, bo_user;

-- Populate Table ..

insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW00','DIGEST','QU5_DIGEST');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW01','HIERARCHY','QU5_HIER');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW02','GENERALLIST','QU5_GENERAL_LIST');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW03','ROLE','QU5_ROLE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW04','POSITION','QU5_POS');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW05','REP','QU5_REP');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW06','REPADDRESS','QU5_REP_ADDRESS');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW07','PRODUCT','QU5_PROD');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW08','PRODUCTBARCODE','QU5_PROD_BARCODE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW09','CUSTOMER','QU5_CUST');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW10','CUSTOMERADDRESS','QU5_CUST_ADDRESS');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW11','CUSTOMERNOTE','QU5_CUST_NOTE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW12','CUSTOMERCONTACT','QU5_CUST_CONTACT');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW13','CUSTOMERVISITORDAY','QU5_CUST_VISITOR_DAY');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW14','CUSTOMERCONTACTTRAINING','QU5_CUST_CONTACT_TRAINING');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW15','ASSORTMENTDETAIL','QU5_ASSORT_DTL');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW16','CUSTOMERASSORTMENTDETAIL','QU5_CUST_ASSORT_DTL');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW17','PRODUCTASSORTMENTDETAIL','QU5_PROD_ASSORT_DTL');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW18','AUTHORISEDLISTPRODUCT','QU5_AUTH_LIST_PROD');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW19','APPOINTMENT','QU5_APPOINT');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW20','CALLCARD','QU5_CALLCARD');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW21','CALLCARDNOTE','QU5_CALLCARD_NOTE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW22','ORDERHEADER','QU5_ORD_HDR');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW23','ORDERDETAIL','QU5_ORD_DTL');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW24','TERRITORY','QU5_TERR');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW25','CUSTOMERTERRITORY','QU5_CUST_TERR');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW26','POSITIONTERRITORY','QU5_POS_TERR');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW27','SURVEY','QU5_SURVEY');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW28','SURVEYQUESTION','QU5_SURVEY_QUESTION');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW29','RESPONSEOPTION','QU5_RESPONSE_OPT');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW30','TASK','QU5_TASK');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW31','TASKASSIGNMENT','QU5_TASK_ASSIGNMENT');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW32','TASKCUSTOMER','QU5_TASK_CUST');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW33','TASKPRODUCT','QU5_TASK_PROD');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW34','TASKSURVEY','QU5_TASK_SURVEY');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW35','ACTIVITYHEADER','QU5_ACT_HDR');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW36','SURVEYANSWER','QU5_SURVEY_ANSWER');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW37','GRAVEYARD','QU5_GRAVEYARD');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW38','CUSTOMERWHOLESALER','QU5_CUST_WHOLESALER');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW39','ACTIVITYDETAILDISTCHECK1','QU5_ACT_DTL_DIST_CHECK_1');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW40','ACTIVITYDETAILDISTCHECK2','QU5_ACT_DTL_DIST_CHECK_2');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW41','ACTIVITYDETAILRELAYHOURS','QU5_ACT_DTL_RELAY_HOURS');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW42','ACTIVITYDETAILSECONDSITE','QU5_ACT_DTL_SECOND_SITE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW43','ACTIVITYDETAILPTOFINTERUPT','QU5_ACT_DTL_INTERUPTION');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW44','ACTIVITYDETAILHARDWARE','QU5_ACT_DTL_HARDWARE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW45','ACTIVITYDETAILUPGRADES','QU5_ACT_DTL_UPGRADES');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW46','ACTIVITYDETAILTRAINING','QU5_ACT_DTL_TRAINING');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW47','ACTIVITYDETAILSHAREOFSHELF','QU5_ACT_DTL_SHELF_SHARE');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW48','ACTIVITYDETAILPROMOCOMPLIANCE','QU5_ACT_DTL_COMPLIANT');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW49','ACTIVITYDETAILNEWPRODDEV','QU5_ACT_DTL_NEW_PROD_DEV');
insert into qu5_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU5CDW99','*ALL','QU5_INTERFACE_LIST');
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
