/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cConfiguration
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;
import java.util.zip.*;
import java.io.*;
import java.text.SimpleDateFormat;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.w3c.dom.Document;
import org.w3c.dom.DOMException;

/**
 * This class implements the distribution configuration functionality.
 */
public class cConfiguration {
   
   //
   // Instance private declarations
   //
   private HashMap cobjAttributes;
   private HashMap cobjTransforms;
   private HashMap cobjTransfers;
   int cintEmailPort;
   long clngPollingInterval;

   /**
    * Constructs a new instance
    */
   public cConfiguration() {
      cobjAttributes = new HashMap();
      cobjTransforms = new HashMap();
      cobjTransfers = new HashMap();
      cintEmailPort = 0;
      clngPollingInterval = 0;
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
    * Checks the configuration for a registered transform
    *
    * @param strName the transform name
    * @return boolean the transform name existance
    */
   public boolean isTransform(String strName) {
      return cobjTransforms.containsKey(strName.toUpperCase());
   }
   
   /**
    * Checks the configuration for a registered transfer
    *
    * @param strName the transfer name
    * @return boolean the transfer name existance
    */
   public boolean isTransfer(String strName) {
      return cobjTransfers.containsKey(strName.toUpperCase());
   }
   
   /**
    * Gets the transform mode
    *
    * @param strName the transform name
    * @return String the transform mode
    */
   public String getTransformMode(String strName) {
      return ((cTransform)cobjTransforms.get(strName.toUpperCase())).getMode();
   }
   
   /**
    * Gets the transfer script
    *
    * @param strName the transform name
    * @return String the transfer script
    */
   public String getTransferScript(String strName) {
      return ((cTransfer)cobjTransfers.get(strName.toUpperCase())).getScript();
   }
   
   /**
    * Processes a registered transform
    *
    * @param strName the transform name
    * @param strInputFiles the transform input file array
    * @param strOutputFiles the transform output file array
    * @throws Exception the exception message
    */
   public void  processTransform(String strName, String[] strInputFiles, String[] strOutputFiles) throws Exception {
      ((cTransform)cobjTransforms.get(strName.toUpperCase())).process(strInputFiles, strOutputFiles);
   }
   
   /**
    * Processes a registered transfer
    *
    * @param strName the transfer name
    * @param strInputFile the transfer input file
    * @param strScript the transfer script
    * @return String the transfer output
    * @throws Exception the exception message
    */
   public String  processTransfer(String strName, String strInputFile, String strScript) throws Exception {
      return ((cTransfer)cobjTransfers.get(strName.toUpperCase())).process(strInputFile, strScript);
   }
   
   /**
    * Creates the execution
    *
    * @param strDistributionPath the temporary distribution path
    * @param strTransferPath the temporary transfer path
    * @param strTransformPath the temporary transform path
    * @throws Exception the exception message
    */
   public void createExecution(String strDistributionPath, String strTransferPath, String strTransformPath) throws Exception {
      
      //
      // Output the log start
      //
      putLogLine("--> CREATE EXECUTION");
      
      //
      // Create the execution temporary directories
      //
      putLogLine("-----> CREATE WORK DIRECTORY - Distribution");
      if (!(new File(strDistributionPath)).mkdir()) {
         putLogLine("-----> **EXCEPTION** - Unable to create directory (" + strDistributionPath + ")");
         throw new Exception("Unable to create directory (" + strDistributionPath + ")");
      }
      putLogLine("-----> CREATE TEMPORARY DIRECTORY - Transfer");
      if (!(new File(strTransferPath)).mkdir()) {
         putLogLine("-----> **EXCEPTION** - Unable to create directory (" + strTransferPath + ")");
         throw new Exception("Unable to create directory (" + strTransferPath + ")");
      }
      putLogLine("-----> CREATE TEMPORARY DIRECTORY - Transform");
      if (!(new File(strTransformPath)).mkdir()) {
         putLogLine("-----> **EXCEPTION** - Unable to create directory (" + strTransformPath + ")");
         throw new Exception("Unable to create directory (" + strTransformPath + ")");
      }
      
   }
   
   /**
    * Completes the execution
    *
    * @param strDistributionPath the temporary distribution path
    * @param strArchivePath the archive path
    * @param strPostProcessing the post processing action
    * @param bolFiles the distribution files existence
    * @throws Exception the exception message
    */
   public void completeExecution(String strDistributionPath, String strArchivePath, String strPostProcessing, boolean bolFiles) throws Exception {
      
      //
      // Output the log start
      //
      putLogLine("--> COMPLETE EXECUTION");
      
      //
      // Perform the post processing as required
      //
      if (bolFiles) {
         if (strPostProcessing.equalsIgnoreCase("*ZIP_ARCHIVE") || strPostProcessing.equalsIgnoreCase("*ZIP_ARCHIVE_DELETE")) {
            putLogLine("-----> POST PROCESSING - *ZIP_ARCHIVE Work Directory - Distribution");
            File[] objChildren = retrieveFileList(strDistributionPath, "*");
            String[] strChildren = retrieveNameList(objChildren);
            compressFiles(strChildren, strArchivePath);
         }
      }
      if (strPostProcessing.equalsIgnoreCase("*ZIP_ARCHIVE_DELETE") || strPostProcessing.equalsIgnoreCase("*DELETE")) {
         putLogLine("-----> POST PROCESSING - *DELETE Work Directory - Distribution");
         if (!deleteDirectory(new File(strDistributionPath))) {
            putLogLine("-----> **EXCEPTION** - Unable to delete directory (" + strDistributionPath + ")");
            throw new Exception("Unable to delete directory (" + strDistributionPath + ")");
         }
      }
      
   }
   
   /**
    * Deletes the execution
    *
    * @param strTransferPath the temporary transfer path
    * @param strTransformPath the temporary transform path
    * @throws Exception the exception message
    */
   public void deleteExecution(String strTransferPath, String strTransformPath) throws Exception {
      
      //
      // Output the log start
      //
      putLogLine("--> DELETE EXECUTION");
      
      //
      // Delete the execution temporary directories
      //
      putLogLine("-----> DELETE TEMPORARY DIRECTORY - Transfer");
      if (!deleteDirectory(new File(strTransferPath))) {
         putLogLine("-----> **EXCEPTION** - Unable to delete directory (" + strTransferPath + ")");
         throw new Exception("Unable to delete directory (" + strTransferPath + ")");
      }
      putLogLine("-----> DELETE TEMPORARY DIRECTORY - Transform");
      if (!deleteDirectory(new File(strTransformPath))) {
         putLogLine("-----> **EXCEPTION** - Unable to delete directory (" + strTransformPath + ")");
         throw new Exception("Unable to delete directory (" + strTransformPath + ")");
      }
      
   }
   
   /**
    * Loads the distribution directory from the source directory
    *
    * @param strSourcePath the path to the source file
    * @param strSourceFiles the source file filter
    * @param strDistributionPath the temporary distribution path
    * @return int the selected file count
    * @throws Exception the exception message
    */
   public int loadDistribution(String strSourcePath, String strSourceFiles, String strDistributionPath) throws Exception {
      
      //
      // Output the log start
      //
      putLogLine("--> LOAD DISTRIBUTION DIRECTORY");
      
      //
      // Retrieve the source path files
      // **notes** 1. Only move files that have not been modified in the last x minutes
      //           2. Log warning for any files that fail to move
      //
      int intReturn = 0; 
      long lngStartMilliseconds = Calendar.getInstance().getTimeInMillis();
      File objDistributionPath = new File(strDistributionPath);
      File[] objChildren = retrieveFileList(strSourcePath, strSourceFiles);
      for (int i=0; i<objChildren.length; i++) {
         if (objChildren[i].isFile()) {
            if ((lngStartMilliseconds - objChildren[i].lastModified()) / 60000 >= clngPollingInterval) {
               putLogLine("-----> MOVING FILE - Moving file (" + objChildren[i].getName() + ") from source directory to distribution directory");
               if (!objChildren[i].renameTo(new File(objDistributionPath, objChildren[i].getName()))) {
                  putLogLine("-----> **WARNING** - Unable to move file (" + objChildren[i].getName() + ") from source directory to distribution directory");
               } else {
                  intReturn++;
               }
            }
         }
      }
      if (intReturn == 0) {
         putLogLine("-----> **WARNING** - No files were available within the polling interval to move from source directory to distribution directory");
      }
      return intReturn;
   }
   
   /**
    * Refreshes the transfer directory from the distribution directory
    *
    * @param strDistributionPath the temporary distribution path
    * @param strTransferPath the temporary transfer path
    * @throws Exception the exception message
    */
   public void refreshTransfer(String strDistributionPath, String strTransferPath) throws Exception {
      
      //
      // Output the log start
      //
      putLogLine("-----> REFRESH TRANSFER DIRECTORY");
      
      //
      // Retrieve the distribution path files
      //
      File objTransferPath = new File(strTransferPath);
      clearDirectory(objTransferPath);
      File[] objChildren = retrieveFileList(strDistributionPath, "*");
      for (int i=0; i<objChildren.length; i++) {
         try {
            copyFile(objChildren[i], new File(objTransferPath, objChildren[i].getName()));
         } catch(Exception objException) {
            putLogLine("-----> **EXCEPTION** - Unable to copy file (" + objChildren[i].getName() + ") from distribution directory to transfer directory");
            throw new Exception("Unable to copy file (" + objChildren[i].getName() + ") from distribution directory to transfer directory");
         }
      }
      
   }
   
   /**
    * Method to retrieve a filtered file list
    *
    * @param strPath the file path
    * @param strFile the file name
    * @returns File[] the return file list
    * @throws Exception the exception message
    */
   public File[] retrieveFileList(String strPath, String strFile) throws Exception {
      File[] objChildren;
      StringBuffer strBuffer = new StringBuffer();
      if (strFile.equals("*")) {
         strBuffer.append("*");
      } else {
         char[] chrName = strFile.toCharArray();
         for (int i=0; i<chrName.length; i++) {
            if (chrName[i] == '*') {
               strBuffer.append(".*");
            } else if (chrName[i] == '?') {
               strBuffer.append(".");
            } else if ("+()^$.{}[]|\\".indexOf(chrName[i]) != -1) {
               strBuffer.append("\\").append(chrName[i]);
            } else {
               strBuffer.append(chrName[i]);
            } 
         }
      }
      final String strMatch = strBuffer.toString();
      File objFile = new File(strPath);
      if (objFile.isDirectory()) {
         objChildren = objFile.listFiles(
            new FilenameFilter() {
               public boolean accept(File objDirectory, String strName) {
                  if (strMatch.equals("*")) {
                     return true;
                  }
                  return (strName.toLowerCase().matches(strMatch));
               }
            }
         );
      } else {
         objChildren = new File[0];
      }
      return objChildren;
   }
   
   /**
    * Method to retrieve a filtered name list
    *
    * @param objFiles the file array
    * @returns String[] the return file names
    * @throws Exception the exception message
    */
   public String[] retrieveNameList(File[] objFiles) throws Exception {
      int intFiles = 0;
      for (int i=0; i<objFiles.length; i++) {
         if (objFiles[i].isFile()) {
            intFiles++;    
         }
      }
      String[] strChildren = new String[intFiles];
      for (int i=0; i<objFiles.length; i++) {
         if (objFiles[i].isFile()) {
            strChildren[i] = objFiles[i].getCanonicalPath();    
         }
      }
      return strChildren;
   }
   
   /**
    * Method to clear a directory and all children
    *
    * @param objFile the directory reference
    * @returns boolean the return state
    * @throws Exception the exception message
    */
   public boolean clearDirectory(File objFile) throws Exception {
      if (objFile.isDirectory()) {
         String[] strChildren = objFile.list();
         for (int i=0; i<strChildren.length; i++) {
            File objWork = new File(objFile, strChildren[i]);
            if (objWork.isFile()) {
               if (!objWork.delete()) {
                  return false;
               }
            } else if (objWork.isDirectory()) {
               if (!deleteDirectory(objWork)) {
                  return false;
               }
            }
         }
      }
      return true;
   }
   
   /**
    * Method to delete a directory and all children
    *
    * @param objFile the directory reference
    * @returns boolean the return state
    * @throws Exception the exception message
    */
   public boolean deleteDirectory(File objFile) throws Exception {
      if (objFile.isDirectory()) {
         String[] strChildren = objFile.list();
         for (int i=0; i<strChildren.length; i++) {
            if (!deleteDirectory(new File(objFile, strChildren[i]))) {
               return false;
            }
         }
      }
      return objFile.delete();
   }
   
   /**
    * Method to copy a file
    *
    * @param objSource the source file reference
    * @param objTarget the target file reference
    * @throws Exception the exception message
    */
   public void copyFile(File objSource, File objTarget) throws Exception {
      InputStream objInputStream = new FileInputStream(objSource);
      OutputStream objOutputStream = new FileOutputStream(objTarget);
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      while ((intLength = objInputStream.read(bytBuffer)) > 0) {
         objOutputStream.write(bytBuffer, 0 ,intLength);
      }
      objInputStream.close();
      objOutputStream.close();
      objInputStream = null;
      objOutputStream = null;
   }
   
   /**
    * Method to compress files
    *
    * @param strInputFiles the input file array
    * @param strOutputFile the output file
    * @throws Exception the exception message
    */
   public void compressFiles(String[] strInputFiles, String strOutputFile) throws Exception {
      ZipOutputStream objOutputStream = null;
      FileInputStream objInputStream = null;
      byte[] bytBuffer = new byte[4096];
      int intLength = 0;
      try {
         objOutputStream = new ZipOutputStream(new FileOutputStream(strOutputFile));
         for (int i=0; i<strInputFiles.length; i++) {
            objOutputStream.putNextEntry(new ZipEntry(new File(strInputFiles[i]).getName()));
            objInputStream = new FileInputStream(strInputFiles[i]);
            while ((intLength = objInputStream.read(bytBuffer)) > 0) {
               objOutputStream.write(bytBuffer,0,intLength);
            }
            objInputStream.close();
            objOutputStream.closeEntry();
         }
         objOutputStream.close();
      } catch(Exception objException) {
         throw new Exception("Compress Files Failed - " + objException.getMessage());
      } finally {
         objOutputStream = null;
         objInputStream = null;
      }
   }
   
   /**
    * Method to send an email
    *
    * @param strAddress the email address
    * @param strSubject the email subject
    * @param strSubject the email body
    * @throws Exception the exception message
    */
   public void sendEmail(String strAddress, String strSubject, String strBody) throws Exception {
      cEmail objEmail = new cEmail();
      try {
         objEmail.send(this.getAttribute("emailServer"), cintEmailPort, this.getAttribute("emailFrom"), strAddress, strSubject, strBody);
      } catch(Exception objException) {
         throw new Exception("Email Failed - " + objException.getMessage());
      } finally {
         objEmail = null;
      }
   }
   
   /**
    * Method to put a log line
    *
    * @param strData the log data
    * @throws Exception the exception message
    */
   public void putLogLine(String strData) throws Exception {
      PrintWriter objPrintWriter = new PrintWriter(new FileWriter(this.getAttribute("absoluteLogFile"), true));
      objPrintWriter.println((new SimpleDateFormat("yyyy/mm/dd HH:mm:ss")).format(Calendar.getInstance().getTime()) + " " + strData);
      objPrintWriter.close();
   }
   
   /**
    * Loads the distribution configuration.
    *
    * @param strConfiguration the distribution configuration file
    * @throws Exception the exception message
    */
   public void load(String strConfiguration) throws Exception {

      //
      // Clear the configuration maps
      //
      cobjAttributes.clear();
      cobjTransforms.clear();
      cobjTransfers.clear();
      
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
            throw new Exception("Unable to read distribution configuration file (" + strConfiguration + ")");
         }
         objDocument = objBuilder.parse(objFile);
         processNode(objDocument.getChildNodes());
         if (cobjAttributes.isEmpty()) {
            throw new Exception("Unable to find configuration data in distribution configuration file (" + strConfiguration + ")");
         }
         if (this.getAttribute("text") == null || this.getAttribute("text").equals("")) {
            throw new Exception("Configuration attribute - text not supplied");
         }
         if (this.getAttribute("sourceHost") == null || this.getAttribute("sourceHost").equals("")) {
            throw new Exception("Configuration attribute - source host not supplied");
         }
         if (this.getAttribute("binPath") == null || this.getAttribute("binPath").equals("")) {
            throw new Exception("Configuration attribute - binary path not supplied");
         }
         if (this.getAttribute("logPath") == null || this.getAttribute("logPath").equals("")) {
            throw new Exception("Configuration attribute - log path not supplied");
         }
         if (this.getAttribute("distributionPath") == null || this.getAttribute("distributionPath").equals("")) {
            throw new Exception("Configuration attribute - distribution path not supplied");
         }
         if (this.getAttribute("transferPath") == null || this.getAttribute("transferPath").equals("")) {
            throw new Exception("Configuration attribute - transfer path not supplied");
         }
         if (this.getAttribute("transformPath") == null || this.getAttribute("transformPath").equals("")) {
            throw new Exception("Configuration attribute - transform path not supplied");
         }
         if (this.getAttribute("archivePath") == null || this.getAttribute("archivePath").equals("")) {
            throw new Exception("Configuration attribute - archive path not supplied");
         }
         if (this.getAttribute("pollingInterval") == null || this.getAttribute("pollingInterval").equals("")) {
            throw new Exception("Configuration attribute - polling interval not supplied");
         }
         if (this.getAttribute("emailServer") == null || this.getAttribute("emailServer").equals("")) {
            throw new Exception("Configuration attribute - email server not supplied");
         }
         if (this.getAttribute("emailPort") == null || this.getAttribute("emailPort").equals("")) {
            throw new Exception("Configuration attribute - email port not supplied");
         }
         if (this.getAttribute("emailFrom") == null || this.getAttribute("emailFrom").equals("")) {
            throw new Exception("Configuration attribute - email from not supplied");
         }
      } catch(Exception objException) {
         throw new Exception("Distribution - Configuration Load Failed - " + objException.getMessage());
      } finally {
         objDocument = null;
         objBuilder = null;
         objFactory = null;
      }
         
      //
      // Validate the configuration attributes
      //
      try {
         if (this.getAttribute("binPath").endsWith(File.separator)) {
            this.setAttribute("binPath", this.getAttribute("binPath").substring(0,this.getAttribute("binPath").length()-1));
         }
         if (!(new File(this.getAttribute("binPath"))).isDirectory()) {
            throw new Exception("Attribute (binPath) is not a directory");
         }
         if (this.getAttribute("logPath").endsWith(File.separator)) {
            this.setAttribute("logPath", this.getAttribute("logPath").substring(0,this.getAttribute("logPath").length()-1));
         }
         if (!(new File(this.getAttribute("logPath"))).isDirectory()) {
            throw new Exception("Attribute (logPath) is not a directory");
         }
         if (this.getAttribute("distributionPath").endsWith(File.separator)) {
            this.setAttribute("distributionPath", this.getAttribute("distributionPath").substring(0,this.getAttribute("distributionPath").length()-1));
         }
         if (!(new File(this.getAttribute("distributionPath"))).isDirectory()) {
            throw new Exception("Attribute (distributionPath) is not a directory");
         }
         if (this.getAttribute("transferPath").endsWith(File.separator)) {
            this.setAttribute("transferPath", this.getAttribute("transferPath").substring(0,this.getAttribute("transferPath").length()-1));
         }
         if (!(new File(this.getAttribute("transferPath"))).isDirectory()) {
            throw new Exception("Attribute (transferPath) is not a directory");
         }
         if (this.getAttribute("transformPath").endsWith(File.separator)) {
            this.setAttribute("transformPath", this.getAttribute("transformPath").substring(0,this.getAttribute("transformPath").length()-1));
         }
         if (!(new File(this.getAttribute("transformPath"))).isDirectory()) {
            throw new Exception("Attribute (transformPath) is not a directory");
         }
         if (this.getAttribute("archivePath").endsWith(File.separator)) {
            this.setAttribute("archivePath", this.getAttribute("archivePath").substring(0,this.getAttribute("archivePath").length()-1));
         }
         if (!(new File(this.getAttribute("archivePath"))).isDirectory()) {
            throw new Exception("Attribute (archivePath) is not a directory");
         }
         clngPollingInterval = Long.parseLong(this.getAttribute("pollingInterval"));
         cintEmailPort = Integer.parseInt(this.getAttribute("emailPort"));
      } catch(Exception objException) {
         throw new Exception("Distribution - Configuration Load Failed - " + objException.getMessage());
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
         } else if (objNode.getNodeName().toUpperCase().equals("REGISTERTRANSFORM")) {
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
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("MODE")) {
                     strParameters[3] = objAttributeNode.getNodeValue();
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to register transform - code not supplied");
               }
               if (strParameters[1] == null || strParameters[1].equals("")) {
                  throw new Exception("Unable to register transform - text not supplied");
               }
               if (strParameters[2] == null || strParameters[2].equals("")) {
                  throw new Exception("Unable to register transform - class not supplied");
               }
               if (strParameters[3] == null || strParameters[3].equals("")) {
                  throw new Exception("Unable to register transform - mode not supplied");
               }
               if (!strParameters[3].equalsIgnoreCase("*SINGLE") && !strParameters[3].equalsIgnoreCase("*GROUP")) {
                  throw new Exception("Unable to register transform - mode must be *SINGLE or *GROUP");
               }
               if (cobjTransforms.containsKey(strParameters[0].toUpperCase())) {
                  throw new Exception("Unable to register transform - already registered");
               }
               cobjTransforms.put(strParameters[0].toUpperCase(), new cTransform(strParameters));
            }
         } else if (objNode.getNodeName().toUpperCase().equals("REGISTERTRANSFER")) {
            if (objNode.hasAttributes()) {
               String[] strParameters = new String[20];
               objAttributeMap = objNode.getAttributes();
               for (int j=0;j<objAttributeMap.getLength();j++) {
                  objAttributeNode = objAttributeMap.item(j);
                   if (objAttributeNode.getNodeName().toUpperCase().equals("CODE")) {
                     strParameters[0] = objAttributeNode.getNodeValue().toUpperCase();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("TEXT")) {
                     strParameters[1] = objAttributeNode.getNodeValue();
                  } else if (objAttributeNode.getNodeName().toUpperCase().equals("SCRIPT")) {
                     strParameters[2] = objAttributeNode.getNodeValue();
                  }
               }
               if (strParameters[0] == null || strParameters[0].equals("")) {
                  throw new Exception("Unable to register transfer - code not supplied");
               }
               if (strParameters[1] == null || strParameters[1].equals("")) {
                  throw new Exception("Unable to register transfer - text not supplied");
               }
               if (strParameters[2] == null || strParameters[2].equals("")) {
                  throw new Exception("Unable to register transfer - script not supplied");
               }
               if (cobjTransfers.containsKey(strParameters[0].toUpperCase())) {
                  throw new Exception("Unable to register transfer - already registered");
               }
               cobjTransfers.put(strParameters[0].toUpperCase(), new cTransfer(strParameters));
            }
         }
      }
   }

}