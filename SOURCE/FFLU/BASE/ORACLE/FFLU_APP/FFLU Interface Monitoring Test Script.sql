-- Call to monitor a currently running lics interface.
select * from table(fflu_api.load_monitor(
  'HORNCHR', -- i_user_code in varchar2
  38));

begin
  fflu_common.load_execute;
end;

-- Call to monitor a currently running lics interface.
select * from table(fflu_api.lics_monitor(
  'HORNCHR', -- i_user_code in varchar2
  2033273));

-- Call to fetch the types of status descriptions and codes.
select * from table(fflu_api.get_xaction_status_list());

-- Call to fetch the number of records for the current filter criteria.
declare
  v_count fflu_common.st_size;
begin
  v_count := fflu_api.get_xaction_count(
    'HORNCHR', -- i_user_code in varchar2
    'LAWS_OF_GROWTH', -- interface_group_code in varchar2,
    null, -- i_interface_code in varchar2, 
    null, -- i_interface_type_code in varchar2, 
    null, -- i_xaction_seq in fflu_common.st_sequence,
    '7', -- i_xaction_status_code in fflu_common.st_status,
    null, -- i_start_datetime in date,
    null -- i_end_datetime in date
    );
  dbms_output.put_line('Filer Count : ' || v_count);
end;

-- Call to fetch the current page of interface data to be displayed.  
select * from table(fflu_api.get_xaction_list(
    'HORNCHR', -- i_user_code in varchar2
    'EFXCDW_INBOUND', -- interface_group_code in varchar2,
    null, -- i_interface_code in varchar2, 
    null, -- i_interface_type_code in varchar2, 
    null, -- i_xaction_seq in fflu_common.st_sequence,
    null, -- i_xaction_status_code in fflu_common.st_status,
    null, -- i_start_datetime in date,
    null, -- i_end_datetime in date,
    1, -- i_start_row in fflu_common.st_count,
    10 -- i_no_rows in fflu_common.st_count
));


-- Call to fetch the other trace executions that have been run for this 
-- interface
select * from table(fflu_api.get_xaction_trace_list(
  'HORNCHR', -- i_user_code in varchar2
  2037672));


-- Call to return the data rows of an interface and the number of errors for each row for a given trace.
select * from table(fflu_api_dev.get_xaction_data(
  'HORNCHR', -- i_user_code in varchar2
  2032647, -- i_xaction_seq in fflu_common.st_sequence,
  3, -- i_xaction_trace_seq in fflu_common.st_trace,
  1, -- i_start_row in fflu_common.st_count,
  2 -- i_no_rows in fflu_common.st_count
));


-- Call to return all the header error messages by interface.
select * from table(fflu_api_dev.get_xaction_errors(
  'HORNCHR', -- i_user_code in varchar2
  2032620, -- i_xaction_seq in fflu_common.st_sequence,
  2 -- i_xaction_trace_seq in fflu_common.st_trace,
  ));

-- Call to return a page of data rows that contain errors. 
select * from table (fflu_api_dev.get_xaction_data_with_errors(
  'HORNCHR', -- i_user_code in varchar2
  2032878, -- i_xaction_seq in fflu_common.st_sequence,
  2, -- i_xaction_trace_seq in fflu_common.st_trace,
  1, -- i_start_row in fflu_common.st_count,
  2 -- i_no_rows in fflu_common.st_count) 
));

-- Call to return all the errors that would belong on a page of data rows. 
select * from table (fflu_api_dev.get_xaction_data_errors_by_pge(
  'HORNCHR', -- i_user_code in varchar2
  2032878, -- i_xaction_seq in fflu_common.st_sequence,
  2, -- i_xaction_trace_seq in fflu_common.st_trace,
  1, -- i_from_data_row fflu_common.st_count,
  500 -- i_to_data_row fflu_common.st_count
));

-- Call to return all the errors that would belong on a page of data rows. 
select * from table (fflu_api.get_xaction_data_errors_by_row(
  'HORNCHR', -- i_user_code in varchar2
  2036722, -- i_xaction_seq in fflu_common.st_sequence,
  20, -- i_xaction_trace_seq in fflu_common.st_trace,
  1, -- i_from_data_row fflu_common.st_count,
  2 -- i_to_data_row fflu_common.st_count
));







