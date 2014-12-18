create or replace and compile java source named "JdbcConnect" as
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
