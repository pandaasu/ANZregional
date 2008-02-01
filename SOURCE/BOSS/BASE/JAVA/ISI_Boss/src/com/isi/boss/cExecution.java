/**
 * Package : ISI Boss
 * Type    : Class
 * Name    : cExecution
 * Author  : Steve Gregan
 * Date    : August 2007
 */
package com.isi.boss;
import java.util.*;
import java.io.*;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the BOSS execution functionality.
 */
public class cExecution {
   
   //
   // Instance private declarations
   //
   private cConfiguration cobjConfiguration;
   private HashMap cobjAttributes;
   private ArrayList cobjCollectors;

   /**
    * Constructs a new instance
    */
   public cExecution() {
      cobjConfiguration = new cConfiguration();
      cobjAttributes = new HashMap();
      cobjCollectors = new ArrayList();
   }
   
   /**
    * Retrieves the execution attribute
    *
    * @param strName the attibute name
    * @return String the attibute value
    */
   public String getAttribute(String strName) {
      return (String)cobjAttributes.get(strName.toUpperCase());
   }
   
   /**
    * Sets the execution attribute
    *
    * @param strName the attibute name
    * @param strValue the attibute value
    */
   public void setAttribute(String strName, String strValue) {
      cobjAttributes.put(strName.toUpperCase(), strValue);
   }
   
   /**
    * Processes the BOSS execution using the supplied configurtion.
    *
    * @param strConfiguration the BOSS configuration file
    * @param strExecution the BOSS execution file
    * @throws Exception the exception message
    */
   public void process(String strConfiguration, String strExecution) throws Exception {
      
      //
      // Load the configuration
      //
      cobjConfiguration.load(strConfiguration);
      
      //
      // Clear the execution maps
      //
      cobjAttributes.clear();
      
      //
      // Parse the distribution execution XML file
      //
      DocumentBuilderFactory objFactory = null;
      DocumentBuilder objBuilder = null;
      Document objDocument = null;
      try {
         objFactory = DocumentBuilderFactory.newInstance();
         objBuilder = objFactory.newDocumentBuilder();
         File objFile = new File(strExecution);
         if (!objFile.canRead()) {
            throw new Exception("Unable to read BOSS execution file (" + strExecution + ")");
         }
         objDocument = objBuilder.parse(objFile);
         processNode(objDocument.getChildNodes());
         if (cobjAttributes.isEmpty()) {
            throw new Exception("Unable to find execution data in BOSS execution file (" + strExecution + ")");
         }
         if (this.getAttribute("text") == null || this.getAttribute("text").equals("")) {
            throw new Exception("Execution attribute - text not supplied");
         }
      } catch(Exception objException) {
         throw new Exception("BOSS - Execution Parsing Failed - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
      
      //
      // Process the collector list
      //
      cobjConfiguration.openConnection();
      try {
         for (int i=0; i<cobjCollectors.size(); i++) {
            ((cCollector)cobjCollectors.get(i)).process(cobjConfiguration);
         }
      } finally {
         cobjConfiguration.closeConnection();
      }
         
      //
      // Destroy the configuration
      //
      cobjConfiguration = null;

   }
   
   /**
   * Process the XML node
   */
   private void processNode(org.w3c.dom.NodeList objNodeList) throws Exception {
      org.w3c.dom.Node objNode = null;
      org.w3c.dom.NamedNodeMap objAttributeMap = null;
      org.w3c.dom.Node objAttributeNode = null;
      for (int i=0;i<objNodeList.getLength();i++) {
         objNode = objNodeList.item(i);
         if (objNode.getNodeName().toUpperCase().equals("EXECUTION")) {
            if (objNode.hasAttributes()) {
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  cobjAttributes.put(objAttributeNode.getNodeName().toUpperCase(), objAttributeNode.getNodeValue());
               }
            }
            processNode(objNode.getChildNodes());
         } else if (objNode.getNodeName().toUpperCase().equals("COLLECTOR")) {
            if (objNode.hasAttributes()) {
               String[] strParameters = new String[50];
               HashMap objChildAttributes = new HashMap();
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  if (objAttributeNode.getNodeName().toUpperCase().equals("AGENT")) {
                     strParameters[0] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("OBJECT")) {
                     strParameters[1] = objAttributeNode.getNodeValue().toUpperCase();
                  } else {
                     objChildAttributes.put(objAttributeNode.getNodeName().toUpperCase(), objAttributeNode.getNodeValue());
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to load collector - agent not supplied");
               }
               if (strParameters[1] == null || strParameters[1].equals("")) {
                  throw new Exception("Unable to load collector - object not supplied");
               }
               if (!cobjConfiguration.isAgent(strParameters[0])) {
                  throw new Exception("Unable to load collector - agent (" + strParameters[0] + ") not registered in configuration");
               }
               cobjCollectors.add(new cCollector(strParameters, objChildAttributes));
            }
         }
      }
   }
   
   /**
   * Usage and terminate method
   */
   protected static void usageAndTerminate() {
      System.out.println("Usage: com.isi.boss.cCollector [-configuration Collector configuration file -execution Collector execution file]");
      System.exit(1);
   }

   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    *  -configuration = the collector configuration file
    *  -execution = the collector execution file
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cExecution objExecution;
      
      //
      // Process the entry point request
      //
      try {
         
         //
         // Retrieve the command line arguments
         //
         String strConfiguration = null;
         String strExecution = null;
         try {
            for (int i=0;i<args.length;i++) {
               if (args[i].toUpperCase().equals("-CONFIGURATION")) {
                  strConfiguration = args[++i];
               } else if (args[i].toUpperCase().equals("-EXECUTION")) {
                  strExecution = args[++i];
               }
            }
         } catch(ArrayIndexOutOfBoundsException e) {
            usageAndTerminate();
         }
         
         //
         // Check for valid argument combinations
         //
         if (strConfiguration == null ||
             strExecution == null) {
            usageAndTerminate();
         }
         
         //
         // Process the collector
         //
         objExecution = new cExecution();
         objExecution.process(strConfiguration, strExecution);
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objExecution = null;
      }
      
   }

}