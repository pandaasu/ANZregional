/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_recipe_sequence
 Owner   : bds
 Author  : Steve Gregan

*******************************************************************************/

/**/
/* Sequence creation
/**/
create sequence bds_recipe_sequence
   increment by 1
   start with 1
   maxvalue 99999999999
   minvalue 1
   nocycle
   nocache;


/**/
/* Authority
/**/
grant select on bds_recipe_sequence to bds_app;


/**/
/* Synonym
/**/
create public synonym bds_recipe_sequence for bds.bds_recipe_sequence;

create sequence recipe_bom_id_seq
   increment by 1
   start with 1
   maxvalue 99999999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence recipe_resource_id_seq
   increment by 1
   start with 1
   maxvalue 99999999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence recipe_src_text_id_seq
   increment by 1
   start with 1
   maxvalue 99999999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence recipe_src_value_id_seq
   increment by 1
   start with 1
   maxvalue 99999999999999999999
   minvalue 1
   nocycle
   nocache;

grant select on recipe_bom_id_seq to bds_app;
grant select on recipe_resource_id_seq to bds_app;
grant select on recipe_src_text_id_seq to bds_app;
grant select on recipe_src_value_id_seq to bds_app;

create or replace public synonym recipe_bom_id_seq for bds.recipe_bom_id_seq;
create or replace public synonym recipe_resource_id_seq for bds.recipe_resource_id_seq;
create or replace public synonym recipe_src_text_id_seq for bds.recipe_src_text_id_seq;
create or replace public synonym recipe_src_value_id_seq for bds.recipe_src_value_id_seq;
