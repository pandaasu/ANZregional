/**
 * System : ISI Utility
 * Type   : Class
 * Name   : InvokerTest
 * Author : Steve Gregan
 * Date   : January 2004
 */
package com.isi.utility;
import java.sql.*;

/**
 * This class implements the stream reader functionality.
 * This facility supports the execution of external operating
 * system commands and scripts. Standard in and error are wrapped
 * and raised as an exception the the calling procedure. The
 * assumption is made that this is always executed from inside oracle.
 */
public final class InvokerTest {
   
   /**
    * SQL constants
    */
   public static final String SYSTEM_CONTEXT =
      "select 'CURRENT_SCHEMA: [' || sys_context('USERENV','CURRENT_SCHEMA') || " +
      "'] CURRENT_USER: [' || sys_context('USERENV','CURRENT_USER') ||" +
      "'] SESSION_USER: [' || sys_context('USERENV','SESSION_USER') ||" +
      "'] PROXY_USER: ' || sys_context('USERENV','PROXY_USER') || ']' from dual";

   /**
    * Executes the invoker test
    * 
    * @return String the context variables
    */
   public static String execute() throws Exception {
      
      //
      // Local variables
      //
      PreparedStatement objStatement;
      ResultSet objResultSet;
      String strReturn;
      
      //
      // Create the oracle default connection
      //
      Connection objConnection = new oracle.jdbc.OracleDriver().defaultConnection();
      objConnection.setAutoCommit(false);
      
      //
      // Retrieve and return the context information
      //
      objStatement = objConnection.prepareStatement(SYSTEM_CONTEXT);
      objResultSet = objStatement.executeQuery();
      objResultSet.next();
      strReturn = objResultSet.getString(1);
      objResultSet.close();
      objStatement.close();
      
      //
      // Close the connection
      //
      objConnection.close();
      
      //
      // Return the value
      //
      return strReturn;

   }

}
