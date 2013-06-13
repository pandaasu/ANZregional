-- Test loading an interface.
declare
  v_clob_data nclob;
  v_data varchar2(4000 byte);
  v_load_seq fflu_common.st_sequence;
begin
  -- Test Creating an Interface Header.
  v_load_seq := fflu_api.load_start('HORNCHR','CHRISTEST','My File Name');
  SYS.dbms_output.put_line('Load Sequence : ' || v_load_seq);
  -- Now load a segment
  v_data := 'THIS IS MY LINE TEST' || CHR(10) || CHR(10) || 'More Data' || CHR(10) || 'ûÞ' || CHR(10);
  v_clob_data := to_clob(v_data);
  fflu_api.load_segment(v_load_seq,'HORNCHR','CHRISTEST','My File Name',1,lengthb(v_data),4,v_clob_data);
  fflu_api.load_segment(v_load_seq,'HORNCHR','CHRISTEST','My File Name',2,lengthb(v_data),4,v_clob_data);
  fflu_api.load_complete(v_load_seq,'HORNCHR','CHRISTEST','My File Name',2,8);
end;




SELECT * FROM FFL_LOAD_HEADER


select t1.*, length(data_record), lengthb(data_record) from fflu_load_data t1

-- Test cancelling an interface
declare
begin
  -- Test Creating an Interface Header.
  fflu_api_dev.load_cancel(5,'HORNCHR','CHRISTEST','My File Name');
end;

declare
begin
  fflu_api_dev.load_execute();
end;

select * from fflu_load_header order by load_seq desc

-- Test the load Monitoring Function
select * from table (fflu_api.load_monitor(1));

update fflu_load_header set row_count_tran = null where load_seq = 27;

commit;
