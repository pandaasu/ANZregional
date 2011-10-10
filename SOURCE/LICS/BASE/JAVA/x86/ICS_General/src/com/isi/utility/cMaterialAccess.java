/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapInterface
 * Author  : Steve Gregan
 * Date    : June 2005
 */
package com.isi.utility;
import java.util.*;
import java.io.*;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the SAP to LAD base interface functionality. All SAP to LAD.
 * interfaces must extend this abstract class.
 */
public class cMaterialAccess extends cDataAccess {
   
   /**
    * Class constructor
    * @param strSapClient the SAP connection client
    * @param strSapUserId the SAP connection user identifier
    * @param strSapPassword the SAP connection password
    * @param strSapLanguage the SAP connection language
    * @param strSapSystem the SAP connection system
    * @throws Exception message
    */
   public cMaterialAccess(cTransaction objTransaction) throws Exception {
      super(objTransaction);
      // load the xml stream
      // create a collection of rows
      // create a collection of objects (columns)
      // generate the SQL ***impossible - specific to transaction***
      // inner class for primary key structure
      // load - loads from database
      // 
      // update - updates persistant data
      // create - creates persistant data
      // delete - deletes persistant data
      // commit or rollback is handled by transaction
      //
   }
   
   /**
    * Retrieves the selected SAP audit trail and loads into Oracle. This method connects
    * to the requested SAP database and retrieves the selected audit trail data. A connection is
    * then made to the requested Oracle database and the audit trail data is inserted.
    * @param strIdentifier the SAP interface identifier
    * @param strConfiguration the SAP interface configuration file
    * @param strOutputFile the SAP interface output file
    * @param strUserId the SAP user identifier
    * @param strPassword the SAP password
    * @throws Exception the exception message
    */
   public void process(String strIdentifier,
                       String strConfiguration,
                       String strOutputFile,
                       String strUserId,
                       String strPassword) throws Exception {

      //
      // Parse the interface configuration XML file
      //
      HashMap objParameters = new HashMap();
      DocumentBuilderFactory objFactory = null;
      DocumentBuilder objBuilder = null;
      Document objDocument = null;
      try {
         objFactory = DocumentBuilderFactory.newInstance();
         objBuilder = objFactory.newDocumentBuilder();
         File objFile = new File(strConfiguration);
         if (!objFile.canRead()) {
            throw new Exception("Unable to read interface configuration file (" + strConfiguration + ")");
         }
         objDocument = objBuilder.parse(objFile);
         objParameters.clear();
         processNode(strIdentifier, objDocument.getChildNodes(), objParameters);
         if (objParameters.isEmpty()) {
            throw new Exception("Unable to find configuration data for (" + strIdentifier.toUpperCase() + ") in interface configuration file (" + strConfiguration + ")");
         }
      } catch(Exception objException) {
         throw new Exception("SAP INTERFACE - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
      
      //
      // Load and instance the interface class
      //
      iSapInterface objInterface;
      String strClass = (String)objParameters.get("CLASS");
      if (strClass == null) {
         throw new Exception("SAP INTERFACE - Interface class not supplied");
      }
      try {
         Class objInterfaceClass = Class.forName(strClass);
         try {
            objInterface = (iSapInterface)objInterfaceClass.newInstance();
         } catch(Exception objException) {
            throw new Exception("SAP INTERFACE - CLASS (" + strClass + ") unable to cast to iSapInterface");
         }
      } catch(ClassNotFoundException objException) {
         throw new Exception("SAP INTERFACE - CLASS (" + strClass + ") not found");
      }

      //
      // Connect to SAP and process the interface request
      //
      String strSapClient = (String)objParameters.get("SAPCLIENT");
      String strSapUserId = (String)objParameters.get("SAPUSERID");
      String strSapPassword = (String)objParameters.get("SAPPASSWORD");
      String strSapLanguage = (String)objParameters.get("SAPLANGUAGE");
      String strSapServer = (String)objParameters.get("SAPSERVER");
      String strSapSystem = (String)objParameters.get("SAPSYSTEM");
      if (strSapClient == null) {
         throw new Exception("SAP INTERFACE - SAP connection client not supplied in configuration file");
      }
      if (strSapUserId == null) {
         throw new Exception("SAP INTERFACE - SAP connection user id not supplied in configuration file");
      }
      if (strSapPassword == null) {
         throw new Exception("SAP INTERFACE - SAP connection password not supplied in configuration file");
      }
      if (strSapLanguage == null) {
         throw new Exception("SAP INTERFACE - SAP connection language not supplied in configuration file");
      }
      if (strSapServer == null) {
         throw new Exception("SAP INTERFACE - SAP connection server not supplied in configuration file");
      }
      if (strSapSystem == null) {
         throw new Exception("SAP INTERFACE - SAP connection system not supplied in configuration file");
      }
      if (strSapUserId.toUpperCase().equals("*PROMPTED")) {
         if (strUserId == null) {
            throw new Exception("SAP INTERFACE - SAP connection not supplied by calling method");
         } else {
            strSapUserId = strUserId;
         }
      }
      if (strSapPassword.toUpperCase().equals("*PROMPTED")) {
         if (strPassword == null) {
            throw new Exception("SAP INTERFACE - SAP connection not supplied by calling method");
         } else {
            strSapPassword = strPassword;
         }
      }
      cSapConnection objSAPConnection = null;
      try {
         try {
            objSAPConnection =  new cSapConnection(strSapClient, strSapUserId, strSapPassword, strSapLanguage, strSapServer, strSapSystem);
         } catch(Exception objException) {
            throw new Exception("SAP Connection failed - " + objException.getMessage());
         }
         objInterface.process(objSAPConnection, objParameters, strOutputFile);
         objSAPConnection.disconnect();
      } catch(Exception objException) {
         throw new Exception("SAP INTERFACE - " + objException.getMessage());
      } finally {
         if (objSAPConnection != null) {
            objSAPConnection.disconnect();
         }
      }
      
   }
   
   /**
   * Process the XML node
   */
   private void processNode(String strIdentifier, org.w3c.dom.NodeList objNodeList, HashMap objParameters) {
      org.w3c.dom.Node objNode = null;
      org.w3c.dom.NamedNodeMap objAttributeMap = null;
      org.w3c.dom.Node objAttributeNode = null;
      for (int i=0;i<objNodeList.getLength();i++) {
         objNode = objNodeList.item(i);
         if (objNode.getNodeName().toUpperCase().equals("CONFIGURATION")) {
            if (objParameters.isEmpty()) {
               processNode(strIdentifier, objNode.getChildNodes(), objParameters);
            }
         } else if (objNode.getNodeName().toUpperCase().equals("INTERFACE") && objParameters.isEmpty()) {
            if (objNode.hasAttributes()) {
               boolean bolFound = false;
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  if (objAttributeNode.getNodeName().toUpperCase().equals("IDENTIFIER") && objAttributeNode.getNodeValue().toUpperCase().equals(strIdentifier.toUpperCase())) {
                     bolFound = true;
                  }
                  objParameters.put(objAttributeNode.getNodeName().toUpperCase(), objAttributeNode.getNodeValue());
               }
               if (!bolFound) {
                  objParameters.clear();
               }
            }
         }
      }
   }
   
   /**
   * Usage and terminate method
   */
   protected static void usageAndTerminate() {
      System.out.println("Usage: com.isi.sap.cSapInterface [-identifier SAP interface identifier -configuration SAP interface configuration file -output SAP interface output file -user SAP user id -password SAP password]");
      System.exit(1);
   }

   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    *  -identifier = the SAP interface identifier in the configuration file
    *  -configuration = the SAP interface configuration file
    *  -output = the SAP interface output file
    *  -user = the SAP user identifier
    *  -password = the SAP password
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cSapInterface objSapInterface;
      
      //
      // Process the entry point request
      //
      try {
         
         //
         // Retrieve the command line arguments
         //
         String strIdentifier = null;
         String strConfiguration = null;
         String strOutputFile = null;
         String strUserId = null;
         String strPassword = null;
         try {
            for (int i=0;i<args.length;i++) {
               if (args[i].toUpperCase().equals("-IDENTIFIER")) {
                  strIdentifier = args[++i];
               } else if (args[i].toUpperCase().equals("-CONFIGURATION")) {
                  strConfiguration = args[++i];
               } else if (args[i].toUpperCase().equals("-OUTPUT")) {
                  strOutputFile = args[++i];
               } else if (args[i].toUpperCase().equals("-USER")) {
                  strUserId = args[++i];
               } else if (args[i].toUpperCase().equals("-PASSWORD")) {
                  strPassword = args[++i];
               }
            }
         } catch(ArrayIndexOutOfBoundsException e) {
            usageAndTerminate();
         }
         
         //
         // Check for valid argument combinations
         //
         if (strIdentifier == null ||
             strConfiguration == null ||
             strOutputFile == null) {
            usageAndTerminate();
         }
         
         //
         // Process the interface
         //
         objSapInterface = new cSapInterface();
         objSapInterface.process(strIdentifier,
                                 strConfiguration,
                                 strOutputFile,
                                 strUserId,
                                 strPassword);
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objSapInterface = null;
      }
      
   }

}