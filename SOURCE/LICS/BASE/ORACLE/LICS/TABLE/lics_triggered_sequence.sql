/**/
/* Sequence creation
/**/
create sequence lics_triggered_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on lics_triggered_sequence to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_triggered_sequence for lics.lics_triggered_sequence;
