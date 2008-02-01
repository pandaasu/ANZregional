/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cExecution
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;
import java.io.*;
import java.text.SimpleDateFormat;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the distribution execution functionality.
 */
public class cExecution {
   
   //
   // Instance private declarations
   //
   private cConfiguration cobjConfiguration;
   private HashMap cobjAttributes;
   private ArrayList cobjDistributions;
   private String cstrDistributionPath;
   private String cstrTransferPath;
   private String cstrTransformPath;
   private String cstrArchivePath;
   private String cstrSupportAddress;
   private String cstrSupportSubject;
   private String cstrSupportBody;
   private String cstrSuccessAddress;
   private String cstrSuccessSubject;
   private String cstrSuccessBody;

   /**
    * Constructs a new instance
    */
   public cExecution() {
      cobjConfiguration = new cConfiguration();
      cobjAttributes = new HashMap();
      cobjDistributions = new ArrayList();
      cstrDistributionPath = null;
      cstrTransferPath = null;
      cstrTransformPath = null;
      cstrArchivePath = null;
      cstrSupportAddress = null;
      cstrSupportSubject = null;
      cstrSupportBody = null;
      cstrSuccessAddress = null;
      cstrSuccessSubject = null;
      cstrSuccessBody = null;
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
    * Processes the distribution execution using the supplied configurtion.
    *
    * @param strConfiguration the distribution configuration file
    * @param strExecution the distribution execution file
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
            throw new Exception("Unable to read distribution execution file (" + strExecution + ")");
         }
         objDocument = objBuilder.parse(objFile);
         processNode(objDocument.getChildNodes());
         if (cobjAttributes.isEmpty()) {
            throw new Exception("Unable to find execution data in distribution execution file (" + strExecution + ")");
         }
         if (this.getAttribute("text") == null || this.getAttribute("text").equals("")) {
            throw new Exception("Execution attribute - text not supplied");
         }
         if (this.getAttribute("sourcePath") == null || this.getAttribute("sourcePath").equals("")) {
            throw new Exception("Execution attribute - source path not supplied");
         }
         if (this.getAttribute("sourceFiles") == null || this.getAttribute("sourceFiles").equals("")) {
            throw new Exception("Execution attribute - source files not supplied");
         }
         if (this.getAttribute("logFile") == null || this.getAttribute("logFile").equals("")) {
            throw new Exception("Execution attribute - log file not supplied");
         }
         if (this.getAttribute("emailSupportAddress") == null || this.getAttribute("emailSupportAddress").equals("")) {
            throw new Exception("Execution attribute - email support address not supplied");
         }
         if (this.getAttribute("emailSupportSubject") == null || this.getAttribute("emailSupportSubject").equals("")) {
            throw new Exception("Execution attribute - email support subject not supplied");
         }
         if (this.getAttribute("emailSupportBody") == null || this.getAttribute("emailSupportBody").equals("")) {
            throw new Exception("Execution attribute - email support body not supplied");
         }
         if (this.getAttribute("emailSuccessAddress") != null && !this.getAttribute("emailSuccessAddress").equals("")) {
            if (this.getAttribute("emailSuccessSubject") == null || this.getAttribute("emailSuccessSubject").equals("")) {
               throw new Exception("Execution attribute - email success subject must be supplied when success address supplied");
            }
            if (this.getAttribute("emailSuccessBody") == null || this.getAttribute("emailSuccessBody").equals("")) {
               throw new Exception("Execution attribute - email success body must be supplied when success address supplied");
            }
         }
      } catch(Exception objException) {
         throw new Exception("Distribution - Execution Parsing Failed - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
         
      //
      // Fix execution attributes
      //
      if (this.getAttribute("sourcePath").endsWith(File.separator)) {
         this.setAttribute("sourcePath", this.getAttribute("sourcePath").substring(0,this.getAttribute("sourcePath").length()-1));
      }
      if (!(new File(this.getAttribute("sourcePath"))).isDirectory()) {
         throw new Exception("Attribute (sourcePath) is not a directory");
      }
      
      //
      // Initialise the execution identifier from the timestamp
      //
      String strIdentifier = "execution_" + (new SimpleDateFormat("yyyyMMddHHmmssSSS")).format(Calendar.getInstance().getTime());
      cobjConfiguration.setAttribute("absoluteLogFile", cobjConfiguration.getAttribute("logPath") + File.separator + strIdentifier + "_" + this.getAttribute("logFile"));
         
      //
      // Start the log file
      //
      cobjConfiguration.putLogLine("[START] FILE DISTRIBUTION UTILITY LOG - Identifier (" + strIdentifier + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Source Path (" + this.getAttribute("sourcePath") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Source Files (" + this.getAttribute("sourceFiles") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Log File (" + this.getAttribute("logFile") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Email Support Address (" + this.getAttribute("emailSupportAddress") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Email Support Subject (" + this.getAttribute("emailSupportSubject") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Email Support Body (" + this.getAttribute("emailSupportBody") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Email Success Address (" + this.getAttribute("emailSuccessAddress") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Email Success Subject (" + this.getAttribute("emailSuccessSubject") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Email Success Body (" + this.getAttribute("emailSuccessBody") + ")");
      cobjConfiguration.putLogLine("--> EXECUTION - Post Processing (" + this.getAttribute("postProcessing") + ")");
  
      //
      // Process the execution stream
      //
      boolean bolException = false;
      try {
         
         //
         // Set the temporary path names
         //
         cstrDistributionPath = cobjConfiguration.getAttribute("distributionPath") + File.separator + strIdentifier;
         cstrTransferPath = cobjConfiguration.getAttribute("transferPath") + File.separator + strIdentifier;
         cstrTransformPath = cobjConfiguration.getAttribute("transformPath") + File.separator + strIdentifier;
         cstrArchivePath = cobjConfiguration.getAttribute("archivePath") + File.separator + strIdentifier + ".zip";
         cstrSupportAddress = this.getAttribute("emailSupportAddress");
         cstrSupportSubject = this.getAttribute("emailSupportSubject");
         cstrSupportBody = this.getAttribute("emailSupportBody");
         cstrSupportSubject = cstrSupportSubject.replaceAll("(?i)@@FDU_EXECUTION", strIdentifier);
         cstrSupportSubject = cstrSupportSubject.replaceAll("(?i)@@FDU_LOG_FILE", strIdentifier + "_" + this.getAttribute("logFile"));
         cstrSupportBody = cstrSupportBody.replaceAll("(?i)@@FDU_EXECUTION", strIdentifier);
         cstrSupportBody = cstrSupportBody.replaceAll("(?i)@@FDU_LOG_FILE", strIdentifier + "_" + this.getAttribute("logFile"));
         if (this.getAttribute("emailSuccessAddress") != null && !this.getAttribute("emailSuccessAddress").equals("")) {
            cstrSuccessAddress = this.getAttribute("emailSuccessAddress");
            cstrSuccessSubject = this.getAttribute("emailSuccessSubject");
            cstrSuccessBody = this.getAttribute("emailSuccessBody");
            cstrSuccessSubject = cstrSuccessSubject.replaceAll("(?i)@@FDU_EXECUTION", strIdentifier);
            cstrSuccessSubject = cstrSuccessSubject.replaceAll("(?i)@@FDU_LOG_FILE", strIdentifier + "_" + this.getAttribute("logFile"));
            cstrSuccessBody = cstrSuccessBody.replaceAll("(?i)@@FDU_EXECUTION", strIdentifier);
            cstrSuccessBody = cstrSuccessBody.replaceAll("(?i)@@FDU_LOG_FILE", strIdentifier + "_" + this.getAttribute("logFile"));
         }
         
         //
         // Create the execution
         //
         cobjConfiguration.createExecution(cstrDistributionPath, cstrTransferPath, cstrTransformPath);
         
         //
         // Loads the distribution directory from the source directory
         // **note** this is the static directory that all distributions process from
         //
         if (cobjConfiguration.loadDistribution(this.getAttribute("sourcePath"), this.getAttribute("sourceFiles"), cstrDistributionPath) != 0) {

            //
            // Process the distribution list
            //
            for (int i=0; i<cobjDistributions.size(); i++) {
               ((cDistribution)cobjDistributions.get(i)).process(cobjConfiguration, cstrDistributionPath, cstrTransferPath, cstrTransformPath);
            }

            //
            // Complete the execution directories
            //
            cobjConfiguration.completeExecution(cstrDistributionPath, cstrArchivePath, this.getAttribute("postProcessing"), true);
            
         } else {
            
            //
            // Complete the execution directories
            //
            cobjConfiguration.completeExecution(cstrDistributionPath, cstrArchivePath, this.getAttribute("postProcessing"), false);
         
         }

      } catch(Exception objException) {
         bolException = true;
         cobjConfiguration.putLogLine("--> EMAIL - Send Support Email (" + this.getAttribute("emailSupportAddress") + ")");
         cobjConfiguration.sendEmail(cstrSupportAddress, cstrSupportSubject, cstrSupportBody);
         throw new Exception("Distribution - Execution Process Failed - " + objException.getMessage());
      } finally {
         try {
            cobjConfiguration.deleteExecution(cstrTransferPath, cstrTransformPath);
         } catch(Exception objException) {
            throw new Exception("Distribution - Execution Process Failed - " + objException.getMessage());
         }
         if (!bolException) {
            if (this.getAttribute("emailSuccessAddress") != null && !this.getAttribute("emailSuccessAddress").equals("")) {
               cobjConfiguration.putLogLine("--> EMAIL - Send Success Email (" + this.getAttribute("emailSuccessAddress") + ")");
               cobjConfiguration.sendEmail(cstrSuccessAddress, cstrSuccessSubject, cstrSuccessBody);
            }
         }
         cobjConfiguration.putLogLine("[END] FILE DISTRIBUTION UTILITY LOG");
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
         } else if (objNode.getNodeName().toUpperCase().equals("DISTRIBUTION")) {
            if (objNode.hasAttributes()) {
               String[] strParameters = new String[50];
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                   if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     strParameters[0] = objAttributeNode.getNodeValue();
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to create distribution - text not supplied");
               }
               cobjDistributions.add(new cDistribution(strParameters));
               processNode(objNode.getChildNodes());
            }
         } else if (objNode.getNodeName().toUpperCase().equals("TRANSFORM")) {
            if (objNode.hasAttributes()) {
               String[] strParameters = new String[50];
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                   if (objAttributeNode.getNodeName().toUpperCase().equals("TYPE")) {
                     strParameters[0] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     strParameters[1] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("FILES")) {
                     strParameters[2] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("OUTPUTNAME")) {
                     strParameters[3] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("OUTPUTEXTENSION")) {
                     strParameters[4] = objAttributeNode.getNodeValue();
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to load transform action - type not supplied");
               }
               if (strParameters[1] == null || strParameters[1].equals("")) {
                  throw new Exception("Unable to load transform action - text not supplied");
               }
               if (strParameters[2] == null || strParameters[2].equals("")) {
                  throw new Exception("Unable to load transform action - files not supplied");
               }
               if (strParameters[3] == null || strParameters[3].equals("")) {
                  throw new Exception("Unable to load transform action - output name not supplied");
               }
               if (strParameters[4] == null || strParameters[4].equals("")) {
                  throw new Exception("Unable to load transform action - output extension not supplied");
               }
               if (!cobjConfiguration.isTransform(strParameters[0])) {
                  throw new Exception("Unable to load transform action - transform type (" + strParameters[0] + ") not registered in configuration");
               }
               if (cobjConfiguration.getTransformMode(strParameters[0]).equalsIgnoreCase("*SINGLE")) {
                  if (!strParameters[3].equalsIgnoreCase("@@FDU_SAME")) {
                     throw new Exception("Unable to load transform action - output name must be @@FDU_SAME for *SINGLE mode transform type (" + strParameters[0] + ")");
                  }
               }
               if (cobjConfiguration.getTransformMode(strParameters[0]).equalsIgnoreCase("*GROUP")) {
                  if (strParameters[3].equalsIgnoreCase("@@FDU_SAME")) {
                     throw new Exception("Unable to load transform action - output name must not be @@FDU_SAME for *GROUP mode transform type (" + strParameters[0] + ")");
                  }
                  if (strParameters[4].equalsIgnoreCase("@@FDU_SAME")) {
                     throw new Exception("Unable to load transform action - output extension must not be @@FDU_SAME for *GROUP mode transform type (" + strParameters[0] + ")");
                  }
               }
               ((cDistribution)cobjDistributions.get(cobjDistributions.size()-1)).addAction(new cTransformAction(strParameters, cobjConfiguration.getTransformMode(strParameters[0])));
            }
         } else if (objNode.getNodeName().toUpperCase().equals("TRANSFER")) {
            if (objNode.hasAttributes()) {
               String[] strParameters = new String[50];
               HashMap objChildAttributes = new HashMap();
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                   if (objAttributeNode.getNodeName().toUpperCase().equals("TYPE")) {
                     strParameters[0] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     strParameters[1] = objAttributeNode.getNodeValue();
                  } else {
                     objChildAttributes.put(objAttributeNode.getNodeName().toUpperCase(), objAttributeNode.getNodeValue());
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to load transfer action - type not supplied");
               }
               if (strParameters[1] == null || strParameters[1].equals("")) {
                  throw new Exception("Unable to load transfer action - text not supplied");
               }
               if (!cobjConfiguration.isTransfer(strParameters[0])) {
                  throw new Exception("Unable to load transfer action - transfer type (" + strParameters[0] + ") not registered in configuration");
               }
               ((cDistribution)cobjDistributions.get(cobjDistributions.size()-1)).addAction(new cTransferAction(strParameters, objChildAttributes, cobjConfiguration.getTransferScript(strParameters[0])));
            }
         }
      }
   }
   
   /**
   * Usage and terminate method
   */
   protected static void usageAndTerminate() {
      System.out.println("Usage: com.isi.distribution.cExecution [-configuration Distribution configuration file -execution Distribution execution file]");
      System.exit(1);
   }

   /**
    * Main method - provides an entry point to the application. This method currently supports
    * the following combination of arguments:
    *  -configuration = the distribution configuration file
    *  -execution = the distribution execution file
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
         // Process the execution
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