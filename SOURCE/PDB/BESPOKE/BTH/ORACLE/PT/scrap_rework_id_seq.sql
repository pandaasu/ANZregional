create sequence pt.scrap_rework_id_seq
  start with 1
  maxvalue 999999999999999999999999999
  minvalue 1
  nocycle
  nocache
  noorder;

/**/
/* authority 
/**/
grant select on pt.scrap_rework_id_seq to pt_app;

/**/
/* synonym 
/**/
create or replace public synonym scrap_rework_id_seq for pt.scrap_rework_id_seq;