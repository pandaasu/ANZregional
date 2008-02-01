
/**/
/* Sequence creation
/**/
create sequence sap_trace_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on sap_trace_sequence to ods_app;

/**/
/* Synonym
/**/
create public synonym sap_trace_sequence for ods.sap_trace_sequence;
