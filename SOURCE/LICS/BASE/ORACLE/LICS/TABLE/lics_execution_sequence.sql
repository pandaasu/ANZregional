/**/
/* Sequence creation
/**/
create sequence lics_execution_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on lics_execution_sequence to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_execution_sequence for lics.lics_execution_sequence;