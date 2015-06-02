
set define off;

  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_interface_list
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    Interface / Entity / Table List

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-07-10  Mal Chambeyron        Increase Entity Name from 32 > 64 char
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- Table DDL
drop table ods.qu3_interface_list cascade constraints;

create table ods.qu3_interface_list (
  q4x_interface_name              varchar2(32 char)               not null, -- LICS Limit
  q4x_entity_name                 varchar2(64 char)               not null,
  q4x_table_name                  varchar2(30 char)               not null -- Oracle Limit
);

-- Constraints and Checks
alter table ods.qu3_interface_list add constraint qu3_interface_list_pk primary key (q4x_interface_name)
  using index (create unique index qu3_interface_list_pk on ods.qu3_interface_list(q4x_interface_name));

alter table ods.qu3_interface_list add constraint qu3_interface_list_entity_uk unique (q4x_entity_name)
  using index (create unique index qu3_interface_list_entity_uk on ods.qu3_interface_list(q4x_entity_name));

alter table ods.qu3_interface_list add constraint qu3_interface_list_table_uk unique (q4x_table_name)
  using index (create unique index qu3_interface_list_table_uk on ods.qu3_interface_list(q4x_table_name));

alter table ods.qu3_interface_list add constraint qu3_interface_list_int_ck check (q4x_interface_name = upper(q4x_interface_name));

alter table ods.qu3_interface_list add constraint qu3_interface_list_entity_ck check (q4x_entity_name = upper(q4x_entity_name));

alter table ods.qu3_interface_list add constraint qu3_interface_list_table_ck check (q4x_table_name = upper(q4x_table_name));

-- Comments
comment on table ods.qu3_interface_list is'Quofore Interface Control : Interface / Entity / Table List';
comment on column ods.qu3_interface_list.q4x_interface_name is'Primary Key - Interface Name - MUST BE UPPERCASE';
comment on column ods.qu3_interface_list.q4x_entity_name is'Unique Key - Entity Name - MUST BE UPPERCASE';
comment on column ods.qu3_interface_list.q4x_table_name is'Unique Key - Table Name - MUST BE UPPERCASE';

-- Synonyms
create or replace public synonym qu3_interface_list for ods.qu3_interface_list;

-- Grants
grant select,insert,update,delete on ods.qu3_interface_list to ods_app;
grant select on ods.qu3_interface_list to dds_app, qv_user, bo_user;

-- Populate Table ..

insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW00','DIGEST','QU3_DIGEST');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW01','HIERARCHY','QU3_HIER');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW02','GENERALLIST','QU3_GENERAL_LIST');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW03','ROLE','QU3_ROLE');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW04','POSITION','QU3_POS');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW05','REP','QU3_REP');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW06','REPADDRESS','QU3_REP_ADDRS');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW07','PRODUCT','QU3_PROD');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW08','PRODUCTBARCODE','QU3_PROD_BARCODE');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW09','CUSTOMER','QU3_CUST');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW10','CUSTOMERADDRESS','QU3_CUST_ADDRS');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW11','CUSTOMERNOTE','QU3_CUST_NOTE');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW12','CUSTOMERCONTACT','QU3_CUST_CONTACT');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW13','CUSTOMERVISITORDAY','QU3_CUST_VISIT_DAY');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW14','ASSORTMENTDETAIL','QU3_ASSORT_DTL');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW15','CUSTOMERASSORTMENTDETAIL','QU3_CUST_ASSORT_DTL');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW16','PRODUCTASSORTMENTDETAIL','QU3_PROD_ASSORT_DTL');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW17','AUTHORISEDLISTPRODUCT','QU3_AUTH_LIST_PROD');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW18','APPOINTMENT','QU3_APPOINT');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW19','CALLCARD','QU3_CALLCARD');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW20','CALLCARDNOTE','QU3_CALLCARD_NOTE');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW21','ORDERHEADER','QU3_ORD_HDR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW22','ORDERDETAIL','QU3_ORD_DTL');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW23','TERRITORY','QU3_TERR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW24','CUSTOMERTERRITORY','QU3_CUST_TERR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW25','POSITIONTERRITORY','QU3_POS_TERR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW26','SURVEY','QU3_SURVEY');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW27','SURVEYQUESTION','QU3_SURVEY_QUESTION');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW28','RESPONSEOPTION','QU3_RESPONSE_OPT');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW29','TASK','QU3_TASK');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW30','TASKASSIGNMENT','QU3_TASK_ASSIGN');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW31','TASKCUSTOMER','QU3_TASK_CUST');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW32','TASKPRODUCT','QU3_TASK_PROD');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW33','TASKSURVEY','QU3_TASK_SURVEY');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW34','ACTIVITYHEADER','QU3_ACT_HDR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW35','ACTIVITYDETAILHOTSPOT','QU3_ACT_DTL_HOTSPOT');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW36','ACTIVITYDETAILGPA','QU3_ACT_DTL_GPA');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW37','ACTIVITYDETAILRANGING','QU3_ACT_DTL_RANGING');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW38','ACTIVITYDETAILPOS','QU3_ACT_DTL_POS');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW39','ACTIVITYDETAILOFFLOCATION','QU3_ACT_DTL_OFF_LOC');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW40','SURVEYANSWER','QU3_SURVEY_ANSWER');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW41','GRAVEYARD','QU3_GRAVEYARD');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW42','ACTIVITYDETAILHWAUDITGROC','QU3_ACT_DTL_HWAUDIT_GR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW43','ACTIVITYDETAILHARDWAREAUDITROUTE','QU3_ACT_DTL_HWAUDIT_RO');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW44','ACTIVITYDETAILSTOREOPPGROCERY','QU3_ACT_DTL_STOREOP_GR');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW45','ACTIVITYDETAILSTOREOPPROUTE','QU3_ACT_DTL_STOREOP_RO');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW46','ACTIVITYDETAILTOPSKUAUDIT','QU3_ACT_DTL_TOP_SKU');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW47','ACTIVITYDETAILPACKAGINGCHGAUDIT','QU3_ACT_DTL_PCKING_CHG');
insert into qu3_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU3CDW99','*ALL','QU3_INTERFACE_LIST');
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
