/**/
/* Sequence creation
/**/
create sequence lics_event_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on lics_event_sequence to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_event_sequence for lics.lics_event_sequence;