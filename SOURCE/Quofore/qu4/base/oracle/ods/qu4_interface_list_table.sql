
set define off;

  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_interface_list
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Interface / Entity / Table List

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-07-10  Mal Chambeyron        Increase Entity Name from 32 > 64 char
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- Table DDL
drop table ods.qu4_interface_list cascade constraints;

create table ods.qu4_interface_list (
  q4x_interface_name              varchar2(32 char)               not null, -- LICS Limit
  q4x_entity_name                 varchar2(64 char)               not null,
  q4x_table_name                  varchar2(30 char)               not null -- Oracle Limit
);

-- Constraints and Checks
alter table ods.qu4_interface_list add constraint qu4_interface_list_pk primary key (q4x_interface_name)
  using index (create unique index qu4_interface_list_pk on ods.qu4_interface_list(q4x_interface_name));

alter table ods.qu4_interface_list add constraint qu4_interface_list_entity_uk unique (q4x_entity_name)
  using index (create unique index qu4_interface_list_entity_uk on ods.qu4_interface_list(q4x_entity_name));

alter table ods.qu4_interface_list add constraint qu4_interface_list_table_uk unique (q4x_table_name)
  using index (create unique index qu4_interface_list_table_uk on ods.qu4_interface_list(q4x_table_name));

alter table ods.qu4_interface_list add constraint qu4_interface_list_int_ck check (q4x_interface_name = upper(q4x_interface_name));

alter table ods.qu4_interface_list add constraint qu4_interface_list_entity_ck check (q4x_entity_name = upper(q4x_entity_name));

alter table ods.qu4_interface_list add constraint qu4_interface_list_table_ck check (q4x_table_name = upper(q4x_table_name));

-- Comments
comment on table ods.qu4_interface_list is'Quofore Interface Control : Interface / Entity / Table List';
comment on column ods.qu4_interface_list.q4x_interface_name is'Primary Key - Interface Name - MUST BE UPPERCASE';
comment on column ods.qu4_interface_list.q4x_entity_name is'Unique Key - Entity Name - MUST BE UPPERCASE';
comment on column ods.qu4_interface_list.q4x_table_name is'Unique Key - Table Name - MUST BE UPPERCASE';

-- Synonyms
create or replace public synonym qu4_interface_list for ods.qu4_interface_list;

-- Grants
grant select,insert,update,delete on ods.qu4_interface_list to ods_app;
grant select on ods.qu4_interface_list to dds_app, qv_user, bo_user;

-- Populate Table ..

insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW00','DIGEST','QU4_DIGEST');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW01','HIERARCHY','QU4_HIER');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW02','GENERALLIST','QU4_GENERAL_LIST');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW03','ROLE','QU4_ROLE');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW04','POSITION','QU4_POS');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW05','REP','QU4_REP');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW06','REPADDRESS','QU4_REP_ADDRESS');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW07','PRODUCT','QU4_PROD');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW08','PRODUCTBARCODE','QU4_PROD_BARCODE');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW09','CUSTOMER','QU4_CUST');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW10','CUSTOMERADDRESS','QU4_CUST_ADDRESS');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW11','CUSTOMERNOTE','QU4_CUST_NOTE');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW12','CUSTOMERCONTACT','QU4_CUST_CONTACT');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW13','CUSTOMERVISITORDAY','QU4_CUST_VISITOR_DAY');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW14','ASSORTMENTDETAIL','QU4_ASSORT_DTL');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW15','CUSTOMERASSORTMENTDETAIL','QU4_CUST_ASSORT_DTL');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW16','PRODUCTASSORTMENTDETAIL','QU4_PROD_ASSORT_DTL');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW17','AUTHORISEDLISTPRODUCT','QU4_AUTH_LIST_PROD');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW18','APPOINTMENT','QU4_APPOINT');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW19','CALLCARD','QU4_CALL_CARD');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW20','CALLCARDNOTE','QU4_CALL_CARD_NOTE');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW21','ORDERHEADER','QU4_ORD_HDR');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW22','ORDERDETAIL','QU4_ORD_DTL');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW23','TERRITORY','QU4_TERR');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW24','CUSTOMERTERRITORY','QU4_CUST_TERR');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW25','POSITIONTERRITORY','QU4_POS_TERR');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW26','SURVEY','QU4_SURVEY');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW27','SURVEYQUESTION','QU4_SURVEY_QUESTION');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW28','RESPONSEOPTION','QU4_RESPONSE_OPT');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW29','TASK','QU4_TASK');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW30','TASKASSIGNMENT','QU4_TASK_ASSIGNMENT');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW31','TASKCUSTOMER','QU4_TASK_CUST');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW32','TASKPRODUCT','QU4_TASK_PROD');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW33','TASKSURVEY','QU4_TASK_SURVEY');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW34','ACTIVITYHEADER','QU4_ACT_HDR');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW35','ACTIVITYDETAILDISTRIBUTION','QU4_ACT_DTL_DIST');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW36','ACTIVITYDETAILPERMANENCY','QU4_ACT_DTL_PERMANCY');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW37','ACTIVITYDETAILDISPLAYTRADESTD','QU4_ACT_DTL_DISPLY_STD');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW38','SURVEYANSWER','QU4_SURVEY_ANSWER');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW39','GRAVEYARD','QU4_GRAVEYARD');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW40','ACTIVITYDETAILPLANOGRAM','QU4_ACT_DTL_PLANOGRAM');
insert into qu4_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU4CDW99','*ALL','QU4_INTERFACE_LIST');
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
