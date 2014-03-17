prompt :: Compile Package [jdbc_connect] ::::::::::::::::::::::::::::::::::::::::::::::

/*******************************************************************************
/* Package Definition
/*******************************************************************************

 System  : df_app
 Package : jdbc_connect
 Owner   : df_app
 Author  : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 JDBC Connection Utility Package

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-05   Mal Chambeyron         Created

*******************************************************************************/

create or replace type df_app.tt_jdbc_connect as table of varchar2(512);
/

create or replace and compile java source named "JdbcConnect" as
  import java.sql.*;
  import java.util.*;
  import oracle.jdbc.driver.*;
  import oracle.sql.*;
 
  public class JdbcConnect {
  
    private static Connection getJdbcConnection(
      String driverClass,
      String connectionString,
      String username,
      String password
    ) throws SQLException, ClassNotFoundException {
      Connection dbConnection = null;
      Class.forName(driverClass);
      dbConnection = DriverManager.getConnection(connectionString, username, password);
      return dbConnection;
    }
    
    public static java.sql.Array arrayWrapper(
      String typeName,
      Object stringArray
    ) throws java.sql.SQLException {
      oracle.jdbc.OracleDriver ora = new oracle.jdbc.OracleDriver();
      java.sql.Connection conn = ora.defaultConnection();
      oracle.jdbc.OracleConnection oraConn = (oracle.jdbc.OracleConnection)conn;
      java.sql.Array arr = oraConn.createARRAY(typeName.toUpperCase(), stringArray);
      return arr;
    }
    
    public static java.sql.Array JdbcSelect(
      String driverClass,
      String connectionString,
      String username,
      String password,
      String sqlString
    ) throws SQLException, ClassNotFoundException, Exception {
    
      if (sqlString.toLowerCase().contains("update") || sqlString.toLowerCase().contains("delete")) {
        throw new Exception("SQL Cannot Contain Text [UPDATE] or [DELETE]: [" + sqlString + "]"); 
      }
        
      Connection connection = getJdbcConnection(
        driverClass,
        connectionString,
        username,
        password
      );
      Statement statement = connection.createStatement();
      ResultSet resultSet = statement.executeQuery(sqlString);
      ArrayList<String> stringArrayList = new ArrayList<String>();
      while (resultSet.next()) {
        stringArrayList.add(resultSet.getString("OUTPUT_RECORD"));
      }
      resultSet.close();
      statement.close();
      connection.close();
      String[] stringArray = new String[stringArrayList.size()];
      stringArray = stringArrayList.toArray(stringArray);      
      return arrayWrapper("TT_JDBC_CONNECT", stringArray);      
    }
    
  }
/

show errors;

create or replace package df_app.jdbc_connect as
/*******************************************************************************
/* Package Definition
/*******************************************************************************

 System  : df_app
 Package : jdbc_connect
 Owner   : df_app
 Author  : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 JDBC Connection Utility Package

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2014-02-05   Mal Chambeyron         Created

*******************************************************************************/

  type rt_output is record (
    output_record                   varchar2(512)
  );

  type tt_output is table of rt_output;
 
  function jdbc_select( 
    i_connection_name in varchar2,
    i_sql_string in varchar2
  ) return tt_output pipelined;
  
end jdbc_connect;
/

create or replace package body df_app.jdbc_connect as

  function jdbc_select_private(
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
    vr_jdbc_connect_config jdbc_connect_config%rowtype;
    v_output rt_output;
  begin
  
    select * into vr_jdbc_connect_config from jdbc_connect_config where connection_name = i_connection_name;
    
    v_array := jdbc_connect.jdbc_select_private(
      vr_jdbc_connect_config.driver_class,
      vr_jdbc_connect_config.connection_string,
      vr_jdbc_connect_config.username,
      vr_jdbc_connect_config.password,
      i_sql_string
    );
    for i in 1..v_array.count loop
      v_output.output_record := v_array(i);
      pipe row(v_output);
    end loop;
  end;
  
end jdbc_connect;
/

grant execute on df_app.jdbc_connect to lics_app, fflu_app;

