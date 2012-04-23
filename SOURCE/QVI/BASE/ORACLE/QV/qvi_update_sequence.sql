/**/
/* Sequence creation
/**/

create sequence qvi_update_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on qvi_update_sequence to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym qvi_update_sequence for qv.qvi_update_sequence;
