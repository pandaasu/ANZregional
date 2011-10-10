/**
 * Package : ISI SIMULATION
 * Type    : Class
 * Name    : cSimulator
 * Author  : Steve Gregan
 * Date    : January 2006
 */
package com.isi.simulation;
import java.util.*;
import java.io.*;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the simulation functionality.
 */
public class cSimulator {
   
   //
   // Instance private declarations
   //
   private String cstrSimulationName;
   private String cstrText;
   private String cstrMode;
   private String cstrSimulationScript;
   private String cstrSimulationPath;
   private String cstrIcsPath;
   private String cstrRemoteServer;
   private long clngDurationMinutes;
   private long clngProcessCount;
   private boolean cbolShutdown;
   private long clngStartTime;
   private int cintEventIndex;
   private ArrayList cobjProcesses;
   private ArrayList cobjEvents;
   private ArrayList cobjExecutions;
   
   /**
    * Constructs a new instance
    * 
    * @throws Exception the exception message
    */
   public cSimulator() throws Exception {
      cstrSimulationName = null;
      cstrText = null;
      cstrMode = null;
      cstrSimulationScript = null;
      cstrSimulationPath = null;
      cstrIcsPath = "*NONE";
      cstrRemoteServer = "*NONE";
      clngDurationMinutes = 0;
      clngProcessCount = 0;
      cbolShutdown = false;
      clngStartTime = 0;
      cintEventIndex = 0;
      cobjProcesses = new ArrayList();
      cobjEvents = new ArrayList();
      cobjExecutions = new ArrayList();
   }
   
   /**
    * Processes the simulation from the configuration file.
    *
    * @param strConfiguration the simulation configuration file
    * @param strExecutionFile the simulation execution stack dump file
    * @throws Exception the exception message
    */
   public void process(String strConfiguration, String strExecutionFile) throws Exception {
      
      //
      // Parse the simulation configuration XML file
      //
      DocumentBuilderFactory objFactory = null;
      DocumentBuilder objBuilder = null;
      Document objDocument = null;
      try {
         objFactory = DocumentBuilderFactory.newInstance();
         objBuilder = objFactory.newDocumentBuilder();
         File objFile = new File(strConfiguration);
         if (!objFile.canRead()) {
            throw new Exception("Unable to read simulation configuration file (" + strConfiguration + ")");
         }
         objDocument = objBuilder.parse(objFile);
         processNode(objDocument.getChildNodes());
         if (cstrSimulationName == null) {
            throw new Exception("Simulation name is missing from the configuration file (" + strConfiguration + ")");
         }
         if (cstrMode == null || (!cstrMode.equals("*TEST") && !cstrMode.equals("*PROD"))) {
            throw new Exception("Simulation mode must be *TEST or *PROD in the configuration file (" + strConfiguration + ")");
         }
         if (cstrSimulationScript == null) {
            throw new Exception("Simulation script is missing from the configuration file (" + strConfiguration + ")");
         }
         if (cstrSimulationPath == null) {
            throw new Exception("Simulation path is missing from the configuration file (" + strConfiguration + ")");
         }
         if (clngDurationMinutes <= 0) {
            throw new Exception("Simulation duration is less than or equal to zero (" + strConfiguration + ")");
         }
         if (clngProcessCount <= 0) {
            throw new Exception("Simulation process count is less than or equal to zero (" + strConfiguration + ")");
         }
      } catch(Exception objException) {
         throw new Exception("ICS_SIMULATION - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
      
      //
      // Create the simulation executions from the event model
      //
      for (int i=0; i<cobjEvents.size(); i++) {
         ((cEvent)cobjEvents.get(i)).getExecutions(cobjExecutions, clngDurationMinutes);
      }
      Collections.sort(cobjExecutions);
      
      //
      // Dump the simulation executionstack when required
      //
      if (strExecutionFile != null) {
         PrintWriter objPrintWriter = new PrintWriter(new FileWriter(strExecutionFile, false));
         for (int i=0; i<cobjExecutions.size(); i++) {
            objPrintWriter.println("Delay: " + ((cExecution)cobjExecutions.get(i)).getDelay() + "Interface: " + ((cExecution)cobjExecutions.get(i)).getInterface());
         }
         objPrintWriter.close();
      }
      
      //
      // Create the simulation processes
      //
      for (int i=1; i<=clngProcessCount; i++) {
         cobjProcesses.add(new cProcess("PROCESS#" + i, this));
      }

      //
      // Start the simulation
      //
      String[] objStartTokens = new String[6];
      objStartTokens[0] = cstrSimulationScript;
      objStartTokens[1] = cstrSimulationName;
      objStartTokens[2] = cstrMode;
      objStartTokens[3] = "*START";
      objStartTokens[4] = cstrSimulationName;
      objStartTokens[5] = cstrSimulationPath;
      cExecution objStartExecution = new cExecution(cstrSimulationName,0,objStartTokens);
      objStartExecution.execute(cstrSimulationName);
      objStartExecution = null;
      
      //
      // Start the simulation
      //
      clngStartTime = System.currentTimeMillis();
      cintEventIndex = 0;

      //
      // Start the simulation processes
      //
      for (int i=0; i<cobjProcesses.size(); i++) {
         ((cProcess)cobjProcesses.get(i)).start();
      }

      //
      // Pause this thread until execution queue is exhausted
      // Stops when any inactive child processes are found
      //
      while (cintEventIndex < cobjExecutions.size()) {
         try {
            Thread.sleep(5000);
         } catch (InterruptedException objException) {}
         for (int i=0; i<cobjProcesses.size(); i++) {
            if (!((cProcess)cobjProcesses.get(i)).isActive()) {
               cintEventIndex = cobjExecutions.size();
            }
         }
      }

      //
      // Stop the simulation processes and wait for completion
      //
      for (int i=0; i<cobjProcesses.size(); i++) {
         ((cProcess)cobjProcesses.get(i)).stop();
      }
      boolean bolActive = true;
      while (bolActive) {
         bolActive = false;
         for (int i=0; i<cobjProcesses.size(); i++) {
            if (((cProcess)cobjProcesses.get(i)).isActive()) {
               bolActive = true;
            }
         }
      }

      //
      // Stop the simulation
      //
      String[] objStopTokens = new String[6];
      objStopTokens[0] = cstrSimulationScript;
      objStopTokens[1] = cstrSimulationName;
      objStopTokens[2] = cstrMode;
      objStopTokens[3] = "*STOP";
      objStopTokens[4] = cstrSimulationName;
      objStopTokens[5] = cstrSimulationPath;
      cExecution objStopExecution = new cExecution(cstrSimulationName,0,objStopTokens);
      objStopExecution.execute(cstrSimulationName);
      objStopExecution = null;
 
   }
   
   /**
    * Process the simulation XML node
    */
   private void processNode(org.w3c.dom.NodeList objNodeList) {
      org.w3c.dom.Node objNode = null;
      org.w3c.dom.NamedNodeMap objAttributeMap = null;
      org.w3c.dom.Node objAttributeNode = null;
      String[] strParameter = new String[20];
      for (int i=0;i<objNodeList.getLength();i++) {
         objNode = objNodeList.item(i);
         if (objNode.getNodeName().toUpperCase().equals("SIMULATION")) {
            if (objNode.hasAttributes()) {
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  if (objAttributeNode.getNodeName().toUpperCase().equals("NAME")) {
                     cstrSimulationName = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     cstrText = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("MODE")) {
                     cstrMode = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("SIMULATIONSCRIPT")) {
                     cstrSimulationScript = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("SIMULATIONPATH")) {
                     cstrSimulationPath = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("ICSPATH")) {
                     cstrIcsPath = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("REMOTESERVER")) {
                     cstrRemoteServer = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("DURATIONMINUTES")) {
                     clngDurationMinutes = Long.parseLong(objAttributeNode.getNodeValue());
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("PROCESSCOUNT")) {
                     clngProcessCount = Long.parseLong(objAttributeNode.getNodeValue());
                  }
               }
            }
            processNode(objNode.getChildNodes());
         } else if (objNode.getNodeName().toUpperCase().equals("EVENT")) {
            strParameter[0] = cstrMode;
            strParameter[1] = cstrSimulationName;
            strParameter[2] = cstrSimulationScript;
            strParameter[3] = cstrSimulationPath;
            strParameter[4] = cstrIcsPath;
            strParameter[5] = cstrRemoteServer;
            strParameter[6] = "*NONE";
            strParameter[7] = "*NONE";
            strParameter[8] = "*NONE";
            strParameter[9] = "0";
            strParameter[10] = "*NONE";
            if (objNode.hasAttributes()) {
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                  if (objAttributeNode.getNodeName().toUpperCase().equals("EXECTYPE")) {
                     strParameter[6] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("EXECINTERFACE")) {
                     strParameter[7] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("EXECFILE")) {
                     strParameter[8] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("EXECCOUNT")) {
                     strParameter[9] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     strParameter[10] = objAttributeNode.getNodeValue();
                  }
               }
               cobjEvents.add(new cEvent(strParameter));
            }
         }
      }
   }
   
   /**
    * Retrieve the next simulation execution
    *
    * @throws Exception the exception message
    */
   public synchronized cExecution getNextExecution() throws Exception {
      cExecution objExecution = null;
      if (cintEventIndex < cobjExecutions.size()) {
         long lngCurrentTime = System.currentTimeMillis();
         if ((clngStartTime + ((cExecution)cobjExecutions.get(cintEventIndex)).getDelay()) <= lngCurrentTime) {
            objExecution = (cExecution)cobjExecutions.get(cintEventIndex);
            cintEventIndex++;
         }
      }
      return objExecution;
   }
   
   /**
    * Usage and terminate method
    */
   protected static void usageAndTerminate() {
      System.out.println("Usage: com.isi.simulation.cSimulator [-configuration (simulation configuration file) -execution (execution stack dump file) -stacktrace]");
      System.exit(1);
   }

   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    *  -configuration = the simulation configuration file
    *  -stacktrace = java stack trace required
    * @param args the command line arguments
    */
   public static void main(String[] args) {
      
      //
      // Local variables
      //
      cSimulator objSimulator;
      
      //
      // Process the entry point request
      //
      try {
         
         //
         // Retrieve the command line arguments
         //
         String strConfiguration = null;
         String strExecutionFile = null;
         boolean bolStackTrace = false;
         try {
            for (int i=0;i<args.length;i++) {
               if (args[i].toUpperCase().equals("-CONFIGURATION")) {
                  strConfiguration = args[++i];
               } else if (args[i].toUpperCase().equals("-EXECUTION")) {
                  strExecutionFile = args[++i];
               } else if (args[i].toUpperCase().equals("-STACKTRACE")) {
                  bolStackTrace = true;
               }
            }
         } catch(ArrayIndexOutOfBoundsException e) {
            usageAndTerminate();
         }
         
         //
         // Check for valid arguments
         //
         if (strConfiguration == null) {
            usageAndTerminate();
         }
         
         //
         // Process the simulator
         //
         System.out.println(Calendar.getInstance().getTime() + " - START ICS_SIMULATION");
         objSimulator = new cSimulator();
         objSimulator.process(strConfiguration, strExecutionFile);
         System.out.println(Calendar.getInstance().getTime() + " - STOP ICS_SIMULATION");
         
      } catch (Throwable objThrowable) {
         StringWriter objStringWriter = new StringWriter();
         PrintWriter objPrintWriter = new PrintWriter(objStringWriter);
         objThrowable.printStackTrace(objPrintWriter);
         System.out.println(objStringWriter.getBuffer().toString());
      } finally {
         objSimulator = null;
      }
      
   }

}