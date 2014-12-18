create or replace package body jdbc_connect as

  function jdbc_select_private (
    i_driver_class in varchar2,
    i_connection_string in varchar2,
    i_username in varchar2,
    i_password in varchar2,
    i_sql_string in varchar2
  ) return tt_jdbc_connect
  is language java name 'JdbcConnect.JdbcSelect(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.sql.Array';

  function jdbc_select(
    i_connection_name in varchar2,
    i_sql_string in varchar2
  ) return tt_output pipelined 
  is
    v_array tt_jdbc_connect := tt_jdbc_connect();
    rv_jdbc_connect_config jdbc_connect_config%rowtype;
    v_output rt_output;
  begin
  
    select * into rv_jdbc_connect_config from jdbc_connect_config where connection_name = i_connection_name;
    
    v_array := jdbc_connect.jdbc_select_private(
      rv_jdbc_connect_config.driver_class,
      rv_jdbc_connect_config.connection_string,
      rv_jdbc_connect_config.username,
      rv_jdbc_connect_config.password,
      i_sql_string
    );
    for i in 1..v_array.count loop
      v_output.output_record := v_array(i);
      pipe row(v_output);
    end loop;
  end;
  
end jdbc_connect;
/