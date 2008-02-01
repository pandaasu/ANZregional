/**
 * Package : ISI BOSS
 * Type    : Class
 * Name    : cOracleExec
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss.agent;
import com.isi.boss.iAgent;
import java.util.*;
import java.sql.*;

/**
 * This class implements the oracle database execute agent.
 */
public final class cOracleExec implements iAgent {
   
   /**
    * Implements the iAgent interface retrieve method
    */
   public String retrieve(HashMap objAttributes) throws Exception {
      StringBuffer strBuffer = new StringBuffer();
      Connection objOracleConnection = null;
      PreparedStatement objOracleStatement = null;
      ResultSet objOracleResultset = null;
      try {
         DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
         objOracleConnection = DriverManager.getConnection((String)objAttributes.get("CONNECTION"), (String)objAttributes.get("USER"), (String)objAttributes.get("PASSWORD"));
         objOracleConnection.setAutoCommit(false);
         objOracleStatement = objOracleConnection.prepareStatement("select * from table(boss_app.boss_collector.get_output('" + (String)objAttributes.get("PROCEDURE") + "'))");
         objOracleResultset = objOracleStatement.executeQuery();
         while (objOracleResultset.next()) {
            strBuffer.append(objOracleResultset.getString(1));
         }
      } catch(Exception objException) {
         throw objException;
      } finally {
         if (objOracleResultset != null) {
            objOracleResultset.close();
         }
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         if (objOracleConnection != null) {
            objOracleConnection.close();
         }
         objOracleResultset = null;
         objOracleStatement = null;
         objOracleConnection = null;
      }
      return strBuffer.toString();
   }

}