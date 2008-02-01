/**
 * Package : ISI BOSS
 * Type    : Class
 * Name    : cAgent
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss;
import java.util.*;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import javax.xml.parsers.*;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the BOSS agent functionality.
 */
public class cAgent {
   
   //
   // Instance private declarations
   //
   private String cstrCode;
   private String cstrText;
   private String cstrClass;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the agent parameter array
    */
   public cAgent(String[] strParameters) {
      cstrCode = strParameters[0];
      cstrText = strParameters[1];
      cstrClass = strParameters[2];
   }
   
   /**
    * Processes the BOSS agent using the supplied configuration.
    *
    * @param strObject the collector object
    * @param objAttributes the collector attributes map
    * @param objOracleConnection the BOSS database connection
    * @throws Exception the exception message
    */
   public void process(String strObject, HashMap objAttributes, Connection objOracleConnection) throws Exception {
      
      //
      // Process the transformation
      //
      iAgent objAgentInstance;
      try {
      
         //
         // Load and instance the agent class
         //
         try {
            Class objAgentClass = Class.forName(cstrClass);
            try {
               objAgentInstance = (iAgent)objAgentClass.newInstance();
            } catch(Exception objException) {
               throw new Exception("Class (" + cstrClass + ") unable to cast to iAgent");
            }
         } catch(ClassNotFoundException objException) {
            throw new Exception("Class (" + cstrClass + ") not found");
         }

         //
         // Execute the agent instance
         //
         String strResult = null;
         try {
            strResult = objAgentInstance.retrieve(objAttributes);
         } catch(Exception objException) {
            throw new Exception("Retrieve Failed - " + objException.getMessage());
         }
         if (strResult == null || strResult.equals("")) {
            throw new Exception("Retrieve Failed - Result not returned");
         }
         
         //
         // Parse the agent result XML string
         //
         ArrayList objMeasures = new ArrayList();
         DocumentBuilderFactory objFactory = null;
         DocumentBuilder objBuilder = null;
         Document objDocument = null;
         try {
            objFactory = DocumentBuilderFactory.newInstance();
            objBuilder = objFactory.newDocumentBuilder();
            objDocument = objBuilder.parse(new InputSource(new StringReader(strResult)));
            processNode(objDocument.getChildNodes(), objMeasures);
         } catch(Exception objException) {
            throw new Exception("Result Parsing Failed - " + objException.getMessage());
         } finally {
            objDocument = null;
            objBuilder = null;
            objFactory = null;
         }
         for (int i=0; i<objMeasures.size(); i++) {
            String[] strParameters = (String[])objMeasures.get(i);
            if (strParameters[0] == null || strParameters[0].equals("")) {
               throw new Exception("Unable to load measure (" + strParameters[0] + ") - code not supplied");
            }
            if (strParameters[1] == null || strParameters[1].equals("")) {
               throw new Exception("Unable to load measure (" + strParameters[0] + ") - parent not supplied");
            }
            if (strParameters[2] == null || strParameters[2].equals("")) {
               throw new Exception("Unable to load measure (" + strParameters[0] + ") - type not supplied");
            }
            if (strParameters[3] == null || strParameters[3].equals("")) {
               throw new Exception("Unable to load measure (" + strParameters[0] + ") - alert not supplied");
            }
            if (strParameters[4] == null || strParameters[4].equals("")) {
               throw new Exception("Unable to load measure (" + strParameters[0] + ") - value not supplied");
            }
            if (strParameters[5] == null || strParameters[5].equals("")) {
               throw new Exception("Unable to load measure (" + strParameters[0] + ") - text not supplied");
            }
         }
         
         //
         // Process the agent result
         //
         String INSERT_MEASURE =
            "insert into boss_obj_measure" +
            " (obm_object," +
            " obm_sequence," +
            " obm_measure," +
            " obm_parent," +
            " obm_type," +
            " obm_alert," +
            " obm_value," +
            " obm_description)" +
            " values (?, ?, ?, ?, ?, ?, ?, ?)";
         try {
            double dblSequence = 0;
            CallableStatement objCallableStatement = objOracleConnection.prepareCall("{? = call boss_app.boss_maintenance.update_object(?)}");
            try {
               objCallableStatement.registerOutParameter(1, Types.DOUBLE);
               objCallableStatement.setString(2, strObject);
               objCallableStatement.execute();
               dblSequence = objCallableStatement.getDouble(1);
            } catch(Exception objException) {
               throw new Exception("BOSS Object Update Failed - " + objException.getMessage());
            } finally {
               if (objCallableStatement != null) {
                  objCallableStatement.close();
               }
               objCallableStatement = null;
            }
            PreparedStatement objOracleStatement = objOracleConnection.prepareStatement(INSERT_MEASURE);
            try {
               for (int i=0; i<objMeasures.size(); i++) {
                  String[] strValues = (String[])objMeasures.get(i);
                  objOracleStatement.setString(1, strObject);
                  objOracleStatement.setDouble(2, dblSequence);
                  objOracleStatement.setString(3, strValues[0]);
                  objOracleStatement.setString(4, strValues[1]);
                  objOracleStatement.setString(5, strValues[2]);
                  objOracleStatement.setString(6, strValues[3]);
                  objOracleStatement.setString(7, strValues[4]);
                  objOracleStatement.setString(8, strValues[5]);
                  objOracleStatement.executeUpdate();
               }
            } catch(Exception objException) {
               throw new Exception("BOSS Measure Insert Failed - " + objException.getMessage());
            } finally {
               if (objOracleStatement != null) {
                  objOracleStatement.close();
               }
               objOracleStatement = null;
            }
            objOracleConnection.commit();
         } catch(Exception objException) {
            objOracleConnection.rollback();
            throw objException;
         }

      } catch(Exception objException) {
         throw new Exception("Agent (" + cstrCode + ") - " + objException.getMessage());
      } finally {
         objAgentInstance = null;
      }
      
   }
   
   /**
    * Process the XML node
    */
   private void processNode(org.w3c.dom.NodeList objNodeList, ArrayList objMeasures) throws Exception {
      org.w3c.dom.Node objNode = null;
      org.w3c.dom.NamedNodeMap objAttributeMap = null;
      org.w3c.dom.Node objAttributeNode = null;
      for (int i=0;i<objNodeList.getLength();i++) {
         objNode = objNodeList.item(i);
         if (objNode.getNodeName().toUpperCase().equals("BOSS_DATA")) {
            processNode(objNode.getChildNodes(), objMeasures);
         } else if (objNode.getNodeName().toUpperCase().equals("MEASURE")) {
            String[] strParameters = new String[10];
            if (objNode.hasAttributes()) {
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  if (objAttributeNode.getNodeName().toUpperCase().equals("CODE")) {
                     strParameters[0] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("PARENT")) {
                     strParameters[1] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TYPE")) {
                     strParameters[2] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("ALERT")) {
                     strParameters[3] = objAttributeNode.getNodeValue().toUpperCase();
                  }
               }
            }
            objMeasures.add(strParameters);
            processNode(objNode.getChildNodes(), objMeasures);
         } else if (objNode.getNodeName().toUpperCase().equals("VALUE")) {
            String[] strParameters = (String[])objMeasures.get(objMeasures.size()-1);
            strParameters[9] = "V";
            processNode(objNode.getChildNodes(), objMeasures);
         } else if (objNode.getNodeName().toUpperCase().equals("TEXT")) {
            String[] strParameters = (String[])objMeasures.get(objMeasures.size()-1);
            strParameters[9] = "T";
            processNode(objNode.getChildNodes(), objMeasures);
         } else if (objNode.getNodeName().toUpperCase().equals("#CDATA-SECTION")) {
            String[] strParameters = (String[])objMeasures.get(objMeasures.size()-1);
            if (strParameters[9].equals("V")) {
               strParameters[4] = objNode.getNodeValue();
            }
            if (strParameters[9].equals("T")) {
               strParameters[5] = objNode.getNodeValue();
            }
         }
      }
   }

}