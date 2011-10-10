/**
 * System : ISI Utility
 * Type   : Class
 * Name   : Documentation
 * Author : Steve Gregan
 * Date   : January 2004
 */
package com.isi.utility;
import java.io.*;
import java.util.*;
import java.sql.*;
import oracle.jdbc.driver.*;

/**
 * This class implements the documentation facility.
 * This facility supports the retrieval of source and documentation from
 * the Oracle meta data. The assumption is made that this is always executed
 * from inside the oracle instance.
 */
public final class Documentation {
   
   /**
    * Retrieves Oracle view source
    * 
    * @param strOwner the owner of the view
    * @param strName the name of the view
    * @return void
    * @exception Exception the exceptions
    */
   public static void retrieveViewSource(String strOwner, String strName) throws Exception {
      
      //
      // Local variables
      //
      PreparedStatement objStatement = null;
      ResultSet objResultSet = null;
      String RETRIEVE_SOURCE =
         "select" +
         " text" +
         " from dba_views" +
         " where owner = ?" +
         " and view_name = ?";
      String DELETE_TEMP =
         "delete from lics_temp";
      String INSERT_TEMP =
         "insert into lics_temp" +
         " (dat_dta_seq," +
         " dat_record)" +
         " values(?, ?)";
      
      //
      // Retrieve the default connection
      //
      Connection objConnection = new OracleDriver().defaultConnection();
      objConnection.setAutoCommit(false);

      //
      // Exceptions trap
      //
      try {
         
         //
         // Delete the current lics_temp session rows
         //
         objStatement = objConnection.prepareStatement(DELETE_TEMP);
         objStatement.executeUpdate();
         objStatement.close();
         objStatement = null;
         
         //
         // Retrieve the view source from dba_views and load to an array list
         //
         ArrayList objSource = new ArrayList();
         objStatement = objConnection.prepareStatement(RETRIEVE_SOURCE);
         objStatement.setString(1, strOwner.toUpperCase());
         objStatement.setString(2, strName.toUpperCase());
         objResultSet = objStatement.executeQuery();
         if (objResultSet.next()) {
            String strData = null;
            BufferedReader objReader = new BufferedReader(objResultSet.getCharacterStream(1));
            while((strData = objReader.readLine()) != null) {
               if (!strData.equals("")) {
                  objSource.add(strData + "\r\n");
               }
            }
            objReader.close();
         }
         objResultSet.close();
         objStatement.close();
         objResultSet = null;
         objStatement = null;
         
         //
         // Insert the new lics_temp session rows
         //
         if (objSource.size() != 0) {
            objStatement = objConnection.prepareStatement(INSERT_TEMP);
            for (int i=0;i<objSource.size();i++) {
               objStatement.setInt(1, i+1);
               objStatement.setString(2, (String)objSource.get(i));
               objStatement.executeUpdate();
            }
            objStatement.close();
            objStatement = null;
         }

         //
         // Commit the database
         //
         objConnection.commit();

      } catch(Exception objException) {
         objConnection.rollback();
         throw objException;
         
      } finally {
         if (objResultSet != null) {
            objResultSet.close();
         }
         if (objStatement != null) {
            objStatement.close();
         }
      }

   }
   
   /**
    * Retrieves Oracle PL/SQL source documentation
    * 
    * @param strOwner the owner of the source
    * @param strName the name of the source
    * @param strType the type of the source
    * @return void
    * @exception Exception the exceptions
    */
   public static void retrieveDocumentation(String strOwner, String strName, String strType) throws Exception {
      
      //
      // Local variables
      //
      PreparedStatement objStatement = null;
      ResultSet objResultSet = null;
      String RETRIEVE_SOURCE =
         "select" +
         " text" +
         " from all_source" +
         " where owner = ?" +
         " and name = ?" +
         " and type = ?" +
         " order by line asc";
      String DELETE_TEMP =
         "delete from lics_temp";
      String INSERT_TEMP =
         "insert into lics_temp" +
         " (dat_dta_seq," +
         " dat_record)" +
         " values(?, ?)";
      
      //
      // Retrieve the default connection
      //
      Connection objConnection = new OracleDriver().defaultConnection();
      objConnection.setAutoCommit(false);

      //
      // Exceptions trap
      //
      try {
         
         //
         // Delete the current lics_temp session rows
         //
         objStatement = objConnection.prepareStatement(DELETE_TEMP);
         objStatement.executeUpdate();
         objStatement.close();
         objStatement = null;
         
         //
         // Retrieve the source documentation from dba_source and load to an array list
         //
         ArrayList objDocumentation = new ArrayList();
         boolean bolComment = false;
         objStatement = objConnection.prepareStatement(RETRIEVE_SOURCE);
         objStatement.setString(1, strOwner.toUpperCase());
         objStatement.setString(2, strName.toUpperCase());
         objStatement.setString(3, strType.toUpperCase());
         objResultSet = objStatement.executeQuery();
         while (objResultSet.next()) {
            String strData = objResultSet.getString(1);
            if (strData == null || strData.equals("")) {
               strData = " ";
            }
            if (strData.trim().equals("/*<DOCUMENTATION>")) {
               bolComment = true;
            } else if (strData.trim().equals("</DOCUMENTATION>*/")) {
               bolComment = false;
            } else if (bolComment) {
               objDocumentation.add(strData);
            }
         }
         objResultSet.close();
         objStatement.close();
         objResultSet = null;
         objStatement = null;
         
         //
         // Insert the new lics_temp session rows
         //
         if (objDocumentation.size() != 0) {
            objStatement = objConnection.prepareStatement(INSERT_TEMP);
            for (int i=0;i<objDocumentation.size();i++) {
               objStatement.setInt(1, i+1);
               objStatement.setString(2, (String)objDocumentation.get(i));
               objStatement.executeUpdate();
            }
            objStatement.close();
            objStatement = null;
         }

         //
         // Commit the database
         //
         objConnection.commit();

      } catch(Exception objException) {
         objConnection.rollback();
         throw objException;
         
      } finally {
         if (objResultSet != null) {
            objResultSet.close();
         }
         if (objStatement != null) {
            objStatement.close();
         }
      }

   }
   
}