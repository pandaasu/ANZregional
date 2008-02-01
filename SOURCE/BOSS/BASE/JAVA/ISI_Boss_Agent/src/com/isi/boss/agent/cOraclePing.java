/**
 * Package : ISI BOSS
 * Type    : Class
 * Name    : cOraclePing
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss.agent;
import com.isi.boss.iAgent;
import java.util.*;
import java.sql.*;

/**
 * This class implements the oracle database ping agent.
 */
public final class cOraclePing implements iAgent {
   
   /**
    * Implements the iAgent interface retrieve method
    */
   public String retrieve(HashMap objAttributes) throws Exception {
      String strValue = "*ON";
      String strAlert = "*NO";
      Connection objOracleConnection = null;
      try {
         DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
         objOracleConnection = DriverManager.getConnection((String)objAttributes.get("CONNECTION"), (String)objAttributes.get("USER"), (String)objAttributes.get("PASSWORD"));
      } catch(SQLException objException) {
         if (objException.getErrorCode() != 1017) {
            strValue = "*OFF";
            strAlert = "*YES";
         }
      } finally {
         if (objOracleConnection != null) {
            objOracleConnection.close();
         }
         objOracleConnection = null;
      }
      return "<?xml version='1.0'?><boss_data><measure code='STATUS' parent='*TOP' type='*SWITCH' alert='" + strAlert + "'><value><![CDATA[" + strValue + "]]></value><text><![CDATA[Database State]]></text></measure></boss_data>";
   }

}