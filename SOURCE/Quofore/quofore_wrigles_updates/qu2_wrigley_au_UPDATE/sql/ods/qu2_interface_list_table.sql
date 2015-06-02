
set define off;

  /*****************************************************************************
  ** Table Definition
  ******************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_interface_list
    Author   : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
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
drop table ods.qu2_interface_list cascade constraints;

create table ods.qu2_interface_list (
  q4x_interface_name              varchar2(32 char)               not null, -- LICS Limit
  q4x_entity_name                 varchar2(64 char)               not null,
  q4x_table_name                  varchar2(30 char)               not null -- Oracle Limit
);

-- Constraints and Checks
alter table ods.qu2_interface_list add constraint qu2_interface_list_pk primary key (q4x_interface_name)
  using index (create unique index qu2_interface_list_pk on ods.qu2_interface_list(q4x_interface_name));

alter table ods.qu2_interface_list add constraint qu2_interface_list_entity_uk unique (q4x_entity_name)
  using index (create unique index qu2_interface_list_entity_uk on ods.qu2_interface_list(q4x_entity_name));

alter table ods.qu2_interface_list add constraint qu2_interface_list_table_uk unique (q4x_table_name)
  using index (create unique index qu2_interface_list_table_uk on ods.qu2_interface_list(q4x_table_name));

alter table ods.qu2_interface_list add constraint qu2_interface_list_int_ck check (q4x_interface_name = upper(q4x_interface_name));

alter table ods.qu2_interface_list add constraint qu2_interface_list_entity_ck check (q4x_entity_name = upper(q4x_entity_name));

alter table ods.qu2_interface_list add constraint qu2_interface_list_table_ck check (q4x_table_name = upper(q4x_table_name));

-- Comments
comment on table ods.qu2_interface_list is'Quofore Interface Control : Interface / Entity / Table List';
comment on column ods.qu2_interface_list.q4x_interface_name is'Primary Key - Interface Name - MUST BE UPPERCASE';
comment on column ods.qu2_interface_list.q4x_entity_name is'Unique Key - Entity Name - MUST BE UPPERCASE';
comment on column ods.qu2_interface_list.q4x_table_name is'Unique Key - Table Name - MUST BE UPPERCASE';

-- Synonyms
create or replace public synonym qu2_interface_list for ods.qu2_interface_list;

-- Grants
grant select,insert,update,delete on ods.qu2_interface_list to ods_app;
grant select on ods.qu2_interface_list to dds_app, qv_user, bo_user;

-- Populate Table ..

insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW00','DIGEST','QU2_DIGEST');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW01','HIERARCHY','QU2_HIER');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW02','GENERALLIST','QU2_GENERAL_LIST');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW03','ROLE','QU2_ROLE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW04','POSITION','QU2_POS');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW05','REP','QU2_REP');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW06','REPADDRESS','QU2_REP_ADDRS');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW07','PRODUCT','QU2_PROD');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW08','PRODUCTBARCODE','QU2_PROD_BARCODE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW09','CUSTOMER','QU2_CUST');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW10','CUSTOMERADDRESS','QU2_CUST_ADDRS');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW11','CUSTOMERNOTE','QU2_CUST_NOTE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW12','CUSTOMERCONTACT','QU2_CUST_CONTACT');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW13','CUSTOMERVISITORDAY','QU2_CUST_VISIT_DAY');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW14','ASSORTMENTDETAIL','QU2_ASSORT_DTL');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW15','CUSTOMERASSORTMENTDETAIL','QU2_CUST_ASSORT_DTL');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW16','PRODUCTASSORTMENTDETAIL','QU2_PROD_ASSORT_DTL');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW17','AUTHORISEDLISTPRODUCT','QU2_AUTH_LIST_PROD');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW18','APPOINTMENT','QU2_APPOINT');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW19','CALLCARD','QU2_CALLCARD');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW20','CALLCARDNOTE','QU2_CALLCARD_NOTE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW21','ORDERHEADER','QU2_ORD_HDR');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW22','ORDERDETAIL','QU2_ORD_DTL');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW23','TERRITORY','QU2_TERR');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW24','CUSTOMERTERRITORY','QU2_CUST_TERR');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW25','POSITIONTERRITORY','QU2_POS_TERR');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW26','SURVEY','QU2_SURVEY');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW27','SURVEYQUESTION','QU2_SURVEY_QUESTION');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW28','RESPONSEOPTION','QU2_RESPONSE_OPT');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW29','TASK','QU2_TASK');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW30','TASKASSIGNMENT','QU2_TASK_ASSIGN');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW31','TASKCUSTOMER','QU2_TASK_CUST');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW32','TASKPRODUCT','QU2_TASK_PROD');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW33','TASKSURVEY','QU2_TASK_SURVEY');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW34','ACTIVITYHEADER','QU2_ACT_HDR');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW35','ACTIVITYDETAILALOC','QU2_ACT_DTL_A_LOC');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW38','ACTIVITYDETAILSELLIN','QU2_ACT_DTL_SELL_IN');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW39','ACTIVITYDETAILOFFLOCATION','QU2_ACT_DTL_OFF_LOC');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW40','ACTIVITYDETAILFACING','QU2_ACT_DTL_FACING');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW41','ACTIVITYDETAILCHECKOUTSTD','QU2_ACT_DTL_CHECKOUT');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW42','ACTIVITYDETAILCHECKOUTEXPRESSQZ','QU2_ACT_DTL_EXPRESS_Q');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW43','ACTIVITYDETAILCHECKOUTEXPRESS','QU2_ACT_DTL_EXPRESS');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW44','ACTIVITYDETAILCHECKOUTSELFSCANQZ','QU2_ACT_DTL_SELFSCAN_Q');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW45','ACTIVITYDETAILCHECKOUTSELFSCAN','QU2_ACT_DTL_SELFSCAN');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW46','ACTIVITYDETAILLOCOOS','QU2_ACT_DTL_LOC_OOS');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW47','ACTIVITYDETAILPERMDISPLAY','QU2_ACT_DTL_PERM_DISP');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW48','SURVEYANSWER','QU2_SURVEY_ANSWER');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW49','GRAVEYARD','QU2_GRAVEYARD');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW50','ACTIVITYDETAILFACINGAISLE','QU2_ACT_DTL_FACE_AISLE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW51','ACTIVITYDETAILFACINGEXPRESS','QU2_ACT_DTL_FACE_EXPRE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW52','ACTIVITYDETAILFACINGSELFSCAN','QU2_ACT_DTL_FACE_SELFS');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW53','ACTIVITYDETAILFACINGSTANDARD','QU2_ACT_DTL_FACE_STAND');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW54','ACTIVITYDETAILCOMPETITIONACT','QU2_ACT_DTL_COMP_ACT');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW55','ACTIVITYDETAILCOMPETITIONFACINGS','QU2_ACT_DTL_COMP_FACE');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW56','ACTIVITYDETAILEXECCOMPLIANCE','QU2_ACT_DTL_EXEC_COMPL');
insert into qu2_interface_list (q4x_interface_name,q4x_entity_name,q4x_table_name) values ('QU2CDW99','*ALL','QU2_INTERFACE_LIST');
commit;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
