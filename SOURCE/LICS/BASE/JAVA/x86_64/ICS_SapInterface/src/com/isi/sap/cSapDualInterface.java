/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapDualInterface
 * Author  : Steve Gregan
 * Date    : February 2007
 */
package com.isi.sap;
import java.util.*;
import java.io.*;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the SAP base dual interface functionality. All SAP dual
 * interfaces must extend this abstract class.
 */
public class cSapDualInterface {
   
   /**
    * Retrieves the selected SAP audit trail and loads into Oracle. This method connects
    * to the requested SAP database and retrieves the selected audit trail data. A connection is
    * then made to the requested Oracle database and the audit trail data is inserted.
    * @param strIdentifier the SAP interface identifier
    * @param strConfiguration the SAP interface configuration file
    * @param strOutputFile the SAP interface output file
    * @param strUserId01 the SAP user identifier 01
    * @param strPassword01 the SAP password 01
    * @param strUserId02 the SAP user identifier 02
    * @param strPasswor0d2 the SAP password 02
    * @throws Exception the exception message
    */
   public void process(String strIdentifier,
                       String strConfiguration,
                       String strOutputFile,
                       String strUserId01,
                       String strPassword01,
                       String strUserId02,
                       String strPassword02) throws Exception {

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
         throw new Exception("SAP DUAL INTERFACE - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
      
      //
      // Load and instance the interface class
      //
      iSapDualInterface objDualInterface;
      String strClass = (String)objParameters.get("CLASS");
      if (strClass == null) {
         throw new Exception("SAP DUAL INTERFACE - Interface class not supplied");
      }
      try {
         Class objInterfaceClass = Class.forName(strClass);
         try {
            objDualInterface = (iSapDualInterface)objInterfaceClass.newInstance();
         } catch(Exception objException) {
            throw new Exception("SAP DUAL INTERFACE - CLASS (" + strClass + ") unable to cast to iSapDualInterface");
         }
      } catch(ClassNotFoundException objException) {
         throw new Exception("SAP DUAL INTERFACE - CLASS (" + strClass + ") not found");
      }

      //
      // Connect to SAP and process the interface request
      //
      String strSapClient01 = (String)objParameters.get("SAPCLIENT01");
      String strSapUserId01 = (String)objParameters.get("SAPUSERID01");
      String strSapPassword01 = (String)objParameters.get("SAPPASSWORD01");
      String strSapLanguage01 = (String)objParameters.get("SAPLANGUAGE01");
      String strSapServer01 = (String)objParameters.get("SAPSERVER01");
      String strSapSystem01 = (String)objParameters.get("SAPSYSTEM01");
      String strSapClient02 = (String)objParameters.get("SAPCLIENT02");
      String strSapUserId02 = (String)objParameters.get("SAPUSERID02");
      String strSapPassword02 = (String)objParameters.get("SAPPASSWORD02");
      String strSapLanguage02 = (String)objParameters.get("SAPLANGUAGE02");
      String strSapServer02 = (String)objParameters.get("SAPSERVER02");
      String strSapSystem02 = (String)objParameters.get("SAPSYSTEM02");
      if (strSapClient01 == null) {
         throw new Exception("SAP DUAL INTERFACE - SAP connection client 01 not supplied in configuration file");
      }
      if (strSapUserId01 == null) {
         throw new Exception("SAP DUAL INTERFACE - SAP connection user id 01 not supplied in configuration file");
      }
      if (strSapPassword01 == null) {
         throw new Exception("SAP DUAL INTERFACE - SAP connection password 01 not supplied in configuration file");
      }
      if (strSapLanguage01 == null) {
         throw new Exception("SAP DUAL INTERFACE - SAP connection language 01 not supplied in configuration file");
      }
      if (strSapServer01 == null) {
         throw new Exception("SAP DUAL INTERFACE - SAP connection server 01 not supplied in configuration file");
      }
      if (strSapSystem01 == null) {
         throw new Exception("SAP DUAL INTERFACE - SAP connection system 01 not supplied in configuration file");
      }
      if (strSapUserId01.toUpperCase().equals("*PROMPTED")) {
         if (strUserId01 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection user id 01 not supplied by calling method");
         } else {
            strSapUserId01 = strUserId01;
         }
      }
      if (strSapPassword01.toUpperCase().equals("*PROMPTED")) {
         if (strPassword01 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection password 01 not supplied by calling method");
         } else {
            strSapPassword01 = strPassword01;
         }
      }
      if (strSapServer02 != null) {
         if (strSapClient02 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection client 02 not supplied in configuration file");
         }
         if (strSapUserId02 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection user id 02 not supplied in configuration file");
         }
         if (strSapPassword02 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection password 02 not supplied in configuration file");
         }
         if (strSapLanguage02 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection language 02 not supplied in configuration file");
         }
         if (strSapServer02 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection server 02 not supplied in configuration file");
         }
         if (strSapSystem02 == null) {
            throw new Exception("SAP DUAL INTERFACE - SAP connection system 02 not supplied in configuration file");
         }
         if (strSapUserId02.toUpperCase().equals("*PROMPTED")) {
            if (strUserId02 == null || strUserId02.toUpperCase().equals("*NONE")) {
               throw new Exception("SAP DUAL INTERFACE - SAP connection user id 02 not supplied by calling method");
            } else {
               strSapUserId02 = strUserId02;
            }
         }
         if (strSapPassword02.toUpperCase().equals("*PROMPTED")) {
            if (strPassword02 == null || strPassword02.toUpperCase().equals("*NONE")) {
               throw new Exception("SAP DUAL INTERFACE - SAP connection password 02 not supplied by calling method");
            } else {
               strSapPassword02 = strPassword02;
            }
         }
      }
      cSapConnection objSapConnection01 = null;
      cSapConnection objSapConnection02 = null;
      try {
         try {
            objSapConnection01 = new cSapConnection(strSapClient01, strSapUserId01, strSapPassword01, strSapLanguage01, strSapServer01, strSapSystem01);
         } catch(Exception objException) {
            throw new Exception("SAP Connection 01 failed - " + objException.getMessage());
         }
         if (strSapServer02 != null) {
            try {
               objSapConnection02 = new cSapConnection(strSapClient02, strSapUserId02, strSapPassword02, strSapLanguage02, strSapServer02, strSapSystem02);
            } catch(Exception objException) {
               throw new Exception("SAP Connection 02 failed - " + objException.getMessage());
            }
         }
         objDualInterface.process(objSapConnection01, objSapConnection02, objParameters, strOutputFile);
         objSapConnection01.disconnect();
         objSapConnection01 = null;
         if (objSapConnection02 != null) {
            objSapConnection02.disconnect();
            objSapConnection02 = null;
         }
      } catch(Exception objException) {
         throw new Exception("SAP DUAL INTERFACE - " + objException.getMessage());
      } finally {
         if (objSapConnection01 != null) {
            objSapConnection01.disconnect();
         }
         if (objSapConnection02 != null) {
            objSapConnection02.disconnect();
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
      System.out.println("Usage: com.isi.sap.cSapDualInterface [-identifier SAP interface identifier -configuration SAP interface configuration file -output SAP interface output file -user01 SAP user id -password01 SAP password -user02 SAP user id -password02 SAP password]");
      System.exit(1);
   }

   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    *  -identifier = the SAP interface identifier in the configuration file
    *  -configuration = the SAP interface configuration file
    *  -output = the SAP interface output file
    *  -user01 = the SAP user identifier 01
    *  -password02 = the SAP password 01
    *  -user02 = the SAP user identifier 02
    *  -password02 = the SAP password 02
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cSapDualInterface objSapDualInterface;
      
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
         String strUserId01 = null;
         String strPassword01 = null;
         String strUserId02 = null;
         String strPassword02 = null;
         try {
            for (int i=0;i<args.length;i++) {
               if (args[i].toUpperCase().equals("-IDENTIFIER")) {
                  strIdentifier = args[++i];
               } else if (args[i].toUpperCase().equals("-CONFIGURATION")) {
                  strConfiguration = args[++i];
               } else if (args[i].toUpperCase().equals("-OUTPUT")) {
                  strOutputFile = args[++i];
               } else if (args[i].toUpperCase().equals("-USER01")) {
                  strUserId01 = args[++i];
               } else if (args[i].toUpperCase().equals("-PASSWORD01")) {
                  strPassword01 = args[++i];
               } else if (args[i].toUpperCase().equals("-USER02")) {
                  strUserId02 = args[++i];
               } else if (args[i].toUpperCase().equals("-PASSWORD02")) {
                  strPassword02 = args[++i];
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
         objSapDualInterface = new cSapDualInterface();
         objSapDualInterface.process(strIdentifier,
                                     strConfiguration,
                                     strOutputFile,
                                     strUserId01,
                                     strPassword01,
                                     strUserId02,
                                     strPassword02);
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objSapDualInterface = null;
      }
      
   }

}