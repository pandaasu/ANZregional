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
