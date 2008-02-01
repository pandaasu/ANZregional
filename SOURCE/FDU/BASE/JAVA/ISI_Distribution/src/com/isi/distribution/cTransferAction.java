/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cTransferAction
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;
import java.io.*;

/**
 * This class implements the transfer action functionality.
 */
public class cTransferAction {
   
   //
   // Instance private declarations
   //
   private String cstrType;
   private String cstrText;
   private HashMap cobjAttributes;
   private String cstrScript;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the transfer action parameter array
    * @param objAttributes the transfer action attributes map
    * @param strMode the transfer action script
    */
   public cTransferAction(String[] strParameters, HashMap objAttributes, String strScript) {
      cstrType = strParameters[0];
      cstrText = strParameters[1];
      cobjAttributes = objAttributes;
      cstrScript = strScript;
   }
   
   /**
    * Processes the distribution transfer action
    *
    * @param objConfiguration the configuration reference
    * @param strTransferPath the transfer path
    * @throws Exception the exception message
    */
   public void process(cConfiguration objConfiguration, String strTransferPath) throws Exception {
      
      //
      // Output the log start
      //
      objConfiguration.putLogLine("-----> TRANSFER - " + cstrType + " - " + cstrText);
      
      //
      // Process the transfer
      //
      try {
         File[] objFiles = objConfiguration.retrieveFileList(strTransferPath, "*");
         for (int i=0; i<objFiles.length; i++) {
         if (!objFiles[i].isDirectory()) {
            String strScript = objConfiguration.getAttribute("binPath") + File.separator + cstrScript;
            Object[] objKeys = cobjAttributes.keySet().toArray();
            for (int j=0;j<objKeys.length;j++) {
               strScript = strScript.replaceAll("(?i)@@" + (String)objKeys[j], ((String)cobjAttributes.get((String)objKeys[j])).replaceAll("(?i)@@FDU_SAME", objFiles[i].getName()).replaceAll("\\\\","\\\\\\\\"));
            }
            strScript = strScript.replaceAll("(?i)@@FDU_TRANSFER_FILE", objFiles[i].getCanonicalPath().replaceAll("\\\\","\\\\\\\\"));
            strScript = strScript.replaceAll("(?i)@@FDU_ABSOLUTE_LOG_FILE", objConfiguration.getAttribute("absoluteLogFile").replaceAll("\\\\","\\\\\\\\"));
            objConfiguration.putLogLine("--------> PROCESS TRANSFER - File=(" + objFiles[i].getCanonicalPath() + ") Script=(" + strScript + ")");
            objConfiguration.putLogLine("-----------> **START SCRIPT OUTPUT**");
            objConfiguration.putLogLine("-----------> " + objConfiguration.processTransfer(cstrType, objFiles[i].getCanonicalPath(), strScript));  
            objConfiguration.putLogLine("-----------> **END SCRIPT OUTPUT**");
         }
      }
         
      } catch(Exception objException) {
         objConfiguration.putLogLine("--------> **EXCEPTION** - Transfer failed - " + objException.getMessage());
         throw new Exception("Transfer action Exception");
      }
      
   }

}