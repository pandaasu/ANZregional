/**
 * Package : ISI Boss
 * Type    : Class
 * Name    : cConfiguration
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss;
import java.util.*;
import java.sql.*;
import java.io.*;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the BOSS configuration functionality.
 */
public class cConfiguration {
   
   //
   // Instance private declarations
   //
   private HashMap cobjAttributes;
   private HashMap cobjAgents;
   private Connection cobjOracleConnection;

   /**
    * Constructs a new instance
    */
   public cConfiguration() {
      cobjAttributes = new HashMap();
      cobjAgents = new HashMap();
      cobjOracleConnection = null;
   }
   
   /**
    * Retrieves the configuration attribute
    *
    * @param strName the attibute name
    * @return String the attibute value
    */
   public String getAttribute(String strName) {
      return (String)cobjAttributes.get(strName.toUpperCase());
   }
   
   /**
    * Sets the configuration attribute
    *
    * @param strName the attibute name
    * @param strValue the attibute value
    */
   public void setAttribute(String strName, String strValue) {
      cobjAttributes.put(strName.toUpperCase(), strValue);
   }
   
   /**
    * Checks the configuration for a registered agent
    *
    * @param strName the agent name
    * @return boolean the agent name existance
    */
   public boolean isAgent(String strName) {
      return cobjAgents.containsKey(strName.toUpperCase());
   }
   
   /**
    * Processes a collector registered transform
    *
    * @param strAgent the collector agent
    * @param strObject the collector object
    * @param objAttributes the collector attributes map
    * @throws Exception the exception message
    */
   public void  processCollector(String strAgent, String strObject, HashMap objAttributes) throws Exception {
      ((cAgent)cobjAgents.get(strAgent)).process(strObject, objAttributes, cobjOracleConnection);
   }
   
   /**
    * Opens the BOSS database cobnnection
    *
    * @throws Exception the exception message
    */
   public void openConnection() throws Exception {
      try {
         DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
         cobjOracleConnection = DriverManager.getConnection(this.getAttribute("connection"), this.getAttribute("user"), this.getAttribute("password"));
         cobjOracleConnection.setAutoCommit(false);
      } catch(Exception objException) {
         throw new Exception("BOSS - Database Connection Failed - " + objException.getMessage());
      }
   }
   
   /**
    * Opens the BOSS database cobnnection
    *
    * @throws Exception the exception message
    */
   public void closeConnection() throws Exception {
      if (cobjOracleConnection != null) {
         cobjOracleConnection.close();
      }
      cobjOracleConnection = null;
   }
   
   /**
    * Loads the BOSS configuration.
    *
    * @param strConfiguration the BOSS configuration file
    * @throws Exception the exception message
    */
   public void load(String strConfiguration) throws Exception {

      //
      // Clear the configuration maps
      //
      cobjAttributes.clear();
      cobjAgents.clear();
      
      //
      // Parse the distribution configuration XML file
      //
      DocumentBuilderFactory objFactory = null;
      DocumentBuilder objBuilder = null;
      Document objDocument = null;
      try {
         objFactory = DocumentBuilderFactory.newInstance();
         objBuilder = objFactory.newDocumentBuilder();
         File objFile = new File(strConfiguration);
         if (!objFile.canRead()) {
            throw new Exception("Unable to read BOSS configuration file (" + strConfiguration + ")");
         }
         objDocument = objBuilder.parse(objFile);
         processNode(objDocument.getChildNodes());
         if (cobjAttributes.isEmpty()) {
            throw new Exception("Unable to find configuration data in BOSS configuration file (" + strConfiguration + ")");
         }
         if (this.getAttribute("connection") == null || this.getAttribute("connection").equals("")) {
            throw new Exception("Configuration attribute - connection not supplied");
         }
         if (this.getAttribute("user") == null || this.getAttribute("user").equals("")) {
            throw new Exception("Configuration attribute - user not supplied");
         }
         if (this.getAttribute("password") == null || this.getAttribute("password").equals("")) {
            throw new Exception("Configuration attribute - password not supplied");
         }
      } catch(Exception objException) {
         throw new Exception("BOSS - Configuration Load Failed - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
      
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
         if (objNode.getNodeName().toUpperCase().equals("CONFIGURATION")) {
            if (objNode.hasAttributes()) {
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  cobjAttributes.put(objAttributeNode.getNodeName().toUpperCase(), objAttributeNode.getNodeValue());
               }
            }
            processNode(objNode.getChildNodes());
         } else if (objNode.getNodeName().toUpperCase().equals("REGISTERAGENT")) {
            if (objNode.hasAttributes()) {
               String[] strParameters = new String[20];
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                   if (objAttributeNode.getNodeName().toUpperCase().equals("CODE")) {
                     strParameters[0] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     strParameters[1] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("CLASS")) {
                     strParameters[2] = objAttributeNode.getNodeValue();
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to register agent - code not supplied");
               }
               if (strParameters[1] == null || strParameters[1].equals("")) {
                  throw new Exception("Unable to register agent - text not supplied");
               }
               if (strParameters[2] == null || strParameters[2].equals("")) {
                  throw new Exception("Unable to register agent - class not supplied");
               }

               if (cobjAgents.containsKey(strParameters[0].toUpperCase())) {
                  throw new Exception("Unable to register agent - already registered");
               }
               cobjAgents.put(strParameters[0].toUpperCase(), new cAgent(strParameters));
            }
         }
      }
   }

}