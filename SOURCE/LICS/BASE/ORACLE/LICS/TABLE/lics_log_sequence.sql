/**/
/* Sequence creation
/**/

create sequence lics_log_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on lics_log_sequence to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_log_sequence for lics.lics_log_sequence;
