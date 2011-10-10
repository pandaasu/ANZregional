/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : cSapVdsExtract
 * Author  : Steve Gregan
 * Date    : March 2010
 */
package com.isi.vds;
import java.util.*;
import java.io.*;
import javax.xml.parsers.*;
import org.w3c.dom.Document;

/**
 * This class implements the SAP to VDS extract functionality.
 */
public class cSapVdsExtract {
   
   /**
    * Retrieves the selected SAP extract data to VDS.
    * @param strIdentifier the VDS interface identifier
    * @param strConfiguration the VDS interface configuration file
    * @param strReplace the VDS interface data full replacement indicator Y/N
    * @throws Exception the exception message
    */
   public void process(String strIdentifier, String strConfiguration, String strReplace) throws Exception {

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
         throw new Exception("SAP VDS EXTRACT - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
      
      //
      // Load and instance the interface class
      //
      iSapVdsExtract objInterface;
      String strClass = (String)objParameters.get("CLASS");
      if (strClass == null) {
         throw new Exception("SAP VDS EXTRACT - Interface class not supplied");
      }
      try {
         Class objInterfaceClass = Class.forName(strClass);
         try {
            objInterface = (iSapVdsExtract)objInterfaceClass.newInstance();
         } catch(Exception objException) {
            throw new Exception("SAP VDS EXTRACT - CLASS (" + strClass + ") unable to cast to iSapExtract");
         }
      } catch(ClassNotFoundException objException) {
         throw new Exception("SAP VDS EXTRACT - CLASS (" + strClass + ") not found");
      }

      //
      // Process the extract request
      //
     
      try {
         objInterface.process(objParameters, strReplace);
      } catch(Exception objException) {
         throw new Exception("SAP VDS EXTRACT - " + objException.getMessage());
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
      System.out.println("Usage: com.isi.vds.cSapVdsExtract [-identifier VDS interface identifier -configuration VDS interface configuration file -replace Y/N full data replacement");
      System.exit(1);
   }

   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    *  -identifier = the VDS interface identifier in the configuration file
    *  -configuration = the VDS interface configuration file
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cSapVdsExtract objSapVdsExtract;
      
      //
      // Process the entry point request
      //
      try {
         
         //
         // Retrieve the command line arguments
         //
         String strIdentifier = null;
         String strConfiguration = null;
         String strReplace = null;
         try {
            for (int i=0;i<args.length;i++) {
               if (args[i].toUpperCase().equals("-IDENTIFIER")) {
                  strIdentifier = args[++i];
               } else if (args[i].toUpperCase().equals("-CONFIGURATION")) {
                  strConfiguration = args[++i];
               } else if (args[i].toUpperCase().equals("-REPLACE")) {
                  strReplace = args[++i];
               }
            }
         } catch(ArrayIndexOutOfBoundsException e) {
            usageAndTerminate();
         }
         
         //
         // Check for valid argument combinations
         //
         if (strIdentifier == null ||
             strConfiguration == null) {
            usageAndTerminate();
         }
         
         //
         // Process the extract
         //
         objSapVdsExtract = new cSapVdsExtract();
         objSapVdsExtract.process(strIdentifier, strConfiguration, strReplace);
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
         System.exit(1);
      } finally {
         objSapVdsExtract = null;
      }
      
   }

}