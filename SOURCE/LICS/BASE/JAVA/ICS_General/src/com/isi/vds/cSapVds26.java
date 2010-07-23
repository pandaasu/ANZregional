/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVds26
 * Author  : Steve Gregan
 * Date    : July 2010
 */
package com.isi.vds;
import com.isi.sap.*;
import java.util.*;
import java.text.*;
import java.io.*;
import java.sql.*;

/**
 * This class implements the SAP packaging instruction extract functionality. This functionality retrieves
 * SAP packaging instructions data based on supplied filters and then extracts the required packaging
 * instruction data for all materials.
 */
public final class cSapVds26 implements iSapVdsExtract {
   
   //
   // Declare the class variable
   //
   cSapConnection cobjSapConnection = null;
   Connection cobjOracleConnection = null;
   String cstrDatReplace;
   int cintDatCount;
   String cstrSapClient;
   String cstrSapUserId;
   String cstrSapPassword;
   String cstrSapLanguage;
   String cstrSapServer;
   String cstrSapSystem;
   String cstrVdsConnection;
   String cstrVdsUserId;
   String cstrVdsPassword;
   String cstrKOTP505Filter;
   String cstrVdsQuery;
   String cstrVdsKOTP505Columns;
   String cstrVdsKONDPColumns;
   String cstrVdsPACKPOColumns;
   String cstrLogging = null;
   PrintWriter cobjPrintWriter;
   
   /**
    * Processes the SAP to VDS packaging instruction extract.
    * @throws Exception the exception message
    */
   public void process(HashMap objParameters, String strReplace) throws Exception {
      
      //
      // Initialise the class variables
      //
      cobjSapConnection = null;
      cobjOracleConnection = null;
      cstrLogging = null;
      
      //
      // Retrieve any interface specific parameters
      //
      if (strReplace == null || strReplace.equals("") || strReplace.length() < 5) {
         cstrDatReplace = "*FULL";
         cintDatCount = 1000;
      } else if (strReplace.length() == 5) {
         cstrDatReplace = strReplace.substring(0,5);
         cintDatCount = 1000;
      } else {
         cstrDatReplace = strReplace.substring(0,5);
         try {
            cintDatCount = Integer.parseInt(strReplace.substring(5));
         } catch(Throwable objThrowable) {
            cintDatCount = 1000;
         }
      }
      if (!cstrDatReplace.equals("*META") && !cstrDatReplace.equals("*FULL")) {
         cstrDatReplace = "*FULL";
      }
      cstrSapClient = (String)objParameters.get("SAPCLIENT");
      cstrSapUserId = (String)objParameters.get("SAPUSERID");
      cstrSapPassword = (String)objParameters.get("SAPPASSWORD");
      cstrSapLanguage = (String)objParameters.get("SAPLANGUAGE");
      cstrSapServer = (String)objParameters.get("SAPSERVER");
      cstrSapSystem = (String)objParameters.get("SAPSYSTEM");
      cstrVdsConnection = (String)objParameters.get("VDSCONNECTION");
      cstrVdsUserId = (String)objParameters.get("VDSUSERID");
      cstrVdsPassword = (String)objParameters.get("VDSPASSWORD");
      cstrKOTP505Filter = (String)objParameters.get("KOTP505_FILTER");
      cstrVdsQuery = (String)objParameters.get("VDS_QUERY");
      cstrVdsKOTP505Columns = (String)objParameters.get("VDS_KOTP505_COLUMNS");
      cstrVdsKONDPColumns = (String)objParameters.get("VDS_KONDP_COLUMNS");
      cstrVdsPACKPOColumns = (String)objParameters.get("VDS_PACKPO_COLUMNS");
      cstrLogging = (String)objParameters.get("LOGGING");
      if (cstrSapClient == null) {
         throw new Exception("VDS Packaging Instruction Extract - SAP connection client not supplied in configuration file");
      }
      if (cstrSapUserId == null) {
         throw new Exception("VDS Packaging Instruction Extract - SAP connection user id not supplied in configuration file");
      }
      if (cstrSapPassword == null) {
         throw new Exception("VDS Packaging Instruction Extract - SAP connection password not supplied in configuration file");
      }
      if (cstrSapLanguage == null) {
         throw new Exception("VDS Packaging Instruction Extract - SAP connection language not supplied in configuration file");
      }
      if (cstrSapServer == null) {
         throw new Exception("VDS Packaging Instruction Extract - SAP connection server not supplied in configuration file");
      }
      if (cstrSapSystem == null) {
         throw new Exception("VDS Packaging Instruction Extract - SAP connection system not supplied in configuration file");
      }
      if (cstrVdsConnection == null) {
         throw new Exception("VDS Packaging Instruction Extract - VDS connection string not supplied in configuration file");
      }
      if (cstrVdsUserId == null) {
         throw new Exception("VDS Packaging Instruction Extract - VDS user id not supplied in configuration file");
      }
      if (cstrVdsPassword == null) {
         throw new Exception("VDS Packaging Instruction Extract - VDS password not supplied in configuration file");
      }
      if (cstrKOTP505Filter == null) {
         throw new Exception("VDS Packaging Instruction Extract - KOTP505 filter not supplied in configuration file");
      }
      if (cstrVdsQuery == null || cstrVdsQuery.toUpperCase().equals("*NONE")) {
         throw new Exception("VDS Packaging Instruction Extract - VDS query must be supplied");
      }
      if (cstrVdsKOTP505Columns == null) {
         cstrVdsKOTP505Columns = "*";
      }
      if (cstrVdsKONDPColumns == null) {
         cstrVdsKONDPColumns = "*";
      }
      if (cstrVdsPACKPOColumns == null) {
         cstrVdsPACKPOColumns = "*";
      }
      if (cstrLogging != null) {
         cobjPrintWriter = new PrintWriter(new FileWriter(cstrLogging, false));
      }
      
      //
      // Start log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.print("Start VDS Packaging Instruction Extract ("+strReplace+") becomes ("+cstrDatReplace+" / "+cintDatCount+") : " + Calendar.getInstance().getTime()); 
         cobjPrintWriter.flush();
      }
      
      //
      // Monitor exceptions
      //
      try {

         //////////////////////////////////////////
         // Step 1 - Connect to the ODS database //
         //////////////////////////////////////////
         
         //
         // Create an Oracle thin JDBC connection
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("==> Start VDS Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         try {
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
            cobjOracleConnection = DriverManager.getConnection(cstrVdsConnection, cstrVdsUserId, cstrVdsPassword);
            cobjOracleConnection.setAutoCommit(false);
         } catch(Exception objException) {
            throw new Exception("VDS Oracle connection failed - " + objException.getMessage());
         }
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("==> End VDS Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         ///////////////////////////////////////////
         // Step 2 - Perform the required extract //
         ///////////////////////////////////////////
         
         if (cstrDatReplace.equals("*META")) {
            extractMeta();
         } else {
            extractData();
         }
         
      } catch(Exception objException) {
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("VDS Packaging Instruction Extract - " + objException.getMessage());
            cobjPrintWriter.close();
         }
         throw new Exception("VDS Packaging Instruction Extract - " + objException.getMessage());
      } finally {
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
         if (cobjOracleConnection != null) {
            cobjOracleConnection.close();
         }
         cobjOracleConnection = null;
      }
      
      //
      // End log
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("End VDS Packaging Instruction Extract: " + Calendar.getInstance().getTime());
         cobjPrintWriter.close();
      }
         
   }
   
   /**
    * Processes the meta request.
    * @throws Exception the exception message
    */
   private void extractMeta() throws Exception {
      
      cSapSingleQuery objSapSingleQuery = null;
      CallableStatement objOracleStatement = null;
      ArrayList objWorkDATA = null;
      String[] strKNUMH = null;
      String[] strPACKNR = null;
 
      //
      // Set the packaging instruction condition array from the work array
      //
      strKNUMH = new String[]{"KNUMH = '0'"};
      strPACKNR = new String[]{"PACKNR = '0'"};
      
      //
      // Start MPKG meta retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Meta Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // Exception trap
      //
      try {
         
         //
         // SAP connection
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start SAP Connection: " + Calendar.getInstance().getTime()); 
            cobjPrintWriter.flush();
         }
         try {
            cobjSapConnection =  new cSapConnection(cstrSapClient, cstrSapUserId, cstrSapPassword, cstrSapLanguage, cstrSapServer, cstrSapSystem);
         } catch(Exception objException) {
            throw new Exception("SAP Connection failed - " + objException.getMessage());
         }
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End SAP Connection: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         //
         // VDS start meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start vds_extract.start_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.start_meta(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End vds_extract.start_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         //
         // SAP retrieve meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start retrieve SAP meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
         objSapSingleQuery.execute("KOTP505", "KOTP505", cstrVdsKOTP505Columns, strKNUMH,0,0);
         objSapSingleQuery.execute("KONDP", "KONDP", cstrVdsKONDPColumns, strKNUMH,0,0);
         objSapSingleQuery.execute("PACKPO", "PACKPO", cstrVdsPACKPOColumns, strPACKNR,0,0);
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End retrieve SAP meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
         //
         // VDS update meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start vds_extract.update_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objWorkDATA = objSapSingleQuery.getResultSet().getMetaData().toList();
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_meta(?,?)}");
         for (int j=0; j<objWorkDATA.size(); j++) {
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.setString(2, (String)objWorkDATA.get(j));
            objOracleStatement.execute();
         }
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End vds_extract.update_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }

         //
         // VDS final meta
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start vds_extract.final_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.final_meta(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
         objOracleStatement.close();
         objOracleStatement = null;
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End vds_extract.final_meta: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
      } catch(Exception objException) {
         throw new Exception("Meta retrieval failed - " + objException.getMessage());
      } finally {
         objSapSingleQuery = null;
         if (cobjSapConnection != null) {
            cobjSapConnection.disconnect();
         }
         cobjSapConnection = null;
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         objOracleStatement = null;
      }
      
      //
      // End MPKG meta retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Meta Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }
   
   /**
    * Processes the data request.
    * @throws Exception the exception message
    */
   private void extractData() throws Exception {
      
      cSapSingleQuery objSapSingleQuery = null;
      CallableStatement objOracleStatement = null;
      ArrayList objMATNR = null;
      ArrayList objKNUMH = null;
      ArrayList objPACKNR = null;
      ArrayList objWorkMATNR = null;
      ArrayList objWorkDATA = null;
      
      //
      // Start MPKG data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> Start Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
         
      //
      // Initialise the work array
      //
      objWorkDATA = new ArrayList();
      
      //
      // Clear the document list
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start vds_extract.clear_list: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {
         objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.clear_list(?)}");
         objOracleStatement.setString(1, cstrVdsQuery);
         objOracleStatement.execute();
      } catch(Exception objException) {
         throw new Exception("Data retrieval failed - " + objException.getMessage());
      } finally {
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         objOracleStatement = null;
      }
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> End vds_extract.clear_list: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // Initialise the work array
      //
      objWorkMATNR = new ArrayList();
         
      //
      // VDS_DOC_LIST retrieval - material document list
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> Start VDS_DOC_LIST retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      try {  
         objOracleStatement = cobjOracleConnection.prepareCall("{ ? = call vds_extract.create_buffer('select matnr from vds.matl_mara where mtart in (''FERT'',''ZREP'') and zzistdu = ''X'' order by matnr asc') }");
         objOracleStatement.registerOutParameter(1, Types.CLOB);
         objOracleStatement.execute();
         Clob objReturn = objOracleStatement.getClob(1);
         String strData = null;
         BufferedReader objReader = new BufferedReader(objReturn.getCharacterStream());
         while((strData = objReader.readLine()) != null) {
            if (!strData.equals("")) {
               StringTokenizer objTokenizer = new StringTokenizer(strData,",");
               while (objTokenizer.hasMoreTokens()) {
                  objWorkMATNR.add(objTokenizer.nextToken());
               }
            }
         }
         objReader.close();
      } catch(Exception objException) {
         throw new Exception("Data retrieval failed - " + objException.getMessage());
      } finally {
         if (objOracleStatement != null) {
            objOracleStatement.close();
         }
         objOracleStatement = null;
      }
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("====> End VDS_DOC_LIST retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
      //
      // Set the material condition array from the work array
      //
      objMATNR = cSapUtility.getOrConditionsArray(objWorkMATNR,"MATNR = '<KEYVALUE></KEYVALUE>'",cintDatCount);
      
      //
      // MARA data retrieval
      //
      if (objMATNR.size() == 0) {
         
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> No materials for SAP extract: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         
      } else {
         
         //
         // SAP retrieve data
         //
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> Start SAP extract: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
         try {

            //
            // VDS start data
            //
            if (cstrLogging != null) {
               cobjPrintWriter.println();
               cobjPrintWriter.print("======> Start vds_extract.start_data: " + Calendar.getInstance().getTime());
               cobjPrintWriter.flush();
            }
            objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.start_data(?)}");
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.execute();
            objOracleStatement.close();
            objOracleStatement = null;
            if (cstrLogging != null) {
               cobjPrintWriter.println();
               cobjPrintWriter.print("======> End vds_extract.start_data: " + Calendar.getInstance().getTime());
               cobjPrintWriter.flush();
            }

            //
            // SAP extract data
            //
            if (cstrLogging != null) {
               cobjPrintWriter.println();
               cobjPrintWriter.print("======> Start SAP Connection: " + Calendar.getInstance().getTime()); 
               cobjPrintWriter.flush();
            }
            try {
               cobjSapConnection =  new cSapConnection(cstrSapClient, cstrSapUserId, cstrSapPassword, cstrSapLanguage, cstrSapServer, cstrSapSystem);
            } catch(Exception objException) {
               throw new Exception("SAP Connection failed - " + objException.getMessage());
            }
            if (cstrLogging != null) {
               cobjPrintWriter.println();
               cobjPrintWriter.print("======> End SAP Connection: " + Calendar.getInstance().getTime());
               cobjPrintWriter.flush();
            }
            objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.update_data(?,?)}");

            //
            // SAP KOTP505 extract
            //
            objKNUMH = new ArrayList();
            for (int i=0; i<objMATNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("KOTP505", "KOTP505", cstrVdsKOTP505Columns, cSapUtility.concatenateArray((String[])objMATNR.get(i), new String[]{"AND (" + cstrKOTP505Filter + ")"}),0,0);
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> Start KOTP505 vds_extract.update_data:"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objWorkDATA = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkDATA.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkDATA.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End KOTP505 vds_extract.update_data (" + objWorkDATA.size() + "):"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objKNUMH = objSapSingleQuery.getResultSet().getMergedArray(objKNUMH,"KOTP505","KNUMH");
            }
            objKNUMH = cSapUtility.getOrConditionsArray(objKNUMH, "KNUMH = '<KEYVALUE>KNUMH</KEYVALUE>'", 500);

            //
            // SAP KONDP extract
            //
            objPACKNR = new ArrayList();
            for (int i=0; i<objKNUMH.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("KONDP", "KONDP", cstrVdsKONDPColumns, (String[])objKNUMH.get(i), 0, 0);
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> Start KONDP vds_extract.update_data:"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objWorkDATA = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkDATA.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkDATA.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End KONDP vds_extract.update_data (" + objWorkDATA.size() + "):"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objPACKNR = objSapSingleQuery.getResultSet().getMergedArray(objPACKNR,"KONDP","PACKNR");
            }
            objPACKNR = cSapUtility.getOrConditionsArray(objPACKNR, "PACKNR = '<KEYVALUE>PACKNR</KEYVALUE>'", 500);

            //
            // SAP PACKPO extract
            //
            for (int i=0; i<objPACKNR.size(); i++) {
               objSapSingleQuery = new cSapSingleQuery(cobjSapConnection);
               objSapSingleQuery.execute("PACKPO", "PACKPO", cstrVdsPACKPOColumns, (String[])objPACKNR.get(i), 0, 0);
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> Start PACKPO vds_extract.update_data:"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
               objWorkDATA = objSapSingleQuery.getResultSet().toList();
               for (int j=0; j<objWorkDATA.size(); j++) {
                  objOracleStatement.setString(1, cstrVdsQuery);
                  objOracleStatement.setString(2, (String)objWorkDATA.get(j));
                  objOracleStatement.execute();
               }
               if (cstrLogging != null) {
                  cobjPrintWriter.println();
                  cobjPrintWriter.print("======> End PACKPO vds_extract.update_data (" + objWorkDATA.size() + "):"+ Calendar.getInstance().getTime());
                  cobjPrintWriter.flush();
               }
            }

            //
            // Close the oracle statement
            //
            if (objOracleStatement != null) {
               objOracleStatement.close();
               objOracleStatement = null;
            }

            //
            // VDS final data
            //
            if (cstrLogging != null) {
               cobjPrintWriter.println();
               cobjPrintWriter.print("======> Start vds_extract.final_data: " + Calendar.getInstance().getTime());
               cobjPrintWriter.flush();
            }
            objOracleStatement = cobjOracleConnection.prepareCall("{call vds_extract.final_data(?)}");
            objOracleStatement.setString(1, cstrVdsQuery);
            objOracleStatement.execute();
            objOracleStatement.close();
            objOracleStatement = null;
            if (cstrLogging != null) {
               cobjPrintWriter.println();
               cobjPrintWriter.print("======> End vds_extract.final_data: " + Calendar.getInstance().getTime());
               cobjPrintWriter.flush();
            }

         } catch(Exception objException) {
            throw new Exception("Data retrieval failed - " + objException.getMessage());
         } finally {
            objSapSingleQuery = null;
            if (cobjSapConnection != null) {
               cobjSapConnection.disconnect();
            }
            cobjSapConnection = null;
            if (objOracleStatement != null) {
               objOracleStatement.close();
            }
            objOracleStatement = null;
         }
         if (cstrLogging != null) {
            cobjPrintWriter.println();
            cobjPrintWriter.print("====> End SAP extract: " + Calendar.getInstance().getTime());
            cobjPrintWriter.flush();
         }
      
      }
      
      //
      // End MPKG data retrieval
      //
      if (cstrLogging != null) {
         cobjPrintWriter.println();
         cobjPrintWriter.print("==> End Data Retrieval: " + Calendar.getInstance().getTime());
         cobjPrintWriter.flush();
      }
      
   }

}